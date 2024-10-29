// PLV-2366 - INICIO
global class SeguroBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
	
	public static ContractBO bo = ContractBO.getInstance();
	global SeguroBatch() {}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(
			[
				SELECT 
					Id, 
					Payload__c 
				FROM 
					Contract 
				WHERE 
					Status 		= 'Emitido' 
				and Endosso__c 	= '0'
			]
		);
	}

   	global void execute(Database.BatchableContext BC, List<Contract> listStage) {
		System.debug('--> EXECUTE DO BATCH');
    	bo.atualizarPayloadSeguro(listStage);
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('--> FINISH DO BATCH');
	}
	
}
// PLV-2366 - FIM