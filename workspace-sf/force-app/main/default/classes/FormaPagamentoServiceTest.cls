@isTest
private class FormaPagamentoServiceTest {
	
	@isTest 
	static void testeSincronizacaoFormasPagamento() {
		String responseJsonString = '[{"codigoEmpresa": "1","codigoRamo": "531","codigoModalidade": "0","codigoCategoriaContaContrato": "05","codigoCategoriaObjetoSeguro": "31","codigoOperacaoPrincipal": "0531","codigoSubOperacao": "0120","codigoPlanoParcelamento": "11","descricaoPlanoParcelamento": "A VISTA NA CIA","numeroParcela": "1","codigoMeioRecebimento": "*","percentualAdicionalFracionamento": "1","taxaJuros": "0","quantidadeLimiteDiasAnteriorVencimento": "1","quantidadeLimiteDiaVigencia": "10","dataInicialVigencia": "2016-06-01","dataFinalVigencia": "2099-12-31"}]';

		//Gera resposta do serviço
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 200, 'OK'));

		//Verifca se existe algum municipio
		List<FormaPagamento__c> formasPgto = [Select Id From FormaPagamento__c];
		System.assert(formasPgto.isEmpty());

		//Insere Ramo
		RamoSeguro__c ramo = new RamoSeguro__c(
			Name = 'Ramo teste',
			Codigo__c = '531',
			CodigoEmpresa__c = '1',
			IdExterno__c = '1531'
		);

		insert ramo;

		Test.startTest();

		FormaPagametoBO.getInstance().sincronizarFormasPagamento();

		Test.stopTest();

		//Verifica se algum municipio foi criado
		formasPgto = [Select Id, Name From FormaPagamento__c];
		System.assert(!formasPgto.isEmpty());
		System.assertEquals(formasPgto[0].Name, 'A VISTA NA CIA');
	}

	@isTest
	static void testarErroSincronizacao() {
		String responseJsonString = '[{"codigoEmpresa": "1","codigoRamo": "531","codigoModalidade": "0","codigoCategoriaContaContrato": "05","codigoCategoriaObjetoSeguro": "31","codigoOperacaoPrincipal": "0531","codigoSubOperacao": "0120","codigoPlanoParcelamento": "11","descricaoPlanoParcelamento": "A VISTA NA CIA","numeroParcela": "1","codigoMeioRecebimento": "*","percentualAdicionalFracionamento": "1","taxaJuros": "0","quantidadeLimiteDiasAnteriorVencimento": "1","quantidadeLimiteDiaVigencia": "10","dataInicialVigencia": "2016-06-01","dataFinalVigencia": "2099-12-31"}]';

		//Gera resposta do serviço
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 500, 'OK'));

		//Verifca se existe algum municipio
		List<FormaPagamento__c> formasPgto = [Select Id From FormaPagamento__c];
		System.assert(formasPgto.isEmpty());

		//Insere Ramo
		RamoSeguro__c ramo = new RamoSeguro__c(
			Name = 'Ramo teste',
			Codigo__c = '531',
			CodigoEmpresa__c = '1',
			IdExterno__c = '1531'
		);

		insert ramo;

		Test.startTest();

		try {
			FormaPagametoBO.getInstance().sincronizarFormasPagamento();
		}
		catch(Exception e) {
			System.assert(e.getMessage().contains('Erro ao buscar formas de pagamento:'));
		}

		Test.stopTest();
	}

}