/**************************************************************************************************************************************************************************
 * 
 *  Classe responsável administrar qual tipo de builder será processado
 *  // @author Everymind - Sprint 23*
 **************************************************************************************************************************************************************************/
public without sharing class OrcamentoDirector 
{
	private static final OrcamentoDirector instance = new OrcamentoDirector();
	public static OrcamentoDirector getInstance() {return instance; }
	private OrcamentoDirector() { }

	private static final String SIGLA_EMISSAO_GENERICO = 'gravar';
	private static final String SIGLA_ATUALIZAR_DEVOLUTIVA = 'devolutiva';

	private static final String SIGLA_CANCELAMENTO = 'cancelamento';
	private static final String SIGLA_ENDOSSO = 'endosso';
	private static final String SIGLA_NOVO = 'novo';
	private static final String SIGLA_RENOVACAO = 'renovacao';


	/*
  	 * @author Everymind - Sprint 23
  	 * @Descrição: recebe o payload de orcamento e deireciona ao processamento (bulder) especifica de acordo com os parametros de entrada
 	*/
	public RetornoOrcamentoRestTO.ValidacaoOrcamentoTO processarOrcamento(String payload , String path){
		RetornoOrcamentoRestTO.ValidacaoOrcamentoTO retorno = new RetornoOrcamentoRestTO.ValidacaoOrcamentoTO();
		Orcamento orcamentoGerado;

		// trata parametros url p/ redirecionar p/ builder correta
		String fluxoProduto = path.split('/')[path.split('/').size()-1];
		System.debug('fluxoProduto: ' + fluxoProduto);

		try 
		{
			if(fluxoProduto == SIGLA_EMISSAO_GENERICO) 
				retorno = OrcamentoFacade.getInstance().gerarOrcamento(payload);
			else if(fluxoProduto == SIGLA_ATUALIZAR_DEVOLUTIVA)
			{
				System.debug('processarOrcamento >> cancelamento >> inicio');
				System.debug('ISA payload' + payload);

				orcamentoGerado = OrcamentoGenericoBuilder.getInstance().montarOrcamento((EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class), null, true);
				retorno = OrcamentoGenericoBuilder.getInstance().converterOrcamentoParaRetornoOrcamento(orcamentoGerado);
			}
		} 
		catch(Exception e) 
		{
			System.debug(e.getMessage());
			throw new OrcamentoDirectorException(e.getMessage());
		}

		return retorno;
	}

	public class OrcamentoDirectorException extends Exception {}
}