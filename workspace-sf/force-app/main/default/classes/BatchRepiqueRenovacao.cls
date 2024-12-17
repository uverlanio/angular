/****************************************************************************************************************************
 * Classe de Negocio implementada para acionar o fluxo de repique limitando o número de registros                     *
 * @author : Rogerio Menezes - Globant                                                                                *
 * @date 06/12/2024                                                                                                   *
 * Classe implementada tendo como origem a história FNPVVEP-187                                                       *
 * **************************************************************************************************************************/
global class BatchRepiqueRenovacao implements Database.Batchable<sObject>, Database.StateFul, Database.AllowsCallouts, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Date dataAtual = Date.today();

        if(!Test.isRunningTest()){
            return Database.getQueryLocator(
                [SELECT Id, 
                Codigo__c, 
                Status__c, 
                MensagemInterna__c, 
                Proposta__r.Id, 
                Proposta__r.Status, 
                Proposta__r.Tipo__c, 
                DataRepique__c,
                DiasFalhaIntegracao__c
        FROM CriticaProposta__c 
        WHERE Proposta__r.Status = 'Em análise' 
            AND Proposta__r.Tipo__c = 'Renovacao' 
            AND Status__c = 'Falha na Integração' 
            AND MomentoAnalise__c = 'Palavra final' 
            AND Owner.Name = 'Fila Renovação' 
            AND (DataRepique__c < :dataAtual OR DataRepique__c = NULL) 
            LIMIT 3] 
            );
        }else{ 
            return Database.getQueryLocator(
                [SELECT Id
        FROM CriticaProposta__c 
        WHERE Proposta__r.Status = 'Em análise' 
            AND Proposta__r.Tipo__c = 'Renovacao' 
            AND Status__c = 'Falha na Integração' 
            AND MomentoAnalise__c = 'Palavra final']
            );
        }
    }

    public void scheduleBatch() {
        String cron = '0 0 15 * * ?';
        if(!Test.isRunningTest()) System.schedule('BatchRepiqueRenovacao', cron, this); //FNPVVEP-191 INICIO/FIM
    }

    global void execute(Database.BatchableContext BC, List<CriticaProposta__c> scope) {

        BatchRepiqueRenovacaoJob jobClass = new BatchRepiqueRenovacaoJob();

            Integer scheduledJobCount = [SELECT COUNT() FROM CronJobDetail WHERE JobType = '7'];

            Integer controleRegistrosCrt = 100 - scheduledJobCount;  
            Integer count = 1;

            if(!scope.isEmpty()){
                for(CriticaProposta__c critica : scope){
                    if(count <= controleRegistrosCrt){
                        List<CriticaProposta__c> criticasUpdate = new List<CriticaProposta__c>();
                        criticasUpdate.add(critica);
                        String minute = String.valueOf(Datetime.now().addMinutes(1).minute());
                        String second = string.valueOf(count); 
                        String jobName = 'Job_RepiquePalvraFinal' + string.valueOf(critica.id);
                        String cronTime = second+' '+minute+' * * * ?';
                        jobClass.scope = criticasUpdate;
                        if(!Test.isRunningTest()) System.schedule(jobName, cronTime, jobClass);
                    }
                    count++;
                }     
            }
    }

    global void execute(SchedulableContext schedulableContext){
        Database.executeBatch(this, 3);
        System.abortJob(schedulableContext.getTriggerId());
    }

    global void finish(Database.BatchableContext BC) {
        String min = String.valueOf(Datetime.now().addMinutes(1).minute());
        String ss = String.valueOf(Datetime.now().second());
        String cron = ss + ' ' + min + ' * * * ? *';
        if (Datetime.now().hour() >= 15) {
            if(!Test.isRunningTest()) System.schedule('BatchRepiqueRenovacao', cron, new BatchRepiqueRenovacao());
        }
        //FNPVVEP-191 INICIO
        else{
            String cronDiario = '0 0 15 * * ?';
            if(!Test.isRunningTest()) System.schedule('BatchEnviaCobrancaRenovacao', cronDiario, this);
        }
        //FNPVVEP-191 FIM
    }
}