unit NewClient;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, INIFiles, uEnc, PE_Files, PjResFile, uEof;

type
  TFormNewClient = class(TForm)
    SaveDialog: TSaveDialog;
    CreateNewClient: TButton;
    SelectClient: TButton;
    OpenDialog: TOpenDialog;
    CreateResArchive: TButton;
    ODM: TOpenDialog;
    SDM: TSaveDialog;
    procedure SelectClientClick(Sender: TObject);
    procedure CreateNewClientClick(Sender: TObject);
    procedure CreateResArchiveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormNewClient: TFormNewClient;
  ClientFile: string;

implementation

{$R *.dfm}

procedure TFormNewClient.SelectClientClick(Sender: TObject);
begin
  if OpenDialog.Execute then begin
    ClientFile := OpenDialog.FileName;
  end;
end; { SelectClientClick -> Select Client Exe }

procedure PeOptimize(FilePath: string);
var
  PE: PE_File;
begin
  PE := PE_File.Create;
  PE.LoadFromFile(FilePath);
  PE.OptimizeHeader(True);
  PE.OptimizeFileAlignment;
  PE.FlushFileCheckSum;
  PE.OptimizeFile(True, True, True, False);
  PE.SaveToFile(FilePath);
  PE.Free;
end; { PeOptimize -> Optimize PE Header }

procedure RemoveResource(FilePath: string; ResName: PAnsiChar; ResType: PAnsiChar);
var
  FS: TFileStream;
  Hndle: THandle;
  DLength: DWord;
  Data: Pointer;
begin
  // Open Update Resources
  Hndle := BeginUpdateResource(PChar(FilePath), False);

  if Hndle <> 0 then
  try
    // Update Resources
    UpdateResource(Hndle, ResType, ResName, LANG_NEUTRAL, nil, 0);

    // Save Changes
    EndUpdateResource(Hndle, False);
  finally
    FreeLibrary(Hndle);
  end;
end; { RemoveResource -> Header Remove Resource }

procedure TFormNewClient.CreateNewClientClick(Sender: TObject);
var
  ClientPath : String;
begin
  if ClientFile <> '' then begin
    if SaveDialog.Execute then begin
      ClientPath := SaveDialog.FileName;

      // New Copy Client
      CopyFile(PChar(ClientFile), PChar(ClientPath), False);

      // Optimize PE
      PeOptimize(ClientPath);

      // Remove Resources
      RemoveResource(ClientPath, 'DESCRIPTION', RT_RCDATA);
      RemoveResource(ClientPath, 'DVCLAL', RT_RCDATA);
      RemoveResource(ClientPath, 'PACKAGEINFO', RT_RCDATA);

      RemoveResource(ClientPath, 'BBABORT', RT_BITMAP);
      RemoveResource(ClientPath, 'BBALL', RT_BITMAP);
      RemoveResource(ClientPath, 'BBCANCEL', RT_BITMAP);
      RemoveResource(ClientPath, 'BBCLOSE', RT_BITMAP);
      RemoveResource(ClientPath, 'BBHELP', RT_BITMAP);
      RemoveResource(ClientPath, 'BBIGNORE', RT_BITMAP);
      RemoveResource(ClientPath, 'BBNO', RT_BITMAP);
      RemoveResource(ClientPath, 'BBOK', RT_BITMAP);
      RemoveResource(ClientPath, 'BBRETRY', RT_BITMAP);
      RemoveResource(ClientPath, 'BBYES', RT_BITMAP);
      RemoveResource(ClientPath, 'PREVIEWGLYPH', RT_BITMAP);

      RemoveResource(ClientPath, PChar(1), RT_CURSOR);
      RemoveResource(ClientPath, PChar(2), RT_CURSOR);
      RemoveResource(ClientPath, PChar(3), RT_CURSOR);
      RemoveResource(ClientPath, PChar(4), RT_CURSOR);
      RemoveResource(ClientPath, PChar(5), RT_CURSOR);
      RemoveResource(ClientPath, PChar(6), RT_CURSOR);
      RemoveResource(ClientPath, PChar(7), RT_CURSOR);

      RemoveResource(ClientPath, PChar(32761), RT_GROUP_CURSOR);
      RemoveResource(ClientPath, PChar(32762), RT_GROUP_CURSOR);
      RemoveResource(ClientPath, PChar(32763), RT_GROUP_CURSOR);
      RemoveResource(ClientPath, PChar(32764), RT_GROUP_CURSOR);
      RemoveResource(ClientPath, PChar(32765), RT_GROUP_CURSOR);
      RemoveResource(ClientPath, PChar(32766), RT_GROUP_CURSOR);
      RemoveResource(ClientPath, PChar(32767), RT_GROUP_CURSOR);

      RemoveResource(ClientPath, PChar(4079), RT_STRING);
      RemoveResource(ClientPath, PChar(4080), RT_STRING);
      RemoveResource(ClientPath, PChar(4081), RT_STRING);
      RemoveResource(ClientPath, PChar(4082), RT_STRING);
      RemoveResource(ClientPath, PChar(4083), RT_STRING);
      RemoveResource(ClientPath, PChar(4084), RT_STRING);
      RemoveResource(ClientPath, PChar(4085), RT_STRING);
      RemoveResource(ClientPath, PChar(4086), RT_STRING);
      RemoveResource(ClientPath, PChar(4087), RT_STRING);
      RemoveResource(ClientPath, PChar(4088), RT_STRING);
      RemoveResource(ClientPath, PChar(4089), RT_STRING);
      RemoveResource(ClientPath, PChar(4090), RT_STRING);
      RemoveResource(ClientPath, PChar(4091), RT_STRING);
      RemoveResource(ClientPath, PChar(4092), RT_STRING);
      RemoveResource(ClientPath, PChar(4093), RT_STRING);
      RemoveResource(ClientPath, PChar(4094), RT_STRING);
      RemoveResource(ClientPath, PChar(4095), RT_STRING);
      RemoveResource(ClientPath, PChar(4096), RT_STRING);

      RemoveResource(ClientPath, 'DLGTEMPLATE', RT_DIALOG);
    end;
  end else
    ShowMessage('Client Exe Dosyasýný Seçin!');
end; { CreateNewClientClick -> Create New Client and Optimize Header }

procedure TFormNewClient.CreateResArchiveClick(Sender: TObject);
var
  i : Integer;
  FS: TFileStream;
  ResFile: TPJResourceFile;
  ResItem: TPJResourceEntry;
  FileContext: AnsiString;
begin
  // Create Resource File
  ResFile := TPJResourceFile.Create;

  // Add Resource Data
  if ODM.Execute then begin
    for i := 0 to ODM.Files.Count - 1 do begin
      // Add Empty Resource
      ResItem := ResFile.AddEntry(RT_RCDATA, PChar(ExtractFileName(ODM.Files.Strings[i])), 0);

      // Read File Content
      FileContext := EN(EofRF(ODM.Files.Strings[i]));

      // Write Resource
      ResItem.Data.WriteBuffer(Pointer(FileContext)^, Length(FileContext));
    end;

    // Save Resource to File
    if ODM.Files.Count > 0 then
      if SDM.Execute then
        ResFile.SaveToFile(SDM.FileName);
  end;
end; { CreateResArchiveClick -> Res Arþivi Oluþturur }

end.

