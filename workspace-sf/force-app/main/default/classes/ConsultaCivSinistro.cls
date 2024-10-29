//PLV-4096 - Inicio
public class ConsultaCivSinistro  {
	//MGRC-1657 - INICIO
	// @Future(callout = true) //PLV-4826 - Inicio/Fim
    // public static void ConsultaCivSinistroTicketBCPIntegracao(Set<Id> listIds){        
    //     System.debug('ConsultaCivSinistroIntegracao ******************* ');
	// 	System.debug('ConsultaCivSinistroIntegracao.listIds = '+ listIds);

	// 	//4096
    //     List<Case> listSinistros = [select Id, Contrato__r.Empresa__c, Contrato__r.RamoSeguro__r.Codigo__c, SinistroBeneficioAvisado__c, Nome_Segurado__c, Cpf_Segurado__c, Dataocorrencia__c, Subject, Description, Numero_titulo__c,
	// 	Vitima__c, IdPrestadora__c, TipoEvento__c, EmpresaSplit__c, sucursal__c, RamoSplit__c, Numero_Apolice__c, SinistroPrioritario__c from Case where Id =: listIds];                                                                
        
    //     Case casoObj = listSinistros[0];
	// 	String token = '';
            
	// 	if(!test.isRunningTest())
	// 		token = getTokenCIV();
            
	// 		String nomeServico = 'Consulta_Civ_Ticket_BCP';
            
    //         Http http = new Http();
    //         HttpRequest request = new HttpRequest();
            
    //         request.setEndpoint(gerarEndpoint(nomeServico));
    //         request.setMethod('POST');
    //         request.setHeader('Authorization', 'Bearer '+token);
    //         request.setHeader('Content-Type', 'application/json');                        						
			
	// 		CivSinistroTO.Request objCasoSinistro = new CivSinistroTO.Request();
			
	// 		objCasoSinistro.nomeSegurado = casoObj.Nome_Segurado__c;
	// 		//PLV-4096 - inicio fix
	// 		if(casoObj.Cpf_Segurado__c != null && casoObj.Cpf_Segurado__c != ''){
	// 			objCasoSinistro.cpfSegurado = casoObj.Cpf_Segurado__c.substring(0, 11);
	// 			objCasoSinistro.digitoCpfSegurado = casoObj.Cpf_Segurado__c.substring(12, 14); //Digito CPF
	// 		}
	// 		//PLV-4096 - fim fix						
	// 		objCasoSinistro.dataOcorrencia = String.valueOf(casoObj.Dataocorrencia__c);
	// 		objCasoSinistro.assunto = casoObj.Subject;
	// 		objCasoSinistro.descricao = casoObj.Description;			
	// 		objCasoSinistro.origem = 'SFDC';
	// 		objCasoSinistro.prestadora = casoObj.Numero_titulo__c;
	// 		objCasoSinistro.vitima = casoObj.Vitima__c;
	// 		objCasoSinistro.idAtendimentoPrestadora = casoObj.IdPrestadora__c;
	// 		objCasoSinistro.caseId = casoObj.Id;
	// 		objCasoSinistro.tipoEvento = casoObj.TipoEvento__c;
	// 		objCasoSinistro.avisado = 'true';
	// 		//objCasoSinistro.empresa = String.valueOf(Integer.valueOf(casoObj.EmpresaSplit__c));
	// 		//PLV-4096 - inicio fix-1
	// 		objCasoSinistro.empresa = casoObj.Contrato__r.Empresa__c;
	// 		//PLV-4096 - fim fix-1
	// 		objCasoSinistro.sucursal = casoObj.sucursal__c;
	// 		//objCasoSinistro.ramo = String.valueOf(Integer.valueOf(casoObj.RamoSplit__c));
	// 		//PLV-4096 - inicio fix-1
	// 		objCasoSinistro.ramo = casoObj.Contrato__r.RamoSeguro__r.Codigo__c;
	// 		//PLV-4096 - fim fix-1
	// 		objCasoSinistro.apolice = casoObj.Numero_Apolice__c;
	// 		//PLV-4096 - inicio fix
	// 		if(casoObj.Numero_Apolice__c != null && casoObj.Numero_Apolice__c != ''){
	// 			objCasoSinistro.endosso = objCasoSinistro.apolice.substring(10, 11); //Digito da apolice
	// 		}
	// 		//PLV-4096 - fim fix
	// 		objCasoSinistro.sinistroPrioritario = casoObj.SinistroPrioritario__c;
	// 		objCasoSinistro.edsTip = '2';
						
	// 		List<PagamentoGarantia__c> listaPG = [select Id, Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c, CurrencyIsoCode, Valor_indenizado__c from PagamentoGarantia__c where  Caso__c =: casoObj.Id];
			
	// 		List<CivSinistroTO.GarantiaSinistroTO> listGarantiasTO = new List<CivSinistroTO.GarantiaSinistroTO>();
												
	// 		for(PagamentoGarantia__c pg : listaPG){
	// 			CivSinistroTO.GarantiaSinistroTO garantiaTO = new CivSinistroTO.GarantiaSinistroTO();
	// 			garantiaTO.sigla = pg.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c;
	// 			garantiaTO.valorIndenizado = pg.Valor_indenizado__c;
	// 			garantiaTO.moedaIndenizacao = pg.CurrencyIsoCode;
				
	// 			listGarantiasTO.add(garantiaTO);
	// 		}									

	// 		objCasoSinistro.garantias = listGarantiasTO;
	// 		CivSinistroTO.Sinistro sinistroObj = new CivSinistroTO.Sinistro();

	// 		sinistroObj.Sinistro = objCasoSinistro;
			
	// 		//Sinistro jsSinistro = new Sinistro();
	// 		//jsSinistro.Sinistro	 = 	objCasoSinistro;												
			            
    //         request.setBody(System.JSON.serialize(sinistroObj));
                        
    //         System.debug('ConsultaCivSinistroIntegracao.Sinistro = ' + System.JSON.serialize(sinistroObj));
            
    //         HttpResponse response = http.send(request);
            
    //         if( response.getStatusCode() == 200 ){
                
    //             System.debug('Ok');
    //             System.debug(response.getBody());
    //             String response2 = response.getBody();
                
	// 			System.debug('retorno1 = ' + response2);
	// 			System.debug('retorno 2= ' + (CivSinistroTO.Response) System.JSON.deserialize(response2, CivSinistroTO.Response.class));
	// 			CivSinistroTO.Response retorno = (CivSinistroTO.Response) System.JSON.deserialize(response2, CivSinistroTO.Response.class);
                
    //             System.debug('Ticket BCP ==> ' + retorno.data.sinistro);
	// 			casoObj.Ticket_BCP__c = retorno.data.sinistro.idTicketBCP;
	// 			casoObj.NumeroSinistro__c = retorno.data.sinistro.numeroSinistro;
	// 			casoObj.SinistroBeneficioAvisado__c = true;
	// 			//PLV-4096 - inicio fix-1
	// 			casoObj.EmpresaSplit__c = Decimal.valueOf(retorno.data.sinistro.empresa);
	// 			casoObj.RamoSplit__c = Decimal.valueOf(retorno.data.sinistro.ramo);
	// 			//PLV-4096 - fim fix-1
	// 			update casoObj;
    //             //Setar dados de retorno no objeto
                
    //             //System.debug('retorno = '+ retorno);                                 
                
    //         }else{
    //             System.debug('Erro');
    //             System.debug('Erro serviço = ' + response.getBody());               
				
    //             String response2 = response.getBody();
    //             //JsonCIVConsultaMoeda retorno = JsonCIVConsultaMoeda.parseErro(response2);
    //             erroRetorno erroRetornoObj = (erroRetorno) System.JSON.deserialize(response2, erroRetorno.class);
    //             System.debug('erroRetornoObj = ' + erroRetornoObj);
	// 			System.debug('erroRetornoObj.mensagem = ' + erroRetornoObj.mensagem);
				
    //         }
        		        		
        
    // }
	//MGRC-1657 - FIM

	public static String getTokenCIV(){
        System.debug('ConsultaCivSinistro.getTokenCIV ******************* ');
        String token;
        
        // Buscar a credencial oauth2 do Auth0
        CredencialOAuth2__mdt credencialOAuth2 = 
            [SELECT Id, ClientId__c, ClientSecret__c, 
             GrantType__c, Audience__c, Status__c 
             FROM CredencialOAuth2__mdt 
             WHERE DeveloperName = 'CIV'
            ];
        
        if (!credencialOAuth2.Status__c) {
            return '';
        }
        String nomeServico = 'GerarTokenCIV';	
        system.debug('token: '+ credencialOAuth2);
        
        String client_Id = credencialOAuth2.ClientId__c;
        String client_secret = credencialOAuth2.ClientSecret__c;
        String grant_type = credencialOAuth2.GrantType__c;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(gerarEndpoint(nomeServico));
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String payload = 'client_id='+EncodingUtil.urlEncode(client_id,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(client_secret,'UTF-8')+'&grant_type='+grant_type;
        
        System.debug('payload = ' + payload);    
        request.setBody(payload);
        
        System.debug('request = ' + request);
        
        HttpResponse response = http.send(request);
        
        if( response.getStatusCode() == 200 ){
            
            System.debug('Ok');
            
            String response2 = response.getBody();
            system.debug(response.getBody());
            jsonTokenConsultaMoeda retorno = jsonTokenConsultaMoeda.parse(response2);
            
            token = retorno.access_token;
            
        }else{
            System.debug('Erro');
        }               
        
        system.debug('token: '+token);
        return token;
    }

	public static String gerarEndpoint(String nomeServico) {
        Servico__mdt servico =  buscarMetadadoServico(nomeServico);
        String endpoint =  String.isNotBlank(servico.Endpoint__c) ? servico.Endpoint__c : '';
        return Test.isRunningTest() ? 'http://testes.portoseguro.com.br/fake-endpoint' : 'callout:' + servico.NomeCredencial__c + endpoint;
    }

	public static Servico__mdt buscarMetadadoServico(String nomeServico) {
        system.debug('Nome '+nomeServico);
        return MetadataDAO.getInstance().buscarServico(nomeServico);
    }

	public class erroRetorno{
        public Integer codigo;
		public String mensagem;
		public String dataOcorrencia;
		public String fonte;
		public String tipo;
		public String additionalInfo;                
    }

	public class Sinistro{
		public CivSinistroTO.Request Sinistro;			    
    }

}
//PLV-4096 - Fim