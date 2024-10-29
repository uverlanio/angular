//PLV-4034 Inicio
public class ControleIntegracao  {
	@Future(callout = true)
	public static void createRecordControleIntegracao(List<Id> pagamentosSet){
		System.debug('ControleIntegracao.createRecordControleIntegracao------------>');

		Id recordId = pagamentosSet[0];
		system.debug('recordId: '+recordId);

	   //PLV-4034-Fix2 Inicio
       List<Pagamento_de_sinistro__c> lstPagSinistro = [select Id, OP_SAP__c, Beneficiario_da_Garantia__c, Dados_Bancarios__c, Caso_de_Sinistro__r.Sinistro_Judicial__c, Numero_do_sinistro_formula__c, Valor_Pago__c, Beneficiario_da_Garantia__r.Cpf__c, Beneficiario_da_Garantia__r.Cnpj__c, Conta_formula__c, Data_Programada_de_Pagamento__c, Valor_total_a_ser_indenizado__c from Pagamento_de_sinistro__c where id =: recordId ];
	   //PLV-4034-Fix2 Fim
	   /*List<BeneficiarioGarantia__c> LstBene = [SELECT Id, Name, Informacao_bancaria__c, Data_programada_do_pagamento__c,Pagamento_de_garantia__c, Conta__c, Status__c,Tipo_de_Pagamento__c, conta__r.Cnpj__c, conta__r.Cpf__c, Pagamento_de_garantia__r.ValorIndenizado__c, Percentual_de_indenizacao__c, Pagamento_de_garantia__r.Caso__r.NumeroSinistro__c, Pagamento_de_garantia__r.Caso__c, Pagamento_de_garantia__r.Caso__r.Sinistro_Judicial__c, ValorIndenizacao__c
       		                                    FROM BeneficiarioGarantia__c
                                                WHERE Pagamento_de_sinistro__c =: recordId
                                                //AND Status__c = 'Liberado'
                                                //AND Tipo_de_Pagamento__c != null
                                                //AND Data_programada_do_pagamento__c != null
                                                ];*/      
        system.debug('lstPagSinistro gfs'+ lstPagSinistro);

        Http h = new Http(); 
        
        List<Object> LstObject2Heroku = new List<Object>();
        List<Pagamento_de_sinistro__c> lstLessDate = new List<Pagamento_de_sinistro__c>();
        String Retorno;
        String bodyDel;

        //Id idCurrentUser = UserInfo.getUserId();
        Id idCurrentPorifle = UserInfo.getProfileId();
        //User u = [SELECT ProfileId FROM User WHERE Id = :idCurrentUser];
        Profile p = [SELECT Name FROM Profile WHERE Id =: idCurrentPorifle];
        
        for(Pagamento_de_sinistro__c bene : lstPagSinistro){
            system.debug('bene gfs'+ bene);

            Date d = Date.Today();
            if(bene.Data_Programada_de_Pagamento__c == null && bene.Caso_de_Sinistro__r.Sinistro_Judicial__c == false && p.Name != 'Coordenador'){
                bene.Data_Programada_de_Pagamento__c = d.AddDays(2);      
            }else if(((bene.Data_Programada_de_Pagamento__c < d.AddDays(2) && (bene.Caso_de_Sinistro__r.Sinistro_Judicial__c == false && p.Name != 'Coordenador')) || (bene.Data_Programada_de_Pagamento__c < d && (bene.Caso_de_Sinistro__r.Sinistro_Judicial__c == true || p.Name == 'Coordenador')))){
                lstLessDate.add(bene);
            }else if(bene.Data_Programada_de_Pagamento__c == null){
                bene.Data_Programada_de_Pagamento__c = d.AddDays(2); 
            }
            
            ServiceTO.ParamPagamentoBeneficiarioTO parambene = new ServiceTO.ParamPagamentoBeneficiarioTO();
            parambene.id = bene.Id; 
            parambene.idobjeto = bene.Id;
            parambene.dataprogramadapagamento = bene.Data_Programada_de_Pagamento__c; 
            
			system.debug('parambene.dataprogramadapagamento');
            system.debug(parambene.dataprogramadapagamento);
            
            //converte percentual para calculo                                    
            //Double decvalor = bene.Percentual_de_indenizacao__c/100;             
            
            parambene.valorpagamento = bene.Valor_total_a_ser_indenizado__c;
            
			//PLV-4034-Fix2 Inicio
           	parambene.idconta = bene.Beneficiario_da_Garantia__c;
            //PLV-4034-Fix2 Fim
			if(bene.Beneficiario_da_Garantia__r.Cnpj__c != null)  parambene.cnpjcpf = bene.Beneficiario_da_Garantia__r.Cnpj__c;
            if(bene.Beneficiario_da_Garantia__r.Cpf__c !=  null && bene.Beneficiario_da_Garantia__r.Cnpj__c == null) parambene.cnpjcpf = bene.Beneficiario_da_Garantia__r.Cpf__c;
            parambene.tipoconta = 'Beneficiário';
            parambene.status = 'PENDENTE';
            parambene.datapagamento = null;
            parambene.tipopagamento = 'SINISTRO';
            parambene.matricula = Userinfo.getUserId();  
            parambene.codigoexcecao = null;
            parambene.descricaoexcecao = null;
            
 			system.debug('aqui');          
            //converte o percentual
            //Decimal decbruto = bene.Percentual_de_indenizacao__c/100;
            //system.debug('decbruto' + decbruto);
            
           // Decimal valorind = bene.Pagamento_de_garantia__r.ValorIndenizado__c != null ? (bene.Pagamento_de_garantia__r.ValorIndenizado__c * decbruto).setScale(2) : null;
            //PLV-4034-Fix2 Inicio
			parambene.valorbruto = bene.Valor_total_a_ser_indenizado__c;
			//PLV-4034-Fix2 Inicio
            system.debug('valorbruto' + parambene.valorbruto); 
            
            
            parambene.tributacao = 'false';
            parambene.tiporemuneracao = null;
            parambene.datacancelamento = null;
            parambene.motivo = '';
            //PLV-4034-Fix2 Inicio
			parambene.descricao = 'Pagamento Sinistro = '+ bene.Numero_do_sinistro_formula__c;
            //PLV-4034-Fix2 Fim
			parambene.susepcorretor = null;
            parambene.dataatualizacao = system.today(); 
            
            LstObject2Heroku.add(parambene);
        }

        //String lessDate = JSON.serialize(lstLessDate);

        //if(lstLessDate.size() > 0 ) return lessDate;
       
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
			system.debug('Status Integração = '+ '200');
			system.debug('req = ' + req);
			system.debug('Retorno = ' + Retorno);

            system.debug('lstPagSinistro '+lstPagSinistro);
			
			List<BeneficiarioGarantia__c> listBen = [select Id, Is_Integracao__c, Pagamento_de_Sinistro__r.Dados_Bancarios__c, Pagamento_de_Sinistro__c, Data_programada_do_pagamento__c from BeneficiarioGarantia__c where Pagamento_de_Sinistro__c in :(lstPagSinistro)];

            For(BeneficiarioGarantia__c o : listBen)
            {
               BeneficiarioGarantia__c ben = new BeneficiarioGarantia__c();
               ben.Id = o.Id;
			   ben.Pagamento_de_Sinistro__c = o.Pagamento_de_Sinistro__c;
               ben.Data_programada_do_pagamento__c = o.Data_programada_do_pagamento__c;
               ben.Status__c = 'Aguardando Pagamento';
			   ben.Informacao_bancaria__c = o.Pagamento_de_Sinistro__r.Dados_Bancarios__c;
			   ben.Is_Integracao__c = true;
               LstBene2update.add(ben);
            }
            
            system.debug('LstBene2update '+LstBene2update);
            if(!LstBene2update.isEmpty())database.update(LstBene2update); 
            
        //Upsert na LogIntegração com id=75, data=today , idObjeto=idSinistro e status = 'Pendente'.
            
            Set<String> idsObjeto = new Set<String>();

            for(Pagamento_de_sinistro__c bene2 : lstPagSinistro){
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
            for(Pagamento_de_sinistro__c b : lstPagSinistro){
                String idObjeto = b.Id;

                if(sControle.contains(idObjeto)) continue;
                
                ControleIntegracao__c controleIntegracao = new ControleIntegracao__c();
                controleIntegracao.CodigoIntegracao__c = '75';
                controleIntegracao.Status__c = 'Pendente';
                controleIntegracao.DataCriacaoRegistro__c = system.today();
                controleIntegracao.IdObjeto__c = idObjeto;
                controleIntegracao.Pagamento_Sinistro__c = idObjeto; //LECVP-212 - INICIO
                Pagamento_de_Sinistro__c ps = PagamentoSinistroDAO.getInstance().buscar(new Set<Id>{b.Id});
                controleIntegracao.Objeto__c = ps.Name; //LECVP-212 - FIM
                lControle2Update.add(controleIntegracao);
                    
            }
			System.debug('Criou controle integração = ' + lControle2Update);
            insert lControle2Update;
			//PLV-4034-Fix3 Inicio
			if(!Test.isRunningTest()){
                SolicitarPagamentoCasoFilhoControllerTO.RetornoTO ret = (SolicitarPagamentoCasoFilhoControllerTO.RetornoTO)JSON.deserialize(Retorno, SolicitarPagamentoCasoFilhoControllerTO.RetornoTO.class);
				Pagamento_de_sinistro__c pagSin = lstPagSinistro[0];
				pagSin.OP_SAP__c = ret.Id;
				System.debug('Atualizar pagSin = ' + pagSin);
                
				update pagSin;
			}
			//PLV-4034-Fix3 Fim	
 
            //return 'OK';
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
            //return 'ERRO';
        }
	
	}

	public static void updateStatusPagamentoDeSinistro(List<Pagamento_de_Sinistro__c> lPagamentos){
		
				Pagamento_de_Sinistro__c Pagamento = lPagamentos[0];
				List<BeneficiarioGarantia__c> listBen = [select Id, Status__c from BeneficiarioGarantia__c where Pagamento_de_Sinistro__c in :(lPagamentos)];

				for(BeneficiarioGarantia__c beneficiario : listBen){
                    beneficiario.Status__c = Pagamento.Status__c;
                    beneficiario.Permitir_Alteracao__c = true;    // LECVPV-200 INICIO/FIM                
                }

				update listBen;
	}
}
//PLV-4034 Fim