unit ufrmMain;

interface

uses uTaskInterface, System.Generics.Collections, System.SyncObjs,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    Memo1: TMemo;
    lbTask: TListBox;
    pTask: TPanel;
    pButtons: TPanel;
    pParams: TPanel;
    btnStart: TButton;
    btnStop: TButton;
    btnAddParam: TButton;
    pResult: TPanel;
    mResult: TMemo;
    lbResult: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbTaskClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnAddParamClick(Sender: TObject);
  private

    vTask: TList<ITask>;
    vLog: ILog;
    vDll: TList<HMODULE>;
    vEvent: TEvent;
    procedure LoadDll(aName: string);
    procedure Check(Sender: TObject);
    procedure DolbTaskClick;
    procedure ClearEditFrame;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses uTaskParam, uTaskThread, uParamFrame, uEditFrame,  uTask, uLog,
System.IniFiles;

{$R *.dfm}

procedure TfrmMain.btnAddParamClick(Sender: TObject);
begin
  vTask.Items[lbTask.ItemIndex].AddParam;
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  vTask.Items[lbTask.ItemIndex].Status:=ttsWork;
end;

procedure TfrmMain.btnStopClick(Sender: TObject);
begin
  vTask.Items[lbTask.ItemIndex].Status:=ttsIdle;
end;

procedure TfrmMain.Check(Sender: TObject);
begin
  if vTask.Items[lbTask.ItemIndex].Status = ttsIdle then
  btnStart.Enabled:=True;
  for var I in vTask.Items[lbTask.ItemIndex].GetParams do
    if Length(I.Check) > 0 then
    begin
      btnStart.Enabled:=False;
      Break;
    end;
end;

procedure TfrmMain.ClearEditFrame;
var vFrame: TFrame;
begin
  while pParams.ControlCount > 0 do
  begin
    vFrame:=pParams.Controls[0] as TEditFrame;
    vFrame.Parent:=nil;
    FreeAndNil(vFrame);
  end;
end;

procedure TfrmMain.DolbTaskClick;
begin
  lbTaskClick(Self);
end;

function CheckEmpty(aValue: string): string;
begin
  if Length(aValue) = 0 then
    Result:='пустое значение'
  else
    Result:=EmptyStr;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var ST: TstringList;
    I: Integer;
    S: string;
begin
  vDll:=TList<HMODULE>.Create;
  vTask:=TList<ITask>.Create;
  vEvent:=TEvent.Create(nil, True, False, '');
  vLog:=TLog.Create('Лог');
  vLog.Subscribe(procedure(aTask: ITask; aMsg: string)
  begin
    Memo1.Lines.Add(aTask.Name + ' - ' + aMsg);
    mResult.Lines.Text:=aTask.TaskResult;
  end,
  procedure(aTask: ITask)
  begin
    lbTaskClick(Self);
  end);

  ST:=TStringList.Create;
  try
    with TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini')) do
    begin
      ReadSection('load', ST);
      for I:=0 to ST.Count - 1 do
      begin
        S:=ReadString('load', ST[I], '');
        if FileExists(S) then
          LoadDll(S);
      end;

    end;
  finally
    FreeAndNil(ST);
  end;


  for var t in vTask do
    lbTask.Items.Add(T.Name);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(vEvent);
  FreeAndNil(vTask);
  for var H in vDll do
    FreeLibrary(H);
  FreeAndNil(vDll);
  ClearEditFrame;
end;

procedure TfrmMain.lbTaskClick(Sender: TObject);
var vFrame: TEditFrame;
begin
  btnStart.Enabled:=False;
  btnStop.Enabled:=False;

  if lbTask.ItemIndex > -1 then
  begin
    mResult.Lines.Text:=vTask.Items[lbTask.ItemIndex].TaskResult;
    btnStart.Enabled:=vTask.Items[lbTask.ItemIndex].Status = ttsIdle;
    btnStop.Enabled:=vTask.Items[lbTask.ItemIndex].Status = ttsWork;

    btnAddParam.Caption:=vTask.Items[lbTask.ItemIndex].AddParamCaption;
    btnAddParam.Visible:=Length(btnAddParam.Caption) > 0;

    ClearEditFrame;

    for var I in vTask.Items[lbTask.ItemIndex].GetParams do
    begin
      vFrame:=TEditFrame.Create(I, Check);
      vFrame.Parent:=pParams;
      vFrame.eParamValue.Text:=I.Value;
      vFrame.Enabled:=not btnStop.Enabled;
    end;
  end;
end;

type
  TGetTasks = function: TArray<ITask>;
  TInit = procedure (aThreadFab: TFunc<ITask, ILog, TProc<ITask, ITaskThread>, ITaskThread>);

procedure TfrmMain.LoadDll(aName: string);
var Handle: HMODULE;
    GetTasks: TGetTasks;
    Init: TInit;
begin
  Handle:=LoadLibrary(PWideChar(aName));
  if Handle <> 0 then
  begin
    @Init := GetProcAddress(Handle, 'Init');
    if @Init <> nil then
      Init(function (aTask: ITask; aLog: ILog; aProc: TProc<ITask, ITaskThread>): ITaskThread
      begin
        Result:=TTaskThread.Create(aTask, aLog, aProc);
      end);
    @GetTasks := GetProcAddress(Handle, 'GetTasks');
    if @GetTasks <> nil then
    for var Task in GetTasks do
    begin
      Task.Log:=vLog;
      vTask.Add(Task);
    end;
  end
  else
    raise Exception.Create(aName + ' не  найдена');
end;

end.

