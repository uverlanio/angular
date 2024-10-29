/**
 * Regras de Negócio do Objeto Garantia__c
 * @author Fernando Barcellos
 *
 **/
public class GarantiaBO {
	private static GarantiaBO classInstance;

	static {
		classInstance = new GarantiaBO();
	}

	private GarantiaBO() {
		
	}

	public static GarantiaBO getInstance() {
		return classInstance;
	}

	public List<Garantia__c> buscarGarantiasPorId(Set<Id> idsGarantias, Set<Id> idsProdutos) {
		return GarantiaDAO.getInstance().buscarGarantiasPorId(idsGarantias, idsProdutos);
	}

	public void validarGarantias(List<GarantiaCampanha__c> garantiasCampanhas) {
		Set<Id> idsCanalCampanha = new Set<Id>();
		Set<Id> idsGarantiasCampanha = new Set<Id>();

		for (GarantiaCampanha__c garantiaCampanha : garantiasCampanhas) {
			system.debug('garantiaCampanha ' + garantiaCampanha);
			idsCanalCampanha.add(garantiaCampanha.CanalCampanha__c);
			idsGarantiasCampanha.add(garantiaCampanha.Garantia__c);
		}

		// CANAIS CAMPANHA
		List<CanalCampanha__c> canaisCampanha = CanalCampanhaDAO.getInstance().buscarCanaisCampanhaPorId(idsCanalCampanha);
		Set<Id> idsProdutosCampanha = new Set<Id>();
		system.debug('canaisCampanha ' + canaisCampanha);
		for (CanalCampanha__c canalCampanha : canaisCampanha) {
			idsProdutosCampanha.add(canalCampanha.Produto__c);
		}
		system.debug('idsProdutosCampanha ' + idsProdutosCampanha);
		List<Garantia__c> garantias = buscarGarantiasPorId(idsGarantiasCampanha, idsProdutosCampanha);
		Map<Id, List<GarantiaProduto__c>> mapGarantiaProdutos = new Map<Id, List<GarantiaProduto__c>>();
		system.debug('garantias ' + garantias);
		for (Garantia__c gar : garantias) {
			List<GarantiaProduto__c> lstProdutos = new List<GarantiaProduto__c>();

			for (GarantiaProduto__c gp : gar.GarantiasProduto__r) {
				lstProdutos.add(gp);
			}

			mapGarantiaProdutos.put(gar.Id, lstProdutos);
		}

		// VALIDAÇÕES
		for (GarantiaCampanha__c garantiaCampanha : garantiasCampanhas) {
			List<GarantiaProduto__c> garantiasProduto = mapGarantiaProdutos.get(garantiaCampanha.Garantia__c);
			system.debug('garantiasProduto ' + garantiasProduto);
			Set<Id> idsGarantiasProdutoExistentes = new Set<Id>();
			Set<String> teste = new Set<String>();
			for (GarantiaProduto__c garantiaProduto : garantiasProduto) {
				system.debug('garantiaProduto ' + garantiaProduto);
				idsGarantiasProdutoExistentes.add(garantiaProduto.Garantia__c);
				teste.add(garantiaProduto.Garantia__c);
			}
			system.debug('idsGarantiasCampanha '+ idsGarantiasCampanha);
			system.debug('teste '+ teste);
			system.debug('idsGarantiasProdutoExistentes ' + idsGarantiasProdutoExistentes);
			// VALIDAÇÃO 1
			if (!idsGarantiasCampanha.containsAll(idsGarantiasProdutoExistentes) || idsGarantiasProdutoExistentes.size() == 0) {
				garantiaCampanha.addError('Garantia inexistente nas Garantias do produto.');
			}
		}
	}

	// POR062-1 - INICIO
	public Map<String, Garantia__c> mapearGarantiaPorCobertura(List<Garantia__c> garantias)
	{
		Map<String, Garantia__c> garantiaPorCobertura = new Map<String, Garantia__c>();
		for(Garantia__c garantia : garantias)
		{
			garantiaPorCobertura.put(garantia.Sigla__c, garantia);
		}
		return garantiaPorCobertura;
	}
	// POR062-1 - FIM
}