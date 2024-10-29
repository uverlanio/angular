/**
 * Proposta REST
 * @author Eric Tunú @ 14/06/2018
 *
 **/
@RestResource(urlMapping='/proposta/*')
global with sharing class PropostaREST extends ServicoRestBase 
{
	private static final PropostaREST instance = new PropostaREST();
	private static PropostaFacade Proposta = PropostaFacade.getInstance();

	global PropostaREST()
	{
		super.setServicoRestBase('GeracaoProposta');
	}

	@HttpPost
    global static void processarPost() 
	{
    	instance.processarServico('POST');
    }

    /*
  	 * @author Everymind - Sprint 22 (Ultima Atualizacao)
  	 * @Descrição: metodo de  entrada emissão
 	*/
    public override void processarServico(String metodo)
	{
    	try 
		{
			RestRequest req = RestContext.request;
			String endpoint = req.requestURI;

    		if(metodo == 'POST')
			{
				String payload = req.requestBody.toString();
				System.debug(LoggingLevel.FINEST, 'PAYLOAD RECEBIDO CIV');
				System.debug(LoggingLevel.FINEST, payload);
				System.debug('endpoint ' + endpoint);

				RetornoPropostaRestTO.ValidacaopropostaTO retorno = PropostaDirector.getInstance().processarProposta(payload, endpoint);
				System.debug('RESPOSTA DO GRAVAR > '+JSON.serialize(retorno, true));
				this.retonarSucesso(JSON.serialize(retorno, true), 200);
    		}
		}
		catch (Exception e)
		{
			RetornoPropostaRestTO.ValidacaopropostaTO retorno = new RetornoPropostaRestTO.ValidacaopropostaTO();
			RetornoPropostaRestTO.DevolutivasTO linha = new RetornoPropostaRestTO.DevolutivasTO();
			retorno.devolutivas = new List<RetornoPropostaRestTO.DevolutivasTO>();

			// PLV-2312-28 INICIO
			
			linha.descricao  = 'Erro ao processar a proposta. Origem: Salesforce. Linha:' + e.getLineNumber() + '. Mensagem: ' + e.getMessage() + '. StackTrace: '+e.getStackTraceString();			// PLV-2312-28 FIM
			linha.codigo	= -2;
			linha.origem	= '18';
		
			retorno.devolutivas.add(linha);

			this.retonarSucesso(JSON.serialize(retorno), 200);
		}
    }
}