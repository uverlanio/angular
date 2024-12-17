//ZSVEP-37-INICIO
@isTest
public with sharing class DataExporterControllerTest {
    @TestSetup
    static void makeData(){

    }

    // private class MockAccessTokenGenerator implements HttpCalloutMock {
    //     public HTTPResponse respond(HTTPRequest req) {
    //         HttpResponse res = new HttpResponse();
    //         res.setStatusCode(200);
    //         res.setBody('{"access_token":"testAccessToken","token_type":"Bearer","expires_in":3600}');
    //         return res;
    //     }
    // }

    // @isTest
    // static void credencialOk(){
    //     DataExporterController data = new DataExporterController();
    //     data.buscaCredencial('EqualizacaoAmbienteHml');
    //     System.debug('');
    // }

    // @isTest
    // public static void getTokenTest(){
    //     String token = DataExporterController.getInstance().getToken('hml');
    //     System.debug('Token validado? ' + token);
    // }   

    @isTest
    public static void instanceClass(){
        DataExporterController.getInstance();
    }  
}
//ZSVEP-37-FIM