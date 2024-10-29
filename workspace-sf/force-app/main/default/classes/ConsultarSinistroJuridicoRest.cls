/*******************************************************************************************************************************
* 
* @author Pedro Augusto - SYS4B
* @date 13/07/2020
* @modifiedAt 25/09/2020
* Classe criada por conta da história PLV-4046
* Serviço para consultar sinistros Jurídicos
******************************************************************************************************************************/
@RestResource(urlMapping='/sinistro/consultarjuridico')
global with sharing class ConsultarSinistroJuridicoRest {

	@HttpPost
	global static void processarPost() {
		System.debug('processarPost');
		RestRequest req = RestContext.request;
		RestResponse response = RestContext.response;
		Response responseToSend = new Response();
		String payload = req.requestBody.toString();
		
		System.debug('payload '+payload);
		
		try {
			SinistroJuridicoBO.Request payloadRequest = (SinistroJuridicoBO.Request) JSON.deserialize(payload, SinistroJuridicoBO.Request.class);
			responseToSend = consultarSinistros(payloadRequest);
			System.debug('responseToSend'+JSON.serialize(responseToSend));	
		} catch (Exception e) {
			responseToSend.setError('Inconsistências no payload de requisição: '+e.getCause() +' : '+e.getStackTraceString());
		}
		
		response.responseBody = Blob.valueOf(JSON.serialize(responseToSend,true));
		response.addHeader('Content-Type', 'application/json');
	}

	global static Response consultarSinistros(SinistroJuridicoBO.Request sinistro){
		System.debug('ConsultarSinistro');
		
		//Fixar empresa
		sinistro.empresa = sinistro.empresa == null || String.isBlank(sinistro.empresa) ? '' : sinistro.empresa; // LECVPV-141 INICIO/FIM
		Response retorno = new Response();
		
        String msg = sinistro.validar('ConsultarSinistro'); 
        System.debug('msg'+msg);
		if(String.isNotBlank(msg)) return retorno.setError(msg);

		retorno.fillData(sinistro);

		System.debug('responsebody :::> '+JSON.serialize(retorno));

		System.debug('consultarSinistros - FIM');
		return retorno;
	}

	global class Response {

		public Integer resultado {get;set;}
		public String mensagem {get;set;}
		public List<SinistroJuridicoBO.SinistroTO> sinistros {get;set;} // LECVPV-141 INICIO/FIM

		//Somente retorna se encontrar informação
		// LECVPV-141 INICIO
		// public  List<SinistroJuridicoBO.SeguradoTO> Segurado {get;set;}
		// public  List<SinistroJuridicoBO.SinistroTO> Sinistro {get;set;}
		// public  List<SinistroJuridicoBO.ApoliceTO> Apolice {get;set;}
		// public  List<SinistroJuridicoBO.CoberturaTO> Cobertura {get;set;}
		// public  SinistroJuridicoBO.TerceiroTO TerceiroCausador {get;set;}//Não obrigatório
		// public  SinistroJuridicoBO.VistoriaTO Vistoria {get;set;}//Não obrigatório
		// LECVPV-141 FIM
		

		public Response(){
			this.resultado = 1;
			this.mensagem = '';
			this.sinistros = new List<SinistroJuridicoBO.SinistroTO>(); // LECVPV-141 INICIO/FIM
		}
		
		public Response setError(String mensagem){
			this.resultado = 1;
			this.mensagem = mensagem;
			// LECVPV-141 INICIO
			this.sinistros = null;
			// this.Segurado = null;
			// this.Sinistro = null;
			// this.Apolice = null;
			// this.Cobertura = null;
			// this.TerceiroCausador = null;
			// this.Vistoria = null;
			// LECVPV-141 FIM
			return this;
		}
		public void setSucesso(){
			this.resultado = 0;
			this.mensagem = '';
		}

		public Response fillData(SinistroJuridicoBO.Request request){

			//Exemplo: 1.1369.2020.500092
			//Empresa ramo ano numero
			System.debug('fillData');
			String NumeroSinistro = request.empresa+'.'+request.ramo+'.'+request.ano+'.'+request.numero;
			System.debug('NumeroSinistro: '+NumeroSinistro);
			List<Case> lCase = [SELECT Id
									, NumeroApoliceFormula__c
									, Contrato__c

									//SEGURADO
									, Segurado_do_contrato__r.Conta__r.Name
									, Segurado_do_contrato__r.Conta__r.CPF__c

									//EMPRESA
									, Contrato__r.Empresa__c //LECVPV-141 INICIO/FIM

									//APOLICETO
									, Contrato__r.Sucursal__c
									, Contrato__r.CodigoRamo__c
									, Contrato__r.CodigoModalidade__c
									, Contrato__r.NumeroApolice__c
									, Contrato__r.Endosso__c
									, Contrato__r.TipoEndosso__c
									, Contrato__r.StartDate
									, Contrato__r.VigenciaFinal__c
									, Contrato__r.EndDate
									, Contrato__r.CodigoCorretor__c
									, Contrato__r.CodigoCorretor__r.NomeCorretor__r.Name
									, Contrato__r.CodigoCorretor__r.NomeCorretor__r.Phone
									, Contrato__r.CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c
									, Contrato__r.RamoSeguro__r.GrupoRamoSinistro__c

									//SinistroTO
									, RamoSplit__c
									, NumeroSinistro__c
									, NumeroSinistroSplit__c
									, AnoSinistroSplit__c
									, Contrato__r.ModalidadeSeguro__r.RamoSeguro__c
									//, Contrato__r.CodigoModalidade__c
									, Dataocorrencia__c // LECVPV-237 - INICIO/FIM
									, Status
									, EmpresaSplit__c // LECVPV-141 INICIO/FIM

							FROM Case
							WHERE NumeroSinistro__c LIKE: '%' + NumeroSinistro]; //LECVPV-141 INICIO/FIM
			
			System.debug('lCase: '+lCase);

			
			Set<Id> setIdContracts = new Set<Id>();
			Map<Id,Contract> mapCasexContract = new Map<Id,Contract>();
			if(!lCase.isEmpty())
			for(Case forCase : lCase){
				setIdContracts.add(forCase.Contrato__c);
				mapCasexContract.put(forCase.Id,forCase.Contrato__r);
			}
			System.debug('setIdContracts: '+setIdContracts);
			System.debug('mapCasexContract: '+mapCasexContract);

			List<PagamentoGarantia__c> listGarantiaSinistro = new List<PagamentoGarantia__c>();
			if(!lCase.isEmpty())
			listGarantiaSinistro = [SELECT Id
												, caso__c
												, Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c
												, Garantia_do_segurado_do_contrato__r.Garantia__r.Name   // LECVPV-201 INICIO/FIM
												, Garantia_do_segurado_do_contrato__r.Valor__c
												 FROM PagamentoGarantia__c
												 WHERE Caso__c in:mapCasexContract.keyset()];
												 
			System.debug('listGarantiaSinistro: '+listGarantiaSinistro);
			
			Map<Id,List<PagamentoGarantia__c>> mapSinistroGarantia  = new Map<Id,List<PagamentoGarantia__c>>();
			if(!listGarantiaSinistro.isEmpty())
			for(PagamentoGarantia__c garantia : listGarantiaSinistro){
				if(!mapSinistroGarantia.keySet().contains(garantia.Caso__c)){
					mapSinistroGarantia.put(garantia.Caso__c, new List<PagamentoGarantia__c> {garantia});
				}else{
					mapSinistroGarantia.get(garantia.Caso__c).add(garantia);
				}
			}
			System.debug('mapSinistroGarantia: '+mapSinistroGarantia);

			
			//APÓS O MAPEAMENTO, VAMOS NESSA PESSOAL!!! MONTAR O ABENÇOADO
			
			if(lCase.isEmpty()){
				return this.setError('Sinistro não localizado');
			}else if(listGarantiaSinistro.isEmpty()){
				return this.setError('Garantias não localizadas');
			}

			//LECVPV-141 INICIO
			try {
                this.setSucesso();

			//	this.Segurados = new List<SinistroJuridicoBO.SeguradoTO>();
					
			//	this.Sinistros = new List<SinistroJuridicoBO.SinistroTO>();
				
			//	this.Apolices = new List<SinistroJuridicoBO.ApoliceTO>();
				
			//	this.Coberturas = new List<SinistroJuridicoBO.CoberturaTO>();

			// this.Segurado = new List<SinistroJuridicoBO.SeguradoTO>();
			// this.Sinistro = new List<SinistroJuridicoBO.SinistroTO>();
			// this.Apolice = new List<SinistroJuridicoBO.ApoliceTO>();
			this.sinistros =  new List<SinistroJuridicoBO.SinistroTO>();
				for(Case caso : lCase){
					//SinistroJuridicoBO.SinistroTO payloadSinistro = new SinistroJuridicoBO.SinistroTO();
					SinistroJuridicoBO.SinistroTO payloadSinistro = new SinistroJuridicoBO.SinistroTO(caso);
					payloadSinistro.segurado = new SinistroJuridicoBO.SeguradoTO(caso);
					payloadSinistro.apolice = new SinistroJuridicoBO.ApoliceTO(caso);
					payloadSinistro.coberturas = new List<SinistroJuridicoBO.CoberturaTO>();
					for(PagamentoGarantia__c pg : mapSinistroGarantia.get(caso.Id)){
						payloadSinistro.coberturas.add(new SinistroJuridicoBO.CoberturaTO(pg));
					}
					this.sinistros.add(payloadSinistro);
				}
				
				// this.Segurados = new SinistroJuridicoBO.SeguradoTO().dtoSegurado(lCase);
					
				// this.Sinistros = new SinistroJuridicoBO.SinistroTO().dtoSinistro(lCase);
				
				// this.Apolices = new SinistroJuridicoBO.ApoliceTO().dtoApolice(lCase);
				
				// this.Coberturas = new List<SinistroJuridicoBO.CoberturaTO>(); //LECVPV-141 INICIO/FIM
				// for(Case caso : lCase){
				// 	for(PagamentoGarantia__c pg : mapSinistroGarantia.get(caso.Id)){
				// 		this.Coberturas.add(new SinistroJuridicoBO.CoberturaTO(pg);
				// 	}
				// }

				System.debug('MAPEAMENTO FINALIZADO');
				
			} catch (Exception e ) {
				return this.setError('Erro no mapeamento de dados: ' + e.getLineNumber() + ' - '+e.getMessage());
			}

			System.debug('Response MONTADO');
			return this;
			//LECVPV-141 FIM
		}
	}


	
}