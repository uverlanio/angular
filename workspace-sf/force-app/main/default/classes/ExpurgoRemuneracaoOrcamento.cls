/**
 * Expurgo de dados para o Orçamento
 *  objeto: RemuneracaoOrcamento__c
 * caminho do objeto:
 *  RemuneracaoOrcamento__c
 *  > Opportunity
 * 
 * 20/02/2024
 */
public with sharing class ExpurgoRemuneracaoOrcamento { 

    public List<RemuneracaoOrcamento__c> getDadosExpurgo(Integer qt) {
        List<RemuneracaoOrcamento__c> expList = new List<RemuneracaoOrcamento__c>(); 

        String query= 'SELECT Id '//', Name, IsDeleted'
        +'FROM RemuneracaoOrcamento__c '
        +'WHERE Oportunidade__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList = Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<RemuneracaoOrcamento__c> expList) {
        if (!Test.isRunningTest()) {
            delete (List<RemuneracaoOrcamento__c>)expList;
        }
    }
}