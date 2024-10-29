/**
 * @Author Fernando Barcellos
 * 
 **/
public class IntegracaoBO {
	
	private static final IntegracaoBO instance = new IntegracaoBO();
	
	public static IntegracaoBO getInstance() {
		return instance;
	}

	private IntegracaoBO() { }

	public Integracao__c buscarIntegracaoPorId(Id idIntegracao) {
		return IntegracaoDAO.getInstance().buscarIntegracaoPorId(idIntegracao);
	}

	public Integracao__c buscarIntegracaoPorNomeObjeto(String nomeObjeto) {
		return IntegracaoDAO.getInstance().buscarIntegracaoPorNomeObjeto(nomeObjeto);
	}

	public void executarIntegracao(String developerName) {
		Integracao__c integracao = IntegracaoDAO.getInstance().buscarIntegracaoPorNomeObjeto(developerName);
		
		if (integracao.DeveloperName__c == 'Modalidade__c') {
			ModalidadeBO.getInstance().sincronizarDados();
		}
		else if (integracao.DeveloperName__c == 'RamoSeguro__c') {
			RamoSeguroBO.getInstance().sincronizarDados();
		}
		else if (integracao.DeveloperName__c == 'Profissao__c') {
			System.debug('Profissao__c entrou');
			ProfissaoBO.getInstance().sincronizarDados();
		}
		else if (integracao.DeveloperName__c == 'RamoAtividade__c') {
			RamoAtividadeBO.getInstance().sincronizarDados();
		}
		else if (integracao.DeveloperName__c == 'Account') {
			AccountBO.getInstance().sincronizarDadosEmpresaSeguro();
		}
		else {
			System.debug('Integração não configurada: ' + developerName);
		}
	}

	public void atualizarUltimaExecucao(String developerName) {
		try {
			Integracao__c integracao = IntegracaoDAO.getInstance().buscarIntegracaoPorNomeObjeto(developerName);
			integracao.UltimaExecucao__c = System.now();

			System.debug('=========== Última execução que será atualizada');
			System.debug(integracao);

			update integracao;
		}
		catch(Exception e) {
			System.debug('Error: ' + e.getMessage());
		}
	}
}