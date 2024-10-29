global class BatchExecucaoBCP implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts{
    public BatchExecucaoBCPTO.consultarBCPRetorno responseHerokuTratado  = new BatchExecucaoBCPTO.consultarBCPRetorno();
    private Set<String> listProp = new Set<String>();

    global Database.QueryLocator start(Database.BatchableContext context){
        if(!Test.isRunningTest()){
            responseHerokuTratado = HerokuService.getInstance().consultarBCP();
        }
        if(responseHerokuTratado.descricao != 'A consulta não retornou registros'){
            for (BatchExecucaoBCPTO.consultarBCPdados reg : responseHerokuTratado.dados){
                for(BatchExecucaoBCPTO.consultarBCPregistros nmProp : reg.registros){
                    listProp.add(nmProp.numeroProposta);
                }
            }
        }
        return Database.getQueryLocator([SELECT id, NumeroApolice__c, Proposta__r.NumeroProposta__c FROM contract WHERE NumeroPropostaUnico__c IN : listProp]);  
    }

    global void execute(Database.BatchableContext BC, List<SObject> Contratos){
        Map<String, String> mapPropostaApolice = new Map<String, String>();
        Set<Id> setIdsContrato = new Set<Id> ();

        if(Contratos != null){
            for(SObject queryResult : Contratos){
                Contract contrato = (Contract)queryResult;
                mapPropostaApolice.put(contrato.Proposta__r.NumeroProposta__c, contrato.NumeroApolice__c);
                setIdsContrato.add(contrato.Id);
            }
            if(setIdsContrato != null && mapPropostaApolice != null){
                try{
                    new QuoteBO().chamarCIVEmissao(setIdsContrato, mapPropostaApolice);      
                }
                catch (Exception e){
                      System.debug('Erro não abortivo ao chamar o CIV: ' + e.getMessage() + ' na linha: ' + e.getLineNumber());
                }
            } 
        }
    }

    global void finish(Database.BatchableContext BC){ }

    global void execute(SchedulableContext ctx){
        if(Test.isRunningTest()){
            String retorno = '{"servico":"/reprocessamentobcp/consultar-bcp","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2021-12-08T17:27:06.993Z","descricao":"A consulta localizou 2 registro(s).","dados":[{"registros":[{"numeroProposta":"18-00001910"},{"numeroProposta":"18-00001910"}],"totalRegistros":2}]}';
            BatchExecucaoBCPTO.consultarBCPRetorno teste = (BatchExecucaoBCPTO.consultarBCPRetorno) JSON.deserialize(retorno, BatchExecucaoBCPTO.consultarBCPRetorno.class);
            this.responseHerokuTratado = teste;
        }
        Database.executeBatch(this, 100);
    }
}