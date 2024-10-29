//PLV-4096 INICIO
@isTest
global class ConsultaCivTestMock implements HttpCalloutMock{
    
   global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string body = '{'+
					   '"meta":{'+
						  '"statusHttp":200,'+
						  '"servico":"/sinistro/criar",'+
						  '"mensagem":"OK",'+
						  '"dataExecucao":"2020-06-25T12:05:38.946Z"'+
					   '},'+
					   '"data":{'+
						  '"sinistro":{'+
							 '"status":"Avisado",'+
							 '"ramo":"1369",'+
							 '"numeroSinistro":"1.1369.2020.500020",'+
							 '"idAtendimentoPrestadora":"IdAssist19",'+
							 '"idTicketBCP":123456,'+
							 '"empresa":"1",'+
							 '"ano":2020'+
						  '},'+
						  '"mensagem":"",'+
						  '"erro":false'+
					   '}'+
					   '}';

			res.setBody('{'+
					   '"meta":{'+
						  '"statusHttp":200,'+
						  '"servico":"/sinistro/criar",'+
						  '"mensagem":"OK",'+
						  '"dataExecucao":"2020-06-25T12:05:38.946Z"'+
					   '},'+
					   '"data":{'+
						  '"sinistro":{'+
							 '"status":"Avisado",'+
							 '"ramo":"1369",'+
							 '"numeroSinistro":"1.1369.2020.500020",'+
							 '"idAtendimentoPrestadora":"IdAssist19",'+
							 '"idTicketBCP":123456,'+
							 '"empresa":"1",'+
							 '"ano":2020'+
						  '},'+
						  '"mensagem":"",'+
						  '"erro":false'+
					   '}'+
					   '}');
       
       	res.setBodyAsBlob(Blob.valueOf(body));
        res.setStatusCode(200);
        return res;
    }
    
     global class ConsultaMoedaEstrangeiraTestErroMock implements HttpCalloutMock{
         global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            string body = 'tetetetetet';
       		res.setBodyAsBlob(Blob.valueOf(body));
            res.setBody('{"error":"erro"}');
            res.setStatusCode(500);
            return res;
        }
    }
    
     global class ConsultaMoedaEstrangeiraToken implements HttpCalloutMock{
         global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            string body = 'tetetetetet';
       		res.setBodyAsBlob(Blob.valueOf(body));
            res.setBody('{'+
                        '"access_token": "5c82016d-b35e-4b82-aaf4-97af6a1bc68e",'+
                        '"token_type": "Bearer",'+
                        '"expires_in": 3600,'+
                        '"scope": "oob"'+
                        '}');
            res.setStatusCode(200);
            return res;
        }
    }     
}
//PLV-4096 FIM