unit uTypes;

interface

uses Classes, Forms, uSockets;

type
  {*
    Client Form Class
  *}
  TCForm = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FormID : String;
  public
    Client: TTCPConnection;
    constructor Create(AOwner: TComponent; ClientPointer: TTCPConnection; ID: String);
    procedure ExecuteThread(CMD: String = ''); virtual;
  end;
  TCFormClass = class of TCForm;

  {*
    Client Listing Data
  *}
  TClientData = class
    IP        : String;
    LocalIP   : String;
    Username  : String;
    PCName    : String;
    AntiVirus : String;
    OS        : String;
    MacAddr   : String;
    CliVersion: String;
    Forms     : TStringList;
    is64      : Boolean;
    MinVerChecked: Boolean;
    MinActive : Boolean;
    MinVersion: Integer;
  end;

implementation

constructor TCForm.Create(AOwner: TComponent; ClientPointer: TTCPConnection; ID: String);
begin
  // Set Owner Form
  inherited Create(Owner);

  // Set Client
  Client := ClientPointer;
  FormID := ID;

  // Form Adýný Belirle
  with TClientData(Client.Data) do
  begin
    Caption := IP + ' : ' + Username + ' - ' + Caption;
  end;

  // Set Close Event
  OnClose := FormClose;
end; {* Form Constructor *}

procedure TCForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Remove Form List
  if Client.Connected then
  with TClientData(Client.Data) do begin
    Forms.Delete(Forms.IndexOf(FormID));
  end;

  Action := caFree;
end; {* Form Close Event *}

procedure TCForm.ExecuteThread(CMD: String = '');
begin
end;

end.
