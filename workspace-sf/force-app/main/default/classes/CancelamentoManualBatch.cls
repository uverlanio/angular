/**
 * Created by Alessandro Ponte on 25/06/2019.
 */

public with sharing class CancelamentoManualBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    List<String> listNumeroApolice = new List<String>();

    public CancelamentoManualBatch(List<String> numerosApolice){
        this.listNumeroApolice = numerosApolice;
    }

    public Database.QueryLocator start(Database.BatchableContext job){

        // Busco os contratos ativos com Garantia da Capitalização
        Database.QueryLocator retorno = Database.getQueryLocator([
                SELECT
                        Id,
                        NumeroApolice__c,
                        Status
                FROM
                        Contract
                WHERE
                        Status = 'Emitido'
                AND
                        NumeroApolice__c =: listNumeroApolice
        ]);

        return retorno;
    }

    public void execute(Database.BatchableContext jobId, List<Contract> listContrato){
        System.debug('EXECUCAO DO CANCELAMENTO MANUAL PARA ' + listContrato.size() + ' contratos.');

        // Cancela o contrato
        for(Contract contrato : listContrato){
            RetornoAcaoBotaoTO retornoAcaoBotaoTO = ContractBO.getInstance().cancelarContratoSelecionado(contrato.Id, 'INA'); //MGRC-1657 - INICIO/FIM
        }
    }

    public void finish(Database.BatchableContext jobId){
        System.debug('FIM DA EXECUCAO DO CANCELAMENTO MANUAL');
    }

}