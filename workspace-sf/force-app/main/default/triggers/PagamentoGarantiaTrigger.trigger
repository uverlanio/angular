trigger PagamentoGarantiaTrigger on PagamentoGarantia__c (before update, before insert, before delete, after insert, after update) {
    //PLV-3028 - Início - Remoção publicação no EventBus
    new PagamentoGarantiaTriggerHandler().run();
    //PLV-3028 - Fim - Remoção publicação no EventBus
}