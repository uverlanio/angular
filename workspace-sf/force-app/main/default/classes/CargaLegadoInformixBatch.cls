public with sharing class CargaLegadoInformixBatch implements Database.Batchable<sObject> {
    //PLV-4293 - INICIO
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id
                ,Banco__c
                ,BancoNew__c
                ,Conta__c
                ,Conta__r.Papel__c
            FROM InformacaoBancaria__c 
            WHERE Papel__c = 'Agenciador'
            AND BancoNew__c = null
            AND Banco__c <> null
            AND Conta__c <> null
            LIMIT 10000
        ]);
    }

    public void execute(Database.BatchableContext context, List<InformacaoBancaria__c> infoBancarias) {

        if (infoBancarias.size() > 0) {
            Map<String,Banco__c> mapBancos = new Map<String,Banco__c>();
        
            List<Banco__c> bancos = [
                SELECT Id
                    ,CodigoBanco__c
                FROM Banco__c
                WHERE Ativo__c = true
                LIMIT 10000
            ];
        
            if(bancos.size() > 0) {
                for (Banco__c banco : bancos) {
                    mapBancos.put(banco.CodigoBanco__c, banco);
                }
            }
        
            Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
        
            for (InformacaoBancaria__c info : infoBancarias) {
                Account conta = new Account(Id = info.Conta__c);

                //Se encontrar o Banco preenche
                if (mapBancos.containsKey(info.Banco__c)) {
                    info.BancoNew__c = mapBancos.get(info.Banco__c).Id;
                    conta.Ativo__c = true;
                }
                else {
                    conta.Ativo__c = false;
                }

                if (info.Conta__r.Papel__c != null && !info.Conta__r.Papel__c.contains('Agenciador')) {
                    conta.Papel__c = info.Conta__r.Papel__c + 'Agenciador;';
                }
                else if (info.Conta__r.Papel__c == null) {
                    conta.Papel__c = 'Agenciador;';
                }

                accountsToUpdate.put(info.Conta__c, conta);
            }
        
            Integer nErros = 0;
        
            Database.SaveResult[] srListInfo = Database.update(infoBancarias, false);
            for (Database.SaveResult sr : srListInfo) {
                if (!sr.isSuccess()) {
                    nErros++;
                    for (Database.Error err: sr.getErrors()) {
                        System.debug('Os seguinte erros ocorreram.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        
            if (accountsToUpdate.values().size() > 0) {
                Integer nErrosConta = 0;
        
                Database.SaveResult[] srListInfoContas = Database.update(accountsToUpdate.values(), false);
                for (Database.SaveResult sr : srListInfoContas) {
                    if (!sr.isSuccess()) {
                        nErrosConta++;
                        for (Database.Error err: sr.getErrors()) {
                            System.debug('Os seguinte erros ocorreram.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
        
                System.debug('SCRIPT 4293 - INFO BANCARIA - Contas ERROS: ' + nErrosConta);
            }
        } 
    }

    public void finish(Database.BatchableContext context) {

    }
    //PLV-4293 - FIM
}