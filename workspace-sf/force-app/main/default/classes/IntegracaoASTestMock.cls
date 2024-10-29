@isTest
global class IntegracaoASTestMock  implements HttpCalloutMock {
     
    global HTTPResponse respond(HTTPRequest req) {
        
        System.assertEquals('https://xxxxxxxx.com', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());        
       
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);
        return res;
    }
}