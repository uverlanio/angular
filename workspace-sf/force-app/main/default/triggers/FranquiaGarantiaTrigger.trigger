//PLV - 4282 INICIO - Adicionado after insert 
trigger FranquiaGarantiaTrigger on FranquiaGarantia__c (before update, before delete, after insert) {
	new FranquiaGarantiaTriggerHandler().run();
}
//PLV - 4282 FIM - Adicionado after insert