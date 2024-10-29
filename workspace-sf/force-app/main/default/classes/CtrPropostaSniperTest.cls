/*********************************************************************************************************************************************************************

@description  Classe que contem a Controller para o Formulario.
@author Diogo Borges - Avanxo
@date 01/10/2019
@Classe criada por conta da história PLV-2687
        
**********************************************************************************************************************************************************************/

@isTest
public class CtrPropostaSniperTest {
    
    //AV-85 - INICIO
    @testSetup 
	static void setup(){

        Account contaTeste = new Account(
                Name = 'Conta 41',
                CodigoEmpresa__c = '214',
                IdExterno__c = '13143510000160',
                Papel__c = 'Parceiro',
                Sexo__c = 'Masc',
                Cpf__c = '76466318095',
                Pis__c = '123456789', // PLV-4445
                Cnpj__c = '13.143.510/0001-60',
                Inscricao_Municipal__c = '123456789', // PLV-4445
                Nacionalidade__c = 'Brasileira',
                EstadoCivil__c = 'Casado (a)',
                Email__c = 'teste@teste.com.br'
        );
        insert contaTeste;   
        
        //RVI 214 - INICIO
        //Massa de teste para método que trata o Orquestrador
        Account contaTeste14 = new Account(
                Name = 'Conta 14',
                CodigoEmpresa__c = '14',
                IdExterno__c = '13143510000360',
                Papel__c = 'Parceiro',
                Sexo__c = 'Masc',
                Cpf__c = '44329539004',
                Pis__c = '123456788', // PLV-4445
                Cnpj__c = '66.040.693/0001-54',
                Inscricao_Municipal__c = '123456689', // PLV-4445
                Nacionalidade__c = 'Brasileira',
                EstadoCivil__c = 'Casado (a)',
                Email__c = 'teste14@teste.com.br'
        );
        insert contaTeste14;
        //RVI 214 - FIM

        RamoSeguro__c ramoSegurado = new RamoSeguro__c(
                Name = 'SEGURO VIAGEM',  //AV-85 FIX 05 INICIO-FIM
                CodigoEmpresa__c = '214',
                Codigo__c = '2',
                Empresa__c = contaTeste.Id,
                Status__c = 'Ativo',
                CodigoOrigemDoMovimentoBCP__c = '32'
        );
        insert ramoSegurado;
        
        //cria modalidade
        Modalidade__c modalidade = new Modalidade__c(
                RamoSeguro__c = ramoSegurado.Id,
                Name = 'SEGURO VIAGEM', //AV-85 FIX 05 INICIO-FIM
                Codigo__c = '0'
        );
        insert modalidade;

        //cria forma de pagamento
        FormaPagamento__c formaPagamento = new FormaPagamento__c(
                Codigo__c = '41',
                Name = 'FRAC.1.A PARCELA CARNE',
                RamoSeguro__c = ramoSegurado.id,
                Modalidade__c = modalidade.id
        );

        insert formaPagamento;
        //RVI-39 - INICIO
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Empresa__c = contaTeste.Id;
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Empresa__c = contaTeste.Id;
        update produtoCom;

        //RVI 214 - INICIO
        //Massa de teste que trata o Orquestrador
        Product2 produto14 = TestDataFactory.gerarProdutoComericial(produtoTec);
        produto14.Status__c ='ativo';
        produto14.Empresa__c = contaTeste14.Id;
        update produto14;
        //RVI 214 - FIM
        
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        
        //TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        
        Opportunity orcamento = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        //TKCL-240 INICIO
        orcamento.Numero__c = '00006767';
        update orcamento;
        //TKCL-240 FIM

        //RVI-39 - FIM   

        
        //VIAG-301 INICIO
        Quote testQuote = new Quote(
            Name = 'Test Quote',
            OpportunityId = orcamento.Id,
            VigenciaFinal__c = Date.today().addMonths(12),
            VigenciaInicial__c = Date.today(),
            VoucherPdfDownloadUrl__c = 'http://example.com/voucher.pdf',
            NumeroProposta__c = 'PROP12345',
            Opcao__c = '1',
            Origem__c = '18',
            MeioComercializacao__c = 'APP',
            Status = 'Contratada',
            DataCalculo__c = Date.today().addDays(-5),
            Chave_de_Agrupamento__c = 'AGRUP123',
            RamoSeguro__c = ramoSegurado.Id,
            Modalidade__c = modalidade.Id,
            CanalDistribuicao__c = canalDistribuicao.Id
        );
        insert testQuote; 
        //VIAG-301 FIM
    }

    @isTest
    static void testFormularioSnipper() {         
        
        String payloadReturn = '{"servico":"/voucher/gravar-voucher","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2021-09-21T20:39:01.842Z","descricao":"Inclusão realizada com sucesso.","dados":[{"cpf":"023.456.789-29","voucher":"KFN0975-ZZ","produto":"VIDA_ON","datainsercao":"2021-09-21"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));

        //RVI-39
        Opportunity orcamentoCodigoEmpresa = [SELECT Numero__c FROM Opportunity LIMIT 1];
        
        EmissaoTO proposta = new EmissaoTO();
            proposta.indice= 1;
            proposta.codigoEmpresa=0;
            proposta.numeroOrcamento = orcamentoCodigoEmpresa.Numero__c.trim();
            proposta.numeroPortal= '0';
            proposta.origem= 18;
            proposta.ramoSeguro= 1391;
            proposta.tipoSeguro= 'Novo';
            proposta.entradaNegocio= 'COR';
            proposta.dataProtocolo= '2022-02-03';
            proposta.meioComercializacao= 'SFC';
            proposta.codigoProdutoVida= 'VI-PESSOAS';
            proposta.canalDistribuicao= 'COR';
            proposta.segmento= 'Individual';
            proposta.tempoRendaProtegida= '24';
            proposta.dependentesFinanceiros= false;
            proposta.formaReceberApolice= 'DIGITAL';
            proposta.termoGuarda= false;
            proposta.termoResponsabilidade= true;
            proposta.assinaturaEletronica= true;
            proposta.susepOrcamento = 'COL10J';
        
        List<EmissaoTO> propostaLst = new List<EmissaoTO>();
        propostaLst.add(proposta);

        EmissaoTO.OfertasTO propostaTransmissao = new EmissaoTO.OfertasTO();
        propostaTransmissao.propostas = propostaLst;

        String jsonTransmissao = JSON.serialize(propostaTransmissao);
        //RVI-39 - FIM

		Test.startTest();     
        
        CtrPropostaSniper testeSnipper = new CtrPropostaSniper();
        testeSnipper.opServico = '';
        testeSnipper.servicosEntrada = '';
        testeSnipper.entradaTransmissao = jsonTransmissao; //RVI-39 - INICIO/FIM
        testeSnipper.apoliceContratoOriginal = ''; //TKCL-240 INCIO/FIM FIX01
        testeSnipper.dadosPagamento = ''; //TKCL-240 INCIO/FIM FIX01

        testeSnipper.DadosVoucher = '{"cpf" : "180.917.248-96", "voucher" : "17961495", "produto" : "VIAGEM_VIDA_ON"}';
        
        ContractBO.ResponseHerokuGravarVoucher responseGravarVoucherVidaOn = HerokuService.getInstance().gravarVoucherVidaOn(testeSnipper.DadosVoucher);
		String jsonResponseConsulta = JSON.serialize(responseGravarVoucherVidaOn);   
        
     testeSnipper.pagTransmissao();
        Test.stopTest();
               
                
    }

    @isTest
    static void testfindIdFormaPagamento(){
        CtrPropostaSniper testeSnipper = new CtrPropostaSniper();
        Test.startTest();
        testeSnipper.findIdFormaPagamento();
        Test.stopTest();
    }
/*
   @isTest
    static void testQuote() {
       Account contaTeste2 = new Account(
                Name = 'Conta 20',
                CodigoEmpresa__c = '218',
                IdExterno__c = '75879634051',
                Papel__c = 'Parceiro',
                Sexo__c = 'Masc',
                Cpf__c = '75879634051',
                Pis__c = '123456789', // PLV-4445
                Cnpj__c = '87.049.903/0001-45',
                Inscricao_Municipal__c = '223456789', // PLV-4445
                Nacionalidade__c = 'Brasileira',
                EstadoCivil__c = 'Casado (a)',
                Email__c = 'testenovo@teste.com.br'
                
        );
        Insert contaTeste2;
        
        
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste2);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste2);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        update produtoCom;

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste2, produtoCom, canalDistribuicao);
        Opportunity orcamentoRenovado = TestDataFactory.gerarOrcamentoObjeto(contaTeste2, produtoCom, canalDistribuicao);
		
         Quote proposta = new Quote(            
            Name = '18-00006767',
            NumeroPropostaUnico__c = '00006767',
            DependentesFinanceiros__c = false,
            OpportunityId = orcamentoContratado.id,
            CodigoCorretor__c = dadosCorretor.Id,
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,            
            Modalidade__c = modalidade.Id,
            Status = 'Em análise'         
        );
        insert proposta;
        
		Test.startTest();
        
		//CtrPropostaSniper testeSnipper2 = new CtrPropostaSniper();        
        CtrPropostaSniper.getQuote(proposta.Name); //RVI-39 - INICIO/FIM
      
        Test.stopTest();

    }   
    //AV-85 - FIM
   */
    @isTest
    static void carregarEstruturaDados() {
        CtrPropostaSniper.DevolutivasTO DevolutivasTO = new CtrPropostaSniper.DevolutivasTO();
        DevolutivasTO.descricao = '';

        CtrPropostaSniper.DataTO DataTO = new CtrPropostaSniper.DataTO();
        DataTO.devolutivas = new List<CtrPropostaSniper.DevolutivasTO>();

        CtrPropostaSniper.RetornoTO RetornoTO = new CtrPropostaSniper.RetornoTO();
        RetornoTO.data = DataTO;
        
    }

    @isTest
    static void testTransmissaoContratacao() {
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('CriacaoTransmissao');
        mock.setStatusCode(500);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);

        //RVI-39
        Opportunity orcamentoCodigoEmpresa = [SELECT Numero__c FROM Opportunity LIMIT 1];
        
        EmissaoTO proposta = new EmissaoTO();
            proposta.indice= 1;
            proposta.codigoEmpresa=0;
            proposta.numeroOrcamento = orcamentoCodigoEmpresa.Numero__c.trim();
            proposta.numeroPortal= '0';
            proposta.origem= 18;
            proposta.ramoSeguro= 1391;
            proposta.tipoSeguro= 'Novo';
            proposta.entradaNegocio= 'COR';
            proposta.dataProtocolo= '2022-02-03';
            proposta.meioComercializacao= 'SFC';
            proposta.codigoProdutoVida= 'VI-PESSOAS';
            proposta.canalDistribuicao= 'COR';
            proposta.segmento= 'Individual';
            proposta.tempoRendaProtegida= '24';
            proposta.dependentesFinanceiros= false;
            proposta.formaReceberApolice= 'DIGITAL';
            proposta.termoGuarda= false;
            proposta.termoResponsabilidade= true;
            proposta.assinaturaEletronica= true;

        List<EmissaoTO> propostaLst = new List<EmissaoTO>();
        propostaLst.add(proposta);

        EmissaoTO.OfertasTO propostaTransmissao = new EmissaoTO.OfertasTO();
        propostaTransmissao.propostas = propostaLst;

        String jsonTransmissao = JSON.serialize(propostaTransmissao);
        //RVI-39 - FIM

		Test.startTest();
        
		//CtrPropostaSniper testeSnipper2 = new CtrPropostaSniper();        
        CtrPropostaSniper.transmissaoContratacao(jsonTransmissao); //RVI-39 - INICIO/FIM
        Test.stopTest();

    }   
    // AV-631  AV-699 inicio 
    /*
     @isTest
     static void testMascaraCPF() {
       
		Test.startTest();
             
        CtrPropostaSniper.MascaraCPF('24874738869'); 

        Test.stopTest();  
     }
    
    @isTest
    static void testcpfbloqueado() {
      
         Account contaTeste2 = new Account(
                Name = 'Conta 20',
                CodigoEmpresa__c = '218',
                IdExterno__c = '75879634051',
                Papel__c = 'Parceiro',
                Sexo__c = 'Masc',
                Cpf__c = '75879634051',
                Pis__c = '123456789', // PLV-4445
                Cnpj__c = '87.049.903/0001-45',
                Inscricao_Municipal__c = '223456789', // PLV-4445
                Nacionalidade__c = 'Brasileira',
                EstadoCivil__c = 'Casado (a)',
                Email__c = 'testenovo@teste.com.br'
                
        );
        
        Test.startTest();
             
             CtrPropostaSniper.cpfBloqueado(contaTeste2.Cpf__c,'Brasil-ouro');
     
        Test.stopTest();  
     }
      // AV-631 AV-699 FIM
    */

    static void testEstruturaRetornoEnderecoTO() {
        
        CtrPropostaSniper.EnderecoCompletoTO EnderecoCompletoTOMock = new CtrPropostaSniper.EnderecoCompletoTO();
        EnderecoCompletoTOMock.bairro = 'Teste';
        EnderecoCompletoTOMock.cep = '000';
        EnderecoCompletoTOMock.cidade = 'Teste';
        EnderecoCompletoTOMock.complementoCep = '000';
        EnderecoCompletoTOMock.logradouro = 'Teste';
        EnderecoCompletoTOMock.tipoLogradouro = 'Teste';
        EnderecoCompletoTOMock.uf = 'AA';
        
        CtrPropostaSniper.EnderecoGuiaPostalEBOTO EnderecoGuiaPostalEBOTOMock = new CtrPropostaSniper.EnderecoGuiaPostalEBOTO();
		EnderecoGuiaPostalEBOTOMock.cepCidade = 'Teste';
        EnderecoGuiaPostalEBOTOMock.cepComplementoCidade = 'Teste';
        EnderecoGuiaPostalEBOTOMock.cepEspecial = 'Teste';
        EnderecoGuiaPostalEBOTOMock.cepName = 'Teste';
        EnderecoGuiaPostalEBOTOMock.codigoBairro = 'Teste';
        EnderecoGuiaPostalEBOTOMock.codigoCidade = 'Teste';
        EnderecoGuiaPostalEBOTOMock.codigoFoneticoLogradouro = 'Teste';
        EnderecoGuiaPostalEBOTOMock.codigoLogradouro = 'Teste';
        EnderecoGuiaPostalEBOTOMock.enderecoCompleto = EnderecoCompletoTOMock;
        EnderecoGuiaPostalEBOTOMock.primeiroCodigoFoneticoCidade = 'Teste';
        EnderecoGuiaPostalEBOTOMock.primeiroCodigoFoneticoLogradouro = 'Teste';
        EnderecoGuiaPostalEBOTOMock.segundoCodigoFoneticoCidade = 'Teste';
        EnderecoGuiaPostalEBOTOMock.segundoCodigoFoneticoLogradouro = 'Teste';
        EnderecoGuiaPostalEBOTOMock.terceiroCodigoFoneticoCidade = 'Teste';
        EnderecoGuiaPostalEBOTOMock.terceiroCodigoFoneticoLogradouro = 'Teste';
        
        CtrPropostaSniper.EnderecosGuiaPostalEBOTO EnderecosGuiaPostalEBOTOMock = new CtrPropostaSniper.EnderecosGuiaPostalEBOTO();
        EnderecosGuiaPostalEBOTOMock.enderecoGuiaPostalEBO = EnderecoGuiaPostalEBOTOMock;
        
        CtrPropostaSniper.ObterEnderecoPorCEPResponseTO ObterEnderecoPorCEPResponseTOMock = new CtrPropostaSniper.ObterEnderecoPorCEPResponseTO();
        ObterEnderecoPorCEPResponseTOMock.enderecosGuiaPostalEBO = EnderecosGuiaPostalEBOTOMock;
        
        CtrPropostaSniper.RetornoEnderecoTO RetornoEnderecoTOMock = new CtrPropostaSniper.RetornoEnderecoTO();
        RetornoEnderecoTOMock.obterEnderecoPorCEPResponse = ObterEnderecoPorCEPResponseTOMock;
    }

    
    @isTest
    static void testConsultaCep() {
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('mockConsultaCep');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
        testEstruturaRetornoEnderecoTO();
		CtrPropostaSniper testeSnipper2 = new CtrPropostaSniper();
        testeSnipper2.fieldName = 'teste';
        testeSnipper2.entradaServicoCep = 'jsonCep';   
        testeSnipper2.consultaCEP();

        Test.stopTest();
    }
    //FIM - PLV-4656-VI-Guilherme Brito
    
    //PLV-2948 Fix3 - Inicio - Ajuste classe de teste
    @isTest
    static void testTransmissaoContratacaoDevolutiva() {
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('CriacaoTransmissaoDevolutiva');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);
        //RVI-39
        Opportunity orcamentoCodigoEmpresa = [SELECT Numero__c FROM Opportunity LIMIT 1];
        
        EmissaoTO proposta = new EmissaoTO();
            proposta.indice= 1;
            proposta.codigoEmpresa=0;
            proposta.numeroOrcamento = orcamentoCodigoEmpresa.Numero__c.trim();
            proposta.numeroPortal= '0';
            proposta.origem= 18;
            proposta.ramoSeguro= 1391;
            proposta.tipoSeguro= 'Novo';
            proposta.entradaNegocio= 'COR';
            proposta.dataProtocolo= '2022-02-03';
            proposta.meioComercializacao= 'SFC';
            proposta.codigoProdutoVida= 'VI-PESSOAS';
            proposta.canalDistribuicao= 'COR';
            proposta.segmento= 'Individual';
            proposta.tempoRendaProtegida= '24';
            proposta.dependentesFinanceiros= false;
            proposta.formaReceberApolice= 'DIGITAL';
            proposta.termoGuarda= false;
            proposta.termoResponsabilidade= true;
            proposta.assinaturaEletronica= true;

        List<EmissaoTO> propostaLst = new List<EmissaoTO>();
        propostaLst.add(proposta);

        EmissaoTO.OfertasTO propostaTransmissao = new EmissaoTO.OfertasTO();
        propostaTransmissao.propostas = propostaLst;

        String jsonTransmissao = JSON.serialize(propostaTransmissao);
        //RVI-39 - FIM
		Test.startTest();
        
        CtrPropostaSniper.transmissaoContratacao(jsonTransmissao); //RVI-39 - INICIO/FIM
        //string NameQuote = QuoteBO.getInstance().gerarNameProposta('18','00824369');
        //CtrPropostaSniper.getQuote(NameQuote);
        //CtrPropostaSniper.getUrlSampleMed(NameQuote);
        Test.stopTest();

    }
    //PLV-2948 Fix3 - Fim - Ajuste classe de teste

    //PLV-4367 - INÍCIO
    @isTest
    public static String retornarDadosAgenciadores(){

        String entradaJson = '{' +
                             + '"nome": "testeAgenciador", '
                             + '"susep": "", '
                             + '"codigoAgenciador": "", '
                             + '"cpf": "", '
                             + '"cnpj": "", '
            				 + '"papel": "agenciador" '
                             + '}';
        return entradaJson;
    }

    @isTest
    public static void consultaAgenciadoresTest(){
        
        Account acc = (account) new AccountFactory.PessoaFisica().createRecord();
        acc.LastName = 'testeAgenciador';
        acc.papel__c = 'Agenciador';
        update acc;
        

        system.debug('retornarDadosAgenciadores: ' + retornarDadosAgenciadores());
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/buscaAgenciador';
        request.httpMethod = 'POST';
        // request.requestBody = Blob.valueof(retornarDadosAgenciadores());

        Test.startTest();
        RestContext.request = request;
        CtrPropostaSniper propostaSniperOBj = new CtrPropostaSniper();
        propostaSniperOBj.entradaAgenciadores = retornarDadosAgenciadores();        
        propostaSniperOBj.consultaAgenciadores();
        
        system.debug('propostaSniperOBj.retornoAgenciadores: ' + propostaSniperOBj.retornoAgenciadores);
        System.assertEquals(true, String.isNotBlank(propostaSniperOBj.retornoAgenciadores));

        Test.stopTest();    
    }
    //PLV-4367 - FIM
    
    //PLV-4475 - INÍCIO
    @isTest
    public static void consultaCorretoresTest(){
        Account conta = (Account) new AccountFactory.PessoaJuridica().createRecord();
        conta.Papel__c = 'Corretor';
        conta.SusepPrincipal__c = 'P5005J';
        update conta;

        Test.startTest();
        CtrPropostaSniper propostaSniperOBj = new CtrPropostaSniper();
        propostaSniperOBj.entradaCorretores = 'p5005j';  
        propostaSniperOBj.consultaCorretores();
        
        system.debug('propostaSniperOBj.retornoAgenciadores: ' + propostaSniperOBj.retornoCorretores);
        System.assertEquals(true, String.isNotBlank(propostaSniperOBj.retornoCorretores));

        Test.stopTest(); 
    }
    //PLV-4475 - FIM

    @isTest
    public static void consultaOpcoesTipoServicoTest()
    {
        List<OpcoesServicoTO> opcoesServicoLst = new List<OpcoesServicoTO>();
        OpcoesServicoTO opcaoServico = new OpcoesServicoTO();
        Servico__mdt servico = [SELECT Id, DeveloperName FROM Servico__mdt LIMIT 1];
        
        opcaoServico.Id = servico.Id;
        opcaoServico.servico = servico.DeveloperName;
        opcaoServico.body = 'Teste';
        opcaoServico.metodo = 'GET';

        opcoesServicoLst.add(opcaoServico);

        String jsonOpcaoServico = JSON.serialize(opcoesServicoLst);

        Test.startTest();
        CtrPropostaSniper propostaSniper = new CtrPropostaSniper();
        propostaSniper.servicosEntrada = jsonOpcaoServico;
        propostaSniper.consultaOpcoesTipoServico();
        Test.stopTest(); 
    }

    //TKCL-240 INICIO
    @istest static void aptlmkTest(){
        String codRamo = '531';
        String descricao = 'Porto auto';
        String ofertaSelecionada = '00006767';
        String parcelas = '5';
        List<Opportunity> codEmpresa = [SELECT Id, Produto__r.Empresa__r.CodigoEmpresa__c FROM Opportunity WHERE Numero__c =: ofertaSelecionada];

		String codEmp = codEmpresa[0].Produto__r.Empresa__r.CodigoEmpresa__c;
        String payloadReturn = '{"idExterno":"080622001","expiraEm":"120","nome":"Cliente Fulando de Tal","tipoTransacao":"CAPTURA","tipoLink":"REGISTRO_CARTAO","documento":{"tipo":"CPF","numero":"13481182657"},"produto":{"codigo":"32","descricao":"Porto Auto"},"metadados":{"tipo_documento_comercial":"01","endosso":"","codigo_empresa":"1","composicao_valor_parcela":"01","codigo_ramo":"'+ codRamo +'","parcela":"5","contrato_comercial":"","evento_emissao":"1","flag_sinalizador_processo":"O","flag_produto_seguro":"S","codigo_agregador":"","codigo_modalidade":"24","auth_type":"SINGLE"},"valorTotal":"1000","planoPagamento":[{"parcelas":1,"descricao":"1xsemjuros(R$1.000,00)","valorTotal":1000},{"parcelas":2,"descricao":"2xsemjuros(R$500,00)","valorTotal":1000},{"parcelas":3,"descricao":"3xcomjuros(R$375,00)","valorTotal":1125},{"parcelas":4,"descricao":"4xcomjuros(R$300,00)","valorTotal":1200},{"parcelas":5,"descricao":"5xcomjuros(R$250,00)","valorTotal":1250}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
        Test.startTest();
          CtrPropostaSniper.getAPIAptlmk(codRamo, descricao, ofertaSelecionada, parcelas);
        Test.stopTest();
    }
    //TKCL-240 FIM

    //RVI 214 - INICIO
    //Método de teste para validar quando for selecionado Empresa14
    @isTest
    static void getOrchestratorTestContains(){ 

        Product2 prod = [SELECT id, Name, Empresa__r.CodigoEmpresa__c FROM Product2 WHERE Empresa__r.CodigoEmpresa__c = '14' LIMIT 1];
        Oferta__c oferta = new Oferta__c(
            Produto__c = prod.id,                
            Name = 'EntradaOrchestrator',
            VigenciaInicio__c = System.today()
        );
        insert oferta;

        Test.startTest();        
        CtrPropostaSniper ctr = new CtrPropostaSniper();
        ctr.entradaOrchestrator = 'EntradaOrchestrator';
        ctr.getOrchestrator();
        Test.stopTest();
        System.assertEquals('true', ctr.retornoOrchestrator);
    }
    //RVI 214 - FIM

    //RVI 214 - INICIO
    //Método de teste para validar quando não for selecionado Empresa14
    @isTest
    static void getOrchestratorTestNotContains(){ 

        Test.startTest();        
        CtrPropostaSniper ctr = new CtrPropostaSniper();
        ctr.getOrchestrator();
        Test.stopTest();
        System.assertEquals('false', ctr.retornoOrchestrator);
    }
    //RVI 214 - FIM

    //RVI 262 e RVI-223 - INICIO    
    @IsTest
    static void testGetLink() {   
        API_Link_de_Pagamento__mdt mtd = new API_Link_de_Pagamento__mdt();
        mtd.DeveloperName = 'API_Link_de_Pagamento_Email';
        mtd.token_url__c = 'https://portoapicloud-dev.portoseguro.com.br/oauth/v2/access-token';
        APITokenizacaoService service = new APITokenizacaoService();

        String jsonRequest = '{\"expiraEm\":3600,\"configuracaoPagamento\":{\"produto\":{\"codProduto\":\"148\",\"nomeVertical\":\"VidaePrevidência\",\"nomeProduto\":\"VidaIndividual\",\"icone\":\"vida_previdencia\"},\"cartaoCredito\":{\"planoPagamento\":{\"parcelas\":3,\"descricao\":\"3xdeR$15,00semjuros\",\"valorTotal\":45.01}},\"contratos\":[{\"descricao\":\"PlanoEssencialVD\",\"valorTotal\":20.01,\"idExterno\":\"1001CM000206\"},{\"descricao\":\"PlanoEssencialVP\",\"valorTotal\":25,\"idExterno\":\"1001CM000207\"}]}}';
        String response = ctrPropostaSniper.getLink(jsonRequest);
    }
    //RVI 262 e RVI-223 - FIM 
    
    //VIAG-301 INICIO
    @isTest
    static void testTransmissaoContratacaoViagemMock() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('CriacaoTransmissao');
        mock.setStatusCode(500);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Opportunity orcamentoCodigoEmpresa = [SELECT Numero__c FROM Opportunity LIMIT 1];
        
        EmissaoTO proposta = new EmissaoTO();
        proposta.codigoEmpresa = 0;
        proposta.numeroOrcamento = orcamentoCodigoEmpresa.Numero__c.trim();
        proposta.segmento = 'Viagem';
        proposta.contratantes = new List<EmissaoTO.ContratanteTO>();
        
        EmissaoTO.ContratanteTO contratante = new EmissaoTO.ContratanteTO();
        contratante.grupos = new List<EmissaoTO.GrupoTO>();
        contratante.pessoa = new EmissaoTO.PessoaTO();
        contratante.pessoa.dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
        contratante.pessoa.dadosPessoaFisica.numeroCpf = '764663180';
        contratante.pessoa.dadosPessoaFisica.digitoCpf = '95';
        
        EmissaoTO.GrupoTO grupo = new EmissaoTO.GrupoTO();
        grupo.segurados = new List<EmissaoTO.SeguradoTO>();
        
        EmissaoTO.SeguradoTO segurado = new EmissaoTO.SeguradoTO();
        segurado.pessoa = new EmissaoTO.PessoaTO();
        segurado.pessoa.enderecos = new List<EmissaoTO.EnderecoTO>();
        segurado.pessoa.dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
        segurado.pessoa.dadosPessoaFisica.numeroCpf = '764663180';
        segurado.pessoa.dadosPessoaFisica.digitoCpf = '95';
        
        EmissaoTO.EnderecoTO endereco = new EmissaoTO.EnderecoTO();
        endereco.logradouro = 'Av. Paulista';
        endereco.complemento = 'Apto 101';
        endereco.bairro = 'Bela Vista';
        endereco.cidade = 'São Paulo';
        
        segurado.pessoa.enderecos.add(endereco);
        grupo.segurados.add(segurado);
        contratante.grupos.add(grupo);
        proposta.contratantes.add(contratante);
        
        List<EmissaoTO> propostaLst = new List<EmissaoTO>();
        propostaLst.add(proposta);
        EmissaoTO.OfertasTO propostaTransmissao = new EmissaoTO.OfertasTO();
        propostaTransmissao.propostas = propostaLst;
        
        String jsonTransmissao = JSON.serialize(propostaTransmissao);
        
        Test.startTest();
        CtrPropostaSniper.transmissaoContratacao(jsonTransmissao);
        Test.stopTest();
        
        System.assertEquals('764663180', proposta.contratantes.get(0).grupos.get(0).segurados.get(0).pessoa.dadosPessoaFisica.numeroCpf);
    }
    
    @isTest
    static void testTransmissaoContratacaoViagemSensedia() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('CriacaoTransmissao');
        mock.setStatusCode(500);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Opportunity orcamentoCodigoEmpresa = [SELECT Numero__c FROM Opportunity LIMIT 1];
        
        EmissaoTO proposta = new EmissaoTO();
        proposta.codigoEmpresa = 0;
        proposta.numeroOrcamento = orcamentoCodigoEmpresa.Numero__c.trim();
        proposta.segmento = 'Viagem';

        proposta.contratantes = new List<EmissaoTO.ContratanteTO>();
        EmissaoTO.ContratanteTO contratante = new EmissaoTO.ContratanteTO();
        contratante.grupos = new List<EmissaoTO.GrupoTO>();
        contratante.pessoa = new EmissaoTO.PessoaTO();
        contratante.pessoa.dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
        contratante.pessoa.dadosPessoaFisica.numeroCpf = '12345678900';
        contratante.pessoa.dadosPessoaFisica.digitoCpf = '00';
        
        EmissaoTO.GrupoTO grupo = new EmissaoTO.GrupoTO();
        grupo.segurados = new List<EmissaoTO.SeguradoTO>();
        
        EmissaoTO.SeguradoTO segurado = new EmissaoTO.SeguradoTO();
        segurado.pessoa = new EmissaoTO.PessoaTO();
        segurado.pessoa.enderecos = new List<EmissaoTO.EnderecoTO>();
        segurado.pessoa.dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
        segurado.pessoa.dadosPessoaFisica.numeroCpf = '12345678900';
        segurado.pessoa.dadosPessoaFisica.digitoCpf = '00';
        
        EmissaoTO.EnderecoTO endereco = new EmissaoTO.EnderecoTO();
        endereco.logradouro = 'Av. Paulista';
        endereco.complemento = 'Apto 101';
        endereco.bairro = 'Bela Vista';
        endereco.cidade = 'São Paulo';
        
        segurado.pessoa.enderecos.add(endereco);
        grupo.segurados.add(segurado);
        contratante.grupos.add(grupo);
        proposta.contratantes.add(contratante);
        
        List<EmissaoTO> propostaLst = new List<EmissaoTO>();
        propostaLst.add(proposta);
        EmissaoTO.OfertasTO propostaTransmissao = new EmissaoTO.OfertasTO();
        propostaTransmissao.propostas = propostaLst;
        
        String jsonTransmissao = JSON.serialize(propostaTransmissao);
        
        Test.startTest();
        CtrPropostaSniper.transmissaoContratacao(jsonTransmissao);
        Test.stopTest();
        
        System.assertEquals('12345678900', proposta.contratantes.get(0).grupos.get(0).segurados.get(0).pessoa.dadosPessoaFisica.numeroCpf);
    }

    @IsTest
    static void testCpfBloqueado1() {
        Account accBloqueado = [SELECT Cpf__c, Produtos_Bloqueados__c FROM Account LIMIT 1];
        accBloqueado.Produtos_Bloqueados__c = 'PROD1';
        update accBloqueado;
        
        Test.startTest();
        // Cenário 1: Produto e CPF correspondem a uma conta bloqueada
        Boolean resultado1 = CtrPropostaSniper.cpfBloqueado(accBloqueado.Cpf__c, 'PROD1');
        System.assertEquals(true, resultado1, 'CPF deve estar bloqueado para PROD1');
        Test.stopTest();        
    }
    
    @IsTest
    static void testCpfBloqueado2() {
        Account accBloqueado = [SELECT Cpf__c, Produtos_Bloqueados__c FROM Account LIMIT 1];
        accBloqueado.Produtos_Bloqueados__c = 'PROD1';
        update accBloqueado;
        
        Test.startTest();
        // Cenário 2: Produto e CPF não correspondem a uma conta bloqueada
        Boolean resultado2 = CtrPropostaSniper.cpfBloqueado(accBloqueado.Cpf__c, 'PROD2');
        System.assertEquals(false, resultado2, 'CPF não deve estar bloqueado para PROD2');
        Test.stopTest(); 
    }
    
    @IsTest
    static void testCpfBloqueado3() {
        Account accBloqueado = [SELECT Cpf__c, Produtos_Bloqueados__c FROM Account LIMIT 1];
        accBloqueado.Produtos_Bloqueados__c = 'PROD1';
        update accBloqueado;
        
        Test.startTest();
        // Cenário 3: Produto é null
        Boolean resultado3 = CtrPropostaSniper.cpfBloqueado(accBloqueado.Cpf__c, null);
        System.assertEquals(false, resultado3, 'O status deve ser false quando CodProduto for null');
        Test.stopTest(); 
    }
    
    @IsTest
    static void testCpfBloqueado4() {
        Test.startTest();
        // Cenário 4: CPF não está associado a nenhuma conta
        Boolean resultado4 = CtrPropostaSniper.cpfBloqueado('99999999999', 'PROD1');
        System.assertEquals(false, resultado4, 'CPF não existente deve retornar false');
        Test.stopTest(); 
    }
    
    
    @IsTest
    static void testGetAPIOrquestrador() {
        String jsonRequest = '{"idExterno":"00006767", "metadados": {"codigo_empresa": "0001", "auth_type": "MULTI"}}';

        Test.startTest();
        String mockTokenResponse = '{"access_token":"mockAccessToken","token_type":"Bearer"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockTokenResponse, 200, 'OK'));
        String mockLinkPgtoResponse = '{"linkPagamento":"https://example.com/payment-link"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockLinkPgtoResponse, 200, 'OK'));
        String responseBody = CtrPropostaSniper.getAPIOrquestrador(jsonRequest);
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAntecipCom() {
        Test.startTest();
        String listAntecipacao = CtrPropostaSniper.getAntecipCom('00006767');
        Test.stopTest();
        System.Debug('listAntecipacao '+listAntecipacao);
    }
    
    @IsTest
    static void testEnviarEmail() {
        CtrPropostaSniper classeInstancia = new CtrPropostaSniper();
        String mockJsonEmail = '{"email":"teste@teste.com","link":"http://example.com","nome":"João","proposta":"Proposta Teste","corretor":"Corretor Teste"}';
        classeInstancia.jsonEmail = mockJsonEmail;

        Test.startTest();
        classeInstancia.enviarEmail();
        Test.stopTest();
        
        System.assertEquals('Deu sucesso', classeInstancia.retornoEmail, 'O retorno do email deve ser o esperado.');
    }
    
    @IsTest
    static void testGerarHeaderOAuth2ComAutorizacao() {
        String mockHeaderAutorizacao = 'Bearer mockedAccessToken';
        Map<String, String> result = CtrPropostaSniper.gerarHeaderOAuth2(mockHeaderAutorizacao);
        
        System.assertEquals(3, result.size(), 'O mapa de headers deve conter 3 elementos.');
        System.assertEquals('application/json', result.get('Content-Type'), 'O Content-Type deve ser application/json.');
        System.assertEquals('application/json', result.get('Accept'), 'O Accept deve ser application/json.');
        System.assertEquals(mockHeaderAutorizacao, result.get('Authorization'), 'O Authorization deve conter o token mockado.');
    }
    
    @IsTest
    public static void testConsultaOpcoesTipoServicoComConsultaProfissao() {
        List<OpcoesServicoTO> opcoesServicoLst = new List<OpcoesServicoTO>();
        OpcoesServicoTO opcaoServico = new OpcoesServicoTO();
        
        opcaoServico.Id = '12345'; 
        opcaoServico.servico = 'Consulta_Profissao';
        opcaoServico.body = 'Teste Body';
        opcaoServico.metodo = 'GET';

        opcoesServicoLst.add(opcaoServico);
        String jsonOpcaoServico = JSON.serialize(opcoesServicoLst);
        String mockResponseOpcaoProfissao = '{"response":"mocked profession data"}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockResponseOpcaoProfissao, 200, 'OK'));
        CtrPropostaSniper propostaSniper = new CtrPropostaSniper();
        propostaSniper.servicosEntrada = jsonOpcaoServico;
        propostaSniper.consultaOpcoesTipoServico();
        Test.stopTest();

        System.assertNotEquals(null, propostaSniper.opServico, 'O serviço de Consulta Profissão deve retornar uma resposta válida.');
        System.assert(propostaSniper.opServico.contains('mocked profession data'), 'A resposta deve conter os dados mockados da profissão.');
    }
    
    @isTest
    public static void testRetorno2TO() {

        CtrPropostaSniper.Retorno2TO retorno = new CtrPropostaSniper.Retorno2TO();
        
        CtrPropostaSniper.DevolutivasTO devolutivas = new CtrPropostaSniper.DevolutivasTO();
        devolutivas.descricao = 'Descrição Teste';
        devolutivas.codigo = '001';
        
        CtrPropostaSniper.validacoesEstruturaisTO validacoes = new CtrPropostaSniper.validacoesEstruturaisTO();
        validacoes.valido = true;

        CtrPropostaSniper.ProblemasTO problema = new CtrPropostaSniper.ProblemasTO();
        problema.descricao = 'Descrição de Teste';
        problema.codigo = '001';

        validacoes.problemas = new List<CtrPropostaSniper.ProblemasTO>{ problema };
        retorno.validacoesEstruturais = validacoes;
        
        System.assertEquals('Descrição de Teste', retorno.validacoesEstruturais.problemas[0].descricao);
    }
    
    @isTest
    static void testGetQuote() {
        Product2 produtoTeste = TestDataFactory.gerarProdutoTecnico();
        produtoTeste.Status__c = 'Ativo';
        produtoTeste.ProductCode = 'VI-PESSOAS'; 
        produtoTeste.Segmento__c = 'Individual';
        update produtoTeste;
        
        Quote quote = [SELECT Name FROM Quote LIMIT 1];
        quote.Produto__c = produtoTeste.Id;
        quote.Status = 'Enviada';
        quote.PropostaPdfDownloadUrl__c = 'http://teste.com';
        update quote;
        
        Test.startTest();
        String resultado = CtrPropostaSniper.getQuote(quote.Name);
        System.debug('resultado ' + resultado);
        Test.stopTest();

        System.assertNotEquals('', resultado, 'O resultado não deveria ser vazio');
    }
    
    @isTest
    static void testGetQuote2() {
        Product2 produtoTeste = TestDataFactory.gerarProdutoTecnico();
        produtoTeste.Status__c = 'Ativo';
        produtoTeste.ProductCode = 'VI-PESSOAS'; 
        produtoTeste.Segmento__c = 'Individual';
        update produtoTeste;
        
        Quote quote = [SELECT Name FROM Quote LIMIT 1];
        quote.Produto__c = produtoTeste.Id;
        quote.Status = 'Recusada';
        quote.CodigoMotivoDevolucao__c = '14';
        quote.PropostaPdfDownloadUrl__c = 'http://teste.com';
        update quote;
        
        Test.startTest();
        String resultado = CtrPropostaSniper.getQuote(quote.Name);
        Test.stopTest();
        
        System.assertEquals('Proposta Recusada', resultado);
    }
    
    @isTest
    static void testGetQuote3() {
        Product2 produtoTeste = TestDataFactory.gerarProdutoTecnico();
        produtoTeste.Status__c = 'Ativo';
        produtoTeste.ProductCode = 'VI-PESSOAS'; 
        produtoTeste.Segmento__c = 'Individual';
        update produtoTeste;
        
        Quote quote = [SELECT Name FROM Quote LIMIT 1];
        quote.Produto__c = produtoTeste.Id;
        quote.Status = 'Enviada';
        update quote;
        
        Test.startTest();
        String resultado = CtrPropostaSniper.getQuote(quote.Name);
        Test.stopTest();

        System.assertEquals('', resultado, 'O resultado deveria ser vazio');
    }
    
    /*
	@isTest
    static void testGetUrlSampleMed() {

        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];

        Garantia__c garantia = new Garantia__c(
            Name = 'Garantia Teste',
            Sigla__c = 'GRT'
        );
        insert garantia;

        GarantiaProposta__c garantiaProposta = new GarantiaProposta__c(
            Proposta__c = proposta.Id,
            Capital__c = 10000,
            Garantia__c = garantia.Id
        );
        insert garantiaProposta;
        
        ContratanteProposta__c contratanteProposta = new ContratanteProposta__c(
            Proposta__c = proposta.Id
        );
        insert contratanteProposta;
        
        GrupoProposta__c grupoProposta = new GrupoProposta__c(
            ContratanteProposta__c = contratanteProposta.Id
        );
        insert grupoProposta;
        
        Profissao__c profissao = new Profissao__c(Codigo__c = 'Prof001');
        insert profissao;

        SeguradoProposta__c segurado = new SeguradoProposta__c(
            GrupoProposta__c = grupoProposta.Id,
            Profissao__c = profissao.Id
        );
        insert segurado;

        RemuneracaoProposta__c remuneracao = new RemuneracaoProposta__c(
            Proposta__c = proposta.Id
        );
        insert remuneracao;

        FavorecidoRemuneracaoProposta__c favorecido = new FavorecidoRemuneracaoProposta__c(
            RemuneracaoProposta__c = remuneracao.Id,
            CorretorResponde__c = true
        );
        insert favorecido;

        CriticaProposta__c critica = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            Acao__c = 'auto',
            Status__c = 'Não iniciada',
            MomentoAnalise__c = 'Subscrição',
            Codigo__c = '75'
        );
        insert critica;


        Test.startTest();
        String mockResponse = '{"SuccessEntries":[{"Applicant":{"questionnaire_url":"http://example.com"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockResponse, 200, 'OK'));
        String retorno = CtrPropostaSniper.getUrlSampleMed(proposta.Name);
        Test.stopTest();

        System.assertNotEquals(retorno, null, 'A URL de retorno não deve ser nula');
    }*/
    
    @isTest
    static void testConsultaRendaVidaON() {
        String mockResponse = '[{"codigo": "001", "descricao": "Renda A"}, {"codigo": "002", "descricao": "Renda B"}]';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockResponse, 200, 'OK'));
        String resultado = CtrPropostaSniper.consultaRendaVidaON();
        Test.stopTest();
    }
    
    @isTest
    static void testConsultaDadosPagOriginal2() {
        Account account = [SELECT Id, Name, Cpf__c, PersonEmail, PersonMobilePhone, Phone, Sexo__c, PersonBirthdate, EstadoCivil__c FROM Account LIMIT 1];
    
        Contract contrato = new Contract(
            AccountId = account.Id,
            Status = 'Em elaboração', 
            StartDate = Date.today(),
            IdExterno__c = 'Contrato-12345'
        );
        insert contrato;
        
        CartaoCredito__c cartaoCredito = new CartaoCredito__c(
            CartoPortoSeguro__c = true,
            CodigoSeguranca__c = '123',
            NomeTitular__c = 'Titular Teste',
            NumeroCartao__c = '4111111111111111',
            Vencimento__c = '01-01-2025',
            Bandeira__c = 'Visa', 
            Conta__c = account.Id
        );
        insert cartaoCredito;
        
        InformacaoBancaria__c informacaoBancaria = new InformacaoBancaria__c(
            Agencia__c = '1234',
            Digito__c = '1',
            NumeroConta__c = '123456-7',
            TipoPessoa__c = 'Fisica',
            Conta__c = account.Id
        );
        insert informacaoBancaria;
        
        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
            Conta__c = account.Id,
            CartaoCredito__c = cartaoCredito.Id,
            InformacaoBancaria__c = informacaoBancaria.Id,
            Contrato__c = contrato.Id,
            TipoResponsavelPagamento__c = 'CON',
            VigenciaInicial__c = Date.today()
        );
        insert contratanteContrato;
        
        GrupoContrato__c grupoContrato = new GrupoContrato__c(
            ContratanteContrato__c = contratanteContrato.Id
        );
        insert grupoContrato;
        
        SeguradoContrato__c seguradoContrato = new SeguradoContrato__c(
            NomeResponsavel__c = 'Responsável Financeiro',
            CpfResponsavel__c = '12345678901',
            vinculoComSegurado__c = 'Responsável',
            ResponsavelFinanceiroSeguro__c = true,
            ResponsavelPagamento__c = account.Id,
            GrupoContrato__c = grupoContrato.Id
        );
        insert seguradoContrato;

        CtrPropostaSniper sniper = new CtrPropostaSniper();
        sniper.apoliceContratoOriginal = 'Contrato-12345';
        Test.startTest();
        sniper.consultaDadosPagOriginal();
        Test.stopTest();
        
        System.assertNotEquals(sniper.dadosPagamento, null, 'Os dados de pagamento não devem ser nulos');
    }
    
    @isTest
    static void testConsultaCepRemote() {
        String entradaServicoCep = '12345000'; // Simulando apenas o CEP
        String tipoCep = 'someTipoCep';

        String mockResponse = '';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockResponse, 200, 'OK'));
        
        Test.startTest();
        String retorno = CtrPropostaSniper.consultaCepRemote(entradaServicoCep, tipoCep);
        Test.stopTest();
        
        System.assertEquals('', retorno, 'O retorno do serviço deve ser vazio');
    }
    //VIAG-301 FIM
    
}