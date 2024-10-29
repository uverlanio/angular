/**
 * @author Santana,Jeferson (Sys4B)
 * @date 2020-05-12
 * @description Para recuperar o Documento no ECM ou SF
 * Classe criada por conta da história PLV-3746
 */
@RestResource(urlMapping='/DocumentAPI/*')
global with sharing class DocumentAPI {
    @TestVisible private static List<public_arquivoecm__x> mockedRequests = new List<public_arquivoecm__x>();
    @TestVisible private static String mockIdentificador{get;set;}
    @TestVisible private static String mockjson{get;set;}
    @TestVisible private static List<Contract> mockContrato = new List<Contract>();    
    @TestVisible private static List<Quote> mockProposta = new List<Quote>(); 
    
    
 	global class retornoECMArquivo{
            public String error{get;set;}
            public string sucesso{get;set;}
            public string ticket{get;set;}
    }
    //MGRC-505 INICIO
    @HttpGet
	global static void doGet() {
        doLegado();
    }
    //MGRC-505-FIX FIM
    
    // MGRC-635 FIX INICIO

   
    @TestVisible
    private class validaToken{
        //String chave{get;set;}
        @TestVisible private String chaveDescript{get;set;}
        @TestVisible
        private void descript(string chave){
            CryptoToken c = new CryptoToken();
            // PLV-5188-INICIO FIX01
            System.debug(chave); // PLV-5188-INICIO/FIM FIX02
            if(chave.contains('~~') || chave.contains('$$') ){ // PLV-5188-INICIO/FIM FIX02  // PLV-5188 - FIX05 - INICIO/FIM   // PLV-5188 - FIX07 - INICIO/FIM
                chaveDescript = c.decryptUrl(chave);
            }else{
                chaveDescript = c.decrypt(chave);
            }
            // PLV-5188-FIM FIX01
        }

     
    }
   
    @TestVisible
    private class returnHTML{
        @TestVisible private String htmlToken{get;set;}
        @TestVisible private String htmlAuth{get;set;}
        @TestVisible private String htmlFile{get;set;}
        
        @TestVisible
        private returnHTML(){

   
           String estrutura = '<html>'
             +'<head>'
             +   '</head>'
             +   '<body>'
             +  '<table align="center" bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="0" class="m_principal" width="600">'
             +       '<tbody>'
             +           '<tr>'
             +           '<td><img src="https://portoseguro.com.br/NovoInstitucional/static_files/images/Informes%20de%20Rendimentos/Imagens/Headers%20EMKT/Header.Informa%C3%83%C2%A7%C3%83%C2%A3o_Importante.png" style="display: block; max-width: 100%; width: 600px; height: 354px;" /></td>'
             +           '</tr>'
             +          ' <tr>'
             +               '<td style="padding: 30px;">'
             +               '<table border="0" cellpadding="0" cellspacing="0" width="100%">'
             +                   '<tbody>'
             +                      '<tr>'
             +                           '<td style="padding-bottom: 10px;">'
             +                            '<p style="font-size: 20px; line-height: 20px; color: rgb(0, 153, 255);"><span style="font-family:verdana,geneva,sans-serif;"><span style="color:#000000;"><span id="docs-internal-guid-86ee8c66-7fff-d5f0-fbe7-91831ab1d68c"><span style="font-size: 11pt; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; vertical-align: baseline; white-space-collapse: preserve;">Ser um Porto seguro na vida dos nossos clientes &eacute; nossa prioridade. E cuidar da seguran&ccedil;a dos seus dados faz parte disso! </span></span></span></span></p>'
             +                            ' <p dir="ltr" style="line-height:1.38;text-align: justify;margin-top:0pt;margin-bottom:0pt;"><span style="font-family:verdana,geneva,sans-serif;"><span id="docs-internal-guid-57f2977f-7fff-6ba2-6054-b85419610cc9"><span style="font-size: 11pt; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; vertical-align: baseline; white-space-collapse: preserve;">Com isso, um novo link foi gerado e enviado para o e-mail cadastrado, para ter acesso aos arquivos enviados, voc&ecirc; dever&aacute; digitar o c&oacute;digo de acesso, enviado no pr&oacute;prio e-mail.</span></span></span></p>'
             +                             '<p><span style="font-family:verdana,geneva,sans-serif;"><font color="#222222"><span style="font-size: 14.6667px; white-space-collapse: preserve;">Em caso de d&uacute;vidas ou mais informa&ccedil;&otilde;es, entre em contato com seu Corretor.</span></font></span></p>'
             +                             '<p><strong><span style="font-family:verdana,geneva,sans-serif;">Todo cuidado &eacute; <u>Porto</u>.</span></strong></p>'
             +                          ' </td>'
             +                      ' </tr>'
             +                   '</tbody>'
             +               '</table>'
             +               '</td>'
             +           '</tr>'
             +       '</tbody>'
             +   '</table>'
             +   '<p>&nbsp;</p>'
             +   '</body>'
             +   '</html>';
             
            String htmlTokenTexto = 'Desculpa, não foi possível carregar seu arquivo! Tente novamente. <span style="color:#FFF;">token</span>';
            htmlToken = estrutura.replace('{#TEXTO}',htmlTokenTexto);
            String htmlAuthTexto = 'Desculpa, não foi possível carregar seu arquivo! Tente novamente. <span style="color:#FFF;">Auten</span>';
            htmlAuth = estrutura.replace('{#TEXTO}',htmlAuthTexto);
            String htmlFileTexto = 'Desculpa, não foi possível carregar seu arquivo! Tente novamente.'+  +' <span style="color:#FFF;">File</span>';
            htmlFile = estrutura.replace('{#TEXTO}',htmlFileTexto);
          

        }
         // MGRC-623 FIM 
    }

  
    //MGRC-505 INICIO
    public static void enviaEmail(String identificador, String tipoemail){
        CryptoToken c = new CryptoToken();  
        String chave = identificador;
        String emaildestino = '';
        String modeloEmail = '';
        String senha = '';
        String name = '';
        String DistributionPublicUrl = '';
        // MGRC-803 INICIO
        String numApolice = '';
        String numCelular = '';
        // MGRC-803 FIM
        Map<String,String> mapToReturn = new Map<String,String>();

        chave = chave.replace(' ','+');
        String chaveDescript = c.decrypt(chave);
        String dadosDoc = chaveDescript;
        String[] trataChave = dadosDoc.split('\\|');
        chave = trataChave[0];
         List<Contact> conList = new list<Contact>();
         List<Contract> enviaContrato = new List<Contract>();
         List<Quote> enviaProposta = new List<Quote>();


        if (FormaPagamento__c.SObjectType.getDescribe().isAccessible()) {
            System.debug('FormaPagamento Acessivel = true');
        } else {
            System.debug('FormaPagamento Acessivel = false');
        }
        if (Schema.sObjectType.FormaPagamento__c.fields.Codigo__c.isAccessible()) {
            System.debug('Codigo FormaPagto Acessivel = true');
        } else {
            System.debug('Codigo FormaPagto Acessivel = false');
        }


         if ((tipoemail == 'apoliceIndividualpage')|| (tipoemail == 'apolicepage') ||(tipoemail == 'endossopage')||(tipoemail == 'cancelamentopage')||(tipoemail == 'endossoIndividualpage')||(tipoemail == 'boletopage')) {
            system.debug('contratoID>>>>>>>'+chave);
            enviaContrato = [select id, FormaPagamento__c, Account.Name, Account.NomeSocial__c, Account.PersonEmail, Account.PersonMobilePhone, AccountID, IdExterno__c, NumeroApolice__c, email__c, Senha__c, DistributionPublicUrl__c from  Contract where Id =: chave ]; // MGRC-BOLETOS INICIO/FIM && LECVPV_190 FIX02 - INICIO/FIM
            Id formaPagtoId = enviaContrato[0].FormaPagamento__c;
            System.debug('Giordano Forma Pagto ID : '+formaPagtoId);
            Set<Id> fpids = new Set<Id>();
            fpids.add(formaPagtoId);
            System.debug('Giordano FPIDs : '+fpids);
          //  List<FormaPagamento__c> formaPagamento = FormaPagamentoDAO.getInstance().buscarFormasPagamentoPorIds(fpids);
            List<FormaPagamento__c> formaPagamento = [SELECT Codigo__c FROM FormaPagamento__c WHERE Id = 'a0aL0000007ApMDIA0' WITH SECURITY_ENFORCED];
        //    List<FormaPagamento__c> formaPagamento2 = [SELECT Codigo__c FROM FormaPagamento__c WHERE Id IN (SELECT FormaPagamento__c FROM Contract Where Id =:chave )];
            System.debug('Giordano FormaPagtoList : '+formaPagamento);
         //   String codFormaPagto = formaPagamento[0].Codigo__c;
            conList = [select id from contact where AccountId =: enviaContrato[0].AccountId];
            List<public_boleto__x> boletos = new List<public_boleto__x>();
        //    System.debug('Giordano Forma Pagto: '+ formaPagtoId + ' - '+codFormaPagto);
        //    if ('41'.equals(codFormaPagto)) {
                boletos = [SELECT id, numeroparcela__c,idcontrato__c, urlboleto__c, vencimento__c FROM public_boleto__x where idcontrato__c = '8000t000000k1GbAAI' order by idcontrato__c, numeroparcela__c asc ];
        //    }
            System.debug('Giordano BOLETOS: '+ boletos);
              if (enviaContrato.size() >0 ) {
                    name = String.isEmpty(enviaContrato[0].Account.NomeSocial__c) ? enviaContrato[0].Account.Name : enviaContrato[0].Account.NomeSocial__c; //LECVPV_190 FIX02 - INICIO/FIM
                    emaildestino = enviaContrato[0].email__c;
                    senha = enviaContrato[0].Senha__c;
                    DistributionPublicUrl = enviaContrato[0].DistributionPublicUrl__c;
                     // MGRC-803 INICIO
                    numApolice = enviaContrato[0].NumeroApolice__c;
                    numCelular = enviaContrato[0].Account.PersonMobilePhone;
                     // MGRC-803 FIM
                }
         } else if ((tipoemail == 'voucherpage')||(tipoemail=='propostaPage')) {   // MGRC-635 INICIO-FIM

         enviaProposta = [Select Id, Account.Name, Account.NomeSocial__c, email__c, Senha__c, DistributionPublicUrl__c from Quote where Id =: chave ]; //LECVPV_190 FIX02 - INICIO/FIM
         conList = [select id from contact where AccountId =: enviaProposta[0].AccountId];
                if (enviaProposta.size() >0 ) {
                    name = String.isEmpty(enviaProposta[0].Account.NomeSocial__c) ? enviaProposta[0].Account.Name : enviaProposta[0].Account.NomeSocial__c; //LECVPV_190 FIX02 - INICIO/FIM
                    emaildestino = enviaProposta[0].email__c;
                    senha = enviaProposta[0].Senha__c;
                    DistributionPublicUrl = enviaProposta[0].DistributionPublicUrl__c;
               
                }
                system.debug('Email Voucher>>>>>>> '+emaildestino);
        }
        
        String bodyToSend = '';
        String emailSubject = '';
        switch on tipoemail {
            when 'apoliceIndividualpage' {
                modeloEmail = 'BoasVindasHtml';  // MGRC-620-FIX INICIO-FIM
                bodyToSend = retrieveTemplate(modeloEmail).HtmlValue;
                emailSubject = retrieveTemplate(modeloEmail).Subject;
                bodyToSend = bodyToSend.replace('{!Contract.Senha__c}', senha );        
                bodyToSend = bodyToSend.replace('{!Contract.DistributionPublicUrl__c}', DistributionPublicUrl);
                bodyToSend = bodyToSend.replace('{!if(Account.NomeSocial__c="", Account.Name, Account.NomeSocial__c)}', name );   // MGRC-635-FIX INICIO-FIM && LECVPV_190 FIX02 - INICIO/FIM
                // MGRC-803 INICIO
                bodyToSend = bodyToSend.replace('#apolice#',numApolice);
                bodyToSend = bodyToSend.replace('#cel#',numCelular);
                bodyToSend = bodyToSend.replace('#email#',emaildestino);
                // MGRC-803 FIM
            }
            when 'endossopage' {
                modeloEmail = 'EmailEndossoViagem';   
                bodyToSend = retrieveTemplate(modeloEmail).HtmlValue;
                emailSubject = retrieveTemplate(modeloEmail).Subject;
                bodyToSend = bodyToSend.replace('{!if(Account.NomeSocial__c="", Account.Name, Account.NomeSocial__c)}', name );  //LECVPV_190 FIX02 - INICIO/FIM      
                bodyToSend = bodyToSend.replace('{!Contract.Senha__c}', senha );        
                bodyToSend = bodyToSend.replace('{!Contract.DistributionPublicUrl__c}', DistributionPublicUrl);
                
            }
            when 'cancelamentopage' {
                modeloEmail = 'Email_Cancelamento'; // MGRC-635-FIX INICIO-FIM
                bodyToSend = retrieveTemplate(modeloEmail).HtmlValue;
                emailSubject = retrieveTemplate(modeloEmail).Subject;
                bodyToSend = bodyToSend.replace('{!if(Account.NomeSocial__c="", Account.Name, Account.NomeSocial__c)}', name );  //LECVPV_190 FIX02 - INICIO/FIM
                bodyToSend = bodyToSend.replace('{!Contract.DistributionPublicUrl__c}', DistributionPublicUrl);               
                bodyToSend = bodyToSend.replace('{!Contract.Senha__c}', senha );
                          
            }
            when 'endossoIndividualpage' {
                modeloEmail = 'EndossoVidaON';  
                bodyToSend = retrieveTemplate(modeloEmail).HtmlValue;
                emailSubject = retrieveTemplate(modeloEmail).Subject;
                bodyToSend = bodyToSend.replace('{!if(Account.NomeSocial__c="", Account.Name, Account.NomeSocial__c)}', name );  //LECVPV_190 FIX02 - INICIO/FIM
                bodyToSend = bodyToSend.replace('{!Contract.DistributionPublicUrl__c}', DistributionPublicUrl);               
                bodyToSend = bodyToSend.replace('{!Contract.Senha__c}', senha );        
            }
            // MGRC-635 FIX INICIO
            when 'voucherpage' {
                modeloEmail = 'Email_Voucher';  
                bodyToSend = retrieveTemplate(modeloEmail).HtmlValue;
                emailSubject = retrieveTemplate(modeloEmail).Subject;
                System.debug('Gior -> Name: '+name);
                bodyToSend = bodyToSend.replace('{!if(Quote.NomeSocial__c="", Quote.Nome_do_contratante__c, Quote.NomeSocial__c)}', name ); //HOTFIX - LECVPV
                bodyToSend = bodyToSend.replace('{!Quote.Senha__c}', senha ); // MGRC-635-FIX-2 INICIO/FIM
                String voucher ='';
                // MGRC-635 FIX FIM
                // MGRC-635 FIX INICIO
                List<SeguradoProposta__c> listSegurado  = [SELECT id, Conta__r.name,GrupoProposta__r.ContratanteProposta__r.Proposta__c, GrupoProposta__r.ContratanteProposta__r.Proposta__r.DistributionPublicUrl__c, GrupoProposta__r.ContratanteProposta__r.Proposta__r.Senha__c FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: chave];
                 if (listSegurado.size() >1 ){
                   for (integer i=0; i< listSegurado.size(); i++ ) {
                    voucher += '<span style="padding:0px 10px 0px 10px; font-size:12px; font-family:Arial, sans-serif;"><a href="'+ listSegurado[i].GrupoProposta__r.ContratanteProposta__r.Proposta__r.DistributionPublicUrl__c+'" target="_blank">'+listSegurado[i].Conta__r.name+'</a></span><br>'; // MGRC-635-FIX-2 INICIO/FIM
                   }   
                      
                 } else {
                    voucher = '<span style="padding:0px 10px 0px 10px; font-size:12px; font-family:Arial, sans-serif;"><a href="'+DistributionPublicUrl+'" target="_blank">'+name+'</a></span><br>'; // MGRC-635-FIX-2 INICIO/FIM
                }
               // MGRC-635 FIX FIM
                bodyToSend = bodyToSend.replace('#LISTALINK#', voucher );        
               
            }



             // MGRC-635 FIX FIM
            when 'apolicepage' {
                modeloEmail = 'Email_Apolice'; // MGRC-620-FIX INICIO-FIM
                bodyToSend = retrieveTemplate(modeloEmail).HtmlValue;
                emailSubject = retrieveTemplate(modeloEmail).Subject;
                
                bodyToSend = bodyToSend.replace('{!Contract.Senha__c}', senha );        
                bodyToSend = bodyToSend.replace('{!Contract.DistributionPublicUrl__c}', DistributionPublicUrl);
                bodyToSend = bodyToSend.replace('{!if(Account.NomeSocial__c="", Account.Name, Account.NomeSocial__c)}', name );  //LECVPV_190 FIX02 - INICIO/FIM
                  
               
            }
            /*
            when 'boletopage' {
                modeloEmail = 'Email_BoletoPage'; // email boas vindas  
            }
            */
            // MGRC-635 INICIO
             when 'propostaPage' {
                modeloEmail = 'EmailPropostaLink';
                bodyToSend = retrieveTemplate(modeloEmail).HtmlValue;
                emailSubject = retrieveTemplate(modeloEmail).Subject;
                
                bodyToSend = bodyToSend.replace('{!Quote.Senha__c}', senha );        
                bodyToSend = bodyToSend.replace('{!Quote.DistributionPublicUrl__c}', DistributionPublicUrl);
                bodyToSend = bodyToSend.replace('{!if(Quote.NomeSocial__c="", Quote.Nome_do_contratante__c, Quote.NomeSocial__c)}', name ); //LECVPV_190 FIX02 - INICIO/FIM     
            }
           // MGRC-635 FIM
           
        }
      
     System.debug('Modelo de email: '+modeloEmail + 'emaildestino:'+ emaildestino); 

     Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
          
     OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'adminsalesforce.vida@portoseguro.com.br'];
     if ( owea.size() > 0 ) {
        System.debug('Email da org: ' + owea.get(0).Id);
        email.setOrgWideEmailAddressId(owea.get(0).Id);
     }
     string[] to = new string[] {emaildestino};
     email.setToAddresses(to);
     email.setSubject(emailSubject);
     email.setHtmlBody(bodyToSend);
     try{
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        System.debug('results: ' + results);
    }catch(exception e){
         apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
     }
    
    }
    
    global static EmailTemplate retrieveTemplate(String modeloEmail){
        EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName=: modeloEmail];
        return  emailTemplate;    
    }


     // MGRC-635 FIX FIM
     global static void doLegado() { 
        system.debug('mocklist'+mockedRequests);
    	RestRequest params = RestContext.request;
        system.debug('mockIdentificador'+mockIdentificador);
        system.debug('params.requestURI = ' + params.requestURI);// PLV-5188-INICIO/FIM FIX03
        system.debug(params.requestURI);// PLV-5188-INICIO/FIM FIX03
    	String identificador = (mockIdentificador != null) ? mockIdentificador :params.requestURI.substring(params.requestURI.lastIndexOf('doGet')+6);
       
        system.debug('identificador'+identificador);
        validaToken tk = new validaToken();
        returnHTML html = new returnHTML();
        try{
            system.debug('identificador'+identificador);
            System.debug(identificador);// PLV-5188 INICIO/FIM
            tk.descript(identificador);
            System.debug('tk>> ' + JSON.serialize(tk));
            String dadosDoc = tk.chaveDescript;
            dadosDoc = dadosDoc.replace(' ','+');
            String[] trataChave = dadosDoc.split('\\|');
            System.debug('trataChave>> ' + JSON.serialize(trataChave));
            String idDoc = trataChave[0];
            String nomeArq = trataChave[1];
            System.debug('trataChave ID DOC>> ' + idDoc + 'nomeArq>>> '+ nomeArq);
            //PLV-4566 - INICIO
            Boolean apoliceIndividualpage = nomeArq.contains('Apolice_Individual'); 
            Boolean apolicepage = (apoliceIndividualpage == true) ? false : nomeArq.contains('Apolice'); 
            //PLV-4566 - FIM
            Boolean voucherpage = nomeArq.contains('Voucher'); 
            //PLV-4568 - INICIO
            Boolean endossoIndividualpage = nomeArq.contains('Endosso_Individual');
            Boolean endossopage = (endossoIndividualpage == true) ? false : nomeArq.contains('Endosso'); // plv - 4014 inicio/fim
            //PLV-4568 - FIM

            Boolean cancelamentopage = nomeArq.contains('Cancelamento'); //PLV-5133 - FIX01 - INICIO/FIM

            //PLV-4953 - INÍCIO
            Boolean boletopage  = nomeArq.contains('Boleto');
            system.debug('trataChave'+trataChave);
            Boolean propostaPage = nomeArq.contains('Proposta_');
            //PLV-4953 - FIM
            RestResponse returnError = RestContext.response;

            if(boletopage==true){ 
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    NamedCredential endpontSF = [select Endpoint from NamedCredential where DeveloperName = 'SFECM' limit 1]; //MGRC-635-FIX INICIO-FIM
                    request.setEndpoint(endpontSF.Endpoint+'apex/VFGerarBoleto?token='+identificador);
                    system.debug('entrou na chamada do Boleto'+endpontSF.Endpoint);

                        request.setMethod('GET');
                        HttpResponse resp = http.send(request);
                        RestResponse resArquivo = RestContext.response;
                        if(resp.getStatusCode() == 200){
                        
                         returnError.addHeader('Content-Type', 'text/html charset=utf-8');
                         returnError.responseBody =  Blob.valueOf(html.htmlToken);   
                        
                        
                        }else{
                            system.debug('erro ao busca arquivo SF');
                            resArquivo.addHeader('Content-Type', 'text/html charset=utf-8');
                            resArquivo.responseBody = Blob.valueOf(html.htmlFile);
                            resArquivo.statusCode = resp.getStatusCode();
                        }

                        return; // PLV-5188 INICIO/FIM

            }
            //PLV-4953 - INÍCIO
            if(propostaPage == true ){
                enviaEmail(identificador, 'propostaPage'); // MGRC-505 INICIO/FIM
                returnError.addHeader('Content-Type', 'text/html charset=utf-8');
                 returnError.responseBody =  Blob.valueOf(html.htmlToken); 
                 // MGRC-635 FIM

            }
            else{
                //PLV-4953 - FIM

                List <public_arquivoecm__x> obj = (!mockedRequests.isEmpty()) ? mockedRequests :[SELECT idsf__c, nomearquivo__c, idecm__c, status__c, tipoarquivo__c FROM public_arquivoecm__x 
                                                WHERE idsf__c =: idDoc
                                                AND nomearquivo__c =: nomeArq
                                                AND status__c = 'CRIADO'];
                system.debug('obj>> ' + JSON.serialize(obj));
                if(obj.size() == 0){
                    
                    
                    List<Contract> contrato = (!mockContrato.isEmpty()) ? mockContrato :[SELECT Id FROM Contract WHERE Id =: idDoc];
                    // plv - 4014 inicio
                    //PLV-4566 - INICIO
                    //PLV-5008 - APP INICIO
                    Boolean downloadOrcamentoVI = nomeArq.contains('VI_ORC');
                    Boolean downloadOrcamentoVIAGEM = nomeArq.contains('VIAGEM_ORC');
                    if(downloadOrcamentoVI == true ){
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        NamedCredential endpontSF = [select Endpoint from NamedCredential where DeveloperName = 'SFECM' limit 1]; //MGRC-635-FIX INICIO-FIM
                        System.debug('idDoc ENTRADA>> ' + idDoc);
                        idDoc = idDoc.replace('=S&','=SIM&').replace('=N&','=NÃO&').replace('=T&','=true&').replace('=F&','=false&').replace('sexo=M&','sexo=MASCULINO&').replace('sexo=F&','sexo=FEMININO&');
                        idDoc = idDoc.replace('nuOrc=','numeroOrcamento=').replace('&nmSeg=','&nomeSeguradoPDF=').replace('&nmSegScl=','&nomeSocialSeguradoPDF=').replace('&nascSeg=','&nascimentoSeguradoPDF=').replace('&fumS=','&fumanteSeguradoPDF=').replace('&sexo=','&sexoSeguradoPDF=').replace('&depSeg=','&dependenteSeguradoPDF=').replace('&ocupSeg=','&ocupacaoSeguradoPDF=').replace('&trabSeg=','&formaTrabalhoSeguradoPDF='); //HOTFIX 4 - LECVPV 189 - INICIO/FIM
                        System.debug('idDoc SAÍDA>> ' + idDoc);

                        request.setEndpoint(endpontSF.Endpoint+'apex/OrcamentoVidaPage?' + idDoc);
                        system.debug('request>> ' + request);
                        request.setMethod('GET');
                        HttpResponse resp = http.send(request);
                        RestResponse resArquivo = RestContext.response;
                        if(resp.getStatusCode() == 200){
                            system.debug('busca arquivo SF');
                            resArquivo.addHeader('Content-Type', resp.getHeader('Content-Type'));
                            System.debug( resp.getHeader('Content-Disposition'));
                            resArquivo.addHeader('Content-Disposition', 'inline; filename=\'ORCAMENTO - '+idDoc+'.pdf\'');
                            resArquivo.responseBody = resp.getBodyAsBlob();               
                            resArquivo.statusCode = resp.getStatusCode();
                        }
                        //enviaEmail(identificador, 'modeloOrcamentoVidaPage'); // MGRC-505 INICIO/FIM
                    }else if(downloadOrcamentoVIAGEM  == true ){                    
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        NamedCredential endpontSF = [select Endpoint from NamedCredential where DeveloperName = 'SFECM' limit 1]; //MGRC-635-FIX INICIO-FIM
                        System.debug('idDoc ENTRADA>> ' + idDoc);
                        idDoc = idDoc.replace('=S&','=SIM&').replace('=N&','=NÃO&').replace('=T&','=true&').replace('=F&','=false&').replace('sexo=M&','sexo=MASCULINO&').replace('sexo=F&','sexo=FEMININO&');
                        idDoc = idDoc.replace('nuOrc=','numeroOrcamento=').replace('&nmSeg=','&nomePDF=').replace('&nmSegScl=','&nomeSocialPDF=').replace('&origem=','&origemPDF=').replace('&cotacao=','&cotacaoPDF='); //HOTFIX 4 - LECVPV 189 - INICIO/FIM
                        
                        
                        System.debug('idDoc SAÍDA>> ' + idDoc);

                        request.setEndpoint(endpontSF.Endpoint+'apex/OrcamentoPage?' + idDoc);
                        system.debug('request>> ' + request);
                        request.setMethod('GET');
                        HttpResponse resp = http.send(request);
                        RestResponse resArquivo = RestContext.response;
                        if(resp.getStatusCode() == 200){
                            system.debug('busca arquivo SF');
                            resArquivo.addHeader('Content-Type', resp.getHeader('Content-Type'));
                            System.debug( resp.getHeader('Content-Disposition'));
                            resArquivo.addHeader('Content-Disposition', 'inline; filename=\'ORCAMENTO - '+idDoc+'.pdf\'');
                            resArquivo.responseBody = resp.getBodyAsBlob();               
                            resArquivo.statusCode = resp.getStatusCode();
                        }
                    }
                    else
                    //PLV-5008 - APP FIM
                    if(apolicepage == false && voucherpage == false && endossopage == false && apoliceIndividualpage == false && endossoIndividualpage == false && cancelamentopage == false){ //PLV-4568 - INICIO / FIM //PLV-5133 - FIX01 - INICIO/FIM
                    //PLV-4566 - FIM
                      
                        returnError.addHeader('Content-Type', 'text/html charset=utf-8');
                        returnError.responseBody =  Blob.valueOf(html.htmlToken);   
                     
                    // plv - 4014 fim	
                        
                    }else{
                        system.debug('else>> ');
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        NamedCredential endpontSF = [select Endpoint from NamedCredential where DeveloperName = 'SFECM' limit 1]; //MGRC-635-FIX INICIO-FIM
                        system.debug('endpoint'+endpontSF);
                        if(apolicepage == true){
                        enviaEmail(identificador, 'apolicepage'); // MGRC-505 INICIO/FIM
                      
                         //  request.setEndpoint(endpontSF.Endpoint+'apex/ApolicePage?token='+identificador); // MGRC-505 INICIO/FIM
                         //  system.debug('entrou na chamada do serviço apolice'+endpontSF.Endpoint + 'identificador:'+ identificador); // MGRC-505 INICIO/FIM
                         returnError.addHeader('Content-Type', 'text/html charset=utf-8');
                         returnError.responseBody =  Blob.valueOf(html.htmlToken);  
                         System.debug('Apolice identificador>>>'+identificador);
                        
                      }
                        //PLV-4566 - INICIO
                        if(apoliceIndividualpage == true){
                          // request.setEndpoint(endpontSF.Endpoint+'apex/ApoliceVidaIndividual?token='+identificador); // MGRC-505 INICIO/FIM
                            //system.debug('entrou na chamada do serviço apolice Individual'+endpontSF.Endpoint); // MGRC-505 INICIO/FIM
                          enviaEmail(identificador, 'apoliceIndividualpage'); // MGRC-505 INICIO/FIM
                         
                          returnError.addHeader('Content-Type', 'text/html charset=utf-8');
                          returnError.responseBody =  Blob.valueOf(html.htmlToken); 
                       }
                        //PLV-4566 - FIM
                        //PLV-4568 - INICIO
                        if(endossoIndividualpage == true){
                            enviaEmail(identificador, 'endossoIndividualpage'); // MGRC-505 INICIO/FIM
                       
                           // request.setEndpoint(endpontSF.Endpoint+'apex/ApoliceVidaIndividual?token='+identificador); // MGRC-505 INICIO/FIM
                          //  system.debug('entrou na chadama do serviço endosso Individual'+endpontSF.Endpoint); // MGRC-505 INICIO/FIM
                          returnError.addHeader('Content-Type', 'text/html charset=utf-8');
                          returnError.responseBody =  Blob.valueOf(html.htmlToken); 
                      }
                        //PLV-4568 - FIM
                        //PLV-5133 - FIX01 - INICIO
                        if(cancelamentopage == true) {
                            enviaEmail(identificador, 'cancelamentopage'); // MGRC-505 INICIO/FIM
                           // request.setEndpoint(endpontSF.Endpoint+'apex/EndossoPage?token='+identificador); // MGRC-505 INICIO/FIM
                           // system.debug('entrou na chamada do cancelamento '+endpontSF.Endpoint); // MGRC-505 INICIO/FIM
                           returnError.addHeader('Content-Type', 'text/html charset=utf-8');
                           returnError.responseBody =  Blob.valueOf(html.htmlToken); 
                         
                        }
                        //PLV-5133 - FIX01 - FIM
                        if(voucherpage == true){
                          enviaEmail(identificador, 'voucherpage'); // MGRC-505 INICIO/FIM
                          //  request.setEndpoint(endpontSF.Endpoint+'apex/VoucherPage?token='+identificador); // MGRC-505 INICIO/FIM
                          //  system.debug('entrou na chadama do serviço Voucher'+endpontSF.Endpoint); // MGRC-505 INICIO/FIM
                          returnError.addHeader('Content-Type', 'text/html charset=utf-8');
                          returnError.responseBody =  Blob.valueOf(html.htmlToken); 
                          System.debug('Voucher identificador>>>'+identificador);
                         
                        }
                        
                        
                        // plv - 4014 inicio
                        if(endossopage == true){
                           returnError.addHeader('Content-Type', 'text/html charset=utf-8');
                            returnError.responseBody =  Blob.valueOf(html.htmlToken); 
                            enviaEmail(identificador, 'endossopage'); // MGRC-505 INICIO/FIM
                            
                                //plv-4014 fix 2 fim
                            //PLV-4588-FIM

                        }   
                   
                    }
                    
    
                }else{
                    //Busca arquivo no ECM.
                    string identificadorECM;
                    string typeArchive;
                    for(public_arquivoecm__x a : obj){
                        identificadorECM = a.idecm__c;
                        typeArchive = a.tipoarquivo__c;
                        
                    }
                    
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    List <Servico__mdt> servico = [
                            SELECT
                                NomeCredencial__c,
                                NomeToken__c,
                                Endpoint__c,
                                DeveloperName
                            FROM
                                Servico__mdt
                            WHERE
                                DeveloperName = 'ECMAUTH' or DeveloperName = 'ECMDOC' OR DeveloperName ='Consultar_ArquivoSF'
                        ];
                
                
                    String endpointAuth;
                    String endpoitDoc;
                    for(Servico__mdt s : servico){
                        if(s.DeveloperName == 'ECMAUTH'){
                            endpointAuth = s.Endpoint__c;
                            
                        }else if(s.DeveloperName == 'ECMDOC'){
                            endpoitDoc = s.Endpoint__c;
                        }
                    }
                    
                    //realiza authenticação.
                    request.setEndpoint('callout:PortoSeguroECM'+endpointAuth);
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    String body = 'username={!$Credential.Username}&password={!$Credential.Password}';
                    request.setBody(body);
                    HttpResponse resp = http.send(request);
                    if (resp.getStatusCode() == 200) {
                        String endpoint = endpoitDoc;
                        endpoint = endpoint.replace('{{ID_ECM}}',identificadorECM);
                        
                        RestResponse res = RestContext.response;
                        res.addHeader('Content-Type', 'application/json');
                        retornoECMArquivo objRetorno =  (mockjson != null) ? (retornoECMArquivo)System.JSON.deserialize(mockjson,retornoECMArquivo.class)  :(retornoECMArquivo)System.JSON.deserialize(resp.getBody(),retornoECMArquivo.class);
                                        
                        HttpRequest requestArquivo = new HttpRequest();
                        requestArquivo.setEndpoint('callout:PortoSeguroECM'+endpoint);
                        requestArquivo.setMethod('GET');
                        requestArquivo.setHeader('OTCSTicket',objRetorno.ticket);
                        HttpResponse response = http.send(requestArquivo);
                        
                        if (response.getStatusCode() == 200) {
                            RestResponse resArquivo = RestContext.response;
                            resArquivo.addHeader('Content-Type', 'application/'+typeArchive);
                            resArquivo.responseBody = response.getBodyAsBlob();
                            resArquivo.statusCode = response.getStatusCode();
                        }else{
                            RestResponse resArquivo = RestContext.response;
                            resArquivo.addHeader('Content-Type', 'text/html charset=utf-8');
                            resArquivo.responseBody = Blob.valueOf(html.htmlFile);
                            resArquivo.statusCode = response.getStatusCode();
                        }
                        
                        
                    }else{
                        system.debug('falha na autenticacao ECM');
                        RestResponse res = RestContext.response;
                        res.addHeader('Content-Type', 'text/html charset=utf-8');
                        res.responseBody = Blob.valueOf(html.htmlAuth);
                        res.statusCode = resp.getStatusCode();
                    }
                
                }

            
            }
            
        }catch(Exception e){
             system.debug('messege'+e.getMessage());
             system.debug('trace'+e.getStackTraceString());
             RestResponse returnError = RestContext.response;
             returnError.addHeader('Content-Type', 'text/html charset=utf-8');
             returnError.responseBody =  Blob.valueOf(html.htmlToken);           
             returnError.statusCode = 500;
             
        } 	        
	}
    //MGRC-505 FIM  


}