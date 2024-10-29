@isTest
public with sharing class VidaOnServiceTest {

    @isTest
    public static void testGetToken() {

        VidaOnService vidaOnService = VidaOnService.getInstance();
        
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"access_token":"00000000-0000-0000-0000-000000000000","expires_in":3600,"token_type":"Basic"}'); 

        vidaOnService.gerarTokenSensedia = new Servico__mdt(
            DeveloperName = 'Gerar_Token_Sensedia_AWS',
            NomeCredencial__c = 'Credencial',
            NomeToken__c = 'Token',
            Endpoint__c = 'https://example.com'
        );
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        HttpResponse actualResponse = vidaOnService.getToken('Gerar_Token_Sensedia_AWS', new CredencialOAuth2__mdt());
        Test.stopTest();
        
        System.assert(mockResponse.getStatusCode() == actualResponse.getStatusCode(), 'Status code diferente.');
        System.assert(mockResponse.getBody() == actualResponse.getBody(), 'Corpo da resposta diferente.');
    }


    @IsTest
    public static void testGerarTokenSensediaOAuth2() {
        VidaOnService vidaOnService = VidaOnService.getInstance();

        String nomeCredencial = 'Sensedia';
        String endpointToken = 'Gerar_Token_Sensedia_AWS';

        vidaOnService.gerarTokenSensedia = new Servico__mdt(
            DeveloperName = 'Gerar_Token_Sensedia_AWS',
            NomeCredencial__c = 'Credencial',
            NomeToken__c = 'Token',
            Endpoint__c = 'https://example.com'
        );

        vidaOnService.sensedia = new CredencialOAuth2__mdt(
            DeveloperName = 'Sensedia',
            ClientId__c = '12345',
            ClientSecret__c = '54321',
            GrantType__c = 'client_credentials',
            Status__c = true
        );

        Test.startTest();
        String accessToken = vidaOnService.gerarTokenSensediaOAuth2(nomeCredencial, endpointToken);
        Test.stopTest();

        System.assertNotEquals(null, accessToken, 'Token não foi gerado corretamente.');
    }

    @IsTest
    public static void testGetRendas() {

        VidaOnService vidaOnService = VidaOnService.getInstance();

        String nomeEndpoint = 'Consulta_Renda_Vida_ON';
        String tokenSensedia = 'dummyToken';

        vidaOnService.consultaRendaVidaOn = new Servico__mdt(
            DeveloperName = 'Consulta_Renda_Vida_ON',
            NomeCredencial__c = 'Credencial',
            NomeToken__c = 'Token',
            Endpoint__c = 'https://example.com'
        );

        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('[{"codigo": "8000", "descricao": "R$ 4.000,01 a R$ 8.000,00"}, '
            + '{"codigo": "4000", "descricao": "Até R$ 4.000,00"}, '
            + '{"codigo": "12000", "descricao": "R$ 8.000,01 a R$ 12.000,00"}, '
            + '{"codigo": "16000", "descricao": "R$ 12.000,01 a R$ 16.000,00"}, '
            + '{"codigo": "20000", "descricao": "R$ 16.000,01 a R$ 20.000,00"}, '
            + '{"codigo": "39000", "descricao": "Acima de R$ 20.000,00"}]');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        HttpResponse actualResponse = vidaOnService.getRendas(nomeEndpoint, tokenSensedia);
        Test.stopTest();

        // Verifique se a resposta é a esperada
        System.assert(mockResponse.getStatusCode() == actualResponse.getStatusCode(), 'Status code diferente.');
        System.assert(mockResponse.getBody() == actualResponse.getBody(), 'Corpo da resposta diferente.');
    }

    @IsTest
    public static void testBuscaRendaVidaON() {

        VidaOnService vidaOnService = VidaOnService.getInstance();

        String nomeEndPoint = 'Consulta_Renda_Vida_ON';
        String endpointToken = 'Gerar_Token_Sensedia_AWS';
        String tokenSensedia = 'Basic 00000000-0000-0000-0000-000000000000';

        vidaOnService.consultaRendaVidaOn = new Servico__mdt(
            DeveloperName = 'Consulta_Renda_Vida_ON',
            NomeCredencial__c = 'Credencial',
            NomeToken__c = 'Token',
            Endpoint__c = 'https://example.com'
        );

        vidaOnService.gerarTokenSensedia = new Servico__mdt(
            DeveloperName = 'Gerar_Token_Sensedia_AWS',
            NomeCredencial__c = 'Credencial',
            NomeToken__c = 'Token',
            Endpoint__c = 'https://example.com'
        );

        vidaOnService.sensedia = new CredencialOAuth2__mdt(
            DeveloperName = 'Sensedia',
            ClientId__c = '12345',
            ClientSecret__c = '54321',
            GrantType__c = 'client_credentials',
            Status__c = true
        );

        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('[{"codigo": "8000", "descricao": "R$ 4.000,01 a R$ 8.000,00"}, '
                            + '{"codigo": "4000", "descricao": "Até R$ 4.000,00"}, '
                            + '{"codigo": "12000", "descricao": "R$ 8.000,01 a R$ 12.000,00"}, '
                            + '{"codigo": "16000", "descricao": "R$ 12.000,01 a R$ 16.000,00"}, '
                            + '{"codigo": "20000", "descricao": "R$ 16.000,01 a R$ 20.000,00"}, '
                            + '{"codigo": "39000", "descricao": "Acima de R$ 20.000,00"}]');

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
            String resposta = vidaOnService.buscaRendaVidaON();
        Test.stopTest();

        System.assertEquals(JSON.serialize(new List<VidaOnService.RendaTO>{
            new VidaOnService.RendaTO('8000', 'R$ 4.000,01 a R$ 8.000,00'),
            new VidaOnService.RendaTO('4000', 'Até R$ 4.000,00'),
            new VidaOnService.RendaTO('12000', 'R$ 8.000,01 a R$ 12.000,00'),
            new VidaOnService.RendaTO('16000', 'R$ 12.000,01 a R$ 16.000,00'),
            new VidaOnService.RendaTO('20000', 'R$ 16.000,01 a R$ 20.000,00'),
            new VidaOnService.RendaTO('39000', 'Acima de R$ 20.000,00')
        }), resposta, 'Resposta incorreta.');

        System.assertEquals(tokenSensedia, vidaOnService.gerarTokenSensediaOAuth2('Sensedia', endpointToken), 'Token Sensedia incorreto.');
    }



    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }
}