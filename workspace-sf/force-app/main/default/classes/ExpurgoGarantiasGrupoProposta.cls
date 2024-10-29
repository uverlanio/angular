/**
 * Expurgo de dados para o Proposta
 *  objeto: GarantiasGrupoProposta__c 
 * caminho do objeto:
 *  GarantiasGrupoProposta__c 
 *  > GrupoProposta__c
 *  > ContratanteProposta__c
 *  > Proposta__c
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoGarantiasGrupoProposta {
    
    public List<GarantiasGrupoProposta__c> getDadosExpurgo(Integer qt) { 
        List<GarantiasGrupoProposta__c> expList= new List<GarantiasGrupoProposta__c>();
        String query= 'SELECT Id '
            +'FROM GarantiasGrupoProposta__c  '
            +'WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<GarantiasGrupoProposta__c> expList) {
        if (!Test.isRunningTest()) {
           delete (List<GarantiasGrupoProposta__c>)expList;
        }
    }
}