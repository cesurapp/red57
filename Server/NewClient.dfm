object FormNewClient: TFormNewClient
  Left = 1626
  Top = 420
  BorderStyle = bsSingle
  Caption = 'Yeni Client Olu'#351'tur'
  ClientHeight = 151
  ClientWidth = 190
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object CreateNewClient: TButton
    Left = 40
    Top = 64
    Width = 113
    Height = 25
    Caption = 'Create New Client'
    TabOrder = 0
    OnClick = CreateNewClientClick
  end
  object SelectClient: TButton
    Left = 40
    Top = 24
    Width = 113
    Height = 25
    Caption = 'Select Client Exe'
    TabOrder = 1
    OnClick = SelectClientClick
  end
  object CreateResArchive: TButton
    Left = 40
    Top = 104
    Width = 113
    Height = 25
    Caption = 'Create RES Archive'
    TabOrder = 2
    OnClick = CreateResArchiveClick
  end
  object SaveDialog: TSaveDialog
    FileName = 'client'
  end
  object OpenDialog: TOpenDialog
    DefaultExt = '.exe'
    Filter = 'XRed57 (.exe)|*.exe'
    Top = 32
  end
  object ODM: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing, ofForceShowHidden]
    Top = 64
  end
  object SDM: TSaveDialog
    FileName = 'archive'
    Top = 96
  end
end
