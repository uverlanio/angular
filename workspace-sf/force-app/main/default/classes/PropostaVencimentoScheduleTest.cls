// PLV-4337 - INICIO
/*
*  @author: Squad Avanxo 
*  @description: Schedule Batch para vencer as propostas - CLASSE DE TESTE
*/
@isTest
public class PropostaVencimentoScheduleTest {
 
    @TestSetup
    static void setup(){
        TestDataFactory.gerarDadosSetup();
    }

    @isTest
    public static void validarSchedule(){
        Account conta = ( Account ) new AccountFactory.PessoaFisica().createRecord();
        RamoSeguro__c ramoSeguro = ( RamoSeguro__c ) new RamoSeguroFactory( conta ).createRecord();
        DadosCorretor__c dadosCorretor = ( DadosCorretor__c ) new DadosCorretorFactory( conta ).createRecord();
        Modalidade__c modalidade = ( Modalidade__c ) new ModalidadeFactory( ramoSeguro ).createRecord();

        Product2 produtoTecnico = ( Product2 ) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = ( Product2 ) new ProdutoFactory.ProdutoComercial( produtoTecnico ).createRecord();

        Opportunity orcamento = ( Opportunity ) new OrcamentoFactory.VidaIndividual( produtoComercial, conta ).createRecord();

        Quote proposta = ( Quote ) new PropostaFactory( produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
        proposta.DataVencimento__c = System.today() - 1;
        update proposta;
        
        System.debug( 'PropostaVencimentoScheduleTest - Data de Vencimento: ' + proposta.DataVencimento__c );
        
        Test.startTest();
        
        PropostaVencimentoSchedule classe = new PropostaVencimentoSchedule();
        
        Test.stopTest();
    }
}
// PLV-4337 - FIM