trigger GarantiaRelacionadaTrigger on GarantiaRelacionada__c (before insert, before update, before delete, after insert, after update) {
    new GarantiaRelacionadaTriggerHandler().run();
}