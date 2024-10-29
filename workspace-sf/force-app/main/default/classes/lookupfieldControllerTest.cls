//PLV-4043 INICIO
@isTest
public class lookupfieldControllerTest {
   	
    
    @TestSetup
    static void setup(){
        TestDataFactory.gerarDadosSetup();        
    }

    static testMethod void testLookupField() {
        
        Account contaTeste = TestDataFactory.gerarConta();

        InformacaoBancaria__c InformacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaTeste);
		List<String> idConta = new List<String>();
        idConta.add(contaTeste.Id);
        List<string> returnFields = new List<string> {'Name','Banco__c'};
        InformacaoBancaria__c a = [SELECT Id FROM InformacaoBancaria__c LIMIT 1];
		lookupfieldController.getObjectDetails('InformacaoBancaria__c');
        lookupfieldController.GetRecentRecords('InformacaoBancaria__c', returnFields, 5,idConta);
        lookupfieldController.SearchRecords('InformacaoBancaria__c', returnFields, returnFields, '', 'Name', 'ASC', 5,idConta);
        lookupfieldController.GetRecord('InformacaoBancaria__c', returnFields, a.Id);
    }
}
//PLV-4043 FIM