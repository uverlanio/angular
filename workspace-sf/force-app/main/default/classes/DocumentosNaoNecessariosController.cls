/**
 * Realiza cadastro dos docuemntos de entrada e saída não necessários do objeto ProdutoCanal__c
 *
 **/
public class DocumentosNaoNecessariosController {

    @AuraEnabled
    public static ProdutoCanal__c buscarProdutoCanal(String produtoCanalId){
    	return ProdutoCanalBO.getInstance().buscarProdutoCanal((Id) produtoCanalId);
    }

    @AuraEnabled
    public static List<DocumentoProduto__c> buscarDocumentosProduto(String produtoId){
    	return DocumentBO.getInstance().buscarDocumentosProduto(new Set<Id>{produtoId});
    }

    @AuraEnabled
    public static void salvarProdutoCanal(ProdutoCanal__c produtoCanal){
    	ProdutoCanalBO.getInstance().salvarProdutoCanal(produtoCanal);
    }
}