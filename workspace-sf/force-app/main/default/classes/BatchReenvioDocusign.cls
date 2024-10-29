/*********************************************************************************************************************************************************************
@description  Realiza o envio do documento de proposta para DOCUSIGN
@author Carlos Pessoa - META
@date 10/11/2020
@Classe criada por conta da história PLV-4471    
**********************************************************************************************************************************************************************/

global class BatchReenvioDocusign implements Database.Batchable<sObject>, Database.StateFul, Database.AllowsCallouts, Schedulable {
    

    public BatchReenvioDocusign(){}

    global List<CriticaProposta__c> listCriticaUpdate = new List<CriticaProposta__c>();
    // PLV-4552 - FIX 2
    // PLV-4839-FIX 4 - INICIO
    // global List<CriticaOrcamento__C> listCriticaOrcamentoUpdate = new List<CriticaOrcamento__C>();
    // PLV-4839-FIX 4 - FIM
    global List<Quote> listPropostaUpdate = new List<Quote>();

    global Database.QueryLocator start(Database.BatchableContext BC){
        // PLV-4545
        // PLV-4839-FIX 5 INICIO
        String query = 'SELECT Id, Name, RealizarEnvioDocusign__c, OpportunityId FROM Quote WHERE RealizarEnvioDocusign__c = true AND Status = \'Em análise\' Order By CreatedDate DESC LIMIT 100'; 
        // PLV-4839-FIX 5 FIM
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('BatchReenvioDocusign - Docusign - Enviado');
        try{
            List<Quote> listProposta = (List<Quote>) scope;
            List<Id> listContentId = new List<Id>();
            List<Id> listIdProposta = new List<Id>();

            //PLV-5155 - INICIO
            List<CriticaProposta__c> criticaPayload = new List<CriticaProposta__c>();
            //PLV-5155 - FIM

        // PLV-4545
            // PLV-4839-FIX 4 - INICIO
            // List<Id> listIdOrcamento = new List<Id>();
            // PLV-4839-FIX 4 - FIM
            
            Map<String, Blob> mapVersionData = new Map<String, Blob>();
            Map<String, String> mapPropostaContent = new Map<String, String>();
            Map<String, String> mapEmailContratante = new Map<String, String>();
            Map<String, CriticaProposta__c> mapCritica = new Map<String, CriticaProposta__c>();
            // PLV-4839-FIX 3 - INICIO
            Map<String, CriticaProposta__c> mapCriticaSampleMed = new Map<String, CriticaProposta__c>();
            List<CriticaProposta__c> listCriticaSampleMed = [SELECT Id, Proposta__c, Status__c, Acao__c
                                                            FROM CriticaProposta__c 
                                                            WHERE Proposta__c IN: listProposta AND Integracao__c = 'SAMPLE']; 

                                                            
            for(CriticaProposta__c cp : listCriticaSampleMed){
                mapCriticaSampleMed.put(cp.Proposta__c, cp);
            }
            // PLV-4839-FIX 3 - FIM
            // PLV-4545
            // PLV-4552 - FIX 2
            // PLV-4839-FIX 4 - INICIO
            // Map<String, CriticaOrcamento__c> mapCriticaOrcamento = new Map<String, CriticaOrcamento__c>();
            // PLV-4839-FIX 4 - FIM
            // PLV-4552

            //INICIO | PLV-4647-VI-Guilherme Brito
            // PLV-4552 - FIX 2
            // PLV-4839-FIX 3 - INICIO
            List<CriticaProposta__c> listCriticaProposta = [SELECT Id, Proposta__c, Status__c, Acao__c, MomentoAnalise__c
                                                            FROM CriticaProposta__c 
                                                            WHERE Proposta__c IN: listProposta AND (Status__c = 'Pendente' OR Status__c = 'Em aprovação') AND Integracao__c = 'DOCUSIGN']; 
            // PLV-4839-FIX 3 - FIM
            //FIM| PLV-4647-VI-Guilherme Brito

            for(Quote proposta : listProposta){
                listIdProposta.add(proposta.Id);
        // PLV-4545
            // PLV-4839-FIX 4 - INICIO
            // listIdOrcamento.add(proposta.OpportunityId);
            // PLV-4839-FIX 4 - FIM
            }
            List<ContentDocumentLink> listCdi = [SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId IN: listIdProposta
                                                AND ContentDocument.Title LIKE 'Proposta_%' Order By ContentDocument.CreatedDate DESC];
            List<ContratanteProposta__c> listContratante = [SELECT Id, Conta__r.PersonEmail, Proposta__c FROM ContratanteProposta__c WHERE Proposta__c IN: listProposta AND Tipo__c = 'Principal']; 

            for(CriticaProposta__c cp : listCriticaProposta){
                mapCritica.put(cp.Proposta__c, cp);
            }
            
            for(ContentDocumentLink cdi : listCdi){
                if(!listContentId.contains(cdi.ContentDocumentId))
                    listContentId.add(cdi.ContentDocumentId);
                if(mapPropostaContent.get(cdi.LinkedEntityId) == null)
                    mapPropostaContent.put(cdi.LinkedEntityId, cdi.ContentDocumentId);
            }

            
            for(ContratanteProposta__c contratante : listContratante){
                mapEmailContratante.put(contratante.Proposta__c, contratante.Conta__r.PersonEmail);
            }

            List<ContentVersion> listCV = [SELECT id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId IN: listContentId];	
            
            for(ContentVersion cv : listCV){
                mapVersionData.put(cv.ContentDocumentId, cv.VersionData);
            }
		
        // PLV-4545
        
        //INICIO | PLV-4647-VI-Guilherme Brito
        // PLV-4552 FIX 2 INICIO
        // PLV-4839-FIX 4 - INICIO
        // for(CriticaOrcamento__c co : [SELECT Id, Acao__c, Orcamento__c , Justificativa__c FROM CriticaOrcamento__c WHERE Orcamento__c IN: listIdOrcamento AND Origem__c = 'ODM' AND Status__c = 'Pendente']){
        //     mapCriticaOrcamento.put(co.Orcamento__c, co);
        // }
        // PLV-4839-FIX 4 - FIM
        // PLV-4552 FIX 2 FIM
        //FIM| PLV-4647-VI-Guilherme Brito

            //PLV-5155 - INICIO
            List<PayloadDocusignTO> payloads =  new List<PayloadDocusignTO>(); 
            String returnService;
            //PLV-5155 - FIM
            
            for(Quote proposta : listProposta){
                PayloadDocusignTO payload = new PayloadDocusignTO();
                Blob cv = mapVersionData.get(mapPropostaContent.get(proposta.Id));
                CriticaProposta__c critica = mapCritica.get(proposta.Id);
                // PLV-4839-FIX 3 INICIO
                CriticaProposta__c criticaSample = mapCriticaSampleMed.get(proposta.Id);
                // PLV-4839-FIX 3 FIM
                // PLV-4552 - FIX 2
                // PLV-4839-FIX 4 - INICIO
                // CriticaOrcamento__c criticaOrcamento = mapCriticaOrcamento.get(proposta.OpportunityId);
                // PLV-4839-FIX 4 - FIM
                
        // PLV-4545
                // PLV-4552 - INICIO
                // PLV-4839-FIX 3 - INICIO ------------
                String brandId = null;
                // PLV-4839-FIX 4 - INICIO
                if(critica != null && critica.MomentoAnalise__c == 'Recalculo'){
                // PLV-4839-FIX 4 - FIM
                    brandId = Canal_Subscricao__c.getValues('agravo') != null ? Canal_Subscricao__c.getValues('agravo').Marca_Docusign__c : null;
                }else if(criticaSample != null ){
                    brandId = Canal_Subscricao__c.getValues(criticaSample.acao__c) != null ? Canal_Subscricao__c.getValues(criticaSample.acao__c).Marca_Docusign__c : null;
                }else{
                    brandId = Canal_Subscricao__c.getValues('QTR_INTERNO') != null ? Canal_Subscricao__c.getValues('QTR_INTERNO').Marca_Docusign__c : null;
                }
                // if(mapCriticaOrcamento.get(proposta.OpportunityId) != null && mapCriticaOrcamento.get(proposta.OpportunityId).Acao__c != null){
                //     if(criticaOrcamento != null)
                //         brandId = Canal_Subscricao__c.getValues(criticaOrcamento.Acao__c) != null ? Canal_Subscricao__c.getValues(criticaOrcamento.Acao__c).Marca_Docusign__c : null;
                // }
                // // PLV-4552 FIX 2 INICIO
                // Boolean brandCritica = false;
                // if(brandId == null && critica != null){
                //     brandId = Canal_Subscricao__c.getValues(critica.Acao__c) != null ? Canal_Subscricao__c.getValues(critica.Acao__c).Marca_Docusign__c : null; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
                //     brandCritica = true;
                // }else{
                //     brandCritica = false;
                // }
                // PLV-4839-FIX 3 - FIM ----------------
                // PLV-4552 FIX 2 FIM
                // PLV-4552 - FIM
                 
                payload.sfid = proposta.Id;
                payload.name = proposta.name; //PLV-4839
                payload.mailTo = mapEmailContratante.get(proposta.Id);
                // PLV-4552
                if(cv != null)
                    payload.base64 = EncodingUtil.base64Encode(cv);
                payload.nomeArquivo = 'Proposta';//PLV-4665 - INICIO/FIM
                // PLV-4545 INICIO
                payload.brandId = brandId;
                payload.events = new List<Event>();
                Event event = new Event();
                event.status = 'assinada';
                // PLV-4839-INICIO
                event.path = '/services/apexrest/retornoDocusign';
                event.ecm = String.valueOf(PastaECM__c.getValues('Proposta').Id_Pasta__c);
                event.formato = 'pdf';
                // PLV-4839-FIM
                payload.events.add(event);
                // PLV-4545 FIM
                //String returnService; //PLV-5155 - INICIO/FIM
        // PLV-4545
                // PLV-4839-FIX 3 - INICIO
                // PLV-4552 - INICIO FIX
                if(critica != null && brandId != null && cv != null){
                    //PLV-5155 - INICIO
                    //returnService = !Test.isRunningTest() ? HerokuService.getInstance().enviarAssinaturaDigital(JSON.serialize(payload)) : 'Enviado';
                    payloads.add(payload); 
                    criticaPayload.add(critica);
                    //PLV-5155 - FIM
                    System.debug('Tem critica e tem brandId');
                    System.debug(JSON.serialize(payload));
                }else{
                    System.debug('Critica: ' + critica);
                    System.debug('brandId: ' + brandId);
                    System.debug('cv: ' + cv);
                    //returnService = 'error'; //PLV-5155 - INICIO/FIM
                }
                // PLV-4552 - FIM FIX
                //PLV-5155 - INICIO
                // if(returnService != 'error'){
                //     critica.Status__c = 'Em aprovação';
                //     proposta.RealizarEnvioDocusign__c = false;
                //     listPropostaUpdate.add(proposta);
                //     listCriticaUpdate.add(critica);
                // }else{
                //     System.debug('ERRO AO ENVIAR DOCUMENTO DOCUSIGN');
                //     System.debug('Critica: ' + critica);
                //     System.debug('brandId: ' + brandId);
                //     System.debug('cv: ' + cv);
                // }		
                //PLV-5155 - FIM
                // PLV-4839-FIX 3 - FIM

            }

            //PLV-5155 - INICIO
            //PLV-5675 - INICIO
            //returnService = !Test.isRunningTest() ? HerokuService.getInstance().enviarAssinaturaDigital(JSON.serialize(payloads)) : 'Enviado'; 
            
            //MGRC-1253 - INICIO
            // returnService = !Test.isRunningTest() ? CIVServices.getInstance().sendDocusign(JSON.serialize(payloads)) : 'Enviado'; 
            returnService = !Test.isRunningTest() ? SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.DOCUSIGN, JSON.serialize(payloads)): 'Enviado';
            //MGRC-1253 - FIM
            
            //PLV-5675 - FIM
            if(returnService != 'error'){
                for(Quote proposta : listProposta){                    
                    proposta.RealizarEnvioDocusign__c = false;
                    listPropostaUpdate.add(proposta);                    
                }
                for(CriticaProposta__c criticaEnvio : criticaPayload){
                    criticaEnvio.Status__c = 'Em aprovação';
                    listCriticaUpdate.add(criticaEnvio);
                }
            }else{
                System.debug('ERRO AO ENVIAR DOCUMENTO DOCUSIGN');                
            }	
            //PLV-5155 - FIM


		}catch(Exception ex){
			System.debug('Erro ao enviar docusign - > BatchReenvioDocusign');
			System.debug(ex.getMessage());
			System.debug(ex.getLineNumber());
		}
		
    }

    global void finish(Database.BatchableContext BC){
        Database.SaveResult[] srList = Database.update(listCriticaUpdate, false);
        Database.SaveResult[] srList2 = Database.update(listPropostaUpdate, false);
        // PLV-4552 FIX 2
        // PLV-4839-FIX 4 - INICIO
        // Database.SaveResult[] srList3 = Database.update(listCriticaOrcamentoUpdate, false);
        // PLV-4839-FIX 4 - FIM

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully updated CriticaProposta__c. CriticaProposta__c ID: ' + sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('CriticaProposta__c fields that affected this error: ' + err.getFields());
                }
            }
        }

        for (Database.SaveResult sr : srList2) {
            if (sr.isSuccess()) {
                System.debug('Successfully updated Quote. Quote ID: ' + sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Quote fields that affected this error: ' + err.getFields());
                }
            }
        }
        // PLV-4552 FIX 2 INICIO
        // PLV-4839-FIX 4 - INICIO
        // for (Database.SaveResult sr : srList3) {
        //     if (sr.isSuccess()) {
        //         System.debug('Successfully updated CriticaOrcamento__c. CriticaOrcamento__c ID: ' + sr.getId());
        //     }
        //     else {
        //         for(Database.Error err : sr.getErrors()) {
        //             System.debug('The following error has occurred.');                    
        //             System.debug(err.getStatusCode() + ': ' + err.getMessage());
        //             System.debug('CriticaOrcamento__c fields that affected this error: ' + err.getFields());
        //         }
        //     }
        // }
        // PLV-4839-FIX 4 - FIM
        // PLV-4552 FIX 2 FIM
    }
    
    public class PayloadDocusignTO {
		public String sfid { get; set; }
		public String name { get; set; } //PLV-4839
		public String mailto { get; set; }
        public String nomeArquivo{set;get;} //PLV-4665 - INICIO/FIM
		// PLV-4545
		public List<Event> events { get; set; }
		public String base64 { get; set; }
		// PLV-4545
		public String brandId { get; set; }
    }
    // PLV-4545 INICIO
    public class Event {
        public String status { get; set; }
        public String type = 'salesforce';
        public String path { get; set; }
        public String ecm { get; set; }
        public String formato { get; set; }
    }
    // PLV-4545 FIM    
    global void execute(SchedulableContext sc) {
        BatchReenvioDocusign b = new BatchReenvioDocusign(); 
        database.executebatch(b);
    }

    global void agendarBatch(){
        System.schedule('BatchReenvioDocusign Agendado > 30 minutos','0 0 * * * ?',new BatchReenvioDocusign());
        System.schedule('BatchReenvioDocusign Agendado2 > 30 minutos','0 30 * * * ?',new BatchReenvioDocusign());
    }
}