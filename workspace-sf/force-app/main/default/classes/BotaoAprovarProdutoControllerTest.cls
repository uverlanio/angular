/**
* Created by Alessndro Ponte on 08/12/2018.
*/

@IsTest
private class BotaoAprovarProdutoControllerTest {
    
    //PLV-4291 - Inicio - Ajuste de indentacao e criacao de novos metodos para cobrir o fluxo de aprovacao do produto
    @TestSetup
    static void setup(){
        TestDataFactory.gerarDadosSetup();
        TestDataFactory.gerarProdutoComercialAtivo(false);
    }
    
    @IsTest
    static void testProdutoJaAtivo() {
        Product2 produto = [SELECT Id FROM Product2 limit 1];
        Test.startTest();
        RetornoAcaoBotaoTO retorno = (RetornoAcaoBotaoTO) JSON.deserialize(BotaoAprovarProdutoController.aprovarProduto(produto.Id),RetornoAcaoBotaoTO.class);
        Test.stopTest();
        
        System.assert(retorno.mensagens.contains('Produto já esta Ativo!'));   
    }
    
    @isTest
    static void testProdutoColetivoAtivadoSucesso() {
        Product2 produto = [SELECT Id, Status__c, Segmento__c FROM Product2 limit 1]; //PLV-4291 - Fix - Inicio/Fim
        
        produto.Status__c = 'Em criação';
        produto.Segmento__c = 'Coletivo';
        update produto;
        
        Test.startTest();
        RetornoAcaoBotaoTO retorno = (RetornoAcaoBotaoTO) JSON.deserialize(BotaoAprovarProdutoController.aprovarProduto(produto.Id),RetornoAcaoBotaoTO.class);
        Test.stopTest();
        System.debug('retorno ------------------ ' + retorno);
    }
    
    @isTest
    static void testProdutoIndividualAtivadoSucesso() {
        Product2 produto = [SELECT Id, Status__c, Segmento__c FROM Product2 limit 1]; //PLV-4291 - Fix - Inicio/Fim
        
        produto.Status__c = 'Em criação';
        produto.Segmento__c = 'Individual';
        update produto;
        
        Test.startTest();
        RetornoAcaoBotaoTO retorno = (RetornoAcaoBotaoTO) JSON.deserialize(BotaoAprovarProdutoController.aprovarProduto(produto.Id),RetornoAcaoBotaoTO.class);
        Test.stopTest();
        System.debug('retorno ------------------ ' + retorno);
    }
    
    @isTest
    static void testProdutoStatusInvalido() {
        Product2 produto = [SELECT Id, Status__c, Segmento__c FROM Product2 limit 1]; //PLV-4291 - Fix - Inicio/Fim

        produto.Status__c = 'Inativo';
        produto.Segmento__c = 'Coletivo';
        update produto;
        
        Test.startTest();
        RetornoAcaoBotaoTO retorno = (RetornoAcaoBotaoTO) JSON.deserialize(BotaoAprovarProdutoController.aprovarProduto(produto.Id),RetornoAcaoBotaoTO.class);
        Test.stopTest();
        System.debug('retorno ------------------ ' + retorno);
        System.assert(retorno.mensagens.contains('Este produto não pode ser enviado para aprovação tendo como status: ' + produto.Status__c));
    }
    //PLV-4291 - Fim
}