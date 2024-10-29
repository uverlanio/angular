//PLV-4449-VI - INICIO
trigger CartaoCreditoTrigger on CartaoCredito__c (before insert, before update, after insert, after update) {
    new CartaoCreditoTriggerHandler().run();
}
//PLV-4449-VI - FIM