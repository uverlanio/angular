/**
 * @author Isabela (Globant) & Jeferson (Sys4B)
 * @date 2020-03-28
 * @description RestECMTestMock (Mock class for RestECMTest & DocumentoEcmControllerTest)
 * Classe criada por conta da história PLV-3413
 */
@isTest
global class RestECMTestMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ticket":"123456"}');
        res.setStatusCode(200);
        return res;
    }
    
    global class RestECMConnectionError implements HttpCalloutMock{
         global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"body":"sucesso"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    global class RestECMFileError implements HttpCalloutMock{
         global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"ticket":"123456"}');
            res.setStatusCode(500);
            return res;
        }
    }
}