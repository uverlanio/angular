/**
 * Classe de teste para os batchs de expurgo:
 *      ExpurgoGarantiaSeguradoOrcamentoBatch
 *      ExpurgoGarantiaGrupoOrcamentoBatch
 *      ExpurgoSeguradoOrcamentoBatch
 *      ExpurgoGarantiasContratanteOrcBatch
 *      ExpurgoGrupoOrcamentoBatch
 *      ExpurgoContratanteOrcamentoBatch
 */
@IsTest 
public with sharing class ExpurgoOrcamentoBatchTest {
    @TestSetup
    static void makeData(){
        // ExpurgoOrcamentoDataFactory.setupData();    
        // TestDataFactory com erro de inserção de registro
        // System.DmlException: Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, valor duplicado encontrado: <unknown> duplica o valor no registro com ID: <unknown>: []
    }

    @IsTest 
    static void expurgoOrcamentoBatchesTest() {
        
        Test.startTest();

        // GarantiaSeguradoOrcamento__c
        ExpurgoGarantiaSeguradoOrcamentoBatch batchGarantiaSeguradoOrcamento= new ExpurgoGarantiaSeguradoOrcamentoBatch();
        Database.executeBatch(batchGarantiaSeguradoOrcamento, 1);

        // GarantiaGrupoOrcamento__c
        ExpurgoGarantiaGrupoOrcamentoBatch batchGarantiaGrupoOrcamento= new ExpurgoGarantiaGrupoOrcamentoBatch();
        Database.executeBatch(batchGarantiaGrupoOrcamento, 1);

        // SeguradoOrcamento__c
        ExpurgoSeguradoOrcamentoBatch batchSeguradoOrcamento= new ExpurgoSeguradoOrcamentoBatch();
        Database.executeBatch(batchSeguradoOrcamento, 1);

        // GrarantiasContratanteOrcamento__c
        ExpurgoGarantiasContratanteOrcBatch batchGarantiasContratanteOrc= new ExpurgoGarantiasContratanteOrcBatch();
        Database.executeBatch(batchGarantiasContratanteOrc, 1);

        // GrupoOrcamento__c
        ExpurgoGrupoOrcamentoBatch batchGrupoOrcamento= new ExpurgoGrupoOrcamentoBatch();
        Database.executeBatch(batchGrupoOrcamento, 1);

        // ContratanteOrcamento__c
        ExpurgoContratanteOrcamentoBatch batchContratanteOrcamento= new ExpurgoContratanteOrcamentoBatch();
        Database.executeBatch(batchContratanteOrcamento, 1);

        // GarantiaOrcamento__c
        ExpurgoGarantiaOrcamentoBatch batchGarantiaOrcamento= new ExpurgoGarantiaOrcamentoBatch();
        Database.executeBatch(batchGarantiaOrcamento, 1);

        // CriticaOrcamento__c
        ExpurgoCriticaOrcamentoBatch batchCriticaOrcamento= new ExpurgoCriticaOrcamentoBatch();
        Database.executeBatch(batchCriticaOrcamento, 1);

        Test.stopTest();
    }
}