unit uNamed;

interface

uses uTaskInterface;

type

  TNamed = class(TInterfacedObject, INamed)
    private
      FName: string;
    protected
      function GetName: string;
    public
      constructor Create(aName: string);
  end;

implementation
{ TNamed }

constructor TNamed.Create(aName: string);
begin
  inherited Create;
  FName:=aName;
end;

function TNamed.GetName: string;
begin
  Result:=FName;
end;

end.
