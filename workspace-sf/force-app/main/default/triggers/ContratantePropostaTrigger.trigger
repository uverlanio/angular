trigger ContratantePropostaTrigger on ContratanteProposta__c  (before insert, before update, after insert, after update) {
    new ContratantePropostaTriggerHandler().run();
}