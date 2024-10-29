/*@isTest
global class PagamentosRecentesControllerMock implements WebServiceMock {
    
	global void doInvoke(Object stub,Object request,Map<String, Object> response,String endpoint,String soapAction,
                         String requestName,String responseNS,String responseName,String responseType){
    
    //pagamentosrecentescontroller.doAddResponse response_x = new pagamentosrecentescontroller.doAddResponse();
                             
                             
   
    }
}*/


@isTest
global class PagamentosRecentesControllerMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://lotus-vida-services-avanxo.herokuapp.com/api/pagamentos/consulta-pagamentos-recentes', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        //System.assertEquals('Authorization', );
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"id": 75,"idconta": "0011F000009D3eOQAS","dataprogramadapagamento":'+ 
                     +'"2019-01-25T00:00:00.000Z","datapagamento": "2019-01-24T00:00:00.000Z",'+
        			 +'"valorpagamento": "2000.00000","status": "PAGO","motivo": "pagou atrasado",'+
        			 +'"idobjeto": "5003F000004yzCMQAY"}]');
        
        res.setStatusCode(200);
        return res;
    }
    
    global HTTPResponse respondCancelaPagamento(HTTPRequest req) {
    	
       //Criando uma resposta falsa
       		HttpResponse resposta = new HttpResponse();
        	resposta.setHeader('Content-Type', 'application/json');
        	resposta.setBody('{"affectedRows": 1,"count": 1,"rows": []}');
        	resposta.setStatusCode(200);        
        return resposta;
    }
}