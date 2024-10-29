/*
        @Autor: Pedro Augusto Braz - SYS4B
        @Criado em: 03/06/2020
        @Descrição: Classe controller de Envio de E-mail 
        @Classe de Testes: VoucherEmailControllerTest
        @Extra: Esta classe utiliza de um método da Util.cls para enviar os e-mails
 
        Histórico de alterações:
            03/06/2020 - Pedro Augusto Braz - SYS4B - Criação - PLV-3755
            12/06/2020 - Pedro Augusto Braz - SYS4B - FIX Chamada de devolutiva sendo feita antes do processo de criação do voucher ser executado
*/

//PLV-3755 - INICIO
public class VoucherEmailController {
	
    public class InnerVoucher{
        @AuraEnabled public String quoteId {get;set;}
        @AuraEnabled public String Segmento {get;set;} //PLV-5459 INICIO/FIM
        @AuraEnabled public String Nome {get;set;}
        @AuraEnabled public String URlFinal {get;set;}
        @AuraEnabled public String emailToSend {get;set;}
        @AuraEnabled public Boolean principal {get;set;}
        @AuraEnabled public String  Senha {get;set;} // MGRC-505 INICIO /FIM
        @AuraEnabled public String  DistributionPublicUrl {get;set;} // MGRC-505 INICIO /FIM
    }
    
    public static Map<Id,InnerVoucher> mapVoucher {get;set;}
    
    
    public static Map<String,String> SendEmails(Set<String> pSetQuoteIds, String pQuotePrincipalId){
        
        Map<String,String> mapToReturn = new Map<String,String>();
        mapVoucher = new Map<Id,InnerVoucher>();
        String bodyToSend = '';
        
        //Caso venha nulo não pode prosseguir
        if(pSetQuoteIds==null && pSetQuoteIds.size()==0){  mapToReturn.put('Sucesso','false');mapToReturn.put('Erro','Set de ID das cotações VAZIO');return mapToReturn;
        }
          
        Map<Id,Quote> mapQuote = new  Map<Id,Quote>([SELECT Id, Nome_do_contratante__c,Origem__c, Account.PersonEmail, NumeroProposta__c, Email__c, VoucherPdfDownloadUrl__c, Produto__r.GerarVoucher__c, Segmento__c, Senha__c, DistributionPublicUrl__c FROM Quote WHERE id IN:pSetQuoteIds  ]); //PLV - 4440  INICIO/FIM adicionado gerarvoucher na query - PLV-5459 Colocando o segmento INICIO/FIM // MGRC-505 INICIO /FIM
        System.debug('mapQuote:>>  '+mapQuote);
        //PLV - 4440  INICIO gerarVoucher produto
        Boolean nGerarVoucher = true;
        for(Quote pQuote : mapQuote.values()){
            if(!pQuote.Produto__r.GerarVoucher__c){
                nGerarVoucher = false;
            	break;
            }
        } 
        if(!nGerarVoucher)return mapToReturn;

        //PLV - 4440  FIM Ajuste gerarVoucher produto
        String baseURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1].Endpoint;
        baseURL += [SELECT NomeCredencial__c,NomeToken__c,Endpoint__c,DeveloperName FROM Servico__mdt WHERE DeveloperName='Consultar_ArquivoSF' LIMIT 1].Endpoint__c;

        List<SeguradoProposta__c> listSegurado  = [SELECT id, Conta__r.name, Conta__r.NomeSocial__c, GrupoProposta__r.ContratanteProposta__r.Proposta__c FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c IN:pSetQuoteIds]; //LECVPV - 190 - INICIO/FIM

        Map<Id,SeguradoProposta__c> propostaXname = new Map<Id,SeguradoProposta__c>();
        if(listSegurado!=null && listSegurado.size()>0){
            for(SeguradoProposta__c seg :listSegurado){   propostaXname.put(seg.GrupoProposta__r.ContratanteProposta__r.Proposta__c,seg);
            }
        }

        for(Quote cotacao : mapQuote.values()){
            InnerVoucher vou = new InnerVoucher();

            //FIX FORMAÇÃO DO NOME DO VOUCHER
            //O PROCESSO DE DEVOLUTIVA AS VEZES TEM SIDO CHAMADO ANTES DO VOUCHER SER GERADO PELA TRIGGER
            //POR ISSO É NECESSÁRIO ESSA LINHA A BAIXO PARA QUE NÃO QUEBRE A APLICAÇÃO
            if(String.isBlank(cotacao.VoucherPdfDownloadUrl__c)){
                string nomeVoucher = 'Voucher_'+cotacao.Origem__c+'_'+cotacao.NumeroProposta__c+'.pdf';
                cotacao.VoucherPdfDownloadUrl__c = baseURL+Util.encryptDocPublicURL(cotacao.Id, nomeVoucher);
            }
            if(String.isBlank(cotacao.DistributionPublicUrl__c)){
                string nomeVoucher = 'Voucher_'+cotacao.Origem__c+'_'+cotacao.NumeroProposta__c;
          
          
            }
            //O ♥ ABAIXO TAMBÉM É PREENCHIDO NA TRIGGER
            if(String.isBlank(cotacao.Email__c) && String.isNotBlank(cotacao.Account.PersonEmail))
                cotacao.Email__c = cotacao.Account.PersonEmail;

            //LECVPV-190 - INICIO
            vou.Nome = '';
            if(propostaXname!=null && propostaXname.keyset().contains(cotacao.Id)){
                vou.Nome = propostaXname.get(cotacao.Id).Conta__r.NomeSocial__c !=null ?  propostaXname.get(cotacao.Id).Conta__r.NomeSocial__c : propostaXname.get(cotacao.Id).Conta__r.name;
            }
            //LECVPV-190 - FIM
            vou.URLFinal = cotacao.VoucherPdfDownloadUrl__c;
            vou.Segmento = cotacao.Segmento__c; //PLV-5459 INICIO/FIM
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
        System.debug('mapVoucher.values():>>  '+mapVoucher.values());
        if(mapVoucher.values().size()>1){
            toReplace += 'Clique nos links abaixo e acesse os vouchers:</p>'; // VIAG-183- INICIO-FIM
            InnerVoucher first = String.isNotBlank(pQuotePrincipalId) ? mapVoucher.get(pQuotePrincipalId) : mapVoucher.values()[0];
            
            //MONTA O LINK PRINCIPAL
            toReplace+='<span style="padding:0px 10px 0px 10px; font-size:12px; font-family:Arial, sans-serif;"><a href="'+first.DistributionPublicUrl+'" target="_blank">'+first.Nome+'</a></span> com seu Token de acesso: '+ first.senha; // MGRC-505 INICIO /FIM
            nomePrincipal = first.Nome;
            emailPrincipal = first.emailToSend;
            senhaPrincipal = first.Senha; // MGRC-505 INICIO /FIM
            distributionURLPrincipal = first.DistributionPublicUrl;   // MGRC-505 INICIO /FIM     
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
            if(String.isBlank(mapVoucher.values()[0].URLFinal)){
                mapToReturn.put('Sucesso','false');mapToReturn.put('Erro',mapVoucher.values()[0].quoteId+' - Proposta sem LINK definido');return mapToReturn;
            }
            nomePrincipal = mapVoucher.values()[0].Nome;     
            emailPrincipal = mapVoucher.values()[0].emailToSend;
            senhaPrincipal = mapVoucher.values()[0].senha;   // MGRC-505 INICIO /FIM 
            distributionURLPrincipal =  mapVoucher.values()[0].DistributionPublicUrl; // MGRC-505 INICIO /FIM
            //PLV-5459  verifica se o segmento é viagem INICIO/FIM
            
            if (mapVoucher.values()[0].Segmento =='Viagem') {  
            toReplace += '<a href ="'+ distributionURLPrincipal +'" target"_blank">Clique aqui</a> e acesse o voucher, utilize seu token de acesso: '+ senhaPrincipal; // VIAG-183- INICIO-FIM // MGRC-505 INICIO /FIM
            } else {
            toReplace += '<a href ="'+ distributionURLPrincipal +'" target"_blank">Clique aqui</a> e confira a Carta Garantia. Utilze o seu token de acesso: '+ senhaPrincipal +'</p>'; // MGRC-505 INICIO /FIM
            }
            
            }
        //VALIDA DE SE O E-MAIL PRINCIPAL ESTA BRANCO
        if(String.isBlank(emailPrincipal)){
            mapToReturn.put('Sucesso','false');mapToReturn.put('Erro','Email principal não informado no CADASTRO');return mapToReturn;
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
            Util.enviarEmail(bodyToSend, new List<String> {emailPrincipal}, emailTemplate.Subject );
            mapToReturn.put('Sucesso','true');
        } catch (Exception e ) {
            mapToReturn.put('Sucesso','false');mapToReturn.put('Erro','Problemas ao enviar e-mail');return mapToReturn;
        }
        
        return mapToReturn;
    }

    
}
//PLV-3755 - FIM