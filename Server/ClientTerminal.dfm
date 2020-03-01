object TerminalForm: TTerminalForm
  Left = 1560
  Top = 690
  Width = 808
  Height = 696
  Caption = 'Terminal'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Output: TMemo
    Left = 0
    Top = 0
    Width = 792
    Height = 637
    Align = alClient
    BevelEdges = [beTop, beBottom]
    BevelInner = bvNone
    BevelKind = bkFlat
    BevelOuter = bvRaised
    BorderStyle = bsNone
    Color = clBlack
    Font.Charset = TURKISH_CHARSET
    Font.Color = 46848
    Font.Height = -15
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 637
    Width = 792
    Height = 21
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Command: TMemo
      Left = 0
      Top = 0
      Width = 792
      Height = 21
      Align = alClient
      BorderStyle = bsNone
      Color = clInfoText
      Font.Charset = TURKISH_CHARSET
      Font.Color = 46848
      Font.Height = -15
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
  end
end
