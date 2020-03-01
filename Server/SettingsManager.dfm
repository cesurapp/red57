object FormSettings: TFormSettings
  Left = 1585
  Top = 168
  BorderStyle = bsSingle
  Caption = 'FormSettings'
  ClientHeight = 191
  ClientWidth = 449
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 249
    Height = 81
    Caption = 'Sistem Tray'
    TabOrder = 0
    object PlayConnectSound: TCheckBox
      Left = 16
      Top = 22
      Width = 209
      Height = 17
      Caption = 'Client Ba'#287'land'#305#287#305'nda Uyar'#305' Sesi '#199'al'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object PlayDisconnectSound: TCheckBox
      Left = 16
      Top = 46
      Width = 209
      Height = 17
      Caption = 'Client Ba'#287'lant'#305's'#305' Kesilirse Uyar'#305' Sesi '#199'al'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 264
    Top = 8
    Width = 177
    Height = 81
    Caption = 'Server Portu'
    TabOrder = 1
    object ServerPort: TEdit
      Left = 16
      Top = 23
      Width = 145
      Height = 21
      TabOrder = 0
      Text = '1200'
    end
  end
  object ButtonSave: TButton
    Left = 264
    Top = 159
    Width = 177
    Height = 25
    Caption = 'Kaydet ve Kapat'
    TabOrder = 2
    OnClick = ButtonSaveClick
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 95
    Width = 433
    Height = 58
    Caption = 'Dns Update URL'
    TabOrder = 3
    object DnsUpdateURL: TEdit
      Left = 16
      Top = 23
      Width = 401
      Height = 21
      TabOrder = 0
      Text = 'http://sync.afraid.org/u/Vs2wSeLQtqp570Orsp1p6Tio/'
    end
  end
end
