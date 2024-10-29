/*********************************************************************************************************************************************************************

@description  Classe que contem a Controller para o Formulario.
@author Renan Martins - Avanxo
@date 03/006/2019
@Hackathon Sniper Atualização 11/06/2019
@Classe criada por conta da história PLV-2318
        
**********************************************************************************************************************************************************************/
public with sharing class CtrFormularioEntradaSniper {
	
	//PLV2607 - INCIO - Removido esta instância
	//private static final CtrFormularioSnipper instancia = new CtrFormularioSnipper();
	//PLV2607 - FIM 
	private static CIVServices civServ = CIVServices.getInstance();

	// PLV-3502 - INICIO
	public String dadosEntrada {get;set;}
	public String identificadorSusep {get;set;}
	public BuscaTermosTO retornoObj = new BuscaTermosTO();
	public String hasbloqueio {get;set;}
	public class BuscaTermosTO {
		public List<CanalTO> canais { get; set; }
		public Set<String> codigos { get; set; }
	}

	public class CanalTO {
		public String nome;
		public String sigla;
	}

	public CtrFormularioEntradaSniper(){
		List<CanalTO> listaCanais = new List<CanalTO>();
		List<GeradorOferta__c> listaCanaisAtivos = [SELECT CanalDistribuicao__c, identificacaoRepresentante__c FROM GeradorOferta__c WHERE status__c = 'Ativo' and CanalDistribuicao__c != null ORDER BY identificacaoRepresentante__c NULLS LAST];
		System.debug('listaCanaisAtivos ' + listaCanaisAtivos);
		Set<Id> setIdCanais = new Set<Id>();
		for(GeradorOferta__c canal : listaCanaisAtivos){
			setIdCanais.add(canal.get('CanalDistribuicao__c').toString());
		}
		List<CanalDistribuicao__c> canais = [SELECT Name, Sigla__c FROM CanalDistribuicao__c WHERE Id IN :setIdCanais];
		for(CanalDistribuicao__c canal : canais){
			CanalTO canalObj = new CanalTO();
			canalObj.nome = canal.get('Name').toString();
			canalObj.sigla = canal.get('Sigla__c').toString();
			System.debug(canalObj);
			listaCanais.add(canalObj);
		}
		retornoObj.canais = listaCanais;
		dadosEntrada = SYSTEM.JSON.serialize(retornoObj);
	}

	public void identificarUsuario() {
		try{
			List<GeradorOferta__c> codigos = [SELECT CodigoOfertaConsultiva__c, identificacaoRepresentante__c FROM GeradorOferta__c WHERE status__c = 'Ativo' and CodigoOfertaConsultiva__c != null and (identificacaoRepresentante__c = '' OR identificacaoRepresentante__c = :identificadorSusep) ORDER BY identificacaoRepresentante__c NULLS LAST];
			Set<String> setIdCodigos = new Set<String>();
			System.debug('codigos ' + codigos);
			for(GeradorOferta__c codigo : codigos){
				setIdCodigos.add(codigo.get('CodigoOfertaConsultiva__c').toString());
			}
		
			retornoObj.codigos = setIdCodigos;
			
			dadosEntrada = SYSTEM.JSON.serialize(retornoObj);
			// System.debug(dadosEntrada);
		}catch(Exception ex){
			dadosEntrada = '{"message": "Erro ao identificar corretor"}';
		}
	}
	// PLV-3502 - FIM

	//Redireciona a  Tela
	public PageReference redirecionar() {
		
		String entrada;
		String retorno;
		Object retornoSemConsultivo;
		String retSemConsultivoStr;
		PageReference page2;

	  	
			//Mostra os  parametros de Entrada 
			System.debug('ENTRADA '+ ApexPages.currentPage().getParameters());

			//Chama o Json de Entrada 
			//Consultivo Entrada(String jsonEntradaConsultivo )
			Map<String, String> mEntrada = ApexPages.currentPage().getParameters();

			//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
			try{
				
					// Json de Retorno,após fazer a chamada da Entrada do Json
					entrada = mEntrada.get('jsonEntradaConsultivo');
					system.debug('mEntrada: ' + mEntrada.get('jsonEntradaConsultivo'));
					//PLV-3223 - INÍCIO
					Map<String,Object> mapObjEntrada = new Map<String,Object>();
                	if(!Test.isRunningTest()){
                    	mapObjEntrada = (Map<String,Object>) JSON.deserializeUntyped(entrada);
                	}
					//PLV-3223 - FIM
                //PLV2533 - INÍCIO - Alterações da lógica para chamada do CIV Consultivo
                //Remover trecho comentado abaixo - Código será migrado para a classe ctrformularioSnipper
				/*	retorno = consultivo(entrada);
                
						if(retorno == 'Erro na requisição'){
							String message =  '{'+
                    				    	+'  "message":"Erro no serviço. Entre em contato com o administrador."'+
                	        					 +'}';
					
                   			System.debug('Dentro do IF(retorno = ERRO - Metodo: redirecionar)');
                   			System.debug('Message: ' + message);				
							
							//Chama a página pageFormularioSnipper retornando a mensagem de Erro no serviço.
							page2 = Page.formularioSniper;
							page2.getParameters().put('ErroServico', message);	
						}
						else{
							//Cria um Objeto com atributo e valor deserializando
							Map<String,Object> mRetorno = (Map<String,Object>) JSON.deserializeUntyped(retorno);
		
							//Tira dentro do Objeto o Atributo 'consultivo' somente. 
        					retornoSemConsultivo = mRetorno.get('consultivo');
							//Cria novamente a lista sem o Consultivo como início
        					retSemConsultivoStr = JSON.serialize(retornoSemConsultivo);
        					System.debug('CtrFormularioEntradaSniper - '+retSemConsultivoStr);

							//Chama a Pagina pageFormularioSnipper
							//Dados é variavel que tem o Json completo dentro 
							page2 = Page.formularioSniper;
							page2.getParameters().put('dados', retSemConsultivoStr);
						}
				 */
                 //PLV2533 - FIM - Alterações da lógica para chamada do CIV Consultivo
                 //Remover até aqui - Código será migrado para a classe ctrformularioSnipper
						//PLV-3223-INÍCIO AV-620 INICIO
						String Resultado;
						//II-114  Início
						Map<String,Object> mapConsultivo = new Map<String,Object>();
						if(!Test.isRunningTest()){
							mapConsultivo = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(mapObjEntrada.get('consultivo')));
						}
						System.debug('codigoOfertaConsultiva => '+ mapConsultivo.get('codigoOfertaConsultiva'));
						//II-114  FIM
						if(mapObjEntrada.get('acao') == 'CONSULTAR'){
							page2 = Page.consultaOfertas;
						}else{

							//II-114  Início                
							if (mapConsultivo.get('codigoOfertaConsultiva') != null && mapConsultivo.get('codigoOfertaConsultiva') != '') {
								if (String.valueOf(mapConsultivo.get('codigoOfertaConsultiva')).toUpperCase() == 'VIDA_INDIVIDUAL_VP' || String.valueOf(mapConsultivo.get('codigoOfertaConsultiva')).toUpperCase() == 'VIDA_INDIVIDUAL') {
									page2 = Page.OrcamentoVidaIndividual;
								}else {
									page2 = Page.formularioSniper;
								}
							} else {
								page2 = Page.formularioSniper;
							}
							//II-114  FIM
							page2.getParameters().put('dados', entrada);
						 
						}
						//PLV-3223-FIM
                		
						return page2;

				}catch(Exception ex){
							System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage());							
							throw new ServiceException('ERRO de serviço: ' + ex.getMessage() + ' Linha: ' + ex.getLineNumber());
				}
				//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
	}

    
   //PLV2533 - INÍCIO - Alterações da lógica para chamada do CIV Consultivo
   //Remover trecho comentado abaixo - Código será migrado para a classe ctrformularioSnipper
	
    //Metodo Consultivo Retorno Json (CIV CONSULTIVO)
	/*
    public static String consultivo(String jsonEntradaConsultivo) {
       // system.debug('Consultivo 1 : +++++ ' + jsonEntradaConsultivo);
		
			String Response;			

		//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
       	try{
           	System.debug('Matheus == ' + jsonEntradaConsultivo);
	    	//busca o Json no Serviço CivServ método consultivoContratacao      
        	Response = civServ.consultivoContratacao(jsonEntradaConsultivo);
			System.debug('Response gfs ==>' + Response);


         	/*
			//Faz um Map e list de tudo que tem dentro do Json COnsultivo
        	Map<String, Object> mResponseJson = (Map<String,Object>) JSON.deserializeUntyped(Response);
        	System.debug('Response gfs 2 ==>' + mResponseJson);    
        
        	Map<String, Object> mData = (Map<String,Object>) mResponseJson.get('consultivo');
        	List<Object> lConjuntos = (List<Object>) mData.get('conjuntos');
           System.debug('Iskander = lConjuntos = ' + lConjuntos);
        	Map<String, Object> mItemsConjuntos  = (Map<String,Object>) lConjuntos[0];
           	System.debug('Iskander = mItemsConjuntos = ' + mItemsConjuntos);
        	List<Object> lInformacoes = (List<Object>) mItemsConjuntos.get('informacoes');
           System.debug('Iskander = lInformacoes = ' + lInformacoes);
        	Map<String, Object> mItemslInformacoes = (Map<String,Object>) lInformacoes[0];	
           System.debug('Iskander = mItemslInformacoes = ' + mItemslInformacoes);
        	List<Object> lOpcoes = (List<Object>) mItemslInformacoes.get('opcoes');	
           System.debug('Iskander = lOpcoes = ' + lOpcoes);
        	Map<String, Object> mItemslOpcoes = (Map<String,Object>) lOpcoes[0];
           System.debug('Iskander = mItemslOpcoes = ' + mItemslOpcoes);

			List<Object> lRegrasSequencia = (List<Object>) mItemsConjuntos.get('regrasSequencia');	
        	Map<String, Object> mItemslRegrasSequencia = (Map<String,Object>) lRegrasSequencia[0];

    
        	System.debug('JSONNNNN '+ mResponseJson);
			System.debug('JSONNNNN '+ (List<Object>) mItemslInformacoes.get('opcoes'));
        	System.debug('JSONNNNN1 '+ (List<Object>) mItemsConjuntos.get('regrasSequencia'));

     		FormularioSniperTO ResponseTeste = (FormularioSniperTO)json.deserialize(Response,FormularioSniperTO.class);
    
      		System.debug('TEste TO  : '+ json.deserialize(Response,FormularioSniperTO.class));
        	System.debug('variavel TO ' + ResponseTeste);
       		
       	}
       	catch(Exception ex){       		
			System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage());
			throw new ServiceException('O seguinte ERRO ocorreu: ' + ex.getMessage());	
		}
		//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.

		return Response;
	}
	*/

	//PLV2533 - FIM - Alterações da lógica para chamada do CIV Consultivo
    //Remover até aqui - Código será migrado para a classe ctrformularioSnipper

//PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
public class ServiceException extends Exception { }
//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
}