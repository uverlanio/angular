//PLV-5230 - INICIO
@isTest
public class QueueableIntegracaoOpinTest {

    @testSetup
	private static void setup() {
        TestDataFactory.gerarDadosSetup();
 
		Product2 prodTec = TestDataFactory.gerarProdutoTecnico();
        prodTec.Status__c = 'Ativo';
        prodTec.Segmento__c ='Individual';
        update prodTec;

        Product2 prodCom = TestDataFactory.gerarProdutoComericial(prodTec);
        Product2 prodCom2 = prodCom.clone();
        
        insert prodCom2; 

	}

    @isTest
    private static void QueueIntegracaoOpinErro1_Test() {

        List<Product2> prods = [SELECT Id, Status__c, RecordTypeId  FROM Product2 LIMIT 1];
  
        String erromsg;
        try {
            Test.startTest();

            Id jobId = System.enqueueJob( new QueueableIntegracaoOpin(prods, 99) );

            Test.stopTest();
        } catch (Exception ex) {
            erromsg = ex.getMessage();
        }
 
        System.assert(erromsg.contains('OPIN inválida')) ;
        

    }
}
//PLV-5230 - FIM