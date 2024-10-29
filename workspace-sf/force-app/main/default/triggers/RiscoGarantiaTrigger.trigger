trigger RiscoGarantiaTrigger on RiscoGarantia__c (after insert, after delete, before update, before delete) {
	new RiscoGarantiaTriggerHandler().run();
}