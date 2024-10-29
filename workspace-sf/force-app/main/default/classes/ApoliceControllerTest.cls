@IsTest
class ApoliceControllerTest {
    
    @TestSetup
    static void setup(){
        
        TestDataFactory.gerarDadosSetup();
        //PLV-3746 - INICIO
        SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
        sCripto.Name = 'Senha';
        sCripto.Senha__c = 'TesteCrypto';
        insert sCripto;
        //PLV-3746 - FIM
        
    }
    
    @IsTest
    static void TestPass(){
        Account contaTeste = TestDataFactory.gerarConta();
        Endereco__c endereco = TestDataFactory.gerarEndereco(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        //PLV - 4250 inicio
        Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Produto Porto';
        update garantiaCobertura;
        //PLV - 4250 fim
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSegurado);
        Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome produtoTec 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '201700001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		produtoTec.TipoResponsavelPagamento__c = 'SEG';
		insert produtoTec;

        produtoTec.Status__c = 'Em criação';
        update produtoTec;

        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        Map<String,List<SObject>> mapListSObject = TestDataFactory.gerarProdutoComercialAtivo(false);
        produtoCom.Status__c ='ativo';
        update produtoCom;

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoCom);
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__C parceiro = TestDataFactory.gerarParceiro(contaTeste, formaPagamento);
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoCom);
        Opportunity opp = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        InformacaoBancaria__c InformacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaTeste);
        RemuneracaoProdutoParceiro__c RemuneracaoProdutoParceiro = TestDataFactory.gerarRemuneracaoProdutoParceiro(tipoRemuneracao, produtoParceiro, 20);
        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(contaTeste, 20.00, 'Corretor', true, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);        
        system.debug('favorecidoRemuneracao: '+favorecidoRemuneracao.RemuneracaoProdutoParceiro__c); 
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, opp, modalidade);
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
		//PLV-5053 INICO
		contrato.Tipo__c = 'Novo';
		update contrato;
		//PLV-5053 FIM 
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
        //PLV - 4250 inicio
        GarantiaContratanteContrato__c garantiaContratanteContratoCobertura = TestDataFactory.gerarGarantiaContratanteContrato(garantiaCobertura, contratanteContrato);
        GarantiaContratanteContrato__c garantiaContratanteContrato = TestDataFactory.gerarGarantiaContratanteContrato(garantia, contratanteContrato);
        //PLV - 4250 fim
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
        update produtoTecnico;
        
        
        Product2 produtoComercial = (Product2) new produtoFactory.produtoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.productCode = 'CONSULTIVO';
        // PLV-3673  -  INICIO
        produtoComercial.VigenciaInicial__c = system.today().addDays(2);
        produtoComercial.VigenciaFinal__c = system.today().addDays(30);  
        // PLV-3673  -  FIM      
        update produtoComercial;
        
        //  associaProdutoCanal(produtoComercial, 'COR');        
        
        TipoRemuneracao__c TipoRemuneracao1 = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord(); 
        system.debug('TipoRemuneracao no meu metodo:' + TipoRemuneracao);
        remuneracaoProduto__c remuneracaoProduto = (remuneracaoProduto__c) new RemuneracaoProdutoFactory(TipoRemuneracao1, produtoComercial).createRecord();
        CanalDistribuicao__c canalDistribuicao1 = (CanalDistribuicao__c) new CanalDistribuicaoFactory().createRecord();       
        RamoSeguro__c ramoSegurado1 = (RamoSeguro__c) new RamoSeguroFactory().createRecord();
        
        // PLV - 4250 Inicio
        RamoGarantia__c ramoGarantia1 = (RamoGarantia__c) new RamoGarantiaFactory(garantiaCobertura, ramoSegurado1).createRecord(); 
        GarantiaProduto__c garantiaProdutoTEC = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTecnico, garantiaCobertura, ramoSegurado1);

        GarantiaProduto__c garantiaProdutoCobertura = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantiaCobertura, garantiaProdutoTEC, ramoSegurado1).createRecord();
        garantiaProdutoCobertura.TipoGarantia__c = 'Cobertura';
        garantiaProdutoCobertura.ambitoTerritorial__c = 'TerritorioNacional';
        garantiaProdutoCobertura.CaracteristicaGarantia__c = 'Principal';
        update garantiaProdutoCobertura;
        garantiaContratanteContratoCobertura.GarantiaProduto__c = garantiaProdutoCobertura.Id;
        update garantiaContratanteContratoCobertura;
        //PLV - 4250 fim
        
        List<Contract> lContrato = new List<Contract>();
        lContrato.add(contrato);
        
        PageReference pdf = Page.ApolicePage;
        Map<String,String> mPDFParam = pdf.getParameters();
        mPDFParam.put('contratoId', contrato.Id);
        //PLV-3746
        CryptoToken c = new CryptoToken();      
        String cri = c.encrypt(contrato.Id+'|Apolice_1_1_1369_000002430_0_Test2');
        mPDFParam.put('token', cri);
        //Fim - PLV-3746
        mPDFParam.put('renderAs', 'pdf');
        Test.setCurrentPage(pdf);
        ApexPages.StandardController sc = new ApexPages.standardController(contrato);
        ApoliceController apc = new ApoliceController();
        apc.doAction();
        
        Garantia__c garantia2 = TestDataFactory.gerarGarantia();
        garantia2.Tipo__c ='Benefício';
        GarantiaContratanteContrato__c garantiaContratanteContratoAssist = TestDataFactory.gerarGarantiaContratanteContrato(garantia2, contratanteContrato);
        
        ApoliceController.wrapGarantiaContratante wrap = new ApoliceController.wrapGarantiaContratante(garantiaContratanteContrato);
        ApoliceController.wrapAssistenciasBeneficios wrapAssist = new ApoliceController.wrapAssistenciasBeneficios(garantiaContratanteContratoAssist);
        ApoliceController.wrapBeneficiarios wrapBene = new ApoliceController.wrapBeneficiarios(beneficiario);
        
        decimal a = 2000.6;
        String valor = a.format();
        
        //PLV-3884 - INICIO
        ApoliceController.trataValores(valor, 'BRL');
        ApoliceController.trataValores(valor, 'USD');
        ApoliceController.trataValores(valor, 'EUR');
        
        integer b = 2000;
        String valor2 = b.format();
        
        ApoliceController.trataValores(valor2, 'BRL');
        ApoliceController.trataValores(valor2, 'USD');
        ApoliceController.trataValores(valor2, 'EUR');
        
        String valor3 = '200,00';
        ApoliceController.trataValores(valor3, 'BRL');
        ApoliceController.trataValores(valor3, 'USD');
        ApoliceController.trataValores(valor3, 'EUR');
        
        //PLV-3884 - FIM
        
        
    }
    
}