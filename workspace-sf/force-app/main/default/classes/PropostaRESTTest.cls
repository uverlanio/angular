@isTest
private class PropostaRESTTest
{

  @TestSetup  
  static void setup(){
    TestDataFactory.gerarDadosSetup();
    //PLV-3744 - INICIO
    TestDataFactory.Token();
    //PLV-3744 - FIM 
    // PLV-2312-28 INICIO
    TestDataFactory.gerarContrato(true); //PLV-3367 - INICIO/FIM
    // PLV-2312-28 FIM
    
    //PLV-3460 Fix 5 - INICIO
    //Aumentando coberturas da classe de teste
    Profissao__c prof = (Profissao__c) new ProfissaoFactory().createRecord();
    //Código removido por conta da história PLV-3367
    //PLV-3460 Fix 5 - FIM
  }

  /* =========================== TESTES DE MASSIFICADOS ===========================================================
     ============================================================================================================== */

  /*@isTest //ANNVI-55 - INICIO
  private static void testEmissaoPropostaMassificados()
  {   
    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaMassificados' LIMIT 1];
    String payload = staticResource.Body.toString();

    EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload,EmissaoTO.PayloadTO.class);

    // Atualiza o vencimento da primeira parcela dos contratantes
    for(EmissaoTO.ContratanteTO contratanteTO :payloadTO.proposta.contratantes){
      if(contratanteTO.dadosPagamento != null && contratanteTO.dadosPagamento.vencimentoPrimeiraParcela != null){

        contratanteTO.dadosPagamento.vencimentoPrimeiraParcela = String.valueOf(System.today().addMonths(1));
      }
    }

    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/api/proposta/massificados/novo';
    request.httpMethod = 'POST';
    request.requestBody = Blob.valueOf(JSON.serialize(payloadTO));
    RestContext.request = request;
    RestContext.response = new RestResponse();

    Test.startTest();
    PropostaREST.processarPost();
    Test.stopTest();


    // get da resposta em um mapa
    Map<String, Object> mapReturnObjectsByParam = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
    RetornoPropostaRestTO.ValidacaopropostaTO retorno = (RetornoPropostaRestTO.ValidacaopropostaTO) JSON.deserialize(JSON.serialize(mapReturnObjectsByParam.get('data')), RetornoPropostaRestTO.ValidacaopropostaTO.class);
    RetornoRestTO.MetaTO metaTO = (RetornoRestTO.MetaTO) JSON.deserialize(JSON.serialize(mapReturnObjectsByParam.get('meta')),RetornoRestTO.MetaTO.class);

    System.debug('RETORNO ' + retorno.devolutivas[0].descricao);
   // System.assertEquals('EMISSÃO - Contratação realizada com sucesso.', retorno.devolutivas[0].descricao);
    //System.assertEquals(200,metaTO.statusHttp);
  }*/ //ANNVI-55 - FIM

  @isTest
  private static void testEmissaoPropostaMassificadosCriticaODM()
  {
    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaMassificadosCriticaODM' LIMIT 1];
    String payload = staticResource.Body.toString();

    EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload,EmissaoTO.PayloadTO.class);

    // Atualiza o vencimento da primeira parcela dos contratantes
    for(EmissaoTO.ContratanteTO contratanteTO :payloadTO.proposta.contratantes){
      if(contratanteTO.dadosPagamento != null && contratanteTO.dadosPagamento.vencimentoPrimeiraParcela != null){

        contratanteTO.dadosPagamento.vencimentoPrimeiraParcela = String.valueOf(System.today().addMonths(1));
      }
    }

    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/api/proposta/massificados/novo';
    request.httpMethod = 'POST';
    request.requestBody = Blob.valueOf(JSON.serialize(payloadTO));
    RestContext.request = request;
    RestContext.response = new RestResponse();

    Test.startTest();
    PropostaREST.processarPost();
    Test.stopTest();


    // get da resposta em um mapa
    Map<String, Object> mapReturnObjectsByParam = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
    RetornoPropostaRestTO.ValidacaopropostaTO retorno = (RetornoPropostaRestTO.ValidacaopropostaTO) JSON.deserialize(JSON.serialize(mapReturnObjectsByParam.get('data')), RetornoPropostaRestTO.ValidacaopropostaTO.class);
    RetornoRestTO.MetaTO metaTO = (RetornoRestTO.MetaTO) JSON.deserialize(JSON.serialize(mapReturnObjectsByParam.get('meta')),RetornoRestTO.MetaTO.class);

    System.debug('RETORNO ' + retorno.devolutivas[0].descricao);
    ////System.assertEquals('Erro não mapeado, Critica 1 não encontrada no cadastro do parceiro', retorno.devolutivas[0].descricao);
    //System.assertEquals(200,metaTO.statusHttp);
  }

  @isTest
  private static void testEmissaoPropostaMassificadosParcelaVencida()
  {
    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaMassificadosComCriticas' LIMIT 1];
    String payload = staticResource.Body.toString();

    EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload,EmissaoTO.PayloadTO.class);

    // Atualiza o vencimento da primeira parcela dos contratantes
    for(EmissaoTO.ContratanteTO contratanteTO :payloadTO.proposta.contratantes){
      if(contratanteTO.dadosPagamento != null && contratanteTO.dadosPagamento.vencimentoPrimeiraParcela != null){

        contratanteTO.dadosPagamento.vencimentoPrimeiraParcela = String.valueOf(System.today().addMonths(-1));
      }
    }

    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/api/proposta/massificados/novo';
    request.httpMethod = 'POST';
    request.requestBody = Blob.valueOf(JSON.serialize(payloadTO));
    RestContext.request = request;
    RestContext.response = new RestResponse();

    Test.startTest();
    PropostaREST.processarPost();
    Test.stopTest();

    // get da resposta em um mapa
    Map<String, Object> mapReturnObjectsByParam = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
    RetornoPropostaRestTO.ValidacaopropostaTO retorno = (RetornoPropostaRestTO.ValidacaopropostaTO) JSON.deserialize(JSON.serialize(mapReturnObjectsByParam.get('data')), RetornoPropostaRestTO.ValidacaopropostaTO.class);
    RetornoRestTO.MetaTO metaTO = (RetornoRestTO.MetaTO) JSON.deserialize(JSON.serialize(mapReturnObjectsByParam.get('meta')),RetornoRestTO.MetaTO.class);

    System.debug('retorno ' + retorno);
     // --> Internalização Renner (remoção da critica: 36)- INICIO
     //Data de vencimento da parcela invalida.
    //System.assertEquals('Erro não mapeado, Critica 36 não encontrada no cadastro do parceiro', retorno.devolutivas[0].descricao);
     // --> Internalização Renner (remoção da critica: 36)- FIM
     
    //System.assertEquals(200,metaTO.statusHttp);
  }

  @isTest
  private static void testEmissaoPropostaMassificadosComParceiroInvalido()
  {

    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaMassificados' LIMIT 1];
    String payload = staticResource.Body.toString();

    EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload,EmissaoTO.PayloadTO.class);

    // Atualiza o vencimento da primeira parcela dos contratantes
    for(EmissaoTO.ContratanteTO contratanteTO :payloadTO.proposta.contratantes){
      if(contratanteTO.dadosPagamento != null && contratanteTO.dadosPagamento.vencimentoPrimeiraParcela != null){

        contratanteTO.dadosPagamento.vencimentoPrimeiraParcela = String.valueOf(System.today().addMonths(1));
      }
    }

    // Altera o parceiro para gerar critica
    payloadTO.proposta.parceiro = '78756413213';

    Test.startTest();

    RetornoPropostaRestTO.ValidacaopropostaTO retorno = PropostaFacade.getInstance().gerarProposta(payloadTO);

    Test.stopTest();

    //System.assert(retorno.devolutivas[0].descricao == 'Parceiro não encontrado');
  }

  @isTest
  private static void testEmissaoPropostaMassificadosComParceiroSemRemuneracao()
  {

    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaMassificados' LIMIT 1];
    String payload = staticResource.Body.toString();

    EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload,EmissaoTO.PayloadTO.class);

    // Atualiza o vencimento da primeira parcela dos contratantes
    for(EmissaoTO.ContratanteTO contratanteTO :payloadTO.proposta.contratantes){
      if(contratanteTO.dadosPagamento != null && contratanteTO.dadosPagamento.vencimentoPrimeiraParcela != null){

        contratanteTO.dadosPagamento.vencimentoPrimeiraParcela = String.valueOf(System.today().addMonths(1));
      }
    }

    List<RemuneracaoProdutoParceiro__c> listRemuneracaoProdutoParceiro = [SELECT Id,ProdutoParceiro__c, ProdutoParceiro__r.Parceiro__c, ProdutoParceiro__r.Parceiro__r.Name, ProdutoParceiro__r.Parceiro__r.Codigo__c FROM RemuneracaoProdutoParceiro__c WHERE ProdutoParceiro__r.Parceiro__r.Codigo__c =: payloadTO.proposta.parceiro];
    delete listRemuneracaoProdutoParceiro;

    Test.startTest();

    RetornoPropostaRestTO.ValidacaopropostaTO retorno = PropostaFacade.getInstance().gerarProposta(payloadTO);

    Test.stopTest();

    //System.assert(retorno.devolutivas[0].descricao == 'Remunerações do Parceiro não encontradas.');
  }

  /* =========================== FIM TESTES DE MASSIFICADOS =======================================================
     ============================================================================================================== */


  @isTest
  private static void testarComDevolutivasServico()
  {
    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadProposta001' LIMIT 1];
    String payload = staticResource.Body.toString();

    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/api/proposta';
    request.httpMethod = 'POST';
    request.requestBody = Blob.valueOf(payload);

    RestResponse res = new RestResponse();

    RestContext.response = res;
    RestContext.request = request;


    Test.startTest();

    PropostaREST.processarPost();

    Test.stopTest();

    List<Quote> lstQuote = [SELECT Id FROM Quote ];
  }

  @isTest
  private static void testarServico()
  {
    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadProposta' LIMIT 1];
    String payload = staticResource.Body.toString();

    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/api/proposta';
    request.httpMethod = 'POST';
    request.requestBody = Blob.valueOf(payload);

    RestResponse res = new RestResponse();

    Test.startTest();
    RestContext.response = res;
    RestContext.request = request;

    PropostaREST.processarPost();

    Test.stopTest();


    List<Quote> lstQuote = [SELECT Id FROM Quote];

    //System.assert(lstQuote.size() > 0);
  }

  @isTest
  private static void testarConsultaPropostaErro()
  {

    List<Quote> lstQuote = [SELECT Id  FROM Quote];

    ServiceTO.ParametroConsultarPropostaTO parametrosTO = new ServiceTO.ParametroConsultarPropostaTO();
    // parametrosTO.empresa  = lstQuote[0].Empresa_c;
    // parametrosTO.ramo     = lstQuote[0].Ramo__c;
    // parametrosTO.origem   = lstQuote[0].Origem__c;
    parametrosTO.proposta = lstQuote[0].Id;	

    Test.startTest();
      
    PropostaRetornoTO.PayloadTO retorno = propostaFacade.getInstance().consultaPropostas(parametrosTO);
    
    Test.stopTest();

    System.assertEquals(100, retorno.proposta.Status);

  }

  @isTest
  private static void testarConsultaProposta()
  {
	//PLV-3367 - INICIO
    List<Quote> lstQuote = [SELECT Id, Status, NumeroProposta__c  FROM Quote];
      system.debug('lstQuote .. '+lstQuote);

    ServiceTO.ParametroConsultarPropostaTO parametrosTO = new ServiceTO.ParametroConsultarPropostaTO();
    // parametrosTO.empresa  = lstQuote[0].Empresa_c;
    // parametrosTO.ramo     = lstQuote[0].Ramo__c;
    // parametrosTO.origem   = lstQuote[0].Origem__c;
    parametrosTO.proposta = lstQuote[0].NumeroProposta__c;
      system.debug('parametrosTO .. '+parametrosTO.proposta);

    Test.startTest();
        List<Contract> lstContract = [SELECT Id, Status FROM Contract WHERE Proposta__c = :lstQuote[0].Id];
      system.debug('lstContract .. '+lstContract);
        lstQuote[0].Status = 'Contratada';
        update lstQuote[0];
      system.debug('lstQuote[0].Status .. '+lstQuote[0].Status);
        if(lstContract.size() > 0){
            lstContract[0].Status = 'Emitido';       
            update lstContract[0];
            system.debug('lstContract[0].Status if .. '+lstContract[0].Status);
        }
		PropostaRetornoTO.PayloadTO retorno = propostaFacade.getInstance().consultaPropostas(parametrosTO);
      system.debug('retorno .. '+retorno);
    Test.stopTest();
    //PLV-3367 - FIM

    System.assertEquals(0, retorno.proposta.Status);

  }

  @isTest
  private static void testarCriticasServico()
  {
    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PropostaCriticas' LIMIT 1];
    String payload = staticResource.Body.toString();

    //II-48 INICIO 
    List<Quote> lstQuote = [SELECT Id, CodigoMotivoDevolucao__c FROM Quote];
    lstQuote[0].CodigoMotivoDevolucao__c = '18';
    update lstQuote;
    //II-48 FIM

    EmissaoTO.PayloadTO objPayload = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
    RetornoPropostaRestTO.ValidacaopropostaTO retorno = new RetornoPropostaRestTO.ValidacaopropostaTO();


    Test.startTest();

    List<CriticaProposta__c> lstCriticasProposta = CriticasFacade.getInstance().parseCriticasRetornoAceitacaoTO(
            objPayload.retornoAceitacao, lstQuote[0].Id, 'ODM');
            //correção
            //lstCriticasProposta[0].Status = 'Não iniciada';
            //update lstCriticasProposta[0];
            system.debug('lstCriticasProposta>>>>>'+lstCriticasProposta);

    insert lstCriticasProposta;


    PropostaFacade.getInstance().processaPayload(payload+payload, retorno);
    PropostaFacade.getInstance().gerarProposta(objPayload);


    Test.stopTest();

    System.debug('testarCriticasServico >> lstQuote' +lstQuote);
    System.debug('testarCriticasServico >> objPayload.retornoAceitacao' +objPayload.retornoAceitacao);
    System.debug('testarCriticasServico >> lstCriticasProposta' + lstCriticasProposta);


    //    //System.assert(lstQuote.size() < 2);
  }

  @isTest
  private static void testarServicoComPayloadErrado()
  {
    Test.startTest(); //AV-824 - INICIO/FIM LECVPV-218
    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PropostaCriticas' LIMIT 1];
    String payload = staticResource.Body.toString();

    //II-48 INICIO 
    List<Quote> lstQuote = [SELECT Id, CodigoMotivoDevolucao__c FROM Quote];
    lstQuote[0].CodigoMotivoDevolucao__c = '18';
    update lstQuote;
    //II-48 FIM

    EmissaoTO.PayloadTO objPayload = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);


    RetornoPropostaRestTO.ValidacaopropostaTO retorno = PropostaFacade.getInstance().gerarProposta(objPayload);

    

    List<CriticaProposta__c> lstCriticasProposta = CriticasFacade.getInstance().parseCriticasRetornoAceitacaoTO(objPayload.retornoAceitacao, lstQuote[0].Id, 'ODM');

    insert lstCriticasProposta;

    Test.stopTest();

    List<CriticaProposta__c> criticas = [SELECT Id FROM CriticaProposta__c];

    // //System.assert(lstQuote.size() < 2);
  }

  //@isTest UTILIZA FLUXO DE MASSIFICADOS, POREM NAO É UMA PROPOSTA DE MASSIFICADOS
  private static void testarServicoComProdutoInvalido()
  {

    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadProposta' LIMIT 1];
    String payload = staticResource.Body.toString();

    Quote proposta = [SELECT Id FROM Quote LIMIT 1];

    EmissaoTO.PayloadTO objPayload = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);

    // Altera o codigo do produto
    objPayload.proposta.codigoProdutoVida = '150';

    Test.startTest();

    RetornoPropostaRestTO.ValidacaopropostaTO retorno = PropostaFacade.getInstance().gerarProposta(objPayload);
    Test.stopTest();

    //System.assertEquals('Produto não encontrado', retorno.devolutivas[0].descricao);
  }

  //@isTest  UTILIZA FLUXO DE MASSIFICADOS, POREM NAO É UMA PROPOSTA DE MASSIFICADOS
  private static void testarServicoOutroMeioComercializacaoComSucesso()
  {

    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadProposta' LIMIT 1];
    String payload = staticResource.Body.toString();


    EmissaoTO.PayloadTO objPayload = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
    objPayload.proposta.dataCalculo = String.valueOf(System.today());
    objPayload.proposta.dataCriacaoPortal = String.valueOf(System.today());

    Test.startTest();

    RetornoPropostaRestTO.ValidacaopropostaTO retorno = PropostaFacade.getInstance().gerarProposta(objPayload);

    Test.stopTest();

    //System.assertEquals('EMISSÃO - Contratação realizada com sucesso.', retorno.devolutivas[0].descricao);
  }

  @isTest
  private static void testarMapeamentoOrcamento()
  {

    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadProposta001' LIMIT 1];
    String payload = staticResource.Body.toString();

    EmissaoTO.PayloadTO objPayload = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);

    Map<String,EmissaoTO.CoberturaTO> mapGarantiasPorNumeroSeguradoGrupoVidaSigla = new Map<String, EmissaoTO.CoberturaTO>();
    mapGarantiasPorNumeroSeguradoGrupoVidaSigla = PropostaFacade.getInstance().MontarMapaGarantiasCalculo(objPayload, mapGarantiasPorNumeroSeguradoGrupoVidaSigla);
	
    //PLV-3884 - INICIO - Adicionando CurrencyIsoCode e ajustando indentacao
    List<Product2> l = [
        SELECT Id, Name, Status__c, VigenciaInicial__c, VigenciaFinal__c, Versao__c, 
            VersaoAnterior__c, ProdutoTecnico__c, RecordTypeId, RecordType.DeveloperName, 
            ProductCode, Description, 
            ( SELECT Id, Documento__c, Descricao__c, MeioEnvio__c, Papel__c, Tipo__c FROM DocumentosProduto__r ),
            ( SELECT Id, FormaPagamento__c, FormaPagamento__r.Codigo__c, FormaPagamento__r.RamoSeguro__r.Codigo__c, FormaPagamento__r.Name FROM CondicoesCobranca__r ),
            ( SELECT Id, Name, FormaPagamento__c, FormaPagamento__r.Name, Produto__c, OwnerId, PremioMinimoProduto__c, PremioMinimoParcela__c, TipoContratacao__c, PeriodicidadePagamento__c, RecordTypeId FROM PremiosMinimoProduto__r ),
            ( SELECT Id, CurrencyIsoCode, Garantia__c, Garantia__r.Tipo__c, Garantia__r.Sigla__c, GarantiaProduto__c, RecordTypeId, TipoCapital__c, TipoLimiteCapital__c, LimiteCapitalMinimo__c, LimiteCapitalMaximo__c, LimiteIdadeMinimo__c, LimiteIdadeMaximo__c, Obrigatoria__c FROM GarantiasProduto__r ),
            ( SELECT Id, Name, LimiteMaximo__c, LimiteMinimo__c, Obrigatoria__c, Produto__c, TipoRemuneracao__c, TipoRemuneracao__r.Name, TipoRemuneracao__r.LimiteMinimo__c, TipoRemuneracao__r.LimiteMaximo__c, TipoRemuneracao__r.Codigo__c FROM RemuneracoesProduto__r )
        FROM Product2 WHERE ProductCode = : String.valueOf(objPayload.proposta.codigoProdutoVida)
        AND Status__c = 'Ativo' AND VersaoMaxima__c = true
        AND RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];
	//PLV-3884 - FIM
    
    Product2 produto = l[0];
    Parceiro__c parceiro = ParceiroDAO.getInstance().obtemParceiro(objPayload.proposta.parceiro);
	objPayload.proposta.meioComercializacao = 'CO2'; //PLV-3367 - INICIO/FIM
      
    Test.startTest();
    Opportunity orcamento = PropostaFacade.getInstance().gerarOrcamento(objPayload,produto, parceiro, mapGarantiasPorNumeroSeguradoGrupoVidaSigla);
    Test.stopTest();

    List<Opportunity> orcs = [select Id from Opportunity limit 1];
    //System.assert(orcs[0] != null);
  }
}