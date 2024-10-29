/*
*
* Classe responsável pelo processamento da busca de produtos
*
*/
public class ProductFacade {
	private static final ProductFacade instance = new ProductFacade();
	private ProductBO produtoBo = ProductBO.getInstance();
	private FormaPagametoBO formaPagamentoBo = FormaPagametoBO.getInstance();

	private ProductFacade() { }

	public static ProductFacade getInstance(){
		return instance;
	}

	//Busca produtos por segmento
	public ProductServiceTO.RetornoConsultaProdutoTO buscarProdutos(String segmento) {
		ProductServiceTO.RetornoConsultaProdutoTO retorno = new ProductServiceTO.RetornoConsultaProdutoTO();

        try { 
            //Realiza tratamento do nome do segmento
            Map<String, String> mapSegmento = new Map<String, String>();
            Map<Id, Set<Id>> produtoIdFormaPagamentoIds = new Map<Id, Set<Id>>();
            mapSegmento.put('VI', 'Individual');
            mapSegmento.put('VG', 'Coletivo');
            segmento = mapSegmento.get(segmento);

            //Busca todos os produtos de um segmento, e monta estrutura de retorno do serviço
            for (Product2 produto : produtoBo.buscarProdutosComerciaisPorSegmento(segmento)) {
                retorno.produtos.add(this.gerarProductTO(retorno, produto));

                //Recupera todas ids de forma de pagamento associado as condiçõe de pagamento do produto
                for (CondicaoCobranca__c condicaoCobranca : produto.CondicoesCobranca__r) {
                  	if(!produtoIdFormaPagamentoIds.containsKey(produto.Id)){
                  		produtoIdFormaPagamentoIds.put(produto.Id, new Set<Id>());
                  	}
                  	produtoIdFormaPagamentoIds.get(produto.Id).add(condicaoCobranca.FormaPagamento__c);
                }
            }

            //Gera as formas de pagamento para cada produto encontrado
            this.gerarFormasPagamento(retorno, produtoIdFormaPagamentoIds);
            retorno.mensagem = 'Consulta efetuada com sucesso';
        }
        catch(Exception e) {
        	retorno.produtos = null;
            retorno.mensagem = e.getLineNumber() + ': ' + e;
            retorno.erro = -1;
        }
        return retorno;
	}

	//Busca produtos código
	public ProductServiceTO.RetornoConsultaProdutoTO buscarProdutos(String codigoProduto, String tipoBusca) {
		ProductServiceTO.RetornoConsultaProdutoTO retorno = new ProductServiceTO.RetornoConsultaProdutoTO();

        try { 
        	//Busca produto pelo código e gera estrutura de retorno
        	Boolean verificarRegraProtocoloManual = tipoBusca != null && (tipoBusca == 'documentos' || tipoBusca == 'planos') ? true : false;
        	Map<Id, Set<Id>> produtoIdFormaPagamentoIds = new Map<Id, Set<Id>>();
        	Product2 produto = produtoBo.buscarProdutoPorCodigo(codigoProduto);

        	//Verifica se o produto pode ou não ser retornado
        	if(verificarRegraProtocoloManual){
        		Boolean possuiProtocoloManual = false;

        		//Verifica se possui algum documento tipo 'Protocolo manual'
        		for (DocumentoProduto__c documentoProduto : produto.DocumentosProduto__r) {
        			if(documentoProduto.MeioEnvio__c == 'Protocolo manual'){
        				possuiProtocoloManual = true;
        				break;
        			}
        		}

        		//Se não existir documento tipo 'Protocolo manual', retorna erro
        		if(!possuiProtocoloManual){
        			retorno.mensagem = 'Este produto não possui documento com meio de envio \'Protocolo manual\'';
            		retorno.erro = -1;
            		return retorno;
        		}
        	}

        	//Gera retorno do produto
        	retorno.produtos.add(this.gerarProductTO(retorno, produto));

        	//Não gera forma de pagamentos quando busca for por docuementos
        	if(tipoBusca != 'documentos'){
                //Recupera todas ids de forma de pagamento associado as condiçõe de pagamento do produto
                for (CondicaoCobranca__c condicaoCobranca : produto.CondicoesCobranca__r) {
                    if(!produtoIdFormaPagamentoIds.containsKey(produto.Id)){
                        produtoIdFormaPagamentoIds.put(produto.Id, new Set<Id>());
                    }
                    produtoIdFormaPagamentoIds.get(produto.Id).add(condicaoCobranca.FormaPagamento__c);
                }
	        
	            //Gera as formas de pagamento para cada produto encontrado
	            this.gerarFormasPagamento(retorno, produtoIdFormaPagamentoIds);
        	}
            
            retorno.mensagem = 'Consulta efetuada com sucesso';
        }
        catch(Exception e) {
        	retorno.produtos = null;
            retorno.mensagem = e.getLineNumber() + ': ' + e;
            retorno.erro = -1;
        }
        return retorno;
	}

	//Realiza processamento da informação e retorna nó de ProductServiceTO.ProdutoTO
	private ProductServiceTO.ProdutoTO gerarProductTO(ProductServiceTO.RetornoConsultaProdutoTO retorno, Product2 produto){
		ProductServiceTO.ProdutoTO produtoRetorno = new ProductServiceTO.ProdutoTO();
        produtoRetorno.codigoProduto = Integer.valueOf(produto.ProductCode);
        produtoRetorno.descricao = produto.Name;
        produtoRetorno.documentos = new List<ProductServiceTO.DocumentoTO>();
        produtoRetorno.formasPagamento = new List<ProductServiceTO.FormaPagamentoTO>();

        for (DocumentoProduto__c documentoProduto : produto.DocumentosProduto__r) {
            ProductServiceTO.DocumentoTO documentoRetorno = new ProductServiceTO.DocumentoTO();
            documentoRetorno.nomeDocumento = documentoProduto.Documento__c;
            documentoRetorno.documentoObrigatorio = false; //FIXO, ESTE DADO AINDA NÃO EXISTE NO SF
            produtoRetorno.documentos.add(documentoRetorno);
        }

        //Gera map que será util no momento do processamento das formas de pagamento
        retorno.mapProdutoTO.put(produto.Id, produtoRetorno);

        return produtoRetorno;
	}

	//Gera as forma de pagamentos para cada produto encontrado na lista
	private void gerarFormasPagamento(ProductServiceTO.RetornoConsultaProdutoTO retorno, Map<Id, Set<Id>> produtoIdFormaPagamentoIds){
		Set<Id> todasFormaPagamentoIds = new Set<Id>();
        Map<Id, FormaPagamento__c> mapFormasPagamento = new Map<Id, FormaPagamento__c>();

		//Recupera todas as ids de ramo de seguro
		for(Set<Id> formaPagamentoIds : produtoIdFormaPagamentoIds.values()){
			todasFormaPagamentoIds.addAll(formaPagamentoIds);
		}

		//Gera map com a relação de ramo de seguro e formas de pagamento
		for(FormaPagamento__c formaPgto : formaPagamentoBo.buscarFormasPagamentoPorIds(todasFormaPagamentoIds)){
            mapFormasPagamento.put(formaPgto.Id, formaPgto);
		}

		//Gera os dados de retorno
		for(Id produtoId : produtoIdFormaPagamentoIds.keySet()){
			for(Id formaPagamentoId : produtoIdFormaPagamentoIds.get(produtoId)){
				retorno.mapProdutoTO.get(produtoId).formasPagamento.add(this.gerarFormaPagamentoTo(mapFormasPagamento.get(formaPagamentoId)));
			}
		}
	}

	//Realiza parse da estrutura 
	private ProductServiceTO.FormaPagamentoTO gerarFormaPagamentoTo(FormaPagamento__c formaPgto){
		ProductServiceTO.FormaPagamentoTO formaPagamentoTo = new ProductServiceTO.FormaPagamentoTO();
		formaPagamentoTo.codigo = formaPgto.Codigo__c;
		formaPagamentoTo.descricao = formaPgto.Name;
		formaPagamentoTo.ramoSeguro = formaPgto.RamoSeguro__r.Codigo__c;

        if(formaPgto.Modalidade__c != null)
		  formaPagamentoTo.modalidade = Integer.valueOf(formaPgto.Modalidade__r.Codigo__c);

		for(PlanoParcelamento__c plano : formaPgto.PlanosParcelamento__r){
			ProductServiceTO.ParcelaTO parcela = new ProductServiceTO.ParcelaTO();
			parcela.numeroParcela = plano.NumeroParcela__c;
			parcela.meioRecebimento = plano.CodigoMeioRecebimento__c;
			formaPagamentoTo.parcelas.add(parcela);
		}

		return formaPagamentoTo;
	}
}