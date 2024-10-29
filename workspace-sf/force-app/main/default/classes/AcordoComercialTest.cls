/**
 * Testes Acordo comercial
 * @author Alex Gomes @ 22/02/2018
 *
 **/
@isTest
class AcordoComercialTest {

	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
	}
	
	@isTest
	static void validarGeracaoProdutoAcordo() 
	{
		RetornoAcaoBotaoTO resposta;

		Map<String,List<SObject>> objetoDados = TestDataFactory.gerarProdutoComercialAtivo(false);
		Product2 produtoCom = (Product2)objetoDados.get('Product2').get(0);

		// CRIA CANAL DE DISTRIBUIÇÃO
		CanalDistribuicao__c canalDistribuicao1 = new CanalDistribuicao__c(
			Name = 'Canal 1',
			Papeis__c = 'Corretor',
			Status__c = 'Em criação'
		);

		insert canalDistribuicao1;

		canalDistribuicao1.Status__c = 'Em ativação';
		update canalDistribuicao1;

		canalDistribuicao1.Status__c = 'Ativo';
		update canalDistribuicao1;

		CanalDistribuicao__c canalDistribuicao2 = new CanalDistribuicao__c(
			Name = 'Canal 2',
			Papeis__c = 'Corretor',
			Status__c = 'Em criação'
		);

		insert canalDistribuicao2;

		canalDistribuicao2.Status__c = 'Em ativação';
		update canalDistribuicao2;

		canalDistribuicao2.Status__c = 'Ativo';
		update canalDistribuicao2;

		// CRIA PRODUTOS DO CANAL DE DISTRIBUIÇÃO
		ProdutoCanal__c produtoCanal = new ProdutoCanal__c(
			CanalDistribuicao__c = canalDistribuicao1.Id,
			Produto__c = produtoCom.Id,
			ModeloRemuneracao__c = 'Nominal'
		);

		insert produtoCanal;

		// TESTES

		TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c();
		tipoRemuneracao.Name = 'Remuneração Teste';
		tipoRemuneracao.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
		tipoRemuneracao.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracao;

		// CRIA UM ACORDO
		AcordoComercial__c acordo = new AcordoComercial__c(
			Name = 'Acordo xpto',
			CanalDistribuicao__c = canalDistribuicao1.Id,
			TipoRemuneracao__c = tipoRemuneracao.Id,
			VigenciaInicial__c = System.today().addDays(30),
			Periodicidade__c = 'Mensal',
			MomentoPagamento__c = 'Emissão',
			ModeloRemuneracao__c = 'Pontos',
			Valor__c = 5
		);

		insert acordo;

		//Executa chamado do botão customizado 
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(AcordoComercialAcaoBotaoController.gerarProdutosAcordoComercial(acordo.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Verifica se foi criado o produto do acordo
		ProdutoAcordo__c produtoAcordo = [Select Id, Produto__c From ProdutoAcordo__c Where AcordoComercial__c =: acordo.Id Limit 1];
		System.assert(produtoAcordo != null);
		System.assertEquals(produtoAcordo.Produto__c, produtoCanal.Produto__c);

		//Altera o canal de distribuicao do acordo
		acordo.CanalDistribuicao__c = canalDistribuicao2.Id;
		update acordo;

		//Executa novamente chamada no botão para considerar os produtos do canal novo
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(AcordoComercialAcaoBotaoController.gerarProdutosAcordoComercial(acordo.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Verica se apenas foi removido o produto do acordo anterior (não vai criar novo, pois canalDistribuicao2 nao tem produto)
		List<ProdutoAcordo__c> produtosAcordo = [Select Id, Produto__c From ProdutoAcordo__c Where AcordoComercial__c =: acordo.Id];
		System.assert(produtosAcordo.isEmpty());

		//Altera novamente para o canalDistribuicao1, que possui produto.
		acordo.CanalDistribuicao__c = canalDistribuicao1.Id;
		update acordo;

		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(AcordoComercialAcaoBotaoController.gerarProdutosAcordoComercial(acordo.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		produtoAcordo = [Select Id, Produto__c From ProdutoAcordo__c Where AcordoComercial__c =: acordo.Id Limit 1];
		System.assert(produtoAcordo != null);
		System.assertEquals(produtoAcordo.Produto__c, produtoCanal.Produto__c);

		//Teste canal de distribuição não preenchido
		acordo.CanalDistribuicao__c = null;
		update acordo;

		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(AcordoComercialAcaoBotaoController.gerarProdutosAcordoComercial(acordo.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.ERROR);
		System.assertEquals('Não foi possível gerar os produtos do acordo, pois não foi encontrado Canal de distribuição.', resposta.mensagens.get(0));
	}

	@isTest
	static void atualizarVersaoProdutoAcordoComercialTest(){

		Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome produtoTec 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '201700001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		produtoTec.TipoResponsavelPagamento__c = 'SEG';
		insert produtoTec;

		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234x';
		update produtoTec;

		produtoTec.Status__c = 'Ativo';
		update produtoTec;

		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		produtoCom.VersaoMaxima__c = false;
		insert produtoCom;

		// Product2 produtoComercial = [SELECT Id, Name, Status__c FROM Product2 WHERE Id =: produtoCom.Id];
		
		// produtoComercial.Status__c = 'Em ativação';
		// produtoComercial.NumeroSusep__c = '1234';
		// update produtoComercial;

		// // produtoComercial.Status__c = 'Ativo';
		// // update produtoComercial;

		Test.startTest();
		Product2 produtoTecnico = TestDataFactory.gerarProdutoTecnico();
		// Product2 produtoComercial = TestDataFactory.gerarProdutoComericial(produtoTecnico);

		
		Set<String> setProductCode = new Set<String>();
		// setProductCode.add(produtoCom.ProductCode);

		// List<Product2> listNovosProduto = new List<Product2>{produtoComercial};
		List<Product2> listNovosProduto = new List<Product2>{produtoCom};

		for(Product2 produto : listNovosProduto){
			setProductCode.add(produto.ProductCode);
		}


		List<AggregateResult> listAggregateResults = ProductDAO.getInstance().buscarProdutoMaximaVersao(setProductCode, 'ProdutoComercial');
		List<ProdutoAcordo__c> produtoAcordoList = AcordoComercialDAO.getInstance().buscarProdutosPorProductCode(setProductCode);

		Map<String, Product2> mapProdutoMaximaVersao = new Map<String, Product2>();

		if(!listAggregateResults.isEmpty()){
			for(Integer i = 0; i < listAggregateResults.size(); i++){
				String productCodeMaximaVersao = (String)listAggregateResults[i].get('ProductCode');
				mapProdutoMaximaVersao.put(productCodeMaximaVersao, produtoCom);
			}
		}

		AcordoComercialBO.getInstance().atualizarVersaoProdutoAcordoComercial(mapProdutoMaximaVersao, produtoAcordoList);
		Test.stopTest();
	}
}