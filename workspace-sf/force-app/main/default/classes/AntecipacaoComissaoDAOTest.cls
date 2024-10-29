//ZSVEP-76-INICIO
@isTest
public class AntecipacaoComissaoDAOTest {

    @testSetup
    static void setup() {
        Product2 product = new Product2(
            Name = 'Test Product',
            ProductCode = 'TEST_CODE',
            Status__c = 'Ativo'
        );

        RemuneracaoProduto__c remuneracaoProduto = new RemuneracaoProduto__c(
            Produto__c = product.Id
        );
        insert remuneracaoProduto;

        AntecipacaoComissao__c antecipacaoComissao = new AntecipacaoComissao__c(
            LimiteMaximo__c = 50,
            LimiteMinimo__c = 40,
            TipoEvento__c = 'Seguro Novo',
            RemuneracaoProduto__c = remuneracaoProduto.Id
        );
        insert antecipacaoComissao;
    }

    @isTest
    static void testBuscarAntecipacaoComissaoPorProdutCode() {
        Set<String> codigosProduto = new Set<String>{'2345678'};
        List<AntecipacaoComissao__c> result = AntecipacaoComissaoDAO.getInstance().buscarAntecipacaoComissaoPorProdutCode(codigosProduto);
    }
}
//ZSVEP-76-FIM