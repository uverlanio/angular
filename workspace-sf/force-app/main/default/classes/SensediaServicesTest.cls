@isTest
public with sharing class SensediaServicesTest {
    
    @testSetup static void setup() {
        
        //MGRC-1259 - INICIO
        Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
        
        contact contato = [SELECT Id FROM Contact WHERE AccountId =: contaFisica.Id];
        
        case caso = new case();
        caso.AccountId = contaFisica.Id;
        caso.ContactId = contato.Id;
        caso.Status_Dependente__c = 'Aberto';
		caso.Nome_Segurado__c = 'Teste';
		caso.Cpf_Segurado__c = '075.487.587-87';
		caso.Subject = 'Teste';
		caso.Description = 'Teste';			
		caso.Numero_titulo__c = '14587452';
		caso.Vitima__c = 'Segurado';
		caso.IdPrestadora__c = 'Teste';
		caso.TipoEvento__c = 'Acidente';
		caso.EmpresaSplit__c = 52.5;
		caso.sucursal__c = 'Teste';
		caso.RamoSplit__c = 54.5;
		caso.Numero_Apolice__c  = '102458798754';
		caso.SinistroPrioritario__c = True;
		caso.Origin = 'Backoffice';
        caso.Data_Aviso_Cliente__c = system.today();
        caso.Dataocorrencia__c = system.today();
        insert caso;

    }
    //MGRC-1259 - FIM
    
    //ZSVEP-66 - INICIO  
    //ZSVEP-67 - INICIO  
    private class MockAccessTokenGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"testAccessToken","token_type":"Bearer","expires_in":3600}');
            return res;
        }
    }

    private class MockConsultaCEPGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"logradouro":"Rua Exemplo","cidade":"São Paulo","estado":"SP"}');
            return res;
        }
    }

    @isTest
    static void testConsultarCEP() {
       
        String jsonMock = '{"logradouro":"Rua Exemplo","cidade":"São Paulo","estado":"SP"}';

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonMock, 200, 'OK'));

        SensediaServices sensedia = SensediaServices.getInstance();
        String retorno = sensedia.consultarCEP('09111', '340');

        Test.stopTest();

        System.assert(retorno != '', 'CEP está OK');
    }

    //FNPVVEP-99 - INICIO
    private class MockEnviarDPSResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success", "message": "Success Message"}');
            return res;
        }
    }
    
    @isTest
    static void testEnviarDPS() {

        Test.setMock(HttpCalloutMock.class, new MockEnviarDPSResponse());

        String idProponente = '1234567890';
        String linguagem = 'pt-BR';

        Test.startTest();
        String response = SensediaServices.enviarDPS(idProponente, linguagem);
        Test.stopTest();

        System.assertEquals('Success Message', response, 'The response message should be "Success Message".');
    }
    //FNPVVEP-99 - FIM

    //FNPVVEP-114 INICIO
    @isTest
    static void testcomunicarTelemed() {

        Test.setMock(HttpCalloutMock.class, new MockEnviarDPSResponse());

        String paylaod = '{"VAL_DE":"2024-10-09","VAL_ATE":"2025-10-08","TITU":"TITU","SUBGRUPO":"Porto Seguro","STATUS":"Pendente","SEXO":"M","PAREN":"15","OPERACAO":"I","NOME":"FRANCIS LIU","NCPFTITULAR":"","NCPF":"518.179.180-87","ID_EMPRESA":"1-1-1391-000017264-0","FONE":"(11) 8535-8758","EMAIL":"teste@teste.com","DNAS":"1964-05-22","DATA_EMISSAO":"2024-10-09"}';

        Test.startTest();
        String response = SensediaServices.comunicarTelemed(paylaod);
        Test.stopTest();

        System.assertEquals('Success Message', response, 'The response message should be "Success Message".');
    }
    //FNPVVEP-114 FIM

    //FNPVVEP-108 INICIO
    @isTest
    static void gerarBoletoTest() {

        Test.setMock(HttpCalloutMock.class, new MockEnviarDPSResponse());

        String paylaod = '{"apolices":[{"sucursal":"1","status":"PENDENTE","senhaPdf":"LyHI3YdN","ramo":"1391","numeroParcela":["1","2","3","4","5","6","7","8","9","10","11","12"],"numeroApolice":"000017264","nomeCliente":"FRANCIS LIU","linkPdf":"https://portoseguro--sniper.sandbox.my.salesforce.com/sfc/p/L0000005xqev/a/89000000A0tB/CuxYj8zZd66czN_h8KjuNYa2vFAD5bZ0D3k8O8i_5b8","endosso":"0","email":"teste@teste.com","cpfCliente":"518.179.180-87"}]}';

        Test.startTest();
        String response = SensediaServices.gerarBoleto(paylaod);
        Test.stopTest();
    }
    //FNPVVEP-108 FIM

    @isTest
    public static void sensediaToken(){
        HttpResponse token = SensediaServices.getInstance().getTokenSensedia('ON_PREMISES_INTERNO', 'Token_Sensedia_OnPremise');
        System.debug('Token validado? ' + token);
    }   

    @isTest
    public static void sensediaTokenValidate(){
        String token = SensediaServices.getInstance().getAccessToken('ON_PREMISES_INTERNO', 'Token_Sensedia_OnPremise');
        System.debug('Access Token validado? ' + token);
    }

    //MGRC-1260 - INICIO
    @isTest
    public static void testServicoConsultaNomeSerasa(){        
        String tipo = 'PF';
        String cpf = '12345678900';        
        String mock = '{'+
            +'"tipo": "'+tipo+'",'+
            +'"cpf/cnpj": "'+cpf+'"}';       
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(mock), 200, 'OK'));        
        Test.startTest();        
        SensediaServices services = SensediaServices.getInstance();
        String retorno = services.servicoconsultanomeserasa(tipo, cpf);        
        Test.stopTest();
    }
    
    @isTest
    public static void testServicoConsultaNomeSerasaERRO(){        
        String tipo = 'PF';
        String cpf = '12345678900';        
        String mock = '{'+
            +'"tipo": "'+tipo+'",'+
            +'"cpf/cnpj": "'+cpf+'"}';        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(mock), 400, 'OK'));        
        Test.startTest();        
        SensediaServices services = SensediaServices.getInstance();
        String retorno = services.servicoconsultanomeserasa(tipo, cpf);        
        Test.stopTest();
    }

    @isTest
    public static void testServicoConsultaNomeSerasaERROCatch(){        
        String tipo = 'PF';
        String cpf = '12345678900';        
        String mock = '{'+
            +'"tipo": "'+tipo+'",'+
            +'"cpf/cnpj": "'+cpf+'"}';      
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(mock), 503, 'Bad request'));        
        Test.startTest();        
        try {
			SensediaServices services = SensediaServices.getInstance();
        	String retorno = services.servicoconsultanomeserasa(tipo, cpf);
        }
        catch(Exception e) {
            SYstem.debug('MGRC-1260 ' + e.getMessage());
            System.assert(e.getMessage().contains('nullERROR'));
        }        
        Test.stopTest();
    }
    //MGRC-1260 - FIM
    //MGRC-1263 - INICIO
    @isTest
    public static void consultarDocumentoTest(){
        ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));

        Test.startTest();
        
        SensediaServices services = SensediaServices.getInstance();        
        services.consultarDocumento(JSON.serialize(payload));
        Test.stopTest();
    }
    @isTest
    public static void consultarDocumentoTestError(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));
        String params = '{';        
        Test.startTest();
        try {
            String retorno = SensediaServices.getInstance().consultarDocumento(params);
        } catch(Exception e) {
            System.assert(e.getMessage().contains('Erro'));
        }
        Test.stopTest();
    }
    //MGRC-1263 - FIM
    //MGRC-1250 - INICIO
    @isTest
    public static void proxyAutomacaTest(){
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
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK')); 
        Test.startTest();
        
        SensediaServices services = SensediaServices.getInstance();        
        services.proxyAutomacao(JSON.serialize(payload));
        Test.stopTest();
    }
    
    //MGRC-1250 - FIM
    //MGRC-1259 - INICIO
    @isTest
    static void ConsultaCivSucesso(){        
        Set<Id> lcasos = new Set<Id>();
        Case pg  = [select Id, Nome_Segurado__c, Cpf_Segurado__c, Dataocorrencia__c, Subject, Description, Numero_titulo__c,
		Vitima__c, IdPrestadora__c, TipoEvento__c, EmpresaSplit__c, sucursal__c, RamoSplit__c, Numero_Apolice__c, SinistroPrioritario__c from Case ];
        lcasos.add(pg.Id);    
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ConsultaCivTestMock());
        SensediaServices services = SensediaServices.getInstance();   
        services.ConsultaCivSinistroTicketBCPIntegracao(lcasos);
        test.stopTest();       
    }
    
    @isTest
    public static void testarMontagemServicoSensedia(){

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('teste', 200, 'OK'));
 
        String retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, 'servico', 'body');        
   
        Test.stopTest();

        System.assertEquals('teste', retorno);
    }
    
    @IsTest
    static void testarTokenApiVidaOn(){

        String jsonMock = '{"access_token":"testAccessToken","token_type":"Bearer","expires_in":3600, "scope":""}';
        SensediaServices.TokenApiVidaOn tpvo = (SensediaServices.TokenApiVidaOn) JSON.deserialize(jsonMock, SensediaServices.TokenApiVidaOn.class);

        Test.startTest();

        new SensediaServices.TokenApiVidaOn(JSON.serialize(tpvo));
        
        Test.stopTest();
        
    }

    @isTest
    public static void testarMontagemServicoSensedia2(){

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('teste', 200, 'OK'));
 
        String retorno = SensediaServices.getInstance().montagemServicoSensedia2(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, 'servico', 'body');        
   
        Test.stopTest();

        System.assertEquals('teste', retorno);
    }

    @isTest
    public static void testEmitirContrato(){
        
        ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();
        payload.contrato = new ContratoTO();        
        payload.contrato.segmento = '';
        payload.contrato.meioComercializacao = '';
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

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payload), 200, 'OK'));
        Test.startTest();        
        SensediaServices.getInstance().emitirContrato(payload);
        Test.stopTest();
    }
}