@isTest
private class ContractTriggerHandlerTest {
	
	@testSetup 
	static void setup(){
        TestDataFactory.gerarDadosSetup();
        // PLV-4337 - INICIO
        // PLV-3744 - INICIO
        // TestDataFactory.Token();
        // PLV-3744 - FIM
        // PLV-4337 - FIM
        //testInsertGarantiaProposta();
	}

    @isTest
    public static void testContract(){
        //PLV-3460 - INICIO
        String payloadReturn = '{"contrato": {"codigoEmpresa": "1","codigoSucursal": "1","ramoSeguro": "1391","numeroApolice": "00000021","numeroEndosso": "0"},"integracoesObrigatorias": [],"integracoesComplementares": []}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));  
        // PLV-2312-28 INICIO
    	Map<String,List<SObject>> mapListObject = TestDataFactory.gerarContrato(true);
		// PLV-2312-28 FIM

    	Contract contrato = (Contract) TestDataFactory.pegarRegistro(mapListObject, 'Contract');
    	System.assertEquals(true, (contrato != null));
        System.debug('contrato ' + contrato);
        contrato.Status = 'Emitido';
        update contrato;
        //PLV-3460 - FIM
	}
}