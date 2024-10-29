/****************************************************************************************************************************
 * Classe de negocio implementada para o processo automático correção de número de apólice e nome de contratos              *
 * que já tiveram parcelas geradas                                                                                          *
 * @author : Globant                                                                                                        *
 * @date 26/01/2024                                                                                                         *
 * Classe implementada tendo como origem a história PLV-5855                                                                *
 * **************************************************************************************************************************/
global class BatchAtualizarNomeProposta implements Database.Batchable<SObject>, Schedulable, Database.Stateful{
    @TestVisible private List<public_parcelacontrato__x> mockedRequests = new List<public_parcelacontrato__x>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT id, Proposta__r.id, Name, NumeroProposta__c, Origem__c FROM Contract WHERE Status =\'Em elaboração\' AND Segmento__c != \'Massificados\' AND Tipo__c = \'Novo\'  ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Contract> records){
        Set<String> quoteNames = new Set<String>();
        for(Contract record: records){
            String nomeQuote;
            if(record.NumeroProposta__c != null && record.Origem__c != null){
                nomeQuote = record.Origem__c + '-' + record.NumeroProposta__c;
                quoteNames.add(nomeQuote);
            }
        }
        
        List<public_parcelacontrato__x> lstParcelas =  (!mockedRequests.isEmpty()) ? mockedRequests : [ 
            SELECT 
                Id__c, 
                Empresa__c,
                Ramo__c, 
                Sucursal__c, 
                Apolice__c, 
                Endosso__c, 
                idProposta__c
            FROM public_parcelacontrato__x 
            WHERE idProposta__c in: quoteNames
        ];

        Map<String, String> mapContractNames = new Map<String, String>();
        Map<String, String> mapNumApolice = new Map<String, String>();

        for(public_parcelacontrato__x parcela: lstParcelas){
            String contractNewName;
            if(parcela.Empresa__c != null && parcela.Ramo__c != null && parcela.Apolice__c != null && parcela.Sucursal__c != null && parcela.Endosso__c != null){
                contractNewName = parcela.Empresa__c + '-' + parcela.Sucursal__c + '-' + parcela.Ramo__c + '-' + parcela.Apolice__c + '-' + parcela.Endosso__c;
                mapContractNames.put(parcela.idProposta__c, contractNewName);
                mapNumApolice.put(parcela.idProposta__c, parcela.Apolice__c);
            }
        }

        Set<Contract> foundContractsToUpdate = new Set<Contract>();
        Set<Quote> foundQuotesToUpdate = new Set<Quote>();
        Set<Quote> notFoundQuotesToUpdate = new Set<Quote>();

        for(Contract record: records){
            Contract contractToUpdate = new Contract();
            Quote quoteToUpdate = new Quote();
            String nomeQuoteKey;

            if(record.NumeroProposta__c != null && record.Origem__c != null){
                nomeQuoteKey = record.Origem__c + '-' + record.NumeroProposta__c;
            }
            System.debug('mapContractNames '+ mapContractNames);
            System.debug('mapNumApolice '+ mapNumApolice);
            
            if(!String.isBlank(nomeQuoteKey) && !String.isBlank(mapContractNames.get(nomeQuoteKey)) && !String.isBlank(mapNumApolice.get(nomeQuoteKey))){
                contractToUpdate.id = record.Id;
                contractToUpdate.Name = mapContractNames.get(nomeQuoteKey);
                contractToUpdate.NumeroApolice__c = mapNumApolice.get(nomeQuoteKey);
                contractToUpdate.Status = 'Emitido';

                quoteToUpdate.id = record.Proposta__r.id;
                quoteToUpdate.Status = 'Contratada';

                foundContractsToUpdate.add(contractToUpdate);
                foundQuotesToUpdate.add(quoteToUpdate);
            }else{
                quoteToUpdate.id = record.Proposta__r.id;
                quoteToUpdate.Status = 'Em análise';

                notFoundQuotesToUpdate.add(quoteToUpdate);
            }
        }
        List<Contract> updateFoundContractsToUpdate = new List<Contract>(foundContractsToUpdate);
        List<Quote> updateFoundQuotesToUpdate = new List<Quote>(foundQuotesToUpdate);
        List<Quote> updateNotFoundQuotesToUpdate = new List<Quote>(notFoundQuotesToUpdate);

        if(!updateFoundContractsToUpdate.isEmpty()) update updateFoundContractsToUpdate;
        BatchReestimuloPropostaJob jobClass = new BatchReestimuloPropostaJob();

        Integer scheduledJobCount = [SELECT COUNT() FROM CronJobDetail WHERE JobType = '7'];

        Integer controleRegistrosCrt = 100 - scheduledJobCount;  
        Integer count = 1;

        if(!updateFoundQuotesToUpdate.isEmpty()){
            for(Quote QuoteUpdateFound : updateFoundQuotesToUpdate){
                if(count <= controleRegistrosCrt){
                    
                    String minute = string.valueOf(system.now().minute() +1); //PLV-5856 FIX-03 INICIO/FIM        
                    String second = string.valueOf(count); //PLV-5856 FIX 05 INICIO/FIM
                    String jobName = '45_Job_Contratada' + string.valueOf(QuoteUpdateFound.id);
                    String cronTime = second+' '+minute+' * * * ?';
    
                    jobClass.quoteToUpdate = QuoteUpdateFound;
                    if(!Test.isRunningTest()) System.schedule(jobName, cronTime, jobClass);
                }
            }
            count++;
        }
        if(!updateNotFoundQuotesToUpdate.isEmpty()){
            for(Quote QuoteUpdate : updateNotFoundQuotesToUpdate){
                if(count <= controleRegistrosCrt){
                    
                    String minute = string.valueOf(system.now().minute() +1);      
                    String second = string.valueOf(count); 
                    String jobName = '45_Job_Em_analise_' + string.valueOf(QuoteUpdate.id);
                    String cronTime = second+' '+minute+' * * * ?';

                    jobClass.quoteToUpdate = QuoteUpdate;
                    if(!Test.isRunningTest()) System.schedule(jobName, cronTime, jobClass);

                    minute = string.valueOf(system.now().minute()+2);  
                    jobName = '45_Job_Disponivel para_contratacao_' + string.valueOf(QuoteUpdate.id);
                    QuoteUpdate.Status = 'Disponível para contratação';

                    jobClass.quoteToUpdate = QuoteUpdate;
                    if(!Test.isRunningTest()) System.schedule(jobName, cronTime, jobClass);
                }
                count = count + 2;
            }
        } 
        //ANNVI-25 FIM
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext SC)
    {
        BatchAtualizarNomeProposta batchPropostas = new BatchAtualizarNomeProposta();
        Database.executeBatch(batchPropostas);
    }

    global void scheduleBatch() {

        String cron1  = ' 0 0 10 * * ?';
        String cron2 = ' 0 0 17 * * ?';

        system.schedule('ReestimuloProposta1', cron1, this);
        system.schedule('ReestimuloProposta2', cron2, this);
    }
}