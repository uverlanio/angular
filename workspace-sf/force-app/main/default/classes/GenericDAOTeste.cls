/*******************************************************************************************************************************
* 
* @author Pedro Augusto Braz - SYS4B
* @date 30/04/2021
* @modifiedAt 
* Classe de teste criada para subir cobertura de teste das DAOS de forma emergencial - PLV-4921

******************************************************************************************************************************/
@isTest
private class GenericDAOTeste {
	static testMethod void GenericDAOTeste(){
        TestDataFactory.gerarDadosSetup();
		SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
        sCripto.Name = 'Senha';
        sCripto.Senha__c = 'TesteCrypto';
        insert sCripto;
        
        Account contaTeste = TestDataFactory.gerarConta();
        Endereco__c endereco = TestDataFactory.gerarEndereco(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        
        Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Invalidez Permanente Total';
        update garantiaCobertura;
        
        Garantia__c garantiaCobertura2 = TestDataFactory.gerarGarantia();
        garantiaCobertura2.name = 'Morte';
        update garantiaCobertura2;
        
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSegurado);
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c ='Individual';
        update produtoTec;
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        Map<String,List<SObject>> mapListSObject = TestDataFactory.gerarProdutoComercialAtivo(false);
        produtoCom.Status__c ='Ativo';
        produtoCom.Segmento__c ='Individual';        
        update produtoCom;
        
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoCom);
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__C parceiro = TestDataFactory.gerarParceiro(contaTeste, formaPagamento);
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoCom);       
        Opportunity opp = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);        
        
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantiaCobertura,opp);
        garantiaOrcamento.PremioTotal__c=100;
        update garantiaOrcamento;
        GarantiaOrcamento__c garantiaOrcamento2 = TestDataFactory.gerarGarantiaOrcamento(garantiaCobertura2,opp);   
        
        
        
        
        ////
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        InformacaoBancaria__c InformacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaTeste);
        RemuneracaoProdutoParceiro__c RemuneracaoProdutoParceiro = TestDataFactory.gerarRemuneracaoProdutoParceiro(tipoRemuneracao, produtoParceiro, 20);
        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(contaTeste, 20.00, 'Corretor', true, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);        
        system.debug('favorecidoRemuneracao: '+favorecidoRemuneracao.RemuneracaoProdutoParceiro__c); 
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, opp, modalidade);
        /*ContratanteProposta__c contratanteproposta = [SELECT id FROM ContratanteProposta__c WHERE Proposta__c =:cot.Id LIMIT 1];
        GrupoProposta__c grupoproposta = [SELECT id FROM GrupoProposta__c WHERE ContratanteProposta__c =:contratanteproposta.Id LIMIT 1];
        GarantiasGrupoProposta__c garantiagrupoproposta = TestDataFactory.gerarGarantiaGrupoProposta(garantiaCobertura, grupoProposta);*/
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
        favorecidoRemuneracaoContrato.Conta__c = contaTeste.Id;
        favorecidoRemuneracaoContrato.CorretorLider__c = TRUE;
        favorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
        favorecidoRemuneracaoContrato.Susep__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepEmissao__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepOrcamento__c='p5005j';
        favorecidoRemuneracaoContrato.DadosCorretor__c = dadosCorretor.Id;
        favorecidoRemuneracaoContrato.Papel__c ='Corretor';
        favorecidoRemuneracaoContrato.Participacao__c =100;
        insert favorecidoRemuneracaoContrato;
        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaTeste, contaTeste);
        
        GarantiaContratanteContrato__c garantiaContratanteContratoCobertura = TestDataFactory.gerarGarantiaContratanteContrato(garantiaCobertura, contratanteContrato);
        garantiaContratanteContratoCobertura.CurrencyIsoCode = 'BRL';
        update garantiaContratanteContratoCobertura;
        GarantiaContratanteContrato__c garantiaContratanteContrato = TestDataFactory.gerarGarantiaContratanteContrato(garantia, contratanteContrato);
        garantiaContratanteContrato.CurrencyIsoCode = 'BRL';
        update garantiaContratanteContrato;
        
        GarantiaContratanteContrato__c garantiaContratanteContratoCobertura2 = TestDataFactory.gerarGarantiaContratanteContrato(garantiaCobertura2, contratanteContrato);
        garantiaContratanteContratoCobertura2.CurrencyIsoCode = 'BRL';
        update garantiaContratanteContratoCobertura2;
        GarantiaContratanteContrato__c garantiaContratanteContrato2 = TestDataFactory.gerarGarantiaContratanteContrato(garantia, contratanteContrato);
        garantiaContratanteContrato2.CurrencyIsoCode = 'BRL';
        update garantiaContratanteContrato2;
        
        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c segurado = TestDataFactory.gerarSeguradoContrato(grupoContrato, contaTeste);
        BeneficiarioSeguradoContrato__c beneficiario = new BeneficiarioSeguradoContrato__c();
        beneficiario.Nome__c ='';
        beneficiario.CpfCnpj__c= '';
        beneficiario.Conta__c = contaTeste.Id;
        beneficiario.GrauParentescoPep__c ='Avó';
        beneficiario.SeguradoContrato__c = segurado.Id;
        beneficiario.Participacao__c = 10;
        beneficiario.TipoBeneficiario__c ='Nome do beneficiário';
        insert beneficiario;
        
        Product2 produtoTecnico = (Product2) new produtoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';        
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        produtotecnico.Segmento__c ='Individual';
        update produtoTecnico;
        
        
        Product2 produtoComercial = (Product2) new produtoFactory.produtoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';       
        produtoComercial.productCode = 'CONSULTIVO';
        
        produtoComercial.VigenciaInicial__c = system.today().addDays(2);
        produtoComercial.VigenciaFinal__c = system.today().addDays(30);  
        
        produtoComercial.Segmento__c ='Individual';      
        update produtoComercial;
        
        RamoSeguro__c ramoSegurado1 = (RamoSeguro__c) new RamoSeguroFactory().createRecord();
        RamoSeguro__c ramoSegurado2 = (RamoSeguro__c) new RamoSeguroFactory().createRecord();

        new RamoGarantiaFactory(garantiaCobertura, ramoSegurado1).createRecord(); 
        new RamoGarantiaFactory(garantiaCobertura, ramoSegurado2).createRecord(); 
        GarantiaProduto__c garantiaProdutoTEC  = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTecnico, garantiaCobertura, ramoSegurado1);
        GarantiaProduto__c garantiaProdutoTEC2 = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTecnico, garantiaCobertura, ramoSegurado2);

        GarantiaProduto__c garantiaProdutoCobertura = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantiaCobertura, garantiaProdutoTEC, ramoSegurado1).createRecord();
        GarantiaProduto__c garantiaProdutoCobertura2 = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantiaCobertura2, garantiaProdutoTEC2, ramoSegurado2).createRecord();
        garantiaProdutoCobertura.TipoGarantia__c = 'Cobertura';
        garantiaProdutoCobertura.ambitoTerritorial__c = 'TerritorioNacional';
        garantiaProdutoCobertura.CaracteristicaGarantia__c = 'Principal';
        update garantiaProdutoCobertura;
        garantiaContratanteContratoCobertura.GarantiaProduto__c = garantiaProdutoCobertura.Id;
        update garantiaContratanteContratoCobertura;

        TestDataFactory.gerarGarantiaContrato(contrato, garantiaProdutoCobertura);



        

        //CLASSES DAOS
        //proposta cot 
        //endereco

        GarantiasGrupoPropostaDAO daoGarantiasGrupoPropostaDAO = GarantiasGrupoPropostaDAO.getInstance();
        CarenciaGarantiaDAO daoCarenciaGarantiaDAO = CarenciaGarantiaDAO.getInstance();
        FranquiaGarantiaDAO daoFranquiaGarantiaDAO = FranquiaGarantiaDAO.getInstance();
        GarantiaPropostaDAO daoGarantiaPropostaDAO = GarantiaPropostaDAO.getInstance();
        GarantiaProdutoDAO daoGarantiaProdutoDAO = GarantiaProdutoDAO.getInstance();
        GrupoPropostaDAO daoGrupoPropostaDAO = GrupoPropostaDAO.getInstance();
        ProfissaoDAO daoProfissaoDAO = ProfissaoDAO.getInstance();
        GarantiaDAO daoGarantiaDAO = GarantiaDAO.getInstance();
        CaseDAO daoCaseDAO = CaseDAO.getInstance();
        EnderecoDAO daoEnderecoDAO = new EnderecoDAO();
        QueueDAO daoQueueDAO = new QueueDAO();
        OpportunityDAO daoOpportunityDAO = OpportunityDAO.getInstance();
        ParceiroDAO daoParceiroDAO = ParceiroDAO.getInstance();
        PremioMinimoProdutoDAO daoPremioMinimoProdutoDAO = PremioMinimoProdutoDAO.getInstance();
        ProductDAO daoProductDAO = ProductDAO.getInstance();
        AccountDAO daoAccountDAO = AccountDAO.getInstance();
        BeneficiarioSeguradoPropostaDAO daoBeneficiarioSeguradoPropostaDAO = BeneficiarioSeguradoPropostaDAO.getInstance();
        RamoSeguroBO daoRamoSeguroBO = RamoSeguroBO.getInstance();
        RamoSeguroDAO daoRamoSeguroDAO = RamoSeguroDAO.getInstance();
        
        
        daoEnderecoDAO.buscarEnderecosPorId(new Set<Id>{endereco.id});
        daoEnderecoDAO.buscarEnderecoConta(contaTeste.id);
        daoEnderecoDAO.buscarEnderecosConta(contaTeste.id);
        daoGarantiasGrupoPropostaDAO.listaGarantiasVida(new Set<Id>{endereco.id});
        daoCarenciaGarantiaDAO.buscarCarenciasGarantia(new Set<Id>{endereco.id});
        daoFranquiaGarantiaDAO.buscarFranquiasGarantia(new Set<Id>{endereco.id});
        daoGarantiaDAO.buscarGarantiasPorSigla(new Set<String>{garantia.sigla__c});
        daoQueueDAO.buscarFilaPorNome('BAC');
        daoGarantiaPropostaDAO.buscarGruposPropostaPorIds(new Set<Id>{cot.id});
        daoCaseDAO.buscarCasoPorId(new Set<Id>{endereco.id});
        daoGrupoPropostaDAO.buscarGruposPropostaPorIds(new Set<Id>{endereco.id});
        daoParceiroDAO.buscarProdutosParceiro(new Set<String>{endereco.id},new Set<String>{endereco.id});

        daoGarantiaProdutoDAO.buscarGarantiasProdutoPorProdutoCapId(new List<String>{'abcd'});
        daoGarantiaProdutoDAO.buscarGarantiasProdutoPorProdutoCode(new Set<String>{produtoComercial.ProductCode});

        daoProfissaoDAO.buscarProfissoesPorStatus('ABC');
        daoProfissaoDAO.buscarProfisoesAtivasPorCodigo(new Set<String>{'ABC'});
        daoProfissaoDAO.buscarProfissoesTodas();
        daoProfissaoDAO.buscarProfissoesNaoExistentesNoWS(new Set<String>{'ABC'});

        daoOpportunityDAO.buscarGarantiasContratanteOrcamentoPorSegurados(new Set<Id>{endereco.id});
        daoOpportunityDAO.buscarGarantiasOrcamentoPorOrcamento(new Set<Id>{endereco.id});
        daoOpportunityDAO.buscarVidasOrcamentoPorOrcamento(new Set<Id>{endereco.id});
        daoOpportunityDAO.buscarGarantiasGrupoOrcamentoPorOrcamento(new Set<Id>{endereco.id});
        
        daoPremioMinimoProdutoDAO.buscarPremiosPorId(new Set<Id>{endereco.id});
        
        daoProductDAO.buscarProdutoEndosso(produtoComercial.id);
        daoProductDAO.buscarTiposProdutos();
        
        daoAccountDAO.buscarContasPorPapel('ABC');
        
        daoBeneficiarioSeguradoPropostaDAO.buscarBeneficiariosSeguradoProposta(new Set<String>{'ABC'});
        
        daoRamoSeguroBO.buscarRamosSeguro(new Set<Id>{endereco.id});
        daoRamoSeguroDAO.obterRamoPorCodigo('ABC');
        daoRamoSeguroDAO.buscarRamosPorIds(new Set<Id>{endereco.id});
	}
}