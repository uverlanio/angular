global class BatchTokenSensidiaAws implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, NomeToken__c FROM Servico__mdt WHERE DeveloperName = 'Gerar_Boleto']);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        String token = SensediaServices.getInstance().getAccessToken('AWS_EXTERNO', 'Token_Sensedia_AWS');
        for (SObject obj : scope) {
            Servico__mdt servico = (Servico__mdt)obj;
            servico.NomeToken__c = token; 
        }

        try {
            update scope; 
        } catch (DmlException e) {
            System.debug('Erro ao atualizar o token: ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch de geração de token concluído.');
    }

    global void execute(SchedulableContext SC) {
        BatchTokenSensidiaAws batch = new BatchTokenSensidiaAws();
        Database.executeBatch(batch);
    }

    public static void scheduleBatch() {
        String cronExp1 = '0 0 * * * ?';  // A cada hora no minuto 0
        String cronExp2 = '0 50 * * * ?'; // A cada hora no minuto 50
        
        BatchTokenSensidiaAws scheduler = new BatchTokenSensidiaAws();
        System.schedule('BatchTokenSensidiaAwsScheduler_0', cronExp1, scheduler);
        System.schedule('BatchTokenSensidiaAwsScheduler_50', cronExp2, scheduler);

    }
}