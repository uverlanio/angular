/**
 * @author Guilherme Azevedo
 * @date 2020-12-14
 * @description Criada para a história PLV-4644
 */
global class BatchErroSampleMed_sch implements Database.Batchable<SObject>, Schedulable, Database.Stateful, Database.AllowsCallouts {
    Boolean singleRun = false;
    Date beginDate;
    Date endDate;

    //++++++++++++++++++++++++
    // CONSTRUCTOR
    //++++++++++++++++++++++++

    public BatchErroSampleMed_sch() {}

    public BatchErroSampleMed_sch(Date beginDate, Date endDate) {
        this.beginDate = beginDate;
        this.endDate = endDate.addDays(1);
        this.singleRun = true;
    }
    
    //++++++++++++++++++++++++
    // BATCH METHODS
    //++++++++++++++++++++++++

    global void execute(SchedulableContext sc) {
        try {
            //ABORTAR JOB ANTERIOR
            System.abortJob(sc.getTriggerId());

            Database.executeBatch(new BatchErroSampleMed_sch(), 25);
        } catch (Exception ex) {
            System.debug('Erro durante o agendamento do Batch : \n' + ex.getMessage() + ', ' + ex.getStackTraceString());
        }
    } 

	global Database.QueryLocator start(Database.BatchableContext context) {
        String query = 
        + ' SELECT ID '
        + ' FROM CriticaProposta__c '
        + ' WHERE Integracao__c = \'SAMPLE\' '
        + ' AND Status__c = \'Falha na Integração\'';

        if (beginDate != null && endDate != null) {
            query += ' AND CreatedDate >= ' +  getFormattedDatetimeStr(beginDate)
            + ' AND CreatedDate < ' + getFormattedDatetimeStr(endDate);
        }
        else {
            query += ' AND CreatedDate >= LAST_N_DAYS:5 ';
        }

        query += ' ORDER BY CreatedDate DESC '
        + ' LIMIT 50000' ;
        
        System.debug('Query => ' + query);

		return Database.getQueryLocator(query);
    }

	global void execute(Database.BatchableContext context, List<CriticaProposta__c> scope) {
        Set<Id> criticasToUpdate = new Set<Id>();
        
        try {
            for (CriticaProposta__c critica : scope) {
                criticasToUpdate.add(critica.Id);
            }
            
            IntegracaoSampleMed.integrar(criticasToUpdate, false);
        } catch (Exception ex) {
            System.debug('\nBatchErroSampleMed_sch :: batch execute :: EXCEPTION : ' 
                + ex.getMessage() + ', ' + ex.getSTackTraceString() + ', scope : \n' + JSON.serializePretty(scope)); 
        }
    }

    global void finish(Database.BatchableContext context) {
        if (!singleRun) {
            BatchErroSampleMed_sch.scheduleNext();
        }
    }

    //++++++++++++++++++++++++
    // PUBLIC METHODS
    //++++++++++++++++++++++++
    
    global static void runAndSchedule() {
        Database.executeBatch(new BatchErroSampleMed_sch(), 50);
    }

    global static void singleRunByDate(String beginDateStr, String endDateStr) {
        Database.executeBatch(new BatchErroSampleMed_sch(Date.parse(beginDateStr), Date.parse(endDateStr)), 50);
    }

    global static String scheduleNext() {
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset/1000);

        return System.schedule('BatchErroSampleMed_sch : ' + local, '0 0 0/4 * * ?', new BatchErroSampleMed_sch());
    }

    //++++++++++++++++++++++++
    // PRIVATE METHODS
    //++++++++++++++++++++++++

    private String getFormattedDatetimeStr(Date data) {
        String dia = data.day() < 10 ? '0' + data.day() : String.valueOf(data.day());
        String mes = data.month() < 10 ? '0' + data.month() : String.valueOf(data.month());
        String ano = String.valueOf(data.year());
        return ano + '-' + mes + '-' + dia + 'T00:00:00Z';
    }
}