@isTest
private class FiliaisParceiroTest {

    @testSetup
    private static void setup() {

        TestDataFactory.gerarDadosSetup();
        TestDataFactory.gerarParceiroCompletoAtivo(true);
    }

    @isTest
    static void testarVerificacaoDuplicidadeBulk() {
        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];

        List<FilialParceiro__c> listFilial = new List<FilialParceiro__c>{
                new FilialParceiro__c(CodigoFilialParceiro__c = '01', Name = 'Teste', Parceiro__c = parceiro.Id),
                new FilialParceiro__c(CodigoFilialParceiro__c = '01', Name = 'Teste2',  Parceiro__c = parceiro.Id)
        };

        try {
            Test.startTest();
            insert listFilial;
            Test.stopTest();
        }
        catch (Exception e){
            System.assert(e.getMessage().contains('Código da filial já foi cadastrado.'));
        }

    }

    @isTest
    static void testarVerificacaoDuplicidade() {
        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];

        List<FilialParceiro__c> listFilial = new List<FilialParceiro__c>{
                new FilialParceiro__c(CodigoFilialParceiro__c = '01', Name = 'Teste', Parceiro__c = parceiro.Id),
                new FilialParceiro__c(CodigoFilialParceiro__c = '02', Name = 'Teste2',  Parceiro__c = parceiro.Id)
        };
        insert listFilial;

        FilialParceiro__c novaFilial = new FilialParceiro__c(CodigoFilialParceiro__c = '02', Name = 'Teste2',  Parceiro__c = parceiro.Id);

        try {
            Test.startTest();
            insert novaFilial;
            Test.stopTest();
        }
        catch (Exception e){
            System.assert(e.getMessage().contains('Código da filial já foi cadastrado.'));
        }

    }

}