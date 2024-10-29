public with sharing class EmailFileReport {
    
	public static void createFile(){
		//cria arquivo e vincula ao objeto Arquivo_Integracao__c
		List<String> lista = new List<String>();
		List<String> listatotal = new List<String>();
		String str;
		String header = 'Id|Name';
		//lista.add(header);

		List<ContentVersion> arquivo = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE Title = 'Teste report' order by CreatedDate desc limit 1];
		List<String> csvFileLines = new List<String>();
		if(arquivo.size() > 0){
			Blob csvFileBody =arquivo[0].VersionData;
			String csvAsString= csvFileBody.toString();
			csvFileLines = csvAsString.split('\n');
			system.debug('teste santana'+csvFileLines);
			system.debug('teste santana String'+csvFileLines);
			
		}
		if(csvFileLines.size() > 0){
			listatotal.addAll(csvFileLines);
		}
		/*List<Quote> lquote = [SELECT Id, name FROM Quote limit 20];
		for(Quote q:lquote){
			String st = q.Id+'|'+q.Name;
			lista.add(st);
		}
		if(lista.size() > 0){
			listatotal.addAll(lista);
		}*/

		List<MegaDayReport__mdt> params = [SELECT Coberturas__c, EmailDestinatarios__c, Ramos__c FROM MegaDayReport__mdt];
       
        List<String> lramos = params[0].Ramos__c.split(',');
        List<String> lcoberturas = params[0].Coberturas__c.split(',');
        Date inicio = System.today();
        Date fim = System.today();
        List<Quote> lquote = [SELECT ID, Name, Origem__c,  NumeroProposta__c, Status, produto__r.name, PremioTotal__c, DataProtocolo__c, LastModifiedDate, (SELECT id FROM GarantiasProposta__r WHERE Garantia__r.Sigla__c in: lcoberturas ) FROM Quote WHERE DAY_ONLY(convertTimezone(CreatedDate)) >=: inicio AND DAY_ONLY(convertTimezone(CreatedDate)) <=: fim AND RamoSeguro__r.Codigo__c in: lramos AND Tipo__c != 'Renovacao'];
		Map<Id, Quote> mQuote = new Map<Id,Quote>(lquote);

		System.debug(mQuote.keySet());

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
		System.debug('seguradosProposta###'+lSeguradoProposta);
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
		System.debug('Favorecido######'+lFavorecido);
		Map<String,FavorecidoRemuneracaoProposta__c> mFavorecido = new Map<String, FavorecidoRemuneracaoProposta__c>();
		if(lFavorecido.size() > 0){
			for(FavorecidoRemuneracaoProposta__c f : lFavorecido){
				mFavorecido.put(f.RemuneracaoProposta__r.Proposta__c,f);
			}
		}
		for(Quote q:lquote){
			String corretor =  (String.isNotBlank(mFavorecido.get(q.Id).Susep__c)) ? mFavorecido.get(q.Id).Susep__c : '';
			List<String> lcpf = mSeguradoProposta.get(q.Id).Conta__r.Cpf__c.split('-');
			String cpf = lcpf[0].replace('.','');
			String digitoCPF = lcpf[1];
			String st = q.Origem__c+'|'+q.NumeroProposta__c+'|'+q.Status+'|'+corretor+'|S|20/03/2023|20/03/2023|'+q.produto__r.name+'|'+q.PremioTotal__c+'|'+mSeguradoProposta.get(q.Id).Conta__r.Name+'|'+mSeguradoProposta.get(q.Id).Conta__r.PersonBirthdate.format()+'|'+cpf+'|'+digitoCPF+'|'+mSeguradoProposta.get(q.Id).Conta__r.Sexo__c;
			lista.add(st);
		}
		if(lista.size() > 0){
			listatotal.addAll(lista);
		}

		if(listatotal.size() > 0){
			str = String.join(listatotal,'\n');

			ContentVersion file = new ContentVersion(
				Title = 'Teste report',
				VersionData = Blob.valueOf(str),
				PathOnClient = 'TestAquivoReport.txt',
				origin = 'H'
			);
			insert file;	
		}
		
		if(arquivo.size() > 0){
			delete (new ContentDocument(Id = arquivo[0].ContentDocumentId));
		}
		
		
	}

	
	public static void sendAttach() {
		Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
		Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        List<ContentVersion> book = [select  id, ContentDocumentId, VersionData, Title from ContentVersion where Title = 'Teste report' order by CreatedDate desc limit 1];
		
		Blob b = book[0].VersionData;
		attach.setFileName(book[0].Title+'.txt');
		attach.setBody(b);
		semail.setSubject('Book details');
		String[] sendTo = new String[]{'jefer.santana@gmail.com'};
		semail.setToAddresses(sendTo);
		semail.setPlainTextBody('Please find the attached book details');
		semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
		
	}

	public static void geraRelatorio(){
		List<MegaDayReport__mdt> params = [SELECT Coberturas__c, EmailDestinatarios__c, Ramos__c FROM MegaDayReport__mdt];
       
        List<String> lramos = params[0].Ramos__c.split(',');
        List<String> lcoberturas = params[0].Coberturas__c.split(',');
        Date inicio = System.today()-1;
        Date fim = System.today()-1;
        List<Quote> lquote = [SELECT ID, Name, Origem__c,  NumeroProposta__c, Status, produto__r.name, PremioTotal__c, DataProtocolo__c, LastModifiedDate, (SELECT id FROM GarantiasProposta__r WHERE Garantia__r.Sigla__c in: lcoberturas ) FROM Quote WHERE DAY_ONLY(convertTimezone(CreatedDate)) >=: inicio AND DAY_ONLY(convertTimezone(CreatedDate)) <=: fim AND RamoSeguro__r.Codigo__c in: lramos AND Tipo__c != 'Renovacao'];
		Map<Id, Quote> mQuote = new Map<Id,Quote>(lquote);

		System.debug(mQuote.keySet());

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
		System.debug('seguradosProposta###'+lSeguradoProposta);

		List<FavorecidoRemuneracaoProposta__c> lFavorecido = [SELECT 
																ID,
																RemuneracaoProposta__r.Proposta__c,
																RemuneracaoProposta__r.TipoRemuneracao__r.Name,
																Susep__c,                                   // susep
																CorretorLider__c                            // flagsuseplider
															FROM FavorecidoRemuneracaoProposta__c
															WHERE RemuneracaoProposta__r.Proposta__c IN: mQuote.KeySet()
															AND RemuneracaoProposta__r.TipoRemuneracao__r.Name = 'CORRETAGEM'];
		System.debug('Favorecido######'+lFavorecido);
	}
}