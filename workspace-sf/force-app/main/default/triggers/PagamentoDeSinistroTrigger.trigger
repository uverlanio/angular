// história: PLV-4065
// descrição da história: aviso de liquidação de sinistros
// Data de Criação: 31/07/2020
// Desenvolvedor: Tiago Welter - Sys4b
// PLV-4335 - Inicio
trigger PagamentoDeSinistroTrigger on Pagamento_de_Sinistro__c (after insert, after update, before update, before insert) {
    new PagamentoDeSinistroTriggerHandler().run();
}
// PLV-4335 - Fim