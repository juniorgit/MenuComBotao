object FormPrincipal: TFormPrincipal
  Left = 0
  Top = 0
  Caption = 'Principal'
  ClientHeight = 237
  ClientWidth = 453
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = Menu
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Menu: TMainMenu
    OwnerDraw = True
    Left = 195
    Top = 69
    object Arquivo1: TMenuItem
      Caption = 'Arquivo'
      object Abrir1: TMenuItem
        Caption = 'Abrir'
        OnClick = Abrir1Click
      end
      object Salvar1: TMenuItem
        Caption = 'Salvar'
        OnClick = Abrir1Click
      end
      object Salvarcomo1: TMenuItem
        Caption = 'Salvar como...'
        OnClick = Abrir1Click
      end
      object Fechar1: TMenuItem
        Caption = 'Fechar'
        OnClick = Abrir1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Sair1: TMenuItem
        Caption = 'Sair'
        OnClick = Abrir1Click
      end
    end
    object Editar1: TMenuItem
      Caption = 'Editar'
      object Recortar1: TMenuItem
        Caption = 'Recortar'
        OnClick = Abrir1Click
      end
      object Copiar1: TMenuItem
        Caption = 'Copiar'
        OnClick = Abrir1Click
      end
      object Colar1: TMenuItem
        Caption = 'Colar'
        OnClick = Abrir1Click
      end
      object Excluir1: TMenuItem
        Caption = 'Excluir'
        OnClick = Abrir1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Fonte1: TMenuItem
        Caption = 'Fonte...'
        OnClick = Abrir1Click
      end
    end
    object Ajuda2: TMenuItem
      Tag = 99
      AutoHotkeys = maAutomatic
      Caption = 'Ajuda'
      GroupIndex = 101
      object Ajuda1: TMenuItem
        Tag = 1252
        Caption = 'Ajuda'
        ImageIndex = 3
        OnClick = Abrir1Click
      end
      object Sobre1: TMenuItem
        Tag = 1265
        Caption = 'Sobre'
        OnClick = Abrir1Click
      end
    end
  end
end
