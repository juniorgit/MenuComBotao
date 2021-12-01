unit MenuHelpUnit;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Graphics, ShellAPI, Vcl.Forms, Vcl.Menus, Vcl.Buttons, Generics.Collections;

type
  TMenuHelp = class
  private
    ListaWidth        : TDictionary<string, Integer>;
    ListaWidthRaiz    : TDictionary<Integer, Integer>;
    ListaHelp         : TDictionary<string, string>;
    ListaMenuInvisivel: TList<Integer>;

    function GetMousePos: TPoint;
    function GetWidth(const Menu: TMenuItem): Integer;
    function GetWindowMenuItemRaizRect(Handle: THandle; Index: Integer): TRect;

    procedure AssociarEventoDrawItem(Menu: TMenuItem);
    procedure Inicializar(Form: TForm);
    procedure EventoDesenhaItemMenu(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
  public
    procedure AddHelp(const MenuItem: TMenuItem; const UrlHelp: string);
    function IsClicouBotaoHelp(const MenuItem: TMenuItem): Boolean;

    constructor Create(Form: TForm);
    destructor Destroy; override;
  end;

var
  MenuBotao: TMenuHelp;

implementation

const
  LARGURA_BOTAO       = 18;
  PIXELS_ANTES_TEXTO  = 22;
  MARGEM_INTERROGACAO = 3;
  MARGEM_BOTAO        = 3;

constructor TMenuHelp.Create(Form: TForm);
begin
  ListaWidth         := TDictionary<string, Integer>.Create;
  ListaWidthRaiz     := TDictionary<Integer, Integer>.Create;
  ListaHelp          := TDictionary<string, string>.Create;
  ListaMenuInvisivel := TList<Integer>.Create;
  Inicializar(Form);
end;

destructor TMenuHelp.Destroy;
begin
  ListaWidth.Free;
  ListaWidthRaiz.Free;
  ListaHelp.Free;
  ListaMenuInvisivel.Free;
  inherited;
end;

{$WARNINGS OFF}


function TMenuHelp.GetWindowMenuItemRaizRect(Handle: THandle; Index: Integer): TRect;
var
  Info: TMenuBarInfo;
begin
  FillChar(Info, SizeOf(Info), 0);
  Info.cbSize := SizeOf(Info);
  try
    GetMenuBarInfo(Handle, $FFFFFFFD, Index, Info);
  except
    // em alguns Windows tava dando erro "System error. Code 87". (algo haver com os registradores 32/64.)
  end;
  Result := Info.rcBar;
end;
{$WARNINGS ON}


procedure TMenuHelp.Inicializar(Form: TForm);
var
  I   : Integer;
  Rect: TRect;
begin
  Form.Menu.OwnerDraw := True;

  // percorre todos os itens de menu
  for I := 0 to Pred(Form.Menu.Items.Count) do
  begin
    // pega o tamanho na horizontal em pixel do menus principais (ficam na barra superior)
    Rect := GetWindowMenuItemRaizRect(Form.Handle, I + 1);
    ListaWidthRaiz.Add(Form.Menu.Items[I].MenuIndex, Rect.Right - Rect.Left);

    // e chama o método que vai percorrer os sub-menus recursivamente
    AssociarEventoDrawItem(Form.Menu.Items[I]);
  end;
end;

procedure TMenuHelp.AssociarEventoDrawItem(Menu: TMenuItem);
var
  I: Integer;
begin
  // percorre os itens
  for I := 0 to Pred(Menu.Count) do
  begin
    // divisão pula
    if (Menu.Items[I].Caption = '-') then
    begin
      Continue;
    end;

    // associa o evento
    Menu.Items[I].OnDrawItem := EventoDesenhaItemMenu;

    // se ESTE item tem sub-menus chama novamente a funcao passando ele (recursividade)
    if Menu.Items[I].Count > 0 then
    begin
      AssociarEventoDrawItem(Menu.Items[I]);
    end;
  end;
end;

function TMenuHelp.GetMousePos: TPoint;
begin
  // pega posição do mouse no form ativo (onde vai estar o menu)
  if Assigned(Screen.ActiveForm) then
  begin
    GetCursorPos(Result);
    ScreenToClient(Screen.ActiveForm.Handle, Result);
  end;
end;

function TMenuHelp.GetWidth(const Menu: TMenuItem): Integer;
var
  I  : Integer;
  liW: Integer;
begin
  Result := 0;

  // é o raiz?
  if Menu.Parent.Name = '' then
  begin
    // soma o width todos antes dele para acrescentar no result
    for I := Menu.MenuIndex - 1 downto 0 do
    begin
      if ListaWidthRaiz.ContainsKey(I) then
      begin
        liW    := ListaWidthRaiz[I];
        Result := Result + liW;
      end;
    end;
  end;

  // se esse menu não tá na lista onde tem os tamanhos, retorna zero
  if ListaWidth.ContainsKey(Menu.Name) then
  begin
    // pega o tamanho deste menu
    Result := ListaWidth[Menu.Name];

    // se tem menu pai, vamos acrescentar o menu dele através de recursividade para ir voltando até o menu raiz
    if Menu.Parent <> nil then
    begin
      Result := Result + GetWidth(Menu.Parent);
    end;
  end;
end;

procedure TMenuHelp.AddHelp(const MenuItem: TMenuItem; const UrlHelp: string);
begin
  // lista do help - se não tiver, adiciona
  if not ListaHelp.ContainsKey(MenuItem.Name) and (UrlHelp > '') then
  begin
    ListaHelp.Add(MenuItem.Name, UrlHelp);
  end;
end;

procedure TMenuHelp.EventoDesenhaItemMenu(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
var
  MenuItem             : TMenuItem;
  Text                 : string;
  X, Y                 : Integer;
  BtRect               : TRect;
  OldBkMode, ItemAltura: Integer;
begin
  MenuItem := TMenuItem(Sender);

  // no momento que desenha o menu, guardamos o tamanho da área que o Delphi
  // separou pra ele (Width) para usarmos no click para saber se clicou no botão
  if not ListaWidth.ContainsKey(MenuItem.Name) then
    ListaWidth.Add(MenuItem.Name, ARect.Right - ARect.Left);

  ItemAltura         := ARect.Bottom - ARect.Top;
  ACanvas.Font.Color := clMenuText;

  // tira do caption o "&"
  Text := StringReplace(MenuItem.Caption, '&', '', [rfReplaceAll, rfIgnoreCase]);
  X    := PIXELS_ANTES_TEXTO;
  Y    := ARect.Top + ((ItemAltura div 2) - (ACanvas.TextHeight(Text) div 2));

  // selecionado, coloca fundo azul
  if Selected then
  begin
    ACanvas.Brush.Color := clSkyBlue;
  end;

  // disabilitado é cinza
  if not MenuItem.Enabled then
  begin
    ACanvas.Font.Color := clGray;
  end;

  // desenha o texto
  ACanvas.TextRect(ARect, ARect.Left + X, Y, Text);

  // se tem help, vamos adicionar um botão no canto direito
  if (ListaHelp.ContainsKey(MenuItem.Name)) then
  begin
    // BtRect é a posição onde vai ficar o botão
    BtRect.Top    := ARect.Top + MARGEM_BOTAO;
    BtRect.Left   := ARect.Right - LARGURA_BOTAO + 1;
    BtRect.Right  := ARect.Right - MARGEM_BOTAO;
    BtRect.Bottom := ARect.Bottom - MARGEM_BOTAO;

    // se está com a seleção vamos desenhar a borda do botão
    if Selected then
    begin
      DrawButtonFace(ACanvas, BtRect, 1, bsNew, False, False, False);
    end;

    // ativa modo transparente
    OldBkMode := SetBkMode(ACanvas.Handle, TRANSPARENT);

    // desenha uma "?" dentro do botão
    ACanvas.Font.Color := clGreen;
    ACanvas.Font.Style := [fsBold];
    ACanvas.Font.Name  := 'Arial';
    ACanvas.TextOut(BtRect.Left + MARGEM_INTERROGACAO, BtRect.Top, '?');
    SetBkMode(ACanvas.Handle, OldBkMode);
  end;

  // desenha bitmap se existir
  if (MenuItem.Bitmap <> nil) and MenuItem.Enabled then
  begin
    ACanvas.Draw(ARect.Left + 2, ARect.Top + 1, MenuItem.Bitmap)
  end;

  // é item de menu com check ou radio?
  if MenuItem.Checked then
  begin
    ACanvas.Brush.Color := clMenuText;

    if MenuItem.RadioItem then
    begin
      // desenha bolinha
      ACanvas.RoundRect(ARect.Left + 8, ARect.Top + (ItemAltura div 2) - 3, ARect.Left + 14, ARect.Top + (ItemAltura div 2) + 3, 2, 2)
    end
    else
    begin
      // desenha o check
      ACanvas.Pen.Width := 1;
      ACanvas.Pen.Color := clMenuText;
      ACanvas.MoveTo(ARect.Left + 14, ARect.Top + (ItemAltura div 2) + -1);
      ACanvas.LineTo(ARect.Left + 10, ARect.Top + (ItemAltura div 2) + 3);
      ACanvas.LineTo(ARect.Left + 07, ARect.Top + (ItemAltura div 2));
      ACanvas.MoveTo(ARect.Left + 14, ARect.Top + (ItemAltura div 2) + -2);
      ACanvas.LineTo(ARect.Left + 10, ARect.Top + (ItemAltura div 2) + 2);
      ACanvas.LineTo(ARect.Left + 07, ARect.Top + (ItemAltura div 2) + -1);
      ACanvas.MoveTo(ARect.Left + 14, ARect.Top + (ItemAltura div 2));
      ACanvas.LineTo(ARect.Left + 10, ARect.Top + (ItemAltura div 2) + 4);
      ACanvas.LineTo(ARect.Left + 07, ARect.Top + (ItemAltura div 2) + 1);
    end;
  end;
end;

function TMenuHelp.IsClicouBotaoHelp(const MenuItem: TMenuItem): Boolean;
var
  P          : TPoint;
  LarguraMenu: Integer;
  Url        : string;
begin
  Result := False;

  // existe help para esse menu?
  if ListaHelp.ContainsKey(MenuItem.Name) then
  begin
    Url := ListaHelp[MenuItem.Name];

    // obter o width de todos os menus pais somados
    LarguraMenu := GetWidth(MenuItem);
    P           := GetMousePos;

    // se o mouse está numa posição específica do menu, então está sobre o botão!
    if (P.X >= LarguraMenu - LARGURA_BOTAO) and (P.X <= LarguraMenu + LARGURA_BOTAO) then
    begin
      // indica que já processamos - para não chamar a função normal do menu
      Result := True;

      // para garantir que vai abrir no navegador
      if (Pos('http://', LowerCase(Url)) = 0) or (Pos('https://', LowerCase(Url)) = 0) then
      begin
        Url := 'http://' + Url;
      end;

      // abre no navegador
      ShellExecute(Application.Handle, 'open', PChar(Url), '', '', SW_NORMAL);
    end;
  end;
end;

end.
