/**
 * Author: Marcelo Ratton
 * Team: SYS4B - Salesforce
 * Test: ExpurgoScheduleTest
 * 
 * Description: classe para agendar o Expurgo
 */
global with sharing class ExpurgoSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        // --- Orçamento

        // GarantiaSeguradoOrcamento__c
        ExpurgoGarantiaSeguradoOrcamentoBatch expGarantiaSeguradoOrcamentoBatch= new ExpurgoGarantiaSeguradoOrcamentoBatch();
        String retOrc1= Database.executeBatch(expGarantiaSeguradoOrcamentoBatch);
        System.debug('ExpurgoGarantiaSeguradoOrcamentoBatch '+retOrc1);

        // GarantiaGrupoOrcamento__c
        ExpurgoGarantiaGrupoOrcamentoBatch expGarantiaGrupoOrcamentoBatch= new ExpurgoGarantiaGrupoOrcamentoBatch();
        String retOrc2= Database.executeBatch(expGarantiaGrupoOrcamentoBatch);
        System.debug('ExpurgoGarantiaGrupoOrcamentoBatch '+retOrc2);

        // SeguradoOrcamento__c
        ExpurgoSeguradoOrcamentoBatch expSeguradoOrcamentoBatch= new ExpurgoSeguradoOrcamentoBatch();
        String retOrc3= Database.executeBatch(expSeguradoOrcamentoBatch);
        System.debug('ExpurgoSeguradoOrcamentoBatch '+retOrc3);

        // GrarantiasContratanteOrcamento__c
        ExpurgoGarantiasContratanteOrcBatch expGrarantiasContratanteOrcamentoBatch= new ExpurgoGarantiasContratanteOrcBatch();
        String retOrc4= Database.executeBatch(expGrarantiasContratanteOrcamentoBatch);
        System.debug('ExpurgoGrarantiasContratanteOrcamentoBatch '+retOrc4);

        // GrupoOrcamento__c
        ExpurgoGrupoOrcamentoBatch expGrupoOrcamentoBatch= new ExpurgoGrupoOrcamentoBatch();
        String retOrc5= Database.executeBatch(expGrupoOrcamentoBatch);
        System.debug('ExpurgoGrupoOrcamentoBatch '+retOrc5);

        // ContratanteOrcamento__c
        ExpurgoContratanteOrcamentoBatch expContratanteOrcamentoBatch= new ExpurgoContratanteOrcamentoBatch();
        String retOrc6= Database.executeBatch(expContratanteOrcamentoBatch);
        System.debug('ExpurgoContratanteOrcamentoBatch '+retOrc6);

        // GarantiaOrcamento__c
        ExpurgoGarantiaOrcamentoBatch expGarantiaOrcamentoBatch= new ExpurgoGarantiaOrcamentoBatch();
        String retOrc7= Database.executeBatch(expGarantiaOrcamentoBatch);
        System.debug('ExpurgoGarantiaOrcamentoBatch '+retOrc7);

        // CriticaOrcamento__c
        ExpurgoCriticaOrcamentoBatch expCriticaOrcamentoBatch= new ExpurgoCriticaOrcamentoBatch();
        String retOrc8= Database.executeBatch(expCriticaOrcamentoBatch);
        System.debug('ExpurgoCriticaOrcamentoBatch '+retOrc8);

        // --- Proposta

        // BeneficiarioSeguradoProposta__c
        ExpurgoBeneficiarioSeguradoPropostaBatch expBeneficiarioSeguradoPropostaBatch= new ExpurgoBeneficiarioSeguradoPropostaBatch();
        String retProp1= Database.executeBatch(expBeneficiarioSeguradoPropostaBatch);
        System.debug('ExpurgoBeneficiarioSeguradoPropostaBatch '+retProp1);

        // GarantiaSeguradoProposta__c
        ExpurgoGarantiaSeguradoPropostaBatch expGarantiaSeguradoPropostaBatch= new ExpurgoGarantiaSeguradoPropostaBatch();
        String retProp2= Database.executeBatch(expGarantiaSeguradoPropostaBatch);
        System.debug('ExpurgoGarantiaSeguradoPropostaBatch '+retProp2);

        // GarantiasGrupoProposta__c
        ExpurgoGarantiasGrupoPropostaBatch expGarantiasGrupoPropostaBatch= new ExpurgoGarantiasGrupoPropostaBatch();
        String retProp3= Database.executeBatch(expGarantiasGrupoPropostaBatch);
        System.debug('ExpurgoGarantiasGrupoPropostaBatch '+retProp3);

        // SeguradoProposta__c
        ExpurgoSeguradoPropostaBatch expSeguradoPropostaBatch= new ExpurgoSeguradoPropostaBatch();
        String retProp4= Database.executeBatch(expSeguradoPropostaBatch);
        System.debug('ExpurgoSeguradoPropostaBatch '+retProp4);

        // GarantiaContratanteProposta__c
        ExpurgoGarantiaContratantePropostaBatch expGarantiaContratantePropostaBatch= new ExpurgoGarantiaContratantePropostaBatch();
        String retProp5= Database.executeBatch(expGarantiaContratantePropostaBatch);
        System.debug('ExpurgoGarantiaContratantePropostaBatch '+retProp5);

        // GrupoProposta__c
        ExpurgoGrupoPropostaBatch expGrupoPropostaBatch= new ExpurgoGrupoPropostaBatch();
        String retProp6= Database.executeBatch(expGrupoPropostaBatch);
        System.debug('ExpurgoGrupoPropostaBatch '+retProp6);

        // ContratanteProposta__c
        ExpurgoContratantePropostaBatch expContratantePropostaBatch= new ExpurgoContratantePropostaBatch();
        String retProp7= Database.executeBatch(expContratantePropostaBatch);
        System.debug('ExpurgoContratantePropostaBatch '+retProp7);

        // FavorecidoRemuneracaoProposta__c
        ExpurgoFavorecidoRemuneracaoPropBatch expFavorecidoRemuneracaoPropBatch= new ExpurgoFavorecidoRemuneracaoPropBatch();
        String retProp8= Database.executeBatch(expFavorecidoRemuneracaoPropBatch);
        System.debug('ExpurgoFavorecidoRemuneracaoPropBatch '+retProp8);

        // RemuneracaoProposta__c
        ExpurgoRemuneracaoPropostaBatch expRemuneracaoPropostaBatch= new ExpurgoRemuneracaoPropostaBatch();
        String retProp9= Database.executeBatch(expRemuneracaoPropostaBatch);
        System.debug('ExpurgoRemuneracaoPropostaBatch '+retProp9);

        // CriticaProposta__c
        ExpurgoCriticaPropostaBatch expCriticaPropostaBatch= new ExpurgoCriticaPropostaBatch();
        String retProp10= Database.executeBatch(expCriticaPropostaBatch);
        System.debug('ExpurgoCriticaPropostaBatch '+retProp10);

        // GarantiaProposta__c
        ExpurgoGarantiaPropostaBatch expGarantiaPropostaBatch= new ExpurgoGarantiaPropostaBatch();
        String retProp11= Database.executeBatch(expGarantiaPropostaBatch);
        System.debug('ExpurgoGarantiaPropostaBatch '+retProp11);

        // DeclaracaoSaude__c

        // Quote (Proposta)

        // Orçamento (Opportunity)
    }
}

/*
 * código para implementar o agendamento [executado no Developer Console]

    ExpurgoSchedule expOrcamentoSch= new ExpurgoSchedule();
    String sch= '0 0 2 * * ?';
    String jobId= System.schedule('Expurgo Orçamento', sch, expOrcamentoSch);

*/