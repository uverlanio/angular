public with sharing class ExpurgoDeclaracaoSaudeBatch implements Database.Batchable<DeclaracaoSaude__c> {
    public static ExpurgoDeclaracaoSaude obj= new ExpurgoDeclaracaoSaude();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<DeclaracaoSaude__c> start(Database.BatchableContext bc) {
        List<DeclaracaoSaude__c> expList= new List<DeclaracaoSaude__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de DeclaracaoSaude__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<DeclaracaoSaude__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de DeclaracaoSaude__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}