/**
 * @author Santana,Jeferson (Sys4B)
 * @date 2020-05-12
 * @description Para recuperar o Documento no ECM ou SF
 * Classe criada por conta da história PLV-3746
 */
@RestResource(urlMapping='/DocumentAPI2/*')
global with sharing class DocumentAPI2 {
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
    
    @HttpGet
	global static void doGet() { 
        //List<public_arquivoecm__x> mockedRequests = new List<public_arquivoecm__x>();
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
          

            if(boletopage==true){ 
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    NamedCredential endpontSF = [select Endpoint from NamedCredential where DeveloperName = 'SFECM' limit 1];
                    request.setEndpoint(endpontSF.Endpoint+'apex/VFGerarBoleto?token='+identificador);
                    system.debug('entrou na chadama do Boleto'+endpontSF.Endpoint);

                        request.setMethod('GET');
                        HttpResponse resp = http.send(request);
                        RestResponse resArquivo = RestContext.response;
                        if(resp.getStatusCode() == 200){
                            system.debug('busca arquivo SF');
                            resArquivo.addHeader('Content-Type', resp.getHeader('Content-Type'));
                            resArquivo.addHeader('Content-Disposition', 'inline; filename=\'Boleto-'+identificador+'.pdf\'');
                            resArquivo.responseBody = resp.getBodyAsBlob();               
                            resArquivo.statusCode = resp.getStatusCode();
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
                 Http http = new Http();
                 HttpRequest request = new HttpRequest();
                NamedCredential endpontSF = [select Endpoint from NamedCredential where DeveloperName = 'SFECM' limit 1];
                system.debug('nomeAqr>> ' + idDoc);
                Quote proposta = [SELECT Id, Name FROM Quote WHERE Id = :idDoc];
                system.debug('proposta>1 ' + JSON.serialize(proposta));
                request.setEndpoint(endpontSF.Endpoint+'apex/PropostaIndividual?numProposta=' + proposta.Name);
                system.debug('request>> ' + request);
                request.setMethod('GET');
                HttpResponse resp = http.send(request);
                RestResponse resArquivo = RestContext.response;
                if(resp.getStatusCode() == 200){
                    system.debug('busca arquivo SF');
                    resArquivo.addHeader('Content-Type', resp.getHeader('Content-Type'));
                    System.debug( resp.getHeader('Content-Disposition'));
                    resArquivo.addHeader('Content-Disposition', 'inline; filename=\'TesteTituloNovo.pdf\'');
                    resArquivo.responseBody = resp.getBodyAsBlob();               
                    resArquivo.statusCode = resp.getStatusCode();
                }
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
                        NamedCredential endpontSF = [select Endpoint from NamedCredential where DeveloperName = 'SFECM' limit 1];
                        System.debug('idDoc ENTRADA>> ' + idDoc);
                        idDoc = idDoc.replace('=S&','=SIM&').replace('=N&','=NÃO&').replace('=T&','=true&').replace('=F&','=false&').replace('sexo=M&','sexo=MASCULINO&').replace('sexo=F&','sexo=FEMININO&');
                        idDoc = idDoc.replace('nuOrc=','numeroOrcamento=').replace('&nmSeg=','&nomeSeguradoPDF=').replace('&nascSeg=','&nascimentoSeguradoPDF=').replace('&fumS=','&fumanteSeguradoPDF=').replace('&sexo=','&sexoSeguradoPDF=').replace('&depSeg=','&dependenteSeguradoPDF=').replace('&ocupSeg=','&ocupacaoSeguradoPDF=').replace('&trabSeg=','&formaTrabalhoSeguradoPDF=');
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
                    }else if(downloadOrcamentoVIAGEM  == true ){                    
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        NamedCredential endpontSF = [select Endpoint from NamedCredential where DeveloperName = 'SFECM' limit 1];
                        System.debug('idDoc ENTRADA>> ' + idDoc);
                        idDoc = idDoc.replace('=S&','=SIM&').replace('=N&','=NÃO&').replace('=T&','=true&').replace('=F&','=false&').replace('sexo=M&','sexo=MASCULINO&').replace('sexo=F&','sexo=FEMININO&');
                        idDoc = idDoc.replace('nuOrc=','numeroOrcamento=').replace('&nmSeg=','&nomePDF=').replace('&origem=','&origemPDF=').replace('&cotacao=','&cotacaoPDF=');
                        
                        
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
                        RestResponse returnError = RestContext.response;
                        returnError.addHeader('Content-Type', 'text/html charset=utf-8');
                        returnError.responseBody =  Blob.valueOf(html.htmlToken);   
                        system.debug('Apolice, Voucher ou Endosso não existe.'+dadosDoc);
                    // plv - 4014 fim	
                        
                    }else{
                        system.debug('else>> ');
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        NamedCredential endpontSF = [select Endpoint from NamedCredential where DeveloperName = 'SFECM' limit 1];
                        system.debug('endpoint'+endpontSF);
                        if(apolicepage == true){
                           request.setEndpoint(endpontSF.Endpoint+'apex/ApolicePage?token='+identificador);
                           system.debug('entrou na chadama do serviço apolice'+endpontSF.Endpoint);
                        }
                        //PLV-4566 - INICIO
                        if(apoliceIndividualpage == true){
                            request.setEndpoint(endpontSF.Endpoint+'apex/ApoliceVidaIndividual?token='+identificador);
                            system.debug('entrou na chadama do serviço apolice Individual'+endpontSF.Endpoint);
                        }
                        //PLV-4566 - FIM
                        //PLV-4568 - INICIO
                        if(endossoIndividualpage == true){
                            request.setEndpoint(endpontSF.Endpoint+'apex/ApoliceVidaIndividual?token='+identificador); //PLV 5032 INICIO - FIM
                            system.debug('entrou na chadama do serviço endosso Individual'+endpontSF.Endpoint);
                        }
                        //PLV-4568 - FIM
                        //PLV-5133 - FIX01 - INICIO
                        if(cancelamentopage == true) {
                            request.setEndpoint(endpontSF.Endpoint+'apex/EndossoPage?token='+identificador);
                            system.debug('entrou na chamada do cancelamento '+endpontSF.Endpoint);
                        }
                        //PLV-5133 - FIX01 - FIM
                        if(voucherpage == true){
                            request.setEndpoint(endpontSF.Endpoint+'apex/VoucherPage?token='+identificador);
                            system.debug('entrou na chadama do serviço Voucher'+endpontSF.Endpoint);
                        }
                        
                        
                        // plv - 4014 inicio
                        if(endossopage == true){
                            //PLV-4588-INICIO
                            //plv-4014 fix 2 inicio
                            
                            /*Contract contratoAtual = [SELECT Id, Name FROM Contract WHERE Id =: IdDoc];
                            contratantecontrato__c cc = [SELECT Id FROM contratantecontrato__c WHERE Contrato__c =: IdDoc];
                            ParcelamentoContratoTO retornoParcelas = ContractFacade.getInstance().ObterParcelasContratoSegurado(cc.Id);
                            system.debug('retornoParcelas = '+JSON.serialize(retornoParcelas));
                            String nomeContratoOriginal = contratoAtual.Name.substring(0, contratoAtual.Name.length() -1)+'0'; 

                            Contract contratoOriginal = [SELECT Id FROM Contract WHERE Name =: nomeContratoOriginal];
                            contratantecontrato__c ccOriginal = [SELECT Id FROM contratantecontrato__c WHERE Contrato__c =: contratoOriginal.Id];
                            ParcelamentoContratoTO retornoParcelasOriginal = ContractFacade.getInstance().ObterParcelasContratoSegurado(ccOriginal.Id);
                            system.debug('retornoParcelasOriginal = '+JSON.serialize(retornoParcelasOriginal));
                            */
                            request.setEndpoint(endpontSF.Endpoint+'apex/ApolicePage?token='+identificador); //PLV-5053 INICIO/FIM
                            system.debug('entrou na chadama do serviço Endosso'+endpontSF.Endpoint);
                            //plv-4014 fix 2 fim
                            //PLV-4588-FIM

                        }   
                        // plv - 4014 fim
                        request.setMethod('GET');
                        HttpResponse resp = http.send(request);
                        RestResponse resArquivo = RestContext.response;
                        if(resp.getStatusCode() == 200){
                        system.debug('busca arquivo SF');
                        resArquivo.addHeader('Content-Type', resp.getHeader('Content-Type'));
                        System.debug( resp.getHeader('Content-Disposition'));
                        resArquivo.addHeader('Content-Disposition', 'inline; filename=\'TesteTituloNovo.pdf\'');
                        resArquivo.responseBody = resp.getBodyAsBlob();               
                        resArquivo.statusCode = resp.getStatusCode();
                        }else{
                        system.debug('erro ao busca arquivo SF');
                        resArquivo.addHeader('Content-Type', 'text/html charset=utf-8');
                        resArquivo.responseBody = Blob.valueOf(html.htmlFile);
                        resArquivo.statusCode = resp.getStatusCode();
                        }
                        System.debug('Carlos - ' + resArquivo);
                        
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
            /*
            String estrutura = '<html>'
                        +'<header>'
                        +'<meta charset="utf-8"/>'
                        +'</header>'
                        +'<body>'
                        +'<div class="conteudo" style="width:500px; font-size:12px; font-family:Arial, sans-serif;">'
                                +'<img src="https://portoseguro--sniper--c.cs249.content.force.com/servlet/servlet.ImageServer?id=015L0000000mtkS&oid=00DL0000005xqev&lastMod=1582049566000" width="500">'
                                +'<p style="padding:0px 10px 0px 10px; font-size:12px; font-family:Arial, sans-serif;">'
                				+'<p style="color:#CD0000; padding:15px; text-align:center;"><b>Erro: </b>{#TEXTO}</p>'
                                +'</p>'	
                                +'<div class="redesSociais" style="height:30px; background:#E8E8E8; border-top:1px solid #696969; border-bottom: 1px solid #696969; text-align:center; padding-top:10px; margin-top:5px;">'
                                +'    <span style="padding-left:20px;"><a href=" https://www.portoseguro.com.br/fale-conosco/contatos#redes-sociais?utm_campaign=comm_news_previd&utm_source=rodape_fixo&utm_medium=eml" target="_blank" style="color:#696969; font-weight:bold; font-family:Arial, sans-serif;">Rede Sociais</a></span>'
                                +'    <span style="padding-left:20px;"><a href="https://www.portoseguro.com.br/" target="_blank" style="color:#696969; font-weight:bold; font-family:Arial, sans-serif;">Área do Cliente<a></span>'
                                +'    <span style="padding-left:20px;"><a href="https://www.portoseguro.com.br/fale-conosco/contatos?utm_campaign=comm_news_previd&utm_source=rodape_fixo&utm_medium=eml" target="_blank" style="color:#696969; font-weight:bold; font-family:Arial, sans-serif;">Atendimento</a></span>'
                                +'    <span style="padding-left:20px;"><a href="https://www.portoseguro.com.br/institucional/responsabilidade-socioambiental/projetos-corporativos/negocios-sustentaveis?utm_campaign=comm_news_previd&utm_source=rodape_fixo&utm_medium=eml" target="_blank" style="color:#696969; font-weight:bold; font-family:Arial, sans-serif;">Sustentabilidade</a></span>'
                                +'</div>'
                                +'<div style="font-size:11px; color:#696969; font-weight:bold; font-family:Arial, sans-serif;">'
                                +'    <p style="padding:15px 15px 0px 15px;">'
                                +'        Porto Seguro Cia. de Seguros Gerais SA - CNPJ: 61198.16410001-60, Alameda Barão de Piracicaba n°'
                                +'        618 - Torre B - 3° Andar - Campos Elíseos - São Paulo - CEP 01216-012. lnformações reduzidas.'
                                +'        Consulte as Condições Gerais do seguro contratado no site www.portoseguro.com'
                                +'        Susep: Seguro Viagem Individual -15414.900447612015-4Z Seguro Viagem Individual Aventura'
                                +'        -15414.900707/2015-18. O registro deste plano na SUSEP não implica, por parte da Autarquia, incentivo'
                                +'        ou recomendação à sua comercialização - Central de Atendimento: (11) 3366-3377 (Grande São Paulo)'
                                +'        0800-727-9393 (demais localidades). Horario de atendimento: de segunda a sexta-feira, das 8h15 as'
                                +'        18h30. Atendimento exclusivo para deficientes auditivos: 0800-727-8736. Atendimento emergencial:'
                                +'        +55(11) 3366-3330 Brasil e Exterior (24 horas e chamadas a cobrar). Ouvidoria: 0800-727-1184. SAC'
                                +'        0800-727-2746 (24 horas). Não fazer distribuição deste material em vias públicas.'
                                +'    </p>'
                                +'</div>'  
                        +'</div>'
                        +'</body>'
                        +'</html>';
            */
            String estrutura = '<html>'
            +'<style type="text/css">'
            +'.cabecalhoLogo{'               
            +   ' display: flex;'
            +   ' justify-content: center;'
            +   ' align-items: center;'
            +   ' position: relative;'
            +'}'
            +'.distanciaPadraoMedia{'
            +   'font-family: arial'
            +   ' margin-top: 5%;'
            +   ' margin-left: 20%;'
            +   ' margin-right: 20%;'
            +   ' font-size: 20px;'
            + '}'
            +'</style>'
            +'<header>'
            +'<meta charset="utf-8"/>'
            +'</header>'
            +'<body>'
            +'<div class="content">'
            +'<header class="cabecalhoLogo">'
                +'<div class="divCabecalho">'
                   + '<div class="logo"><img src="/linkdesativado/resource/1673040233000/NovoLogoApolice" height="60px" width="260px" />'
                  + '</div>'               
                  + '</div>'   
            +' </header>'
            +' <div class="distanciaPadraoMedia">'
            +  '<p align="justify">'
            +    '    Muito obrigado por escolher a PORTO SEGURO para proteger voc&ecirc; e sua fam&iacute;lia.' 
            +    '    &Eacute; muito bom ter voc&ecirc; como nosso Cliente. Sabemos que imprevistos podem acontecer e,' 
            +    '    por isso, nossas coberturas e servi&ccedil;os proporcionam mais tranquilidade e seguran&ccedil;a '
            +   '    para a sua viagem. Conte com a gente!'
            +    '    Por seguran&ccedil;a um novo link foi gerado e enviado para o e-mail cadastrado.  '      
            +    '</p>'
            + '</div>'  
            +'</body>'
            +'</html>';
            String htmlTokenTexto = 'Desculpa, não foi possível carregar seu arquivo! Tente novamente. <span style="color:#FFF;">token</span>';
            htmlToken = estrutura.replace('{#TEXTO}',htmlTokenTexto);
            String htmlAuthTexto = 'Desculpa, não foi possível carregar seu arquivo! Tente novamente. <span style="color:#FFF;">Auten</span>';
            htmlAuth = estrutura.replace('{#TEXTO}',htmlAuthTexto);
            String htmlFileTexto = 'Desculpa, não foi possível carregar seu arquivo! Tente novamente.'+  +' <span style="color:#FFF;">File</span>';
            htmlFile = estrutura.replace('{#TEXTO}',htmlFileTexto);
           
        }
      
        
    }
}