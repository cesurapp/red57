unit uCon;

interface

uses
  Windows, Classes, Sysutils;

type
  TCon = class(TComponent)
  private
    InputPipeRead, InputPipeWrite: THandle;
    OutputPipeRead, OutputPipeWrite: THandle;
    ErrorPipeRead, ErrorPipeWrite: THandle;
    ProcessInfo: TProcessInformation;
  public
    destructor Destroy; override;
    function Start():Boolean;
    procedure Stop();
    procedure Send(C: String);
    function Output(): AnsiString;
  end;

implementation

destructor TCon.Destroy;
begin
  Stop;
  inherited Destroy;
end;


function TCon.Start(): Boolean;
var
  DosApp: string;
  DosSize: Integer;
  Security: TSecurityAttributes;
  Start: TStartUpInfo;
  BytesRem: Integer;
begin
  Result := False;
  SetLength(Dosapp, 255);
  DosSize := GetEnvironmentVariable('COMSPEC', @DosApp[1], 255);
  SetLength(Dosapp, DosSize);

  with Security do begin
    nlength := SizeOf(TSecurityAttributes);
    binherithandle := true;
    lpsecuritydescriptor := nil;
  end;

  CreatePipe(InputPipeRead, InputPipeWrite, @Security, 0);
  CreatePipe(OutputPipeRead, OutputPipeWrite, @Security, 0);
  //CreatePipe(ErrorPipeRead, ErrorPipeWrite, @Security, 0);

  FillChar(Start, Sizeof(Start), #0);
  start.cb := SizeOf(start);
  start.hStdInput := InputPipeRead;
  start.hStdOutput := OutputPipeWrite;
  start.hStdError := OutputPipeWrite;
  start.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
  start.wShowWindow := SW_HIDE;
  if CreateProcess(nil, PChar(DosApp), @Security, @Security, true, CREATE_NEW_CONSOLE or SYNCHRONIZE, nil, nil, Start, ProcessInfo) then
    Result := True;
end; { Start -> Create CMD Instance }

procedure TCon.Stop();
begin
  Send('exit');
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);
  CloseHandle(InputPipeRead);
  CloseHandle(InputPipeWrite);
  CloseHandle(OutputPipeRead);
  CloseHandle(OutputPipeWrite);
  //CloseHandle(ErrorPipeRead);
  //CloseHandle(ErrorPipeWrite);
end; { Stop -> Destroy CMD Instance }

procedure TCon.Send(C: String);
var
  BytesWritten: DWord;
  Buf: AnsiString;
begin
  C := C + ' & set /a 2*733572018' + #13#10;

  SetLength(Buf, Length(C));
  CharToOem(PAnsiChar(C), PAnsiChar(Buf));

  WriteFile(InputPipeWrite, Buf[1], Length(Buf), BytesWritten, nil);
end; { Send -> Send CMD Command }

function TCon.Output(): AnsiString;
var
  TextBuffer: array[1..32767] of AnsiChar;
  TextString: string;
  BytesRead: Cardinal;
  PipeSize: Integer;
  BytesRem: Integer;
begin
  Result := '';
  PipeSize := Sizeof(TextBuffer);
  while true do begin
    PeekNamedPipe(OutputPipeRead, nil, PipeSize, @BytesRead, @PipeSize, @BytesRem);
    if BytesRead > 0 then
    begin
      ReadFile(OutputPipeRead, TextBuffer, PipeSize, BytesRead, nil);
      OemToAnsi(@TextBuffer, @TextBuffer);
      TextString := String(TextBuffer);
      SetLength(TextString, BytesRead);
      Result := Result + TextString;

      if POS('1467144036', Result) > 0 then begin
        Result := StringReplace(Result, ' & set /a 2*733572018', '', [rfReplaceAll]);
        Result := StringReplace(Result, '1467144036', '', [rfReplaceAll]);
        Break;
      end;

      Sleep(75);
    end;
  end;
end; { Output -> Get CMD Output }

end.

