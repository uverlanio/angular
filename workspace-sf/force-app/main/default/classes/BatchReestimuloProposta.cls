/****************************************************************************************************************************
 * Classe de Negocio implementada para o processo automático de alteração de Status de Propostas que já foram liberadas     *
 * @author : Globant                                                                                                        *
 * @date 09/11/2023                                                                                                         *
 * Classe implementada tendo como origem a história PLV-5856                                                                *
 * **************************************************************************************************************************/
global class BatchReestimuloProposta implements Database.Batchable<SObject>, Schedulable, Database.Stateful{
    global Set<String> quoteNames {get;set;}
    global Set<String> updatedQuoteNames {get;set;} //PLV-5856 FIX-03 INICIO/FIM
    global List<String> emailAdress {get;set;}
    
    global BatchReestimuloProposta(){
        this.quoteNames = new Set<String>();
        this.emailAdress = new List<String>();
        this.updatedQuoteNames = new Set<String>(); //PLV-5856 FIX-03 INICIO/FIM
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'select id, Status__c, Proposta__c, Proposta__r.Name from CriticaProposta__c where MomentoAnalise__c = \'Palavra final\' and Status__c =\'Liberado\' and Proposta__r.Status =\'Em análise\'and Proposta__r.Tipo__c != \'Renovacao\' AND Proposta__r.Contract.Id = null'; //PLV-5856 FIX-03 INICIO/FIM
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<CriticaProposta__c> records){
        //PLV-5856 FIX 01 INICIO
        Set<Quote> quoteSet = new Set<Quote>();

        for(CriticaProposta__c record: records){
            Quote toUpdate = new Quote();
            toUpdate.id = record.Proposta__c;
            toUpdate.Status = 'Disponível para contratação';
            toUpdate.name = record.Proposta__r.name; //PLV-5856 FIX-03 INICIO/FIM
            quoteSet.add(toUpdate);
            this.quoteNames.add(record.Proposta__r.Name);
        }
        List<Quote> listOfQuotes = new List<Quote>(quoteSet);

        //PLV-5856 FIX 06 INICIO
        Integer scheduledJobCount = [SELECT COUNT() FROM CronJobDetail WHERE JobType = '7'];

        Integer controleRegistrosCrt = 100 - scheduledJobCount;  
        //PLV-5856 FIX 06 FIM

        Integer count = 1; //PLV-5856 FIX-04 INICIO/FIM
        for(Quote QuoteUpdate : listOfQuotes){
            if(count <= controleRegistrosCrt){ //PLV-5856 FIX-04 INICIO/FIM
                String minute = string.valueOf(system.now().minute() +1); //PLV-5856 FIX-03 INICIO/FIM        
                String second = string.valueOf(count); //PLV-5856 FIX 05 INICIO/FIM
                
                String jobName = '30_Job_' + string.valueOf(QuoteUpdate.id);
                String cronTime = second+' '+minute+' * * * ?';
                BatchReestimuloPropostaJob jobClass = new BatchReestimuloPropostaJob();
                jobClass.quoteToUpdate = QuoteUpdate;
                if(!Test.isRunningTest()) System.schedule(jobName, cronTime, jobClass); //PLV-5856 FIX 02 INICIO/FIM
                this.updatedQuoteNames.add(QuoteUpdate.name);
            }
            count++; //PLV-5856 FIX-04 INICIO/FIM
        }

        //PLV-5856 FIX 01 FIM
    }
    
    global void finish(Database.BatchableContext bc){
        if (!this.updatedQuoteNames.isEmpty()){ //PLV-5856 FIX-03 INICIO/FIM
            StaticResource srObject = [SELECT id, body FROM StaticResource WHERE Name = 'EmailsReestimulo' LIMIT 1];
            String contents = srObject.body.toString();
            this.emailAdress = contents.split(',');
            
            //PLV-5856 FIX 03 INICIO
            String bodyToSend = 'Propostas que tiveram o status alterado para \'Disponível para contratação\' pelo processo de reestimulo de propostas: #listaQuote# <br> Data de execução:  #processDate# <br> Número de propostas que restam processar: #numQuotesNaoProcessada# ';
            
            String numQuotesNaoProcessada = String.ValueOf(this.quoteNames.size() - this.updatedQuoteNames.size());
            String stringQuotesValue = '';
            for(String quoteName : this.updatedQuoteNames){
                stringQuotesValue = stringQuotesValue + quoteName +'<br>'; 
            }

            bodyToSend = bodyToSend.replace('#listaQuote#', stringQuotesValue);
            bodyToSend = bodyToSend.replace('#numQuotesNaoProcessada#', numQuotesNaoProcessada);
            //PLV-5856 FIX 03 FIM
            bodyToSend = bodyToSend.replace('#processDate#', String.valueOf(date.today()));
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(this.emailAdress);
            email.setSubject('Reestimulo Propostas ' + date.today().format());
            email.setHtmlBody(bodyToSend);
    
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });    
        }
    }
    
    global void execute(SchedulableContext SC)
    {
        BatchReestimuloProposta batchPropostas = new BatchReestimuloProposta();
        Database.executeBatch(batchPropostas);
    }

    global void scheduleBatch() {

        String cron1  = ' 0 0 9 * * ?';
        String cron2 = ' 0 0 16 * * ?';

        system.schedule('ReestimuloProposta1', cron1, this);
        system.schedule('ReestimuloProposta2', cron2, this);
    }
}