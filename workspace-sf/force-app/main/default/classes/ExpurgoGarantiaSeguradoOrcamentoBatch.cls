/**
 * Expurgo de dados
 * 
 * Description: excluir dados obsoletos da base para evitar 'inchaço'
 */
public with sharing class ExpurgoGarantiaSeguradoOrcamentoBatch implements Database.Batchable<GarantiaSeguradoOrcamento__c> {
    public static ExpurgoGarantiaSeguradoOrcamento obj= new ExpurgoGarantiaSeguradoOrcamento();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<GarantiaSeguradoOrcamento__c> start(Database.BatchableContext bc) {
        List<GarantiaSeguradoOrcamento__c> expList= new List<GarantiaSeguradoOrcamento__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de GarantiaSeguradoOrcamento__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<GarantiaSeguradoOrcamento__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de GarantiaSeguradoOrcamento__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}