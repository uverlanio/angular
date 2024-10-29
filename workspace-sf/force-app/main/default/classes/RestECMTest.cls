/**
 * @author Isabela (Globant) & Jeferson (Sys4B)
 * @date 2020-03-28
 * @description RestECMTest (Test class for RestECM)
 * Classe criada por conta da história PLV-3413
 */
@isTest
global class RestECMTest{

    @isTest 
    static void buscarArquivoECMTest() {
    	Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new RestECMTestMock());
            HttpResponse res = RestECM.buscarArquivoECM('123');
            String contentType = res.getHeader('Content-Type');
            System.assert(contentType == 'application/json');
            String atualValue = res.getBody();
            String esperadotedValue = '{"ticket":"123456"}';
    	Test.stopTest();
        System.assertEquals(atualValue, esperadotedValue);
        System.assertEquals(200, res.getStatusCode());
	}
    
    @isTest
    static void buscarArquivoECMTestFileError() {
    	Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestECMTestMock.RestECMFileError());
            HttpResponse res = RestECM.buscarArquivoECM('222');
            String contentType = res.getHeader('Content-Type');
            System.assert(contentType == 'application/json');
            RestECM.retornoECMArquivo objRetorno = (RestECM.retornoECMArquivo)System.JSON.deserialize(res.getBody(),RestECM.retornoECMArquivo.class);
    	Test.stopTest();
        System.assertEquals(500, res.getStatusCode());
	}
    
    @isTest
    static void buscarArquivoECMTestConnectionError() {
    	Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestECMTestMock.RestECMConnectionError());
            HttpResponse res = RestECM.buscarArquivoECM('123');
    	Test.stopTest();
        System.assertEquals(null, res);
	}
}