/**
 * Created by Losada on 29/11/2018.
 */

@isTest
private class ContabilizacaoValoresRESTTest 
{

	@TestSetup
	static void setup(){
        TestDataFactory.gerarDadosSetup();
	    // PLV-2312-28 INICIO
        TestDataFactory.gerarContrato(true);
	    // PLV-2312-28 FIM
	}

   @IsTest
  private static void testarServico()
  { 

    //PLV-3667 - INICIO
    RamoSeguro__c ramoSeguro = [SELECT id FROM RamoSeguro__c LIMIT 1];
		system.debug('Classe de Teste - ramoSeguro: ' + ramoSeguro);

    Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
    system.debug('Classe de Teste - modalidade: ' + modalidade);
    //PLV-3667 - FIM

    // Mock para callout
    String jsonContabilizacao = '{"data":[{"idexterno": "8000j0000001zHIAAY_a1N0j000001DTqZEAW","idfatura": null,"codigoparceiro": "27351731000138","origemproposta": 18,"numeroproposta": "1826400961","numeropropostaporto": "26400961","numerofatura": null,"responsavelfinanceiro": "0010j00000DjfO6AAJ","tiporesponsavelpagamento": "PAR","seguradosalesforce": "a1N0j000001DTqZEAW","vidasalesforce": null,"datapagamento": null,"datavencimento": "2018-12-12T00:00:00.000Z","dataemissao": "2018-11-29T00:00:00.000Z","datacancelamento": null,"numeroparcela": 1,"status": "PENDENTE","titulo": "","produto": "V0003064","valoriof": "0.03","valorliquido": "8.13","valorparcela": "8.16","valorpago": null,"empresa": "1","sucursal": "85","ramo": "1377","apolice": "00005134","endosso": "0","quantidadevidacontrato": null,"id": 23671},{"idexterno": "8000j0000001zHIAAY_a1N0j000001DTqZEAW","idfatura": null,"codigoparceiro": "27351731000138","origemproposta": 18,"numeroproposta": "1826400961","numeropropostaporto": "26400961","numerofatura": null,"responsavelfinanceiro": "0010j00000DjfO6AAJ","tiporesponsavelpagamento": "PAR","seguradosalesforce": "a1N0j000001DTqZEAW","vidasalesforce": null,"datapagamento": null,"datavencimento": "2019-01-12T00:00:00.000Z","dataemissao": "2018-11-29T00:00:00.000Z","datacancelamento": null,"numeroparcela": 2,"status": "PENDENTE","titulo": "","produto": "V0003064","valoriof": "0.03","valorliquido": "8.13","valorparcela": "8.16","valorpago": null,"empresa": "1","sucursal": "85","ramo": "1377","apolice": "00005134","endosso": "0","quantidadevidacontrato": null,"id": 23672}],"meta": {"dataExecucao": "2018-12-04T18:54:12.589Z","servico": "Buscar parcelas do contrato por segurado ou vida","statusHttp": 200,"mensagem": "OK"}}';

    Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonContabilizacao, 200, 'OK'));

    String payload = '{"dataProcessamento" : "'+String.valueOf(System.today()) + '"}';


	List<Contract> contratoX = [Select id, name, DataEmissao__c from Contract Where Name = '14889'];
	if(contratoX.size() > 0)
	{
		for(Contract xx : contratoX)
		  System.debug('======> Achou contrato: '  + xx.DataEmissao__c);
	}


    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/api/contabilizacaovalores';
    request.httpMethod = 'POST';
    request.requestBody = Blob.valueOf(payload);

    RestResponse res = new RestResponse();

    Test.startTest();

    RestContext.response = res;
    RestContext.request = request;

    ContabilizacaoValoresREST.processarPost();

    Test.stopTest();

	String jsonResposta = RestContext.response.responseBody.toString();

    System.debug(jsonResposta);

    System.assert(jsonResposta.contains('"ok"'));

  }
}