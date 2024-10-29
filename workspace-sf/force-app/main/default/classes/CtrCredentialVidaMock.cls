/****
@description Classe de mock para classe CtrCredentialVidaTest
@author Isabela Fin - Globant
@date 17/07/2020
@Classe referente a historia PLV-4039      
*****/
@isTest
global class CtrCredentialVidaMock implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"codigo":"0"}');
        res.setStatusCode(200);
        return res;
    }

    global class InvalidSession implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setBody('{"codigo":"1"}');
            res.setStatusCode(200);
            return res;
        }
    }

    global class CalloutError implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setBody('{"message":"Métodos parâmetros insuficientes"}');
            res.setStatusCode(400);
            return res;
        }
    }
}