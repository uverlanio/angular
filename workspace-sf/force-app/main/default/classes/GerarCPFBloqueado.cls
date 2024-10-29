public with sharing class GerarCPFBloqueado {
    
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getListaProdutos(){
        String RecordType = 'Produto comercial';
        String Status = 'Ativo';
        string query = 'Select Name, ProductCode from Product2 where status__c =: Status and RecordType.Name =: RecordType order by Name ASC';
        list<Product2> lstObject = Database.query(query);
        system.debug('lstObject==> '+lstObject);
        
        return lstObject;
    }

  
 

}