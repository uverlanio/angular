@isTest
private class F5ServiceTest {
    //INICIO - PLV-4656 Guilherme Brito
    //PLV-2942 - Inicio - teste consulta
    static void testEstruturaObjLogradouros() {
        F5Service.ObjLogradouros ObjLogradourosMock = new F5Service.ObjLogradouros();
        ObjLogradourosMock.logradouros = new List<F5Service.Logradouros>();
        
        F5Service.TipoEnderecamentoPostal TipoEnderecamentoPostalMock = new F5Service.TipoEnderecamentoPostal();
        TipoEnderecamentoPostalMock.codigoTipoEnderecamentoPostal = 1;
        TipoEnderecamentoPostalMock.nomeTipoEnderecamentoPostal = 'Mock';

        F5Service.tipoLogradouro tipoLogradouroMock = new F5Service.tipoLogradouro();
        tipoLogradouroMock.codigoTipoLogradouro = 1;
        tipoLogradouroMock.nomeTipoLogradouro = 'Mock';
        tipoLogradouroMock.siglaTipoLogradouro = 'Mock';

        F5Service.bairro bairroMock = new F5Service.bairro();
        bairroMock.codigoBairro = 1;
        bairroMock.nomeBairro = 'Mock';

        F5Service.TipoSituacaoLocalidade TipoSituacaoLocalidadeMock = new F5Service.TipoSituacaoLocalidade();
        TipoSituacaoLocalidadeMock.ativo = true;
        TipoSituacaoLocalidadeMock.codigoTipoSituacaoLocalidade = 1;
        TipoSituacaoLocalidadeMock.descricaoTipoSituacaoLocalidade = 'Mock';

        F5Service.Estado EstadoMock = new F5Service.Estado();
        EstadoMock.codigoEstado	= 1;
		EstadoMock.nomeEstado = 'Mock';
		EstadoMock.siglaEstado = 'Mock';
		EstadoMock.siglaEstadoOrigemExterna = 'Mock';
        EstadoMock.ativo = true;
        
        F5Service.tipoLocalidade tipoLocalidadeMock = new F5Service.tipoLocalidade();
        tipoLocalidadeMock.ativo = true;
        tipoLocalidadeMock.codigoTipoLocalidade = 1;
        tipoLocalidadeMock.codigoTipoLocalidadeOrigemExterna = '1';
        tipoLocalidadeMock.nomeTipoLocalidade = 'Mock';

        F5Service.localidade localidadeMock = new F5Service.localidade();
        localidadeMock.codigoLocalidade = 1;
        localidadeMock.nomeLocalidade = 'Mock';
        localidadeMock.nomeAbreviadoLocalidade = 'Mock';
        localidadeMock.codigoLocalidadeOrigemExterna = 1;
        localidadeMock.tipoSituacaoLocalidade = TipoSituacaoLocalidadeMock;
        localidadeMock.estado = EstadoMock;
        localidadeMock.codigoLocalidadeMunicipioIbge = 'Mock';
        localidadeMock.ativo = true;
        localidadeMock.tipoLocalidade = tipoLocalidadeMock;

        F5Service.Logradouros LogradourosMock = new F5Service.Logradouros();
        LogradourosMock.codigoLogradouro = 1;
		LogradourosMock.nomeLogradouro = 'Mock';
		LogradourosMock.nomeAbreviadoLogradouro = 'Mock';
		LogradourosMock.numeroCepLogradouro = 1;
		LogradourosMock.numeroCepComplementoLogradouro = 1;	
		LogradourosMock.textoComplementoLogradouro = 'Mock';
		LogradourosMock.codigoLogradouroOrigemExterna = 1;
		LogradourosMock.tipoEnderecamentoPostal = TipoEnderecamentoPostalMock;
		LogradourosMock.tipoLogradouro = tipoLogradouroMock;
		LogradourosMock.bairro = bairroMock;
        LogradourosMock.localidade = localidadeMock;
        LogradourosMock.ativo = true;
    }

    @isTest 
    static void testeConsultaCartao() {
        //Gera payloa de saida
        ConsultaCartaoTO.PostTO payload = new ConsultaCartaoTO.PostTO();
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.bonusSeguro = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.codCanal = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.codProduto = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.codRamoSolicitante = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.cpf = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.dataNasc = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.deptoSolicitante = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.idadeInformacao = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.nome = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.premio = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.ramoProduto = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.score = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.sistemaOrigem = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.susep = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.tipoCanal = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.tipoEndosso = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.tipoPessoa = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.tipoPlano = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.tipoSistema = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.uf = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.clienteComRestricao = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.scoreCsb8 = '';

        //Gera payload de resposta
        ConsultaCartaoTO.ResponseTO respostaServico = new ConsultaCartaoTO.ResponseTO();
        respostaServico.ofertarEConsultarCartaoResponse.codRetorno = '1212';
        respostaServico.ofertarEConsultarCartaoResponse.msgRetorno = '';
        respostaServico.ofertarEConsultarCartaoResponse.devolutivaOferta = '5';
        respostaServico.ofertarEConsultarCartaoResponse.prioridadeBandeira = '6';
        respostaServico.ofertarEConsultarCartaoResponse.codigoRetorno = '21';
        respostaServico.ofertarEConsultarCartaoResponse.mensagemRetorno = 'Sucesso';


        //Gera resposta do serviço
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(respostaServico), 200, 'OK'));
        Test.startTest();

        ConsultaCartaoTO.ResponseTO resposta = F5Service.getInstance().consultarCartao(payload);

        Test.stopTest();

        //Verifica se algum municipio foi criado
        System.assertEquals(resposta.ofertarEConsultarCartaoResponse.codRetorno, respostaServico.ofertarEConsultarCartaoResponse.codRetorno);
    }

    @isTest
    static void testarErroConsultaCartao() {
        //Gera payloa de saida
        ConsultaCartaoTO.PostTO payload = new ConsultaCartaoTO.PostTO();
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.bonusSeguro = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.codCanal = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.codProduto = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.codRamoSolicitante = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.cpf = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.dataNasc = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.deptoSolicitante = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.idadeInformacao = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.nome = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.premio = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.ramoProduto = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.score = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.sistemaOrigem = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.susep = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.tipoCanal = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.tipoEndosso = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.tipoPessoa = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.tipoPlano = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.tipoSistema = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.uf = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.clienteComRestricao = '';
        payload.ofertarEConsultarCartao.entradaOfertarEConsultarCartao.scoreCsb8 = '';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
            ConsultaCartaoTO.ResponseTO resposta = F5Service.getInstance().consultarCartao(payload);
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro ao consultar cartões'));
        }
        
        Test.stopTest();
    }  

    @isTest 
    static void testebuscarEmpresasSeguro() {

        ServiceTO.EmpresaSeguroTO respostaServico = new ServiceTO.EmpresaSeguroTO();
        respostaServico.codigoEmpresa = '';
        respostaServico.nomeEmpresa = '';
        respostaServico.numeroCpfCnpj = '';
        respostaServico.ordem = '';
        respostaServico.digitoCpfCnpj = '';
        respostaServico.siglaEmpresa = '';
        respostaServico.codigoPlanoContaContabil = '';
        respostaServico.tipoLivroDiario = '';
        respostaServico.numeroInscricaoEstadual = '';

        //Gera resposta do serviço
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(respostaServico), 200, 'OK'));
        Test.startTest();

        List<ServiceTO.EmpresaSeguroTO> resposta = F5Service.getInstance().buscarEmpresasSeguro();

        Test.stopTest();

        //Verifica se algum municipio foi criado
        //System.assertEquals(resposta.ofertarEConsultarCartaoResponse.codRetorno, respostaServico.ofertarEConsultarCartaoResponse.codRetorno);
    }

    @isTest
    static void testarbuscarEmpresasSeguroErro() {

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
            List<ServiceTO.EmpresaSeguroTO> resposta = F5Service.getInstance().buscarEmpresasSeguro();
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro ao buscar empresas de seguro'));
        }
        
        Test.stopTest();
    }  

    @isTest
    static void testBuscarEnderecoPorUF() {

        //ServiceTO.ObterCidadeUFTO respostaService = new ServiceTO.ObterCidadeUFTO();
        ServiceTO.ObterCidadeUFTO cidadeUf = new ServiceTO.ObterCidadeUFTO();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(cidadeUf), 200, 'OK'));

        Test.startTest();

        F5Service.getInstance().buscarEnderecoPorUF('mock');

        Test.stopTest();
    }

    @isTest
    static void testBuscarEnderecoPorUFErro() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
            F5Service.getInstance().buscarEnderecoPorUF('mock');
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro ao buscar Endereço por UF'));
        }
        
        Test.stopTest();
    }

    @isTest
    static void testbuscarEnderecoPorCEP() {

        ServiceTO.ObterCidadeUFTO respostaService = new ServiceTO.ObterCidadeUFTO();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(respostaService), 200, 'OK'));

        Test.startTest();

        F5Service.getInstance().buscarEnderecoPorCEP('mock', '{}');

        Test.stopTest();
    }

    @isTest
    static void testbuscarEnderecoPorCEPErro() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
            F5Service.getInstance().buscarEnderecoPorCEP('mock', '{}');
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro ao buscar Endereço por CEP'));
        }
        
        Test.stopTest();
    }

    @isTest
    static void testbuscarEnderecoPorLogradouro() {

        ServiceTO.ObterCidadeLogradouroTO respostaService = new ServiceTO.ObterCidadeLogradouroTO();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(respostaService), 200, 'OK'));

        Test.startTest();

        F5Service.getInstance().buscarEnderecoPorLogradouro('mock', '{}', '{}', '{}');

        Test.stopTest();
    }

    @isTest
    static void testbuscarEnderecoPorLogradouroErro() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
            F5Service.getInstance().buscarEnderecoPorLogradouro('mock', '{}', 'a', 'a');
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Logradouro'));
        }
        
        Test.stopTest();
    }

    @isTest
    static void testbuscarFormasPagamento() {

        List<ServiceTO.FormaPagamentoTO> respostaService = new List<ServiceTO.FormaPagamentoTO>();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(respostaService), 200, 'OK'));

        Test.startTest();

        F5Service.getInstance().buscarFormasPagamento('mock', '{}', '{}');

        Test.stopTest();
    }

    @isTest
    static void testbuscarFormasPagamentoErro() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
            F5Service.getInstance().buscarFormasPagamento('mock', '{}', '{}');
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro'));
        }
        
        Test.stopTest();
    }

    @isTest
    static void testbuscarModalidades() {

        ServiceTO.ModalidadeTO respostaService2 = new ServiceTO.ModalidadeTO();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(respostaService2), 200, 'OK'));

        Test.startTest();

        F5Service.getInstance().buscarModalidades('mock');

        Test.stopTest();
    }

    @isTest
    static void testbuscarModalidadesErro() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
            F5Service.getInstance().buscarModalidades('mock');
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro'));
        }
        
        Test.stopTest();
    }

    @isTest
    static void testbuscarMunicipios() {

        List<ServiceTO.MunicipioTO> respostaService3 = new List<ServiceTO.MunicipioTO>();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(respostaService3), 200, 'OK'));

        Test.startTest();

        F5Service.getInstance().buscarMunicipios('mock');

        Test.stopTest();
    }

    @isTest
    static void testbuscarMunicipiosErro() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
            F5Service.getInstance().buscarMunicipios('mock');
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro'));
        }
        
        Test.stopTest();
    }

    @isTest
    static void testbuscarProfissoes() {

        List<ServiceTO.ProfissaoTO> respostaService3 = new List<ServiceTO.ProfissaoTO>();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(respostaService3), 200, 'OK'));

        Test.startTest();

        //F5Service.getInstance().buscarProfissoes();

        Test.stopTest();
    }
	//PLV-4878 INICIO
    @isTest
    static void testbuscarProfissoesErro() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
            F5Service.getInstance().buscarProfissoes();
        }
        catch(Exception e) {
            
        }
        
        Test.stopTest();
    }
	//PLV-4878 FIM
    @isTest
    static void testbuscarRamosAtividade() {

        ServiceTO.RamoAtividadeTO respostaService2 = new ServiceTO.RamoAtividadeTO();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(respostaService2), 200, 'OK'));

        Test.startTest();

        F5Service.getInstance().buscarRamosAtividade();

        Test.stopTest();
    }

    @isTest
    static void testbuscarRamosAtividadeErro() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
            F5Service.getInstance().buscarRamosAtividade();
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro'));
        }
        
        Test.stopTest();
    }

    @isTest
    static void testbuscarRamosSeguro() {

        ServiceTO.RamoSeguroTO respostaService2 = new ServiceTO.RamoSeguroTO();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(respostaService2), 200, 'OK'));

        Test.startTest();

        F5Service.getInstance().buscarRamosSeguro();

        Test.stopTest();
    }

    @isTest
    static void testbuscarRamosSeguroErro() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        Test.startTest();

        try {
            F5Service.getInstance().buscarRamosSeguro();
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Erro'));
        }
        
        Test.stopTest();
    }

    @isTest
    static void testConsultaCep() {

        Test.startTest();
        testEstruturaObjLogradouros();
        F5Service.getInstance().consultaCEP('jsonCEP', 'Mock');

        Test.stopTest();
    }

    //PLV-2942 - Fim	
    //INICIO - PLV-4656 Guilherme Brito
}