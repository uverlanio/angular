//INICIO | PLV-2233-27 
trigger NotaFiscalTrigger on NotaFiscal__c (after insert, after update) {
        new NotaFiscalTriggerHandler().run();
}
//FIM | PLV-2233-27