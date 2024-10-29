/**
 * @author Jeferson (Sys4B)
 * @date 2020-05-14
 * @description DocumentAPI (Mock class for DocumentAPI)
 * Classe criada por conta da história PLV-3746
 */
@isTest
global class ServiceRestTestMock implements HttpCalloutMock{
   global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ticket":"123456"}');
        string body = 'tetetetetet';
       	res.setBodyAsBlob(Blob.valueOf(body));
        res.setStatusCode(200);
        return res;
    }
    
    global class ServiceRestTestMockECMErro implements HttpCalloutMock{
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
    
    global class ServiceRestTestMockSF implements HttpCalloutMock{
         global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            string body = 'tetetetetet';
       		res.setBodyAsBlob(Blob.valueOf(body));
            res.setBody('{"body":"sucesso"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    global class ServiceRestTestMockSFErro implements HttpCalloutMock{
         global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            string body = 'tetetetetet';
       		res.setBodyAsBlob(Blob.valueOf(body));
            res.setBody('{"body":"sucesso"}');
            res.setStatusCode(500);
            return res;
        }
    }
}