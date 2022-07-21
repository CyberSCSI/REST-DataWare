unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.DateUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.Edit,
  FMX.Layouts, FMX.Objects, FMX.ListBox,
  REST.Types,
  uRESTDAO, uRDWRESTDAO;

type
  TfPrincipal = class(TForm)
    FlowLayout1: TFlowLayout;
    eServidor: TEdit;
    Label1: TLabel;
    ePorta: TEdit;
    Label2: TLabel;
    eEndpoint: TEdit;
    Label3: TLabel;
    Memo1: TMemo;
    Layout1: TLayout;
    Image1: TImage;
    FlowLayout2: TFlowLayout;
    eUsuario: TEdit;
    Label4: TLabel;
    eSenha: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    ComboBox1: TComboBox;
    Layout2: TLayout;
    procedure IniciarClick(Sender: TObject);
  private
    { Private declarations }
    REST: TRESTDAO;
    RDWREST: TRDWRESTDAO;
    inicio, fim: Double;
    procedure TesteAB(aMemo: TMemo);
    procedure TesteRESTRequest(aMemo: TMemo);
    procedure TesteRDWRequest(aMemo: TMemo);
    procedure LogMessage(aMemo: TMemo; aMessage: string);
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

{$R *.fmx}

procedure TfPrincipal.IniciarClick(Sender: TObject);
begin
  inicio := now;
  Memo1.Lines.Clear;
  LogMessage(Memo1, 'Testes iniciados �s ' + TimeToStr(inicio));
  REST := TRESTDAO.Create(eServidor.Text, ePorta.Text);
  RDWREST := TRDWRESTDAO.Create(eServidor.Text, ePorta.Text);
  if (ComboBox1.ItemIndex = 1) and
    ((eUsuario.Text <> EmptyStr) and (eSenha.Text <> EmptyStr)) then
  begin
    REST.SetBasicAuth(eUsuario.Text, eSenha.Text);
    RDWREST.SetBasicAuth(eUsuario.Text, eSenha.Text);
  end;
  TThread.CreateAnonymousThread(
    procedure
    begin
      // TesteAB(Memo1);
      TesteRESTRequest(Memo1);
      TesteRDWRequest(Memo1);

      fim := now;
      LogMessage(Memo1, '=======================================');
      LogMessage(Memo1, 'Testes finalizados ap�s ' + FormatDateTime('nn:ss:zzz',
        (fim - inicio)) + ' (min:seg:mil)');
    end).Start;
end;

procedure TfPrincipal.LogMessage(aMemo: TMemo; aMessage: string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      aMemo.Lines.Add(aMessage);
      aMemo.GoToTextEnd;
    end);
end;

procedure TfPrincipal.TesteAB(aMemo: TMemo);
begin
  LogMessage(aMemo, 'Realizando testes A/B...');
end;

procedure TfPrincipal.TesteRDWRequest(aMemo: TMemo);
var
  I: integer;
  thread: TThread;
  pass, fail: integer;

  procedure TesteEndpoint(metodo: string; count: integer);
  var
    I: integer;
    ini, fim: Double;
  begin
    ini := now;
    if pos('GET', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisi��es...');
      for I := 0 to count do
        if not REST.TesteEndpointGET(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'M�todo GET falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
      fim := now;
      inc(pass);
      LogMessage(aMemo, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
        (fim - ini)) + ' (min:seg:mil)');
    end;

    ini := now;
    if pos('POST', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisi��es...');
      for I := 0 to count do
        if not REST.TesteEndpointPOST(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'M�todo POST falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
      fim := now;
      inc(pass);
      LogMessage(aMemo, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
        (fim - ini)) + ' (min:seg:mil)');
    end;

    ini := now;
    if pos('PUT', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisi��es...');
      for I := 0 to count do
        if not REST.TesteEndpointPUT(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'M�todo PUT falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
      fim := now;
      inc(pass);
      LogMessage(aMemo, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
        (fim - ini)) + ' (min:seg:mil)');
    end;

    ini := now;
    if pos('PATCH', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisi��es...');
      for I := 0 to count do
        if not REST.TesteEndpointPATCH(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'M�todo PATCH falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
      fim := now;
      inc(pass);
      LogMessage(aMemo, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
        (fim - ini)) + ' (min:seg:mil)');
    end;

    ini := now;
    if pos('DELETE', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisi��es...');
      for I := 0 to count do
        if not REST.TesteEndpointDELETE(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'M�todo DELETE falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
      fim := now;
      inc(pass);
      LogMessage(aMemo, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
        (fim - ini)) + ' (min:seg:mil)');
    end;
  end;

begin
  pass := 0;
  fail := 0;
  LogMessage(aMemo, 'Realizando testes de Requisi��o com RDW RESTClient...');
  if (eServidor.Text = EmptyStr) or (ePorta.Text = EmptyStr) then
  begin
    LogMessage(aMemo, 'Erro: Configura��es de servidor ou porta inv�lidas');
    exit;
  end
  else
  begin
    if not RDWREST.TesteEndpointGET(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo GET falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo GET dispon�vel');
      TesteEndpoint('GET', 100);
      TesteEndpoint('GET', 1000);
      TesteEndpoint('GET', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es GET concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo GET falhou!');

      LogMessage(aMemo, 'Teste GET conclu�do');
    end;

    if not RDWREST.TesteEndpointPOST(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo POST falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo POST dispon�vel');
      TesteEndpoint('POST', 100);
      TesteEndpoint('POST', 1000);
      TesteEndpoint('POST', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es POST concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo POST falhou!');

      LogMessage(aMemo, 'Teste POST conclu�do');
    end;

    if not RDWREST.TesteEndpointPUT(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo PUT falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo PUT dispon�vel');
      TesteEndpoint('PUT', 100);
      TesteEndpoint('PUT', 1000);
      TesteEndpoint('PUT', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es PUT concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo PUT falhou!');

      LogMessage(aMemo, 'Teste PUT conclu�do');
    end;

    if not RDWREST.TesteEndpointPATCH(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo PATCH falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo PATCH dispon�vel');
      TesteEndpoint('PATCH', 100);
      TesteEndpoint('PATCH', 1000);
      TesteEndpoint('PATCH', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es PATCH concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo PATCH falhou!');

      LogMessage(aMemo, 'Teste PATCH conclu�do');
    end;

    if not RDWREST.TesteEndpointDELETE(eEndpoint.Text) then
    begin
      aMemo.Lines.Add('Teste m�todo DELETE falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo DELETE dispon�vel');
      TesteEndpoint('DELETE', 100);
      TesteEndpoint('DELETE', 1000);
      TesteEndpoint('DELETE', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es DELETE concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 100000)
      // then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo DELETE falhou!');

      LogMessage(aMemo, 'Teste DELETE conclu�do');
    end;
  end;
  LogMessage(aMemo, 'Fim de testes de Requisi��o com RDW RESTClient...');
  LogMessage(aMemo, Format('Testes realizados: %d, Sucesso: %d, Falhas: %d',
    [pass + fail, pass, fail]));
end;

procedure TfPrincipal.TesteRESTRequest(aMemo: TMemo);
var
  I: integer;
  thread: TThread;
  pass, fail: integer;

  procedure TesteEndpoint(metodo: string; count: integer);
  var
    I: integer;
    ini, fim: Double;
  begin
    ini := now;
    if pos('GET', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisi��es...');
      for I := 0 to count do
        if not REST.TesteEndpointGET(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'M�todo GET falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
      fim := now;
      inc(pass);
      LogMessage(aMemo, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
        (fim - ini)) + ' (min:seg:mil)');
    end;

    ini := now;
    if pos('POST', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisi��es...');
      for I := 0 to count do
        if not REST.TesteEndpointPOST(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'M�todo POST falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
      fim := now;
      inc(pass);
      LogMessage(aMemo, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
        (fim - ini)) + ' (min:seg:mil)');
    end;

    ini := now;
    if pos('PUT', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisi��es...');
      for I := 0 to count do
        if not REST.TesteEndpointPUT(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'M�todo PUT falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
      fim := now;
      inc(pass);
      LogMessage(aMemo, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
        (fim - ini)) + ' (min:seg:mil)');
    end;

    ini := now;
    if pos('PATCH', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisi��es...');
      for I := 0 to count do
        if not REST.TesteEndpointPATCH(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'M�todo PATCH falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
      fim := now;
      inc(pass);
      LogMessage(aMemo, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
        (fim - ini)) + ' (min:seg:mil)');
    end;

    ini := now;
    if pos('DELETE', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisi��es...');
      for I := 0 to count do
        if not REST.TesteEndpointDELETE(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'M�todo DELETE falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
      fim := now;
      inc(pass);
      LogMessage(aMemo, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
        (fim - ini)) + ' (min:seg:mil)');
    end;
  end;

begin
  pass := 0;
  fail := 0;
  LogMessage(aMemo, 'Realizando testes de Requisi��o com REST nativos...');
  if (eServidor.Text = EmptyStr) or (ePorta.Text = EmptyStr) then
  begin
    LogMessage(aMemo, 'Erro: Configura��es de servidor ou porta inv�lidas');
    exit;
  end
  else
  begin
    if not REST.TesteEndpointGET(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo GET falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo GET dispon�vel');
      TesteEndpoint('GET', 100);
      TesteEndpoint('GET', 1000);
      TesteEndpoint('GET', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es GET concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo GET falhou!');

      LogMessage(aMemo, 'Teste GET conclu�do');
    end;

    if not REST.TesteEndpointPOST(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo POST falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo POST dispon�vel');
      TesteEndpoint('POST', 100);
      TesteEndpoint('POST', 1000);
      TesteEndpoint('POST', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es POST concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo POST falhou!');

      LogMessage(aMemo, 'Teste POST conclu�do');
    end;

    if not REST.TesteEndpointPUT(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo PUT falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo PUT dispon�vel');
      TesteEndpoint('PUT', 100);
      TesteEndpoint('PUT', 1000);
      TesteEndpoint('PUT', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es PUT concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo PUT falhou!');

      LogMessage(aMemo, 'Teste PUT conclu�do');
    end;

    if not REST.TesteEndpointPATCH(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo PATCH falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo PATCH dispon�vel');
      TesteEndpoint('PATCH', 100);
      TesteEndpoint('PATCH', 1000);
      TesteEndpoint('PATCH', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es PATCH concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo PATCH falhou!');

      LogMessage(aMemo, 'Teste PATCH conclu�do');
    end;

    if not REST.TesteEndpointDELETE(eEndpoint.Text) then
    begin
      aMemo.Lines.Add('Teste m�todo DELETE falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo DELETE dispon�vel');
      TesteEndpoint('DELETE', 100);
      TesteEndpoint('DELETE', 1000);
      TesteEndpoint('DELETE', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es DELETE concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 100000)
      // then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo DELETE falhou!');

      LogMessage(aMemo, 'Teste DELETE conclu�do');
    end;
  end;
  LogMessage(aMemo, 'Fim de testes de Requisi��o com REST nativos...');
  LogMessage(aMemo, Format('Testes realizados: %d, Sucesso: %d, Falhas: %d',
    [pass + fail, pass, fail]));
end;

end.
