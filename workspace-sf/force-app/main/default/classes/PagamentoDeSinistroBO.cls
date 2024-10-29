// história: PLV-4065
// descrição da história: aviso de liquidação de sinistros
// Data de Criação: 31/07/2020
// Desenvolvedor: Tiago Welter - Sys4b
public virtual class PagamentoDeSinistroBO {
    
    public PagamentoDeSinistroBO() { } 
    private static final PagamentoDeSinistroBO instancia = new PagamentoDeSinistroBO();
    private static final String alcadaSF    = 'Alçada Salesforce';  //PLV-4825 - Inicio/Fim
    private static final String alcadaSAP   = 'Alçada SAP';         //PLV-4825 - Inicio/Fim

    private PagamentoDeSinistroBO dao = PagamentoDeSinistroBO.getInstance();
    private CasoDAO daoCases = CasoDAO.getInstance();
    private static CIVServices civServ = CIVServices.getInstance();
    public static PagamentoDeSinistroBO getInstance(){
        return instancia;
    }

    
    //PLV-4065 inicio
    public void enviaAvisoLiberacaoPagamento(List<Pagamento_de_Sinistro__c> pagamentos) {

        Map<Id, Case> mCaso = new Map<Id, Case>(); 
        Set<Id> sContrato = new Set<Id>();
        Set<Id> sCaso = new Set<Id>();
        Set<Id> sAccount = new Set<Id>();
        Map<Id, List<Pagamento_de_Sinistro__c>> pagamentoMap = new Map<Id, List<Pagamento_de_Sinistro__c>>();
        // PLV-5316 - INICIO
        EmailTemplate templateCPagCondiCli   = [Select id,body,Subject from EmailTemplate where name = 'Pagamento Condicionado Cliente'];
        EmailTemplate templateCPagCondiCor   = [Select id,body,Subject from EmailTemplate where name = 'Pagamento Condicionado Corretor'];
        EmailTemplate templatePagCli   	 	 = [Select name, id, body, Subject FROM EmailTemplate WHERE name = 'Aviso Pagamento Beneficiário - Cliente'];
        EmailTemplate templatePagCor   	 	 = [Select id,body,Subject from EmailTemplate where name = 'Aviso PG Corretor'];
        EmailTemplate templatePagBen   	 	 = [SELECT name, id, body, Subject FROM EmailTemplate WHERE name = 'Aviso Pagamento Beneficiário - Cliente'];
        List<Pagamento_de_Sinistro__c> LstPagSinWithRelated =  new List<Pagamento_de_Sinistro__c>([SELECT Id, Caso_de_Sinistro__c, Beneficiario_da_Garantia__r.PersonEmail, Beneficiario_da_Garantia__r.Email__c FROM Pagamento_de_Sinistro__c WHERE Id IN :pagamentos]);
        // PLV-5316 - FIM
        
        //FIX 1
        OrgWideEmailAddress[] owea  = [select Id from OrgWideEmailAddress where Address = 'sinistro.vida@portoseguro.com.br'];
        List<User>    lstUserIdOrg  = [SELECT Id FROM User WHERE Email = 'adminsalesforce.vida@portoseguro.com.br']; // PLV-5316 - INÍCIO/FIM
        
        
        //VIAG-226-INICIO
        Set<Id> casoIds = new Set<Id>();
        for (Pagamento_de_Sinistro__c pagamento : pagamentos) {
            casoIds.add(pagamento.Caso_de_Sinistro__c);
        }
        
        Map<Id, Case> casosMap = new Map<Id, Case>([SELECT Id, Origin FROM Case WHERE Id IN :casoIds]);
        
        // Passo 3: Filtrar a lista de Pagamento_de_Sinistro__c
        List<Pagamento_de_Sinistro__c> pagamentosFiltrados = new List<Pagamento_de_Sinistro__c>();
        for (Pagamento_de_Sinistro__c pagamento : pagamentos) {
            Case caso = casosMap.get(pagamento.Caso_de_Sinistro__c);
            if (caso != null && caso.Origin != 'Prestadora') {
                pagamentosFiltrados.add(pagamento);
            }
        }
		//VIAG-226-FIM

        for(Pagamento_de_Sinistro__c c : pagamentosFiltrados){ //VIAG-226-INICIO/FIM
            //FIX 2 - ajuste de status para disparo de email
            if(c.Status__c == 'Aprovada' && c.Caso_de_Sinistro__c != null){ //PLV-4772-INICIO/FIM
                sCaso.add(c.Caso_de_Sinistro__c);

                pagamentoMap.put(c.Caso_de_Sinistro__c, new List<Pagamento_de_Sinistro__c>());
                pagamentoMap.get(c.Caso_de_Sinistro__c).add(c);

            }
        } 
        
        //FIX 1
        if(!sCaso.isEmpty() && owea.size() > 0){

            for(Case c : [Select Id,Contrato__c,AccountId,IdPrestadora__c,Account.PersonEmail,Lista_de_pendencias__c From Case Where id In :sCaso] ){
                mCaso.put(c.Id, c);
                sContrato.add(c.Contrato__c);
                sAccount.add(c.AccountId);
            }
            
            List<Messaging.SingleEmailMessage> allMessageList = new List<Messaging.SingleEmailMessage>();
            Map<Id, FavorecidoRemuneracaoContrato__c> mFavRemunCont = daoCases.buscarCorretores(sContrato);
            String emailCorretor;
            Id contactId;
            // PLV-5316 - INÍCIO
            Id beneficiarioId;
            // PLV-5316 - FIM
            Id templateCorretor;
            Id templateCliente;
            Id pagamentoId;
            Id parceiroId;
            
            Map<Id, List<Contact>> contactMap = new Map<Id, List<Contact>>();
            for(Contact a : [Select Id, AccountId From Contact Where AccountId in :sAccount])
            {
                contactMap.put(a.AccountId, new List<Contact>());
                contactMap.get(a.AccountId).add(a);
            }

            Map<Id, List<Parceiro__c>> parceiroMap = new Map<Id, List<Parceiro__c>>();
            for(Parceiro__c a : [Select Id, Conta__c From Parceiro__c Where Conta__c in :sAccount])
            {
                parceiroMap.put(a.Conta__c, new List<Parceiro__c>());
                parceiroMap.get(a.Conta__c).add(a);
            }
            
            for(Case caso: mCaso.values()) {

                contactId = null;
                // PLV-5316 - INÍCIO
                beneficiarioId  = null;
                // PLV-5316 - FIM
                templateCorretor = null;
                pagamentoId = null; 
                parceiroId = null; 
                //FIX 2
                if (parceiroMap.containsKey(caso.AccountId))
                {
                    for (Parceiro__c c : parceiroMap.get(caso.AccountId))
                    {
                        if(caso.AccountId == c.Conta__c)
                        {
                            parceiroId = c.Id;
                        }
                    }
                }
                
                if (contactMap.containsKey(caso.AccountId))
                {
                    for (Contact c : contactMap.get(caso.AccountId))
                    {
                        if(caso.AccountId == c.AccountId)
                        {
                            contactId = c.Id;
                        }
                    }
                }
                
                if(contactId == null) continue;
                           
                // PLV-5316 - INÍCIO
                List<Pagamento_de_Sinistro__c> lstPG =  new List<Pagamento_de_Sinistro__c>();
                String PersonEmailBen = '';
                String EmailBen = '';
                // PLV-5316 - FIM
                
                if (pagamentoMap.containsKey(caso.Id))
                {
                    for (Pagamento_de_Sinistro__c c : pagamentoMap.get(caso.Id))
                    {
                        if(caso.Id == c.Caso_de_Sinistro__c)
                        {
                            pagamentoId = c.Id;
                            
                            // PLV-5316 - INÍCIO
                            for(Pagamento_de_Sinistro__c c2 : LstPagSinWithRelated){
                                
                                if(caso.Id == c2.Caso_de_Sinistro__c){
                                    lstPG.add(c2);
                                }
                            }
                            // PLV-5316 - FIM
                        }
                    }
                }

                // PLV-5316 - INÍCIO
                PersonEmailBen = lstPG[0].Beneficiario_da_Garantia__r.PersonEmail;
                EmailBen = lstPG[0].Beneficiario_da_Garantia__r.Email__c;
                beneficiarioId = lstPG[0].Beneficiario_da_Garantia__r.Id;
                System.debug('Logando Emails: '+lstPG);
                // PLV-5316 - FIM

                if(pagamentoId == null) continue;
                
                FavorecidoRemuneracaoContrato__c vFavRemCont = mFavRemunCont.get(caso.Contrato__c);
                if(vFavRemCont == null) continue;
                
                List<string> toadd = new List<string>();
                List<string> toaddBen = new List<string>(); // PLV-5316 - INICIO/FIM

                // PLV-5316 - INÍCIO
                if(vFavRemCont.DadosCorretor__r.NomeCorretor__r.Email__c == null){
                    toadd.add(vFavRemCont.DadosCorretor__r.NomeCorretor__r.PersonEmail);
                }else{
                    toadd.add(vFavRemCont.DadosCorretor__r.NomeCorretor__r.Email__c);
                }
                // toadd.add(emailCorretor);
                // PLV-5316 - FIM
               
                //FIX 2
                if(caso.Lista_de_pendencias__c != null){
                    templateCorretor = templateCPagCondiCor.Id;
                    templateCliente = templateCPagCondiCli.Id;
                }else{
                    templateCorretor = templatePagCor.Id;
                    templateCliente = templatePagCli.Id;
                }
                if(templateCorretor == null) continue;

                // PLV-5316 - INÍCIO
                if(PersonEmailBen == null || PersonEmailBen == ''){
                    toaddBen.add(EmailBen);
                }else{
                    toaddBen.add(PersonEmailBen);
                }

                if(!toaddBen.isEmpty()){
                    Messaging.SingleEmailMessage mailBen = new Messaging.SingleEmailMessage();   
                    system.debug('toaddBen: '+toaddBen);                     
                    mailBen.setToAddresses(toaddBen);
                    // PLV-5316 - INICIO
                    // mail.setTargetObjectId(contactId);
                    mailBen.setSaveAsActivity(false);
                    // mailBen.setTargetObjectId('005L0000006X8mYIAS');
                    mailBen.setTargetObjectId(lstUserIdOrg[0].Id);
                    // PLV-5316 - FIM
                    mailBen.setTemplateID(templatePagBen.Id); 
                    mailBen.setWhatId(pagamentoId);
                    mailBen.setOrgWideEmailAddressId(owea.get(0).Id);
                    allMessageList.add(mailBen);
                }
                // PLV-5316 - FIM
                
                //email corretor
                //FIX 2
                if(!toadd.isEmpty()){ // PLV-5316 - INICIO/FIM
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                    
                    system.debug('toadd ao lado: '+toadd);
                    mail.setToAddresses(toadd);
                    // PLV-5316 - INICIO
                    // mail.setTargetObjectId(contactId);
                    mail.setSaveAsActivity(false);
                    // mail.setTargetObjectId('005L0000006X8mYIAS');
                    mail.setTargetObjectId(lstUserIdOrg[0].Id);
                    // PLV-5316 - FIM
                    mail.setTemplateID(templateCorretor); 
                    mail.setWhatId(pagamentoId);
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    allMessageList.add(mail);
                } // PLV-5316 - INICIO/FIM

                system.debug('toaddBen ao lado: '+toaddBen);
                //FIX 2
                if(caso.IdPrestadora__c == null && templateCliente != null && parceiroId == null){
                    system.debug('caso.Account.PersonEmail: '+caso.Account.PersonEmail);
                    List<string> toadd2 = new List<string>();
                    toadd2.add(caso.Account.PersonEmail);
                    
                    Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
                    mail2.setToAddresses(toadd2);
                    // PLV-5316 - INICIO
                    mail2.setSaveAsActivity(false);
                    // mail2.setTargetObjectId(contactId);
                    // mail2.setTargetObjectId('005L0000006X8mYIAS');
                    mail2.setTargetObjectId(lstUserIdOrg[0].Id);
                    // PLV-5316 - FIM
                    mail2.setTemplateID(templateCliente); 
                    mail2.setWhatId(pagamentoId);
                    mail2.setOrgWideEmailAddressId(owea.get(0).Id);
                    allMessageList.add(mail2);
                }
                
            }    

            if(allMessageList.size() > 0){
                Messaging.sendEmail(allMessageList,false);
            }

        }
        //PLV-4772-INICIO
        if(sCaso.size() > 0) {
            gerarPayloadPagamento(sCaso);
        }
        //PLV-4772-INICIO
    }
    //PLV-4065 fim

	//PLV-4034 Inicio
		public void createRecordControleIntegracaoBO(List<Pagamento_de_Sinistro__c> listPagamentos){
			System.debug('PagamentoDeSinistroBO.createRecordControleIntegracaoBO------------>');
			List<Id> sPagamento = new List<Id>();

			for(Pagamento_de_Sinistro__c pagamento : listPagamentos){
				//PLV-4034-Fix3 Inicio
                
				if((pagamento.Status__c == 'Liberado' && pagamento.Tipo_de_OP__c == 'Indenização' && pagamento.Tipo_de_OP__c == null) && pagamento.OP_SAP__c == null){
					sPagamento.add(pagamento.Id);
				}
				//PLV-4034-Fix3 Fim			
			}

			if(!sPagamento.isEmpty()){
				ControleIntegracao.createRecordControleIntegracao(sPagamento);
			}
		}
	//PLV-4034 Fim

	//PLV-4034 Inicio
		public void updateStatusPagamentoDeSinistroBO(List<Pagamento_de_Sinistro__c> listPagamentos){
			System.debug('PagamentoDeSinistroBO.updateStatusPagamentoDeSinistroBO------------>');			
			
			List<Pagamento_de_Sinistro__c> lPagamentos = new List<Pagamento_de_Sinistro__c>();

			for(Pagamento_de_Sinistro__c pagamento : listPagamentos){
				if(pagamento.Status__c == 'Pago' || pagamento.Status__c == 'Erro'){					
					lPagamentos.add(pagamento);
				}			
			}
			
			if(!lPagamentos.isEmpty()){
				ControleIntegracao.updateStatusPagamentoDeSinistro(lPagamentos);
			}
		}
	//PLV-4034 Fim

	//PLV-4034 Inicio FDS
		public void cancelRecordPagamentoSinistro(List<Pagamento_de_Sinistro__c> listPagamentos, Map<Id, Pagamento_de_Sinistro__c> mPagOld){
			System.debug('PagamentoDeSinistroBO.cancelRecordPagamentoSinistro------------>');
			Set<Id> sPagamento = new Set<Id>();

			for(Pagamento_de_Sinistro__c pagamento : listPagamentos){				
				if(pagamento.Status__c == 'Cancelado' && mPagOld.get(pagamento.Id).Status__c == 'Pendente' && pagamento.Tipo_de_OP__c == 'Indenização'){
					sPagamento.add(pagamento.Id);
				}							
			}

			if(!sPagamento.isEmpty()){							
				List<BeneficiarioGarantia__c> listBen = [select Id, Is_Integracao__c, Pagamento_de_Sinistro__r.Dados_Bancarios__c, Pagamento_de_Sinistro__c, Data_programada_do_pagamento__c from BeneficiarioGarantia__c where Pagamento_de_Sinistro__c in :(sPagamento)];

				For(BeneficiarioGarantia__c o : listBen){               
					   o.Pagamento_de_Sinistro__c = null;               
					   o.Status__c = 'Liberado';			                  
				}
				update listBen;				
			}
		}
	//PLV-4034 Fim FDS

	//PLV-4034 Inicio FDS
		public void cancelRecordControleIntegracaoBO(List<Pagamento_de_Sinistro__c> listPagamentos){
			System.debug('PagamentoDeSinistroBO.cancelRecordControleIntegracaoBO------------>');
			Set<Id> sPagamento = new Set<Id>();

			for(Pagamento_de_Sinistro__c pagamento : listPagamentos){
				//PLV-4034-Fix3 Inicio
				if(pagamento.Status__c == 'Cancelado' && pagamento.Tipo_de_OP__c == 'Indenização' && pagamento.OP_SAP__c != null){
					sPagamento.add(pagamento.Id);
				}
				//PLV-4034-Fix3 Fim			
			}

			if(!sPagamento.isEmpty()){
				atualizaPagamentoExterno(sPagamento);
			}
		}
	//PLV-4034 Fim FDS
	
	//PLV-4034 Inicio FDS
	@future(callout=true)
	public static void atualizaPagamentoExterno(Set<Id>idRequisicaoPag){
        List<Pagamento__x> lPagamentoExterno = [SELECT idObjeto__c, Status__c FROM Pagamento__x WHERE idObjeto__c IN : (idRequisicaoPag)];
        List<Pagamento__x> lPagamentoExternoUpdate = new List<Pagamento__x>();
        for(Pagamento__x p : lPagamentoExterno){
            p.Status__c = 'CANCELADO';
            lPagamentoExternoUpdate.add(p);
        }
      
		if(!lPagamentoExternoUpdate.isEmpty()){            
            Database.SaveResult[] srList = Database.updateAsync(lPagamentoExternoUpdate);            
			System.debug('srList = ' + srList);
			
			List<BeneficiarioGarantia__c> listBen = [select Id, Is_Integracao__c, Pagamento_de_Sinistro__r.Dados_Bancarios__c, Pagamento_de_Sinistro__c, Data_programada_do_pagamento__c from BeneficiarioGarantia__c where Pagamento_de_Sinistro__c in :(idRequisicaoPag)];

			For(BeneficiarioGarantia__c o : listBen){               
				   o.Pagamento_de_Sinistro__c = null;               
				   o.Status__c = 'Liberado';			                  
			}
			update listBen;

			List<ControleIntegracao__c> listControle = [SELECT id, IdObjeto__c FROM ControleIntegracao__c WHERE  IdObjeto__c IN: idRequisicaoPag];
		
			for(ControleIntegracao__c controle : listControle){
				controle.Status__c = 'Erro';
			}

			update listControle;
		}
    }
	//PLV-4034 Fim FDS
	
	//PLV - 4335 - Inicio

    public void atualizaAprovacaoPorValor(List<Pagamento_de_Sinistro__c> ltPagamentoSinistro){
        if(! ltPagamentoSinistro.isEmpty()){
            for(Pagamento_de_Sinistro__c pagamentoItem : ltPagamentoSinistro){
                if(pagamentoItem.Valor_total_a_ser_indenizado__c != null && pagamentoItem.Valor_total_a_ser_indenizado__c > 0){
                    if(pagamentoItem.Valor_total_a_ser_indenizado__c <= 100000){
                        //pagamentoItem.Tipo_de_Aprova_o__c = 'Alçada Salesforce'; //PLV-4825 - Inicio/Fim
                        pagamentoItem.Tipo_de_Aprova_o__c = alcadaSAP; //PLV-4825 - Inicio/Fim 
                        pagamentoItem.BeneficiarioValidado__c = true;
                        pagamentoItem.Valor_total_a_ser_indenizado__c = pagamentoItem.Valor_total_a_ser_indenizado__c.setScale(2);
                    }else{
                        pagamentoItem.Tipo_de_Aprova_o__c = alcadaSAP;    
                    }      
                }
            }

        }
    }   
    //PLV - 4335 - FIM
    public class RetornoTO{
        public List<RecusaTO> recusas;
    }
    public class RecusaTO{
        public MensagemTO mensagens;
        public Integer codigo; 
    }
    public class MensagemTO{
        public String cliente;
    }
    
    
    //PLV-4772 inicio
    @future(callout=true)
    public static void gerarPayloadPagamento(Set<Id> setCaso) {
        System.debug('gerarPayLoad######');
        Set<Id> sContrato = new Set<Id>();
        Set<Id> sCaso = setCaso;
        Set<Id> sAccount = new Set<Id>();
        String payload;
        Map<Id, FranquiaGarantia__c> mapFranquiaDaGarantia = new Map<Id, FranquiaGarantia__c>();
        OrgWideEmailAddress[] owea  = [select Id from OrgWideEmailAddress where Address = 'sinistro.vida@portoseguro.com.br'];
        Map<Id, Case> mCaso = new Map<Id, Case>();

        if(!sCaso.isEmpty() && owea.size() > 0){            
            for(Case c : [Select Id,Contrato__c,AccountId,IdPrestadora__c,Account.PersonEmail,Lista_de_pendencias__c From Case Where id In :sCaso] ){
                mCaso.put(c.Id, c);
                sContrato.add(c.Contrato__c);
                sAccount.add(c.AccountId);
            }
        }
        List<PagamentoGarantia__c> listPagamentoGarantia = [select Id, Name, Caso__r.Id, Caso__r.CaseNumber, Caso__r.Contact.Name, Caso__r.Contact.Id, Caso__r.AccountId, Caso__r.Account.Name, 
                                    Caso__r.Account.PersonBirthdate, Caso__r.Account.Sexo__c, Caso__r.Account.Fumante__c, Caso__r.Account.Profissao__r.Name, Caso__r.Account.Profissao__r.CodigoProfissao__c, Caso__r.Account.RegimeTrabalho__c, 
                                    Caso__r.Account.Renda__c,Caso__r.Account.Cpf__c, Caso__r.Contrato__c, Caso__r.Contrato__r.TermoGuarda__c, Garantia_do_segurado_do_contrato__r.Id, Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.Name, 
                                    Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.CancelaGarantia__c, Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.MomentoCancelamento__c,Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c, Fase__c, Status_do_pagamento__c 
                                    from PagamentoGarantia__c where Caso__r.Id in : sCaso];
		System.debug('listPagamentoGarantia   ==>>'+listPagamentoGarantia);
        List<GrupoProfissoes__c> listGrupoProfissoes = [SELECT Id, GrupoRisco__r.Name, Profissao__r.Name FROM GrupoProfissoes__c];
        Map<String,GrupoProfissoes__c> mGrupoProfissoes = new Map<String,GrupoProfissoes__c>();
        for (GrupoProfissoes__c grupo: listGrupoProfissoes){
            mGrupoProfissoes.put(grupo.Profissao__r.Name, grupo);
        }
        Map<Id,Contract> mContract = new Map<Id,Contract>();
        List<Contract> listContract= [select Id, Name, MeioComercializacao__c, Oportunidade__r.Numero__c, Oportunidade__r.NumeroOferta__c, Produto__r.ProductCode, Oportunidade__r.CanalDistribuicao__r.Sigla__c, Oportunidade__r.NumeroPortal__c, 
        Oportunidade__r.TipoVigencia__c, Oportunidade__r.VigenciaInicial__c, Oportunidade__r.VigenciaFinal__c, Produto__r.Segmento__c, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c, 
        TipoContrato__c, VigenciaFinal__c, StartDate, AccountId from Contract where Id in : sContrato];
        for (Contract c: listContract){
            mContract.put(c.AccountId, c);
        }
        List<GarantiaContrato__c> listGarantias = [select Id, Name,Garantia__r.Name, Capital__c, Garantia__r.Sigla__c, MoedaGarantia__c, FranquiaGarantia__c, FranquiaGarantia__r.Name, FranquiaGarantia__r.CodigoFranquia__c, ValorCotacao__c, Contrato__c from GarantiaContrato__c where Contrato__c in : sContrato];
        List<String> lSigla = new List<String>();
        for (GarantiaContrato__c garantia: listGarantias){
            lSigla.add(garantia.Garantia__r.Sigla__c);
        }
        List<FranquiaGarantia__c> listFranquiaGarantia = [SELECT Id, Franquia__r.CodigoFranquia__c, Franquia_Padrao__c,  GarantiaProduto__r.Garantia__r.Sigla__c, GarantiaProduto__r.QuantidadeMaximaContratacao__c 
                                                FROM FranquiaGarantia__c 
                                                WHERE Franquia_Padrao__c = true 
                                                AND GarantiaProduto__r.Garantia__r.Sigla__c IN: lSigla];

        List<GrupoContrato__c> lstGrupoContrato = [SELECT  Id, Name, TipoCalculo__c, Numero__c, QuantidadeVidas__c, ContratanteContrato__r.Contrato__c
                            FROM    GrupoContrato__c
                            WHERE   ContratanteContrato__r.Contrato__c in : sContrato];
        Set<id> idsGarantias = new Set<id>();
        Set<id> idsGarantiaContrato = new Set<id>();
        for (PagamentoGarantia__c pagamento: listPagamentoGarantia){
            for(GarantiaContrato__c garantiaContrato: listGarantias){                 
                idsGarantias.add(garantiaContrato.FranquiaGarantia__c);
                idsGarantiaContrato.add(garantiaContrato.id);
            }
        }
        List<FranquiaGarantia__c> franquiatemp = new List<FranquiaGarantia__c>();
        if (idsGarantias!=null&&idsGarantiaContrato!=null) {
            franquiatemp = [SELECT Id, Name, (SELECT id, Name FROM Garantias_do_contrato__r where id in :idsGarantiaContrato  LIMIT 1) FROM FranquiaGarantia__c WHERE id IN :idsGarantias];
        }

        List<FavorecidoRemuneracaoContrato__c> listFavorecido = [SELECT Id, CorretorLider__c, Participacao__c, Papel__c, Susep__c, SusepEmissao__c, SusepOficialCorretor__c, SusepOrcamento__c, AntecipacaoComissao__c
                                , RemuneracaoContrato__c, RemuneracaoContrato__r.TipoRemuneracao__r.Name, RemuneracaoContrato__r.Percentual__c, RemuneracaoContrato__r.Porcentagem_de_Retencao__c,RemuneracaoContrato__r.Contrato__c
                                ,Conta__c , Conta__r.Cnpj__c, Conta__r.Cpf__c, Conta__r.C_digo_do_Agenciador__c, Conta__r.Name
                                FROM FavorecidoRemuneracaoContrato__c
                                WHERE RemuneracaoContrato__r.Contrato__c in:sContrato];
        
        Map<String,ContratanteContrato__c> mContratante = new Map<String,ContratanteContrato__c>();
        List<ContratanteContrato__c> listContratante = [SELECT Id, Name, Conta__c, Contrato__c FROM ContratanteContrato__c WHERE Contrato__c in :sContrato];
        for (ContratanteContrato__c contratante: listContratante){
            mContratante.put(contratante.Conta__c, contratante);
        }
       
        for (PagamentoGarantia__c pagamento: listPagamentoGarantia){
            if (pagamento.Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.CancelaGarantia__c && pagamento.Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.MomentoCancelamento__c == 'Pagamento') {
               
                EndossoTO.request request = new EndossoTO.request();
                request.orcamento = new EndossoTO.OrcamentoTO();
                request.orcamento.tipoSeguro = 'EDS';
                if (mContract.get(pagamento.Caso__r.AccountId).Oportunidade__r.Numero__c!=null) {
                    request.orcamento.tipoVigencia = mContract.get(pagamento.Caso__r.AccountId).Oportunidade__r.TipoVigencia__c;
                    request.orcamento.vigenciaFinal = mContract.get(pagamento.Caso__r.AccountId).Oportunidade__r.VigenciaFinal__c;
                    request.orcamento.numeroOrcamento = mContract.get(pagamento.Caso__r.AccountId).Oportunidade__r.Numero__c;
                    request.orcamento.numeroOferta = mContract.get(pagamento.Caso__r.AccountId).Oportunidade__r.NumeroOferta__c;
                    request.orcamento.canalDistribuicao = mContract.get(pagamento.Caso__r.AccountId).Oportunidade__r.CanalDistribuicao__r.Sigla__c;                
                    request.orcamento.numeroPortal = mContract.get(pagamento.Caso__r.AccountId).Oportunidade__r.NumeroPortal__c;
                    request.orcamento.vigenciaInicial = mContract.get(pagamento.Caso__r.AccountId).Oportunidade__r.VigenciaInicial__c;
                    request.orcamento.entradaNegocio = 0;
                }
                request.orcamento.orcnum = ''; 
                request.orcamento.dataCalculo = String.valueOf(System.today());
                request.orcamento.codigoProdutoVida = mContract.get(pagamento.Caso__r.AccountId).Produto__r.ProductCode;
                request.orcamento.meioComercializacao = mContract.get(pagamento.Caso__r.AccountId).MeioComercializacao__c; 
                request.orcamento.ordemPortal = 1;
                request.orcamento.segmento = mContract.get(pagamento.Caso__r.AccountId).Produto__r.Segmento__c ;  
                request.orcamento.dataEndosso = String.ValueOf(System.Today().addDays(+5)); //INICIO/FIM - PLV-4686 - Guilherme Brito
                
                request.orcamento.contratoOriginal = new EndossoTO.ContratoOriginalTO();
                request.orcamento.contratoOriginal.empresa = mContract.get(pagamento.Caso__r.AccountId).Empresa__c;
                request.orcamento.contratoOriginal.sucursal = mContract.get(pagamento.Caso__r.AccountId).Sucursal__c;
                request.orcamento.contratoOriginal.ramo = mContract.get(pagamento.Caso__r.AccountId).CodigoRamo__c;
                request.orcamento.contratoOriginal.apolice = mContract.get(pagamento.Caso__r.AccountId).NumeroApolice__c;
                request.orcamento.contratoOriginal.endosso = mContract.get(pagamento.Caso__r.AccountId).Endosso__c;
                request.orcamento.contratoOriginal.tipoContrato = mContract.get(pagamento.Caso__r.AccountId).TipoContrato__C!=null? mContract.get(pagamento.Caso__r.AccountId).TipoContrato__C : '';
                request.orcamento.contratoOriginal.vigenciaFinal = mContract.get(pagamento.Caso__r.AccountId).VigenciaFinal__c;
                request.orcamento.contratoOriginal.vigenciaInicial = mContract.get(pagamento.Caso__r.AccountId).StartDate;
                Decimal valorPago = 0;
                Decimal valorTotal = 0;

                ParcelamentoContratoTO retornoParcelas = new ParcelamentoContratoTO();
                retornoParcelas.data = new List<ParcelamentoContratoTO.DataTO>();
                if(!Test.isRunningTest()){
                retornoParcelas = ContractFacade.getInstance().ObterParcelasContratoSegurado(mContratante.get(pagamento.Caso__r.AccountId).Id);
                }

                if(!retornoParcelas.data.isEmpty())
                {
                for(ParcelamentoContratoTO.DataTO item: retornoParcelas.data)
                {
                    if(item.status == 'PAGA'){
                        valorPago += decimal.ValueOf(item.valorParcela);
                    }
                    valorTotal += decimal.ValueOf(item.valorParcela);
                }
                }
                request.orcamento.contratoOriginal.premioPago = valorTotal;               
                
                
                List<String> siglas = new List<String>();
                
                Map<String, FranquiaGarantia__c> mapFranquiaGarantia = new Map<String, FranquiaGarantia__c>();
                Map<String, GarantiaContrato__c> mapGarantiaContrato = new Map<String, GarantiaContrato__c>();
                List<EndossoTO.CoberturaTO> listCobertura = new List<EndossoTO.CoberturaTO>();
                   
                List<String> siglasFranquia = new List<String>();
                for(FranquiaGarantia__c fg : listFranquiaGarantia){
                    siglasFranquia.add(fg.GarantiaProduto__r.Garantia__r.Sigla__c);
                    mapFranquiaGarantia.put(fg.GarantiaProduto__r.Garantia__r.Sigla__c, fg);
                }
                
                for(FranquiaGarantia__c franquiatmp : franquiatemp){
                    if(franquiatmp.Garantias_do_contrato__r.isEmpty()) return;
                    for(GarantiaContrato__c fran : franquiatmp.Garantias_do_contrato__r){
                        if (fran.Id!=null && franquiatmp!=null) {
                            mapFranquiaDaGarantia.put(fran.Id, franquiatmp);                            
                        }
                    }
                }
                
                for(GarantiaContrato__c gc : listGarantias){
                    if(!mapGarantiaContrato.containsKey(gc.Garantia__r.Sigla__c)){
                        if (gc.Contrato__c == pagamento.Caso__r.Contrato__c) { 
                            EndossoTO.CoberturaTO cobertura = new EndossoTO.CoberturaTO();
                            cobertura.sigla = gc.Garantia__r.Sigla__c;
                            cobertura.valor = gc.Capital__c!=null? gc.Capital__c : 0;
                            if (!mapFranquiaGarantia.containskey(cobertura.sigla) || mapFranquiaGarantia.get(cobertura.sigla).GarantiaProduto__r.QuantidadeMaximaContratacao__c==null) {
                                cobertura.quantidade = 0;
                            }
                            else {
                                cobertura.quantidade = mapFranquiaGarantia.get(cobertura.sigla).GarantiaProduto__r.QuantidadeMaximaContratacao__c;
                            }
                            cobertura.moeda = '';
                            FranquiaGarantia__c franquia = mapFranquiaDaGarantia.get(gc.id);
                            cobertura.franquia = '';
                            cobertura.cotacaoMoeda = 0;
                            cobertura.cobrado = '';
                            
                            listCobertura.add(cobertura);
                            mapGarantiaContrato.put(gc.Garantia__r.Sigla__c, gc);
                        }
                    }
                }

                request.orcamento.contratoOriginal.contratantes = new List<EndossoTO.ContratanteTO>();
                EndossoTO.ContratanteTO contratanteOriginal = new EndossoTO.ContratanteTO();
                contratanteOriginal.tipo = 'PRI';
                contratanteOriginal.numero = 0;
                contratanteOriginal.grupos = new List<EndossoTO.GrupoTO>();
                EndossoTO.GrupoTO grupoOriginal = new EndossoTO.GrupoTO();
                grupoOriginal.tipoCalculo = '';
                grupoOriginal.tarifa = 0;
                grupoOriginal.segurados = new List<EndossoTO.SeguradoTO>();
                grupoOriginal.qtdeVidas = 0;
                grupoOriginal.nome = '';
                grupoOriginal.numero = 0;
                EndossoTO.SeguradoTO seguradoOriginal = new EndossoTO.SeguradoTO();
                seguradoOriginal.numero = 0;
                seguradoOriginal.pessoa = new EndossoTO.PessoaTO();
                seguradoOriginal.pessoa.nome = pagamento.Caso__r.Account.Name;
                seguradoOriginal.pessoa.rendaMensal = String.valueOf(pagamento.Caso__r.Account.Renda__c)!=null? String.valueOf(pagamento.Caso__r.Account.Renda__c) : '';                    
                integer index = seguradoOriginal.pessoa.rendaMensal.indexOf('.');
                seguradoOriginal.pessoa.rendaMensal = seguradoOriginal.pessoa.rendaMensal.substring(0,index);
                seguradoOriginal.pessoa.dadosPessoaFisica = new EndossoTO.DadosPessoaFisicaTO();
                seguradoOriginal.pessoa.tipo = 'FIS';
                seguradoOriginal.pessoa.dadosPessoaFisica.fumante = pagamento.Caso__r.Account.Fumante__c == 'Sim'? true: false;
                seguradoOriginal.pessoa.dadosPessoaFisica.dataNascimento = pagamento.Caso__r.Account.PersonBirthdate!=null? string.valueOf(pagamento.Caso__r.Account.PersonBirthdate)+'T00:00:00.000Z' : '';
                seguradoOriginal.pessoa.dadosPessoaFisica.sexo = pagamento.Caso__r.Account.Sexo__c!=null? pagamento.Caso__r.Account.Sexo__c : '';
                seguradoOriginal.pessoa.dadosPessoaFisica.profissao = pagamento.Caso__r.Account.Profissao__r.Name!=null? pagamento.Caso__r.Account.Profissao__r.CodigoProfissao__c : '';
                seguradoOriginal.pessoa.dadosPessoaFisica.regimeTrabalho = pagamento.Caso__r.Account.RegimeTrabalho__c!=null? pagamento.Caso__r.Account.RegimeTrabalho__c : 'CLT';
                seguradoOriginal.pessoa.dadosPessoaFisica.numeroCpf = pagamento.Caso__r.Account.Cpf__c!=null? pagamento.Caso__r.Account.Cpf__c : '';
                seguradoOriginal.pessoa.dadosPessoaFisica.grupoProfissao = mGrupoProfissoes.get(pagamento.Caso__r.Account.Profissao__r.Name).GrupoRisco__r.Name!=null? mGrupoProfissoes.get(pagamento.Caso__r.Account.Profissao__r.Name).GrupoRisco__r.Name : '';
                seguradoOriginal.pessoa.dadosPessoaFisica.digitoCpf = '';
                seguradoOriginal.coberturas = listCobertura;
                grupoOriginal.segurados.add(seguradoOriginal);
                contratanteOriginal.grupos.add(grupoOriginal);
                request.orcamento.contratoOriginal.contratantes.add(contratanteOriginal);

                for(FavorecidoRemuneracaoContrato__c lf: listFavorecido){
                    if (lf.RemuneracaoContrato__r.Contrato__c==pagamento.Caso__r.Contrato__r.Id) {                    
                        EndossoTO.RemuneracaoTO remuneracao = new EndossoTO.RemuneracaoTO();
                        remuneracao.percentual = lf.RemuneracaoContrato__r.Percentual__c;
                        remuneracao.tipoRemuneracao =  lf.RemuneracaoContrato__r.TipoRemuneracao__r.Name;
                        if(request.orcamento.remuneracoes == null){
                            request.orcamento.remuneracoes = new List<EndossoTO.RemuneracaoTO>();
                        }
                        request.orcamento.remuneracoes.add(remuneracao);
                    }
                }

                request.orcamento.contratantes = new List<EndossoTO.ContratanteTO>();
                EndossoTO.ContratanteTO contratante = new EndossoTO.ContratanteTO();
                contratante.tipo = 'PRI'; 
                contratante.numero = 1;
            
                contratante.grupos = new List<EndossoTO.GrupoTO>();
                for( GrupoContrato__c grupoContrato : lstGrupoContrato ){
                    if (pagamento.Caso__r.Contrato__r.Id == grupoContrato.ContratanteContrato__r.Contrato__c) {
                        
                        EndossoTO.GrupoTO grupo = new EndossoTO.GrupoTO();
                        grupo.tipoCalculo = grupoContrato.TipoCalculo__c!=null? grupoContrato.TipoCalculo__c : '';
                        grupo.tarifa = 0;
                        grupo.numero = Integer.valueOf(grupoContrato.Numero__c)!=null?Integer.valueOf(grupoContrato.Numero__c) : 0;
                        grupo.nome = grupoContrato.Name!=null? grupoContrato.Name : '';                   
                        grupo.qtdeVidas = Integer.valueOf(grupoContrato.QuantidadeVidas__c)!=null? Integer.valueOf(grupoContrato.QuantidadeVidas__c) : 0;                            
                                                
                        grupo.segurados = new List<EndossoTO.SeguradoTO>();
                        EndossoTO.SeguradoTO segurado = new EndossoTO.SeguradoTO();
                        segurado.numero = 1;
                        segurado.pessoa = new EndossoTO.PessoaTO();
                        segurado.pessoa.nome = pagamento.Caso__r.Account.Name;
                        segurado.pessoa.dadosPessoaFisica = new EndossoTO.DadosPessoaFisicaTO();
                        segurado.pessoa.dadosPessoaFisica.dataNascimento = pagamento.Caso__r.Account.PersonBirthdate!=null? string.valueOf(pagamento.Caso__r.Account.PersonBirthdate)+'T00:00:00.000Z':'';
                        segurado.pessoa.dadosPessoaFisica.sexo = pagamento.Caso__r.Account.Sexo__c!=null? pagamento.Caso__r.Account.Sexo__c : '';
                        segurado.pessoa.dadosPessoaFisica.fumante = pagamento.Caso__r.Account.Fumante__c == 'Sim'? true: false;
                        segurado.pessoa.dadosPessoaFisica.numeroCpf = pagamento.Caso__r.Account.cpf__c!=null? pagamento.Caso__r.Account.cpf__c:'';
                        segurado.pessoa.dadosPessoaFisica.digitoCpf = '';
                        segurado.pessoa.dadosPessoaFisica.profissao = pagamento.Caso__r.Account.Profissao__r.CodigoProfissao__c!=null? pagamento.Caso__r.Account.Profissao__r.CodigoProfissao__c:'';
                        segurado.pessoa.dadosPessoaFisica.grupoProfissao = mGrupoProfissoes.get(pagamento.Caso__r.Account.Profissao__r.Name).GrupoRisco__r.Name!=null?mGrupoProfissoes.get(pagamento.Caso__r.Account.Profissao__r.Name).GrupoRisco__r.Name:'';
                        segurado.pessoa.dadosPessoaFisica.regimeTrabalho = pagamento.Caso__r.Account.RegimeTrabalho__c!=null? pagamento.Caso__r.Account.RegimeTrabalho__c:'CLT';
                        segurado.pessoa.rendaMensal = pagamento.Caso__r.Account.Renda__c!=null? String.valueOf(pagamento.Caso__r.Account.Renda__c):'';                             
                        segurado.pessoa.tipo = 'FIS';
                        
                        segurado.coberturas = new List<EndossoTO.CoberturaTO>();
                        
                        for( GarantiaContrato__c eCobertura : listGarantias ){
                            if (eCobertura.Contrato__c==pagamento.Caso__r.Contrato__c&&eCobertura.Garantia__r.Sigla__c!=pagamento.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c) {
                                
                                EndossoTO.CoberturaTO cobertura = new EndossoTO.CoberturaTO();
                                //PLV-4803 - INICIO
                                if('TELEMED'.equalsIgnoreCase(eCobertura.Garantia__r.Sigla__c)){
                                    cobertura.valor = eCobertura.Capital__c!=null? eCobertura.Capital__c : 0;
                                    cobertura.sigla = eCobertura.Garantia__r.Sigla__c;
                                    cobertura.quantidade = 0;
                                    cobertura.moeda = null;
                                    cobertura.franquia = ''; 
                                    cobertura.cotacaoMoeda = null;
                                    cobertura.cobrado = null;
                                }else{
                                    cobertura.valor = eCobertura.Capital__c!=null? eCobertura.Capital__c : 0;
                                    cobertura.sigla = eCobertura.Garantia__r.Sigla__c;
                                    cobertura.quantidade = 1;
                                    cobertura.moeda = eCobertura.MoedaGarantia__c!=null? eCobertura.MoedaGarantia__c:'';
                                    cobertura.franquia = eCobertura.FranquiaGarantia__c!=null? eCobertura.FranquiaGarantia__r.CodigoFranquia__c:'';
                                    cobertura.cotacaoMoeda = 0;
                                    cobertura.cobrado = '';
                                    

                                }
                                
                                //PLV-4803 - FIM
                                segurado.coberturas.add( cobertura );
                            }
                        }
                        
                        grupo.segurados.add( segurado );
                        contratante.grupos.add( grupo );
                    }
                }
                request.orcamento.contratantes.add(contratante);
                request.orcamento.consultivo = false;
                request.orcamento.closeDate = System.Today();
                payload = JSON.serialize(request);

                System.debug('>PAYLOAD> ' + payload);
                          
                pagOfertas(payload, new List<Id>(sCaso)[0]);
            }
        }
    }

    public static void  pagOfertas(String payload, Id idCaso) {
      
        String retorno = calculoOfertas(payload);
        System.debug('retorno ====>>> ' + retorno);
        EmissaoTO.PayloadTO retornoOrcamento = (EmissaoTO.PayloadTO) JSON.deserialize(retorno,EmissaoTO.PayloadTO.class);
        EmissaoTO orcamento = retornoOrcamento.ofertas[0].orcamento;
        System.debug('orcamento --->' + orcamento);
        if (!Test.isRunningTest()) {
            payloadTransmissao.gerarEndossoPagamento(idCaso, orcamento);            
        }
 	
      }
  
      public static String calculoOfertas(String calculosContrats) {
  
        String Response;	
  
        try{
            Response = ''; //civServ.criacaoCalculo(calculosContrats);  //MGRC-1657 - INICIO/FIM
            System.debug('Response: ' + Response);
        }
        catch(Exception ex){
          System.debug('###### ERROR: (" + ex.getLineNumber() + "): ' + ex.getMessage());
          throw new ServiceException('ERRO de serviço: ' + ex.getMessage() + ' Linha: ' + ex.getLineNumber());
        }	
             
        return Response;
    }
    
    public class ServiceException extends Exception { }	
    //PLV-4772 fim

    //PLV-4604 - INICIO
    public void updateOPSAPRequisicao(List<Pagamento_de_Sinistro__c> lstPagamentos, Map<Id, Pagamento_de_Sinistro__c> mapPagamentoOld){
        Map<Id, String> mapRequisicaoOP = new Map<Id,String>(); 
        for(Pagamento_de_Sinistro__c pagamento : lstPagamentos){
            Pagamento_de_Sinistro__c pagamentoOld = mapPagamentoOld.get(pagamento.Id);
            if(pagamento.OP_SAP__c != null && pagamento.OP_SAP__c != pagamentoOld.OP_SAP__c){
                mapRequisicaoOP.put(pagamento.Requisicao_de_Pagamento__c, pagamento.OP_SAP__c);
            }
        }
        if(mapRequisicaoOP.size() > 0){
            List<Requisicao_de_Pagamento__c> lstRequisicao = [SELECT Id FROM Requisicao_de_Pagamento__c WHERE Id IN:mapRequisicaoOP.keySet()];
            for(Requisicao_de_Pagamento__c requisicao : lstRequisicao){
                requisicao.Numero_OP_SAP__c = mapRequisicaoOP.get(requisicao.Id);
            }
            update lstRequisicao;
        }
    }
    //PLV-4604 - FIM
    //LECVP-344 - INICIO
    public void atualizarValorPagoCaso(List<Pagamento_de_Sinistro__c> pgtoSin){

        Decimal valorTotalPago = 0;
        String statusPgto = 'Pago';
        Set<Id> pgtoGarId = new Set<Id>();

        List<PagamentoGarantia__c> pgsGar = [SELECT Id FROM PagamentoGarantia__c WHERE Caso__c = :pgtoSin[0].Caso_de_Sinistro__c];

        AggregateResult[] valoresPagGar = new AggregateResult[]{};

        for(PagamentoGarantia__c p : pgsGar){
            pgtoGarId.add(p.Id);
        }

        valoresPagGar = BeneficiarioGarantiaDAO.getInstance().buscarValPagoGarsSin(statusPgto, pgtoGarId);

        for(AggregateResult valorPagGar : valoresPagGar){
            Object valor = valorPagGar.get('valorPagoGar') != null ? valorPagGar.get('valorPagoGar') : null;
            
            if(valor != null){
                valorTotalPago += (Decimal)valor;
            }
        }

        if(valorTotalPago > 0){
            Case cs = [ SELECT Id, Valor_Pago__c FROM Case WHERE Id = :pgtoSin[0].Caso_de_Sinistro__c];
            cs.Valor_Pago__c = valorTotalPago;
            update cs;
        }
    }

    public void atualizarValorPagoGarantia(List<Pagamento_de_Sinistro__c> pgtoSin){
    
        Decimal valorTotalPago = 0;
        String statusPgto = 'Pago';
        Set<Id> pgtoGarId = new Set<Id>();
        List<PagamentoGarantia__c> pgsGarValPg = new List<PagamentoGarantia__c>();

        Pagamento_de_Sinistro__c ps = [SELECT Id, Status__c, Garantia_do_Sinistro__c FROM Pagamento_de_Sinistro__c WHERE Id = :pgtoSin[0].Id];
        
        if(ps.Status__c == 'Pago'){
            List<PagamentoGarantia__c> pgGar = [SELECT Id, Valor_pago__c FROM PagamentoGarantia__c WHERE Id = : ps.Garantia_do_Sinistro__c];

            if(!pgGar.isEmpty()){
                AggregateResult[] valoresPagGar = BeneficiarioGarantiaDAO.getInstance().buscarValPagoGarSin(statusPgto, pgGar[0].Id);

                for(AggregateResult valorPagGar : valoresPagGar){
                    Object valor = valorPagGar.get('valorPagoGar') != null ? valorPagGar.get('valorPagoGar') : null;
            
                    if(valor != null){
                    valorTotalPago += (Decimal)valor;
                    }
                }

                if(valorTotalPago > 0){
                    pgGar[0].Valor_Pago__c = valorTotalPago;
                    update pgGar[0];
                }
            }
        }
    }

    //LECVP-344 - INICIO
    //II-59 FIX08 INICIO
    public void calcularSaldResrvCaso(List<MovimentoSinistro__c> movimentoSin){ 

        Decimal valTotMovs = 0;
        Set<String> tipoMovs = new Set<String>{'%Aviso%', '%Acerto%','%Pagamento%'};
        List<Case> casosUpdate = new List<Case>();   
        
        Set<Id> casosIds = new Set<Id>();
        for (MovimentoSinistro__c ms : movimentoSin) {
            casosIds.add(ms.Caso__c);
        }

        List<MovimentoSinistro__c> lstMS = [SELECT Id, PagamentoGarantia__c, ValorMovimento__c, TipoMovimento__c, DescricaoMovimento__c, Caso__c 
                                            FROM MovimentoSinistro__c 
                                            WHERE Caso__c IN :casosIds];

        List<Case> casos = [ SELECT Id FROM Case WHERE Id IN :casosIds];

        if(!lstMS.isEmpty()){
            for(Case cs : casos){
                valTotMovs = 0;
                Set<Id> garantiasId = new Set<Id>();
                List<MovimentoSinistro__c> listMovAvAcerts = new List<MovimentoSinistro__c>();
                List<MovimentoSinistro__c> listMovPgtos = new List<MovimentoSinistro__c>();
                for(MovimentoSinistro__c ms : lstMS){
                    if(ms.Caso__c == cs.Id){
                        if(ms.PagamentoGarantia__c != null){
                            garantiasId.add(ms.PagamentoGarantia__c);
                        }
                        if(ms.TipoMovimento__c == 'Aviso' || ms.TipoMovimento__c == 'Acerto'){
                            listMovAvAcerts.add(ms);
                        }else{
                            listMovPgtos.add(ms);
                        }
                    }
                }
                system.debug('valTotMovs antes >> ' + valTotMovs);
                valTotMovs = this.calcularExtrato(garantiasId, listMovAvAcerts, listMovPgtos);
                system.debug('valTotMovs depois >> ' + valTotMovs);
                if(valTotMovs >= 0){
                    cs.Saldo_da_reserva__c = valTotMovs;
                    casosUpdate.add(cs);
                }

            }
            if(!casosUpdate.isEmpty()){
                update casosUpdate;
            }
        }
    }
    //II-59 FIX08 FIM
    //LECVP-344 - FIM

    //LECVP-344 - INICIO
    public void calcularSaldResrvGarantia(List<MovimentoSinistro__c> movimentoSin){

        Set<String> tipoMovs = new Set<String>{'%Aviso%', '%Acerto%','%Pagamento%'};
        List<PagamentoGarantia__c> atualizarGars = new List<PagamentoGarantia__c>();
        Set<Id> garantiasId = new Set<Id>();
        Decimal valTotMovs = 0;
        Decimal valsAvisAcerts = 0;
        Decimal valsPagtos = 0;
        List<MovimentoSinistro__c> listMovAvAcerts = new List<MovimentoSinistro__c>();
        List<MovimentoSinistro__c> listMovPgtos = new List<MovimentoSinistro__c>();
        //II-59 FIX08 INICIO
        Set<Id> casosIds = new Set<Id>();
        for (MovimentoSinistro__c ms : movimentoSin) {
            casosIds.add(ms.Caso__c);
        }

        List<MovimentoSinistro__c> listMS = [SELECT Id, PagamentoGarantia__c, ValorMovimento__c, TipoMovimento__c, DescricaoMovimento__c 
                                             FROM MovimentoSinistro__c 
                                             WHERE Caso__c IN :casosIds];
        //II-59 FIX08 FIM
       
        if(!listMS.isEmpty()){
            
            for(MovimentoSinistro__c ms : listMS){
                if(ms.PagamentoGarantia__c != null){
                    garantiasId.add(ms.PagamentoGarantia__c);
            }
                if(ms.TipoMovimento__c == 'Aviso' || ms.TipoMovimento__c == 'Acerto'){
                    listMovAvAcerts.add(ms);
                }else{
                    listMovPgtos.add(ms);
                }
            }

            /* 
            List<MovimentoSinistro__c> listMovs = PagamentoGarantiaDAO.getInstance().buscarTipoMovEGarantias(garantiasId, tipoMovs);

            for(MovimentoSinistro__c mv : listMovs){
                if(mv.TipoMovimento__c == 'Aviso' || mv.TipoMovimento__c == 'Acerto'){
                    listMovAvAcerts.add(mv);
                }else{
                    listMovPgtos.add(mv);
                }
            }

            */
            //II-59-FIX06-INICIO
            for(Id garId : garantiasId){
                valsAvisAcerts = 0;
                valsPagtos = 0; // LECVPV-147 INICIO/FIM
                for(MovimentoSinistro__c mv : listMovAvAcerts){                  
                    if(mv.PagamentoGarantia__c == garId && mv.ValorMovimento__c != null ){ // II-59-FIX07-INICIO/FIM                
                        System.debug('ENTROU AQUI: ' + mv.PagamentoGarantia__c);
                        System.debug('ENTROU AQUI: ' + mv.ValorMovimento__c);
                        System.debug('ENTROU AQUI: ' + garId);
                        valsAvisAcerts += mv.ValorMovimento__c;
                        System.debug('HENRIQUE VALOR: ' + valsAvisAcerts);
                    }                
                }//II-59-FIX06-FIM
                for(MovimentoSinistro__c mv : listMovPgtos){
                    if(mv.PagamentoGarantia__c == garId){
                        valsPagtos += mv.ValorMovimento__c;
                    }                
                }
                
				System.debug('valsAvisAcerts Henrique: ' + valsAvisAcerts);
                System.debug('valsPagtos Henrique: ' + valsPagtos);
                
               /* if (valsAvisAcerts >= valsPagtos){
                valTotMovs = valsAvisAcerts - valsPagtos;
                }else{
                    valTotMovs = valsPagtos - valsAvisAcerts;
                }*/
                 valTotMovs = (valsPagtos - valsAvisAcerts) * -1;
                
                System.debug('Val Tot Movs: ' + valTotMovs);

                PagamentoGarantia__c pg = new PagamentoGarantia__c(
                    Id = garId,
                    Saldo_da_reserva__c = valTotMovs
                );

                if(!atualizarGars.contains(pg) && pg.Id != null){
                    System.debug('ENTROU AQUI NO if da linha 975: ');
                    atualizarGars.add(pg);
                }
            }

            System.debug('LISTA DE ATUALIZAR GARANTIAS: ' + atualizarGars);
            if(!atualizarGars.isEmpty()){
                System.debug('Entrou aqui ??:');
                BeneficiarioGarantiaTriggerHandler.criarMovimento = false;
                update atualizarGars;
            }
        }
    }
    //LECVP-344 - FIM

     //LECVPV-200 - INICIO
     private  List<ComplementoIndenizacao__c> criarComplementosParaBaixar(Map<Id,Decimal> mapGarantiaFator){
       
        List<ComplementoIndenizacao__c> complementosBaixar = new List<ComplementoIndenizacao__c>();

        for (Id pagGar : mapGarantiaFator.keySet()) {
            complementosBaixar.addAll(
                ComplementoIndenizacaoBO.getInstance().criarComplementosBaixaPorPagamento(
                   mapGarantiaFator.get(pagGar),pagGar
                )
            );
        }
        return complementosBaixar;
     }

     // Baixar valor provisionado das garantias do movimento e dos complementos de indenizaçao quando o movimento for um pagamento
    public void efetuarBaixasPorPagamento(List<MovimentoSinistro__c> movimentoSin){

        List<PagamentoGarantia__c> garantiasBaixar = new List<PagamentoGarantia__c>();
        Set<Id> garantiasBaixarIds = new Set<Id>();
        Map<Id,Decimal> mapGarantiaValoresMov = new  Map<Id,Decimal>();
        Map<Id,Decimal> mapGarantiaValoresProv = new  Map<Id,Decimal>();
        Map<Id,Decimal> mapGarantiaComplementosInd = new  Map<Id,Decimal>();
        Map<Id,Decimal> mapGarantiaFator = new  Map<Id,Decimal>();

        for (MovimentoSinistro__c ms : movimentoSin) {
            if (ms.TipoMovimento__c == 'Pagamento') {
                garantiasBaixarIds.add(ms.PagamentoGarantia__c);
                if (!mapGarantiaValoresMov.containsKey(ms.PagamentoGarantia__c)) {
                    mapGarantiaValoresMov.put(ms.PagamentoGarantia__c,ms.ValorMovimento__c);
                } else {
                    Decimal valorPago =mapGarantiaValoresMov.get(ms.PagamentoGarantia__c);
                    mapGarantiaValoresMov.put(ms.PagamentoGarantia__c,valorPago + ms.ValorMovimento__c);
                }
            }
        }
        if (garantiasBaixarIds.isEmpty()) return;

        List<PagamentoGarantia__c> pagamentosGarantia = [SELECT Id, Valor_indenizado__c, ComplementoIndenizacao__c FROM PagamentoGarantia__c WHERE Id IN :garantiasBaixarIds]; 

        if (!pagamentosGarantia.isEmpty()) {
            for (PagamentoGarantia__c pg : pagamentosGarantia) {
                mapGarantiaValoresProv.put(pg.Id,pg.Valor_indenizado__c);
                mapGarantiaComplementosInd.put(pg.Id,pg.ComplementoIndenizacao__c); 
            }

            for (Id garId : garantiasBaixarIds) {
                Decimal principalProv = mapGarantiaValoresProv.get(garId);
                Decimal complementos = mapGarantiaComplementosInd.get(garId);
                Decimal totalPago =  mapGarantiaValoresMov.get(garId);
                // LECVPV-238-FIX01 INICIO
                Decimal fator = principalProv == 0 ? 1 : totalPago/(principalProv);
                // Decimal baixaComplementos = complementos*fator;
               // LECVPV-238-FIX01 FIM
                Decimal baixaPrincipal = totalPago;
                PagamentoGarantia__c pagGar = new PagamentoGarantia__c(
                    Id = garId,
                    Valor_indenizado__c = principalProv - baixaPrincipal
                ); 
                if(!garantiasBaixar.contains(pagGar) && pagGar.Id != null){
                    garantiasBaixar.add(pagGar);
                }
                mapGarantiaFator.put(garId,fator);
            }
            if(!garantiasBaixar.isEmpty()){
                BeneficiarioGarantiaTriggerHandler.criarMovimento = false;
                BeneficiarioGarantiaTriggerHandler.isFirstTime = false;
                update garantiasBaixar;
            }
            List<ComplementoIndenizacao__c> complementosBaixar = criarComplementosParaBaixar(mapGarantiaFator);
            PagamentoGarantiaTriggerHandler.isFirstTime = false;
            insert (complementosBaixar);
        }
    }
    //LECVPV-200 - FIM

    public Decimal calcularExtrato(Set<Id> garantiasId, List<MovimentoSinistro__c> listMovAvAcerts, List<MovimentoSinistro__c> listMovPgtos){

        Decimal valTotMovs = 0;
        Decimal valsAvisAcerts = 0;
        Decimal valsPagtos = 0;
    
        for(MovimentoSinistro__c mv : listMovAvAcerts){
            if(mv.ValorMovimento__c != null){
                system.debug('valsAvisAcerts antes >> ' + valsAvisAcerts);
                system.debug('mv.ValorMovimento__c >> ' + mv.ValorMovimento__c);
                valsAvisAcerts += mv.ValorMovimento__c;
                system.debug('valsAvisAcerts depois >> ' + valsAvisAcerts);
            }
        }
    
        for(MovimentoSinistro__c mv : listMovPgtos){
            if(mv.ValorMovimento__c != null){
                system.debug('valsPagtos antes >> ' + valsPagtos);
                system.debug('mv.ValorMovimento__c >> ' + mv.ValorMovimento__c);
                valsPagtos += mv.ValorMovimento__c;
                system.debug('valsPagtos depois >> ' + valsPagtos);
            }
        }

        /*if (valsAvisAcerts >= valsPagtos){
        valTotMovs = valsAvisAcerts - valsPagtos;
        }else{
            valTotMovs = valsPagtos - valsAvisAcerts;
        }*/
        system.debug('valTotMovs antes >> ' + valTotMovs);
        valTotMovs = (valsPagtos - valsAvisAcerts) * -1;
        system.debug('valTotMovs depois >> ' + valTotMovs);

        return valTotMovs;
    }
    //LECVP-344 - FIM
}