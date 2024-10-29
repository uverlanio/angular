trigger ParametroRenovacaoTrigger on ParametroRenovacao__c (before insert, before update, before delete, after insert) {
	new ParametroRenovacaoTriggerHandler().run();
}