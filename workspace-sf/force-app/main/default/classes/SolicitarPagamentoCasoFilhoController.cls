/*********************************************************************************
 * Comentado por conta da história PLV-1887
 * Diego ZTL
**********************************************************************************
*/

public with sharing class SolicitarPagamentoCasoFilhoController {
    
    @AuraEnabled
    public static String verificafase(String recordId) 
    {
	    //* Origem do acionamento será na fase Status = "Liquidação" e 
        //status diferente de Status_Dependente__c ="Recusado" e "Pago".      
        
        List<PagamentoGarantia__c> lPagGarantia = [Select Id, Status_do_pagamento__c, Fase__c, Caso__c, Soma_Percentual__c 
                           FROM PagamentoGarantia__c Where Caso__c =: recordId 
                           And Fase__c = 'Em Análise' 
                           And Status_do_pagamento__c != 'Recusado'
                           And Status_do_pagamento__c != 'Pago'
                           limit 1]; 
        
        if(lPagGarantia.size() == 0)return 'Somente é possível solicitar pagamento na fase "Em Análise" e status diferente de Recusado ou Pago.';

        if(lPagGarantia[0].Soma_Percentual__c > 100) return 'Favor verificar os percentuais de indenização dos beneficiários do caso, pois somados não podem ultrapassar 100%.';
        
		//* Verificar se existe alguma atividade do tipo "Pendência" 
		//com status diferente de "Resolvida". 
		//Caso exista, informar a mensagem ao usuário 
		//"Não é possível realizar o pagamento pois há pendências em aberto."
		List<Task> LstTsk = [SELECT Id 
                    FROM Task 
                    WHERE WhatId IN:lPagGarantia
                   	AND Status != 'Finalizada' 
                   	AND TipoComunicado__c = 'Pendência'];
        
       	if(LstTsk.size() > 0)return 'Não é possível realizar o pagamento pois há pendências em aberto.';      
        
        //Verificar se o Caso de atendimento daquele pagamento está diferente da fase "Em Regulação"
        //Caso estiver, exibir mensagem de erro e nao permitir a criação

        List<Case> vCase = [Select Id, Status From Case Where Id =: recordId AND Status = 'Em Regulação'];

        if(vCase.size() == 0 && !Test.isRunningTest()) return 'O Caso precisa estar em fase de Regulação para criação de pagamentos.';
     
    //Regra 1 = exista um beneficiario, se não "Beneficiário não informado"
    //Regra 2 = se o status de cada beneficiario for liberado, 
    //e existir um tipo de pagamento realizar o pagamento (heroku).
    //Regra 2.1  caso não exista tipo de pagamento msg = "Tipo de Pagamento não informado"
    
	List<BeneficiarioGarantia__c> LstBene = [SELECT Pagamento_de_garantia__c,Status__c,Tipo_de_Pagamento__c 
                                             FROM BeneficiarioGarantia__c
                                             WHERE Pagamento_de_garantia__c IN: lPagGarantia
                                             ];
    
	List<Object> Lst2Pay = new List<Object>();
    List<Object> Lstnot2Pay = new List<Object>();
    List<Object> LstNaoLiberados = new List<Object>();
    if(LstBene.size()==0){return 'Não foi encontrado beneficiário no pagamento selecionado.';
    }else{
        for(BeneficiarioGarantia__c b : LstBene)
        {
            if((b.Status__c == 'Liberado') && (b.Tipo_de_Pagamento__c != null))
            {
                Lst2Pay.add(b);
            }
            if((b.Status__c == 'Liberado') && (b.Tipo_de_Pagamento__c == null)){Lstnot2Pay.add(b);
            }
            if(b.Status__c != 'Liberado')
            {
                LstNaoLiberados.add(b);
            }
        }

		//se tiver um pagável liberar solicitação de pagamento
        if(Lst2Pay.size() > 0)
        {
            //paga no heroku //valor de indenização x Percentual_de_indenizacao__c 
            return 'Ok';
        }
        
        //se n tiver um pagável "Tipo de Pagamento não informado"
        if((Lstnot2Pay.size() > 0)&& (Lst2Pay.size() == 0)){return 'Tipo de Pagamento não informado.';
        }

        if(LstBene.size() == LstNaoLiberados.size())
        {
            return 'Não existem beneficiários liberados para pagamento.';
        }
    }
     
    return null;
    }

	@AuraEnabled
    public static List<PagamentoGarantia__c> consultainfo(String recordId) 
    {     
        //PLV-2336 - Inicio - Incluído o campo PercentualLiberados__c no Select para atender regra de negócio e alterado o nome da variável
        
         List<PagamentoGarantia__c> lstPag = [Select ValorIndenizado__c,ComplementoIndenizacao__c, Capital__c, PercentualLiberados__c
                               FROM PagamentoGarantia__c WHERE caso__c =: recordId
                               limit 1]; 
        return lstPag;
        //PLV-2336 - Fim
    }

    @AuraEnabled
    public static void salvadataBenef(String recordId, String cidBenef){
        String[] aidBenef = cidBenef.split(' ');

        List<BeneficiarioGarantia__c> LstBene = [SELECT Id, Data_programada_do_pagamento__c
                                                FROM BeneficiarioGarantia__c
                                                WHERE Pagamento_de_garantia__c =: recordId
                                                AND Id =: aidBenef];

        List<BeneficiarioGarantia__c> updateLstBene = new List<BeneficiarioGarantia__c>();

        Date d = Date.Today().AddDays(2);
        for(BeneficiarioGarantia__c cBenef : LstBene){        
            cBenef.Data_programada_do_pagamento__c = d;
            updateLstBene.add(cBenef);
        }

        update updateLstBene;
    }
       
   	@AuraEnabled
    public static String gravapagamento(String recordId, Decimal valorpagamento)
    {  

      //PLV 2448 - Ajuste no valor pagamento no heroku - Fix1 - Ínicio            
       
      // Double novopagamento = valorpagamento;
        
       system.debug('recordId: '+recordId);
       List<BeneficiarioGarantia__c> LstBene = [SELECT Id, Name, Data_programada_do_pagamento__c,Pagamento_de_garantia__c, Conta__c, Status__c,Tipo_de_Pagamento__c, conta__r.Cnpj__c, conta__r.Cpf__c, Pagamento_de_garantia__r.ValorIndenizado__c, Percentual_de_indenizacao__c, Pagamento_de_garantia__r.Caso__r.NumeroSinistro__c, Pagamento_de_garantia__r.Caso__c, Pagamento_de_garantia__r.Caso__r.Sinistro_Judicial__c, ValorIndenizacao__c
       		                                    FROM BeneficiarioGarantia__c
                                                WHERE Pagamento_de_garantia__c =: recordId
                                                AND Status__c = 'Liberado'
                                                AND Tipo_de_Pagamento__c != null
                                                //AND Data_programada_do_pagamento__c != null
                                                ];
       //PLV 2448 - Ajuste no valor pagamento no heroku - Fix1 - FIm        
         system.debug('LstBene gfs'+ LstBene);
        
        // Instantiate a new http object
        Http h = new Http(); 
        
        List<Object> LstObject2Heroku = new List<Object>();
        List<BeneficiarioGarantia__c> lstLessDate = new List<BeneficiarioGarantia__c>();
        String Retorno;
        String bodyDel;

        //Id idCurrentUser = UserInfo.getUserId();
        Id idCurrentPorifle = UserInfo.getProfileId();
        //User u = [SELECT ProfileId FROM User WHERE Id = :idCurrentUser];
        Profile p = [SELECT Name FROM Profile WHERE Id =: idCurrentPorifle];
        
        for(BeneficiarioGarantia__c bene : LstBene){
            system.debug('bene gfs'+ bene);

            Date d = Date.Today();
            if(bene.Data_programada_do_pagamento__c == null && bene.Pagamento_de_garantia__r.Caso__r.Sinistro_Judicial__c == false && p.Name != 'Coordenador'){
                bene.Data_programada_do_pagamento__c = d.AddDays(2);      
            }else if(((bene.Data_programada_do_pagamento__c < d.AddDays(2) && (bene.Pagamento_de_garantia__r.Caso__r.Sinistro_Judicial__c == false && p.Name != 'Coordenador')) || (bene.Data_programada_do_pagamento__c < d && (bene.Pagamento_de_garantia__r.Caso__r.Sinistro_Judicial__c == true || p.Name == 'Coordenador')))){
                lstLessDate.add(bene);
            }else if(bene.Data_programada_do_pagamento__c == null){
                bene.Data_programada_do_pagamento__c = d.AddDays(2); 
            }
            
            ServiceTO.ParamPagamentoBeneficiarioTO parambene = new ServiceTO.ParamPagamentoBeneficiarioTO();
            parambene.id = bene.Id; 
            parambene.idobjeto = bene.Id;
            parambene.dataprogramadapagamento = bene.Data_programada_do_pagamento__c;
            
			system.debug('parambene.dataprogramadapagamento');
            system.debug(parambene.dataprogramadapagamento);
            
            //converte percentual para calculo
            //
            
            
            Double decvalor = bene.Percentual_de_indenizacao__c/100;
            
            
			//PLV 2448 - Ajuste no valor pagamento no heroku - Fix1 - Ínicio            
            //parambene.valorpagamento = decvalor != null ? (novopagamento * decvalor) : 0; 
            
            parambene.valorpagamento = bene.ValorIndenizacao__c;
			//PLV 2448 - Ajuste no valor pagamento no heroku - Fix1 - Fim 
            
           	parambene.idconta = bene.Conta__c;
            if(bene.conta__r.Cnpj__c != null)  parambene.cnpjcpf = bene.conta__r.Cnpj__c;
            if(bene.conta__r.Cpf__c !=  null && bene.conta__r.Cnpj__c == null) parambene.cnpjcpf = bene.conta__r.Cpf__c;
            parambene.tipoconta = 'Beneficiário';
            parambene.status = 'PENDENTE';
            parambene.datapagamento = null;
            parambene.tipopagamento = 'SINISTRO';
            parambene.matricula = Userinfo.getUserId();  
            parambene.codigoexcecao = null;
            parambene.descricaoexcecao = null;
            
 			system.debug('aqui');          
            //converte o percentual
            Decimal decbruto = bene.Percentual_de_indenizacao__c/100;
            system.debug('decbruto' + decbruto);
            
            Decimal valorind = bene.Pagamento_de_garantia__r.ValorIndenizado__c != null ? (bene.Pagamento_de_garantia__r.ValorIndenizado__c * decbruto).setScale(2) : null;
            parambene.valorbruto = valorind;
            system.debug('valorbruto' + parambene.valorbruto); 
            
            
            parambene.tributacao = 'false';
            parambene.tiporemuneracao = null;
            parambene.datacancelamento = null;
            parambene.motivo = '';
            parambene.descricao = 'Pagamento Sinistro '+ bene.Pagamento_de_garantia__r.Caso__r.NumeroSinistro__c;
            parambene.susepcorretor = null;
            parambene.dataatualizacao = system.today(); 
            
            LstObject2Heroku.add(parambene);
        }

        String lessDate = JSON.serialize(lstLessDate);

        if(lstLessDate.size() > 0 ) return lessDate;
       
        system.debug('LstObject2Heroku' + LstObject2Heroku);
        
        String body = JSON.serialize(LstObject2Heroku);

        CredencialOAuth2__mdt  credencial = MetadataDAO.getInstance().buscarCredencial('VidaCloudApi');
        Servico__mdt servico = MetadataDAO.getInstance().buscarServico('Salvar_Pagamento');
        String Token = HerokuService.getInstance().gerarTokenOAuth2('VidaCloudApi');
        
        //configurar endpoint e serviço no heroku
        
        system.debug('credencial: '+credencial);
        system.debug('servico: '+servico);
        system.debug('Token: '+Token);
        
        
        HttpResponse res;
        HttpRequest req = new HttpRequest();
        req.setBody(body);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', Token);
        req.setEndpoint(credencial.Audience__c + '/api/' + servico.Endpoint__c); 
        req.setMethod('POST');

        system.debug(credencial.Audience__c);
        res = h.send(req); 
                                  
        Retorno = res.getBody().replace('[','').replace(']','');
        
        List<PagamentoGarantia__c> LstCaso = new List<PagamentoGarantia__c>();
        List<BeneficiarioGarantia__c> LstBene2update = new List<BeneficiarioGarantia__c>();
        system.debug(req);
        system.debug(res.getBody());
        
        if (res.getStatusCode() == 200)
        { 
            system.debug('LstBene '+LstBene);

            For(BeneficiarioGarantia__c o : LstBene)
            {
               BeneficiarioGarantia__c ben = new BeneficiarioGarantia__c();
               ben.Id = o.Id;
               ben.Data_programada_do_pagamento__c = o.Data_programada_do_pagamento__c;
               ben.Status__c = 'Aguardando Pagamento';
               LstBene2update.add(ben);
            }
            
            system.debug('LstBene2update '+LstBene2update);
            if(!LstBene2update.isEmpty())database.update(LstBene2update); 
            
        //Upsert na LogIntegração com id=75, data=today , idObjeto=idSinistro e status = 'Pendente'.
            
            Set<String> idsObjeto = new Set<String>();

            for(BeneficiarioGarantia__c bene2 : LstBene){
                idsObjeto.add(bene2.id);
            }

            Set<String> sControle = new Set<String>();

            for(ControleIntegracao__c controle : 
                        [SELECT id, IdObjeto__c 
                         FROM ControleIntegracao__c 
                         WHERE CodigoIntegracao__c = '75'
                         AND Status__c = 'Pendente'
                         AND DataCriacaoRegistro__c =: system.today()
                         AND IdObjeto__c IN: idsObjeto]){ sControle.add(controle.IdObjeto__c);
            }

            List<ControleIntegracao__c> lControle2Update = new List<ControleIntegracao__c>();
            for(BeneficiarioGarantia__c b : LstBene){
                String idObjeto = b.Id;

                if(sControle.contains(idObjeto)) continue;
                
                ControleIntegracao__c controleIntegracao = new ControleIntegracao__c();
                controleIntegracao.CodigoIntegracao__c = '75';
                controleIntegracao.Status__c = 'Pendente';
                controleIntegracao.DataCriacaoRegistro__c = system.today();
                controleIntegracao.IdObjeto__c = idObjeto;
                lControle2Update.add(controleIntegracao);
                    
            }

            insert lControle2Update;
 
            return 'OK';
		}else
        {
            
			system.debug('ENTROUUU' + Retorno);
             
           
                CredencialOAuth2__mdt  credencialDel = MetadataDAO.getInstance().buscarCredencial('VidaCloudApi');
                Servico__mdt servicoDel = MetadataDAO.getInstance().buscarServico('Deleta_Pagamento');
                String TokenDel = HerokuService.getInstance().gerarTokenOAuth2('VidaCloudApi');
                
                //configurar endpoint e serviço no heroku para delete

                HttpResponse resDel;
                HttpRequest reqDel = new HttpRequest();
                reqDel.setHeader('Content-Type', 'application/json');
                reqDel.setHeader('Authorization', TokenDel);
                reqDel.setEndpoint(credencialDel.Audience__c + '/api/' + servicoDel.Endpoint__c); 
                reqDel.setMethod('POST');
            	if(!Test.isRunningTest()){
                SolicitarPagamentoCasoFilhoControllerTO.RetornoTO ret = (SolicitarPagamentoCasoFilhoControllerTO.RetornoTO)JSON.deserialize(Retorno, SolicitarPagamentoCasoFilhoControllerTO.RetornoTO.class);
            	bodyDel = ret.Id;
                reqDel.setBody(bodyDel);                
                resDel = h.send(reqDel);
                system.debug(resDel.getBody());
                }else
                {
                    SolicitarPagCasoFilhoControllerMock mock = new SolicitarPagCasoFilhoControllerMock();
                    resDel = mock.respond2(reqDel);
         
                }
            return 'ERRO';
        }
    }
    
    
    @AuraEnabled
    public static String atualizaregistro(String recordId, Decimal valorpagamento) 
    {           
        
        List<PagamentoGarantia__c> LstCase = [Select Id From PagamentoGarantia__c where Id =: recordId limit 1];
        //LstCase[0].Complemento_de_Indenizacao__c = valorpagamento;
        //LstCase[0].Data_programada_do_pagamento__c = dataprogramada;
        
        if(!LstCase.isEmpty()) database.update(LstCase); 


        return 'Concluído'; 
    }

}