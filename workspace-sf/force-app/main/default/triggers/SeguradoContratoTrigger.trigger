trigger SeguradoContratoTrigger on SeguradoContrato__c (after insert) {
	new SeguradoContratoTriggerHandler().run();
}