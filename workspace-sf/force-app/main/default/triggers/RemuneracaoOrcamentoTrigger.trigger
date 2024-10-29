trigger RemuneracaoOrcamentoTrigger on RemuneracaoOrcamento__c (before insert, before update, after insert, after update) {
	new RemuneracaoOrcamentoTriggerHandler().run();
}