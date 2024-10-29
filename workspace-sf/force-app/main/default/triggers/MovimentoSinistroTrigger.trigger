trigger MovimentoSinistroTrigger on MovimentoSinistro__c (after insert) {
	new MovimentoSinistroTriggerHandler().run();
}