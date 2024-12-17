/****************************************************************************************************************************
 * Classe de Negocio implementada para acionar o fluxo de envio de cobrança limitando o número de registros           *
 * @author : Rogerio Menezes - Globant                                                                                *
 * @date 16/12/2024                                                                                                   *
 * Classe implementada tendo como origem a história FNPVVEP-191                                                       *
 * **************************************************************************************************************************/
global class BatchEnviaCobrancaRenovacao implements Database.Batchable<sObject>, Database.StateFul, Database.AllowsCallouts, Schedulable {

    private Integer limite;

    global Database.QueryLocator start(Database.BatchableContext BC) {

        List<Constante__mdt> constante = MetadataDAO.getInstance().buscarConstante('Limite_Email_Renovacao');
        limite = Integer.valueOf(constante[0].Valor__c);
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
                DiasFalhaIntegracao__c,
                Proposta__r.DataEnvioEmailCobranca__c
        FROM CriticaProposta__c 
        WHERE Proposta__r.Status = 'Em análise' 
            AND Proposta__r.Tipo__c = 'Renovacao' 
            AND (((FalhaIntegracao__c = 0 OR FalhaIntegracao__c = 1) AND DataFalhaIntegracao__c = NULL) OR DiasFalhaIntegracao__c = 4 OR DiasFalhaIntegracao__c = 8 OR DiasFalhaIntegracao__c = 12 OR DiasFalhaIntegracao__c = 16)
            AND (Status__c = 'Falha na Integração' OR Status__c = 'Pendenciado') 
            AND MomentoAnalise__c = 'Palavra final' 
            AND Owner.Name = 'Fila Renovação' 
            AND Proposta__r.DataEnvioEmailCobranca__c != :dataAtual
            LIMIT :limite] 
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
        String cron = '0 0 11 * * ?';
        if(!Test.isRunningTest()) System.schedule('BatchEnviaCobrancaRenovacao', cron, this);
    }

    global void execute(Database.BatchableContext BC, List<CriticaProposta__c> scope) {

        for (CriticaProposta__c critica : scope) {
            Map<String, Object> flowInputs = new Map<String, Object>{
                'RecordId' => critica.Id 
            };

            Flow.Interview flowInterview = Flow.Interview.createInterview('Envia_Cobranca_Renovacao_Limitado', flowInputs);
            flowInterview.start();
        }
    }

    global void execute(SchedulableContext schedulableContext){
        Database.executeBatch(this);
        System.abortJob(schedulableContext.getTriggerId());
    }

    global void finish(Database.BatchableContext BC) {
        String min = String.valueOf(Datetime.now().addMinutes(1).minute());
        String ss = String.valueOf(Datetime.now().second());
        String cron = ss + ' ' + min + ' * * * ? *';
        if (Datetime.now().hour() >= 11) {
            if(!Test.isRunningTest()) System.schedule('BatchEnviaCobrancaRenovacao', cron, new BatchEnviaCobrancaRenovacao());
        }else{
            String cronDiario = '0 0 11 * * ?';
            if(!Test.isRunningTest()) System.schedule('BatchEnviaCobrancaRenovacao', cronDiario, this);
        }
    }
}