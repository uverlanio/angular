/**************************************************************************************************************************************************************************
 * 
 *  Classe responsável pelas funcionalidades do componente de Configuração de oferta
 *
 **************************************************************************************************************************************************************************/
public class ConfiguradorOfertaController {
    
	private static ConfiguracaoBO objConfiguracaoBo = ConfiguracaoBO.getInstance(); 
	private static ProductBO objProductBo = ProductBO.getInstance();
	private static GarantiaProdutoBO objGarantiaProdutoBo = GarantiaProdutoBO.getInstance(); 

	///**
 //    * Realiza a busca dos detalhes de uma configuração
 //    *
 //    * @param configuracaoId - id da configuração
 //    *
    @AuraEnabled
    public static Configuracao__c buscarConfiguracao(String configuracaoId){
        return objConfiguracaoBo.buscarConfiguracao((Id)configuracaoId);
    }

	///**
 //    * Realiza a busca dos produtos de um segmento
 //    *
 //    * @param segmento - segmento do produto
 //    *
    @AuraEnabled
    public static List<Product2> buscarProdutosComerciais(String segmento){
        return objProductBo.buscarProdutosComerciaisPorSegmento(segmento);
    }

    ///**
    // * Realiza a busca das garantias do produto de um produto em especifico
    // *
    // * @param produtoId - id do produto a ter as garantias buscadas
    // *
    @AuraEnabled
    public static List<GarantiaProduto__c> buscarGarantiasProdutos(String produtoId){
        return objGarantiaProdutoBo.buscarGarantiasProduto((Id)produtoId);
    }

    ///**
    // * Realiza a busca das garantias do produto da configuracao
    // *
    // * @param produtoConfiguracaoId - id do produto da configuração a ter as garantias buscadas
    // *
    @AuraEnabled
    public static List<GarantiaProdutoConfiguracao__c> buscarGarantiasProdutosConfiguracao(String produtoConfiguracaoId){
        return objConfiguracaoBo.buscarGarantiasProdutosConfiguracao((Id)produtoConfiguracaoId);
    }

    ///**
    // * Salva as informações de produto da configuração
    // *
    // * @param produtoConfiguracao - objeto de ProdutoConfiguracao__c a ser salvo
    // *
    @AuraEnabled
    public static Id salvarProdutosConfiguracao(ProdutoConfiguracao__c produtoConfiguracao){
        return objConfiguracaoBo.salvarProdutosConfiguracao(produtoConfiguracao); 
    }

    ///**
    // * Salva as informações de garantia do produto da configuração
    // *
    // * @param garantiasProdutosConfiguracao - lista de GarantiaProdutoConfiguracao__c a ser salvo
    // *
    @AuraEnabled
    public static void salvarGarantiasProdutosConfiguracao(String garantiasProdutosConfiguracao){
        objConfiguracaoBo.salvarGarantiasProdutosConfiguracao((List<GarantiaProdutoConfiguracao__c>)JSON.deserialize(garantiasProdutosConfiguracao, List<GarantiaProdutoConfiguracao__c>.class) ); 
    }


    ///**
    // * Salva as informações de criterios da configuração
    // *
    // * @param criteriosConfiguracao - lista de CriterioConfiguracao__c a ser salvo
    // *
    @AuraEnabled
    public static void salvarCriteriosConfiguracao(String criteriosConfiguracao){
        objConfiguracaoBo.salvarCriteriosConfiguracao((List<CriterioConfiguracao__c>)JSON.deserialize(criteriosConfiguracao, List<CriterioConfiguracao__c>.class) ); 
    }

    ///**
    // * Exclui registros de garantia do produto da configuração
    // *
    // * @param garantiasProdutosConfiguracao - lista de GarantiaProdutoConfiguracao__c a ser excluido
    // *
    @AuraEnabled
    public static void excluirGarantiasProdutosConfiguracao(String garantiasProdutosConfiguracao){
        objConfiguracaoBo.excluirGarantiasProdutosConfiguracao((List<GarantiaProdutoConfiguracao__c>)JSON.deserialize(garantiasProdutosConfiguracao, List<GarantiaProdutoConfiguracao__c>.class) ); 
    }

    ///**
    // * Exclui um produto da configuração
    // *
    // * @param produtoConfiguracaoId - id do produto da configuração a ser excluido
    // *
    @AuraEnabled
    public static void excluirProdutoConfiguracao(String produtoConfiguracaoId){
        objConfiguracaoBo.excluirProdutoConfiguracao((Id)produtoConfiguracaoId); 
    }

    ///**
    // * Exclui um criterio da configuração
    // *
    // * @param produtoConfiguracaoId - id do produto da configuração a ser excluido
    // *
    @AuraEnabled
    public static void excluirCriterioConfiguracao(String criterioConfiguracaoId){
        objConfiguracaoBo.excluirCriterioConfiguracao((Id)criterioConfiguracaoId); 
    }

    ///**
    // * Busca as opções de campos possíveis da página de criterio
    // *
    // * @param nomesObjeto - nomes do objetos a terem os campo definidos buscados
    // * @param segmento - segmento do item
    // * @param tipoComponente - nome do componente/página
    // *
    @AuraEnabled
    public static String buscarOpcoesCamposCriterio(List<String> nomesObjeto, String segmento, String tipoComponente){
        return JSON.serialize(objConfiguracaoBo.buscarOpcoesCamposCriterio(nomesObjeto, segmento, tipoComponente));
    }

    ///**
    // * Busca as informações de metadado de cada campo
    // *
    // * @param nomesObjeto - nomes do objetos a terem os campo definidos buscados
    // * @param segmento - segmento do item
    // * @param tipoComponente - nome do componente/página
    // *
    @AuraEnabled
    public static String buscarMapInformacoesCamposCriterio(List<String> nomesObjeto, String segmento, String tipoComponente){
        return JSON.serialize(objConfiguracaoBo.buscarMapInformacoesCamposCriterio(nomesObjeto, segmento, tipoComponente));
    }
}