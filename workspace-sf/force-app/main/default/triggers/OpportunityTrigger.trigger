trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update) {
    //PLV-3028 - Início - Remoção publicação no EventBus
    new OpportunityTriggerHandler().run();
    //PLV-3028 - Fim - Remoção publicação no EventBus
}