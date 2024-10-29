trigger BeneficiarioGarantiaTrigger on BeneficiarioGarantia__c (after insert, after update, before delete, before update, before insert) {
    //PLV-3028 - Início - Remoção publicação no EventBus
    new BeneficiarioGarantiaTriggerHandler().run();
    //PLV-3028 - Fim - Remoção publicação no EventBus
}