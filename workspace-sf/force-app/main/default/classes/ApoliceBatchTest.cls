/********************************************************************************************************************
* Classe de teste para  ApoliceBatch 
* @author Odemir Olivatti Sys4b
* @date 02/10/2021
*********************************************************************************************************************/



@isTest
class ApoliceBatchTest {
    
   
    @TestSetup
    static void setup(){
        TestDataFactory.gerarDadosSetup();
        //PLV-3744 - INICIO
        //TestDataFactory.Token();
        //PLV-3744 - FIM 
	    // PLV-2312-28 INICIO
        TestDataFactory.gerarContrato(true);
       
        // PLV-2312-28 FIM
       	// Codigo removido por conta da historia PLV-3460 Fix 5
    }



    @IsTest
    static void TestOne(){
        Test.startTest();
       
      
        Contract c =[ SELECT Id,Produto__r.segmento__c, Name FROM Contract limit 1];
        
        c.Status='Emitido';
        c.ApolicePdfDownloadUrl__c=null;
        update c;
        c.produto__r.segmento__c = 'Viagem';
         update c.produto__r;
        List<Contract> contracts=[SELECT Id, Name FROM Contract WHERE Segmento__c = 'Viagem' AND ApolicePdfDownloadUrl__c = NULL AND Status='Emitido' ];
        System.assert(contracts.size() > 0,'Nao encontrado contrados sem apolice');
        String ret= System.enqueueJob(new ApoliceBatch());
        Test.stopTest();
        System.assert(ret != null,'Erro iniciando batch ');
    }
}