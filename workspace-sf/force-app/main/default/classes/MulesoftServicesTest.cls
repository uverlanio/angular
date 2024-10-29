//ANNVI-208 - INICIO
@isTest
private class MulesoftServicesTest {

    private class MockAccessTokenGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"testAccessToken","token_type":"Bearer","expires_in":3600}');
            return res;
        }
    }

    @isTest
    public static void mulesoftToken(){
        HttpResponse token = MulesoftServices.getInstance().getTokenMulesoft(MulesoftServices.DOMAIN.AWS_EXTERNO.toString(), MulesoftServices.MULESOFT_TOKEN.toString());
        System.debug('Token validado? ' + token);
    }
    
    @isTest
    public static void mulesoftTokenValidate(){
        String token = MulesoftServices.getInstance().getAccessToken(MulesoftServices.DOMAIN.AWS_EXTERNO.toString(), MulesoftServices.MULESOFT_TOKEN.toString());
        System.debug('Access Token validado? ' + token);
    }

    @isTest
    public static void testConsultarDadosBCP(){        
              
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"status: success"}', 200, 'OK'));

        Test.startTest();        

        String retorno = MulesoftServices.getInstance().consultarDadosBCP('13214654654');

        Test.stopTest();

        System.assertEquals('{"status: success"}', retorno);
    }

    @isTest
    public static void testarChamarServico(){

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('teste', 200, 'OK'));
 
        String retorno = MulesoftServices.getInstance().chamarServico(MulesoftServices.VERB.POST, MulesoftServices.DOMAIN.AWS_EXTERNO, 'servico', 'body');        
   
        Test.stopTest();

        System.assertEquals('teste', retorno);
    }
}

//ANNVI-208 - FIM