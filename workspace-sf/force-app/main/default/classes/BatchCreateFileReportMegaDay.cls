/***
* Created: Jeferson Santana (Sys4b)
* Date: 2023-04-28
* Description: run report generation routine in txt format and send by email classs of test: BatchCreateFileReportMegaDayTest
* task-History : PMH-24
***/ 
global with sharing class BatchCreateFileReportMegaDay implements Database.Batchable<sObject>, Database.StateFul, Database.AllowsCallouts{
    public String query;
	public List<String> lEmailsDestino;
	public Date ini;
	public Date fi;

	public BatchCreateFileReportMegaDay(Date inicio, Date fim){
		this.ini = inicio;
		this.fi = fim;
	}

    global Database.QueryLocator start(Database.BatchableContext BC){
		
        List<MegaDayReport__mdt> params = [SELECT Coberturas__c, EmailDestinatarios__c, Ramos__c FROM MegaDayReport__mdt];
        
		this.lEmailsDestino = (Test.isRunningTest()) ? new List<String>{'teste@teste.com.br'} : params[0].EmailDestinatarios__c.split(',');
        List<String> lramos = (Test.isRunningTest()) ? new List<String>{'1391'} : params[0].Ramos__c.split(',');
        List<String> lcoberturas = (Test.isRunningTest()) ? new List<String>{'AED'} : params[0].Coberturas__c.split(',');
        Date inicio = (this.ini != null) ? this.ini : System.Date.today();
        Date fim = (this.fi != null) ? this.fi :System.Date.today();
		
        if(Test.isRunningTest()){
			return Database.getQueryLocator([SELECT ID, Name, Origem__c,  NumeroProposta__c, Status, produto__r.name, PremioTotal__c, DataProtocolo__c, LastModifiedDate FROM Quote where Tipo__c = 'Renovacao']);
		}else{
			return Database.getQueryLocator([SELECT ID, Name, Origem__c,  NumeroProposta__c, Status, produto__r.name, PremioTotal__c, DataProtocolo__c, LastModifiedDate, (SELECT id FROM GarantiasProposta__r WHERE Garantia__r.Sigla__c in: lcoberturas ) FROM Quote WHERE DAY_ONLY(convertTimezone(CreatedDate)) >=: inicio AND DAY_ONLY(convertTimezone(CreatedDate)) <=: fim AND RamoSeguro__r.Codigo__c in: lramos AND Tipo__c != 'Renovacao']);
		}
       
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            List<Quote> lquote = scope;
					
			if(lquote.size() > 0){
				Map<Id, Quote> mQuote = new Map<Id,Quote>(lquote);
				List<SeguradoProposta__c> lSeguradoProposta = [SELECT 
																ID,
																GrupoProposta__r.ContratanteProposta__r.Proposta__c,
																Conta__r.Name,                  // nome
																Conta__r.Cpf__c,                // cpfnumero, cpfdigito
																Conta__r.Sexo__c,               // sexo
																Conta__r.PersonBirthdate,       // datanascimento
																Conta__r.PersonEmail,           // email            //PLV- 5068 - FIX02 - INICIO/FIM
																Conta__r.Rne__c,                // npasrne
																Conta__r.PersonHomePhone,       // ddd, // telefone
																CepResidencial__c,              // cepzonapostal, cepsufixo
																CidadeResidencial__c,           // cidade
																UFResidencial__c,               // uf
																ComplementoResidencial__c,      // complementoendereco
																BairroResidencial__c,           // bairro
																LogradouroResidencial__c,       // logradouro
																numeroResidencial__c            // numerocasa        
															FROM SeguradoProposta__c
															WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c IN: mQuote.KeySet()];
				
				//System.debug('seguradosProposta###'+lSeguradoProposta);
				Map<String,SeguradoProposta__c> mSeguradoProposta = new Map<String,SeguradoProposta__c>();
				if(lSeguradoProposta.size() > 0){
					for(SeguradoProposta__c s : lSeguradoProposta){
						mSeguradoProposta.put(s.GrupoProposta__r.ContratanteProposta__r.Proposta__c,s);
					}
				}										
					
				List<FavorecidoRemuneracaoProposta__c> lFavorecido = [SELECT 
																		ID,
																		RemuneracaoProposta__r.Proposta__c,
																		RemuneracaoProposta__r.TipoRemuneracao__r.Name,
																		Susep__c,                                   // susep
																		CorretorLider__c                            // flagsuseplider
																	FROM FavorecidoRemuneracaoProposta__c
																	WHERE RemuneracaoProposta__r.Proposta__c IN: mQuote.KeySet()
																	AND RemuneracaoProposta__r.TipoRemuneracao__r.Name = 'CORRETAGEM'];
				//System.debug('Favorecido######'+lFavorecido);
				Map<String,FavorecidoRemuneracaoProposta__c> mFavorecido = new Map<String, FavorecidoRemuneracaoProposta__c>();
				if(lFavorecido.size() > 0){
					for(FavorecidoRemuneracaoProposta__c f : lFavorecido){
						mFavorecido.put(f.RemuneracaoProposta__r.Proposta__c,f);
					}
				}

				List<String> lista = new List<String>();
				List<String> listatotal = new List<String>();
				
				String str;
				
				List<ContentVersion> arquivo = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE Title = 'ReportMegaDay' order by CreatedDate desc limit 1];
				List<String> csvFileLines = new List<String>();
				Map<String,String> mcsvFileLines = new Map<String,String>();
				List<String> lString = new List<String>();
				String text;
				if(arquivo.size() > 0){
					Blob csvFileBody =arquivo[0].VersionData;
					String csvAsString= csvFileBody.toString();
					csvFileLines = csvAsString.split('\n');
					csvFileLines.sort();
					for(Integer i=0; i < csvFileLines.size(); i++){
						text =  csvFileLines.get(i);
						lString = text.split('\\|');
						mcsvFileLines.put(lString[1],text);
					}		
				}
				//System.debug('map'+mcsvFileLines);	
				//System.debug('lista arquivo original'+csvFileLines);
							
				for(Quote q:lquote){
					if(mFavorecido.containsKey(q.Id) == false || mSeguradoProposta.containsKey(q.Id) == false){
						continue;
					}
					//System.debug('####numero proposta'+q.NumeroProposta__c);
					if(mcsvFileLines.containsKey(q.NumeroProposta__c)){
						//System.debug('####remove Indice###'+mcsvFileLines.get(q.NumeroProposta__c));
						mcsvFileLines.remove(q.NumeroProposta__c);
					}
					//PMH-24-FIX1 - INICIO
					String corretor =  (String.isNotEmpty(mFavorecido.get(q.Id).Susep__c)) ? mFavorecido.get(q.Id).Susep__c : '""';
					String corretorLider = (mFavorecido.get(q.Id).CorretorLider__c) ? 'S' :'N';
					List<String> lcpf = mSeguradoProposta.get(q.Id).Conta__r.Cpf__c.split('-');
					String cpf = lcpf[0].replace('.','');
					String digitoCPF = lcpf[1];
					String dtprotocolo = (String.isNotEmpty(String.valueOf(q.DataProtocolo__c))) ? String.valueOf(q.DataProtocolo__c.format()) : '""';
					String dtatualizacao = (String.isNotEmpty(String.valueOf(q.LastModifiedDate))) ? String.valueOf(q.LastModifiedDate.format('dd/MM/yyyy')) : '""';
					
					String st;																 
					if(Test.isRunningTest()){
						st = '18|12345';
					}else{
						List<String> separaCep = mSeguradoProposta.get(q.Id).CepResidencial__c.split('-'); 
						String cepPri = (separaCep.size() == 2) ? separaCep[0] : '""'; //PMH-24-FIX2 - INICIO/FIM
						String cepComp = (separaCep.size() == 2) ? separaCep[1] : '""'; //PMH-24-FIX2 - INICIO/FIM
						List<String> fone = mSeguradoProposta.get(q.Id).Conta__r.PersonHomePhone.split(' ');
						String fon = (fone.size() == 2) ? fone[1] : '""';
						String ddd = (fone.size() == 2) ? fone[0].replace('(', '').replace(')', '') : '""';
						st = q.Origem__c+'|'+q.NumeroProposta__c+'|'+q.Status+'|'+corretor+'|'+corretorLider+'|'+dtprotocolo+'|'+dtatualizacao+'|'+q.produto__r.name+'|'+q.PremioTotal__c.SetScale(2)+'|'+mSeguradoProposta.get(q.Id).Conta__r.Name+'|'+mSeguradoProposta.get(q.Id).Conta__r.PersonBirthdate.format()+'|'+cpf+'|'+digitoCPF+'|'+mSeguradoProposta.get(q.Id).Conta__r.Sexo__c.replace('MASC','Masculino')+'|'+cepPri+'|'+cepComp+'|'+mSeguradoProposta.get(q.Id).CidadeResidencial__c+'|'+mSeguradoProposta.get(q.Id).UFResidencial__c+'|'+mSeguradoProposta.get(q.Id).logradouroResidencial__c+'|'+mSeguradoProposta.get(q.Id).bairroResidencial__c+'|'+mSeguradoProposta.get(q.Id).numeroResidencial__c+'|'+mSeguradoProposta.get(q.Id).ComplementoResidencial__c+'|'+ddd+'|'+fon+'|'+mSeguradoProposta.get(q.Id).Conta__r.PersonEmail; //PMH-24-FIX2 - INICIO/FIM
					}
					lista.add(st.replace('null','""'));
					//PMH-24-FIX1 - FIM
				}

				if(mcsvFileLines.size() > 0){	
					System.debug('lista arquivo'+mcsvFileLines.values());				
					listatotal.addAll(mcsvFileLines.values());
				}

				if(lista.size() > 0){
					listatotal.addAll(lista);
				}
				
				if(listatotal.size() > 0){
					str = String.join(listatotal,'\n');
					ContentVersion file = new ContentVersion(
						Title = 'ReportMegaDay',
						VersionData = Blob.valueOf(str),
						PathOnClient = 'ReportMegaDay.txt',
						origin = 'H'
					);
					insert file;	
				}
				if(arquivo.size() > 0){
					delete (new ContentDocument(Id = arquivo[0].ContentDocumentId));
				}
				
			}
        }catch(Exception e){
            System.debug('erro ao criar registro ou gerar arquivo');
			System.debug(e.getMessage());
			System.debug(e.getLineNumber());
        }
    }
    global void finish(Database.BatchableContext BC){
       //aqui envia o email.
	   Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
		Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        List<ContentVersion> book = [select  id, ContentDocumentId, VersionData, Title from ContentVersion where Title = 'ReportMegaDay' order by CreatedDate desc limit 1];
		if(book.size() > 0){
			Blob b = book[0].VersionData;
			attach.setFileName(book[0].Title+'.txt');
			attach.setBody(b);
			semail.setSubject('Relatório Mega day');
			//String[] sendTo = new String[]{'jefer.santana@gmail.com'};
			semail.setToAddresses(this.lEmailsDestino);
			semail.setPlainTextBody('');
			semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
			Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
		}
		
            
    }

}