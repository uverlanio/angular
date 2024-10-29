@isTest
public class CriticaContratoTriggerTest { 
    
   @isTest
  private static void testEmissaoPropostaMassificados()
  {
  
    TestDataFactory.gerarDadosSetup();
	
	Map<String,List<SObject>> mapListObject = TestDataFactory.gerarContrato(true);

	Contract contrato = (Contract) TestDataFactory.pegarRegistro(mapListObject, 'Contract');

	CriticaContrato__c criticaContrato = new CriticaContrato__c(
		Contrato__c = contrato.Id,
		Area__c = 'Teste Area'
		
	);
	insert criticaContrato;

	criticaContrato.Area__c = 'Teste';

	update criticaContrato;

	delete criticaContrato;

	System.assertEquals(true, (contrato != null));
    }
	@isTest
	private static void testin(){
		
		ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
		ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
		Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
		produtoTecnico.Status__c = 'Em ativação';
		produtoTecnico.NumeroSusep__c = '123';
		produtoTecnico.VersaoRenovacao__c = 'Versão atual';
		update produtoTecnico;
		produtoTecnico.Status__c = 'Ativo';
		produtoTecnico.segmento__c = 'Individual'; //PLV-4168 - V.I - INICIO/FIM
		update produtoTecnico;
		Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
		produtoComercial.ProductCode = '1';
		produtoComercial.Status__c = 'Ativo';
		produtoComercial.segmento__c = 'Individual'; //PLV-4168 - V.I - INICIO/FIM
		produtoComercial.CodigoPrecificaProduto__c = 'VI-PESSOAS'; // PLV-5331 INICIO / FIM
		update produtoComercial;
		FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
		CondicaoCobranca__c condicaoCobranca = (CondicaoCobranca__c) new CondicaoCobrancaFactory.CondicaoCobranca(produtoComercial, formaPagamento).createRecord();
		RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory().createRecord();
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
		RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
		GarantiaProduto__c garantiaProdutoTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
		GarantiaProduto__c garantiaProdutoCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garantiaProdutoTec, ramoSeguro).createRecord();

		Account contaTeste = TestDataFactory.gerarConta();
		Endereco__c endereco = TestDataFactory.gerarEndereco(contaTeste);
		RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
		Garantia__c garantia1 = TestDataFactory.gerarGarantia();
		Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
		garantiaCobertura.name = 'Produto Porto';
		update garantiaCobertura;
		RamoGarantia__c ramoGarantia1 = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
		Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
		produtoTec.Status__c = 'Ativo';
		update produtoTec;
		Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
		Map<String,List<SObject>> mapListSObject = TestDataFactory.gerarProdutoComercialAtivo(false);
		produtoCom.Status__c ='ativo';
		update produtoCom;
		CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
		canalDistribuicao.Status__c = 'Ativo';
		update canalDistribuicao;
		ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoCom);
		Parceiro__C parceiro = TestDataFactory.gerarParceiro(contaTeste, formaPagamento);
		ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoCom);
		Opportunity opp = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
		DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
		TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
		InformacaoBancaria__c InformacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaTeste);
		RemuneracaoProdutoParceiro__c RemuneracaoProdutoParceiro = TestDataFactory.gerarRemuneracaoProdutoParceiro(tipoRemuneracao, produtoParceiro, 20);
		FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(contaTeste, 20.00, 'Corretor', true, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);        
		Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
		Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, opp, modalidade);
		Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
		ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaTeste, contaTeste);
		GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
		SeguradoContrato__c segurado = TestDataFactory.gerarSeguradoContrato(grupoContrato, contaTeste);

		GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
		GrupoRisco__c grupoRisco = new GrupoRisco__c();
		Profissao__c profissao = new Profissao__c();

		profissao.CodigoProfissao__c = '2111-05';
		profissao.Name = 'Atuário';
		insert profissao;
		grupoRisco.Name = 'DIT';
		Insert grupoRisco;
		grupoProfissao.grupoRisco__c = grupoRisco.Id;
		grupoProfissao.profissao__c = profissao.Id;
		insert grupoProfissao;

		//GarantiaContrato__c garantiacont = TestDataFactory.gerarGarantiaContrato(contrato,garantiaProdutoCom);

		List<SObject> lstSObject = new List<SObject>();
		System.debug('<<<start>>>');
		GarantiaContrato__c garantiaContrato = new GarantiaContrato__c(
			Contrato__c = contrato.Id,
			GarantiaProduto__c = garantiaProdutoCom.Id,
			Garantia__c = garantiaProdutoCom.Garantia__c,
			TipoCapital__c = 'Capital uniforme',
			VersaoTitulo__c = '1'
		);
		lstSObject.add(garantiaContrato);

		RemuneracaoContrato__c remuneracaoContrato = new RemuneracaoContrato__c(
			Contrato__c = contrato.Id,
			TipoRemuneracao__c = tipoRemuneracao.Id
		);
		lstSObject.add(remuneracaoContrato);

		CriticaContrato__c criticaContrato = new CriticaContrato__c(
				Contrato__c = contrato.Id,
				Area__c = 'Teste Area'
				
			);
		lstSObject.add(criticaContrato);
		insert lstSObject;
        
        List<RemuneracaoContrato__c> remuneracaolist = [SELECT Id FROM RemuneracaoContrato__c];
        List<CriticaContrato__c> cricitalst = [SELECT Id FROM CriticaContrato__c];
        List<GarantiaContrato__c> garantialst = [SELECT Id FROM GarantiaContrato__c];
        system.debug('size remuneração>>' + remuneracaolist);
        System.debug('size garantialst>> ' + garantialst);
        System.debug('size cricitalst>> ' + cricitalst);
	}
}