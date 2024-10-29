/*********************************************************************************************************************************************************************
@description Classe batch responsavel por dar baixar nos casos de sinistro com Reserva 
@author Rogerio Souza de Menezes - Globant
@date 10/08/2023
**********************************************************************************************************************************************************************/
//II-59 INICIO
global class BatchBaixaReserva implements Database.Batchable<sObject>, Database.StateFul, Database.AllowsCallouts, Schedulable {

    List<Constante__mdt> constante = MetadataDAO.getInstance().buscarConstante('DATA_CORTE_SINISTRO');
    //FNPVVEP-19 - INICIO
    List<Constante__mdt> limite = MetadataDAO.getInstance().buscarConstante('LIMITE_BATCH_BAIXA_RESERVA');

    Integer ultimosDias = Integer.valueOf(constante[0].Valor__c);
    Date dataCorte = Date.today().addDays(-ultimosDias);
    global final Integer limiteQuery = Integer.valueOf(limite[0].Valor__c);
    //FNPVVEP-19 - FIM

    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(
                [SELECT Id, RamoSplit__c, Owner.Name, Saldo_da_reserva__c, Status, CreatedDate
                    FROM Case
                    WHERE Type = 'Sinistro'
                        AND RamoSplit__c NOT IN (980, 1380)
                        AND Sinistro_Judicial__c  = false // II-59-FIX01-INICIO/FIM
                        AND Status != 'Fechado'
                        AND Saldo_da_reserva__c != null
                        AND Saldo_da_reserva__c > 0
                        AND PagtoAssistCardInternacional__c != 'Sim' //II-59-FIX06-INICIO/FIM
                        AND Data_sinistro_avisado__c < :dataCorte
                        AND ReservaNegativa__c = false //FNPVVEP-19 - INICIO/FIM
                    LIMIT : limiteQuery
                    ]
        );
    }

    global void execute(Database.BatchableContext batchableContext, List<Case> scope){
        baixarCasosReserva(scope);
    }

    global void execute(SchedulableContext schedulableContext){
        Database.executeBatch(this);
    }

    global void finish(Database.BatchableContext batchableContext){}

    global void agendarBatch(){
        String cron = '0 0 8 * * ?'; 
        String cron1 = '0 0 10 * * ?'; 
        String cron2 = '0 0 12 * * ?'; 
        String cron3 = '0 0 14 * * ?'; 
        String cron4 = '0 0 16 * * ?'; 
        system.schedule('BaixarReserva 8H',cron,this);
        system.schedule('BaixarReserva 10H',cron1,this);
        system.schedule('BaixarReserva 12H',cron2,this);
        system.schedule('BaixarReserva 14H',cron3,this);
        system.schedule('BaixarReserva 16H',cron4,this);
    }

    global void baixarCasosReserva(List<Case> casosReserva){    

        //FNPVVEP-19 - INICIO
        List<PagamentoGarantia__c> garantias = new List<PagamentoGarantia__c>();
        List<PagamentoGarantia__c> garantiaAFechar = new List<PagamentoGarantia__c>();
        List<MovimentoSinistro__c> movimentosGerados = new List<MovimentoSinistro__c>();
        List<Case> fecharCasos = new List<Case>();

        Set<Id> casosId = new Set<Id>(); //II-59-FIX02-INICIO
        Set<Id> setCase = new Set<Id>();

        Map<Id, List<PagamentoGarantia__c>> pagamentoGarantiaIndexedByCaseId = new Map<Id, List<PagamentoGarantia__c>>();

        PagamentoGarantia__c garantia = new PagamentoGarantia__c();
        MovimentoSinistroBO movSinBO = MovimentoSinistroBO.getInstance();

        for(Case casoMov : casosReserva){
            setCase.add(casoMov.id);
        }
        //II-59-FIX05-FIM

        Map<Id, Integer> mapSequencia = SequenciaMovimentoSinistroHelper.sequenciaMovimentos(setcase);

        List<PagamentoGarantia__c> pagamentoGarantias = PagamentoGarantiaDAO.getInstance().buscarCasosBySetId(setCase);  

        for(PagamentoGarantia__c pagGarantia : pagamentoGarantias){
            if(!pagamentoGarantiaIndexedByCaseId.containsKey(pagGarantia.Caso__c)){
                pagamentoGarantiaIndexedByCaseId.put(pagGarantia.Caso__c, new List<PagamentoGarantia__c>());
            }

            pagamentoGarantiaIndexedByCaseId.get(pagGarantia.Caso__c).add(pagGarantia);
        }

        for(Case caso : casosReserva){
            garantias = pagamentoGarantiaIndexedByCaseId.get(caso.Id);

            //II-59-FIX05-INICIO
            if(!garantias.isEmpty()){
                
                Integer iteradorMovimento = 0;

                for(PagamentoGarantia__c garantiasSinistro : garantias){

                    if(caso.Saldo_da_reserva__c >= 0){
                        garantia = verificarGarantia(garantiasSinistro);
                    
                        garantia = prepararGarantia(garantiasSinistro, garantia.Fase__c, garantia.Status_do_pagamento__c, '68');         
                        garantiaAFechar.add(garantia);
    
                        Case casoAFechar = new Case(Id = garantia.Caso__c, 
                                                    Status = garantia.Caso__r.Status, 
                                                    Saldo_da_reserva__c = garantia.Caso__r.Saldo_da_reserva__c, 
                                                    Status_Dependente__c = garantia.Caso__r.Status_Dependente__c, 
                                                    Motivos_de_recusa__c = '69'); //II-59 FIX01 INICIO-FIM        
                        
                        //II-59-FIX06-INICIO
                        if(garantiasSinistro.Saldo_da_reserva__c > 0){
    
                            Decimal valorMovimento = -1 * garantiasSinistro.Saldo_da_reserva__c;
                            Boolean permitirGerarMov = garantia.Saldo_da_reserva__c == 0 && garantia.Caso__r.Saldo_da_reserva__c == 0 ? false : true;
                            
                            iteradorMovimento = iteradorMovimento + 1;

                            Integer sequencia = mapSequencia.containsKey(caso.Id) ? mapSequencia.get(caso.Id) + iteradorMovimento : 1;
    
                            MovimentoSinistro__c movimentoGerado = movSinBO.criarMovimento(caso.Id, MovimentoSinistroTO.AC_AVISADO_MENOS, valorMovimento, String.valueOf(sequencia), garantiasSinistro.Id, false); //FNPVVEP-19 INICIO/FIM
                           
                            if(movimentoGerado != null && movimentoGerado.SinistroJudicial__c == false){
    
                                if(permitirGerarMov){
                                    movimentosGerados.add(movimentoGerado);
                                }
                                
                                if(!casosId.contains(casoAFechar.Id)){
                                    casosId.add(casoAFechar.Id);
                                    casoAFechar.Status = 'Fechado';
                                    fecharCasos.add(casoAFechar);
                                }
                                //II-59-FIX02-FIM
                            }         
                        }
                    //FNPVVEP-19 INICIO
                        if(garantiasSinistro.Saldo_da_reserva__c < 0){
                            caso.ReservaNegativa__c = true;
                            fecharCasos.add(caso);
                        }
                    }

                    if(caso.Saldo_da_reserva__c < 0){
                        caso.ReservaNegativa__c = true;
                        fecharCasos.add(caso);
                    }
                    //FNPVVEP-19 FIM

                    //II-59-FIX06-FIM
                    //II-59-FIX05-FIM                                           
                }
            }
        }
        //FNPVVEP-19 - FIM

    
        if(!garantiaAFechar.isEmpty()){
            update garantiaAFechar;
        }
        if(!fecharCasos.isEmpty()){
            update fecharCasos;
        }        
        if(!movimentosGerados.isEmpty()){
            insert movimentosGerados;
        }
    }

    private static PagamentoGarantia__c prepararGarantia(PagamentoGarantia__c garantia, String fase, String statusPgto, String motivoRecusa){
        garantia.Fase__c = fase;
        garantia.Status_do_pagamento__c = statusPgto;
        garantia.Motivo_da_Recusa__c = motivoRecusa;
        return garantia;
    }
    //II-59-FIX02-INICIO
    private static PagamentoGarantia__c verificarGarantia(PagamentoGarantia__c garantia){ 

        if(garantia.Fase__c == 'Fechado' && garantia.Status_do_pagamento__c == 'Pago' &&
            garantia.Caso__r.Status == 'Liquidação'){
                return garantia;
            }

        if(garantia.Fase__c != 'Fechado' && garantia.Status_do_pagamento__c != 'Pago' &&
            garantia.Caso__r.Status == 'Liquidação'){
                return garantia;
            }

        if(garantia.Fase__c != 'Fechado' && garantia.Status_do_pagamento__c != 'Pago' &&
             garantia.Caso__r.Status != 'Liquidação'){
                garantia.Caso__r.Status_Dependente__c = 'Cancelado';
                garantia.Fase__c = 'Fechado';
                garantia.Status_do_pagamento__c = 'Cancelado';
            }
         
         return garantia;
    }
    //II-59-FIX02-FIM
}
//II-59 FIM