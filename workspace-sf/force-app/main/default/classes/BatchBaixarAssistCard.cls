/*********************************************************************************************************************************************************************
@description Classe batch responsavel por dar baixar nos casos da Assist Card
@author Uverlanio Silva - Globant
@date 24/05/2023
**********************************************************************************************************************************************************************/
//LECVP-318 - INICIO
global class BatchBaixarAssistCard implements Database.Batchable<sObject>, Database.StateFul, Database.AllowsCallouts, Schedulable{
   
    static List<AsyncApexJob> jobs = AsyncApexJobDao.getInstancia().buscarClasses(
        new Set<String> { 'BatchBaixarAssistCard' }
    );

    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(
                [SELECT Id, Status, Type, Contrato__r.CodigoRamo__c FROM Case 
                    WHERE 
                        Data_pagamento__c <= TODAY 
                    AND
                        PagtoAssistCardInternacional__c = 'Sim' 
                    AND 
                        Contrato__r.Segmento__c  = 'Viagem'
                    AND
                        Contrato__r.TipoViagem__c = 'Internacional'
                    AND  
                        Status IN ('Avisado','Em Regulação') //LECVP-318- FIX -  INICIO/FIM
                    ]
        );
    }

    global void execute(Database.BatchableContext batchableContext, List<Case> casosAssist){
        baixarCasosAssist(casosAssist, BatchBaixarAssistCard.jobs);
    }

    global void execute(SchedulableContext schedulableContext){
        Database.executeBatch(this, 10);
    }

    global void finish(Database.BatchableContext batchableContext){}

    global void baixarCasosAssist(List<Case> casosAssist, List<AsyncApexJob> jobs){

       
        List<PagamentoGarantia__c> garantias = new List<PagamentoGarantia__c>();
        Case casoAFechar = new Case();
        List<Case> fecharCasos = new List<Case>();
        MovimentoSinistroBO movSinBO = MovimentoSinistroBO.getInstance();
        List<MovimentoSinistro__c> movimentosAGerar = new List<MovimentoSinistro__c>();
        MovimentoSinistro__c movimentoGerado = new MovimentoSinistro__c();
        Boolean temPagtoParcial = false;
        // LECVPV-238-FIX01 INICIO
        // List<PagamentoGarantia__c> garantiasAFechar = new List<PagamentoGarantia__c>();
        // PagamentoGarantia__c garantia = new PagamentoGarantia__c();
        List<ID> idsGarantiasFechar = new List<ID>();
        // LECVPV-238-FIX01 FIM
        Set<Id> setCase = new Set<Id>();
        Map<Id,Integer> mapSequencia = new Map<Id,Integer>();
        Integer sequencia;
        String sequencia2;

        for(Case casoMov : casosAssist){
            setCase.add(casoMov.id);
        }

        try{
            //LECVP-318 - FIX - INICIO
            for(Case caso : casosAssist){
                garantias = PagamentoGarantiaDAO.getInstance().buscarCasoParaAtualizarFaseStatus(caso.Id);
                mapSequencia = SequenciaMovimentoSinistroHelper.sequenciaMovimentos(setcase);
                System.debug('Henrique mapSequencia: ' +mapSequencia );
                if(!garantias.isEmpty()){
                    if(garantias.size() == 1){
                        if(garantias[0].Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c == 'DMHO' &&
                                garantias[0].Caso__r.Contrato__r.CodigoRamo__c == '1369' && garantias[0].Fase__c != 'Fechado' ){
                            // LECVPV-238-FIX01 INICIO
                            // garantia = prepararGarantia(garantias[0], 'Fechado', 'Pago');
                            // garantiasAFechar.add(garantia);
                            idsGarantiasFechar.add(garantias[0].Id);
                            casoAFechar.Id = garantias[0].Caso__c;
                            // LECVPV-238-FIX01 FIM
                            casoAFechar.Status = 'Fechado';
                            if(mapSequencia == null){
                                mapSequencia = new Map<Id,Integer>();
                                sequencia = 1;
                            }else if(mapSequencia.containsKey(caso.Id)){
                                sequencia = mapSequencia.get(caso.Id) + 1;
                            }else{
                                sequencia = 1;
                            }

                            sequencia2 = String.valueOf(sequencia);
                            movimentoGerado = movSinBO.criarMovimento(caso.Id, MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS, garantias[0].ValorIndenizado__c, sequencia2, garantias[0].Id,false);  // LECVPV-140-FIX02 INICIO/FIM // LECVPV-238 INICIO/FIM
                            
                            if(movimentoGerado != null){
                                // LECVPV-238-FIX01 INICIO
                                movimentosAGerar.add(movimentoGerado);
                                // insert movimentoGerado;
                                // LECVPV-238-FIX01 FIM
                            }

                            if(!fecharCasos.contains(casoAFechar)){
                                fecharCasos.add(casoAFechar);
                            }                            
                        }                    
                    }else{
                        for(PagamentoGarantia__c garantiaComMaisCob : garantias){                          
                            if(garantiaComMaisCob.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c == 'DMHO' &&
                                    garantiaComMaisCob.Caso__r.Contrato__r.CodigoRamo__c == '1369' && garantiaComMaisCob.Fase__c != 'Fechado' ){
                                // LECVPV-238-FIX01 INICIO
                                //  garantia = prepararGarantia(garantiaComMaisCob, 'Fechado', 'Pago');
                                //   garantiasAFechar.add(garantia); 
                                idsGarantiasFechar.add(garantiaComMaisCob.ID);
                                // LECVPV-238-FIX01 FIM
                                if(mapSequencia == null){
                                    mapSequencia = new Map<Id,Integer>();
                                    sequencia = 1;
                                }else if(mapSequencia.containsKey(caso.Id)){
                                    sequencia = mapSequencia.get(caso.Id) + 1;
                                }else{
                                    sequencia = 1;
                                }
                                sequencia2 = String.valueOf(sequencia);
                                if(!temPagtoParcial){
                                    movimentoGerado = movSinBO.criarMovimento(caso.Id, MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS, garantiaComMaisCob.ValorIndenizado__c, sequencia2, garantiaComMaisCob.Id,false); // LECVPV-140-FIX02 INICIO/FIM // LECVPV-238 INICIO/FIM
                                    if(movimentoGerado != null){
                                        // LECVPV-238-FIX01 INICIO
                                         movimentosAGerar.add(movimentoGerado);
									     // insert movimentoGerado;
                                        // LECVPV-238-FIX01 FIM
									}
                                    temPagtoParcial = true;
                                }
                            }
                        }
                    }
                }
                temPagtoParcial = false;
            }

            //  LECVP-318 - FIX - FIM

            // LECVPV-238-FIX01 INICIO
            if (!movimentosAGerar.isEmpty()) {
                 insert movimentosAGerar;
            }
            
            if(!idsGarantiasFechar.isEmpty()){
                List<PagamentoGarantia__c> garantiasFechar = 
                [ SELECT Id, Fase__c, Status_do_pagamento__c FROM PagamentoGarantia__c WHERE ID IN :idsGarantiasFechar];
                List<PagamentoGarantia__c> garantiasUpdate = new List<PagamentoGarantia__c>();
                for (PagamentoGarantia__c pGarantia : garantiasFechar) {
                    garantiasUpdate.add(prepararGarantia(pGarantia, 'Fechado', 'Pago'));
                }
                update garantiasUpdate;
            }
            // LECVPV-238-FIX01 FIM

            if(!fecharCasos.isEmpty()){
                update fecharCasos;
            }
           
        }catch(Exception e){
            System.debug('Erro na tentativa de execucao' + e.getMessage() + ' na linha: ' + e.getLineNumber());
            
            if(!jobs.isEmpty() && jobs[0].Id != null){
                System.abortJob(jobs[0].Id);
            }
        }
    }

    private static PagamentoGarantia__c prepararGarantia(PagamentoGarantia__c garantia, String fase, String statusPgto){

        garantia.Fase__c = fase;
        garantia.Status_do_pagamento__c = statusPgto;

        return garantia;
    }
}
//LECVP-318 - FIM