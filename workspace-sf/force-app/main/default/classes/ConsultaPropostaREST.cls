/**
 * Consulta Proposta REST
 * @author Eric Tunú @ 26/06/2018
 *
 **/
@RestResource(urlMapping='/ConsultaPropostas/*')
global with sharing class ConsultaPropostaREST extends ServicoRestBase 
{
	private static final ConsultaPropostaREST instance = new ConsultaPropostaREST();
	private static PropostaFacade Proposta = PropostaFacade.getInstance();

	global ConsultaPropostaREST()
	{
		super.setServicoRestBase('ConsultaPropostas');
	}

	@HttpGet
    global static void processarPost() 
	{
    	instance.processarServico('GET');
    }

    public override void processarServico(String metodo)
	{
		
    	try 
		{
    		if(metodo == 'GET')
			{
				ServiceTO.ParametroConsultarPropostaTO parametrosTO = new ServiceTO.ParametroConsultarPropostaTO();
			
				parametrosTO.empresa 	= RestContext.request.params.get('empresa');
				parametrosTO.ramo 		= RestContext.request.params.get('ramo');
				parametrosTO.origem 	= RestContext.request.params.get('origem');
				parametrosTO.proposta 	= RestContext.request.params.get('proposta');
				
				parametrosTO.proposta 	= completeToLeft(parametrosTO.proposta, '0', 8);

	        	PropostaRetornoTO.PayloadTO retorno = Proposta.consultaPropostas(parametrosTO);
				system.debug('retorno ' + JSON.serialize(retorno));
				this.retonarSucesso(JSON.serialize(retorno), 200);
    		}
		}
		catch (Exception e) 
		{
			this.retornarErro(e.getMessage());
		}
    }
	
	public String completeToLeft(String value, String c, integer size) {
		String result = value;

		while (result.length() < size) {
			result = c + result;
		}

		return result;
	}	
}