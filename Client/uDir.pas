
{********************************************************}
{                                                        }
{    Firesoft Utils Package                              }
{    ShellNotify Component                               }
{                                                        }
{    Copyright (c) Federico Firenze                      }
{    Buenos Aires, Argentina                             }
{                                                        }
{********************************************************}

unit uDir;

{$IFNDEF VER110}
  {$IFNDEF VER120}
    {$IFNDEF VER130}
      {$WARN SYMBOL_PLATFORM OFF}
      {$DEFINE DELPHICLX}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

interface

uses
  Windows, Messages, Classes, ShlObj;

{
 Referencias MSDN:

 http://msdn.microsoft.com/library/default.asp?url=/library/en-us/shellcc/platform/shell/reference/structures/SHChangeNotifyEntry.asp
 http://msdn.microsoft.com/library/default.asp?url=/library/en-us/shellcc/platform/shell/reference/Functions/SHChangeNotifyRegister.asp
 http://msdn.microsoft.com/library/default.asp?url=/library/en-us/shellcc/platform/shell/reference/functions/SHChangeNotifyDeregister.asp
 http://msdn.microsoft.com/library/default.asp?url=/library/en-us/shellcc/platform/shell/reference/functions/shilcreatefrompath.asp
 http://msdn.microsoft.com/library/default.asp?url=/library/en-us/shellcc/platform/shell/reference/structures/SHGetPathFromIDList.asp
}

const
  SHCNF_ACCEPT_INTERRUPTS = $0001;
  SHCNF_ACCEPT_NON_INTERRUPTS = $0002;

  { Mensaje de Notificación de Cambios }
  WM_SHELLNOTIFY = WM_USER + $5000;

type
  SHChangeNotifyEntry = record
    pidl: PItemIDList;
    fRecursive: Boolean;
  end;
  PSHChangeNotifyEntry = ^SHChangeNotifyEntry;

  TItemIDArray = record
    pidl: array[0..1] of PItemIDList
  end;
  PItemIDArray = ^TItemIDArray;

{$EXTERNALSYM SHChangeNotifyRegister}
function SHChangeNotifyRegister(hWnd: HWND; fSources: Integer; fEvents: Longint; wMsg: UINT; cEntries: Integer; pfsne: PSHChangeNotifyEntry): ULONG; stdcall;
{$EXTERNALSYM SHChangeNotifyDeregister}
function SHChangeNotifyDeregister(ulID: ULONG): Boolean; stdcall;
{$EXTERNALSYM SHILCreateFromPath}
function SHILCreateFromPath(pszPath: PChar; ppidl: PSHChangeNotifyEntry; var rgflnOut: PDWORD): HRESULT; stdcall;
{$EXTERNALSYM SHILCreateFromPath}
function SHILCreateFromPathNT(pszPath: LPCWSTR; ppidl: PSHChangeNotifyEntry; var rgflnOut: PDWORD): HRESULT; stdcall;


type
  TShellNotifyEvent = (neAssocChanged, neAttributes, neCreate, neDelete, neDriveAdd, neDriveAddGUI, neDriveRemoved,
                       neMediaInserted, neMediaRemoved, neMkDir, neNetShare, neNetUnshare, neRenameFolder, neRenameItem,
                       neRmDir, neServerDisconnect, neUpdateDir, neUpdateImage, neUpdateItem, neOther);
  TShellNotifyEvents = set of TShellNotifyEvent;
  TSHNotifyEvent = procedure(Sender: TObject; Event: TShellNotifyEvent; Path1, Path2: string) of object;

  TShellNotify = class(TComponent)
  private
    FActive: Boolean;
    FHandle: THandle;
    FNotifyEvents: TShellNotifyEvents;
    FPathList: TStrings;
    FOnNotify: TSHNotifyEvent;
    procedure SetActive(const Value: Boolean);
    procedure SetShellNotifyEvents(const Value: TShellNotifyEvents);
    procedure SetPathList(const Value: TStrings);
  protected
    hNotify: ULONG; { Handle }
    procedure WndProc(var Message: TMessage);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Open;
    procedure Close;

    property Handle: THandle read FHandle;
  published
    property NotifyEvents: TShellNotifyEvents read FNotifyEvents write SetShellNotifyEvents default [neCreate, neDelete, neMkDir, neRenameFolder, neRenameItem, neRmDir];
    property PathList: TStrings read FPathList write SetPathList;
    property Active: Boolean read FActive write SetActive default False; { Tiene que estar por debajo de NotifyEvents y PathList }
    property OnNotify: TSHNotifyEvent read FOnNotify write FOnNotify;
  end;

{$IFNDEF FSUTILS}
procedure Register;
{$ENDIF}

implementation

uses
  SysUtils, ShellApi, Consts{$IFNDEF DELPHICLX}, Forms{$ENDIF};

{$IFNDEF FSUTILS}
procedure Register;
begin
  RegisterComponents('FX', [TShellNotify]);
end;
{$ENDIF}

function SHChangeNotifyRegister;  external shell32 index 2;
function SHChangeNotifyDeregister; external shell32 index 4;
function SHILCreateFromPathNT; external shell32 index 28;
function SHILCreateFromPath; external shell32 index 28;


function NotifyEventsToLongint(ANotifyEvents: TShellNotifyEvents): Longint;
begin
  Result := 0;

  if neAssocChanged in ANotifyEvents Then
    Result := Result or SHCNE_ASSOCCHANGED;

  if neAttributes in ANotifyEvents Then
    Result := Result or SHCNE_ATTRIBUTES;

  if neCreate in ANotifyEvents Then
    Result := Result or SHCNE_CREATE;

  if neDelete in ANotifyEvents Then
    Result := Result or SHCNE_DELETE;

  if neDriveAdd in ANotifyEvents Then
    Result := Result or SHCNE_DRIVEADD;

  if neDriveAddGUI in ANotifyEvents Then
    Result := Result or SHCNE_DRIVEADDGUI;

  if neDriveRemoved in ANotifyEvents Then
    Result := Result or SHCNE_DRIVEREMOVED;

  if neMediaInserted in ANotifyEvents Then
    Result := Result or SHCNE_MEDIAINSERTED;

  if neMediaRemoved in ANotifyEvents Then
    Result := Result or SHCNE_MEDIAREMOVED;

  if neMkDir in ANotifyEvents Then
    Result := Result or SHCNE_MKDIR;

  if neNetShare in ANotifyEvents Then
    Result := Result or SHCNE_NETSHARE;

  if neNetUnshare in ANotifyEvents Then
    Result := Result or SHCNE_NETUNSHARE;

  if neRenameFolder in ANotifyEvents Then
    Result := Result or SHCNE_RENAMEFOLDER;

  if neRenameItem in ANotifyEvents Then
    Result := Result or SHCNE_RENAMEITEM;

  if neRmDir in ANotifyEvents Then
    Result := Result or SHCNE_RMDIR;

  if neServerDisconnect in ANotifyEvents Then
    Result := Result or SHCNE_SERVERDISCONNECT;

  if neUpdateDir in ANotifyEvents Then
    Result := Result or SHCNE_UPDATEDIR;

  if neUpdateImage in ANotifyEvents Then
    Result := Result or SHCNE_UPDATEIMAGE;

  if neUpdateItem in ANotifyEvents Then
    Result := Result or SHCNE_UPDATEITEM;
end;

function LongintToNotifyEvent(AValue: Longint): TShellNotifyEvent;
begin
  case AValue of
    SHCNE_ASSOCCHANGED:
      Result := neAssocChanged;
    SHCNE_ATTRIBUTES:
      Result := neAttributes;
    SHCNE_CREATE:
      Result := neCreate;
    SHCNE_DELETE:
      Result := neDelete;
    SHCNE_DRIVEADD:
      Result := neDriveAdd;
    SHCNE_DRIVEADDGUI:
      Result := neDriveAddGui;
    SHCNE_DRIVEREMOVED:
      Result := neDriveRemoved;
    SHCNE_MEDIAINSERTED:
      Result := neMediaInserted;
    SHCNE_MEDIAREMOVED:
      Result := neMediaRemoved;
    SHCNE_MKDIR:
      Result := neMkDir;
    SHCNE_NETSHARE:
      Result := neNetShare;
    SHCNE_NETUNSHARE:
      Result := neNetUnShare;
    SHCNE_RENAMEFOLDER:
      Result := neRenameFolder;
    SHCNE_RENAMEITEM:
      Result := neRenameItem;
    SHCNE_RMDIR:
      Result := neRmDir;
    SHCNE_SERVERDISCONNECT:
      Result := neServerDisconnect;
    SHCNE_UPDATEDIR:
      Result := neUpdateDir;
    SHCNE_UPDATEIMAGE:
      Result := neUpdateImage;
    SHCNE_UPDATEITEM:
      Result := neUpdateItem;
  else
    Result := neOther;
  end;
end;

function PidlToStr(pidl: PItemIDList): string;
var
  PResult: PChar;
begin
  PResult := StrAlloc(MAX_PATH);
  try
    if not SHGetPathFromIDList(pidl, PResult) then
      Result := ''
    else
      Result := StrPas(PResult);
  finally
    StrDispose(PResult);
  end;
end;

{ TShellNotify }

procedure TShellNotify.Close;
begin
  if hNotify > 0 Then
    SHChangeNotifyDeregister(hNotify);

  if FHandle > 0 Then
    DeallocateHWnd(FHandle);
end;

constructor TShellNotify.Create(AOwner: TComponent);
begin
  inherited;
  FPathList := TStringList.Create;
  FActive := False;
  FNotifyEvents := [neCreate, neDelete, neMkDir, neRenameFolder, neRenameItem, neRmDir];
end;

destructor TShellNotify.Destroy;
begin
  Active := False;
  FPathList.Free;
  inherited;
end;

procedure TShellNotify.Open;
var
  BuffPath: array[0..MAX_PATH] of WideChar;
  iPath,
  cEntries: Integer;
  fEvents: Longint;
  Attr: PDWORD;
  NotifyEntrys: array[0..1023] of SHChangeNotifyEntry; {Si uso un Array dinámico Falla}

  {$IFNDEF DELPHICLX}
  procedure RaiseLastOsError;
  begin
    RaiseLastWin32Error;
  end;
  {$ENDIF}
begin
  if FNotifyEvents = [] Then
    fEvents := SHCNE_ALLEVENTS
  else
    fEvents := NotifyEventsToLongint(FNotifyEvents);


  FHandle := AllocateHWnd(WndProc);
  try
    if FPathList.Count = 0 Then
    begin
      { Notifica cambios de todo el FileSystem }
      cEntries := 1;
      with NotifyEntrys[0] do
      begin
        pidl := nil;
        fRecursive := True;
      end;
    end
    else
    begin
      cEntries := FPathList.Count;
      for iPath := 0 to cEntries-1 do
      begin
        if Win32Platform <> VER_PLATFORM_WIN32_WINDOWS Then
        begin                        
          StringToWideChar(FPathList[iPath], BuffPath, SizeOf(BuffPath));
          if SHILCreateFromPathNT(BuffPath, @NotifyEntrys[iPath], Attr) <> S_OK Then
            RaiseLastOsError;
        end else
        begin
          if SHILCreateFromPath(PChar(FPathList[iPath]), @NotifyEntrys[iPath], Attr) <> S_OK Then
            RaiseLastOsError;
        end;

        NotifyEntrys[iPath].fRecursive := True;
      end;
    end;


    hNotify := SHChangeNotifyRegister(FHandle, SHCNF_ACCEPT_INTERRUPTS + SHCNF_ACCEPT_NON_INTERRUPTS,
                                      fEvents, WM_SHELLNOTIFY, cEntries, @NotifyEntrys);
    if hNotify = 0 then
      RaiseLastOsError;

  except
    Close;
    raise;
  end;
end;

procedure TShellNotify.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
  begin
    if not (csDesigning in ComponentState) then
    begin
      if Value then Open else Close;
    end;
    FActive := Value;
  end;
end;

procedure TShellNotify.SetShellNotifyEvents(const Value: TShellNotifyEvents);
begin
  if FNotifyEvents <> Value Then
  begin
    Active := False; { TODO : Falta Código }
    FNotifyEvents := Value;
  end;
end;

procedure TShellNotify.SetPathList(const Value: TStrings);
begin
  Active := False; { TODO : Falta Código }
  FPathList.Assign(Value);
end;

procedure TShellNotify.WndProc(var Message: TMessage);
var
  NotifyEvent: TShellNotifyEvent;
  pItem: PItemIDArray;
  Path1,
  Path2 : string;
begin
  if Message.Msg = WM_SHELLNOTIFY Then
  begin
    NotifyEvent := LongintToNotifyEvent(Message.LParam and SHCNE_ALLEVENTS);
    pItem := PItemIDArray(Message.wParam);
    Path1 := PidlToStr(pItem^.pidl[0]);

    if NotifyEvent in [neRenameFolder, neRenameItem, neUpdateImage] Then
      Path2 := PidlToStr(pItem^.pidl[1])
    else
      Path2 := '';

    if Assigned(FOnNotify) Then
      FOnNotify(Self, NotifyEvent, Path1, Path2);
  end
  else
    Message.Result := DefWindowProc(FHandle, Message.Msg, Message.wParam, Message.lParam);
end;

end.
