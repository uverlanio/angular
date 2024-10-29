@isTest
private class AntecipacaoComissaoTriggerHandlerTest {
    @TestSetup
    static void setup(){
        ContadorCodigo__c contCodigoTec3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico3 = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico3.Status__c = 'Ativo';
        update produtoTecnico3;
        Product2 produtoComercial3 = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico3).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoProduto__c rem = (RemuneracaoProduto__c) new RemuneracaoProdutoFactory(tipoRemuneracao,produtoComercial3).createRecord();

        AntecipacaoComissao__c antecipacao = new AntecipacaoComissao__c();
        antecipacao.RemuneracaoProduto__c = rem.Id;
        antecipacao.LimiteMinimo__c = 10;
        antecipacao.LimiteMaximo__c = 20;
        antecipacao.TipoEvento__c = 'Seguro Novo';

        insert antecipacao;
    }

    @isTest
    public static void testAfterInsert() {
        //List<AntecipacaoComissao__c> antecipacoes = new List<AntecipacaoComissao__c>();
        
        //AntecipacaoComissao__c antecipacao = new AntecipacaoComissao__c();
        //antecipacoes.add(antecipacao);
        
        Test.startTest();
        //AntecipacaoComissaoTriggerHandler handler = new AntecipacaoComissaoTriggerHandler();
        //handler.afterInsert();
        RemuneracaoProduto__c remprod = [SELECT id FROM RemuneracaoProduto__c LIMIT 1];
        AntecipacaoComissao__c antecipacao1 = new AntecipacaoComissao__c();
        antecipacao1.RemuneracaoProduto__c = remprod.Id;
        antecipacao1.LimiteMinimo__c = 10;
        antecipacao1.LimiteMaximo__c = 20;
        antecipacao1.TipoEvento__c = 'Endosso';

        insert antecipacao1;
        Test.stopTest();
        
    }
    
    @isTest
    public static void testAfterUpdate() {
        //List<AntecipacaoComissao__c> antecipacoes = new List<AntecipacaoComissao__c>();
        
        //AntecipacaoComissao__c antecipacao = new AntecipacaoComissao__c();
        //antecipacoes.add(antecipacao);
        
        Test.startTest();
        //AntecipacaoComissaoTriggerHandler handler = new AntecipacaoComissaoTriggerHandler();
        //handler.afterUpdate();
        AntecipacaoComissao__c antecip = [SELECT id, LimiteMaximo__c FROM AntecipacaoComissao__c WHERE TipoEvento__c = 'Seguro Novo'];
        antecip.LimiteMaximo__c = 35;
        update antecip;
        Test.stopTest();
    }
}