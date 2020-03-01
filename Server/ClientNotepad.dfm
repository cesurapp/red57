object ClientNotepadForm: TClientNotepadForm
  Left = 1553
  Top = 797
  Width = 800
  Height = 600
  Caption = 'Not Defteri'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 784
    Height = 25
    Align = alTop
    TabOrder = 0
    object Save: TButton
      Left = 3
      Top = 2
      Width = 75
      Height = 21
      Caption = 'Kaydet'
      TabOrder = 0
      OnClick = SaveClick
    end
  end
  object Editor: TMemo
    Left = 0
    Top = 25
    Width = 784
    Height = 537
    Align = alClient
    Enabled = False
    TabOrder = 1
  end
end
