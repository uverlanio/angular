trigger RemuneracaoMultinivelTrigger on RemuneracaoMultinivel__c (before insert, before update) {
	new RemuneracaoMultinivelTriggerHandler().run();
}