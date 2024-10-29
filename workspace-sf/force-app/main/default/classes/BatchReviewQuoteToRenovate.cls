/**
 * @description       : Consultar propostas que estão prestes a serem renovadas e verificar se o contrato está cancelado, para que a renovação seja feita ou não. (II-185)
 * @author            : Kevin Vogado (GLOBANT)
 * @last modified on  : 31-05-2024
 * @last modified by  : Kevin Vogado
**/
public with sharing class BatchReviewQuoteToRenovate implements Database.Batchable<sObject>, Schedulable{

    public void scheduleBatch() {
        //FNPVVEP-57 - INICIO
        //String cron = '0 0 5 * * ?'; 
        String cron = '0 10 0 * * ?';
        //FNPVVEP-57 - FIM
        system.schedule('BatchReviewQuoteToRenovate', cron, this);
    }

    public Database.QueryLocator start (Database.BatchableContext context){
        return Database.getQueryLocator(
            [SELECT ID, ContratoRenovado__c, CreatedDate FROM Quote WHERE Tipo__c = 'Renovacao' AND Status = 'Em análise' AND LiberarContratoRenovacao__c = true] //FNPVVEP-93 INICIO/FIM
        );
    }

    public void execute(SchedulableContext sc){
        BatchReviewQuoteToRenovate batch = new BatchReviewQuoteToRenovate();
        Id batchId = database.executeBatch(batch);
    }

    public void execute (Database.BatchableContext context, List<Quote> propostasTipoRenovacao){
        //FNPVVEP-93 INICIO
        try{
            Map<Id, Quote> contratoRenovadoPorProposta = new Map<Id, Quote>();

            List<Quote> duplicatedQuotes = new List<Quote>();//FNPVVEP-18 - INICIO/FIM

            //FNPVVEP-18 - INICIO
            for(Quote propostaRenovacao : propostasTipoRenovacao){
                if(!contratoRenovadoPorProposta.containsKey(propostaRenovacao.ContratoRenovado__c)){
                    contratoRenovadoPorProposta.put(propostaRenovacao.ContratoRenovado__c, propostaRenovacao);
                }else{
                    duplicatedQuotes.add(propostaRenovacao);
                } 
            }
            //FNPVVEP-18 - FIM

            List<Contract> contratosRelacionadosAProposta = [SELECT Id, Status, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c, StartDate, StatusRenovacao__c, Tipo__c  FROM Contract WHERE Id IN :contratoRenovadoPorProposta.keySet()]; 

            if(!duplicatedQuotes.isEmpty()) updateStatusCritiquesAndQuotes(duplicatedQuotes);//FNPVVEP-18 - INICIO/FIM

            if(!contratosRelacionadosAProposta.isEmpty()) updateStatusContractsAndQuotes(contratosRelacionadosAProposta, contratoRenovadoPorProposta);

        }catch(Exception ex){
            System.debug('Erro ao analisar as Propostas antes da Renovação - > BatchReviewQoteToRenovate');
			System.debug(ex.getMessage());
			System.debug(ex.getLineNumber());
        }
        //FNPVVEP-93 FIM
    }

    //FNPVVEP-57 - INICIO
    public void finish (Database.BatchableContext context){
        Boolean batchReviewExecutado = verificarExecucaoBatchReview();
        if(batchReviewExecutado){
                String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().minute() + 4); //FNPVVEP-117 FIX03 INICIO/FIM
                String ss = String.valueOf(Datetime.now().second());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                String formattedDatetime = String.valueOf(Datetime.now()).substring(0, 19).replace('T', ' ').replace(':', '-');
                BatchContrPropRenv batch = new BatchContrPropRenv(); 
                JobsAgendados__c jb = new JobsAgendados__c();
                jb.Name = 'BatchContrPropRenv ' + formattedDatetime;
                jb.jobId__c = System.schedule('BatchContrPropRenv - Temporario - 4 minutos ' + String.valueOf(Datetime.now()), nextFireTime, batch); //FNPVVEP-117 FIX03 INICIO/FIM
                if (!Test.isRunningTest()) insert jb; //FNPVVEP-93 INICIO/FIM
        }
    }
    //FNPVVEP-57 - FIM

    //FNPVVEP-18 - INICIO
    public void updateStatusCritiquesAndQuotes(List<Quote> duplicatedQuotes) {

        List<CriticaProposta__c> criticasParaAtualizar = new List<CriticaProposta__c>();
        Map<Id, Quote> propostasIndexedById = new Map<Id, Quote>();

        for (Quote proposta : duplicatedQuotes) {
            proposta.Status = 'Cancelada';
            proposta.Observacoes__c = 'Proposta cancelada por duplicidade';
            propostasIndexedById.put(proposta.Id, proposta);
        }

        if (!propostasIndexedById.keySet().isEmpty()) {
            List<CriticaProposta__c> criticas = [SELECT Id, Status__c, Proposta__c FROM CriticaProposta__c WHERE Proposta__c IN :propostasIndexedById.keySet()];

            if(!criticas.isEmpty()){
                for (CriticaProposta__c critica : criticas) {
                    if (critica.Id != null && critica.Status__c != 'Cancelada') {
                        critica.Status__c = 'Cancelada';
                        criticasParaAtualizar.add(critica);
                    }
                }
            }
        }
        
        try {
            if (!propostasIndexedById.values().isEmpty()) update propostasIndexedById.values(); 
            if (!criticasParaAtualizar.isEmpty()) update criticasParaAtualizar; 
        } catch (Exception ex) {
            System.debug('Erro ao atualizar proposta duplicada  - > BatchReviewQuoteToRenovate');
            System.debug(ex.getMessage());
            System.debug(ex.getLineNumber());
        }
    }
    //FNPVVEP-18 - FIM
    //FNPVVEP-57 - INICIO
    public Boolean verificarExecucaoBatchReview() {
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'BatchReviewQuoteToRenovate'];

        for (AsyncApexJob job : jobs) {
            if (job.Status == 'Completed') {
                return true;
            }
        }
        return false;
    }
    //FNPVVEP-57 - FIM

    //FNPVVEP-93 INICIO
    public void updateStatusContractsAndQuotes(List<Contract> contratosRelacionadosAProposta, Map<Id, Quote> contratoRenovadoPorProposta) {

        Set<String> numerosApolice = new Set<String>();
        Set<String> numerosEmpresa = new Set<String>();
        Set<String> numerosSucursal = new Set<String>();
        Set<String> numerosRamo = new Set<String>();
        List<Contract> contratosParaAtualizar = new List<Contract>();
        List<Quote> propostasParaAtualizar = new List<Quote>();
        Map<String, Contract> contratosMap = new Map<String, Contract>();

        for (Contract contrato : contratosRelacionadosAProposta) {
            if (contrato.NumeroApolice__c != null) {
                numerosEmpresa.add(contrato.Empresa__c);
                numerosSucursal.add(contrato.Sucursal__c);
                numerosRamo.add(contrato.CodigoRamo__c);
                numerosApolice.add(contrato.NumeroApolice__c);
                String nomeApolice = contrato.Empresa__c + contrato.Sucursal__c + contrato.CodigoRamo__c + contrato.NumeroApolice__c;
                contratosMap.put(nomeApolice, contrato);
            }
        }

        List<Contract> contratosEndosso = [
            SELECT Id, Status, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c, StartDate, StatusRenovacao__c, Tipo__c  
            FROM Contract 
            WHERE NumeroApolice__c IN :numerosApolice 
            AND Empresa__c IN :numerosEmpresa 
            AND Sucursal__c IN :numerosSucursal 
            AND CodigoRamo__c IN :numerosRamo 
            AND Endosso__c != '0'
        ];

        Map<String, Contract> maiorEndossoMap = new Map<String, Contract>();

        if(!contratosEndosso.isEmpty()){
            for (Contract contrato : contratosEndosso) {
                String nomeApolice = contrato.Empresa__c + contrato.Sucursal__c + contrato.CodigoRamo__c + contrato.NumeroApolice__c;
                if (contrato.Tipo__c == 'Cancelamento') {
                    maiorEndossoMap.put(nomeApolice, contrato);
                } else if (!maiorEndossoMap.containsKey(nomeApolice) || contrato.Endosso__c > maiorEndossoMap.get(nomeApolice).Endosso__c) {
                    maiorEndossoMap.put(nomeApolice, contrato);
                }
            }
        }

        List<Contract> ultimoEndosso = new List<Contract>(maiorEndossoMap.values());

        if(!ultimoEndosso.isEmpty()){
            for (Contract contrato : ultimoEndosso) {
                String nomeApolice = contrato.Empresa__c + contrato.Sucursal__c + contrato.CodigoRamo__c + contrato.NumeroApolice__c;
                if(contratosMap.containsKey(nomeApolice)){
                    Contract contratoOriginal = contratosMap.get(nomeApolice);
                    Quote propostaTipoRenovacao = contratoRenovadoPorProposta.get(contratoOriginal.Id);
                    if(contrato.Status == 'Emitido' && contrato.Tipo__c == 'Cancelamento') {
                        propostaTipoRenovacao.Status = 'Cancelada';
                        propostasParaAtualizar.add(propostaTipoRenovacao);
                    }
                    else if(contrato.StartDate > propostaTipoRenovacao.CreatedDate && contrato.Status == 'Emitido'){
                        propostaTipoRenovacao.Status = 'Cancelada';
                        propostasParaAtualizar.add(propostaTipoRenovacao);
                        contratoOriginal.StatusRenovacao__c = 'Não Renovado';
                        contratosParaAtualizar.add(contratoOriginal);
                    }
                }
            }
        }
        
        try {
            if(!propostasParaAtualizar.isEmpty()) update propostasParaAtualizar;
            if(!contratosParaAtualizar.isEmpty()) update contratosParaAtualizar;
        } catch (Exception ex) {
            System.debug('Erro ao cancelar proposta de renovação');
            System.debug(ex.getMessage());
            System.debug(ex.getLineNumber());
        }
    }
    //FNPVVEP-93 FIM
}