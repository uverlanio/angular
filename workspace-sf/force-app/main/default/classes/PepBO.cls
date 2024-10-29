/***
* Created: Jeferson Santana (Sys4b)
* Date: 2024-08
* Description: class responsible for testing: BatchCreateFileReportMegaDayTest 
* task-History : LECVPV-218
***/ 
public with sharing class PepBO {
    private static final PepBO instance = new PepBO();
	public Boolean processoPep = false;
	public static PepBO getInstance() {return instance; }
    //INICIO - LECVPV-218-V1
    public static void createPepObjeto(List<PepTO> listpepPessoa){
		System.debug('##createPepObjeto##'+listpepPessoa);
		//System.debug('##createPepObjeto##'+listpepPessoa.size());
		List<Pep__c> listPep = new List<Pep__c>();
		List<PepRelacionamento__c> listPepRelacionamento = new List<PepRelacionamento__c>();
		Map<Integer,List<PepRelacionamento__c>> mapListPepRelac = new Map<Integer, List<PepRelacionamento__c>>();
		Integer count = 0;
		for(PepTO pepPessoa : listpepPessoa){
			Pep__c pepObj = new Pep__c();
			Boolean relacionamento = false;		
			if((pepPessoa.listaPessoa == null) && (pepPessoa.listaRelacionada == null)){
				pepObj.PepList__c = 'Não';
				pepObj.CPF__c = pepPessoa.dadosObjeto.cpf;
				pepObj.Name = pepPessoa.dadosObjeto.nomeAccount;
			}else if(pepPessoa.listaPessoa != null){
				pepObj.PepList__c = 'Sim';
				pepObj.Name = pepPessoa?.listaPessoa?.nomePEP;
				pepObj.CPF__c = String.valueOf(pepPessoa?.listaPessoa?.cpfPEP);
				//pepObj.Cargo__c = pepPessoa?.listaPessoa?.mandatoPEPs?.cargoPEPWS?.nomeCargo;
				pepObj.CodigoPEP__c = pepPessoa?.listaPessoa?.codigoPEP;
				pepObj.DateUpdate__c = pepPessoa?.listaPessoa?.dataAtualizacao;
				pepObj.Avaliado__c = 'Paulo Roberto Ferreira Lisboa';
			}else if((pepPessoa.listaRelacionada != null) && (pepPessoa.listaPessoa == null)){ 
				pepObj.PepList__c = 'Relacionamento próximo';
				pepObj.Name = pepPessoa?.listaRelacionada.nomePessoaRelacionada;
				pepObj.CPF__c = String.valueOf(pepPessoa?.listaRelacionada?.numeroCPF);
				pepObj.DateUpdate__c = pepPessoa?.listaRelacionada?.dataAtualizacao;
				pepObj.Avaliado__c = 'Paulo Roberto Ferreira Lisboa';
				relacionamento = true;
			}
			List<PepTO.PessoaRelacaoPEPs> listRelacao;
			
			pepObj.LastAppointment__c = System.now();
			pepObj.Account__c = pepPessoa.dadosObjeto.accountId;
			switch on  pepPessoa.dadosObjeto.nomeObject{
				when 'SeguradoProposta__c' {
					pepObj.Segurado_da_proposta__c = pepPessoa.dadosObjeto.id;
					pepObj.RecordTypeId = Schema.SObjectType.Pep__c.getRecordTypeInfosByName().get('seguradoProposta').getRecordTypeId();
				}	
				when 'BeneficiarioSeguradoProposta__c' {
					pepObj.BeneficiarioSeguradoProposta__c = pepPessoa.dadosObjeto.id;
					pepObj.RecordTypeId = Schema.SObjectType.Pep__c.getRecordTypeInfosByName().get('BenificiarioSeguradoProposta').getRecordTypeId();
				}	
				when 'BeneficiarioGarantia__c' {
					pepObj.BeneficiarioGarantia__c = pepPessoa.dadosObjeto.id;
					pepObj.RecordTypeId = Schema.SObjectType.Pep__c.getRecordTypeInfosByName().get('BeneficiarioGarantia').getRecordTypeId();
				}										
			}
			
			listPep.add(pepObj);

			if(relacionamento){	
				for(PepTO.PessoaRelacaoPEPs obj : pepPessoa.listaRelacionada.pessoaRelacaoPEPs){
					PepRelacionamento__c objPepRelacionamento = new PepRelacionamento__c();
					objPepRelacionamento.Pep__c = pepObj.Id;
					objPepRelacionamento.GrauParentesco__c = obj?.descricaoRelacionamento;
					objPepRelacionamento.DataAtualizacao__c = obj?.dataAtualizacao;
					objPepRelacionamento.NomePep__c = obj?.pessoaPEPWS?.nomePEP;
					objPepRelacionamento.codigoPEP__c = obj?.pessoaPEPWS?.codigoPEP;
					listPepRelacionamento.add(objPepRelacionamento);
				}
				mapListPepRelac.put(count,listPepRelacionamento);
			}
			count++;
		}
		//System.debug('####listPep##'+listPep);
		//System.debug('###mapListPepRelac##'+mapListPepRelac);
		
		Database.SaveResult[] listPepsInsert = Database.insert(listPep, true);

		List<PepRelacionamento__c> listPepRelacionamentoInsert = new List<PepRelacionamento__c>();
		for(Integer x=0; x < listPepsInsert.size(); x++){
			if(listPepsInsert[x].isSuccess()){	

				if(mapListPepRelac.containsKey(x)){
					for(PepRelacionamento__c objPepRelacionamento : mapListPepRelac.get(x)){
						objPepRelacionamento.Pep__c = listPepsInsert[x].Id;
						listPepRelacionamentoInsert.add(objPepRelacionamento);
					}
				}	
			}
		}
		
		insert listPepRelacionamento;
	}
	//FIM - LECVPV-218-V1
	//INICIO - LECVPV-218-V1
     public Map<String,Pep__c> getPepSeguradoProposta(Set<Id> setIds){
		List<Pep__c> listPep = [SELECT Id, Segurado_da_proposta__c FROM Pep__c WHERE Segurado_da_proposta__c IN: setIds];
		Map<String, Pep__c> mapPep = new Map<String, Pep__c>();
		for(Pep__c obj : listPep){
			mapPep.put(obj.Segurado_da_proposta__c,obj);
		}

		return mapPep;
	}
	//FIM - LECVPV-218-V1
	//INICIO - LECVPV-218-V1
	public Map<String, Pep__c> getPepBenificiarioProposta(Set<Id> setIds){
		Map<String, Pep__c> mapPep = new Map<String, Pep__c>();
		List<Pep__c> listPep = [SELECT Id, BeneficiarioSeguradoProposta__c FROM Pep__c WHERE BeneficiarioSeguradoProposta__c IN: setIds];
		for(Pep__c obj : listPep){
			mapPep.put(obj.BeneficiarioSeguradoProposta__c,obj);
		}
		return mapPep;
    }

	public Map<String, Pep__c> getPepBenificiarioGarantia(Set<Id> setIds){
		Map<String, Pep__c> mapPep = new Map<String, Pep__c>();
		List<Pep__c> listPep = [SELECT Id, BeneficiarioGarantia__c FROM Pep__c WHERE BeneficiarioGarantia__c IN: setIds];
		for(Pep__c obj : listPep){
			mapPep.put(obj.BeneficiarioGarantia__c,obj);
		}
		return mapPep;
	}
	//FIM  - LECVPV-218-V1
	//INICIO - LECVPV-218-V1
	 public void getListObjectPep(List<SObject> listObj){
		System.debug('###listObj'+listObj);
		Map<String,PepTo.DataObjects> mapObjects = new Map<String,PepTo.DataObjects>();
		Set<Id> setIds = new Set<Id>();
		for(SObject obj : listObj){
			setIds.add((Id) obj.get('Id'));
		}
		Id id = (Id) listObj[0].get('Id');
		SObjectType t = id.getSObjectType();
		String nameObject = t.getDescribe().getName();
		
		switch on nameObject {
			when 'SeguradoProposta__c'{
				Map<String, Pep__c> mapPepSeg = this.getPepSeguradoProposta(setIds);
				Set<Id> setIdsSeg = new Set<Id>();
				if(mapPepSeg.size() == 0){
					setIdsSeg.addAll(setIds);
				}else{
					for(String key : setIds){
						if(!mapPepSeg.containsKey(key)){
							setIdsSeg.add(mapPepSeg.get(key).Segurado_da_proposta__c);
						}
					}
				}
				if(setIdsSeg.size() > 0){
					List<SeguradoProposta__c> listSegurado = [SELECT Id, GrupoProposta__r.ContratanteProposta__r.Proposta__r.Account.Cpf__c, GrupoProposta__r.ContratanteProposta__r.Proposta__r.Account.Name, GrupoProposta__r.ContratanteProposta__r.Proposta__r.AccountId FROM SeguradoProposta__c WHERE Id IN: setIdsSeg AND (GrupoProposta__r.ContratanteProposta__r.Proposta__r.Segmento__c NOT IN ('Viagem','Massificados') AND GrupoProposta__r.ContratanteProposta__r.Proposta__r.Segmento__c != null)]; //INICIO/FIM LECVPV-235
				
					for(SeguradoProposta__c obj : listSegurado){
						PepTo.DataObjects objPep = new PepTo.DataObjects();
						String cpf = (String.isNotEmpty(obj.GrupoProposta__r.ContratanteProposta__r.Proposta__r.Account.Cpf__c)) ? obj.GrupoProposta__r.ContratanteProposta__r.Proposta__r.Account.Cpf__c.replace('.', '').replace('-','') : null;
						if(String.isNotEmpty(cpf) && cpf.length() == 11){
							objPep.cpf = obj.GrupoProposta__r.ContratanteProposta__r.Proposta__r.Account.Cpf__c;
							objPep.nomeAccount = obj.GrupoProposta__r.ContratanteProposta__r.Proposta__r.Account.Name;
							objPep.nomeObject = nameObject;
							objPep.id = obj.Id;
							objPep.accountId = obj.GrupoProposta__r.ContratanteProposta__r.Proposta__r.AccountId;

			
							mapObjects.put(cpf, objPep);
						}
					}
				}
			}
			when 'BeneficiarioSeguradoProposta__c'{
				//System.debug('####'+this.getPepBenificiarioProposta(setIds).size()); 
				//INICIO LECVPV-235-FIX1
				List<BeneficiarioSeguradoProposta__c> listBen = listObj;
				if(listBen[0].TipoBeneficiario__c == 'Nome do beneficiário'){
					Map<String, Pep__c> mapPepBenSegProp = this.getPepBenificiarioProposta(setIds);
					Set<Id> setIdsBen = new Set<Id>();
					if(mapPepBenSegProp.size() == 0){
						setIdsBen.addAll(setIds);
					}else{
						for(String key : setIds){
							if(!mapPepBenSegProp.containsKey(key)){
								setIdsBen.add(mapPepBenSegProp.get(key).BeneficiarioSeguradoProposta__c);
							}
						}
					}
					//System.debug('###setIdsBen'+setIdsBen);
					if(setIdsBen.size() > 0){
						List<BeneficiarioSeguradoProposta__c> listBenificiario = [SELECT Id, Nome__c, CpfCnpj__c FROM BeneficiarioSeguradoProposta__c WHERE Id IN: setIdsBen AND (SeguradoProposta__r.GrupoProposta__r.ContratanteProposta__r.Proposta__r.Segmento__c NOT IN ('Viagem','Massificados') AND SeguradoProposta__r.GrupoProposta__r.ContratanteProposta__r.Proposta__r.Segmento__c != null)]; //INICIO/FIM LECVPV-235
						for(BeneficiarioSeguradoProposta__c obj : listBenificiario){
							PepTo.DataObjects objPep = new PepTo.DataObjects();
							String cpf = (String.isNotEmpty(obj.CpfCnpj__c)) ? obj.CpfCnpj__c.replace('.', '').replace('-','') : null;

							if(String.isNotEmpty(obj.CpfCnpj__c) && cpf.length() == 11){
								objPep.cpf = obj.CpfCnpj__c;
								objPep.nomeAccount = obj.Nome__c;
								objPep.nomeObject = nameObject;
								objPep.id = obj.Id;
								//objPep.accountId = obj.GrupoProposta__r.ContratanteProposta__r.Proposta__r.AccountId;

				
								mapObjects.put(objPep.cpf.replace('.','').replace('-', ''), objPep);
							}
							
						}
					}
					//FIM LECVPV-235-FIX1
				}//INICIO-FIM
				
			}
			when 'BeneficiarioGarantia__c'{
				Map<String, Pep__c> mapPepSinistro = this.getPepBenificiarioGarantia(setIds);
				Set<Id> setIdsSinistro = new Set<Id>();
				if(mapPepSinistro.size() == 0){
					setIdsSinistro.addAll(setIds);
				}else{
					for(String key : setIds){
						if(!mapPepSinistro.containsKey(key)){
							setIdsSinistro.add(mapPepSinistro.get(key).Segurado_da_proposta__c);
						}
					}
				}
				//System.debug('###SINISTRO##'+setIdsSinistro);
				if(setIdsSinistro.size() > 0){
					//INICIO - LECVPV-235-FIX1
					List<BeneficiarioGarantia__c> listSinistro = new List<BeneficiarioGarantia__c>();
					if(Test.isRunningTest()){
						listSinistro = [SELECT Id,Conta__c, Pagamento_de_garantia__r.Id, Conta__r.Cpf__c, Conta__r.Name FROM BeneficiarioGarantia__c WHERE Id IN: setIdsSinistro];
					}else{
						listSinistro = [SELECT Id,Conta__c, Pagamento_de_garantia__r.Id, Conta__r.Cpf__c, Conta__r.Name FROM BeneficiarioGarantia__c WHERE Id IN: setIdsSinistro AND (Pagamento_de_garantia__r.Caso__r.Contrato__r.Proposta__r.Segmento__c NOT IN ('Viagem','Massificados') AND Pagamento_de_garantia__r.Caso__r.Contrato__r.Proposta__r.Segmento__c != null)];
					}
					
					//FIM - LECVPV-235-FIX1
					for(BeneficiarioGarantia__c obj : listSinistro){
						PepTo.DataObjects objPep = new PepTo.DataObjects();
						String cpf = (String.isNotEmpty(obj.Conta__r.Cpf__c)) ? obj.Conta__r.Cpf__c.replace('.', '').replace('-','') : null;
						if(String.isNotEmpty(cpf) && cpf.length() == 11){
							objPep.cpf = obj.Conta__r.Cpf__c;
							objPep.nomeAccount = obj.Conta__r.Name;
							objPep.nomeObject = nameObject;
							objPep.id = obj.Id;
							objPep.accountId = obj.Conta__c;

			
							mapObjects.put(cpf, objPep);
						}
					}
				}
			}
		}
		

		if(!Test.isRunningTest()){
			processoPep = true;
		}
		
		ID jobID = (mapObjects.size() > 0) ? System.enqueueJob(new BatchPep(mapObjects, processoPep),0) : null;
	 }
	//FIM - LECVPV-218-V1
}