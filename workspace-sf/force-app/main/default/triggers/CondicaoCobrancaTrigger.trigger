/**
 * Trigger CondicaoCobranca__c
 * @author Fernando Barcellos @ 11/01/2018
 *
 **/
trigger CondicaoCobrancaTrigger on CondicaoCobranca__c (before insert, before update) {
	new CondicaoCobrancaTriggerHandler().run();
}