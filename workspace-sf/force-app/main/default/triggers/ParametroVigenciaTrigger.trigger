/**
 * Trigger ParametroVigencia__c
 * @author Fernando Barcellos @ 17/05/2018
 *
 **/
trigger ParametroVigenciaTrigger on ParametroVigencia__c (before insert, before update) {
    new ParametroVigenciaTriggerHandler().run();
}