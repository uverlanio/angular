//ANNVI-201 - INICIO
@isTest
private class CriticaPropostaAutorizacaoCartaoTest {

    @TestSetup
    static void makeData(){
        
        Account contaTeste = TestDataFactory.gerarConta();

        Account contaPF = (Account) new AccountFactory.PessoaFisica().createRecord();
        Account contaPJ = (Account) new AccountFactory.PessoaJuridica().createRecord();

        Account contasegurado = new Account(
             RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
             LastName = 'Teste',
             NomeSocial__c = 'Teste TI',
             Nacionalidade__c = 'Brasileira',
             CPF__c = '00478394659',
             Rg__c = '232323231',
             DataExpedicao__c = Date.today(),
             OrgaoExpedidor__c = '123132',
             PersonBirthDate = (Date.today()-7300),
             EstadoCivil__c = 'Solteiro (a)',
             PersonEmail = 'abc@portoseguro.com.br'
         );
        insert contasegurado;
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaPF);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaPF);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        update produtoCom;

        GarantiaProduto__c garantiaProdutoTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);
        GarantiaProduto__c garantiaProdutoCom = TestDataFactory.gerarGarantiaProdutoTecnico(produtoCom, garantia1, ramoSegurado);
        Questionario__c questionarioProdCom = TestDataFactory.gerarQuestionario();
        QuestionarioProduto__c questionarioProduto = TestDataFactory.gerarQuestionarioProduto(questionarioProdCom, produtoCom, garantiaProdutoCom);
        ParametroVigencia__c parametroCom = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaComercial(produtoCom).createRecord();
	    QueueableQTD__c qtdRecordDetails = (QueueableQTD__c) new QueueableQTDFactory().createRecord();
        QueueableQTD__c qtdRecordSend = qtdRecordDetails.clone();
        qtdRecordSend.Name = 'QueueableContractDetails';
        qtdRecordSend.Quantidade__c = 20;
        insert qtdRecordSend;
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        canalDistribuicao.Sigla__c = 'VAR';
        canalDistribuicao.Name = 'Varejista';
        canalDistribuicao.Papeis__c = 'Varejo';
        update canalDistribuicao;
        
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        Opportunity orcamentoContratado = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoCom, contaPF).createRecord();
        orcamentoContratado.StageName = 'Disponível para contratação';
        orcamentoContratado.NumeroOferta__c = '1234';
        orcamentoContratado.Origem__c = '18';
        update orcamentoContratado;
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantia1, orcamentoContratado);   
        RemuneracaoOrcamento__c remuneracaoOrcamento = TestDataFactory.gerarRemuneracaoOrcamento(orcamentoContratado, tipoRemuneracao);
        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamentoContratado, contaPF);
        GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);
        SeguradoOrcamento__c seguradoOrcamento = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamento);
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPF, formaPagamento).createRecord();
        update parceiro;

        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta('18','00324366'),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18','00324366'),
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
                NumeroProposta__c = '00324366',
                Parceiro__c = '67708896000139'        
        );
        insert proposta;

        CartaoCredito__c cartaoCredito = (CartaoCredito__c) new CartaoCreditoFactory.PessoaFisica(contaTeste).getRecord();
        insert cartaoCredito;

        ContratanteProposta__c contratanteProposta = TestDataFactory.gerarContratanteProposta(contaTeste, proposta, formaPagamento);
        contratanteProposta.Proposta__r = proposta;
        contratanteProposta.CartaoCredito__r = cartaoCredito;       

        List<Profile> profiles = [SELECT Id, Name FROM Profile];
        Profile profileComPermissao = new Profile();
        
        for(Profile profile : profiles){
            Boolean canUpdate = hasUpdatePermission('CriticaProposta__c');
                if(canUpdate){
                    profileComPermissao = profile;
                    break;
                }
        }

            User userWithReadPermission = new User(
            Username = 'testuser_read@example.com',
            Email = 'testuser_read@example.com',
            Alias = 'tusr',
            ProfileId = profileComPermissao.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Test',
            LastName = 'User'
        );
        insert userWithReadPermission;

        CriticaProposta__c critica = TestDataFactory.gerarCriticaProposta(proposta);
        critica.id = null;
        critica.OwnerId = userWithReadPermission.Id;
        critica.CurrencyIsoCode = 'BRL';
        critica.RecordTypeId = RecordTypeBO.buscarTipoRegistro('CriticaProposta__c', 'Aviso').Id;
        critica.Area__c = '';
        critica.Codigo__c = '172';
        critica.Descricao__c = 'teste';
        critica.DataConclusao__c = System.today(); 
        critica.MensagemCliente__c = '';
        critica.MensagemInterna__c = '';
        critica.MensagemRepresentante__c = '';
        critica.Procedimento__c = '';
        critica.Origem__c = 'Salesforce';
        critica.Severidade__c = 1;
        critica.Status__c = 'Pendente';
        critica.Tipo__c = 'Analise';
        critica.MomentoAnalise__c = 'Recalculo';
        critica.Integracao__c  = '';
        critica.ErrosRecalculo__c = '';
        insert critica;
    }

    @isTest
    static void testProcessarPostSuccess() {

        Test.startTest();

        Quote quote = [SELECT Id FROM QUOTE LIMIT 1];
        CriticaProposta__c criticaProposta = [SELECT Id FROM CriticaProposta__c LIMIT 1];

        String numeroReferencia = '1|' + quote.Id +'|' + criticaProposta.Id;
        
        CriticaPropostaAutorizacaoCartao.Request requestStargate = new CriticaPropostaAutorizacaoCartao.Request();
        requestStargate.stargate = new CriticaPropostaAutorizacaoCartao.RequestStargate();
        requestStargate.stargate.codigoGateway = 1;
        requestStargate.stargate.mensagemGateway = 'a';
        requestStargate.stargate.numeroReferencia = numeroReferencia;
        requestStargate.stargate.codigo = '2'; 
        requestStargate.stargate.mensagem = 'Mensagem de teste';

        String payload = JSON.serialize(requestStargate);

        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(payload);
        RestContext.request.requestUri = '/services/apexrest/proposta/critica/autorizacaocartao';

        CriticaPropostaAutorizacaoCartao.Response response = CriticaPropostaAutorizacaoCartao.processarPost();
        Test.stopTest();

        System.assertEquals(true, response.sucesso, 'A resposta deve ser bem-sucedida');
    }

    @isTest
    static void testProcessarPostFailure() {
        
        CriticaPropostaAutorizacaoCartao.RequestStargate requestStargate = new CriticaPropostaAutorizacaoCartao.RequestStargate();
        requestStargate.numeroReferencia = 'ref|12345|non_existing_id'; 
        requestStargate.codigo = '3';
        requestStargate.mensagem = 'Ops! Transação já realizada anteriormente. Consulte a forma de pagamento de suas parcelas pelo Portal do Cliente';

        String payload = JSON.serialize(requestStargate);

        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(payload);
        RestContext.request.requestUri = '/services/apexrest/proposta/critica/autorizacaocartao';

        CriticaPropostaAutorizacaoCartao.Response response = CriticaPropostaAutorizacaoCartao.processarPost();
        Test.stopTest();

        System.assertEquals(false, response.sucesso, 'A resposta deve indicar falha');
        System.assertNotEquals(null, response.mensagem, 'Uma mensagem de erro deve ser fornecida');
    }

    @isTest
    static void testIsApprovedWithCobrancasPaga() {

        CriticaPropostaAutorizacaoCartao.RequestPortopag request = new CriticaPropostaAutorizacaoCartao.RequestPortopag();
        request.id = '1';
        request.idExterno = 'x1';
        request.estado = 'x';
        request.cobrancas = new List<EmissaoTO.CobrancaTO>();
        
        EmissaoTO.CobrancaTO cobrancaPaga = new EmissaoTO.CobrancaTO();
        cobrancaPaga.estado = 'PAGA';
        request.cobrancas.add(cobrancaPaga);
        
        Boolean result = request.isApproved();
        
        System.assertEquals(true, result, 'Deve ser aprovado quando houver cobrança paga.');
    }

    @isTest
    static void testIsApprovedWithoutCobrancas() {

        CriticaPropostaAutorizacaoCartao.RequestPortopag request = new CriticaPropostaAutorizacaoCartao.RequestPortopag();
        request.cobrancas = new List<EmissaoTO.CobrancaTO>();
        
        Boolean result = request.isApproved();

        System.assertEquals(false, result, 'Não deve ser aprovado quando não houver cobranças.');
    }

    @isTest
    static void testGetMsgCartaoWithCobrancasPaga() {

        CriticaPropostaAutorizacaoCartao.RequestPortopag request = new CriticaPropostaAutorizacaoCartao.RequestPortopag();
        request.cobrancas = new List<EmissaoTO.CobrancaTO>();
        
        EmissaoTO.CobrancaTO cobrancaPaga = new EmissaoTO.CobrancaTO();
        cobrancaPaga.estado = 'PAGA';
        request.cobrancas.add(cobrancaPaga);
        
        String msg = request.getMsgCartao();
        
        System.assertEquals('APROVADO', msg, 'A mensagem deve ser APROVADO quando houver cobrança paga.');
    }

    @isTest
    static void testGetMsgCartaoWithoutCobrancas() {

        CriticaPropostaAutorizacaoCartao.RequestPortopag request = new CriticaPropostaAutorizacaoCartao.RequestPortopag();
        request.cobrancas = new List<EmissaoTO.CobrancaTO>();
        request.mensagem = 'Sem cobranças.';
        
        String msg = request.getMsgCartao();
        
        System.assertEquals('Sem cobranças.', msg, 'A mensagem deve ser a mensagem padrão quando não houver cobranças.');
    }

    @isTest
    static void testGetMsgCartaoWithCobrancasRejeitadas() {

        CriticaPropostaAutorizacaoCartao.RequestPortopag request = new CriticaPropostaAutorizacaoCartao.RequestPortopag();
        request.cobrancas = new List<EmissaoTO.CobrancaTO>();
        
        EmissaoTO.CobrancaTO cobrancaRejeitada = new EmissaoTO.CobrancaTO();
        cobrancaRejeitada.estado = 'PENDENTE';
        request.cobrancas.add(cobrancaRejeitada);
        
        String msg = request.getMsgCartao();
        
        System.assertEquals('REJEITADO', msg, 'A mensagem deve ser REJEITADO quando as cobranças não estão pagas.');
    }

    @isTest
    static void testAtualizarCriticasCriticaInexistente() {

        CriticaPropostaAutorizacaoCartao.RequestStargate reqStargate = new CriticaPropostaAutorizacaoCartao.RequestStargate();
        reqStargate.numeroReferencia = 'ref|123|fakeId';
        
        CriticaPropostaAutorizacaoCartao.Response retorno = CriticaPropostaAutorizacaoCartao.atualizarCriticas(reqStargate);
        
        System.assertEquals(false, retorno.sucesso, 'A operação deve falhar quando a crítica não existir.');
        System.assert(retorno.mensagem.contains('Critica da proposta inexistente para o número de referência informado.'), 'Mensagem de erro deve ser apropriada.');
    }

    @isTest
    static void testAtualizarCriticasCriticaLiberada() {

        Quote quote = [SELECT Id FROM QUOTE LIMIT 1];
        CriticaProposta__c criticaProposta = [SELECT Id, Status__c FROM CriticaProposta__c LIMIT 1];

        criticaProposta.Status__c = 'Liberado';
        update criticaProposta;

        CriticaPropostaAutorizacaoCartao.RequestStargate reqStargate = new CriticaPropostaAutorizacaoCartao.RequestStargate();
        reqStargate.numeroReferencia = '1|' + quote.Id +'|' + criticaProposta.Id; 

        reqStargate.mensagem = 'Ops! Transação já realizada anteriormente. Consulte a forma de pagamento de suas parcelas pelo Portal do Cliente';
        
        CriticaPropostaAutorizacaoCartao.Response retorno = CriticaPropostaAutorizacaoCartao.atualizarCriticas(reqStargate);
        
        System.assertEquals(false, retorno.sucesso, 'A operação deve falhar quando a crítica já está liberada.');
        System.assert(retorno.mensagem.contains('A Critica da Proposta já estava liberada'), 'Mensagem de erro deve ser apropriada.');
    }

    @isTest
    static void testAtualizarCriticasComFalhaNaAprovacao() {

        Quote quote = [SELECT Id FROM QUOTE LIMIT 1];
        CriticaProposta__c criticaProposta = [SELECT Id FROM CriticaProposta__c LIMIT 1];

        CriticaPropostaAutorizacaoCartao.RequestStargate reqStargate = new CriticaPropostaAutorizacaoCartao.RequestStargate();
        reqStargate.numeroReferencia = '1|' + quote.Id +'|' + criticaProposta.Id; 
        reqStargate.mensagem = 'Test failure message';

        CriticaPropostaAutorizacaoCartao.Response retorno = CriticaPropostaAutorizacaoCartao.atualizarCriticas(reqStargate);
        System.debug('retorno mensagem: '+ retorno.mensagem);
        
        System.assertEquals(false, retorno.sucesso, 'A operação deve falhar em caso de não aprovação.');
        System.assert(retorno.mensagem.contains('Falha na Integração'), 'Status: Falha na Integração');
    }

    public static Boolean hasUpdatePermission(String objectName) {

        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            
        if(objectType != null) {
            return objectType.getDescribe().isUpdateable();
        }
        return false;
    }    
}
//ANNVI-201 - FIM