/*********************************************************************************************************************************************************************
@description Classe  batch responsavel por reenvio dos contratos.
@author Uverlanio Silva - Globant
@date 23/01/2023
**********************************************************************************************************************************************************************/
global class BatchReenvioContratoBCP implements Database.Batchable<sObject>, Database.StateFul, Database.AllowsCallouts, Schedulable{
    
    static List<AsyncApexJob> jobs = AsyncApexJobDao.getInstancia().buscarClasses(
        new Set<String> { 'BatchReenvioContratoBCP' }
    );
    
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(
            [SELECT Id, BCP_DataHoraEnvio__c, BCP_DataHoraRetorno__c, BCP_Contrato__c FROM BCP_Log__c] //LECVP-72 - INICIO - FIM
        );
    }

    global void execute(Database.BatchableContext batchableContext, List<BCP_Log__c> logs){
        reenviarPayloadSemTckt(logs, BatchReenvioContratoBCP.jobs);
        apagarLogs(logs, BatchReenvioContratoBCP.jobs);
    }

    global void execute(SchedulableContext schedulableContext){
        Database.executeBatch(this, 10);
    }

    global void finish(Database.BatchableContext batchableContext){}

    global void apagarLogs(List<BCP_Log__c> logs, List<AsyncApexJob> jobs){
        Boolean possuiTicket = false;
        List<BCP_Log__c> listaApagarLogs = new List<BCP_Log__c>();
        
        try{
            
            Set<Id> idsContrato = Util.recuperarIdsPorCampoDeSObject(logs, Schema.BCP_Log__c.BCP_Contrato__c);
            List<Contract> contratos = ContractDAO.getInstance().buscar(idsContrato);
            Map<Id, Contract> contratosMapeado = new Map<Id, Contract> (contratos);
            Map<Id, BCP_Log__c> mapBCPLog = new Map<Id, BCP_Log__c>(logs);

            for(BCP_Log__c log : mapBCPLog.values())
            {
                //LECVP-72 - INICIO
                Integer diferenciaDias = 0;

                if(log.BCP_DataHoraEnvio__c != null){             
                    diferenciaDias = log.BCP_DataHoraEnvio__c.date().daysBetween(Datetime.now().date());                    
                 }else{
                    diferenciaDias = log.BCP_DataHoraRetorno__c.date().daysBetween(Datetime.now().date());
                 }                 
                 possuiTicket = verificarContratoPossuiTckt(contratosMapeado.get(log?.BCP_Contrato__c));

                    if(diferenciaDias >= 7 || possuiTicket){
                    listaApagarLogs.add(log);
                }//LECVP-72 - FIM
            }

            if(!listaApagarLogs.isEmpty()){
                Set<Id> logIds = Util.recuperarIdsPorCampoDeSObject(listaApagarLogs, Schema.BCP_Log__c.Id);
                List<BCP_Log__c> listaLogs = BCPLogDAO.getInstance().buscarLogsBCPPorId(logIds);

                if(!listaLogs.isEmpty()){
                    delete listaLogs;
                }
            }           
        }catch(Exception e){
            System.debug('Erro na limpeza de logs BCP: ' + e.getMessage() + ' na linha: ' + e.getLineNumber());
            if(!jobs.isEmpty() && String.isNotBlank(jobs[0].Id)){
                System.abortJob(jobs[0].Id);
            }
        }
    }
    
    global void reenviarPayloadSemTckt(List<BCP_Log__c> logs, List<AsyncApexJob> jobs){

        Set<Id> setContratosEmitidos = new Set<Id>();
        List<Contract> listaContratos = new List<Contract>();
        Map<Id, Contract> mapContratos;
        Map<String, String> mapPropostaApolice = new Map<String, String>();
        
        try{
            Set<Id> idContratos = Util.recuperarIdsPorCampoDeSObject(logs, Schema.BCP_Log__c.BCP_Contrato__c);
            List<Contract> contratos = ContractDAO.getInstance().buscarPorBCPTicket(idContratos, new Set<String> { '' });
            Map<Id, Contract> contratosPorId = new Map<Id, Contract>(contratos);
            
            for(BCP_Log__c log : logs){
                Contract contrato = contratosPorId.get(log.BCP_Contrato__c);
                if(contrato != null){
                    if(!listaContratos.contains(contrato)){
                        listaContratos.add(contrato);
                        setContratosEmitidos.add(contrato.id);
                    }
                }
            }
            mapContratos = new Map<Id, Contract> (listaContratos);

            for(Contract contrato : mapContratos.values()){
                if(
                    String.isNotBlank(contrato?.Proposta__c) &&
                    String.isNotBlank(contrato?.Proposta__r?.NumeroProposta__c)
                ) {
                    mapPropostaApolice.put(contrato.Proposta__r.NumeroProposta__c, contrato.NumeroApolice__c);
                    
                    if(mapContratos.isEmpty() || mapPropostaApolice.isEmpty()){
                        throw new BatchReenvioContratoBCPException('Contratos ou apolices nao encontrados!');
                    }
                }
            }
            
            try{
                new QuoteBO().chamarCIVReenvio(setContratosEmitidos, mapPropostaApolice);
            }catch (Exception e){
                System.debug('Erro não abortivo ao chamar o CIV: ' + e.getMessage() + ' na linha: ' + e.getLineNumber());
            }
        }catch (Exception e){
            System.debug('Erro na tentativa de reenvio do contrato a BCP via CIV: ' + e.getMessage() + ' na linha: ' + e.getLineNumber());
            
            if(!jobs.isEmpty() && jobs[0].Id != null){
                System.abortJob(jobs[0].Id);
            }
        }
    }

    global Boolean verificarContratoPossuiTckt(Contract contrato){
        return String.isNotBlank(contrato?.BCP_Ticket__c);
    }

    public class BatchReenvioContratoBCPException extends Exception{}
}