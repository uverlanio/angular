/**
 * @description       : Para rodar o batch e gerar a nova garantia AFE 
 * @author            : Matheus Meneses,Rogerio Menezes,Veronice Boesing,Romeu Bonfim@
 * @group             : 
 * @last modified on  : 03-31-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class BatchAceleraAFE implements Database.Batchable<sObject>, Database.StateFul,Database.AllowsCallouts{
    //TODO : adicionar interface Schedulable 
    //coletar os lotes de registros

        global Set<Id> idContrato  { get; set; }
        global final Integer limite = 500;

        global BatchAceleraAFE(){
            this.idContrato = new Set<Id>();
        }

        global Database.QueryLocator start(Database.BatchableContext bc){
            return Database.getQueryLocator([
                SELECT Contrato__c, Contrato__r.Proposta__r.DataProtocolo__c, Contrato__r.Segmento__c, Contrato__r.Status, 
                       Contrato__r.PremioTotal__c, Garantia__r.Sigla__c, Contrato__r.Proposta__r.Status
                FROM GarantiaContrato__c 
                WHERE Contrato__r.Proposta__r.CreatedDate >= 2023-03-20T00:00:00Z //PLV-5795 FIX01 INICO-FIM 
                    AND Contrato__r.Proposta__r.CreatedDate <= 2023-03-24T23:59:59Z //PLV-5795 FIX01 INICO-FIM
                    AND Contrato__r.Proposta__r.Status = 'Contratada' 
                    AND Contrato__r.Segmento__c = 'Individual' 
                    AND Contrato__r.Status = 'Emitido' 
                    AND Contrato__r.PremioTotal__c >= 1200
                    AND Contrato__r.Tipo__c = 'Novo' //II-21 INCIO-FIM
                    AND (Garantia__r.Sigla__c = 'AFI' OR Garantia__r.Sigla__c = 'AFF')
                    LIMIT : limite //II-21 INCIO-FIM
                ]);
        }
        
        global void execute(Database.BatchableContext bc, List<GarantiaContrato__c> scope){     
            
            AssisFuneralCtr assFuneral = new AssisFuneralCtr();

            //II-21 FIX01 INICIO
            Set<Id> contratoIds = new Set<Id>();

            for(GarantiaContrato__c gc : scope){
                contratoIds.add(gc.Contrato__c);
            }

            List<GarantiaContrato__c> hasAFE = [SELECT Contrato__c, Contrato__r.Proposta__r.DataProtocolo__c, Contrato__r.Segmento__c, //II-21 FIX01 INICIO-FIM
                    Contrato__r.Status, 
                    Contrato__r.PremioTotal__c, Garantia__r.Sigla__c, Contrato__r.Proposta__r.Status
                FROM GarantiaContrato__c 
                WHERE Contrato__r.Proposta__r.CreatedDate >= 2023-03-20T00:00:00Z 
                    AND Contrato__r.Proposta__r.CreatedDate <= 2023-03-24T23:59:59Z 
                    AND Contrato__r.Proposta__r.Status = 'Contratada' 
                    AND Contrato__r.Segmento__c = 'Individual' 
                    AND Contrato__r.Status = 'Emitido' 
                    AND Contrato__r.PremioTotal__c >= 1200
                    AND Contrato__r.Tipo__c = 'Novo' 
                    AND Garantia__r.Sigla__c = 'AFE'
                    AND Contrato__c IN: contratoIds];

            Set<Id> contratoIdsToRemove = new Set<Id>();
            for(GarantiaContrato__c gc : hasAFE){
                contratoIdsToRemove.add(gc.Contrato__c);
            }

            List<GarantiaContrato__c> scopeWithoutAFE = new List<GarantiaContrato__c>();
            for (GarantiaContrato__c gc : scope) {
                if (!contratoIdsToRemove.contains(gc.Contrato__c)) {
                    scopeWithoutAFE.add(gc);
                }
            }
            //II-21 FIX01 FIM

            Garantia__c afe = [SELECT Id, Name, Sigla__c FROM Garantia__c WHERE Sigla__c ='AFE'];
            
            Map<Id, List<GarantiaContrato__c>> assuranceIndexedByContract = AssisFuneralCtr.getAssuranceMap(scopeWithoutAFE); //II-21 FIX01 INICIO-FIM
            
            this.idContrato.addAll(assuranceIndexedByContract.keySet());
            //II-21 INCIO
            List<GarantiaProduto__c> garantiaProdutoList = assFuneral.getGarantiaProduto(); 

            assFuneral.insertAssurance(assuranceIndexedByContract, afe, garantiaProdutoList);

            assFuneral.insertGarantiaContratanteCtr(assuranceIndexedByContract.keySet(), afe, garantiaProdutoList);

            assFuneral.insertGarantiaGrupoContratanteCtr(assuranceIndexedByContract.keySet(), afe, garantiaProdutoList);

            assFuneral.insertGarantiaSeguradoCtr(assuranceIndexedByContract.keySet(), afe, garantiaProdutoList);
            //II-21 FIM

            //Set<Id> contractId = assuranceIndexedByContract.keySet();

            //AssisFuneralCtr.criarApoliceSync(contractId);
        }

        global void finish(Database.BatchableContext bc){
           AssisFuneralCtr.criarApoliceSync(this.idContrato); 
        }

        global void execute(SchedulableContext sc) {
            BatchAceleraAFE b = new BatchAceleraAFE(); 
            database.executebatch(b);
        }
}