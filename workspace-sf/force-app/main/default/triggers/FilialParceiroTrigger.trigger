trigger FilialParceiroTrigger on FilialParceiro__c (before insert) {
    new FilialParceiroTriggerHandler().run();
}