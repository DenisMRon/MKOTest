unit uTaskParam;

interface

uses uTaskInterface, uNamed;

type

  TCheckFunc = reference to function (aValue: string): string;

  TTaskParam = class(TNamed, ITaskParam)
    private
      FValue: string;
      FCheck: TCheckFunc;
    protected
      function GetValue: string;
      procedure SetValue(aValue: string);
      function Check: string;
    public
      constructor Create(aName: string; aCheck: TCheckFunc);
  end;

implementation

uses System.SysUtils, System.Classes;

{ TTaskParam }

function TTaskParam.Check: string;
begin
  if Assigned(FCheck) then
    Result:=FCheck(FValue)
  else
    Result:=EmptyStr;
end;

constructor TTaskParam.Create(aName: string; aCheck: TCheckFunc);
begin
  inherited Create(aName);
  FCheck:=aCheck;
end;

function TTaskParam.GetValue: string;
begin
  Result:=FValue;
end;

procedure TTaskParam.SetValue(aValue: string);
begin
  FValue:=aValue;
end;

end.
