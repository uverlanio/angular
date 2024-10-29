/**
 * Trigger CanalCampanha__c
 * @author Fernando Barcellos @ 18/01/2018
 *
 **/
trigger CanalCampanhaTrigger on CanalCampanha__c (before insert, before update) {
	new CanalCampanhaTriggerHandler().run();
}