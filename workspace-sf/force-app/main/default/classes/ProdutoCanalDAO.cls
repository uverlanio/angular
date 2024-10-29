/**
 * Camada de abstração de dados do objeto ProdutoCanal__c
 * @author Fernando Barcellos @ 05/12/2017
 *
 **/
public class ProdutoCanalDAO {
	private static ProdutoCanalDAO classInstance;

	static {
		classInstance = new ProdutoCanalDAO();
	}

	private ProdutoCanalDAO() { }

	public static ProdutoCanalDAO getInstance() {
		return classInstance;
	}

	public List<ProdutoCanal__c> buscarProdutoCanalPorCanalDistribuicao(String status) {
		return buscarProdutoCanalPorCanalDistribuicao(new Set<String>{ status });
	}

	public List<ProdutoCanal__c> buscarProdutoCanalPorCanalDistribuicao(Set<String> setCanalDistribuicao) {
		return [
						SELECT
										Id,
										Name,
										Produto__c
						FROM
										ProdutoCanal__c
						WHERE
										CanalDistribuicao__c =: setCanalDistribuicao
		];
	}

	public ProdutoCanal__c buscarProdutoCanalPorId(Id produtoCanalId) {
		List<ProdutoCanal__c> lista = this.buscarProdutoCanalPorIds(new Set<Id> {produtoCanalId});
		return !lista.isEmpty() ? lista.get(0) : null;
	}

	public List<ProdutoCanal__c> buscarProdutoCanalPorIds(Set<Id> produtoCanalIds) {
		return [
						SELECT
										Id,
										Name,
										Produto__c,
										CanalDistribuicao__c,
										DocumentosNaoNecessariosEntrada__c,
										DocumentosNaoNecessariosSaida__c
						FROM
										ProdutoCanal__c
						WHERE
										Id IN: produtoCanalIds
		];
	}

	public List<ProdutoCanal__c> buscarProdutoCanalPorProdutoIds(Set<Id> produtoIds) {
		return [
						SELECT
										Id,
										Name,
										Produto__c,
										CanalDistribuicao__c,
										DocumentosNaoNecessariosEntrada__c,
										DocumentosNaoNecessariosSaida__c,
						(
										SELECT
														Id,
														ProdutoCanal__c,
														LimiteMinimo__c,
														LimiteMaximo__c,
														TipoRemuneracao__c,
														TipoRemuneracao__r.LimiteMinimo__c,
														TipoRemuneracao__r.LimiteMaximo__c
										FROM
														RemuneracoesProdutoCanal__r
						)
						FROM
										ProdutoCanal__c
						WHERE
										Produto__c IN: produtoIds
		];
	}

	public List<ProdutoCanal__c> buscarProdutoCanalPorOportunidade(Id idOportunidade) {
		return [
						SELECT
										Id,
										Name,
						(
										SELECT
														Id,
														Name,
														TipoRemuneracao__c,
														TipoRemuneracao__r.Name,
														TipoRemuneracao__r.LimiteMinimo__c,
														TipoRemuneracao__r.LimiteMaximo__c
										//Participacao__c
										FROM
														RemuneracoesProdutoCanal__r
										ORDER BY
														TipoRemuneracao__r.Name ASC
						),
										Produto__c,
										Produto__r.Name,
										Produto__r.RecordType.Name,
										CanalDistribuicao__c,
										LimiteMinimoRecuperacao__c,
										LimiteMaximoRecuperacao__c
						FROM
										ProdutoCanal__c
						WHERE
						Produto__c IN
						(
										SELECT
														Produto__c
										FROM
														Opportunity
										WHERE Id =: idOportunidade
						)
						AND CanalDistribuicao__c IN
						(
										SELECT
														CanalDistribuicao__c
										FROM
														Opportunity
										WHERE
														Id =: idOportunidade
						)
		];
	}

	public List<ProdutoCanal__c> buscarProdutosCanalAtivosPorIdProduto(Set<Id> idsProduto, Set<Id> idsCanalDistribuicao) {
		return [
						SELECT
										Id,
										CanalDistribuicao__c,
										CanalDistribuicao__r.Status__c,
										Produto__c,
										Produto__r.ProductCode,
										Produto__r.CodigoPrecificaProduto__c // PLV-5331 INÍCIO / FIM 
						FROM
										ProdutoCanal__c
						WHERE
						Produto__c IN : idsProduto
						OR (CanalDistribuicao__c IN : idsCanalDistribuicao AND CanalDistribuicao__r.Status__c = 'Ativo')
		];
	}

	public List<ProdutoCanal__c> buscarProdutosPorProductCode(Set<String> setProductCode){
		return [
						SELECT
										Id,
										Produto__c,
										Produto__r.VersaoMaxima__c,
										Produto__r.Versao__c,
										Produto__r.ProductCode,
										Produto__r.CodigoPrecificaProduto__c // PLV-5331 INÍCIO / FIM 
						FROM
										ProdutoCanal__c
						WHERE
										Produto__r.ProductCode =: setProductCode
		];
	}
}