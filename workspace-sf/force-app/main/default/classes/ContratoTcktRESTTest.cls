/*********************************************************************************************************************************************************************

@description  Classe de teste API REST Contrato Ticket.
@author Uverlanio Mauricio
@date 23/01/2023
@Classe criada por conta da história LECVP-72        
**********************************************************************************************************************************************************************/
//LECVP-72 - INICIO
@isTest
private class ContratoTcktRESTTest {    

    @isTest static void testarEndpoint(){

        RestResponse response = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/api/contrato/bcp/devolutivas';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(JSON.serialize(gerarDados()));

        String retornoMock = '{"status" : "ok"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoMock, 200, 'OK'));

        RestContext.response = response;
	    RestContext.request = request;

        Test.startTest();

	    ContratoTcktREST.processarPost();        

	    Test.stopTest();
        
        String retorno = RestContext.response.responseBody.toString();
	    System.assertEquals(true, retorno != null);
    }

    @isTest static void testarEndpointException(){
        RestResponse response = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/api/contrato/bcp/devolutivas';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf('');

        String retornoMock = '{"status" : "ok"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoMock, 400, 'Ticket inválido'));

        RestContext.response = response;
	    RestContext.request = request;

        Test.startTest();

	    ContratoTcktREST.processarPost(); 

	    Test.stopTest();
    }

    public static BCPContratoTcktTO gerarDados(){

        BCPContratoTcktTO contratoTckt = new BCPContratoTcktTO();
        BCPContratoTcktTO.RespostaBCP respostaBCP = new BCPContratoTcktTO.RespostaBCP();
        contratoTckt.proposta = '0';
        respostaBCP.numeroSequenciaControle = '0';
        respostaBCP.codigo = '0';
        contratoTckt.respostaBCP = respostaBCP;

        return contratoTckt;
    }
}
//LECVP-72 - FIM