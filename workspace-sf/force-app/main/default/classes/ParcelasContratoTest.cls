@isTest
private class ParcelasContratoTest {
	
	@testSetup 
	static void setup(){
        TestDataFactory.gerarDadosSetup();

        // Dados
        dadosTest();

        dadosParcelasContrato();
	}

	public static void dadosTest(){
        Account conta = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
            LastName = 'Teste',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '00478394659',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = Date.valueOf('1980-12-24'),
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

        //TKCL-246 FIX05 INICIO
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        CanalDistribuicao__c canalDistribuicao = (CanalDistribuicao__c) new CanalDistribuicaoFactory().createRecord(); 

        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
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


        Quote proposta = new Quote(
            Name= 'Teste Contrato',
            OpportunityId=oportunidade.Id,
            DataProtocolo__c = Date.today(),
            DataCalculo__c =  Date.today(),
            Empresa__c = conta.Id,
            ExpirationDate = Date.today(),
            Produto__c = produtoComercial.id //TKCL-246 FIX05 INICIO/FIM
        );
        insert proposta;

        ContratanteProposta__c segurado = new ContratanteProposta__c(
            conta__c = conta.Id,
            Proposta__c = proposta.Id,
            Tipo__c = 'Principal'
        );
        insert segurado;

        GrupoProposta__c grupo = new GrupoProposta__c(
            Name = 'Teste',
            QuantidadeVidas__c = 1,
            ContratanteProposta__c = segurado.Id
        );
        insert grupo;


        SeguradoProposta__c vida = new SeguradoProposta__c(
            Conta__c = conta.Id,	
            GrupoProposta__c = grupo.Id
        );
        insert vida;


        BeneficiarioSeguradoProposta__c beneficiario = new BeneficiarioSeguradoProposta__c(
            SeguradoProposta__c = vida.Id,
            CpfCnpj__c = '00478394659',
            Nome__c = 'Teste Contrato',
            TipoBeneficiario__c = 'Nome do beneficiário',
            GrauParentesco__c = 'Pai',
            Participacao__c = 100,
            Pep__c = 'Não'
        );
        insert beneficiario;

        Contract contrato = new Contract(
			Name = '111',
			Oportunidade__c = oportunidade.Id,
			Proposta__c = proposta.Id,
			Tipo__c = 'Novo',
			AccountId = conta.Id
		);
		insert contrato;

		ContratanteContrato__c seguradoContrato = TestDataFactory.gerarContratanteContrato(contrato, conta, null);
    }

    @isTest
    public static void dadosParcelasContrato(){

    	Contract contrato = [SELECT id FROM Contract WHERE Name = '111'];
    	ContratanteContrato__c seguradoroContrato = [SELECT id FROM ContratanteContrato__c where Contrato__c = :contrato.id];

    	ParcelamentoContratoTO parcelamentoContrato = new ParcelamentoContratoTO();

    	ParcelamentoContratoTO.MetaTO meta = new ParcelamentoContratoTO.MetaTO();
    	meta.dataExecucao = '';
    	meta.servico = '';
    	meta.statusHttp = 0;
    	meta.mensagem = '';

    	List<ParcelamentoContratoTO.DataTO> lstData = new List<ParcelamentoContratoTO.DataTO>();
    	ParcelamentoContratoTO.DataTO data = new ParcelamentoContratoTO.DataTO();
    	data.idfatura = 0;
    	data.status = '';
    	data.endosso = '';
    	data.idexterno = '';
    	data.valorparcela = '';
    	data.seguradosalesforce = '';
    	data.vidasalesforce = '';
    	data.valoriof = '';
    	data.id = 0;
    	data.empresa = '';
    	data.ramo = '';
    	data.numeroparcela = 1;
    	data.apolice = '';
    	data.responsavelfinanceiro = '';
    	data.titulo = '';
    	data.origemproposta = 1;
    	data.idparceiro = '';
    	data.datavencimento = '';
    	data.contrato = '';
    	data.numeroproposta = '';
    	data.valorliquido = '';
    	data.sucursal = '';

    	lstData.add(data);

		parcelamentoContrato.meta = meta;
		parcelamentoContrato.data = lstData;

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(parcelamentoContrato), 200, 'OK'));
		Test.startTest();

        List<ParcelasContratoController.Parcelamento> lstParcelamento = ParcelasContratoController.obterParcelas(seguradoroContrato.id);

        Test.stopTest();
        System.assertEquals(12, lstParcelamento.size()); //TKCL-246 FIX05 INICIO/FIM

    }

	@IsTest
	static void testAtualizarParcelaContrato(){

		String respostaSucesso = '{"meta":{"dataExecucao":"2019-01-21T21:29:58.816Z","servico":"AtualizarStatusParcelasContrato.","statusHttp":200,"mensagem":"1 atualizada(s) com sucesso."}}';
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(respostaSucesso), 200, 'OK'));
		Boolean atualizou = ParcelasContratoController.atualizarParcelaContrato(1,'PENDENTE');

		System.assertEquals(atualizou,true);

    }
    //PLV-3869 - INICIO - PEDRO AUGUSTO -SYS4B
    @IsTest
	static void testCanEditPositivo(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';

        Profile p = [SELECT Id FROM Profile WHERE Name='Administrador porto'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='pt_BR',
        LocaleSidKey='pt_BR', ProfileId = p.Id,
        TimeZoneSidKey='America/Sao_Paulo',
         UserName=uniqueUserName);
        Boolean canEdit = null;
        Test.startTest();
        System.runAs(u) {
            canEdit = ParcelasContratoController.getCanEdit();
        }
        Test.stopTest();

		System.assertEquals(canEdit,true);

    }

    @IsTest
	static void testCanEditNegativo(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';

        Profile p = [SELECT Id FROM Profile WHERE Name='Atendimento'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='pt_BR',
        LocaleSidKey='pt_BR', ProfileId = p.Id,
        TimeZoneSidKey='America/Sao_Paulo',
         UserName=uniqueUserName);
        Boolean canEdit = null;
        Test.startTest();
        System.runAs(u) {
            canEdit = ParcelasContratoController.getCanEdit();
        }
        Test.stopTest();

		System.assertEquals(canEdit,false);

    }
    
    //PLV-3869 - FIM - PEDRO AUGUSTO -SYS4B

	
}