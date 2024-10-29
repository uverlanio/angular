@isTest
private class SeletorParametrosVigenciaTest {
	
	@testSetup 
	static void setup(){
        TestDataFactory.gerarDadosSetup();

        dadosBuscarParametrosVigencia();
        dadosClonarParametroVigencia();
	}

    @isTest
    public static void dadosBuscarParametrosVigencia(){
    	//Test.startTest();
    	//FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
		
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
		insert produtoCom;

		ParametroVigencia__c parametroVigencia = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);

    	List<ParametroVigencia__c> lstParametroVigencia = SeletorParametrosVigenciaController.buscarParametrosVigencia(produtoCom.Id);
    	//Test.stopTest();
    	System.assertEquals(1, lstParametroVigencia.size());
    }

    @isTest
    public static void dadosClonarParametroVigencia(){
    	//Test.startTest();
    	//FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
		
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
		insert produtoCom;

		ParametroVigencia__c parametroVigencia = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);
		FaixaDevolucao__c faixaDevolucao = TestDataFactory.gerarFaixaDevolucaoProdutoComercial(parametroVigencia);

		Id idRetorno = SeletorParametrosVigenciaController.clonarParametroVigencia(produtoCom.Id, parametroVigencia.Id);
    	//Test.stopTest();
    	System.assertEquals(true, (idRetorno != null));
    }
	
}