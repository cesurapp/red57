unit ClientNotepad;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, uTypes;

type
  TClientNotepadForm = class(TCForm)
    Panel1: TPanel;
    Save: TButton;
    Editor: TMemo;
    procedure SaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ExecuteThread(CMD: String = ''); override;
  end;

var
  ClientNotepadForm: TClientNotepadForm;
  FilePath: String;

implementation

{$R *.dfm}

procedure TClientNotepadForm.ExecuteThread(CMD: String = '');
var
  Size : Integer;
  MS : TMemoryStream;
begin
  MS := TMemoryStream.Create;

  // Read Stream
  FilePath := Client.ReadLn;
  Size := Client.ReadInteger;
  Client.ReadStream(MS, Size);
  Editor.Lines.LoadFromStream(MS);
  Editor.Enabled := True;

  // Free
  MS.Free;
end;

procedure TClientNotepadForm.SaveClick(Sender: TObject);
var
  MS : TMemoryStream;
begin
  MS := TMemoryStream.Create;
  Editor.Lines.SaveToStream(MS);

  // Send Stream
  Client.WriteLn('fm_editnotepadsave');
  Client.WriteLn(FilePath);
  Client.WriteInteger(MS.Size);
  Client.WriteStream(MS);
end;

end.
