/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de PremioMinimoProduto__c
 *
 **************************************************************************************************************************************************************************/
public  class PremioMinimoProdutoBO {
	private static final PremioMinimoProdutoBO instancia = new PremioMinimoProdutoBO();
	private PremioMinimoProdutoDAO dao = PremioMinimoProdutoDAO.getInstance();

	private PremioMinimoProdutoBO() {
	}

	public static PremioMinimoProdutoBO getInstance(){
		return instancia;
	}

	/**
     * Realiza validação se algum cadastro existente na base. Metodo de trigger
     *
     * @param premiosProduto  - lista dos itens de premios do produto a ser validado
     */
    public void validarPremiosMinimo(List<PremioMinimoProduto__c> premiosProduto){
    	Set<Id> produtosIds = new Set<Id>();
    	Set<Id> premiosMinimosIds = new Set<Id>();
    	Set<String> valoresExistentes = new Set<String>();

    	//Extrai valores
    	for(PremioMinimoProduto__c premio : premiosProduto){
    		premiosMinimosIds.add(premio.Id);
    		produtosIds.add(premio.Produto__c);
    	}

    	List<PremioMinimoProduto__c> premiosExistentes = dao.buscarPremios(produtosIds, premiosMinimosIds);

    	//Se achou algo, verifica se algum registro é extamente igual ao que está sendo inserido/atualizado (de acordo com uma garantia de produto)
    	if(!premiosExistentes.isEmpty()){
    		//Monta set com a combinacao de valores a serem validados
	    	for(PremioMinimoProduto__c premioExistente : premiosExistentes){
	    		valoresExistentes.add(premioExistente.FormaPagamento__c + premioExistente.TipoContratacao__c + premioExistente.PeriodicidadePagamento__c);
	    	}

	    	//Realiza validação
	    	for(PremioMinimoProduto__c premio : premiosProduto){
	    		if(valoresExistentes.contains(premio.FormaPagamento__c + premio.TipoContratacao__c + premio.PeriodicidadePagamento__c)){
	    			premio.addError('Cadastro de prêmio já existente para estes valores');
	    		}
	    	}
    	}
    }


    /*********************************************************************************************************
    *
    * Habilita novamente a flag que permite que as regra de limite sejam executadas
    *
    *********************************************************************************************************/
    public void habilitarValidacaoRegrasProdutoComercial(List<PremioMinimoProduto__c> premiosMinimo){
        RegrasFabricaProdutos.habilitarValidacaoRegrasProdutoComercial(premiosMinimo, 'PremioMinimoProduto__c', 'PremioMinimoProdutoHandler');
    }
}