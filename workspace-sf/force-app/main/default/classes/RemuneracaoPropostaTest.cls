/**
 * Created by Alessndro Ponte on 16/07/2018.
 */

@IsTest
private class RemuneracaoPropostaTest {

  @TestSetup
  static void setup(){
    TestDataFactory.gerarDadosSetup();
    // PLV-2312-28 INICIO
    TestDataFactory.gerarProposta(true);
    // PLV-2312-28 FIM
  }

  @IsTest
  static void testBehaviour(){

    // Pega a proposta
    Quote proposta = [SELECT Id FROM Quote LIMIT 1];
    // Pega o tipo de Remuneracao
    TipoRemuneracao__c tipoRemuneracao = [SELECT Id FROM TipoRemuneracao__c LIMIT 1];

//    RemuneracaoProposta__c remuneracaoProposta = TestDataFactory.gerarRemuneracaoProposta(proposta, tipoRemuneracao);

    // Cria uma remuneracao para apagar
    RemuneracaoProposta__c remuneracaoPropostaParaApagar = new RemuneracaoProposta__c(
        TipoRemuneracao__c = tipoRemuneracao.Id,
        Proposta__c = proposta.Id,
        Percentual__c = 11
    );
    insert  remuneracaoPropostaParaApagar;

    Id remuneracaoPropostaParaApagarId = remuneracaoPropostaParaApagar.Id;

    List<RemuneracaoProposta__c> listaRemuneracaoPropostaParaApagar = new List<RemuneracaoProposta__c>{remuneracaoPropostaParaApagar};

    Test.startTest();
    List<RemuneracaoProposta__c> listRemuneracaoProposta = RemuneracaoPropostaController.buscarRemuneracaoProposta(proposta.Id);
    List<Opportunity> listRemuneracaoOrcamento  = RemuneracaoPropostaController.buscarRemuneracaoOrcamentoNoOrcamento(proposta.Id);

    // Atualiza a participação da remuneracao
    RemuneracaoProposta__c remuneracaoProposta = listRemuneracaoProposta[0];
    Decimal percentualAntiga = remuneracaoProposta.Percentual__c;
    remuneracaoProposta.Percentual__c = percentualAntiga + 10;

    RemuneracaoPropostaController.salvarRemuneracaoProposta ( listRemuneracaoProposta, listaRemuneracaoPropostaParaApagar);


    Test.stopTest();

    // Testa o metodo buscarRemuneracaoProposta
    System.assert(listRemuneracaoProposta.size() > 0);
    // Testa o metodo buscarRemuneracaoOrcamentoNoOrcamento
    System.assert(listRemuneracaoOrcamento.size() > 0);

    System.debug('remuneracaoPropostaParaApagarId' + remuneracaoPropostaParaApagarId);

    // Testa o método salvarRemuneracaoProposta verificando se apagou a remuneracao
    List<RemuneracaoProposta__c> listRemuneracaoPropostaResp = [SELECT Id FROM RemuneracaoProposta__c WHERE Id =: remuneracaoPropostaParaApagarId];
    System.assert(listRemuneracaoPropostaResp.size() == 0);

    // Testa o método salvarRemuneracaoProposta verificando se atualizou a remuneracao
    RemuneracaoProposta__c remuneracaoPropostaResp2 = [SELECT Id,Percentual__c FROM RemuneracaoProposta__c WHERE Id =: remuneracaoProposta.Id LIMIT 1];
    System.assert(remuneracaoPropostaResp2.Percentual__c == PercentualAntiga + 10); 

  }
}