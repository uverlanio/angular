//INICIO | PLV-2179-27- remover duplicidade
global class StageDadosCorretorBatch implements Database.Batchable<sObject> {
	
	global StageDadosCorretorBatch() { }
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('ESTOU NO RETORNO DA QUERY');
		Database.QueryLocator retorno = Database.getQueryLocator( [SELECT Name, CodigoSucursalDestinoCheque__c, NomeCorretor__c, SucursalVinculo__c, SucursalDestinoCheque__c, Tipo__c, CreatedDate FROM DadosCorretor__c ORDER BY CreatedDate DESC] );
		System.debug('QUERY retorno' + retorno);
		return retorno;
	}

   	global void execute(Database.BatchableContext BC, List<DadosCorretor__c> lista) {
		System.debug('ESTOU NO EXECUTE DO BATCH');

		List<StageDadosCorretor__c> stage = new List<StageDadosCorretor__c>();
		for(DadosCorretor__c item : lista)
		{
			StageDadosCorretor__c stageItem = new StageDadosCorretor__c();
			stageItem.Name = item.Name;
			stage.add(stageItem);
		}

		System.debug('itens '+ stage.size());

		insert stage;
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('ESTOU NO FINISH DO BATCH');
		Database.executeBatch(new DadosCorretorBatch());
	}
	
}
//FIM | PLV-2179-27- remover duplicidade