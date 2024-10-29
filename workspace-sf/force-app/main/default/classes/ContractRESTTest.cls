@isTest
private class ContractRESTTest {
	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
		//PLV-5128 - INICIO
		// PLV-2312-28 INICIO
		//TestDataFactory.gerarContrato(true);
		// PLV-2312-28 FIM
		gerarDados();
		//PLV-5128 - FIM
	}

	@isTest
	private static void TestParsePhones(){
		Contract contrato = [SELECT Id, Status, AccountId FROM Contract LIMIT 1];

		Test.startTest();
		Account acc = new Account(Id = contrato.AccountId);
		acc.Phone = '(11) 98888-7777';
		//acc.PersonHomePhone = '(11) 98888-7777';
		//acc.PersonOtherPhone = '(11) 98888-7777';
		acc.Fax = '(11) 98888-7777';
		update acc;

		contrato.Status = 'Emitido';
		Test.stopTest();
	}

	@isTest
	private static void testarRecompraTitulo(){ 
		RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/api/contrato/recompra-titulo';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf('');

	    String retornoPortoCap = '[{"cd_versao" : 2, "cd_retorno" : 0, "id_lote" : 24, "nm_retorno" : "xpto", "Cessionario" : ["Cd_cessionario" : "", "vr_titulo" : 121, "nr_lote" : 1, "Cd_cessionario" : "555"]}]';
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoPortoCap, 200, 'OK'));

	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    //try {
	    	ContractREST.processarPost();
	    //} catch(Exception ex) {
	    //	System.debug(ex.getMessage());
	    //}
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();

	    System.debug(jsonResposta);
	}

	@isTest
	private static void testarConsultaTitulo(){ 
	   	RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/api/contrato/consulta-titulo';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf('{}');

	  	String retornoPortoCap = '"Propostas": [{"nm_pessoa": "I4PROCAP SEGURO VIDA E PREVIDENCIA SA","nr_cnpjcpf": 67567732000139,"Cd_promocao": "VITST","cd_versao": 2,"nr_serie": "02VP02C18","nr_proposta": 2,"dt_emissao": "2018-03-26T00:00:00","dt_inicio_vigencia": "2018-03-26T00:00:00","DadosTitulos": {"Titulos": [{ "cd_cessionario": "8555", "nm_cessionario": "", "nr_cpfcnpj_cessionario": 0, "Nr_titulo": 1, "vr_desconto": 0, "Vr_valor": 0.6, "nr_sorte": "80338", "nm_status": "Suspenso", "nr_Lote": "534543" }]}}]';
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoPortoCap, 200, 'OK'));

	    Test.startTest();

	    RestContext.response = res;
	    RestContext.request = request;

	    try {
	    	ContractREST.processarPost();	
	    } catch(Exception ex) {
	    	System.debug(ex.getMessage());
	    }

	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();

	    System.debug(jsonResposta);
	}

	@isTest
	private static void testarConsultaProposta(){ 	    
	    //String payloadProposta = '{"empresa" : "22", "ramo" : "2", "origem": "18", "proposta" : "1385"}';

        Contract contrato = [SELECT Id, Empresa__c, RamoSeguro__r.Codigo__c, Proposta__r.Origem__c, Proposta__r.NumeroProposta__c FROM Contract LIMIT 1];

	    String payloadProposta = '{"empresa" : "'+contrato.Empresa__c+'", "ramo" : "'+contrato.RamoSeguro__r.Codigo__c+'", "origem": "'+contrato.Proposta__r.Origem__c+'", "proposta" : "'+contrato.Proposta__r.NumeroProposta__c+'"}';

	    RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(payloadProposta);
	    request.requestUri ='/services/apexrest/api/contrato/consulta-contrato-proposta';

	    ConsultarDadosContratoTO.DadosParcelasTO obj = new ConsultarDadosContratoTO.DadosParcelasTO();
	    obj.data = new List<ConsultarDadosContratoTO.ParcelasTO>();

    	Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(obj), 200, 'OK'));
	    Test.startTest();

	    RestContext.response = res;
	    RestContext.request = request;
	    
	   	ContractREST.processarPost();

	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();

	    System.debug(jsonResposta);
	}

	@isTest
	private static void testarConsultaApolice(){
		//PLV-5128 - INICIO
        Contract contrato = [SELECT Id, Empresa__c, CodigoRamo__c, Sucursal__c, NumeroApolice__c, Endosso__c, AccountId,
			PremioTotal__c, Proposta__r.NumeroProposta__c, Origem__c, Produto__c FROM Contract LIMIT 1];
		
		RemuneracaoContrato__c rc = [SELECT Id FROM RemuneracaoContrato__c WHERE Contrato__c =: contrato.Id];

		FavorecidoRemuneracaoContrato__c frc = new FavorecidoRemuneracaoContrato__c(
			Conta__c = contrato.AccountId,
			RemuneracaoContrato__c = rc.Id,
			Susep__c = 'TTT',
			CorretorLider__c = true
		);
		insert frc;

		ContratanteContrato__c contratante = [SELECT Id FROM ContratanteContrato__c WHERE Tipo__c = 'Principal' LIMIT 1];

		ConsultarDadosContratoTO.ParcelasTO parcelasTO = new ConsultarDadosContratoTO.ParcelasTO();
		parcelasTO.idexterno = contrato.Id + '_' + contratante.Id;
		parcelasTO.idfatura = null;
		parcelasTO.codigoparceiro = null;
		parcelasTO.idcontratosalesforce = contrato.Id;
		parcelasTO.origemproposta = Integer.valueOf(contrato.Origem__c);
		parcelasTO.numeroproposta = contrato.Proposta__r.NumeroProposta__c;
		parcelasTO.numerofatura = null;
		parcelasTO.responsavelfinanceiro = contrato.AccountId;
		parcelasTO.tiporesponsavelpagamento = 'CON';
		parcelasTO.seguradosalesforce = contratante.Id;
		parcelasTO.vidasalesforce = null;
		parcelasTO.datapagamento = null;
		parcelasTO.datavencimento = String.valueOf(System.today());
		parcelasTO.numeroparcela = 1;
		parcelasTO.status = 'PENDENTE';
		parcelasTO.titulo = '';
		parcelasTO.produto = 'VI-PESSOAS';
		parcelasTO.valoriof = '20.89';
		parcelasTO.valorliquido = String.valueOf(contrato.PremioTotal__c - 20.89);
		parcelasTO.valorparcela = String.valueOf(contrato.PremioTotal__c);
		parcelasTO.valorpago = null;
		parcelasTO.valorrestituicao = null;
		parcelasTO.empresa = contrato.Empresa__c;
		parcelasTO.sucursal = contrato.Sucursal__c;
		parcelasTO.ramo = contrato.CodigoRamo__c;
		parcelasTO.apolice = contrato.NumeroApolice__c;
		parcelasTO.endosso = contrato.Endosso__c;
		parcelasTO.quantidadevidacontrato = 1;
		parcelasTO.id = 1;
		parcelasTO.antecipacaocomissao = 'S';

		ConsultarDadosContratoTO.DadosParcelasTO obj = new ConsultarDadosContratoTO.DadosParcelasTO();
	    obj.data = new List<ConsultarDadosContratoTO.ParcelasTO>{parcelasTO};
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(obj), 200, 'OK'));

	    ServiceTO.ParametroConsultaContratoPorApoliceTO payload = new ServiceTO.ParametroConsultaContratoPorApoliceTO();
	    payload.empresa  = contrato.Empresa__c;
	    payload.ramo     = contrato.CodigoRamo__c;
	    payload.sucursal = contrato.Sucursal__c;
	    payload.apolice  = contrato.NumeroApolice__c;
	    payload.endosso  = contrato.Endosso__c;
		payload.numeroparcela = 1;

	    RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.httpMethod = 'POST';
		request.requestBody = Blob.valueOf(JSON.serialize(payload));
	    request.requestUri ='/services/apexrest/api/contrato/consulta-contrato-apolice';

	    RestContext.response = res;
	    RestContext.request = request;

		Test.startTest();
	   	ContractREST.processarPost();
	    Test.stopTest();

		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
		Map<String, Object> dataMap = (Map<String, Object>) responseMap.get('data');
		System.assertEquals(0, dataMap.get('statusChamada'));
		//PLV-5128 - FIM
	}

	//PLV-5128 - INICIO
	@isTest
	private static void testarParametroInvalidoConsultaApolice() {
		RestResponse res = new RestResponse();
	    RestRequest req = new RestRequest();
	    req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"empresa": "1","sucursal": "1","ramo": "1391","apolice","endosso": "1","numeroparcela"}');
	    req.requestUri ='/services/apexrest/api/contrato/consulta-contrato-apolice';

		RestContext.response = res;
	    RestContext.request = req;
	    
		Test.startTest();
		ContractREST.processarPost();
	    Test.stopTest();
		
		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
		Map<String, Object> dataMap = (Map<String, Object>) responseMap.get('data');
		System.assertEquals(-1, dataMap.get('statusChamada'));
	}

	@isTest
	private static void testarValorNaoInformadoConsultaApolice() {
		RestResponse res = new RestResponse();
	    RestRequest req = new RestRequest();
	    req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"empresa": "1","sucursal": "1","ramo": "1391","apolice": "000013137","endosso": "1","numeroparcela": null}');
	    req.requestUri ='/services/apexrest/api/contrato/consulta-contrato-apolice';

		RestContext.response = res;
	    RestContext.request = req;
	    
		Test.startTest();
		ContractREST.processarPost();
	    Test.stopTest();
		
		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
		Map<String, Object> dataMap = (Map<String, Object>) responseMap.get('data');
		System.assertEquals(-1, dataMap.get('statusChamada'));
	}
	//PLV-5128 - FIM

	@isTest
	private static void testaDAO(){
		List<SeguradoContrato__c> l = [Select Id, GrupoContrato__c, GrupoContrato__r.ContratanteContrato__c From SeguradoContrato__c ];
        SeguradoContratoDAO.getInstance().obterVida(l[0].Id);
        //PLV-3460 Fix 5 - INICIO - Ajuste para aumento de cobertura da classe de teste
        List<Contract> c = [SELECT Id, Name, AccountId, Empresa__c, CodigoRamo__c, Sucursal__c, NumeroApolice__c, Endosso__c, Proposta__c, Parceiro__c, Produto__c, (SELECT Id FROM ContratantesContrato__r) FROM Contract];
        Contract contract = c[0];
        //ContractDAO dao = ContractDAO.getInstance();
        ContractDAO.getInstance().buscarContratantesContratoByContrato(new Set<Id>{contract.Id});
        ContractDAO.getInstance().buscarCriticaContratoByContrato(new Set<Id>{contract.Id});
        ContractDAO.getInstance().buscarGarantiasGrupoContratoByContrato(new Set<Id>{contract.Id});
        ContractDAO.getInstance().buscarGarantiasSeguradoContratoByContrato(new Set<Id>{contract.Id});
        ContractDAO.getInstance().buscarGarantiasContratanteContratoByContrato(new Set<Id>{contract.Id});
		ContractDAO.getInstance().buscarListSeguradosContratoByContrato(new Set<Id>{contract.Id});
        ContractDAO.getInstance().buscarListGrupoContratoByContrato(new Set<Id>{contract.Id});
        ContractDAO.getInstance().buscarContratantesPorNumeroApolice(new Set<String>{contract.Name});
        ContractDAO.getInstance().buscarGruposPorNumeroApolice(new Set<String>{contract.Name});
        //ContractDAO.getInstance().buscarContratos(new Set<Id>{contract.Id});
		//ContractDAO.getInstance().verificarContratosMassificados();        
        //ContractDAO.getInstance().buscarSeguradoContratoPorContractId(new Set<Id>{contract.Id});
        //ContractDAO.getInstance().buscarPorNumeroApoliceEndosso(contract.Name, contract.Endosso__c);
		//ContractDAO.getInstance().buscarContratosPorCodigo(new List<String>{contract.Name});
        //ContractDAO.getInstance().buscarPorNumeroApolice(new Set<String>{contract.Name});
        //ContractDAO.getInstance().buscarContratosPorId(new Set<Id>{contract.Id});
        //ContractDAO.getInstance().buscarRemuneracaoContratoPorId(new Set<Id>{contract.Id});
        //ContractDAO.getInstance().buscarContratosAnteriores(new Set<String>{contract.Empresa__c + '-' + contract.Sucursal__c + '-' + contract.CodigoRamo__c + '-' + contract.NumeroApolice__c + '-%'});
        //ContractDAO.getInstance().buscarContratosPorId(new Set<Id>{contract.Id});
        //ContractDAO.getInstance().buscarContratosPorId(new Set<Id>{contract.Id});
        //ContractDAO.getInstance().buscarContratoById(contract.Id);
        //ContractDAO.getInstance().buscarProdutoDoParceiro(new Set<String>{contract.Parceria__r.Codigo__c}, new Set<Id>{contract.Produto__c});
        //ContractDAO.getInstance().buscarSeguradosContrato(new Set<Id>{contract.ContratantesContrato__r[0].Id});
        //ContractDAO.getInstance().buscarParceiros(new Set<Id>{contract.AccountId});
        //ContractDAO.getInstance().buscarGarantiasContratante(new Set<String>{contract.ContratantesContrato__r[0].Id});
        //ContractDAO.getInstance().buscarGarantiasSegurado(new Set<String>{l[0].Id});
        //ContractDAO.getInstance().buscarContratoPorProposta(contract.Empresa__c, contract.CodigoRamo__c, contract.Origem__c, contract.Proposta__r.NumeroProposta__c);
        //ContractDAO.getInstance().buscarContratoPorProposta(new Set<Id>{contract.Proposta__c});
        //PLV-3460 Fix 5 - FIM - Ajuste para aumento de cobertura da classe de teste
	}

	//PLV-5128 - INICIO
	public static void gerarDados() {

		Account pessoaFisica = new Account(
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
			LastName = 'Pessoa Fisica',
			Nacionalidade__c = 'Brasileira',
			CPF__c = '30792848012',
			Rg__c = '232323231',
			DataExpedicao__c = Date.today(),
			OrgaoExpedidor__c = '123132',
			PersonBirthDate = (Date.today()-7300),
			EstadoCivil__c = 'Solteiro (a)',
			Sexo__c = 'Masc',
			Pis__c = '123456789'
		);
		insert pessoaFisica;

		Account contaParceiro = new Account(
			Name = 'Parceiro',
			CodigoEmpresa__c = '12',
			IdExterno__c = '67708896000139',
			Inscricao_Municipal__c = '123456789',
			Papel__c = 'Parceiro',
			Cnpj__c = '67.708.896/0001-39'
		);
		insert contaParceiro;

		FormaPagamento__c formaPagamento = new FormaPagamento__c(
			Codigo__c = '1234',
			Name = '3X'
		);
		insert formaPagamento;

		Parceiro__c parceiro = new Parceiro__c(
			ApoliceFaturamento__c = '1',
			DiaFaturamento__c = '15',
			DiaPreFaturamento__c = '20',
			PrazoVencimento__c = '10',
			Conta__c = contaParceiro.Id,
			FaturaProdutosSeparados__c = 'Sim',
			PossuiAnexoFatura__c = 'Nao',
			FormaPagamento__c = formaPagamento.Id,
			SiglaParceiro__c = 'PAR',
			Empresa__c = '12',
			Sucursal__c = '12',
			Ramo__c = '12'
        );
        insert parceiro;

        Garantia__c garantia = new Garantia__c(
			Name = 'Produto Porto',
			VigenciaInicial__c = System.today(),
			Tipo__c = 'Cobertura',
			Sigla__c = 'PP'
	    );
		insert garantia;

		String ramo = '1391';

        RamoSeguro__c ramoSeguro = new RamoSeguro__c(
			Name = 'Segurado',
			CodigoEmpresa__c = '214',
			Codigo__c = ramo,
			IdExterno__c = '214_9',
			Empresa__c = contaParceiro.Id,
			CodigoOrigemDoMovimentoBCP__c = '32',
			Status__c = 'Ativo'
		);
		insert ramoSeguro;

        RamoGarantia__c ramoGarantia = new RamoGarantia__c(
			Garantia__c = garantia.Id,
			RamoSeguro__c = ramoSeguro.Id
		);
		insert ramoGarantia;

        Modalidade__c modalidade = new Modalidade__c(
			RamoSeguro__c = ramoSeguro.Id,
			Name = 'Factory',
			Codigo__c = '0'
		);
		insert modalidade;

        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;

        GarantiaProduto__c garantiaProdTec = new GarantiaProduto__c(
            Garantia__c = garantia.Id,
            Produto__c = produtoTecnico.Id,
            RamoSeguro__c = ramoSeguro.Id,
            OrdemPrioridade__c = 1,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id,
            TipoGarantia__c = 'Cobertura',
			TipoCapital__c = 'Capital uniforme',
			TipoBeneficiario__c = 'O próprio segurado',
			CodigoPromocao__c = 'VITST',
			VersaoTitulo__c = '1');
        insert garantiaProdTec;

        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
		update produtoComercial;

        GarantiaProduto__c garantiaProdCom = new GarantiaProduto__c(
			Garantia__c = garantia.Id,
			GarantiaProduto__c = garantiaProdTec.Id,
			Produto__c = produtoComercial.Id,
			OrdemPrioridade__c = 1,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id,
			TipoGarantia__c = 'Cobertura',
			TipoCapital__c = 'Capital uniforme',
			RamoSeguro__c = ramoSeguro.Id,
			TipoCaracteristicaEspecial__c = 'Cestas',
			LimiteMaximoCaracteristicaEspecial__c = 100,
			LimiteMinimoCaracteristicaEspecial__c = 10,
			CodigoPromocao__c = 'VITST',
			VersaoTitulo__c = '1',
			Obrigatoria__c = true,
			PrazoMaximoLiquidacao__c = 10,
			TipoPrazoMaximoLiquidacao__c = 'Dia',
			PrazoAvisoSinistro__c = 20,
			TipoPrazoAvisoSinistro__c = 'Ano',
			OrigemSinistroBeneficio__c = 'Acidente',
			LimiteCapitalMinimo__c = 20,
			LimiteCapitalMaximo__c = 900,
			currencyIsoCode = 'BRL',
			TipoBeneficiario__c = 'Mãe',
			CancelaSegurado__c = true,
			VigenciaGarantia__c = 'Contratação até fim da apólice'
		);
		insert garantiaProdCom;

        Account contaCorretor = new Account(
			Name = 'ContaCorretor',
			Papel__c = 'Corretor',
			IdExterno__c = '38012786532',
			Cnpj__c = '38.579.897/0001-22'
		);
        insert contaCorretor;

		DadosCorretor__c dadosCorretor = new DadosCorretor__c(
			Name = contaCorretor.Name,
			NomeCorretor__c = contaCorretor.Id
        );
        insert dadosCorretor;

		Banco__c banco = new Banco__c(
			CodigoBanco__c = '341',
            ConveniadoADC__c  = false,
            Name = 'BANCO ITAU S/A',
            Ativo__c = true
		);
		insert banco;

		InformacaoBancaria__c infoBancariaCorretor = new InformacaoBancaria__c(
			Conta__c = contaCorretor.Id,
			Agencia__c = '8765',
			Banco__c = '341',
			NumeroConta__c = '012345',
			Digito__c = '3',
			BancoNew__c = banco.Id,
			StatusIntegracao__c = 'Validada'
		);
		insert infoBancariaCorretor;

		ProdutoParceiro__c produtoParceiro = new ProdutoParceiro__c(
			Produto__c = produtoComercial.Id,
			Parceiro__c = parceiro.Id,
			CodigoProdutoParceiro__c = produtoComercial.Id
        );
        insert produtoParceiro;

		TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
            Name = 'CORRETAGEM',
            Codigo__c = 'COR',
            LimiteMinimo__c = 0,
            LimiteMaximo__c = 100
        );		
		insert tipoRemuneracao;

		RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro = new RemuneracaoProdutoParceiro__c(
			Percentual__c = 20,
			TipoRemuneracao__c = tipoRemuneracao.Id,
			ProdutoParceiro__c = produtoParceiro.Id
        );
        insert remuneracaoProdutoParceiro;

		FavorecidoRemuneracao__c favorecidoRemuneracao = new FavorecidoRemuneracao__c(
            Conta__c = contaCorretor.Id,
            Percentual__c = 80.00,
            Papel__c = 'Corretor',
            Lider__c = true,
            DadosCorretor__c = dadosCorretor.Id,
            RemuneracaoProdutoParceiro__c = remuneracaoProdutoParceiro.Id,
            InformacaoBancaria__c = infoBancariaCorretor.Id
        );
        insert favorecidoRemuneracao;

		String origem = '18';

        Opportunity orcamento = new Opportunity(
			Name = 'Teste Contrato',
			StageName = 'Em criação',
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
			AccountId = pessoaFisica.Id,
			CloseDate = Date.today(),
			Origem__c = origem
		);
		insert orcamento;

        String numeroProposta = '00006767';

		Quote proposta = new Quote(
			Name = QuoteBO.getInstance().gerarNameProposta(origem, numeroProposta),
			NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem, numeroProposta),
			Produto__c = produtoComercial.Id,
			RamoSeguro__c = ramoSeguro.Id,
			Status = 'Em criação',
			VigenciaInicial__c = System.today(),
			VigenciaFinal__c = System.today().addMonths(1),
			Empresa__c = contaParceiro.Id,
			CodigoCorretor__c = dadosCorretor.Id,
			DataCalculo__c = System.today(),
			DataCriacaoPortal__c = System.today(),
			TipoVigencia__c = 'Anual',
			MeioComercializacao__c = 'PMC',
			OpportunityId = orcamento.Id,
			Origem__c = origem,
			Modalidade__c = modalidade.Id,
			NumeroProposta__c = numeroProposta,
			Parceiro__c = parceiro.Id,
			PremioTotal__c = 2387.58
        );
		insert proposta;

        GarantiaProposta__c garantiaProposta = new GarantiaProposta__c(
			Proposta__c = proposta.Id,
			GarantiaProduto__c = garantiaProdTec.Id,
			Garantia__c = garantiaProdTec.Garantia__c,
			TipoCapital__c = 'Capital uniforme'
        );
		insert garantiaProposta;

        ContratanteProposta__c segurado = new ContratanteProposta__c(
			conta__c = pessoaFisica.Id,
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
			Conta__c = pessoaFisica.Id,
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

		RemuneracaoProposta__c remuneracao = new RemuneracaoProposta__c(
			Proposta__c = proposta.Id,
			tipoRemuneracao__c = tipoRemuneracao.Id
		);
        insert remuneracao;

		FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c(
			RemuneracaoProposta__c = remuneracao.Id,
			Conta__c = contaCorretor.Id
		);
		insert favorecidoRemuneracaoProposta;

		String empresa = '14';
		String sucursal = '1';
        String numeroApolice = '000000014889';
        String endosso = '0';

        Contract contrato = new Contract(
			Name = ContractBO.getInstance().gerarNameContrato(empresa, sucursal, ramo, numeroApolice, endosso),
			Produto__c = produtoComercial.Id,
			NumeroApolice__c = numeroApolice,
			RamoSeguro__c = ramoSeguro.Id,
			Status = 'Em elaboração',
			Empresa__c = empresa,
			CodigoCorretor__c = dadosCorretor.Id,
			MeioComercializacao__c = 'PMC',
			Proposta__c = proposta.Id,
			Oportunidade__c = orcamento.Id,
			AccountId = pessoaFisica.Id,
			StartDate = System.today(),
			VigenciaFinal__c = System.today().addDays(30),
			DataEmissao__c = System.today(),
			Endosso__c = endosso,
			Sucursal__c = sucursal,
			CodigoRamo__c = ramo,
			Origem__c = origem,
			PremioComercial__c = 15000.00,
			Parceiro__c = '67708896000139',
			Tipo__c = 'Endosso',
			PremioTotal__c = 4879.68
        );
        insert contrato;

        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
			CurrencyIsoCode = 'BRL',
			Contrato__c = contrato.Id,
			Conta__c = pessoaFisica.Id,
			Tipo__c = 'Principal',
			QuantidadeParcelas__c = 1,
			VencimentoPrimeiraParcela__c = System.today().addDays(20),
			TipoResponsavelPagamento__c = 'PAR',
			IOF__c = 10,
			Logradouro__c = 'Rua xpto',
			NumeroEndereco__c = '55',
			Pais__c = 'Brasil',
			PremioComercial__c = 150,
			PremioPuro__c = 150,
			PremioTotal__c = 300,
			TaxaComercial__c = 0.10,
			TaxaPura__c =  0.10,
			TaxaTotal__c =  0.10,
			TipoEndereco__c = 'Comercial',
			TipoLogradouro__c = 'Rua'
		);
		insert contratanteContrato;

        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c seguradoContrato = TestDataFactory.gerarSeguradoContrato(grupoContrato, pessoaFisica);
        GarantiaContrato__c garantiaContrato = TestDataFactory.gerarGarantiaContrato(contrato, garantiaProdCom);
        GarantiaContratanteContrato__c garantiaContratanteContrato = TestDataFactory.gerarGarantiaContratanteContrato(garantia, contratanteContrato);
        GarantiaGrupoContrato__c garantiaGrupoContrato = TestDataFactory.gerarGarantiaGrupoContrato(garantia, grupoContrato);
        GarantiaSeguradoContrato__c garantiaSeguradoContrato = TestDataFactory.gerarGarantiaSeguradoContrato(garantia, seguradoContrato);
        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
	}
	//PLV-5128 - FIM
}