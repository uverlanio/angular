public class AntecipacaoComissaoDAO {

	private static final AntecipacaoComissaoDAO instance = new AntecipacaoComissaoDAO();

	public static AntecipacaoComissaoDAO getInstance() {
		return instance;
	}
   // VIAG-148 INICIO
	public List<AntecipacaoComissao__c> buscarAntecipacaoComissaoPorProdutCode(Set<String> codigosProduto){
  
		return [
            SELECT ID, 
            LimiteMaximo__c, 
            LimiteMinimo__c, 
            TipoEvento__c, 
            RemuneracaoProduto__c, 
            RemuneracaoProduto__r.TipoRemuneracao__r.Name,
            RemuneracaoProduto__r.Name  
            FROM
            AntecipacaoComissao__c 
            WHERE RemuneracaoProduto__r.Produto__r.ProductCode IN: codigosProduto 
            AND RemuneracaoProduto__r.Produto__r.Status__c = 'Ativo'
		];
		
	}
	 // VIAG-148 FIM
}