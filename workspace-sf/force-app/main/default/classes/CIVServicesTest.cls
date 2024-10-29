@isTest
private class CIVServicesTest {
    
    @testSetup 
    static void setup(){
        TestDataFactory.gerarDadosSetup();
    }
    
    @isTest
    public static void testTransmitirProposta(){
        
        List<EmissaoTO> lstEmissaoTO = new List<EmissaoTO>();
        EmissaoTO emissaoTO = new EmissaoTO();
        emissaoTO.origemOriginal = 0;
        emissaoTO.numeroOriginal = '040';
        //emissaoTO.Name = 'teste';
        emissaoTO.canalDistribuicao = 'teste';
        emissaoTO.parceiro = 'teste';
        emissaoTO.tipoResponsavelPagamento = 'teste';
        emissaoTO.tipoBeneficiario = '';
        emissaoTO.idContratoParceiro = 'teste';
        emissaoTO.idContratanteParceiro = 'teste';
        emissaoTO.origem = 0;
        emissaoTO.numero = 'teste';
        
        lstEmissaoTO.add(emissaoTO);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(emissaoTO), 200, 'OK'));
        Test.startTest();
        
        CIVServices services = CIVServices.getInstance();
        RetornoPropostaRestTO retorno = services.transmitirProposta(lstEmissaoTO);
        
        Test.stopTest();
        System.assertEquals(true, (retorno != null));
         
	}
	
	@isTest 
    public static void testTransmitirPropostaErro(){
        
        List<EmissaoTO> lstEmissaoTO = new List<EmissaoTO>();
        EmissaoTO emissaoTO = new EmissaoTO();
        emissaoTO.origemOriginal = 0;
        emissaoTO.numeroOriginal = '';
        
        emissaoTO.canalDistribuicao = '';
        emissaoTO.parceiro = '';
        emissaoTO.tipoResponsavelPagamento = '';
        emissaoTO.tipoBeneficiario = '';
        emissaoTO.idContratoParceiro = '';
        emissaoTO.idContratanteParceiro = '';
        emissaoTO.origem = 0;
        emissaoTO.numero = '';
        
		lstEmissaoTO.add(emissaoTO);
		
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
			CIVServices services = CIVServices.getInstance();
			RetornoPropostaRestTO retorno = services.transmitirProposta(lstEmissaoTO);
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro'));
        }
        
        Test.stopTest();       
        
    }
    
    @isTest
    public static void testEmitirContrato(){
        
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
        
        ContratoTO.FavorecidosTO favorecido = new ContratoTO.FavorecidosTO();
        favorecido.papel = '';
        favorecido.participacao = 0;
        favorecido.corretorLider = true;
        favorecido.susepOficialCorretor = '';
        favorecido.susepEmissao  = '';
        favorecido.susepOrcamento  = '';
        favorecido.pessoa = new ContratoTO.PessoaTO();
        favorecido.pessoa.nome = '';
        favorecido.pessoa.tipo = '';
        favorecido.pessoa.email = '';
        
        ContratoTO.TelefonesTO telefone = new ContratoTO.TelefonesTO();
        telefone.tipoTelefone = '';
        telefone.numeroTelefone = '';
        telefone.dddTelefone = '';
        favorecido.pessoa.telefones = new List<ContratoTO.TelefonesTO>();
        favorecido.pessoa.telefones.add(telefone);
        
        ContratoTO.EnderecosTO endereco = new ContratoTO.EnderecosTO();
        endereco.tipoLogradouro = '';
        endereco.cidade = '';
        endereco.tipoEndereco = '';
        endereco.logradouro = '';
        endereco.bairro = '';
        endereco.cep = '';
        endereco.uf = '';
        endereco.numeroLogradouro = '';
        endereco.paisResidencia = '';
        endereco.complementoCep = '';
        favorecido.pessoa.enderecos = new List<ContratoTO.EnderecosTO>();
        favorecido.pessoa.enderecos.add(endereco);
        
        favorecido.pessoa.dadosPessoaFisica = new ContratoTO.DadospessoafisicaTO();
        favorecido.pessoa.dadosPessoaFisica.sexo = '';
        favorecido.pessoa.dadosPessoaFisica.nacionalidade = '';
        favorecido.pessoa.dadosPessoaFisica.estadoCivil = '';
        favorecido.pessoa.dadosPessoaFisica.digitoCpf = '';
        favorecido.pessoa.dadosPessoaFisica.dataNascimento = '';
        favorecido.pessoa.dadosPessoaFisica.numeroCpf = '';
        
        favorecido.pessoa.dadosPessoaJuridica = new ContratoTO.DadospessoajuridicaTO();
        favorecido.pessoa.dadosPessoaJuridica.digitoCnpj = '';
        favorecido.pessoa.dadosPessoaJuridica.numeroCnpj = '';
        favorecido.pessoa.dadosPessoaJuridica.ordemCnpj = '';
        
        ContratoTO.RemuneracoesTO remuneracao = new ContratoTO.RemuneracoesTO();
        remuneracao.tipoRemuneracao = '';
        remuneracao.percentual = 0;
        remuneracao.favorecidos = new List<ContratoTO.FavorecidosTO>();
        remuneracao.favorecidos.add(favorecido);
        
        payload.contrato.remuneracoes = new List<ContratoTO.RemuneracoesTO>();
        payload.contrato.remuneracoes.add(remuneracao);
        
        payload.contrato.precificacao = new ContratoTO.PrecificacaoTO();
        
        ContratoTO.CoberturasTO cobertura = new ContratoTO.CoberturasTO();
        payload.contrato.precificacao.coberturas = new List<ContratoTO.CoberturasTO>();
        payload.contrato.precificacao.coberturas.add(cobertura);
        
        
        
        
        
        
        
        //public List<RemuneracoesTO> remuneracoes { get; set; }
        
        
        //List<ContratoTO.SeguradosTO> lstSegurados = new List<ContratoTO.SeguradosTO>();
        
        
        //public List<SeguradosTO> segurados { get; set; }
        
        //public PrecificacaoTO precificacao { get; set; }
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK')); //PLV-3393 - INICIO/FIM
        Test.startTest();
        
        CIVServices services = CIVServices.getInstance();
        //PLV-3393 - INICIO - Integração BCP
        //ServiceTO.ContratoTO retorno = services.emitirContrato(payload);
        services.emitirContrato(payload);
        Test.stopTest();
        //System.assertEquals(true, (retorno != null));
        //PLV-3393 - INICIO - Integração BCP
    }
    
    //AVX SP27 - PLV-1673 Teste de valida��o do bloqueio banc�rio 
    @isTest
    public static void testValidarBloqueioBancario(){
        
        ValidarComposicaoBancariaTO validarbloqueiobancario = new ValidarComposicaoBancariaTO();
        validarbloqueiobancario.status = 0;
        validarbloqueiobancario.codigo = '';
        validarbloqueiobancario.mensagem = '';
        validarbloqueiobancario.dataOcorrencia  = '';
        validarbloqueiobancario.fonte = '';
        validarbloqueiobancario.tipo = '';
        validarbloqueiobancario.additionalInfo = '';
        
        validarbloqueiobancario.DadosBancarios = new ValidarComposicaoBancariaTO.DadosBancarios();
        //public Id idConsultaRegistro {get;set;}
        validarbloqueiobancario.DadosBancarios.banco = '';
        validarbloqueiobancario.DadosBancarios.agencia = '';
        validarbloqueiobancario.DadosBancarios.contaCorrente = '';
        validarbloqueiobancario.DadosBancarios.digitoContaCorrente = '';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(validarbloqueiobancario), 200, 'OK'));
        Test.startTest();
        
        CIVServices services = CIVServices.getInstance();
        String retorno = services.validarBloqueioBancario(String.valueOf(validarbloqueiobancario));
        
        Test.stopTest();
    }
    
    @isTest
    public static void testValidarComposicaoBancariaErro(){
        
        ValidarComposicaoBancariaTO validarComposicaoBancaria = new ValidarComposicaoBancariaTO();
        validarComposicaoBancaria.status = 0;
        validarComposicaoBancaria.codigo = '';
        validarComposicaoBancaria.mensagem = '';
        validarComposicaoBancaria.dataOcorrencia  = '';
        validarComposicaoBancaria.fonte = '';
        validarComposicaoBancaria.tipo = '';
        validarComposicaoBancaria.additionalInfo = '';
        
        validarComposicaoBancaria.DadosBancarios = new ValidarComposicaoBancariaTO.DadosBancarios();
        //public Id idConsultaRegistro {get;set;}
        validarComposicaoBancaria.DadosBancarios.banco = '';
        validarComposicaoBancaria.DadosBancarios.agencia = '';
        validarComposicaoBancaria.DadosBancarios.contaCorrente = '';
        validarComposicaoBancaria.DadosBancarios.digitoContaCorrente = '';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();
        
        try {
			CIVServices services = CIVServices.getInstance();
        	String retorno = services.validarComposicaoBancaria(String.valueOf(validarComposicaoBancaria));
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            System.assert(e.getMessage().contains('Erro'));
        }
        
        
        Test.stopTest();
    }
    //MGRC-1657 - INICIO
    //AVX SP27 - PLV-1673 Teste de sucesso, valida��o do nome no Serasa
    // @isTest
    // public static void testServicoConsultaNomeSerasa(){
        
    //     String tipo = 'PF';
    //     String cpf = '12345678900';
        
    //     String mock = '{'+
    //         +'"tipo": "'+tipo+'",'+
    //         +'"cpf/cnpj": "'+cpf+'"}';        
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(mock), 200, 'OK'));
        
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
    //     String retorno = services.servicoconsultanomeserasa(tipo, cpf);
        
    //     Test.stopTest();
    // }
    
    // //AVX SP27 - PLV-1673 Teste de erro, valida��o do bloqueio banc�rio
    // @isTest
    // public static void testServicoConsultaNomeSerasaERRO(){
        
    //     String tipo = 'PF';
    //     String cpf = '12345678900';
        
    //     String mock = '{'+
    //         +'"tipo": "'+tipo+'",'+
    //         +'"cpf/cnpj": "'+cpf+'"}';        
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(mock), 400, 'OK'));
        
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
    //     String retorno = services.servicoconsultanomeserasa(tipo, cpf);
        
    //     Test.stopTest();
    // }
    
    //PLV-1096 - Início - Método criado para aumento de cobertura da classe de teste

    //MGRC-1657 - INICIO
    // @isTest
    // public static void testCriacaodePropostaSinistro(){
        
    //     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //     mock.setStaticResource('MockCriacaoPropostaSinistro');
    //     mock.setStatusCode(200);
    //     mock.setHeader('Content-Type', 'application/json');
        
    //     Test.setMock(HttpCalloutMock.class, mock);
        
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
    //     String retorno = services.criacaodepropostasinistro('Mock');
        
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    //PLV-1096 - Fim - Método criado para aumento de cobertura da classe de teste
    
    //PLV-2687 - Início - Cobertura do metodo CriacaoTransmissao(erro 500)
    
    //MGRC-1657 - INICIO
    // @isTest
    // public static void testCriacaoTransmissao(){
        
    //     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //     mock.setStaticResource('CriacaoTransmissao');
    //     mock.setStatusCode(500);
    //     mock.setHeader('Content-Type', 'application/json');
        
    //     Test.setMock(HttpCalloutMock.class, mock);
        
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
    //     String retorno = services.criacaoTransmissao('Mock');
        
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    //PLV-2687 - Fim - Cobertura do metodo CriacaoTransmissao(erro 500)
    
    //PLV-3667 Início - Cobertura para o método gerarTokenOAuth2Heroku(status 200)
    @isTest
    public static void testgerarTokenOAuth2Heroku200(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('mock'), 200, 'OK'));
        
        Test.startTest();
        
        CIVServices services = CIVServices.getInstance();
        String retorno = services.gerarTokenOAuth2Heroku('Mock');
        
        Test.stopTest();
    }
    
    //PLV-3667 Início - Cobertura para o método calculoOrcamentoOferta
    //MGRC-1657 - INICIO
    // @isTest
    // public static void testCalculoOrcamentoOferta(){
        
    //     ServiceTO.ParamOrcamentoCalculoTO param = new ServiceTO.ParamOrcamentoCalculoTO();
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(param), 200, 'OK'));
        
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
    //     ServiceTO.DataCancelamentoTO retorno = services.calculoOrcamentoOferta(param);
        
    //     Test.stopTest();
    // }

    //PLV-3667 Início - Cobertura para o método consultivoContratacao
    //MGRC-1657 - INICIO
    // @isTest
    // public static void testConsultivoContratacao(){
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('mock'), 200, 'OK'));
        
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
    //     String retorno = services.consultivoContratacao('mock');
        
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM

    //PLV-3667 Início - Cobertura para o método criacaoCalculo
    //MGRC-1657 - INICIO
    // @isTest
    // public static void testCriacaoCalculo(){
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('mock'), 200, 'OK'));
        
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
    //     String retorno = services.criacaoCalculo('mock');
        
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    //PLV-3667 Início - Cobertura para o método opcaoServicos
    //MGRC-1657 - INICIO
    // @isTest
    // public static void testOpcaoServicoso(){
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('mock'), 200, 'OK'));
        
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
        
    //     //PLV-4324 - Inicio
    //     OpcoesServicoTO op = new OpcoesServicoTO();
    //     op.id = 'mock';
    //     op.servico = 'Consulta_Profissao'; //PLV-4779 - INÍCIO/FIM
    //     op.body = null;
    //     op.metodo = 'GET';
    //     String retorno = services.opcaoServicos(op);
    //     //PLV-4324 - Fim
        
    //     Test.stopTest();
    // }
    //PLV-3667 Início - Cobertura para o método consultarOferta

    // @isTest
    // public static void testConsultarOferta(){
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('mock'), 200, 'OK'));
        
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
    //     String retorno = services.consultarOferta('mock');
        
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    //PLV-3667 Início - Cobertura para o método calculoPropostaTransmissao
    @isTest
    public static void testCalculoPropostaTransmissao(){
        
        ServiceTO.ParamPropostaCalculoTO param = new ServiceTO.ParamPropostaCalculoTO();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(param), 200, 'OK'));
        
        Test.startTest();
        
        CIVServices services = CIVServices.getInstance();
        RetornoPropostaRestTO.ValidacaopropostaTO retorno = services.calculoPropostaTransmissao(param);
        
        Test.stopTest();
    }
    
    //PLV-4361 INICIO
    //MGRC-1657 - INICIO
    // @isTest 
    // public static void criacaoPropostaSamplemedTest() {
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('mock'), 200, 'OK'));
        
    //     Test.startTest();
        
    //     CIVServices.getInstance().criacaoPropostaSampleMed('mock');
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    // PLV-4361 FIM
    // PLV-4516 INICIO

    //MGRC-1657 - INICIO
    // @isTest 
    // public static void enviarSinistroEmRegulacaoTest() {
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('mock'), 200, 'OK'));
        
    //     Test.startTest();
        
    //     CIVServices.getInstance().enviarSinistroEmRegulacao('{}');
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM

    //PLV-4516 FIM
    //MGRC-1657 - INICIO
    //PLV-1096 - Início - Método criado para aumento de cobertura da classe de teste
    // @isTest
    // public static void testCriacaodeOrcamentoSinistro(){
        
    //     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //     mock.setStaticResource('MockCriacaoOrcamentoSinistro');
    //     mock.setStatusCode(200);
    //     mock.setHeader('Content-Type', 'application/json');
        
    //     Test.setMock(HttpCalloutMock.class, mock);
        
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
    //     String retorno = services.criacaodeorcamentosinistro('Mock');
        
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    //PLV-1096 - Fim - Método criado para aumento de cobertura da classe de teste

    //PLV-1096 - Início - Método criado para aumento de cobertura da classe de teste
    // @isTest
    // public static void testServicoConsultaODM(){
        
    //     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //     mock.setStaticResource('MockConsultaODM');
    //     mock.setStatusCode(200);
    //     mock.setHeader('Content-Type', 'application/json');
        
    //     Test.setMock(HttpCalloutMock.class, mock);
        
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
    //     String retorno = services.servicoConsultaODM('Mock');
        
    //     Test.stopTest();
    // }
    //PLV-1096 - Fim - Método criado para aumento de cobertura da classe de teste
    //MGRC-1657 - FIM
    
    //INICIO - Cobertura de classe de teste - Guilherme Brito 

    @isTest
    public static void testCalculoPropostaTransmissaoErroCatch(){
        
        ServiceTO.ParamPropostaCalculoTO param = new ServiceTO.ParamPropostaCalculoTO();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(param), 503, 'Bad Request'));
        
        Test.startTest();
        
        try {
			CIVServices services = CIVServices.getInstance();
        	RetornoPropostaRestTO.ValidacaopropostaTO retorno = services.calculoPropostaTransmissao(param);
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('nullERROR'));
        }
        
        Test.stopTest();
    }

    //MGRC-1657 - INICIO
    // @isTest
    // public static void testServicoConsultaODMErro(){
        
    //     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //     mock.setStaticResource('MockConsultaODM');
    //     mock.setStatusCode(503);
    //     mock.setHeader('Content-Type', 'application/json');
        
    //     Test.setMock(HttpCalloutMock.class, mock);
        
    //     Test.startTest();
	// 	try {
	// 		CIVServices services = CIVServices.getInstance();
    //     	String retorno = services.servicoConsultaODM('Mock');
    //     }
    //     catch(Exception e) {
    //         System.assert(e.getMessage().contains('nullERROR'));
    //     }        
        
        
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM

    @isTest 
    public static void testEmitirContratoErro(){
        
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
        
        ContratoTO.FavorecidosTO favorecido = new ContratoTO.FavorecidosTO();
        favorecido.papel = '';
        favorecido.participacao = 0;
        favorecido.corretorLider = true;
        favorecido.susepOficialCorretor = '';
        favorecido.susepEmissao  = '';
        favorecido.susepOrcamento  = '';
        favorecido.pessoa = new ContratoTO.PessoaTO();
        favorecido.pessoa.nome = '';
        favorecido.pessoa.tipo = '';
        favorecido.pessoa.email = '';
        
        ContratoTO.TelefonesTO telefone = new ContratoTO.TelefonesTO();
        telefone.tipoTelefone = '';
        telefone.numeroTelefone = '';
        telefone.dddTelefone = '';
        favorecido.pessoa.telefones = new List<ContratoTO.TelefonesTO>();
        favorecido.pessoa.telefones.add(telefone);
        
        ContratoTO.EnderecosTO endereco = new ContratoTO.EnderecosTO();
        endereco.tipoLogradouro = '';
        endereco.cidade = '';
        endereco.tipoEndereco = '';
        endereco.logradouro = '';
        endereco.bairro = '';
        endereco.cep = '';
        endereco.uf = '';
        endereco.numeroLogradouro = '';
        endereco.paisResidencia = '';
        endereco.complementoCep = '';
        favorecido.pessoa.enderecos = new List<ContratoTO.EnderecosTO>();
        favorecido.pessoa.enderecos.add(endereco);
        
        favorecido.pessoa.dadosPessoaFisica = new ContratoTO.DadospessoafisicaTO();
        favorecido.pessoa.dadosPessoaFisica.sexo = '';
        favorecido.pessoa.dadosPessoaFisica.nacionalidade = '';
        favorecido.pessoa.dadosPessoaFisica.estadoCivil = '';
        favorecido.pessoa.dadosPessoaFisica.digitoCpf = '';
        favorecido.pessoa.dadosPessoaFisica.dataNascimento = '';
        favorecido.pessoa.dadosPessoaFisica.numeroCpf = '';
        
        favorecido.pessoa.dadosPessoaJuridica = new ContratoTO.DadospessoajuridicaTO();
        favorecido.pessoa.dadosPessoaJuridica.digitoCnpj = '';
        favorecido.pessoa.dadosPessoaJuridica.numeroCnpj = '';
        favorecido.pessoa.dadosPessoaJuridica.ordemCnpj = '';
        
        ContratoTO.RemuneracoesTO remuneracao = new ContratoTO.RemuneracoesTO();
        remuneracao.tipoRemuneracao = '';
        remuneracao.percentual = 0;
        remuneracao.favorecidos = new List<ContratoTO.FavorecidosTO>();
        remuneracao.favorecidos.add(favorecido);
        
        payload.contrato.remuneracoes = new List<ContratoTO.RemuneracoesTO>();
        payload.contrato.remuneracoes.add(remuneracao);
        
        payload.contrato.precificacao = new ContratoTO.PrecificacaoTO();
        
        ContratoTO.CoberturasTO cobertura = new ContratoTO.CoberturasTO();
        payload.contrato.precificacao.coberturas = new List<ContratoTO.CoberturasTO>();
        payload.contrato.precificacao.coberturas.add(cobertura);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();
        
        try {
			CIVServices services = CIVServices.getInstance();
        	services.emitirContrato(payload);
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro'));
        }
        Test.stopTest();
    }

    @isTest
    public static void testValidarComposicaoBancaria(){
        
        ValidarComposicaoBancariaTO validarComposicaoBancaria = new ValidarComposicaoBancariaTO();
        validarComposicaoBancaria.status = 0;
        validarComposicaoBancaria.codigo = '';
        validarComposicaoBancaria.mensagem = '';
        validarComposicaoBancaria.dataOcorrencia  = '';
        validarComposicaoBancaria.fonte = '';
        validarComposicaoBancaria.tipo = '';
        validarComposicaoBancaria.additionalInfo = '';
        
        validarComposicaoBancaria.DadosBancarios = new ValidarComposicaoBancariaTO.DadosBancarios();
        //public Id idConsultaRegistro {get;set;}
        validarComposicaoBancaria.DadosBancarios.banco = '';
        validarComposicaoBancaria.DadosBancarios.agencia = '';
        validarComposicaoBancaria.DadosBancarios.contaCorrente = '';
        validarComposicaoBancaria.DadosBancarios.digitoContaCorrente = '';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(validarComposicaoBancaria), 200, 'OK'));
        Test.startTest();
        
        CIVServices services = CIVServices.getInstance();
        String retorno = services.validarComposicaoBancaria(String.valueOf(validarComposicaoBancaria));
        
        Test.stopTest();
        System.assertEquals(true, (retorno != null));  
    }

    @isTest
    public static void testValidarBloqueioBancarioErro(){
        
        ValidarComposicaoBancariaTO validarbloqueiobancario = new ValidarComposicaoBancariaTO();
        validarbloqueiobancario.status = 0;
        validarbloqueiobancario.codigo = '';
        validarbloqueiobancario.mensagem = '';
        validarbloqueiobancario.dataOcorrencia  = '';
        validarbloqueiobancario.fonte = '';
        validarbloqueiobancario.tipo = '';
        validarbloqueiobancario.additionalInfo = '';
        
        validarbloqueiobancario.DadosBancarios = new ValidarComposicaoBancariaTO.DadosBancarios();
        //public Id idConsultaRegistro {get;set;}
        validarbloqueiobancario.DadosBancarios.banco = '';
        validarbloqueiobancario.DadosBancarios.agencia = '';
        validarbloqueiobancario.DadosBancarios.contaCorrente = '';
        validarbloqueiobancario.DadosBancarios.digitoContaCorrente = '';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 503, 'Bad request'));
        Test.startTest();
        
        try {
			CIVServices services = CIVServices.getInstance();
        	String retorno = services.validarBloqueioBancario(String.valueOf(validarbloqueiobancario));
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('nullERROR'));
        }
        
        Test.stopTest();
    }

    //MGRC-1657 - INICIO
    // @isTest
    // public static void testServicoConsultaNomeSerasaERROCatch(){
        
    //     String tipo = 'PF';
    //     String cpf = '12345678900';
        
    //     String mock = '{'+
    //         +'"tipo": "'+tipo+'",'+
    //         +'"cpf/cnpj": "'+cpf+'"}';        
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(mock), 503, 'Bad request'));
        
    //     Test.startTest();
        
    //     try {
	// 		CIVServices services = CIVServices.getInstance();
    //     	String retorno = services.servicoconsultanomeserasa(tipo, cpf);
    //     }
    //     catch(Exception e) {
    //         SYstem.debug('PLV-4656 ' + e.getMessage());
    //         System.assert(e.getMessage().contains('nullERROR'));
    //     }
        
    //     Test.stopTest();
    // }
    
    //MGRC-1657 - INICIO
    // @isTest
    // public static void testCriacaodePropostaSinistroErro(){
        
    //     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //     mock.setStaticResource('MockCriacaoPropostaSinistro');
    //     mock.setStatusCode(503);
    //     mock.setHeader('Content-Type', 'application/json');
        
    //     Test.setMock(HttpCalloutMock.class, mock);
        
    //     Test.startTest();
        
    //     try {
	// 		CIVServices services = CIVServices.getInstance();
    //     	String retorno = services.criacaodepropostasinistro('Mock');
    //     }
    //     catch(Exception e) {
    //         System.assert(e.getMessage().contains('nullERROR'));
    //     }
        
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    //MGRC-1657 - INICIO
    // @isTest
    // public static void testCalculoOrcamentoOfertaErro(){
        
    //     ServiceTO.ParamOrcamentoCalculoTO param = new ServiceTO.ParamOrcamentoCalculoTO();
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(param), 503, 'Bad Request'));
        
    //     Test.startTest();
        
    //     try {
	// 		CIVServices services = CIVServices.getInstance();
    //     	ServiceTO.DataCancelamentoTO retorno = services.calculoOrcamentoOferta(param);
    //     }
    //     catch(Exception e) {
    //         SYstem.debug('PLV-4656 ' + e.getMessage());
    //         System.assert(e.getMessage().contains('nullERROR'));
    //     }
        
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    //MGRC-1657 - INICIO
    // @isTest
    // public static void testConsultivoContratacaoErro(){
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('mock'), 500, 'Bad Request'));
        
    //     Test.startTest();
        
    //     try {
	// 		CIVServices services = CIVServices.getInstance();
    //     	String retorno = services.consultivoContratacao('mock');
    //     }
    //     catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
        
    //     Test.stopTest();
    // }

    // @isTest
    // public static void testConsultivoContratacaoErroCatch(){
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('mock'), 503, 'Bad Request'));
        
    //     Test.startTest();
        
    //     try {
	// 		CIVServices services = CIVServices.getInstance();
    //     	String retorno = services.consultivoContratacao('mock');
    //     }
    //     catch(Exception e) {
    //         System.assert(e.getMessage().contains('nullError'));
    //     }
        
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    @isTest
    public static void testCalculoPropostaTransmissaoErro(){
        
        ServiceTO.ParamPropostaCalculoTO param = new ServiceTO.ParamPropostaCalculoTO();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(param), 500, 'Bad Request'));
        
        Test.startTest();
        
        try {
			CIVServices services = CIVServices.getInstance();
        	RetornoPropostaRestTO.ValidacaopropostaTO retorno = services.calculoPropostaTransmissao(param);
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro'));
        }
        
        Test.stopTest();
    }

    //MGRC-1657 - INICIO
    // @isTest
    // public static void testCriacaodeOrcamentoSinistroErro(){
        
    //     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //     mock.setStaticResource('MockCriacaoOrcamentoSinistro');
    //     mock.setStatusCode(503);
    //     mock.setHeader('Content-Type', 'application/json');
        
    //     Test.setMock(HttpCalloutMock.class, mock);
        
        
    //     Test.startTest();
        
        
    //     try {
	// 		CIVServices services = CIVServices.getInstance();
    //     	String retorno = services.criacaodeorcamentosinistro('Mock');
    //     }
    //     catch(Exception e) {
    //         System.assert(e.getMessage().contains('nullERROR'));
    //     }
        
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    //INICIO - PLV-4656 Guilherme Brito 
    
    //MGRC-1657 - INICIO
    // @isTest 
    // public static void consultarCEPTest() {
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"logradouros":[{"codigoLogradouro":1104579,"nomeLogradouro":"Rio Branco","nomeAbreviadoLogradouro":"Av Rio Branco","nomeCorreio":"Porto Seguro - Companhia de Seguros Gerais","nomeAbreviadoCorreio":"Pto Seguro - Companhia S Gerais","numeroCepLogradouro":1205,"numeroCepComplementoLogradouro":905,"textoComplementoLogradouro":" ","codigoLogradouroOrigemExterna":612001,"tipoEnderecamentoPostal":{"codigoTipoEnderecamentoPostal":2,"nomeTipoEnderecamentoPostal":"Grande Usuário Correio"},"tipoLogradouro":{"codigoTipoLogradouro":8,"nomeTipoLogradouro":"Avenida","siglaTipoLogradouro":"Av"},"bairro":{"codigoBairro":53798,"nomeBairro":"Campos Elíseos"},"localidade":{"codigoLocalidade":10551,"nomeLocalidade":"São Paulo","nomeAbreviadoLocalidade":"S Paulo","codigoLocalidadeOrigemExterna":9668,"tipoSituacaoLocalidade":{"codigoTipoSituacaoLocalidade":1,"descricaoTipoSituacaoLocalidade":"codificada em nível de logradouro","ativo":true},"estado":{"codigoEstado":25,"nomeEstado":"São Paulo","siglaEstado":"SP","siglaEstadoOrigemExterna":"26","ativo":true},"codigoLocalidadeMunicipioIbge":"3550308 ","tipoLocalidade":{"codigoTipoLocalidade":1,"nomeTipoLocalidade":"Distrito","codigoTipoLocalidadeOrigemExterna":"M","ativo":true},"ativo":true},"ativo":true}]}', 200, 'OK'));
        
    //     Test.startTest();
    //     CIVServices.getInstance().consultarCEP('{}', '{}');
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    //FIM - PLV-4656 Guilherme Brito 

    //FIM - Cobertura de classe de teste - Guilherme Brito

    //MGRC-1657 - INICIO
    //AV-85 INICIO
    // @isTest
    // public static void testServicoCIVLTMSucesso(){
    //     String jsonSucesso = '{"document": "18091724896", "voucher": "17961495"}';
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonSucesso, 200, 'OK'));
    //     String params = '{"id": "51", "campaignId": "11"}';        
    //     Test.startTest();
    //     String retorno = CIVServices.getInstance().servicoCIVLTM(params);
    //     Test.stopTest();
    //     System.assertEquals(retorno, jsonSucesso);
    // }


    // @isTest
    // public static void testServicoCIVLTMFail(){
    //     String json = '{"document": "18091724896", "voucher": "17961495"}';
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 422, 'OK'));
    //     String params = '{}';        
    //     Test.startTest();
    //     String retorno = CIVServices.getInstance().servicoCIVLTM(params);
    //     Test.stopTest();
    //     System.assertEquals(retorno, 'Erro na requisição');
    // }


    // @isTest
    // public static void testservicoConsultaCPFativoLTMSucesso(){
    //     String jsonSucesso = '{"mensagemRetorno":"Processamento realizado com sucesso","listaSeguros":{"seguroVida":{"codigoFormaPagamento":"41","ramo":"1391","listaParcelaSeguroVida":{"parcelaSeguroVida":{"valorParcela":"145.74925","numeroParcela":"1"}},"linkApolice":"http:\\/\\/washmlvidanova\\/servicosvida\\/obterApolice?param=MSwxMzkxLDE3ODYxNiw1OCwxMzY1","dataTransmissao":"2023-09-18T00:00:00-03:00","nomeComercialProduto":"Porto Vida ON","nomeSegurado":"DANILLO","inicioVigencia":"2023-08-04T00:00:00-03:00","apolice":"178616","sucursal":"1","finalVigencia":"2024-08-03T00:00:00-03:00","listaBeneficiariosSeguro":{"beneficiarioSeguro":{"percentualDistribuicaoCapital":"100"}},"cpf":"33126200826","listaGarantiasContratadas":{"garantiaContratada":[{"nomeGarantia":"Morte","valorCapital":"40000.0"},{"nomeGarantia":"Invalidez Permanente Total ou Parcial por Acidente","valorCapital":"40000.0"}]},"descricaoFormaPagamento":"FRAC. 1A PARCELA CARNE"}},"codigoRetorno":"0","seguroVidaOnAtivo":true}';
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonSucesso, 200, 'OK'));
    //     String params = '{"cpf":"37351525897"}';        
    //     Test.startTest();
    //     String retorno = CIVServices.getInstance().servicoConsultaCPFativoLTM(params);
    //     Test.stopTest();
    //     System.assertEquals(jsonSucesso, retorno);
    // }

    // @isTest
    // public static void testservicoConsultaCPFativoLTMFail(){
    //     String json = '{"mensagemRetorno":"Processamento realizado com sucesso","listaSeguros":{"seguroVida":{"codigoFormaPagamento":"52","ramo":"1391","listaParcelaSeguroVida":{"parcelaSeguroVida":{"valorParcela":"3052.44054","numeroParcela":"1"}},"linkApolice":"http://waststvida/servicosvida/obterApolice?param=MSwxMzkxLDE2NDIzMiw1OCwxMDA3MDk=","dataTransmissao":"2021-01-29T00:00:00-02:00","nomeComercialProduto":"Porto Vida ON","nomeSegurado":"TESTE MARCOS LEONARDO","inicioVigencia":"2021-08-23T00:00:00-03:00","apolice":"164232","sucursal":"1","finalVigencia":"2022-08-22T00:00:00-03:00","listaBeneficiariosSeguro":{"beneficiarioSeguro":{"percentualDistribuicaoCapital":"100"}},"cpf":"37351525897","listaGarantiasContratadas":{"garantiaContratada":[{"nomeGarantia":"Morte","valorCapital":"100000.0"},{"nomeGarantia":"Invalidez Permanente Total ou Parcial por Acidente","valorCapital":"30000.0"}]},"descricaoFormaPagamento":"ADC - TODAS PARCELAS"}},"codigoRetorno":"0","seguroVidaOnAtivo":true}';
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 422, 'OK'));
    //     String params = '{}';        
    //     Test.startTest();
    //     String retorno = CIVServices.getInstance().servicoConsultaCPFativoLTM(params);
    //     Test.stopTest();
    //     System.assertEquals(retorno, 'Erro na requisição');
    // }
    // AV-85 FIM
    //MGRC-1657 - FIM
    // PLV-5230 - INICIO
    //MGRC-1657 - INICIO
    // @isTest
    // public static void testIncluirProdutoVidaOpinSucesso(){
    //     StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadEnvioOPIN' LIMIT 1];
    //     String payload = sr.Body.toString(); 
    //     String jsonSucesso = '{"routed":true}';
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonSucesso, 200, 'OK'));          
    //     Test.startTest();
    //     String retorno = CIVServices.getInstance().incluirProdutoVidaOpin(payload);
    //     Test.stopTest();
    //     System.assertEquals(retorno, jsonSucesso);
    // }


    // @isTest
    // public static void testIncluirProdutoVidaOpinFail(){
    //     String json = '{"Erro na requisição: 422"}';
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 422, 'OK'));
    //     String params = '{}';        
    //     Test.startTest();
    //     try {
    //         String retorno = CIVServices.getInstance().incluirProdutoVidaOpin(params);
    //     } catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
    //     Test.stopTest();        
    // }


    // @isTest
    // public static void testIncluirProdutoVidaOpinErro(){        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
    //     String params = '{';        
    //     Test.startTest();
    //     try {
    //         String retorno = CIVServices.getInstance().incluirProdutoVidaOpin(params);
    //     } catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
    //     Test.stopTest();        
    // }
    //PLV-5230 - FIM
    //MGRC-1657 - FIM
    //MGRC-1657 - INICIO
    // @isTest
    // public static void sendDocusignTest(){
    //     ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();
    //     payload.contrato = new ContratoTO();
        
    //     payload.contrato.segmento = '';
    //     payload.contrato.meioComercializacao = '';
    //     //payload.contrato.idSeguradoParceiro = '';
    //     payload.contrato.codigoEmpresa = '';
    //     payload.contrato.ramoSeguro = '';
    //     payload.contrato.vigenciaInicial = '';
    //     payload.contrato.tipoVigencia = '';
    //     payload.contrato.origem = 0;
    //     payload.contrato.tipoSeguro = '';
    //     payload.contrato.numeroEndosso = 0;
    //     payload.contrato.canalDistribuicao = '';
    //     payload.contrato.nomeEmpresa = '';
    //     payload.contrato.numero = '';
    //     payload.contrato.codigoSucursal = '';
    //     payload.contrato.nomeRamoSeguro = '';
    //     payload.contrato.vigenciaFinal = '';
    //     payload.contrato.valorPremio = 0.0;
    //     payload.contrato.idContratoParceiro = '';
    //     payload.contrato.dataCalculo = '';
    //     payload.contrato.numeroApolice = 0;
    //     payload.contrato.nomeProduto = '';
    //     payload.contrato.codigoProdutoVida = '';
    //     payload.contrato.parceiro = '';
    //     payload.contrato.numeroSusepProduto = '';
    //     payload.contrato.nomeCanalDistribuicao = '';
        
    //     payload.contrato.geracaoApolice = new ContratoTO.GeracaoapoliceTO();
    //     payload.contrato.geracaoApolice.unidadeNegocio = '';
    //     payload.contrato.geracaoApolice.nomeArquivoJasper = '';
    //     payload.contrato.geracaoApolice.leituraApartir = '';
    //     payload.contrato.geracaoApolice.centroDeCustoPagador = '';
    //     payload.contrato.geracaoApolice.tipoExtensaoGerada = '';
    //     payload.contrato.geracaoApolice.idAplicacaoUtilizadora = '';
    //     payload.contrato.geracaoApolice.nomeRelatorioGerado = '';
    //     payload.contrato.geracaoApolice.fileSystem = '';
    //     payload.contrato.geracaoApolice.nomeDiretorioArquivo = '';
    //     payload.contrato.geracaoApolice.assinaturaDiretor = '';
        
    //     payload.contrato.geracaoApolice.arquivo = new ContratoTO.ArquivoTO();
    //     payload.contrato.geracaoApolice.arquivo.textoInformativo = '';
    //     payload.contrato.geracaoApolice.arquivo.mensagemAssistenciaFuneral = '';
    //     payload.contrato.geracaoApolice.arquivo.exibirMensagemRenovacao  = '';
    //     payload.contrato.geracaoApolice.arquivo.mensagemProcessoSusep  = '';
    //     payload.contrato.geracaoApolice.arquivo.numeroProcessoSusepCNSP315  = '';
    //     payload.contrato.geracaoApolice.arquivo.unidadeOperacional  = '';
        
    //     payload.contrato.geracaoApolice.arquivo.observacoes = new ContratoTO.ObservacoesTO();
    //     payload.contrato.geracaoApolice.arquivo.observacoes.condicoesGerais = '';
        
    //     payload.contrato.geracaoApolice.arquivo.cabecalho = new ContratoTO.CabecalhoTO();
    //     payload.contrato.geracaoApolice.arquivo.cabecalho.image = '';       
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK')); 
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();
        
    //     services.sendDocusign('');
    //     Test.stopTest();
    // }

    // @isTest
    // public static void ErrorsendDocusignTest(){        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
    //     String params = '{';        
    //     Test.startTest();
    //     try {
    //         String retorno = CIVServices.getInstance().sendDocusign(params);
    //     } catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
    //     Test.stopTest();        
    // }

    // @isTest
    // public static void proxyAutomacaTest(){
    //     ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();
    //     payload.contrato = new ContratoTO();
        
    //     payload.contrato.segmento = '';
    //     payload.contrato.meioComercializacao = '';
    //     //payload.contrato.idSeguradoParceiro = '';
    //     payload.contrato.codigoEmpresa = '';
    //     payload.contrato.ramoSeguro = '';
    //     payload.contrato.vigenciaInicial = '';
    //     payload.contrato.tipoVigencia = '';
    //     payload.contrato.origem = 0;
    //     payload.contrato.tipoSeguro = '';
    //     payload.contrato.numeroEndosso = 0;
    //     payload.contrato.canalDistribuicao = '';
    //     payload.contrato.nomeEmpresa = '';
    //     payload.contrato.numero = '';
    //     payload.contrato.codigoSucursal = '';
    //     payload.contrato.nomeRamoSeguro = '';
    //     payload.contrato.vigenciaFinal = '';
    //     payload.contrato.valorPremio = 0.0;
    //     payload.contrato.idContratoParceiro = '';
    //     payload.contrato.dataCalculo = '';
    //     payload.contrato.numeroApolice = 0;
    //     payload.contrato.nomeProduto = '';
    //     payload.contrato.codigoProdutoVida = '';
    //     payload.contrato.parceiro = '';
    //     payload.contrato.numeroSusepProduto = '';
    //     payload.contrato.nomeCanalDistribuicao = '';
        
    //     payload.contrato.geracaoApolice = new ContratoTO.GeracaoapoliceTO();
    //     payload.contrato.geracaoApolice.unidadeNegocio = '';
    //     payload.contrato.geracaoApolice.nomeArquivoJasper = '';
    //     payload.contrato.geracaoApolice.leituraApartir = '';
    //     payload.contrato.geracaoApolice.centroDeCustoPagador = '';
    //     payload.contrato.geracaoApolice.tipoExtensaoGerada = '';
    //     payload.contrato.geracaoApolice.idAplicacaoUtilizadora = '';
    //     payload.contrato.geracaoApolice.nomeRelatorioGerado = '';
    //     payload.contrato.geracaoApolice.fileSystem = '';
    //     payload.contrato.geracaoApolice.nomeDiretorioArquivo = '';
    //     payload.contrato.geracaoApolice.assinaturaDiretor = '';
        
    //     payload.contrato.geracaoApolice.arquivo = new ContratoTO.ArquivoTO();
    //     payload.contrato.geracaoApolice.arquivo.textoInformativo = '';
    //     payload.contrato.geracaoApolice.arquivo.mensagemAssistenciaFuneral = '';
    //     payload.contrato.geracaoApolice.arquivo.exibirMensagemRenovacao  = '';
    //     payload.contrato.geracaoApolice.arquivo.mensagemProcessoSusep  = '';
    //     payload.contrato.geracaoApolice.arquivo.numeroProcessoSusepCNSP315  = '';
    //     payload.contrato.geracaoApolice.arquivo.unidadeOperacional  = '';
        
    //     payload.contrato.geracaoApolice.arquivo.observacoes = new ContratoTO.ObservacoesTO();
    //     payload.contrato.geracaoApolice.arquivo.observacoes.condicoesGerais = '';
        
    //     payload.contrato.geracaoApolice.arquivo.cabecalho = new ContratoTO.CabecalhoTO();
    //     payload.contrato.geracaoApolice.arquivo.cabecalho.image = '';        
       
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK')); 
    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();        
    //     services.proxyAutomacao(JSON.serialize(payload));
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM

    //MGRC-1657 - INICIO

    // @isTest
    // public static void criarArquivoTest(){
    //     ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();

    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

    //     Test.startTest();
       
    //     CIVServices services = CIVServices.getInstance();        
    //     services.criarArquivo(JSON.serialize(payload));
    
    //     Test.stopTest();
        

    // }
    //MGRC-1657 - FIM

    // @isTest
    // public static void GerarAtualizacaoMonetariaTest(){
    //     ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();

    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

    //     Test.startTest(); 
        
    //     CIVServices services = CIVServices.getInstance();        
    //     services.GerarAtualizacaoMonetaria(JSON.serialize(payload));
    //     Test.stopTest();
        
    // }

    //MGRC-1657 - INICIO
    // @isTest
    // public static void GeraAtualizacaoTaxaJurosTest(){
    //     ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();

    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();        
    //     services.GeraAtualizacaoTaxaJuros(JSON.serialize(payload));
    //     Test.stopTest();
        
    // }
    //MGRC-1657 - FIM

    //MGRC-1657 - INICIO
    // @isTest
    // public static void integracaoRecalculoPropostaTest(){
    //     ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();

    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();       
    //     services.integracaoRecalculoProposta(JSON.serialize(payload));
    //     Test.stopTest();
        
    // }
    // @isTest
    // public static void integracaoRecalculoPropostaTestError(){        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
    //     String params = '{';        
    //     Test.startTest();
    //     try {
    //         String retorno = CIVServices.getInstance().integracaoRecalculoProposta(params);
    //     } catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
    //     Test.stopTest();        
    // }
    //MGRC-1657 - FIM

    //MGRC-1657 - INICIO
    // @isTest
    // public static void integracaoNovoCartaoTest(){
    //     ServiceTO.NovoCartaoTO payload = new ServiceTO.NovoCartaoTO();

    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();       
    //     services.integracaoNovoCartao(payload);
    //     Test.stopTest();
    // }
    // @isTest
    // public static void integracaoNovoCartaoTestError(){
    //     ServiceTO.NovoCartaoTO payload = new ServiceTO.NovoCartaoTO();
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        
    //     Test.startTest();
    //     CIVServices service = CIVServices.getInstance(); 
    //     try {
    //         service.integracaoNovoCartao(payload);
    //     } catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
    //     Test.stopTest();        
    // }
    //MGRC-1657 - FIM

    //MGRC-1657 - INICIO
    // @isTest
    // public static void integracaoCartaoOfflineTest(){
    //     ServiceTO.CobrancaCartaoOfflineTO payload = new ServiceTO.CobrancaCartaoOfflineTO();

    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();        
    //     services.integracaoCartaoOffline(payload);
    //     Test.stopTest();
    // }

    // @isTest
    // public static void integracaoCartaoOfflineTestError(){
    //     ServiceTO.CobrancaCartaoOfflineTO payload = new ServiceTO.CobrancaCartaoOfflineTO();
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));

    //     Test.startTest();
    //     CIVServices services = CIVServices.getInstance();
    //     try {
    //         services.integracaoCartaoOffline(payload);
    //     } catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM    

    @isTest
    public static void integracaoASTest(){
        ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

        Test.startTest();
        
        CIVServices services = CIVServices.getInstance();        
        services.integracaoAS(JSON.serialize(payload));
        Test.stopTest();
    }

    //MGRC-1657 - INICIO
    // @isTest
    // public static void integracaoASTestError(){
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
    //     String params = '{';        
    //     Test.startTest();
    //     try {
    //         String retorno = CIVServices.getInstance().integracaoRecalculoProposta(params);
    //     } catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM

    //MGRC-1657 - INICIO
    // @isTest
    // public static void civLiquidacaoTest(){
    //     ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();

    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();        
    //     services.civLiquidacao(JSON.serialize(payload));
    //     Test.stopTest();
    // }
    // @isTest
    // public static void civLiquidacaoTestError(){
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
    //     String params = '{';        
    //     Test.startTest();
    //     try {
    //         String retorno = CIVServices.getInstance().civLiquidacao(params);
    //     } catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
    //     Test.stopTest();
    // }

    // @isTest
    // public static void consultaSessaoLegadoTest(){
    //     ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();

    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();        
    //     services.consultaSessaoLegado(JSON.serialize(payload));
    //     Test.stopTest();
    // }
    // @isTest
    // public static void consultaSessaoLegadoTestError(){
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
    //     String params = '{';        
    //     Test.startTest();
    //     try {
    //         String retorno = CIVServices.getInstance().consultaSessaoLegado(params);
    //     } catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
    //     Test.stopTest();
    // }
    //MGRC-1657 - INICIO
    // @isTest
    // public static void enviaSinistroBCPTest(){
    //     ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();

    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();    
    //     services.enviaSinistroBCP(JSON.serialize(payload));
    //     Test.stopTest();
    // }
    // @isTest
    // public static void enviaSinistroBCPTestError(){
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
    //     String params = '{';        
    //     Test.startTest();
    //     try {
    //         String retorno = CIVServices.getInstance().enviaSinistroBCP(params);
    //     } catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
    //MGRC-1657 - INICIO
    // @isTest
    // public static void consultarDocumentoTest(){
    //     ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();

    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

    //     Test.startTest();
        
    //     CIVServices services = CIVServices.getInstance();        
    //     services.consultarDocumento(JSON.serialize(payload));
    //     Test.stopTest();
    // }
    // @isTest
    // public static void consultarDocumentoTestError(){
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
    //     String params = '{';        
    //     Test.startTest();
    //     try {
    //         String retorno = CIVServices.getInstance().consultarDocumento(params);
    //     } catch(Exception e) {
    //         System.assert(e.getMessage().contains('Erro'));
    //     }
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM
}