trigger AccountTrigger on Account (after update, before insert, before update, before delete) { //PLV-3748 - INICIO/FIM - Inclusao do before delete
    new AccountTriggerHandler().run();
}