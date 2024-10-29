//PLV-4305 Complemento - INICIO - Ciacao de trigger para validacoes
trigger AntecipacaoComissaoTrigger on AntecipacaoComissao__c (after insert, after update) {
    new AntecipacaoComissaoTriggerHandler().run();
}
//PLV-4305 Complemento - FIM