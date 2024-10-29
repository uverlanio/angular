//ZSVEP-76-INICIO
@isTest
public class AtualizarSistemasExternosBatchTest {
    
    @testSetup
    static void setup() {

        Account acc = new Account(
            Name = 'Test Account',
            Cnpj__c = '99.605.927/0001-12'   
        );
        insert acc;

        RamoSeguro__c ramo = new RamoSeguro__c(
            Codigo__c = '993',
            CodigoEmpresa__c = '35'
        );
        insert ramo;

        Contract cont = new Contract(
            AccountId = acc.Id,
            Status = 'Em elaboração',
            Parceiro__c = 'Test Parceiro',
            Empresa__c = '12',
            Sucursal__c = 'Abc',
            RamoSeguro__c = ramo.Id,
            Name = 'Test Contract',
            Endosso__c = 'Test Endosso',
            IdContrato__c = 'Test IdContrato',
            IdContratoParceiro__c = 'Test IdContratoParceiro',
            CodigoRamo__c = 'Test CodigoRamo',
            NumeroApolice__c = 'Test NumeroApolice',
            Tipo__c = 'Novo',
            StartDate = Date.today(),
            VigenciaFinal__c = Date.today().addYears(1),
            DataEmissao__c = Date.today(),
            MeioComercializacao__c = 'SFC'
        );
        insert cont;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        Integer contador = 0;
        AtualizarSistemasExternosBatch batch = new AtualizarSistemasExternosBatch(contador);
        Database.executeBatch(batch, 10);
        Test.stopTest();
    }

    @isTest
    static void testFinishMethod() {
        Test.startTest();
        Integer contador = 1;
        AtualizarSistemasExternosBatch batch = new AtualizarSistemasExternosBatch(contador);
        batch.finish(null);
        Test.stopTest();
    }
}
//ZSVEP-76-FIM