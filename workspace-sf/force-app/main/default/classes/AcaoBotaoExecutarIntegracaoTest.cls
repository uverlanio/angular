@isTest
private class AcaoBotaoExecutarIntegracaoTest {

    @isTest
    public static void testExecutarIntegracao() {

        Integracao__c integracao = new Integracao__c();
        integracao.DeveloperName__c = 'Teste';
        insert integracao;
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(new List<Integracao__c>{integracao});
        
        AcaoBotaoExecutarIntegracao controller = new AcaoBotaoExecutarIntegracao(stdSetController);
        
        Map<String, Object> result = AcaoBotaoExecutarIntegracao.executarIntegracao(integracao.Id);
    }
}