unit uRESTDWFphttpBase;

{$I ..\..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
  de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
  Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
  de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

  Membros do Grupo :

  XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
  A. Brito                   - Admin - Administrador do desenvolvimento.
  Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
  Anderson Fiori             - Admin - Gerencia de Organiza��o dos Projetos
  Fl�vio Motta               - Member Tester and DEMO Developer.
  Mobius One                 - Devel, Tester and Admin.
  Gustavo                    - Criptografia and Devel.
  Eloy                       - Devel.
  Roniery                    - Devel.
}


interface

Uses
  SysUtils,  Classes,  DateUtils,  SyncObjs,
  {$IFDEF DELPHIXE2UP}vcl.ExtCtrls{$ELSE}ExtCtrls{$ENDIF},

  uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject, uRESTDWBasic,
  uRESTDWBasicDB, uRESTDWParams, uRESTDWBasicClass, uRESTDWAbout,
  uRESTDWConsts, uRESTDWDataUtils, uRESTDWTools, uRESTDWAuthenticators,
  fphttpserver, HTTPDefs, fpwebclient, base64;

Type

  TOnRequest = Procedure(Sender: TObject;
                          var ARequest: TFPHTTPConnectionRequest;
                          var AResponse: TFPHTTPConnectionResponse) Of Object;


  { TRESTDWFphttpServicePooler }

  TRESTDWFphttpServicePooler = Class(TRESTServicePoolerBase)
  Private
    // Events
    FOnRequest : TOnRequest;

    // HTTP Server
    HttpAppSrv: TFPHttpServer;

    // SSL Params
    vSSLRootCertFile, vSSLPrivateKeyFile, vSSLPrivateKeyPassword, vSSLCertFile: String;
    vSSLVerMethodMin, vSSLVerMethodMax: TSSLVersion;
    vSSLVerifyDepth: Integer;
    vSSLVerifyPeer: boolean;
    vSSLTimeoutSec: Cardinal;
    vSSLUse: boolean;

    // HTTP Params
    vMaxClients: Integer;
    vServiceTimeout: Integer;
    vBuffSizeBytes: Integer;
    vBandWidthLimitBytes: Cardinal;
    vBandWidthSampleSec: Cardinal;
    vListenBacklog: Integer;

    Property OnRequest : TOnRequest read FOnRequest write FOnRequest;
    Procedure ExecRequest(Sender: TObject;
                          Var ARequest: TFPHTTPConnectionRequest;
                          Var AResponse : TFPHTTPConnectionResponse);
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; override;

    Procedure SetActive(Value: boolean); Override;
    Procedure EchoPooler(ServerMethodsClass: TComponent; AContext: TComponent;
      Var Pooler, MyIP: String; AccessTag: String; Var InvalidTag: boolean); Override;

  Published
    // Events

    // SSL Params
    Property SSLRootCertFile: String Read vSSLRootCertFile Write vSSLRootCertFile;
    Property SSLPrivateKeyFile: String Read vSSLPrivateKeyFile Write vSSLPrivateKeyFile;
    Property SSLPrivateKeyPassword: String Read vSSLPrivateKeyPassword Write vSSLPrivateKeyPassword;
    Property SSLCertFile: String Read vSSLCertFile Write vSSLCertFile;
    Property SSLVerifyDepth: Integer Read vSSLVerifyDepth Write vSSLVerifyDepth default 9;
    Property SSLVerifyPeer: boolean Read vSSLVerifyPeer Write vSSLVerifyPeer default false;
    Property SSLVersionMin: TSSLVersion Read vSSLVerMethodMin Write vSSLVerMethodMin default svTLSv12;
    // SSL TimeOut in Seconds
    Property SSLUse: boolean Read vSSLUse Write vSSLUse default false;

  End;


Implementation

Uses uRESTDWJSONInterface, Dialogs;

procedure TRESTDWFphttpServicePooler.ExecRequest(Sender: TObject;
      Var ARequest: TFPHTTPConnectionRequest;
      Var AResponse : TFPHTTPConnectionResponse);
var
  vContentType,
  AuthRealm,
  sCharSet,
  ErrorMessage,
  vResponseString     : String;
  StatusCode,
  I                   : Integer;
  vResponseHeader,
  HeaderList          : TStringList;
  ResultStream,
  ContentStringStream : TStream;
  CORSCustomHeaders   : TStrings;
  Redirect            : TRedirect;

  a : String;

  aUserName,
  aPassword : String;

  procedure PassAuth;
  var
    xValue,
    LAuth: String;
    PosDelim : Integer;
  begin
    // Daria pra fazer parser do Authorization...
    LAuth := ARequest.Authorization ;
    if (Copy(LAuth,1,5) = 'Basic') then
       begin
            xValue    := DecodeStringBase64( Copy(LAuth,7,Length(LAuth) - 6) ) ;// <> 'anderson:1234'
            PosDelim  := LastDelimiter(':', xValue);
            aUserName := Copy(xValue, 1, PosDelim - 1);
            aPassword := Copy(xValue, PosDelim + 1);
    end;

  end;

  procedure ParseHeader;
  var
    I: Integer;
  begin
    HeaderList.NameValueSeparator:= ':';
    for I := 0 to Pred(ARequest.FieldCount) do
      HeaderList.AddPair(ARequest.FieldNames[I], ARequest.FieldValues[I]  );
  end;

begin
  HeaderList := nil;
  vResponseHeader     := nil;
  ResultStream        := nil;
  CORSCustomHeaders   := nil;
  ContentStringStream := nil;

  HeaderList := TStringList.Create;

  ParseHeader;
  PassAuth;

  vContentType    := ARequest.ContentType;
  AuthRealm       := '' ;
  sCharSet        := aRequest.AcceptCharset;
  ErrorMessage    := '';
  vResponseString := '';
  StatusCode      := 200;

  vResponseHeader   := TStringList.Create;
  ResultStream      := TStream.Create;
  CORSCustomHeaders := TStrings.Create;
  ContentStringStream := TStringStream.Create;

  try
    if CommandExec(TComponent(aRequest)                                           , //AContext
                   RemoveBackslashCommands(ARequest.GetHTTPVariable(hvPathInfo) ) , //Url
                   ARequest.GetHTTPVariable(hvMethod) + ' ' +
                   ARequest.GetHTTPVariable(hvURL) + ' HTTP/' +
                   ARequest.GetHTTPVariable(hvHTTPVersion)                        , //RawHTTPCommand
                   vContentType                                                   , //ContentType
                   ARequest.GetHTTPVariable(hvRemoteAddress)                      , //ClientIP
                   aRequest.GetFieldByName('User-Agent')                          , //UserAgent
                   aUserName                                                      , //AuthUsername
                   aPassword                                                      , //AuthPassword
                   ''                                                             , //Token
                   aRequest.CustomHeaders                                         , //RequestHeaders
                   StrToInt( aRequest.GetHTTPVariable(hvServerPort) )             , //ClientPort
                   HeaderList                                                     , //RawHeaders
                   aRequest.CustomHeaders                                         , //Params
                   aRequest.URI                                                   , //QueryParams
                   ContentStringStream                                            , //ContentStringStream
                   AuthRealm                                                      , //AuthRealm
                   sCharSet                                                       , //sCharSet
                   ErrorMessage                                                   , //ErrorMessage
                   StatusCode                                                     , //StatusCode
                   vResponseHeader                                                , //ResponseHeaders
                   vResponseString                                                , //ResponseString
                   ResultStream                                                   , //ResultStream
                   CORSCustomHeaders                                              , //CORSCustomHeaders
                   Redirect                                                         //Redirect
                   ) then
      begin


            //SetReplyCORS;
            //AResponseInfo.AuthRealm   := vAuthRealm;
            AResponse.ContentType := vContentType;
            If Encoding = esUtf8 Then
             AResponse.AcceptCharset := 'utf-8'
            Else
             AResponse.AcceptCharset := 'ansi';
            AResponse.Code               := StatusCode;
            If (vResponseString <> '')   Or
               (ErrorMessage    <> '')   Then
             Begin
              If Assigned(ResultStream)  Then
               FreeAndNil(ResultStream);
              If (vResponseString <> '') Then
               ResultStream  := TStringStream.Create(vResponseString)
              Else
               ResultStream  := TStringStream.Create(ErrorMessage);
             End;
            If Assigned(ResultStream)    Then
             Begin
               AResponse.ContentStream := ResultStream;
               AResponse.SendContent;  //SendContent � necess�rio para devolver o conte�do
               AResponse.ContentStream := Nil;
               AResponse.ContentLength := ResultStream.Size;
             End;

            For I := 0 To vResponseHeader.Count -1 Do
             AResponse.CustomHeaders.AddPair(vResponseHeader.Names [I],
                                             vResponseHeader.Values[vResponseHeader.Names[I]]);
            If vResponseHeader.Count > 0 Then
             AResponse.SendHeaders;
             //AResponse.WriteContent;
      end
      else
      begin
        a := 'no.';
      end;

  finally
    if assigned(vResponseHeader)then
      FreeAndNil(vResponseHeader);
    if assigned(ResultStream)then
      FreeAndNil(ResultStream);
    if assigned(CORSCustomHeaders)then
      FreeAndNil(CORSCustomHeaders);
    if assigned(ContentStringStream)then
      FreeAndNil(ContentStringStream);
    if assigned(HeaderList)then
      FreeAndNil(HeaderList);
  end;
end;

constructor TRESTDWFphttpServicePooler.Create(AOwner: TComponent);
Begin
  Inherited Create(AOwner);

  HttpAppSrv := TFPHttpServer.Create(nil);
  HttpAppSrv.Port:= ServicePort;
  HttpAppSrv.OnRequest:= @ExecRequest;
  vMaxClients := 0;
  vServiceTimeout := 60000; // TimeOut in Milliseconds
  vBuffSizeBytes := 262144; // 256kb Default
  vBandWidthLimitBytes := 0;
  vBandWidthSampleSec := 1;
  vListenBacklog := 50;
End;

destructor TRESTDWFphttpServicePooler.Destroy;
Begin
  Try
    If Active Then
    Begin
      {If HttpAppSrv.ListenAllOK Then
        HttpAppSrv.Stop;  }
      HttpAppSrv.Active:= False;
    End;
  Except
    //
  End;

  If Assigned(HttpAppSrv) Then
  begin
    {
    If Assigned(HttpAppSrv.SSLContext) Then
    begin
      HttpAppSrv.SSLContext.Free;
      HttpAppSrv.SSLContext := nil;
    end;
     }
    FreeAndNil(HttpAppSrv);
  end;
  {
  if Assigned(vBruteForceProtection) then
    FreeAndNil(vBruteForceProtection);

  if Assigned(vIcsSelfAssignedCert) then
    FreeAndNil(vIcsSelfAssignedCert);

  if Assigned(vIpBlackList) then
    FreeAndNil(vIpBlackList);
   }
  Inherited Destroy;
End;

procedure TRESTDWFphttpServicePooler.EchoPooler(ServerMethodsClass: TComponent;
  AContext: TComponent; var Pooler, MyIP: String; AccessTag: String;
  var InvalidTag: boolean);
Var
  Remote: THTTPHeader;
  i: Integer;
Begin
  InvalidTag := false;
  MyIP := '';

  If ServerMethodsClass <> Nil Then
  Begin
    For i := 0 To ServerMethodsClass.ComponentCount - 1 Do
    Begin
      If (ServerMethodsClass.Components[i].ClassType = TRESTDWPoolerDB) Or
         (ServerMethodsClass.Components[i].InheritsFrom(TRESTDWPoolerDB)) Then
      Begin
        If Pooler = Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]) Then
        Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <>
              AccessTag Then
            Begin
              InvalidTag := true;
              exit;
            End;
          End;
          If AContext <> Nil Then
          Begin
            Remote := THTTPHeader(AContext);
            MyIP := Remote.RemoteAddress;
          End;
          Break;
        End;
      End;
    End;
  End;
  If MyIP = '' Then
    Raise Exception.Create(cInvalidPoolerName);
End;

procedure TRESTDWFphttpServicePooler.SetActive(Value: boolean);
var
  x: Integer;
Begin
  If (Value) Then
  Begin
    Try
      if not(Assigned(ServerMethodClass)) and (Self.GetDataRouteCount = 0) then
        raise Exception.Create(cServerMethodClassNotAssigned);

       HttpAppSrv.Active:= True;
    Except
      On E: Exception do
      Begin
        Raise Exception.Create(E.Message);
      End;
    End;
  End
  Else
   If Not(Value) Then
   Begin
    Try
      HttpAppSrv.Active:= False;
    Except
    End;
  End;
  Inherited SetActive(Value);
End;

End.
