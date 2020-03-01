unit uUsb;

interface

uses Windows, Messages, Classes, SysUtils, Registry, Masks, uWin, uEnc;

type
  PDevBroadcastDeviceInterface = ^DEV_BROADCAST_DEVICEINTERFACE;
  DEV_BROADCAST_DEVICEINTERFACE = record
    dbcc_size: DWORD;
    dbcc_devicetype: DWORD;
    dbcc_reserved: DWORD;
    dbcc_classguid: TGUID;
    dbcc_name: char;
  end;

  PDEV_BROADCAST_VOLUME = ^DEV_BROADCAST_VOLUME;
  DEV_BROADCAST_VOLUME = record
    dbcv_size: DWORD;
    dbcv_devicetype: DWORD;
    dbcv_reserved: DWORD;
    dbcv_unitmask: DWORD;
    dbcv_flags: WORD;
  end;

const
  GUID_DEVINTERFACE_USB_DEVICE: TGUID = '{A5DCBF10-6530-11D2-901F-00C04FB951ED}';
  DBT_DEVICEARRIVAL = $8000; // System detected a new device
  DBT_DEVICEREMOVECOMPLETE = $8004; // Device is gone
  DBT_DEVTYP_DEVICEINTERFACE = $00000005; // Device interface class
  DBT_DEVTYP_VOLUME = $00000002; // Device interface class
  DBTF_MEDIA = $0001;
  DBTF_NET = $0002;

var
  // Registry Keys
  UBK: String;          // 'SYSTEM\CurrentControlSet\Enum\USB\%s\%s'
  UBSTK: String;        // SYSTEM\CurrentControlSet\Enum\USBSTOR
  SBK1: String;         // UBSTK + '\%s'
  SBK2: String;         // SBK1 + '\%s'

type
  { Event Types }
  TOnDvVoEv = procedure(const bInserted : boolean; const sDrive : string) of object; // TOnDevVolumeEvent
  TOnUsChEv = procedure(const bInserted : boolean; const ADevType,ADriverName, AFriendlyName : string) of object; // TOnUsbChangeEvent
  TUsNo = class // TUsbNotifier
  private
    FWndHa: HWND;
    FOnUsChEv : TOnUsChEv; // FOnUsbChangeEvent
    FOnDvVoEv : TOnDvVoEv; // FOnDevVolumeEvent
    procedure WnMt(var AMessage: TMessage); // WinMethod
    procedure WMDvCh(var AMessage: TMessage); // WMDeviceChange
    procedure GtUbIn(const ADeviceString: string; out ADevType, ADriverDesc, AFriendlyName: string); // GetUsbInfo
    function DrLet(const aUM: Cardinal): string; // DriverLetter
  public
    constructor Create;
    property OnUbChe : TOnUsChEv read FOnUsChEv write FOnUsChEv; // OnUsbChange
    property OnDvVo : TOnDvVoEv read FOnDvVoEv write FOnDvVoEv; // OnDevVolume
    destructor Destroy; override;
  end;

implementation

constructor TUsNo.Create;
var
  rDbi: DEV_BROADCAST_DEVICEINTERFACE;
  iSize: integer;
begin
  inherited Create;

  // Default Reg Pointer
  UBK := DE('axczgWhXZu+ViMdgo8Ba1/FoNPWjIKWivJzMaO14MruCv0+zV+Fe');
  UBSTK := DE('axczgWhXZu+ViMdgo8Ba1/FoNPWjIKWivJzMaO14MruCgsvtWD');
  SBK1 := UBSTK + '\%s';
  SBK2 := SBK1 + '\%s';

  FWndHa := AllocateHWnd(WnMt);
  iSize := SizeOf(DEV_BROADCAST_DEVICEINTERFACE);
  ZeroMemory(@rDbi, iSize);
  rDbi.dbcc_size := iSize;
  rDbi.dbcc_devicetype := DBT_DEVTYP_DEVICEINTERFACE;
  rDbi.dbcc_reserved := 0;
  rDbi.dbcc_classguid := GUID_DEVINTERFACE_USB_DEVICE;
  rDbi.dbcc_name := #0;
  RDN(FWndHa, @rDbi, DEVICE_NOTIFY_WINDOW_HANDLE);
end;

destructor TUsNo.Destroy;
begin
  DeallocateHWnd(FWndHa);
  inherited Destroy;
end;

procedure TUsNo.WnMt(var AMessage: TMessage);
begin
  if (AMessage.Msg = WM_DEVICECHANGE) then
    WMDvCh(AMessage)
  else
    AMessage.Result := DefWindowProc(FWndHa, AMessage.Msg, AMessage.wParam, AMessage.lParam);
end;

procedure TUsNo.WMDvCh(var AMessage: TMessage);
var
  iDevType: integer;
  sDevString, sDevType,
  sDriverName, sFriendlyName: string;
  pData: PDevBroadcastDeviceInterface;
  pVol: PDEV_BROADCAST_VOLUME;
begin
  if (AMessage.wParam = DBT_DEVICEARRIVAL) or (AMessage.wParam = DBT_DEVICEREMOVECOMPLETE) then
  begin
    pData := PDevBroadcastDeviceInterface(AMessage.LParam);
    iDevType := pData^.dbcc_devicetype;

    if iDevType = DBT_DEVTYP_VOLUME then
      if Assigned(FOnDvVoEv) then begin
        pVol := PDEV_BROADCAST_VOLUME(AMessage.LParam);
        FOnDvVoEv((AMessage.wParam = DBT_DEVICEARRIVAL), DrLet(pVol.dbcv_unitmask));
      end
      else
    else
    if iDevType = DBT_DEVTYP_DEVICEINTERFACE then begin
      sDevString := PChar(@pData^.dbcc_name);
      GtUbIn(sDevString,sDevType,sDriverName,sFriendlyName);
      if Assigned(FOnUsChEv) then
         FOnUsChEv((AMessage.wParam = DBT_DEVTYP_VOLUME), sDevType,sDriverName,sFriendlyName);
    end;
  end;
end;

procedure TUsNo.GtUbIn(const ADeviceString: string;
  out ADevType, ADriverDesc,
  AFriendlyName: string);
var sWork, sKey1, sKey2: string;
  oKeys, oSubKeys: TStringList;
  oReg: TRegistry;
  i, ii: integer;
  bFound: boolean;
begin
  ADevType := '';
  ADriverDesc := '';
  AFriendlyName := '';

  if ADeviceString <> '' then begin
    bFound := false;
    oReg := TRegistry.Create;
    oReg.RootKey := HKEY_LOCAL_MACHINE;

    sWork := copy(ADeviceString, pos('#', ADeviceString) + 1, 1026);
    sKey1 := copy(sWork, 1, pos('#', sWork) - 1);
    sWork := copy(sWork, pos('#', sWork) + 1, 1026);
    sKey2 := copy(sWork, 1, pos('#', sWork) - 1);

    // Get the Device type description from \USB key
    if oReg.OpenKeyReadOnly(Format(UBK, [skey1, sKey2])) then begin
      ADevType := oReg.ReadString('DeviceDesc');
      oReg.CloseKey;
      oKeys := TStringList.Create;
      oSubKeys := TStringList.Create;

      if oReg.OpenKeyReadOnly(UBSTK) then begin
        oReg.GetKeyNames(oKeys);
        oReg.CloseKey;

        // Iterate through list to find our sKey2
        for i := 0 to oKeys.Count - 1 do begin
          if oReg.OpenKeyReadOnly(Format(SBK1, [oKeys[i]])) then begin
            oReg.GetKeyNames(oSubKeys);
            oReg.CloseKey;

            for ii := 0 to oSubKeys.Count - 1 do begin
              if MatchesMask(oSubKeys[ii], sKey2 + '*') then begin
                if oReg.OpenKeyReadOnly(Format(SBK2, [oKeys[i],
                  oSubKeys[ii]])) then begin
                  ADriverDesc := oReg.ReadString('DeviceDesc');
                  AFriendlyName := oReg.ReadString('FriendlyName');
                  oReg.CloseKey;
                end;
                bFound := true;
              end;
            end;
          end;

          if bFound then break;
        end;
      end;

      FreeAndNil(oKeys);
      FreeAndNil(oSubKeys);
    end;

    FreeAndNil(oReg);
  end;
end;

function TUsNo.DrLet(const aUM: Cardinal): string;
begin
  case aUM of
    1: result := 'A';
    2: result := 'B';
    4: result := 'C';
    8: result := 'D';
    16: result := 'E';
    32: result := 'F';
    64: result := 'G';
    128: result := 'H';
    256: result := 'I';
    512: result := 'J';
    1024: result := 'K';
    2048: result := 'L';
    4096: result := 'M';
    8192: result := 'N';
    16384: result := 'O';
    32768: result := 'P';
    65536: result := 'Q';
    131072: result := 'R';
    262144: result := 'S';
    524288: result := 'T';
    1048576: result := 'U';
    2097152: result := 'V';
    4194304: result := 'W';
    8388608: result := 'X';
    16777216: result := 'Y';
    33554432: result := 'Z';
  end;

  Result := Result + ':';
end;


end.

