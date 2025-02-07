/**************************************************************************************************************************************************************************
 * 
 *  Classe responsável por realizar mock nas repostas das classe de testes, quando há Callout
 *
 **************************************************************************************************************************************************************************/
@isTest
global class MockHttpResponse implements HttpCalloutMock {
    private Integer statusCode {get; set;}
    private String body {get; set;}
    private String status {get; set;}

    global MockHttpResponse(String body, Integer statusCode, String status){
        this.body = body;
        this.statusCode = statusCode;
        this.status = status;
    }

    // Implementa método da interface
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setStatus(status);
        res.setBody(body);
        
        return res;
    }
}