program TCPClient;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  INIFiles,
  Cli in 'Cli.pas',
  CliP in 'CliP.pas',
  uEnc in 'uEnc.pas',
  uList in '..\Server\uList.pas',
  uSockets in '..\Server\uSockets.pas',
  uThread in '..\Server\uThread.pas',
  uAnt in 'uAnt.pas',
  uTypes in 'uTypes.pas',
  uEof in 'uEof.pas',
  PJResFile in '..\Server\PJResFile.pas';

// Global Variables
var
  ConfigData: TCnfg;
  Client: TCli;

procedure LoadConfig();
begin
  // Create Config Class Object
  ConfigData := TCnfg.Create;

  // Set Default Value
  with ConfigData do begin
    TpP := '192.168.1.99';
    TpPo := 1200;
    TpTmr := 3000;
  end;

  // Load Config File
  LdCnf(ConfigData);
end;

begin
// Load Configuration
LoadConfig;

// Create Client
with TCli.Create(, ConfigData);


Readln;
end.
