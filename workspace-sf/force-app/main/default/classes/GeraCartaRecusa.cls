/*
PLV-4632 - CRIADO EM 22/11/2020
AUTOR: JEFERSON SANTANA
DESCRIÇÃO: classe responsavel por validar se existe carta recusa a ser enviada para o heroku
*/
public class GeraCartaRecusa {
    public GeraCartaRecusa(){
        
    }
    public static void validarCartaRecusa(List<Case>lsinistros){
        Set<Id>idsCasos = new Set<Id>();
        Map<Id,Case>mapCasos = new Map<Id, Case>();
        Boolean gerarPDF = true;
        
        Recordtype recIdSinistro = [select SobjectType, Id, DeveloperName from RecordType where SobjectType = 'Case' And DeveloperName = 'Sinistro' LIMIT 1];
        for(Case c : lsinistros){
            system.debug('status teste'+c.Status);
            system.debug('status Depen teste'+c.Status_Dependente__c);
           
            if(c.RecordTypeId == recIdSinistro.Id && c.Status == 'Fechado'){
                if(c.Status_Dependente__c == 'Recusado'){
                    idsCasos.add(c.Id);
                }else if(c.Status_Dependente__c == 'Pago'){
                    idsCasos.add(c.Id);
                    mapCasos.put(c.Id,c);
                }
                
            }

        }
        if(idsCasos.size()>0){
            List<PagamentoGarantia__c> garantiasRecusadas = [SELECT 
                                                             Caso__r.Id, 
                                                             Caso__r.Account.Name, 
                                                             Caso__r.Nome_do_Corretor__c, 
                                                             Caso__r.Codigo_Corretor__c,
                                                             Caso__r.ProdutoContratoFormula__c,
                                                             Caso__r.NumeroSinistro__c,
                                                             Caso__r.Email_para_envio_da_recusa__c,
                                                             Caso__r.Descricao_da_Recusa__c
                                                             FROM 
                                                             PagamentoGarantia__c 
                                                             WHERE Caso__c IN : (idsCasos)
                                                             AND Status_do_pagamento__c = 'Recusado' 
                                                             AND Fase__c = 'Fechado' 
                                                             AND Caso__r.EnvelopeIdDocusign__c = NULL //PLV-4665-FIX1 - INICIO/FIM
                                                            ];
            if(garantiasRecusadas.size() > 0){
                if(mapCasos.size()>0){
                    for(PagamentoGarantia__c pag : garantiasRecusadas){
                        if(mapCasos.get(pag.Caso__r.Id).Motivos_de_recusa__c == null || mapCasos.get(pag.Caso__r.Id).Email_para_envio_da_recusa__c == null){
                           system.debug('existe garantia recusada e campo descrição e email estão vazio');
                           gerarPDF = false; 
                           break;
                        }
                    }
                }                
                
                
                if(gerarPDF)
                	GeraPDFCartaRecusa(idsCasos);
                
                
            }
        }
    
    }
    
    @future (callout=true)
    public static void GeraPDFCartaRecusa(Set<Id> casos){
        Map<Id,ContentVersion> mContentVersion = new Map<Id,ContentVersion>();
        List<Case> casosSinistros = [select Id,
                               		   Nome_do_Corretor__c,
                               		   Account.Name,
                               		   ProdutoContratoFormula__c,
                               		   NumeroSinistro__c,
                               		   Codigo_Corretor__c,
                               		   Descricao_da_Recusa__c,
                                       Email_para_envio_da_recusa__c
                               from Case
                               where
                               Id IN: casos];
        
        PageReference pdf = Page.CartaRecusa;
        Map<String,String> mPDFParam = pdf.getParameters();
        mPDFParam.put('renderAs', 'pdf'); 
        mPDFParam.put('nomeCorretor', casosSinistros[0].Nome_do_Corretor__c +' '+casosSinistros[0].Codigo_Corretor__c);
        mPDFParam.put('nomeSegurado', casosSinistros[0].Account.Name);
        mPDFParam.put('produto',casosSinistros[0].ProdutoContratoFormula__c);
        mPDFParam.put('numeroSinistro', casosSinistros[0].NumeroSinistro__c);
        mPDFParam.put('observacao',casosSinistros[0].Descricao_da_Recusa__c);
        
        system.debug('observacao'+casosSinistros[0].Descricao_da_Recusa__c);
        
        system.debug('MAPPDF'+mPDFParam);
    
        
        string nomeCarta = 'Carta Recusa';
        
        ContentVersion file = new ContentVersion(
            Title = nomeCarta,
            VersionData = Test.IsRunningTest() ? Blob.valueOf('TEST') : pdf.getContentAsPDF(),
            PathOnClient ='/cartarecusa.pdf',
            origin = 'H'
        );
        mContentVersion.put(casosSinistros[0].Id, file);             

        if (mContentVersion.isEmpty()) return;
        
        insert mContentVersion.values();
        
        Map<Id, ContentVersion> mContentVersionInserted = new Map<Id, ContentVersion>(
            [SELECT Id, ContentDocumentId, Title, VersionData FROM ContentVersion WHERE Id IN :mContentVersion.values()]
        );
        
        List<ContentDocumentLink> lContentDocumentLink = new List<ContentDocumentLink>();     
       
        ContentDocumentLink fileLink = new ContentDocumentLink(
            LinkedEntityId = casosSinistros[0].Id,
            ContentDocumentId = mContentVersionInserted.get(mContentVersion.get(casosSinistros[0].Id).Id).ContentDocumentId,
            ShareType = 'V'
        ); 
        lContentDocumentLink.add(fileLink);
        insert lContentDocumentLink; 
        
        Map<String,String> mDadosPDF = new Map<String,String>();
        String bas64Encoder = EncodingUtil.base64Encode(mContentVersionInserted.get(mContentVersion.get(casosSinistros[0].Id).Id).versionData);
        mDadosPDF.put('base64',bas64Encoder);
        mDadosPDF.put('idcaso',casosSinistros[0].Id);
        mDadosPDF.put('email', casosSinistros[0].Email_para_envio_da_recusa__c);
        
        
        if(mDadosPDF.size()>0){
          ID jobID = System.enqueueJob(new AsyncEnviaArquivoHeroku(mDadosPDF));
        }
    }
        
    @future (callout=true)
	public static void enviaArquivoHeroku(Map<String, String>arquivosBase64) {
        system.debug('map nase64'+arquivosBase64);
        
        PastaECM__c pastaECM = PastaECM__c.getValues('carta recusa');
        GeraCartaRecusa.Body bodyjson = new GeraCartaRecusa.Body();
      	bodyjson.sfid = arquivosBase64.get('idcaso');
        bodyjson.base64 = arquivosBase64.get('base64');
        bodyjson.mailto = arquivosBase64.get('email');
        bodyjson.nomeArquivo = 'Caso'; //PLV-4665 - INCIO/FIM
		        
       	List<GeraCartaRecusa.Events> leventos = new List<GeraCartaRecusa.Events>();
        GeraCartaRecusa.Events eventos = new GeraCartaRecusa.Events();
        eventos.ecm = pastaECM.Id_Pasta__c;
        eventos.formato = 'json';
        eventos.path = '/caso/salvarRecusaSinistroDocusign'; //PLV-4634 INICIO/FIM
        eventos.status = 'lida';
        eventos.type = 'salesforce';
        
        leventos.add(eventos);        
        bodyjson.events = leventos;
        
        //GeraCartaRecusa gcr = new GeraCartaRecusa();
        
        //gcr.body = bodyjson;     
        String json = JSON.serializePretty(bodyjson);
        system.debug('obj'+bodyjson);
        if(!Test.isRunningTest())
        	HerokuService.getInstance().enviaCartaRecusa(json);
       
    }
    
    //public Body body {get;set;}

	public class Body {
        public String sfid{get;set;}
		public String mailto{get;set;}
		public String base64{get;set;}
        public String nomeArquivo{get;set;} //PLV-4665 - INCIO/FIM
        
        public List<Events> events {get;set;} 
	}
    public class Events {
		public String status {get;set;} 
		public String type {get;set;}
		public String path {get;set;} 
		public String ecm {get;set;} 
		public String formato {get;set;} 
    }
    
    public class AsyncEnviaArquivoHeroku implements Queueable {
        Map<String,String> mDadosPDF1 = new Map<String,String>();
        public AsyncEnviaArquivoHeroku(Map<String,String> m){
            this.mDadosPDF1 = m;
        }
        public void execute(QueueableContext context) {
            
            GeraCartaRecusa.enviaArquivoHeroku(this.mDadosPDF1);
            
                   
        }
    }
    
}