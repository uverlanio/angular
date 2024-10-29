/**
 * Trigger FormaPagamentoCampanha__c
 * @author Fernando Barcellos @ 19/02/2018
 *
 **/
trigger FormaPagamentoCampanhaTrigger on FormaPagamentoCampanha__c (before insert, before update) {
	new FormaPagamentoCampanhaTriggerHandler().run();
}