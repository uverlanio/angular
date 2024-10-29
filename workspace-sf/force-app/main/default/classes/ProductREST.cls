/**
 * Product REST
 * @author Fernando Barcellos @ 26/06/2018
 *
 **/
@RestResource(urlMapping='/produtos/*')
global with sharing class ProductREST extends ServicoRestBase {
    private static final ProductREST instance = new ProductREST();
    private static ProductFacade facade = ProductFacade.getInstance();

    global ProductREST() {
        super.setServicoRestBase('ProductService');
    }

    @HttpGet
    global static void consultarProdutos() {
        instance.processarServico('GET');
    }

    //Realiza a interpretação da URI e realiza as chamadas de acordo com os parametros encontrados
    public override void processarServico(String metodo) {
        try {
            if (metodo == 'GET') {
                RestRequest req = RestContext.request;
                ProductServiceTO.RetornoConsultaProdutoTO retorno;

                //Realiza busca por segmemto
                if (req.params.containsKey('segmentoProduto')) {
                    retorno = facade.buscarProdutos(req.params.get('segmentoProduto'));
                }
                //Realiza busca por produto
                else{ 
                    String uri = req.requestURI.substringAfterLast('produtos/');
                    List<String> lstUri = uri.split('/');
                    String codigoProduto = lstUri.get(0);
                    String tipoBusca = lstUri.size() > 1 ? lstUri.get(1) : null;
                    retorno = facade.buscarProdutos(codigoProduto, tipoBusca);
                }

                this.retonarSucesso(JSON.serialize(retorno), 200);
            }
        }
        catch (Exception e) {
            this.retornarErro(e.getMessage());
        }
    }
}