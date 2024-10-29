/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-31-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class BatchAceleraAssistenciaFuneral implements Database.Batchable<sObject>, Database.StateFul,Database.AllowsCallouts{
    //TODO : adicionar interface Schedulable 
    //coletar os lotes de registros

        global Set<Id> idContrato  { get; set; }

        global BatchAceleraAssistenciaFuneral(){
            this.idContrato = new Set<Id>();
        }

        global Database.QueryLocator start(Database.BatchableContext bc){
            return Database.getQueryLocator([
                SELECT Contrato__r.Proposta__r.DataProtocolo__c, Contrato__r.Segmento__c, Contrato__r.Status, 
                       Contrato__r.PremioTotal__c, Garantia__r.Sigla__c, Contrato__r.Proposta__r.Status
                FROM GarantiaContrato__c 
                WHERE Contrato__r.Proposta__r.DataProtocolo__c >= 2023-03-20 
                    AND Contrato__r.Proposta__r.DataProtocolo__c <2023-03-25
                    AND Contrato__r.Proposta__r.Status = 'Contratada' 
                    AND Contrato__r.Segmento__c = 'Individual' 
                    AND Contrato__r.Status = 'Emitido' 
                    AND Contrato__r.PremioTotal__c >= 1200 
                    AND (Garantia__r.Sigla__c = 'AFI' OR Garantia__r.Sigla__c = 'AFF')]);
        }
        
        global void execute(Database.BatchableContext bc, List<GarantiaContrato__c> scope){     
            
            AssisFuneralCtr assFuneral = new AssisFuneralCtr();

            Garantia__c afe = [SELECT Id, Name, Sigla__c FROM Garantia__c WHERE Sigla__c ='AFE'];

            Map<Id, List<GarantiaContrato__c>> assuranceIndexedByContract = AssisFuneralCtr.getAssuranceMap(scope);

            
            this.idContrato.addAll(assuranceIndexedByContract.keySet());

            assFuneral.insertAssurance(assuranceIndexedByContract, afe);

            assFuneral.insertGarantiaContratanteCtr(assuranceIndexedByContract.keySet(), afe);

            assFuneral.insertGarantiaGrupoContratanteCtr(assuranceIndexedByContract.keySet(), afe);

            assFuneral.insertGarantiaSeguradoCtr(assuranceIndexedByContract.keySet(), afe);

            //Set<Id> contractId = assuranceIndexedByContract.keySet();

            //AssisFuneralCtr.criarApoliceSync(contractId);
        }

        global void finish(Database.BatchableContext bc){
           AssisFuneralCtr.criarApoliceSync(this.idContrato); 
        }

        global void execute(SchedulableContext sc) {
        BatchAceleraAssistenciaFuneral b = new BatchAceleraAssistenciaFuneral(); 
        database.executebatch(b);
        }
}