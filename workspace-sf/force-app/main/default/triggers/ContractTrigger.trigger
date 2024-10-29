trigger ContractTrigger on Contract (after insert, after update, before delete, before insert, before update) {
    //PLV-3028 - Início - Remoção publicação no EventBus
    new ContractTriggerHandler().run();
    //PLV-3028 - Fim - Remoção publicação no EventBus
}