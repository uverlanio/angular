@isTest
public class ContractFactory extends SObjectFactory {

    private static Contract staticRecord;
    
    private static Contract getRecordStatic( Product2 produto, RamoSeguro__c ramoSeguro, Account empresa, 
    	DadosCorretor__c dadosCorretor, Opportunity orcamento, Modalidade__c modalidade ) {
        if( staticRecord == null ) {
             staticRecord = get( produto, ramoSeguro, empresa, dadosCorretor, orcamento, modalidade, '18-00006768', '67708896000139' );
        } 
        return staticRecord;
	}

    public static Contract get( Product2 produto, RamoSeguro__c ramoSeguro, Account empresa, 
		DadosCorretor__c dadosCorretor, Opportunity orcamento, Modalidade__c modalidade, String nome, String parceiro ) 
    {
        Contract proposta = new Contract(
            AccountId = empresa.Id,
            Name = nome,
            NumeroPropostaUnico__c = nome,
            Produto__c = produto.Id,
            Produto__r = produto,
            RamoSeguro__c = ramoSeguro.Id,
            RamoSeguro__r = ramoSeguro,
            Status = 'Em elaboração',
            StartDate = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = 'AB',
            CodigoCorretor__c = dadosCorretor.Id,
            CodigoCorretor__r = dadosCorretor,
            // DataCalculo__c = System.today(),
            CreatedDate = System.today(),
            // TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', //PLV-4550 INICIO/FIM
            // OpportunityId = orcamento.Id,
            // Opportunity = orcamento,
            Origem__c = '18',
            // Modalidade__c = modalidade.Id,
            // Modalidade__r = modalidade,
            NumeroProposta__c = '00006767',
            Parceiro__c = parceiro
        ); 

        return proposta;
    }

    public ContractFactory() {
        this(
            ( Product2 ) new ProdutoFactory.ProdutoComercial().createRecord(),
            ( RamoSeguro__c ) new RamoSeguroFactory().createRecord(),
            ( Account ) new AccountFactory.PessoaJuridica().createRecord(),
            ( DadosCorretor__c ) new DadosCorretorFactory().createRecord(),
            ( Opportunity ) new OrcamentoFactory.VidaIndividual().createRecord(),
            ( Modalidade__c ) new ModalidadeFactory().createRecord()
        );
    }

	public ContractFactory( Product2 produto, RamoSeguro__c ramoSeguro, Account empresa, 
		DadosCorretor__c dadosCorretor, Opportunity orcamento, Modalidade__c modalidade) {
		super( getRecordStatic( produto, ramoSeguro, empresa, dadosCorretor, orcamento, modalidade ) );
	}
}
// PLV-2932 - FIM
// PLV-4337 - FIM