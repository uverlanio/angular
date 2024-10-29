/**************************************************************************************************************************************************************************
 *
 *	Classe base para as classes responsáveis por serviços
 *
 **************************************************************************************************************************************************************************/
public abstract class ServiceBase {
	public String nomeEndpoint {get; set;}
	public String mensagemErro {get; set;}

	public ServiceBase() { }

	/**
	 * Gera endpoint de serviço, de acordo com o ambiente no qual está sendo excutado (DEV, HOM ou PROD)
	 *
	 * @param  	nomeServico  - Nome do serviço no qual se quer o endpoint
	 * @return  String - Endpoint gerado com base no serviço e ambiente
	 */
	public String gerarEndpoint(String nomeServico) {
		Servico__mdt servico =  this.buscarMetadadoServico(nomeServico);
		String endpoint =  String.isNotBlank(servico.Endpoint__c) ? servico.Endpoint__c : '';
		
		return System.Test.isRunningTest() ? 'http://testes.portoseguro.com.br/fake-endpoint' : 'callout:' + servico.NomeCredencial__c + endpoint;//RVI-175 - INICIO/FIM //II-42 FIX01 INICIO/FIM
	}

	/**
	 * Busca metadado serviço
	 *
	 * @param  	nomeServico  - Nome do serviço no qual se quer o endpoint
	 * @return  Servico__mdt
	 */
	public Servico__mdt buscarMetadadoServico(String nomeServico) {
		return MetadataDAO.getInstance().buscarServico(nomeServico);
	}

	/**
	 * Busca metadado credencial OAuth 2
	 *
	 * @param  	nomeCredencial  - Nome da credencial no qual se quer os dados
	 * @return  CredencialOAuth2__mdt
	 */
	public CredencialOAuth2__mdt buscarCredencial(String nomeCredencial) {
		return MetadataDAO.getInstance().buscarCredencial(nomeCredencial);
	}

	public Map<String, String> gerarHeaderOAuth2(String headerAutorizacao) {
		Map<String, String> header = new Map<String, String>();
		header.put('Content-Type', 'application/json');
		header.put('Accept','application/json');
		if (String.isNotBlank(headerAutorizacao)) {
			header.put('Authorization', headerAutorizacao);
		}

		return header;
	}
}