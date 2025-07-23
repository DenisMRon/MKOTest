unit uParamFrame;

interface

uses Vcl.Forms, System.Classes, uTaskInterface;

type
  TParamFrame = class(TFrame)
  protected
    FParam: ITaskParam;
    FOnChange: TNotifyEvent;
  public
    constructor Create(aParam: ITaskParam; aOnChange: TNotifyEvent); reintroduce; virtual;
  end;


implementation

{ TParamFrame }

constructor TParamFrame.Create(aParam: ITaskParam; aOnChange: TNotifyEvent);
begin
  inherited Create(nil);
  FParam:=aParam;
  FOnChange:=aOnChange;
end;

end.
