/**
 * Expurgo de dados para o Orçamento
 *  objeto: GarantiaContratanteOrcamento__c
 * caminho do objeto:
 *  GarantiaContratanteOrcamento__c
 *  > ContratanteOrcamento__c
 *  > Opportunity
 * 
 * 20/02/2024
 */
public with sharing class ExpurgoGarantiasContratanteOrcamento { 

    public List<GarantiaContratanteOrcamento__c> getDadosExpurgo(Integer qt) {
        List<GarantiaContratanteOrcamento__c> expList = new List<GarantiaContratanteOrcamento__c>(); 

        String query= 'SELECT Id '//', Name, PremioTotal__c, IsDeleted'
            +'FROM GarantiaContratanteOrcamento__c '
            +'WHERE ContratanteOrcamento__r.Orcamento__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<GarantiaContratanteOrcamento__c> expList) {
        if (!Test.isRunningTest()) {
            delete (List<GarantiaContratanteOrcamento__c>)expList;
        }
    }
}