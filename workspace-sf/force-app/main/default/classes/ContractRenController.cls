public with sharing class ContractRenController {
    @AuraEnabled
    public static List<Contract> getContracts(String idCTR) {
        
        Set<Id> setIdCtr = new Set<Id>();
        Set<Id> setIdCtrN = new Set<Id>();
        List<Contract> retorno = new List<Contract>();
               
        List<Contract> contracts = 
                [SELECT 
                     Id, Name, Account.Id, Account.Name, StartDate, VigenciaFinal__c, 
                     PremioTotal__c, FormaPagamento__r.Codigo__c, 
                     FormaPagamento__r.Name, PrimeiroContratoRenovacao__c, CurrencyIsoCode 
                FROM Contract
                WHERE PrimeiroContratoRenovacao__c = :idCTR
                ORDER BY VigenciaFinal__c DESC];  
                
        retorno = contracts;        
               
        if(contracts.size() == 0){
            List<Contract> ctrFL = 
                [SELECT 
                     Id, PrimeiroContratoRenovacao__c 
                FROM Contract
                WHERE Id = :idCTR
                AND PrimeiroContratoRenovacao__c != null];    

                for(Contract ctrFLUnico : ctrFL){
                    setIdCtr.add(ctrFLUnico.PrimeiroContratoRenovacao__c);
                    setIdCtrN.add(ctrFLUnico.Id);
                }

                List<Contract> ctrIR = 
                [SELECT 
                    Id, Name, Account.Id, Account.Name, StartDate, VigenciaFinal__c, 
                    PremioTotal__c, FormaPagamento__r.Codigo__c, 
                    FormaPagamento__r.Name, PrimeiroContratoRenovacao__c, CurrencyIsoCode 
                FROM Contract
                WHERE (PrimeiroContratoRenovacao__c IN :setIdCtr OR Id IN :setIdCtr)
                AND Id NOT IN :setIdCtrN 
                ORDER BY VigenciaFinal__c DESC]; 
                
                retorno = ctrIR;
        } 
        return retorno;
    }

    @AuraEnabled
    public static List<Contract> getContractName(String idCTR) {               
        List<Contract> contract = 
                [SELECT Name
                FROM Contract
                WHERE Id = :idCTR];  
        
        return contract;
    }
}