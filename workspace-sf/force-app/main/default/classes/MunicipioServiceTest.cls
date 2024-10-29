@isTest
private class MunicipioServiceTest {
    
    @isTest 
    static void testeSincronizacaoMunicipios() {
        String responseJsonString = '[{"codigoCidade": "6839","cepCidade": "27670","cepComplementoCidade": "0","primeiroCodigoFoneticoCidade": "(yh)&KXc!!!!!!!","segundoCodigoFoneticoCidade": "(yh)&KXc!!!!!!!","terceiroCodigoFoneticoCidade": "(yh)&KXc!!!!!!!","unidadeFederativaCodigo": "RJ","nomeCidade": "ABARRACAMENTO"}]';

        //Gera resposta do serviço
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 200, 'OK'));
        Test.startTest();

        //Verifca se existe algum municipio
        List<Municipio__c> municipios = [Select Id From Municipio__c];
        System.assert(municipios.isEmpty());

        MunicipioBO.getInstance().sincronizarDadosMunicipio();

        Test.stopTest();

        //Verifica se algum municipio foi criado
        municipios = [Select Id, Name From Municipio__c];
        System.assert(!municipios.isEmpty());
        System.assertEquals(municipios[0].Name, 'ABARRACAMENTO');
    }

    @isTest
    static void testarErroSincronizacao() {
        String responseJsonString = '[{"codigoCidade": "6839","cepCidade": "27670","cepComplementoCidade": "0","primeiroCodigoFoneticoCidade": "(yh)&KXc!!!!!!!","segundoCodigoFoneticoCidade": "(yh)&KXc!!!!!!!","terceiroCodigoFoneticoCidade": "(yh)&KXc!!!!!!!","unidadeFederativaCodigo": "RJ","nomeCidade": "ABARRACAMENTO"}]';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 500, 'OK'));
        Test.startTest();

        try {
            MunicipioBO.getInstance().sincronizarDadosMunicipio();
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro ao buscar municipios do estado'));
        }
        
        Test.stopTest();
    }

}