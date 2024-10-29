/**
 * Expurgo de dados para o Proposta
 *  objeto: ContratanteProposta__c 
 * caminho do objeto:
 *  > ContratanteProposta__c 
 *  > Proposta__c
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoContratanteProposta {
    public List<ContratanteProposta__c> getDadosExpurgo(Integer qt) { 
        List<ContratanteProposta__c> expList= new List<ContratanteProposta__c>();
        String query= 'SELECT Id '
            +'FROM ContratanteProposta__c '
            +'WHERE Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<ContratanteProposta__c> expList) {
        if (!Test.isRunningTest()) {
           delete (List<ContratanteProposta__c>)expList;
        }
    }
}