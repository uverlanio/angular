/*
PLV-4350 - CRIADO EM 12/11/2020
AUTOR: JEFERSON SANTANA
DESCRIÇÃO: TESTE SERVIÇO RETORNO RESPOSTA SAMPLEMED
*/
@IsTest
global class ServiceGarantiaPropostaTest {
	@testSetup 
    static void setup() {
		TestDataFactory.gerarDadosSetup();
        TestDataFactory.gerarContrato(true);      
    }
    global class ServiceGarantiaPropostaTestMethod implements HttpCalloutMock{
         global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            string body = 'sucesso';
       		res.setBodyAsBlob(Blob.valueOf(body));
            res.setBody('{"body":"sucesso"}');
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void testgarantiasPropostaLista() {
		String json = '{'+
		'    \"applicants\":'+
		'		{'+
		'            \"Applicant\": {'+
		'                \"address\": \"RUA TESTE\",'+
		'                \"birthday\": \"1978-10-12\",'+
		'                \"broker_agency_name\": \"TESTE\",'+
		'                \"city\": \"SAO PAULO\",'+
		'                \"codproposal\": \"18-00028537\",'+
		'                \"conclusion_questionnaire\": null,'+
		'                \"document_value\": \"123\",'+
		'                \"created\": \"2020-11-06 11:35:14\",'+
		'                \"email\": \"jefer.santana@gmail.com\",'+
		'                \"id\": \"38\",'+
		'                \"marital_status\": \"1\",'+
		'                \"name\": \"JEFERSON SANTANA\",'+
		'                \"neighborhood\": \"CENTRO\",'+
		'                \"observation\": \"TESTE DE PARA RESPONDER QUETIONARIO\",'+
		'                \"occupation\": \"ANALISTA DE SISTEMA\",'+
		'                \"phone1\": \"11999999999\",'+ // ANNVI-55 - INICIO/FIM
		'                \"phone2\": \"\",'+
		'                \"phone3\": \"\",'+
		'                \"questionnaire_status\": \"0\",'+
		'                \"rg_informed\": \"261476664\",'+
		'                \"salary\": \"100,00\",'+
		'                \"sex\": \"1\",'+
		'                \"state\": \"SP\",'+
		'                \"zip\": \"02500000\",'+
		'                \"age\": \"42\",'+
		'                \"created_formatted\": \"06/11/2020 11:35:14\",'+
		'                \"finished_date_formatted\": \"<i>Nenhum</i>\",'+
		'                \"interview_date_formatted\": \"<i>Nenhum</i>\",'+
		'                \"conclusion_questionnaire_formatted\": \"<i>Nenhum</i>\",'+
		'                \"birthday_formatted\": \"12/10/1978\",'+
		'                \"first_name\": \"JEFERSON\",'+
		'                \"questionnaire_status_label\": \"New\",'+
		'                \"score_result\": 0,'+
		'                \"status_progress\": \"new\",'+
		'                \"sla_stage\": 1'+
		'            },'+
		'            \"Questionnaire\": {'+
		'                \"name\": \"Questionário Validação\",'+
		'                \"id\": \"4\"'+
		'            },'+
		'            \"Answer\": [],'+
		'            \"ApplicantsProduct\": ['+
		'                {'+
		'                    \"capital_id\": \"1001\",'+
		'                    \"status\": \"1\",'+
		'                    \"value\": \"10.000,00\",'+
		'                    \"id\": \"41\",'+
		'                    \"applicant_id\": \"38\",'+
		'                    \"label\": \"Traslado de Corpo\",'+
		'					 \"id_on_origin\": \"IPA\",'+
		'					 \"medical_opinion\":\"observacao\",'+ //PLV-4350 - FIX1 - INICIO/FIM
		'                    \"ApplicantsProductsRule\": []'+
		'                },'+
		'                {'+
		'                    \"capital_id\": \"1002\",'+
		'                    \"status\": \"2\",'+ 
		'                    \"value\": \"10.000,00\",'+
		'                    \"id\": \"42\",'+
		'                    \"applicant_id\": \"38\",'+
		'                    \"label\": \"Morte Acidental\",'+
		'					 \"id_on_origin\": \"MA\",'+
		'					 \"medical_opinion\":\"observacao\",'+ //PLV-4350 - FIX1 - INICIO/FIM
		'                    \"ApplicantsProductsRule\": []'+
		'                },'+
		'                {'+
		'                    \"capital_id\": \"1003\",'+
		'                    \"status\": \"4\",'+ //PLV-4350 FIX 1
		'                    \"value\": \"10.000,00\",'+
		'                    \"id\": \"43\",'+
		'                    \"applicant_id\": \"38\",'+
		'                    \"label\": \"Acompanhante em caso de hospitalização prolongada\",'+
		'					 \"id_on_origin\": \"IPA\",'+
		'					 \"medical_opinion\":\"observacao\",'+ //PLV-4350 - FIX1 - INICIO/FIM
		'                    \"ApplicantsProductsRule\": []'+
		'                }'+
		'            ],'+
		'            \"Upload\": [],'+
		'			\"paging\": {'+
		'				\"page\": 2,'+
		'				\"current\": 8,'+
		'				\"count\": 38,'+
		'				\"prevPage\": true,'+
		'				\"nextPage\": false,'+
		'				\"pageCount\": 2,'+
		'				\"order\": [],'+
		'				\"limit\": 30'+
		'			}'+
		'		}'+
		'}';
		ServiceGarantiaProposta r = ServiceGarantiaProposta.parse(json);
		System.assert(r != null);
		
        Test.setMock(HttpCalloutMock.class, new ServiceGarantiaPropostaTestMethod());
        RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueOf(json);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ServiceGarantiaProposta/atualizaGarantia';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
       	//System.assert(res.responseBody != null);
        
        ServiceGarantiaProposta.Paging pagina = r.applicants.Paging;
        pagina.page = 1;
		pagina.current = 1;
		pagina.count = 1; 
		pagina.prevPage = true; 
		pagina.nextPage = true; 
		pagina.pageCount = 1; 
		//pagina.Answer; 
		pagina.limit_Z = 1; 

		ServiceGarantiaProposta.Applicant aplicant = r.applicants.Applicant;
		aplicant.address = 'centro';
		aplicant.birthday = '1990-01-10'; 
		aplicant.broker_agency_name = ''; 
		aplicant.city = ''; 
		aplicant.codproposal = ''; 
		aplicant.conclusion_questionnaire = null; 
		aplicant.document_value = ''; 
		aplicant.created = ''; 
		aplicant.email = ''; 
		aplicant.id = ''; 
		aplicant.marital_status = ''; 
		aplicant.name = ''; 
		aplicant.neighborhood = ''; 
		aplicant.observation = ''; 
		aplicant.occupation = ''; 
		aplicant.phone1 = ''; 
		aplicant.phone2 = ''; 
		aplicant.phone3 = ''; 
		aplicant.questionnaire_status = ''; 
		aplicant.rg_informed = ''; 
		aplicant.salary = ''; 
		aplicant.sex = ''; 
		aplicant.state = ''; 
		aplicant.zip = ''; 
		aplicant.age = ''; 
		aplicant.created_formatted = ''; 
		aplicant.finished_date_formatted = ''; 
		aplicant.interview_date_formatted = ''; 
		aplicant.conclusion_questionnaire_formatted = ''; 
		aplicant.birthday_formatted = ''; 
		aplicant.first_name = ''; 
		aplicant.questionnaire_status_label = ''; 
		aplicant.score_result = 1; 
		aplicant.status_progress = ''; 
        aplicant.sla_stage = 1; 

		ServiceGarantiaProposta.Questionnaire questionario = r.applicants.Questionnaire;
		questionario.name = ''; 
		questionario.id = null; 
		
		        
        ServiceGarantiaProposta.garantiasPropostaLista();
		
	}

	static testMethod void testgarantiasPropostaListaSemProduto() {
		String json = '{'+
		'    \"applicants\":'+
		'		{'+
		'            \"Applicant\": {'+
		'                \"address\": \"RUA TESTE\",'+
		'                \"birthday\": \"1978-10-12\",'+
		'                \"broker_agency_name\": \"TESTE\",'+
		'                \"city\": \"SAO PAULO\",'+
		'                \"codproposal\": \"18-00028537\",'+
		'                \"conclusion_questionnaire\": null,'+
		'                \"document_value\": \"123\",'+
		'                \"created\": \"2020-11-06 11:35:14\",'+
		'                \"email\": \"jefer.santana@gmail.com\",'+
		'                \"id\": \"38\",'+
		'                \"marital_status\": \"1\",'+
		'                \"name\": \"JEFERSON SANTANA\",'+
		'                \"neighborhood\": \"CENTRO\",'+
		'                \"observation\": \"TESTE DE PARA RESPONDER QUETIONARIO\",'+
		'                \"occupation\": \"ANALISTA DE SISTEMA\",'+
		'                \"phone1\": \"11999999999\",'+ // ANNVI-55 - INICIO/FIM
		'                \"phone2\": \"\",'+
		'                \"phone3\": \"\",'+
		'                \"questionnaire_status\": \"0\",'+
		'                \"rg_informed\": \"261476664\",'+
		'                \"salary\": \"100,00\",'+
		'                \"sex\": \"1\",'+
		'                \"state\": \"SP\",'+
		'                \"zip\": \"02500000\",'+
		'                \"age\": \"42\",'+
		'                \"created_formatted\": \"06/11/2020 11:35:14\",'+
		'                \"finished_date_formatted\": \"<i>Nenhum</i>\",'+
		'                \"interview_date_formatted\": \"<i>Nenhum</i>\",'+
		'                \"conclusion_questionnaire_formatted\": \"<i>Nenhum</i>\",'+
		'                \"birthday_formatted\": \"12/10/1978\",'+
		'                \"first_name\": \"JEFERSON\",'+
		'                \"questionnaire_status_label\": \"New\",'+
		'                \"score_result\": 0,'+
		'                \"status_progress\": \"new\",'+
		'                \"sla_stage\": 1'+
		'            },'+
		'            \"Questionnaire\": {'+
		'                \"name\": \"Questionário Validação\",'+
		'                \"id\": \"4\"'+
		'            },'+
		'            \"Answer\": [],'+
		'            \"ApplicantsProduct\": ['+
		'            ],'+
		'            \"Upload\": [],'+
		'			\"paging\": {'+
		'				\"page\": 2,'+
		'				\"current\": 8,'+
		'				\"count\": 38,'+
		'				\"prevPage\": true,'+
		'				\"nextPage\": false,'+
		'				\"pageCount\": 2,'+
		'				\"order\": [],'+
		'				\"limit\": 30'+
		'			}'+
		'		}'+
		'}';
		ServiceGarantiaProposta r = ServiceGarantiaProposta.parse(json);
		System.assert(r != null);
		
        Test.setMock(HttpCalloutMock.class, new ServiceGarantiaPropostaTestMethod());
        RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueOf(json);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ServiceGarantiaProposta/atualizaGarantia';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
       		        
        ServiceGarantiaProposta.garantiasPropostaLista();
	}
	@IsTest
	static void ServiceGarantiaPropostaTest() {  
		//II-42 FIXO1 INICIO
        List<ContratoTO.PayloadTO> payloadList = new List<ContratoTO.PayloadTO>();
        ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();
        payload.contrato = new ContratoTO();
        
        payload.contrato.segmento = '';
        payload.contrato.meioComercializacao = '';
        //payload.contrato.idSeguradoParceiro = '';
        payload.contrato.codigoEmpresa = '';
        payload.contrato.ramoSeguro = '';
        payload.contrato.vigenciaInicial = '';
        payload.contrato.tipoVigencia = '';
        payload.contrato.origem = 0;
        payload.contrato.tipoSeguro = '';
        payload.contrato.numeroEndosso = 0;
        payload.contrato.canalDistribuicao = '';
        payload.contrato.nomeEmpresa = '';
        payload.contrato.numero = '';
        payload.contrato.codigoSucursal = '';
        payload.contrato.nomeRamoSeguro = '';
        payload.contrato.vigenciaFinal = '';
        payload.contrato.valorPremio = 0.0;
        payload.contrato.idContratoParceiro = '';
        payload.contrato.dataCalculo = '';
        payload.contrato.numeroApolice = 0;
        payload.contrato.nomeProduto = '';
        payload.contrato.codigoProdutoVida = '';
        payload.contrato.parceiro = '';
        payload.contrato.numeroSusepProduto = '';
        payload.contrato.nomeCanalDistribuicao = '';
        
        payload.contrato.geracaoApolice = new ContratoTO.GeracaoapoliceTO();
        payload.contrato.geracaoApolice.unidadeNegocio = '';
        payload.contrato.geracaoApolice.nomeArquivoJasper = '';
        payload.contrato.geracaoApolice.leituraApartir = '';
        payload.contrato.geracaoApolice.centroDeCustoPagador = '';
        payload.contrato.geracaoApolice.tipoExtensaoGerada = '';
        payload.contrato.geracaoApolice.idAplicacaoUtilizadora = '';
        payload.contrato.geracaoApolice.nomeRelatorioGerado = '';
        payload.contrato.geracaoApolice.fileSystem = '';
        payload.contrato.geracaoApolice.nomeDiretorioArquivo = '';
        payload.contrato.geracaoApolice.assinaturaDiretor = '';
        
        payload.contrato.geracaoApolice.arquivo = new ContratoTO.ArquivoTO();
        payload.contrato.geracaoApolice.arquivo.textoInformativo = '';
        payload.contrato.geracaoApolice.arquivo.mensagemAssistenciaFuneral = '';
        payload.contrato.geracaoApolice.arquivo.exibirMensagemRenovacao  = '';
        payload.contrato.geracaoApolice.arquivo.mensagemProcessoSusep  = '';
        payload.contrato.geracaoApolice.arquivo.numeroProcessoSusepCNSP315  = '';
        payload.contrato.geracaoApolice.arquivo.unidadeOperacional  = '';
        
        payload.contrato.geracaoApolice.arquivo.observacoes = new ContratoTO.ObservacoesTO();
        payload.contrato.geracaoApolice.arquivo.observacoes.condicoesGerais = '';
        
        payload.contrato.geracaoApolice.arquivo.cabecalho = new ContratoTO.CabecalhoTO();
        payload.contrato.geracaoApolice.arquivo.cabecalho.image = ''; 
        
        payloadList.add(payload);
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payloadList), 200, 'OK'));
		//II-42 FIX01 FIM
		Test.startTest();     
		Quote proposta = [SELECT Id, NumeroPropostaUnico__c FROM Quote LIMIT 1];
		proposta.NumeroPropostaUnico__c = '123';
		upsert proposta;
		String numeroProposta = '123';
        Account conta = [SELECT Id FROM Account LIMIT 1];
        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
        // Apaga todos os contratantes da Proposta para gerar um novo
        List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id limit 1];
        delete listContratantePropostaParaDeletar;
        
        ContratanteProposta__c seguradoProposta = TestDataFactory.gerarContratanteProposta(conta,proposta,formaPagamento);
        List<ContratanteProposta__c> listContratanteProposta = [SELECT Id, Complemento__c FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id limit 1];
        ContratanteProposta__c contProposta = new ContratanteProposta__c();
        contProposta.Id = listContratanteProposta[0].Id;
        contProposta.Complemento__c = 'AAAA';
        update contProposta;
        
        
		
		RamoSeguro__c ramoVida = new RamoSeguro__c(
			Name = 'VIDA',
			CodigoEmpresa__c = '14',
			Codigo__c = '2',
			IdExterno__c = '14_2',
			Empresa__c = conta.Id,
			Status__c = 'Ativo',
			CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
		);
		insert ramoVida;

		RamoSeguro__c ramoMorte = new RamoSeguro__c(
			Name = 'Morte',
			CodigoEmpresa__c = '15',
			Codigo__c = '2',
			IdExterno__c = '15_2',
			Empresa__c = conta.Id,
			Status__c = 'Ativo',
			CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
		);
		insert ramoMorte;

		Modalidade__c modalidade1 = new Modalidade__c(
			RamoSeguro__c = ramoVida.Id,
			Name = 'Mod teste'
		);
		insert modalidade1;

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		garantia.Sigla__c = 'MA';
		insert garantia;

		RamoGarantia__c ramoGarantiaVida = new RamoGarantia__c(
			Garantia__c = garantia.Id,
			RamoSeguro__c = ramoVida.Id
			
		);
		insert ramoGarantiaVida;

		RamoGarantia__c ramoGarantiaMorte = new RamoGarantia__c(
			Garantia__c = garantia.Id,
			RamoSeguro__c = ramoMorte.Id
		);
		insert ramoGarantiaMorte;

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

		GarantiaProduto__c coberturaTec = new GarantiaProduto__c();
		coberturaTec.Garantia__c = garantia.Id;
		coberturaTec.Produto__c = produtoTec.Id; //
		coberturaTec.OrdemPrioridade__c = 1;
		coberturaTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
		coberturaTec.TipoCapital__c = 'Capital uniforme';
		coberturaTec.RamoSeguro__c = ramoVida.Id;
		coberturaTec.TipoGarantia__c = 'Cobertura';
		insert coberturaTec;

		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		LimiteGarantiaProduto__c limiteGarantiaProduto = (LimiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord();
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

		GarantiaProduto__c coberturaCom1 = new GarantiaProduto__c();
		coberturaCom1.GarantiaProduto__c = coberturaTec.Id;
		coberturaCom1.Garantia__c = garantia.Id;
		coberturaCom1.Produto__c = produtoCom.Id; //
		coberturaCom1.OrdemPrioridade__c = 1;
		coberturaCom1.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom1.TipoCapital__c = 'Capital uniforme';
		coberturaCom1.RamoSeguro__c = ramoVida.Id;
        coberturaCom1.TipoCaracteristicaEspecial__c = 'Cestas';
        coberturaCom1.LimiteMaximoCaracteristicaEspecial__c = 100;
        coberturaCom1.LimiteMinimoCaracteristicaEspecial__c = 10;
        coberturaCom1.TipoGarantia__c = 'Cobertura';
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		coberturaCom1.CurrencyIsoCode = 'BRL';
        coberturaCom1.LimiteCapitalMinimo__c = 10;
        coberturaCom1.LimiteCapitalMaximo__c = 100;
		
		coberturaCom1.CurrencyIsoCode = 'BRL';
        coberturaCom1.LimiteCapitalMinimo__c = 10;
        coberturaCom1.LimiteCapitalMaximo__c = 100;
	
		insert coberturaCom1;

		GarantiaProduto__c garantiaProduto = [select Id from GarantiaProduto__c limit 1];

		GarantiaProposta__c garantiaProposta = new GarantiaProposta__c();
		garantiaProposta.Garantia__c = garantia.Id;
		garantiaProposta.GarantiaProduto__c =  garantiaProduto.Id;
		garantiaProposta.Proposta__c = proposta.Id;   

		insert garantiaProposta;
		
		ServiceGarantiaProposta.ApplicantsProduct objSampleMed = new ServiceGarantiaProposta.ApplicantsProduct();
		objSampleMed.capital_id = '1001'; 
		objSampleMed.status = '1';
		objSampleMed.value = '';
		objSampleMed.id = '41';
		objSampleMed.applicant_id = '1' ;
		objSampleMed.label = 'Morte';
		objSampleMed.id_on_origin = 'MA';
		objSampleMed.medical_opinion = 'OBSERVACAO'; //PLV-4350 - FIX1 - INICIO/FIM
		
		List<ServiceGarantiaProposta.ApplicantsProduct> listGarantiasPropostas = new List<ServiceGarantiaProposta.ApplicantsProduct>();
		listGarantiasPropostas.add(objSampleMed);
		
		CriticaProposta__c critica = new CriticaProposta__c();
		critica.Proposta__c = proposta.Id;
		critica.Integracao__c = 'SAMPLE';
		critica.MomentoAnalise__c = 'Subscrição';
		insert critica;
		System.debug('criticaId: ' + critica.Id);

		//II-42 INICIO
		CriticaProposta__c criticaTeste = new CriticaProposta__c();
		criticaTeste.Proposta__c = proposta.Id;
		criticaTeste.Integracao__c = 'SAMPLE';
		criticaTeste.MomentoAnalise__c = 'Resseguro';
		insert criticaTeste;
		System.debug('criticaTesteId: ' + criticaTeste.Id);
		//II-42 FIM
	
		GarantiaPropostaBO objGarantia =  GarantiaPropostaBO.getInstance();
        objGarantia.atualizaGarantiasProposta(numeroProposta, listGarantiasPropostas);
        Test.stopTest();
		
	}

}