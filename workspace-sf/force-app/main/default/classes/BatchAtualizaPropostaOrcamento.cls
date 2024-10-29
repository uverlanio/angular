/**
 * @description       : Consultar todas transferencias corretagem e alterar a susep da proposta renovação de acordo com o tipo (carteira ou individual) - RVI-265
 * @author            : Kevin Vogado e Matheus Meneses (GLOBANT)
 * @last modified on  : 24-08-2023
 * @last modified by  : Bruno Filipe
**/
global class BatchAtualizaPropostaOrcamento implements Database.Batchable<sObject>, Database.StateFul, Schedulable, Database.AllowsCallouts{
    
    AtualizaPropOrcamentoCtr ctrPDF = new AtualizaPropOrcamentoCtr();
    List<TransferenciaCorretagem__c> updatePDF = new  List<TransferenciaCorretagem__c>();

    global void execute(SchedulableContext sc){
        BatchAtualizaPropostaOrcamento batch = new BatchAtualizaPropostaOrcamento();
        Id batchId = database.executeBatch(batch);
    }

    global void scheduleBatch() {
        String cron = '0 0 5 * * ?'; 
        system.schedule('BatchAtualizaPropostaOrcamento', cron, this);
    }

    global Database.QueryLocator start(Database.BatchableContext context) {	
        
       // Date dataRenovacaoMinus15Days = Date.today().addDays(-15);
       // Date dataRenovacaoMinus90Days = Date.today().addDays(-90);

		/*return Database.getQueryLocator([
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

                CodCor__c,
                ValidoAte__c, 
                TransferirCarteira__c,

                ContratoTransferido__c, 
                ContratoTransferido__r.Proposta__r.Id, 
                ContratoTransferido__r.Proposta__c, 

                CreatedDate

            FROM TransferenciaCorretagem__c 
            //WHERE (ContratoTransferido__r.DataRenovacao__c <= :dataRenovacaoMinus15Days 
            //        AND ContratoTransferido__r.VigenciaFinal__c >= :dataRenovacaoMinus15Days
            //        AND  ContratoTransferido__r.Name != null)
            //        OR TransferirCarteira__c = true
            WHERE (		
                    ContratoTransferido__r.DataRenovacao__c <= :dataRenovacaoMinus15Days 
                AND ContratoTransferido__r.DataRenovacao__c >  :dataRenovacaoMinus90Days
                AND ContratoTransferido__r.VigenciaFinal__c >= :dataRenovacaoMinus15Days
                AND ContratoTransferido__r.Name != null)
                //  OR (TransferirCarteira__c = true AND CreatedDate >= TODAY) //dataRenovacaoMinus90Days
                 OR (TransferirCarteira__c = true AND CreatedDate >: dataRenovacaoMinus90Days) //dataRenovacaoMinus90Days
        ]);*/
        return Database.getQueryLocator([
            SELECT Id, CodigoCorretor__c, CodigoCorretor__r.Name, ContratoRenovado__c, Status, Tipo__c, OpportunityId, Opportunity.CodigoCorretor__c, Opportunity.CodigoCorretor__r.Name, Opportunity.ContratoRenovado__c,
                                (SELECT Id, Name FROM RemuneracoesProposta__r)
                                  FROM Quote
                                  WHERE Status = 'Em análise' 
                                  AND Tipo__c = 'Renovacao'
                                  AND LiberarContratoRenovacao__c = true
        ]);

	}

    //global void execute(Database.BatchableContext BC, List<TransferenciaCorretagem__c> transferencias){
    global void execute(Database.BatchableContext BC, List<Quote> propostas){

        // AtualizaPropOrcamentoCtr ctr = new AtualizaPropOrcamentoCtr();
        // ctr.insertFavRemuneracaoProposta(transferencias);
        // updatePDF.addAll(transferencias);
        List<Quote> qtTest = new List<Quote>();

        for (Quote qt: propostas) {
            qtTest.add(qt);
            System.debug('qtTest' + qtTest);
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        // ctrPDF.insertFavRemuneracaoProposta(updatePDF);
    } 
}