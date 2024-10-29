//INICIO | PLV-2179-27- remover duplicidade
global class DadosCorretorBatch implements Database.Batchable<sObject> 
{
	public static DadosCorretorBO bo = DadosCorretorBO.getInstance();
	global DadosCorretorBatch() { }
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('ESTOU NO RETORNO DA QUERY');
		Database.QueryLocator retorno = Database.getQueryLocator( 
			[
				SELECT 
					Name
				FROM 
					StageDadosCorretor__c 
				ORDER BY 
					CreatedDate DESC

				
			]);
		System.debug('QUERY retorno' + retorno);
		return retorno;
	}

   	global void execute(Database.BatchableContext BC, List<StageDadosCorretor__c> listStage) {
		System.debug('ESTOU NO EXECUTE DO BATCH');
    	bo.removeRegistrosDuplicados(listStage);
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('ESTOU NO FINISH DO BATCH');
	}
	
}
//FIM | PLV-2179-27- remover duplicidade