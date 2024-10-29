/**
 * Created by Alessandro Ponte on 04/09/2018.
 */

global class TitulosRecompraBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    public static ContractBO bo = ContractBO.getInstance();


    global TitulosRecompraBatch(){

    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        // Busco os contratos ativos com Garantia da Capitalização
        Database.QueryLocator retorno = Database.getQueryLocator([
            SELECT 
                Id, 
                Contrato__c, 
                Contrato__r.Proposta__c, 
                Contrato__r.Proposta__r.Origem__c,
                Contrato__r.Proposta__r.Name, 
                GarantiaProduto__r.CodigoPromocao__c, 
                GarantiaProduto__r.ValorTitulo__c,
                VersaoTitulo__c, 
                NumeroSorte__c, 
                DataSorteio__c,
                LoteCapitalizacao__c 
            FROM 
                GarantiaContrato__c
            WHERE 
                Contrato__r.StartDate <=: System.today() 
            AND Contrato__r.VigenciaFinal__c >=: System.today()
            AND Garantia__r.Sigla__c = 'CAP'
        ]);

        System.debug('ESTOU NO RETORNO DA QUERY');

        return retorno;
    }

    global void execute(Database.BatchableContext BC, List<GarantiaContrato__c> listGarantiaContrato){
        System.debug('ESTOU NO EXECUTE DO BATCH');
        bo.processarRecompraTitulos(listGarantiaContrato);
    }

    global void finish(Database.BatchableContext BC){
        System.debug('ESTOU NO FINISH DO BATCH');
    }

    public class BatchTituloException extends Exception {}
}