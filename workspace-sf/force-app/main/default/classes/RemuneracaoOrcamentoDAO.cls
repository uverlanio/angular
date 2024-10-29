/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pela disponibilização dos dados do objeto de RemuneracaoOrcamento__c
 *
 **************************************************************************************************************************************************************************/
public  class RemuneracaoOrcamentoDAO {
	private static final RemuneracaoOrcamentoDAO instancia = new RemuneracaoOrcamentoDAO();
	private GarantiaProdutoDAO dao = GarantiaProdutoDAO.getInstance();

	private RemuneracaoOrcamentoDAO() {
	}

	public static RemuneracaoOrcamentoDAO getInstance(){
		return instancia;
	}

	public List<RemuneracaoOrcamento__c> buscarRemuneracoesOportunidade(Set<Id> setOrcamentoId) {
		return [
			SELECT
				Id,
				Name,
				Oportunidade__c,
				Oportunidade__r.Name,
                Oportunidade__r.CanalDistribuicao__c,
                Oportunidade__r.VigenciaInicial__c,
                Oportunidade__r.VigenciaFinal__c,
                Oportunidade__r.Produto__c,
                Oportunidade__r.Produto__r.LimiteTotalCarregamento__c,
				TipoRemuneracao__c,
				TipoRemuneracao__r.Name,
                Percentual__c
			FROM
				RemuneracaoOrcamento__c
			WHERE
				Oportunidade__c =: setOrcamentoId
			ORDER BY
				TipoRemuneracao__r.Name ASC
		];
	}
    
}