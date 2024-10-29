trigger GarantiaPropostaTrigger on GarantiaProposta__c (before insert, before update) {
	new GarantiaPropostaTriggerHandler().run();
}