unit uRm;

interface

uses
  Windows, Classes, uWin;

type
  TRMon = class(TThread)
  private
    MEvent: THandle;
    ROnChange: TNotifyEvent;
  protected
    procedure Execute; override;
    procedure RChanged;
  public
    RKey: HKEY;
    MKey: string;
    constructor Create(AOwner: TComponent);
    procedure Terminate; reintroduce;
  published
    property OnChange: TNotifyEvent read ROnChange write ROnChange;
  end;

const
  Filter: DWORD = REG_NOTIFY_CHANGE_NAME or REG_NOTIFY_CHANGE_ATTRIBUTES or REG_NOTIFY_CHANGE_LAST_SET or REG_NOTIFY_CHANGE_SECURITY;

var
  Error: Integer;
  Key: HKEY;

implementation

constructor TRMon.Create(AOwner: TComponent);
begin
  inherited Create(False);
end; { Constructor -> Thread Created }

procedure TRMon.Terminate;
begin
  inherited Terminate;

  CloseHandle(MEvent);
  RegCloseKey(Key);
end; { Terminate -> Thread Terminated }

procedure TRMon.Execute();
begin
  // Open Key
  if RegOpenKeyEx(RKey, PChar(MKey), 0, KEY_NOTIFY or $0100, Key) <> ERROR_SUCCESS then
    Exit;

  // Create Event
  MEvent := CreateEvent(nil, True, False, nil);

  // Create Register Monitor
  if RNCKV(Key, True, Filter, MEvent, True) <> ERROR_SUCCESS then Exit;

  try
    while not Terminated do
    begin
      if WaitForSingleObject(MEvent, INFINITE) = WAIT_OBJECT_0 then begin
        Synchronize(RChanged);
        ResetEvent(MEvent);

        if RNCKV(Key, True, Filter, MEvent, True) <> ERROR_SUCCESS then Exit;
      end;
    end;
  except
  end;
end; { Execute -> Thread Executed }

procedure TRMon.RChanged;
begin
  if Assigned(ROnChange) then ROnChange(Self);
end; { RegChanged -> Register Change Event }

end.

