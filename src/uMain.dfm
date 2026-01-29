object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'API Cielo - Links de Pagamento'
  ClientHeight = 780
  ClientWidth = 1180
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PageMain: TPageControl
    Left = 8
    Top = 8
    Width = 1164
    Height = 764
    ActivePage = TabConfig
    TabOrder = 0
    object TabConfig: TTabSheet
      Caption = 'Configuracao e Autenticacao'
      object lblMerchantId: TLabel
        Left = 16
        Top = 16
        Width = 62
        Height = 13
        Caption = 'MerchantId'
      end
      object lblMerchantKey: TLabel
        Left = 16
        Top = 64
        Width = 70
        Height = 13
        Caption = 'MerchantKey'
      end
      object lblEnvironment: TLabel
        Left = 16
        Top = 112
        Width = 67
        Height = 13
        Caption = 'Ambiente API'
      end
      object lblTimeout: TLabel
        Left = 16
        Top = 160
        Width = 61
        Height = 13
        Caption = 'Timeout (ms)'
      end
      object lblTestPaymentId: TLabel
        Left = 16
        Top = 224
        Width = 101
        Height = 13
        Caption = 'PaymentId para teste'
      end
      object edtMerchantId: TEdit
        Left = 16
        Top = 32
        Width = 520
        Height = 21
        TabOrder = 0
      end
      object edtMerchantKey: TEdit
        Left = 16
        Top = 80
        Width = 520
        Height = 21
        PasswordChar = '*'
        TabOrder = 1
      end
      object cbEnvironment: TComboBox
        Left = 16
        Top = 128
        Width = 200
        Height = 21
        Style = csDropDownList
        TabOrder = 2
      end
      object edtTimeout: TEdit
        Left = 16
        Top = 176
        Width = 120
        Height = 21
        TabOrder = 3
      end
      object edtTestPaymentId: TEdit
        Left = 16
        Top = 240
        Width = 520
        Height = 21
        TabOrder = 4
      end
      object btnLoadConfig: TButton
        Left = 560
        Top = 32
        Width = 120
        Height = 25
        Caption = 'Carregar INI'
        TabOrder = 5
        OnClick = btnLoadConfigClick
      end
      object btnSaveConfig: TButton
        Left = 560
        Top = 80
        Width = 120
        Height = 25
        Caption = 'Salvar INI'
        TabOrder = 6
        OnClick = btnSaveConfigClick
      end
      object btnTestAuth: TButton
        Left = 560
        Top = 238
        Width = 120
        Height = 25
        Caption = 'Testar Auth'
        TabOrder = 7
        OnClick = btnTestAuthClick
      end
      object memoAuthResult: TMemo
        Left = 16
        Top = 280
        Width = 1040
        Height = 200
        ScrollBars = ssVertical
        TabOrder = 8
      end
    end
    object TabLink: TTabSheet
      Caption = 'Geracao e Consulta'
      object grpCreateLink: TGroupBox
        Left = 16
        Top = 16
        Width = 1120
        Height = 416
        Caption = 'Geracao de Link'
        TabOrder = 0
        object lblExpiration: TLabel
          Left = 16
          Top = 24
          Width = 83
          Height = 13
          Caption = 'Data expiracao'
        end
        object lblTitle: TLabel
          Left = 200
          Top = 24
          Width = 30
          Height = 13
          Caption = 'Titulo'
        end
        object lblOrderNumber: TLabel
          Left = 520
          Top = 24
          Width = 82
          Height = 13
          Caption = 'Numero do pedido'
        end
        object lblAmount: TLabel
          Left = 16
          Top = 72
          Width = 60
          Height = 13
          Caption = 'Valor total'
        end
        object lblInstallments: TLabel
          Left = 160
          Top = 72
          Width = 86
          Height = 13
          Caption = 'Qtde parcelas'
        end
        object lblPaymentType: TLabel
          Left = 300
          Top = 72
          Width = 74
          Height = 13
          Caption = 'Tipo pagamento'
        end
        object lblReturnUrl: TLabel
          Left = 520
          Top = 72
          Width = 106
          Height = 13
          Caption = 'URL retorno/pagamento'
        end
        object lblCustomerName: TLabel
          Left = 16
          Top = 120
          Width = 79
          Height = 13
          Caption = 'Nome cliente'
        end
        object lblSoftDescriptor: TLabel
          Left = 300
          Top = 120
          Width = 72
          Height = 13
          Caption = 'SoftDescriptor'
        end
        object lblCapture: TLabel
          Left = 520
          Top = 120
          Width = 40
          Height = 13
          Caption = 'Captura'
        end
        object lblAuthenticate: TLabel
          Left = 620
          Top = 120
          Width = 63
          Height = 13
          Caption = 'Autenticacao'
        end
        object lblDescription: TLabel
          Left = 16
          Top = 168
          Width = 52
          Height = 13
          Caption = 'Descricao'
        end
        object lblAdditionalJson: TLabel
          Left = 520
          Top = 168
          Width = 76
          Height = 13
          Caption = 'JSON adicional'
        end
        object lblMerchantFields: TLabel
          Left = 520
          Top = 272
          Width = 196
          Height = 13
          Caption = 'MerchantDefinedFields (id=valor)'
        end
        object dtpExpiration: TDateTimePicker
          Left = 16
          Top = 40
          Width = 160
          Height = 21
          Date = 45200.000000000000000000
          Time = 0.000000000000000000
          TabOrder = 0
        end
        object edtTitle: TEdit
          Left = 200
          Top = 40
          Width = 300
          Height = 21
          TabOrder = 1
        end
        object edtOrderNumber: TEdit
          Left = 520
          Top = 40
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object edtAmount: TEdit
          Left = 16
          Top = 88
          Width = 120
          Height = 21
          TabOrder = 3
        end
        object edtInstallments: TEdit
          Left = 160
          Top = 88
          Width = 120
          Height = 21
          TabOrder = 4
        end
        object cbPaymentType: TComboBox
          Left = 300
          Top = 88
          Width = 200
          Height = 21
          Style = csDropDownList
          TabOrder = 5
        end
        object edtReturnUrl: TEdit
          Left = 520
          Top = 88
          Width = 560
          Height = 21
          TabOrder = 6
        end
        object edtCustomerName: TEdit
          Left = 16
          Top = 136
          Width = 260
          Height = 21
          TabOrder = 7
        end
        object edtSoftDescriptor: TEdit
          Left = 300
          Top = 136
          Width = 200
          Height = 21
          TabOrder = 8
        end
        object chkCapture: TCheckBox
          Left = 520
          Top = 136
          Width = 70
          Height = 17
          Caption = 'Ativar'
          TabOrder = 9
        end
        object chkAuthenticate: TCheckBox
          Left = 620
          Top = 136
          Width = 70
          Height = 17
          Caption = 'Ativar'
          TabOrder = 10
        end
        object memoDescription: TMemo
          Left = 16
          Top = 184
          Width = 480
          Height = 80
          ScrollBars = ssVertical
          TabOrder = 11
        end
        object memoAdditionalJson: TMemo
          Left = 520
          Top = 184
          Width = 560
          Height = 80
          ScrollBars = ssVertical
          TabOrder = 12
        end
        object memoMerchantFields: TMemo
          Left = 520
          Top = 288
          Width = 560
          Height = 48
          ScrollBars = ssVertical
          TabOrder = 13
        end
        object chkIncludeCard: TCheckBox
          Left = 16
          Top = 272
          Width = 140
          Height = 17
          Caption = 'Incluir dados do cartao'
          TabOrder = 14
          OnClick = chkIncludeCardClick
        end
        object grpCardData: TGroupBox
          Left = 16
          Top = 344
          Width = 760
          Height = 56
          Caption = 'Dados do cartao'
          TabOrder = 15
          object lblCardNumber: TLabel
            Left = 12
            Top = 16
            Width = 68
            Height = 13
            Caption = 'Numero cartao'
          end
          object lblCardHolder: TLabel
            Left = 180
            Top = 16
            Width = 63
            Height = 13
            Caption = 'Portador'
          end
          object lblCardExp: TLabel
            Left = 360
            Top = 16
            Width = 60
            Height = 13
            Caption = 'Validade'
          end
          object lblCardCvv: TLabel
            Left = 450
            Top = 16
            Width = 21
            Height = 13
            Caption = 'CVV'
          end
          object lblCardBrand: TLabel
            Left = 520
            Top = 16
            Width = 44
            Height = 13
            Caption = 'Bandeira'
          end
          object edtCardNumber: TEdit
            Left = 12
            Top = 30
            Width = 160
            Height = 21
            TabOrder = 0
          end
          object edtCardHolder: TEdit
            Left = 180
            Top = 30
            Width = 170
            Height = 21
            TabOrder = 1
          end
          object edtCardExp: TEdit
            Left = 360
            Top = 30
            Width = 80
            Height = 21
            TabOrder = 2
          end
          object edtCardCvv: TEdit
            Left = 450
            Top = 30
            Width = 60
            Height = 21
            TabOrder = 3
          end
          object cbCardBrand: TComboBox
            Left = 520
            Top = 30
            Width = 120
            Height = 21
            Style = csDropDownList
            TabOrder = 4
          end
        end
        object btnCreateLink: TButton
          Left = 840
          Top = 344
          Width = 120
          Height = 25
          Caption = 'Gerar Link'
          TabOrder = 16
          OnClick = btnCreateLinkClick
        end
      end
      object memoCreateResponse: TMemo
        Left = 16
        Top = 440
        Width = 1120
        Height = 80
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object grpConsult: TGroupBox
        Left = 16
        Top = 536
        Width = 1120
        Height = 220
        Caption = 'Consulta / Resultado'
        TabOrder = 2
        object lblPaymentId: TLabel
          Left = 16
          Top = 24
          Width = 55
          Height = 13
          Caption = 'PaymentId'
        end
        object lblTid: TLabel
          Left = 16
          Top = 72
          Width = 18
          Height = 13
          Caption = 'TID'
        end
        object lblAuthorization: TLabel
          Left = 200
          Top = 72
          Width = 63
          Height = 13
          Caption = 'Autorizacao'
        end
        object lblNsu: TLabel
          Left = 360
          Top = 72
          Width = 23
          Height = 13
          Caption = 'NSU'
        end
        object lblBrandOut: TLabel
          Left = 480
          Top = 72
          Width = 44
          Height = 13
          Caption = 'Bandeira'
        end
        object lblInstallmentsOut: TLabel
          Left = 600
          Top = 72
          Width = 79
          Height = 13
          Caption = 'Qtde parcelas'
        end
        object lblInstallmentAmountOut: TLabel
          Left = 720
          Top = 72
          Width = 90
          Height = 13
          Caption = 'Valor parcela'
        end
        object lblAmountOut: TLabel
          Left = 840
          Top = 72
          Width = 55
          Height = 13
          Caption = 'Valor total'
        end
        object lblLinkUrlOut: TLabel
          Left = 16
          Top = 120
          Width = 44
          Height = 13
          Caption = 'Link URL'
        end
        object edtPaymentId: TEdit
          Left = 16
          Top = 40
          Width = 520
          Height = 21
          TabOrder = 0
        end
        object edtTid: TEdit
          Left = 16
          Top = 88
          Width = 160
          Height = 21
          ReadOnly = True
          TabOrder = 1
        end
        object edtAuthorization: TEdit
          Left = 200
          Top = 88
          Width = 140
          Height = 21
          ReadOnly = True
          TabOrder = 2
        end
        object edtNsu: TEdit
          Left = 360
          Top = 88
          Width = 100
          Height = 21
          ReadOnly = True
          TabOrder = 3
        end
        object edtBrandOut: TEdit
          Left = 480
          Top = 88
          Width = 100
          Height = 21
          ReadOnly = True
          TabOrder = 4
        end
        object edtInstallmentsOut: TEdit
          Left = 600
          Top = 88
          Width = 100
          Height = 21
          ReadOnly = True
          TabOrder = 5
        end
        object edtInstallmentAmountOut: TEdit
          Left = 720
          Top = 88
          Width = 100
          Height = 21
          ReadOnly = True
          TabOrder = 6
        end
        object edtAmountOut: TEdit
          Left = 840
          Top = 88
          Width = 120
          Height = 21
          ReadOnly = True
          TabOrder = 7
        end
        object edtLinkUrlOut: TEdit
          Left = 16
          Top = 136
          Width = 840
          Height = 21
          ReadOnly = True
          TabOrder = 8
        end
        object btnOpenLink: TButton
          Left = 870
          Top = 134
          Width = 120
          Height = 25
          Caption = 'Abrir Link'
          TabOrder = 9
          OnClick = btnOpenLinkClick
        end
        object btnConsult: TButton
          Left = 560
          Top = 38
          Width = 120
          Height = 25
          Caption = 'Consultar'
          TabOrder = 10
          OnClick = btnConsultClick
        end
        object memoConsultResponse: TMemo
          Left = 16
          Top = 168
          Width = 1088
          Height = 40
          ScrollBars = ssVertical
          TabOrder = 11
        end
      end
    end
    object TabLogs: TTabSheet
      Caption = 'Logs'
      object memoLogs: TMemo
        Left = 16
        Top = 16
        Width = 1120
        Height = 640
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object btnOpenLog: TButton
        Left = 16
        Top = 672
        Width = 120
        Height = 25
        Caption = 'Abrir arquivo'
        TabOrder = 1
        OnClick = btnOpenLogClick
      end
    end
  end
end
