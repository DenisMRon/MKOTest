unit uTaskThread;

interface

uses uTaskInterface, System.Generics.Collections, System.SysUtils, System.Classes;

type

  TTaskThread = class(TThread, ITaskThread)
{$IFNDEF AUTOREFCOUNT}
    private const
      objDestroyingFlag = Integer($80000000);
      function GetRefCount: Integer; inline;
{$ENDIF}
    private
      FExecute: TProc<ITask, ITaskThread>;
      FParent: ITask;
      FLog: ILog;
      FMsg: string;
      FStatus: TTaskStatus;
    protected
{$IFNDEF AUTOREFCOUNT}
      [Volatile] FRefCount: Integer;
      class procedure __MarkDestroying(const Obj); static; inline;
{$ENDIF}
      function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;

      procedure SyncLog;
      function GetTerminated: Boolean;
      function GetStatus: TTaskStatus;
      procedure SetStatus(aValue: TTaskStatus);
      procedure Execute; override;
    public
{$IFNDEF AUTOREFCOUNT}
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;
      class function NewInstance: TObject; override;
      property RefCount: Integer read GetRefCount;
{$ENDIF}
      procedure DoLog;
      procedure DoStatus;
      procedure DoSyncLog;
      property Status: TTaskStatus read GetStatus write SetStatus;
      property Terminated;
      constructor Create(aParent: ITask; aLog: ILog; aExecute: TProc<ITask, ITaskThread>); reintroduce;
      procedure Log(aMsg: string);
  end;



implementation

{ TTaskThread }

procedure TTaskThread.AfterConstruction;
begin
  AtomicDecrement(FRefCount);
end;

procedure TTaskThread.BeforeDestruction;
begin
  if RefCount <> 0 then
    Error(reInvalidPtr);
end;

constructor TTaskThread.Create(aParent: ITask; aLog: ILog;
                               aExecute: TProc<ITask, ITaskThread>);
begin
  inherited Create(True);
  FParent:=aParent;
  FLog:=aLog;
  FExecute:=aExecute;
  FreeOnTerminate:=False;
//  Start;
end;

procedure TTaskThread.DoLog;
begin
  if Assigned(FLog) then
    FLog.Add(FParent, FMsg);
end;

procedure TTaskThread.DoStatus;
begin
  FLog.Status(FParent);
end;

procedure TTaskThread.DoSyncLog;
begin
  FLog:=FParent.Log;
end;

procedure TTaskThread.Execute;
begin
  Status:=ttsWork;
  try
    FParent.TaskResult:=EmptyStr;
    if Assigned(FExecute) then
    try
      FExecute(FParent, Self);
    except
      on E: Exception do
        FLog.Add(FParent, E.Message);
    end;
  finally
    Status:=ttsIdle;
  end;
end;

function TTaskThread.GetRefCount: Integer;
begin
  Result := FRefCount and not objDestroyingFlag;
end;

function TTaskThread.GetStatus: TTaskStatus;
begin
  Result:=FStatus;
end;

function TTaskThread.GetTerminated: Boolean;
begin
  Result:=Terminated;
end;

procedure TTaskThread.Log(aMsg: string);
begin
  FMsg:=aMsg;
  Synchronize(DoLog);
end;

class function TTaskThread.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TTaskThread(Result).FRefCount := 1;
end;

function TTaskThread.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TTaskThread.SetStatus(aValue: TTaskStatus);
begin
  FStatus:=aValue;
  Synchronize(DoStatus);
//  DoStatus;
end;

procedure TTaskThread.SyncLog;
begin
  Synchronize(DoSyncLog);
end;

function TTaskThread._AddRef: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicIncrement(FRefCount);
{$ELSE}
  Result := __ObjAddRef;
{$ENDIF}
end;

function TTaskThread._Release: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicDecrement(FRefCount);
  if Result = 0 then
  begin
    // Mark the refcount field so that any refcounting during destruction doesn't infinitely recurse.
    __MarkDestroying(Self);
    Destroy;
  end;
{$ELSE}
  Result := __ObjRelease;
{$ENDIF}
end;

class procedure TTaskThread.__MarkDestroying(const Obj);
var
  LRef: Integer;
begin
  repeat
    LRef := TTaskThread(Obj).FRefCount;
  until AtomicCmpExchange(TTaskThread(Obj).FRefCount, LRef or objDestroyingFlag, LRef) = LRef;
end;

end.
