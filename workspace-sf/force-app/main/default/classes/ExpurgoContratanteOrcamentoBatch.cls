/**
 * Expurgo de dados
 * 
 * Description: excluir dados obsoletos da base para evitar 'inchaço'
 */
public with sharing class ExpurgoContratanteOrcamentoBatch implements Database.Batchable<ContratanteOrcamento__c> {
    public static ExpurgoContratanteOrcamento obj= new ExpurgoContratanteOrcamento();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<ContratanteOrcamento__c> start(Database.BatchableContext bc) {
        List<ContratanteOrcamento__c> expList= new List<ContratanteOrcamento__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de ContratanteOrcamento__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<ContratanteOrcamento__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de ContratanteOrcamento__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}