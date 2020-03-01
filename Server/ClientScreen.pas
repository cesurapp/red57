unit ClientScreen;

interface

uses
  Windows, Classes, Controls, StdCtrls, ExtCtrls, Forms, Sysutils, Graphics, Jpeg, uTypes, uSockets, uFunctions;

type
  TScreenForm = class(TCForm)
    Image: TImage;
    Panel1: TPanel;
    ScreenCapture: TButton;
    StartCaptureTimer: TButton;
    CaptureSave: TCheckBox;
    procedure ScreenCaptureClick(Sender: TObject);
    procedure StartCaptureTimerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    CommandTimer: TTimer;
    Working: Boolean;
  public
    procedure ExecuteThread(CMD: String = ''); override;
  end;

implementation

{$R *.dfm}

procedure TScreenForm.FormCreate(Sender: TObject);
begin
  if not Working then begin
    Working := True;
    Client.WriteLn('screenshoot');
  end;
end;

procedure TScreenForm.ExecuteThread(CMD: String = '');
var
  MS : TMemoryStream;
  Size : Integer;
  JPG : TJPEGImage;
begin
  MS := TMemoryStream.Create;
  JPG := TJPEGImage.Create;

  // Read Stream
  Size := Client.ReadInteger;
  if Client.ReadStream(MS, Size) then begin
    JPG.LoadFromStream(MS);
    Image.Picture.Bitmap.Assign(JPG);

    if CaptureSave.Checked then JPG.SaveToFile(UserFolder(Client.Data, 'jpg'));
    JPG.Free;
    MS.Free;
  end;

  Working := False;
end;

{****************************************************************************
                      Screen Capture -> Baþlangýç
****************************************************************************}

procedure TScreenForm.ScreenCaptureClick(Sender: TObject);
begin
  Client.WriteLn('screenshoot');
end; {* New Screen Capture *}

procedure TScreenForm.StartCaptureTimerClick(Sender: TObject);
begin
  // Create Timer
  if not Assigned(CommandTimer) then begin
    CommandTimer := TTimer.Create(Self);
    CommandTimer.Interval := 500;
    CommandTimer.OnTimer := ScreenCaptureClick;
    CommandTimer.Enabled := False;
  end;

  // Change Button Name
  if CommandTimer.Enabled then begin
    CommandTimer.Enabled := False;
    StartCaptureTimer.Caption := 'Zamanlayýcý Çalýþtýr';
  end else begin
    CommandTimer.Enabled := True;
    StartCaptureTimer.Caption := 'Zamanlayýcý Kapat';
  end;
end; { StartCaptureTimerClick -> New Screen Capture Timer for Click Button }

end.

