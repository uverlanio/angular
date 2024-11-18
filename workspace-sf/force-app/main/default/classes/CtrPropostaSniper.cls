/*********************************************************************************************************************************************************************
@description  Classe que contem a ClasseTeste para o CtrPropostaSniper.
@author Renan Martins - Avanxo
@date 24/06/2019
@Hackathon Sniper Atualização 24/06/2019
@Classe criada por conta da história PLV-2389 
        
**********************************************************************************************************************************************************************/
global class CtrPropostaSniper { //PLV-5517 - INCIO/FIM

    public String transmissao {get;set;}
    public String entradaTransmissao {get;set;}	
	public String retornoEndereco {get;set;}
	public String entradaServicoCep {get;set;}
	public String tipoCep {get;set;} //PLV-5812 INICIO-FIM
    public String entradaAgenciadores {get;set;} //PLV-4367 - INÍCIO/FIM
	public String retornoAgenciadores {get;set;} //PLV-4367 - INÍCIO/FIM
    public String entradaCorretores {get;set;} //PLV-4475 - INÍCIO/FIM
	public String retornoCorretores {get;set;} //PLV-4475 - INÍCIO/FIM
	public String opServico {get;set;} //PLV-4324 - Inicio/Fim
	public String servicosEntrada {get;set;} //PLV-4324 - Inicio/Fim
	public String apoliceContratoOriginal {get;set;} //PLV-4889 - INICIO/FIM
    public String dadosPagamento {get;set;} //PLV-4889 - INICIO/FIM
	public static List<Oferta__c> listOferta {get;set;}//RVI-214 - INÍCIO/FIM 
	public String entradaOrchestrator { get; set;}//RVI-214 - INÍCIO/FIM 
	public String retornoOrchestrator { get; set;}//RVI-214 - INÍCIO/FIM 
	public String jsonEmail { get; set;}//RVI-262 e RVI-223 - INÍCIO/FIM 
    //RVI-262-FIX01-INICIO
    public String retornoEmail { get; set;}//RVI-301
    //RVI-262-FIX01-FIM

	//PLV-4322 - INICIO
	public String fieldName {get;set;}
	//PLV-4322 - FIM	
    
    //private static final CtrFormularioSnipper instancia = new CtrFormularioSnipper();
	private static CIVServices civServ = CIVServices.getInstance();  

	//PLV-2942 - Inicio - Chamada serviço CEP
	private static F5Service f5Serv = F5Service.getInstance();
	//PLV-2942 - fim
	
	//AV-85 INICIO
	public String dadosVoucher {get;set;}
	public class jsonDadosVoucher {
		public String cpf;
		public String produto;
		public String voucher;
	}
	public String paramIdFormaPagamento {get;set;} 
	//AV-85 FIM
	//RVI-319 INICIO
	// public Boolean isCartaoPorto		{get;set;} 
	// public String jsonResponseCalculo 	{get;set;}
	//RVI-319 FIM
    //Refencia Transmissao
		
	    public void pagTransmissao() {	
			//AV-85 INICIO
			jsonDadosVoucher objetoDadosVoucher = (jsonDadosVoucher) System.JSON.deserialize(DadosVoucher, jsonDadosVoucher.class);			
			map<String, Object> mapDadosVoucher = new map<String, Object>();
			String msgRetorno = '';
			System.debug('Entrada Transmissao: '+ entradaTransmissao);
			System.debug('objetoDadosVoucher: ' + objetoDadosVoucher);
			if(objetoDadosVoucher.produto == 'VIAGEM_VIDA_ON'){
				mapDadosVoucher.put('produto', objetoDadosVoucher.produto);
				mapDadosVoucher.put('cpf', objetoDadosVoucher.cpf);
				mapDadosVoucher.put('voucher', objetoDadosVoucher.voucher);
				String jsonMap = JSON.serialize(mapDadosVoucher);
				System.debug('jsonMap: ' + jsonMap);
				ContractBO.ResponseHerokuGravarVoucher responseGravarVoucherVidaOn = HerokuService.getInstance().gravarVoucherVidaOn(jsonMap);
				String jsonResponseConsulta = JSON.serialize(responseGravarVoucherVidaOn);
			}
			//AV-85 FIM
			//AV-530 INICIO
			//AV-531 INICIO
			EmissaoTO.OfertasTO objetoTransmissao = (EmissaoTO.OfertasTO) JSON.deserialize(entradaTransmissao, EmissaoTO.OfertasTO.class);
			System.debug('ObjetoTransmissao: ' + JSON.serialize(objetoTransmissao));
			
			//RVI-319 INICIO
			// System.debug('jsonResponseCalculo: ' + jsonResponseCalculo);
			// System.debug('isCartaoPorto: ' + isCartaoPorto);
			// if(isCartaoPorto){
			// 	objetoTransmissao
			// }
			//RVI-319 FIM

			//AV-655 INICIO
			if(objetoTransmissao.propostas[0].codigoProdutoVida == 'VIDA_ON' && objetoTransmissao.propostas[0].tipoSeguro != 'EDS'){
				//VIDA-95 - INICIO
				Profissao__c profissao = [SELECT Id, Codigo__c FROM Profissao__c WHERE NomeFantasia__c = :objetoTransmissao.propostas[0].contratantes[0].pessoa.dadosPessoaFisica.profissao LIMIT 1];

				objetoTransmissao.propostas[0].contratantes[0].pessoa.dadosPessoaFisica.profissao = profissao.Codigo__c;
				objetoTransmissao.propostas[0].contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.profissao = profissao.Codigo__c;

				List<GrupoProfissoes__c> grupoProfissao = [SELECT GrupoRisco__r.Name FROM GrupoProfissoes__c WHERE Profissao__c = :profissao.Id LIMIT 1];

				String nomeGrupoProfissao = !grupoProfissao.isEmpty() ? grupoProfissao[0].GrupoRisco__r.Name : '';

				objetoTransmissao.propostas[0].contratantes[0].pessoa.dadosPessoaFisica.grupoProfissao = nomeGrupoProfissao;
				objetoTransmissao.propostas[0].contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.grupoProfissao = nomeGrupoProfissao;
				//VIDA-95 - FIM


				entradaTransmissao = JSON.serialize(objetoTransmissao);
			}
			//AV-655 FIM
			List<String> ConsultaVidaOn = new List<String>();
			String descricao;
			Boolean podeContratar = true;         
			if(objetoTransmissao.propostas[0].codigoProdutoVida == 'VIDA_ON' && objetoTransmissao.propostas[0].tipoSeguro != 'EDS'){ //AV-634 INICIO/FIM
				System.debug('Passei 1***');
				ConsultaVidaOn = ConsultarVidaOnBO.getInstance().ConsultarVidaOnBO(entradaTransmissao);             
				podeContratar = ConsultaVidaOn.size() > 0 ? Boolean.valueOf(ConsultaVidaOn[0]) : podeContratar;
				System.debug('Danilo podeContratar'+ podeContratar);
				descricao = podeContratar? '' : ConsultaVidaOn[1];
				System.debug('Danilo descricao'+ descricao);
			}
			if(podeContratar == true){
				System.debug('Passei 2***');
				Boolean seguroAtivoVidaON;
				if(objetoTransmissao.propostas[0].codigoProdutoVida == 'VIDA_ON' && objetoTransmissao.propostas[0].tipoSeguro != 'EDS'){ //AV-634 INICIO/FIM
					String cpfAVerificar = objetoTransmissao.propostas[0].contratantes[0].pessoa.dadosPessoaFisica.numeroCpf + objetoTransmissao.propostas[0].contratantes[0].pessoa.dadosPessoaFisica.digitoCpf;                
				  	seguroAtivoVidaON = Boolean.valueOf(ConsultarVidaOnBO.getInstance().consultaSeguroAtivo(cpfAVerificar));
					if(seguroAtivoVidaON) { 
						descricao = 'O CPF informado possui este produto ativo, não é possível contratar novamente.'; 	podeContratar = false;
					}
				}
			}
			if(podeContratar == false) { 
				System.debug('Passei 3***');
				transmissao = '{"erroVidaOnMessage":"'+descricao+'"}';      
				//AV-531 FIM			 
			}else{
				System.debug('Passei 4***');
	
	            // VIAG-159 INICIO
				//Transmissão recebe o objeto de Retorno do Transmissão  
				/* AV-620  AV-631 não serão mais utilizados inicio
				Opportunity Produto = [SELECT  Produto__r.ProductCode FROM Opportunity WHERE Numero__c =: objetoTransmissao.propostas[0].numeroOrcamento Limit 1];
				String APIProduto = Produto.Produto__r.ProductCode;
			    String CorretorSusep;
				String CPF;
				Boolean StatusCPF = false;
				Boolean statusCorretor = false;
	            
				if(objetoTransmissao.propostas[0].segmento == 'Viagem') {   //AV-620 - AV-631 Fix 01 Inicio Fim 
				 	CPF = objetoTransmissao.propostas[0].contratantes[0].pessoa.dadosPessoaFisica.numeroCpf + objetoTransmissao.propostas[0].contratantes[0].pessoa.dadosPessoaFisica.digitoCpf; 
				
					if (CPF !='') {
						StatusCPF = cpfBloqueado(CPF,  APIProduto);
						System.debug ('CPF:'+ CPF + ' StatusCPF: '+StatusCPF);
					}
				
                 System.debug ('objetoTransmissaoJsonDiferente ' + objetoTransmissao);
			 	//}  else {
					 
                    System.debug ('objetoTransmissao json ' + objetoTransmissao);
				} 
				AV-620 não serão mais utilizados fim */
				// VIAG-159 FIM

				System.debug ('objetoTransmissao json ' + objetoTransmissao);
				String jsonTransmissao = entradaTransmissao;
			    
				transmissao = transmissaoContratacao(entradaTransmissao);
						
			    // VIAG-159 INICIO
				/* / AV-620, AV-699 e VIAG-152 INICIO
				if(objetoTransmissao.propostas[0].segmento == 'Viagem') { 

					 /* desnecessario
					Opportunity Produto = [SELECT  Produto__r.ProductCode FROM Opportunity WHERE Numero__c =: objetoTransmissao.propostas[0].numeroOrcamento Limit 1];
					String CPF = objetoTransmissao.propostas[0].contratantes[0].pessoa.dadosPessoaFisica.numeroCpf + objetoTransmissao.propostas[0].contratantes[0].pessoa.dadosPessoaFisica.digitoCpf; 
					String APIProduto = Produto.Produto__r.ProductCode;
					Boolean	StatusCPF = false;
				 
					if (CPF !='') {
					 StatusCPF = cpfBloqueado(CPF,  APIProduto);
						System.debug ('CPF:'+ CPF + ' StatusCPF: '+StatusCPF );
						if (StatusCPF == true){
							String Link = 'https://portoseguro.com.br/canal-de-ajuda';
							transmissao = '{"erroVidaOnMessage":"<h4>Ops!Algo deu errado.</h4><br><h6>Para seguir com a contratação, por favor, entre em contato com a nossa central de ajuda:</h6><br><a href='+Link+'>IR PARA A CENTRAL DE AJUDA</a>"}';   
							
						}	
					}
                 
					Retorno2TO retornoDevolutiva = (Retorno2TO) JSON.deserialize(transmissao, CtrPropostaSniper.Retorno2TO.class);
					System.debug('ret: ' + JSON.serialize(retornoDevolutiva) + '>>>>>'+ retornoDevolutiva.validacoesEstruturais !=null );
					if (retornoDevolutiva.validacoesEstruturais !=null) {
						if (retornoDevolutiva.validacoesEstruturais.valido == false ) {
							String retornocodigo = retornoDevolutiva.validacoesEstruturais.problemas[0].codigo;
							System.debug('retornoDevolutiva>>>>>'+ retornoDevolutiva.validacoesEstruturais.valido + 'Codigo: '+ retornocodigo);
							if ((retornocodigo== '-1')||(retornocodigo== '-3')){
									String Link = 'https://portoseguro.com.br/canal-de-ajuda';
									transmissao = '{"erroVidaOnMessage":"<h4>Ops!Algo deu errado.</h4><br><h6>Para seguir com a contratação, por favor, entre em contato com a nossa central de ajuda:</h6><br><a href='+Link+'>IR PARA A CENTRAL DE AJUDA</a>"}';   
								}
						}
					}
				}

				// AV-620, AV-699, VIAG-152 E VIAG-159 INICIO FIM */
				
				System.debug('ENTRADA TRANSMISSÃO: '+ transmissao);
			}		
			//AV-530 FIM  
			
		}

	// RVI-219 - INICIO
	public class DocOrquestrador {
		public String tipo;		// "CPF"
		public String numero;	// "13481182657"
	}

	public class ProdOrquestrador {
		public String codigo;		// "01", "32"
		public String descricao;	// "Porto Auto"
	}

	public class MetaOrquestrador {
		public String tipo_documento_comercial;		// "01"
		public String endosso;						// "0", ""
		public String codigo_empresa;				// "001"
		public String composicao_valor_parcela;		// "01"
		public String codigo_ramo;					// "531"
		public String parcela;						// "5"
		public String contrato_comercial;			// ""
		public String evento_emissao;				// "1"
		public String flag_sinalizador_processo;	// "O"
		public String flag_produto_seguro;			// "S"
		public String codigo_agregador;				// ""
		public String codigo_modalidade;			// "1", "24"
		public String auth_type;					// "SINGLE"
		public String tipoLink;						// "SOLICITACAO_PAGAMENTO", "REGISTRO_CARTAO"
	}

	public class PlanoPagamento {
		public String parcelas;		// "5"
		public String descricao;	// "5x com juros (R$ 250,00)"
		public String valorTotal;	// "1250.00"
	}
	
	public class JsonOrquestrador {
		public String idExterno;				// "080622001"
		public String expiraEm;					// "70"
		public String nome;						// "Cliente Fulando de Tal"
		public String tipoTransacao;			// "CAPTURA"
		public DocOrquestrador documento;
		public ProdOrquestrador produto;
		public MetaOrquestrador metadados;
		public String valorTotal;				// "1000"
		public PlanoPagamento planoPagamento;
	}

	@RemoteAction
	global static string getAPIOrquestrador(String json) {

		JsonOrquestrador jOrquestrador = (JsonOrquestrador)System.JSON.deserialize(json, JsonOrquestrador.class);
		RestResponse restResponse = RestContext.response;
		API_Link_de_Pagamento__mdt metadadosAPI = MetadataDAO.getInstance().apiLinkDePgto('API_Link_de_Pagamento');//RVI-294
		APTlmkGeraLinkPgtoCartaoCreditoService service = new APTlmkGeraLinkPgtoCartaoCreditoService();
		HttpResponse tokenResponse = service.getToken(metadadosAPI);

		if(tokenResponse.getStatusCode() != 200) {                
			restResponse.statusCode = tokenResponse.getStatusCode(); 
			return tokenResponse.getBody();
		}            

		List<Opportunity> lstOportunidade = [SELECT Id, Produto__r.Empresa__r.CodigoEmpresa__c FROM Opportunity WHERE Numero__c =: jOrquestrador.idExterno];
		jOrquestrador.expiraEm = metadadosAPI.expiraEm__c;
		jOrquestrador.tipoTransacao = 'CAPTURA';
		jOrquestrador.metadados.codigo_empresa = lstOportunidade[0].Produto__r.Empresa__r.CodigoEmpresa__c;
		jOrquestrador.metadados.auth_type = 'SINGLE';
		jOrquestrador.metadados.tipoLink = 'SOLICITACAO_PAGAMENTO';
		String body = System.JSON.serialize(jOrquestrador);
		TokenApiLinkPgtoCartaoCredito tokenApiLinkPgtoCartaoCredito = new TokenApiLinkPgtoCartaoCredito(tokenResponse.getBody());
		HttpResponse urlResponse = service.getLinkPgtoCartaoCredito(body, metadadosAPI, tokenApiLinkPgtoCartaoCredito);

		System.debug('nav-urlResponse.getBody: ' + urlResponse.getBody());
		
		return urlResponse.getBody();
	}
	// RVI-219 - FIM

	//TKCL-240 INICIO
	@RemoteAction
	global static string getAPIAptlmk(
			String codRamo, 
			String descricao, 
			String ofertaSelecionada, 
			String parcelas
		){

        RestResponse restResponse = RestContext.response;
        API_Link_de_Pagamento__mdt metadados = MetadataDAO.getInstance().apiLinkDePgto('API_Link_de_Pagamento');//RVI-294
        APTlmkGeraLinkPgtoCartaoCreditoService service = new APTlmkGeraLinkPgtoCartaoCreditoService();
  
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        HttpResponse tokenResponse = service.getToken(metadados);
		
        if(tokenResponse.getStatusCode() != 200){                
            restResponse.statusCode = tokenResponse.getStatusCode(); 
			return tokenResponse.getBody(); //TKCL-240 FIX01 INICIO/FIM
        }            

        TokenApiLinkPgtoCartaoCredito tokenApiLinkPgtoCartaoCredito = new TokenApiLinkPgtoCartaoCredito(tokenResponse.getBody());
		
		HttpResponse urlResponse = new HttpResponse();
		
		List<Opportunity> codEmpresa = [SELECT Id, Produto__r.Empresa__r.CodigoEmpresa__c FROM Opportunity WHERE Numero__c =: ofertaSelecionada];

		String codEmp = codEmpresa[0].Produto__r.Empresa__r.CodigoEmpresa__c;
		String valorParcela = '1000';

		//RVI-294
		String codigo = '32';
		if(codEmp == '14'){
			descricao = 'Vida do Seu Jeito';
			codigo = '8b4da283-389d-47d5-83f0-fd8fc6d02708';
		}
		String body = '{"idExterno":"'+ofertaSelecionada+'","expiraEm":"'+ metadados.expiraEm__c +'","nome":"Cliente Fulando de Tal","tipoTransacao":"CAPTURA","tipoLink":"REGISTRO_CARTAO","documento":{"tipo":"CPF","numero":"13481182657"},"produto":{"codigo":"'+ codigo +'","descricao":"'+ descricao +'"},"metadados":{"tipo_documento_comercial":"01","endosso":"","codigo_empresa":"'+ codEmp +'","composicao_valor_parcela":"01","codigo_ramo":"'+ codRamo +'","parcela":"'+ parcelas + '","contrato_comercial":"","evento_emissao":"1","flag_sinalizador_processo":"O","flag_produto_seguro":"S","codigo_agregador":"","codigo_modalidade":"24","auth_type":"SINGLE"},"valorTotal":"'+ valorParcela +'"}'; 
		System.debug('body >>> ' + body);
		//RVI-294

		urlResponse = service.getLinkPgtoCartaoCredito(body, metadados, tokenApiLinkPgtoCartaoCredito);
		System.debug('Rogerio urlResponse' + urlResponse.getBody());
		return urlResponse.getBody();
	}
	//TKCL-240 FIM
	
	//PLV-5517 - INCIO
	//II-163 INICIO
	@RemoteAction
	global static string getQuote(String numQuote){
		Quote proposta = new Quote();
		//II-177 INICIO
		String link;
		NamedCredential endpointSF = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1];		
		List <Quote> lstProposta = [SELECT Id,Name,Produto__r.ProductCode,Produto__r.Segmento__c,PropostaPdfDownloadUrl__c,Status FROM Quote WHERE Name =:numQuote ORDER BY CreatedDate DESC limit 1];
		String recusada = 'Proposta Recusada';
		link = endpointSF.Endpoint+'apex/PropostaIndividual?idProposta=' + lstProposta[0].Id;
		//II-177 FIM
		
		if(!lstProposta.IsEmpty() && lstProposta[0].Produto__r.ProductCode.contains('VI-PESSOAS') && lstProposta[0].Produto__r.Segmento__c.contains('Individual') && lstProposta[0].PropostaPdfDownloadUrl__c != null && lstProposta[0].Status != 'Recusada'){
			proposta.PropostaPdfDownloadUrl__c = lstProposta[0].PropostaPdfDownloadUrl__c; System.debug('proposta ' + proposta);
			return link; //II-177 INICIO/FIM
		}else if(!lstProposta.IsEmpty() && lstProposta[0].Produto__r.ProductCode.contains('VI-PESSOAS') && lstProposta[0].Produto__r.Segmento__c.contains('Individual') && lstProposta[0].Status == 'Recusada'){ //II-163 FIX01 INICIO/FIM
			return recusada;
		}
		return '';
	}
	//II-163 FIM
	//PLV-5517 - FIM

	//PLV-5493 - INICIO

	@RemoteAction
	global static string getUrlSampleMed(String numQuote){		
		system.debug('ENTROU++++');
		String Retorno;

		list<GarantiaProposta__c> garantiaProposta = [SELECT Id,Capital__c,Garantia__c,Garantia__r.Sigla__c FROM GarantiaProposta__c WHERE Proposta__r.Name =: numQuote];
		System.debug('SELECT GARANTIA++++' + garantiaProposta);
		SeguradoProposta__c segurado = [SELECT id,GrupoProposta__r.ContratanteProposta__r.Proposta__r.Name,Profissao__r.Codigo__c FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__r.Name =: numQuote Limit 1];
		Quote proposta = [SELECT id,Name,NumeroPropostaUnico__c,Account.PersonBirthdate,Account.BillingCity,Account.BillingState,Account.Sexo__c,( SELECT Id, Garantia__r.Sigla__c,Capital__c FROM GarantiasProposta__r WHERE Garantia__r.Sigla__c != 'TELEMED' AND Garantia__r.Sigla__c != 'IPTA' AND Garantia__r.Sigla__c != 'IPAM') FROM Quote WHERE Name =: numQuote Limit 1];
		FavorecidoRemuneracaoProposta__c favorecido = [SELECT id,RemuneracaoProposta__r.Proposta__r.Name,CorretorResponde__c FROM FavorecidoRemuneracaoProposta__c WHERE RemuneracaoProposta__r.Proposta__r.Name =:numQuote Limit 1];
		CriticaProposta__c critica = [SELECT id,Acao__c,Status__c,MomentoAnalise__c,Codigo__c FROM CriticaProposta__c WHERE Proposta__r.Name =: numQuote AND MomentoAnalise__c = 'Subscrição' AND Codigo__c >= '70' AND Codigo__c <= '79' Limit 1]; //PLV-5493 FIX-01 - INICIO/FIM
		system.debug('SELECT PROPOSTA+++++' + proposta);
		system.debug('SELECT Critica+++++' + critica);
		system.debug('SELECT SEGURADO+++++' + segurado);
		system.debug('SELECT FAVORECIDO+++++' + favorecido);
		IntegracaoSampleMed.ResponseSampleMed RetornoURL = IntegracaoSampleMed.getSampleMed(proposta , critica, segurado, favorecido);
		system.debug('RetornoURL++++' + RetornoURL);
		if(!RetornoURL.SuccessEntries.isEmpty()){  Retorno = RetornoURL.SuccessEntries[0].Applicant.questionnaire_url;
			system.debug('RETORNO++++' + RetornoURL.SuccessEntries[0].Applicant.questionnaire_url);
		}
		return Retorno;
	}

	//PLV-5493 - FIM
	
	//PLV-5812 INICIO
	@RemoteAction
	global static String consultaCepRemote(String entradaServicoCep, String tipoCep){ //PLV-5812 INICIO-FIM FIX01
		String retornoServico = F5Service.getInstance().consultaCEP(entradaServicoCep, tipoCep);
		System.debug('retornoServico Rogerio >>>>' + retornoServico);
		return retornoServico;
	}
	//PLV-5812 FIM

	//VIDA-27 - INICIO
	@RemoteAction
	global static String consultaRendaVidaON() {
        String rendaMensal = VidaOnService.getInstance().buscaRendaVidaON();
		System.debug('retornoServico >>>>' + rendaMensal);
		return rendaMensal;
	}
	//VIDA-27 - FIM
	

	//INICIO - PLV-4656-VI-Guilherme Brito
	public void consultaCEP(){ 
		String entrada = entradaServicoCep;
		String cepName = fieldName;
		
		System.debug('tipoCep: ' + tipoCep);
		System.debug('Class: CTRPropostaSniper');
		System.debug('JSONname: ' + cepName);
		System.debug('Entrada: ' + entrada);

		//Mock antigo
		//String retornoServico = F5Service.mockRetornoConsultaCep;
		
        String retornoServico = F5Service.getInstance().consultaCEP(entrada, cepName);
		system.debug('retornoServico >>>>' + retornoServico );
		//PLV-5812	INICIO
		RetornoEnderecoTO retorno = (RetornoEnderecoTO) JSON.deserialize(retornoServico, RetornoEnderecoTO.class);
		//List<RetornoEnderecoTO> retorno = (List<RetornoEnderecoTO>) JSON.deserialize(retornoServico, List<RetornoEnderecoTO>.class);
		//PLV-5812 FIM
		
		//EnderecoCompletoTO retorno2 = (EnderecoCompletoTO) JSON.deserialize(retornoServico, EnderecoCompletoTO.class);

		/*
		if(Test.isRunningTest()){
			
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.codigoBairro = '10';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.codigoCidade = '8';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.codigoFoneticoLogradouro = '2';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.codigoLogradouro = '3';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.primeiroCodigoFoneticoCidade = '19';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.primeiroCodigoFoneticoLogradouro = '987';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.segundoCodigoFoneticoCidade = '123';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.segundoCodigoFoneticoLogradouro = '675';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.terceiroCodigoFoneticoCidade = '876';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.terceiroCodigoFoneticoLogradouro = '666';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.cepComplementoCidade = '320';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.cepCidade = '320';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.cepEspecial = '321';
			
			EnderecoCompletoTO endereco = new EnderecoCompletoTO();
			endereco.bairro = 'CAMPOS ELISEOS22';
			endereco.cep = '01204';
			endereco.cidade = 'SAO PAULO';
			endereco.complementoCep = '1';
			endereco.logradouro = 'GUAIANASES';
			endereco.tipoLogradouro = 'RUA';
			endereco.uf = 'SP';
			retorno.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto = endereco;
		}
		*/
		System.debug('retorno >>>>' + retorno);

		retornoEndereco = JSON.serialize(retorno); //PLV-5812 INICIO-FIM
		System.debug('retornoEndereco >>>>' + retornoEndereco);

		//FIM - PLV-4656-VI-Guilherme Brito
		
	}

    //Metódo que Busca o Transmissão do Serviço da CIVSERVICE
	public static String transmissaoContratacao(String entradaTransmissao) {

		string jsonTransmissao = entradaTransmissao; //RVI-39 - INICIO/FIM
        
		//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
		//String ResponseTransmissao;
		String retorno;
		//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.

		try{
			//exclusão mock PLV-2687
			String message;

			//RVI-39 - INICIO
			//PropostaTO.Root entrada = (PropostaTO.Root) JSON.deserialize(jsonTransmissao, PropostaTO.Root.class);
			
            System.debug('jsonTransmissao>> ' + jsonTransmissao);
            
			EmissaoTO.OfertasTO entrada = (EmissaoTO.OfertasTO) JSON.deserialize(jsonTransmissao, EmissaoTO.OfertasTO.class);
			
			/*if(entrada.propostas.get(0).segmento == 'Individual'){
				System.debug('Proposta para transmissão (antes de recuperar o código da empresa) >>>> ' + entrada);
				Opportunity orcamento = [SELECT Id, Produto__c, Produto__r.Empresa__r.CodigoEmpresa__c FROM Opportunity WHERE Numero__c =: entrada.propostas.get(0).numeroOrcamento LIMIT 1];
				for(PropostaTO.Proposta proposta : entrada.propostas)
				{
					proposta.codigoEmpresa = Integer.valueof(orcamento.Produto__r.Empresa__r.CodigoEmpresa__c.trim());
				}
					
				System.debug('JSON da proposta para a transmissão (com código da empresa recuperado e preenchido) >>>> ' + entrada);
				jsonTransmissao = JSON.serialize(entrada, TRUE);
			}*/

			System.debug('Proposta para transmissão (antes de recuperar o código da empresa) >>>> ' + entrada);
			
			Opportunity orcamento = [SELECT Id, Produto__c, Produto__r.Empresa__r.CodigoEmpresa__c FROM Opportunity WHERE Numero__c =: entrada.propostas.get(0).numeroOrcamento LIMIT 1];
            
			System.debug( 'QUERY ORÇAMENTO HENRIQUE: ' + orcamento );
			for(EmissaoTO proposta : entrada.propostas)
			{
				// VIAG-299 SOUSA start
				if(proposta.segmento != '') {//ANNVI-212 - INICIO/FIM
					proposta = ajustAdress(proposta);
				}
				// VIAG-299 SOUSA end

                proposta.codigoEmpresa = Integer.valueof(orcamento.Produto__r.Empresa__r.CodigoEmpresa__c.trim()); 
			}
				
			System.debug('JSON da proposta para a transmissão (com código da empresa recuperado e preenchido) >>>> ' + entrada);

			jsonTransmissao = JSON.serialize(entrada, TRUE);
			System.debug('jsonTransmissao serialized >>> '+ jsonTransmissao); // ANNVI-48 INICIO/FIM

			//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
			//Chama o serviço através da classe civService e valida o retorno.

			//if(entrada.propostas.get(0).codigoProdutoVida == 'VI-PESSOAS'){
		
			//Boolean StatusCorretor = corretorBloqueado(Corretor, CodProduto);
            // System.debug('O Status do corretor eh >>>>'+ StatusCorretor);
            
            //VIAG-271 - INICIO
			//MGRC-1571-INICIO TRANSMISSAO SEGURO NOVO
			//MGRC-1571-BUGFIX-TRANSMISSAO-NOVO-ENDOSSO-INICIO	
			Map<String, Object> calculosMap = (Map<String, Object>) JSON.deserializeUntyped(jsonTransmissao);
			String codigoProdutoVida;
			String tipoSeguro;

			if (calculosMap.containsKey('propostas') && calculosMap.get('propostas') != null) {
				List<Object> propostasList = (List<Object>) calculosMap.get('propostas');

				if (!propostasList.isEmpty()) {
					Map<String, Object> propostaMap = (Map<String, Object>) propostasList[0];
					codigoProdutoVida = (String) propostaMap.get('codigoProdutoVida');
					tipoSeguro = (String) propostaMap.get('tipoSeguro');
					
					System.debug('Código Produto Vida: ' + codigoProdutoVida);
					System.debug('Tipo Seguro: ' + tipoSeguro);
				}

				if(entrada.propostas.get(0).segmento == 'Viagem' || codigoProdutoVida == 'VIAGEM_VIDA_ON'){ //ZSVEP-308-INICIO/FIM
                    //VIAG-301 INICIO
                    if(entrada.propostas.get(0).numeroOrcamento != null){
                        
                        List<String> status = new List<String>{'Contratada', 'Disponível para contratação'};
                        
                        List<Quote> quotes = [
                            SELECT 
                            VigenciaFinal__c, 
                            VigenciaInicial__c, 
                            DataLimitePagamento__c, 
                            VoucherPdfDownloadUrl__c, 
                            NumeroProposta__c,
                            Opcao__c, 
                            Origem__c,
                            CanalDistribuicao__r.Sigla__c,
                            Empresa__r.CodigoEmpresa__c, 
                            MeioComercializacao__c, 
                            Status,
                            RamoSeguro__r.Codigo__c, 
                            Modalidade__r.Codigo__c, 
                            DataCalculo__c,
                            Opportunity.ContadorOrcamento__c, 
                            Chave_de_Agrupamento__c 
                            FROM Quote 
                            WHERE Opportunity.Numero__c =: entrada.propostas.get(0).numeroOrcamento AND Status IN: status 
							
                        ];    
                        
                        if(!quotes.isEmpty()){
                        	return buildResponse(quotes);   
                        }
                    }
                    retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, SensediaServices.TRANSMISSAO_CONTRATACAO_VIAGEM, jsonTransmissao);
					//VIAG-301 FIM
				} else {	
					switch on codigoProdutoVida {
						//MGRC-1586-INICIO
						when 'VIDA_ON' {
							if (tipoSeguro == 'Novo') {
								retorno = SensediaServices.getInstance().montagemServicoSensedia(
									SensediaServices.VERB.POST, 
									SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
									SensediaServices.TRANSMISSAO_CONTRATACAO_VIDA_ON, 
									jsonTransmissao
								);
							} else if (tipoSeguro == 'EDS') {
								retorno = SensediaServices.getInstance().montagemServicoSensedia(
                                    SensediaServices.VERB.POST, 
                                    SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
                                    SensediaServices.TRANSMISSAO_CONTRATACAO_ENDOSSO_VIDA_ON, 
                                    jsonTransmissao
                                );
							} else {
								System.debug('Falha na transmissão - VIDA_ON');
							}
						}
						//MGRC-1586-FIM
						//MGRC-1584-INICIO
						when 'VI-PESSOAS' {
							if (tipoSeguro == 'Novo') {
								retorno = SensediaServices.getInstance().montagemServicoSensedia(
									SensediaServices.VERB.POST, 
									SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
									SensediaServices.TRANSMISSAO_CONTRATACAO_VDSJ, 
									jsonTransmissao
								);
							} else if (tipoSeguro == 'EDS') {
								retorno = SensediaServices.getInstance().montagemServicoSensedia(
                                    SensediaServices.VERB.POST, 
                                    SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
                                    SensediaServices.TRANSMISSAO_CONTRATACAO_ENDOSSO_VDSJ, 
                                    jsonTransmissao
                                );
							} else {
								System.debug('Falha na transmissão - VI-PESSOAS');
							}
						}
						//MGRC-1584-FIM
						//MGRC-1585-INICIO
						when 'APTLMKT' {
							if (tipoSeguro == 'Novo') {
								retorno = SensediaServices.getInstance().montagemServicoSensedia(
									SensediaServices.VERB.POST, 
									SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
									SensediaServices.TRANSMISSAO_CONTRATACAO_APTLMKT, 
									jsonTransmissao
								);
							} else if (tipoSeguro == 'EDS') {
								retorno = SensediaServices.getInstance().montagemServicoSensedia(
                                    SensediaServices.VERB.POST, 
                                    SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
                                    SensediaServices.TRANSMISSAO_CONTRATACAO_ENDOSSO_APTLMKT, 
                                    jsonTransmissao
                                );
							} else {
								System.debug('Falha na transmissão - APTLMKT');
							}
						}
						//MGRC-1585-FIM
					}	
					//MGRC-1571-BUGFIX-TRANSMISSAO-NOVO-ENDOSSO-FIM
				}
				// System.debug('forcando civserv --->>> '+ civServ.criacaoTransmissao(jsonTransmissao));
				// retorno = civServ.criacaoTransmissao(jsonTransmissao); //MGRC-1571-BUGFIX INICIO/FIM
			}
			//MGRC-1571-FIM TRANSMISSAO SEGURO NOVO
			//VIAG-271 - FIM
			

            //RVI-39 - FIM
			//PLV-2948 - Inicio - Tratamento de devolutivas
			// if(retorno == 'Erro na requisição'){
			// 	message =  '{'+
			// 					+'"message":"Erro no serviço. Entre em contato com o administrador."'+
			// 						+'}';
		
			// 	System.debug('Dentro do IF(retorno = ERRO - Metodo: transmissaoContratacao)');
			// 	System.debug('Message: ' + message);

			// 	return message;
            // }

			//PLV-2948 Fix3 - Inicio - Ajuste do retorno do serviço, caso haja devolutiva
			//Deserializar retorno
			//PLV-3763 - INICIO - Trecho comentado
			/*Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(retorno);
			system.debug('ret: ' + JSON.serialize(result));
			if(result.get('data') != null){
				//Buscar devolutiva
				RetornoTO retornoDevolutiva = (RetornoTO) JSON.deserialize(retorno, CtrPropostaSniper.RetornoTO.class);
				system.debug('dev: ' + JSON.serialize(retornoDevolutiva));
				for(ResultadosTO resultado : retornoDevolutiva.data.resultados){
					for (DevolutivasTO devolutiva : resultado.devolutivas) {
						message = '{'+
									+'"message": "'+ devolutiva.descricao 
									+'"}';
					}	
				}
				return message;
			}*/
			//PLV-3763 - FIM
			//PLV-2948 Fix3 - Fim - Ajuste do retorno do serviço, caso haja devolutiva
			//PLV-2948 - Rollback

			//PLV-2948 - Fim - Tratamento de devolutivas

		} catch(Exception ex){
			System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage() + ' st=' +ex.getStackTraceString());
			throw new ServiceException('O seguinte ERRO ocorreu: ' + ex.getMessage() + ', ' + ex.getStackTraceString());	
		}
		system.debug('retorno mensagem>>>>>'+ retorno);

    	return retorno;
    	//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
	}

	// VIAG-299 SOUSA start
	private static EmissaoTO ajustAdress(EmissaoTO proposta){

		if(proposta.contratantes != null){ //ANNVI-212 - INICIO/FIM
			for(EmissaoTO.ContratanteTO contratante : proposta.contratantes){
				contratante = ajustAdress(contratante);
			}
		}//ANNVI-212 - INICIO/FIM
		return proposta;
	}
	private static EmissaoTO.ContratanteTO ajustAdress(EmissaoTO.ContratanteTO contratante){

		for(EmissaoTO.GrupoTO grupo : contratante.grupos){
			grupo = ajustAdress(grupo);
		}

		//ANNVI-212 - INICIO
		if(contratante.pessoa != null){
			if(contratante.pessoa.enderecos != null){
				for(EmissaoTO.EnderecoTO endereco : contratante.pessoa.enderecos){
					endereco = ajustAdress(endereco);
				}
			}
		}
		//ANNVI-212 - FIM

		return contratante;
	}
	private static EmissaoTO.GrupoTO ajustAdress(EmissaoTO.GrupoTO grupo){

		for(EmissaoTO.SeguradoTO segurado : grupo.segurados){
			segurado = ajustAdress(segurado);
		}

		return grupo;
	}
	private static EmissaoTO.SeguradoTO ajustAdress(EmissaoTO.SeguradoTO segurado){

		for(EmissaoTO.EnderecoTO endereco : segurado.pessoa.enderecos){
			endereco = ajustAdress(endereco);
		}

		return segurado;
	}
	private static EmissaoTO.EnderecoTO ajustAdress(EmissaoTO.EnderecoTO endereco){

		endereco.logradouro = endereco.logradouro.replaceAll('\'', ' ');
		endereco.bairro = endereco.bairro.replaceAll('\'', ' ');
		endereco.cidade = endereco.cidade.replaceAll('\'', ' ');
		endereco.complemento = endereco.complemento.replaceAll('\'', ' ');

		return endereco;
	}
	// VIAG-299 SOUSA end
    // AV-699 INICIO
   
	  public Static Boolean cpfBloqueado(string cpf, string CodProduto) {
		Boolean StatusCPF = false;
	    List<Account> ConsultaCPFBloqueado = new List<Account>();
      	
		if (CodProduto != Null) {
				ConsultaCPFBloqueado = [Select Id, Name from Account where Cpf__c =: cpf and Produtos_Bloqueados__c includes (:CodProduto)]; 
				if (ConsultaCPFBloqueado.size() > 0) {
					StatusCPF = true;
				} else {
					StatusCPF = false;
				}
		 } else {
			StatusCPF = false;
		 }
		 System.debug('jsonTransmissao>> CodProduto  ' + CodProduto + 'CPF Cliente '+ cpf+ ' STATUS: '+ StatusCPF);
		return StatusCPF;
	
		}
	
	
		// AV-699 FIM
      
    
    //PLV-4367 - INÍCIO 
    public void consultaAgenciadores(){
        try {
            
            BuscaAgenciador.AgenciadorTO reqBody = new BuscaAgenciador.AgenciadorTO();
            reqBody.nome = 'teste';
            reqBody.susep = '';
            reqBody.codigoAgenciador = '';
            reqBody.cpf = '063.329.239-70';
            reqBody.cnpj = '';
    
            RestRequest req = new RestRequest(); 
            
            req.requestURI = '/services/apexrest/buscaAgenciador'; 
            req.httpMethod = 'POST';
            //req.requestBody = Blob.valueof(JSON.serialize(reqBody));
            req.requestBody = Blob.valueof(entradaAgenciadores);
            RestContext.request = req;
            
            BuscaAgenciador.Response res = BuscaAgenciador.BuscaAgenciador();
			String conteudoAgenciadores = '';
            
            if(res.data != null){
				if(res.data.success){
                    for(BuscaAgenciador.AgenciadorTO ag : res.data.agenciadores){
                        if(conteudoAgenciadores != '') conteudoAgenciadores += ',';
                          conteudoAgenciadores +=
                             	  '{'+
                                        +'"nome": "'+ ag.nome + '",'
										+'"susep": "'+ ag.susep + '",'
                             			+'"codigoAgenciador": "'+ ag.codigoAgenciador + '",'
                             			+'"cpf": "'+ ag.cpf + '",'
                             			+'"cnpj": "'+ ag.cnpj + '",'
                             			+'"papel": "'+ ag.papel +'"'
                                 +'}';
                    }
                }   
			}
            
            retornoAgenciadores = '{"agenciadores":['+conteudoAgenciadores+']}';

        } catch(Exception ex) {
		}
        
    }
   	//PLV-4367 - FIM
    
    //PLV-4475 - INÍCIO
    public void consultaCorretores(){
        try {
            
            BuscaAgenciador.AgenciadorTO reqBody = new BuscaAgenciador.AgenciadorTO();
            reqBody.nome = '';
            reqBody.susep = entradaCorretores.toUpperCase(); //PLV-5158
            reqBody.codigoAgenciador = '';
            reqBody.cpf = '';
            reqBody.papel = 'Corretor';
            reqBody.cnpj = '';
    
            RestRequest req = new RestRequest(); 
            
            req.requestURI = '/services/apexrest/buscaAgenciador'; 
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSON.serialize(reqBody));
            RestContext.request = req;
            
            BuscaAgenciador.Response res = BuscaAgenciador.BuscaAgenciador();
            
            if(res.data != null && res.data.success && !res.data.agenciadores.isEmpty()){ retornoCorretores = '{"corretor":"'+entradaCorretores.toUpperCase()+'","encontrado":true}';
			}
            else {
                retornoCorretores = '{"corretor":"'+entradaCorretores.toUpperCase()+'","encontrado":false}';
            }

        } catch(Exception ex) {
		}
    }
	//PLV-4475 - FIM
	
    //PLV-4889 - INICIO
    public void consultaDadosPagOriginal() {
         ContratanteContrato__c pgt = [ SELECT Id, Conta__c,//PLV-4911 INICIO/FIM
            FormaPagamento__c, 
            CartaoCredito__c,
            CartaoCredito__r.CartoPortoSeguro__c, 
            CartaoCredito__r.CodigoSeguranca__c, 
            CartaoCredito__r.NomeTitular__c,
            CartaoCredito__r.NumeroCartao__c,
            CartaoCredito__r.Vencimento__c,
            CartaoCredito__r.Bandeira__c,//PLV-4926-INICIO/FIM
            InformacaoBancaria__c,
            InformacaoBancaria__r.Agencia__c,
            InformacaoBancaria__r.Digito__c,
            InformacaoBancaria__r.BancoNew__r.CodigoBanco__c,
            InformacaoBancaria__r.NumeroConta__c,
            InformacaoBancaria__r.TipoPessoa__c,
            InformacaoBancaria__r.Conta__r.Cpf__c,
            ResponsavelPagamento__c,
            TipoResponsavelPagamento__c,
            VigenciaInicial__c
        FROM ContratanteContrato__c 
        WHERE Contrato__r.IdExterno__c=:apoliceContratoOriginal]; //PLV-4889-FIX //PLV-4911 INICIO/FIM
        List<ContratanteContrato__c> contratantes = [ SELECT Id FROM ContratanteContrato__c WHERE Contrato__r.IdExterno__c=:apoliceContratoOriginal]; //PLV-4889-FIX
        
		//PLV-4911 - INICIO
        //String segurados = '[]';
        if(contratantes.size() > 0){
			GrupoContrato__c segurados = [  SELECT 
											(SELECT NomeResponsavel__c
													, CpfResponsavel__c
													, vinculoComSegurado__c
													, ResponsavelFinanceiroSeguro__c
													, ResponsavelPagamento__c
											FROM SeguradosContrato__r
                                			LIMIT 1)		
										FROM GrupoContrato__c 
										WHERE ContratanteContrato__c =: contratantes[0].Id
										];
			String accIdResp = segurados.SeguradosContrato__r[0]!=null && segurados.SeguradosContrato__r[0].ResponsavelFinanceiroSeguro__c==true ? pgt.Conta__c : segurados.SeguradosContrato__r[0].ResponsavelPagamento__c;
			Account contaResponsavelFinanceiro = [SELECT Id, PersonEmail, PersonMobilePhone
													, PersonHomePhone
													, Phone
													//PLV-5153 - INICIO
													, Sexo__c
													, PersonBirthdate
													, EstadoCivil__c
													//PLV-5153 - FIM														
													, (SELECT id
															, CEP__c
															, Bairro__c
															, Complemento__c
															, Cidade__c
															, Estado__c
															, Numero__c
															, TipoLogradouro__c
															, Logradouro__c
															FROM Enderecos__r
															WHERE MaisAtual__c = true) 
													FROM Account
													WHERE Id =: accIdResp];
			if(contaResponsavelFinanceiro != null){ 
             segurados.SeguradosContrato__r[0].ResponsavelPagamento__r = contaResponsavelFinanceiro;
			}
			Map<String, Object> mapToReturn = new Map<String, Object> ();
			mapToReturn.put('dadosPgt',pgt); mapToReturn.put('dadosSegurado',segurados);
			this.dadosPagamento = JSON.serialize(mapToReturn);
        }
				//PLV-4911 - FIM
    }
    //PLV-4889 - FIM

	//PLV-2948 Fix3 - Inicio - Ajuste do retorno do serviço, caso haja devolutiva
	public class RetornoTO 
	{
		public DataTO data { get; set; }
	}

	public class DataTO 
	{
		public List<DevolutivasTO> devolutivas { get; set; }
		
	}

	public class DevolutivasTO 
	{
		public String descricao { get; set; }
		public String codigo { get; set; }
		
	}

// AV-620 e AV-699 inicio
public class Retorno2TO 
	{
		public validacoesEstruturaisTO validacoesEstruturais { get; set; }
	}


	public class validacoesEstruturaisTO
	{
		public List<ProblemasTO> problemas { get; set; }
		public Boolean  valido { get; set; }
	}
	
	public class ProblemasTO
	{
		public String descricao { get; set; }
		public String codigo { get; set; }
		
	}

// AV-620 E AV-699 FIM



	//PLV-2948 Fix3 - Fim - Ajuste do retorno do serviço, caso haja devolutiva
	//PLV-4322 - INICIO

	public class RetornoEnderecoTO{
		public ObterEnderecoPorCEPResponseTO obterEnderecoPorCEPResponse {get;set;} //PLV-5812
	}

	public class ObterEnderecoPorCEPResponseTO{
		public EnderecosGuiaPostalEBOTO enderecosGuiaPostalEBO {get;set;}
	}

	public class EnderecosGuiaPostalEBOTO{
		public EnderecoGuiaPostalEBOTO enderecoGuiaPostalEBO {get;set;}
	}
	public class EnderecoGuiaPostalEBOTO{
		public String codigoLogradouro {get;set;}
		public String codigoFoneticoLogradouro {get;set;}
		public String primeiroCodigoFoneticoLogradouro {get;set;}
		public String segundoCodigoFoneticoLogradouro {get;set;}
		public String terceiroCodigoFoneticoLogradouro {get;set;}
		public String codigoBairro {get;set;}
		public String codigoCidade {get;set;}
		public String cepCidade {get;set;}
		public String cepComplementoCidade {get;set;}
		public String primeiroCodigoFoneticoCidade {get;set;}
		public String segundoCodigoFoneticoCidade {get;set;}
		public String terceiroCodigoFoneticoCidade {get;set;}
		public String cepEspecial {get;set;}
		public EnderecoCompletoTO enderecoCompleto {get;set;}
		public String cepName {get; set;}
	}

	public class EnderecoCompletoTO{
		public String tipoLogradouro {get;set;}
		public String logradouro {get;set;}
		//public Object complemento {get;set;}
		public String bairro {get;set;}
		public String cidade {get;set;}
		public String uf {get;set;}
		public String cep {get;set;}
		public String complementoCep {get;set;}
	}

	//PLV-4324 - Inicio
	public void consultaOpcoesTipoServico() { 
		String ResponseOpcaoProfissao;
		System.debug('ServicosEntrada Proposta: ' + servicosEntrada);
		List<OpcoesServicoTO> lstOpcoes = OpcoesServicoTO.parse(servicosEntrada);
		//PLV-4393 - Inicio
		Map<String, Object> mServicos = new Map<String, Object>();
		try{
			for(OpcoesServicoTO tipoServico : lstOpcoes){
				//MGRC-1266 - INICIO
				if(tipoServico.servico == 'Consulta_Profissao'){
					ResponseOpcaoProfissao = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.GET, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.CONSULTA_PROFISSAO, tipoServico.body);//SensediaServices.getInstance().opcaoServicoConsultaProfissao(tipoServico);
				//MGRC-1266 - FIM	
				//MGRC-1281 - INICIO
				}else if (tipoServico.servico == 'paises'){
					ResponseOpcaoProfissao = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.GET, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.PAISES, tipoServico.body);
				//MGRC-1281 - FIM
				//MGRC-1257 - INICIO
				}else if (tipoServico.servico == 'Consulta_Banco'){ 
					ResponseOpcaoProfissao = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.CONSULTA_BANCO, tipoServico.body);
				}
				//MGRC-1257 - FIM
				System.debug('Response Opção Serviço ==>' + ResponseOpcaoProfissao);
				mServicos.put(tipoServico.id, JSON.deserializeUntyped(ResponseOpcaoProfissao));
				System.debug('Map de serviços: ' + mServicos);
			}		
		}
		//PLV-4393 - Fim      
		catch(Exception ex){
			System.debug('###### Método consultaOpcoesTipoServico: (' + ex.getLineNumber() + '): ' + ex.getMessage());			
			String message = '{message":"Erro no serviço. Entre em contato com o administrador.}';           
		}
		// PLV-4724-FIX2 INICIO
		opServico = JSON.serialize(mServicos);
		System.debug('opServicos serializado: ' + opServico);
		System.debug('mServicos serializado: ' + mServicos);
		// PLV-4724-FIX2 FIM
	}
	//PLV-4324 - Fim
	//PLV-4322 - FIM
	// AV-85 INICIO FIX-05
	
	public void findIdFormaPagamento(){
		List<FormaPagamento__c> idFormaPagamento = [
			SELECT id
			FROM FormaPagamento__c
			WHERE Codigo__c = '41'
			AND Name = 'FRAC.1.A PARCELA CARNE'
			AND RamoSeguro__r.Name = 'SEGURO VIAGEM'
			AND Modalidade__r.Name = 'SEGURO VIAGEM'
		];
		paramIdFormaPagamento = idFormaPagamento[0].Id;
	}
	// AV-85 FIM FIX-05
	public static Map<String, String> gerarHeaderOAuth2(String headerAutorizacao) {
		Map<String, String> header = new Map<String, String>(); header.put('Content-Type', 'application/json'); header.put('Accept','application/json');
		if (String.isNotBlank(headerAutorizacao)) { header.put('Authorization', headerAutorizacao);
		}

		return header;
	}

	//***************** RVI-214 - INICIO *****************
	//Método para indentificar código da empresa 14
	public void getOrchestrator(){
		List<Oferta__c> listOferta = new List<Oferta__c>([SELECT id, Name, Produto__r.Name, Produto__r.ProductCode 
                       FROM Oferta__c 
                       WHERE Produto__r.Empresa__r.CodigoEmpresa__c = '14' 
					   // RVI-214 - INICIO
					   // Alterei a condição AND
					   AND Name = :entradaOrchestrator]);
					   // RVI-214 - FIM
		System.debug('Giordano retorno orchestrator listOferta: ' + listOferta);
							
		if (listOferta != null && listOferta.size() > 0){  // RVI-289-FIX01 INICIO/FIM
			retornoOrchestrator = 'true';			
		}else{
			retornoOrchestrator = 'false';			
		}		
	}
	//***************** RVI-214 - FIM *****************

	//***************** RVI-262 e RVI-218 e RVI-223  INICIO **************
	//Método para enviar email
	public void enviarEmail(){
		//***************** RVI-262  e RVI-223 INICIO **************
        
		//RVI-262-FIX01-INICIO
 		EnviaEmailLink.Input input = EnviaEmailLink.parse(jsonEmail);
		retornoEmail = EnviaEmailLink.formatarEmail(input);//RVI-301
        //RVI-262-FIX01-FIM
		//***************** RVI-262  e RVI-223 FIM **************	
	}
	//***************** RVI-262 e RVI-218 e RVI-223  FIM *****************

	//***************** RVI-262 e RVI-223 INICIO **************
	@RemoteAction
	global static string getLink(String jsonRequest){
		System.debug('Teste getLink');
		API_Link_de_Pagamento__mdt mtd = API_Link_de_Pagamento__mdt.getInstance('API_Link_de_Pagamento_Email');
		APITokenizacaoService service = new APITokenizacaoService();
		HttpResponse responseToken = service.getToken(mtd);
		TokenApiLinkPgtoCartaoCredito tokenApiLinkPgtoCartaoCredito = new TokenApiLinkPgtoCartaoCredito(responseToken.getBody());
		HttpResponse responseEmail = service.getLinkPgtoCartaoCredito(jsonRequest, mtd, tokenApiLinkPgtoCartaoCredito);
		return responseEmail.getBody();
	}
	//***************** RVI-262 e RVI-223 FIM *****************
	//ANNVI-41 INICIO
	@RemoteAction
	//ANNVI-209 INICIO
	global static string getAntecipCom(String produtoSF){
		//List<Opportunity> orcamentoSF = OpportunityDAO.getInstance().buscarProduPorNumero(ofertaSelecionada);
		AltFormPgtoDAO formaPagDAO = new AltFormPgtoDAO();
		List<AntecipacaoComissao__c> listAntecipacao = formaPagDAO.verificaAntecipacaoProdEventoNovo(produtoSF);
		//ANNVI-209 FIM
		return JSON.serialize(listAntecipacao);
	}
	//ANNVI-41 FIM
	
    //VIAG-301 INICIO
	public static String buildResponse(List<Quote> quoteRecords) {

		// Construir o JSON usando mapas
		Map<String, Object> response = new Map<String, Object>();
	
		// Parte 1: 'validacoesEstruturais'
		response.put('validacoesEstruturais', new Map<String, Object>{
			'problemas' => new List<Object>(),
			'valido' => true
		});
	
		// Parte 2: 'retornoFinanceiro'
		response.put('retornoFinanceiro', new Map<String, Object>{
			'autorizacaoCartao' => new Map<String, Object>{
				'stargate' => new Map<String, Object>{
					'numeroReferencia' => '', // Se não houver valor específico, pode permanecer vazio
					'codigo' => 2, // Valor mockado, substitua se necessário
					'mensagem' => 'APROVADO', // Valor mockado, substitua se necessário
					'codigoGateway' => 0, // Valor mockado, substitua se necessário
					'mensagemGateway' => 'APROVADA', // Valor mockado, substitua se necessário
					'codigoAgrupamento' => quoteRecords.isEmpty() ? null : quoteRecords[0].Chave_de_Agrupamento__c
				},
				'portopag' => null // Valor mockado, substitua se necessário
			}
		});
	
		// Parte 3: 'devolutivasPropostas'
		List<Map<String, Object>> devolutivasPropostas = new List<Map<String, Object>>();
		Integer quoteIndex = 0;
		for (Quote quoteRecord : quoteRecords) {
			Integer qtdDiasVigencia = 0;
			if (quoteRecord.VigenciaFinal__c != null && quoteRecord.VigenciaInicial__c != null) {
				qtdDiasVigencia = quoteRecord.VigenciaInicial__c.daysBetween(quoteRecord.VigenciaFinal__c);
			}
	
			Map<String, Object> proposta = new Map<String, Object>{
				'vigenciaFinal' => String.valueOf(quoteRecord.VigenciaFinal__c),
				'numeroOrcamento' => Integer.valueOf(quoteRecord.Opportunity.ContadorOrcamento__c),
				'numero' => quoteRecord.NumeroProposta__c,
				'indice' => 1, // Valor mockado, substitua se necessário
				'qtdDiasVigencia' => qtdDiasVigencia,
				'origem' => Integer.valueOf(quoteRecord.Origem__c),
				'arquivos' => new List<Map<String, Object>>{
					new Map<String, Object>{
						'link' => quoteRecord.VoucherPdfDownloadUrl__c,
						'nome' => 'Voucher'
					}
				},
				'canalDistribuicao' => quoteRecord.CanalDistribuicao__r.Sigla__c,
				'codigoEmpresa' => 0, // Valor mockado, substitua se necessário
				'meioComercializacao' => quoteRecord.MeioComercializacao__c,
				'validadePagamento' => quoteRecord.DataLimitePagamento__c != null ? quoteRecord.DataLimitePagamento__c.format('yyyy-MM-dd HH:mm:ss') : null,
				'sucursal' => 1, // Valor mockado, substitua se necessário
				'ramoSeguro' => Integer.valueOf(quoteRecord.RamoSeguro__r.Codigo__c),
				'vigenciaInicial' => String.valueOf(quoteRecord.VigenciaInicial__c),
				'status' => quoteRecord.Status,
				'modalidade' => quoteRecord.Modalidade__r.Codigo__c,
				'dataCalculo' => String.valueOf(quoteRecord.DataCalculo__c)
			};
	
			devolutivasPropostas.add(new Map<String, Object>{
				'proposta' => proposta,
				'retornoAceitacao' => new Map<String, Object>{
					'pendencias' => new List<Object>(),
					'avisos' => new List<Object>(),
					'recusas' => new List<Object>(),
					'analises' => new List<Object>()
				}
			});
			quoteIndex++;
		}
	
		response.put('devolutivasPropostas', devolutivasPropostas);
	
		// Retornar o JSON como uma string
		return JSON.serialize(response);
	}	
    //VIAG-301 FIM

//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
public class ServiceException extends Exception { }
//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
}