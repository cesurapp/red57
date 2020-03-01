unit uFunctions;

interface

uses
  Windows, Messages, Classes, Sysutils, StdCtrls, ComCtrls, Winsock, Graphics, MMSystem, WinInet, uTypes, uSockets, Dialogs;

function GetLocalIP: Tstrings;
function GetRandomStr(PLen: Integer): string;
function GetInetData(const aUrl: string): string;
function GetTempDir: string;
function FormatSize(const bytes: Longint): string;
procedure PlaySound(const AResName: string);
procedure AddLog(Status: TRichEdit; Color: TColor; Text: string);
procedure ShowClientProcessForm(App: TComponent; FormClass: TCFormClass; FormID: string; Client: TTCPConnection);
procedure ExecuteThreadForm(FormClass: TCFormClass; FormID: string; Client: TTCPConnection; CMD: String = '');
function UserFolder(uData: TObject; Extension: String = ''; Folder: String = ''): String;
function BoolToString(Bl: Boolean): string;

implementation

function GetLocalIP: Tstrings;
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
end; {* Get Local IP Adress *}

function GetRandomStr(PLen: Integer): string;
var
  str: string;
begin
  Randomize;
  str := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789';
  Result := '';
  repeat
    Result := Result + str[Random(Length(str)) + 1];
  until (Length(Result) = PLen)
end; { * GetRandomStr -> Rastgele Karakter Oluþturur * }

function GetInetData(const aUrl: string): string;
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
          if dwBytesRead = 0 then
            break;
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
end; { MyGetInetData -> Internetten String olarak veri okur }

function GetTempDir: string;
var
  tempFolder: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, @tempFolder);
  result := StrPas(tempFolder);
end; {* GetTempDir -> Temp Dizinini Verir *}

function FormatSize(const bytes: Longint): string;
const
  B = 1;
  KB = 1024 * B;
  MB = 1024 * KB;
  GB = 1024 * MB;
begin
  if bytes <> 0 then
  begin
    if bytes > GB then
      result := FormatFloat('#.## GB', bytes / GB)
    else if bytes > MB then
      result := FormatFloat('#.## MB', bytes / MB)
    else if bytes > KB then
      result := FormatFloat('#.## KB', bytes / KB)
    else
      result := FormatFloat('#.## bytes', bytes);
  end
  else
    result := '';
end;

procedure PlaySound(const AResName: string);
var
  HResource: TResourceHandle;
  HResData: THandle;
  PWav: Pointer;
begin
  HResource := FindResource(HInstance, PChar(AResName), 'WAV');
  if HResource <> 0 then
  begin
    HResData := LoadResource(HInstance, HResource);
    if HResData <> 0 then
    begin
      PWav := LockResource(HResData);
      if Assigned(PWav) then
      begin
        sndPlaySound(nil, SND_NODEFAULT);
        sndPlaySound(PWav, SND_ASYNC or SND_MEMORY);
      end;
    end;
  end
  else
    RaiseLastOSError;
end; { * PlaySound -> Ses Çalar * }

procedure AddLog(Status: TRichEdit; Color: TColor; Text: string);
begin
  // Rengi Ayarla
  Status.SelAttributes.Color := Color;

  // Yazýyý Gir
  Status.Lines.Add(Text + ' ');

  // Scrollbar en sona ilerler
  SendMessage(Status.Handle, WM_VSCROLL, SB_BOTTOM, 0);
  SendMessage(Status.Handle, EM_SETSEL, Status.GetTextLen - 1, Status.GetTextLen);
  SendMessage(Status.Handle, EM_REPLACESEL, 0, LPARAM(PChar('')));
end; { * AddLog -> Log'a Renkli Yazý Ekler * }

procedure ShowClientProcessForm(App: TComponent; FormClass: TCFormClass; FormID: string; Client: TTCPConnection);
var
  Form: TCForm;
begin
  // Create Form
  with TClientData(Client.Data) do
    if Forms.IndexOf(FormID) = -1 then begin
      Form := FormClass.Create(App, Client, FormID);
      Forms.AddObject(FormID, Form);
      Form.Show;
    end else
      TCForm(Forms.Objects[Forms.IndexOf(FormID)]).Show;
end; { ShowClientProcessForm ->Client Ýþlemleri için Form Gösterir }

procedure ExecuteThreadForm(FormClass: TCFormClass; FormID: string; Client: TTCPConnection; CMD: String = '');
begin
  with TClientData(Client.Data) do begin
    TCForm(Forms.Objects[Forms.IndexOf(FormID)]).ExecuteThread(CMD);
  end;
end; { ShowClientProcessForm ->Client Ýþlemleri için Form Gösterir }

function UserFolder(uData: TObject; Extension: String = ''; Folder: String = ''): String;
begin
  with TClientData(uData) do begin
    Result := Format('%sClientData\%s-%s-%s', [IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))), Username, PCName, MacAddr]);
  end;

  if Folder <> '' then
    Result := Result + '\' + Folder;

  if not DirectoryExists(Result) then
    ForceDirectories(Result);

  if Extension <> '' then
    Result := Result +'\'+ FormatDateTime('ddhhnnsszzz', Now) + '.' + Extension;
end;

function BoolToString(Bl: Boolean): string;
begin
  if Bl then
    Result := 'True'
  else
    Result := 'False';
end;

end.

