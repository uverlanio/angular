/*
        @Autor: Mauricio Verissimo
        @Criado em: 23/11/2023
        @Descrição: Classe controller de Envio de E-mail com token
        @Classe de Testes: VoucherEmailControllerTest
        @Extra: Esta classe utiliza de um método da Util.cls para enviar os e-mails
        Estória: MGRC-505 
     
*/


public class VoucherEmailControllerNew {
	
    public class InnerVoucher{
        @AuraEnabled public String quoteId {get;set;}
        @AuraEnabled public String Segmento {get;set;} 
        @AuraEnabled public String Nome {get;set;}
        @AuraEnabled public String URlFinal {get;set;}
        @AuraEnabled public String emailToSend {get;set;}
        @AuraEnabled public Boolean principal {get;set;}
        @AuraEnabled public String  Senha {get;set;} 
        @AuraEnabled public String  DistributionPublicUrl {get;set;} 
    }
    public static Map<Id,InnerVoucher> mapVoucher {get;set;}
   
    public static  Map<String,String>  SendEmailVoucher(List<Quote> plProposta, Map<Id, Quote> mapOldQuotes){
        List<Quote> lProposta = new List<Quote>();
        Set<Id> sProdutoId = new Set<Id>();
        String oportunidadeID = plProposta[0].OpportunityId;
        String pQuotePrincipalId = plProposta[0].Id;
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> pSetQuoteIds = new Set<Id>();
        Set<Id> sPropostaId = new Set<Id>();
        System.debug('SendEmailVoucher@'+oportunidadeID);
        Map<String,String> mapToReturn = new Map<String,String>();
        mapVoucher = new Map<Id,InnerVoucher>();
        String bodyToSend = '';

        Set<Id> quotesIds = new Set<Id>();
        
        // Make sure of the map's instance
        if(mapOldQuotes == null)
            mapOldQuotes = new Map<Id, Quote>();
        
        // Verify if is a new record or if have changes in the date field
        for(Quote objQuote : plProposta){
            Quote quoteOld = mapOldQuotes.get(objQuote.Id);
            system.debug('gera contrato >> mapOldQuotes: ' + mapOldQuotes.get(objQuote.Id));
            System.debug('gera contrato >> quoteOld: '+ quoteOld);
            System.debug('gera contrato >> status: '+ objQuote.Status);
            System.debug('gera contrato >> Senha: '+ objQuote.Senha__c);
            // PLV-2378-29 - INICIO
           
            if((objQuote.Status == 'Contratada') && (objQuote.Senha__c !=''))
            {
                quotesIds.add(objQuote.Id);
                QuoteTriggerHandler.sendEmailVou = true;
            }
           
        }
        
        System.debug('gera contrato >> ids : '+ quotesIds);
        
              
        if (quotesIds !=null && quotesIds.size() >0){
            // mapToReturn.put('Erro','Set de ID das cotações VAZIO');return mapToReturn;
          System.debug('mapQuote: quotesIds VoucherEmailNew>>>>>>>  '+ quotesIds );
          System.debug('mapQuote: quotes Size VoucherEmailNew>>>>>>>  '+ quotesIds.size() );
        Map<Id,Quote> mapQuote = new  Map<Id,Quote>([SELECT Id, Nome_do_contratante__c,Origem__c, Account.PersonEmail, NumeroProposta__c, Email__c, VoucherPdfDownloadUrl__c, Produto__r.GerarVoucher__c, Segmento__c, Senha__c, DistributionPublicUrl__c FROM Quote WHERE Id IN: quotesIds]); 
        System.debug('mapQuote:VoucherEmailNew>>>>>>>  '+mapQuote);
         Boolean nGerarVoucher = true;
            for(Quote pQuote : mapQuote.values()){
                if(!pQuote.Produto__r.GerarVoucher__c){
                    nGerarVoucher = false;
                    break;
                }
            } 
            if(!nGerarVoucher){
                mapToReturn.put('Erro','nGerarVoucher VAZIO'); return mapToReturn;
            }


        String baseURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1].Endpoint;
        baseURL += [SELECT NomeCredencial__c,NomeToken__c,Endpoint__c,DeveloperName FROM Servico__mdt WHERE DeveloperName='Consultar_ArquivoSF' LIMIT 1].Endpoint__c;

        List<SeguradoProposta__c> listSegurado  = [SELECT id, Conta__r.name, Conta__r.NomeSocial__c,GrupoProposta__r.ContratanteProposta__r.Proposta__c FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c IN:quotesIds]; //LECVPV - 190 - INICIO/FIM

        Map<Id,SeguradoProposta__c> propostaXname = new Map<Id,SeguradoProposta__c>();
        if(listSegurado!=null && listSegurado.size()>0){
            for(SeguradoProposta__c seg :listSegurado){   propostaXname.put(seg.GrupoProposta__r.ContratanteProposta__r.Proposta__c,seg);
            }
        }

        for(Quote cotacao : mapQuote.values()){
            InnerVoucher vou = new InnerVoucher();

            if(String.isBlank(cotacao.VoucherPdfDownloadUrl__c)){
                string nomeVoucher = 'Voucher_'+cotacao.Origem__c+'_'+cotacao.NumeroProposta__c+'.pdf';
                cotacao.VoucherPdfDownloadUrl__c = baseURL+Util.encryptDocPublicURL(cotacao.Id, nomeVoucher);
            }
           
           if(String.isBlank(cotacao.Email__c) && String.isNotBlank(cotacao.Account.PersonEmail))
                cotacao.Email__c = cotacao.Account.PersonEmail;

            //LECVPV-190 - INICIO
            vou.Nome = '';
            if(propostaXname!=null && propostaXname.keyset().contains(cotacao.Id)){
                vou.Nome = propostaXname.get(cotacao.Id).Conta__r.NomeSocial__c !=null ?  propostaXname.get(cotacao.Id).Conta__r.NomeSocial__c : propostaXname.get(cotacao.Id).Conta__r.name;
            }
            //LECVPV-190 - FIM
            System.debug('cotacao.Senha__c>> '+cotacao.Senha__c);
            vou.URLFinal = cotacao.VoucherPdfDownloadUrl__c;
            vou.Segmento = cotacao.Segmento__c;
            vou.quoteId = cotacao.Id;
            vou.emailToSend = cotacao.Email__c;
            vou.Senha = cotacao.Senha__c;
            vou.DistributionPublicUrl =  cotacao.DistributionPublicUrl__c;
            vou.principal = pQuotePrincipalId == cotacao.Id ? true : false;
			mapVoucher.put(cotacao.Id,vou);
            mapToReturn.put(cotacao.id, cotacao.VoucherPdfDownloadUrl__c);
        }

        System.debug('mapToReturn:>>  '+mapToReturn);

       if(mapToReturn.values().size()==0){
           mapToReturn.put('Sucesso','false');mapToReturn.put('Erro','Não foram encontrados registros a serem enviados');return mapToReturn;
       }
       

        //Realizar processamento do e-mail
        //Via email template
        EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName= 'Email_Voucher'];
        bodyToSend = emailTemplate.HtmlValue;
        String toReplace = '<p style="padding:0px 10px 0px 10px; font-size:12px; font-family:Arial, sans-serif;">';
        String nomePrincipal ='';
        String emailPrincipal ='';
        String senhaPrincipal = '';
        String distributionURLPrincipal = '';
        System.debug('mapVoucher.values() Vindo do VoucherNew:>>  '+mapVoucher.values());
        if(mapVoucher.values().size()>1){
            toReplace += 'Clique nos links abaixo e acesse os vouchers:</p>'; // VIAG-183- INICIO-FIM
            InnerVoucher first = String.isNotBlank(pQuotePrincipalId) ? mapVoucher.get(pQuotePrincipalId) : mapVoucher.values()[0];
            
            //MONTA O LINK PRINCIPAL
            toReplace+='<span style="padding:0px 10px 0px 10px; font-size:12px; font-family:Arial, sans-serif;"><a href="'+first.DistributionPublicUrl+'" target="_blank">'+first.Nome+'</a></span> com seu Token de acesso: '+ first.senha; // MGRC-505 INICIO /FIM
            nomePrincipal = first.Nome;
            emailPrincipal = first.emailToSend;
            senhaPrincipal = first.Senha;
            distributionURLPrincipal = first.DistributionPublicUrl;       
            //MONTA OS DEMAIS LINKS
            for(InnerVoucher vou : mapVoucher.values()){
                if(!vou.principal){
                    if(String.isBlank(vou.URLFinal)){
                       mapToReturn.put('Sucesso','false');mapToReturn.put('Erro',vou.quoteId+' - Proposta sem LINK definido');return mapToReturn;
                    }
                    toReplace+='<br><span style="padding:0px 10px 0px 10px; font-size:12px; font-family:Arial, sans-serif;"><a href="'+vou.DistributionPublicUrl+'" target="_blank">'+vou.Nome+'</a></span> com seu token de acesso: '+vou.Senha; // MGRC-505 INICIO /FIM
                }
            }
            toReplace +='</p>';
        }else{
         
            nomePrincipal = mapVoucher.values()[0].Nome;     
            emailPrincipal = mapVoucher.values()[0].emailToSend;
            senhaPrincipal = mapVoucher.values()[0].senha;   // MGRC-505 INICIO /FIM 
            distributionURLPrincipal =  mapVoucher.values()[0].DistributionPublicUrl; // MGRC-505 INICIO /FIM
            
            if (mapVoucher.values()[0].Segmento =='Viagem') {  
            toReplace += '<a href ="'+ distributionURLPrincipal +'" target"_blank">Clique aqui</a> e acesse o voucher, utilize seu token de acesso: '+ senhaPrincipal; // VIAG-183- INICIO-FIM // MGRC-505 INICIO /FIM
            } else {
            toReplace += '<a href ="'+ distributionURLPrincipal +'" target"_blank">Clique aqui</a> e confira a Carta Garantia. Utilze o seu token de acesso: '+ senhaPrincipal +'</p>'; // MGRC-505 INICIO /FIM
            }
            
            }
        //VALIDA DE SE O E-MAIL PRINCIPAL ESTA BRANCO
        if(String.isBlank(emailPrincipal)){
          //  mapToReturn.put('Sucesso','false');mapToReturn.put('Erro','Email principal não informado no CADASTRO');return mapToReturn;
        }
        //System.debug('bodyToSend:>>  '+bodyToSend);
        System.debug('nomePrincipal:>>  '+nomePrincipal);
        System.debug('toReplace:>>  '+toReplace);
        //FAZ SUBSTITUIÇÕES DE A CORDO COM O QUE FOI MAPEADO
		bodyToSend = bodyToSend.replace('{!if(Quote.NomeSocial__c="", Quote.Nome_do_contratante__c, Quote.NomeSocial__c)}', nomePrincipal); //HOTFIX - LECVPV
        bodyToSend = bodyToSend.replace('{!Quote.Senha__c}', senhaPrincipal); // VIAG-240 INICIO/FIM               
        bodyToSend = bodyToSend.replace('#LISTALINK#', toReplace);
        
        System.debug('bodyToSend:>>  '+bodyToSend);

        try {
            //Chama classe de envio de e-mail
            System.debug('#senhaPrincipal# '+senhaPrincipal);
            if (senhaPrincipal != '' && senhaPrincipal != NULL) { //VIAG-323 INICIO/FIM
                if( mapQuote.size()==1){
                    Util.enviarEmail(bodyToSend,  new List<String> {mapVoucher.values()[0].emailToSend} , emailTemplate.Subject );
                } else {
                    Util.enviarEmail(bodyToSend, new List<String> {emailPrincipal}, emailTemplate.Subject );
                }
            } //VIAG-323 INICIO/FIM
      
            mapToReturn.put('Sucesso','true');
        } catch (Exception e ) {
           mapToReturn.put('Sucesso','false');mapToReturn.put('Erro','Problemas ao enviar e-mail');return mapToReturn;
       
        }
      
      }
     
      return mapToReturn;
     }
    
}