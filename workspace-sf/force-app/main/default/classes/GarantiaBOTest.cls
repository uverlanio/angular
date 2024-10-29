// POR062-1 - INICIO
@isTest
private class GarantiaBOTest {
   
    @isTest static void testarMapearGarantiaPorCobertura(){

        Test.startTest();

        List<Garantia__c> garantias = new List<Garantia__c>();
        Garantia__c garantia = new Garantia__c(
            Id = 'a0nL0000008CQuDIAW',
            Sigla__c = 'AFF'
        );

        garantias.add(garantia);

        GarantiaBO.getInstance().mapearGarantiaPorCobertura(garantias);

        Test.stopTest();
    }
    
}
// POR062-1 - FIM