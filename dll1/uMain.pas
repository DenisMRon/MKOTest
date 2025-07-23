unit uMain;

interface

uses uTaskInterface, System.Classes, System.SysUtils;

function GetTasks: TArray<ITask>;
procedure Init(aThreadFab: TFunc<ITask, ILog, TProc<ITask, ITaskThread>, ITaskThread>);


implementation

uses System.Generics.Collections, System.StrUtils, System.IOUtils,
     uTask, uTaskParam;

var vTasks: TList<ITask>;

procedure Init(aThreadFab: TFunc<ITask,ILog,TProc<ITask, ITaskThread>, ITaskThread>);
begin
   vThreadFab:=aThreadFab;
end;


procedure FileSearch(const dirName:string; const mask: string; OnSearch: TProc<string>; aThread: ITaskThread);
var
  searchResult: TSearchRec;
begin
  if aThread.Terminated then Exit;
  if FindFirst(IncludeTrailingPathDelimiter(dirName) + mask, faAnyFile, searchResult)=0 then begin
    try
      repeat
       if aThread.Terminated then Exit;
        if (searchResult.Attr and faDirectory)=0 then begin
            OnSearch(IncludeTrailingPathDelimiter(dirName)+searchResult.Name);
        end;
      until FindNext(searchResult)<>0
    finally
      FindClose(searchResult);
    end;
  end;
  if aThread.Terminated then Exit;
  if FindFirst(IncludeTrailingPathDelimiter(dirName) + '*' , faDirectory, searchResult)=0 then begin
    try
      repeat
        if aThread.Terminated then Exit;
        if ((searchResult.Attr and faDirectory) <> 0) and
           (searchResult.Name<>'.') and (searchResult.Name<>'..') then begin
          FileSearch(IncludeTrailingPathDelimiter(dirName)+searchResult.Name, mask, OnSearch, aThread);
        end;
      until FindNext(searchResult)<>0
    finally
      FindClose(searchResult);
    end;
  end;
end;


function GetTasks: TArray<ITask>;
begin
  Result:=vTasks.ToArray;
end;

initialization

  vTasks:=TList<ITask>.Create;
  vTasks.Add(TTask.Create('Поиск файла по маске',
                      [TTaskParam.Create('Путь', function(aValue: string): string
                       begin
                         if DirectoryExists(aValue) then
                           Result:=EmptyStr
                         else
                           Result:='Путь не существует';
                       end),
                       TTaskParam.Create('Маска', nil)],
                       '+Маска',
  function (aTask: ITask): ITaskParam
  var vName: string;
  begin
    vName:='Маска ' + IntToStr(Length(aTask.GetParams) - 1);
    Result:=TTaskParam.Create(vName, nil);
  end,
  nil,
  procedure(aTask:ITask; aThread: ITaskThread)
  var vPath, vMask: string;
      vParams: TArray<ITaskParam>;
      I: Integer;
      vCnt: Integer;
  begin
    if aThread.Terminated then Exit;

    vParams:=aTask.GetParams;
    vPath:=vParams[0].Value;
    aThread.Log('Поиск файлов в папке ' + vPath);

    if DirectoryExists(vPath) then
    for I:=1 to High(vParams) do
    begin
      if aThread.Terminated then Exit;
      vMask:=vParams[I].Value;
      aThread.Log('Поиск файлов по маске ' + vMask);

      vCnt:=0;
      aTask.TaskResult:=IntToStr(vCnt);
      FileSearch(vPath, vMask, procedure (aFile: string)
      begin
        aThread.Log('Найден файл ' + aFile);
        Inc(vCnt);
        aTask.TaskResult:=IntToStr(vCnt);
      end, aThread);
    end;
  end));

  vTasks.Add(TTask.Create('Поиск вхождений последовательностей символов',
                      [TTaskParam.Create('Файл', function(aValue: string): string
                       begin
                         if FileExists(aValue) then
                           Result:=EmptyStr
                         else
                           Result:='Файл не существует';
                       end),
                       TTaskParam.Create('Символы', nil)],
                       '+Символы',
  function (aTask: ITask): ITaskParam
  var vName: string;
  begin
    vName:='Символы ' + IntToStr(Length(aTask.GetParams) - 1);
    Result:=TTaskParam.Create(vName, nil);
  end,
  nil,
  procedure(aTask:ITask; aThread: ITaskThread)
  var vPath, vMask: string;
      vParams: TArray<ITaskParam>;
      I: Integer;
      vPos, vCnt: Integer;
      S: string;
  begin
    if aThread.Terminated then Exit;

    vParams:=aTask.GetParams;
    vPath:=vParams[0].Value;
    aThread.Log('Поиск в файле ' + vPath);

    if FileExists(vPath) then
    for I:=1 to High(vParams) do
    begin
      if aThread.Terminated then Exit;
      vMask:=vParams[I].Value;
      aThread.Log('Поиск вхождений последовательности символов ' + vMask);

      vPos:=0;
      vCnt:=0;
      aTask.TaskResult:=IntToStr(vCnt);

      S:=TFile.OpenText(vPath).readtoEnd;
      repeat
        if aThread.Terminated then Exit;
        Inc(vPos);
        vPos:=System.StrUtils.PosEx(vMask, S, vPos);
        if vPos > 0 then
        begin
          aThread.Log('Найдено вхождение в позиции ' + IntToStr(vPos));
          Inc(vCnt);
          aTask.TaskResult:=IntToStr(vCnt);
        end;
      until vPos = 0;
    end;
  end));
end.
