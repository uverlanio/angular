//PLV-3854 INICIO

@isTest
global class ConsultaMoedaEstrangeiraTestMock implements HttpCalloutMock{
    
   global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string body = '{'+
                    '"ItensCotacao": {'+
                    '"ItemCotacao": {'+
                    '"moedaOrigem": "USD",'+
                    '"moedaDestino": "BRL",'+
                    '"dataCotacao": 22052020,'+
                    '"cotacao": "5.60130000"'+
                    '}'+
                    '}'+
                    '}';

        res.setBody('{'+
                    '"ItensCotacao": {'+
                    '"ItemCotacao": {'+
                    '"moedaOrigem": "USD",'+
                    '"moedaDestino": "BRL",'+
                    '"dataCotacao": 22052020,'+
                    '"cotacao": "5.60130000"'+
                    '}'+
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
//PLV-3854 FIM