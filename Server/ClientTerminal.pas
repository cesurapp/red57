unit ClientTerminal;

interface

uses
  Windows, Forms, Classes, StdCtrls, SysUtils, Controls, ExtCtrls, uTypes, uSockets, Dialogs, Messages;

type
  TTerminalForm = class(TCForm)
    Output: TMemo;
    Panel1: TPanel;
    Command: TMemo;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  public
    Active: Boolean;
    Working: Boolean;
    procedure ExecuteThread(CMD: string = ''); override;
  end;

implementation

{$R *.dfm}

procedure TTerminalForm.ExecuteThread(CMD: string = '');
var
  Status: string;
  MS: TMemoryStream;
  SL: TStringList;
  Size: Integer;
begin
  if CMD = 'console_run' then begin
    Status := Client.ReadLn;
    Active := StrToBool(Status);
  end;

  if CMD = 'console_cmd' then begin
    MS := TMemoryStream.Create;
    SL := TStringList.Create;

    // Read Stream
    Size := Client.ReadInteger;
    if Client.ReadStream(MS, Size) then begin
      SL.LoadFromStream(MS);
      Output.Lines.AddStrings(SL);
      SendMessage(Output.Handle, EM_LINESCROLL, 0, Output.Lines.Count);
      SL.Free;
      MS.Free;
    end;
  end;

  Working := False;
end; { ExecuteThread -> Client Thread Main }

{****************************************************************************
                      Terminal -> Baþlangýç
****************************************************************************}

procedure TTerminalForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) and Active and not Working then begin
    if (Trim(AnsiUpperCase(Command.Lines.Text)) <> 'CLS') then begin
      Working := True;
      Client.WriteLn('console_cmd');
      Client.WriteLn(Trim(Command.Lines.Text));
    end else
      Output.Lines.Clear;

    Command.Lines.Clear;
  end;
end; {* Send Terminal Command -> Keyboard *}

procedure TTerminalForm.FormCreate(Sender: TObject);
begin
  if Client.Connected then begin
    Working := True;
    Client.WriteLn('console_run');
  end;
end; {* FormCreate -> Console Run *}

procedure TTerminalForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Client.Connected then begin
    Client.WriteLn('console_stop');
  end;
end; {* FormClose -> Console Stop *}

end.

