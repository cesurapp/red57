{##########################################
#                                         #
#  Thread                                 #
#                                         #
#  Author:   red57                        #
#  Date:     2010-07-09                   #
#  Version:  0.1                          #
#                                         #
#                                         #
##########################################}

unit uThread;

interface
uses Windows;

type
  TNotifyEvent = procedure(Sender: TObject) of object;
  TSynchronizeProcedure = procedure of object;
  TThreadPriority = (tpIdle, tpLowest, tpLower, tpNormal,
                     tpHigher, tpHighest, tpTimeCritical);

  TThread = class
  private
    FHandle: THandle;
    FThreadId: Cardinal;
    FTerminated: Boolean;
    FSuspended: Boolean;
    FExitCode: Cardinal;
    FOnTerminate: TNotifyEvent;
    FFreeOnTerminate: Boolean;
    FPriority: TThreadPriority;
    FData: TObject;
    FFreeDataOnTerminate: Boolean;
    procedure SetPriority(Value: TThreadPriority);
  protected
    procedure Synchronize(SnycProc: TSynchronizeProcedure);
    procedure Execute; virtual; abstract;
  public
    constructor Create(CreateSuspended: Boolean);
    procedure Resume;
    procedure Suspend;
    procedure Terminate;
    function WaitFor(Timeout: Cardinal = INFINITE): Cardinal;
    property Terminated: Boolean read FTerminated;
    property Suspended: Boolean read FSuspended;
    property Priority: TThreadPriority read FPriority write SetPriority;
    property FreeOnTerminate: Boolean read FFreeOnTerminate write FFreeOnTerminate;
    property ExitCode: Cardinal read FExitCode;
    property Handle: THandle read FHandle;
    property Id: Cardinal read FThreadId;
    property OnTerminate: TNotifyEvent read FOnTerminate write FOnTerminate;
    property Data: TObject read FData write FData;
    property FreeDataOnTerminate: Boolean read FFreeDataOnTerminate write FFreeDataOnTerminate;
    procedure Lock;
    procedure Unlock;
    destructor Destroy; override;
  end;


implementation

const
  THREAD_ERROR = Cardinal(-1);

var
  ThreadLock: TRTLCriticalSection;


function ThreadFunc(Thread: Pointer): Integer;
begin
  with TThread(Thread) do try
    Execute;
  finally
    GetExitCodeThread(FHandle, Cardinal(Result));
    FExitCode := Result;
    FTerminated := True;
    if Assigned(FOnTerminate) then
    begin
      Lock;
      try
        FOnTerminate(Thread);
      finally
        Unlock;
      end;
    end;
    if FFreeDataOnTerminate then
      FData.Free;
    ExitThread(Result);
    if FFreeOnTerminate then
      Free;            
  end;
end;


constructor TThread.Create(CreateSuspended: Boolean);
var
  Flags: Cardinal;
begin
  inherited Create;
  FTerminated := False;
  FSuspended := CreateSuspended;
  FExitCode := 0;
  FOnTerminate := nil;
  FFreeOnTerminate := False;
  FPriority := tpNormal;
  FData := nil;
  FFreeDataOnTerminate := False;

  if CreateSuspended then
    Flags := CREATE_SUSPENDED
  else
    Flags := 0;

  FHandle := BeginThread(nil, 0, ThreadFunc, Pointer(Self), Flags, FThreadId);
end;

procedure TThread.Synchronize(SnycProc: TSynchronizeProcedure);
begin
  Lock;
  try
    SnycProc;
  finally
    Unlock;
  end;
end;

procedure TThread.SetPriority(Value: TThreadPriority);
var
  Priority: Integer;
begin
  if Value <> FPriority then
  begin
    case Value of
      tpIdle: Priority := THREAD_PRIORITY_IDLE;
      tpTimeCritical: Priority := THREAD_PRIORITY_TIME_CRITICAL;
      else Priority := Integer(Value) - THREAD_PRIORITY_NORMAL;
    end;
    if SetThreadPriority(FHandle, Priority) then
      FPriority := Value;
  end;
end;

procedure TThread.Resume;
begin
  if FSuspended and (ResumeThread(FHandle) <> THREAD_ERROR) then
    FSuspended := False;
end;

procedure TThread.Suspend;
begin
  if not Suspended and (SuspendThread(FHandle) <> THREAD_ERROR) then
    FSuspended := True;
end;

procedure TThread.Terminate;
begin
  if not FTerminated then
    FTerminated := True;
end;

function TThread.WaitFor(Timeout: Cardinal = INFINITE): Cardinal;
begin
  Result := WaitForSingleObject(FHandle, Timeout);
end;

procedure TThread.Lock;
begin
  EnterCriticalSection(ThreadLock);
end;

procedure TThread.Unlock;
begin
  LeaveCriticalSection(ThreadLock);
end;

destructor TThread.Destroy;
begin
  CloseHandle(FHandle);
  inherited Destroy;
end;


initialization
  InitializeCriticalSection(ThreadLock);

finalization
  DeleteCriticalSection(ThreadLock);

end.
