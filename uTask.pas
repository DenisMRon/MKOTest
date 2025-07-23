unit uTask;

interface

uses uTaskInterface, uNamed,
     System.Generics.Collections, System.SysUtils, System.Classes;

type

  TTask = class(TNamed, ITask)
    private
      FParams: TList<ITaskParam>;
      FThread: ITaskThread;
      FLog: ILog;
      FExecute: TProc<ITask, ITaskThread>;
      FTaskResult: string;
      FAddParamCaption: string;
      FAddPAramProc: TFunc<ITask, ITaskParam>;
    protected
      function GetParams: TArray<ITaskParam>;
      procedure AddParam;
      function AddParamCaption: string;

      procedure SetStatus(aValue: TTaskStatus);
      function GetStatus: TTaskStatus;
      function GetTaskResult: string;
      procedure SetTaskResult(aValue: string);

      function GetLog: ILog;
      procedure SetLog(aLog: ILog);

    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;
      constructor Create(aName: string;
                         aParams: array of ITaskParam; aAddPAramCaption: string;
                         aAddPAramProc: TFunc<ITask, ITaskParam>;
                         aLog: ILog; aExecute: TProc<ITask, ITaskThread>);
  end;

  var vThreadFab: TFunc<ITask, ILog, TProc<ITask, ITaskThread>, ITaskThread>;

implementation

uses uTaskParam;

{ TTask }

procedure TTask.AddParam;
var vParam: ITaskParam;
begin
  if Assigned(FAddPAramProc) then
  begin
    vParam:=FAddPAramProc(Self);
    if Assigned(vParam) then
    begin
      FParams.Add(vParam);
      if Assigned(FLog) then
         FLog.Status(Self);
    end;
  end;
end;

function TTask.AddParamCaption: string;
begin
  Result:=FAddParamCaption;
end;

procedure TTask.AfterConstruction;
begin
  inherited;
end;

procedure TTask.BeforeDestruction;
begin
  FThread:=nil;
  FreeAndNil(FParams);
  inherited;
end;

constructor TTask.Create(aName: string;
                         aParams: array of ITaskParam;
                         aAddPAramCaption: string;
                         aAddPAramProc: TFunc<ITask, ITaskParam>;
                         aLog: ILog; aExecute: TProc<ITask, ITaskThread>);
begin
  inherited Create(aName);
  FLog:=aLog;
  FExecute:=aExecute;
  FParams:=TList<ITaskParam>.Create;
  FParams.AddRange(aParams);
  FAddParamCaption:=aAddPAramCaption;
  FAddPAramProc:=aAddPAramProc;
  FThread:=nil;
end;

function TTask.GetLog: ILog;
begin
  Result:=FLog;
end;

function TTask.GetParams: TArray<ITaskParam>;
begin
  Result:=FParams.ToArray;
end;

function TTask.GetStatus: TTaskStatus;
begin
  if Assigned(FThread) then
    Result:=FThread.Status
  else
    Result:=ttsIdle;
end;

function TTask.GetTaskResult: string;
begin
  Result:=FTaskResult;
end;

procedure TTask.SetLog(aLog: ILog);
begin
  FLog:=aLog;
  if Assigned(FThread) then
    FThread.SyncLog;
end;

procedure TTask.SetStatus(aValue: TTaskStatus);
begin
  if aValue <> GetStatus then
  begin
    if aValue = ttsWork then
    begin
      FThread:=vThreadFab(Self, FLog, FExecute);
      FThread.Start;
    end
    else
    begin
      FThread.Log('Выполнение останавливается');
      FThread.Terminate;
    end;
  end;
end;

procedure TTask.SetTaskResult(aValue: string);
begin
  FTaskResult:=aValue;
end;


end.
