trigger Product2Trigger on Product2 (after insert, after update, before insert, before update, before delete) {
    //PLV-3028 - Início - Remoção publicação no EventBus
    new ProductTriggerHandler().run();
    //PLV-3028 - Fim - Remoção publicação no EventBus
}