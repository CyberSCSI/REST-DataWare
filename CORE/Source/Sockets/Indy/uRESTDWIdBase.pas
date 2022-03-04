unit uRESTDWIdBase;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware vers�o CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
 de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
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
 {$IFDEF FPC}
 SysUtils,      Classes, Db, Variants, {$IFDEF RESTDWWINDOWS}Windows,{$ENDIF}
 uRESTDWBasic, uRESTDWBasicDB, uRESTDWConsts, DataUtils, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
 uRESTDWParams, uRESTDWAbout
 {$ELSE}
  {$IF CompilerVersion <= 22}
   SysUtils, Classes, Db, Variants, EncdDecd, SyncObjs, DataUtils, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
   uRESTDWBasic, uRESTDWBasicDB, uRESTDWParams, uRESTDWMassiveBuffer, uRESTDWAbout
  {$ELSE}
   System.SysUtils, System.Classes, Data.Db, Variants, system.SyncObjs, DataUtils, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
   uRESTDWBasic, uRESTDWBasicDB, uRESTDWParams, uRESTDWAbout,
   {$IF Defined(RESTDWFMX)}{$IFNDEF RESTDWAndroidService}FMX.Forms,{$ENDIF}
   {$ELSE}
    {$IF CompilerVersion <= 22}Forms,
     {$ELSE}VCL.Forms,
    {$IFEND}
   {$IFEND}
   uRESTDWCharset
   {$IFDEF RESTDWWINDOWS}
    , Windows
   {$ENDIF}
   , uRESTDWConsts
  {$IFEND}
 {$ENDIF};


Type
 TRESTDWIdServicePooler = Class(TRESTServicePoolerBase)
End;

Type
 TRESTDWIdServiceCGI = Class(TRESTServiceShareBase)
End;

Type
 TRESTDWIdDatabase = Class(TRESTDWDatabasebaseBase)
End;

Type
 TRESTDWIdClientPooler = Class(TRESTClientPoolerBase)
End;

implementation

end.
