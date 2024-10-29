// PLV-4997 - INÍCIO
global class BatchExpurgoOrcamentos implements Database.Batchable<SObject>, Schedulable
{
    private Integer batch = 0;

	global BatchExpurgoOrcamentos(Integer batch)
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
            query = 'SELECT Oportunidade__c FROM Contract WHERE CreatedDate < LAST_N_MONTHS:12 AND Oportunidade__c != NULL AND Oportunidade__r.QuantidadeGarantias__c > 0';
        else if(batch == 2)
            query = 'SELECT Id FROM Opportunity WHERE CreatedDate < LAST_N_DAYS:45 AND StageName != \'Contratado\' AND QuantidadeGarantias__c > 0';
        
        return Database.getQueryLocator(query);
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<SObject> scope)
    {
        List<Contract> orcamentosContratados = new List<Contract>();
        List<Opportunity> orcamentosNaoContratados = new List<Opportunity>();

		Set<Id> IdsOrcamento = new Set<Id>();

        for(SObject orcamento : scope)
        {
            if(orcamento instanceof Contract)
            {
                orcamentosContratados.add((Contract)orcamento);
            }
            else
            {
                orcamentosNaoContratados.add((Opportunity)orcamento);
            }
        }

        for(Contract orcamentoContratado : orcamentosContratados)
        {
			IdsOrcamento.add(orcamentoContratado.Oportunidade__c);
		}

        for(Opportunity orcamentoNaoContratado : orcamentosNaoContratados)
        {
			IdsOrcamento.add(orcamentoNaoContratado.Id);
		}
		
		List<GarantiaOrcamento__c> garantiasOrcamento = OpportunityDAO.getInstance().buscarGarantiasOrcamento(IdsOrcamento);
		List<RemuneracaoOrcamento__c> remuneracoesOrcamento = RemuneracaoOrcamentoDAO.getInstance().buscarRemuneracoesOportunidade(IdsOrcamento);
		// Já retorna as Garantias dos Contratantes.
		List<ContratanteOrcamento__c> contratantesOrcamento = OpportunityDAO.getInstance().buscarContratantesOrcamento(IdsOrcamento);
		// Já retorna as Garantias dos Grupos.
		List<GrupoOrcamento__c> gruposOrcamento = OpportunityDAO.getInstance().buscarGruposOrcamentoPorOrcamento(IdsOrcamento);
		// Já retorna as Garantias dos Segurados.
		List<SeguradoOrcamento__c> seguradosOrcamento = OpportunityDAO.getInstance().buscarSeguradosOrcamentoPorOrcamento(IdsOrcamento);
        List<Attachment> anexosOrcamento = [SELECT Id FROM Attachment WHERE ParentId =: IdsOrcamento];
		
        try
        {
            if(batch == 1)
                System.debug('<<<< INICIO DO EXPURGO DOS ORCAMENTOS CONTRATADOS >>>>');
            else if(batch == 2)
                System.debug('<<<< INICIO DO EXPURGO DOS ORCAMENTOS NAO CONTRATADOS >>>>');

            System.debug('------------------------------------------------');
            System.debug('QUANTIDADE DE ORCAMENTOS: '+IdsOrcamento.size());  
            System.debug('------------------------------------------------');
            System.debug('QUANTIDADE DE GARANTIAS DE ORCAMENTO A SEREM EXCLUIDAS: '+garantiasOrcamento.size());
			delete garantiasOrcamento;
            System.debug('QUANTIDADE DE REMUNERACOES DE ORCAMENTO A SEREM EXCLUIDAS: '+remuneracoesOrcamento.size());
			delete remuneracoesOrcamento;
            System.debug('QUANTIDADE DE SEGURADOS DE ORCAMENTO A SEREM EXCLUIDOS: '+seguradosOrcamento.size());
			delete seguradosOrcamento;
            System.debug('QUANTIDADE DE GRUPOS DE ORCAMENTO A SEREM EXCLUIDOS: '+gruposOrcamento.size());
			delete gruposOrcamento;
			System.debug('QUANTIDADE DE CONTRATANTES DE ORCAMENTO A SEREM EXCLUIDOS: '+contratantesOrcamento.size());
            delete contratantesOrcamento;
            System.debug('QUANTIDADE DE ANEXOS DE ORCAMENTO A SEREM EXCLUIDOS: '+anexosOrcamento.size());
            delete anexosOrcamento;

            if(garantiasOrcamento.size() > 0)
            	Database.emptyRecycleBin(garantiasOrcamento);
            
            if(remuneracoesOrcamento.size() > 0)
            	Database.emptyRecycleBin(remuneracoesOrcamento);
            
            if(seguradosOrcamento.size() > 0)
            	Database.emptyRecycleBin(seguradosOrcamento);
            
            if(gruposOrcamento.size() > 0)
            	Database.emptyRecycleBin(gruposOrcamento);
            
            if(contratantesOrcamento.size() > 0)
            	Database.emptyRecycleBin(contratantesOrcamento);
            
            if(anexosOrcamento.size() > 0)
            	Database.emptyRecycleBin(anexosOrcamento);
		}
		catch(Exception e)
        {
			System.debug('Erro na exclusão do Expurgo de Orçamentos: ' + e.getMessage());
		}

        System.debug('------------------------------------------------');
        System.debug('<<<< REGISTROS RELACIONADOS AOS ORCAMENTOS APOS O EXPURGO >>>>');  
        System.debug('------------------------------------------------');
        List<GarantiaOrcamento__c> garantiasOrcamentoExcluidas = OpportunityDAO.getInstance().buscarGarantiasOrcamento(IdsOrcamento);
		System.debug('QUANTIDADE DE GARANTIAS DE ORCAMENTO APOS O EXPURGO: '+garantiasOrcamentoExcluidas.size());
        List<RemuneracaoOrcamento__c> remuneracoesOrcamentoExcluidas = RemuneracaoOrcamentoDAO.getInstance().buscarRemuneracoesOportunidade(IdsOrcamento);
		// Já retorna as Garantias dos Contratantes.
        System.debug('QUANTIDADE DE REMUNERACOES DE ORCAMENTO APOS O EXPURGO: '+remuneracoesOrcamentoExcluidas.size());
		List<ContratanteOrcamento__c> contratantesOrcamentoExcluidos = OpportunityDAO.getInstance().buscarContratantesOrcamento(IdsOrcamento);
		// Já retorna as Garantias dos Grupos.
		System.debug('QUANTIDADE DE CONTRATANTES DE ORCAMENTO APOS O EXPURGO: '+contratantesOrcamentoExcluidos.size());
        List<GrupoOrcamento__c> gruposOrcamentoExcluidos = OpportunityDAO.getInstance().buscarGruposOrcamentoPorOrcamento(IdsOrcamento);
		// Já retorna as Garantias dos Segurados.
        System.debug('QUANTIDADE DE GRUPOS DE ORCAMENTO APOS O EXPURGO: '+gruposOrcamentoExcluidos.size());
		List<SeguradoOrcamento__c> seguradosOrcamentoExcluidos = OpportunityDAO.getInstance().buscarSeguradosOrcamentoPorOrcamento(IdsOrcamento);
        System.debug('QUANTIDADE DE SEGURADOS DE ORCAMENTO APOS O EXPURGO: '+seguradosOrcamentoExcluidos.size());
        List<Attachment> anexosOrcamentoExcluidos = [SELECT Id FROM Attachment WHERE ParentId =: IdsOrcamento];
        System.debug('QUANTIDADE DE ANEXOS DE ORCAMENTO APOS O EXPURGO: '+anexosOrcamentoExcluidos.size());
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context){ }

     global void execute(SchedulableContext SC)
     {
        BatchExpurgoOrcamentos batchOrcamentos = new BatchExpurgoOrcamentos(1);
        Database.executeBatch(batchOrcamentos, 100);

        BatchExpurgoOrcamentos batchNaoContratados = new BatchExpurgoOrcamentos(2);
        Database.executeBatch(batchNaoContratados, 100);
    }
}
// PLV-4997 - FIM