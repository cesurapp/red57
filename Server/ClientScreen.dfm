object ScreenForm: TScreenForm
  Left = 152
  Top = 28
  Width = 1177
  Height = 812
  Caption = 'Ekran ve Kamera G'#246'r'#252'nt'#252' Yakalama'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage
    Left = 0
    Top = 33
    Width = 1161
    Height = 741
    Align = alClient
    AutoSize = True
    Proportional = True
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1161
    Height = 33
    Align = alTop
    TabOrder = 0
    object ScreenCapture: TButton
      Left = 6
      Top = 4
      Width = 115
      Height = 25
      Caption = 'Ekran G'#246'r'#252'nt'#252's'#252' Al'
      TabOrder = 0
      OnClick = ScreenCaptureClick
    end
    object StartCaptureTimer: TButton
      Left = 120
      Top = 4
      Width = 113
      Height = 25
      Caption = 'Zamanlay'#305'c'#305' '#199'al'#305#351't'#305'r'
      TabOrder = 1
      OnClick = StartCaptureTimerClick
    end
    object CaptureSave: TCheckBox
      Left = 240
      Top = 8
      Width = 113
      Height = 17
      Caption = 'G'#246'r'#252'nt'#252'leri Kaydet'
      TabOrder = 2
    end
  end
end
