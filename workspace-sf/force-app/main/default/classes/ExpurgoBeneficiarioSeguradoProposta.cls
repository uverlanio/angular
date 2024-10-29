/**
 * Expurgo de dados para o Proposta
 *  objeto: BeneficiarioSeguradoProposta__c 
 * caminho do objeto:
 *  BeneficiarioSeguradoProposta__c 
 *  > SeguradoProposta__c
 *  > GrupoProposta__c
 *  > ContratanteProposta__c
 *  > Proposta__c
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoBeneficiarioSeguradoProposta {
    
    public List<BeneficiarioSeguradoProposta__c> getDadosExpurgo(Integer qt) { 
        List<BeneficiarioSeguradoProposta__c> expList= new List<BeneficiarioSeguradoProposta__c>();
        String query= 'SELECT Id '
            +'FROM BeneficiarioSeguradoProposta__c '
            +'WHERE SeguradoProposta__r.GrupoProposta__r.ContratanteProposta__r.Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<BeneficiarioSeguradoProposta__c> expList) {
        if (!Test.isRunningTest()) {
           delete (List<BeneficiarioSeguradoProposta__c>)expList;
        }
    }
}