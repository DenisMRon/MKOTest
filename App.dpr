program App;

uses
  sharemem,
  Vcl.Forms,
  ufrmMain in 'ufrmMain.pas' {frmMain},
  uTaskInterface in 'uTaskInterface.pas',
  uTask in 'uTask.pas',
  uNamed in 'uNamed.pas',
  uTaskParam in 'uTaskParam.pas',
  uLog in 'uLog.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
