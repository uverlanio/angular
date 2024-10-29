/**
 * Trigger CriticaOrcamento__c
 *
 **/
trigger CriticaOrcamentoTrigger on CriticaOrcamento__c (before Insert, after insert, after update)
{
	new CriticaOrcamentoTriggerHandler().run();
}