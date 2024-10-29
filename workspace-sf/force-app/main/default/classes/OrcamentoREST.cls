/**
 * Orçamento REST
 * @author Fernando Barcellos @ 20/04/2018
 *
 **/
@RestResource(urlMapping='/orcamento/*')
global with sharing class OrcamentoREST extends ServicoRestBase  {
	private static final OrcamentoREST instance = new OrcamentoREST();
	private static OrcamentoFacade orcamento = OrcamentoFacade.getInstance();
	//PLV-2323 INICIO Importando SniperMock
//	private static SniperMock sniperMock = new SniperMock();
	//PLV-2323 INICIO Importando SniperMock

    //PLV2365: INICIO
	global OrcamentoREST(){
		super.setServicoRestBase('Orcamento');
	}
	//PLV2365: FIM

	@HttpPost
	global static void processarPost() {
		instance.processarServico('POST');
	}

	/*
  	 * @author Everymind - Sprint 23
  	 * @Descrição: Entrada do serviço de orcamento, recebe o payload de orcamento
 	*/
	public override void processarServico(String metodo)
	{
		try 
		{
			RestRequest req = RestContext.request;
			//PLV-2323 INICIO
			String endpoint = req.requestURI;
			//PLV-2323 FIM
			//
			system.debug('Endpoint: ' + endpoint);
			System.debug('Request >>>>>>> ' + req);
			System.debug('metodo ' + metodo);
			Object retornoSniper;
			RetornoOrcamentoRestTO.ValidacaoOrcamentoTO retornoValidacao;
			String retorno;

    		if(metodo == 'POST')
			{
				String payload = req.requestBody.toString();
				System.debug(LoggingLevel.FINEST, 'PAYLOAD RECEBIDO CIV');
				System.debug(LoggingLevel.FINEST, payload);
				//PLV-2323 INICIO Mock orcamento/sugestao/mock - Alteracao
				if(endpoint.indexOf('/sugestao/mock') > -1) {
					retornoSniper = SniperMock.retornoSugestaoOrcamento();
					retorno = JSON.serialize(retornoSniper, true);
				}
				//PLV-2323 FIM Mock orcamento/sugestao/mock Alteracao
				//PLV-2327 INICIO Alteracao
				else if(endpoint.indexOf('orcamento/mock') > -1 ) {
					OrcamentoDirector.getInstance().processarOrcamento(payload, endpoint);
					retornoSniper = SniperMock.retornoGravaoOrcamento();
					retorno = JSON.serialize(retornoSniper, true);
				//PLV2365: INICIO
				}else if(endpoint.indexOf('orcamento/civcalculo') > -1 ) { 
				    //PLV2365: INICIO
					EmissaoTO.PayloadTO retornoOrcamento = OrcamentoGenericoBuilder.getInstance().gerarOrcamentoCivCalculo(payload);
				    //PLV2365: FIM

					retorno = JSON.serialize(retornoOrcamento, true);
				}else if(endpoint.indexOf('orcamento/gravarorcamentos') > -1 ) {
				    //PLV2365: INICIO
				    system.debug('Entrou no gravar');
					ServiceTO.PayRetornoOfertasTO ofertas = OrcamentoGenericoBuilder.getInstance().gerarOrcamentoGravar(payload);
				    //PLV2365: FIM
					system.debug('Ofertas vindas para o json = >' + ofertas);


					retorno = JSON.serialize(ofertas, true);
					system.debug('Json de oferas rest = >' + retorno);
				//PLV2365: FIM
				//PLV-2589: INICIO
				
				}
                //Código Removido para história PLV-2146
                //PLV-2146 - Início
                else if(endpoint.indexOf('orcamento/gerarDadosIniciais') > -1 ) {
					String retornoGerarDadosIniciais = GerarDadosIniciais.getInstance().gerarDadosIniciais(payload);
                    System.debug('Retorno retornoGerarNumeroOrcamento Rest>>>>>' + retornoGerarDadosIniciais );
                    retorno = retornoGerarDadosIniciais;
                    System.debug('Retorno Json Rest>>>>>' + retorno );
                }
                //PLV-2146 - Fim
                else {
                    //PLV-2589: FIM
					// chama a direcionadora do serviço de orçamento
					retornoValidacao = OrcamentoDirector.getInstance().processarOrcamento(payload, endpoint);	                    
					retorno = JSON.serialize(retornoValidacao, true);                    
				}

				this.retonarSucesso(retorno, 200);
    		}
		}
		catch (Exception e)
		{
			// em caso de  erro no processamento do orçamento retorna a seguinte devolutiva
			RetornoOrcamentoRestTO.ValidacaoOrcamentoTO retornoValidacao = new RetornoOrcamentoRestTO.ValidacaoOrcamentoTO();
			RetornoOrcamentoRestTO.DevolutivasTO linha = new RetornoOrcamentoRestTO.DevolutivasTO();
			retornoValidacao.devolutivas = new List<RetornoOrcamentoRestTO.DevolutivasTO>();

			// PLV-2312-28 INICIO
			linha.descricao	= 'Erro ao processar o orcamento. Origem: Salesforce. Linha:' + e.getLineNumber() + '. Mensagem: ' + e.getMessage();
			// PLV-2312-28 FIM
			linha.codigo	= -2;
			linha.origem	= '18';
		
			retornoValidacao.devolutivas.add(linha);
			
			this.retonarSucesso(JSON.serialize(retornoValidacao, true), 200);
		}
	}
}