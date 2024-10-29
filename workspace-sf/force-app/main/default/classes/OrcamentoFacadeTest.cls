@isTest
private class OrcamentoFacadeTest {
	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
	}

	private static OrcamentoTO.PayloadTO gerarPayloadOrcamento() {        
		OrcamentoTO.PayloadTO payload = new OrcamentoTO.PayloadTO();
		OrcamentoTO orcamento = new OrcamentoTO();
		orcamento.solicitacaoOferta = new OrcamentoTO.SolicitacaoOfertaTO();
		orcamento.solicitacaoOferta.codigoProdutoVida = '201700001';
		orcamento.solicitacaoOferta.vigenciaInicial = System.today();
		orcamento.solicitacaoOferta.vigenciaFinal = System.today().addDays(1);
		orcamento.solicitacaoOferta.meioComercializacao = 'PPW'; //PLV-4550 INICIO/FIM
		orcamento.solicitacaoOferta.numeroPortal = '00012345';

		OrcamentoTO.PremioTO premio = new OrcamentoTO.PremioTO();
		premio.puro = 100;
		premio.puroDesconto = 100;
		premio.puroInterno = 10;
		premio.puroResseguro = 10;
		premio.comercial = 100;
		premio.comercialDesconto = 100;
		premio.total = 900;

		OrcamentoTO.TaxaTO taxa = new OrcamentoTO.TaxaTO();
		taxa.puroInterno = 1;
		taxa.puroResseguro = 1;
		taxa.comercial = 0.2;
		taxa.total = 90;

		OrcamentoTO.CoberturaTO cobertura = new OrcamentoTO.CoberturaTO();
		cobertura.sigla = 'CAP';
		cobertura.moeda = 'BRL';
		cobertura.premio = premio;
		cobertura.taxa = taxa;

		OrcamentoTO.DocumentoTO documento = new OrcamentoTO.DocumentoTO();
		documento.tipoDocumentoIdentidade = '';
		documento.orgaoExpedidorDocumento = 'SSP';
		documento.numeroDocumentoIdentidade = '234387659';
		documento.dataExpedicaoDocumento = System.today().addYears(-20);

		OrcamentoTO.DadosPessoaFisicaTO dadosPF = new OrcamentoTO.DadosPessoaFisicaTO();
		dadosPF.dataNascimento = System.today().addYears(-30);
		dadosPF.sexo = 'FEM';
		dadosPF.numeroCpf = '434457780';
		dadosPF.digitoCpf = '94';
		dadosPF.nacionalidade = 'BRA';
		dadosPF.estadoCivil = 'SOL';
		dadosPF.profissao = null; //PLV-3054 - Inicio/Fim - Ajuste na classe de teste
		dadosPF.pep = false;
		dadosPF.tipoRelacionamentoPep = '';
		dadosPF.documentos = new List<OrcamentoTO.DocumentoTO>{documento};

		OrcamentoTO.EnderecoTO endereco = new OrcamentoTO.EnderecoTO();
		endereco.tipoLogradouro = 'AV';
		endereco.tipoEndereco = 'RES';
		endereco.logradouro = 'Av Segurado';
		endereco.numeroLogradouro = '34';
		endereco.complemento = 'casa 4';
		endereco.bairro = 'Lotus';
		endereco.cidade = 'São Paulo';
		endereco.uf = 'SP';
		endereco.cep = '05890';
		endereco.complementoCep = '001';

		OrcamentoTO.TelefoneTO telefone = new OrcamentoTO.TelefoneTO();
		telefone.tipoTelefone = 'RES';
		telefone.dddTelefone = '11';
		telefone.numeroTelefone = '909869543';

		OrcamentoTO.PessoaTO pessoa = new OrcamentoTO.PessoaTO();
		pessoa.tipo = 'FIS';
		pessoa.nome = 'Maria do Socorro';
		pessoa.email = 'maria@socorro.com.br';
		pessoa.dadosPessoaFisica = dadosPF; 
		pessoa.enderecos = new List<OrcamentoTO.EnderecoTO>{endereco};
		pessoa.telefones = new List<OrcamentoTO.TelefoneTO>{telefone};

		OrcamentoTO.SeguradoTO segurado = new OrcamentoTO.SeguradoTO();
		segurado.coberturas = new List<OrcamentoTO.CoberturaTO>{cobertura};
		segurado.pessoa = pessoa;
		segurado.premio = premio;
		segurado.taxa = taxa;

		OrcamentoTO.GrupoTO grupo = new OrcamentoTO.GrupoTO();
		grupo.coberturas = new List<OrcamentoTO.CoberturaTO>{cobertura};
		grupo.segurados = new List<OrcamentoTO.SeguradoTO>{segurado};
		grupo.premio = premio;
		grupo.taxa = taxa;

		OrcamentoTO.ContratanteTO contratante = new OrcamentoTO.ContratanteTO();
		contratante.tipo = 'PRI';
		contratante.pessoa = pessoa;
		contratante.coberturas = new List<OrcamentoTO.CoberturaTO>{cobertura};
		contratante.grupos = new List<OrcamentoTO.GrupoTO>{grupo};
		contratante.premio = premio;
		contratante.taxa = taxa;
		
		OrcamentoTO.IndiceMonetarioTO indice = new OrcamentoTO.IndiceMonetarioTO();	
		indice.moeda = 'BRL';
		indice.valor = 1000;

		OrcamentoTO.MensagemTO mensagens = new OrcamentoTO.MensagemTO();
		mensagens.cliente = 'teste';
		mensagens.interna = 'teste';
		mensagens.representante = 'teste';

		OrcamentoTO.StatusTO errosRetorno = new OrcamentoTO.StatusTO();
		errosRetorno.mensagens = mensagens;
		errosRetorno.codigo = 0;
		errosRetorno.origem = 'ODM';
		errosRetorno.area = 'teste';
		errosRetorno.descricao = 'teste';
		errosRetorno.procedimento = 'teste';
		errosRetorno.severidade = 1;
		errosRetorno.quantidade = 1;
		errosRetorno.status = 'teste';

		OrcamentoTO.RetornoAceitacaoTO retornoAceitacao = new OrcamentoTO.RetornoAceitacaoTO();
		retornoAceitacao.avisos = new List<OrcamentoTO.StatusTO>{errosRetorno};
		retornoAceitacao.analises = new List<OrcamentoTO.StatusTO>{errosRetorno};
		retornoAceitacao.recusas = new List<OrcamentoTO.StatusTO>{errosRetorno};
		retornoAceitacao.pendencias = new List<OrcamentoTO.StatusTO>{errosRetorno};

		OrcamentoTO.AgenteTO agente = new OrcamentoTO.AgenteTO();
		agente.papel = 'COR';
		agente.corretagem = 10;
		agente.susep = '54545';
		agente.susepEmissao = '54545';
		agente.susepOrcamento = '54545';
		agente.agenciamento = 10;
		agente.proLabore = 10;
		agente.assessoria = 10;
		agente.comissao = 10;
		agente.pessoa = pessoa;

		OrcamentoTO.RemuneracaoTO remuneracao = new OrcamentoTO.RemuneracaoTO();
		remuneracao.canal = 'EXE';
		remuneracao.agentes = new List<OrcamentoTO.AgenteTO>{agente};

		orcamento.indiceMonetario = new List<OrcamentoTO.IndiceMonetarioTO>{indice};
		orcamento.retornoAceitacao = retornoAceitacao;
		orcamento.solicitacaoOferta.numeroOrcamento = '123';
		orcamento.solicitacaoOferta.meioComercializacao = 'PPW'; 
		orcamento.solicitacaoOferta.numeroPortal = '767';
		orcamento.solicitacaoOferta.tipoSeguro = 'NOV';
		orcamento.solicitacaoOferta.contratantes = new List<OrcamentoTO.ContratanteTO>{Contratante};
		orcamento.solicitacaoOferta.remuneracao = remuneracao;
	
		OrcamentoTO.PrecificacaoTO precificacao = new OrcamentoTO.PrecificacaoTO();
		precificacao.juros = 10;
		precificacao.iof = 10;
		precificacao.encargos = 10;
		precificacao.custoApolice = 500;
		precificacao.coberturas = new List<OrcamentoTO.CoberturaTO>{cobertura}; 
		precificacao.premio = premio;
		precificacao.taxa = taxa;
		precificacao.contratantes = new List<OrcamentoTO.ContratanteTO>{Contratante};

		OrcamentoTO.CalculoTO calculo = new OrcamentoTO.CalculoTO();
		calculo.precificacao = precificacao;

		orcamento.oferta = new OrcamentoTO.OfertaTO();
		orcamento.oferta.calculo = calculo;

		payload.orcamentos = new List<OrcamentoTO>{orcamento};

		return payload;
	}

	@isTest
	private static void coberturaDAO() {
		// PLV-2312-28 INICIO
		Map<String,List<SObject>> mapListObject = TestDataFactory.gerarOrcamento(false);
		// PLV-2312-28 FIM
	
		SeguradoOrcamento__c segurado = (SeguradoOrcamento__c)TestDataFactory.pegarRegistro(mapListObject, 'SeguradoOrcamento__c');
		GarantiaOrcamento__c garantiaOrc = (GarantiaOrcamento__c)TestDataFactory.pegarRegistro(mapListObject, 'GarantiaOrcamento__c');
		GrupoOrcamento__c grupoOrc = (GrupoOrcamento__c)TestDataFactory.pegarRegistro(mapListObject, 'GrupoOrcamento__c');
		ContratanteOrcamento__c ContratanteOrc = (ContratanteOrcamento__c)TestDataFactory.pegarRegistro(mapListObject, 'ContratanteOrcamento__c');
		
		GarantiaGrupoOrcamentoDAO dao1 = GarantiaGrupoOrcamentoDAO.getInstance();
		GarantiaOrcamentoDAO dao2 = GarantiaOrcamentoDAO.getInstance();
		GrupoOrcamentoDAO dao3 = GrupoOrcamentoDAO.getInstance();
		SeguradoOrcamentoDAO dao4 = SeguradoOrcamentoDAO.getInstance();
		ContratanteOrcamentoDAO dao5 = ContratanteOrcamentoDAO.getInstance();

		//dao1.listaGarantiasSegurado(new Set<Id>{segurado.Id});
		dao2.listarGarantiasOrcamento(new Set<Id>{garantiaOrc.Id});
		dao3.listarGrupoOrcamento(new Set<Id>{grupoOrc.Id});
		dao4.listarSeguradoOrcamento(new Set<Id>{segurado.Id});
		dao5.buscarContratantesPrincipaisPorOrcamento(new Set<Id>{ContratanteOrc.Id});
	}

	@isTest
	private static void testarGerarNovoOrcamento() {
		Map<String,List<SObject>> mapListObject = TestDataFactory.gerarProdutoComercialAtivo(false);
		
		// Pega dados do produto comercial
		Product2 produtoComercial = (Product2) TestDataFactory.pegarRegistro(mapListObject, 'Product2');
        Account conta = (Account)TestDataFactory.pegarRegistro(mapListObject, 'Account');
        Garantia__c garantia = (Garantia__c)TestDataFactory.pegarRegistro(mapListObject, 'Garantia__c');

        GarantiaProduto__c garantiaProduto = (GarantiaProduto__c)TestDataFactory.pegarRegistro(mapListObject, 'GarantiaProduto__c');
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c)TestDataFactory.pegarRegistro(mapListObject, 'TipoRemuneracao__c');
        TipoRemuneracao__c tipoRemuneracaoParaCanal = TestDataFactory.gerarTipoRemuneracao();

        // geracao do orcamento
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao,produtoComercial);
        RemuneracaoProduto__c remuneracaoProduto = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracaoParaCanal);
        RemuneracaoCanal__c remuneracaoCanal = TestDataFactory.gerarRemuneracaoCanal(produtoCanal, tipoRemuneracaoParaCanal);

        // Ativa o Canal de Distribuicao
        canalDistribuicao.Status__c = 'Ativo';
        update  canalDistribuicao;

		OrcamentoTO.PayloadTO payload = gerarPayloadOrcamento();

		//Novo orçamento
		OrcamentoFacade.getInstance().gerarOrcamento(JSON.serialize(payload));
		//OrcamentoDirector.getInstance().processarOrcamento(JSON.serialize(payload));

		OrcamentoFacadeTest.chamarRestOrcamento(JSON.serialize(payload));

		String numeroOrcamento = payload.orcamentos[0].solicitacaoOferta.meioComercializacao + '-' + payload.orcamentos[0].solicitacaoOferta.numeroPortal;
		Opportunity orcamento = [SELECT Id, Name FROM Opportunity WHERE Name =: numeroOrcamento Limit 1];

		System.assertEquals(numeroOrcamento, orcamento.Name); 
	}

	@isTest
	private static void testarCancelamentoOrcamento() {
	// PLV-2312-28 INICIO
        Map<String,List<SObject>> mapListObject = TestDataFactory.gerarContrato(true);
	// PLV-2312-28 FIM

		OrcamentoTO.PayloadTO payload = gerarPayloadOrcamento();
		payload.orcamentos[0].solicitacaoOferta.apolice = '14889';
		payload.orcamentos[0].solicitacaoOferta.tipoSeguro = 'CAN';
		executarCancelamento(JSON.serialize(payload));
		executarCancelamentoOferta(JSON.serialize(payload.orcamentos[0]));
	}

	@future
	private static void executarCancelamento(String payload) {
		try {
			OrcamentoFacade.getInstance().gerarOrcamento(payload);	
		} catch(Exception ex) {
			System.debug(ex.getMessage());
		}	
	}

	@future
	private static void executarCancelamentoOferta(String payload) {
		try {
			OrcamentoFacade.getInstance().gerarOrcamentoCancelamento((OrcamentoTO)JSON.deserialize(payload, OrcamentoTO.class));	
		} catch(Exception e) {
			System.debug(e.getMessage());
		}
	}

	private static void chamarRestOrcamento(String payload) {
        RestRequest postRequest = new RestRequest();
        postRequest.requestURI = '/services/apexrest/orcamento';
        postRequest.requestBody = Blob.valueOf(payload);
        postRequest.httpMethod = 'POST';
        postRequest.addHeader('Content-Type', 'application/json');
        RestContext.request = postRequest;
        RestContext.response =  new RestResponse();

		OrcamentoREST.processarPost();
		
		OrcamentoFacadeTest.chamarRestOrcamentoSugestaoMock(payload);
	}

	//PLV-3667 - INICIO - Aumentar cobertura de testes
	private static void chamarRestOrcamentoSugestaoMock(String payload) {
        RestRequest postRequest = new RestRequest();
        postRequest.requestURI = '/services/apexrest/orcamento/sugestao/mock';
        postRequest.requestBody = Blob.valueOf(payload);
        postRequest.httpMethod = 'POST';
        postRequest.addHeader('Content-Type', 'application/json');
        RestContext.request = postRequest;
        RestContext.response =  new RestResponse();

		OrcamentoREST.processarPost();
		
		OrcamentoFacadeTest.chamarRestOrcamentoMock(payload);
	}

	private static void chamarRestOrcamentoMock(String payload) {
        RestRequest postRequest = new RestRequest();
        postRequest.requestURI = '/services/apexrest/orcamento/mock';
        postRequest.requestBody = Blob.valueOf(payload);
        postRequest.httpMethod = 'POST';
        postRequest.addHeader('Content-Type', 'application/json');
        RestContext.request = postRequest;
        RestContext.response =  new RestResponse();

		OrcamentoREST.processarPost();

		OrcamentoFacadeTest.chamarRestOrcamentoCivCalculo(payload);
	}

	private static void chamarRestOrcamentoCivCalculo(String payload) {
        RestRequest postRequest = new RestRequest();
        postRequest.requestURI = '/services/apexrest/orcamento/civcalculo';
        postRequest.requestBody = Blob.valueOf(payload);
        postRequest.httpMethod = 'POST';
        postRequest.addHeader('Content-Type', 'application/json');
        RestContext.request = postRequest;
        RestContext.response =  new RestResponse();

		OrcamentoREST.processarPost();

		OrcamentoFacadeTest.chamarRestOrcamentoGravar(payload);
	}

	private static void chamarRestOrcamentoGravar(String payload) {
        RestRequest postRequest = new RestRequest();
        postRequest.requestURI = '/services/apexrest/orcamento/gravarorcamentos';
        postRequest.requestBody = Blob.valueOf(payload);
        postRequest.httpMethod = 'POST';
        postRequest.addHeader('Content-Type', 'application/json');
        RestContext.request = postRequest;
        RestContext.response =  new RestResponse();

		OrcamentoREST.processarPost();

		OrcamentoFacadeTest.chamarRestOrcamentoGerarDadosIniciais(payload);
	}

	private static void chamarRestOrcamentoGerarDadosIniciais(String payload) {
        RestRequest postRequest = new RestRequest();
        postRequest.requestURI = '/services/apexrest/orcamento/gerarDadosIniciais';
        postRequest.requestBody = Blob.valueOf(payload);
        postRequest.httpMethod = 'POST';
        postRequest.addHeader('Content-Type', 'application/json');
        RestContext.request = postRequest;
        RestContext.response =  new RestResponse();

		OrcamentoREST.processarPost();		
	}
	//PLV-3667 - FIM - Aumentar cobertura de testes
}