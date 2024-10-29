/**
 * Created by Alessandro Ponte on 14/12/2018.
 */

@IsTest
private class TitulosCapitalizacaoControllerTest {

  @TestSetup
  static void setup(){
    TestDataFactory.gerarDadosSetup();
    TestDataFactory.gerarParceiroCompletoAtivo(true);
  }

  @IsTest
  static void testBuscarTodosParceiros(){

    Test.startTest();

    TitulosCapitalizacaoController.buscarTodosParceiros();

    Test.stopTest();

    List<Parceiro__c> listParceiro = [SELECT Id FROM Parceiro__c];
    System.assert(listParceiro.size() > 0);

  }

  @IsTest
  static void testGerarNumeroProposta(){

    String payloadReturn = '{"data": {"lote": 13,"nome": "PORTO_RE_CCR_ETQ_00000002_VG09.PRO.tar.gz","status": "PROCESSADO"},"meta": {"dataExecucao": "2018-12-17T17:53:01.330Z","servico": "Gerador de números de proposta","statusHttp": 200,"mensagem": "OK"}}';
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));

    Parceiro__c parceiro = [SELECT Id,Codigo__c FROM Parceiro__c LIMIT 1];

    ContratoTO.SolicitarTituloTO solicitarTituloTO = new ContratoTO.SolicitarTituloTO();
    solicitarTituloTO.produto = 'CCR';
    solicitarTituloTO.parceiro = parceiro.Codigo__c;
    solicitarTituloTO.origemproposta = 18;
    solicitarTituloTO.quantidade = 1;

    Test.startTest();

    STring retornoString = TitulosCapitalizacaoController.gerarNumeroProposta(JSON.serialize(solicitarTituloTO));
    HerokuResponseTO.TituloTO tituloTO = (HerokuResponseTO.TituloTO) JSON.deserialize(retornoString,HerokuResponseTO.TituloTO.class);

    Test.stopTest();

    System.assert(tituloTO.meta.statusHttp == 200);

  }

  @IsTest
  static void testConsultarEstoque(){

    String payloadReturn = '{"data": [{"idlote": 13, "produto": "VG00000012", "dataregistro": "2018-1218", "codigoparceiro": "11312312312321", "status": "PROCESSADO", "quantidade": "3"} ], "meta": {"dataExecucao": "2018-12-17T17:53:01.330Z", "servico": "Gerador de números de proposta", "statusHttp": 200, "mensagem": "OK"}}';
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));

    Parceiro__c parceiro = [SELECT Id, Codigo__c FROM Parceiro__c LIMIT 1];

    ContratoTO.ConsultarEstoqueTO consultarEstoqueTO = new ContratoTO.ConsultarEstoqueTO();
    consultarEstoqueTO.codigoProduto = 'VG00000012';
    consultarEstoqueTO.codigoParceiro = parceiro.Codigo__c;
    consultarEstoqueTO.dataInicial = '2018-11-01';
    consultarEstoqueTO.dataFinal = '2018-12-01';

    Test.startTest();

    STring retornoString = TitulosCapitalizacaoController.consultarEstoque(JSON.serialize(consultarEstoqueTO));
    System.System.debug('testConsultarEstoque: '+ retornoString);
    HerokuResponseTO.LoteTO loteTO = (HerokuResponseTO.LoteTO) JSON.deserialize(retornoString, HerokuResponseTO.LoteTO.class);

    Test.stopTest();

    System.assert(loteTO.meta.statusHttp == 200);

  }

}