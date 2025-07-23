unit uLog;

interface

uses uTaskInterface, uNamed,
     System.Generics.Collections, System.SysUtils, System.Classes;

type
  TEventItem = record
    OnAdd: TProc<ITask, string>;
    OnStatus: TProc<ITask>;
    constructor Create(aOnAdd: TProc<ITask, string>; aOnStatus: TProc<ITask>);
  end;
  TMsgItem = record
    Task: ITask;
    Msg: string;
    constructor Create(aTask: ITask; aMsg: string);
  end;

  TLog = class(TNamed, ILog)
    private
      FList: TList<TMsgItem>;
      FSubscribers: TList<TEventItem>;
    protected
      procedure Subscribe(aOnAdd: TProc<ITask, string>; aOnStatus: TProc<ITask>);
      procedure Add(aTask: ITask; aMsg: string);
      procedure Status(aTask: ITask);
      procedure Write;
    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;
  end;

implementation

{ TLog }

procedure TLog.Add(aTask: ITask; aMsg: string);
begin
  TMonitor.Enter(Self);
  try
    FList.Add(TMsgItem.Create(aTask, aMsg));
    Write;
    TMonitor.PulseAll(Self);
  finally
    TMonitor.Exit(Self);
  end;
end;

procedure TLog.AfterConstruction;
begin
  inherited;
  FList:=TList<TMsgItem>.Create;
  FSubscribers:=TList<TEventItem>.Create;
end;

procedure TLog.BeforeDestruction;
begin
  FreeAndNil(FSubscribers);
  FreeAndNil(FList);
  inherited;
end;

procedure TLog.Status(aTask: ITask);
begin
  TMonitor.Enter(Self);
  try
    for var Item in FSubscribers do
      Item.OnStatus(aTask);
    TMonitor.PulseAll(Self);
  finally
    TMonitor.Exit(Self);
  end;
end;

procedure TLog.Subscribe(aOnAdd: TProc<ITask, string>; aOnStatus: TProc<ITask>);
begin
  TMonitor.Enter(Self);
  try
    FSubscribers.Add(TEventItem.Create(aOnAdd, aOnStatus));
    TMonitor.PulseAll(Self);
  finally
    TMonitor.Exit(Self);
  end;
end;

procedure TLog.Write;
begin
  for var Msg in FList do
    for var Item in FSubscribers do
      Item.OnAdd(Msg.Task, Msg.Msg);
  FList.Clear;
end;

{ TEventItem }

constructor TEventItem.Create(aOnAdd: TProc<ITask, string>;
  aOnStatus: TProc<ITask>);
begin
  OnAdd:=aOnAdd;
  OnStatus:=aOnStatus;
end;

{ TMsgItem }

constructor TMsgItem.Create(aTask: ITask; aMsg: string);
begin
  Task:=aTask;
  Msg:=aMsg;
end;

end.
