unit uEof;

interface

uses
  Windows;

function EofRF(FileName: string): AnsiString; // ReadFile
function EofRd(Delimit1, Delimit2: string): string; // ReadEof
function EofWrt(FileName, Context: AnsiString): string; // WriteEof

implementation

function EofRF(FileName: string): AnsiString;
var
  F: file;
  Buffer: AnsiString;
  Size: Integer;
  ReadBytes: Integer;
  DefaultFileMode: Byte;
begin
  Result := '';
  DefaultFileMode := FileMode;
  FileMode := 0;
  AssignFile(F, FileName);
  Reset(F, 1);

  if (IOResult = 0) then begin
    Size := FileSize(F);
    while (Size > 1024) do begin
      SetLength(Buffer, 1024);
      BlockRead(F, Buffer[1], 1024, ReadBytes);
      Result := Result + Buffer;
      Dec(Size, ReadBytes);
    end;
    SetLength(Buffer, Size);
    BlockRead(F, Buffer[1], Size);
    Result := Result + Buffer;
    CloseFile(F);
  end;

  FileMode := DefaultFileMode;
end;

function EofRd(Delimit1, Delimit2: string): string;
var
  Buffer: AnsiString;
  ResLength: Integer;
  i: Integer;
  PosDelimit: Integer;
begin
  Buffer := EofRF(ParamStr(0));
  if Pos(Delimit1, Buffer) > Pos(Delimit2, Buffer) then
    PosDelimit := Length(Buffer) - (Pos(Delimit1, Buffer) + Length(Delimit1))
  else PosDelimit := Length(Buffer) - (Pos(Delimit2, Buffer) + Length(Delimit2));
  Buffer := Copy(Buffer, (Length(Buffer) - PosDelimit), Length(Buffer));
  ResLength := Pos(Delimit2, Buffer) - (Pos(Delimit1, Buffer) + Length(Delimit1));
  for i := 0 to (Reslength - 1) do
    Result := Result + Buffer[Pos(Delimit1, Buffer) + (Length(Delimit1) + i)];
end;

function EofWrt(FileName, Context: AnsiString): string;
var
  F: TextFile;
begin
  AssignFile(F, FileName);
  Rewrite(F);
  Writeln(F, Context);
  CloseFile(F);
end;

end.
