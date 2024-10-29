/**
 * Expurgo de dados para o Proposta
 *  objeto: SeguradoProposta__c
 * caminho do objeto:
 *  > GrupoProposta__c
 *  > ContratanteProposta__c
 *  > Proposta__c
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoSeguradoProposta {
    
    public List<SeguradoProposta__c> getDadosExpurgo(Integer qt) { 
        List<SeguradoProposta__c> expList= new List<SeguradoProposta__c>();
        String query= 'SELECT Id '
            +'FROM SeguradoProposta__c '
            +'WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<SeguradoProposta__c> expList) {
        if (!Test.isRunningTest()) {
           delete (List<SeguradoProposta__c>)expList;
        }
    }
}