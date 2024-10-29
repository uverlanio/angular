/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pela ações de botões do objeto Product2
 *
 **************************************************************************************************************************************************************************/
public class ProductAcaoBotaoController {
	private static ProductBO bo = ProductBO.getInstance();

	@AuraEnabled
	public static String ativarProduto(String idProduto){
		return JSON.serialize(bo.ativarProduto(Id.valueOf(idProduto)));
	}

	@AuraEnabled
	public static String gerarNovaVersao(String idProduto){
		RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO();

		try {
			Id novoProdutoId = bo.gerarNovaVersao(Id.valueOf(idProduto));
			retorno.tipo = RetornoAcaoBotaoTO.SUCCESS;
			retorno.linkRedirecionar = novoProdutoId;
			retorno.mensagens.add('Nova versão gerada com sucesso!');
		} catch(Exception e) {
			retorno.tipo = RetornoAcaoBotaoTO.ERROR;
			retorno.mensagens.add(e.getMessage());
		}

		return JSON.serialize(retorno);
	}

	@AuraEnabled
	public static String gerarNovoProdutoComercial(String idProduto){
		RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO();

		try {
			Id novoProdutoId = bo.gerarNovoProdutoComercial(Id.valueOf(idProduto));
			retorno.tipo = RetornoAcaoBotaoTO.SUCCESS;
			retorno.linkRedirecionar = novoProdutoId;
			retorno.mensagens.add('Produto comercial gerado com sucesso!');
		} catch(Exception e) {
			retorno.tipo = RetornoAcaoBotaoTO.ERROR;
			retorno.mensagens.add(e.getMessage());
		}
		
		return JSON.serialize(retorno);
	}
}