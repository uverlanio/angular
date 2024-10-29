global class BatchAtualizaPropostOorcamento implements Database.Batchable<sObject>, Database.StateFul, Schedulable{

    global void execute(SchedulableContext sc){
        BatchAtualizaPropostOorcamento batch = new BatchAtualizaPropostOorcamento();
        Id batchId = database.executeBatch(batch);
    }

    global void scheduleBatch() {
        String cron = '0 0 5 * * ?'; 
        system.schedule('BatchAtualizaPropostaOrcamento', cron, this);
    }

    global Database.QueryLocator start(Database.BatchableContext context) {	
        
        Date dataRenovacaoMinus15Days = Date.today().addDays(-15);

		return Database.getQueryLocator([
            SELECT Id,
                PercSusepLider__c, 
                PercPriCoCorretor__c, 
                PercSegCoCorretor__c, 
                PercTerCoCorretor__c, 
                PercQuaCoCorretor__c, 
                PercQuiCoCorretor__c,

                SusepPriCoCorretagem__r.Name, 
                SusepPriCoCorretagem__c, 
                SusepPriCoCorretagem__r.NomeCorretor__c, 

                SusepSegCoCorretagem__r.Name, 
                SusepSegCoCorretagem__c, 
                SusepSegCoCorretagem__r.NomeCorretor__c, 

                SusepTerCoCorretagem__r.Name, 
                SusepTerCoCorretagem__c, 
                SusepTerCoCorretagem__r.NomeCorretor__c, 

                SusepQuaCoCorretagem__r.Name, 
                SusepQuaCoCorretagem__c, 
                SusepQuaCoCorretagem__r.NomeCorretor__c, 

                SusepQuiCoCorretagem__r.Name, 
                SusepQuiCoCorretagem__c, 
                SusepQuiCoCorretagem__r.NomeCorretor__c, 

                SusepOriginal__c, 
                SusepOriginal__r.Name,

                SusepAtual__c, 
                SusepAtual__r.Name,
                SusepAtual__r.NomeCorretor__c, 

                ValidoAte__c, 
                TransferirCarteira__c,
                CodCor__c, //II-154 INICIO/FIM

                ContratoTransferido__c, 
                ContratoTransferido__r.Proposta__r.Id, 
                ContratoTransferido__r.Proposta__c 

            FROM TransferenciaCorretagem__c 
            WHERE (ContratoTransferido__r.DataRenovacao__c <= :dataRenovacaoMinus15Days 
                    AND ContratoTransferido__r.VigenciaFinal__c >= :dataRenovacaoMinus15Days )
            OR TransferirCarteira__c = true
        ]);
	}

    global void execute(Database.BatchableContext BC, List<TransferenciaCorretagem__c> transferencias){

        AtualizaPropOrcamentoCtr ctr = new AtualizaPropOrcamentoCtr();

        ctr.insertFavRemuneracaoProposta(transferencias);

    }

    global void finish(Database.BatchableContext bc){
    }
    
}