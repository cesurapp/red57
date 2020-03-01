unit uIcon;

interface

uses
  Windows, Classes, SysUtils, uEnc;

type
  PByte = ^Byte;
  PBitmapInfo = ^BitmapInfo;

type
  PMEMICONDIRENTRY = ^TMEMICONDIRENTRY;
  TMEMICONDIRENTRY = packed record
    bWidth:           Byte;
    bHeight:          Byte;
    bColorCount:      Byte;
    bReserved:        Byte;
    wPlanes:          Word;
    wBitCount:        Word;
    dwBytesInRes:     DWORD;
    nID:              Word;
  end;

  PMEMICONDIR = ^TMEMICONDIR;
  TMEMICONDIR = packed record
    idReserved:       Word;
    idType:           Word;
    idCount:          Word;
    idEntries:        Array[0..15] of TMEMICONDIRENTRY;
  end;

  PICONDIRENTRY = ^TICONDIRENTRY;
  TICONDIRENTRY = packed record
    bWidth:           Byte;
    bHeight:          Byte;
    bColorCount:      Byte;
    bReserved:        Byte;
    wPlanes:          Word;
    wBitCount:        Word;
    dwBytesInRes:     DWORD;
    dwImageOffset:    DWORD;
  end;

  PICONDIR = ^TICONDIR;
  TICONDIR = packed record
    idReserved:       Word;
    idType:           Word;
    idCount:          Word;
    idEntries:        Array[0..0] of TICONDIRENTRY;
  end;

  PICONIMAGE = ^TICONIMAGE;
  TICONIMAGE = packed record
    Width,
    Height,
    Colors:           UINT;
    lpBits:           Pointer;
    dwNumBytes:       DWORD;
    pBmpInfo:         PBitmapInfo;
  end;

  PICONRESOURCE = ^TICONRESOURCE;
  TICONRESOURCE = packed record
    nNumImages:       UINT;
    IconImages:       Array[0..15] of TICONIMAGE;
  end;

  TPageInfo = packed record
    Width:            Byte;
    Height:           Byte;
    ColorQuantity:    Integer;
    Reserved:         DWORD;
    PageSize:         DWORD;
    PageOffSet:       DWORD;
  end;

  TPageDataHeader = packed record
    PageHeadSize:     DWORD;
    XSize:            DWORD;
    YSize:            DWORD;
    SpeDataPerPixSize: Integer;
    ColorDataPerPixSize: Integer;
    Reserved:         DWORD;
    DataAreaSize:     DWORD;
    ReservedArray:    Array[0..15] of char;
  end;

  TIcoFileHeader = packed record
    FileFlag:         Array[0..3] of byte;
    PageQuartity:     Integer;
    PageInfo:         TPageInfo;
  end;

type
  PIcoItemHeader = ^TIcoItemHeader;
  TIcoItemHeader = packed record
    Width: Byte;
    Height: Byte;
    Colors: Byte;
    Reserved: Byte;
    Planes: Word;
    BitCount: Word;
    ImageSize: DWORD;
  end;

  PIcoItem = ^TIcoItem;
  TIcoItem = packed record
    Header: TIcoItemHeader;
    Offset: DWORD;
  end;

  PIcoHeader = ^TIcoHeader;
  TIcoHeader = packed record
    Reserved: Word;
    Typ: Word;
    ItemCount: Word;
    Items: array[0..MaxInt shr 4 - 1] of TIcoItem;
  end;

  PGroupIconDirItem = ^TGroupIconDirItem;
  TGroupIconDirItem = packed record
    Header: TIcoItemHeader;
    Id: Word;
  end;

  PGroupIconDir = ^TGroupIconDir;
  TGroupIconDir = packed record
    Reserved: Word;
    Typ: Word;
    ItemCount: Word;
    Items: array[0..MaxInt shr 4 - 1] of TGroupIconDirItem;
  end;

function ExIcFrFi(ResFileName: string; IcoFileName: string; nIndex: string): Boolean; // ExtractIconFromFile
function ExMaIcFrFi(ResFileName: string; IcoFileName: string): Boolean;               // ExtractMainIconFromFile
function WrIcReToFi(hFile: hwnd; lpIR: PICONRESOURCE): Boolean;                       // WriteIconResourceToFile
function ChIcEx(FileName, IcoFileName: pchar): Boolean;                               // ChangeIconExe

implementation

function WrICHe(hFile: THandle; nNumEntries: UINT): Boolean; // WriteICOHeader
type
  TFIcoHeader = record
    wReserved: WORD;
    wType: WORD;
    wNumEntries: WORD;
  end;
var
  IcoHeader: TFIcoHeader;
  dwBytesWritten: DWORD;
begin
  Result := False;
  IcoHeader.wReserved := 0;
  IcoHeader.wType := 1;
  IcoHeader.wNumEntries := WORD(nNumEntries);
  if not WriteFile(hFile, IcoHeader, SizeOf(IcoHeader), dwBytesWritten, nil) then
  begin
    Result := False;
    Exit;
  end;
  if dwBytesWritten <> SizeOf(IcoHeader) then Exit;
  Result := True;
end;

function CalculateImageOffset(lpIR: PICONRESOURCE; nIndex: UINT): DWORD;
var
  dwSize: DWORD;
  i: Integer;
begin
  dwSize := 3 * SizeOf(WORD);
  inc(dwSize, lpIR.nNumImages * SizeOf(TICONDIRENTRY));
  for i := 0 to nIndex - 1 do
    inc(dwSize, lpIR.IconImages[i].dwNumBytes);
  Result := dwSize;
end;

function WrIcReToFi(hFile: hwnd; lpIR: PICONRESOURCE): Boolean;
var
  i: UINT;
  dwBytesWritten: DWORD;
  ide: TICONDIRENTRY;
  dwTemp: DWORD;
begin
  Result := False;
  for i := 0 to lpIR^.nNumImages - 1 do
  begin
    ide.bWidth := lpIR^.IconImages[i].Width;
    ide.bHeight := lpIR^.IconImages[i].Height;
    ide.bReserved := 0;
    ide.wPlanes := lpIR^.IconImages[i].pBmpInfo.bmiHeader.biPlanes;
    ide.wBitCount := lpIR^.IconImages[i].pBmpInfo.bmiHeader.biBitCount;
    if ide.wPlanes * ide.wBitCount >= 8 then
      ide.bColorCount := 0
    else
      ide.bColorCount := 1 shl (ide.wPlanes * ide.wBitCount);
    ide.dwBytesInRes := lpIR^.IconImages[i].dwNumBytes;
    ide.dwImageOffset := CalculateImageOffset(lpIR, i);
    if not WriteFile(hFile, ide, sizeof(TICONDIRENTRY), dwBytesWritten, nil) then Exit;
    if dwBytesWritten <> sizeof(TICONDIRENTRY) then Exit;
  end;
  for i := 0 to lpIR^.nNumImages - 1 do
  begin
    dwTemp := lpIR^.IconImages[i].pBmpInfo^.bmiHeader.biSizeImage;
    // Set the sizeimage member to zero
    lpIR^.IconImages[i].pBmpInfo^.bmiHeader.biSizeImage := 0;
    // Write the image bits to file
    if not WriteFile(hFile, lpIR^.IconImages[i].lpBits^, lpIR^.IconImages[i].dwNumBytes, dwBytesWritten, nil) then
      Exit;
    if dwBytesWritten <> lpIR^.IconImages[i].dwNumBytes then
      Exit;
    // set it back
    lpIR^.IconImages[i].pBmpInfo^.bmiHeader.biSizeImage := dwTemp;
  end;
  Result := True;
end;

function AdIcImPo(lpImage: PICONIMAGE): Bool; // AdjustIconImagePointers
begin
  if lpImage = nil then
  begin
    Result := False;
    exit;
  end;
  lpImage.pBmpInfo := PBitMapInfo(lpImage^.lpBits);
  lpImage.Width := lpImage^.pBmpInfo^.bmiHeader.biWidth;
  lpImage.Height := (lpImage^.pBmpInfo^.bmiHeader.biHeight) div 2;
  lpImage.Colors := lpImage^.pBmpInfo^.bmiHeader.biPlanes * lpImage^.pBmpInfo^.bmiHeader.biBitCount;
  Result := true;
end;

function ExIcFrFi(ResFileName: string; IcoFileName: string; nIndex: string): Boolean;
var
  h: HMODULE;
  lpMemIcon: PMEMICONDIR;
  lpIR: TICONRESOURCE;
  src: HRSRC;
  Global: HGLOBAL;
  i: integer;
  hFile: hwnd;
begin
  Result := False;
  hFile := CreateFile(pchar(IcoFileName), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if hFile = INVALID_HANDLE_VALUE then Exit;
  h := LoadLibraryEx(pchar(ResFileName), 0, LOAD_LIBRARY_AS_DATAFILE);
  if h = 0 then exit;
  try
    src := FindResource(h, pchar(nIndex), RT_GROUP_ICON);
    if src = 0 then
      Src := FindResource(h, Pointer(StrToInt(nIndex)), RT_GROUP_ICON);
    if src <> 0 then
    begin
      Global := LoadResource(h, src);
      if Global <> 0 then
      begin
        lpMemIcon := LockResource(Global);
        if Global <> 0 then
        begin
          try
            lpIR.nNumImages := lpMemIcon.idCount;
            for i := 0 to lpMemIcon^.idCount - 1 do
            begin
              src := FindResource(h, MakeIntResource(lpMemIcon^.idEntries[i].nID), RT_ICON);
              if src <> 0 then
              begin
                Global := LoadResource(h, src);
                if Global <> 0 then
                begin
                  try
                    lpIR.IconImages[i].dwNumBytes := SizeofResource(h, src);
                  except
                    Result := False;
                    FreeLibrary(h);
                    CloseHandle(hFile);
                    Exit;
                  end;
                  GetMem(lpIR.IconImages[i].lpBits, lpIR.IconImages[i].dwNumBytes);
                  CopyMemory(lpIR.IconImages[i].lpBits, LockResource(Global), lpIR.IconImages[i].dwNumBytes);
                  if not AdIcImPo(@(lpIR.IconImages[i])) then exit;
                end;
              end;
            end;
            if WrICHe(hFile, lpIR.nNumImages) then
              if WrIcReToFi(hFile, @lpIR) then
                Result := True;
          finally
            if Result = True then
              for i := 0 to lpIR.nNumImages - 1 do
                if assigned(lpIR.IconImages[i].lpBits) then
                  FreeMem(lpIR.IconImages[i].lpBits);
          end;
        end;
      end;
    end;
  finally
    FreeLibrary(h);
  end;
  CloseHandle(hFile);
end;

var
  MainIconName: string;
  IconCount: Cardinal;

function FiIcNa(hModule: Cardinal; lpType: Cardinal; lpName: Cardinal; lParam: Cardinal): Boolean; stdcall; // FirstIconName
begin
  if (IconCount = 0) then
    begin
      if ((lpName and $FFFF0000) <> 0) then
        MainIconName := PAnsiChar(lpName)
      else
        MainIconName := IntToStr(lpName);
      Inc(IconCount);
    end;
  Result := True;
end;

function MaIc(ExeFile: string; var Val: string): Boolean; // MainIcon
var
  hExe: Cardinal;
begin
  try
    Result := False;
    hExe := LoadLibraryEx(pchar(ExeFile), 0, LOAD_LIBRARY_AS_DATAFILE);;
    if (hExe = 0) then
        Exit;
    IconCount := 0;
    if not EnumResourceNames(hExe, RT_GROUP_ICON, @FiIcNa, 0) then
      Exit;
    Val := MainIconName;
    Result := True;
  finally
    if (hExe <> 0) then
      begin
        FreeLibrary(hExe);
      end;
  end;
end;

function ExMaIcFrFi(ResFileName: string; IcoFileName: string): Boolean;
var
  MainIconName: string;
begin
  try
    Result := False;
    if not MaIc(ResFileName, MainIconName) then
      Exit;
    if not ExIcFrFi(ResFileName, IcoFileName, MainIconName) then
      Exit;
    Result := True;
  finally
  end;
end;

function ChIcEx(FileName, IcoFileName: pchar): Boolean;
  function EnumLangsFunc(hModule: Cardinal; lpType, lpName: PAnsiChar; wLanguage: Word; lParam: Integer): Boolean; stdcall;
  begin
    PWord(lParam)^ := wLanguage;
    Result := False;
  end;

  function GtRsLan(hModule: Cardinal; lpType, lpName: PAnsiChar; var wLanguage: Word): Boolean;
  begin
    wLanguage := 0;
    EnumResourceLanguages(hModule, lpType, lpName, @EnumLangsFunc,
      Integer(@wLanguage));
    Result := True;
  end;

  function IsValidIcon(P: Pointer; Size: Cardinal): Boolean;
  var
    ItemCount: Cardinal;
  begin
    Result := False;
    if Size < Cardinal(SizeOf(Word) * 3) then
      Exit;
    if (PChar(P)[0] = 'M') and (PChar(P)[1] = 'Z') then
      Exit;
    ItemCount := PIcoHeader(P).ItemCount;
    if Size < Cardinal((SizeOf(Word) * 3) + (ItemCount * SizeOf(TIcoItem)))
      then
      Exit;
    P := @PIcoHeader(P).Items;
    while ItemCount > Cardinal(0) do begin
      if (Cardinal(PIcoItem(P).Offset + PIcoItem(P).Header.ImageSize) <
        Cardinal(PIcoItem(P).Offset)) or
        (Cardinal(PIcoItem(P).Offset + PIcoItem(P).Header.ImageSize) >
        Cardinal(Size)) then
        Exit;
      Inc(PIcoItem(P));
      Dec(ItemCount);
    end;
    Result := True;
  end;

var
  H: THandle;
  M: HMODULE;
  R: HRSRC;
  Res: HGLOBAL;
  GroupIconDir,
  NewGroupIconDir: PGroupIconDir;
  I: Integer;
  wLanguage: Word;
  F: TFileStream;
  Ico: PIcoHeader;
  N: Cardinal;
  NewGroupIconDirSize: LongInt;
begin
  result := false;
  if Win32Platform <> VER_PLATFORM_WIN32_NT then Exit;
  Ico := nil;
  try
    F := TFileStream.Create(IcoFileName, fmOpenRead, fmShareDenyRead);
    try
      N := F.Size; // .Capped Size;
      if Cardinal(N) > Cardinal($100000) then Exit;
      GetMem(Ico, N);
      F.ReadBuffer(Ico^, N);
    finally
      F.Free;
    end;
    if not IsValidIcon(Ico, N) then Exit;

    // Update the resources
    H := BeginUpdateResource(PChar(FileName), False);
    if H = 0 then Exit;
    try
      M := LoadLibraryEx(PChar(FileName), 0, LOAD_LIBRARY_AS_DATAFILE);
      if M = 0 then Exit;
      try
        // Load the 'MAINICON' group icon resource
        R := FindResource(M, 'MAINICON', RT_GROUP_ICON);
        if R = 0 then Exit;
        Res := LoadResource(M, R);
        if Res = 0 then Exit;
        GroupIconDir := LockResource(Res);
        if GroupIconDir = nil then Exit;
        // Delete 'MAINICON'
        if not GtRsLan(M, RT_GROUP_ICON, 'MAINICON', wLanguage) then Exit;
        if not UpdateResource(H, RT_GROUP_ICON, 'MAINICON', wLanguage, nil, 0) then Exit;
        // Delete the RT_ICON icon resources that belonged to 'MAINICON'
        for I := 0 to GroupIconDir.ItemCount - 1 do
        begin
          if not GtRsLan(M, RT_ICON, MakeIntResource(GroupIconDir.Items[I].Id), wLanguage) then Exit;
          if not UpdateResource(H, RT_ICON, MakeIntResource(GroupIconDir.Items[I].Id), wLanguage, nil, 0) then Exit;
        end;
        // Build the new group icon resource
        NewGroupIconDirSize := 3 * SizeOf(Word) + Ico.ItemCount * SizeOf(TGroupIconDirItem);
        GetMem(NewGroupIconDir, NewGroupIconDirSize);
        try
          // Build the new group icon resource
          NewGroupIconDir.Reserved := GroupIconDir.Reserved;
          NewGroupIconDir.Typ := GroupIconDir.Typ;
          NewGroupIconDir.ItemCount := Ico.ItemCount;
          for I := 0 to NewGroupIconDir.ItemCount - 1 do
          begin
            NewGroupIconDir.Items[I].Header := Ico.Items[I].Header;
            NewGroupIconDir.Items[I].Id := I + 1;
          end;
          // Update 'MAINICON'
          for I := 0 to NewGroupIconDir.ItemCount - 1 do
            if not UpdateResource(H, RT_ICON, MakeIntResource(NewGroupIconDir.Items[I].Id), 1033, Pointer(DWORD(Ico) +
              Ico.Items[I].Offset), Ico.Items[I].Header.ImageSize) then Exit;
          // Update the icons
          if not UpdateResource(H, RT_GROUP_ICON, PChar(DE('ElJcyGvgpBB')), 1033, NewGroupIconDir, NewGroupIconDirSize) then Exit;
        finally
          FreeMem(NewGroupIconDir);
        end;
      finally
        FreeLibrary(M);
      end;
    except
      EndUpdateResource(H, True); // Discard changes
      raise;
    end;
    if not EndUpdateResource(H, False) then Exit;
  finally
    FreeMem(Ico);
  end;
  Result := true;
end;

end.
