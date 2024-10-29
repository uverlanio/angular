trigger OfertaTrigger on Oferta__c (before update, after insert) {
    new OfertaTriggerHandler().run();
}