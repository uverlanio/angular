/**
 * Botão na página de integrações
 * @author Fernando Barcellos @ XX/XX/2017
 *
 **/
public class AcaoBotaoExecutarIntegracao {
	private ApexPages.StandardSetController standardSetController;
	private List<Integracao__c> registros;
	private List<Integracao__c> integracoes;

	public String registrosSelecionados {get; set;}

	public AcaoBotaoExecutarIntegracao(ApexPages.StandardSetController stdSetController) {
		List<String> idsSelecionados = new List<String>();
		List<Integracao__c> integracoesSelecionadas = stdSetController.getSelected();
		if (integracoesSelecionadas != null) {
			for (Integracao__c integracao : integracoesSelecionadas) {
				idsSelecionados.add(String.valueOf(integracao.Id));
			}
			registrosSelecionados = JSON.serialize(idsSelecionados);
		}
	}
    
    public class NewException extends Exception {} //PLV-4287 - INICIO/FIM

	/**
	* Realiza execução anonima do script recebido
	*
	* @param   nomeSobject  - nome do objeto Salesforce no qual se está se invocando uma ação
	* @param   nomeAcao  - nome da ação a ser executada de acordo com o objeto
	* @param   sObjectId  - id do registro no qual se invocou a ação
	* @return  ExecucaoAnonimaResult - objeto contendo o resultado da execução
	*/
	@remoteAction
	public static Map<String, Object> executarIntegracao(String integracaoSelecionada) {

        //PLV-4287 - INICIO
        Id profileId = userinfo.getProfileId();
        String profileName = [ SELECT Id, Name FROM Profile WHERE Id =: profileId ].Name;
        String perfisSemPermissao = '|BI Salesforce||';
        if( perfisSemPermissao.contains( profileName ) ) { throw new NewException( 'O perfil \'' + profileName + '\' não pode executar integração.' ); }
        //PLV-4287 - FIM
        
		try {
			System.debug('executarIntegracao : ' + integracaoSelecionada);
			Integracao__c integracao = IntegracaoBO.getInstance().buscarIntegracaoPorId(Id.valueOf(integracaoSelecionada));
			IntegracaoBO.getInstance().executarIntegracao(integracao.DeveloperName__c);
		}
		catch(Exception e) {
			System.debug('ERRO AcaoBotaoExecutarIntegracao: ' + e.getLineNumber() + ', ' + e.getMessage());
		}

		Map<String, Object> mapResponse = new Map<String, Object>();
		mapResponse.put('success', true);
		mapResponse.put('message', 'Integração ' + integracaoSelecionada + ' + enviada para executar.');

		return mapResponse;
	}
}