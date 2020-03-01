unit ClientPE;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, uTypes,
  ComCtrls, ToolWin, Menus, StdCtrls, ExtCtrls;

type
  TPEForm = class(TCForm)
    Panel1: TPanel;
    ProcessList: TListView;
    Panel2: TPanel;
    EndProcess: TButton;
    NewProcess: TButton;
    RefreshProcess: TButton;
    StatusBar: TStatusBar;
    procedure EndProcessClick(Sender: TObject);
    procedure RefreshProcessClick(Sender: TObject);
    procedure NewProcessClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ExecuteThread(CMD: string = ''); override;
  end;

var
  PEForm: TPEForm;

implementation

uses DateUtils;

{$R *.dfm}

procedure TPEForm.ExecuteThread(CMD: string = '');
var
  SL: TStringList;
  MS: TMemoryStream;
  Size, i: Integer;
  Status: String;
begin
  if CMD = 'pe_list' then begin
    SL := TStringList.Create;
    MS := TMemoryStream.Create;

    // Read Stream
    Size := Client.ReadInteger;
    Client.ReadStream(MS, Size);
    SL.LoadFromStream(MS);

    // Add ListView
    ProcessList.Clear;
    for i := 0 to SL.Count - 1 do
      if (i mod 2 = 0) then begin
        with ProcessList.Items.Add do begin
          Caption := SL.Strings[i];
          SubItems.Insert(0, SL.Strings[i + 1]);
        end;
      end;
  end;

  if CMD = 'pe_kill' then begin
    Status := Client.ReadLn;

    if StrToBool(Status) then
      StatusBar.SimpleText := 'Görev Sonlandýrýldý!'
    else
      StatusBar.SimpleText := 'Ýþlem Baþarýsýz';
  end;

  if CMD = 'pe_new' then begin
    Status := Client.ReadLn;

    if StrToBool(Status) then
      StatusBar.SimpleText := 'Yeni Görev Çalýþtýrýldý!'
    else
      StatusBar.SimpleText := 'Ýþlem Baþarýsýz';
  end;
end;

{****************************************************************************
                              Process Explorer
****************************************************************************}

procedure TPEForm.RefreshProcessClick(Sender: TObject);
begin
  Client.WriteLn('pe_list');
end;

procedure TPEForm.EndProcessClick(Sender: TObject);
var
  ProcID: Integer;
begin
  if ProcessList.SelCount > 0 then begin
    ProcID := StrToInt(ProcessList.Selected.SubItems.Strings[0]);

    Client.WriteLn('pe_kill');
    Client.WriteInteger(ProcID);
  end;
end;

procedure TPEForm.NewProcessClick(Sender: TObject);
var
  Path: string;
begin
  Path := InputBox('Yeni Görev', 'Yeni görev için dosya yolunu girin', '');

  if Path <> '' then begin
    Client.WriteLn('pe_new');
    Client.WriteLn(Path);
  end;
end;

end.

