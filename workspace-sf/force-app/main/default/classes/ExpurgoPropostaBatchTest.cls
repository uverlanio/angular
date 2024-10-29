@IsTest
public with sharing class ExpurgoPropostaBatchTest {
    @TestSetup
    static void makeData(){
        // TestDataFactory com erro de inserção de registro
        // System.DmlException: Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, valor duplicado encontrado: <unknown> duplica o valor no registro com ID: <unknown>: []
    }

    @IsTest 
    static void expurgoPropostaBatchesTest() {
        
        Test.startTest();

        // BeneficiarioSeguradoProposta__c
        ExpurgoBeneficiarioSeguradoPropostaBatch batchBeneficiarioSeguradoProposta= new ExpurgoBeneficiarioSeguradoPropostaBatch();
        Database.executeBatch(batchBeneficiarioSeguradoProposta, 1);

        // GarantiaSeguradoProposta__c
        ExpurgoGarantiaSeguradoPropostaBatch batchGarantiaSeguradoProposta= new ExpurgoGarantiaSeguradoPropostaBatch();
        Database.executeBatch(batchGarantiaSeguradoProposta, 1);

        // GarantiasGrupoProposta__c
        ExpurgoGarantiasGrupoPropostaBatch batchGarantiasGrupoProposta= new ExpurgoGarantiasGrupoPropostaBatch();
        Database.executeBatch(batchGarantiasGrupoProposta, 1);

        // SeguradoProposta__c
        ExpurgoSeguradoPropostaBatch batchSeguradoProposta= new ExpurgoSeguradoPropostaBatch();
        Database.executeBatch(batchSeguradoProposta, 1);

        // GarantiaContratanteProposta__c
        ExpurgoGarantiaContratantePropostaBatch batchGarantiaContratanteProposta= new ExpurgoGarantiaContratantePropostaBatch();
        Database.executeBatch(batchGarantiaContratanteProposta, 1);

        // GrupoProposta__c
        ExpurgoGrupoPropostaBatch batchGrupoProposta= new ExpurgoGrupoPropostaBatch();
        Database.executeBatch(batchGrupoProposta, 1);

        // ContratanteProposta__c
        ExpurgoContratantePropostaBatch batchContratanteProposta= new ExpurgoContratantePropostaBatch();
        Database.executeBatch(batchContratanteProposta, 1);

        // FavorecidoRemuneracaoProposta__c
        ExpurgoFavorecidoRemuneracaoPropBatch batchFavorecidoRemuneracaoProp= new ExpurgoFavorecidoRemuneracaoPropBatch();
        Database.executeBatch(batchFavorecidoRemuneracaoProp, 1);

        // RemuneracaoProposta__c
        ExpurgoRemuneracaoPropostaBatch batchRemuneracaoProposta= new ExpurgoRemuneracaoPropostaBatch();
        Database.executeBatch(batchRemuneracaoProposta, 1);

        // CriticaProposta__c
        ExpurgoCriticaPropostaBatch batchCriticaProposta= new ExpurgoCriticaPropostaBatch();
        Database.executeBatch(batchCriticaProposta, 1);

        // GarantiaProposta__c
        ExpurgoGarantiaPropostaBatch batchGarantiaProposta= new ExpurgoGarantiaPropostaBatch();
        Database.executeBatch(batchGarantiaProposta, 1);

        // DeclaracaoSaude__c
        ExpurgoDeclaracaoSaudeBatch batchDeclaracaoSaude= new ExpurgoDeclaracaoSaudeBatch();
        Database.executeBatch(batchDeclaracaoSaude, 1);

        // Quote (Proposta)
        ExpurgoPropostaBatch batchProposta= new ExpurgoPropostaBatch();
        Database.executeBatch(batchProposta, 1);
        
        Test.stopTest();
    }
}