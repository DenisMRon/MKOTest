unit uMain;

interface

uses uTaskInterface, System.Classes, System.SysUtils;

function GetTasks: TArray<ITask>;
procedure Init(aThreadFab: TFunc<ITask, ILog, TProc<ITask, ITaskThread>, ITaskThread>);


implementation

uses System.Generics.Collections,
     uTask, uTaskParam, ShellApi, Windows;

var vTasks: TList<ITask>;

procedure Init(aThreadFab: TFunc<ITask,ILog,TProc<ITask, ITaskThread>, ITaskThread>);
begin
   vThreadFab:=aThreadFab;
end;

function GetTasks: TArray<ITask>;
begin
  Result:=vTasks.ToArray;
end;

procedure RunCmdCommand(const ACommand: string; aThread: ITaskThread);
var StartupInfo: TStartupInfo;
    ProcessInfo: TProcessInformation;
    Res: DWORD;
begin
  if aThread.Terminated then Exit;
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);
  // Create the process
  CreateProcess(nil, PChar('cmd.exe /c ' + ACommand), nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);
  try
  // Wait for the process to finish
    repeat
      if aThread.Terminated then Exit;

      Res:=WaitForSingleObject(ProcessInfo.hProcess, 1000);
    until (Res <> WAIT_TIMEOUT);
  // Close process and thread handles
  finally
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end;



initialization

  vTasks:=TList<ITask>.Create;
  vTasks.Add(TTask.Create('Выполнение Shell-команды',
                      [TTaskParam.Create('Команда', nil)],
                       EmptyStr,nil,
  nil,
  procedure(aTask:ITask; aThread: ITaskThread)
  var vPath: string;
      vParams: TArray<ITaskParam>;
  begin
    if aThread.Terminated then Exit;

    vParams:=aTask.GetParams;
    vPath:=vParams[0].Value;
    aThread.Log('Выполнение Shell-команды ' + vPath);
    RunCmdCommand(vPath, aThread);
  end));

end.

