// CRIAÇÃO EM FUNÇÃO DA HISTORIA PLV-3918
//PLV-4148 - INICIO
trigger RequisicaoPagamentoTrigger on Requisicao_de_Pagamento__c (after insert, after update, before update) { //PLV-4604 - INICIO/FIM
	new RequisicaoPagamentoTriggerHandler().run();
}
//PLV-4148 - FIM