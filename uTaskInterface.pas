unit uTaskInterface;

interface

uses System.Generics.Collections, System.SysUtils, System.Classes;

type

  INamed = interface
    function GetName: string;
    property Name: string read GetName;
  end;

  ITaskParam = interface(INamed)
    function Check: string;
    function GetValue: string;
    procedure SetValue(aValue: string);
    property Value: string read GetValue write SetValue;
  end;

  TTaskStatus = (ttsIdle, ttsWork);

  ILog = interface;

  ITask = interface(INamed)
    function GetParams: TArray<ITaskParam>;
    procedure AddParam;
    function AddParamCaption: string;
    procedure SetStatus(aValue: TTaskStatus);
    function GetStatus: TTaskStatus;
    property Status: TTaskStatus read GetStatus write SetStatus;
    function GetTaskResult: string;
    procedure SetTaskResult(aValue: string);
    property TaskResult: string read GetTaskResult write SetTaskResult;
    function GetLog: ILog;
    procedure SetLog(aLog: ILog);
    property Log: ILog read GetLog write SetLog;
  end;

  ILog = interface
    procedure Subscribe(aOnAdd: TProc<ITask, string>; aOnStatus: TProc<ITask>);
    procedure Add(aTask: ITask; aMsg: string);
    procedure Status(aTask: ITask);
  end;

  ITaskThread = interface
    function GetStatus: TTaskStatus;
    procedure SetStatus(aValue: TTaskStatus);
    property Status: TTaskStatus read GetStatus write SetStatus;
    procedure Log(aMsg: string);
    procedure SyncLog;
    procedure Start;
    procedure Terminate;
    function GetTerminated: Boolean;
    property Terminated: Boolean read GetTerminated;
  end;


implementation

end.
