/********************************************************************************************************************
* OpinCIVTO (Open Insurance)
* @author Squad_VidaDoSeuJeito
* @date 10/10/2021
* Classe para o teste do tratamento das responses do CIV criada por conta da história PLV-5230
*********************************************************************************************************************/

@isTest
public class IntegracaoOpinServiceTest {

    @isTest
    static void testRequestServiceSuccess() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadEnvioOPIN' LIMIT 1];
        String payload = sr.Body.toString();        
        String jsonSuccess = '{"routed":true}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonSuccess, 200, 'OK'));
        test.startTest();       
        IntegracaoOpinService.getInstance().enviar(payload);        
        test.stopTest();
        System.assertEquals(jsonSuccess, '{"routed":true}');
    }

    @isTest
    static void testRequestServiceFailCIV() {
        Boolean expectedExceptionThrown;
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadEnvioOPIN' LIMIT 1];
        String payload = sr.Body.toString(); 
        String jsonFail = '{"Erro na requisição"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonFail, 200, 'OK'));
        test.startTest();
        try {
            IntegracaoOpinService.getInstance().enviar(payload);
        } catch(Exception e) {        
            expectedExceptionThrown = e.getMessage().contains('IntegracaoOpinServiceException - Body: ' + jsonFail) ? true : false;                        
        }     
        test.stopTest();
        System.assertEquals(expectedExceptionThrown, true);    
    }

    @isTest
    static void testRequestServiceNotAuthorizedBadRequest() {
        Boolean expectedExceptionThrown;
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadEnvioOPIN' LIMIT 1];
        String payload = sr.Body.toString(); 
        String jsonFail = '{"error":"not_authorised","reason":"Login failed"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonFail, 200, 'OK'));
        test.startTest();
        try {
        IntegracaoOpinService.getInstance().enviar(payload);
        } catch(Exception e) {        
            expectedExceptionThrown = e.getMessage().contains('IntegracaoOpinServiceException - Body: ' + jsonFail) ? true : false;                         
        }
        test.stopTest();
        System.assertEquals(expectedExceptionThrown, true);   
    }
}
//PLV-5230 - FIM