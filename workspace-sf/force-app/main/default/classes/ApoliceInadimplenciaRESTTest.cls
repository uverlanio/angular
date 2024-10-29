//PLV-4556 FIX 1 - INÍCIO
@isTest
public with sharing class ApoliceInadimplenciaRESTTest {
    @isTest
    static void cancelamento() {
        TestDataFactory.gerarDadosSetup();
        TestDataFactory.gerarContrato(true);
        
        List<Contract> contratos = [SELECT Id, NumeroApolice__c,StatusHeroku__c,  Name FROM Contract];
        if (contratos.size() > 0) {
            //PLV-5708 FIX-03 INICIO 
            for(Contract contrato : contratos){
                contrato.VigenciaFinal__c = System.today();
                contrato.StartDate = System.today();
                contrato.origem__c = '18';
                contrato.NumeroProposta__c = '00006767';
            }
            update contratos;
            //PLV-5708 FIX-03 FIM 
            RestRequest request = new RestRequest();
            
            request.requestURI = '/services/apexrest/apoliceInadimplencia';
            request.requestBody = Blob.valueOf('{"acao":"cancelar","itens":[{"id":"1","sucesso":true,"contrato":"'+ 
                                               contratos[0].NumeroApolice__c +'","apolice":"'+ contratos[0].NumeroApolice__c +
                                               '","input":"' + contratos[0].Name + '"}]}');
            request.httpMethod = 'POST';
            RestContext.request = request;
            
            ApoliceInadimplenciaREST.cancelarApolice();
            contratos = [SELECT Id, NumeroApolice__c,StatusHeroku__c,  Name FROM Contract];
            System.assert(contratos[0].StatusHeroku__c == 'Aguardando Processamento');
           
        }
    }
}
//PLV-4556 FIX 1 - FIM