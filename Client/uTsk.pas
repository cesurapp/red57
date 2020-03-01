unit uTsk;

interface

uses
  Windows, Classes, StrUtils, SysUtils, uFnc, uEnc;

type
  TTskDt = class
    Name: string;
    Path: string;
    Force: Boolean;
    Level: string;  // LIMITED - HIGHEST
    Delay: string;  // dddd:ss
    Timer: string;  // ONSTART - ONLOGON - HOURLY
    Acc: string;    // Administrator - NT AUTHORITY\SYSTEM - NT AUTHORITY\LOCALSERVICE
  end;

type
  TTsk = class(TComponent)
  public
    constructor Create(AOwner: TComponent; OpeS : String);
    function Add(D: TTskDt): Boolean;
    function AddXml(Name, XlPat: string; Force: Boolean): Boolean;
    function Remove(Name: string; Force: Boolean): Boolean;
    function Check(Name: string): Boolean;
    function Run(Name: string): Boolean;
    function Stop(Name: string): Boolean;
  end;

implementation

var
  Query: string;
  Output: string;
  OS: String;

constructor TTsk.Create(AOwner: TComponent; OpeS : String);
begin
  inherited Create(AOwner);
  OS :=OpeS;
end;

function TTsk.Add(D: TTskDt): Boolean;
begin
  if OS = 'XP' then
    // schtasks /CREATE /TN "%s" /TR "%s" /RU "%s" /SC "%s"
    Query := Format(DE('6BABfEfta7Mr28xDl6+HvSCXyjC497w9+VOeq5U9uClo8aRG9PSMk/dZTaRE2pdlD6T1t1Ys66M'), [D.Name, D.Path, D.Acc, D.Timer])
  else
    // schtasks /CREATE /TN "%s" /TR "%s" /RL %s /RU "%s" /SC "%s" /DELAY %s %s
    Query := Format(DE('6BABfEfta7Mr28xDl6+HvSCXyjC497w9+VOeq5U9umifu48NtOmZnWT5v4kM4SfEgvBKXjarBcuEPpJddlX5N2rM2o5KmPVr'), [D.Name, D.Path, D.Level, D.Acc, D.Timer, D.Delay, IfThen(D.Force, '/F', '')]);
  Result := GtDoOu(Output, Query, '', 10000);
end; { Add -> Zamanlanmýþ Görev Ekler }

function TTsk.AddXml(Name, XlPat: string; Force: Boolean): Boolean;
begin
  // schtasks /CREATE /XML "%s" /TN "%s" %s
  Query := Format(DE('6BABfEfta7Mr28xDl6+HvSCX+7FxVyAnnPyiEWRx5oe+EHV3Z+D'), [XlPat, Name, IfThen(Force, '/F', '')]);
  Result := GtDoOu(Output, Query, '', 10000);
end; { AddXml -> Zamanlanmýþ Görev Ekler }

function TTsk.Remove(Name: string; Force: Boolean): Boolean;
begin
  // schtasks /DELETE%s /TN "%s"
  Query := Format(DE('6BABfEfta7Mr2gR/dn/sWymvw+BF3eK3xKOf'), [IfThen(Force, ' /F', ''), Name]);
  Result := GtDoOu(Output, Query, '', 10000);
end; { Remove -> Zamanlanmýþ Görevi Siler }

function TTsk.Check(Name: string): Boolean;
begin
  // schtasks /QUERY /TN "%s"
  Query := Format(DE('6BABfEfta7Mr20AjVu7YIMMDptPCKKbW'), [Name]);
  Result := GtDoOu(Output, Query, '', 10000);
end; { Check -> Zamanlanmýþ Görevi Denetler }

function TTsk.Run(Name: string): Boolean;
begin
  // schtasks /RUN /TN "%s"
  Query := Format(DE('6BABfEfta7Mr24g8k/XAC9/eCEDxRA'), [Name]);
  Result := GtDoOu(Output, Query, '', 10000);
end; { Run -> Zamanlanmýþ Görevi Çalýþtýrýr }

function TTsk.Stop(Name: string): Boolean;
begin
  // schtasks /END /TN "%s"
  Query := Format(DE('6BABfEfta7Mr2kByqsIBxAHvMQpbOB'), [Name]);
  Result := GtDoOu(Output, Query, '', 10000);
end; { Stop -> Zamanlanmýþ Görevi Durdurur }

end.

