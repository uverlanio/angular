trigger DependenteGarantiaTrigger on DependenteGarantia__c (before insert, before update, before delete, after insert) {
	new DependenteGarantiaTriggerHandler().run();
}