trigger GarantiaSeguradoContratoTrigger on GarantiaSeguradoContrato__c (after insert) {
	new GarantiaSeguradoContratoTriggerHandler().run();
}