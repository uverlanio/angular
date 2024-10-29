trigger CarenciaGarantiaTrigger on CarenciaGarantia__c (before update, before delete) {
	new CarenciaGarantiaTriggerHandler().run();
}