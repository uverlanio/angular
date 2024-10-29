/******************************************************************************************************************************
 * Busca propostas em elaboração e envia para o Heroku                                                                        *
 * @author : Globant                                                                                                          *
 * @date 30/09/2022                                                                                                           *
 * Classe implementada tendo como origem a história PLV-5266                                                                  *
 ******************************************************************************************************************************/

global with sharing class RestimuloContratoHeroku  implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts
{

    private final string CONTRACT_STATUS = 'Em elaboração';
    private final integer BATCH_SIZE = 100;

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator([SELECT Name, Empresa__c, Sucursal__c, CodigoRamo__c, RamoSeguro__c, NumeroApolice__c, Endosso__c, NumeroPropostaUnico__c FROM Contract WHERE Status =: CONTRACT_STATUS]);
    }

    global void execute(Database.BatchableContext bc, List<Contract> records)
    {
        HerokuService herokuServ = HerokuService.getInstance();
        RequestHeroku request = new RequestHeroku();

        for(Contract record : records)
        {
            request.propostas.add(new RequestProposta(record));
        }

        string jsonRequest = json.serialize(request);

        responseHeroku resposta = herokuServ.consultaRestimuloContrato(jsonRequest);

        // string mock = '{"servico":"/parcelacontrato/reestimular-status-apolice","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2021-09-21T20:39:01.842Z","descricao":"Parcelas encontradas.","encontrouregistro":true,"dados":[{"empresa":"1","sucursal":"1","ramo":"1391","apolice":"000022594","endosso":"0"}]}';
        //responseHeroku resposta =(responseHeroku)JSON.deserialize(mock, responseHeroku.class);

        if(resposta.encontrouRegistro)
        {
            List<String> contractName = new List<String>();

            for(responseDados dado: resposta.dados)
            {
                string contName = dado.empresa+dado.sucursal+dado.ramo+dado.apolice+dado.endosso;
                contractName.add(contName);
            }

            for(Contract contrato : records)
            {
                String contratoBatch = contrato.Empresa__c+'-'+contrato.Sucursal__c+'-'+contrato.CodigoRamo__c+'-'+contrato.NumeroApolice__c+'-'+contrato.Endosso__c; //PLV-5266-FIX 02 INICIO/FIM  
                for(responseDados dado: resposta.dados)
                {
                    string contractUpdateName =  dado.empresa+'-'+dado.sucursal+'-'+dado.ramo+'-'+dado.apolice+'-'+dado.endosso; //PLV-5266-FIX 02 INICIO/FIM  
                    if(contratoBatch == contractUpdateName)
                    {
                        contrato.NumeroApolice__c = dado.apolice;
                        contrato.status = 'Emitido';
                        contrato.Name = contractUpdateName; 
                    }
                }
            }
            update records;
        }
    }

    global void finish(Database.BatchableContext bc)
    {
        
    }

    global void execute(SchedulableContext ctx)
    {
        Database.executeBatch(this, BATCH_SIZE);
    }

    global class RequestHeroku
    {
        global List<RequestProposta> propostas      {get;set;}

        global RequestHeroku()
        {
            this.propostas = new List<RequestProposta>();
        }
    }

    global class RequestProposta
    {
        global string proposta                      {get;set;}

        public RequestProposta(Contract record)
        {
            this.proposta = record.NumeroPropostaUnico__c;
        }       
    }

    global class responseHeroku
    {
       global string servico                        {get;set;}
       global string status                         {get;set;}
       global integer codigoProcessamento           {get;set;}
       global string dataExecucao                   {get;set;}
       global string descricao                      {get;set;}
       global boolean encontrouRegistro             {get;set;}
       
       global List<responseDados> dados {get;set;}
    }

    global class responseDados
    {
        global string empresa                        {get;set;}
        global string sucursal                       {get;set;}
        global string ramo                           {get;set;}
        global string apolice                        {get;set;}
        global string endosso                        {get;set;}
        global string erro                           {get;set;}
    }
}