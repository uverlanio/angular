/**
 * Serviços da Porto F5
 **/

public class F5Service extends ServiceBase {
	private static final F5Service instance = new F5Service();
	 
	//PLV-4435 INICIO 
	public static String mockRetornoConsultaCep = '{"obterEnderecoPorCEPResponse":{"enderecosGuiaPostalEBO":{"enderecoGuiaPostalEBO":{"codigoLogradouro":"8657","codigoFoneticoEspecial":"OK","primeiroCodigoFoneticoEspecial":"dSn&#124;}aKPc&#124;}aEAz","segundoCodigoFoneticoEspecial":"dSnE!!!&#124;}aQ!!!!","terceiroCodigoFoneticoEspecial":"dSnE!!!EAz3!!!!","cepEspecial":"true","enderecoCompleto":{"tipoLogradouro":"AVENIDA","logradouro":"RIO BRANCO 1489","numeroLogradouro":"1489","cidade":"SAO PAULO","uf":"SP","bairro":"CAMPOS ELISEOS"}}}}}';
    //PLV-4435 FIM
    
	private F5Service() { }

	public static F5Service getInstance() {
		return instance;
	}

	/**
	 * Realiza consulta dos cartões de um cliente
	 */
	public ConsultaCartaoTO.ResponseTO consultarCartao(ConsultaCartaoTO.PostTO payload) {
		ConsultaCartaoTO.ResponseTO respostaTo;

		try {
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('ConsultaCartao'), 'POST', new Map<String, String>(), JSON.serialize(payload), 60000);
			
			if (resposta.getStatusCode() < 400) {
				respostaTo = (ConsultaCartaoTO.ResponseTO)JSON.deserialize(resposta.getBody(), ConsultaCartaoTO.ResponseTO.class);
			}
			else {
				throw new F5ServiceException('Erro ao consultar cartões. ' + 'HTTP Erro: ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new F5ServiceException('Erro ao consultar cartões. ' + e.getMessage());
		}

		return respostaTo; 
	}

	public List<ServiceTO.EmpresaSeguroTO> buscarEmpresasSeguro() {
		List<ServiceTO.EmpresaSeguroTO> tempList;

		try {
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('EmpresaSeguro'), 'GET', new Map<String, String>(), null, 60000);

			System.debug('::: resposta: ' + resposta);

			if(resposta.getStatusCode() < 400){
				ServiceTO.EmpresasSeguroListagemTO tempListagem = (ServiceTO.EmpresasSeguroListagemTO)JSON.deserialize(resposta.getBody(), ServiceTO.EmpresasSeguroListagemTO.class);
				tempList = tempListagem.LotusEmpresaSeguroDBOutput;

				System.debug('::: tempList: ' + tempList);
			}
			else {
				throw new F5ServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
			
		} catch(Exception ex) {
			System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
			throw new F5ServiceException('Erro ao buscar empresas de seguro. ' + ex.getLineNumber() + ': ' + ex.getMessage());
		}

		return tempList;
	}

	/**
	 * Retorna uma lista do serviço externo - Cidades por UF
	*/
	public ServiceTO.ObterCidadeUFTO buscarEnderecoPorUF(String UF) {

		String nomeEndpoint = 'ConsultaEnderecoUF';
		String mensagemErro = 'Erro ao buscar Endereço por UF.';

		ServiceTO.ObterCidadeUFTO tempList;

		String body = ServiceTO.bodySericeUF;
		body = body.replace('{{UF}}', UF);

		try {
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', new Map<String, String>(), body, 60000);
		
			if (resposta.getStatusCode() < 400) {
				//System.debug(JSON.serialize(resposta.getBody()));

				tempList = (ServiceTO.ObterCidadeUFTO)JSON.deserialize(resposta.getBody(), ServiceTO.ObterCidadeUFTO.class);
			}
			else {
				throw new F5ServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new F5ServiceException(mensagemErro);
		}

		return tempList;
	}

	/**
	 * Retorna uma lista do serviço externo - Endereco por CEP
	 */
	public ServiceTO.ObterCidadeCEPTO buscarEnderecoPorCEP(String cep, string sufixo) {

		String nomeEndpoint = 'ConsultaEnderecoCEP';
		String mensagemErro = 'Erro ao buscar Endereço por CEP.';

		ServiceTO.ObterCidadeCEPTO tempList;

		String body = ServiceTO.bodySericeCep;
		body = body.replace('{{CEP}}', cep);
		body = body.replace('{{SUFIXO}}', sufixo);

		try 
		{
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', new Map<String, String>(), body, 60000);
			if (resposta.getStatusCode() < 400) 
			{
				System.debug('resposta: ' + String.isEmpty(resposta.getBody()));

				if(!String.isEmpty(resposta.getBody()))
				{
					System.debug(JSON.serialize('JSON: ' + resposta.getBody()));
					tempList = (ServiceTO.ObterCidadeCEPTO)JSON.deserialize(resposta.getBody(), ServiceTO.ObterCidadeCEPTO.class);
				}
			}
			else
				throw new F5ServiceException('ERROR HTTP ' + resposta.getStatusCode());
		}
		catch (Exception e) {
			System.debug('ERRO:' + e.getMessage());
			throw new F5ServiceException(mensagemErro);
		}

		return tempList;
	}

	/**
	 * Retorna uma lista do serviço externo - Endereco por Logradouro
	 */
	public ServiceTO.ObterCidadeLogradouroTO buscarEnderecoPorLogradouro(String endereco, string cidade, string uf, string numero) {

		String nomeEndpoint = 'ConsultaEnderecoLogrdouro';
		String mensagemErro = 'Erro ao buscar Endereço por Logradouro.';

		ServiceTO.ObterCidadeLogradouroTO tempList;

		String body = ServiceTO.bodySericeLogradouro;
		body = body.replace('{{END}}', endereco);
		body = body.replace('{{CIDADE}}', cidade);
		body = body.replace('{{UF}}', uf);
		body = body.replace('{{NUMERO}}', numero);

		try {
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', new Map<String, String>(), body, 60000);
		
			if (resposta.getStatusCode() < 400) {
				System.debug(JSON.serialize(resposta.getBody()));

				tempList = (ServiceTO.ObterCidadeLogradouroTO)JSON.deserialize(resposta.getBody(), ServiceTO.ObterCidadeLogradouroTO.class);
			}
			else {
				throw new F5ServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new F5ServiceException(mensagemErro);
		}

		return tempList;
	}

	//Busca as formas de pagamento
	public List<ServiceTO.FormaPagamentoTO> buscarFormasPagamento(String codigoEmpresa, String codigoRamo, String vigencia){
		List<ServiceTO.FormaPagamentoTO> formasPagamento;

		try {
			HttpResponse resposta = Util.executarHttpRequest(
				this.gerarEndpoint('FormasPagamento')
				.replace('{{COD_EMPRESA}}', codigoEmpresa)
				.replace('{{COD_RAMO}}', codigoRamo)
				.replace('{{VIGENCIA}}', vigencia),
				'GET', 
				new Map<String, String>(),
				null,
				60000
			);

			if(resposta.getStatusCode() < 400){
				formasPagamento = (List<ServiceTO.FormaPagamentoTO>)JSON.deserialize(resposta.getBody(), List<ServiceTO.FormaPagamentoTO>.class);
			}
			else {
				throw new F5ServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
			
		} catch(Exception ex) {
			System.debug(ex.getMessage());
			throw new F5ServiceException('Erro ao buscar formas de pagamento: ' + ex.getMessage());
		}

		return formasPagamento;
	}

	/**
	 * Retorna uma lista do serviço externo
	 */
	public ServiceTO.ModalidadeTO buscarModalidades(String codigo) {
		ServiceTO.ModalidadeTO tempList;

		try {
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('Modalidade').replace('{{GRUPO}}', codigo), 'GET', new Map<String, String>(), null, 60000);
		
			if (resposta.getStatusCode() < 400) {
				tempList = (ServiceTO.ModalidadeTO)JSON.deserialize(resposta.getBody(), ServiceTO.ModalidadeTO.class);
			}
			else {
				throw new F5ServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new F5ServiceException('Erro ao buscar modalidade.');
		}

		return tempList;
	}

	//Busca municipios de uma UF
	public List<ServiceTO.MunicipioTO> buscarMunicipios(String uf){
		List<ServiceTO.MunicipioTO> municipios;

		try {
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('Municipio').replace('{{UF}}', uf), 'GET', new Map<String, String>(), null, 60000);

			if(resposta.getStatusCode() < 400){
				municipios = (List<ServiceTO.MunicipioTO>)JSON.deserialize(resposta.getBody(), List<ServiceTO.MunicipioTO>.class);
			}
			else {
				throw new F5ServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
			
		} catch(Exception ex) {
			System.debug(ex.getMessage());
			throw new F5ServiceException('Erro ao buscar municipios do estado ' + uf);
		}

		return municipios;
	}

	/**
	 * Retorna uma lista de profissões
	 */
	//PLV-4878 INICIO
	public ServiceTO.OcupacoesTO buscarProfissoes() {
		
		//PLV 4518 Inicio Fix 3
		ServiceTO.OcupacoesTO tempList = new ServiceTO.OcupacoesTO();
		Map<String,String> mapToken = getTokenOcupacaoGovernancia();

		if(mapToken.isEmpty()) return tempList;

		try {
			
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('OcupacaoGovernanca'), 'GET', mapToken , null, 60000);
			
			if (resposta.getStatusCode() < 400) {

				tempList = (ServiceTO.OcupacoesTO)JSON.deserialize(resposta.getBody(), ServiceTO.OcupacoesTO.class);

			}
			else {
				throw new F5ServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getLineNumber() + ', ' + e.getMessage());
			throw new F5ServiceException('Erro ao buscar profissões.');
		}

		return tempList;
		//PLV 4518 Fim Fix 3
	}
	//PLV-4878 FIM
	/**
	 * Retorna uma de ramos de atividade
	 */
	public ServiceTO.RamoAtividadeTO buscarRamosAtividade() {
		ServiceTO.RamoAtividadeTO tempList;

		try {
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('RamoAtividade'), 'GET', new Map<String, String>(), null, 60000);
		
			if (resposta.getStatusCode() < 400) {
				//system.debug('Service: ' + JSON.deserialize(resposta.getBody(), ServiceTO.RamoAtividadeTO.class));

				tempList = (ServiceTO.RamoAtividadeTO)JSON.deserialize(resposta.getBody(), ServiceTO.RamoAtividadeTO.class);
			}
			else {
				throw new F5ServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new F5ServiceException('Erro ao buscar ramos de atividade.');
		}

		return tempList;
	}

	/**
	 * Retorna uma lista de ramos de seguro
	 */
	public List<ServiceTO.RamoSeguroTO> buscarRamosSeguro() {
		List<ServiceTO.RamoSeguroTO> tempList = new List<ServiceTO.RamoSeguroTO>();

		try {
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('RamoSeguro'), 'GET', new Map<String, String>(), null, 60000);

			if (resposta.getStatusCode() < 400) {
				ServiceTO.RamosSeguroListagemTO tempListagem = (ServiceTO.RamosSeguroListagemTO)JSON.deserialize(resposta.getBody(), ServiceTO.RamosSeguroListagemTO.class);
				tempList = tempListagem.LotusRamosSeguroDBOutput;
			}
			else {
				throw new F5ServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new F5ServiceException('Erro ao buscar ramos de seguro.');
		}

		return tempList;
	}	

	//PLV-4656 - Inicio - Guilherme Brito
    public String consultaCEP(String jsonCep, String cepName) {

		string CEPlogradouro = '';
		string CEPcomplemento = '';
		String retorno = '';
		
		List<CtrPropostaSniper.RetornoEnderecoTO> listaEnderecoToReturn = new List<CtrPropostaSniper.RetornoEnderecoTO>(); // PLV-5812 INICO-FIM
		CtrPropostaSniper.RetornoEnderecoTO enderecoToReturn = new CtrPropostaSniper.RetornoEnderecoTO();
		enderecoToReturn.obterEnderecoPorCEPResponse = new CtrPropostaSniper.ObterEnderecoPorCEPResponseTO();
		enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO = new CtrPropostaSniper.EnderecosGuiaPostalEBOTO();
		enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO = new CtrPropostaSniper.EnderecoGuiaPostalEBOTO();
		enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto = new CtrPropostaSniper.EnderecoCompletoTO();

		String numsplit = jsonCep.trim().replaceAll('[^0-9]+', '');
		if(numsplit.length()!=8){
			enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.cepCidade = '';
			enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.cepComplementoCidade = '';
			return JSON.serialize(new CtrPropostaSniper.RetornoEnderecoTO());
		}
		
		CEPlogradouro = numsplit.left(5);
		CEPcomplemento = numsplit.right(3); 
		string retornoServico = SensediaServices.getInstance().consultarCEP(CEPlogradouro, CEPcomplemento); //ZSVEP-66 - INICIO / FIM
		
		if(String.isNotBlank(retornoServico)){
			ObjLogradouros jsonConvertido = (ObjLogradouros) System.JSON.deserialize(retornoServico, ObjLogradouros.class);
			System.debug('jsonConvertido >>>' + jsonConvertido);
			//Logradouros log = jsonConvertido.Logradouros == null ? null : jsonConvertido.Logradouros[0]; //PLV-4656 FIX
			List<Logradouros> logs = jsonConvertido.Logradouros == null ? null : jsonConvertido.Logradouros; // PLV-5812 INICO
			System.debug('karin');
			System.debug(logs);
			// PLV-5812 INICO
			if(logs!=null){
				for(Logradouros log : logs){
					enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto.logradouro = log.nomeLogradouro;
					// PLV-4945-INICIO
					enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto.bairro = log.bairro != null ?  log.bairro.nomeBairro : '';
					enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto.cidade = log.localidade != null ? log.localidade.nomeLocalidade : '';
					enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto.uf = log.localidade != null && log.localidade.estado != null ? log.localidade.estado.siglaEstado : '';
					// PLV-4945-FIM
					enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.cepCidade = CEPlogradouro;
					enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.cepComplementoCidade = CEPcomplemento;
					// ---
					enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.cepName = cepName;
					system.debug('Valor CEP Name após atribuição: ' + enderecoToReturn.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.cepName);

					listaEnderecoToReturn.add(enderecoToReturn);
				}
			}
			// PLV-5812 FIM
			system.debug('enderecoToReturn: ' + enderecoToReturn);
			system.debug('listaEnderecoToReturn: ' + listaEnderecoToReturn);
			retorno = JSON.serialize(listaEnderecoToReturn); // PLV-5812 INICO-FIM
			system.debug('retorno enderecoToReturn: ' + JSON.serialize(enderecoToReturn));
			system.debug('retorno: ' + retorno);
			//retorno = JSON.serialize(enderecoToReturn);
		}

		return retorno;

	}

	//PLV-4878 INICIO
	public static Map<String,String> getTokenOcupacaoGovernancia(){

        System.debug('F5Service.getTokenOcupacaoGovernancia*******************');
        
		Map<String,String> mapAutorizacaoToken = new Map <String,String>(); 
		String autorizacao;
        
        // Buscar a credencial oauth2 do Auth0
        CredencialOAuth2__mdt credencialOAuth2 = 
            [SELECT Id, ClientId__c, ClientSecret__c, 
             GrantType__c, Audience__c, Status__c 
             FROM CredencialOAuth2__mdt 
             WHERE DeveloperName = 'OcupacaoGovernanca'
            ];
        
        if (!credencialOAuth2.Status__c) {
            return mapAutorizacaoToken;
        }
        
		Servico__mdt servicoToken = 
		[SELECT Id, Endpoint__c, NomeCredencial__c
		 FROM Servico__mdt
		 WHERE DeveloperName = 'TokenGovernanca'
		];
	
        

		String endpoint = 'callout:' + servicoToken.NomeCredencial__c + servicoToken.Endpoint__c;
        String client_Id = credencialOAuth2.ClientId__c;
        String client_secret = credencialOAuth2.ClientSecret__c;
        String grant_type = credencialOAuth2.GrantType__c;
		String scope = 'dadosreferencia';

        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		request.setHeader('idp', '6');
		

        
        String payload = 'client_id='+EncodingUtil.urlEncode(client_id,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(client_secret,'UTF-8')+'&grant_type='+grant_type+
		'&username='+'klhplvns'+'&password='+'nb13ssqb'+'&scope='+EncodingUtil.urlEncode(scope,'UTF-8');
        
        System.debug('payload Token Ocupacao = ' + payload);    
        request.setBody(payload);


        System.debug('request = ' + request.getBody());
		
		
        
        HttpResponse response = http.send(request);
        
        if( response.getStatusCode() == 200 ){
            
            System.debug('Ok');
            
            String response2 = response.getBody();
            system.debug(response.getBody());
            jsonTokenConsultaMoeda retorno = jsonTokenConsultaMoeda.parse(response2);
			autorizacao = retorno.token_type + ' ' + retorno.access_token;
			mapAutorizacaoToken.put('Authorization', autorizacao);
        }else{
            System.debug('Erro');
        }               
        
        system.debug('map ocupação: '+mapAutorizacaoToken);
        return mapAutorizacaoToken;
    }
	//PLV-4878 FIM 

	public class ObjLogradouros{
		public Logradouros[] logradouros { get; set; }
	}
	
	public class Logradouros {
		public Integer codigoLogradouro { get; set; }	
		public String nomeLogradouro { get; set; }	
		public String nomeAbreviadoLogradouro { get; set; }
		public Integer numeroCepLogradouro { get; set; }	
		public Integer numeroCepComplementoLogradouro { get; set; }	
		public String textoComplementoLogradouro { get; set; }	 
		public Integer codigoLogradouroOrigemExterna { get; set; }	
		public tipoEnderecamentoPostal tipoEnderecamentoPostal { get; set; }
		public tipoLogradouro tipoLogradouro { get; set; }
		public bairro bairro { get; set; }
		public localidade localidade { get; set; }
		public boolean ativo { get; set; }
	}
	public class TipoEnderecamentoPostal {
		public Integer codigoTipoEnderecamentoPostal { get; set; }	
		public String nomeTipoEnderecamentoPostal { get; set; }
	}
	public class TipoLogradouro {
		public Integer codigoTipoLogradouro { get; set; }	
		public String nomeTipoLogradouro { get; set; }	
		public String siglaTipoLogradouro { get; set; }	
	}
	public class Bairro {
		public Integer codigoBairro { get; set; }	
		public String nomeBairro { get; set; }	
	}
	public class Localidade {
		public Integer codigoLocalidade { get; set; }	
		public String nomeLocalidade { get; set; }	
		public String nomeAbreviadoLocalidade { get; set; }	
		public Integer codigoLocalidadeOrigemExterna { get; set; }	
		public tipoSituacaoLocalidade tipoSituacaoLocalidade { get; set; }
		public estado estado { get; set; }
		public String codigoLocalidadeMunicipioIbge { get; set; }	
		public tipoLocalidade tipoLocalidade { get; set; }
		public boolean ativo { get; set; }
	}
	public class TipoSituacaoLocalidade {
		public Integer codigoTipoSituacaoLocalidade { get; set; }	
		public String descricaoTipoSituacaoLocalidade { get; set; }	
		public boolean ativo { get; set; }
	}
	public class Estado {
		public Integer codigoEstado { get; set; }	
		public String nomeEstado { get; set; }
		public String siglaEstado { get; set; }
		public String siglaEstadoOrigemExterna { get; set; }
		public boolean ativo { get; set; }
	}
	public class TipoLocalidade {
		public Integer codigoTipoLocalidade { get; set; }	
		public String nomeTipoLocalidade { get; set; }	
		public String codigoTipoLocalidadeOrigemExterna { get; set; }
		public boolean ativo { get; set; }
	}
	//PLV-4656 - Fim - Guilherme Brito	

	public class F5ServiceException extends Exception { }
}