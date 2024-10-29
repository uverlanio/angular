// PLV-4998 - INÍCIO
global class BatchExpurgoPropostas implements Database.Batchable<SObject>, Schedulable
{
    private Integer batch = 0;

	global BatchExpurgoPropostas(Integer batch)
    {
        this.batch = batch;
    }
	
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global Database.QueryLocator start(Database.BatchableContext context)
    {
        String query;

        if(batch == 1)
            query = 'SELECT Proposta__c FROM Contract WHERE CreatedDate < LAST_N_YEARS:2 AND Proposta__c != NULL AND Proposta__r.QuantidadeGarantias__c > 0';
        else if(batch == 2)
            query = 'SELECT Id FROM Quote WHERE Status NOT IN (\'Contratada\',\'Em análise\') AND CreatedDate < LAST_N_YEARS:1 AND QuantidadeGarantias__c > 0';
        
        return Database.getQueryLocator(query);
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<SObject> scope)
    {
        List<Contract> propostasContratadas = new List<Contract>();
        List<Quote> propostasNaoContratadas = new List<Quote>();

		Set<Id> IdsProposta = new Set<Id>();

        for(SObject proposta : scope)
        {
            if(proposta instanceof Contract)
            {
                propostasContratadas.add((Contract)proposta);
            }
            else
            {
                propostasNaoContratadas.add((Quote)proposta);
            }
        }

        for(Contract propostasContratada : propostasContratadas)
        {
			IdsProposta.add(propostasContratada.Proposta__c);
		}

        for(Quote propostaNaoContratada : propostasNaoContratadas)
        {
			IdsProposta.add(propostaNaoContratada.Id);
		}
		
		List<GarantiaProposta__c> garantiasProposta = QuoteDAO.getInstance().buscarGarantiasProposta(IdsProposta);
		List<RemuneracaoProposta__c> remuneracoesProposta = QuoteDAO.getInstance().buscarRemuneracaoProposta(IdsProposta);
		List<ContratanteProposta__c> contratantesProposta = QuoteDAO.getInstance().buscarContratantesPropostaPorIdProposta(IdsProposta);
		List<GrupoProposta__c> gruposProposta = QuoteDAO.getInstance().buscarListGrupoPropostaByQuote(IdsProposta);
		List<SeguradoProposta__c> seguradosProposta = QuoteDAO.getInstance().buscarListSeguradoProposta(IdsProposta);
        List<BeneficiarioSeguradoProposta__c> beneficiariosSeguradosProposta = QuoteDAO.getInstance().buscarBeneficiariosSeguradosProposta(IdsProposta);
        List<Attachment> anexosProposta = [SELECT Id FROM Attachment WHERE ParentId =: IdsProposta];
		
        try
        {
            if(batch == 1)
                System.debug('<<<< INICIO DO EXPURGO DAS PROPOSTAS CONTRATADAS >>>>');
            else if(batch == 2)
                System.debug('<<<< INICIO DO EXPURGO DAS PROPOSTAS NAO CONTRATADAS >>>>');

            System.debug('------------------------------------------------');
            System.debug('QUANTIDADE DE PROPOSTAS: '+IdsProposta.size());  
            System.debug('------------------------------------------------');
            System.debug('QUANTIDADE DE GARANTIAS DE PROPOSTAS A SEREM EXCLUIDAS: '+garantiasProposta.size());
			delete garantiasProposta;
            System.debug('QUANTIDADE DE REMUNERACOES DE PROPOSTAS A SEREM EXCLUIDAS: '+remuneracoesProposta.size());
			delete remuneracoesProposta;
            System.debug('QUANTIDADE DE BENEFICIAROS DOS SEGURADOS DE PROPOSTAS A SEREM EXCLUIDOS: '+beneficiariosSeguradosProposta.size());
			delete beneficiariosSeguradosProposta;
            System.debug('QUANTIDADE DE SEGURADOS DE PROPOSTAS A SEREM EXCLUIDOS: '+seguradosProposta.size());
			delete seguradosProposta;
            System.debug('QUANTIDADE DE GRUPOS DE PROPOSTAS A SEREM EXCLUIDOS: '+gruposProposta.size());
			delete gruposProposta;
			System.debug('QUANTIDADE DE CONTRATANTES DE PROPOSTAS A SEREM EXCLUIDOS: '+contratantesProposta.size());
            delete contratantesProposta;
            System.debug('QUANTIDADE DE ANEXOS DE PROPOSTAS A SEREM EXCLUIDOS: '+anexosProposta.size());
            delete anexosProposta;

            if(garantiasProposta.size() > 0)
            	Database.emptyRecycleBin(garantiasProposta);
            
            if(remuneracoesProposta.size() > 0)
            	Database.emptyRecycleBin(remuneracoesProposta);
            
            if(beneficiariosSeguradosProposta.size() > 0)
            	Database.emptyRecycleBin(beneficiariosSeguradosProposta);

            if(seguradosProposta.size() > 0)
            	Database.emptyRecycleBin(seguradosProposta);
            
            if(gruposProposta.size() > 0)
            	Database.emptyRecycleBin(gruposProposta);
            
            if(contratantesProposta.size() > 0)
            	Database.emptyRecycleBin(contratantesProposta);
            
            if(anexosProposta.size() > 0)
            	Database.emptyRecycleBin(anexosProposta);
		}
		catch(Exception e)
        {
			System.debug('Erro na exclusão do Expurgo de Propostas: ' + e.getMessage());
		}

        System.debug('------------------------------------------------');
        System.debug('<<<< REGISTROS RELACIONADOS AS PROPOSTAS APOS O EXPURGO >>>>');  
        System.debug('------------------------------------------------');
        List<GarantiaProposta__c> garantiasPropostasExcluidas = QuoteDAO.getInstance().buscarGarantiasProposta(IdsProposta);
		System.debug('QUANTIDADE DE GARANTIAS DE PROPOSTAS APOS O EXPURGO: '+garantiasPropostasExcluidas.size());
        List<RemuneracaoProposta__c> remuneracoesPropostaExcluidas = QuoteDAO.getInstance().buscarRemuneracaoProposta(IdsProposta);
        System.debug('QUANTIDADE DE REMUNERACOES DE PROPOSTAS APOS O EXPURGO: '+remuneracoesPropostaExcluidas.size());
		List<ContratanteProposta__c> contratantesPropostaExcluidos = QuoteDAO.getInstance().buscarContratantesPropostaPorIdProposta(IdsProposta);
		System.debug('QUANTIDADE DE CONTRATANTES DE PROPOSTAS APOS O EXPURGO: '+contratantesPropostaExcluidos.size());
        List<GrupoProposta__c> gruposPropostaExcluidos = QuoteDAO.getInstance().buscarListGrupoPropostaByQuote(IdsProposta);
        System.debug('QUANTIDADE DE GRUPOS DE PROPOSTAS APOS O EXPURGO: '+gruposPropostaExcluidos.size());
		List<SeguradoProposta__c> seguradosPropostaExcluidos = QuoteDAO.getInstance().buscarListSeguradoProposta(IdsProposta);
        System.debug('QUANTIDADE DE SEGURADOS DE PROPOSTAS APOS O EXPURGO: '+seguradosPropostaExcluidos.size());
        List<BeneficiarioSeguradoProposta__c> BeneficiariosSeguradosPropostaExcluidos = QuoteDAO.getInstance().buscarBeneficiariosSeguradosProposta(IdsProposta);
        System.debug('QUANTIDADE DE SEGURADOS DE PROPOSTAS APOS O EXPURGO: '+beneficiariosSeguradosPropostaExcluidos.size());
        List<Attachment> anexosPropostaExcluidos = [SELECT Id FROM Attachment WHERE ParentId =: IdsProposta];
        System.debug('QUANTIDADE DE ANEXOS DE PROPOSTAS APOS O EXPURGO: '+anexosPropostaExcluidos.size());
	}        
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context){ }

     global void execute(SchedulableContext SC)
     {
        BatchExpurgoPropostas batchPropostas = new BatchExpurgoPropostas(1);
        Database.executeBatch(batchPropostas, 100);

        BatchExpurgoPropostas batchNaoContratados = new BatchExpurgoPropostas(2);
        Database.executeBatch(batchNaoContratados, 100);
    }
}
// PLV-4998 - FIM