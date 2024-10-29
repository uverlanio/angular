@isTest
private class AntecipacaoComissaoBOTest {

    @isTest
    static void testValidaAntecipacoes() {
       

        Test.startTest();
        List<AntecipacaoComissao__c> antecipacoes = new List<AntecipacaoComissao__c>();
        
        RemuneracaoProduto__c remuneracaoProduto = new RemuneracaoProduto__c();
        insert remuneracaoProduto;
        
        AntecipacaoComissao__c antecipacao1 = new AntecipacaoComissao__c();
        antecipacao1.RemuneracaoProduto__c = remuneracaoProduto.Id;
        antecipacao1.TipoEvento__c = 'Evento1';
        antecipacoes.add(antecipacao1);
        
        AntecipacaoComissao__c antecipacao2 = new AntecipacaoComissao__c();
        antecipacao2.RemuneracaoProduto__c = remuneracaoProduto.Id;
        antecipacao2.TipoEvento__c = 'Evento1';
        antecipacoes.add(antecipacao2);
        
        
        AntecipacaoComissaoBO.validaAntecipacoes(antecipacoes);
        Test.stopTest();

    }
}