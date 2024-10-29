/**
 * Trigger GarantiaCampanha__c
 * @author Fernando Barcellos @ 19/02/2018
 *
 **/
trigger GarantiaCampanhaTrigger on GarantiaCampanha__c (before insert, before update) {
	new GarantiaCampanhaTriggerHandler().run();
}