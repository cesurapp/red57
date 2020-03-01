object KeyloggerForm: TKeyloggerForm
  Left = 1416
  Top = 121
  Width = 1023
  Height = 727
  Caption = 'KeyloggerForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object LogList: TListBox
    Left = 0
    Top = 0
    Width = 161
    Height = 689
    Align = alLeft
    ItemHeight = 13
    TabOrder = 0
    OnClick = LogListClick
  end
  object Panel1: TPanel
    Left = 161
    Top = 0
    Width = 846
    Height = 689
    Align = alClient
    TabOrder = 1
    object Panel2: TPanel
      Left = 1
      Top = 658
      Width = 844
      Height = 30
      Align = alBottom
      TabOrder = 0
      object Search: TEdit
        Left = 7
        Top = 4
        Width = 250
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object SearchOne: TButton
        Left = 265
        Top = 4
        Width = 75
        Height = 22
        Caption = 'Bul'
        TabOrder = 1
        OnClick = SearchOneClick
      end
      object SearchAll: TButton
        Left = 346
        Top = 4
        Width = 90
        Height = 22
        Caption = 'T'#252'm'#252'n'#252' Bul'
        TabOrder = 2
        OnClick = SearchAllClick
      end
      object SaveLog: TButton
        Left = 443
        Top = 4
        Width = 75
        Height = 21
        Caption = 'Kaydet'
        TabOrder = 3
        OnClick = SaveLogClick
      end
    end
    object Viewer: TRichEdit
      Left = 1
      Top = 1
      Width = 844
      Height = 657
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
    end
  end
end
