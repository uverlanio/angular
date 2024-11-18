/*********************************************************************************************************************************************************************

@description  Classe que contem a Controller para o Formulario.
@author Renan Martins - Avanxo
@date 03/006/2019
@Hackathon Sniper Atualização 03/06/2019
@Classe criada por conta da história PLV-2318
	
**********************************************************************************************************************************************************************/

public without sharing class CtrFormularioSnipper {

	//PLV2533 - INÍCIO - Alterações da lógica para chamada do CIV Consultivo
	Object retornoSemConsultivo;
	String retSemConsultivoStr;
	public String dadosEntrada			{get;set;}
	public String setItem				{get;set;} //PLV-4016 & PLV-4039 - Inicio/Fim
	public String servicosEntrada		{get;set;}    
	//PLV2533 - FIM - Alterações da lógica para chamada do CIV Consultivo
	public String dados 				{get;set;}
	public String segmento 				{get;set;} //PLV-198 INICIO/FIM
	public String entradaCalculo 		{get;set;}	
	//Inicio da lógica para a história - PVL 2389
	public String entradaCalculo2 		{get;set;}	
	//Fim da lógica para a história - PVL 2389
	//public String ResponseOpcaoServico  {get;set;}	
	public String ofertaPadrao		    {get;set;}
	public String ofertaPersonalizada   {get;set;}
	public String opServico 			{get;set;}
	public String mdtGrupo 				{get;set;}		//PLV-3285
	
	public String strUrlResourceCss 	{get;set;} //PLV-3699
	//PLV-3890 - INICIO
	public String urlExterna {get;set;}
	//PLV-3890 - FIM
	//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
	//public String message				{get;set;}
	//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
	
	//PLV-4393 - Inicio
	public String localStorage 			{get;set;}
	public String paramsToReturn		{get;set;}
	public String jsonResponseCalculo 	{get;set;}
	public String jsonsLocalStorage		{get;set;}
	public String numOrcamentos			{get;set;}
	//PLV-4393 - Fim
	
	public String dadosReutilizados		{get;set;}//PLV-5441 - INICIO/FIM
	
	public String idContratoEndosso	{get;set;} //PLV-4650 - Inicio/Fim - Isabela Fin - Globant
	
	// AV-85 INICIO
	public String paramsPortoPlus 			 {get;set;}
	public String setItemVidaOn				 {get;set;}
	public String retornoLTM				 {get;set;}
	// AV-85 FIM
	//RVI-292 INICIO
	public String dataConvivencia = 'DATA_LIMITE_CONVIVENCIA';	 
	//RVI-292 FIM

	//ANNVI-208 - INICIO
	public static String nomeCompleto 				{get; set;}
    public static String dataNascimento 			{get; set;}
    public static String sexo 						{get; set;}
	public static String cpf 						{get; set;}
	//ANNVI-208 - FIM

	//private static final CtrFormularioSnipper instancia = new CtrFormularioSnipper();
	private static CIVServices civServ = CIVServices.getInstance();
    private static SensediaServices sensediaServ = SensediaServices.getInstance();//VIAG-271
	
	
	//Construtor (Início)
	public CtrFormularioSnipper() {
		//buscarJsonContentDocument(); //PLV-4393
			//PLV2533 - INÍCIO - Alterações da lógica para chamada do CIV Consultivo
			//Passa  os dados(JSON) para a Page pageFormularioSnipper
			//o "dados" Esta fazendo chamada também da classe CtrFormularioEntradaSniper

		try{	
			mdtGrupo = JSON.serialize( new  OrcamentoTO.MdtGrupoTO() );       // PLV-3285            
			if(Test.isRunningTest()){
				List<StaticResource> staticResList = [SELECT name, body FROM StaticResource 
														WHERE name = 'MockConsultivo' OR name = 'MockPagOferta'
														LIMIT 2];
				
				for(StaticResource SR : staticResList){ 
					if(SR.name == 'MockConsultivo'){
						dadosEntrada = SR.Body.toString(); 
					}else{
						entradaCalculo = SR.Body.toString();
					}
				}
				
				System.debug('DadosEntrada mocado - '+ dadosEntrada);
				System.debug('entradaCalculo mocado - '+ entradaCalculo);
			}else{
				//PLV-4782 - INÍCIO
				//PLV-3890 - INCIO	
				System.debug('dados >>: ' + dados);
				string validaEntradaCry = ApexPages.currentPage().getParameters().get('dados');	

				//RVI-292 INICIO
				System.debug('AleValidaEntrada: ' + validaEntradaCry);
				ContractBO.entradaConsultivo objetojsonValidaEntradaCry = (ContractBO.entradaConsultivo) System.JSON.deserialize(validaEntradaCry, ContractBO.entradaConsultivo.class);	
				System.debug('AleValidaEntrada2: ' + objetojsonValidaEntradaCry.consultivo.codigoOfertaConsultiva);
				
				for (Constante__mdt constante: MetadataDAO.getInstance().buscarConstantes(new Set < String > { dataConvivencia })) {
					Datetime dataLimiteConvivencia = Date.valueOf(constante.Valor__c);
					System.debug('dataLimiteConvivencia: ' + dataLimiteConvivencia);
					if (System.today() >= dataLimiteConvivencia && objetojsonValidaEntradaCry.consultivo.codigoOfertaConsultiva == 'VIDA_INDIVIDUAL'){
						objetojsonValidaEntradaCry.consultivo.codigoOfertaConsultiva = 'VIDA_INDIVIDUAL_VP';
						validaEntradaCry = JSON.serialize(objetojsonValidaEntradaCry);
					} 
				}
				System.debug('AleValidaEntrada ALTERADO: ' + validaEntradaCry);
				//RVI-292 FIM

				//PLV-4016 & PLV-4039 - Inicio
				string jsonEntradaConsultivo = validaEntradaCry.replaceAll('\n','').replaceAll('\\s+', '');
				//AV-85 INICIO
				System.debug('Entrada Consultiva****');
				System.debug(jsonEntradaConsultivo);
				ContractBO.paramsPortoPlus objetojsonEntradaConsultivo = (ContractBO.paramsPortoPlus) System.JSON.deserialize(jsonEntradaConsultivo, ContractBO.paramsPortoPlus.class);
				if(objetojsonEntradaConsultivo.consultivo.codigoOfertaConsultiva == 'VIAGEM_VIDA_ON'){
					map<String, String> mapEnvioCIVidaON = new map<String, String>();
					mapEnvioCIVidaON.put('id', objetojsonEntradaConsultivo.IDPortoVidaON);
					mapEnvioCIVidaON.put('campaignId', '23'); //AV-85 FIX 04 INICIO - FIM
					String jsonMapEnvioCIVidaON = JSON.serialize(mapEnvioCIVidaON);
					//MGRC-1256 - INICIO
					//String retorno = CIVServices.getInstance().servicoCIVLTM(jsonMapEnvioCIVidaON);
					String retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.CONSULTA_ID_PORTO_PLUS, jsonMapEnvioCIVidaON);
					//MGRC-1256 - FIM
					if(retorno == 'Erro na requisição'){
						String message =  '{'+
										+'  "message":"Erro no serviço. Entre em contato com o administrador."'+
												+'}';
				
							System.debug('Dentro do IF(retornoConsultivo = ERRO) no vida ON');
							System.debug('Message: ' + message);				
						
							retornoLTM = message;
					}else{
						retornoLTM = retorno;	
					}
				}
				
				//AV-85 FIM

				//PLV-198 INICIO FIX-01
				System.debug('Endosso***** '); 
				System.debug(objetojsonEntradaConsultivo);
				if(objetojsonEntradaConsultivo.consultivo.codigoOfertaConsultiva <> null){
					DecisaoOferta__c DecisaoOfertaSegmento = [SELECT Oferta__r.Segmento__c 
					FROM DecisaoOferta__c 
					WHERE InteligenciaOferta__r.GeradorOfertas__r.CodigoOfertaConsultiva__c =: objetojsonEntradaConsultivo.consultivo.codigoOfertaConsultiva 
					LIMIT 1];

					segmento = DecisaoOfertaSegmento.Oferta__r.Segmento__c;
				}else{
					segmento = 'Erro ao buscar segmento (parametro vazio)';
				}	
				//PLV-198 FIM FIX-01

				setItem = '<script> let jsonEntradaConsultivo = JSON.parse(\'' + jsonEntradaConsultivo + '\');' +
							'if(jsonEntradaConsultivo.consultivo && !jsonEntradaConsultivo.consultivo.voltar) window.localStorage.clear();' +
							'window.localStorage.setItem(\'entradaConsultivo\',\'' + jsonEntradaConsultivo + '\');</script>';
				//PLV-4016 & PLV-4039 - Fim
				//PLV-4782 - FIM 
				if(validaEntradaCry.contains('{')){
					dadosEntrada = validaEntradaCry;
				}else{
					CryptoToken c = new CryptoToken();
					String retorno = validaEntradaCry;
					retorno = retorno.replace(' ','+');
					system.debug('validaEntradaCry'+validaEntradaCry);
		
					String re = c.decrypt(retorno);
					dadosEntrada = re;
					system.debug('crypt'+re);
					Map<String,Object> mapJsonEntrada = (Map<String,Object>)JSON.deserializeUntyped(dadosEntrada);
					urlExterna = (String)mapJsonEntrada.get('URLExterna');
					system.debug('URLExterna'+urlExterna);
				}
				//PLV-3890 - FIM
				
				System.debug('CtrFormularioSnipper1 - '+ dadosEntrada);    
			}

				System.debug('XXX - DADOS ENTRADA - ' + dadosEntrada);
				System.debug('XXX - DADOS' + dados);

				//PLV-3699 - INICIO
				Map<String,Object> mEntrada = (Map<String,Object>) JSON.deserializeUntyped(dadosEntrada);
				// String recurso = mEntrada.get('estilo') == 'PADRAO'? 'pageSnippercss': 'pageSnippercssAlt';
				String recurso = 'pageSnippercss';
				StaticResource static_resource = [SELECT Id, Name, SystemModStamp, Body FROM StaticResource WHERE Name = :recurso LIMIT 1];
	
				strUrlResourceCss = '/resource/' + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime()) + '/' + static_resource.get('Name');
				// String url = '/resource/' + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime()) + '/' + static_resource.get('Name');
				// strUrlResourceCss = new PageReference(url).getContent().toString();
				//PLV-3699 - FIM
				
				//PLV-3890 - INICIO
				if(!String.isBlank(urlExterna)){
					strUrlResourceCss = urlExterna;
					system.debug('enrou css externo');
				}
				system.debug('strUrlResourceCss'+strUrlResourceCss);
				//PLV-3890 - FIM
				
				String retornoConsultivo; 
				retornoConsultivo = consultivo(dadosEntrada);

				system.debug('XXX - retornoConsultivo: '+ JSON.serialize(retornoConsultivo));
				
				if(retornoConsultivo == 'Erro na requisição'){
					String message =  '{'+
									+'  "message":"Erro no serviço. Entre em contato com o administrador."'+
											+'}';
			
					System.debug('Dentro do IF(retornoConsultivo = ERRO)');
					System.debug('Message: ' + message);				
					
					dados = message;
				}else{
					//Cria um Objeto com atributo e valor deserializando
					Map<String,Object> mRetorno = (Map<String,Object>) JSON.deserializeUntyped(retornoConsultivo);

					//Tira dentro do Objeto o Atributo 'consultivo' somente. 
					retornoSemConsultivo = mRetorno.get('consultivo');
					//Cria novamente a lista sem o Consultivo como início
					retSemConsultivoStr = JSON.serialize(retornoSemConsultivo);
					System.debug('retornoConsultivo != Erro --->>> ' + retSemConsultivoStr);

					//Chama a Pagina pageFormularioSnipper
					//Dados é variavel que tem o Json completo dentro 
					//page2 = Page.formularioSniper;
					//page2.getParameters().put('dados', retSemConsultivoStr);
					
					dados = retSemConsultivoStr;
				}            
			
				System.debug('XXX - DADOS' + dados);


				//PLV2533 - Remover trecho comentado abaixo.
			
				//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
				//Recebe o objeto de Retorno do Opção de Serviço e valida se houve retorno com erro.			
			/*	String retorno;
				retorno = consultaProfissao(ResponseOpcaoServico);	
				if(retorno == 'Erro na requisição'){
					dados = '{'+
								+'  "message":"Erro no serviço. Entre em contato com o administrador."'+
								+'}';		  
	
					System.debug('Dentro do IF - retorno');
	
				} else{
				opServico = retorno;
				System.debug('Dentro do ELSE - retorno');
				}  	
				System.debug('Retorno Consulta Profissão: '+ opServico);
				//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
			*/ 
			}catch(Exception ex){
				System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage()+ ' ST='+ ex.getStackTraceString());							
				throw new ServiceException('ERRO de serviço: ' + ex.getMessage() + ' Linha: ' + ex.getLineNumber());
			}
		//PLV2533 - FIM - Alterações da lógica para chamada do CIV Consultivo        			
	}
	
	//Redireciona a  Tela
	//Inicio da lógica para a história - PVL 2389
	public PageReference redirecionarTela() {
	
		//Chama a Pagina pageFormularioSnipper
		//Dados é variavel que tem o Json completo dentro 
		PageReference page3 = Page.PropostaSniper;
		
		return page3;
	
	}
	//Fim da lógica para a história - PVL 2389
	
	//Refencia Ofertas
	//AV-85 - INICIO
	public void pagOfertas() {
		//entradaCalculo Recebe parametros de Entrada do Calculo
		//calculoOfertas tras o Retorno do Calculo.
		//ofertaPadrao recebe o objeto de Retorno do Calculo
		//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.        
		
		jsonEntradaCalculo objetoEntradaCalculo = (jsonEntradaCalculo) System.JSON.deserialize(EntradaCalculo, jsonEntradaCalculo.class);
		System.debug('objetoEntradaCalculo: ' + objetoEntradaCalculo);
		map<String, Object> mapEntradaCalculo = new map<String, Object>();
		Boolean podeUtilizar = true;
		String msgRetorno = '';
		String seguroCPFAtivo = 'true';
		if(objetoEntradaCalculo.consultivo.codigoOfertaConsultiva == 'VIAGEM_VIDA_ON'){
      		mapEntradaCalculo.put('produto', objetoEntradaCalculo.consultivo.codigoOfertaConsultiva);
			//AV-564 INICIO
			for(resposta resposta : objetoEntradaCalculo.consultivo.respostas){
				if(resposta.id == 'DICIO_CPFVOUCHER') mapEntradaCalculo.put('cpf', resposta.conteudo);
				if(resposta.id == 'DICIO_VOUCHER') mapEntradaCalculo.put('voucher', resposta.conteudo);
			}
			System.debug('TESTE: ' +  JSON.serializePretty(mapEntradaCalculo));
			String jsonMap = JSON.serialize(mapEntradaCalculo);
			//AV-564 FIM

			ContractBO.ResponseHerokuConsultarVoucher responseConsultarVoucherVidaOn = HerokuService.getInstance().consultarVoucherVidaOn(jsonMap);
			String jsonResponseConsulta = JSON.serialize(responseConsultarVoucherVidaOn);

			podeUtilizar = responseConsultarVoucherVidaOn.dados[0].podeutilizar;
			msgRetorno = responseConsultarVoucherVidaOn.descricao;
		}
	
		ofertaPersonalizada = ''; //PLV-4698 - INÍCIO/FIM
		String retorno2;
		String ofertaPadraoVidaOn = '';
		String ofertaPadraoViagem = '';
		String ofertaPadraoRetornoCIV = '';
		
		if(!podeUtilizar){
			retorno2 = 'Erro na requisição'; 
			ofertaPadraoVidaOn = '{"message":"'+msgRetorno+'"}';
		} else {
			//chamada de serviço no CIV
			String seguroCPFAtivoMensagem = '';
			String mensagemTratadaRetornoCIV = ''; 
			String cpfConsultaSf = '';//VIDA-142 - INICIO/FIM
			if(objetoEntradaCalculo.consultivo.codigoOfertaConsultiva == 'VIAGEM_VIDA_ON'){
				ContractBO.DadosCPF cpfConsulta = new ContractBO.DadosCPF();
				// Ação emergencial VidaOn - INICIO
				for(resposta resposta : objetoEntradaCalculo.consultivo.respostas){
					if(resposta.id == 'DICIO_CPFVOUCHER'){
						cpfConsulta.cpf = resposta.conteudo.replace('-', '').replace('.', '');
						cpfConsultaSf = resposta.conteudo;//VIDA-142 - INICIO/FIM
					} 
				}
				System.debug('cpfConsulta 2: ' + cpfConsulta);
				// Ação emergencial VidaOn - FIM
				// MGRC-1255 - INICIO
				String retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.CONSULTA_CPF_ATIVO_LTM, JSON.serialize(cpfConsulta));
				System.debug('XXX - retorno ' + retorno);
				// MGRC-1255 - FIM
				//VIDA-142 - INICIO
				Map<String, Object> retornoData = (Map<String, Object>)JSON.deserializeUntyped(retorno);

				Boolean seguroVidaOnAtivo = (Boolean) retornoData.get('seguroVidaOnAtivo');
				System.debug('XXX - seguroVidaOnAtivo ' + seguroVidaOnAtivo);


				if(!seguroVidaOnAtivo){
					List<Contract> vidaOnActivedContracts = [SELECT Id 
															 FROM Contract 
															 WHERE Produto__r.Name ='Porto Vida ON' 
															 AND Status ='Emitido' 
															 AND Tipo__c != 'Cancelamento' 
															 AND Account.Cpf__c =:cpfConsultaSf];//VIDA-142 - INICIO/FIM

					System.debug('XXX - vidaOnActivedContracts ' + vidaOnActivedContracts);
															 
					seguroCPFAtivo = (vidaOnActivedContracts != null && !vidaOnActivedContracts.isEmpty()) ? 'true' : 'false';
					seguroCPFAtivoMensagem = seguroCPFAtivo == 'true' ? 'Processamento realizado com sucesso' : 'CPF não possui seguro VIDA ON ativo'; //VIDA-142 - INICIO/FIM
				}
				//AV-85 FIX 2 INICIO

				if(seguroVidaOnAtivo){
					Boolean multiplosSeguros = retorno.contains('"seguroVida":[');
					Boolean multiplasParcelas = retorno.contains('"parcelaSeguroVida":[');
					
					if(multiplasParcelas && !multiplosSeguros){
						ContractBO.RetornoCIVConsultaLTMList retObject = new ContractBO.RetornoCIVConsultaLTMList();
						retObject = (ContractBO.RetornoCIVConsultaLTMList) JSON.deserialize(retorno, ContractBO.RetornoCIVConsultaLTMList.class);
						seguroCPFAtivo = retObject.seguroVidaOnAtivo;
						seguroCPFAtivoMensagem = retObject.mensagemRetorno; 
					}else if(!multiplasParcelas && !multiplosSeguros){
						ContractBO.RetornoCIVConsultaLTMObject retObject = new ContractBO.RetornoCIVConsultaLTMObject();
						retObject = (ContractBO.RetornoCIVConsultaLTMObject) JSON.deserialize(retorno, ContractBO.RetornoCIVConsultaLTMObject.class);
						seguroCPFAtivo = retObject.seguroVidaOnAtivo;
						seguroCPFAtivoMensagem = retObject.mensagemRetorno; 
					}else if(multiplasParcelas && multiplosSeguros){
						ContractBO.RetornoCIVConsultaLTMMultiSegurosList retObject = new ContractBO.RetornoCIVConsultaLTMMultiSegurosList();
						retObject = (ContractBO.RetornoCIVConsultaLTMMultiSegurosList) JSON.deserialize(retorno, ContractBO.RetornoCIVConsultaLTMMultiSegurosList.class);
						seguroCPFAtivo = retObject.seguroVidaOnAtivo;
						seguroCPFAtivoMensagem = retObject.mensagemRetorno; 
					}else{
						ContractBO.RetornoCIVConsultaLTMMultiSegurosObject retObject = new ContractBO.RetornoCIVConsultaLTMMultiSegurosObject();
						retObject = (ContractBO.RetornoCIVConsultaLTMMultiSegurosObject) JSON.deserialize(retorno, ContractBO.RetornoCIVConsultaLTMMultiSegurosObject.class);
						seguroCPFAtivo = retObject.seguroVidaOnAtivo;
						seguroCPFAtivoMensagem = retObject.mensagemRetorno; 
					}
				}
				//VIDA-142 - FIM

				//AV-85 FIX 2 FIM
			}
			if(seguroCPFAtivo != 'true'){
				retorno2 = 'Erro na requisição';
				mensagemTratadaRetornoCIV = seguroCPFAtivoMensagem == 'Processamento realizado com sucesso' ? 'CPF não possui seguro VIDA ON ativo' : seguroCPFAtivoMensagem; //VIDA-142 - INICIO/FIM
				ofertaPadraoRetornoCIV = '{"message":"'+mensagemTratadaRetornoCIV+'"}';
			}else{
				retorno2 = calculoOfertas(entradaCalculo);
			}	
			ofertaPadraoViagem = '{"message":"Erro no serviço. Entre em contato com o administrador."}';
		}				   	
	
		if(retorno2 == 'Erro na requisição'){
			ofertaPadrao = podeUtilizar == true ? seguroCPFAtivo == 'true' ? ofertaPadraoViagem : ofertaPadraoRetornoCIV : ofertaPadraoVidaOn;
			System.debug('Dentro do IF - retorno2');
		}else{
			ofertaPadrao = retorno2;
		}  	
		//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
	}
	//AV-85 - FIM
	
	//PLV-4891 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
	public void gravaJsonCompleto(){
		System.debug('XXX - numOrcamentos ' + numOrcamentos);
		Set<String> setNumeros = (Set<String>) JSON.deserialize(numOrcamentos, Set<String>.class);
		List<Opportunity> lstOrcamentos = [SELECT Id, Name FROM Opportunity WHERE Numero__c IN :setNumeros];
		Map<String,Object> request = new Map<String,Object>();
		List<CreateFileREST.FileToInsert> itens = new List<CreateFileREST.FileToInsert>();
		for(Opportunity opp :lstOrcamentos){
			CreateFileREST.FileToInsert item = new CreateFileREST.FileToInsert();
			item.fileName = opp.Name + '_' + Datetime.now().format('dd-MM-yyyy_HH:mm:ss') + '_localStorage';
			item.fileBody = jsonsLocalStorage;
			item.recordId = opp.id;
			item.extensao = '.min.json';
			itens.add(item);
			//FileController.createTextFile(opp.Name + '_' + Datetime.now().format('dd-MM-yyyy_HH:mm:ss') + '_localStorage', jsonsLocalStorage, opp.Id, '.min.json');
		}
		request.put('itens',itens);
		if(!Test.isRunningTest())
		String retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, SensediaServices.CRIAR_ARQUIVO, JSON.serialize(request)); //MGRC-1267 - INICIO/FIM
	}
	//PLV-4891 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
	

	public void pagOfertaPersonalizada() {

		System.debug('pagOfertaPersonalizada()');
		System.debug('entradaCalculo2 ' + entradaCalculo2);
		
		//RVI-202 - INICIO
		OrcamentoEntradaCalcTO mapCalc2 = (OrcamentoEntradaCalcTO) System.JSON.deserialize(entradaCalculo2, OrcamentoEntradaCalcTO.class);
		System.debug('mapCalc2 -> ' + mapCalc2);
		
		ProductDAO produtoDao = ProductDAO.getInstance();
		String idProduto = produtoDao.buscarEmpresa14();

		for (Constante__mdt constante: MetadataDAO.getInstance().buscarConstantes(new Set < String > { dataConvivencia })) {
			Datetime dataLimiteConvivencia = Date.valueOf(constante.Valor__c);
			System.debug('dataLimiteConvivencia: ' + dataLimiteConvivencia);
			if (System.today() >= dataLimiteConvivencia ){
				mapCalc2.orcamento.idProdutoSf = idProduto;
				entradaCalculo2 = JSON.serialize(mapCalc2);
			}
		}
		System.debug('EntradaCalculo2 ALTERADO: ' + entradaCalculo2);
		//RVI-202 - FIM
		
		//ofertaPersonalizada recebe o objeto de Retorno do Calculo Personalizado
		//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
		String retorno3 = calculoOfertasPersonalizado(entradaCalculo2);
		
		System.debug('retorno3:'+retorno3);
	
		if(retorno3 == 'Erro na requisição'){
				ofertaPersonalizada = '{'+
								+'  "message":"Erro no serviço. Entre em contato com o administrador."'+
							+'}';
				System.debug('Dentro do IF - retorno3');
		}
		else{
			ofertaPersonalizada = retorno3;
			System.debug('Dentro do ELSE - retorno3');
		}
		system.debug('Retorno Oferta Personalizada: '+ ofertaPersonalizada);
		//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
	}
		
	
		//Busca o calculo do Serviço da CIVSERVICE
		public static String calculoOfertas(String calculosContrats) {
	
		//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
		String Response;

		try{

				//VIAG-271 - INICIO
				//MGRC-1489-INICIO
				Map<String, Object> calculosMap = (Map<String, Object>) JSON.deserializeUntyped(calculosContrats);
	
				if (calculosMap.containsKey('consultivo') && calculosMap.get('consultivo') != null) {
					Map<String, Object> consultivo = (Map<String, Object>) calculosMap.get('consultivo');
					String codigoOfertaConsultiva = (String) consultivo.get('codigoOfertaConsultiva');

					if (codigoOfertaConsultiva == 'VIAGEM' || codigoOfertaConsultiva == 'VIAGEM_VIDA_ON') { //ZSVEP-307-INICIO/FIM
						Response = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, SensediaServices.OFERTAS_CONTRATACAO_VIAGEM, calculosContrats);
					} else {
						// Response = civServ.criacaoCalculo(calculosContrats);
						// Verificações adicionais para diferentes valores de 'codigoOfertaConsultiva'
						switch on codigoOfertaConsultiva {
							//MGRC-1508-INICIO
							when 'VIDA_ON' {
								response = SensediaServices.getInstance().montagemServicoSensedia(
									SensediaServices.VERB.POST, 
									SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
									SensediaServices.OFERTAS_CONTRATACAO_VIDA_ON, 
									calculosContrats
								);
							}
							//MGRC-1508-FIM
							//MGRC-1506-INICIO
							when 'VIDA_INDIVIDUAL', 'VIDA_INDIVIDUAL_VP' {
								response = SensediaServices.getInstance().montagemServicoSensedia(
									SensediaServices.VERB.POST, 
									SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
									SensediaServices.OFERTAS_CONTRATACAO_VDSJ, 
									calculosContrats
								);
							}
							//MGRC-1506-FIM
							//MGRC-1507-INICIO
							when 'APTLMK' {
								response = SensediaServices.getInstance().montagemServicoSensedia(
									SensediaServices.VERB.POST, 
									SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
									SensediaServices.OFERTAS_CONTRATACAO_APTLMKT, 
									calculosContrats
								);
							}
							//MGRC-1507-FIM
						}
					}
				} else {
					//Response = civServ.criacaoCalculo(calculosContrats); //ZSVEP-288-INICIO/FIM
				}
				//VIAG-271 - FIM
				//MGRC-1489-FIM

			system.debug('Response Calculo Padrão ==>' + Response);
	
			//PLV-2607 - Inicio
			String mensagem = '';
			Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(Response);
			System.debug('result '+ result);
			if(result.get('recusas') != null){
				System.debug('tem recusa');
				RetornoTO retorno = (RetornoTO) JSON.deserialize(Response, CtrFormularioSnipper.RetornoTO.class);	
				System.debug('retorno '+ retorno);
				for(RecusaTO recusa: retorno.recusas){
					mensagem += recusa.mensagens.cliente + ',';
					System.debug('MENSAGEM '+ mensagem);
				}
			}
			if(mensagem != ''){
				String mensagemRetorno = '{ '+
							+' "message":"' +mensagem+''+
							+'"}' ;
				return mensagemRetorno;
			}
			//PLV-2607 - Fim
		}
		catch(Exception ex){
			System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage());
			throw new ServiceException('ERRO de serviço: ' + ex.getMessage() + ' Linha: ' + ex.getLineNumber());
		}	
			
		return Response;
		//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
	}
	//PLV-2607 - Inicio
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
	//PLV-2607 - Fim

	//MGRC-1489-INICIO
	//MGRC-1519-INICIO
	//método que Busca o Calculo Personalizado do Serviço da SENSEDIA SERVICES
		public static String calculoOfertasPersonalizado(String calculosContratsPersonalizado) {
		System.debug('calculoOfertasPersonalizado()');
		//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
		String ResponsePersonalizado;
		

		Map<String, Object> calculosMap = (Map<String, Object>) JSON.deserializeUntyped(calculosContratsPersonalizado);
		try{
            if (calculosMap.containsKey('orcamento') && calculosMap.get('orcamento') != null) {
                Map<String, Object> orcamentoMap = (Map<String, Object>) calculosMap.get('orcamento');
                if (orcamentoMap.containsKey('codigoProdutoVida') && orcamentoMap.get('codigoProdutoVida') != null) {
                    String codigoProdutoVida = (String) orcamentoMap.get('codigoProdutoVida');

					if (codigoProdutoVida == 'VI-PESSOAS') {
						System.debug('VDSJ Personalizado ' + codigoProdutoVida);
						ResponsePersonalizado = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, SensediaServices.OFERTAS_CONTRATACAO_PERSONALIZADA_VDSJ, calculosContratsPersonalizado);//SensediaServices.getInstance().chamadasViagem(calculosContrats, 'Ofertas_Contratacao_Viagem_Sensedia');
					} 
				}
			}
				// system.debug('###############################################################');
				// system.debug('Entrada Personalizado ==>' + calculosContratsPersonalizado);
				// ResponsePersonalizado = civServ.criacaoCalculo(calculosContratsPersonalizado);
				// system.debug('Response Calculo Personalizado ==>' + ResponsePersonalizado);	
		}catch(Exception ex){
				System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage()); 
				throw new ServiceException('ERRO de serviço: ' + ex.getMessage() + ' Linha: ' + ex.getLineNumber());
		}          
		//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
			
		return ResponsePersonalizado;
	}
	//MGRC-1489-FIM
	//MGRC-1519-FIM	
	
	//PLV2533 - INÍCIO - Alterações da lógica para chamada do CIV Consultivo
	//PLV2533 - Remover método consultaProfissao abaixo
	//Metódo que Busca o Opção de Serviço do Serviço da CIVSERVICE
	/*	public static String consultaProfissao(String servico) {
	
			//PLV-2411-Sniper - Início da lógica para tratamento de exceção.
			String ResponseOpcaoProfissao;
	
		try{
				ResponseOpcaoProfissao = civServ.opcaoServicos(servico);
				system.debug('Response Opção Serviço ==>' + ResponseOpcaoProfissao);
				
		}
		catch(Exception ex){
			System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage());
			//message = 'Erro de interface. Entre em contato com o administrador';
			throw new ServiceException('ERRO de serviço: ' + ex.getMessage() + ' Linha: ' + ex.getLineNumber());
		}
		//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
			
		return ResponseOpcaoProfissao;
	}
	*/    
	
	//PLV2533 - Adicionar metodo abaixo - Código migrado da classe ctrformularioEntradaSniper
	
	//Metodo Consultivo Retorno Json (CIV CONSULTIVO)	
	public static String consultivo(String jsonEntradaConsultivo) {
		system.debug('XXX - jsonEntradaConsultivo' + jsonEntradaConsultivo);
		
			String Response;			
	
		//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
		try{
			
			System.debug('Dentro do Metodo Consultivo -->> ' + jsonEntradaConsultivo);
			//busca o Json no Serviço SensediaServices método consultivoContratacao 
			//MGRC-1264 - INICIO			
			// Response = civServ.consultivoContratacao(jsonEntradaConsultivo);
			Response = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, SensediaServices.CONSULTIVO_CONTRATACAO, jsonEntradaConsultivo); //ANNVI-208 - INICIO/FIM
			//MGRC-1264 - FIM
			System.debug('XXX - Retorno da chamada do SensediaServices.ConsultivoContratacao ==>' + JSON.serialize(Response));
			
		}
		catch(Exception ex){       		
			System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage()+ 'ST='+ ex.getStackTraceString());
			throw new ServiceException('O seguinte ERRO ocorreu: ' + ex.getMessage());	
		}
		//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
	
		return Response;
	}
	
	//Metódo que Busca o Opção de Serviço do Serviço da CIVSERVICE
	public void consultaOpcoesTipoServico() { 
		String ResponseOpcaoProfissao;
		System.debug('ServicosEntrada: ' + servicosEntrada);
		List<OpcoesServicoTO> lstOpcoes = OpcoesServicoTO.parse(servicosEntrada);
		System.debug('lstOpcoes Henrique: ' + lstOpcoes);
		//PLV-4393 - Inicio
		Map<String, Object> mServicos = new Map<String, Object>();
		try{
			for(OpcoesServicoTO tipoServico : lstOpcoes){
					if(tipoServico.servico == 'paises'){//MGRC-1281 - INICIO
						ResponseOpcaoProfissao = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.GET, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.PAISES, tipoServico.body);//MGRC-1281 - FIM
					}else if(tipoServico.servico == 'Consulta_Banco'){//MGRC-1257 - INICIO
						ResponseOpcaoProfissao = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.CONSULTA_BANCO, tipoServico.body);
					//MGRC-1489-INICIO
						}else if(tipoServico.servico == 'Consulta_Profissao'){
						ResponseOpcaoProfissao = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.GET, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.CONSULTA_PROFISSAO, tipoServico.body);

					}else{
						// ResponseOpcaoProfissao = civServ.opcaoServicos(tipoServico); //PLV-4324 - Inicio/Fim
					//MGRC-1489-FIM	
						system.debug('Response Opção Serviço ==>' + ResponseOpcaoProfissao);
					}//MGRC-1257 - FIM
				
					mServicos.put(tipoServico.id, JSON.deserializeUntyped(ResponseOpcaoProfissao));
					System.debug('Map de serviços: ' + mServicos);
			}		
		}
		//PLV-4393 - Fim     
		catch(Exception ex){
			System.debug('###### Método consultaOpcoesTipoServico: (' + ex.getLineNumber() + '): ' + ex.getMessage());			
			String message =  '{"message":"Erro no serviço. Entre em contato com o administrador."}';           
		}
		opServico = JSON.serialize(mServicos);
		System.debug('mServicos serializado: ' + mServicos);
	}
	
	//PLV-3285 - Retorno Metadata - INICIO
	public static void buscaMetaGrupo(String grupo) {
		Constante__mdt mdt = new Constante__mdt();
		mdt = [	SELECT DeveloperName, Label, NamespacePrefix, QualifiedApiName, Valor__c 
		FROM Constante__mdt	WHERE Label = :grupo LIMIT 1];
	}
	//PLV-3285 - Retorno Metadata - FIM
	
	//PLV2533 - FIM - Alterações da lógica para chamada do CIV Consultivo
	
	//PLV-4393 - Inicio
	public void buscarJsonContentDocument(){
		System.debug('Y@ BUSCAR JSON');
		Map<String, Object> parameters = (Map<String,Object>) JSON.deserializeUntyped(paramsToReturn);
		
		
		if(parameters.containsKey('numOrcamento')){
	
			String numOrcamento = String.valueOf(parameters.get('numOrcamento'));
			// PLV-4891 INICIO
			
			ConsultaDocumentoRest.ConsultaParam orcamento = new ConsultaDocumentoRest.ConsultaParam();
			orcamento.orcamento = numOrcamento;
			String jsonBody = JSON.serialize(orcamento);
			//MGRC-1263 - INICIO
			// String responseString = CIVServices.getInstance().consultarDocumento(jsonBody);
			String responseString = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.CONSULTAR_DOCUMENTO, jsonBody);
			//MGRC-1263 - FIM
			System.debug('RESPONSE CONSULTAR DOCUMENTO');
			System.debug(responseString);
	
			ConsultaDocumentoRest.Response response = (ConsultaDocumentoRest.Response) JSON.deserialize(responseString,ConsultaDocumentoRest.Response.class);
			System.debug('XXX - ResponseDocument: ' + JSON.serialize(response));
			
			//PLV-4921 - INICIO
			if(!Test.isRunningTest()){
				ofertaPadrao = response.data.ofertaPadrao;
				localstorage = response.data.localstorage;
			}
			//PLV-4921 - FIM
			// PLV-4891 FIM
		}
	}
	public void resetOfertas() {
		if(jsonResponseCalculo != null)
			ofertaPadrao = jsonResponseCalculo;
	}
	//PLV-4393 - Fim
	
	//PLV-4650 - Inicio - Isabela Fin - Globant
	public PageReference redirecionaEndossoPage(){
		PageReference endossoPage = Page.GerarEndossoVidaIndividual;
		System.debug('idContratoEndosso >> ' + idContratoEndosso);
		endossoPage.getParameters().put('idContrato',idContratoEndosso);
		endossoPage.getParameters().put('getFromStorage','true');
		endossoPage.setRedirect(true);
		System.debug('redirecionaEndossoPage !!!');
		return endossoPage;
	}
	//PLV-4650 - Fim - Isabela Fin - Globant
	
	//PLV-4600 - INÍCIO - Yuri Olivatti
	public PageReference redirecionaEndossoViagemPage(){
		PageReference endossoPage = Page.GerarEndossoViagem;
		System.debug('idContratoEndosso >> ' + idContratoEndosso);
		endossoPage.getParameters().put('idContrato',idContratoEndosso);
		endossoPage.getParameters().put('getFromStorage','true');
		endossoPage.setRedirect(true);
		System.debug('redirecionaEndossoViagemPage !!!');
		return endossoPage;
	}
	//PLV-4600 - INÍCIO - Yuri Olivatti
	
	//PLV-5441 - INICIO
	
	public void reutilizarDados(){
		System.debug('dadosReutilizados '+ dadosReutilizados);
		
		String idAcc = '';
		String idQuote = '';
		String idSeguradoOrca = ''; //PLV-5474 - INICIO/FIM
		String idResponsavel = ''; //PLV-5476 - INICIO/FIM
		String CEPResponsavel = '';
		clonar clonar = new clonar();		
			
		string validaEntradaCry = ApexPages.currentPage().getParameters().get('dados');
		string jsonEntradaConsultivo = validaEntradaCry.replaceAll('\n','').replaceAll('\\s+', '');		
		System.debug('validaEntradaCry '+ validaEntradaCry);
		System.debug('jsonEntradaConsultivo '+ jsonEntradaConsultivo);
	
		ContractBO.paramsPortoPlus objetojsonEntradaConsultivo = (ContractBO.paramsPortoPlus) System.JSON.deserialize(jsonEntradaConsultivo, ContractBO.paramsPortoPlus.class);

		System.debug('QUERY - entrada'+ objetojsonEntradaConsultivo.consultivo.nProposta);

		if((objetojsonEntradaConsultivo.consultivo.codigoOfertaConsultiva == 'VIDA_INDIVIDUAL' || objetojsonEntradaConsultivo.consultivo.codigoOfertaConsultiva == 'VIDA_INDIVIDUAL_VP' || objetojsonEntradaConsultivo.consultivo.codigoOfertaConsultiva == 'APTLMK') && objetojsonEntradaConsultivo.consultivo.nProposta != null){//PLV-5441 FIX-01 - INICIO/FIM || // RVI-238-INICIO/FIM  //II-56 INICIO/FIM
			String quoteNum = objetojsonEntradaConsultivo.consultivo.nProposta;

			//PLV-5643 - INICIO
			List<SeguradoProposta__c> lstSeguradoOrca = [SELECT Id, Fumante__c, Profissao__r.Codigo__c,
																RegimeTrabalho__c, FaixaRenda__c, Conta__r.EstadoCivil__c, CicloVacinal__c, Conta__r.Cpf__c,
																Conta__r.PersonBirthdate,Conta__r.Sexo__c, Conta__r.TipoDocidentificacao__c,Conta__r.Rg__c,
																Conta__r.OrgaoExpedidor__c, Conta__r.DataExpedicao__c, Reside_no_Brasil__c, Pais_Residente__c,
																Conta__r.Name,PEP__c,TemDependentes__c,EmpresaTrabalhaSocio__c,RamoAtividade__c,tipoEmpresa__c,
																numeroCnpj__c,qtdFuncionarios__c,Email__c,Celular__c,Telefone_comercial__c,PremioTotal__c, 
																Telefone_residencial__c,Renda__c,Conta__r.Nacionalidade__c,cepResidencial__c,logradouroResidencial__c,
																numeroResidencial__c,ComplementoResidencial__c,bairroResidencial__c, CidadeResidencial__c,
																UFResidencial__c,CEPComercial__c,LogradouroComercial__c,NumeroComercial__c,ComplementoComercial__c,
																BairroComercial__c,CidadeComercial__c,UFComercial__c, ResponsavelFinanceiroSeguro__c,ResponsavelPagamento__c,
																NomeResponsavel__c,CpfResponsavel__c,VinculoComSegurado__c,ResponsavelPagamento__r.Sexo__c,
																ResponsavelPagamento__r.PersonBirthdate, ResponsavelPagamento__r.EstadoCivil__c, 
																ResponsavelPagamento__r.PersonEmail, ResponsavelPagamento__r.BillingPostalCode,ResponsavelPagamento__r.BillingStreet,
																ResponsavelPagamento__r.BillingState, ResponsavelPagamento__r.BillingCity,ResponsavelPagamento__r.PersonMobilePhone,
																ResponsavelPagamento__r.PersonHomePhone, ResponsavelPagamento__r.Phone, GrupoProposta__r.ContratanteProposta__r.Proposta__r.Id			
															FROM SeguradoProposta__c 
															WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__r.Name=:quoteNum LIMIT 1];	
															
			System.debug('QUERY - lstSeguradoOrca: ' + JSON.serialize(lstSeguradoOrca));
			
			if(!lstSeguradoOrca.IsEmpty()){
				idSeguradoOrca = lstSeguradoOrca[0].Id; //PLV-5474 - INICIO/FIM
				idResponsavel = lstSeguradoOrca[0].ResponsavelPagamento__c; //PLV-5476 - INICIO/FIM
				CEPResponsavel = lstSeguradoOrca[0].ResponsavelPagamento__r.BillingPostalCode;
				idAcc = lstSeguradoOrca[0].Conta__c;
				idQuote = lstSeguradoOrca[0].GrupoProposta__r.ContratanteProposta__r.Proposta__r.Id;
				
				Quote proposta = [SELECT Id,TermoGuarda__c,Data_da_recusa__c,Status,StatusProponente__c,(SELECT Id,Codigo__c,Descricao__c,Status__c FROM CriticasProposta__r) FROM Quote WHERE Id =:idQuote LIMIT 1];
				System.debug('QUERY - proposta: ' + JSON.serialize(proposta));

				FavorecidoRemuneracaoProposta__c favorecido = [SELECT Id,CorretorLider__c,CorretorResponde__c
																FROM FavorecidoRemuneracaoProposta__c 
																WHERE CorretorLider__c = true AND RemuneracaoProposta__r.Proposta__c =:idQuote];

				System.debug('QUERY - favorecido: ' + JSON.serialize(favorecido));


							
				clonar.DICIO_REAPROVEITAR_ASSINATURA		= String.valueOf(getReaproveitarAssinatura(proposta, favorecido));
				clonar.DICIO_TOTAL							= String.valueOf(lstSeguradoOrca[0].PremioTotal__c);
			}
			//PLV-5643 - FIM

			List<Endereco__c> lstEndResponsavel = [SELECT Id,TipoEndereco__c,Bairro__c,Numero__c FROM Endereco__c 
													WHERE Conta__c =:idResponsavel AND MaisAtual__c = true AND CEP__c =:CEPResponsavel
													ORDER BY CreatedDate DESC LIMIT 1]; //PLV-5476 - INICIO/FIM

			System.debug('QUERY - lstEndResponsavel: ' + JSON.serialize(lstEndResponsavel));

			//PLV-5474 - INICIO
			List<BeneficiarioSeguradoProposta__c> lstBeneficiarioProposta = [SELECT Id,TipoBeneficiario__c,Nome__c,CpfCnpj__c,Data_de_nascimento__c,Sexo__c,GrauParentesco__c,PercentualIndenizacao__c,ImprimirCertificadoSeguro__c, Participacao__c  // RVI-263 - INICIO/FIM
																				FROM BeneficiarioSeguradoProposta__c WHERE SeguradoProposta__c =:idSeguradoOrca];															

			System.debug('QUERY - lstBeneficiarioProposta: ' + JSON.serialize(lstBeneficiarioProposta));

			//II-56 INICIO																
			List<GarantiaProposta__c > lstGarantiaProposta = [SELECT id, Name, Garantia__r.Name, Garantia__r.Sigla__c, Capital__c FROM GarantiaProposta__c Where Proposta__r.Id =: idQuote ];	
			System.debug('QUERY - lstGarantiaProposta: ' + JSON.serialize(lstGarantiaProposta));
			//II-56 FIM

			if(!lstBeneficiarioProposta.IsEmpty()){
				for(BeneficiarioSeguradoProposta__c benef : lstBeneficiarioProposta){
					beneficiario benefic = new beneficiario();
					benefic.DICIO_BENEFTIPO 		= String.valueOf(benef.TipoBeneficiario__c);
					benefic.DICIO_BENEFNOME 		= String.valueOf(benef.Nome__c);
					benefic.DICIO_BENEFCPF 			= String.valueOf(benef.CpfCnpj__c);
					benefic.DICIO_BENEFDATA 		= String.valueOf(benef.Data_de_nascimento__c);
					benefic.DICIO_BENEFSEXO 		= String.valueOf(benef.Sexo__c);
					benefic.DICIO_BENEFPAREN 		= String.valueOf(benef.GrauParentesco__c);
					benefic.DICIO_BENEFPERCEN 		= String.valueOf(benef.PercentualIndenizacao__c);
					benefic.DICIO_BENEFIMPRIMI 		= String.valueOf(benef.ImprimirCertificadoSeguro__c);


					if(clonar.DICIO_LSTBENEF == null){
						clonar.DICIO_LSTBENEF = new List<beneficiario>();
					}
					clonar.DICIO_LSTBENEF.add(benefic);
				}
			}
			//PLV-5474 - FIM
			
			List<Endereco__c> lstEnderecoComercial = [SELECT Id, TipoEndereco__c, CEP__c, Logradouro__c,Numero__c,Complemento__c,Bairro__c, Cidade__c,Estado__c
														FROM Endereco__c WHERE Conta__c =:idAcc AND TipoEndereco__c = 'Comercial' ORDER BY CreatedDate DESC LIMIT 1];

			System.debug('QUERY - lstEnderecoComercial: ' + JSON.serialize(lstEnderecoComercial));


			List<Endereco__c> lstEnderecoResidencial = [SELECT Id, TipoEndereco__c, CEP__c, Logradouro__c,Numero__c,Complemento__c,Bairro__c, Cidade__c,Estado__c
														FROM Endereco__c WHERE Conta__c =:idAcc AND TipoEndereco__c = 'Residencial' ORDER BY CreatedDate DESC LIMIT 1];

			System.debug('QUERY - lstEnderecoResidencial: ' + JSON.serialize(lstEnderecoResidencial));

			
			List<RemuneracaoProposta__c> lstReutilizarRemuneracao = [SELECT Id, Name, TipoRemuneracao__c, TipoRemuneracao__r.Name, Percentual__c 
																		FROM RemuneracaoProposta__c WHERE Proposta__c =:idQuote ORDER BY TipoRemuneracao__r.Name ASC LIMIT 2];	

			System.debug('QUERY - lstReutilizarRemuneracao: ' + JSON.serialize(lstReutilizarRemuneracao));

			//PLV-5636 - INICIO
			List<FavorecidoRemuneracaoProposta__c> lstFavorecidoRemuneracao = [SELECT id,Conta__r.Name, Conta__r.Cpf__c, Conta__r.C_digo_do_Agenciador__c,Papel__c, Susep__c ,SusepOficialCorretor__c,RemuneracaoProposta__r.TipoRemuneracao__r.Name , Conta__r.Cnpj__c
																				 FROM FavorecidoRemuneracaoProposta__c WHERE RemuneracaoProposta__r.Proposta__c =: idQuote AND RemuneracaoProposta__r.TipoRemuneracao__r.Name = 'AGENCIAMENTO' LIMIT 1];	
									
			System.debug('QUERY - lstFavorecidoRemuneracao: ' + JSON.serialize(lstFavorecidoRemuneracao));

			//PLV-5636 - FIM
			
			clonar.DICIO_ORIGEM							= quoteNum;
			clonar.DICIO_AGENCIAMENTO 					= '';
			clonar.DICIO_CORRETAGEM 					= '';
			clonar.DICIO_CICLOCOVID						= '';
			clonar.DICIO_ENDERECOCOM_CEP				= '';
			clonar.DICIO_ENDERECOCOM_LOGRADOURO			= '';
			clonar.DICIO_ENDERECOCOM_NUMERO				= '';
			clonar.DICIO_ENDERECOCOM_COMPLEMENTO		= '';
			clonar.DICIO_ENDERECOCOM_BAIRRO				= '';
			clonar.DICIO_ENDERECOCOM_CIDADE				= '';
			clonar.DICIO_ENDERECOCOM_ESTADO				= '';
			clonar.DICIO_ENDERECORES_CEP				= '';
			clonar.DICIO_ENDERECORES_LOGRADOURO			= '';
			clonar.DICIO_ENDERECORES_NUMERO				= '';
			clonar.DICIO_ENDERECORES_COMPLEMENTO		= '';
			clonar.DICIO_ENDERECORES_BAIRRO				= '';
			clonar.DICIO_ENDERECORES_CIDADE				= '';
			clonar.DICIO_ENDERECORES_ESTADO				= '';
			//PLV-5476 - INICIO
			clonar.DICIO_RESPONSAVEL					= '';
			clonar.DICIO_RESPONSAVELNAME				= '';
			clonar.DICIO_RESPONSAVELCPF					= '';
			clonar.DICIO_RESPONSAVELVINCULO				= '';
			clonar.DICIO_RESPONSAVELSEXO				= '';
			clonar.DICIO_RESPONSAVELDATA				= '';
			clonar.DICIO_RESPONSAVELCIVIL				= '';
			clonar.DICIO_RESPONSAVELEMAIL				= '';
			clonar.DICIO_RESPONSAVELCEP					= '';
			clonar.DICIO_RESPONSAVELTIPO				= '';
			clonar.DICIO_RESPONSAVELBAIRRO				= '';
			clonar.DICIO_RESPONSAVELNUMERO				= '';
			clonar.DICIO_RESPONSAVELRUA					= '';
			clonar.DICIO_RESPONSAVELESTADO				= '';
			clonar.DICIO_RESPONSAVELCIDADE				= '';
			clonar.DICIO_RESPONSAVELTELEFONE1			= '';
			clonar.DICIO_RESPONSAVELTELEFONE2			= '';
			clonar.DICIO_RESPONSAVELTELEFONE3			= '';
			//PLV-5476 - FIM

			if(!lstSeguradoOrca.IsEmpty()){				
				clonar.DICIO_NOME 							= String.valueOf(lstSeguradoOrca[0].Conta__r.Name);//PLV-5606 - INICIO/FIM
				clonar.DICIO_DATANASCIMENTO 				= String.valueOf(lstSeguradoOrca[0].Conta__r.PersonBirthdate);
				clonar.DICIO_DEPENDENTES					= String.valueOf(lstSeguradoOrca[0].TemDependentes__c);
				clonar.DICIO_SEXO							= String.valueOf(lstSeguradoOrca[0].Conta__r.Sexo__c);
				clonar.DICIO_FUMANTE						= String.valueOf(lstSeguradoOrca[0].Fumante__c);
				clonar.DICIO_PROFISSAO						= String.valueOf(lstSeguradoOrca[0].Profissao__r.Codigo__c);
				clonar.DICIO_REGIME_TRABALHO				= String.valueOf(lstSeguradoOrca[0].RegimeTrabalho__c);
				clonar.DICIO_FAIXARENDA						= String.valueOf(lstSeguradoOrca[0].FaixaRenda__c);
				clonar.DICIO_RENDA							= String.valueOf(lstSeguradoOrca[0].Renda__c);
				clonar.DICIO_EMAIL							= String.valueOf(lstSeguradoOrca[0].Email__c);
				clonar.DICIO_TELEFONERES					= String.valueOf(lstSeguradoOrca[0].Telefone_residencial__c);
				clonar.DICIO_TELEFONECOM					= String.valueOf(lstSeguradoOrca[0].Telefone_comercial__c);
				clonar.DICIO_CELULAR						= String.valueOf(lstSeguradoOrca[0].Celular__c);
				clonar.DICIO_CICLOCOVID						= String.valueOf(lstSeguradoOrca[0].CicloVacinal__c);				
				clonar.DICIO_CPF							= String.valueOf(lstSeguradoOrca[0].Conta__r.Cpf__c);
				clonar.DICIO_TIPO_DOCIDENTIFICACAO			= String.valueOf(lstSeguradoOrca[0].Conta__r.TipoDocidentificacao__c);
				clonar.DICIO_DOCIDENTIFICACAO				= String.valueOf(lstSeguradoOrca[0].Conta__r.Rg__c);
				clonar.DICIO_ORGAOEXPEDIDOR					= String.valueOf(lstSeguradoOrca[0].Conta__r.OrgaoExpedidor__c);
				clonar.DICIO_DATAEXPEDICAO					= String.valueOf(lstSeguradoOrca[0].Conta__r.DataExpedicao__c);
				clonar.DICIO_EMPRESA						= String.valueOf(lstSeguradoOrca[0].EmpresaTrabalhaSocio__c);
				clonar.DICIO_RAMOATIVIDADE					= String.valueOf(lstSeguradoOrca[0].RamoAtividade__c);
				clonar.DICIO_TIPOEMPRESA					= String.valueOf(lstSeguradoOrca[0].tipoEmpresa__c);
				clonar.DICIO_CNPJMEI						= String.valueOf(lstSeguradoOrca[0].numeroCnpj__c);
				clonar.DICIO_QTDFUNCIONARIOS				= String.valueOf(lstSeguradoOrca[0].qtdFuncionarios__c);
				clonar.DICIO_ESTADOCIVIL					= String.valueOf(lstSeguradoOrca[0].Conta__r.EstadoCivil__c);
				clonar.DICIO_NACIONALIDADE					= String.valueOf(lstSeguradoOrca[0].Conta__r.Nacionalidade__c);
				clonar.DICIO_RESIDEBRASIL					= String.valueOf(lstSeguradoOrca[0].Reside_no_Brasil__c);
				clonar.DICIO_PAIS							= String.valueOf(lstSeguradoOrca[0].Pais_Residente__c);
				clonar.DICIO_PEP							= String.valueOf(lstSeguradoOrca[0].PEP__c);
				
				clonar.DICIO_ENDERECORES_CEP				= String.valueOf(lstSeguradoOrca[0].cepResidencial__c);
				clonar.DICIO_ENDERECORES_LOGRADOURO			= String.valueOf(lstSeguradoOrca[0].logradouroResidencial__c);
				clonar.DICIO_ENDERECORES_NUMERO				= String.valueOf(lstSeguradoOrca[0].numeroResidencial__c);
				clonar.DICIO_ENDERECORES_COMPLEMENTO		= String.valueOf(lstSeguradoOrca[0].ComplementoResidencial__c);
				clonar.DICIO_ENDERECORES_BAIRRO				= String.valueOf(lstSeguradoOrca[0].bairroResidencial__c);
				clonar.DICIO_ENDERECORES_CIDADE				= String.valueOf(lstSeguradoOrca[0].CidadeResidencial__c);
				clonar.DICIO_ENDERECORES_ESTADO				= String.valueOf(lstSeguradoOrca[0].UFResidencial__c);
				//PLV-5441 FIX02 - INICIO
				if(clonar.DICIO_ENDERECORES_CEP	== null && clonar.DICIO_ENDERECORES_LOGRADOURO == null &&
				clonar.DICIO_ENDERECORES_NUMERO	== null && clonar.DICIO_ENDERECORES_COMPLEMENTO == null &&
				clonar.DICIO_ENDERECORES_BAIRRO == null && clonar.DICIO_ENDERECORES_CIDADE == null && clonar.DICIO_ENDERECORES_ESTADO == null){
				//PLV-5441 FIX02 - FIM
					if(!lstEnderecoResidencial.IsEmpty()){
					clonar.DICIO_ENDERECORES_CEP					= String.valueOf(lstEnderecoResidencial[0].CEP__c);
					clonar.DICIO_ENDERECORES_LOGRADOURO				= String.valueOf(lstEnderecoResidencial[0].Logradouro__c);
					clonar.DICIO_ENDERECORES_NUMERO					= String.valueOf(lstEnderecoResidencial[0].Numero__c);
					clonar.DICIO_ENDERECORES_COMPLEMENTO			= String.valueOf(lstEnderecoResidencial[0].Complemento__c);
					clonar.DICIO_ENDERECORES_BAIRRO					= String.valueOf(lstEnderecoResidencial[0].Bairro__c);
					clonar.DICIO_ENDERECORES_CIDADE					= String.valueOf(lstEnderecoResidencial[0].Cidade__c);
					clonar.DICIO_ENDERECORES_ESTADO					= String.valueOf(lstEnderecoResidencial[0].Estado__c);
					}
				}
				clonar.DICIO_ENDERECOCOM_CEP				= String.valueOf(lstSeguradoOrca[0].CEPComercial__c);
				clonar.DICIO_ENDERECOCOM_LOGRADOURO			= String.valueOf(lstSeguradoOrca[0].LogradouroComercial__c);
				clonar.DICIO_ENDERECOCOM_NUMERO				= String.valueOf(lstSeguradoOrca[0].NumeroComercial__c);
				clonar.DICIO_ENDERECOCOM_COMPLEMENTO		= String.valueOf(lstSeguradoOrca[0].ComplementoComercial__c);
				clonar.DICIO_ENDERECOCOM_BAIRRO				= String.valueOf(lstSeguradoOrca[0].BairroComercial__c);
				clonar.DICIO_ENDERECOCOM_CIDADE				= String.valueOf(lstSeguradoOrca[0].CidadeComercial__c);
				clonar.DICIO_ENDERECOCOM_ESTADO				= String.valueOf(lstSeguradoOrca[0].UFComercial__c);
				//PLV-5441 FIX02 - INICIO
				if(clonar.DICIO_ENDERECOCOM_CEP	== null && clonar.DICIO_ENDERECOCOM_LOGRADOURO == null &&
				clonar.DICIO_ENDERECOCOM_NUMERO	== null && clonar.DICIO_ENDERECOCOM_COMPLEMENTO == null &&
				clonar.DICIO_ENDERECOCOM_BAIRRO == null && clonar.DICIO_ENDERECOCOM_CIDADE == null && clonar.DICIO_ENDERECOCOM_ESTADO == null){
				//PLV-5441 FIX02 - FIM
					if(!lstEnderecoComercial.IsEmpty()){
						clonar.DICIO_ENDERECOCOM_CEP					= String.valueOf(lstEnderecoComercial[0].CEP__c);
						clonar.DICIO_ENDERECOCOM_LOGRADOURO				= String.valueOf(lstEnderecoComercial[0].Logradouro__c);
						clonar.DICIO_ENDERECOCOM_NUMERO					= String.valueOf(lstEnderecoComercial[0].Numero__c);
						clonar.DICIO_ENDERECOCOM_COMPLEMENTO			= String.valueOf(lstEnderecoComercial[0].Complemento__c);
						clonar.DICIO_ENDERECOCOM_BAIRRO					= String.valueOf(lstEnderecoComercial[0].Bairro__c);
						clonar.DICIO_ENDERECOCOM_CIDADE					= String.valueOf(lstEnderecoComercial[0].Cidade__c);
						clonar.DICIO_ENDERECOCOM_ESTADO					= String.valueOf(lstEnderecoComercial[0].Estado__c);
					}
				}				
				//PLV-5476 - INICIO
				clonar.DICIO_RESPONSAVEL					= String.valueOf(lstSeguradoOrca[0].ResponsavelFinanceiroSeguro__c);
				clonar.DICIO_RESPONSAVELNAME				= String.valueOf(lstSeguradoOrca[0].NomeResponsavel__c);
				clonar.DICIO_RESPONSAVELCPF					= String.valueOf(lstSeguradoOrca[0].CpfResponsavel__c);
				clonar.DICIO_RESPONSAVELVINCULO				= String.valueOf(lstSeguradoOrca[0].VinculoComSegurado__c);
				clonar.DICIO_RESPONSAVELSEXO				= String.valueOf(lstSeguradoOrca[0].ResponsavelPagamento__r.Sexo__c);
				clonar.DICIO_RESPONSAVELDATA				= String.valueOf(lstSeguradoOrca[0].ResponsavelPagamento__r.PersonBirthdate);
				clonar.DICIO_RESPONSAVELCIVIL				= String.valueOf(lstSeguradoOrca[0].ResponsavelPagamento__r.EstadoCivil__c);
				clonar.DICIO_RESPONSAVELEMAIL				= String.valueOf(lstSeguradoOrca[0].ResponsavelPagamento__r.PersonEmail);
				clonar.DICIO_RESPONSAVELCEP					= String.valueOf(lstSeguradoOrca[0].ResponsavelPagamento__r.BillingPostalCode);
				if(!lstEndResponsavel.IsEmpty()){
					clonar.DICIO_RESPONSAVELTIPO					= String.valueOf(lstEndResponsavel[0].TipoEndereco__c);
					clonar.DICIO_RESPONSAVELBAIRRO					= String.valueOf(lstEndResponsavel[0].Bairro__c);
					clonar.DICIO_RESPONSAVELNUMERO					= String.valueOf(lstEndResponsavel[0].Numero__c);
				}
				clonar.DICIO_RESPONSAVELRUA					= String.valueOf(lstSeguradoOrca[0].ResponsavelPagamento__r.BillingStreet);
				clonar.DICIO_RESPONSAVELESTADO				= String.valueOf(lstSeguradoOrca[0].ResponsavelPagamento__r.BillingState);
				clonar.DICIO_RESPONSAVELCIDADE				= String.valueOf(lstSeguradoOrca[0].ResponsavelPagamento__r.BillingCity);
				clonar.DICIO_RESPONSAVELTELEFONE1			= String.valueOf(lstSeguradoOrca[0].ResponsavelPagamento__r.PersonMobilePhone);
				clonar.DICIO_RESPONSAVELTELEFONE2			= String.valueOf(lstSeguradoOrca[0].ResponsavelPagamento__r.PersonHomePhone);
				clonar.DICIO_RESPONSAVELTELEFONE3			= String.valueOf(lstSeguradoOrca[0].ResponsavelPagamento__r.Phone);
				//PLV-5476 - FIM				
			}			
			if(!lstReutilizarRemuneracao.IsEmpty()){
				clonar.DICIO_CORRETAGEM						= String.valueOf(lstReutilizarRemuneracao[0].Percentual__c.intValue()); //II-56 INICIO-FIM
				if(lstReutilizarRemuneracao[0].TipoRemuneracao__r.Name == 'AGENCIAMENTO'){
					clonar.DICIO_AGENCIAMENTO 				= String.valueOf(lstReutilizarRemuneracao[0].Percentual__c.intValue()); //II-56 INICIO-FIM
					clonar.DICIO_CORRETAGEM 				= String.valueOf(lstReutilizarRemuneracao[1].Percentual__c.intValue()); //II-56 INICIO-FIM
				}					
			}
			//PLV-5636 - INICIO
			if(!lstFavorecidoRemuneracao.IsEmpty()){
				clonar.DICIO_NOME_AGENCIADOR                = String.valueOf(lstFavorecidoRemuneracao[0].Conta__r.Name);
				clonar.DICIO_CPF_AGENCIADOR					= String.valueOf(lstFavorecidoRemuneracao[0].Conta__r.Cpf__c);
				clonar.DICIO_CODIGOAGENCIADOR				= String.valueOf(lstFavorecidoRemuneracao[0].Conta__r.C_digo_do_Agenciador__c);
				clonar.DICIO_SUSEPAGENCIADOR				= String.valueOf(lstFavorecidoRemuneracao[0].Susep__c);
				clonar.DICIO_TIPOREMUNERACAO                = String.valueOf(lstFavorecidoRemuneracao[0].Papel__c);
				clonar.DICIO_CNPJ_AGENCIADOR				= String.valueOf(lstFavorecidoRemuneracao[0].Conta__r.Cnpj__c);
			}//PLV-5636 - FIM
			//II-56 INICIO
			if(!lstGarantiaProposta.IsEmpty()){
				boolean afiOuAff = false;
				boolean ckup = false;
				boolean ipaOuMap = false;
				boolean dia = false;
				boolean dit = false;
				for (GarantiaProposta__c garProp : lstGarantiaProposta) {
					if (garProp.Garantia__r.Sigla__c == 'AFI' || garProp.Garantia__r.Sigla__c == 'AFF') {
						clonar.DICIO_FUNERAL = garProp.Garantia__r.Sigla__c;
						afiOuAff = true;
					} else if (garProp.Garantia__r.Sigla__c == 'DIA') {
						clonar.DICIO_DIA = garProp.Garantia__r.Sigla__c;
						dia = true;
					} else if (garProp.Garantia__r.Sigla__c == 'DITA') {
						clonar.DICIO_DIT = garProp.Garantia__r.Sigla__c;
						dit = true;
					} else if (garProp.Garantia__r.Sigla__c == 'IPA' || garProp.Garantia__r.Sigla__c == 'MAP') {
						clonar.DICIO_CAPITAL = String.valueOf(garProp.Capital__c.intValue());
					} else if (garProp.Garantia__r.Sigla__c == 'CKUP') {
						clonar.DICIO_CHECKUP = garProp.Garantia__r.Sigla__c;
						ckup = true;
					}
				}
				
				if(!dit){
					clonar.DICIO_DIT = 'NAO_CONTRATADA';
				}
				if(!ckup){
					clonar.DICIO_CHECKUP = 'NÃO_CONTRATADA'; //II-56 FIX01 INICO-FIM
				}
				if(!dia){
					clonar.DICIO_DIA = 'NAO_CONTRATADA';
				}
				if(!afiOuAff){
					clonar.DICIO_FUNERAL = 'NAO_CONTRATADA';
				}
			}
			//II-56 FIM

			
			this.dadosReutilizados = JSON.serialize(clonar);
		}
	}
	
	//PLV-5441 - FIM

	//PLV-5643 - INICIO
	public static Boolean getReaproveitarAssinatura(Quote proposta, FavorecidoRemuneracaoProposta__c favorecido){
		date dataTeste = System.Today().addDays(-31);
		if(proposta != null && favorecido != null && !Test.isRunningTest()){
			//if((proposta.Status == 'Recusada' || proposta.Status == 'Devolvida' || proposta.Status == 'Cancelada') && dataTeste.daysBetween(System.Today()) <= 30){ 	
			if((proposta.Status == 'Recusada' || proposta.Status == 'Devolvida' || proposta.Status == 'Cancelada') && proposta.Data_da_recusa__c.daysBetween(System.Today()) <= 30){ 		
				if(proposta.TermoGuarda__c){
					return true;
				}
				else if(!proposta.TermoGuarda__c){
					for(CriticaProposta__c critica : proposta.CriticasProposta__r){
						Integer codigo = Integer.valueOf(critica.Codigo__c);
						if(codigo == 109 && critica.Status__c == 'Liberado'){
							return true;	
						}
						else if((codigo >= 70 && codigo <= 79) && critica.Status__c == 'Liberado' && proposta.StatusProponente__c != 'Expirado'){							
							return true;													
						}					
					}
				}
				if(favorecido.CorretorResponde__c){
					for(CriticaProposta__c critica : proposta.CriticasProposta__r){
						Integer codigo = Integer.valueOf(critica.Codigo__c);
						if(codigo == 109 && critica.Status__c == 'Liberado'){
							return true;	
						}
					}
				}
				else if(!favorecido.CorretorResponde__c){
					for(CriticaProposta__c critica : proposta.CriticasProposta__r){
						Integer codigo = Integer.valueOf(critica.Codigo__c);
						if((codigo >= 70 && codigo <= 79) && critica.Status__c == 'Liberado' && proposta.StatusProponente__c != 'Expirado'){
							return true;
						}
					}
				}			
			}
        }
		return false;
	}
	//PLV-5643 - FIM

	//ANNVI-208 - INICIO
	@RemoteAction
	public static String consultarDadosPessoaBCP(String cpf){

		ConsultarDadosPessoaBCP conDadPesBCP = ConsultarDadosPessoaBCP.getInstance();
		ConsultarDadosPessoaBCP.ConsltDadPesBCPResponse response = new ConsultarDadosPessoaBCP.ConsltDadPesBCPResponse();
		CtrFormularioSnipper.ResponseCPFBCPTO responseCPFBCP = new CtrFormularioSnipper.ResponseCPFBCPTO();
		try{
			cpf = cpf.replace('.','').replace('-','');
			String retorno = MulesoftServices.getInstance().consultarDadosBCP(cpf);			

				response = (ConsultarDadosPessoaBCP.ConsltDadPesBCPResponse) System.JSON.deserialize(retorno, ConsultarDadosPessoaBCP.ConsltDadPesBCPResponse.class);

				responseCPFBCP.nomeCompleto = response.nome;
				responseCPFBCP.dataNascimento = String.valueOf(response.dataNascimento).replace('-', '/');
				responseCPFBCP.sexo = response.sexo;
		}catch(Exception e){
			responseCPFBCP.nomeCompleto = 'Não encontrado';
			responseCPFBCP.dataNascimento = null;
			responseCPFBCP.sexo = '_';
			System.debug('e.getMessage() ' + e.getMessage());
		}
		return JSON.serialize(responseCPFBCP);
	}
	
	public class ResponseCPFBCPTO {
		public string nomeCompleto;
		public String dataNascimento;
		public string sexo;
	}
	//ANNVI-208 FIM
	
	//AV-85 - INICIO
	public class jsonEntradaCalculo {
		public String orcamento;
		public consultivo consultivo;
	}
	
	public class consultivo {
		public String canalDistribuicao; 
		public String codigoOfertaConsultiva;
		public String identificadorRepresentante; 
		public String meioComercializacao; 
		public List <resposta> respostas;
	}
	public class resposta {
		public String id; 
		public String conteudo; 
	}
	//AV-85 - FIM
	
	//PLV-5441 - INICIO
	public class clonar{
		public String DICIO_ORIGEM;
		public String DICIO_NOME;
		public String DICIO_DATANASCIMENTO;
		//II-56 INICIO
		public String DICIO_FUNERAL;
		public String DICIO_DIT;
		public String DICIO_CAPITAL;
		public String DICIO_CHECKUP;
		public String DICIO_DIA;
		//II-56 FIM
		public String DICIO_SEXO;
		public String DICIO_FUMANTE;
		public String DICIO_PROFISSAO;
		public String DICIO_REGIME_TRABALHO;
		public String DICIO_RENDA;
		public String DICIO_DEPENDENTES;
		public String DICIO_AGENCIAMENTO;
		public String DICIO_CORRETAGEM;
		public String DICIO_CICLOCOVID;
		public String DICIO_CPF;
		public String DICIO_TIPO_DOCIDENTIFICACAO;
		public String DICIO_DOCIDENTIFICACAO;
		public String DICIO_ORGAOEXPEDIDOR;
		public String DICIO_DATAEXPEDICAO;
		public String DICIO_EMPRESA;
		public String DICIO_RAMOATIVIDADE;
		public String DICIO_TIPOEMPRESA;
		public String DICIO_CNPJMEI;
		public String DICIO_QTDFUNCIONARIOS;
		public String DICIO_ESTADOCIVIL;
		public String DICIO_NACIONALIDADE;
		public String DICIO_RESIDEBRASIL;
		public String DICIO_PAIS;
		public String DICIO_PEP;
		public String DICIO_ENDERECORES_CEP;
		public String DICIO_ENDERECORES_LOGRADOURO;
		public String DICIO_ENDERECORES_NUMERO;
		public String DICIO_ENDERECORES_COMPLEMENTO;
		public String DICIO_ENDERECORES_BAIRRO;
		public String DICIO_ENDERECORES_CIDADE;
		public String DICIO_ENDERECORES_ESTADO;
		public String DICIO_ENDERECOCOM_CEP;
		public String DICIO_ENDERECOCOM_LOGRADOURO;
		public String DICIO_ENDERECOCOM_NUMERO;
		public String DICIO_ENDERECOCOM_COMPLEMENTO;
		public String DICIO_ENDERECOCOM_BAIRRO;
		public String DICIO_ENDERECOCOM_CIDADE;
		public String DICIO_ENDERECOCOM_ESTADO;
		public String DICIO_FAIXARENDA;
		public String DICIO_EMAIL;
		public String DICIO_TELEFONERES;
		public String DICIO_TELEFONECOM;
		public String DICIO_CELULAR;
		//PLV-5476 - INICIO
		public String DICIO_RESPONSAVEL;
		public String DICIO_RESPONSAVELNAME;
		public String DICIO_RESPONSAVELCPF;
		public String DICIO_RESPONSAVELVINCULO;
		public String DICIO_RESPONSAVELSEXO;
		public String DICIO_RESPONSAVELDATA;
		public String DICIO_RESPONSAVELCIVIL;
		public String DICIO_RESPONSAVELEMAIL;
		public String DICIO_RESPONSAVELCEP;
		public String DICIO_RESPONSAVELTIPO;
		public String DICIO_RESPONSAVELBAIRRO;
		public String DICIO_RESPONSAVELNUMERO;
		public String DICIO_RESPONSAVELRUA;
		public String DICIO_RESPONSAVELESTADO;
		public String DICIO_RESPONSAVELCIDADE;
		public String DICIO_RESPONSAVELTELEFONE1;
		public String DICIO_RESPONSAVELTELEFONE2;
		public String DICIO_RESPONSAVELTELEFONE3;
		public List <beneficiario> DICIO_LSTBENEF;
		//PLV-5476 - FIM
		//PLV-5636 - INICIO
		public String DICIO_NOME_AGENCIADOR;
		public String DICIO_CPF_AGENCIADOR;
		public String DICIO_CODIGOAGENCIADOR;
		public String DICIO_SUSEPAGENCIADOR;
		public String DICIO_TIPOREMUNERACAO;
		public String DICIO_CNPJ_AGENCIADOR;
		//PLV-5636 - FIM

		//PLV-5643 - INICIO
		public String DICIO_REAPROVEITAR_ASSINATURA;
		public String DICIO_TOTAL;
		//PLV-5643 - FIM
	}	
	//PLV-5474 - INICIO
	public class beneficiario{
		public String DICIO_BENEFTIPO;
		public String DICIO_BENEFNOME;
		public String DICIO_BENEFCPF;
		public String DICIO_BENEFDATA;
		public String DICIO_BENEFSEXO;
		public String DICIO_BENEFPAREN;
		public String DICIO_BENEFPERCEN;
		public String DICIO_BENEFIMPRIMI;
	}
	//PLV-5474 - FIM
	//PLV-5441 - FIM
	
	//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
	public class ServiceException extends Exception { }	
	//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
}