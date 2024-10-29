/**
 * Expurgo de dados para o Proposta
 *  objeto: GarantiaContratanteProposta__c 
 * caminho do objeto:
 *  > GarantiaContratanteProposta__c 
 *  > ContratanteProposta__c
 *  > Proposta__c
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoGarantiaContratanteProposta {
   
    public List<GarantiaContratanteProposta__c> getDadosExpurgo(Integer qt) { 
        List<GarantiaContratanteProposta__c> expList= new List<GarantiaContratanteProposta__c>();
        String query= 'SELECT Id '
            +'FROM GarantiaContratanteProposta__c '
            +'WHERE ContratanteProposta__r.Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<GarantiaContratanteProposta__c> expList) {
        if (!Test.isRunningTest()) {
           delete (List<GarantiaContratanteProposta__c>)expList;
        }
    }
}