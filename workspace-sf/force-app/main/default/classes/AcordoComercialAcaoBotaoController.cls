/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pela ações de botões do objeto AcordoComercial__c
 *
 **************************************************************************************************************************************************************************/
public class AcordoComercialAcaoBotaoController {
	private static AcordoComercialBO bo = AcordoComercialBO.getInstance();

	@AuraEnabled
	public static String gerarProdutosAcordoComercial(String idAcordoComercial){
		RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO();

		try {
			bo.gerarProdutosAcordoComercial(Id.valueOf(idAcordoComercial));
			retorno.tipo = RetornoAcaoBotaoTO.SUCCESS;
			retorno.mensagens.add('Produtos do acordo comercial gerados com sucesso!');
		} catch(Exception e) {
			retorno.tipo = RetornoAcaoBotaoTO.ERROR;
			retorno.mensagens.add(e.getMessage());
		}
		
		return JSON.serialize(retorno);
	}
}