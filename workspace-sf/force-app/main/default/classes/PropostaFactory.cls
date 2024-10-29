// PLV-4337 - INÍCIO
// PLV-2932 - INÍCIO - Criação da classe Factory do objeto Quote 
/**
 * @author AVX - Daniel Zampieri
 * @date 2019-10-17
 * @description Quote Factory Class
 */
@isTest
public class PropostaFactory extends SObjectFactory {

    private static Quote staticRecord;
    
    private static Quote getRecordStatic( Product2 produto, RamoSeguro__c ramoSeguro, Account empresa, 
    	DadosCorretor__c dadosCorretor, Opportunity orcamento, Modalidade__c modalidade ) {
        if( staticRecord == null ) {
             staticRecord = get( produto, ramoSeguro, empresa, dadosCorretor, orcamento, modalidade, '18-00006768', '67708896000139' );
        } 
        return staticRecord;
	}

    public static Quote get( Product2 produto, RamoSeguro__c ramoSeguro, Account empresa, 
		DadosCorretor__c dadosCorretor, Opportunity orcamento, Modalidade__c modalidade, String nome, String parceiro ) 
    {
        Quote proposta = new Quote(
            Name = nome,
            NumeroPropostaUnico__c = nome,
            Produto__c = produto.Id,
            Produto__r = produto,
            RamoSeguro__c = ramoSeguro.Id,
            RamoSeguro__r = ramoSeguro,
            Status = 'Em criação',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = empresa.Id,
            Empresa__r = empresa,
            CodigoCorretor__c = dadosCorretor.Id,
            CodigoCorretor__r = dadosCorretor,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', //PLV-4550 INICIO/FIM
            OpportunityId = orcamento.Id,
            Opportunity = orcamento,
            Origem__c = '18',
            Modalidade__c = modalidade.Id,
            Modalidade__r = modalidade,
            NumeroProposta__c = '00006767',
            Parceiro__c = parceiro
        ); 

        return proposta;
    }

    public PropostaFactory() {
        this(
            ( Product2 ) new ProdutoFactory.ProdutoComercial().createRecord(),
            ( RamoSeguro__c ) new RamoSeguroFactory().createRecord(),
            ( Account ) new AccountFactory.PessoaJuridica().createRecord(),
            ( DadosCorretor__c ) new DadosCorretorFactory().createRecord(),
            ( Opportunity ) new OrcamentoFactory.VidaIndividual().createRecord(),
            ( Modalidade__c ) new ModalidadeFactory().createRecord()
        );
    }

	public PropostaFactory( Product2 produto, RamoSeguro__c ramoSeguro, Account empresa, 
		DadosCorretor__c dadosCorretor, Opportunity orcamento, Modalidade__c modalidade) {
		super( getRecordStatic( produto, ramoSeguro, empresa, dadosCorretor, orcamento, modalidade ) );
	}
}
// PLV-2932 - FIM
// PLV-4337 - FIM