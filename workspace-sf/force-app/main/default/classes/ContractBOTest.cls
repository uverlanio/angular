/**
* ContractBOTest
* @author Luiz Felix @ 01/02/2021
* PLV-4536
**/
//PLV-4536 inicio
@isTest
private class ContractBOTest {
    @TestSetup
    static void setup(){
        //TestDataFactory.gerarDadosSetup();
        //TestDataFactory.gerarContrato(true);

		dadosTest(); //PLV-5099 INICIO / FIM
        
		//PLV-4921 - INICIO
        List<Contract> contractList = [SELECT Id, Name, Status, Endosso__c FROM Contract LIMIT 1];
        contractList[0].Status = 'Emitido';
        contractList[0].Endosso__c = '0';
        update contractList;
        Profile p = [SELECT id, Name FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
        //PLV-4921 - FIM
        User usuario = new User();
        usuario.Username = 'TesteMilestone@Avanxo.com';
        usuario.LastName = 'Teste';
        usuario.Email = 'TesteMilestone@Avanxo.com';
        usuario.Alias = 'TesteAvx';
        usuario.CommunityNickname = 'TesteAvx';
        usuario.TimeZoneSidKey = 'America/Sao_Paulo';
        usuario.LocaleSidKey = 'pt_BR';
        usuario.EmailEncodingKey = 'ISO-8859-1';
        usuario.ProfileId = p.Id;
        usuario.LanguageLocaleKey = 'pt_BR';
        insert usuario;

    }
    //PLV-4921 - INICIO
    @IsTest
    static void testarSeguroBatch(){
        //PLV-5099 INICIO
        String payloadReturn = '{"meta":{"dataExecucao":"newDate()","servico":"servico","statusHttp":200,"mensagem":"mensagem"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
        //PLV-5099 FIM
        SeguroBatch x = new SeguroBatch();
        Test.startTest();
        Database.executeBatch(x);
        Test.stopTest();
    }
    //PLV-4921 - FIM
    @IsTest
    static void gravarUltimoModificadorTest(){
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'TesteMilestone@Avanxo.com'];
        List<Contract> contractList = [SELECT Id,Name, Usuario_temporario__c, Empresa__c, sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c, ContratoOriginal__c  FROM Contract LIMIT 1]; //PLV-5057 INICIO/FIM
        contractList[0].Usuario_temporario__c = usuario.Id;
        contractList[0].Endosso__c = '1';
        update contractList;
        Test.startTest();
        ContractBO.getInstance().gravarUltimoModificador(contractList);
        Test.stopTest();
        
    }
    //PLV-4905 - INICIO
    @isTest
    static void processarIntegracaoAntares_Success(){
        Contract contratoOriginal = [SELECT Id,Name, Usuario_temporario__c, Empresa__c, sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c FROM Contract LIMIT 1];
        
        Quote proposta = [SELECT Id FROM Quote WHERE Name = 'Teste Contrato'];

        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];
        List<Account> conta = [SELECT id FROM Account WHERE LastName = 'Teste'];
        
        Contract contrato = new Contract(
            Name = '111',
            Oportunidade__c = oportunidade.Id,
            Proposta__c = proposta.Id,
            Tipo__c = 'Novo',
            AccountId = conta[0].Id
        );
        insert contrato;
        
        contrato.Endosso__c = '1';
        contrato.Tipo__c = 'Endosso';
        contrato.Status = 'Emitido';
        contrato.SiglaTipoEndosso__c = 'EXC;CAD';
        contrato.ContratoOriginal__c = contratoOriginal.Id;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"servico":"/parcelascontrato/processar-integracao-antares","status":"PROCESSADO","codigoprocessamento":0,"descricao":"Atualização de parcelas para integração Antares feita com sucesso."}', 200, 'OK'));
        Test.startTest();
        update contrato;
        Test.stopTest();
        
    }
    //PLV-4905 - FIM
    
    //PLV-4905 - INICIO
    public static void dadosTest(){
        Account conta = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
            LastName = 'Teste',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '00478394659',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = (Date.today()-7300),
            EstadoCivil__c = 'Solteiro (a)'
        );
        insert conta;
        
        
        Opportunity oportunidade = new Opportunity(
            Name = 'Teste Contrato',
            StageName = 'Em criação',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
            AccountId = conta.Id,
            CloseDate = Date.today()
        );
        insert oportunidade;

		//PLV-5099 INICIO
		Account contaTeste = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c 	= 'ativo';
        produtoCom.Segmento__c	= 'Viagem';
		update produtoCom;

        ParametroVigencia__c parametroCom = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaComercial(produtoCom).createRecord(); //PLV-5768 INICIO/FIM
        
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);

        //TKCL-246 FIX05 INICIO
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        produtoTecnico.ProductCode = '49';
        produtoTecnico.Segmento__c = 'Individual';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.ProductCode = 'APTLMKT';
        produtoComercial.Segmento__c = 'Individual';
        produtoComercial.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercial;
        //TKCL-246 FIX05 FIM
        
        ParametroVigencia__c parametroComViagem = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaComercial(produtoComercial).createRecord(); //PLV-5768 INICIO/FIM

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        cot.NumeroProposta__c = '00001910';
        cot.Origem__c = '18'; //PLV-5773 INICIO-FIM
        cot.PremioTotal__c = 0; //PLV-5766 INICIO/FIM
        update cot;

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        
		contrato.Name 					= 'Erro';
		contrato.Usuario_temporario__c 	= '005L0000005jUuVIAU';
		contrato.Empresa__c 			= '1';
		contrato.Sucursal__c 			= '1';
		contrato.CodigoRamo__c 			= '1391';
		contrato.NumeroApolice__c 		= '000003417';
		contrato.Endosso__c 			= '0';
        contrato.Produto__c             = produtoCom.Id; //PLV-5768 INICIO/FIM
        //PLV-5773 INICIO
        contrato.Proposta__c            = cot.Id; 
        contrato.RamoSeguro__c          = ramoSeguro.Id; 
        contrato.Tipo__c                = 'Novo'; 
        contrato.VigenciaFinal__c       = System.today();         
        contrato.Origem__c              = '18'; 
        contrato.NumeroProposta__c      = cot.NumeroProposta__c; 
        //PLV-5773 FIM
        update contrato;
		//PLV-5099 FIM

        //PLV-5773 INICIO
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento(ramoSeguro, modalidade, 'Cartão', '70');

        Parceiro__c parceiro = TestDataFactory.gerarParceiro(conta, formaPagamento);
        
        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaTeste, conta);
        contratanteContrato.ResponsavelPagamento__c = conta.Id;
        contratanteContrato.QuantidadeParcelas__c = 12;
        contratanteContrato.TipoResponsavelPagamento__c = 'PAR';
        contratanteContrato.Iof__c = 14;
        contratanteContrato.PremioTotal__c = 1000;
        contratanteContrato.PremioComercial__c = 500;
        contratanteContrato.VencimentoDemaisParcelas__c = 'A cada 30 dias';
        contratanteContrato.VencimentoPrimeiraParcela__c = System.today();
        update contratanteContrato;


        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
    
        //SeguradoContrato__c SeguradoContrato = gerarSeguradoContrato(grupoContrato, conta);
        SeguradoContrato__c SeguradoContrato = new SeguradoContrato__c(
                GrupoContrato__c = grupoContrato.Id,
                Conta__c = conta.Id,
                TipoResponsavelPagamento__c = 'PAR',
                ResponsavelPagamento__c = conta.Id
        );
        insert SeguradoContrato;

        //PLV-5773 FIM

        Quote propostaQuote = new Quote(
            Name= 'Teste Contrato',
            OpportunityId=oportunidade.Id,
            DataProtocolo__c = Date.today(),
            DataCalculo__c =  Date.today(),
            Empresa__c = conta.Id,
            ExpirationDate = Date.today(),
            Produto__c = produtoComercial.id //TKCL-246 FIX05 INICIO/FIM
		);
        insert propostaQuote;
        
        ContratanteProposta__c contratanteProposta = new ContratanteProposta__c(
            conta__c = conta.Id,
            Proposta__c = propostaQuote.Id,
            Tipo__c = 'Principal'
        );
        insert contratanteProposta;
        
        GrupoProposta__c grupoProposta = new GrupoProposta__c(
            Name = 'Teste',
            QuantidadeVidas__c = 1,
            ContratanteProposta__c = contratanteProposta.Id
        );
        insert grupoProposta;
        
        SeguradoProposta__c seguradoProposta = new SeguradoProposta__c(
            Conta__c = conta.Id,
            GrupoProposta__c = grupoProposta.Id
        );
        insert seguradoProposta;
        
        BeneficiarioSeguradoProposta__c beneficiario = new BeneficiarioSeguradoProposta__c(
            SeguradoProposta__c = seguradoProposta.Id,
            CpfCnpj__c = '00478394659',
            Nome__c = 'Teste Contrato',
            TipoBeneficiario__c = 'Nome do beneficiário',
            GrauParentesco__c = 'Pai',
            Participacao__c = 100.00,
            Pep__c = 'Nao',
			Sexo__c = 'Masculino',
			Data_de_nascimento__c = System.today(),
			PercentualIndenizacao__c = 100.00
        );
        insert beneficiario;
        
        BeneficiarioSeguradoProposta__c beneficiario2 = new BeneficiarioSeguradoProposta__c(
            SeguradoProposta__c = seguradoProposta.Id,
            CpfCnpj__c = '99235310075',
            Nome__c = 'Teste Contrato',
            TipoBeneficiario__c = 'Nome do beneficiário',
            GrauParentesco__c = 'Pai',
            Participacao__c = 100.00,
            Pep__c = 'Nao',
			Sexo__c = 'Masculino',
			Data_de_nascimento__c = System.today(),
			PercentualIndenizacao__c = 100.00
        );
        insert beneficiario2;

        //FNPVVEP-96 INICIO
        GarantiaProduto__c garantiaProduto = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTecnico, garantia1, ramoSegurado);

        insert new GarantiaContratanteContrato__c(ContratanteContrato__c = contratanteContrato.Id, GarantiaProduto__c = garantiaProduto.Id);
        //FNPVVEP-96 FIM
        
    }
    //PLV-4905 - FIM
    
    //POR062-72 - INICIO
    @isTest static void gerarParametrosTest(){

        List<ServiceTO.SeguroContratoTO> seguroContrato = new List<ServiceTO.SeguroContratoTO>();

        Set<Id> setContractId = new Set<Id>();
        List<Contract> listContrato = new List<Contract>();        
        List<BusinessHours> lstHorariosComerciais = new List<BusinessHours>();
        List<Product2> produto = [SELECT id FROM Product2 WHERE Segmento__c = 'Viagem' LIMIT 1];
        Contract contrato = new Contract();
        contrato.Tipo__c = 'Endosso';
        contrato.Produto__c = produto[0].id;
        listContrato.add(contrato);

        ContractBO contractBO = ContractBO.getInstance();
        seguroContrato = contractBO.gerarDadosSeguro(setContractId, listContrato, null, lstHorariosComerciais);
    }
   
    @isTest static void criarEndossoSyncTest(){
        
        List<Contract> listContract = new List<Contract>();
        Contract contrato = new Contract();

        Test.startTest();
        
        Account conta = new Account();
        conta.Name = 'Teste';
        conta.Cnpj__c = '00.435.565/0001-00';
        
        insert conta;

        contrato.AccountId = conta.Id;        
        contrato.Tipo__c = 'Cancelamento';

        insert contrato;

        listContract.add(contrato);         
        
        ContractBO.getInstance().criarEndosso(listContract);

        Test.stopTest();
    }
    //POR062-72 - FIM

    // POR062-1 - INICIO
    @isTest static void testarMapearContratosPorIdCaso(){

        Test.startTest();

        Contract contrato = new Contract(
            Id = '800L0000002OtelIAC'
        );

        Case caso = new Case(
            Id = '500L000000GS9L5IAL',
            Contrato__c = contrato.Id
        );

        List<Case> listaCasos = new List<Case>();
        listaCasos.add(caso);
    
        ContractBO.getInstance().mapearContratosPorIdCaso(listaCasos);
        
        Test.stopTest();    
    }
    // POR062-1 - FIM

    //PLV-5773 INICIO
    @isTest static void gerarParcelaContratoToTest(){
        Integer numeroParcela = 2;
        Date vencimentoParcelaAnterior = System.today();
        List<ParcelaContratoTO> parcelasContrato = new List<ParcelaContratoTO>();
        Double periodoMaximoInadimplenciaProd = 2;

        ContratanteContrato__c contratanteContrato = [SELECT Id, ResponsavelPagamento__c, QuantidadeParcelas__c, TipoResponsavelPagamento__c, IOF__c, PremioTotal__c, PremioComercial__c, VencimentoDemaisParcelas__c, VencimentoPrimeiraParcela__c FROM ContratanteContrato__c LIMIT 1 ];
        Parceiro__c parceiroTeste = [SELECT Id FROM Parceiro__c LIMIT 1 ];
        Contract contrato = [SELECT Id, NumeroApolice__c, Empresa__c, Sucursal__c, Endosso__c, Tipo__c, Segmento__c, VigenciaFinal__c, Produto__r.ProductCode, Proposta__r.Name, Proposta__r.NumeroProposta__c, Proposta__r.Origem__c, RamoSeguro__r.Codigo__c FROM Contract LIMIT 1 ];
        SeguradoContrato__c seguradoContrato = [SELECT Id, ResponsavelPagamento__c FROM SeguradoContrato__c LIMIT 1 ];
        Product2 produto = [SELECT Id, CodigoPrecificaProduto__c FROM Product2 Where CodigoPrecificaProduto__c = 'APTLMKT' LIMIT 1];

        String prod = contrato.Produto__r.ProductCode;

        Set<id> setResponsavelPagamentoID = new Set<id>();
        setResponsavelPagamentoID.add(seguradoContrato.ResponsavelPagamento__c);
        setResponsavelPagamentoID.add(contratanteContrato.ResponsavelPagamento__c);
        Map<Id, Parceiro__c> mapParceiroPorContaResponsavelPagamento = new Map<Id, Parceiro__c>();

        for (Parceiro__c parceiro: ContractDAO.getInstance().buscarParceiros(setResponsavelPagamentoId)) {
            mapParceiroPorContaResponsavelPagamento.put(parceiro.Conta__c, parceiro);
        }

        Map<Id, Boolean> mapAntecipaComissaoContrato = new Map<Id, Boolean>();
        
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('contratanteContrato', (Object) contratanteContrato);
        mapParams.put('seguradoContrato', (Object) seguradoContrato);
        mapParams.put('contrato', (Object) contrato);
        mapParams.put('ehSergurado', (Object) false);
        mapParams.put('qtdParcelas', (Object) Integer.valueOf(contratanteContrato.QuantidadeParcelas__c));
        mapParams.put('produto', (Object) prod);
        mapParams.put('mapAntecipaComissaoContrato', (Object) mapAntecipaComissaoContrato);
        mapParams.put('mapParceiroPorContaResponsavelPagamento', (Object) mapParceiroPorContaResponsavelPagamento);
        ContractBO bo = ContractBO.getInstance();

        Test.startTest();
        bo.gerarParcelaContratoTO(mapParams, numeroParcela, vencimentoParcelaAnterior, parcelasContrato, periodoMaximoInadimplenciaProd);
        Test.stopTest();
    }
    //PLV-5773 FIM

    //PLV-5766 INICIO
    @isTest static void gerarParametrosTestCan(){
        List<ServiceTO.SeguroContratoTO> seguroContrato = new List<ServiceTO.SeguroContratoTO>();
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Produto Porto';
        update garantiaCobertura;
        Set<Id> setContractId = new Set<Id>();
        Set<Id> setContrato = new Set<Id>();        
        List<BusinessHours> lstHorariosComerciais = new List<BusinessHours>();
        List<Quote> proposta = [SELECT id, PremioTotal__c, Contract.sucursal__c FROM Quote LIMIT 1];
        SeguradoContrato__c seguradoContrato = [SELECT Id, ResponsavelPagamento__c FROM SeguradoContrato__c LIMIT 1 ];
        System.debug('Danilo PremioTotal__c teste>>>' + proposta[0].PremioTotal__c);

        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        RamoAtividade__c ramoAtividade = (RamoAtividade__c) new RamoAtividadeFactory().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        ParametroVigencia__c parametroCom = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaComercial(produtoComercial).createRecord(); //PLV-5768 INICIO/FIM

        Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();

        Account contaParceiro = (Account) new AccountFactory.PessoaJuridica(ramoAtividade).createRecord();
        contaParceiro.Name = 'ASSISTCARD';
        contaParceiro.IdExterno__c = '57756863000100';
        update contaParceiro;

        Parceiro__c parceiroPrestadora = (Parceiro__c) new ParceiroFactory(contaParceiro, formaPagamento).createRecord();
        parceiroPrestadora.status__c = 'Ativo';
        parceiroPrestadora.Sucursal__c = '1';
        parceiroPrestadora.ramo__c = '1396';
        parceiroPrestadora.empresa__c = '1';
        update parceiroPrestadora;

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaFisica, produtoComercial, parceiroPrestadora).createRecord();
        contrato.Tipo__c = 'Cancelamento';
        contrato.Proposta__c = proposta[0].id;
        contrato.Produto__c = produtoComercial.id;
        contrato.Parceiro__c = 'Teste';
        contrato.VigenciaFinal__c = Date.newInstance(2025,12,12);
        update contrato;
        setContrato.add(contrato.id);

        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaFisica).createRecord();
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('AGENCIAMENTO', 15, 1000, 'Integral');
        
        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        remuneracaoContrato.Percentual__c = 1;
        update remuneracaoContrato;

        FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
        favorecidoRemuneracaoContrato.Conta__c = contaFisica.Id;
        favorecidoRemuneracaoContrato.CorretorLider__c = true;
        favorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
        favorecidoRemuneracaoContrato.Susep__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepEmissao__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepOrcamento__c='p5005j';
        favorecidoRemuneracaoContrato.DadosCorretor__c = dadosCorretor.Id;
        favorecidoRemuneracaoContrato.Papel__c ='Corretor';
        favorecidoRemuneracaoContrato.Participacao__c =100;
        insert favorecidoRemuneracaoContrato;

        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaFisica, contaFisica);
        contratanteContrato.TipoResponsavelPagamento__c = 'SEG';
        contratanteContrato.VencimentoDemaisParcelas__c = '28';
        update contratanteContrato;

        GarantiaContratanteContrato__c garantiaContratanteContratoCobertura = TestDataFactory.gerarGarantiaContratanteContrato(garantiaCobertura, contratanteContrato);
        GarantiaContratanteContrato__c garantiaContratanteContrato = TestDataFactory.gerarGarantiaContratanteContrato(garantia, contratanteContrato);

        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c segurado = TestDataFactory.gerarSeguradoContrato(grupoContrato, contaFisica);
        BeneficiarioSeguradoContrato__c beneficiario = new BeneficiarioSeguradoContrato__c();
        beneficiario.Nome__c ='';
        beneficiario.CpfCnpj__c= '';
        beneficiario.Conta__c = contaFisica.Id;
        beneficiario.GrauParentescoPep__c ='Avó';
        beneficiario.SeguradoContrato__c = segurado.Id;
        beneficiario.Participacao__c = 10;
        beneficiario.TipoBeneficiario__c ='Nome do beneficiário';
        insert beneficiario;

        ContractBO contractBOInstance = ContractBO.getInstance();
        contractBO.restit = 5;
        List<Contract> listContrato = ContractDAO.getInstance().buscarContratos(setContrato);

        Map<Id, Boolean> mapAntecipaComissaoContrato = new Map<Id, Boolean>();

        ContractBO bo = ContractBO.getInstance();

        Test.startTest();
        seguroContrato = contractBOInstance.gerarDadosSeguro(setContractId, listContrato, mapAntecipaComissaoContrato, lstHorariosComerciais);
        Test.stopTest();
    }
    //PLV-5766 FIM
    @isTest
    public static void processarRecompraTitulosTest(){
        list<GarantiaContrato__c> lstGarantia = new list<GarantiaContrato__c>();
        Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaFisica);
        RamoSeguro__c ramoSegurado = new RamoSeguro__c(
            Name = 'Segurado',
            CodigoEmpresa__c = '214',
            Codigo__c = '2',
            Empresa__c = contaFisica.Id,
            Status__c = 'Ativo',
            CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
    );
    insert ramoSegurado;
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();

        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTec).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.ProductCode = 'APTLMKT';
        produtoComercial.Segmento__c = 'Individual';
        produtoComercial.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercial;
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        Quote proposta = [SELECT Id FROM Quote WHERE Name = 'Teste Contrato'];

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoComercial, ramoSegurado, contaFisica, dadosCorretor, proposta);

        GarantiaProduto__c garantiaProduto = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);

        GarantiaContrato__c garantiaContrato = TestDataFactory.gerarGarantiaContrato(contrato, garantiaProduto);
        lstGarantia.add(garantiaContrato);

        ContractBO bo = ContractBO.getInstance();

        Test.startTest();
        bo.processarRecompraTitulos(lstGarantia);
        Test.stopTest();
    }
    //FCVEP-29 - INICIO
    @IsTest
    static void testarValidDtIniVig(){
        
        Test.startTest();

        Contract ctr = [SELECT Id, StartDate, VigenciaFinal__c, DataEmissao__c FROM Contract LIMIT 1];

        ctr.StartDate = System.today();
        ctr.VigenciaFinal__c = System.today().addDays(1);
        
        update ctr;

        ContratanteContrato__c cttCtr = new ContratanteContrato__c(
            Contrato__c = ctr.Id
        );

        insert cttCtr;

        Date dtCancVig = ContractBO.validarDataInicialVigencia(ctr.Id, System.today());
        System.assertEquals(dtCancVig, System.today(), 'Data de cancelamento dentro da vigência.');
                
        Test.stopTest();        
    }

    //FNPVVEP-108 INICIO
    @IsTest
    static void testEmissaoBoletoVida(){
        
        Test.startTest();

        List<Contract> ctr = [SELECT Id, StartDate,NumeroApolice__c, Sucursal__c, CodigoRamo__c, Endosso__c, Senha__c, Account.PersonEmail, Account.Name, Account.cpf__c, DistributionPublicUrl__c, Proposta__c, Status, Tipo__c FROM Contract LIMIT 1];
        FormaPagamento__c formaPagamento = [SELECT Id, Codigo__c, Name FROM FormaPagamento__c LIMIT 1];
        formaPagamento.codigo__c = '41';
        update formaPagamento;
        ContratanteContrato__c cttCtr = new ContratanteContrato__c(
            Contrato__c = ctr[0].Id,
            FormaPagamento__c = formaPagamento.Id
        );
        insert cttCtr;
        ContractBO.EmissaoBoletoVida(ctr);
                
        Test.stopTest();        
    }
    //FNPVVEP-108 FIM

    @IsTest
    static void testarValidDtIniForaVig(){

        ParcelamentoContratoTO.DataTO parcelaInadimplente = new ParcelamentoContratoTO.DataTO();
        parcelaInadimplente.idfatura = 1;
        parcelaInadimplente.status = 'INADIMPLENTE';
        parcelaInadimplente.datavencimento = String.valueOf(System.today().addDays(1));
        
        Test.startTest();

        Contract ctr = [SELECT Id, StartDate, VigenciaFinal__c, DataEmissao__c FROM Contract LIMIT 1];

        ctr.StartDate = System.today().addYears(-1);
        ctr.VigenciaFinal__c = System.today().addYears(-1);
        ctr.DataEmissao__c = System.today().addDays(1);
        
        update ctr;

        ContratanteContrato__c cttCtr = new ContratanteContrato__c(
            Contrato__c = ctr.Id
        );

        insert cttCtr;

        Date dtVigIniParcInad = ContractBO.validarDataInicialVigencia(ctr.Id, System.today().addDays(1));
        System.assertEquals(dtVigIniParcInad, Date.valueOf(parcelaInadimplente.datavencimento), 'Data de vencimento da parcela com status inadimplente');
                
        Test.stopTest();        
    }

    @IsTest
    static void testarValidDtIniVigExcp(){
        
        Test.startTest();

        Contract ctr = [SELECT Id, StartDate, VigenciaFinal__c FROM Contract LIMIT 1];

        ctr.StartDate = System.today().addYears(-1);
        ctr.VigenciaFinal__c = System.today().addYears(-1);
        
        update ctr;

        ContratanteContrato__c cttCtr = new ContratanteContrato__c(
            Contrato__c = ctr.Id
        );

        insert cttCtr;

        public_parcelacontrato__x pCtr = new public_parcelacontrato__x(
            idexterno__c = ctr.Id + '_' + cttCtr.Id,
            datavencimento__c = System.today().addDays(1),
            status__c = 'INADIMPLENTE'
        );

        Date dtVigIniParcInad = ContractBO.validarDataInicialVigencia(null, System.today());
        System.assertEquals(dtVigIniParcInad, pCtr.datavencimento__c, 'Data de vencimento da parcela com status inadimplente');
                
        Test.stopTest();        
    }

    @IsTest
    static void testRetonarDataParcInadim(){

        Date dataCancelamento = System.today();
        
        Test.startTest();
        
        ParcelamentoContratoTO parcCtrTO = new ParcelamentoContratoTO();
        parcCtrTO.data = new List<ParcelamentoContratoTO.DataTO>();
        ParcelamentoContratoTO.DataTO parcelaPendente = new ParcelamentoContratoTO.DataTO();
        parcelaPendente.status = 'PENDENTE';
        parcelaPendente.datavencimento = String.valueOf(System.today());
        
        ParcelamentoContratoTO.DataTO parcelaInadimplente = new ParcelamentoContratoTO.DataTO();
        parcelaInadimplente.status = 'INADIMPLENTE';
        parcelaInadimplente.datavencimento = String.valueOf(System.today().addDays(1));
        
        parcCtrTO.data.add(parcelaPendente);
        parcCtrTO.data.add(parcelaInadimplente);

        Date dataParcInad = ContractBO.retonarDataParcInadim(parcCtrTO);

        Test.stopTest();
        
        System.assertNotEquals(dataCancelamento, dataParcInad, 'Data da parcela inadimplente.');
    }
    //FCVEP-29 - FIM
    //FNPVVEP-96 INICIO
    @isTest
    static void contractBOTOTest() {
        
        ContractBO.infoConsultaVoucher infoCV = new ContractBO.infoConsultaVoucher();
        infoCV.cpf = '1';
        infoCV.voucher = '1';
        infoCV.produto = '1';
        infoCV.datautilizacao = '1';

        ContractBO.dadoConsultaVoucher dadosCV = new ContractBO.dadoConsultaVoucher();
        dadosCV.totalutilizacao = 1;
        dadosCV.podeutilizar = false;
        dadosCV.voucher = new List<ContractBO.infoConsultaVoucher>();

        ContractBO.ResponseHerokuConsultarVoucher responseHCV = new ContractBO.ResponseHerokuConsultarVoucher();
        responseHCV.servico = '18-12345';
        responseHCV.status = 'B';
        responseHCV.codigoprocessamento = 1;
        responseHCV.dataexecucao = '1';
        responseHCV.descricao = 'N';
        responseHCV.dados = new List<ContractBO.dadoConsultaVoucher>(); 

        ContractBO.ResponseHerokuGravarVoucher responseHGV = new ContractBO.ResponseHerokuGravarVoucher();
        responseHGV.servico = '18-12345';
        responseHGV.status = 'B';
        responseHGV.codigoprocessamento = 1;
        responseHGV.dataexecucao = '1';
        responseHGV.descricao = 'N';
        responseHGV.dados = new List<ContractBO.infoGravaVoucher>(); 
        
        ContractBO.infoGravaVoucher infoGV = new ContractBO.infoGravaVoucher();
        infoGV.cpf = '1';
        infoGV.voucher = '1';
        infoGV.produto = '1';
        infoGV.datautilizacao = '1'; 
 
        ContractBO.beneficiarioSeguroTO beneficiarioSTO = new ContractBO.beneficiarioSeguroTO();
        beneficiarioSTO.percentualDistribuicaoCapital = 'TESTE';

        ContractBO.listaBeneficiariosSeguroTO listaBSTO = new ContractBO.listaBeneficiariosSeguroTO();
        listaBSTO.beneficiarioSeguro = beneficiarioSTO;

        ContractBO.listaParcelaSeguroVidaTOList listaPSVTL = new ContractBO.listaParcelaSeguroVidaTOList();
        listaPSVTL.parcelaSeguroVida = new List<ContractBO.parcelaSeguroVidaTO>();

        ContractBO.parcelaSeguroVidaTO parcelaSeguroVT = new ContractBO.parcelaSeguroVidaTO();
        parcelaSeguroVT.numeroParcela = 'teste';
        parcelaSeguroVT.valorParcela = 'teste';

        ContractBO.listaParcelaSeguroVidaTOObject listaParcelaSVTObject = new ContractBO.listaParcelaSeguroVidaTOObject();
        listaParcelaSVTObject.parcelaSeguroVida = parcelaSeguroVT;

        ContractBO.garantiaContratada garantiaContratada = new ContractBO.garantiaContratada();
        garantiaContratada.nomeGarantia = 'TESTE';
        garantiaContratada.valorCapital = 'TESTE';

        ContractBO.listaGarantiasContratadasTO listaGarantiaContratada = new ContractBO.listaGarantiasContratadasTO();
        listaGarantiaContratada.garantiaContratada = new List<ContractBO.garantiaContratada>();

        ContractBO.seguroVidaTOList seguroVTL = new ContractBO.seguroVidaTOList();
        seguroVTL.codigoFormaPagamento = 'teste';                              
        seguroVTL.ramo = 'teste';                                                    
        seguroVTL.listaParcelaSeguroVida = listaPSVTL;          
        seguroVTL.linkApolice = 'teste';                                             
        seguroVTL.dataTransmissao = 'teste';                                          
        seguroVTL.nomeComercialProduto = 'teste';                                    
        seguroVTL.nomeSegurado = 'teste';                                            
        seguroVTL.inicioVigencia = 'teste';                                         
        seguroVTL.apolice = 'teste';                                                  
        seguroVTL.sucursal = 'teste';                                                 
        seguroVTL.finalVigencia = 'teste';                                            
        seguroVTL.listaBeneficiariosSeguro = listaBSTO;         
        seguroVTL.cpf = 'teste';                                                              
        seguroVTL.listaGarantiasContratadas = listaGarantiaContratada;       
        seguroVTL.descricaoFormaPagamento = 'teste';    
        
        ContractBO.seguroVidaTOObject seguroVTObject = new ContractBO.seguroVidaTOObject();
        seguroVTObject.codigoFormaPagamento = 'teste';                              
        seguroVTObject.ramo = 'teste';                                                    
        seguroVTObject.listaParcelaSeguroVida = listaParcelaSVTObject;          
        seguroVTObject.linkApolice = 'teste';                                             
        seguroVTObject.dataTransmissao = 'teste';                                          
        seguroVTObject.nomeComercialProduto = 'teste';                                    
        seguroVTObject.nomeSegurado = 'teste';                                            
        seguroVTObject.inicioVigencia = 'teste';                                         
        seguroVTObject.apolice = 'teste';                                                  
        seguroVTObject.sucursal = 'teste';                                                 
        seguroVTObject.finalVigencia = 'teste';                                            
        seguroVTObject.listaBeneficiariosSeguro = listaBSTO;         
        seguroVTObject.cpf = 'teste';                                                              
        seguroVTObject.listaGarantiasContratadas = listaGarantiaContratada;       
        seguroVTObject.descricaoFormaPagamento = 'teste';

        ContractBO.listaSegurosTOListMulti listaSTLM = new ContractBO.listaSegurosTOListMulti();
        listaSTLM.seguroVida = new List<ContractBO.seguroVidaTOList>();

        ContractBO.listaSegurosTOObjectMulti listaSTOM = new ContractBO.listaSegurosTOObjectMulti();
        listaSTOM.seguroVida = new List<ContractBO.seguroVidaTOObject>();

        ContractBO.listaSegurosTOList listaSTL = new ContractBO.listaSegurosTOList();
        listaSTL.seguroVida = seguroVTL;

        ContractBO.listaSegurosTOObject listaSTO = new ContractBO.listaSegurosTOObject();
        listaSTO.seguroVida = seguroVTObject;


        ContractBO.RetornoCIVConsultaLTMMultiSegurosList retornoCivCLMSlist = new ContractBO.RetornoCIVConsultaLTMMultiSegurosList();
        retornoCivCLMSlist.seguroVidaOnAtivo = '1';
        retornoCivCLMSlist.listaSeguros = listaSTLM; 
        retornoCivCLMSlist.mensagemRetorno = '1';
        retornoCivCLMSlist.codigoRetorno = '1'; 

        ContractBO.RetornoCIVConsultaLTMMultiSegurosObject retornoCivCLMSObject = new ContractBO.RetornoCIVConsultaLTMMultiSegurosObject();
        retornoCivCLMSObject.seguroVidaOnAtivo = '1';
        retornoCivCLMSObject.listaSeguros = listaSTOM; 
        retornoCivCLMSObject.mensagemRetorno = '1';
        retornoCivCLMSObject.codigoRetorno = '1'; 

        ContractBO.RetornoCIVConsultaLTMList retornoCivCLSlist = new ContractBO.RetornoCIVConsultaLTMList();
        retornoCivCLSlist.seguroVidaOnAtivo = '1';
        retornoCivCLSlist.listaSeguros = listaSTL; 
        retornoCivCLSlist.mensagemRetorno = '1';
        retornoCivCLSlist.codigoRetorno = '1'; 

        ContractBO.RetornoCIVConsultaLTMObject retornoCivCLTMObject = new ContractBO.RetornoCIVConsultaLTMObject();
        retornoCivCLTMObject.seguroVidaOnAtivo = '1';
        retornoCivCLTMObject.listaSeguros = listaSTO; 
        retornoCivCLTMObject.mensagemRetorno = '1';
        retornoCivCLTMObject.codigoRetorno = '1'; 

        ContractBO.DadosCPF dadosCPF = new ContractBO.DadosCPF();
        dadosCPF.cpf = '1';

        ContractBO.DadosCPFHeroku dadosCPFHeroku = new ContractBO.DadosCPFHeroku();
        dadosCPFHeroku.numeroCpf = '1';

        ContractBO.consultivoPortoPlus consultivoPortoPlus = new ContractBO.consultivoPortoPlus();
        consultivoPortoPlus.codigoOfertaConsultiva = '1';  
        consultivoPortoPlus.canalDistribuicao = '1';        
        consultivoPortoPlus.identificadorRepresentante = '1';
        consultivoPortoPlus.meioComercializacao = '1';      
        consultivoPortoPlus.entradaNegocio = '1';           
        consultivoPortoPlus.voltar = false;                  
        consultivoPortoPlus.nProposta = '1';

        ContractBO.paramsPortoPlus paramsPortoPlus = new ContractBO.paramsPortoPlus();
        paramsPortoPlus.acao = '1';
        paramsPortoPlus.IDPortoVidaON = '1';
        paramsPortoPlus.consultivo = consultivoPortoPlus;


        ContractBO.consultivo consultivo = new ContractBO.consultivo();
        consultivo.codigoOfertaConsultiva = '1';  
        consultivo.canalDistribuicao = '1';        
        consultivo.identificadorRepresentante = '1';
        consultivo.meioComercializacao = '1';      
        consultivo.entradaNegocio = '1';           
        consultivo.voltar = false;

        ContractBO.entradaConsultivo entradaConsultivo = new ContractBO.entradaConsultivo();
        entradaConsultivo.acao = '1';
        entradaConsultivo.consultivo = consultivo;

        ContractBO.ResponseHerokuAntares responseHerokuAntares = new ContractBO.ResponseHerokuAntares();
        responseHerokuAntares.servico = '1';
        responseHerokuAntares.descricao = '1';
        responseHerokuAntares.status = '1';
        responseHerokuAntares.codigoprocessamento = 1;

    }

    @IsTest
    static void validarDataCancelamentoTest(){
        
        Test.startTest();
        Contract ctr = [SELECT Id, StartDate, VigenciaFinal__c FROM Contract LIMIT 1];
        ctr.StartDate = System.today().addYears(-1);
        ctr.VigenciaFinal__c = System.today().addYears(-1);
        update ctr;

        Date dtVigIniParcInad = ContractBO.validarDataCancelamento(ctr.id, ctr.StartDate);
                
        Test.stopTest();        
    }

    @IsTest
    static void criarControlesIntegracao1Test(){
        
        Test.startTest();
        List<Contract> ctr = [SELECT Id, SiglaTipoEndosso__c, Massificados__c, Tipo__c FROM Contract LIMIT 1];
        ctr[0].SiglaTipoEndosso__c = 'Teste';
        ctr[0].Massificados__c = false;
        ctr[0].Tipo__c = 'Endosso';
        update ctr;

        ContractBO.getInstance().criarControlesIntegracao(ctr);
                
        Test.stopTest();        
    }

    @IsTest
    static void criarControlesIntegracao2Test(){
        
        Test.startTest();
        List<Contract> ctr = [SELECT Id, SiglaTipoEndosso__c, Massificados__c, Tipo__c, AccountId FROM Contract LIMIT 1];
        ctr[0].SiglaTipoEndosso__c = 'BEN';
        ctr[0].Massificados__c = false;
        ctr[0].Tipo__c = 'Endosso';
        update ctr;

        ContractBO.getInstance().criarControlesIntegracao(ctr);
                
        Test.stopTest();        
    }

    @IsTest
    static void criarControlesIntegracaoCancelamentoTest(){
        
        Test.startTest();
        List<Contract> ctr = [SELECT Id, SiglaTipoEndosso__c, Massificados__c, Tipo__c FROM Contract LIMIT 1];
        ctr[0].SiglaTipoEndosso__c = 'BEN';
        ctr[0].Massificados__c = false;
        ctr[0].Tipo__c = 'Cancelamento';
        update ctr;

        ContractBO.getInstance().criarControlesIntegracao(ctr);
                
        Test.stopTest();        
    }

    @isTest 
    static void criarApoliceSyncTest(){
        
        List<Contract> listContract = new List<Contract>();

        Test.startTest();
        
        Contract ctr = [SELECT Id, CodigoRamo__c, Tipo__c FROM Contract LIMIT 1];
        ctr.Tipo__c = 'Novo';
        ctr.CodigoRamo__c = '1378';
        update ctr;

        listContract.add(ctr);         
        
        ContractBO.getInstance().criarApolice(listContract);

        Test.stopTest();
    }

    @isTest 
    static void verificarContratosMassificadosTest(){

        Test.startTest();
        ContractBO.getInstance().verificarContratosMassificados();
        Test.stopTest();
    }

    @isTest 
    static void cancelarContratoSelecionadoCanceladoTest(){
        
        Test.startTest();
        
        String tipoEndosso = 'CAD';
        List<Contract> ctr = [SELECT Id, Proposta__r.Contract.NumeroApolice__c, Proposta__r.Contract.Endosso__c, Proposta__r.Contract.Sucursal__c, Proposta__r.Contract.RamoSeguro__r.Codigo__c, Proposta__r.Contract.Empresa__c, Status FROM Contract LIMIT 1];
        ctr[0].Status = 'Cancelado';
        update ctr;

        ContractBO.getInstance().cancelarContratoSelecionado(ctr[0].id, tipoEndosso); //MGRC-1657 - INICIO/FIM

        Test.stopTest();
    }

    @isTest 
    static void gerarNameContratoTest(){
        
        Test.startTest();
        
        String codigoEmpresa = '14'; 
        String codigoSucursal = '1378';
        String codigoRamo = '18'; 
        Integer numeroApolice = 85858;
        String endosso = '1';
        
        ContractBO.getInstance().gerarNameContrato(codigoEmpresa, codigoSucursal, codigoRamo, numeroApolice, endosso);

        Test.stopTest();
    }

    @isTest 
    static void buscarContratantesPorNumeroApoliceTest(){
        
        Test.startTest();
        
        String numeroApolice = '000003417';

        ContractBO.getInstance().buscarContratantesPorNumeroApolice(numeroApolice);

        Test.stopTest();
    }

    @isTest 
    static void buscarPorNumeroApoliceTest(){
        
        Test.startTest();
        
        String numeroApolice = 'Erro';

        ContractBO.getInstance().buscarPorNumeroApolice(numeroApolice);

        Test.stopTest();
    }

    @isTest 
    static void buscarGruposPorNumeroApoliceTest(){
        
        Test.startTest();
        
        String numeroApolice = '000003417';

        ContractBO.getInstance().buscarGruposPorNumeroApolice(numeroApolice);

        Test.stopTest();
    }

    @isTest 
    static void gerarChaveMapaContratoTest(){
        
        Test.startTest();
        String codigoEmpresa = '14'; 
        String codigoSucursal = '1378';
        String codigoRamo = '18'; 
        String numeroApolice = '85858';
        
        ContractBO.getInstance().gerarChaveMapaContrato(codigoEmpresa, codigoSucursal, codigoRamo, numeroApolice);

        Test.stopTest();
    }

    @isTest 
    static void buscarUltimoEndossoApoliceTest(){
        
        Test.startTest();
        String codigoEmpresa = '14'; 
        String codigoSucursal = '1378';
        String codigoRamo = '18'; 
        String numeroApolice = '85858';
        
        ContractBO.getInstance().buscarUltimoEndossoApolice(codigoEmpresa, codigoSucursal, codigoRamo, numeroApolice);

        Test.stopTest();
    }

    @isTest 
    static void gerarComposicaoParcelaTest(){

        Contract ctr = [SELECT Id, CodigoRamo__c, Tipo__c FROM Contract LIMIT 1];
        
        String listContrato = '[{"attributes":{"type":"Contract","url":"/services/data/v61.0/sobjects/Contract/8008900000DTLfxAAH"},"Id":"8008900000DTLfxAAH","Segmento__c":"Individual","AccountId":"001L000001YsXz9IAF","Empresa__c":"14","Sucursal__c":"1","CodigoModalidade__c":14,"RamoSeguro__c":"a1GL0000003DWXWMA4","Name":"14-1-1391-000016470-0","Endosso__c":"0","CodigoRamo__c":"1391","Tarifa__c":"12/08/2024","DescontoAgravoPercentualFormaPagto__c":-5.00,"DescontoAgravoMonetarioFormaPagto__c":-829.22,"Proposta__c":"0Q089000000aqXxCAI","NumeroProposta__c":"00052656","Tipo__c":"Novo","Status":"Emitido","StartDate":"2024-08-13","VigenciaFinal__c":"2025-08-12","CanalDistribuicao__c":"a0AL0000007eweUMAQ","CodigoCorretor__c":"a0QL0000009W6nuMAC","DataEmissao__c":"2024-08-13","PremioPuro__c":6302.14000,"PremioComercial__c":15403.00000,"PremioTotal__c":15461.55000,"ValorIOF__c":58.56,"NumeroPropostaUnico__c":"18-00052656","MeioComercializacao__c":"SFC","Produto__c":"01tL0000008Wi26IAC","Origem__c":"18","RemuneracoesContrato__r":{"totalSize":2,"done":true,"records":[{"attributes":{"type":"RemuneracaoContrato__c","url":"/services/data/v61.0/sobjects/RemuneracaoContrato__c/a1I89000000sNE9EAM"},"Contrato__c":"8008900000DTLfxAAH","Id":"a1I89000000sNE9EAM","Percentual__c":30.00,"TipoRemuneracao__c":"a1VL00000031qzQMAQ","TipoRemuneracao__r":{"attributes":{"type":"TipoRemuneracao__c","url":"/services/data/v61.0/sobjects/TipoRemuneracao__c/a1VL00000031qzQMAQ"},"Name":"CORRETAGEM","Id":"a1VL00000031qzQMAQ"}},{"attributes":{"type":"RemuneracaoContrato__c","url":"/services/data/v61.0/sobjects/RemuneracaoContrato__c/a1I89000000sNEAEA2"},"Contrato__c":"8008900000DTLfxAAH","Id":"a1I89000000sNEAEA2","Percentual__c":0.00,"TipoRemuneracao__c":"a1VL00000031qzLMAQ","TipoRemuneracao__r":{"attributes":{"type":"TipoRemuneracao__c","url":"/services/data/v61.0/sobjects/TipoRemuneracao__c/a1VL00000031qzLMAQ"},"Name":"AGENCIAMENTO","Id":"a1VL00000031qzLMAQ"}}]},"ContratantesContrato__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"ContratanteContrato__c","url":"/services/data/v61.0/sobjects/ContratanteContrato__c/a0f89000000ksa5AAA"},"Contrato__c":"8008900000DTLfxAAH","Id":"a0f89000000ksa5AAA","Tipo__c":"Principal","NomeSocial_do_Contratante__c":"FRANCIS LIU","NomeContratante__c":"FRANCIS LIU","CpfCnpj__c":"518.179.180-87","Conta__c":"001L000001YsXz9IAF","DescontoAgravoPercentualTecnico__c":0.00,"DescontoAgravoMonetarioTecnico__c":0.00,"DescontoAgravoPercentualFormaPagto__c":-5.00,"DescontoAgravoMonetarioFormaPagto__c":-829.22,"PlanoParcelamento__c":"a14DP000003vPpFYAU","QuantidadeParcelas__c":10,"PremioTotal__c":15461.55000,"VencimentoPrimeiraParcela__c":"2024-09-13","ResponsavelPagamento__c":"001L000001YsXz9IAF","TipoResponsavelPagamento__c":"CON","PremioComercial__c":15403.00000,"PremioPuro__c":6302.14000,"VencimentoDemaisParcelas__c":"A cada 30 dias","FormaPagamento__c":"a0aDP000008GAf8YAG","IOF__c":58.56000,"Conta__r":{"attributes":{"type":"Account","url":"/services/data/v61.0/sobjects/Account/001L000001YsXz9IAF"},"RecordTypeId":"012f4000000gnPaAAI","Id":"001L000001YsXz9IAF","RecordType":{"attributes":{"type":"RecordType","url":"/services/data/v61.0/sobjects/RecordType/012f4000000gnPaAAI"},"DeveloperName":"PessoaFisica","Id":"012f4000000gnPaAAI"}},"PlanoParcelamento__r":{"attributes":{"type":"PlanoParcelamento__c","url":"/services/data/v61.0/sobjects/PlanoParcelamento__c/a14DP000003vPpFYAU"},"DescricaoMeioRecebimento__c":"RECEBIMENTO-CART?O RECORRENTE","CodigoMeioRecebimento__c":"W","Id":"a14DP000003vPpFYAU"},"FormaPagamento__r":{"attributes":{"type":"FormaPagamento__c","url":"/services/data/v61.0/sobjects/FormaPagamento__c/a0aDP000008GAf8YAG"},"Codigo__c":"70","Name":"CARTAO DE CREDITO RECORRENTE","Id":"a0aDP000008GAf8YAG"}}]},"GarantiasContrato__r":{"totalSize":10,"done":true,"records":[{"attributes":{"type":"GarantiaContrato__c","url":"/services/data/v61.0/sobjects/GarantiaContrato__c/a0e8900000429BNAAY"},"Contrato__c":"8008900000DTLfxAAH","Id":"a0e8900000429BNAAY","Capital__c":10000.00,"GarantiaProduto__c":"a0jL0000007T5YoIAK","Garantia__c":"a0nL0000008CnWFIA0","PremioComercial__c":272.65,"PremioPuro__c":114.00,"PremioTotal__c":273.69,"PremioIntegral__c":0.00000,"TaxaComercial__c":0.027265,"IOF__c":1.04000,"TaxaPura__c":0.01148,"TaxaTotal__c":0.027368607,"CurrencyIsoCode":"BRL","DescontoAgravoMonetarioComercial__c":0.00,"DescontoAgravoMonetarioInformado__c":0.00,"DescontoAgravoMonetarioTecnico__c":0.00,"DescontoAgravoPercentualComercial__c":0.00,"DescontoAgravoPercentualInformado__c":0.00,"DescontoAgravoPercentualTecnico__c":0.00,"Garantia__r":{"attributes":{"type":"Garantia__c","url":"/services/data/v61.0/sobjects/Garantia__c/a0nL0000008CnWFIA0"},"Sigla__c":"AFF","Id":"a0nL0000008CnWFIA0"}},{"attributes":{"type":"GarantiaContrato__c","url":"/services/data/v61.0/sobjects/GarantiaContrato__c/a0e8900000429BOAAY"},"Contrato__c":"8008900000DTLfxAAH","Id":"a0e8900000429BOAAY","Capital__c":4500.00,"GarantiaProduto__c":"a0jL0000007T5YqIAK","Garantia__c":"a0nL0000008CRhSIAW","PremioComercial__c":320.62,"PremioPuro__c":135.00,"PremioTotal__c":321.84,"PremioIntegral__c":0.00000,"TaxaComercial__c":0.07125,"IOF__c":1.22000,"TaxaPura__c":0.03000,"TaxaTotal__c":0.07152075,"CurrencyIsoCode":"BRL","DescontoAgravoMonetarioComercial__c":0.00,"DescontoAgravoMonetarioInformado__c":0.00,"DescontoAgravoMonetarioTecnico__c":0.00,"DescontoAgravoPercentualComercial__c":0.00,"DescontoAgravoPercentualInformado__c":0.00,"DescontoAgravoPercentualTecnico__c":0.00,"Garantia__r":{"attributes":{"type":"Garantia__c","url":"/services/data/v61.0/sobjects/Garantia__c/a0nL0000008CRhSIAW"},"Sigla__c":"DMHO","Id":"a0nL0000008CRhSIAW"}},{"attributes":{"type":"GarantiaContrato__c","url":"/services/data/v61.0/sobjects/GarantiaContrato__c/a0e8900000429BPAAY"},"Contrato__c":"8008900000DTLfxAAH","Id":"a0e8900000429BPAAY","Capital__c":25.00,"GarantiaProduto__c":"a0jL0000007T5YsIAK","Garantia__c":"a0nL000000AjWNvIAN","PremioComercial__c":119.83,"PremioPuro__c":47.00,"PremioTotal__c":120.28,"PremioIntegral__c":0.00000,"IOF__c":0.46000,"TaxaPura__c":1.91724,"CurrencyIsoCode":"BRL","DescontoAgravoMonetarioComercial__c":0.00,"DescontoAgravoMonetarioInformado__c":0.00,"DescontoAgravoMonetarioTecnico__c":0.00,"DescontoAgravoPercentualComercial__c":0.00,"DescontoAgravoPercentualInformado__c":0.00,"DescontoAgravoPercentualTecnico__c":0.00,"Garantia__r":{"attributes":{"type":"Garantia__c","url":"/services/data/v61.0/sobjects/Garantia__c/a0nL000000AjWNvIAN"},"Sigla__c":"DIT","Id":"a0nL000000AjWNvIAN"}},{"attributes":{"type":"GarantiaContrato__c","url":"/services/data/v61.0/sobjects/GarantiaContrato__c/a0e8900000429BQAAY"},"Contrato__c":"8008900000DTLfxAAH","Id":"a0e8900000429BQAAY","Capital__c":133.00,"GarantiaProduto__c":"a0jL0000007T5YtIAK","Garantia__c":"a0nL000000AjWJPIA3","PremioComercial__c":2.74,"PremioPuro__c":1.00,"PremioTotal__c":2.75,"PremioIntegral__c":0.00000,"TaxaComercial__c":0.02060589041095,"IOF__c":0.01000,"TaxaPura__c":0.26390,"TaxaTotal__c":0.02068419279452,"CurrencyIsoCode":"BRL","DescontoAgravoMonetarioComercial__c":0.00,"DescontoAgravoMonetarioInformado__c":0.00,"DescontoAgravoMonetarioTecnico__c":0.00,"DescontoAgravoPercentualComercial__c":0.00,"DescontoAgravoPercentualInformado__c":0.00,"DescontoAgravoPercentualTecnico__c":0.00,"Garantia__r":{"attributes":{"type":"Garantia__c","url":"/services/data/v61.0/sobjects/Garantia__c/a0nL000000AjWJPIA3"},"Sigla__c":"DIH","Id":"a0nL000000AjWJPIA3"}},{"attributes":{"type":"GarantiaContrato__c","url":"/services/data/v61.0/sobjects/GarantiaContrato__c/a0e8900000429BRAAY"},"Contrato__c":"8008900000DTLfxAAH","Id":"a0e8900000429BRAAY","Capital__c":192000.00,"GarantiaProduto__c":"a0jL0000007T5YuIAK","Garantia__c":"a0nL0000008CnWUIA0","PremioComercial__c":8588.64,"PremioPuro__c":3435.00,"PremioTotal__c":8621.28,"PremioIntegral__c":0.00000,"TaxaComercial__c":0.0447325,"IOF__c":32.64000,"TaxaPura__c":0.017893,"TaxaTotal__c":0.0449024835,"CurrencyIsoCode":"BRL","DescontoAgravoMonetarioComercial__c":0.00,"DescontoAgravoMonetarioInformado__c":0.00,"DescontoAgravoMonetarioTecnico__c":0.00,"DescontoAgravoPercentualComercial__c":0.00,"DescontoAgravoPercentualInformado__c":0.00,"DescontoAgravoPercentualTecnico__c":0.00,"Garantia__r":{"attributes":{"type":"Garantia__c","url":"/services/data/v61.0/sobjects/Garantia__c/a0nL0000008CnWUIA0"},"Sigla__c":"DG17","Id":"a0nL0000008CnWUIA0"}},{"attributes":{"type":"GarantiaContrato__c","url":"/services/data/v61.0/sobjects/GarantiaContrato__c/a0e8900000429BSAAY"},"Contrato__c":"8008900000DTLfxAAH","Id":"a0e8900000429BSAAY","Capital__c":192000.00,"GarantiaProduto__c":"a0jL0000007T5YwIAK","Garantia__c":"a0nL0000008CnWAIA0","PremioComercial__c":2167.30,"PremioPuro__c":912.00,"PremioTotal__c":2175.54,"PremioIntegral__c":0.00000,"TaxaComercial__c":0.01128801875,"IOF__c":8.24000,"TaxaPura__c":0.005003,"TaxaTotal__c":0.01133091322125,"CurrencyIsoCode":"BRL","DescontoAgravoMonetarioComercial__c":0.00,"DescontoAgravoMonetarioInformado__c":0.00,"DescontoAgravoMonetarioTecnico__c":0.00,"DescontoAgravoPercentualComercial__c":0.00,"DescontoAgravoPercentualInformado__c":0.00,"DescontoAgravoPercentualTecnico__c":0.00,"Garantia__r":{"attributes":{"type":"Garantia__c","url":"/services/data/v61.0/sobjects/Garantia__c/a0nL0000008CnWAIA0"},"Sigla__c":"IFPD","Id":"a0nL0000008CnWAIA0"}},{"attributes":{"type":"GarantiaContrato__c","url":"/services/data/v61.0/sobjects/GarantiaContrato__c/a0e8900000429BTAAY"},"Contrato__c":"8008900000DTLfxAAH","Id":"a0e8900000429BTAAY","Capital__c":192000.00,"GarantiaProduto__c":"a0jL0000007T5YyIAK","Garantia__c":"a0nL000000AjWLkIAN","PremioComercial__c":91.20,"PremioPuro__c":38.00,"PremioTotal__c":91.55,"PremioIntegral__c":0.00000,"TaxaComercial__c":0.000475,"IOF__c":0.35000,"TaxaPura__c":0.00020,"TaxaTotal__c":0.000476805,"CurrencyIsoCode":"BRL","DescontoAgravoMonetarioComercial__c":0.00,"DescontoAgravoMonetarioInformado__c":0.00,"DescontoAgravoMonetarioTecnico__c":0.00,"DescontoAgravoPercentualComercial__c":0.00,"DescontoAgravoPercentualInformado__c":0.00,"DescontoAgravoPercentualTecnico__c":0.00,"Garantia__r":{"attributes":{"type":"Garantia__c","url":"/services/data/v61.0/sobjects/Garantia__c/a0nL000000AjWLkIAN"},"Sigla__c":"IPA","Id":"a0nL000000AjWLkIAN"}},{"attributes":{"type":"GarantiaContrato__c","url":"/services/data/v61.0/sobjects/GarantiaContrato__c/a0e8900000429BUAAY"},"Contrato__c":"8008900000DTLfxAAH","Id":"a0e8900000429BUAAY","Capital__c":192000.00,"GarantiaProduto__c":"a0jL0000007T5YzIAK","Garantia__c":"a0nL0000008CQuDIAW","PremioComercial__c":3612.02,"PremioPuro__c":1520.00,"PremioTotal__c":3625.75,"PremioIntegral__c":0.00000,"TaxaComercial__c":0.0188126125,"IOF__c":13.73000,"TaxaPura__c":0.008338,"TaxaTotal__c":0.0188841004275,"CurrencyIsoCode":"BRL","DescontoAgravoMonetarioComercial__c":0.00,"DescontoAgravoMonetarioInformado__c":0.00,"DescontoAgravoMonetarioTecnico__c":0.00,"DescontoAgravoPercentualComercial__c":0.00,"DescontoAgravoPercentualInformado__c":0.00,"DescontoAgravoPercentualTecnico__c":0.00,"Garantia__r":{"attributes":{"type":"Garantia__c","url":"/services/data/v61.0/sobjects/Garantia__c/a0nL0000008CQuDIAW"},"Sigla__c":"BAS","Id":"a0nL0000008CQuDIAW"}},{"attributes":{"type":"GarantiaContrato__c","url":"/services/data/v61.0/sobjects/GarantiaContrato__c/a0e8900000429BVAAY"},"Contrato__c":"8008900000DTLfxAAH","Id":"a0e8900000429BVAAY","Capital__c":192000.00,"GarantiaProduto__c":"a0jL0000007T5Z0IAK","Garantia__c":"a0nL0000008CRh3IAG","PremioComercial__c":228.00,"PremioPuro__c":96.00,"PremioTotal__c":228.87,"PremioIntegral__c":0.00000,"TaxaComercial__c":0.0011875,"IOF__c":0.87000,"TaxaPura__c":0.00050,"TaxaTotal__c":0.0011920125,"CurrencyIsoCode":"BRL","DescontoAgravoMonetarioComercial__c":0.00,"DescontoAgravoMonetarioInformado__c":0.00,"DescontoAgravoMonetarioTecnico__c":0.00,"DescontoAgravoPercentualComercial__c":0.00,"DescontoAgravoPercentualInformado__c":0.00,"DescontoAgravoPercentualTecnico__c":0.00,"Garantia__r":{"attributes":{"type":"Garantia__c","url":"/services/data/v61.0/sobjects/Garantia__c/a0nL0000008CRh3IAG"},"Sigla__c":"MAP","Id":"a0nL0000008CRh3IAG"}},{"attributes":{"type":"GarantiaContrato__c","url":"/services/data/v61.0/sobjects/GarantiaContrato__c/a0e8900000429BWAAY"},"Contrato__c":"8008900000DTLfxAAH","Id":"a0e8900000429BWAAY","Capital__c":0.00,"GarantiaProduto__c":"a0jL0000007T5Z1IAK","Garantia__c":"a0nL0000008Cog2IAC","PremioComercial__c":0.00,"PremioPuro__c":0.00,"PremioTotal__c":0.00,"PremioIntegral__c":0.00000,"IOF__c":0.00000,"CurrencyIsoCode":"BRL","DescontoAgravoMonetarioComercial__c":0.00,"DescontoAgravoMonetarioInformado__c":0.00,"DescontoAgravoMonetarioTecnico__c":0.00,"DescontoAgravoPercentualComercial__c":0.00,"DescontoAgravoPercentualInformado__c":0.00,"DescontoAgravoPercentualTecnico__c":0.00,"Garantia__r":{"attributes":{"type":"Garantia__c","url":"/services/data/v61.0/sobjects/Garantia__c/a0nL0000008Cog2IAC"},"Sigla__c":"TELEMED","Id":"a0nL0000008Cog2IAC"}}]},"Account":{"attributes":{"type":"Account","url":"/services/data/v61.0/sobjects/Account/001L000001YsXz9IAF"},"Name":"FRANCIS LIU","IdExterno__c":"51817918087","Cpf__c":"518.179.180-87","Tributavel__c":false,"Id":"001L000001YsXz9IAF"},"RamoSeguro__r":{"attributes":{"type":"RamoSeguro__c","url":"/services/data/v61.0/sobjects/RamoSeguro__c/a1GL0000003DWXWMA4"},"Codigo__c":"1391","CodigoOrigemDoMovimentoBCP__c":"32","Id":"a1GL0000003DWXWMA4"},"Proposta__r":{"attributes":{"type":"Quote","url":"/services/data/v61.0/sobjects/Quote/0Q089000000aqXxCAI"},"PremioTotal__c":15461.55000,"Id":"0Q089000000aqXxCAI","DataCalculo__c":"2024-08-12","MeioComercializacao__c":"SFC","Name":"18-00052656","NumeroProposta__c":"00052656","Origem__c":"18","Tipo__c":"Novo","TipoVigencia__c":"Periódico","Status":"Contratada","CanalDistribuicao__c":"a0AL0000007eweUMAQ","Empresa__c":"001L000001WfBedIAF","IOF__c":58.56,"Produto__c":"01tL0000008Wi26IAC","OpportunityId":"0068900000EOthgAAD","RamoSeguro__c":"a1GL0000003DWXWMA4","RecordTypeId":"012f4000000QXj0AAG","VigenciaInicial__c":"2024-08-13","VigenciaFinal__c":"2025-08-12","TermoGuarda__c":false,"TermoResponsabilidade__c":true,"AssinaturaEletronica__c":true,"ScoreFraude__c":-1.00,"FormaReceberApolice__c":"DIGITAL","Modalidade__c":"a0uL0000005sdbBIAQ","CanalDistribuicao__r":{"attributes":{"type":"CanalDistribuicao__c","url":"/services/data/v61.0/sobjects/CanalDistribuicao__c/a0AL0000007eweUMAQ"},"Sigla__c":"COR","Name":"Corretor","Id":"a0AL0000007eweUMAQ"},"Empresa__r":{"attributes":{"type":"Account","url":"/services/data/v61.0/sobjects/Account/001L000001WfBedIAF"},"Id":"001L000001WfBedIAF"},"Produto__r":{"attributes":{"type":"Product2","url":"/services/data/v61.0/sobjects/Product2/01tL0000008Wi26IAC"},"Id":"01tL0000008Wi26IAC","Name":"Seguro de Pessoas Individual.","ProductCode":"VI-PESSOASS","Empresa__c":"001L000001WfBedIAF","NumeroSusep__c":"15414.651126/2021-95","Empresa__r":{"attributes":{"type":"Account","url":"/services/data/v61.0/sobjects/Account/001L000001WfBedIAF"},"CodigoEmpresa__c":"14","Name":"PORTO SEGURO VIDA E PREVIDENCIA S/A","Id":"001L000001WfBedIAF"}},"Opportunity":{"attributes":{"type":"Opportunity","url":"/services/data/v61.0/sobjects/Opportunity/0068900000EOthgAAD"},"Id":"0068900000EOthgAAD","CanalDistribuicao__c":"a0AL0000007eweUMAQ","StageName":"Contratado","Numero__c":"00153516","Name":"SFC-00153516","MeioComercializacao__c":"SFC","CanalDistribuicao__r":{"attributes":{"type":"CanalDistribuicao__c","url":"/services/data/v61.0/sobjects/CanalDistribuicao__c/a0AL0000007eweUMAQ"},"Sigla__c":"COR","Id":"a0AL0000007eweUMAQ"}},"RamoSeguro__r":{"attributes":{"type":"RamoSeguro__c","url":"/services/data/v61.0/sobjects/RamoSeguro__c/a1GL0000003DWXWMA4"},"Name":"VIDA INDIVIDUAL","Codigo__c":"1391","CodigoOrigemDoMovimentoBCP__c":"32","CodigoEmpresa__c":"14","Id":"a1GL0000003DWXWMA4"},"RecordType":{"attributes":{"type":"RecordType","url":"/services/data/v61.0/sobjects/RecordType/012f4000000QXj0AAG"},"DeveloperName":"VidaIndividual","Id":"012f4000000QXj0AAG"},"Modalidade__r":{"attributes":{"type":"Modalidade__c","url":"/services/data/v61.0/sobjects/Modalidade__c/a0uL0000005sdbBIAQ"},"CodigoEmpresa__c":"14","Id":"a0uL0000005sdbBIAQ"},"DataEmissao__c":"2024-08-13"},"CanalDistribuicao__r":{"attributes":{"type":"CanalDistribuicao__c","url":"/services/data/v61.0/sobjects/CanalDistribuicao__c/a0AL0000007eweUMAQ"},"Sigla__c":"COR","Id":"a0AL0000007eweUMAQ"},"CodigoCorretor__r":{"attributes":{"type":"DadosCorretor__c","url":"/services/data/v61.0/sobjects/DadosCorretor__c/a0QL0000009W6nuMAC"},"Name":"P5005J","Id":"a0QL0000009W6nuMAC"},"Produto__r":{"attributes":{"type":"Product2","url":"/services/data/v61.0/sobjects/Product2/01tL0000008Wi26IAC"},"ProductCode":"VI-PESSOASS","CodigoPrecificaProduto__c":"VI-PESSOAS","Id":"01tL0000008Wi26IAC"},"NumeroApolice__c":"000016470","IdExterno__c":"14-1-1391-000016470-0"}]';

        List<Contract> listaContratos = new List<Contract>();
        listaContratos = (List<Contract>)JSON.deserialize(listContrato, List<Contract>.class);
        listaContratos[0].id = ctr.id;
        
        listContrato = JSON.serialize(listaContratos);
        
        List<String> lista = new List<String>();
        lista.add('[{"vidasalesforce": null, "valorrestituicao": null, "valorparcela": 1546.20000, "valorpago": null, "valorliquido": 1540.3, "valoriof": 5.91000, "valoragenciamento": 1283.58333333333333333333333333333, "titulo": "", "tiporesponsavelpagamento": "CON", "sucursal": "1", "statusIntegracao": "PENDENTE", "status": "PENDENTE", "seguradosalesforce": "a0f89000000krSjAAI", "responsavelfinanceiro": "001L000001YsXz9IAF", "ramo": "1391", "produto": "VI-PESSOASS", "origemproposta": 18, "numeropropostaporto": "00052656", "numeroparcela": 1, "idproposta": "18-00052656", "idfatura": null, "idexterno": "'+ctr.id+'_a0f89000000krSjAAI", "id": null, "endosso": "0", "empresa": "14", "datavencimento": "2024-09-13", "datapagamento": null, "dataemissao": "2024-08-13", "datacobertura": "2024-12-12", "datacancelamento": null, "codigoparceiro": null, "apolice": null, "antecipacaocomissao": "P"}]');
        lista.add('[{"vidasalesforce": null, "valorrestituicao": null, "valorparcela": 1546.15, "valorpago": null, "valorliquido": 1540.3, "valoriof": 5.85, "valoragenciamento": 1283.58333333333333333333333333333, "titulo": "", "tiporesponsavelpagamento": "CON", "sucursal": "1", "statusIntegracao": "PENDENTE", "status": "PENDENTE", "seguradosalesforce": "a0f89000000krSjAAI", "responsavelfinanceiro": "001L000001YsXz9IAF", "ramo": "1391", "produto": "VI-PESSOASS", "origemproposta": 18, "numeropropostaporto": "00052656", "numeroparcela": 2, "idproposta": "18-00052656", "idfatura": null, "idexterno": "'+ctr.id+'_a0f89000000krSjAAI", "id": null, "endosso": "0", "empresa": "14", "datavencimento": "2024-10-13", "datapagamento": null, "dataemissao": "2024-08-13", "datacobertura": "2025-01-11", "datacancelamento": null, "codigoparceiro": null, "apolice": null, "antecipacaocomissao": "P"}]');
        Test.startTest();     
        ContractBO.gerarComposicaoParcela(listContrato, lista);
        Test.stopTest();
    }
    //FNPVVEP-96 FIM
} //PLV-4536 fim