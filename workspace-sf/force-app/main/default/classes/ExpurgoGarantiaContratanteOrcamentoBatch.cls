/**
 * Expurgo de dados
 * 
 * Description: excluir dados obsoletos da base para evitar 'inchaço'
 */
public with sharing class ExpurgoGarantiaContratanteOrcamentoBatch implements Database.Batchable<GarantiaContratanteOrcamento__c> {
    public static ExpurgoGarantiasContratanteOrcamento obj= new ExpurgoGarantiasContratanteOrcamento();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<GarantiaContratanteOrcamento__c> start(Database.BatchableContext bc) {
        List<GarantiaContratanteOrcamento__c> expList= new List<GarantiaContratanteOrcamento__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de GarantiaContratanteOrcamento__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<GarantiaContratanteOrcamento__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de GarantiaContratanteOrcamento__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}