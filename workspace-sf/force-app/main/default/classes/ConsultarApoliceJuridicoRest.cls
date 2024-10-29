/*******************************************************************************************************************************
* 
* @author Pedro Augusto - SYS4B
* @date 22/09/2020
* @modifiedAt 25/09/2020
* Classe criada por conta da história PLV-4046
* Serviço para consultar sinistros por Apolice
******************************************************************************************************************************/
@RestResource(urlMapping='/sinistro/consultarapolice')
global with sharing class ConsultarApoliceJuridicoRest {
    global ConsultarApoliceJuridicoRest() {

    }

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
			responseToSend = consultarApolice(payloadRequest);
			System.debug('responseToSend'+JSON.serialize(responseToSend));	
		} catch (Exception e) {
			responseToSend.setError('Inconsistências no payload de requisição: '+e.getCause() +' : '+e.getStackTraceString());
		}
		
		response.responseBody = Blob.valueOf(JSON.serialize(responseToSend));
		response.addHeader('Content-Type', 'application/json');
    }


    global static Response consultarApolice(SinistroJuridicoBO.Request sinistro){
		System.debug('ConsultarApolice');
		
		//Fixar empresa
		sinistro.empresa = String.isBlank(sinistro.empresa) ? '1' : sinistro.empresa;
		Response retorno = new Response();
		
        String msg = sinistro.validar('ConsultarApolice'); 
        System.debug('msg'+msg);
		if(String.isNotBlank(msg)) return retorno.setError(msg);

		retorno.fillData(sinistro);

		System.debug('responsebody :::> '+JSON.serialize(retorno));

		System.debug('ConsultarApolice - FIM');
		return retorno;
	}

    global class Response {

		public Integer resultado {get;set;}
		public String mensagem {get;set;}
        public List<SinistroJuridicoBO.ApoliceTO> apolices {get;set;} 
		

		public Response(){
			this.resultado = 1;
			this.mensagem = '';
		}
		
		public Response setError(String mensagem){
			this.resultado = 1;
			this.mensagem = mensagem;
			this.apolices = null;
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
			Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

            Map<Id,Contract> contratos = new Map<Id, Contract>([SELECT Id
                                                , Sucursal__c
                                                , CodigoRamo__c
                                                , CodigoModalidade__c
                                                , NumeroApolice__c
                                                , Endosso__c
                                                , TipoEndosso__c
                                                , StartDate
                                                , VigenciaFinal__c
                                                , EndDate
                                                , CodigoCorretor__c
                                                , CodigoCorretor__r.NomeCorretor__r.Name
                                                , CodigoCorretor__r.NomeCorretor__r.Phone
                                                , CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c
                                                , RamoSeguro__r.GrupoRamoSinistro__c
                                                FROM Contract
                                                WHERE Sucursal__c =: String.valueOf(request.sucursal)
                                                    AND NumeroApoliceFiltro__c =:request.apolice
                                                    AND CodigoRamo__c =:request.ramo]);
			
			System.debug('contratos: ' + JSON.serialize(contratos.keyset()));
			
			if(contratos.isEmpty()){return this.setError('Apólice não localizada');}
			
			List<Case> lCase = [SELECT Id
									, NumeroApoliceFormula__c
									, Contrato__c

									//SEGURADO
									, Segurado_do_contrato__r.Conta__r.Name
									, Segurado_do_contrato__r.Conta__r.CPF__c

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
									, Dataocorrencia__c // LECVPV-237 - INICIO/FIM
									, Status
									, EmpresaSplit__c // LECVPV-141 INICIO/FIM

							FROM Case
							WHERE Contrato__c IN:contratos.keySet()
							AND RecordtypeId=:REC_ID_SINISTRO.Id
							AND NumeroSinistro__c<>''];
			
			System.debug('lCase: '+lCase);
			System.debug('lCase: ' + lCase.size());

			
			Set<Id> setCaseId = (new Map<Id, Case>(lCase)).keySet();
			

			List<PagamentoGarantia__c> listGarantiaSinistro = new List<PagamentoGarantia__c>();
			if(!setCaseId.isEmpty()){
			listGarantiaSinistro = [SELECT Id
												, caso__c
												, Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c
												, Garantia_do_segurado_do_contrato__r.Garantia__r.Name // LECVPV-201 INICIO/FIM
												, Garantia_do_segurado_do_contrato__r.Valor__c
												 FROM PagamentoGarantia__c
                                                 WHERE Caso__c in:setCaseId];
            }
												 
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


			try {
                this.setSucesso();
                this.apolices = new List<SinistroJuridicoBO.ApoliceTO>();
                Map<Id, SinistroJuridicoBO.ApoliceTO> apolicesByContract = new Map<Id,SinistroJuridicoBO.ApoliceTO>();

                for (Contract contrato : contratos.values()) {
                    apolicesByContract.put(contrato.Id, new SinistroJuridicoBO.ApoliceTO(contrato)); // LECVPV-141 INICIO/FIM
                }

                System.debug('apolicesByContract: ' + apolicesByContract);
				System.debug('lCase: ' + lCase.size());
                for(Case caso : lCase){

                    if (apolicesByContract.containsKey(caso.Contrato__c)) {
                        //SinistroJuridicoBO.ApoliceTO apoliceToMap = apolicesByContract.get(caso.Contrato__c);

                        SinistroJuridicoBO.SinistroTO Sinistro = new SinistroJuridicoBO.SinistroTO(caso); // LECVPV-141 INICIO/FIM
                        Sinistro.Coberturas = new List<SinistroJuridicoBO.CoberturaTO>();
						
						if(mapSinistroGarantia.containskey(caso.Id)){
							for(PagamentoGarantia__c pg : mapSinistroGarantia.get(caso.Id)){
								Sinistro.Coberturas.add(new SinistroJuridicoBO.CoberturaTO(pg));  // LECVPV-141 INICIO/FIM
							}
						}

                        if (apolicesByContract.get(caso.Contrato__c).sinistros == null) apolicesByContract.get(caso.Contrato__c).sinistros = new List<SinistroJuridicoBO.SinistroTO>();
                        apolicesByContract.get(caso.Contrato__c).sinistros.add(Sinistro);
                    }
                    
                }
                
                //if (apolicesByContract != null && apolicesByContract.values().size() > 0) {
                    this.apolices = apolicesByContract.values();
                //}
			
                System.debug('apolices : ' + this.apolices);
				System.debug('MAPEAMENTO FINALIZADO');

			} catch (Exception e ) {
                System.debug('fillData : Exception => ' + e.getStackTraceString());
				return this.setError('Erro no mapeamento de dados: ' + e.getLineNumber() + ' - '+e.getMessage());
			}

			System.debug('Response MONTADO');
			return this;

		}
	}
}