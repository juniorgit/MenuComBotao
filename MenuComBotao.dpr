program MenuComBotao;

uses
  Vcl.Forms,
  MenuBotaoMainUnit in 'MenuBotaoMainUnit.pas' {FormPrincipal},
  mMenuBotao in 'Lib\Funcoes\mMenuBotao.pas',
  MenuHelpUnit in 'MenuHelpUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.Run;
end.
