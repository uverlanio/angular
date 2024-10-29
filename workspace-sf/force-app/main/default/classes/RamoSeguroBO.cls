/**
 * Regras de Negócio do objeto RamoSeguro__c
 * @author Fernando Barcellos @ 09/11/2017
 *
 **/
public class RamoSeguroBO {
	private static final RamoSeguroBO instance = new RamoSeguroBO();
	private RamoSeguroDAO dao = RamoSeguroDAO.getInstance();

	private RamoSeguroBO() { }

	public static RamoSeguroBO getInstance() {
		return instance;
	}

	/**
	 * Realiza a listagem de todos os ramos
	 *
	 */
	public List<RamoSeguro__c> listarRamos() {
		return dao.listarRamos();
	}

	/**
	 * Realiza a listagem de ramos de seguro via serviço externo, e atualiza Salesforce
	 *
	 */
	public void sincronizarDados(){
		List<RamoSeguro__c> dadosParaSincronizar = new List<RamoSeguro__c>();

		// AccountBO
		List<Account> lstEmpresas = AccountBO.getInstance().buscarEmpresasGrupoPorto();
		Map<String, Account> mapEmpresas = new Map<String, Account>();

		for (Account empresa : lstEmpresas) {
			mapEmpresas.put(empresa.CodigoEmpresa__c, empresa);
		}

		List<ServiceTO.RamoSeguroTO> tempDados = F5Service.getInstance().buscarRamosSeguro();

		for (ServiceTO.RamoSeguroTO ramo : tempDados) {
			Account empresa = mapEmpresas.get(ramo.codigoEmpresa);
			if (empresa != null) {
				dadosParaSincronizar.add(new RamoSeguro__c(
					Name = ramo.nomeRamo,
					Codigo__c = ramo.codigoRamo,
					CodigoEmpresa__c = ramo.codigoEmpresa,
					IdExterno__c = ramo.codigoEmpresa + '_' + ramo.codigoRamo,
					Empresa__c = empresa.Id,
					SiglaRamo__c = ramo.siglaRamo,
					GrupoRamo__c = ramo.codigoGrupoRamo,
					GrupoRamoSinistro__c = ramo.grupoRamosSinistro,
					GrupoRamoProducao__c = ramo.grupoRamosProducao
				));
			}
		}

		if(!dadosParaSincronizar.isEmpty()){
			upsert dadosParaSincronizar IdExterno__c;

			IntegracaoBO.getInstance().atualizarUltimaExecucao('RamoSeguro__c');

			List<RamoSeguro__c> ramosEmAnalise = RamoSeguroDAO.getInstance().buscarRamosPorStatus('Em análise');
			if (ramosEmAnalise.size() > 0) {
				// publicar feed com mencionando
				String mensagem = 'As informações de Ramos de Seguro foram atualizadas. Verifique as novas ocorrências, pois existem Ramos de Seguro que estão aguardando análise.';
				List<User> lstUsuarios = UserBO.getInstance().tempBuscarAliasNotificacoes();
				ChatterBO.publicarItemFeed(mensagem, lstUsuarios);
			}
			else {
				System.debug('::: ramosEmAnalise.size(): ' + ramosEmAnalise.size());
			}
		}
	}

	public List<RamoGarantia__c> buscarRamosSeguro(Id garantiaId){
		return RamoSeguroDAO.getInstance().buscarRamosGarantiaPorGarantia(garantiaId);
	}


	public List<RamoSeguro__c> buscarRamosSeguro(Set<Id> ramoSeguroIds){
		return RamoSeguroDAO.getInstance().buscarRamosPorids(ramoSeguroIds);
	}
}