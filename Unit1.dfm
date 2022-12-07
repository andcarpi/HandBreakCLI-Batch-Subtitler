object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'frmPrincipal'
  ClientHeight = 688
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object pbSourceLocation: TGroupBox
    Left = 8
    Top = 8
    Width = 608
    Height = 57
    Caption = 'Localiza'#231#227'o dos V'#237'deos'
    TabOrder = 0
    object Button1: TButton
      Left = 572
      Top = 24
      Width = 31
      Height = 25
      Margins.Right = 5
      Caption = '...'
      TabOrder = 1
      OnClick = Button1Click
    end
    object edtSource: TEdit
      Left = 7
      Top = 25
      Width = 565
      Height = 23
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      ReadOnly = True
      TabOrder = 0
    end
  end
  object gb: TGroupBox
    Left = 8
    Top = 71
    Width = 608
    Height = 57
    Caption = 'Salvar em'
    TabOrder = 1
    object Button2: TButton
      Left = 570
      Top = 23
      Width = 31
      Height = 25
      Margins.Right = 5
      Caption = '...'
      TabOrder = 1
      OnClick = Button1Click
    end
    object edtOutput: TEdit
      Left = 7
      Top = 24
      Width = 563
      Height = 23
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      ReadOnly = True
      TabOrder = 0
    end
  end
  object PngBitBtn1: TPngBitBtn
    Left = 328
    Top = 632
    Width = 75
    Height = 25
    Caption = 'Codificar'
    TabOrder = 2
    OnClick = PngBitBtn1Click
  end
  object gpbFileList: TGroupBox
    Left = 8
    Top = 134
    Width = 608
    Height = 355
    Caption = 'Lista de Arquivos'
    TabOrder = 3
    DesignSize = (
      608
      355)
    object lblArquivosEncontrados: TLabel
      Left = 424
      Top = -2
      Width = 177
      Height = 15
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Transparent = False
    end
    object fileList: TCheckListBox
      Left = 7
      Top = 19
      Width = 594
      Height = 326
      ItemHeight = 15
      TabOrder = 0
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 495
    Width = 608
    Height = 122
    Caption = 'Op'#231#245'es'
    TabOrder = 4
    object Label1: TLabel
      Left = 7
      Top = 23
      Width = 126
      Height = 15
      Caption = 'Local do Handbreak CLI'
    end
    object Label2: TLabel
      Left = 471
      Top = 23
      Width = 120
      Height = 15
      Caption = 'Arquivos sem Legenda'
    end
    object Label3: TLabel
      Left = 134
      Top = 71
      Width = 105
      Height = 15
      Caption = 'Preset de Qualidade'
    end
    object edtHandBreak: TEdit
      Left = 5
      Top = 40
      Width = 418
      Height = 23
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      ReadOnly = True
      TabOrder = 0
      Text = 'F:\OneDrive - Unesp\'#193'rea de Trabalho\Vidoe\HandBrakeCLI.exe'
    end
    object Button3: TButton
      Left = 424
      Top = 39
      Width = 31
      Height = 25
      Margins.Right = 5
      Caption = '...'
      TabOrder = 1
      OnClick = Button3Click
    end
    object cbSemLegenda: TComboBox
      Left = 471
      Top = 40
      Width = 130
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 2
      Text = 'Ignorar'
      Items.Strings = (
        'Ignorar'
        'Copiar')
    end
    object edtFiltro: TLabeledEdit
      Left = 6
      Top = 87
      Width = 121
      Height = 23
      EditLabel.Width = 93
      EditLabel.Height = 15
      EditLabel.Caption = 'Filtro de Arquivos'
      TabOrder = 3
      Text = '*.mp4'
    end
    object cbPreset: TComboBox
      Left = 133
      Top = 87
      Width = 130
      Height = 23
      Style = csDropDownList
      ItemIndex = 5
      TabOrder = 4
      Text = 'Fast 720p30'
      Items.Strings = (
        'Very Fast 1080p30'
        'Very Fast 720p30'
        'Very Fast 576p25'
        'Very Fast 480p30'
        'Fast 1080p30'
        'Fast 720p30'
        'Fast 576p25'
        'Fast 480p30'
        'HQ 1080p30 Surround'
        'HQ 720p30 Surround'
        'HQ 576p25 Surround'
        'HQ 480p30 Surround'
        'Super HQ 1080p30 Surround'
        'Super HQ 720p30 Surround'
        'Super HQ 576p25 Surround'
        'Super HQ 480p30 Surround')
    end
  end
  object odDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Title = 'Selecione o Diret'#243'rio'
    Left = 456
    Top = 432
  end
  object hbDialog: TOpenDialog
    FileName = 'handbreakcli.exe'
    Filter = 'HandBreakCLI|*.exe'
    Title = 'Localiza'#231#227'o do HandBreakCLI'
    Left = 248
    Top = 302
  end
end
