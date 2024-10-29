trigger OfertaRemuneracaoProdutoTrigger on OfertaRemuneracaoProduto__c (before delete) {
    new OfertaRemuneracaoProdutoHandler().run();
}