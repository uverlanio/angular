@isTest
private class GerarConsultorBloqueadoTest {
    static testMethod void myUnitTest() {
         test.startTest();	           
        DadosCorretor__c corretor = new DadosCorretor__c();
        corretor.Name = 'Novo corretor SA';
        corretor.Tipo__c = 'Produção';
        corretor.Produtos_Bloqueados__c = 'NP';  
        corretor.SusepOficialCorretor__c = 'BRB01P';
        insert corretor;
    
        String ProdutosBloqueados = 'NP';  
        GerarConsultorBloqueado.getDadosCorretor(corretor.id, ProdutosBloqueados);
        GerarConsultorBloqueado.getListaProdutos();
        Test.stopTest(); 
    }
}