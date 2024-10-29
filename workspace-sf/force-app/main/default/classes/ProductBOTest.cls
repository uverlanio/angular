//PLV-5230 - INICIO
/**
 * Testes ProductBO
 * @author Julio Duarte @ 10/10/2021
 *
 **/
@isTest
public class ProductBOTest {

   @testSetup
	private static void setup() {
        TestDataFactory.gerarDadosSetup();
 
		Product2 prodTec = TestDataFactory.gerarProdutoTecnico();
        prodTec.Status__c = 'Ativo';
        prodTec.Segmento__c ='Individual';
        update prodTec;

        Product2 prodCom = TestDataFactory.gerarProdutoComericial(prodTec);

	}

	@isTest
    private static void iniciarIntegracaoOpinTest() {

        
        Id recordTypeProdutoComercial = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
        map<Id, Product2> antigos = new Map<id, Product2>([SELECT Id, Status__c, RecordTypeId  FROM Product2 WHERE RecordTypeId = :recordTypeProdutoComercial LIMIT 1]);

        //Ajusta o setup dos dados de teste
        id key = (new List<Id>(antigos.keySet()))[0];
        map<Id, Product2> novos = antigos.deepClone();
        novos.get(key).Status__c = 'Ativo';
        novos.get(key).RecordTypeId = recordTypeProdutoComercial;


        Test.startTest();

        Boolean executouIntegracaoOpin = ProductBO.getInstance().iniciarIntegracaoOpin(antigos, novos);

        Test.stopTest();

        //System.assert(executouIntegracaoOpin == true);

    }
}
//PLV-5230 - FIM