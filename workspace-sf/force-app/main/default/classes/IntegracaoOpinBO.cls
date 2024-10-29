//PLV-5230 - INICIO
/*
/*  @author: Squad Globant 
/*  @description: Classe responsável por obter os dados e os disparar o processo de montagem do payload.
/*  @modifiedAt: 05/10/2021
/*/
public  class IntegracaoOpinBO {

    //Implementa Factory
    private static final IntegracaoOpinBO instance = new IntegracaoOpinBO();
    public static IntegracaoOpinBO getInstance() {
		return instance;
	}

    //Construtor
    public IntegracaoOpinBO() {  }

    //Obtem os dados para compor a integração OPIN
    public IntegracaoOpinTO montarOpinTO(Product2 produto) {

        //Injeta dados do Opin na camada wrapper
        IntegracaoOpinWrapper opinWrapper = criarWrapper(produto);

        //Efetua a montagem da TO com as informações do BD
        return opinWrapper.montarEstruturaTO();

    }

    //Obtem os dados para compor a integração OPIN (sobrescreve lista de produtos)
    public IntegracaoOpinTO montarOpinTO(Product2 produto, List<IntegracaoOpinTO.PersonProductsTO> produtosOpin) {

        //Injeta dados do Opin na camada wrapper
        IntegracaoOpinWrapper opinWrapper = criarWrapper(produto, produtosOpin);

        //Efetua a montagem da TO com as informações do BD
        return opinWrapper.montarEstruturaTO();

    }

    //Obtem apenas os dados formatados do Produto 
    public IntegracaoOpinTO.PersonProductsTO montarProdutoOpinTO(Product2 produto) {

         //Injeta dados do Opin na camada wrapper
         IntegracaoOpinWrapper opinWrapper = criarWrapper(produto);
         System.debug('Danilo antes do return montarProdutoOpinTO');
         System.debug('Danilo opinWrapper.montarPersonProducts()[0]' + opinWrapper.montarPersonProducts()[0]);
         return opinWrapper.montarPersonProducts()[0];

    }

    private IntegracaoOpinWrapper criarWrapper(Product2 produto) {

        //Obter as informações do Banco de Dados
        Product2 produtoOpin = ProductDAO.getInstance().buscarProdutoOpin(produto.Id);

        //Injeta dados do Opin na camada wrapper
        return IntegracaoOpinWrapper.getInstance(
                                        produtoOpin, 
                                        GarantiaProdutoDAO.getInstance().buscarGarantiasProdutoOpin(produto.Id),
                                        produtoOpin.PremiosMinimoProduto__r);
    }

    private IntegracaoOpinWrapper criarWrapper(Product2 produto, List<IntegracaoOpinTO.PersonProductsTO> produtosOpin) {

        //Obter as informações do Banco de Dados
        Product2 produtoOpin = ProductDAO.getInstance().buscarProdutoOpin(produto.Id);

        //Injeta dados do Opin na camada wrapper  (sobrescreve lista de produtos)
        return IntegracaoOpinWrapper.getInstance(
                                        produtoOpin, 
                                        GarantiaProdutoDAO.getInstance().buscarGarantiasProdutoOpin(produto.Id),
                                        produtoOpin.PremiosMinimoProduto__r,
                                        produtosOpin);
    }

}
//PLV-5230 - FIM