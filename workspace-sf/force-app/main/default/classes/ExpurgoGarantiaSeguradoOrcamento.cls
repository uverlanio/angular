/**
 * Expurgo de dados para o Orçamento
 *  objeto: GarantiaSeguradoOrcamento__c
 * caminho do objeto:
 * GarantiaSeguradoOrcamento__c 
 *  > SeguradoOrcamento__c 
 *  > GrupoOrcamento__c
 *  > ContratanteOrcamento__c
 *  > Opportunity
 * 
 * 20/02/2024
 */
public with sharing class ExpurgoGarantiaSeguradoOrcamento { 

    public List<GarantiaSeguradoOrcamento__c> getDadosExpurgo(Integer qt) { 
        List<GarantiaSeguradoOrcamento__c> expList= new List<GarantiaSeguradoOrcamento__c>();
        String query= 'SELECT Id '//', Name, PremioTotal__c, GarantiaProduto__c, IsDeleted '
            +'FROM GarantiaSeguradoOrcamento__c '
            +'WHERE SeguradoOrcamento__r.GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<GarantiaSeguradoOrcamento__c> expList) {
        if (!Test.isRunningTest()) {
            delete (List<GarantiaSeguradoOrcamento__c>)expList;
        }
    }
}