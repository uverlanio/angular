/**
 * Trigger RemuneracaoCanal__c
 * @author Alex Gomes @ 30/01/2018
 *
 **/
trigger RemuneracaoCanalTrigger on RemuneracaoCanal__c (before insert, before update, before delete) {
	new RemuneracaoCanalTriggerHandler().run();
}