trigger FaturaTrigger on Fatura__c (before update, before insert, after update) {

	new FaturaTriggerHandler().run();
}