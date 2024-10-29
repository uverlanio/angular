//PLV-4305 Complemento - Classe de teste para testar a regra do objeto
@isTest
public class AntecipacaoComissaoTest {
    
    @isTest
    static void testValidaAntecipacao(){
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

        AntecipacaoComissao__c antecipacao1 = new AntecipacaoComissao__c();
        antecipacao1.RemuneracaoProduto__c = rem.Id;
        antecipacao1.LimiteMinimo__c = 10;
        antecipacao1.LimiteMaximo__c = 20;
        antecipacao1.TipoEvento__c = 'Endosso';

        insert antecipacao1;

        antecipacao1.LimiteMaximo__c = 50;

        update antecipacao1;
    }
}
//PLV-4305 Complemento - FIM