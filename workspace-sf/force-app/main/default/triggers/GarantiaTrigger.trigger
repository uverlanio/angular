trigger GarantiaTrigger on Garantia__c (before insert, before update) {
    new GarantiaTriggerHandler().run();
}