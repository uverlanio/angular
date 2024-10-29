/**
 * Testes Product2
 * @author Fernando Barcellos @ 01/11/2017
 *
 **/
@isTest
private class ProductTest {

	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
	}

	@isTest
	private static void testarAtivacaoGeracaoNovaVersao(){
		RetornoAcaoBotaoTO resposta;

		FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
		Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
    	Account contaTeste = TestDataFactory.gerarConta();
		RamoSeguro__c ramoVida = TestDataFactory.gerarRamoSeguro(contaTeste);
		TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
		Modalidade__c modalidade1 = TestDataFactory.gerarModalidade(ramoVida);
		Garantia__c garantia = TestDataFactory.gerarGarantia();
		RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoVida);
		GarantiaProduto__c garantiaProdutoTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoVida);
        limiteGarantiaProduto__c limGarantiaProdTec = (limiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(garantiaProdutoTec).createRecord(); //PLV - 3046
		PremioMinimoProduto__c premioMinimo = TestDataFactory.gerarPremioMinimoProdutoTecnico(produtoTec, formaPagamento);
		//ContentDocumentLink arquivoTec = TestDataFactory.gerarDocumentoProduto(produtoTec); // correcao ambientes
		ParametroVigencia__c paramVigenciaTec = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);
		RemuneracaoProduto__c remuneracaoProduto = TestDataFactory.gerarRemuneracaoProduto(produtoTec, tipoRemuneracao);
		
		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234x';
		update produtoTec;

		//Ativa o produto
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.ativarProduto(produtoTec.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Criação dos dados
		Product2 produto = TestDataFactory.gerarProdutoComericial(produtoTec);
		ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoComercial(produto);
		FaixaDevolucao__c faixa = TestDataFactory.gerarFaixaDevolucaoProdutoComercial(paramVigencia);
		GarantiaProduto__c garantiaProdutoCom = TestDataFactory.gerarGarantiaProdutoComercial(produto, garantia, garantiaProdutoTec, ramoVida);
		Territorio__c territorioGarantia = TestDataFactory.gerarTerritorioGarantiaComercial(garantiaProdutoCom);

		//Teste produto inativo
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.gerarNovaVersao(produto.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.ERROR);
		System.assert(resposta.mensagens.get(0).indexOf('Produto não ativado. Por favor, ativar o produto antes de executar esta ação.') > -1);

		//Ativa produto
		//ContentDocumentLink arquivo = TestDataFactory.gerarDocumentoProduto(produto); //correcao ambientes
		RemuneracaoProduto__c remuneracaoProdutoCom = TestDataFactory.gerarRemuneracaoProduto(produto, tipoRemuneracao);
		PremioMinimoProduto__c premioMinimoCom = TestDataFactory.gerarPremioMinimoProdutoComercial(produto, formaPagamento);
		Questionario__c questionario = TestDataFactory.gerarQuestionario();
		//QuestionarioProduto__c questionarioProduto = TestDataFactory.gerarQuestionarioProduto(questionario, produto, garantiaProdutoCom);

		produto.Status__c = 'Em ativação';
		produto.NumeroSusep__c = '1234';
		produto.VigenciaFinal__c = null;
		update produto;

		//Ativa produto
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.ativarProduto(produto.Id), RetornoAcaoBotaoTO.class);
		produto = [SELECT Id, Status__c, ProdutoTecnico__c, Name, ProductCode, VigenciaInicial__c, VigenciaFinal__c, TipoCapital__c, RecordTypeId, NumeroSusep__c  From Product2 Where Id = :produto.Id];
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Teste clonagem registros
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.gerarNovaVersao(produto.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Ativa produto clonado. Necessário passar uma vigencia valida
		Product2 produtoClone = [Select Id, VigenciaInicial__c, VigenciaFinal__c, Versao__c,  Status__c, ProdutoTecnico__c From Product2 Where Id =: resposta.linkRedirecionar];
		//ContentDocumentLink arquivo2 = TestDataFactory.gerarDocumentoProduto(produtoClone); //correcao ambientes

		produtoClone.VigenciaInicial__c = System.today().addDays(2);
		produtoClone.Status__c = 'Em ativação';
		produtoClone.NumeroSusep__c = '12345';
		update produtoClone;

		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.ativarProduto(produtoClone.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);
		System.assertEquals(produtoClone.ProdutoTecnico__c, produtoTec.Id);

		//Valida valores do produto clonado e do original, após ativação do produto clonado
		Product2 produtoOriginal = [Select Id, VigenciaFinal__c From Product2 Where Id =: produto.Id];
		produtoClone = [Select Id, VigenciaInicial__c, VigenciaFinal__c, Versao__c,  Status__c From Product2 Where Id =: produtoClone.Id];
		System.assertEquals(produtoClone.Status__c, 'Ativo');
		System.assertEquals(produtoClone.Versao__c, 2);
		System.assertEquals(produtoOriginal.VigenciaFinal__c, produtoClone.VigenciaInicial__c.addDays(-1));

		//Teste clonagem produto sem vigencia
		//ESTA VALIDACAO FUNCIONA, POREM ESTOURA O LIMITE DE QUERY DEVIDO AOS TESTES ACIMA
		//resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.gerarNovaVersao(produtoOriginal.Id), RetornoAcaoBotaoTO.class);
		//System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.ERROR);
		//System.assert(resposta.mensagens.get(0).indexOf('Este produto não está vigente. Não é possível executar esta ação.') > -1);
	}

	@isTest
	private static void testarGeracaoProdutoComercial(){
		RetornoAcaoBotaoTO resposta;

		//Criação dos dados
		Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
		TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
		RemuneracaoProduto__c remuneracao = TestDataFactory.gerarRemuneracaoProduto(produtoTec, tipoRemuneracao);
		ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);
		FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
		PremioMinimoProduto__c premioMinimo = TestDataFactory.gerarPremioMinimoProdutoTecnico(produtoTec, formaPagamento);
    	Account contaTeste = TestDataFactory.gerarConta();
		RamoSeguro__c ramoVida = TestDataFactory.gerarRamoSeguro(contaTeste);
		Modalidade__c modalidade1 = TestDataFactory.gerarModalidade(ramoVida);
		Garantia__c garantia = TestDataFactory.gerarGarantia();
		RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoVida);
		GarantiaProduto__c garantiaProduto = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoVida);
        limiteGarantiaProduto__c limGarantiaProdTec = (limiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(garantiaProduto).createRecord(); //PLV - 3046
		Territorio__c territorioProduto = TestDataFactory.gerarTerritorioProdutoTecnico(produtoTec);
		Territorio__c territorioGarantia = TestDataFactory.gerarTerritorioGarantiaTecnica(garantiaProduto);
		DependenteGarantia__c dependenteGarantia = TestDataFactory.gerarDependenteGarantiaTecnica(garantiaProduto);

		//Teste produto inativo
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.gerarNovoProdutoComercial(produtoTec.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.ERROR);
		System.assert(resposta.mensagens.get(0).indexOf('Produto não ativado. Por favor, ativar o produto antes de executar esta ação.') > -1);

		//Ativa produto
		//ContentDocumentLink arquivo = TestDataFactory.gerarDocumentoProduto(produtoTec); //correcao ambientes

		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234';
		update produtoTec;

		//Ativa produto
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.ativarProduto(produtoTec.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Teste clonagem registros
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.gerarNovoProdutoComercial(produtoTec.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Ativa produto clonado. Necessário passar uma vigencia valida
		Product2 produtoClone = [Select Id, VigenciaInicial__c, VigenciaFinal__c, Versao__c, ProductCode, Status__c From Product2 Where Id =: resposta.linkRedirecionar]; //PLV-3493 - INICIO/FIM - Trazer o campo ProductCode para o teste
		//ContentDocumentLink arquivo2 = TestDataFactory.gerarDocumentoProduto(produtoClone); //correcao ambientes

		produtoClone.VigenciaInicial__c = System.today().addDays(2);
		produtoClone.ProductCode = '2009304920948'; //PLV-3493 - INICIO/FIM - Atribuído valor ao campo para o teste
		produtoClone.Status__c = 'Em ativação';
		produtoClone.NumeroSusep__c = '43434';
		update produtoClone;

		GarantiaProduto__c garantiaProdutoCom = TestDataFactory.gerarGarantiaProdutoComercial(produtoClone, garantia, garantiaProduto, ramoVida);
		ParametroVigencia__c paramVigenciaCom = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoClone);
		Questionario__c questionario = TestDataFactory.gerarQuestionario();
		QuestionarioProduto__c questionarioProduto = TestDataFactory.gerarQuestionarioProduto(questionario, produtoClone, garantiaProdutoCom);

		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.ativarProduto(produtoClone.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Valida valores do produto comercial
		produtoClone = [Select Id, VigenciaInicial__c, VigenciaFinal__c, Versao__c, ProdutoTecnico__c, RecordTypeId, Status__c From Product2 Where Id =: produtoClone.Id];
		System.assertEquals(produtoClone.Status__c, 'Ativo');
		System.assertEquals(produtoClone.RecordTypeId, RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id);

		//PLV-5348 FIX 2 - INICIO
		//Encontra a remuneração vinculada ao produto 
		RemuneracaoProduto__c remuneracaoClone = [Select Id, RemuneracaoProduto__c, RecordTypeId From RemuneracaoProduto__c Limit 1];

		System.assertEquals(remuneracaoClone.RecordTypeId, RecordTypeBO.buscarTipoRegistro('RemuneracaoProduto__c', 'ProdutoTecnico').Id);
		//PLV-5348 FIX 2 - FIM
		//Testa alteração tipo de registro de territorio
		Territorio__c territorioProdutoClone = [Select Id, Territorio__c, Produto__c, RecordTypeId From Territorio__c Where Produto__c =: produtoClone.Id];
		System.assertEquals(territorioProdutoClone.Territorio__c, territorioProduto.Id);
		System.assertEquals(territorioProdutoClone.RecordTypeId, RecordTypeBO.buscarTipoRegistro('Territorio__c', 'ProdutoComercial').Id);

		//NÃO É MAIS GERADO DE FORMA AUTOAMTICAs
		//GarantiaProduto__c garantiaProdutoClone = [Select Id From GarantiaProduto__c Where Produto__c =: produtoClone.Id Limit 1];
		//Territorio__c territorioGarantiaClone = [Select Id, Territorio__c, GarantiaProduto__c, RecordTypeId From Territorio__c Where GarantiaProduto__c =: garantiaProdutoClone.Id];
		//System.assertEquals(territorioGarantiaClone.Territorio__c, territorioGarantia.Id);
		//System.assertEquals(territorioGarantiaClone.RecordTypeId, RecordTypeBO.buscarTipoRegistro('Territorio__c', 'GarantiaProdutoComercial').Id);
	}

	@isTest
	private static void testarGeracaoCodigoProduto() {
		//Verifica contador
		ContadorCodigo__c contadorCodigoProduto = [Select Id, Numero__c From ContadorCodigo__c Where Name = 'ProdutoTecnico' limit 1 ];
		Product2 produto;
		System.assertEquals(contadorCodigoProduto.Numero__c, 0);

		Test.startTest();

		//Gera produto
		produto = new Product2(
			Name = 'Produto Sem código',
			Status__c = 'Em criação',
			VigenciaInicial__c = System.today().addDays(3),
			TipoCapital__c = 'Capital uniforme',
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
			TipoResponsavelPagamento__c = 'SEG'
		);
		insert produto;

		Test.stopTest();

		//Valida contador e o código gerado no produto
		produto = [Select Id, ProductCode From  Product2 Where Id =: produto.Id];
		System.assertEquals(produto.ProductCode, '1');

		contadorCodigoProduto = [Select Id, Numero__c From ContadorCodigo__c Where Name = 'ProdutoTecnico' limit 1 ];
		System.assertEquals(contadorCodigoProduto.Numero__c, 1);
	}

	
	// PLV-3316 - INICIO
	@isTest
	private static void obrigaMomentoCancelamentoTest(){		
		RetornoAcaoBotaoTO resposta;

		FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
		Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
    	Account contaTeste = TestDataFactory.gerarConta();
		RamoSeguro__c ramoVida = TestDataFactory.gerarRamoSeguro(contaTeste);
		TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
		Modalidade__c modalidade1 = TestDataFactory.gerarModalidade(ramoVida);
		Garantia__c garantia = TestDataFactory.gerarGarantia();
		RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoVida);
		GarantiaProduto__c garantiaProdutoTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoVida);
        limiteGarantiaProduto__c limGarantiaProdTec = (limiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(garantiaProdutoTec).createRecord(); //PLV - 3046
		PremioMinimoProduto__c premioMinimo = TestDataFactory.gerarPremioMinimoProdutoTecnico(produtoTec, formaPagamento);
		//ContentDocumentLink arquivoTec = TestDataFactory.gerarDocumentoProduto(produtoTec); //correcao ambientes
		ParametroVigencia__c paramVigenciaTec = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);
		RemuneracaoProduto__c remuneracaoProduto = TestDataFactory.gerarRemuneracaoProduto(produtoTec, tipoRemuneracao);
		
		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234x';
		update produtoTec;

		//Ativa o produto
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.ativarProduto(produtoTec.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Criação dos dados
		Product2 produto = TestDataFactory.gerarProdutoComericial(produtoTec);
		ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoComercial(produto);
		FaixaDevolucao__c faixa = TestDataFactory.gerarFaixaDevolucaoProdutoComercial(paramVigencia);
		GarantiaProduto__c garantiaProdutoCom = TestDataFactory.gerarGarantiaProdutoComercial(produto, garantia, garantiaProdutoTec, ramoVida);
		Territorio__c territorioGarantia = TestDataFactory.gerarTerritorioGarantiaComercial(garantiaProdutoCom);

		garantiaProdutoCom.CancelaSegurado__c = true;
		garantiaProdutoCom.PercentualMaximoCancelamento__c = 100;
		update garantiaProdutoCom;

		produto.Status__c = 'Ativo';
		Try{
			update produto;
		}catch(exception e){}
	}
	// PLV-3316 - FIM

}