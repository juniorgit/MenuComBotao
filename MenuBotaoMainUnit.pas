unit MenuBotaoMainUnit;

interface

uses
  Vcl.Forms, Vcl.Menus, System.Classes, Dialogs;

type
  TFormPrincipal = class(TForm)
    Menu: TMainMenu;
    Ajuda2: TMenuItem;
    Ajuda1: TMenuItem;
    Sobre1: TMenuItem;
    Arquivo1: TMenuItem;
    Abrir1: TMenuItem;
    Salvar1: TMenuItem;
    Salvarcomo1: TMenuItem;
    Fechar1: TMenuItem;
    N1: TMenuItem;
    Sair1: TMenuItem;
    Editar1: TMenuItem;
    Recortar1: TMenuItem;
    Copiar1: TMenuItem;
    Colar1: TMenuItem;
    Excluir1: TMenuItem;
    N2: TMenuItem;
    Fonte1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Abrir1Click(Sender: TObject);
  private
  public
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.dfm}

uses
  MenuHelpUnit;

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  MenuBotao := TMenuHelp.Create(Self);

  // associa os menus com um url que será exibido ao clicar no botão auxiliar
  MenuBotao.AddHelp(Abrir1, 'www.google.com/search?q=abrir');
  MenuBotao.AddHelp(Salvar1, 'www.google.com/search?q=salvar');
  MenuBotao.AddHelp(Copiar1, 'www.google.com/search?q=copiar');
  MenuBotao.AddHelp(Colar1, 'www.google.com/search?q=colar');
  MenuBotao.AddHelp(Sobre1, 'www.google.com/search?q=sobre');
end;

procedure TFormPrincipal.Abrir1Click(Sender: TObject);
begin
  // esta função abre o help associado, se houver quando clica-se no botão ao lado do menu - retorna true se isso acontecer
  if MenuBotao.IsClicouBotaoHelp(TMenuItem(Sender)) then
  begin
    Exit;
  end;

  ShowMessage('Você clicou no menu ' + TMenuItem(Sender).Caption);
end;

procedure TFormPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MenuBotao.Free;
end;

end.
