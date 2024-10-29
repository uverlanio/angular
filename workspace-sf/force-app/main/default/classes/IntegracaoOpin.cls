//PLV-5230 - INICIO
/*
/*  @author: Squad Globant 
/*  @description: Classe "Manager" para integração OPIN (Open Insurance)
/*  @modifiedAt: 05/10/2021
/*/
public class IntegracaoOpin {

    //Implementa Factory
    private static final IntegracaoOpin instance = new IntegracaoOpin();
    public static IntegracaoOpin getInstance() {
		return instance;
	}

    private final IntegracaoOpinBO opinBO = IntegracaoOpinBO.getInstance();
  
    //Construtor
    public IntegracaoOpin() { }

    //Efetua os passos necessários para a integração OPIN
    public void executar(Product2 produto) {

        //Obtém os dados a serem enviados
        IntegracaoOpinTO dadosOpin = opinBO.montarOpinTO(produto);
        String jsonNovo = JSON.serialize(dadosOpin);

        //Não havendo mudança nos dados a serem enviados, aborta processamento
        ProdutoIntegracaoOpin__c ultimaIntegracao = ProdutoIntegracaoOpinDAO.getInstance().buscarProdutoIntegracaoOpin(produto.id);
        if (!verificarNecessidadeReenvio(produto.id, jsonNovo, ultimaIntegracao)) {
            System.debug('INFO - Dados relevantes não modificados desde a última integração.');
            return;
        }
/*
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadEnvioOPIN' LIMIT 1];
        String payload = sr.Body.toString();        
        jsonNovo = payload; 
*/

        //Dispara envio dos dados para OPIN
        IntegracaoOpinService.getInstance().enviar(jsonNovo);

        //Grava as informações da integração realizada (Atualização após Callout - OK)
        atualizarDadosIntegracaoOpin(produto.id, ultimaIntegracao, jsonNovo);

    }

    //Efetua a geração dos Jsons dos Produtos e a montagem da base para envio ao OPIN
    public void gerarProdutoOPIN() {

        //Seleciona os produtos Opin já gerados
        Map<Id, ProdutoOPIN__c> mapProdGerados = new  Map<Id, ProdutoOPIN__c>();
        List<ProdutoOPIN__c> prodsGerados = ProdutoOpinDAO.getInstance().buscarProdutosOPIN();
        for(ProdutoOPIN__c prodGer: prodsGerados) {
            mapProdGerados.put(prodGer.Name, prodGer);
        }
        
        //Seleciona produtos para geração de base para envio a OPIN
        List<Product2> prods = ProductDAO.getInstance().buscarProdutosParaOpin(); 

        Integer LIMITE = 40;
        Integer contador = 0;
        List<ProdutoOPIN__c> prodsOPINUps = new List<ProdutoOPIN__c>();
        for(Product2 produto: prods) {

            if (mapProdGerados.get(produto.id) <> null) {
                continue; //Caso já gerado, não gera novamente
            }
            System.debug('Danilo antes gerarProdutoOPIN');
            IntegracaoOpinTO.PersonProductsTO personProductTO = opinBO.montarProdutoOpinTO(produto);
            System.debug('Danilo depois gerarProdutoOPIN');
            ProdutoOPIN__c produtoOpin = new ProdutoOPIN__c(
                Name = produto.id,
                SiglaProduto__c = produto.Name,
                SistemaOrigem__c = 'SALESFORCE',
                DetalhesJson__c = JSON.serialize(personProductTO)
            );

            prodsOPINUps.add(produtoOpin);

            contador += 1;

            //Impede que o limite de linhas processadas estoure. Caso hava mais produtos, o botão
            //      deverá ser disparado novamente.
            //      TO DO - Discutir para v2  prever melhoria para não haver limite
            if (contador >= LIMITE) {
                break; 
            }
        }
        
        upsert prodsOPINUps Name;
    }

    public void enviarTodosProdutosOPIN() {

        //Selecionar um produto base, para uso da geração dos atributos fora de Produto
        List<Product2> produtosParaOpin = ProductDAO.getInstance().buscarProdutosParaOpin();

        //Selecionar os Jsons a serem enviados, montando uma lista de PersonProductsTO
        List<IntegracaoOpinTO.PersonProductsTO> personProducts = new List<IntegracaoOpinTO.PersonProductsTO>();
        List<ProdutoOPIN__c> produtosOpin = ProdutoOpinDAO.getInstance().buscarProdutosOPIN();
        
        System.debug('Danilo antes do for');
        System.debug('Danilo produtosOpin.size()' + produtosOpin.size());
        for(ProdutoOPIN__c produtoOpin:produtosOpin) {
            System.debug('Danilo produtoOpin ' +produtoOpin);
            personProducts.add((IntegracaoOpinTO.PersonProductsTO)JSON.deserialize(produtoOpin.DetalhesJson__c, IntegracaoOpinTO.PersonProductsTO.class));
        }

        //Executar a geração da TO pela wrapper, chamando o constructor q passa a lista de PersonProducts
        System.debug('Danilo antes do dadosOpin');
        IntegracaoOpinTO dadosOpin = opinBO.montarOpinTO(produtosParaOpin[0], personProducts);
        String jsonComTodosProdutos = JSON.serialize(dadosOpin);
        system.debug('jsonComTodosProdutos = ' + jsonComTodosProdutos);

        //Executar a transmissão ao CIV 
        IntegracaoOpinService.getInstance().enviar(jsonComTodosProdutos);     

    }

    private Boolean verificarNecessidadeReenvio(Id idProduto, String jsonNovo, ProdutoIntegracaoOpin__c ultimaIntegracao) {
        
        String jsonAtual = (ultimaIntegracao == null ? '' : ultimaIntegracao.Dados_Ultima_Integracao__c );

        //Checa a necessidade de envio dos dados
        return (verificarMudancaDados(jsonAtual, jsonNovo));
    }

    private Boolean verificarMudancaDados(String jsonAtual, String jsonNovo) {

        if (jsonAtual == '') {
            return true;
        }

        return (jsonAtual <> jsonNovo); // Caso algum dado dos jsons for diferente

    }

    private void atualizarDadosIntegracaoOpin(Id idProduto, ProdutoIntegracaoOpin__c produtoIntegracaoOK, String jsonNovo) {

        if (produtoIntegracaoOK == null) {
            produtoIntegracaoOK = new ProdutoIntegracaoOpin__c();
        }

        produtoIntegracaoOK.Dados_Ultima_Integracao__c = jsonNovo;
        produtoIntegracaoOK.Data_Ultima_Integracao__c = Datetime.now();
        produtoIntegracaoOK.Produto__c = idProduto;
        upsert produtoIntegracaoOK;

    }
}

//PLV-5230 - FIM