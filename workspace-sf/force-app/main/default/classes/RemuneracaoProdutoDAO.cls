public class RemuneracaoProdutoDAO {

	private static final RemuneracaoProdutoDAO instance = new RemuneracaoProdutoDAO();

	public static RemuneracaoProdutoDAO getInstance() {
		return instance;
	}

	public List<RemuneracaoProduto__c> buscarRemuneracaoProdutoPorProdutos(Set<Id> produtoIds){
		return [
				Select
					Id,
					TipoRemuneracao__c,
					TipoRemuneracao__r.Id,
					TipoRemuneracao__r.Name,
					TipoEvento__c,
					Produto__c,
					LimiteMinimo__c,
					LimiteMaximo__c,
					ParcelasAgenciamento__c,
				    //--> PLV2427 INICIO
					Obrigatoria__c
				    //--> PLV2427 FIM
				From 
					RemuneracaoProduto__c	
				Where 
					Produto__c IN: produtoIds
		];
	}

	public List<RemuneracaoProduto__c> buscarRemuneracaoProdutoPorTiposRemuneracao(Set<Id> tipoRemuneracaoIds){
		return [
				Select
						Id,
						TipoRemuneracao__c,
						TipoRemuneracao__r.Id,
						TipoRemuneracao__r.Name,
						TipoEvento__c,
						Produto__c,
						LimiteMinimo__c,
						LimiteMaximo__c,
						ParcelasAgenciamento__c
				From
						RemuneracaoProduto__c
				Where
						TipoRemuneracao__c IN: tipoRemuneracaoIds
		];
	}

	public List<RemuneracaoProduto__c> buscarRemuneracaoProdutoPorId(Set<Id> remuneracaoProdutoIds){
		return [
				Select
					Id,
					TipoRemuneracao__c,
					TipoRemuneracao__r.Name,
					TipoEvento__c,
					Produto__c,
					LimiteMinimo__c,
					LimiteMaximo__c,
					RemuneracaoProduto__c
				From 
					RemuneracaoProduto__c	
				Where 
					Id IN: remuneracaoProdutoIds
		];
	}

	public List<RemuneracaoProduto__c> buscarRemuneracoesObrigatoriasPorProduto(Set<Id> idsProdutos) {
		return [
			SELECT
				Id,
				TipoRemuneracao__c,
				TipoRemuneracao__r.Name,
				TipoEvento__c,
				Produto__c,
				LimiteMinimo__c,
				LimiteMaximo__c,
				RemuneracaoProduto__c
			FROM
				RemuneracaoProduto__c
			WHERE
				Obrigatoria__c = true
				AND Produto__c IN : idsProdutos
		];
	}

	//PLV-3649 - INICIO - Criacao do metodo para buscar as remuneracoes e devolver no novo servico de gravar orcamento
	//PLV-4344 - Inicio - Ajuste de orcanizacao do codigo e inserir parametro de status do produto na busca
	public List<RemuneracaoProduto__c> buscarRemuneracaoProdutoPorProdutCode(Set<String> codigosProduto){
		
		return [
				SELECT
					Id,
					TipoRemuneracao__c,
					TipoRemuneracao__r.Id,
					TipoRemuneracao__r.Name,
					TipoEvento__c,
					Produto__c,
					LimiteMinimo__c,
					LimiteMaximo__c,
					ParcelasAgenciamento__c,
				    //--> PLV2427 INICIO
					Obrigatoria__c
				    //--> PLV2427 FIM
				FROM 
					RemuneracaoProduto__c	
				WHERE 
					(Produto__r.ProductCode IN :codigosProduto OR Produto__r.CodigoPrecificaProduto__c IN :codigosProduto ) AND //RVI-315-INICIO/FIM
					Produto__r.Status__c = 'Ativo'
		];
		
	}
	//PLV-4344 - Fim
	//PLV-3649 - FIM
}