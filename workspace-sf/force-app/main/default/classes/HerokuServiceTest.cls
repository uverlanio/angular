@isTest
private class HerokuServiceTest {
	@testSetup 
	static void setup(){
		TestDataFactory.gerarDadosSetup();
	}

	@isTest
	private static void testarBuscarParcelasContratoPorApolice(){
		ConsultarDadosContratoTO.DadosParcelasTO retorno = new ConsultarDadosContratoTO.DadosParcelasTO();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 200, 'OK'));

		HerokuService.getInstance().buscarParcelasContratoPorApolice('231');

		Test.stopTest();
	}

	@isTest
	private static void testarBuscarParcelasContratoPorApolice2(){
		ConsultarDadosContratoTO.DadosParcelasTO retorno = new ConsultarDadosContratoTO.DadosParcelasTO();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 401, 'NOK'));

		try {
			HerokuService.getInstance().buscarParcelasContratoPorApolice('231');
		}
		catch(Exception e) {}

		Test.stopTest();
	}

	@isTest
	private static void testarAtualizaStatusFatura(){
		RetornoRestTO retorno = new RetornoRestTO('teste');

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 200, 'OK'));

		HerokuService.getInstance().atualizaStatusFatura(new List<FaturaTO.AtualizarParcelaTO>());

		Test.stopTest();
	}

	@isTest
	private static void testarAtualizaStatusFatura2(){
		RetornoRestTO retorno = new RetornoRestTO('teste');

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 401, 'NOK'));

		try {
			HerokuService.getInstance().atualizaStatusFatura(new List<FaturaTO.AtualizarParcelaTO>());
		}

		catch(Exception e) {}

		Test.stopTest();
	}

	@isTest
	private static void testarBuscarParcelasContratoPorIdExterno(){
		ParcelamentoContratoTO retorno = new ParcelamentoContratoTO();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 200, 'OK'));

		HerokuService.getInstance().buscarParcelasContratoPorIdExterno('231');

		Test.stopTest();
	}

	@isTest
	private static void testarBuscarParcelasContratoPorIdExterno2(){
		ParcelamentoContratoTO retorno = new ParcelamentoContratoTO();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 401, 'NOK'));

		try {
			HerokuService.getInstance().buscarParcelasContratoPorIdExterno('231');
		}
		catch(Exception e) {}

		Test.stopTest();
	}

	@isTest
	private static void testarGerarParcelasContrato(){
		ServiceTO.RetornoCriarParcelaTO retorno = new ServiceTO.RetornoCriarParcelaTO();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 200, 'OK'));

		HerokuService.getInstance().gerarParcelasContrato(new List<ParcelaContratoTO>());

		Test.stopTest();
	}

	@isTest
	private static void testarGerarParcelasContrato2(){
		ServiceTO.RetornoCriarParcelaTO retorno = new ServiceTO.RetornoCriarParcelaTO();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 401, 'NOK'));

		try {
			HerokuService.getInstance().gerarParcelasContrato(new List<ParcelaContratoTO>());
		}
		catch(Exception e) {}

		Test.stopTest();
	}

    /*
	@isTest
	private static void testarAtualizarStatusSinistro(){
		ServiceTO.RetornoAtualizacaoSinistroTO retorno = new ServiceTO.RetornoAtualizacaoSinistroTO();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 200, 'OK'));

		HerokuService.getInstance().atualizarStatusSinistro('', new List<ServiceTO.ParamAtualizacaoStatusSinistroTO>());

		Test.stopTest();
	}

    
	@isTest
	private static void testarAtualizarStatusSinistro2(){
		ServiceTO.RetornoAtualizacaoSinistroTO retorno = new ServiceTO.RetornoAtualizacaoSinistroTO();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 401, 'NOK'));

		try {
			HerokuService.getInstance().atualizarStatusSinistro('', new List<ServiceTO.ParamAtualizacaoStatusSinistroTO>());
		}
		catch(Exception e) {}

		Test.stopTest();
	}
*/
	@isTest
	private static void testarGerarNumeroApolice(){
		List<String> retorno = new List<String>();
		ConsultarDadosContratoTO.NumeroPropostaTO payload = new ConsultarDadosContratoTO.NumeroPropostaTO();
		//payload.empresa = 2; //RVI-298 Comentar
		payload.sucursal = 123;
		payload.ramo = 555;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 200, 'OK'));

		HerokuService.getInstance().gerarNumeroApolice(payload, 1);

		Test.stopTest();
	}

	@isTest
	private static void testarGerarNumeroApolice2(){
		List<String> retorno = new List<String>();
		ConsultarDadosContratoTO.NumeroPropostaTO payload = new ConsultarDadosContratoTO.NumeroPropostaTO();
		//payload.empresa = 2; //RVI-298 Comentar
		payload.sucursal = 123;
		payload.ramo = 555;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 401, 'NOK'));

		try {
			HerokuService.getInstance().gerarNumeroApolice(payload, 1);
		}
		catch(Exception e) {}

		Test.stopTest();
	}

	@isTest
	private static void testarGerarLogErro(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{}', 200, 'OK'));

		HerokuService.getInstance().gerarLogErro(new ServiceTO.ParamGerarErroHerokuTO());

		Test.stopTest();
	}

	@isTest
	private static void testarGerarLogErro2(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{}', 401, 'NOK'));

		try {
			HerokuService.getInstance().gerarLogErro(new ServiceTO.ParamGerarErroHerokuTO());
		}
		catch(Exception e) {}

		Test.stopTest();
	}

	@isTest
	private static void testarGerarToken(){
		String retorno = '{"token_type" : "123", "access_token" : "424sdfsd4234", "expires_in" : 12 }';

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		HerokuService.getInstance().gerarTokenOAuth2('TestToken');

		Test.stopTest();
	}
	
	//AVX SP24 PLV 1837 - M�todo de Test (Sucesso) para o m�todo gerarArquivoLoteSinistro na classe HerokuService
	@isTest
	private static void testarGerarArquivoLoteSinistro(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('2', 200, 'OK'));

		try{
			HerokuService.getInstance().gerarArquivoLoteSinistro('1', new CriarArquivoLoteSinistroTO());
		}catch(Exception e) {}

		Test.stopTest();
	}

	//AVX SP24 PLV 1837 - M�todo de Test (Fracasso) para o m�todo gerarArquivoLoteSinistro na classe HerokuService
	@isTest
	private static void testarGerarArquivoLoteSinistro2(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('2', 500, 'ERRO'));

		try{
			HerokuService.getInstance().gerarArquivoLoteSinistro('1', new CriarArquivoLoteSinistroTO());
		}catch(Exception e) {}

		Test.stopTest();
	}
    //PLV-4632 - INICIO
    @isTest
	private static void testEnviaCartaRecusa(){
		String json = '{'+
		'\"body\" : {'+
		'    \"sfid\" : \"id garantia de sinistro\",'+
		'	\"events\": ['+
		'        {'+
		'            \"status\": \"lida\",'+
		'            \"type\": \"salesforce\",'+
		'            \"path\": \"/servicosalvarGarantiaSinistro\",'+
		'            \"ecm\": \"617611\",'+
		'            \"formato\": \"json\"'+
		'        }'+
		'    ],'+
		'    \"mailto\" : \"jefer.santana@gmail.com\",'+
		'    \"base64\" : \"JJJJJJJEEUYSHS\"'+
		'  }'+
		'}';

		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{}', 200, 'OK'));

		HerokuService.getInstance().enviaCartaRecusa(json);

		Test.stopTest();
	}
    //PLV-4632 - FIM

	//PLV-4905 - INICIO
    @isTest
	private static void atualizarIntegracaoAntares_Success(){
		String json = '{"dataIntegracao":[{"sucursal":"1","ramo":"1391","endosso":"1","empresa":"1","apolice":"000009695"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"servico":"/parcelascontrato/processar-integracao-antares","status":"PROCESSADO","codigoprocessamento":0,"descricao":"Atualização de parcelas para integração Antares feita com sucesso."}', 200, 'OK'));
		Test.startTest();
		ContractBO.ResponseHerokuAntares response = HerokuService.getInstance().atualizarIntegracaoAntares(json);
		Test.stopTest();
		System.assertEquals(response.codigoprocessamento, 0);
		System.assertEquals(response.status, 'PROCESSADO');
	}
    //PLV-4905 - FIM

	//PLV-4905 - INICIO
    @isTest
	private static void atualizarIntegracaoAntares_Empty(){
		String json = '{}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"servico":"/parcelascontrato/processar-integracao-antares","status":"FINALIZADO","codigoprocessamento":0,"descricao":"Dados para processamento não informados. Fim do processo de atualização"}', 200, 'OK'));
		Test.startTest();
		ContractBO.ResponseHerokuAntares response = null;
		String message = null;
		try{
			response = HerokuService.getInstance().atualizarIntegracaoAntares(json);
		}
		catch(Exception ex){
			message = ex.getMessage();
		}
		Test.stopTest();
		System.assertEquals(message.contains('Dados para processamento não informados. Fim do processo de atualização'), true);
		System.assertEquals(response, null);
	}
    //PLV-4905 - FIM

	//PLV-4905 - INICIO
    @isTest
	private static void atualizarIntegracaoAntares_Error(){
		String json = '{}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"servico":"/parcelascontrato/processar-integracao-antares","status":"ERRO","codigoprocessamento":-1,"descricao":"ERROR"}', 500, 'OK'));
		Test.startTest();
		ContractBO.ResponseHerokuAntares response = null;
		String message = null;
		try{
			response = HerokuService.getInstance().atualizarIntegracaoAntares(json);
		}
		catch(Exception ex){
			message = ex.getMessage();
		}
		Test.stopTest();
		System.assertEquals(message.contains('Erro ao Processar Integração Antares'), true);
		System.assertEquals(response, null);
	}
    //PLV-4905 - FIM

	//AV-85 INICIO
	@isTest
	private static void testGravarVoucherVidaOnSucesso(){
		String payloadReturn = '{"servico":"/voucher/gravar-voucher","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2021-09-21T20:39:01.842Z","descricao":"Inclusão realizada com sucesso.","dados":[{"cpf":"023.456.789-29","voucher":"KFN0975-ZZ","produto":"Viagem VidaOn","datainsercao":"2021-09-21"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
		Test.startTest();
		String dadosVoucher = '{"cpf" : "180.917.248-96", "voucher" : "17961495", "produto" : "VIAGEM_VIDA_ON"}';
		ContractBO.ResponseHerokuGravarVoucher responseGravarVoucherVidaOn = HerokuService.getInstance().gravarVoucherVidaOn(dadosVoucher);
		Test.stopTest();
		System.assertEquals(responseGravarVoucherVidaOn.codigoprocessamento, 0);
		System.assertEquals(responseGravarVoucherVidaOn.status, 'PROCESSADO');
	}

	@isTest
	private static void testGravarVoucherVidaOnFail(){
		String json = '{}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"servico":"/voucher/gravar-voucher","status":"ERRO","codigoprocessamento":-1,"descricao":"ERROR"}', 500, 'OK'));
		Test.startTest();
		ContractBO.ResponseHerokuGravarVoucher response = null;
		String message = null;
		try{
			response = HerokuService.getInstance().gravarVoucherVidaOn(json);
		}
		catch(Exception ex){
			message = ex.getMessage();
		}
		Test.stopTest();
		System.assertEquals(message.contains('Erro ao Processar a inserção de Voucher do Produto Viagem VidaOn: '), true);
		System.assertEquals(response, null);
	}
	
	@isTest
	private static void testConsultarVoucherVidaOnSucesso(){
		String payloadReturn = '{"servico":"/voucher/consultar-voucher","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2021-09-21T20:37:26.496Z","descricao":"O CPF ainda pode utilizar 2 voucher(s).","dados":[{"voucher":[{"cpf":"023.456.789-29","voucher":"KFN0975-ZZ","produto":"Viagem VidaOn","datainsercao":null}],"totalutilizacao":0,"podeutilizar":true}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
		Test.startTest();
		String dadosVoucher = '{"cpf" : "180.917.248-96", "voucher" : "17961495", "produto" : "VIAGEM_VIDA_ON"}';
		ContractBO.ResponseHerokuConsultarVoucher responseConsultarVoucherVidaOn = HerokuService.getInstance().consultarVoucherVidaOn(dadosVoucher);
		Test.stopTest();
		System.assertEquals(responseConsultarVoucherVidaOn.codigoprocessamento, 0);
		System.assertEquals(responseConsultarVoucherVidaOn.status, 'PROCESSADO');
	}

	@isTest
	private static void testConsultarVoucherVidaOnFail(){
		String json = '{}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"servico":"/voucher/consultar-voucher","status":"ERRO","codigoprocessamento":-1,"descricao":"ERROR"}', 500, 'OK'));
		Test.startTest();
		ContractBO.ResponseHerokuConsultarVoucher response = null;
		String message = null;
		try{
			response = HerokuService.getInstance().consultarVoucherVidaOn(json);
		}
		catch(Exception ex){
			message = ex.getMessage();
		}
		Test.stopTest();
		System.assertEquals(message.contains('Erro ao Processar a consulta de Voucher do Produto Viagem VidaOn: '), true);
		System.assertEquals(response, null);
	}
	//AV-85 FIM

	//VE-45 INICIO 
	@isTest
	private static void testConsultarBCPSucesso(){
		String payloadReturn = '{"servico":"/reprocessamentobcp/consultar-bcp","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2021-12-08T17:27:06.993Z","descricao":"A consulta localizou 10 registro(s).","dados":[{"registros":[{"origemProposta":"18","numeroProposta":"00001910"},{"origemProposta":"18","numeroProposta":"00001910"},{"origemProposta":"18","numeroProposta":"00001916"},{"origemProposta":"18","numeroProposta":"00001916"},{"origemProposta":"18","numeroProposta":"00001916"},{"origemProposta":"18","numeroProposta":"00001916"},{"origemProposta":"18","numeroProposta":"00001918"},{"origemProposta":"18","numeroProposta":"00001919"},{"origemProposta":"18","numeroProposta":"00001920"},{"origemProposta":"18","numeroProposta":"00001920"}],"totalRegistros":10}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
		Test.startTest();
		BatchExecucaoBCPTO.consultarBCPRetorno responseHerokuTratado =  HerokuService.getInstance().consultarBCP();
		Test.stopTest();
		System.assertEquals(responseHerokuTratado.codigoprocessamento, 0);
		System.assertEquals(responseHerokuTratado.status, 'PROCESSADO');
	}

	@isTest
	private static void testConsultarBCPFracasso(){
		String payloadReturn = '{"servico":"/reprocessamentobcp/consultar-bcp","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2021-12-08T16:57:46.272Z","descricao":"A consulta não retornou registros","dados":[{"registros":[{"origemProposta":null,"numeroProposta":null}],"totalRegistros":0}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
		Test.startTest();
		BatchExecucaoBCPTO.consultarBCPRetorno responseHerokuTratado =  HerokuService.getInstance().consultarBCP();
		Test.stopTest();
		System.assertEquals(responseHerokuTratado.codigoprocessamento, 0);
		System.assertEquals(responseHerokuTratado.status, 'PROCESSADO');
		System.assertEquals(responseHerokuTratado.descricao, 'A consulta não retornou registros');
	}
	//VE-45 FIM 

	//PLV-5266 INICIO
	@isTest
	private static void testConsultRestimuloContratoSucesso(){
		String request = '{"propostas":[{"proposta":"18-00039643"}]}';
		String payloadReturn = '{"servico":"/reestimuloapolice/reestimular-status-apolice","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2022-10-21T17:48:15.518Z","descricao":"Consulta realizada com sucesso.","encontrouregistro":true,"dados":[{"idproposta":"18-00039643","empresa":"1","sucursal":"1","ramo":"1391","apolice":"000022748","endosso":"0"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
		Test.startTest();
		RestimuloContratoHeroku.responseHeroku responseHerokuTratado =  HerokuService.getInstance().consultaRestimuloContrato(request);
		Test.stopTest();
		System.assertEquals(responseHerokuTratado.codigoprocessamento, 0);
		System.assertEquals(responseHerokuTratado.status, 'PROCESSADO');
	}
	@isTest
    private static void testeConsultaRestimuloContratoErro(){
        String json = '{"propostas":[{"proposta":""}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"servico":"/reestimuloapolice/reestimular-status-apolice","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2022-10-21T17:48:15.518Z","descricao":"Consulta não realizada.","encontrouregistro":false,"dados":[{"erro":"Erro ao obter os dados da consulta"}]}', 200, 'OK'));
        Test.startTest();
        RestimuloContratoHeroku.responseHeroku response = null;
        String message = null;
        String responseTratado;
        try{
            response = HerokuService.getInstance().consultaRestimuloContrato(json);
            responseTratado = System.JSON.serialize(response);
        }
        catch(Exception ex){
            message = ex.getMessage();
        }
        Test.stopTest();
        System.assertEquals(responseTratado.contains('Erro ao obter os dados da consulta'), true);
    }
	//PLV-5266 FIM

	//LECVP-72 - INICIO
	@isTest static void testarGerarResultadoIntegracao(){
		
		StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'MockResultadoIntegracao' LIMIT 1];
		String json = sr.Body.toString();
		System.debug('JSON: ' + json);
		ResultadoIntegracaoTO resultadoIntegracaoTO = (ResultadoIntegracaoTO) System.JSON.deserialize(json, ResultadoIntegracaoTO.class);

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 200, 'OK'));
		
		Test.startTest();

        Boolean isException = false;

        try{
		    HerokuService.getInstance().gerarResultadoIntegracao(resultadoIntegracaoTO);
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

		Test.stopTest();
	}

	@isTest
	private static void testarGerarResultadoIntegracaoComHerokuException(){
		
		StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'MockResultadoIntegracao' LIMIT 1];
		String json = sr.Body.toString();
		Boolean isHerokuException = false;
		ResultadoIntegracaoTO resultadoIntegracaoTO = (ResultadoIntegracaoTO) System.JSON.deserialize(json, ResultadoIntegracaoTO.class);

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 400, 'NOK'));
		
		Test.startTest();
		
		try{
			HerokuService.getInstance().gerarResultadoIntegracao(resultadoIntegracaoTO);
		}catch(Exception e){
			isHerokuException = true;
		}
		Test.stopTest();

		System.assert(isHerokuException);
	}
	//LECVP-72 - FIM

	// RVI-255-INICIO
	@isTest
	private static void testarBuscarParcelasContratoPorApoliceEndosso(){
		//ConsultarDadosContratoTO.DadosParcelasTO retorno = new ConsultarDadosContratoTO.DadosParcelasTO();
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		HerokuService.getInstance().buscarParcelasContratoPorApoliceEndosso('000028304','0');

		Test.stopTest();
	}
	// RVI-255-FIM

	//PLV-5776 - INICIO
	@isTest
	private static void testGravarContratosLivesTotalPartner(){

		String request = '{' +
			' "contratos": [ ' +
			'	{' + 
			'		"vigenciaInicial":"2023-03-14",'+
			'		"vigenciaFinal":"2024-03-13",'+ 
			'		"tipo":"Novo","status":"Emitido",'+
			'		"nomeSegurado":"UKLZK COZLNWZRF COGWE MCXMCAC",'+
			'		"name":"1-1-1391-000030090-0",'+
			'		"idConta":"a1kDP000001wfX1YAI",'+
			'		"coberturas": ['+
			'			{"sigla":"DIH"},'+
			'			{"sigla":"DG10"},'+
			'			{"sigla":"AFF"},'+
			'			{"sigla":"IFPD"},'+
			'			{"sigla":"IPA"},'+
			'			{"sigla":"BAS"},'+
			'			{"sigla":"MAP"},'+
			'			{"sigla":"TELEMED"}'+
			'		 ]'+
			'	}' +
			' ] '+
			'}';

		String payloadReturn = '{'+
			'  "service": "/livestotalpartnertable/lives-total-partner/insert",'+
			'  "status": "Finalizado",'+
			'  "executiondate": "2023-03-14T17:44:45.205Z",'+
			'  "description": "Dados inseridos com sucesso.",'+
			'  "data": ['+
			'    {'+
			'      "Qtde de Registros Adicionados": 8'+
			'    }'+
			'  ]'+
			'}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
		Test.startTest();
			HerokuService.getInstance().gravarContratosLivesTotalPartner(request);
			try {
				HerokuService.getInstance().gravarContratosLivesTotalPartner(null);
			} catch (Exception e ) {
				
			}
			
		Test.stopTest();
	}

	@isTest
	private static void cancelarContratoTest(){
		
		try
		{
			HerokuService.getInstance().cancelarContrato(null);
		}
		catch(Exception e)
		{

		}

		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));
		try
		{
			HerokuService.getInstance().cancelarContrato(null);
		}
		catch(Exception e)
		{

		}

		Test.stopTest();
	}

	
	@isTest
	private static void atualizarPayloadSeguroTest(){
		


		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));
		try
		{
			HerokuService.getInstance().atualizarPayloadSeguro(null);
		}
		catch(Exception e)
		{

		}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));
		try
		{
			HerokuService.getInstance().atualizarPayloadSeguro(null);
		}
		catch(Exception e)
		{

		}

		Test.stopTest();
	}
	

	@isTest
	private static void atualizarFluxoSeguroTest(){
		


		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().atualizarFluxoSeguro(null);
		}
		catch(Exception e)
		{

		}

		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().atualizarFluxoSeguro(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().atualizarFluxoSeguro(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}




	@isTest
	private static void GeraNumeroSinistroTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().GeraNumeroSinistro(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().GeraNumeroSinistro(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().GeraNumeroSinistro(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}
	


	
	@isTest
	private static void enviarAssinaturaDigitalTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().enviarAssinaturaDigital(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().enviarAssinaturaDigital(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().enviarAssinaturaDigital(null);
		}
		catch(Exception e){}


		try
		{
			HerokuService.getInstance().enviarAssinaturaDigital(retorno);
		}
		catch(Exception e){}


		Test.stopTest();		
	}
	


	@isTest
	private static void startHerokuExtratoRemuneracaoCancelamentoTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().startHerokuExtratoRemuneracaoCancelamento(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().startHerokuExtratoRemuneracaoCancelamento(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().startHerokuExtratoRemuneracaoCancelamento(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}


	@isTest
	private static void gerarComposicaoParcelasTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().gerarComposicaoParcelas(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().gerarComposicaoParcelas(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().gerarComposicaoParcelas(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}
	
	
	@isTest
	private static void atualizarStatusApoliceTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().atualizarStatusApolice(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().atualizarStatusApolice(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().atualizarStatusApolice(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}

	@isTest
	private static void gravarCPFVidaOnTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().gravarCPFVidaOn(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().gravarCPFVidaOn(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().gravarCPFVidaOn(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}


	

	@isTest
	private static void consultarCPFVidaOnTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().consultarCPFVidaOn(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().consultarCPFVidaOn(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().consultarCPFVidaOn(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}

	
	@isTest
	private static void consultarBCPTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().consultarBCP();
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().consultarBCP();
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().consultarBCP();
		}
		catch(Exception e){}


		Test.stopTest();		
	}
	

	
	@isTest
	private static void consultaRestimuloContratoTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().consultaRestimuloContrato(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().consultaRestimuloContrato(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().consultaRestimuloContrato(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}


	
	@isTest
	private static void gravarContratosLivesTotalPartnerTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().gravarContratosLivesTotalPartner(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().gravarContratosLivesTotalPartner(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().gravarContratosLivesTotalPartner(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}


	
	@isTest
	private static void atualizarParcelaContratoTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().atualizarParcelaContrato(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().atualizarParcelaContrato(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().atualizarParcelaContrato(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}

	
	@isTest
	private static void atualizarIdJobControleBatchTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().atualizarIdJobControleBatch(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().atualizarIdJobControleBatch(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().atualizarIdJobControleBatch(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}

	
	
	@isTest
	private static void gerarNumeroPropostaTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().gerarNumeroProposta(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().gerarNumeroProposta(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().gerarNumeroProposta(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}
	
	
	@isTest
	private static void gerarNumeroPropostaCapitalizacaoTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().gerarNumeroPropostaCapitalizacao(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().gerarNumeroPropostaCapitalizacao(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().gerarNumeroPropostaCapitalizacao(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}
	
	
	@isTest
	private static void consultarArquivoECMTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().consultarArquivoECM(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().consultarArquivoECM(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().consultarArquivoECM(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}
	
	
	@isTest
	private static void cancelarParcelasContratoTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().cancelarParcelasContrato(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().cancelarParcelasContrato(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().cancelarParcelasContrato(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}
	
	
	
	@isTest
	private static void consultarParcelasContratoTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().consultarParcelasContrato(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().consultarParcelasContrato(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().consultarParcelasContrato(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}
	
	
	@isTest
	private static void gerarDadosSeguroContratoTest(){
		
		String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000028304","endosso":"0","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
		Test.startTest();
		try
		{
			HerokuService.getInstance().gerarDadosSeguroContrato(null);
		}
		catch(Exception e){}		

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 400, 'OK'));

		try
		{
			HerokuService.getInstance().gerarDadosSeguroContrato(null);
		}
		catch(Exception e){}


		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));

		try
		{
			HerokuService.getInstance().gerarDadosSeguroContrato(null);
		}
		catch(Exception e){}


		Test.stopTest();		
	}
	

	
	@isTest
	private static void extRemuneracaoCancelaTOTest(){
		
		HerokuService.extRemuneracaoCancelaTO ext = new HerokuService.extRemuneracaoCancelaTO();
		ext.endosso = 'xxx';
		ext.datacancelamento = 'xxx';
		ext.datavencimentoparcela = 'xxx';
		ext.tiporemuneracao = 'xxx';
		ext.valorremuneracao = 'xxx';
		ext.numeroproposta = 'xxx';
		ext.status = 'xxx';
		ext.idconta = 'xxx';
		ext.cnpjcpf = 'xxx';
		ext.empresa = 'xxx';
		ext.sucursal = 'xxx';
		ext.ramo = 'xxx';
		ext.apolice = 'xxx';
		ext.origem = 'xxx';
		ext.ramogarantia = 'xxx';
		ext.tipoconta = 'xxx';
		ext.susepcorretor = 'xxx';

		ext.quantidadeparcelas = 1;
		ext.modalidade = 1;
		ext.percentualtiporemuneracao = 1;
		ext.percentualparticipacaofavorecido = 1;
		ext.premioliquido = 1;

		ext.tributacao = true;		

	}
	
	
	
}