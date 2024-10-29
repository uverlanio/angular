/**
 * EnderecoTrigger
 * @author Fernando Barcellos @ 19/12/2017
 *
 **/

	// PLV-3995 - INICIO
trigger EnderecoTrigger on Endereco__c (after insert, after update, before insert, before update) {
	new EnderecoTriggerHandler().run();
	// PLV-3995 - FIM
}