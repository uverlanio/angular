trigger CasoTrigger on Case (after insert, after update, before update, before insert) {
	new CasoTriggerHandler().run();
}