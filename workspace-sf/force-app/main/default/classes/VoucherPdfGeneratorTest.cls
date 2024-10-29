//FNPVVEP-59 - INICIO
@isTest
public with sharing class VoucherPdfGeneratorTest {

    @isTest static void criarVoucherTest(){

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        Test.startTest();
            VoucherPdfGenerator.getInstance().criarVoucher(new List<Contract>{(Contract) records.get('Contrato')});
        Test.stopTest();

    }
}
//FNPVVEP-59 - FIM