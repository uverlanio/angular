/***
* Created: Jeferson Santana (Sys4b)
* Date: 2023-04-28
* Description: run report generation routine in txt format and send by email classs of test: BatchCreateFileReportMegaDayTest
* task-History : PMH-24
***/ 
global with sharing class SchedulerCreateFileReportmagaDay implements Schedulable{
    @TestVisible private Date inicio;
    @TestVisible private Date fim; 
    public SchedulerCreateFileReportmagaDay(Date inicio, Date fim){
        this.inicio = inicio;
        this.fim = fim;
    }
    global void execute(SchedulableContext sc) {

        BatchCreateFileReportMegaDay b = new BatchCreateFileReportMegaDay(this.inicio, this.fim); 
        
        Id batchId = database.executebatch(b, 2000);
    }

    global static void schedulerBatchReportMegaDay(String param, Date inicio, Date fim){
        
        System.schedule('BatchCreateFileReportMegaDay' + System.now(), param, new SchedulerCreateFileReportmagaDay(inicio, fim));
    }
}