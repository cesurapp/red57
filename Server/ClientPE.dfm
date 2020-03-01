object PEForm: TPEForm
  Left = 1552
  Top = 113
  Width = 630
  Height = 799
  Caption = 'G'#246'rev Y'#246'neticisi'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 701
    Width = 614
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Panel2: TPanel
      Left = 406
      Top = 0
      Width = 208
      Height = 41
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object EndProcess: TButton
        Left = 96
        Top = 8
        Width = 105
        Height = 25
        Caption = 'G'#246'revi Sonland'#305'r'
        TabOrder = 0
        OnClick = EndProcessClick
      end
      object NewProcess: TButton
        Left = 8
        Top = 8
        Width = 81
        Height = 25
        Caption = 'Yeni G'#246'rev'
        TabOrder = 1
        OnClick = NewProcessClick
      end
    end
    object RefreshProcess: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Yenile'
      TabOrder = 1
      OnClick = RefreshProcessClick
    end
  end
  object ProcessList: TListView
    Left = 0
    Top = 0
    Width = 614
    Height = 701
    Align = alClient
    Columns = <
      item
        AutoSize = True
        Caption = 'Name'
      end
      item
        Caption = 'ID'
        Width = 75
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 742
    Width = 614
    Height = 19
    Panels = <>
    SimplePanel = True
  end
end
