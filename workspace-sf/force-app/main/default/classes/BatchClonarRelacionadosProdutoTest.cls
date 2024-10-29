/*********************************************************************************************************************************************************************
@description  Classe de teste para a classe BatchClonarRelacionadosProduto
@author Lucas Hikage - Sys4b
@date 20/08/2020
@Classe criada por conta da história PLV-4183    
**********************************************************************************************************************************************************************/
@isTest
private class BatchClonarRelacionadosProdutoTest {

	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
        
        
	}

	@isTest
	static void executeTest() {
		
		// PLV-4472 INICIO
        Account contaParceiro = new Account(Name = 'ParceiroTeste', IdExterno__c = '74586138825',  Cnpj__c = '38.579.897/0001-22');
        insert contaParceiro;

        Account contaCorretor = new Account(Name = 'ContaCorretor', Papel__c = 'Corretor', IdExterno__c = '38012786532', Cnpj__c = '08.370.609/0001-64' );
		insert contaCorretor;
		// PLV-4472 FIM

        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__c parceiro = TestDataFactory.gerarParceiro(contaParceiro,formaPagamento);
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        Account contaTeste = TestDataFactory.gerarConta();
		RamoSeguro__c ramoVida = TestDataFactory.gerarRamoSeguro(contaTeste);
        ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
        RemuneracaoProduto__c remuneracaoProduto = TestDataFactory.gerarRemuneracaoProduto(produtoTec, tipoRemuneracao);
        Modalidade__c modalidade1 = TestDataFactory.gerarModalidade(ramoVida);
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoVida);
        GarantiaProduto__c garantiaProdutoTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoVida);
        GarantiaProduto__c garantiaProdutoTec2 = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoVida);
        
        Carencia__c carencia = new Carencia__c(
			Name = 'Carencia 1'
		);
		insert carencia;

		CarenciaGarantia__c carenciaGarantiaTec = new CarenciaGarantia__c(
			GarantiaProduto__c = garantiaProdutoTec.Id,
			Carencia__c = carencia.Id,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('CarenciaGarantia__c', 'ProdutoTecnico').Id
		);
		insert carenciaGarantiaTec;
        
        Franquia__c franquia = new Franquia__c(
			Name = 'Franquia 1'
		);
		insert franquia;

		FranquiaGarantia__c franquiaGarantiaTec = new FranquiaGarantia__c(
			GarantiaProduto__c = garantiaProdutoTec.Id,
			Franquia__c = franquia.Id,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('FranquiaGarantia__c', 'ProdutoTecnico').Id
		);
		insert franquiaGarantiaTec;
               
        produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234';
		update produtoTec;

		produtoTec.Status__c = 'Ativo';
		update produtoTec;
        
		Product2 produtoComercial = TestDataFactory.gerarProdutoComericial(produtoTec);
		produtoComercial.Status__c = 'Ativo';
		update produtoComercial;
		ParametroVigencia__c paramVigenciaComercial = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoComercial);
		FaixaDevolucao__c faixa = TestDataFactory.gerarFaixaDevolucaoProdutoComercial(paramVigenciaComercial);
		GarantiaProduto__c garantiaProdutoCom = TestDataFactory.gerarGarantiaProdutoComercial(produtoComercial, garantia, garantiaProdutoTec, ramoVida);
        GarantiaProduto__c garantiaProdutoCom2 = TestDataFactory.gerarGarantiaProdutoComercial(produtoComercial, garantia, garantiaProdutoTec, ramoVida);
		Territorio__c territorioGarantia = TestDataFactory.gerarTerritorioGarantiaComercial(garantiaProdutoCom);
        territorioGarantia.Produto__c = produtoComercial.Id;
        
        update territorioGarantia;
        
        RemuneracaoProduto__c remuneracaoProdutoComercial = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracao);
        
		ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);
        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro = TestDataFactory.gerarRemuneracaoProdutoParceiro(tipoRemuneracao, produtoParceiro, 100);
        remuneracaoProdutoParceiro.RemuneracaoProduto__c = remuneracaoProdutoComercial.Id;
        
        update remuneracaoProdutoParceiro;
        
        GarantiaRelacionada__c garantiaRelTest = (GarantiaRelacionada__c) new GarantiaRelacionadaFactory.ProdutoTecnico(garantiaProdutoTec, garantiaProdutoTec2).createRecord();
        GarantiaRelacionada__c garantiaRelTest2 = (GarantiaRelacionada__c) new GarantiaRelacionadaFactory.ProdutoComercial(garantiaProdutoCom, garantiaProdutoCom2).createRecord();
        
        ParametroRenovacao__c parametroRenovacao = new ParametroRenovacao__c(
			GarantiaProduto__c = garantiaProdutoCom.Id,
			TipoSegurado__c = 'Filhos',
			IdadeMaximaRenovacao__c = 5,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroRenovacao__c', 'ProdutoComercial').Id
		);
        
		insert parametroRenovacao;
        
        CondicaoCobranca__c condicaoCobranca = TestDataFactory.gerarCondicaoCobranca(produtoComercial, formaPagamento);
        
        Questionario__c questionario = TestDataFactory.gerarQuestionario();
        QuestionarioProduto__c questionarioProduto = TestDataFactory.gerarQuestionarioProduto(questionario, produtoComercial, garantiaProdutoCom);
        
        PremioMinimoProduto__c premioMinimoCom = TestDataFactory.gerarPremioMinimoProdutoComercial(produtoComercial, formaPagamento);
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
        
        ProdutoAcordo__c produtoAcordo = new ProdutoAcordo__c(
            Produto__c = produtoComercial.Id,
            AcordoComercial__c = acordo.Id
       	);
        insert produtoAcordo;
        
        DocumentoProduto__c documentoProdutoEntrada1 = new DocumentoProduto__c();
		documentoProdutoEntrada1.Produto__c = produtoComercial.Id;
		documentoProdutoEntrada1.MomentoEnvio__c = 'Endosso';
		documentoProdutoEntrada1.Tipo__c = 'Entrada';
		documentoProdutoEntrada1.MeioEnvio__c = 'Email';
		documentoProdutoEntrada1.Documento__c = 'Declaração Pessoal de Saúde';
		documentoProdutoEntrada1.Papel__c = 'Corretor';
		documentoProdutoEntrada1.Descricao__c = 'Documento do produto - Entrada';
		insert documentoProdutoEntrada1;
        
        
        Risco__c risco = new Risco__c(
			Name = 'Risco 1'
		);
		insert risco;

		RiscoGarantia__c riscoGarantiaCom = new RiscoGarantia__c(
			GarantiaProduto__c = garantiaProdutoCom.Id,
			Risco__c = risco.Id,
			PermiteAlterarProdutoComercial__c = false,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('RiscoGarantia__c', 'ProdutoComercial').Id
		);
		insert riscoGarantiaCom;
        
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        insert grupoRisco;
        
        GrupoRiscoGarantia__c grupoRiscoGarantiaCom = new GrupoRiscoGarantia__c(
        	GarantiaProduto__c = garantiaProdutoCom.Id,
            GrupoRisco__c = grupoRisco.Id
        );
        insert grupoRiscoGarantiaCom;
        
        
		Carencia__c carencia2 = new Carencia__c(
			Name = 'Carencia 2'
		);
		insert carencia2;

		CarenciaGarantia__c carenciaGarantiaComercial = new CarenciaGarantia__c(
			GarantiaProduto__c = garantiaProdutoCom.Id,
			Carencia__c = carencia2.Id,
            CarenciaGarantia__c = carenciaGarantiaTec.Id, //PLV-4106
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('CarenciaGarantia__c', 'ProdutoComercial').Id
		);
		insert carenciaGarantiaComercial;
        
        Franquia__c franquia2 = new Franquia__c(
			Name = 'Franquia 2'
		);
		insert franquia2;

		FranquiaGarantia__c franquiaGarantiaComercial = new FranquiaGarantia__c(
			GarantiaProduto__c = garantiaProdutoCom.Id,
			Franquia__c = franquia2.Id,
            FranquiaGarantia__c = franquiaGarantiaTec.Id, //PLV-4106
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('FranquiaGarantia__c', 'ProdutoComercial').Id
		);
		insert franquiaGarantiaComercial;
        
        ComunicacaoProduto__c comunicacaoProduto = new ComunicacaoProduto__c(
        	Produto__c = produtoComercial.Id
        ); 
        
        insert comunicacaoProduto;
        
        Product2 produtoTecClone = TestDataFactory.gerarProdutoTecnico();
        produtoTecClone.VersaoAnterior__c = produtoTec.Id;
        produtoTecClone.Status__c = 'Em ativação';
		produtoTecClone.NumeroSusep__c = '1234';
		update produtoTecClone;
		
        
		produtoTecClone.Status__c = 'Ativo';
		update produtoTecClone;
        
        Test.startTest();
        
        BatchClonarRelacionadosProduto obj = new BatchClonarRelacionadosProduto(produtoTecClone);
		DataBase.executeBatch(obj); 
        
        Test.stopTest();
        
        List<GarantiaProduto__c> lstGarantiaProduto = [SELECT 	Id, VersaoAnterior__c 
                                                       FROM 	GarantiaProduto__c 
                                                       WHERE 	VersaoAnterior__c =: garantiaProdutoCom.Id
                                                       ];
        System.debug('lstGarantiaProduto - ' + lstGarantiaProduto);
        System.assert(lstGarantiaProduto.size() == 1);
        
		List<ParametroVigencia__c> lstParametroVigencia = [SELECT 	Id, VersaoAnterior__c 
                                                       		FROM 	ParametroVigencia__c 
                                                       		WHERE 	VersaoAnterior__c =: paramVigenciaComercial.Id
                                                       ];
        System.debug('lstParametroVigencia - ' + lstParametroVigencia);
        System.assert(lstParametroVigencia.size() == 1);

        List<DocumentoProduto__c> lstDocumentoProduto = [SELECT 	Id, VersaoAnterior__c 
                                                       	FROM 	DocumentoProduto__c 
                                                       	WHERE 	VersaoAnterior__c =: documentoProdutoEntrada1.Id
                                                       ];
        System.debug('lstDocumentoProduto - ' + lstDocumentoProduto);
        System.assert(lstDocumentoProduto.size() == 1);

        List<ComunicacaoProduto__c> lstComunicacaoProduto = [SELECT 	Id, VersaoAnterior__c 
                                                           FROM 	ComunicacaoProduto__c 
                                                           WHERE 	VersaoAnterior__c =: comunicacaoProduto.Id
                                                       ];
        System.debug('lstComunicacaoProduto - ' + lstComunicacaoProduto);
        System.assert(lstComunicacaoProduto.size() == 1);

        List<RemuneracaoProduto__c> lstRemuneracaoProduto = [SELECT 	Id, VersaoAnterior__c 
                                                           FROM 	RemuneracaoProduto__c 
                                                           WHERE 	VersaoAnterior__c =: remuneracaoProdutoComercial.Id
                                                       ];
        System.debug('lstRemuneracaoProduto - ' + lstRemuneracaoProduto);
        System.assert(lstRemuneracaoProduto.size() == 1);

        
    }
}