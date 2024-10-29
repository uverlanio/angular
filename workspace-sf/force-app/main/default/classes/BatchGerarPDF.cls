/*********************************************************************************************************************************************************************
@description  Realiza a geração de PDF
@author Pedro Augusto Braz - SYS4B
@date 14/11/2020
@Classe criada por conta da história PLV-4544
**********************************************************************************************************************************************************************/
// PLV-4544
global class BatchGerarPDF implements Database.Batchable<sObject>, Database.StateFul, Database.AllowsCallouts, Schedulable {
    
    global Map<Id,Quote> mapPropostas = new Map<Id,Quote>();
    
    public BatchGerarPDF(){}

    global List<CriticaProposta__c> listCriticaUpdate = new List<CriticaProposta__c>();
    global List<Quote> listPropostaUpdate = new List<Quote>();

    global Database.QueryLocator start(Database.BatchableContext BC){
        // PLV-4544
        String query = 'SELECT Id, Name, GerarPDF__c, RealizarEnvioDocusign__c FROM Quote WHERE GerarPDF__c = true AND Status = \'Em análise\' LIMIT 100';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('BatchGerarPDF - Enviado');
        try{
            mapPropostas = new Map<Id,Quote>((List<Quote>)scope);
            
            QuoteBO.gerarPDFPropostaSync(new List<Id>(mapPropostas.keySet()));
            
            for(Quote cotacao :mapPropostas.values() ){
                cotacao.GerarPDF__c = false;
                // PLV-4544
                cotacao.RealizarEnvioDocusign__c = true;
            }


		}catch(Exception ex){
			System.debug('Erro ao gerar documentos - > BatchGerarPDF');
			System.debug(ex.getMessage());
			System.debug(ex.getLineNumber());
		}
		
    }

    global void finish(Database.BatchableContext BC){
        QuoteTriggerHandler.bypassGerarPDF = true;
        Database.SaveResult[] srList = Database.update(mapPropostas.values(), false);
        QuoteTriggerHandler.bypassGerarPDF = false;
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully updated Quote ID: ' + sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Quote fields that affected this error: ' + err.getFields());
                }
            }
        }
        // PLV-4544 FIX INICIO
        List<JobsAgendados__c> listJb = new List<JobsAgendados__c>();
        for(Quote proposta : mapPropostas.values()){
            JobsAgendados__c jb = JobsAgendados__c.getValues('BatchGerarPDF'+proposta.Id);
            if(jb != null){
                System.abortJob(jb.jobId__c);
                listJb.add(jb);
            }
        }
        if(listJb.size() > 0)
            delete listJb;

        // PLV-4544 FIX FIM
        
    }
    
    // PLV-4544 FIX INICIO
    global void execute(SchedulableContext SC) {
        BatchGerarPDF b = new BatchGerarPDF();
        Database.executeBatch(b);
    }
    // PLV-4544 FIX FIM
    
}