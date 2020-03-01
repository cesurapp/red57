unit ClientPreview;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, JPEG, uTypes;

type
  TPreviewForm = class(TForm)
    ImageBox: TImage;
    TextBox: TMemo;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    procedure SetLarge(VCL : TControl);
  public
    procedure ViewImage(Stream: TMemoryStream);
    procedure ViewText(Stream: TStringList);
  end;

var
  PreviewForm: TPreviewForm;

implementation

{$R *.dfm}

procedure TPreviewForm.SetLarge(VCL : TControl);
begin
  VCL.Visible := True;
end;

procedure TPreviewForm.ViewImage(Stream: TMemoryStream);
var
  JPG : TJPEGImage;
begin
  // Set Visible
  TextBox.Visible := False;
  ImageBox.Visible := True;

  // Assign IMG
  JPG := TJPEGImage.Create;
  JPG.LoadFromStream(Stream);
  ImageBox.Picture.Assign(JPG);

  // Set Size
  Width := JPG.Width + 16;
  Height := JPG.Height + 38;
end;

procedure TPreviewForm.ViewText(Stream: TStringList);
begin
  // Set Visible
  ImageBox.Visible := False;
  TextBox.Visible := True;
  
  // Set Content
  TextBox.Clear;
  TextBox.Lines.AddStrings(Stream);

  // Set Size
  Width := 800;
  Height := 600;
end;

procedure TPreviewForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Ord(Key) = VK_ESCAPE) or (Ord(Key) = VK_SPACE) then
    Hide;
end;

end.
