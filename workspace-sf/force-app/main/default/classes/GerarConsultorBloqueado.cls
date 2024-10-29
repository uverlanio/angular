public with sharing class GerarConsultorBloqueado {
    
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getListaProdutos(){
        String RecordType = 'Produto comercial';
        String Status = 'Ativo';
        string query = 'Select Name, ProductCode from Product2 where status__c =: Status and RecordType.Name =: RecordType order by Name ASC';
        list<Product2> lstObject = Database.query(query);
        system.debug('lstObject==> '+lstObject);
        
        return lstObject;
    }

  
   @AuraEnabled(cacheable=true)
    public static  string getDadosCorretor(String recordId, string bloqueado) {
         String status;
       
        try {
            // Query for the contact, which has been associated with an account.
            DadosCorretor__c Dados = [SELECT  Id, Produtos_Bloqueados__c  FROM DadosCorretor__c  WHERE Id =:recordId LIMIT 1];
        
            // Update 
            Dados.Produtos_Bloqueados__c = 'NP';
           update Dados;
           Status = 'Sucesso';
         } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            Status = 'Erro';
         }
       
          return Status;
    }

}