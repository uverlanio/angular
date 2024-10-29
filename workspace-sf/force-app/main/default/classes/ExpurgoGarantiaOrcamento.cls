/**
 * Expurgo de dados para o Orçamento
 *  objeto: GarantiaOrcamento__c
 * caminho do objeto:
 * GarantiaOrcamento__c 
 *  > Opportunity
 * 
 * 09/02/2024
 */
public with sharing class ExpurgoGarantiaOrcamento {

    public List<GarantiaOrcamento__c> getDadosExpurgo(Integer qt) {
        List<GarantiaOrcamento__c> expList = new List<GarantiaOrcamento__c>();  
        String query= 'SELECT Id '//', Name, PremioTotal__c, IsDeleted'
            +'FROM GarantiaOrcamento__c '
            +'WHERE Orcamento__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.USER_MODE);
        System.debug(expList.size());
        return expList;
    }

    public void deleteDadosExpurgo(List<GarantiaOrcamento__c> expList) {
        if (!Test.isRunningTest()) {  
            delete (List<GarantiaOrcamento__c>)expList;
        }
    }
}