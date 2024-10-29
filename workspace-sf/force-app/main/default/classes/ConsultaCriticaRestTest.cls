//II-154 - INICIO
@isTest
private class ConsultaCriticaRestTest {

    @isTest
    static void consultaCritTest() {
        
        RestRequest restReq = new RestRequest();
        ConsultaCriticaRest.Request request = new ConsultaCriticaRest.Request(restReq);

        ConsultaCriticaRest.Criticas critica = new ConsultaCriticaRest.Criticas();
        critica.status = 'Pendente';
        critica.grupo = '';

        List<ConsultaCriticaRest.Criticas> criticas = new List<ConsultaCriticaRest.Criticas>();

        criticas.add(critica);

        ConsultaCriticaRest.Recusas recusa = new ConsultaCriticaRest.Recusas();
        recusa.codigo = null;
        
        List<ConsultaCriticaRest.Recusas> recusas = new List<ConsultaCriticaRest.Recusas>();

        recusas.add(recusa);
        
        request.criticas = criticas;
        request.recusas = recusas;

        String payload = System.JSON.serialize(request) ;

        RestResponse res = new RestResponse();
	    restReq.requestUri ='/services/apexrest/consultaCriticas';
	    restReq.httpMethod = 'POST';
	    restReq.requestBody = Blob.valueOf(payload);
	    RestContext.response = res;
	    RestContext.request = restReq;

        Test.startTest();        
        List<ConsultaCriticaRest.Retorno> criticasRetorno = ConsultaCriticaRest.consultaCriticas();
        Test.stopTest(); 

        Assert.isNotNull(criticasRetorno, 'Success');

    }
    
    @isTest
    static void consultaCritComCodRecInexTest() {
        
        RestRequest restReq = new RestRequest();
        ConsultaCriticaRest.Request request = new ConsultaCriticaRest.Request(restReq);

        ConsultaCriticaRest.Criticas critica = new ConsultaCriticaRest.Criticas();
        critica.status = 'teste';
        critica.grupo = 'teste';

        List<ConsultaCriticaRest.Criticas> criticas = new List<ConsultaCriticaRest.Criticas>();

        criticas.add(critica);

        ConsultaCriticaRest.Recusas recusa = new ConsultaCriticaRest.Recusas();
        recusa.codigo = 1;
        
        List<ConsultaCriticaRest.Recusas> recusas = new List<ConsultaCriticaRest.Recusas>();

        recusas.add(recusa);
        
        request.criticas = criticas;
        request.recusas = recusas;

        String payload = System.JSON.serialize(request) ;

        RestResponse res = new RestResponse();
	    restReq.requestUri ='/services/apexrest/consultaCriticas';
	    restReq.httpMethod = 'POST';
	    restReq.requestBody = Blob.valueOf(payload);
	    RestContext.response = res;
	    RestContext.request = restReq;

        Test.startTest();        
        List<ConsultaCriticaRest.Retorno> criticasRetorno = ConsultaCriticaRest.consultaCriticas();
        Test.stopTest(); 

        Assert.isNotNull(criticasRetorno, 'Success');

    } 
}
//II-154 - FIM