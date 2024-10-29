public with sharing class ExpurgoBeneficiarioSeguradoPropostaBatch  implements Database.Batchable<BeneficiarioSeguradoProposta__c> {
    public static ExpurgoBeneficiarioSeguradoProposta obj= new ExpurgoBeneficiarioSeguradoProposta();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<BeneficiarioSeguradoProposta__c> start(Database.BatchableContext bc) {
        List<BeneficiarioSeguradoProposta__c> expList= new List<BeneficiarioSeguradoProposta__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de BeneficiarioSeguradoProposta__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<BeneficiarioSeguradoProposta__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de BeneficiarioSeguradoProposta__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}