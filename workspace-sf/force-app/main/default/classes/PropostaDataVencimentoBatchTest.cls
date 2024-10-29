// PLV-4337 - INICIO
/*
*  @author: Squad Avanxo 
*  @description: Batch para setar as datas de vencimento das propostas - CLASSE DE TESTE
*/
@isTest
public class PropostaDataVencimentoBatchTest {

    @TestSetup
    static void setup() {
        TestDataFactory.gerarDadosSetup();
    }

    @isTest
    public static void validarSchedule() {
        validarSchedule( System.today().addDays( 5 ) );
    }

    @isTest
    public static void validarSchedule2() {
        validarSchedule( null );
    }

    private static void validarSchedule( Date dataVencimento ) {
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
        
        ParametroVigencia__c parametroVigencia = new ParametroVigencia__c();
        parametroVigencia.Produto__c = produtoComercial.Id;
        parametroVigencia.ValidadeOrcamento__c = 4;
        parametroVigencia.PeriodoMaximoInadimplencia__c = 30;
        insert parametroVigencia;

        Opportunity orcamento = ( Opportunity ) new OrcamentoFactory.VidaIndividual( produtoComercial, conta ).createRecord();
        orcamento.DataVencimento__c = dataVencimento;
        update orcamento;

        List< Quote > propostas = new List< Quote >();
        propostas.add( PropostaFactory.get( produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade, '18-00006768', '67708896000140' ) );
        propostas.add( PropostaFactory.get( produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade, '18-00006769', '67708896000141' ) );
        insert propostas;
        propostas[0].DataVencimento__c = null;
        propostas[1].DataVencimento__c = null;
        update propostas;
        
        Test.startTest();
        
        Database.executebatch( new PropostaDataVencimentoBatch(), 50 );
   
        Test.stopTest();
    }
}
// PLV-4337 - FIM