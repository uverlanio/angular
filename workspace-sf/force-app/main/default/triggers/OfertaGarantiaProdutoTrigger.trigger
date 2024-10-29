//PLV-3434 - INICIO
//PLV-4283 - INICIO - adicionado after Update
trigger OfertaGarantiaProdutoTrigger on OfertaGarantiaProduto__c (before delete, before insert, before update, after update) {
//PLV-3434 - FIM
//PLV-4283 - FIM - adicionado after Update
    new OfertaGarantiaProdutoHandler().run();
}