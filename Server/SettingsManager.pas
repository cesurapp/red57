unit SettingsManager;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, INIFiles;

type
  TFormSettings = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    ServerPort: TEdit;
    ButtonSave: TButton;
    PlayConnectSound: TCheckBox;
    PlayDisconnectSound: TCheckBox;
    GroupBox3: TGroupBox;
    DnsUpdateURL: TEdit;
    procedure ButtonSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  FormSettings: TFormSettings;

implementation

{$R *.dfm}

procedure TFormSettings.FormCreate(Sender: TObject);
var
  iFile: TIniFile;
begin
  if FileExists(ExtractFileDir(ParamStr(0)) + '\AppSettings.ini') then begin
    iFile := TIniFile.Create(ExtractFileDir(ParamStr(0)) + '\AppSettings.ini');

    ServerPort.Text := iFile.ReadString('AppSettings', 'PORT', '21,80');
    DnsUpdateURL.Text := iFile.ReadString('AppSettings', 'DNSURL', '');
    PlayConnectSound.Checked := StrToBoolDef(iFile.ReadString('AppSettings', 'PLAYC', ''), True);
    PlayDisconnectSound.Checked := StrToBoolDef(iFile.ReadString('AppSettings', 'PLAYD', ''), True);

    // File is Free
    iFile.Free;
  end;
end;

procedure TFormSettings.ButtonSaveClick(Sender: TObject);
var
  SFile: TStringList;
begin
  // AppSettings.ini Dosyasý Oluþtur
  SFile := TStringList.Create;
  SFile.Clear;

  SFile.Add('[AppSettings]');
  SFile.Add('PORT=' + ServerPort.Text);
  SFile.Add('DNSURL=' + DnsUpdateURL.Text);
  SFile.Add('PLAYC=' + BoolToStr(PlayConnectSound.Checked));
  SFile.Add('PLAYD=' + BoolToStr(PlayDisconnectSound.Checked));

  SFile.SaveToFile(ExtractFileDir(ParamStr(0)) + '\AppSettings.ini');

  // Pencereyi Kapat
  Close;
end;

end.

