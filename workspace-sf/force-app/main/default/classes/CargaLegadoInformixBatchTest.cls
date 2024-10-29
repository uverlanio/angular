@IsTest
public with sharing class CargaLegadoInformixBatchTest {
    //PLV-4293 - INICIO
    @TestSetup
    static void makeData() {
        
        String banco = '341';
        String agencia = '0123';
        String numeroConta = '01234567';

        Account conta1 = new Account(
            Name = 'Conta 1', 
            Cnpj__c = '08.370.609/0001-64',
            Inscricao_Estadual__c = '12345'
        );
        insert conta1;

        Account conta2 = new Account(
            Name = 'Conta 2',
            Papel__c = 'Segurado;',
            Cnpj__c = '08.571.415/0001-27',
            Inscricao_Estadual__c = '12345'
        );
        insert conta2;

        Banco__c bancoNew = new Banco__c(
            CodigoBanco__c = banco,
            ConveniadoADC__c  = false,
            Name = 'BANCO ITAU S/A',
            Ativo__c = true
        );
        insert bancoNew;
        
        insert new InformacaoBancaria__c (
            Banco__c = '341',
            Conta__c = conta1.Id,
            Agencia__c = agencia,
            NumeroConta__c = numeroConta,
            Papel__c = 'Agenciador'
        );

        insert new InformacaoBancaria__c (
            Banco__c = '111',
            Conta__c = conta2.Id,
            Agencia__c = agencia,
            NumeroConta__c = numeroConta,
            Papel__c = 'Agenciador'
        );
    }

    @IsTest 
	static void carga() {
        Test.startTest();
        Database.executeBatch(new CargaLegadoInformixBatch(), 200);
        Test.stopTest();
    }
    //PLV-4293 - FIM
}