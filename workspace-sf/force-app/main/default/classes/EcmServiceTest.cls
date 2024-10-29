/**
* Testes EcmService
* @author Diogo Borges @ 27/03/2020
* PLV-3667
**/

@isTest
public class EcmServiceTest {
    
    @isTest
    public static void testGerarToken(){
        //PLV-4921 - INICIO
        EcmTO ecmto = new EcmTO();
        ecmto.ticket = 'test';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(ecmto), 200, 'OK'));
        //PLV-4921 - FIM
        
        Test.startTest();
        EcmService ecm = EcmService.getInstance();
        String retorno = ecm.gerarToken();
        
        Test.stopTest();
    }
    
    //buscarDocumento
    
    @isTest
    public static void testBuscarDocumento(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('mock'), 200, 'OK'));
        
        Test.startTest();
        
        EcmService ecm = EcmService.getInstance();
        HttpResponse retorno = ecm.buscarDocumento('Mock');
        
        Test.stopTest();
    }
    //PLV-4921 - INICIO
    public class EcmTO {
        public String ticket {get; set;}
        public String status {get; set;}
        public String codigo {get; set;}
        public String mensagem {get; set;}
        public String base64 {get; set;}
    }
    //PLV-4921 - FIM
}