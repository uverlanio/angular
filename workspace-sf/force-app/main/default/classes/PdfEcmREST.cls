@RestResource(urlMapping='/buscaecmpdf/*')
global with sharing class PdfEcmREST {
	
	@HttpGet
    global static void processarGet() {
    	// PLV-1393-27-v5 - INICIO
    	RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = PdfEcmBO.getInstance().buscarDocumento(RestContext.request.params.get('codigo'));
        // PLV-1393-27-v5 - FINAL
    }
}