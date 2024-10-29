trigger QuoteTrigger on Quote (before insert, before update, after update, after insert) {
    new QuoteTriggerHandler().run();
}