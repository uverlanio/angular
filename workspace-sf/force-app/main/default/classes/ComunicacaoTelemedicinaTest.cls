//FNPVVEP-114 INICIO
@isTest
public class ComunicacaoTelemedicinaTest {

    @testSetup
    static void setupData() {
        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        Contract contract = [SELECT Id  FROM Contract LIMIT 1];

        Garantia__c garantia = new Garantia__c(
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Assistência',
            Sigla__c = 'Telemed',
            Name = 'Telemedicina'
            
        );
        insert garantia;

        GarantiaContrato__c garantiaContrato = new GarantiaContrato__c(
                Contrato__c = contract.Id,
                Garantia__c = garantia.Id,
                TipoCapital__c = 'Capital uniforme',
                VersaoTitulo__c = '1'
        );
        insert garantiaContrato;
    }

    @IsTest
    public static void testComunicacaoTelemedicina() {

        Contract contract = [SELECT Id, Name, StartDate, VigenciaFinal__c, Segmento__c, Tipo__c, DataEmissao__c , Account.Name, Account.Sexo__c, Account.PersonMobilePhone, Account.Cpf__c, Account.PersonBirthdate, Account.PersonEmail, Account.PersonHomePhone  FROM Contract LIMIT 1];

        Test.startTest();
        ComunicacaoTelemedicina.enviarComunicacaoTelemed(contract.Id);
        Test.stopTest();
    }
}
//FNPVVEP-114 FIM