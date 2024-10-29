/***
* Created: Jeferson Santana (Sys4b)
* Date: 2023-04-28
* Description: Class that runTest: PepTO, PepBO, BatchPep, BatchCreateFileReportMegaDay, SeguradoPropostaTriggerHandler, BeneficiarioSeguradoPropostaHandler, SensediaService, Ultis
* task-History : PMH-24
***/ 
@isTest
public with sharing class BatchCreateFileReportMegaDayTest {

    public @TestSetup
    static void makeData(){
        Test.startTest(); //INICIO/FIM - LECVPV-218
        Account contaTeste = TestDataFactory.gerarConta();
        //DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        Account contaCorretor = new Account(Name = 'ContaCorretor', Papel__c = 'Corretor', IdExterno__c = '38012786532', Cnpj__c = '38.579.897/0001-22');       
        insert contaCorretor; 
        Account contaCorretorTest = [SELECT Id,Name FROM Account  WHERE Papel__c = 'Corretor' LIMIT 1];
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaCorretorTest);

        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        update produtoCom;

        GarantiaProduto__c garantiaProdutoTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);
        GarantiaProduto__c garantiaProdutoCom = TestDataFactory.gerarGarantiaProdutoTecnico(produtoCom, garantia1, ramoSegurado);
        Questionario__c questionarioProdCom = TestDataFactory.gerarQuestionario();
        QuestionarioProduto__c questionarioProduto = TestDataFactory.gerarQuestionarioProduto(questionarioProdCom, produtoCom, garantiaProdutoCom);

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('CORRETAGEM', 100, 200, null);
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantia1, orcamentoContratado);   
        RemuneracaoOrcamento__c remuneracaoOrcamento = TestDataFactory.gerarRemuneracaoOrcamento(orcamentoContratado, tipoRemuneracao);
        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamentoContratado, contaTeste);
        GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);
        SeguradoOrcamento__c seguradoOrcamento = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamento);
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        
        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta('18','00326342'),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18','00326342'),
                Produto__c = produtoCom.Id,
                RamoSeguro__c = ramoSegurado.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = contaTeste.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC',
                OpportunityId = orcamentoContratado.Id,
                Origem__c = '18',
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = '00326342',
                Parceiro__c = '49546324000119',
                Tipo__c = 'Renovacao',
                DataProtocolo__c = System.Date.today(),
            	PremioTotal__c = 10
        );
        insert proposta;
        GarantiaProposta__c garantiaProposta = TestDataFactory.gerarGarantiaProposta(proposta, garantiaProdutoTec);
        RemuneracaoProposta__c remuneracaoProposta = TestDataFactory.gerarRemuneracaoProposta(proposta, tipoRemuneracao);
        ContratanteProposta__c contratanteProposta = TestDataFactory.gerarContratanteProposta(contaTeste, proposta, formaPagamento);
        GrupoProposta__c grupoProposta = TestDataFactory.gerarGrupoProposta(contratanteProposta);
        //INICIO - LECVPV-218
        //SeguradoProposta__c seguradoProposta = TestDataFactory.gerarSeguradoProposta(contaTeste, grupoProposta, formaPagamento);
        
        //BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta = TestDataFactory.gerarBeneficiarioSeguradoProposta(contaTeste, seguradoProposta);
        //FIM  - LECVPV-218
        
        //FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = gerarFavorecidoRemuneracaoProposta(contaTeste, remuneracaoProposta, dadosCorretor);
        insert new FavorecidoRemuneracaoProposta__c (RemuneracaoProposta__c = remuneracaoProposta.Id, Conta__c = contaTeste.Id);

        /*Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta);
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.Proposta__c = proposta.Id;
        update contrato;*/ 	

        String str = '18|00326342';
		ContentVersion file = new ContentVersion(
			Title = 'ReportMegaDay',
			VersionData = Blob.valueOf(str),
			PathOnClient = 'ReportMegaDay.txt',
			origin = 'H'
		);
		insert file;
        Test.stopTest();
    }
    @isTest
    public static void testBatch() {
        //INICIO - LECVPV-218
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new CreateServiceMock());
        PepBO.getInstance().processoPep = true;
        Id contaId = [SELECT Id FROM Account LIMIT 1][0].Id;
        SeguradoProposta__c SeguradoProposta = new SeguradoProposta__c(
                Conta__c = contaId,
                ResponsavelPagamento__c = contaId,
                FormaPagamento__c = [SELECT Id FROM FormaPagamento__c LIMIT 1][0].Id,
                PremioTotal__c = 10,
                GrupoProposta__c = [SELECT Id FROM GrupoProposta__c LIMIT 1][0].Id,
                EnderecoBoleto__c = 'http://www.google.com.br',
                PremioComercial__c = 10,
                IOF__c = 1,
                Numero__c = 1
        );

        insert SeguradoProposta;

        BeneficiarioSeguradoProposta__c beneficiarioSeguradoproposta = new BeneficiarioSeguradoProposta__c(
                 Conta__c = contaId,
                 Nome__c = 'Teste',
                 NomePessoaPep__c = 'Teste',
                 SeguradoProposta__c = SeguradoProposta.Id,
                 TipoBeneficiario__c = 'Nome do beneficiário',
                 Participacao__c = 100,
                 MotivoSemCpfCnpj__c = 'Não desejo informar',
                 GrauParentesco__c = 'Cônjuge',
                 Pep__c = 'Sim',
                 CpfCnpj__c = '8701122797'
         );
         insert beneficiarioSeguradoproposta;
        //Test.StartTest();
        //FIM - LECVPV-218
        
        
        datetime mydate = Datetime.now();
        DateTime newDateTime = mydate.addMinutes(5);
        Integer day = newDateTime.day();
        Integer moth = newDateTime.month();
        Integer year = newDateTime.year();
        Integer hours = newDateTime.hour();
        Integer minute = newDateTime.minute();
        String param = '0 '+minute+' '+hours+' '+day+' '+moth+' ? '+year+'';
        BatchCreateFileReportMegaDay ba = new BatchCreateFileReportMegaDay(System.Date.today(),System.Date.today());
        //ba.query = 'SELECT ID, Name, Origem__c,  NumeroProposta__c, Status, produto__r.name, PremioTotal__c, DataProtocolo__c, LastModifiedDate FROM Quote where Tipo__c = \'Renovacao\'';
        ID batchprocessid = Database.executeBatch(ba);
        
        SchedulerCreateFileReportmagaDay.schedulerBatchReportMegaDay(param, System.Date.today(),System.Date.today());
        Test.StopTest();
      
        System.AssertEquals(database.countquery('SELECT COUNT() FROM Quote'),1);  
        
    }
    //INICIO - LECVPV-218
    static testMethod void testPepTO() {
        PepTO pep = new PepTO();
        pep.mensagemRetorno = 'ok';
        PepTO.ListaRelacionada pepListaRelacionada = new PepTO.ListaRelacionada();
        PepTO.PessoaRelacionadaPEPWS pepListaRelacionadapepws = new PepTO.PessoaRelacionadaPEPWS();
        PepTO.PessoaRelacionadaPEPWS_Z pepListaRelacionadapepwsz = new PepTO.PessoaRelacionadaPEPWS_Z();
        PepTO.PessoaRelacionadaPEPWS_Y pepListaRelacionadapepwsy = new PepTO.PessoaRelacionadaPEPWS_Y();
        PepTO.PessoaRelacaoPEPs pessoasRelacao = new PepTO.PessoaRelacaoPEPs();
        PepTO.PessoaRelacaoPEPs_Z pessoasRelacaoZ = new PepTO.PessoaRelacaoPEPs_Z();
        List<PepTO.PessoaRelacaoPEPs> listaPessoasRelacao = new List<PepTO.PessoaRelacaoPEPs>();
        pessoasRelacao.dataAtualizacao = 'teste';
		pessoasRelacao.descricaoRelacionamento = 'teste';
        listaPessoasRelacao.add(pessoasRelacao);
		pessoasRelacaoZ.dataAtualizacao = 'teste';
		pessoasRelacaoZ.descricaoRelacionamento = 'teste';

        pepListaRelacionada.codigoDDD = 11;
        pepListaRelacionada.codigoPessoaRelacionada = 1;
        pepListaRelacionada.siglaUF= 'teste';
		pepListaRelacionada.descricaoEmail= 'teste';
		pepListaRelacionada.flagExclusao= 'teste';
		pepListaRelacionada.nomeLogradouro= 'teste';
		pepListaRelacionada.tipoPessoa= 1;
		pepListaRelacionada.complementoLogradouro= 'teste';
		pepListaRelacionada.nomeBairro= 'teste';
		pepListaRelacionada.nomeCidade= 'teste';
		pepListaRelacionada.numeroTelefone= 1;
		pepListaRelacionada.numeroCepInicial= 1;
		pepListaRelacionada.siglaSexo= 1;
		pepListaRelacionada.numeroCepComplemento= 1;
		pepListaRelacionada.codigoPessoaRelacionada= 1;
		//public List<PessoaRelacaoPEPs> pessoaRelacaoPEPs= 'teste';
		pepListaRelacionada.dataAtualizacao= 'teste';
		pepListaRelacionada.nomePessoaRelacionada= 'teste';
		//public Long numeroCPF= 'teste';
		pepListaRelacionada.dataNascimento= 'teste';
		pepListaRelacionada.numeroRamal= 1;
		pepListaRelacionada.codigoDDD= 1;
		pepListaRelacionada.codigoSituacao= 1;
		pepListaRelacionada.numeroLogradouro= 1;
        pep.listaRelacionada = pepListaRelacionada;

        pepListaRelacionadapepws.siglaUF = 'teste';
		pepListaRelacionadapepws.descricaoEmail = 'teste';
		pepListaRelacionadapepws.flagExclusao = 'teste';
		pepListaRelacionadapepws.nomeLogradouro = 'teste';
		pepListaRelacionadapepws.tipoPessoa = 1;
		pepListaRelacionadapepws.complementoLogradouro = 'teste';
		pepListaRelacionadapepws.nomeBairro = 'teste';
		pepListaRelacionadapepws.nomeCidade = 'teste';
		pepListaRelacionadapepws.numeroTelefone = 1;
		pepListaRelacionadapepws.numeroCepInicial = 1;
		pepListaRelacionadapepws.siglaSexo = 1;
		pepListaRelacionadapepws.numeroCepComplemento = 'teste';
		pepListaRelacionadapepws.codigoPessoaRelacionada = 1;
		pepListaRelacionadapepws.dataAtualizacao = 'teste';
		pepListaRelacionadapepws.nomePessoaRelacionada = 'teste';
		//public Long numeroCPF = 'teste';
		pepListaRelacionadapepws.dataNascimento = 'teste';
		pepListaRelacionadapepws.numeroRamal = 1;
		pepListaRelacionadapepws.codigoDDD = 1;
		pepListaRelacionadapepws.codigoSituacao = 1;
		pepListaRelacionadapepws.numeroLogradouro = 1;

        pepListaRelacionadapepwsz.siglaUF = 'teste';
		pepListaRelacionadapepwsz.descricaoEmail = 'teste';
		pepListaRelacionadapepwsz.flagExclusao = 'teste';
		pepListaRelacionadapepwsz.nomeLogradouro = 'teste';
		pepListaRelacionadapepwsz.tipoPessoa = 1;
		pepListaRelacionadapepwsz.complementoLogradouro = 'teste';
		pepListaRelacionadapepwsz.nomeBairro = 'teste';
		pepListaRelacionadapepwsz.nomeCidade = 'teste';
		pepListaRelacionadapepwsz.numeroTelefone = 1;
		pepListaRelacionadapepwsz.numeroCepInicial = 1;
		pepListaRelacionadapepwsz.numeroCepComplemento = 'teste';
		pepListaRelacionadapepwsz.codigoPessoaRelacionada = 1;
		pepListaRelacionadapepwsz.dataAtualizacao = 'teste';
		pepListaRelacionadapepwsz.nomePessoaRelacionada = 'teste';
		//public Long numeroCPF = 'teste';
		pepListaRelacionadapepwsz.dataNascimento = 'teste';
		pepListaRelacionadapepwsz.numeroRamal = 1;
		pepListaRelacionadapepwsz.codigoDDD = 1;
		pepListaRelacionadapepwsz.codigoSituacao = 1;
		pepListaRelacionadapepwsz.numeroLogradouro = 1;
        
        pepListaRelacionadapepwsy.siglaUF = 'teste';
		pepListaRelacionadapepwsy.descricaoEmail = 'teste';
		pepListaRelacionadapepwsy.flagExclusao = 'teste';
		pepListaRelacionadapepwsy.nomeLogradouro = 'teste';
		pepListaRelacionadapepwsy.tipoPessoa = 1;
		pepListaRelacionadapepwsy.complementoLogradouro = 'teste';
		pepListaRelacionadapepwsy.nomeBairro = 'teste';
		pepListaRelacionadapepwsy.nomeCidade = 'teste';
		pepListaRelacionadapepwsy.numeroTelefone = 1;
		pepListaRelacionadapepwsy.numeroCepInicial = 1;
		pepListaRelacionadapepwsy.siglaSexo = 1;
		pepListaRelacionadapepwsy.numeroCepComplemento = 1;
		pepListaRelacionadapepwsy.codigoPessoaRelacionada = 1;
		pepListaRelacionadapepwsy.dataAtualizacao = 'teste';
		pepListaRelacionadapepwsy.nomePessoaRelacionada = 'teste';
		//public Long numeroCPF = 'teste';
		pepListaRelacionadapepwsy.dataNascimento = 'teste';
		pepListaRelacionadapepwsy.numeroRamal = 1;
		pepListaRelacionadapepwsy.codigoDDD = 1;
		pepListaRelacionadapepwsy.codigoSituacao = 1;
		pepListaRelacionadapepwsy.numeroLogradouro = 1;

        PepTO.MandatoPEPs mandato = new PepTO.MandatoPEPs();
        mandato.dataCarga = 'teste';
        mandato.dataExoneracao = 'teste';
        //public CargoPEPWS cargoPEPWS = 'teste';
        mandato.dataAtualizacao = 'teste';
        mandato.descricaoMotivoExoneracao = 'teste';
        //public OrgaoPEPWS orgaoPEPWS = 'teste';    

        PepTO.OrgaoPEPWS orgao = new PepTO.OrgaoPEPWS();
        orgao.nomeOrgao = 'teste';
        orgao.siglaUF = 'teste';
        orgao.descricaoEmail = 'teste';
        orgao.nomeLogradouro = 'teste';
        orgao.codigoOrgao = 1;
        orgao.complementoLogradouro = 'teste';
        orgao.nomeBairro = 'teste';
        orgao.nomeCidade = 'teste';
        orgao.numeroTelefone = 1;
        orgao.numeroCepInicial = 1;
        orgao.numeroCepComplemento = 1;
        orgao.numeroCNPJ = 1;
        orgao.dataAtualizacao = 'teste';
        orgao.siglaOrgaoSuperior = 'teste';
        orgao.numeroRamal = 1;
        orgao.codigoDDD = 1;
        orgao.numeroLogradouro = 1;
    
        PepTO.ListaPessoa lpessoa = new PepTO.ListaPessoa();
        lpessoa.siglaUF = 'teste';
        lpessoa.descricaoEmail = 'teste';
        lpessoa.flagExclusao = 'teste';
        lpessoa.nomeLogradouro = 'teste';
        lpessoa.complementoLogradouro = 'teste';
        lpessoa.nomePEP = 'teste';
        lpessoa.nomeBairro = 'teste';
        lpessoa.nomeCidade = 'teste';
        lpessoa.numeroTelefone = 1;
        lpessoa.numeroCepInicial = 1;
        lpessoa.siglaSexo = 1;
        lpessoa.numeroCepComplemento = 1;
        lpessoa.dataAtualizacao = 'teste';
        lpessoa.codigoPEP = 1;
        lpessoa.codigoStatus = 1;
        lpessoa.tipoPEP = 'teste';
        lpessoa.dataNascimento = 'teste';
        lpessoa.numeroRamal = 1;
        lpessoa.codigoDDD = 1;
        lpessoa.codigoSituacao = 1;
        lpessoa.numeroLogradouro = 1;

        PepTO.PessoaRelacionadaPEPWS_W pessoaR = new PepTO.PessoaRelacionadaPEPWS_W();
        pessoaR.flagExclusao = 'teste';
        pessoaR.dataAtualizacao = 'teste';
        pessoaR.nomePessoaRelacionada = 'teste';
        pessoaR.numeroTelefone = 1;
        pessoaR.numeroRamal = 1;
        pessoaR.codigoDDD = 1;
        pessoaR.codigoPessoaRelacionada = 1;
        pessoaR.codigoSituacao = 1;
        pessoaR.numeroLogradouro = 1;    

        PepTO.PessoaPEPWS pessoaw = new PepTO.PessoaPEPWS();
        pessoaw.siglaUF = 'teste';
        pessoaw.descricaoEmail = 'teste';
        pessoaw.flagExclusao = 'teste';
        pessoaw.nomeLogradouro = 'teste';
        pessoaw.complementoLogradouro = 'teste';
        pessoaw.nomePEP = 'teste';
        pessoaw.nomeBairro = 'teste';
        pessoaw.nomeCidade = 'teste';
        pessoaw.numeroTelefone = 1;
            
        pessoaw.numeroCepInicial = 1;
        pessoaw.siglaSexo = 1;
        pessoaw.numeroCepComplemento = 1;
        pessoaw.dataAtualizacao = 'teste';
        pessoaw.codigoPEP = 1;
        pessoaw.codigoStatus = 1;
        pessoaw.tipoPEP = 'teste';
        pessoaw.dataNascimento = 'teste';
        pessoaw.numeroRamal = 1;
        pessoaw.codigoDDD = 1;
        pessoaw.codigoSituacao = 1;
        pessoaw.numeroLogradouro = 1;
       
	}

    

    private class CreateServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            String json = '{'+
            '    \"mensagemRetorno\": \"OK\",'+
            '    \"listaRelacionada\": {'+
            '        \"siglaUF\": \"RJ\",'+
            '        \"descricaoEmail\": \"\",'+
            '        \"flagExclusao\": \"A\",'+
            '        \"nomeLogradouro\": \"R DIVISORIA\",'+
            '        \"tipoPessoa\": 70,'+
            '        \"complementoLogradouro\": \"C XV\",'+
            '        \"nomeBairro\": \"BENTO RIBEIRO\",'+
            '        \"nomeCidade\": \"RIO DE JANEIRO\",'+
            '        \"numeroTelefone\": 0,'+
            '        \"numeroCepInicial\": 21331,'+
            '        \"siglaSexo\": 77,'+
            '        \"numeroCepComplemento\": 250,'+
            '        \"codigoPessoaRelacionada\": 90072015,'+
            '        \"pessoaRelacaoPEPs\": ['+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"RELACAO COMERCIAL\",'+
            '                \"pessoaPEPWS\": {'+
            '                    \"siglaUF\": \"\",'+
            '                    \"descricaoEmail\": \"GUSTAVO@CORDEIROEBOTTO.COM\",'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"nomeLogradouro\": \"\",'+
            '                    \"complementoLogradouro\": \"\",'+
            '                    \"nomePEP\": \"FLAVIO NANTES BOLSONARO\",'+
            '                    \"nomeBairro\": \"\",'+
            '                    \"nomeCidade\": \"\",'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"cpfPEP\": 8701122797,'+
            '                    \"numeroCepInicial\": 0,'+
            '                    \"siglaSexo\": 77,'+
            '                    \"numeroCepComplemento\": 0,'+
            '                    \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                    \"codigoPEP\": 262639,'+
            '                    \"codigoStatus\": 0,'+
            '                    \"tipoPEP\": \"F\",'+
            '                    \"dataNascimento\": \"1981-04-30T00:00:00-03:00\",'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoSituacao\": 0,'+
            '                    \"numeroLogradouro\": 0'+
            '                }'+
            '            },'+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"RELACAO COMERCIAL\",'+
            '                \"pessoaPEPWS\": {'+
            '                    \"siglaUF\": \"\",'+
            '                    \"descricaoEmail\": \"BOLSONARO.ENB@GMAIL.COM\",'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"nomeLogradouro\": \"\",'+
            '                    \"complementoLogradouro\": \"\",'+
            '                    \"nomePEP\": \"EDUARDO NANTES BOLSONARO\",'+
            '                    \"nomeBairro\": \"\",'+
            '                    \"nomeCidade\": \"\",'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"cpfPEP\": 10655365770,'+
            '                    \"numeroCepInicial\": 0,'+
            '                    \"siglaSexo\": 77,'+
            '                    \"numeroCepComplemento\": 0,'+
            '                    \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                    \"codigoPEP\": 1007069,'+
            '                    \"codigoStatus\": 0,'+
            '                    \"tipoPEP\": \"F\",'+
            '                    \"dataNascimento\": \"1984-07-10T00:00:00-03:00\",'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoSituacao\": 0,'+
            '                    \"numeroLogradouro\": 0'+
            '                }'+
            '            },'+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"RELACAO COMERCIAL\",'+
            '                \"pessoaPEPWS\": {'+
            '                    \"siglaUF\": \"\",'+
            '                    \"descricaoEmail\": \"CARLOSBOLSONARO.RJ@GMAIL.COM\",'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"nomeLogradouro\": \"\",'+
            '                    \"complementoLogradouro\": \"\",'+
            '                    \"nomePEP\": \"CARLOS NANTES BOLSONARO\",'+
            '                    \"nomeBairro\": \"\",'+
            '                    \"nomeCidade\": \"\",'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"cpfPEP\": 9679208761,'+
            '                    \"numeroCepInicial\": 0,'+
            '                    \"siglaSexo\": 77,'+
            '                    \"numeroCepComplemento\": 0,'+
            '                    \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                    \"codigoPEP\": 1068808,'+
            '                    \"codigoStatus\": 0,'+
            '                    \"tipoPEP\": \"F\",'+
            '                    \"dataNascimento\": \"1982-12-07T00:00:00-03:00\",'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoSituacao\": 0,'+
            '                    \"numeroLogradouro\": 0'+
            '                }'+
            '            }'+
            '        ],'+
            '        \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '        \"nomePessoaRelacionada\": \"JAIR MESSIAS BOLSONARO\",'+
            '        \"numeroCPF\": 45317828791,'+
            '        \"dataNascimento\": \"1955-03-21T00:00:00-03:00\",'+
            '        \"numeroRamal\": 0,'+
            '        \"codigoDDD\": 0,'+
            '        \"codigoSituacao\": 2,'+
            '        \"numeroLogradouro\": 30'+
            '    },'+
            '    \"listaPessoa\": {'+
            '        \"siglaUF\": \"SP\",'+
            '        \"descricaoEmail\": \"DEP JAIRBOLSONARO CAMARA GOV BR\",'+
            '        \"flagExclusao\": \"A\",'+
            '        \"nomeLogradouro\": \"\",'+
            '        \"complementoLogradouro\": \"\",'+
            '        \"nomePEP\": \"JAIR MESSIAS BOLSONARO\",'+
            '        \"nomeBairro\": \"\",'+
            '        \"nomeCidade\": \"CAMPINAS\",'+
            '        \"numeroTelefone\": 32155482,'+
            '        \"cpfPEP\": 45317828791,'+
            '        \"mandatoPEPs\": {'+
            '            \"dataCarga\": \"2024-07-04T12:00:00-03:00\",'+
            '            \"dataExoneracao\": \"2022-12-31T00:00:00-03:00\",'+
            '            \"cargoPEPWS\": {'+
            '                \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                \"descricaoTratamentoFeminino\": \"EXCELENTISSIMA SENHORA\",'+
            '                \"codigoCargo\": 68,'+
            '                \"descricaoTratamentoMasculino\": \"EXCELENTISSIMO SENHOR\",'+
            '                \"nomeCargo\": \"PRESIDENTE DA REPUBLICA\"'+
            '            },'+
            '            \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '            \"descricaoMotivoExoneracao\": \"TERMINO DE MANDATO\",'+
            '            \"orgaoPEPWS\": {'+
            '                \"nomeOrgao\": \"PRESIDENCIA DA REPUBLICA\",'+
            '                \"siglaUF\": \"DF\",'+
            '                \"descricaoEmail\": \"PR PLANALTO GOV BR\",'+
            '                \"nomeLogradouro\": \"PC DOS TRES PODERES PALACIO DO PLANALTO\",'+
            '                \"codigoOrgao\": 3,'+
            '                \"complementoLogradouro\": \"\",'+
            '                \"nomeBairro\": \"\",'+
            '                \"nomeCidade\": \"BRASILIA\",'+
            '                \"numeroTelefone\": 34112222,'+
            '                \"numeroCepInicial\": 70150,'+
            '                \"numeroCepComplemento\": 900,'+
            '                \"numeroCNPJ\": 0,'+
            '                \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                \"siglaOrgaoSuperior\": \"\",'+
            '                \"numeroRamal\": 0,'+
            '                \"codigoDDD\": 61,'+
            '                \"numeroLogradouro\": 0'+
            '            }'+
            '        },'+
            '        \"numeroCepInicial\": 0,'+
            '        \"siglaSexo\": 77,'+
            '        \"numeroCepComplemento\": 0,'+
            '        \"pessoaRelacaoPEPs\": ['+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"RELACAO COMERCIAL\",'+
            '                \"pessoaRelacionadaPEPWS\": {'+
            '                    \"siglaUF\": \"RJ\",'+
            '                    \"descricaoEmail\": \"\",'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"nomeLogradouro\": \"DA MARIA\",'+
            '                    \"tipoPessoa\": 70,'+
            '                    \"complementoLogradouro\": \"AP 503 BL 1\",'+
            '                    \"nomeBairro\": \"VL ISABEL\",'+
            '                    \"nomeCidade\": \"RIO DE JANEIRO\",'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"numeroCepInicial\": 23035,'+
            '                    \"siglaSexo\": 70,'+
            '                    \"numeroCepComplemento\": \"070\",'+
            '                    \"codigoPessoaRelacionada\": 90053706,'+
            '                    \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                    \"nomePessoaRelacionada\": \"ROGERIA NANTES BRAGA BOLSONARO\",'+
            '                    \"numeroCPF\": 7150302726,'+
            '                    \"dataNascimento\": \"1960-05-03T00:00:00-03:00\",'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoSituacao\": 2,'+
            '                    \"numeroLogradouro\": 71'+
            '                }'+
            '            },'+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"CONJUGE\",'+
            '                \"pessoaRelacionadaPEPWS\": {'+
            '                    \"siglaUF\": \"DF\",'+
            '                    \"descricaoEmail\": \"\",'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"nomeLogradouro\": \"QNN\",'+
            '                    \"tipoPessoa\": 70,'+
            '                    \"complementoLogradouro\": \"CJ F C 15\",'+
            '                    \"nomeBairro\": \"CEILANDIA NORTE\",'+
            '                    \"nomeCidade\": \"CEILANDIA\",'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"numeroCepInicial\": 72225,'+
            '                    \"numeroCepComplemento\": \"016\",'+
            '                    \"codigoPessoaRelacionada\": 90262433,'+
            '                    \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                    \"nomePessoaRelacionada\": \"MICHELLE DE PAULA FIRMO REINALDO BOLSONARO\",'+
            '                    \"numeroCPF\": 71137840110,'+
            '                    \"dataNascimento\": \"1982-03-22T00:00:00-03:00\",'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoSituacao\": 2,'+
            '                    \"numeroLogradouro\": 1'+
            '                }'+
            '            },'+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"MAE\",'+
            '                \"pessoaRelacionadaPEPWS\": {'+
            '                    \"siglaUF\": \"SP\",'+
            '                    \"descricaoEmail\": \"\",'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"nomeLogradouro\": \"CEL BENEDITO DE ALBUQUERQUE\",'+
            '                    \"tipoPessoa\": 70,'+
            '                    \"complementoLogradouro\": \"\",'+
            '                    \"nomeBairro\": \"OASIS\",'+
            '                    \"nomeCidade\": \"PERUIBE\",'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"numeroCepInicial\": 11772,'+
            '                    \"siglaSexo\": 70,'+
            '                    \"numeroCepComplemento\": 616,'+
            '                    \"codigoPessoaRelacionada\": 90000283,'+
            '                    \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                    \"nomePessoaRelacionada\": \"OLINDA BONTURI BOLSONARO\",'+
            '                    \"numeroCPF\": 25147830898,'+
            '                    \"dataNascimento\": \"1927-03-28T00:00:00-03:00\",'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoSituacao\": 2,'+
            '                    \"numeroLogradouro\": 582'+
            '                }'+
            '            },'+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T23:11:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"POSSÍVEL IRMA(O)\",'+
            '                \"pessoaRelacionadaPEPWS\": {'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"dataAtualizacao\": \"2024-07-04T23:11:00-03:00\",'+
            '                    \"nomePessoaRelacionada\": \"MARIA DENISE BOLSONARO CAMPOS\",'+
            '                    \"numeroCPF\": 562779892,'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoPessoaRelacionada\": 1000207328,'+
            '                    \"codigoSituacao\": 0,'+
            '                    \"numeroLogradouro\": 0'+
            '                }'+
            '            },'+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T23:11:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"POSSÍVEL IRMA(O)\",'+
            '                \"pessoaRelacionadaPEPWS\": {'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"dataAtualizacao\": \"2024-07-04T23:11:00-03:00\",'+
            '                    \"nomePessoaRelacionada\": \"RENATO ANTONIO BOLSONARO\",'+
            '                    \"numeroCPF\": 7425227843,'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoPessoaRelacionada\": 1000207326,'+
            '                    \"codigoSituacao\": 0,'+
            '                    \"numeroLogradouro\": 0'+
            '                }'+
            '            },'+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"RELACAO COMERCIAL\",'+
            '                \"pessoaRelacionadaPEPWS\": {'+
            '                    \"siglaUF\": \"RJ\",'+
            '                    \"descricaoEmail\": \"\",'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"nomeLogradouro\": \"VSC DE ITAMARATI\",'+
            '                    \"tipoPessoa\": 70,'+
            '                    \"complementoLogradouro\": \"BL 1 AP 101\",'+
            '                    \"nomeBairro\": \"MARACANA\",'+
            '                    \"nomeCidade\": \"RIO DE JANEIRO\",'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"numeroCepInicial\": 20550,'+
            '                    \"siglaSexo\": 77,'+
            '                    \"numeroCepComplemento\": 140,'+
            '                    \"codigoPessoaRelacionada\": 90072013,'+
            '                    \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                    \"nomePessoaRelacionada\": \"CARLOS NANTES BOLSONARO\",'+
            '                    \"numeroCPF\": 9679208761,'+
            '                    \"dataNascimento\": \"1982-12-07T00:00:00-03:00\",'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoSituacao\": 2,'+
            '                    \"numeroLogradouro\": 142'+
            '                }'+
            '            },'+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"RELACAO COMERCIAL\",'+
            '                \"pessoaRelacionadaPEPWS\": {'+
            '                    \"siglaUF\": \"RJ\",'+
            '                    \"descricaoEmail\": \"\",'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"nomeLogradouro\": \"DONA MARIA\",'+
            '                    \"tipoPessoa\": 70,'+
            '                    \"complementoLogradouro\": \"BL 1 AP 503\",'+
            '                    \"nomeBairro\": \"TIJUCA\",'+
            '                    \"nomeCidade\": \"RIO DE JANEIRO\",'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"numeroCepInicial\": 20541,'+
            '                    \"siglaSexo\": 77,'+
            '                    \"numeroCepComplemento\": 901,'+
            '                    \"codigoPessoaRelacionada\": 90072014,'+
            '                    \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                    \"nomePessoaRelacionada\": \"EDUARDO NANTES BOLSONARO\",'+
            '                    \"numeroCPF\": 10655365770,'+
            '                    \"dataNascimento\": \"1984-07-10T00:00:00-03:00\",'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoSituacao\": 2,'+
            '                    \"numeroLogradouro\": 71'+
            '                }'+
            '            },'+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"RELACAO COMERCIAL\",'+
            '                \"pessoaRelacionadaPEPWS\": {'+
            '                    \"siglaUF\": \"RJ\",'+
            '                    \"descricaoEmail\": \"\",'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"nomeLogradouro\": \"DONA MARIA\",'+
            '                    \"tipoPessoa\": 70,'+
            '                    \"complementoLogradouro\": \"AP 0503 1\",'+
            '                    \"nomeBairro\": \"VL ISABEL\",'+
            '                    \"nomeCidade\": \"RIO DE JANEIRO\",'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"numeroCepInicial\": 20541,'+
            '                    \"siglaSexo\": 77,'+
            '                    \"numeroCepComplemento\": 901,'+
            '                    \"codigoPessoaRelacionada\": 90072012,'+
            '                    \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '                    \"nomePessoaRelacionada\": \"FLAVIO NANTES BOLSONARO\",'+
            '                    \"numeroCPF\": 8701122797,'+
            '                    \"dataNascimento\": \"1981-04-30T00:00:00-03:00\",'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoSituacao\": 2,'+
            '                    \"numeroLogradouro\": 71'+
            '                }'+
            '            },'+
            '            {'+
            '                \"dataAtualizacao\": \"2024-07-04T23:11:00-03:00\",'+
            '                \"descricaoRelacionamento\": \"POSSÍVEL IRMA(O)\",'+
            '                \"pessoaRelacionadaPEPWS\": {'+
            '                    \"flagExclusao\": \"A\",'+
            '                    \"dataAtualizacao\": \"2024-07-04T23:11:00-03:00\",'+
            '                    \"nomePessoaRelacionada\": \"ANGELO GUIDO BONTURI BOLSONARO\",'+
            '                    \"numeroCPF\": 4484463830,'+
            '                    \"numeroTelefone\": 0,'+
            '                    \"numeroRamal\": 0,'+
            '                    \"codigoDDD\": 0,'+
            '                    \"codigoPessoaRelacionada\": 1000207327,'+
            '                    \"codigoSituacao\": 0,'+
            '                    \"numeroLogradouro\": 0'+
            '                }'+
            '            }'+
            '        ],'+
            '        \"dataAtualizacao\": \"2024-07-04T12:00:00-03:00\",'+
            '        \"codigoPEP\": 12666,'+
            '        \"codigoStatus\": 0,'+
            '        \"tipoPEP\": \"F\",'+
            '        \"dataNascimento\": \"1955-03-21T00:00:00-03:00\",'+
            '        \"numeroRamal\": 0,'+
            '        \"codigoDDD\": 61,'+
            '        \"codigoSituacao\": 0,'+
            '        \"numeroLogradouro\": 0'+
            '    },'+
            '    \"codigoRetorno\": 1'+
            '}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }
    //FIM - LECVPV-218

}