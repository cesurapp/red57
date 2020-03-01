object PreviewForm: TPreviewForm
  Left = 1556
  Top = 799
  Width = 800
  Height = 600
  Caption = 'PreviewForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object ImageBox: TImage
    Left = 0
    Top = 0
    Width = 784
    Height = 562
    Align = alClient
    AutoSize = True
    Proportional = True
  end
  object TextBox: TMemo
    Left = 0
    Top = 0
    Width = 784
    Height = 562
    Align = alClient
    ReadOnly = True
    TabOrder = 0
  end
end
