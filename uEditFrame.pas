unit uEditFrame;

interface

uses uParamFrame, uTaskInterface,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TEditFrame = class(TParamFrame)
    lParamName: TLabel;
    eParamValue: TEdit;
    procedure eParamValueChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(aParam: ITaskParam; aOnChange: TNotifyEvent); override;
  end;

implementation

{$R *.dfm}

{ TEditFrame }
constructor TEditFrame.Create(aParam: ITaskParam; aOnChange: TNotifyEvent);
begin
  inherited Create(aParam, aOnChange);
  lParamName.AutoSize:=True;
  lParamName.Caption:=FParam.Name;
  eParamValue.Left:=lParamName.Left + lParamName.Width + 10;
  eParamValue.Width:=Width - 10 - eParamValue.Left;
end;
procedure TEditFrame.eParamValueChange(Sender: TObject);
begin
  FParam.Value:=eParamValue.Text;
  Hint:=FParam.Check;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

end.
