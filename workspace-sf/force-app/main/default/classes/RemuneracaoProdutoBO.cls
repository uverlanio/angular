/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de RemuneracaoProduto__c
 *
 **************************************************************************************************************************************************************************/
public  class RemuneracaoProdutoBO {
	private static final RemuneracaoProdutoBO instancia = new RemuneracaoProdutoBO();
	private RemuneracaoProdutoDAO dao = RemuneracaoProdutoDAO.getInstance();

	private RemuneracaoProdutoBO() {	
	}

	public static RemuneracaoProdutoBO getInstance(){
		return instancia;
	}

	/**
	 * Não permite que o mesmo tipo de remuneração seja utilizado em mais de uma Remuneração do produto 
	 *
	 */
	public void validarTiposRemuneracaoExistentes(List<RemuneracaoProduto__c> remuneracoesProduto) { 
		Set<Id> produtoIds = new Set<Id>();
		Set<Id> remuneracaoProdutoIds = new Set<Id>();
		Set<String> tiposRemuneracoesUsados = new Set<String>();
		List<RemuneracaoProduto__c> remuneracoesProdutoBase;

		// verfica se entre os itens inseridos/atualizados não está se repetindo o tipo de remuneração
		for(RemuneracaoProduto__c remuneracao : remuneracoesProduto){
			produtoIds.add(remuneracao.Produto__c);
			remuneracaoProdutoIds.add(remuneracao.Id);
			if(tiposRemuneracoesUsados.contains(remuneracao.Produto__c + '_' + remuneracao.TipoRemuneracao__c + '_' + remuneracao.TipoEvento__c)) {
				remuneracao.addError('Este Tipo de Remuneração já está sendo utilizado em outra Remuneração do produto.');
				return;
			}
			else{
				tiposRemuneracoesUsados.add(remuneracao.Produto__c + '_' + remuneracao.TipoRemuneracao__c + '_' + remuneracao.TipoEvento__c);
			}
		}

		//Limpa variavel para usar novamente em outra validação
		tiposRemuneracoesUsados = new Set<String>();

		//Busca todas as remunerações do produto referente ao produto. Armazena os tipos já usados
		for(RemuneracaoProduto__c remuneracao : dao.buscarRemuneracaoProdutoPorProdutos(produtoIds)) {
			if(!remuneracaoProdutoIds.contains(remuneracao.Id)) {
				tiposRemuneracoesUsados.add(remuneracao.Produto__c + '_' + remuneracao.TipoRemuneracao__c + '_' + remuneracao.TipoEvento__c);
			}	
		}

		if(!tiposRemuneracoesUsados.isEmpty()){
			//Verica se está tentando utilziar um tipo já utilizado novamente
			for(RemuneracaoProduto__c remuneracao : remuneracoesProduto) {
				if(tiposRemuneracoesUsados.contains(remuneracao.Produto__c + '_' + remuneracao.TipoRemuneracao__c + '_' + remuneracao.TipoEvento__c)){
					remuneracao.addError('Este Tipo de Remuneração já está sendo utilizado em outra Remuneração do produto.');
					break;
				}
			}
		}
	}

	/**
	 * Não permite utilizar um tipo de remuneração que não exista no cadastro do produto técnico
	 *
	 */
	public void validarTiposRemuneracaoProdutoComercial(List<RemuneracaoProduto__c> remuneracoesProduto) { 
		Id recordTypeProdutoComercialId = RecordTypeBO.buscarTipoRegistro('RemuneracaoProduto__c', 'ProdutoComercial').Id;
		List<RemuneracaoProduto__c> remuneracoesProdutoComercial = new List<RemuneracaoProduto__c>();
		Set<Id> remuneracaoTecnicoIds = new Set<Id>();

		//Separa apenas as remunerações de produto comercial 
		for(RemuneracaoProduto__c remuneracao : remuneracoesProduto){
			if(remuneracao.RecordTypeId == recordTypeProdutoComercialId){
				remuneracoesProdutoComercial.add(remuneracao);
				remuneracaoTecnicoIds.add(remuneracao.RemuneracaoProduto__c);
			}
		}

		if(!remuneracaoTecnicoIds.isEmpty()){
			Set<Id> tiposRemuneracoesTecnico = new Set<Id>();
			for(RemuneracaoProduto__c remuneracaoTecnica : dao.buscarRemuneracaoProdutoPorId(remuneracaoTecnicoIds)){
				tiposRemuneracoesTecnico.add(remuneracaoTecnica.TipoRemuneracao__c);
			}

			//Valida se o tipo de remuneração a ser utilizado no produto comercial existe no técnico
			for(RemuneracaoProduto__c remuneracao : remuneracoesProdutoComercial){
				if(!tiposRemuneracoesTecnico.contains(remuneracao.TipoRemuneracao__c)){
					remuneracao.addError('Este Tipo de Remuneração não existe no produto técnico. Não pode ser utilizado.');
				}
			}
		}
	}

	public List<RemuneracaoProduto__c> buscarRemuneracoesObrigatoriasPorProduto(Set<Id> idsProdutos) {
		return dao.buscarRemuneracoesObrigatoriasPorProduto(idsProdutos);
	}

	//Retornas as remunerações de produto
	public List<RemuneracaoProduto__c> buscarRemuneracaoProdutoPorProdutos(Set<Id> produtoIds){
		return dao.buscarRemuneracaoProdutoPorProdutos(produtoIds);
	}
}