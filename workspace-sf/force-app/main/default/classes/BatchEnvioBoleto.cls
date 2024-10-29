/*********************************************************************************************************************************************************************
@description  Realiza o envio do boleto para o segurado
@author Carlos Pessoa - META
@date 30/12/2020
@Classe criada por conta da história PLV-4567    
**********************************************************************************************************************************************************************/

global class BatchEnvioBoleto implements Database.Batchable<sObject>, Database.StateFul, Database.AllowsCallouts, Schedulable {
    

    public BatchEnvioBoleto(){}
    global String idContratoTest { get; set; }
    // PLV-4567-COMPLEMENTO
    global Date dataprocessamento { get; set; }

    global List<public_boleto__x> start(Database.BatchableContext BC){
        Date dateFilter = System.today().addDays(-5);
        System.debug('dataprocessamento> ' + dataprocessamento);
        //II-138 INICIO
        List<Constante__mdt> constante = MetadataDAO.getInstance().buscarConstante('ENVIO_BOLETO');
        Integer limite = Integer.valueOf(constante[0].Valor__c);
        //II-138 FIM
        // PLV-4567-COMPLEMENTO INICIO
        if(!Test.isRunningTest()){
            /*if (dataprocessamento != null && dataprocessamento <= System.today()){
                // PLV-4567-FIX - Ajuste na query
                return [SELECT id, numeroparcela__c, numeroapolice__c, status__c, idcontrato__c, urlboleto__c, vencimento__c FROM public_boleto__x where (status__c = 'Emitido' or status__c = 'EMITIDO') and dataprocessamento__c =: dataprocessamento order by numeroparcela__c asc ]; //PLV-4910 - INÍCIO/FIM // PLV-4910-FIX
            }else{*/
                // PLV-4567-FIX - Ajuste na query
                //II-138 INICIO 
                List<public_boleto__x> getContract = [SELECT idcontrato__c FROM public_boleto__x where (status__c = 'Emitido' or status__c = 'EMITIDO') and dataprocessamento__c >=: dateFilter and numeroparcela__c = '001' LIMIT : limite];

                Set<Id> idContract = new Set<Id>();
                for(public_boleto__x boleto : getContract){
                    idContract.add(boleto.idcontrato__c);
                }

                return [SELECT id, numeroparcela__c, numeroapolice__c, status__c, idcontrato__c, urlboleto__c, vencimento__c FROM public_boleto__x where (status__c = 'Emitido' or status__c = 'EMITIDO') and dataprocessamento__c >=: dateFilter and idcontrato__c in : idContract order by idcontrato__c, numeroparcela__c asc ]; //PLV-4910 - INÍCIO/FIM // PLV-4910-FIX
                //II-138 FIM
            //}
        }else{
            // PLV-4567-COMPLEMENTO FIM
            String jsons = '[{"Id":"x0EL0000000004wMAA","numeroparcela__c":"1","numeroapolice__c":"123","status__c":"Emitido","idcontrato__c":"#idcontrato#", "datavencimento":"2012-12-12 "},{"Id":"x0EL0000000004yMAA","numeroparcela__c":"2","numeroapolice__c":"738","status__c":"Emitido","idcontrato__c":"#idcontrato#", "datavencimento":"2012-12-12 "}]';
            jsons = jsons.replace('#idcontrato#', idContratoTest);
            System.debug('id ' + idContratoTest);
            return (List<public_boleto__x>) JSON.deserialize(jsons, List<public_boleto__x>.class);
        }
    }

    global void execute(Database.BatchableContext BC, List<public_boleto__x> scope){
        List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
        List<public_boleto__x> listBoleto = (List<public_boleto__x>) scope;
        List<Id> listIdContrato = new List<Id>();

        //II-138 INICIO
        System.debug('scope >>' + scope);
        Map<Id, List<public_boleto__x>> mapContratoBoletos = new Map<Id, List<public_boleto__x>>();
        for(public_boleto__x boleto : scope){
            if(!mapContratoBoletos.containsKey(boleto.idcontrato__c)){
                mapContratoBoletos.put(boleto.idcontrato__c, new List<public_boleto__x>());
            }
            mapContratoBoletos.get(boleto.idcontrato__c).add(boleto);
        }
        System.debug('Teste mapContratoBoletos >>' + mapContratoBoletos);
        //II-138 FIM
        
        EmailTemplate templateBoasVindas = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName= 'BoasVindasHtml'];
        EmailTemplate templateEndosso = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName= 'EndossoHtml'];
        EmailTemplate templateEmailRenovacao = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName= 'EmailRenovacaoBoleto']; //FNPVVEP-151 INICIO/FIM
        List<CopiaEmail__mdt> copiasEmailBoasVindas = [SELECT Email__c, Template__c, Ativo__c FROM CopiaEmail__mdt WHERE Ativo__c = true AND Template__c LIKE '%BoasVindasHtml%' ]; //PLV-4910 - INÍCIO/FIM
        List<CopiaEmail__mdt> copiasEmailEndosso = [SELECT Email__c, Template__c, Ativo__c FROM CopiaEmail__mdt WHERE Ativo__c = true AND Template__c LIKE '%EndossoHtml%' ]; //PLV-4910 - INÍCIO/FIM
        List<CopiaEmail__mdt> copiasEmail = new List<CopiaEmail__mdt>(); //PLV-4910 - INÍCIO/FIM
        NamedCredential endpontSF = [select Endpoint from NamedCredential where DeveloperName = 'SFECM' limit 1];
        String nomeSocial = ''; //LECVPV_190 FIX03 - INICIO/FIM
        
        
        for(public_boleto__x boleto : listBoleto){
            listIdContrato.add(boleto.idcontrato__c);
        }

        List<ImagemTemplate__mdt> urlTempalte = [SELECT UrlImagem__c FROM ImagemTemplate__mdt WHERE NomeTemplate__c = 'Header Renovacao'];//RVI-194 - INICIO/FIM

        //RVI-144 - INICIO
        Set<Id> ctrIds = new Set<Id>();
        List<ContratanteContrato__c> listContratanteContrato = [SELECT Id, Contrato__r.Account.Name, Contrato__r.Account.NomeSocial__c, Contrato__r.Proposta__r.Name, Contrato__r.EndossoPdfDownloadUrl__c, Contrato__r.ApolicePdfDownloadUrl__c, Contrato__r.NumeroApolice__c, Contrato__r.Account.PersonEmail, Contrato__r.Account.PersonMobilePhone, Contrato__r.tipo__c, Contrato__r.email__c, QuantidadeParcelas__c, Contrato__r.VigenciaFinal__c, Contrato__r.Proposta__r.CodigoCorretor__r.Name, Contrato__c, Contrato__r.DistributionPublicUrl__c, Contrato__r.Senha__c FROM ContratanteContrato__c WHERE Contrato__c IN: listIdContrato]; //II-138 FIX03 INICIO/FIM  && LECVPV_190 FIX03 - INICIO/FIM      
        for(ContratanteContrato__c ctr : listContratanteContrato) ctrIds.add(ctr.Contrato__r.Id); 
        List<GarantiaContrato__c> listGarantiaContrato = [SELECT Capital__c, Garantia__r.Name FROM GarantiaContrato__c WHERE Contrato__c IN :ctrIds];
        List<public_boleto__x> listUpdateBoleto = new List<public_boleto__x>();
        //RVI-144 - FIM
        System.debug('listContrante> ' + Json.Serialize(listContratanteContrato));
        for(ContratanteContrato__c contratante : listContratanteContrato){
            Boolean bloqueiaEmail = false; //PLV-5744 INCIO/FIM
            String bodyToSend = null;
            String subject = null;
            if(contratante.Contrato__r.tipo__c == 'Endosso'){
                if(!Test.isRunningTest()){
                    copiasEmail = copiasEmailEndosso; //PLV-4910 - INÍCIO/FIM
                    bodyToSend = templateEndosso.HtmlValue;
                }else{
                    bodyToSend = '<html><head><meta http-equiv="PRAGMA" content="NO-CACHE"><meta http-equiv="Expires" content="Mon, 01 Jan 1990 12:00:00 GMT">        <meta content="text/html; charset=UTF-8" http-equiv="Content-Type">        <meta content="width=device-width,initial-scale=1" name="viewport">        <title>Porto Seguro - Endosso</title>    </head>    <body style="font-family:Arial, Helvetica, sans-serif; margin:0; background-color: #efefef;">        <table style="width:600px; background-color: #ffffff; margin-left: auto; margin-right: auto; border-collapse:collapse;">            <tbody>                <tr>                    <td><table border="0" cellpadding="0" cellspacing="0" style="width:600px; background-color: #ffffff; margin-left: auto; margin-right: auto;" width="600">    <tbody>        <tr>            <td><img src="https://portoseguro--sniper--c.cs249.visual.force.com/resource/1603831443000/PortoSeguroTemplate/portoseguro-topo.jpg" style="display:block;max-width:100%">            </td>        </tr>    </tbody></table>                    </td>                </tr>                <tr>                    <td style="padding:10px 30px 1px 30px; text-align: justify;">                        <p style="font-size:20px; line-height:26px; color:#00adee;">                            <strong>Olá, #nomeConta#.</strong>                        </p>                        <p style="font-size: 14px; line-height: 20px; font-family: tahoma,geneva,sans-serif;">                            <strong>Informamos que a alteração em sua apólice do Porto Seguro Vida foi realizada de acordo com a sua solicitação.</strong><br><br>                            Pedimos que confira atentamente os detalhes da sua  apólice e, caso tenha alguma dúvida, procure a Central de  Atendimento Vida e Previdência ou consulte o seu Corretor.                            <br><br>Esperamos que você desfrute com saúde e alegria todos os  momentos da vida.                        </p>                        <p style="font-size:15px; line-height:18px;">                            <a href="#endosso#">Clique aqui</a> e confira o documento de Endosso da apólice do seu Seguro de Vida Individual, com as especificações de seguro e das coberturas contratadas.<br/>#boletos#                        </p>                                            </td>                </tr>                <tr>                    <td class="conte" style="padding: 0px 30px 30px 30px;">                        <table style="width: 100%; border-collapse:collapse;">                            <tbody>                                <tr>                                    <td style="border-bottom:1px solid #919191;">                                        <p class="conte-conosco" style="font-size:15px;">                                            Um abraço,<br><br>                                            <strong>                                                <br>                                                Diretoria Porto Seguro Vida e Previdência                                            </strong>                                        </p>                                        <p class="conte-conosco" style="font-size:15px;">                                            <span class="conte-porto" style=" font-size:20px;">Porto Seguro <strong class="conte-vida" style="color:#e528a9;">Para Toda Vida</strong>.</span>                                        </p>                                    </td>                                </tr>                            </tbody>                        </table>                    </td>                </tr>            </tbody>        </table>    <table id="rodape-2016" style=" width: 600px; margin-left: auto; margin-right: auto; border-collapse:collapse;">         <tbody>            <tr>                <td class="links" style="padding: 10px;  border-top: #b0b0b0 1px solid; border-bottom: #b0b0b0 1px solid; background-color: #F0F0F0; text-align: center;">                    <table class="rodape-2016-divisao" style="width: 24%; display: inline-flex; justify-content: center; border-collapse:collapse;">                        <tbody>                            <tr>                                <td class="link" style="padding: 10px; font-family:Arial, Helvetica, sans-serif; font-size:12px; color:#5e5e5e;">                                    <a href="https://www.portoseguro.com.br/fale-conosco/contatos#redes-sociais?utm_campaign=comm_news_vida&amp;#38;utm_source=rodape_fixo&amp;#38;utm_medium=eml" style="color:#5e5e5e;">Redes Sociais</a>                                </td>                            </tr>                        </tbody>                    </table>                    <table class="rodape-2016-divisao" style="width: 24%; display: inline-flex; justify-content: center; border-collapse:collapse;">                        <tbody>                                 <tr>                                <td class="link" style="padding: 10px; font-family:Arial, Helvetica, sans-serif; font-size:12px; color:#5e5e5e;">                                    <a href="https://www.portoseguro.com.br/cliente?utm_campaign=comm_news_vida&amp;#38;utm_source=rodape_fixo&amp;#38;utm_medium=eml" style="color:#5e5e5e;">Área do Cliente</a>                                </td>                            </tr>                        </tbody>                    </table>                    <table class="rodape-2016-divisao" style="width: 24%; display: inline-flex; justify-content: center;border-collapse:collapse;">                    <tbody>                        <tr>                            <td class="link" style="padding: 10px; font-family:Arial, Helvetica, sans-serif; font-size:12px; color:#5e5e5e;">                                <a href="https://www.portoseguro.com.br/fale-conosco/contatos?utm_campaign=comm_news_vida&amp;#38;utm_source=rodape_fixo&amp;#38;utm_medium=eml" style="color:#5e5e5e;">Atendimento</a>                            </td>                        </tr>                    </tbody>                </table>                <table class="rodape-2016-divisao" style="width: 24%; display: inline-flex; justify-content: center; border-collapse:collapse;">                    <tbody>                        <tr>                            <td class="link" style="padding: 10px; font-family:Arial, Helvetica, sans-serif; font-size:12px; color:#5e5e5e;">                                <a href="https://www.portoseguro.com.br/institucional/responsabilidade-socioambiental/projetos-corporativos/negocios-sustentaveis?utm_campaign=comm_news_vida&amp;#38;utm_source=rodape_fixo&amp;#38;utm_medium=eml" style="color:#5e5e5e;">Sustentabilidade</a>                            </td>                        </tr>                    </tbody>                </table>            </td>        </tr>        <tr>            <td class="informacoes contato" style="color: #5e5e5e; padding-top: 20px !important; padding: 10px; font-family: Arial, Helvetica, sans-serif; font-size: 12px;  text-align: justify;">                <strong>11 3366 3377</strong> (Grande São Paulo) | <strong>0800 727 9393</strong> (Demais localidades) | <strong>0800 727 2746</strong> (SAC - informação, reclamação e cancelamento - 24horas) | <strong>0800 727 8736</strong> (SAC 24h - atendimento exclusivo para deficientes auditivos) | <strong>0800 727 1184</strong> (Ouvidoria - das 8h15 às 18h30, de segunda a sexta-feira, exceto feriados)            </td>        </tr>        <tr>                <td class="informacoes" style="font-family: Arial, Helvetica, sans-serif; font-size: 12px; color: #b0b0b0; padding: 10px; text-align: justify;">                    Informações reduzidas. Consulte as Condições Gerais do seguro contratado no site <a href="http://www.portoseguro.com.br/vida?utm_campaign=comm_news_vida&amp;#38;utm_source=rodape_fixo&amp;#38;utm_medium=eml" target="_blank">www.portoseguro.com.br/vida</a>. Processos Susep: Seguro Vida e Acidentes Pessoais Individual Anual: 15414.902186/2014-52; Acidentes Pessoais Individual Plus Anual:  15414.902183/2014-19; Vida Mais Mulher Anual: 15414.902184/2014-63; Vida mais Simples Anual: 15414.902185/2014-16. Sorteio vinculado a Título de Capitalização, modalidade incentivo, emitido pela Porto Seguro Capitalização S/A; CNPJ:16.551.758/0001-58 e processo SUSEP nº 15414.900181.2019-08. O titular sempre terá direito ao recebimento do dinheiro, se assim o desejar. Valor da premiação tem incidência de imposto de renda. É proibida a venda de títulos de capitalização a menores de dezesseis anos. Antes de contratar consulte as condições gerais. O registro deste plano na SUSEP não implica, por parte da Autarquia, incentivo ou recomendação à sua comercialização. A aceitação do seguro está sujeita à análise de risco.                </td>            </tr>        </tbody>    </table>    <form action="#" method="GET" name="resizeData"><input type="hidden" id="baseUrl" name="baseUrl" value="https://portoseguro--Sniper.my.salesforce.com"><input type="hidden" id="path" name="path" value="/email/templaterenderer"><input type="hidden" id="previewFrameName" name="previewFrameName" value="preview_frame"><input type="hidden" id="previewFrame" name="previewFrame" value="previewFrame"><input type="hidden" id="render_type_name" name="render_type_name" value="render_type"><input type="hidden" id="render_type" name="render_type" value="RESIZE_FRAME"><input type="hidden" id="previewWidthName" name="previewWidthName" value="preview_width"><input type="hidden" id="previewHeightName" name="previewHeightName" value="preview_height"></form><script src="https://portoseguro--Sniper.my.salesforce.com/email/wysiwyg/resize.js"></script></body></html>'; //PLV-5203 INICIO/FINAL FIX1
                }
                if(bodyToSend == null)
                    return;
                //PLV-5744 INICIO
                if (contratante.Contrato__r.EndossoPdfDownloadUrl__c == null) {
                    bloqueiaEmail = true;
                } else {
                    bodyToSend = bodyToSend.replace('#endosso#', contratante.Contrato__r.EndossoPdfDownloadUrl__c);
                }
                 //PLV-5744 FIM
                subject = 'Porto Seguro - Endosso';
                // RVI-144 - INICIO
            }else if(contratante.Contrato__r.Tipo__c == 'Renovacao'){ 
                if(!Test.isRunningTest()){
                    copiasEmail = copiasEmailBoasVindas; //II-146 - INICIO
                    bodyToSend = templateEmailRenovacao.HtmlValue; //II-146 - FIM  //FNPVVEP-151 INICIO/FIM
                }else{
                    bodyToSend = '<html><head><title></title></head><body><table align="center" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="principal" width="600"><tbody><tr><td><img src="#ImagemEmail#" style="display: block; max-width: 100%; width: 600px; height: 354px;" /></td></tr><tr><td style="padding:30px;"><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td style="padding-bottom: 10px"><p style="font-size:20px; line-height:20px;color: #0099FF;"><span style="font-size:20px;"><span style="font-family:arial,helvetica,sans-serif;"><strong>Ol&aacute; #nome#,</strong></span></span></p><p style="text-align: justify;"><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"> Estamos felizes em ter voc&ecirc; como cliente e agradecemos a confian&ccedil;a de escolher ser cada vez mais um Porto Seguro para voc&ecirc; e sua fam&iacute;lia. </span></span></p><p style="text-align: justify;"><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"> Chegou o momento de renovar o seu seguro de vida e garantir a seguran&ccedil;a necess&aacute;ria com uma prote&ccedil;&atilde;o que mantem mais tranquilidade para todos os momentos da vida. </span></span></p><p style="text-align: justify;"><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"> Dessa forma, basta realizar o pagamento da primeira parcela, conforme a op&ccedil;&atilde;o escolhida <!--RVI-210 INICIO --> <!-- no documento anexo--> em sua contratação. <!-- RVI-210 FIM --> </span></span></p><p style="text-align: justify;"><strong><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"> A seguir voc&ecirc; confere o valor de capital segurado e as prote&ccedil;&otilde;es do seu seguro de vida: </span></span></strong></p><table border="0" cellpadding="1" cellspacing="1" style="width: 530px"><tbody><tr><td style="text-align: center; background-color: rgb(214, 215, 210);"><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"> Cobertura </span></span></td><td style="text-align: center; background-color: rgb(214, 215, 210);"><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"> Capital Segurado </span></span></td></tr><tr><td style="text-align: center;"><span style="font-size:14px;"> #garantiaNome# </span></td><td style="text-align: center;"><span style="font-size:14px;"> #garantiaCapital# </span></td></tr></tbody></table></td></tr><tr><td style="padding-bottom: 10px"><p style="text-align: justify;"><br /><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"> Lembramos que, de acordo com as condi&ccedil;&otilde;es contratuais, o valor mensal do seu seguro est&aacute; sendo reajustado. </span></span></p><p style="text-align: justify;"><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"> Em caso de d&uacute;vida, acesse&nbsp;<a href="http://www.portoseguro.com.br/vida" target="_blank">www.portoseguro.com.br/vida</a>&nbsp;e confira a Condi&ccedil;&atilde;o Geral, no item &quot;Reajuste do Pr&ecirc;mio por Idade e Atualiza&ccedil;&atilde;o do Capital&quot;. </span></span></p><p style="text-align: justify;"><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"><!-- RVI-210 INICIO --><!--<a href="#linkApolice#">Clique aqui</a> e confira a apólice do seu Seguro de Vida Individual, com as especificações de seguro e das coberturas contratadas.--><!-- RVI-210 FIM --></span></span></p><p><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"> #boletos# </span></span></p></td></tr></tbody></table></td></tr><tr><td bgcolor="#F7F7F7" style="padding: 30px;"><table cellpadding="0" cellspacing="0" class="columns" style="float:left;" width="25%"><tbody><tr><td class="mobile"><img alt="" src="https://www.portoseguro.com.br/NovoInstitucional/static_files/images/Informes%20de%20Rendimentos/Imagens/Vida%20Inteira/portoseguro-icon2png.png" style="width: 104px; height: 72px;" /></td></tr></tbody></table><table cellpadding="0" cellspacing="0" class="columns" style="float:left;" width="75%"><tbody><tr><td style="font-size: 14px;"><p style="text-align: justify;"><strong style="font-family: arial, helvetica, sans-serif; font-size: 16px;">Confira abaixo os dados do seu cadastro:</strong><br /><br /><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"><strong>Proposta n&ordm;:</strong>#proposta#<br /><strong>Ap&oacute;lice n&deg;:&nbsp;</strong></span></span><span style="font-family: arial, helvetica, sans-serif;">#apolice#</span><br /><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"><strong>Vig&ecirc;ncia:&nbsp;</strong></span></span><span style="font-family: arial, helvetica, sans-serif;">#vigenciaFinal#</span><br /><span style="font-size:14px;"><span style="font-family:arial,helvetica,sans-serif;"><strong>Corretor:&nbsp;</strong>#corretor#</span></span></p></td></tr></tbody></table></td></tr><tr><td bgcolor="#F7F7F7" style="padding: 30px;"><table cellpadding="0" cellspacing="0" class="columns" style="float: left;" width="25%"><tbody><tr><td class="mobile"><img alt="" src="https://www.portoseguro.com.br/NovoInstitucional/static_files/images/Informes%20de%20Rendimentos/Imagens/Vida%20Inteira/portoseguro-icon3png.png" style="width: 104px; height: 72px;" /></td></tr></tbody></table><table cellpadding="0" cellspacing="0" class="columns" style="float: left;" width="75%"><tbody><tr><td style="font-size: 14px;"><p style="text-align: justify;"><span style="font-family: arial, helvetica, sans-serif;">Continuamos &agrave; sua disposi&ccedil;&atilde;o e, sempre que precisar, n&atilde;o deixe de falar com o seu Corretor ou entrar em contato conosco pelos canais digitais como&nbsp;<strong>WhatsApp</strong>, atrav&eacute;s do n&uacute;mero&nbsp;<strong>(11) 3003-9303</strong>,&nbsp;<a href="http://www.portoseguro.com.br/a-porto-seguro/fale-com-a-porto-seguro/chat-on-line">Chat Online</a>&nbsp;ou&nbsp;<a href="http://www.portoseguro.com.br/cliente">&Aacute;rea do Cliente</a>. Estamos dispon&iacute;veis tamb&eacute;m na&nbsp;<strong>Central de Atendimento</strong>, nos telefones&nbsp;<strong>(11) 3366-3377</strong>&nbsp;(Capital e Grande S&atilde;o Paulo) e&nbsp;<strong>0800 727 9393</strong>&nbsp;(Demais localidades).</span></p></td></tr></tbody></table></td></tr><tr><td style="padding: 30px; line-height: 24px"><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td style="padding-bottom: 20px; border-bottom: 1px solid #929292;"><span style="font-family:arial,helvetica,sans-serif;"><span style="font-size: 14px;">Um abra&ccedil;o!</span><br /><br /><span style="font-size: 20px;">Porto Seguro <strong style="color: #3C97A8;">Para Toda Vida</strong>.</span></span></td></tr></tbody></table></td></tr><tr><td style="padding: 30px; line-height: 24px; text-align: justify;"><p><span style="font-size:10px;"><span style="font-family:arial,helvetica,sans-serif;"><strong>11 3366 3377</strong>&nbsp;(Grande S&atilde;o Paulo) |&nbsp;<strong>0800 727 9393</strong>&nbsp;(Demais localidades) |&nbsp;<strong>0800 727 2746</strong>&nbsp;(SAC - informa&ccedil;&atilde;o, reclama&ccedil;&atilde;o e cancelamento - 24horas) |&nbsp;<strong>0800 727 8736</strong>&nbsp;(SAC 24h - atendimento exclusivo para deficientes auditivos) |&nbsp;<strong>0800 727 1184</strong>&nbsp;(Ouvidoria - das 8h15 &agrave;s 18h30, de segunda a sexta-feira, exceto feriados)</span></span></p><p><span style="font-size:10px;"><span style="font-family:arial,helvetica,sans-serif;">Informa&ccedil;&otilde;es reduzidas. Consulte as Condi&ccedil;&otilde;es Gerais do seguro contratado no site&nbsp;<a href="https://www.google.com/url?q=http://www.portoseguro.com.br/vida?utm_campaign%3Dcomm_news_vida%26utm_source%3Drodape_fixo%26utm_medium%3Deml&amp;source=gmail-html&amp;ust=1638471085772000&amp;usg=AOvVaw0vPwZ0fQ39QESNo6m5z8dZ" target="_blank">www.portoseguro.com.br/vida</a>. Processos Susep: Seguro de Pessoais Individual: 15414.901355/2016-07. Antes de contratar consulte as condi&ccedil;&otilde;es gerais. O registro deste plano na SUSEP n&atilde;o implica, por parte da Autarquia, incentivo ou recomenda&ccedil;&atilde;o &agrave; sua comercializa&ccedil;&atilde;o. A aceita&ccedil;&atilde;o do seguro est&aacute; sujeita &agrave; an&aacute;lise de risco.</span></span></p><p><span style="font-size:10px;"><span style="font-family:arial,helvetica,sans-serif;"><strong>Porto Seguro Cia de Seguros Gerais</strong><br />Al. Bar&atilde;o de Piracicaba, 618 - Torre B - 3&ordm; Andar - Campos El&iacute;seos - S&atilde;o Paulo - SP - CEP 01216-012</span></span></p></td></tr></tbody></table><p>&nbsp;</p></body></html>'; //RVI-194 - INICIO/FIM
                } 
                if(bodyToSend == null) return;
                //Formatação da lista
                String nomeGarantias = null;
                String nomeCapital = null;
                for(GarantiaContrato__c lGCtr : listGarantiaContrato){
                    nomeCapital   += String.valueOf(lGCtr.Capital__c) + '\n';
                    nomeGarantias += String.valueOf(LGCtr.Garantia__r.Name) + '\n';
                }
                    bodyToSend = bodyToSend.replace('#garantiaNome#', nomeGarantias);
                    bodyToSend = bodyToSend.replace('#garantiaCapital#', nomeCapital);
                    bodyToSend = bodyToSend.replace('#ImagemEmail#', urlTempalte[0].UrlImagem__c); //RVI-194 - INICIO/FIM
                //for(ContratanteContrato__c ctCtr : listContratanteContrato){//FNPVVEP-43 - INICIO
                    //II-138 INICIO
                    if(contratante.Contrato__r.ApolicePdfDownloadUrl__c != null){
                        bodyToSend = bodyToSend.replace('#linkApolice#', contratante.Contrato__r.ApolicePdfDownloadUrl__c);
                    }
                    //II-138 FIM
                    //II-138 FIX02 INICIO

                    bodyToSend = bodyToSend.replace('#apolice#', contratante.Contrato__r.NumeroApolice__c);
                    bodyToSend = bodyToSend.replace('#proposta#', contratante.Contrato__r.Proposta__r.Name);
                    bodyToSend = bodyToSend.replace('#vigenciaFinal#', String.valueOf(contratante.Contrato__r.VigenciaFinal__c));
                    bodyToSend = bodyToSend.replace('#corretor#', contratante.Contrato__r.Proposta__r.CodigoCorretor__r.Name);
                    //Demanda S.I PROD - INICIO
                    nomeSocial = String.isEmpty(contratante.Contrato__r.Account.NomeSocial__c) ? contratante.Contrato__r.Account.Name : contratante.Contrato__r.Account.NomeSocial__c; //LECVPV_190 FIX03 - INICIO/FIM
                    bodyToSend = bodyToSend.replace('{!if(Account.NomeSocial__c="", Account.Name, Account.NomeSocial__c)}', nomeSocial); //LECVPV_190 FIX03 - INICIO/FIM
                    bodyToSend = bodyToSend.replace('{!Contract.DistributionPublicUrl__c}', contratante.Contrato__r.DistributionPublicUrl__c);
                    bodyToSend = bodyToSend.replace('{!Contract.Senha__c}', contratante.Contrato__r.Senha__c);
                    
                    bodyToSend = contratante.Contrato__r.Account.PersonMobilePhone !=null 
                        ? bodyToSend.replace('#cel#', contratante.Contrato__r.Account.PersonMobilePhone) 
                        : bodyToSend.replace('#cel#', '');
                    if (contratante.Contrato__r.Account.PersonEmail == null) {
                        bloqueiaEmail = true;  
                    } else {
                        bodyToSend = bodyToSend.replace('#email#', contratante.Contrato__r.Account.PersonEmail); 
                    }
                    //
                    //Demanda S.I PROD - FIM
                    //II-138 FIX02 FIM
                    subject = 'Porto Seguro - Renovação';
                //}//FNPVVEP-43 - FIM                
                // RVI-144 - FIM
            }else{
                if(!Test.isRunningTest()){
                    copiasEmail = copiasEmailBoasVindas; //PLV-4910 - INÍCIO/FIM
                    bodyToSend = templateBoasVindas.HtmlValue;
                }else{
                    bodyToSend = '<html><head><meta http-equiv="PRAGMA" content="NO-CACHE"><meta http-equiv="Expires" content="Mon, 01 Jan 1990 12:00:00 GMT">            <meta content="text/html; charset=UTF-8" http-equiv="Content-Type">            <meta content="width=device-width,initial-scale=1" name="viewport">            <title>Porto Seguro - Boas Vindas</title>                        <style><!--              /*  table{                    border-collapse:collapse;                }                                                .informacoes{                    font-family: Arial, Helvetica, sans-serif;                    font-size: 12px;                    color: #b0b0b0;                    padding: 10px 20px 20px 20px !important;                    text-align: justify;                }                                @media screen and (max-width:600px) {                    #principal, .principal{                        width:100%;                    }                                        #rodape-2016 {                        width:100%;                    }                                        .rodape-2016-divisao {                        float:left;                        width:100%;                        margin:0px auto 20px auto;                    }                                        .columns{                        width:100%;                    }                                        .alingweb-mob{                        text-align:center;                    }                    .displaynone{                        display:none;                    }                }*/            //--></style>        </head>        <body style="font-family:Arial, Helvetica, sans-serif; margin:0; background-color: #efefef;"><span id="j_id0:emailTemplate:j_id3:j_id4:j_id6:j_id7:j_id9">                <table style="width:600px; background-color: #ffffff; margin-left: auto; margin-right: auto;">                    <tbody>                        <tr>                            <td><table border="0" cellpadding="0" cellspacing="0" style="width:600px; background-color: #ffffff; margin-left: auto; margin-right: auto;" width="600">    <tbody>        <tr>            <td><img src="https://portoseguro--sniper--c.cs249.visual.force.com/resource/1603831443000/PortoSeguroTemplate/portoseguro-topo.jpg" style="display:block;max-width:100%">            </td>        </tr>    </tbody></table>                            </td>                        </tr>                        <tr>                            <td style="padding:10px 30px 1px 30px; text-align: justify;">                                <p style="font-size:20px; line-height:26px; color:#00adee;">                                    <strong>Olá, #nomeConta#.</strong>                                </p>                                <p style="font-size:15px; line-height:18px;">                                    Agradecemos a sua confiança em escolher o <strong>Porto Seguro Vida</strong>.                                     Planejamento, inclusive financeiro, é fundamental para que você tenha mais tranquilidade para aproveitar o hoje ao máximo, sem precisar se preocupar com as incertezas do amanhã.                                    <br><br>                                    <a href="#novo#">Clique aqui</a> e confira a apólice do seu Seguro de Vida Individual, com as especificações de seguro e das coberturas contratadas.                                    <br><br>                                    Você pode consultar a sua apólice a qualquer momento na <strong>Área do Cliente</strong>, além de imprimir a 2ª via de boleto, acompanhar seus pagamentos, consultar as coberturas contratadas e muito mais.                                </p>                            </td>                        </tr>                        <tr>                            <td class="center acesse" style="display: inline-block; text-align: center; width: 100%">                                <a href="https://www.portoseguro.com.br/" style="text-decoration:none; display: inline-block;" target="_blank">                                        <p style="color:#ffffff; font-size:14px; background:#00adee; width:200px;padding:15px 0px;"><strong>Acesse e cadastre-se</strong></p>                                </a>                            </td>                        </tr>                        <tr>                            <td class="dados" style="padding:0px 30px 30px 30px;">                                <table style="width: 100%;">                                    <tbody>                                        <tr>                                            <td style="padding-bottom:0px; border-bottom:1px solid #919191; text-align: justify;">                                                <p style="font-size:15px;">Confira abaixo se os dados do seu cadastro estão corretos. Se alguma informação estiver errada, entre em contato com seu Corretor para atualizá-los.<br><br>                                                    <strong>Apólice: #apolice#</strong> <br>                                                    <strong>E-mail: #email#</strong> <br>                                                    <strong>Cel.: #cel#</strong> #boletos#                                                </p>                                            </td>                                        </tr>                                    </tbody>                                </table>                            </td>                        </tr>                        <tr>                            <td class="center clube" style="display: inline-block; text-align: center; width: 100%">                                <table style="display: inline-block;" width="90%">                                    <tbody>                                        <tr>                                            <td class="clube-container" style="background-color: #f1f5fa;">                                                <table class="columns" style="float:left;" width="45%">                                                    <tbody>                                                        <tr>                                                            <td class="center clubeporto" style="display: flex; justify-content: center; text-align: center; align-items: center; padding:30px 0px;"><img src="https://portoseguro--sniper--c.cs249.visual.force.com/resource/1603831443000/PortoSeguroTemplate/ClubePORTO.jpg" style="display: inline-block;">                                                            </td>                                                        </tr>                                                    </tbody>                                                </table>                                                <table class="columns" style="float:left;" width="49%">                                                    <tbody>                                                        <tr>                                                            <td>                                                                <p class="clube-cliente" style="font-size:15px; text-align: left;">Cliente <strong>Porto Seguro Vida</strong> tem descontos especiais em teatros e exposições, restaurantes, viagem e turismo, eletrodomésticos e muito mais. Acesse, cadastre-se e aproveite.</p>                                                            </td>                                                        </tr>                                                        <tr>                                                            <td class="center clube-parte" style="display: inline-block;">                                                                <a href="https://www.clubeportoseguro.com.br/" style="text-decoration:none;" target="_blank">                                                                    <p style="font-size:15px; text-align:center; color:#ffffff; background:#00adee; width:200px; padding:15px;margin-top:0px;">Faça parte</p>                                                                </a>                                                            </td>                                                        </tr>                                                    </tbody>                                                </table>                                            </td>                                        </tr>                                    </tbody>                                </table>                            </td>                        </tr>                        <tr>                            <td class="conte" style="padding: 0px 30px 30px 30px;">                                <table style="width: 100%;">                                    <tbody>                                        <tr>                                            <td style="border-bottom:1px solid #919191;">                                                <p class="conte-conosco" style="font-size:15px;"><strong>Conte sempre conosco e com seu Corretor.</strong><br><br>                                                    <span class="conte-corretor" style="color:#00adee;"><br>                                                        <br>                                                                                                            </span><br><br>                                                    Um abraço,<br><br>                                                    <strong>                                                        <br>                                                        Diretoria Porto Seguro Vida e Previdência                                                    </strong>                                                </p>                                                <p class="conte-conosco" style="font-size:15px;">                                                    <span class="conte-porto" style=" font-size:20px;">Porto Seguro <strong class="conte-vida" style="color:#e528a9;">Para Toda Vida</strong>.</span>                                                </p>                                            </td>                                        </tr>                                    </tbody>                                </table>                            </td>                        </tr>                    </tbody>                </table>    <span id="j_id0:emailTemplate:j_id3:j_id4:j_id6:j_id7:j_id19:j_id20:j_id22">            </span><table id="rodape-2016" style=" width: 600px; margin-left: auto; margin-right: auto; border-collapse:collapse;">         <tbody>            <tr>                <td class="links" style="padding: 10px;  border-top: #b0b0b0 1px solid; border-bottom: #b0b0b0 1px solid; background-color: #F0F0F0; text-align: center;">                    <table class="rodape-2016-divisao" style="width: 24%; display: inline-flex; justify-content: center; border-collapse:collapse;">                        <tbody>                            <tr>                                <td class="link" style="padding: 10px; font-family:Arial, Helvetica, sans-serif; font-size:12px; color:#5e5e5e;">                                    <a href="https://www.portoseguro.com.br/fale-conosco/contatos#redes-sociais?utm_campaign=comm_news_vida&amp;#38;utm_source=rodape_fixo&amp;#38;utm_medium=eml" style="color:#5e5e5e;">Redes Sociais</a>                                </td>                            </tr>                        </tbody>                    </table>                    <table class="rodape-2016-divisao" style="width: 24%; display: inline-flex; justify-content: center; border-collapse:collapse;">                        <tbody>                                 <tr>                                <td class="link" style="padding: 10px; font-family:Arial, Helvetica, sans-serif; font-size:12px; color:#5e5e5e;">                                    <a href="https://www.portoseguro.com.br/cliente?utm_campaign=comm_news_vida&amp;#38;utm_source=rodape_fixo&amp;#38;utm_medium=eml" style="color:#5e5e5e;">Área do Cliente</a>                                </td>                            </tr>                        </tbody>                    </table>                    <table class="rodape-2016-divisao" style="width: 24%; display: inline-flex; justify-content: center;border-collapse:collapse;">                    <tbody>                        <tr>                            <td class="link" style="padding: 10px; font-family:Arial, Helvetica, sans-serif; font-size:12px; color:#5e5e5e;">                                <a href="https://www.portoseguro.com.br/fale-conosco/contatos?utm_campaign=comm_news_vida&amp;#38;utm_source=rodape_fixo&amp;#38;utm_medium=eml" style="color:#5e5e5e;">Atendimento</a>                            </td>                        </tr>                    </tbody>                </table>                <table class="rodape-2016-divisao" style="width: 24%; display: inline-flex; justify-content: center; border-collapse:collapse;">                    <tbody>                        <tr>                            <td class="link" style="padding: 10px; font-family:Arial, Helvetica, sans-serif; font-size:12px; color:#5e5e5e;">                                <a href="https://www.portoseguro.com.br/institucional/responsabilidade-socioambiental/projetos-corporativos/negocios-sustentaveis?utm_campaign=comm_news_vida&amp;#38;utm_source=rodape_fixo&amp;#38;utm_medium=eml" style="color:#5e5e5e;">Sustentabilidade</a>                            </td>                        </tr>                    </tbody>                </table>            </td>        </tr>        <tr>            <td class="informacoes contato" style="color: #5e5e5e; padding-top: 20px !important; padding: 10px; font-family: Arial, Helvetica, sans-serif; font-size: 12px;  text-align: justify;">                <strong>11 3366 3377</strong> (Grande São Paulo) | <strong>0800 727 9393</strong> (Demais localidades) | <strong>0800 727 2746</strong> (SAC - informação, reclamação e cancelamento - 24horas) | <strong>0800 727 8736</strong> (SAC 24h - atendimento exclusivo para deficientes auditivos) | <strong>0800 727 1184</strong> (Ouvidoria - das 8h15 às 18h30, de segunda a sexta-feira, exceto feriados)            </td>        </tr><tr>                <td class="informacoes chat" style="font-family: Arial, Helvetica, sans-serif; font-size: 12px; color:#b0b0b0; padding: 10px; text-align: justify;">                    <a href="http://porto.vc/chatonline?utm_campaign=comm_news_vida&amp;#38;utm_source=rodape_fixo&amp;#38;utm_medium=eml" target="_blank">Chat On-line.</a><br>                </td>            </tr>        <tr>                <td class="informacoes" style="font-family: Arial, Helvetica, sans-serif; font-size: 12px; color: #b0b0b0; padding: 10px; text-align: justify;">                    Informações reduzidas. Consulte as Condições Gerais do seguro contratado no site <a href="http://www.portoseguro.com.br/vida?utm_campaign=comm_news_vida&amp;#38;utm_source=rodape_fixo&amp;#38;utm_medium=eml" target="_blank">www.portoseguro.com.br/vida</a>. Processos Susep: Seguro Vida e Acidentes Pessoais Individual Anual: 15414.902186/2014-52; Acidentes Pessoais Individual Plus Anual:  15414.902183/2014-19; Vida Mais Mulher Anual: 15414.902184/2014-63; Vida mais Simples Anual: 15414.902185/2014-16. Sorteio vinculado a Título de Capitalização, modalidade incentivo, emitido pela Porto Seguro Capitalização S/A; CNPJ:16.551.758/0001-58 e processo SUSEP nº 15414.900181.2019-08. O titular sempre terá direito ao recebimento do dinheiro, se assim o desejar. Valor da premiação tem incidência de imposto de renda. É proibida a venda de títulos de capitalização a menores de dezesseis anos. Antes de contratar consulte as condições gerais. O registro deste plano na SUSEP não implica, por parte da Autarquia, incentivo ou recomendação à sua comercialização. A aceitação do seguro está sujeita à análise de risco.                </td>            </tr>        </tbody>    </table></span>        <form action="#" method="GET" name="resizeData"><input type="hidden" id="baseUrl" name="baseUrl" value="https://portoseguro--Sniper.my.salesforce.com"><input type="hidden" id="path" name="path" value="/email/templaterenderer"><input type="hidden" id="previewFrameName" name="previewFrameName" value="preview_frame"><input type="hidden" id="previewFrame" name="previewFrame" value="previewFrame"><input type="hidden" id="render_type_name" name="render_type_name" value="render_type"><input type="hidden" id="render_type" name="render_type" value="RESIZE_FRAME"><input type="hidden" id="previewWidthName" name="previewWidthName" value="preview_width"><input type="hidden" id="previewHeightName" name="previewHeightName" value="preview_height"></form><script src="https://portoseguro--Sniper.my.salesforce.com/email/wysiwyg/resize.js"></script></body></html>'; //PLV-5203 INICIO/FINAL FIX1
                }
                if(bodyToSend == null)
                    return;
                //PLV-5744 INICIO
                if (contratante.Contrato__r.ApolicePdfDownloadUrl__c == null || contratante.Contrato__r.NumeroApolice__c == null) {
                    bloqueiaEmail = true;
                } else {
                    bodyToSend = bodyToSend.replace('#novo#', contratante.Contrato__r.ApolicePdfDownloadUrl__c); 
                    bodyToSend = bodyToSend.replace('#apolice#', contratante.Contrato__r.NumeroApolice__c); 
                }
                //PLV-5744 FIM
                // if(!Test.isRunningTest()){FNPVVEP-43 - INICIO
                    //PLV-5744-FIX01 - INICIO
                    if (contratante.Contrato__r.Email__c == null) {
                        bloqueiaEmail = true;  
                    }
                    //II-138 FIX02 INICIO
                    //Demanda S.I PROD - INICIO
                    nomeSocial = String.isEmpty(contratante.Contrato__r.Account.NomeSocial__c) ? contratante.Contrato__r.Account.Name : contratante.Contrato__r.Account.NomeSocial__c; //LECVPV_190 FIX03 - INICIO/FIM
                    bodyToSend = bodyToSend.replace('{!if(Account.NomeSocial__c="", Account.Name, Account.NomeSocial__c)}', nomeSocial); //LECVPV_190 FIX03 - INICIO/FIM
                    bodyToSend = bodyToSend.replace('{!Contract.DistributionPublicUrl__c}', contratante.Contrato__r.DistributionPublicUrl__c);
                    bodyToSend = bodyToSend.replace('{!Contract.Senha__c}', contratante.Contrato__r.Senha__c);
                    //Demanda S.I PROD - FIM
                    //II-138 FIX02 FIM
                    //PLV-5744-FIX01 - INICIO
                    //PLV-5744 INICIO
                    if (contratante.Contrato__r.Account.PersonEmail == null) {
                        bloqueiaEmail = true;  
                    } else {
                        bodyToSend = bodyToSend.replace('#email#', contratante.Contrato__r.Account.PersonEmail); 
                    }
                    
                    bodyToSend = contratante.Contrato__r.Account.PersonMobilePhone !=null 
                        ? bodyToSend.replace('#cel#', contratante.Contrato__r.Account.PersonMobilePhone) 
                        : bodyToSend.replace('#cel#', '');
                    //PLV-5744 FIM
                // }FNPVVEP-43 - FIM
                subject = 'Porto Seguro - Boas Vindas';
            }
            System.debug('bodyToSend> ' + json.serialize(bodyToSend));
            //PLV-5744 INICIO
            nomeSocial = String.isEmpty(contratante.Contrato__r.Account.NomeSocial__c) ? contratante.Contrato__r.Account.Name : contratante.Contrato__r.Account.NomeSocial__c; //LECVPV_190 FIX03 - INICIO/FIM
            bodyToSend = contratante.Contrato__r.Account.Name != null
                ? bodyToSend.replace('#nomeConta#', nomeSocial) //LECVPV_190 FIX03 - INICIO/FIM
                : bodyToSend.replace('#nomeConta#', '');
            //PLV-5744 FIM
            String toInsert = '<br/><br/><b>Para a visualização e impressão dos boletos, clique nos links abaixo:</b><br/><p style="font-size:15px;">';
            Decimal nParcelas = 0;

            //II-138 INICIO
            List<public_boleto__x> contratanteBoletos = mapContratoBoletos.get(contratante.Contrato__r.Id);
            System.debug('Teste contratanteBoletos >>' + contratanteBoletos);
            
            //for(public_boleto__x boleto : listBoleto){
            for(public_boleto__x boleto : contratanteBoletos){
            //II-138 FIM
                if(boleto.idcontrato__c == contratante.Contrato__c){
                    //PLV-5744-FIX01 INICIO
                    if(boleto.urlboleto__c != null){  
                      //  bloqueiaEmail = true;
                      nparcelas++;
                      toinsert += '<a href="'+endpontSF.Endpoint+'/apex/VFGerarBoleto?token='+boleto.urlboleto__c+'"><strong>Parcela '+ boleto.numeroparcela__c +' - '+ getDate(String.valueOf(boleto.vencimento__c)) + '</strong></a><br/>'; //Demanda S.I PROD - INICIO/FIM
                      listUpdateBoleto.add(boleto);
                    }
                    //PLV-5744-FIX01 FIM
                }
            }

            if(bloqueiaEmail == false){ //PLV-5744 INCIO/FIM //II-138 INICIO/FIM
                bodyToSend =    bodyToSend.replace('#boletos#',toInsert);
                bodyToSend += '</p>';
               listEmails.add(gerarEmail(bodyToSend, new List<String> {contratante.Contrato__r.Email__c}, copiasEmail, subject)); //PLV-4910 - INÍCIO/FIM
               System.debug('listEmails <><> ' + listEmails); //II-138 FIX01 INICIO/FIM
                for(public_boleto__x boleto : listUpdateBoleto){
                    boleto.status__c = 'Enviado';
                    // PLV-4567-FIX INICIO
                    boleto.dataenvio__c = System.today();
                    // PLV-4567-FIX FIM
                }
            } 
        }
        
        try {
            //II-138 FIX01 INICIO
            if(listEmails != null && listEmails.size() > 0 && !Test.isRunningTest()){
                System.debug('listEmails <><> ' + JSON.serialize(listEmails));
                Messaging.SendEmailResult[] results = Messaging.sendEmail(listEmails,true);
                // for(Messaging.SendEmailResult result : results){
                //     if (result.success) {
                //         System.debug('The email was sent successfully.');
                //     } else {
                //         System.debug('The email failed to send: '
                //         + result.errors[0].message);
                //     }
                // }
                System.debug('results <><> ' + results);
                if (results[0].isSuccess()) {
                    System.debug('All emails were sent successfully.');
                } else {
                    System.debug('erro');
                    System.debug('Some emails failed to send: ' + results[0].getErrors()[0].getMessage());
                }
            //II-138 FIX01 FIM
            }
            if(!Test.isRunningTest())
                Database.updateAsync(listUpdateBoleto);
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            throw new AuraHandledException('e.getMessage(): ' + e.getMessage());
            
        }
        
        // Util.enviarEmail(bodyToSend, new List<String> {Contrato__r.email__c}, 'Porto Seguro - Boas Vindas');
    }
    
    global void finish(Database.BatchableContext BC){
       
    }

    global void execute(SchedulableContext sc) {
        BatchEnvioBoleto b = new BatchEnvioBoleto(); 
        database.executebatch(b);
    }

    // PLV-4567-FIX INICIO
    global static void agendarBatch(){
        String name = 'BatchEnvioBoleto';
        if(Test.isRunningTest())
        name = 'BatchTest';

        System.schedule(name + ' Agendado Hora em Hora', '0 0 * * * ?', new BatchEnvioBoleto()); //II-138 INICIO-FIM

    }
    // PLV-4567-FIX FIM
    public string getDate(String param){
        if (param != null && param.split(' ').size() > 0) {
            List<String> data = param.split(' ')[0].split('-');
            String dataString = data[2]+'/'+data[1]+'/'+data[0];
            return dataString;
        }else{
            return null;
        }
    }
    //PLV-4910 - INÍCIO
    private Messaging.SingleEmailMessage gerarEmail(String pBodyToSend, List<String> pRecipients, List<CopiaEmail__mdt> copiasEmail, String pSubject){
        String [] emails = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        if(copiasEmail.size() > 0){
            for(CopiaEmail__mdt copia : copiasEmail){
                emails.add(copia.Email__c);
            }
            email.setBccAddresses(emails);  //Cópia oculta
        }
        //PLV-4910 - FIM
        email.setHtmlBody(pBodyToSend);
        email.setToAddresses(pRecipients);
        email.setSubject(pSubject);
        email.setCharset('UTF-8');
        return email;
    }
}