/**
 * Expurgo de dados para o Orçamento
 *  objeto: GrupoOrcamento__c
 * caminho do objeto:
 *  GrupoOrcamento__c
 *  > ContratanteOrcamento__c
 *  > Opportunity
 * 
 * 20/02/2024
 */
public with sharing class ExpurgoGrupoOrcamento { 

    public List<GrupoOrcamento__c> getDadosExpurgo(Integer qt) {
        List<GrupoOrcamento__c> expList = new List<GrupoOrcamento__c>(); 
        String query= 'SELECT Id '//', Name, PremioTotal__c, IsDeleted'
            +'FROM GrupoOrcamento__c '
            +'WHERE ContratanteOrcamento__r.Orcamento__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<GrupoOrcamento__c> expList) {
        if (!Test.isRunningTest()) {  
           delete (List<GrupoOrcamento__c>)expList;
        }
    }
}