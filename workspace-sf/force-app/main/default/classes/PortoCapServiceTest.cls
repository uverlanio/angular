@isTest
private class PortoCapServiceTest {
	@testSetup 
	static void setup(){
        TestDataFactory.gerarDadosSetup();
	}

	@isTest
	static void testarRecompra(){
		List<ServiceTO.RetornoPortoCapTO> retorno = new List<ServiceTO.RetornoPortoCapTO>();

		Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 200, 'OK'));

        PortoCapService.getInstance().solicitarRecompraTitulos(new List<TituloCapitalizacaoTO>());
        Test.stopTest();
	}

	@isTest
	static void testarConsultaTitulos(){
		GarantiaContratoTO.RetornoConsultaTitulosTO retorno = new GarantiaContratoTO.RetornoConsultaTitulosTO();

		Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 200, 'OK'));

        PortoCapService.getInstance().recuperarTitulosSolicitados(new GarantiaContratoTO.DadosPortoCap());
        Test.stopTest();
	}
}