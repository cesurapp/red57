unit ClientInformation;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, StdCtrls, Dialogs, uTypes, uSockets;

type
  TInformationForm = class(TCForm)
    Information: TMemo;
    procedure FormCreate(Sender: TObject);
  private
  public
    procedure ExecuteThread(CMD: String = ''); override;
  end;

implementation

{$R *.dfm}

procedure TInformationForm.FormCreate(Sender: TObject);
begin
  Client.WriteLn('information');
end; { FormCreate -> Send First Command }

procedure TInformationForm.ExecuteThread(CMD: String = '');
var
  MS : TMemoryStream;
  SL : TStringList;
  Size : Integer;
begin
  MS := TMemoryStream.Create;
  SL := TStringList.Create;

  // Read Stream
  Size := Client.ReadInteger;
  if Client.ReadStream(MS, Size) then begin
    SL.LoadFromStream(MS);
    Information.Lines.AddStrings(SL);
    MS.Free;
    SL.Free;
  end;
end; { ExecuteThread -> Information Thread Execute }

end.
