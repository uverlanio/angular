@isTest
private class ContractTest {

	@testSetup 
	static void setup(){
		TestDataFactory.gerarDadosSetup();
		//PLV-5098 - FIX01 - INICIO
		//TestDataFactory.gerarContrato(true); // INICIO/FIM - Cobertura de classe - Guilherme Brito
		//PLV-5098 - FIX01 - FIM
		// Dados
		dadosTest();
	}

	//PLV-4905 - INICIO
    @isTest
    public static void processarIntegracaoAntares_Success(){
        Quote proposta = [SELECT Id FROM Quote WHERE Name = 'Teste Contrato'];
		Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];
		List<Account> conta = [SELECT id FROM Account WHERE LastName = 'Teste'];
        
		Contract contratoOriginal = new Contract(
			Name = '111',
			Oportunidade__c = oportunidade.Id,
			Proposta__c = proposta.Id,
			Tipo__c = 'Novo',
			AccountId = conta[0].Id
		);
		insert contratoOriginal;

		Contract contrato = new Contract(
			Name = '112',
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

	@isTest
	static void criarContasContrato(){
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
	}

	@isTest
	static void criarLogs(){
		Quote proposta = [SELECT Id FROM Quote WHERE Name = 'Teste Contrato'];
		Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];
		List<Account> conta = [SELECT id FROM Account WHERE LastName = 'Teste'];

		List<Contract> listContrato = new List<Contract>();

		Test.startTest();
		Contract contrato = new Contract(
			Name = '111',
			Status = 'Emitido',
			Oportunidade__c = oportunidade.Id,
			Proposta__c = proposta.Id,
			Tipo__c = 'Novo',
			AccountId = conta[0].Id
		);
		insert contrato;
		listContrato.add(contrato);

		ContractBO.getInstance().executarRegrasLog(listContrato);
		Test.stopTest();

		//ControleIntegracao__c log = [SELECT IdObjeto__c FROM ControleIntegracao__c WHERE IdObjeto__c =: contrato.Id LIMIT 1];
		//System.assert(log != null);
		//System.assertEquals(log.IdObjeto__c, contrato.Id);
	}

	// INICIO - PLV-4614-VI-Guilherme Brito
	@isTest
	static void testeVerificarContratosMassificadosTrue() {
		Quote proposta = [SELECT Id FROM Quote WHERE Name = 'Teste Contrato'];
		Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];
		List<Account> conta = [SELECT id FROM Account WHERE LastName = 'Teste'];

		List<Contract> listContrato = new List<Contract>();

		Test.startTest();
		Contract contrato = new Contract(
			Name = '111',
			Status = 'Em elaboração',
			Oportunidade__c = oportunidade.Id,
			Proposta__c = proposta.Id,
			Tipo__c = 'Novo',
			AccountId = conta[0].Id,
			Massificados__c = true
		);
		insert contrato;
		listContrato.add(contrato);

		ContractBO.getInstance().verificarContratosMassificados();
		Test.stopTest();
	}

	@isTest
	static void testGerarParcelasContrato() {

		Quote proposta = [SELECT Id, Produto__c FROM Quote WHERE Name = 'Teste Contrato']; //PLV-5768 INICIO/FIM
		Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];
		Parceiro__c parceiro = [SELECT Id, Codigo__c, Conta__c FROM Parceiro__c LIMIT 1];
		List<Account> conta = [SELECT id FROM Account WHERE LastName = 'Teste'];
		List<Contract> listContrato = new List<Contract>();
		List<ContratanteContrato__c> listContrato2 = new List<ContratanteContrato__c>();
		List<BusinessHours> listBH = new List<BusinessHours>();
		Map<id,Boolean> mockMap = new Map<id,Boolean>();
		mockMap.put(proposta.id, true);
		Test.startTest();

		Contract contrato = new Contract(
			Name = '111',
			Status = 'Em elaboração',
			Oportunidade__c = oportunidade.Id,
			Proposta__c = proposta.Id,
			Tipo__c = 'Novo',
			AccountId = conta[0].Id,
			Massificados__c = true,
			Parceiro__c = 'Teste',
			Produto__c = proposta.Produto__c //PLV-5768 INICIO/FIM
		);

		insert contrato;		

		ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
			Contrato__c = contrato.Id,
			TipoResponsavelPagamento__c = 'SEG'
		);

		insert contratanteContrato;

		System.debug('contratanteContrato.Contrato : ' + contratanteContrato.Contrato__c);
		System.debug('contrato : ' + contrato.Id);

		listContrato.add(contrato);

		//ContratanteContrato__c contratanteContrato = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
		//listContrato2.add(contratanteContrato);
		//insert listContrato2;

		ContractBO.getInstance().gerarParcelasContrato(listContrato, listBH, mockMap);

		Test.stopTest();
	}

	@isTest
	static void SOQLTests() {

		Quote proposta = [SELECT Id FROM Quote WHERE Name = 'Teste Contrato'];
		Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];
		Parceiro__c parceiro = [SELECT Id, Codigo__c, Conta__c FROM Parceiro__c LIMIT 1];
		List<Account> conta = [SELECT id FROM Account WHERE LastName = 'Teste'];
		List<Contract> listContrato = new List<Contract>();
		List<String> listString = new List<String>{'teste', 'teste2'};
		Set<String> setsContract = new Set<String>();
		Set<Id> setsContractId = new Set<Id>();
		List<ContratanteContrato__c> listContrato2 = new List<ContratanteContrato__c>();
		List<BusinessHours> listBH = new List<BusinessHours>();
		Map<id,Boolean> mockMap = new Map<id,Boolean>();
		mockMap.put(proposta.id, true);
		
		Test.startTest();

		Contract contrato = new Contract(
			Name = '111',
			Status = 'Em elaboração',
			Oportunidade__c = oportunidade.Id,
			Proposta__c = proposta.Id,
			Tipo__c = 'Novo',
			AccountId = conta[0].Id,
			Massificados__c = true,
			Parceiro__c = 'Teste'
		);

		insert contrato;
		listContrato.add(contrato);
		setsContract.add(contrato.IdExterno__c);
		setsContractId.add(contrato.id);

		ContratanteContrato__c contratanteContrato = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
		listContrato2.add(contratanteContrato);
		//insert listContrato2;

		ContractDAO.getInstance().buscarContratoOriginalPorId(contrato.id);
		ContractDAO.getInstance().buscarContratosAnteriores(setsContract);
		ContractDAO.getInstance().buscarPorNumeroApolice(setsContract);
		ContractDAO.getInstance().buscarContratos(setsContractId);
		ContractDAO.getInstance().buscarContratosPorCodigo(listString); //<<
		ContractDAO.getInstance().buscarContratoPorProposta(setsContractId);
		ContractDAO.getInstance().buscarContratoPorName('listString');
		ContractDAO.getInstance().buscarPorNumeroApoliceEndosso('listString', 'Teste');
		ContractDAO.getInstance().buscarContratosPorId(setsContractId);
		ContractDAO.getInstance().buscarContratantesPorNumeroApolice(setsContract);
		ContractDAO.getInstance().buscarGruposPorNumeroApolice(setsContract);
		ContractDAO.getInstance().buscarGruposPorContratante(setsContract);
		ContractDAO.getInstance().buscarGarantiasContratante(setsContract);
		ContractDAO.getInstance().buscarGarantiasSegurado(setsContract);
		ContractDAO.getInstance().buscarContratoPorProposta('Empresa', 'Ramo', 'Origem', 'Proposta');
		ContractDAO.getInstance().buscarGarantiaContratoPorId(setsContractId);
		ContractDAO.getInstance().buscarCriticaContratoByContrato(setsContractId);
		ContractDAO.getInstance().buscarGarantiasSeguradoContratoByContrato(setsContractId);
		ContractDAO.getInstance().buscarGarantiasGrupoContratoByContrato(setsContractId);
		ContractDAO.getInstance().buscarGarantiasContratanteContratoByContrato(setsContractId);
		ContractDAO.getInstance().buscarListSeguradosContratoByContrato(setsContractId);
		ContractDAO.getInstance().buscarListGrupoContratoByContrato(setsContractId);
		ContractDAO.getInstance().buscarSeguradoContratoPorContractId(setsContractId);
		ContractDAO.getInstance().buscarRemuneracaoContratoPorId(setsContractId);
		ContractDAO.getInstance().buscarContratantesContratoByContrato(setsContractId);
		ContractDAO.getInstance().buscarContratoById(contrato.id);

		Test.stopTest();
	}


	@isTest
	static void testcriarApolice() {

		Quote proposta = [SELECT Id FROM Quote WHERE Name = 'Teste Contrato'];
		Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];
		List<Account> conta = [SELECT id FROM Account WHERE LastName = 'Teste'];
		List<Contract> listContract = new List<Contract>();

		Contract contrato = new Contract(
			Name = '111',
			Oportunidade__c = oportunidade.Id,
			Proposta__c = proposta.Id,
			Tipo__c = 'Novo',
			AccountId = conta[0].Id
		);
		insert contrato;
		listContract.add(contrato);

		Test.startTest();
		ContractBO.getInstance().criarApolice(listContract);
		Test.stopTest();
	}

	// FIM - PLV-4614-VI-Guilherme Brito

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

		//TKCL-246 FIX05 INICIO
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Account contateste = (Account) new AccountFactory.PessoaFisica().createRecord();
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contateste).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contateste).createRecord();
        CanalDistribuicao__c canalDistribuicao = (CanalDistribuicao__c) new CanalDistribuicaoFactory().createRecord(); 

        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        Product2 produtoTecnicoteste = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnicoteste.Status__c = 'Em ativação';
        produtoTecnicoteste.NumeroSusep__c = '123';
        produtoTecnicoteste.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnicoteste;
        produtoTecnicoteste.Status__c = 'Ativo';
        produtoTecnicoteste.ProductCode = '49';
        produtoTecnicoteste.Segmento__c = 'Individual';
        update produtoTecnicoteste;
		Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnicoteste).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.ProductCode = 'APTLMKT';
        produtoComercial.Segmento__c = 'Individual';
        produtoComercial.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercial;
        //TKCL-246 FIX05 FIM

		ParametroVigencia__c parametroCom = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaComercial(produtoComercial).createRecord(); //PLV-5768 INICIO/FIM

		Quote proposta = new Quote(
			Name= 'Teste Contrato',
			OpportunityId=oportunidade.Id,
			DataProtocolo__c = Date.today(),
			DataCalculo__c =  Date.today(),
			Empresa__c = conta.Id,
			ExpirationDate = Date.today(),
			Produto__c = produtoComercial.Id //TKCL-246 FIX05 INICIO/FIM
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

		BeneficiarioSeguradoProposta__c beneficiario2 = new BeneficiarioSeguradoProposta__c(
			SeguradoProposta__c = vida.Id,
			CpfCnpj__c = '99235310075',
			Nome__c = 'Teste Contrato',
			TipoBeneficiario__c = 'Nome do beneficiário',
			GrauParentesco__c = 'Pai',
			Participacao__c = 100,
			Pep__c = 'Não'
		);
		insert beneficiario2;



		//PLV-5098 - FIX01 - INICIO
		FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
		Account contaParceiro = new Account(Name = 'ParceiroTeste', CodigoEmpresa__c = '12', IdExterno__c = '67708896000139', Inscricao_Municipal__c = '123456789', Cnpj__c = '67.708.896/0001-39');
		insert contaParceiro;
		TestDataFactory.gerarParceiro(contaParceiro,formaPagamento);
		//PLV-5098 - FIX01 - FIM
	}
}