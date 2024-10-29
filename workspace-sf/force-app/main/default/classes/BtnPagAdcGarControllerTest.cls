// PLV-4163 criação da classe
@IsTest
private class BtnPagAdcGarControllerTest {
    @IsTest
    public static void test01() {
        
        PagamentoGarantia__c garanSin = (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord();

        Test.startTest();
        BtnPagAdcGarController.buscarInformacoes(garanSin.Id);
        BtnPagAdcGarController.criarGarantia(garanSin.Id,'1',150);
        Test.stopTest();
    }
}