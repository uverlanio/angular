/**
 * Created by Alessndro Ponte on 01/12/2018.
 */

@IsTest
public class FaturaTest {

  @TestSetup
  public static void setup(){
    TestDataFactory.gerarDadosSetup();
    TestDataFactory.gerarParceiroCompletoAtivo(true);
    TestDataFactory.gerarFatura();
  }
 
    
  @isTest
  public static void gerarFaturaComSucesso(){
    StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadFaturas' LIMIT 1];
    String payload = staticResource.Body.toString();
	
    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/api/fatura';
    request.httpMethod = 'POST';
    request.requestBody = Blob.valueOf(payload);

    RestResponse res = new RestResponse();

    RestContext.response = res;
    RestContext.request = request;

    Test.startTest();

    FaturaREST.processarPost();

    Test.stopTest();

    List<Fatura__c> listFatura = [SELECT Id FROM Fatura__c];

    System.assert( listFatura.size() > 0 );
  }

  @isTest
  public static void gerarFaturaCatch(){

    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/api/fatura';
    request.httpMethod = 'POST';

    RestResponse res = new RestResponse();

    RestContext.response = res;
    RestContext.request = request;

    Test.startTest();

    FaturaREST.processarPost();

    Test.stopTest();

  }

  @IsTest
  static void testBuscarFaturas(){
    Set<Id> setFaturaId = new Set<Id>();

    for(Fatura__c fatura : [SELECT Id FROM Fatura__c]){
      setFaturaId.add(fatura.Id);
    }

    Test.startTest();
    List<Fatura__c> listFatura = FaturaBO.getInstance().buscarFaturas(setFaturaId);
    Test.stopTest();

    System.assert(listFatura.size() > 0);

  }

  @isTest
  public static void alterarFaturaTest()
  {

    String responseJsonString = '{"meta": {"dataExecucao": "2018-12-09T19:34:12.001Z","servico": "Consultar parcelas do contrato ","statusHttp": 200,"mensagem": "Ok"},"data": [{"idlote": 546,"idarquivo": 718,"codigoparceiro": "11333444999978","empresa": "1","sucursal": "11","ramo": "1377","apolice": "00000002","endosso": "201812000","origemproposta": 55,"numeroproposta": 82,"numerocontratoparceiro": "00000025376126","dataemissao": "2018-12-1","iniciocompetencia": "2018-10-24","competencia": "2018-10-1","finalcompetencia": "2018-11-23","datavencimento": "2018-12-20","valorliquido": 1139.8700000000001,"valoriof": 0.32,"valortotal": 1140.19,"tipofatura": "Cobranca","status": "PENDENTE","codigosproduto": "V0003064"}]}';

    Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 200, 'OK'));

      Fatura__c newFatura = new Fatura__c();

      newFatura = [Select 
                    Apolice__c,
                    Empresa__c,
                    Conta__c,
                    Sucursal__c,
                    Ramo__c,
                    CodigoProdutoComercial__c,
                    DataEmissao__c,
                    DataVencimento__c,
                    Endosso__c,
                    FinalCompetencia__c,
                    InicioCompetencia__c,
                    Origem__c,
                    Proposta__c,
                    TipoFatura__c,
                    ValorIOF__c,
                    ValorLiquido__c,
                    ValorTotal__c,
                    Status__c,
                    Name
                  from Fatura__c where Apolice__c = '123456'][0];

      newFatura.ValorLiquido__c = 150;

      update newFatura;

  }

  @IsTest
  static void testAtualizacaoFaturaControleintegracao(){

    String responseString = '{"data":{},"meta":{"servico":"teste","dataExecucao" : "2018-12-03T00:00:00.000Z","statusHttp":200,"mensagem":"Teste"}}';
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseString, 200, 'OK'));

    List<Fatura__c> listFatura = [SELECT Id,Status__c,TipoFatura__c FROM Fatura__c];
    listFatura[0].Status__c = 'Paga';
    listFatura[0].TipoFatura__c = 'Cobranca';
    update listFatura;

    List<ControleIntegracao__c> listControleIntegracao = [SELECT Id FROM ControleIntegracao__c WHERE CodigoIntegracao__c = '63'];

    System.assert(listControleIntegracao.size() > 0);

  }

}