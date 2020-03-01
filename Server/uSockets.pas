{##########################################
#                                         #
#  Sockets                                #
#                                         #
#  Author:   red57                        #
#  Date:     2010-07-10                   #
#  Version:  0.1                          #
#                                         #
##########################################}

unit uSockets;

//{$DEFINE USE_CLASSES}

interface
uses Windows, WinSock, Classes, uThread, uList, SysUtils, ComCtrls;

const
  EOL = #13#10;
  TCP_INFINITE = 0;
  TCP_DEFAULT = 0;

type
  TTCPSocket = class;
  TTCPConnection = class;
  TTCPConnectionThread = class;
  TTCPServer = class;

  TTCPSocketNotifyEvent = procedure(ASocket: TTCPSocket) of object;
  TTCPConnectionNotifyEvent = procedure(AConnection: TTCPConnection) of object;
  TTCPConnectionExecuteProc = procedure(AThread: TTCPConnectionThread) of object;

  TTCPSocket = class
  private
    FSocket: TSocket;
    FLastError: Integer;
    FLastErrorMessage: string;
    FOnError: TTCPSocketNotifyEvent;
  protected
    function CreateSocket: Boolean;
    procedure CloseSocket;
    procedure HandleError(ErrorCode: Integer); overload;
    procedure HandleError; overload;
    procedure SetSocketOpt(Opt, Value: Cardinal; var Local: Cardinal); overload;
    procedure SetSocketOpt(Opt, Value: Cardinal); overload;
  public
    constructor Create;
    property LastError: Integer read FLastError;
    property LastErrorMessage: string read FLastErrorMessage;
    property OnError: TTCPSocketNotifyEvent read FOnError write FOnError;
    destructor Destroy; override;
  end;

  TTCPConnection = class(TTCPSocket)
  private
    FOnConnect: TTCPConnectionNotifyEvent;
    FOnDisconnect: TTCPConnectionNotifyEvent;
    FOnExecute: TTCPConnectionExecuteProc;
    FConnected: Boolean;
    FSendBufferSize: Cardinal;
    FRecvBufferSize: Cardinal;
    FSendTimeout: Cardinal;
    FRecvTimeout: Cardinal;
    FData: TObject;
    FThread: TTCPConnectionThread;
    FSendStream: TStream;
    function GetLocalAddr: TSockAddrIn;
    function GetPeerAddr: TSockAddrIn;
    function GetLocalIP: string;
    function GetLocalPort: Word;
    function GetPeerIP: string;
    function GetPeerPort: Word;
    procedure SetSendBufferSize(Value: Cardinal);
    procedure SetRecvBufferSize(Value: Cardinal);
    procedure SetSendTimeout(Value: Cardinal);
    procedure SetRecvTimeout(Value: Cardinal);
    procedure ThreadTerminate(Sender: TObject);
    function SendStreamPiece: Boolean;
  protected
    function CreateSocket: Boolean;
  public
    constructor Create;
    property Connected: Boolean read FConnected;
    function ReadBuffer(var Buffer; const Len: Cardinal): Integer;
    function ReadBufferLen(var Buffer; Count: Integer): Integer;
    function ReadStream(AStream: TStream; Size: Cardinal;  P: TProgressBar = nil): Boolean;
    function ReadInteger(Convert: Boolean = True): Integer;
    function ReadSmallInt(Convert: Boolean = True): SmallInt;
    function Read: string;
    function ReadLn(Delim: string = EOL): string;
    function WriteBuffer(var Buffer; const Len: Cardinal): Cardinal;
    function WriteStream(AStream: TStream): Boolean;
    procedure WriteInteger(I: Integer; Convert: Boolean = True);
    procedure WriteSmallInt(I: SmallInt; Convert: Boolean = True);
    procedure Write(S: string);
    procedure WriteLn(S: string; Delim: string = EOL);
    procedure Disconnect;
    function Detach: TTCPConnectionThread;
    function RecvBufferCount: Cardinal;
    property LocalIP: string read GetLocalIP;
    property LocalPort: Word read GetLocalPort;
    property PeerIP: string read GetPeerIP;
    property PeerPort: Word read GetPeerPort;
    property Data: TObject read FData write FData;
    property RecvTimeout: Cardinal read FRecvTimeout write SetRecvTimeout;
    property SendTimeout: Cardinal read FSendTimeout write SetSendTimeout;
    property RecvBufferSize: Cardinal read FRecvBufferSize write SetRecvBufferSize;
    property SendBufferSize: Cardinal read FSendBufferSize write SetSendBufferSize;
    property OnConnect: TTCPConnectionNotifyEvent read FOnConnect write FOnConnect;
    property OnDisconnect: TTCPConnectionNotifyEvent read FOnDisconnect write FOnDisconnect;
    property OnExecute: TTCPConnectionExecuteProc read FOnExecute write FOnExecute;
    property Thread: TTCPConnectionThread read FThread;
    destructor Destroy; override;
  end;

  TTCPConnectionThread = class(TThread)
  private
    FConnection: TTCPConnection;
  protected
    procedure Execute; override;
  public
    constructor Create(Connection: TTCPConnection);
    property Connection: TTCPConnection read FConnection;
    procedure Sync(SnycProc: TSynchronizeProcedure);
  end;

  TTCPClientConnection = class(TTCPConnection)
  public
    function Connect(Addr: TSockAddr): Boolean; overload;
    function Connect(Address: string; Port: Word): Boolean; overload;
    function Connect(AddressAndPort: string): Boolean; overload;
  end;

  TTCPServerConnection = class(TTCPConnection)
  private
    FServer: TTCPServer;
  public
    constructor Create(Server: TTCPServer);
    procedure Disconnect;
    property Server: TTCPServer read FServer;
  end;

  TTCPListenerThread = class(TThread)
  private
    FTCPSocket: TTCPSocket;
    FServer: TTCPServer;
  protected
    procedure Execute; override;
  public
    constructor Create(Server: TTCPServer; Socket: TTCPSocket);
    destructor Destroy; override;
  end;

  TTCPBinding = class
  private
    FAddress: string;
    FPort: Word;
    FAddr: TSockAddr;
  protected
    procedure SetAddress(Value: string);
  public
    constructor Create(Address: string; Port: Word); overload;
    constructor Create(AddressAndPort: string); overload;
    constructor Create(Addr: TSockAddr); overload;
    property Address: string read FAddress write SetAddress;
    property Port: Word read FPort write FPort;
  end;

  TTCPServer = class
  private
    FListeners: TThreadList;
    FConnections: TThreadList;
    FBindings: TList;
    FListening: Boolean;
    FOnConnect: TTCPConnectionNotifyEvent;
    FOnDisconnect: TTCPConnectionNotifyEvent;
    FOnExecute: TTCPConnectionExecuteProc;
    FOnError: TTCPSocketNotifyEvent;
    procedure SetListening(Value: Boolean);
  protected
    procedure ListenerTerminate(Sender: TObject);
    procedure ClientConnect(Connection: TTCPServerConnection);
    procedure ClientDisconnect(Connection: TTCPServerConnection);
  public
    constructor Create;
    procedure AddBinding(Binding: TTCPBinding);
    property Listen: Boolean read FListening write SetListening;
    property OnConnect: TTCPConnectionNotifyEvent read FOnConnect write FOnConnect;
    property OnDisconnect: TTCPConnectionNotifyEvent read FOnDisconnect write FOnDisconnect;
    property OnExecute: TTCPConnectionExecuteProc read FOnExecute write FOnExecute;
    property OnError: TTCPSocketNotifyEvent read FOnError write FOnError;
    property Bindings: TList read FBindings;
    procedure ClearBindings;
    property Connections: TThreadList read FConnections;
    destructor Destroy; override;
  end;


function ResolveAddress(Address: string): TInAddr;
function MakeAddr(Address: string; Port: Word; var SockAddr: TSockAddr): Boolean;
function SplitAddress(AddressAndPort: string; var Address: string; var Port: Word): Boolean;

implementation

var
  WSAData: TWSAData;

function ResolveAddress(Address: string): TInAddr;
var
  Host: PHostEnt;
begin
  Result.S_addr := inet_addr(PChar(Address));
  if Result.S_addr = INADDR_NONE then
  begin
    Host := gethostbyname(PChar(Address));
    if Host <> nil then
      Result := PInAddr(Host.h_addr_list^)^;
  end;
end;

function MakeAddr(Address: string; Port: Word; var SockAddr: TSockAddr): Boolean;
var
  Len: Integer;
begin
  Result := True;
  Len := SizeOf(SockAddr);
  FillChar(SockAddr, Len, 0);
  with SockAddr do
  begin
    sin_family := AF_INET;
    sin_port := htons(Port);
    sin_addr := ResolveAddress(Address);
    if sin_addr.S_addr = INADDR_NONE then
      Result := False
  end;
end;

function SplitAddress(AddressAndPort: string; var Address: string; var Port: Word): Boolean;
var
  I, L: Integer;
  PortStr: string;
begin
  Result := True;
  L := Length(AddressAndPort);
  for I := L downto 1 do
    if AddressAndPort[I] = ':' then
    begin
      Address := Copy(AddressAndPort, 0, I - 1);
      PortStr := Copy(AddressAndPort, I + 1, L);
      Val(PortStr, Port, L);
      if L = 0 then Exit
      else Break;
    end;
  Result := False;
  Address := '';
  Port := 0;
end;



//##############################################################################
//################################# TTCPSocket #################################
//##############################################################################

constructor TTCPSocket.Create;
begin
  inherited Create;
  FLastError := 0;
  FLastErrorMessage := '';
  FSocket := INVALID_SOCKET;
  FOnError := nil;
end;

function TTCPSocket.CreateSocket: Boolean;
begin
  FSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  Result := FSocket <> INVALID_SOCKET;
  if not Result then
    HandleError;
end;

procedure TTCPSocket.CloseSocket;
begin
  if FSocket <> INVALID_SOCKET then
  begin
    if WinSock.closesocket(FSocket) = SOCKET_ERROR then
      HandleError;
    FSocket := INVALID_SOCKET;
  end;
end;

procedure TTCPSocket.HandleError(ErrorCode: Integer);
var
  Buffer: PChar;
  Len: Cardinal;
begin
  FLastError := ErrorCode;
  Buffer := nil;
  Len := FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ALLOCATE_BUFFER,
    nil, FLastError, 0, @Buffer, 0, nil
    );
  SetString(FLastErrorMessage, Buffer, Len);
  if Assigned(FOnError) then
    FOnError(Self);
end;

procedure TTCPSocket.HandleError;
begin
  HandleError(WSAGetLastError);
end;

procedure TTCPSocket.SetSocketOpt(Opt, Value: Cardinal; var Local: Cardinal);
begin
  if FSocket = INVALID_SOCKET then
    Local := Value
  else if setsockopt(FSocket, SOL_SOCKET, Opt,
    @Value, SizeOf(Value)) <> SOCKET_ERROR then
    Local := Value
  else
    HandleError;
end;

procedure TTCPSocket.SetSocketOpt(Opt, Value: Cardinal);
begin
  if setsockopt(FSocket, SOL_SOCKET, Opt,
    @Value, SizeOf(Value)) = SOCKET_ERROR then
    HandleError;
end;

destructor TTCPSocket.Destroy;
begin
  CloseSocket;
  inherited Destroy;
end;



//##############################################################################
//############################## TTCPConnection ################################
//##############################################################################

constructor TTCPConnection.Create;
begin
  inherited Create;
  FConnected := False;
  FOnConnect := nil;
  FOnDisconnect := nil;
  FOnExecute := nil;
  FRecvBufferSize := TCP_DEFAULT;
  FSendBufferSize := TCP_DEFAULT;
  FRecvTimeout := TCP_INFINITE;
  FSendTimeout := TCP_INFINITE;
  FThread := nil;
end;

procedure TTCPConnection.ThreadTerminate(Sender: TObject);
begin
  if Sender is TTCPConnectionThread then
    FThread := nil;
end;

function TTCPConnection.CreateSocket: Boolean;
begin
  Result := inherited CreateSocket;
  if Result then
  begin
    if FRecvBufferSize <> TCP_DEFAULT then
      SetRecvBufferSize(FRecvBufferSize);
    if FSendBufferSize <> TCP_DEFAULT then
      SetSendBufferSize(FSendBufferSize);
    if FRecvTimeout <> TCP_INFINITE then
      SetRecvTimeout(FRecvTimeout);
    if FSendTimeout <> TCP_INFINITE then
      SetSendTimeout(FSendTimeout);
  end;
end;

function TTCPConnection.ReadBuffer(var Buffer; const Len: Cardinal): Integer;
begin
  Result := recv(FSocket, Buffer, Len, 0);
  case Result of
    SOCKET_ERROR: if FConnected then
      begin
        HandleError;
        Disconnect;
      end;
    0: Disconnect;
  end;
end;

function TTCPConnection.ReadBufferLen(var Buffer; Count: Integer): Integer;
var
  ErrorCode: Integer;
  iCount: integer;
begin
  Thread.Lock;
  try
    Result := 0;
    if (Count = -1) and FConnected then ioctlsocket(FSocket, FIONREAD, Longint(Result))
    else begin
      if not FConnected then Exit;
      if ioctlsocket(FSocket, FIONREAD, iCount) = 0 then
        if iCount < Count then Count := iCount;

      Result := recv(FSocket, Buffer, Count, 0);
      if Result = SOCKET_ERROR then begin
        HandleError;
        Disconnect;
      end;
    end;
  finally
    Thread.Unlock;
  end;
end;


function TTCPConnection.ReadInteger(Convert: Boolean = True): Integer;
begin
  ReadBuffer(Result, SizeOf(Result));
  if Convert then Result := ntohl(LongWord(Result));
end;

function TTCPConnection.ReadSmallInt(Convert: Boolean = True): SmallInt;
begin
  ReadBuffer(Result, SizeOf(Result));
  if Convert then Result := ntohs(Result);
end;

function TTCPConnection.Read: string;
var
  Len: Cardinal;
begin
  Len := RecvBufferCount;
  SetLength(Result, Len);
  ReadBuffer(Result[1], Len);
end;

function TTCPConnection.ReadLn(Delim: string = EOL): string;
const
  BUFFER_SIZE = 255;
var
  Buffer: string;
  I, L: Cardinal;
begin
  Result := '';
  I := 1;
  L := 1;
  SetLength(Buffer, BUFFER_SIZE);
  while Connected and (L <= Cardinal(Length(Delim))) do
  begin
    ReadBuffer(Buffer[I], 1);
    if Buffer[I] = Delim[L] then
      Inc(L)
    else
      L := 1;
    Inc(I);
    if I > BUFFER_SIZE then
    begin
      Result := Result + Buffer;
      I := 1;
    end;
  end;
  if Connected then
    Result := Result + Copy(Buffer, 0, I - L);
end;

function TTCPConnection.ReadStream(AStream: TStream; Size: Cardinal; P: TProgressBar = nil): Boolean;
var
  Buffer: array[0..65535] of char;
  IncommingLen, RecievedLen, i: integer;
begin
  Result := False;

  for i := 0 to 100000 do begin
    IncommingLen := Thread.Connection.RecvBufferCount;
    while IncommingLen > 0 do begin
      // Read Data
      RecievedLen := Thread.Connection.ReadBuffer(Buffer, SizeOf(Buffer));

      // Write Stream
      AStream.WriteBuffer(Buffer, RecievedLen);

      if P <> nil then begin
        P.Position := Round((AStream.Size * 100) / Size);
      end;

      // Complete
      if AStream.Size >= Size then begin
        AStream.Position := 0;
        Result := True;
        Break;
      end;
    end;

    if IncommingLen > 0 then
      Break;
  end;
end;

function TTCPConnection.WriteBuffer(var Buffer; const Len: Cardinal): Cardinal;
begin
  Result := send(FSocket, Buffer, Len, 0);
  if (Result = SOCKET_ERROR) and FConnected then
  begin
    HandleError;
    Disconnect;
  end;
end;

function TTCPConnection.SendStreamPiece: Boolean;
var
  Buffer: array[0..65535] of Byte;
  StartPos: Integer;
  AmountInBuf: Integer;
  AmountSent: Integer;
  ErrorCode: Integer;
begin
  Thread.Lock;
  try
    Result := False;
    if FSendStream <> nil then begin
      while True do begin
        StartPos := FSendStream.Position;
        AmountInBuf := FSendStream.Read(Buffer, SizeOf(Buffer));
        if AmountInBuf > 0 then
        begin
          AmountSent := send(FSocket, Buffer, AmountInBuf, 0);
          if AmountSent = SOCKET_ERROR then
          begin
            ErrorCode := WSAGetLastError;
            if ErrorCode <> WSAEWOULDBLOCK then
            begin
              FSendStream.Free;
              FSendStream := nil;
              HandleError;
              Disconnect;
              Break;
            end else
            begin
              FSendStream.Position := StartPos;
              Break;
            end;
          end else
          if AmountInBuf > AmountSent then
            FSendStream.Position := StartPos + AmountSent
          else if FSendStream.Position = FSendStream.Size then
          begin
            FSendStream.Free;
            FSendStream := nil;
            Break;
          end;
        end else
        begin
          FSendStream.Free;
          FSendStream := nil;
          Break;
        end;
      end;
      Result := True;
    end;
  finally
    Thread.Unlock;
  end;
end;

function TTCPConnection.WriteStream(AStream: TStream): Boolean;
begin
  Result := False;
  if FSendStream = nil then
  begin
    FSendStream := AStream;
    FSendStream.Position := 0;
    Result := SendStreamPiece;
  end;
end;

procedure TTCPConnection.WriteInteger(I: Integer; Convert: Boolean = True);
begin
  if Convert then I := htonl(I);
  WriteBuffer(I, SizeOf(I));
end;

procedure TTCPConnection.WriteSmallInt(I: SmallInt; Convert: Boolean = True);
begin
  if Convert then I := htons(I);
  WriteBuffer(I, SizeOf(I));
end;

procedure TTCPConnection.Write(S: string);
begin
  WriteBuffer(S[1], Length(S));
end;

procedure TTCPConnection.WriteLn(S: string; Delim: string = EOL);
begin
  if Delim = '' then
    Delim := EOL;
  Write(S + Delim);
end;

procedure TTCPConnection.Disconnect;
begin
  if FConnected then
  begin
    FConnected := False;
    CloseSocket;
    if Assigned(FOnDisconnect) then FOnDisconnect(Self);
  end;
end;

function TTCPConnection.Detach: TTCPConnectionThread;
begin
  if not Assigned(FThread) then
  begin
    FThread := TTCPConnectionThread.Create(Self);
    Result := FThread;
  end
  else
    Result := nil;
end;

function TTCPConnection.RecvBufferCount: Cardinal;
begin
  if ioctlsocket(FSocket, FIONREAD, Integer(Result)) = SOCKET_ERROR then
  begin
    Result := 0;
    HandleError;
  end;
end;

function TTCPConnection.GetLocalAddr: TSockAddrIn;
var
  Len: Integer;
begin
  Len := SizeOf(Result);
  if getpeername(FSocket, Result, Len) = SOCKET_ERROR then
    HandleError;
end;

function TTCPConnection.GetPeerAddr: TSockAddrIn;
var
  Len: Integer;
begin
  Len := SizeOf(Result);
  if getpeername(FSocket, Result, Len) = SOCKET_ERROR then
    HandleError;
end;

function TTCPConnection.GetLocalIP: string;
begin
  Result := inet_ntoa(GetLocalAddr.sin_addr);
end;

function TTCPConnection.GetLocalPort: Word;
begin
  Result := ntohs(GetLocalAddr.sin_port);
end;

function TTCPConnection.GetPeerIP: string;
begin
  Result := inet_ntoa(GetPeerAddr.sin_addr);
end;

function TTCPConnection.GetPeerPort: Word;
begin
  Result := ntohs(GetPeerAddr.sin_port);
end;

procedure TTCPConnection.SetSendBufferSize(Value: Cardinal);
begin
  SetSocketOpt(SO_SNDBUF, Value, FSendBufferSize);
end;

procedure TTCPConnection.SetRecvBufferSize(Value: Cardinal);
begin
  SetSocketOpt(SO_RCVBUF, Value, FRecvBufferSize);
end;

procedure TTCPConnection.SetSendTimeout(Value: Cardinal);
begin
  SetSocketOpt(SO_SNDTIMEO, Value, FSendTimeout);
end;

procedure TTCPConnection.SetRecvTimeout(Value: Cardinal);
begin
  SetSocketOpt(SO_RCVTIMEO, Value, FRecvTimeout);
end;

destructor TTCPConnection.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;



//##############################################################################
//############################ TTCPConnectionThread ############################
//##############################################################################

constructor TTCPConnectionThread.Create(Connection: TTCPConnection);
begin
  inherited Create(True);
  FConnection := Connection;
  OnTerminate := Connection.ThreadTerminate;
  FreeOnTerminate := True;
  Resume;
end;

procedure TTCPConnectionThread.Execute;
begin
  while not Terminated and FConnection.Connected and Assigned(FConnection.FOnExecute) do
    FConnection.FOnExecute(Self);
end;

procedure TTCPConnectionThread.Sync(SnycProc: TSynchronizeProcedure);
begin
  Synchronize(SnycProc);
end;

//##############################################################################
//############################ TTCPClientConnection ############################
//##############################################################################

function TTCPClientConnection.Connect(Addr: TSockAddr): Boolean;
begin
  if not Connected and CreateSocket then
  begin
    FConnected := WinSock.connect(FSocket, Addr, SizeOf(Addr)) <> SOCKET_ERROR;
    if not FConnected then
    begin
      HandleError;
      CloseSocket;
    end
    else if Assigned(FOnConnect) then
      FOnConnect(Self);
  end;
  Result := Connected;
end;

function TTCPClientConnection.Connect(Address: string; Port: Word): Boolean;
var
  Addr: TSockAddr;
begin
  Result := MakeAddr(Address, Port, Addr);
  if Result then
    Result := Connect(Addr);
end;

function TTCPClientConnection.Connect(AddressAndPort: string): Boolean;
var
  Address: string;
  Port: Word;
begin
  Result := SplitAddress(AddressAndPort, Address, Port);
  if Result then
    Result := Connect(Address, Port);
end;



//##############################################################################
//############################ TTCPServerConnection ############################
//##############################################################################

constructor TTCPServerConnection.Create(Server: TTCPServer);
begin
  inherited Create;
  FServer := Server;
  FOnDisconnect := Server.FOnDisconnect;
  FOnExecute := Server.FOnExecute;
  FOnError := Server.FOnError;
end;

procedure TTCPServerConnection.Disconnect;
begin
  inherited Disconnect;
  Server.ClientDisconnect(Self);
end;



//##############################################################################
//############################# TTCPListenerThread #############################
//##############################################################################

constructor TTCPListenerThread.Create(Server: TTCPServer; Socket: TTCPSocket);
begin
  inherited Create(True);
  FServer := Server;
  FTCPSocket := Socket;
  OnTerminate := Server.ListenerTerminate;
  FreeOnTerminate := True;
  Resume;
end;

procedure TTCPListenerThread.Execute;
var
  Connection: TTCPServerConnection;
begin
  repeat
    Connection := TTCPServerConnection.Create(FServer);
    Connection.FSocket := accept(FTCPSocket.FSocket, nil, nil);
    if Connection.FSocket = INVALID_SOCKET then
    begin
      Connection.Free;
      if Terminated or (FTCPSocket.FSocket = INVALID_SOCKET) then
        Break
      else
        FTCPSocket.HandleError;
    end
    else
      FServer.ClientConnect(Connection);
  until Terminated;
end;

destructor TTCPListenerThread.Destroy;
begin
  FTCPSocket.Free;
  inherited Destroy;
end;



//##############################################################################
//################################# TTCPBinding ################################
//##############################################################################

constructor TTCPBinding.Create(Address: string; Port: Word);
begin
  inherited Create;
  if MakeAddr(Address, Port, FAddr) then
  begin
    FAddress := Address;
    FPort := Port;
  end;
end;

constructor TTCPBinding.Create(AddressAndPort: string);
var
  Address: string;
  Port: Word;
begin
  if SplitAddress(AddressAndPort, Address, Port) then
    Create(Address, Port);
end;

constructor TTCPBinding.Create(Addr: TSockAddr);
begin
  inherited Create;
  FAddr := Addr;
  FAddr.sin_family := AF_INET;
  FPort := ntohs(Addr.sin_port);
  FAddress := inet_ntoa(Addr.sin_addr);
end;

procedure TTCPBinding.SetAddress(Value: string);
var
  X: TInAddr;
begin
  if Value <> FAddress then
  begin
    X := ResolveAddress(Value);
    if X.S_addr <> INADDR_NONE then
    begin
      FAddress := Value;
      FAddr.sin_addr := X;
    end;
  end;
end;



//##############################################################################
//################################# TTCPServer #################################
//##############################################################################

constructor TTCPServer.Create;
begin
  inherited Create;
  FListeners := TThreadList.Create;
  FConnections := TThreadList.Create;
  FBindings := TList.Create;
  FListening := False;
  FOnConnect := nil;
  FOnDisconnect := nil;
  FOnExecute := nil;
  FOnError := nil;
end;

procedure TTCPServer.SetListening(Value: Boolean);
var
  I, Len: Integer;
  Socket: TTCPSocket;
  Success: Boolean;
begin
  if Value <> FListening then
  begin
    if Value then
    begin
      Success := False;
      for I := 0 to FBindings.Count - 1 do
      begin
        Socket := TTCPSocket.Create;
        if Socket.CreateSocket then
          with TTCPBinding(FBindings[I]) do
            with Socket do
            begin
              Len := SizeOf(FAddr);
              OnError := Self.FOnError;
              if bind(FSocket, FAddr, Len) = SOCKET_ERROR then
              begin
                HandleError;
                Socket.Free;
              end
              else if WinSock.listen(FSocket, SOMAXCONN) = SOCKET_ERROR then
              begin
                HandleError;
                Socket.Free;
              end
              else
              begin
                FListeners.Add(TTCPListenerThread.Create(Self, Socket));
                Success := True;
              end;
            end;
      end;
      if Success then
        FListening := True;
    end
    else
    begin
      with FListeners.LockList do try
        for I := Count - 1 downto 0 do
          with TTCPListenerThread(Items[I]) do
          begin
            OnTerminate := nil;
            Terminate;
            FTCPSocket.CloseSocket;
            Remove(Items[I]);
          end;
      finally
        FListeners.UnlockList;
      end;

      with FConnections.LockList do try
        for I := Count - 1 downto 0 do
          with TTCPServerConnection(Items[I]) do
          begin
            Disconnect;
          end;
      finally
        FConnections.UnlockList;
      end;

      FListening := False;
    end;
  end;
end;

procedure TTCPServer.ListenerTerminate(Sender: TObject);
begin
  if Sender is TTCPListenerThread then
    FListeners.Remove(Sender);
end;

procedure TTCPServer.ClientConnect(Connection: TTCPServerConnection);
begin
  Connection.FConnected := True;
  FConnections.Add(Connection);
  if Assigned(FOnConnect) then
    FOnConnect(Connection);
end;

procedure TTCPServer.ClientDisconnect(Connection: TTCPServerConnection);
begin
  FConnections.Remove(Connection);
  Connection.Free;
end;

procedure TTCPServer.AddBinding(Binding: TTCPBinding);
begin
  FBindings.Add(Binding);
end;

procedure TTCPServer.ClearBindings;
var
  I: Integer;
begin
  for I := FBindings.Count - 1 downto 0 do
    TTCPBinding(FBindings[I]).Free;
end;

destructor TTCPServer.Destroy;
begin
  SetListening(False);
  ClearBindings;
  FListeners.Free;
  FConnections.Free;
  FBindings.Free;
  inherited Destroy;
end;


initialization
  WSAStartup(MakeWord(1, 1), WSAData);

finalization
  WSACleanup;

end.

