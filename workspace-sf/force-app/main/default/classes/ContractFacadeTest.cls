//	Incidente 5049808 - 29/04/2021 (Globant, Luis Henrique).
//Classe desenvolvida para testar a funcionalidade que estava dando erro de integração devido a falta de tratativa do campo PersonMobilePhone
@isTest
private class ContractFacadeTest {

    // TO-DO CRIAR UM @TestSetup (Responsável por gerar os dados para utilizar nos métodos de testes)
    // RVI-255-INICIO
    @TestSetup
    static void makeData(){

        Recordtype REC_ID_PERSONACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');

        Account contaTeste = new Account(
            RecordTypeId = REC_ID_PERSONACCOUNT.Id,
            FirstName = 'FRANCIS',
            LastName = 'LIU',
            NomeSocial__c = 'FRANCIS LIU', // ANNVI-55 - INICIO/FIM
            Nacionalidade__c = 'Brasileira',
            CPF__c = '518.179.180-87',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = (Date.today()-7300),
            EstadoCivil__c = 'Solteiro (a)',
            Sucursal__c = 'a'
        );
        insert contaTeste;
        
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
    
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();

        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento(ramoSegurado,modalidade,'Boleto','1234');

        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        update produtoTec;
    
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='Ativo';
        produtoCom.Segmento__c = 'Individual';
        update produtoCom;

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();

        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        orcamentoContratado.Type = 'Novo'; 
        orcamentoContratado.StageName = 'Disponível para contratação';  
        update orcamentoContratado;

        Opportunity orcamentoContratado2 = OrcamentoFactory.criarRegOrcamentoVidaIndividual(produtoCom,contaTeste);
        orcamentoContratado2.Type = 'Novo'; 
        orcamentoContratado2.StageName = 'Disponível para contratação';  
        update orcamentoContratado2;

        Opportunity orcamentoContratado3 = OrcamentoFactory.criarRegOrcamentoVidaIndividual(produtoCom,contaTeste);
        orcamentoContratado3.Type = 'Novo'; 
        orcamentoContratado3.StageName = 'Disponível para contratação';  
        update orcamentoContratado3;

        /*Opportunity orcamentoContratado4 = OrcamentoFactory.criarRegOrcamentoVidaIndividual(produtoCom,contaTeste);
        orcamentoContratado4.Type = 'Novo'; 
        orcamentoContratado4.StageName = 'Disponível para contratação';  
        update orcamentoContratado4;*/

        Quote proposta = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        proposta.Status = 'Disponível para Contração';
        proposta.Tipo__c = 'Novo';
        proposta.VigenciaInicial__c = System.today().addDays(10);
        proposta.NumeroProposta__c = '00001234';
        proposta.Origem__c = '18';
        proposta.QuantidadeParcelas__c = 12;
        update proposta;

        Quote proposta2 = new Quote();
        proposta2.OpportunityId = orcamentoContratado2.Id;
        proposta2.Name = '18-00001235';
        proposta2.Status = 'Disponível para Contração';
        proposta2.GerarPDF__c = true;
        proposta2.RealizarEnvioDocusign__c = true;
        proposta2.Produto__c = produtoCom.id; //TKCL-246 FIX05 INICIO/FIM
        insert proposta2;

        Quote proposta3 = new Quote();
        proposta3.OpportunityId = orcamentoContratado3.Id;
        proposta3.Name = '18-00001235';
        proposta3.Status = 'Disponível para Contração';
        proposta3.GerarPDF__c = true;
        proposta3.RealizarEnvioDocusign__c = true;
        proposta3.Produto__c = produtoCom.id; //TKCL-246 FIX05 INICIO/FIM
        insert proposta3;

        /*Quote proposta4 = new Quote();
        proposta4.OpportunityId = orcamentoContratado4.Id;
        proposta4.Name = '18-00001235';
        proposta4.Status = 'Disponível para Contração';
        proposta4.GerarPDF__c = true;
        proposta4.RealizarEnvioDocusign__c = true;
        proposta4.Produto__c = produtoCom.id; //TKCL-246 FIX05 INICIO/FIM
        insert proposta4;*/

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta);
        contrato.Proposta__c = proposta.Id;
        contrato.StatusRenovacao__c = 'Não renovado';
        contrato.AlteraFormaPagto__c = false;
        contrato.Empresa__c = '1';
        contrato.CodigoRamo__c = '1391';
        contrato.Sucursal__c = '35';
        contrato.NumeroApolice__c = '000002668';
        contrato.Endosso__c = '0';
        contrato.Name = '1-35-1391-000002668-0';
        contrato.FormaPagamento__c = formaPagamento.id;
        contrato.ValorPremio__c = 1000;
        contrato.Tipo__c = 'Novo';  
        contrato.TipoEndosso__c = 'INA';
        update contrato;

        Contract contrato2 = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta2);
        contrato2.Proposta__c = proposta2.Id;
        contrato2.StatusRenovacao__c = 'Não renovado';
        contrato2.AlteraFormaPagto__c = false;
        contrato2.Empresa__c = '1';
        contrato2.CodigoRamo__c = '1391';
        contrato2.Sucursal__c = '35';
        contrato2.NumeroApolice__c = '000002667';
        contrato2.Endosso__c = '1';
        contrato2.Name = '1-35-1391-000002667-1';
        contrato2.FormaPagamento__c = formaPagamento.id;
        contrato2.ValorPremio__c = 1000;
        contrato2.Tipo__c = 'Cancelamento';
        contrato2.TipoEndosso__c = 'INA';
        contrato2.premiototal__c = -1331.19;
        update contrato2;

        Contract contrato3 = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta3);
        contrato3.Proposta__c = proposta2.Id;
        contrato3.StatusRenovacao__c = 'Não renovado';
        contrato3.AlteraFormaPagto__c = false;
        contrato3.Empresa__c = '1';
        contrato3.CodigoRamo__c = '1391';
        contrato3.Sucursal__c = '35';
        contrato3.NumeroApolice__c = '000002660';
        contrato3.Endosso__c = '1';
        contrato3.Name = '1-35-1391-000002660-1';
        contrato3.FormaPagamento__c = formaPagamento.id;
        contrato3.ValorPremio__c = 1000;
        contrato3.Tipo__c = 'Endosso';
        contrato3.TipoEndosso__c = 'INA';
        contrato3.premiototal__c = -1331.19;
        update contrato3;

        /*Contract contrato4 = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta4);
        contrato4.Proposta__c = proposta4.Id;
        contrato4.StatusRenovacao__c = 'Não renovado';
        contrato4.AlteraFormaPagto__c = false;
        contrato4.Empresa__c = '1';
        contrato4.CodigoRamo__c = '1391';
        contrato4.Sucursal__c = '35';
        contrato4.NumeroApolice__c = '000002460';
        contrato4.Endosso__c = '1';
        contrato4.Name = '1-35-1391-000002460-1';
        contrato4.FormaPagamento__c = formaPagamento.id;
        contrato4.ValorPremio__c = 1000;
        contrato4.Tipo__c = 'Endosso';
        contrato4.TipoEndosso__c = 'INA';
        contrato4.premiototal__c = 1331.19;
        update contrato4;

        ContratanteContrato__c contratanteContrato4 = TestDataFactory.gerarContratanteContrato(contrato4,contaTeste,contaTeste);
        contratanteContrato4.FormaPagamento__c = formaPagamento.Id;
        contratanteContrato4.Tipo__c = 'Principal';
        contratanteContrato4.QuantidadeParcelas__c = 1;
        update contratanteContrato4;*/

        ContratanteContrato__c contratanteContrato3 = TestDataFactory.gerarContratanteContrato(contrato3,contaTeste,contaTeste);
        contratanteContrato3.FormaPagamento__c = formaPagamento.Id;
        contratanteContrato3.Tipo__c = 'Principal';
        contratanteContrato3.QuantidadeParcelas__c = 1;
        update contratanteContrato3;

        ContratanteContrato__c contratanteContrato2 = TestDataFactory.gerarContratanteContrato(contrato2,contaTeste,contaTeste);
        contratanteContrato2.FormaPagamento__c = formaPagamento.Id;
        contratanteContrato2.Tipo__c = 'Principal';
        contratanteContrato2.QuantidadeParcelas__c = 1;
        update contratanteContrato2;

        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato,contaTeste,contaTeste);
        contratanteContrato.FormaPagamento__c = formaPagamento.Id;
        contratanteContrato.Tipo__c = 'Principal';
        contratanteContrato.QuantidadeParcelas__c = 1;
        update contratanteContrato;

        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c seguradoContrato = TestDataFactory.gerarSeguradoContrato(grupoContrato,contaTeste);
        
    }
    // RVI-255-FIM

	@isTest static void TestAccountPhone() {
        Account ac = new Account();
        ac.Phone = '(11) 91234-1234'; // ANNVI-55 - INICIO/FIM
        
        List<ContratoTO.TelefonesTO> response = ContractFacade.getInstance().parseDadosTelefone(ac);

    }
    
    
    @isTest static void TestAccountPersonHomePhone() {
        Account ac = new Account();
        ac.PersonHomePhone = '(11) 91234-1234'; // ANNVI-55 - INICIO/FIM
        
        List<ContratoTO.TelefonesTO> response = ContractFacade.getInstance().parseDadosTelefone(ac);
    }
    
    @isTest static void TestAccountPersonOtherPhone() {
        Account ac = new Account();
        ac.PersonOtherPhone = '(11) 91234-1234'; // ANNVI-55 - INICIO/FIM
        
        List<ContratoTO.TelefonesTO> response = ContractFacade.getInstance().parseDadosTelefone(ac);
    }
    
    @isTest static void TestAccountFax() {
        Account ac = new Account();
        ac.Fax = '11111111';
        
        List<ContratoTO.TelefonesTO> response = ContractFacade.getInstance().parseDadosTelefone(ac);
    }
    
    @isTest static void TestCalcularPremioLiquido() {
       
        Decimal response = ContractFacade.getInstance().calculaPremioLiquido(10, 40);
    }
    
    @isTest static void TestCalcularPremioLiquidoVazio() {
       
        Decimal response = ContractFacade.getInstance().calculaPremioLiquido(null, null);
    }
    
    @isTest static void TestatualizarParcelaContrato() {
       
        Boolean response = ContractFacade.getInstance().atualizarParcelaContrato(1,'Status');
    }

    //POR062-99 - INICIO
    @isTest static void testarMapeiaPayloadContratoParaEndosso() {       

        Test.startTest();

        Account conta = new Account(
            Name = 'teste', 
            Cnpj__c = '69979029000163'
        );

        insert conta;

        Contract contratoOriginal = new Contract(
                    Name = 'teste2',
                    StartDate = Date.valueOf('2022-10-21'),
                    VigenciaFinal__c = Date.valueOf('2023-10-20'),
                    DataEmissao__c = Date.today(),
                    NumeroApolice__c = '000001834',
                    AccountId = conta.Id
        );

        Quote cotacao = new Quote(
            Name = 'teste',
            Tipo__c = 'Endosso',
            SiglaTipoEndosso__c = 'CAD',
            Contract = contratoOriginal           
        );

        
        upsert contratoOriginal;
        Test.stopTest();

        ContratoTO.PayloadTO retorno = ContractFacade.getInstance().mapeiaPayloadContrato(cotacao, null);
    }

    @isTest static void testarMapeiaPayloadContratoParaCancelamento() {       

        Test.startTest();

        Account conta = new Account(
            Name = 'teste', 
            Cnpj__c = '69979029000163'
        );

        insert conta;

        Contract contratoOriginal = new Contract(
                    Name = 'teste2',
                    StartDate = Date.valueOf('2022-10-21'),
                    VigenciaFinal__c = Date.valueOf('2023-10-20'),
                    DataEmissao__c = Date.today(),
                    NumeroApolice__c = '000001834',
                    AccountId = conta.Id
        );
        
        upsert contratoOriginal;
        Test.stopTest();

        Quote cotacao = new Quote(
            Name = 'teste',
            Tipo__c = 'Cancelamento',
            SiglaTipoEndosso__c = 'CAD',
            Contract = contratoOriginal
        );

        ContratoTO.PayloadTO retorno = ContractFacade.getInstance().mapeiaPayloadContrato(cotacao, null);
    }
    //POR062-99 - FIM

    // RVI-255-INICIO
    @isTest static void conDadosCtrTestFail(){
        String jsonString = '{"empresa": "1","sucursal": "35","ramo": "1391","apolice": "000002668","endosso": "1","numeroparcela": null}'; 
        Test.startTest();
        ContractFacade.getInstance().consultarContrato(jsonString);
        Test.stopTest();
    }

    @isTest static void conDadosCtrCanTest(){
        String jsonString = '{"empresa": "1","sucursal": "35","ramo": "1391","apolice": "000002667","endosso": "1","numeroparcela": 0}'; 
        String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"35","ramo":"1391","apolice":"000002667","endosso":"1","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));
        ContractFacade.getInstance().consultarContrato(jsonString);
        Test.stopTest();
    }

    @isTest static void conDadosCtrEdsTest(){
        String jsonString = '{"empresa": "1","sucursal": "35","ramo": "1391","apolice": "000002660","endosso": "1","numeroparcela": 1}'; 
        String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"35","ramo":"1391","apolice":"000002660","endosso":"1","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));
        ContractFacade.getInstance().consultarContrato(jsonString);
        Test.stopTest();
    }

    /*@isTest static void conDadosCtrEdsTestMov6(){
        String jsonString = '{"empresa": "1","sucursal": "35","ramo": "1391","apolice": "000002460","endosso": "1","numeroparcela": 0}'; 
        String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00043729","numeropropostaporto":"00043729","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"35","ramo":"1391","apolice":"000002460","endosso":"1","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));
        ContractFacade.getInstance().consultarContrato(jsonString);
        Test.stopTest();
    }*/

    @isTest static void conDadosCtrTestExc(){
        String jsonString = '{"empresa": "AS","sucursal": "35","ramo": "1391","apolice": "000002668","endosso": "1","numeroparcela": "1"}'; 
        Test.startTest();
        ContractFacade.getInstance().consultarContrato(jsonString);
        Test.stopTest();
    }

    // @isTest static void conDadosQtTestFail(){
    //     //String jsonString = '{"empresa": "1","proposta":"","ramo": "1391","origem": "18", "parcela": 1}';          
    //     ServiceTO.ParametroConsultarPropostaTO sa = new ServiceTO.ParametroConsultarPropostaTO();  
    //     sa.empresa = '1';        
    //     sa.proposta = '';
    //     sa.ramo = '1391';
    //     sa.origem = '18';
    //     sa.parcela = 1;
    //     Test.startTest();
    //     //ContractFacade.getInstance().consultarProposta(jsonString);   
    //     System.assert(sa.empresa == '1');     
    //     Test.stopTest();
    // }

    /*@isTest static void genConQtTest(){
        //String jsonString = '{"empresa": "1","proposta":"","ramo": "1391","origem": "18", "parcela": 1}';
        ConsultarDadosContratoTO.DadosParcelasTO retorno = new ConsultarDadosContratoTO.DadosParcelasTO();
        ServiceTO.ParametroConsultarPropostaTO sa = new ServiceTO.ParametroConsultarPropostaTO();  
        sa.empresa = '1';    
        sa.ramo = '2';  
        sa.origem = '18';  
        sa.proposta = '00001234';
        sa.parcela = 12;
        System.debug('DEBUG HENRIQUE SA: '+ sa);
        List<Contract> lstcontrato = [
            SELECT
                    Id,
                    Name,
                    Empresa__c,
                    Proposta__r.Origem__c,
                    Proposta__r.NumeroProposta__c,
                    Proposta__r.Name,
                    DataEmissao__c,
                    RamoSeguro__r.Codigo__c,
                    Proposta__r.Modalidade__c,
                    Proposta__r.Modalidade__r.Codigo__c,
                    Sucursal__c,
                    Endosso__c,
                    StartDate,
                    EndDate,
                    VigenciaFinal__c,
                    FormaPagamento__r.Codigo__c,
                    ValorPremio__c,
                    Proposta__r.QuantidadeParcelas__c,
                    CodigoCorretor__r.Name,
                    Tipo__c,
                    TipoEndosso__c,
            (
                    SELECT
                            Id,
                            Conta__r.Name,
                            FormaPagamento__r.Codigo__c,
                            QuantidadeParcelas__c,
                            Tipo__c
                    FROM
                            ContratantesContrato__r
            )
            FROM
                    Contract
    ];


        System.debug('DEBUG HENRIQUE lstcontrato: '+ lstcontrato);
        System.debug('DEBUG HENRIQUE lstcontrato 2 : ' + lstcontrato.size());
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 200, 'OK'));
        HerokuService.getInstance().buscarParcelasContratoPorApolice('231');
        ContractFacade.getInstance().criarConsultaProposta(sa);           
        Test.stopTest();
    }
    */

    @isTest static void obterParConSeg(){
        List<ContratanteContrato__c>idContratante = [SELECT Id, Contrato__c FROM ContratanteContrato__c limit 1];
        List<SeguradoContrato__c> segurado = [
            SELECT
            Id,
            GrupoContrato__c,
            GrupoContrato__r.ContratanteContrato__c
            FROM
            SeguradoContrato__c
            LIMIT 1
        ];
        String idSegurado = segurado[0].id;
        //String resquestMock = idContratante[0].Contrato__c +'_'+ idContratante[0].id;

        System.debug('DEBUG HENRIQUE: ' +idContratante );
        Test.startTest();
        ContractFacade.getInstance().obterParcelasContratoSegurado(idContratante[0].id);
        Test.stopTest();
    }

    @isTest static void obterParConSegIdnull(){
        
        List<SeguradoContrato__c> segurado = [
           SELECT
             Id,
             GrupoContrato__c,
             GrupoContrato__r.ContratanteContrato__c
             FROM
             SeguradoContrato__c
             LIMIT 1
         ];

        System.debug('segurado[0].Id'+ segurado[0].Id);

        List<ContratanteContrato__c>idContratante = [
            SELECT Id,
            Contrato__c 
            FROM ContratanteContrato__c  LIMIT 1
        ];
        System.debug('DEBUG HENRIQUE SEGURADO 2: ' + segurado );

        Test.startTest();
        ContractFacade.getInstance().obterParcelasContratoSegurado(segurado[0].Id);
        Test.stopTest();
    }

    // RVI-255-FIM

    // AJUSTE CLASSE DE TESTE - INICIO

    @isTest
    static void parseDadosEnderecosTest(){
    
        List<Endereco__c> listEndereco = new List<Endereco__c>();

        Endereco__c endereco = new Endereco__c();
        endereco.CEP__c = '38402680';
        listEndereco.add(endereco);

        Id idConta;  

        test.startTest();
        List<ContratoTO.EnderecosTO> endereco2 = contractFacade.getInstance().parseDadosEnderecos(listEndereco, idConta);

        try
        {
            contractFacade.getInstance().parseDadosEnderecos(null, null);
        }
        catch(Exception e){
            system.assertNotEquals(null, endereco2,'');
        }
        test.stopTest();
    }

    @isTest
    static void parseDadosCoberturasTest(){
    
    List<GarantiaProposta__c> listaGarantiaProposta = new List<GarantiaProposta__c>();
    List<CarenciaGarantia__c> listaCarenciaGarantia = new List<CarenciaGarantia__c>();
    List<FranquiaGarantia__c> ListaFranquiaGarantia = new List<FranquiaGarantia__c>();

    Id idRamoSegurado;

    quote proposta = [SELECT Id FROM quote LIMIT 1];

    Franquia__c franquia = new Franquia__c();
    franquia.CodigoFranquia__c = 'FR_NORMAL';
    franquia.Descricao__c = 'Cobertura de Diárias por Incapacidade Temporária - Franquia de 10 dias para doença e 10 dias para acidente.';
    franquia.LimiteMaximo__c = '10';
    franquia.LimiteMinimo__c = '10';
    franquia.Modelo__c = 'Simples';
    franquia.Name = 'Simples';
    //franquia.Status__c = 'Ativo';
    franquia.Tipo__c = 'Dias';
    INSERT franquia;

    Carencia__c carencia = new Carencia__c();
    carencia.CodigoCarencia__c = '1233333333333';
    carencia.Descricao__c = 'TESTE12345 - Carencia 2.0';
    carencia.FormaCarencia__c = 'Simples';
    carencia.LimitePercentual__c = 50;
    carencia.Name = 'Carencia Teste';
    carencia.PeriodoMaximoCarencia__c = 1;
    //carencia.TipoEvento__c = 'Acidente';
    carencia.TipoPeriodo__c = 'Mês(es)';
    carencia.ValorBase__c = 'Salário';
    INSERT carencia;

    Garantia__c garantia = [SELECT Id FROM Garantia__c LIMIT 1]; 

    GarantiaProduto__c garantiaProduto = new GarantiaProduto__c();
    garantiaProduto.Garantia__c = garantia.Id;
    garantiaProduto.TipoGarantia__c = 'Cobertura';
    System.debug('>>> garantia '+garantiaProduto +garantia);
    INSERT garantiaProduto;

    GarantiaProposta__c garantiaProposta = new GarantiaProposta__c();
    garantiaProposta.Proposta__c = proposta.Id;
    garantiaProposta.Garantia__c = garantia.Id;
    garantiaProposta.GarantiaProduto__c = garantiaProduto.Id;
    INSERT garantiaProposta;

    ContratoTO.CoberturasTO cobertura;

    FranquiaGarantia__c franquiaGarantia = new FranquiaGarantia__c();
    franquiaGarantia.Franquia__c = franquia.Id;
    franquiaGarantia.GarantiaProduto__c = garantiaProduto.id;
    INSERT franquiaGarantia;

    CarenciaGarantia__c carenciaGarantia = new CarenciaGarantia__c();
    carenciaGarantia.TipoEmissao__c = 'Endosso';
    carenciaGarantia.GarantiaProduto__c = garantiaProduto.Id;
    carenciaGarantia.Carencia__c = carencia.Id;
    INSERT carenciaGarantia;
    
    listaGarantiaProposta.add(garantiaProposta);

    listaCarenciaGarantia.add(carenciaGarantia);

    ListaFranquiaGarantia.add(franquiaGarantia);
    
    Test.startTest();
    ContractFacade.getInstance().parseDadosCoberturas(listaGarantiaProposta, garantia.Id);

    try{
        contractFacade.getInstance().parseDadosCoberturas(null, null);
        }
        catch(Exception e){
        }
    Test.stopTest();

    }
    
    
    @isTest
    static void parseDadosBeneficiarioSeguradoTest(){
     
    List<BeneficiarioSeguradoProposta__c> listaBeneficiariosSeguradoProposta = new List<BeneficiarioSeguradoProposta__c>();

    FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c];

    quote proposta = [SELECT Id FROM quote LIMIT 1];

    Account contaTeste = [SELECT Id FROM Account];

    Account contaParceiro = new Account(Name = 'ParceiroTeste', 
                                        CodigoEmpresa__c = '12', 
                                        IdExterno__c = '67708896000139', 
                                        Inscricao_Municipal__c = '123456789', 
                                        Cnpj__c = '67.708.896/0001-39'); 
    insert contaParceiro;

    ContratanteProposta__c ContratanteProposta = new ContratanteProposta__c();
    ContratanteProposta.Conta__c = contaTeste.Id;
    ContratanteProposta.Proposta__c = proposta.Id;
    ContratanteProposta.Tipo__c = 'Principal';
    ContratanteProposta.TipoEndereco__c = 'Residencial';
    ContratanteProposta.Cep__c = '03020-000';
    ContratanteProposta.TipoLogradouro__c = 'Rua';
    ContratanteProposta.Logradouro__c = '15';
    ContratanteProposta.NumeroEndereco__c = '15';
    ContratanteProposta.Bairro__c = 'Osasco';
    ContratanteProposta.Cidade__c = 'São Paulo';
    ContratanteProposta.Estado__c = 'SP';
    ContratanteProposta.Pais__c = 'Brasil';
    ContratanteProposta.ResponsavelPagamento__c = (contaParceiro != null) ? contaParceiro.Id : null;
    ContratanteProposta.FormaPagamento__c = formaPagamento.Id;
    ContratanteProposta.PremioTotal__c = 10;
    ContratanteProposta.PremioComercial__c = 10;
    ContratanteProposta.IOF__c = 1;
    ContratanteProposta.QuantidadeParcelas__c = 1;
    ContratanteProposta.EnderecoBoleto__c = 'http://www.google.com.br';
    ContratanteProposta.TipoResponsavelPagamento__c = 'PAR';
    ContratanteProposta.VencimentoPrimeiraParcela__c = System.today();
    ContratanteProposta.PremioPuro__c = 100;
    ContratanteProposta.TaxaPura__c = 10;
    ContratanteProposta.TaxaComercial__c = 10;
    ContratanteProposta.Numero__c = 1;
    INSERT ContratanteProposta;

    GrupoProposta__c grupoProposta = new GrupoProposta__c();
    grupoProposta.ContratanteProposta__c =contratanteProposta.Id;
    grupoProposta.Name = 'Grupo de Teste';
    grupoProposta.Numero__c = 1;    
    INSERT grupoProposta;

    SeguradoProposta__c seguradoProposta = new SeguradoProposta__c();
    seguradoProposta.Conta__c = contaTeste.Id;
    seguradoProposta.ResponsavelPagamento__c = contaParceiro.Id;
    seguradoProposta.FormaPagamento__c = formaPagamento.Id;
    seguradoProposta.PremioTotal__c = 10;
    seguradoProposta.GrupoProposta__c = grupoProposta.Id;
    seguradoProposta.EnderecoBoleto__c = 'http://www.google.com.br';
    seguradoProposta.PremioComercial__c = 10;
    seguradoProposta.IOF__c = 1;
    seguradoProposta.Numero__c = 1;
    INSERT seguradoProposta;

    BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta = new BeneficiarioSeguradoProposta__c();
    beneficiarioSeguradoProposta.Conta__c = contaTeste.Id;
    beneficiarioSeguradoProposta.Nome__c = 'Teste';
    beneficiarioSeguradoProposta.NomePessoaPep__c = 'Teste';
    beneficiarioSeguradoProposta.SeguradoProposta__c = seguradoProposta.Id;
    beneficiarioSeguradoProposta.TipoBeneficiario__c = 'Nome do beneficiário';
    beneficiarioSeguradoProposta.Participacao__c = 100;
    beneficiarioSeguradoProposta.MotivoSemCpfCnpj__c = 'Não desejo informar';
    beneficiarioSeguradoProposta.GrauParentesco__c = 'Cônjuge';
    beneficiarioSeguradoProposta.Pep__c = 'Sim';
         insert beneficiarioSeguradoProposta;

    listaBeneficiariosSeguradoProposta.add(beneficiarioSeguradoProposta);
        
    Test.startTest();
    ContractFacade.getInstance().parseDadosBeneficiarioSegurado(listaBeneficiariosSeguradoProposta);

    try{
        contractFacade.getInstance().parseDadosBeneficiarioSegurado(null);
        }
        catch(Exception e){
        }
    Test.stopTest();
    }

    @IsTest
    static void carregarTaxaComissaoTest(){

        Account contaTeste = [SELECT Id FROM Account];

        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c];
    
        quote proposta = [SELECT Id FROM quote LIMIT 1];

        Contract contrato = new Contract();
        contrato.Proposta__c = proposta.Id;
        contrato.StatusRenovacao__c = 'Não renovado';
        contrato.AlteraFormaPagto__c = false;
        contrato.Empresa__c = '1';
        contrato.CodigoRamo__c = '1391';
        contrato.Sucursal__c = '35';
        contrato.NumeroApolice__c = '000003003';
        contrato.Endosso__c = '0';
        contrato.Name = '1-35-1391-000003003-0';
        contrato.FormaPagamento__c = formaPagamento.Id;
        contrato.ValorPremio__c = 0;
        contrato.Tipo__c = 'Novo';  
        contrato.TipoEndosso__c = 'INA';
        contrato.AccountId = contaTeste.Id;
        INSERT contrato;
        
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
        tipoRemuneracao.Name = 'CORRETAGEM';
        UPDATE tipoRemuneracao;

        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        remuneracaoContrato.Percentual__c = 1;
        UPDATE remuneracaoContrato;

        Contract contratoQuery = ContractDAO.getInstance().buscarContratoPorName(Contrato.Name)[0];

        System.debug('===> Contrato Query: '+contratoQuery);
        Test.startTest();
        ContractFacade.getInstance().carregarTaxaComissao(contratoQuery);
        Test.stopTest();
    }

    @IsTest
    static void retornarNumeroEndossoTest(){

        List<Contract> listaContrato = new List<Contract>();

        Account contaTeste = [SELECT Id FROM Account];

        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c];
    
        quote proposta = [SELECT Id FROM quote LIMIT 1];

        Contract contrato = new Contract();
        contrato.Proposta__c = proposta.Id;
        contrato.StatusRenovacao__c = 'Não renovado';
        contrato.AlteraFormaPagto__c = false;
        contrato.Empresa__c = '1';
        contrato.CodigoRamo__c = '1391';
        contrato.Sucursal__c = '35';
        contrato.NumeroApolice__c = '000003003';
        contrato.Endosso__c = '0';
        contrato.Name = '1-35-1391-000003003-0';
        contrato.FormaPagamento__c = formaPagamento.Id;
        contrato.ValorPremio__c = 0;
        contrato.Tipo__c = 'Novo';  
        contrato.TipoEndosso__c = 'INA';
        contrato.AccountId = contaTeste.Id;
        INSERT contrato;

        test.startTest();
        ContractFacade.getInstance().retornarNumeroEndosso(listaContrato);

        listaContrato.add(contrato);

        ContractFacade.getInstance().retornarNumeroEndosso(listaContrato);

        contrato.Endosso__c = '1';
        listaContrato.clear();

        listaContrato.add(contrato);

        ContractFacade.getInstance().retornarNumeroEndosso(listaContrato);

        contrato.Endosso__c = null;
        listaContrato.clear();

        listaContrato.add(contrato);

        ContractFacade.getInstance().retornarNumeroEndosso(listaContrato);
        test.stopTest();

    }

    @isTest
    static void parseDadosGrupoTest(){
     
    List<GrupoProposta__c> listaGrupoProposta = new List<GrupoProposta__c>();

    FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c];

    quote proposta = [SELECT Id FROM quote LIMIT 1];

    Account contaTeste = [SELECT Id FROM Account];

    RamoSeguro__c ramoSeguro = [SELECT Id FROM RamoSeguro__c];

    Map<String, RecordType> mapStringXRecordType = new Map<String, RecordType>();

    Account contaParceiro = new Account(Name = 'ParceiroTeste', 
                                        CodigoEmpresa__c = '12', 
                                        IdExterno__c = '67708896000139', 
                                        Inscricao_Municipal__c = '123456789', 
                                        Cnpj__c = '67.708.896/0001-39'); 
    INSERT contaParceiro;

    ContratanteProposta__c ContratanteProposta = new ContratanteProposta__c();
    ContratanteProposta.Conta__c = contaTeste.Id;
    ContratanteProposta.Proposta__c = proposta.Id;
    ContratanteProposta.Tipo__c = 'Principal';
    ContratanteProposta.TipoEndereco__c = 'Residencial';
    ContratanteProposta.Cep__c = '03020-000';
    ContratanteProposta.TipoLogradouro__c = 'Rua';
    ContratanteProposta.Logradouro__c = '15';
    ContratanteProposta.NumeroEndereco__c = '15';
    ContratanteProposta.Bairro__c = 'Osasco';
    ContratanteProposta.Cidade__c = 'São Paulo';
    ContratanteProposta.Estado__c = 'SP';
    ContratanteProposta.Pais__c = 'Brasil';
    ContratanteProposta.ResponsavelPagamento__c = (contaParceiro != null) ? contaParceiro.Id : null;
    ContratanteProposta.FormaPagamento__c = formaPagamento.Id;
    ContratanteProposta.PremioTotal__c = 10;
    ContratanteProposta.PremioComercial__c = 10;
    ContratanteProposta.IOF__c = 1;
    ContratanteProposta.QuantidadeParcelas__c = 1;
    ContratanteProposta.EnderecoBoleto__c = 'http://www.google.com.br';
    ContratanteProposta.TipoResponsavelPagamento__c = 'PAR';
    ContratanteProposta.VencimentoPrimeiraParcela__c = System.today();
    ContratanteProposta.PremioPuro__c = 100;
    ContratanteProposta.TaxaPura__c = 10;
    ContratanteProposta.TaxaComercial__c = 10;
    ContratanteProposta.Numero__c = 1;
    INSERT ContratanteProposta;

    GrupoProposta__c grupoProposta = new GrupoProposta__c();
    grupoProposta.Descricao__c = '1';
    grupoProposta.QuantidadeVidas__c = 1;
    grupoProposta.ContratanteProposta__c =contratanteProposta.Id;
    grupoProposta.Name = 'Grupo de Teste';
    grupoProposta.Numero__c = 1;    
    INSERT grupoProposta;

    listaGrupoProposta.add(grupoProposta);

    test.startTest();
    ContractFacade.getInstance().parseDadosGrupo(listaGrupoProposta, proposta.Id, RamoSeguro.Id, mapStringXRecordType);

    try {
        ContractFacade.getInstance().parseDadosGrupo(null, null, null, null);    
    } 
    catch (Exception e) {    
    }
    test.stopTest();
    }

    @IsTest
    static void parceseguradosGrupoTest(){
        List<SeguradoProposta__c> listaSeguradoProposta = new List<SeguradoProposta__c>();

        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c];
    
        quote proposta = [SELECT Id FROM quote LIMIT 1];
    
        Account contaTeste = [SELECT Id FROM Account];
    
        RamoSeguro__c ramoSeguro = [SELECT Id FROM RamoSeguro__c];
    
        Map<String, RecordType> mapStringXRecordType = new Map<String, RecordType>();

        ContratoTo.SeguradosTO contratoToSeguradoTo = new ContratoTo.SeguradosTO();
    
        Account contaParceiro = new Account(Name = 'ParceiroTeste', 
                                            CodigoEmpresa__c = '12', 
                                            IdExterno__c = '67708896000139', 
                                            Inscricao_Municipal__c = '123456789', 
                                            Cnpj__c = '67.708.896/0001-39'); 
        INSERT contaParceiro;
    
        ContratanteProposta__c ContratanteProposta = new ContratanteProposta__c();
        ContratanteProposta.Conta__c = contaTeste.Id;
        ContratanteProposta.Proposta__c = proposta.Id;
        ContratanteProposta.Tipo__c = 'Principal';
        ContratanteProposta.TipoEndereco__c = 'Residencial';
        ContratanteProposta.Cep__c = '03020-000';
        ContratanteProposta.TipoLogradouro__c = 'Rua';
        ContratanteProposta.Logradouro__c = '15';
        ContratanteProposta.NumeroEndereco__c = '15';
        ContratanteProposta.Bairro__c = 'Osasco';
        ContratanteProposta.Cidade__c = 'São Paulo';
        ContratanteProposta.Estado__c = 'SP';
        ContratanteProposta.Pais__c = 'Brasil';
        ContratanteProposta.ResponsavelPagamento__c = (contaParceiro != null) ? contaParceiro.Id : null;
        ContratanteProposta.FormaPagamento__c = formaPagamento.Id;
        ContratanteProposta.PremioTotal__c = 10;
        ContratanteProposta.PremioComercial__c = 10;
        ContratanteProposta.IOF__c = 1;
        ContratanteProposta.QuantidadeParcelas__c = 1;
        ContratanteProposta.EnderecoBoleto__c = 'http://www.google.com.br';
        ContratanteProposta.TipoResponsavelPagamento__c = 'PAR';
        ContratanteProposta.VencimentoPrimeiraParcela__c = System.today();
        ContratanteProposta.PremioPuro__c = 100;
        ContratanteProposta.TaxaPura__c = 10;
        ContratanteProposta.TaxaComercial__c = 10;
        ContratanteProposta.Numero__c = 1;
        INSERT ContratanteProposta;
    
        GrupoProposta__c grupoProposta = new GrupoProposta__c();
        grupoProposta.Descricao__c = '1';
        grupoProposta.QuantidadeVidas__c = 1;
        grupoProposta.ContratanteProposta__c = contratanteProposta.Id;
        grupoProposta.Name = 'Pessoa física';
        grupoProposta.Numero__c = 1;    
        INSERT grupoProposta;

        SeguradoProposta__c seguradoProposta = new SeguradoProposta__c();
        seguradoProposta.Conta__c = contaTeste.Id;
        seguradoProposta.ResponsavelPagamento__c = contaParceiro.Id;
        seguradoProposta.FormaPagamento__c = formaPagamento.Id;
        seguradoProposta.PremioTotal__c = 10;
        seguradoProposta.GrupoProposta__c = grupoProposta.Id;
        seguradoProposta.EnderecoBoleto__c = 'http://www.google.com.br';
        seguradoProposta.PremioComercial__c = 10;
        seguradoProposta.IOF__c = 1;
        seguradoProposta.Numero__c = 1;
        INSERT seguradoProposta;

        Set<Id> SetId = new Set<Id>();
        SetId.add(grupoProposta.Id);
        
        seguradoProposta = SeguradoPropostaDAO.getInstance().buscarGruposPropostaPorIds(SetId)[0];
    
        listaSeguradoProposta.add(seguradoProposta);

        for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Account'))
        mapStringXRecordType.put(tipo.Id, tipo);
    
        Test.startTest();
        ContractFacade.getInstance().parceseguradosGrupo(listaSeguradoProposta, proposta.Id, RamoSeguro.Id, mapStringXRecordType);
    
        try {
        ContractFacade.getInstance().parceseguradosGrupo(null, null, null, null);    
        } 
        catch (Exception e) {    
        }
        Test.stopTest();
        }

        @isTest
        static void parseDadosContratantesTest(){
        List<ContratanteProposta__c> listaContratanteProposta = new List<ContratanteProposta__c>();

        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c];
    
        quote proposta = [SELECT Id FROM quote LIMIT 1];
    
        Account contaTeste = [SELECT Id FROM Account];
    
        RamoSeguro__c ramoSeguro = [SELECT Id FROM RamoSeguro__c];
    
        Map<String, RecordType> mapStringXRecordType = new Map<String, RecordType>();

        Map<Id,Endereco__c> mapaEnderecos = new Map<Id, Endereco__c>();

        ContratoTo.ContratantesTO contratante = new ContratoTo.ContratantesTO();

        Account contaParceiro = new Account(Name = 'ParceiroTeste', 
                                            CodigoEmpresa__c = '12', 
                                            IdExterno__c = '67708896000139', 
                                            Inscricao_Municipal__c = '123456789', 
                                            Cnpj__c = '67.708.896/0001-39'); 
        INSERT contaParceiro;
    
        ContratanteProposta__c ContratanteProposta = new ContratanteProposta__c();
        ContratanteProposta.Conta__c = contaTeste.Id;
        ContratanteProposta.Proposta__c = proposta.Id;
        ContratanteProposta.Tipo__c = 'Principal';
        ContratanteProposta.TipoEndereco__c = 'Residencial';
        ContratanteProposta.Cep__c = '03020-000';
        ContratanteProposta.TipoLogradouro__c = 'Rua';
        ContratanteProposta.Logradouro__c = '15';
        ContratanteProposta.NumeroEndereco__c = '15';
        ContratanteProposta.Bairro__c = 'Osasco';
        ContratanteProposta.Cidade__c = 'São Paulo';
        ContratanteProposta.Estado__c = 'SP';
        ContratanteProposta.Pais__c = 'Brasil';
        ContratanteProposta.ResponsavelPagamento__c = (contaParceiro != null) ? contaParceiro.Id : null;
        ContratanteProposta.FormaPagamento__c = formaPagamento.Id;
        ContratanteProposta.PremioTotal__c = 10;
        ContratanteProposta.PremioComercial__c = 10;
        ContratanteProposta.IOF__c = 1;
        ContratanteProposta.QuantidadeParcelas__c = 1;
        ContratanteProposta.EnderecoBoleto__c = 'http://www.google.com.br';
        ContratanteProposta.TipoResponsavelPagamento__c = 'PAR';
        ContratanteProposta.VencimentoPrimeiraParcela__c = System.today();
        ContratanteProposta.PremioPuro__c = 100;
        ContratanteProposta.TaxaPura__c = 10;
        ContratanteProposta.TaxaComercial__c = 10;
        ContratanteProposta.Numero__c = 1;
        INSERT ContratanteProposta;

        ContratanteProposta = [SELECT 
        ResponsavelPagamento__r.Name,
        ResponsavelPagamento__r.Phone,
        ResponsavelPagamento__r.Cnpj__c,
        ResponsavelPagamento__r.RecordTypeId,
        ResponsavelPagamento__r.PersonHomePhone,
        ResponsavelPagamento__r.PersonOtherPhone,
        ResponsavelPagamento__r.PersonBirthdate,
        ResponsavelPagamento__r.Fax,
        ResponsavelPagamento__r.PersonMobilePhone,
        FormaPagamento__r.Id,
        FormaPagamento__r.Codigo__c,
        Conta__r.Sexo__c,
        Conta__r.PersonMobilePhone,
        Conta__r.Fax,
        Conta__r.Phone,
        Conta__r.EstadoCivil__c,
        Conta__r.PersonBirthdate,
        Conta__r.CPF__c,
        Conta__r.PersonHomePhone,
        Conta__r.PersonOtherPhone,
        Conta__r.Email__c,
        Conta__r.Name,
        Conta__r.NomeSocial__c, // ANNVI-55 - INICIO/FIM
        Conta__c, 
        Tipo__c, 
        Conta__r.RecordTypeId, 
        proposta__c, 
        TipoEndereco__c, 
        Cep__c, 
        TipoLogradouro__c, 
        Logradouro__c, 
        NumeroEndereco__c, 
        Bairro__c, 
        Cidade__c, 
        Estado__c, 
        Pais__c, 
        ResponsavelPagamento__c, 
        PremioTotal__c, 
        FormaPagamento__c, 
        PremioComercial__c, 
        IOF__c, 
        QuantidadeParcelas__c, 
        EnderecoBoleto__c, 
        TipoResponsavelPagamento__c, 
        VencimentoPrimeiraParcela__c, 
        PremioPuro__c, 
        TaxaPura__c, 
        TaxaComercial__c, 
        Numero__c
            FROM
                ContratanteProposta__c
            WHERE
                Id =: ContratanteProposta.Id
        ];

        GrupoProposta__c grupoProposta = new GrupoProposta__c();
        grupoProposta.Descricao__c = '1';
        grupoProposta.QuantidadeVidas__c = 1;
        grupoProposta.ContratanteProposta__c = contratanteProposta.Id;
        grupoProposta.Name = 'Pessoa física';
        grupoProposta.Numero__c = 1;    
        INSERT grupoProposta;

        SeguradoProposta__c seguradoProposta = new SeguradoProposta__c();
        seguradoProposta.Conta__c = contaTeste.Id;
        seguradoProposta.FaixaRenda__c = '2500';
        seguradoProposta.ResponsavelPagamento__c = contaParceiro.Id;
        seguradoProposta.FormaPagamento__c = formaPagamento.Id;
        seguradoProposta.PremioTotal__c = 10;
        seguradoProposta.GrupoProposta__c = grupoProposta.Id;
        seguradoProposta.EnderecoBoleto__c = 'http://www.google.com.br';
        seguradoProposta.PremioComercial__c = 10;
        seguradoProposta.IOF__c = 1;
        seguradoProposta.Numero__c = 1;
        seguradoProposta.PEP__C = 'Sim';
        INSERT seguradoProposta;
    
        listaContratanteProposta.add(ContratanteProposta);

        for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Account'))
        {
            mapStringXRecordType.put(tipo.Id, tipo);
        }

        Test.startTest();
        ContractFacade.getInstance().parseDadosContratantes(listaContratanteProposta, RamoSeguro.Id, mapStringXRecordType);
        seguradoProposta.FaixaRenda__c = '4000';
        seguradoProposta.PEP__C = 'Não';
        UPDATE seguradoProposta;

        listaContratanteProposta.add(ContratanteProposta);

        ContractFacade.getInstance().parseDadosContratantes(listaContratanteProposta, RamoSeguro.Id, mapStringXRecordType);

        seguradoProposta.FaixaRenda__c = '8000';
        seguradoProposta.PEP__C = 'RelacionamentoProximo';
        seguradoProposta.NomePessoaRelacionamentoProximo__c = 'XXXX';
        seguradoProposta.TipoPessoaRelacionamentoProximo__c = 'PessoaFisica';
        seguradoProposta.CpfPessoaRelacionamentoProximo__c = '121.121.121-12';
        UPDATE seguradoProposta;

        listaContratanteProposta.add(ContratanteProposta);

        ContractFacade.getInstance().parseDadosContratantes(listaContratanteProposta, RamoSeguro.Id, mapStringXRecordType);

        seguradoProposta.FaixaRenda__c = '8005';
        UPDATE seguradoProposta;

        listaContratanteProposta.add(ContratanteProposta);

        // ContractFacade.getInstance().parseDadosContratantes(listaContratanteProposta, RamoSeguro.Id, mapStringXRecordType);

        // try 
        // {
        //     ContractFacade.getInstance().parseDadosContratantes(null, null, null);    
        // } 
        // catch (Exception e) {   
        // }
        Test.stopTest();
        }

        // @isTest
        // static void parseDadosContratantes2Test(){
        // List<ContratanteProposta__c> listaContratanteProposta = new List<ContratanteProposta__c>();

        // FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c];
    
        // quote proposta = [SELECT Id FROM quote LIMIT 1];
    
        // Account contaTeste = [SELECT Id FROM Account];
    
        // RamoSeguro__c ramoSeguro = [SELECT Id FROM RamoSeguro__c];
    
        // Map<String, RecordType> mapStringXRecordType = new Map<String, RecordType>();

        // Map<Id,Endereco__c> mapaEnderecos = new Map<Id, Endereco__c>();

        // ContratoTo.ContratantesTO contratante = new ContratoTo.ContratantesTO();

        // Account contaParceiro = new Account(Name = 'ParceiroTeste', 
        //                                     CodigoEmpresa__c = '12', 
        //                                     IdExterno__c = '67708896000139', 
        //                                     Inscricao_Municipal__c = '123456789', 
        //                                     Cnpj__c = '67.708.896/0001-39'); 
        // INSERT contaParceiro;
    
        // ContratanteProposta__c ContratanteProposta = new ContratanteProposta__c();
        // ContratanteProposta.Conta__c = contaTeste.Id;
        // ContratanteProposta.Proposta__c = proposta.Id;
        // ContratanteProposta.Tipo__c = 'Principal';
        // ContratanteProposta.TipoEndereco__c = 'Residencial';
        // ContratanteProposta.Cep__c = '03020-000';
        // ContratanteProposta.TipoLogradouro__c = 'Rua';
        // ContratanteProposta.Logradouro__c = '15';
        // ContratanteProposta.NumeroEndereco__c = '15';
        // ContratanteProposta.Bairro__c = 'Osasco';
        // ContratanteProposta.Cidade__c = 'São Paulo';
        // ContratanteProposta.Estado__c = 'SP';
        // ContratanteProposta.Pais__c = 'Brasil';
        // ContratanteProposta.ResponsavelPagamento__c = (contaParceiro != null) ? contaParceiro.Id : null;
        // ContratanteProposta.FormaPagamento__c = formaPagamento.Id;
        // ContratanteProposta.PremioTotal__c = 10;
        // ContratanteProposta.PremioComercial__c = 10;
        // ContratanteProposta.IOF__c = 1;
        // ContratanteProposta.QuantidadeParcelas__c = 1;
        // ContratanteProposta.EnderecoBoleto__c = 'http://www.google.com.br';
        // ContratanteProposta.TipoResponsavelPagamento__c = 'PAR';
        // ContratanteProposta.VencimentoPrimeiraParcela__c = System.today();
        // ContratanteProposta.PremioPuro__c = 100;
        // ContratanteProposta.TaxaPura__c = 10;
        // ContratanteProposta.TaxaComercial__c = 10;
        // ContratanteProposta.Numero__c = 1;
        // INSERT ContratanteProposta;

        // ContratanteProposta = [SELECT 
        // ResponsavelPagamento__r.Name,
        // ResponsavelPagamento__r.Phone,
        // ResponsavelPagamento__r.Cnpj__c,
        // ResponsavelPagamento__r.RecordTypeId,
        // ResponsavelPagamento__r.PersonHomePhone,
        // ResponsavelPagamento__r.PersonOtherPhone,
        // ResponsavelPagamento__r.PersonBirthdate,
        // ResponsavelPagamento__r.Fax,
        // ResponsavelPagamento__r.PersonMobilePhone,
        // FormaPagamento__r.Id,
        // FormaPagamento__r.Codigo__c,
        // Conta__r.Sexo__c,
        // Conta__r.PersonMobilePhone,
        // Conta__r.Fax,
        // Conta__r.Phone,
        // Conta__r.EstadoCivil__c,
        // Conta__r.PersonBirthdate,
        // Conta__r.CPF__c,
        // Conta__r.PersonHomePhone,
        // Conta__r.PersonOtherPhone,
        // Conta__r.Email__c,
        // Conta__r.Name,
        // Conta__c, 
        // Tipo__c, 
        // Conta__r.RecordTypeId, 
        // proposta__c, 
        // TipoEndereco__c, 
        // Cep__c, 
        // TipoLogradouro__c, 
        // Logradouro__c, 
        // NumeroEndereco__c, 
        // Bairro__c, 
        // Cidade__c, 
        // Estado__c, 
        // Pais__c, 
        // ResponsavelPagamento__c, 
        // PremioTotal__c, 
        // FormaPagamento__c, 
        // PremioComercial__c, 
        // IOF__c, 
        // QuantidadeParcelas__c, 
        // EnderecoBoleto__c, 
        // TipoResponsavelPagamento__c, 
        // VencimentoPrimeiraParcela__c, 
        // PremioPuro__c, 
        // TaxaPura__c, 
        // TaxaComercial__c, 
        // Numero__c
        //     FROM
        //         ContratanteProposta__c
        //     WHERE
        //         Id =: ContratanteProposta.Id
        // ];

        // GrupoProposta__c grupoProposta = new GrupoProposta__c();
        // grupoProposta.Descricao__c = '1';
        // grupoProposta.QuantidadeVidas__c = 1;
        // grupoProposta.ContratanteProposta__c = contratanteProposta.Id;
        // grupoProposta.Name = 'Pessoa física';
        // grupoProposta.Numero__c = 1;    
        // INSERT grupoProposta;

        // SeguradoProposta__c seguradoProposta = new SeguradoProposta__c();
        // seguradoProposta.Conta__c = contaTeste.Id;
        // seguradoProposta.FaixaRenda__c = '2500';
        // seguradoProposta.ResponsavelPagamento__c = contaParceiro.Id;
        // seguradoProposta.FormaPagamento__c = formaPagamento.Id;
        // seguradoProposta.PremioTotal__c = 10;
        // seguradoProposta.GrupoProposta__c = grupoProposta.Id;
        // seguradoProposta.EnderecoBoleto__c = 'http://www.google.com.br';
        // seguradoProposta.PremioComercial__c = 10;
        // seguradoProposta.IOF__c = 1;
        // seguradoProposta.Numero__c = 1;
        // seguradoProposta.PEP__C = 'Sim';
        // INSERT seguradoProposta;
    
        // listaContratanteProposta.add(ContratanteProposta);

        // for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Account'))
        // {
        //     mapStringXRecordType.put(tipo.Id, tipo);
        // }

        //  Test.startTest();
        // // ContractFacade.getInstance().parseDadosContratantes(listaContratanteProposta, RamoSeguro.Id, mapStringXRecordType);
        // // seguradoProposta.FaixaRenda__c = '4000';
        // // seguradoProposta.PEP__C = 'Não';
        // // UPDATE seguradoProposta;

        // // listaContratanteProposta.add(ContratanteProposta);

        // // ContractFacade.getInstance().parseDadosContratantes(listaContratanteProposta, RamoSeguro.Id, mapStringXRecordType);

        // // seguradoProposta.FaixaRenda__c = '8000';
        // // seguradoProposta.PEP__C = 'RelacionamentoProximo';
        // // seguradoProposta.NomePessoaRelacionamentoProximo__c = 'XXXX';
        // // seguradoProposta.TipoPessoaRelacionamentoProximo__c = 'PessoaFisica';
        // // seguradoProposta.CpfPessoaRelacionamentoProximo__c = '121.121.121-12';
        // // UPDATE seguradoProposta;

        // // listaContratanteProposta.add(ContratanteProposta);

        // // ContractFacade.getInstance().parseDadosContratantes(listaContratanteProposta, RamoSeguro.Id, mapStringXRecordType);

        // seguradoProposta.FaixaRenda__c = '8005';
        // UPDATE seguradoProposta;

        // listaContratanteProposta.add(ContratanteProposta);

        // ContractFacade.getInstance().parseDadosContratantes(listaContratanteProposta, RamoSeguro.Id, mapStringXRecordType);

        // try 
        // {
        //     ContractFacade.getInstance().parseDadosContratantes(null, null, null);    
        // } 
        // catch (Exception e) {   
        // }
        // Test.stopTest();
        // } // removendo, método quebrado -- ANNVI-55 - INICIO/FIM
        
        @IsTest
        static void parseDadosRemuneracaoTest(){

        List<RemuneracaoProposta__c> listaRemuneracaoProposta = new List<RemuneracaoProposta__c>();

        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c];
    
        quote proposta = [SELECT Id FROM quote LIMIT 1];
        proposta.CanalDistribuicao__c = 'a0AL0000007eweUMAQ';
        //Update proposta;
    
        Account contaTeste = [SELECT Id FROM Account];
        contaTeste.Sucursal__c = 'XXXX';
    
        RamoSeguro__c ramoSeguro = [SELECT Id FROM RamoSeguro__c];
    
        Map<String, RecordType> mapStringXRecordType = new Map<String, RecordType>();

        ContratoTo.SeguradosTO contratoToSeguradoTo = new ContratoTo.SeguradosTO();
    
        Account contaParceiro = new Account(Name = 'ParceiroTeste', 
                                            CodigoEmpresa__c = '12', 
                                            IdExterno__c = '67708896000139', 
                                            Inscricao_Municipal__c = '123456789', 
                                            Cnpj__c = '67.708.896/0001-39'); 
        INSERT contaParceiro;
    
        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c();
        tipoRemuneracao.Name = 'COMISSÃO';
        tipoRemuneracao.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
        tipoRemuneracao.ModeloRecuperacao__c = 'Integral';
        tipoRemuneracao.Codigo__c = 'COM';
        tipoRemuneracao.LimiteMinimo__c = 10;
        tipoRemuneracao.LimiteMaximo__c = 50;
        INSERT tipoRemuneracao;

        RemuneracaoProposta__c remuneracaoProposta = new RemuneracaoProposta__c();
        remuneracaoProposta.TipoRemuneracao__c = tipoRemuneracao.Id;
        remuneracaoProposta.Proposta__c = proposta.Id;
        remuneracaoProposta.Percentual__c = 100;
        INSERT remuneracaoProposta;

        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c();
        favorecidoRemuneracaoProposta.Conta__c = contaTeste.Id;
        favorecidoRemuneracaoProposta.Papel__c = 'Parceiro';
        favorecidoRemuneracaoProposta.Participacao__c = 100;
        favorecidoRemuneracaoProposta.RemuneracaoProposta__c = remuneracaoProposta.Id;
        favorecidoRemuneracaoProposta.Susep__c = '123';
        favorecidoRemuneracaoProposta.SusepEmissao__c = '123';
        favorecidoRemuneracaoProposta.SusepOficialCorretor__c = '123';
        favorecidoRemuneracaoProposta.SusepOrcamento__c = '123';
        INSERT favorecidoRemuneracaoProposta;

        listaRemuneracaoProposta = [SELECT Id,
                                    TipoRemuneracao__r.Name,
                                    Percentual__c,
                                        (SELECT Conta__r.Name,
                                        Conta__r.NomeSocial__c, // ANNVI-55 - INICIO/FIM
                                        Conta__r.RecordTypeId,
                                        Conta__r.Sexo__c,
                                        Conta__r.PersonMobilePhone,
                                        Conta__r.Fax,
                                        Conta__r.Phone,
                                        Conta__r.EstadoCivil__c,
                                        Conta__r.PersonBirthdate,
                                        Conta__r.CPF__c,
                                        Conta__r.PersonHomePhone,
                                        Conta__r.PersonOtherPhone,
                                        Conta__r.Email__c,
                                        Papel__c,
                                        Participacao__c,
                                        CorretorLider__c,
                                        SusepOficialCorretor__c,
                                        SusepEmissao__c,
                                        SusepOrcamento__c,
                                        susep__c
                                        FROM FavorecidosRemuneracaodaProposta__r ) 
                                    FROM RemuneracaoProposta__c];

        
        listaRemuneracaoProposta.add(remuneracaoProposta);

        for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Account'))
        mapStringXRecordType.put(tipo.Id, tipo);
    
        Test.startTest();
        ContractFacade.getInstance().parseDadosRemuneracao(proposta.CanalDistribuicao__c, favorecidoRemuneracaoProposta.susep__c, contaTeste.Sucursal__c, listaRemuneracaoProposta, mapStringXRecordType);
    
        try {
        ContractFacade.getInstance().parseDadosRemuneracao(null, null, null, null, null);    
        } 
        catch (Exception e) {    
        }
        Test.stopTest();
        }

        // AJUSTE CLASSE DE TESTE - FIM
        //ANNVI-55 - INICIO
        @IsTest
        static void testarCriarConsultaProposta(){

            String jsonString = '{"empresa": "1","proposta":"00052493","ramo": "1391","origem": "18", "parcela": 1}';

            Test.startTest();

            Map<String, Sobject> records = new Map<String, Sobject>();
            records.put('AccountPessoaFisica', (Account) new AccountFactory.PessoaFisica().createRecord());
            
            Account conta = (Account) records.get('AccountPessoaFisica');
            Product2 produtoComercial = [SELECT Id FROM Product2 WHERE Name = 'Nome Produto Comercial'];
            
            CanalDistribuicao__c canalDistribuicao = CreateTestData.createCanalDistribuicao();

            String payloadName = 'PayloadOrcamento001';
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
            Blob payloadEntrada = sr.Body;

            Opportunity orcamento = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-1100760',
            CloseDate = System.today().addDays(19),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(2),
            Produto__c = produtoComercial.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
            AccountId = conta.Id,
            Numero__c = '10005760',
            CanalDistribuicao__c = canalDistribuicao.Id,
            Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );

        insert orcamento;

            records.put('ProdutoComercial', produtoComercial);

            RamoSeguro__c ramoSeguro = CreateTestData.createRamoSeguro((Account) records.get('AccountPessoaFisica'));
            ramoSeguro.Codigo__c = '1391';

            update ramoSeguro;

            records.put('RamoSeguro', ramoSeguro);
            records.put('RamoAtividade', CreateTestData.createRamoAtividade('Teste'));
            records.put('AccountPessoaJuridica', CreateTestData.createAccountWithRecordTypeAndRamoAtividade('PessoaJuridica', (RamoAtividade__c) records.get('RamoAtividade')));
            records.put('FormaPagamento', CreateTestData.createFormaPagamento());
            records.put('AccountPessoaFisica', (Account) new AccountFactory.PessoaFisica().createRecord());
            records.put('Parceiro', CreateTestData.createParceiro((Account) records.get('AccountPessoaJuridica'), (FormaPagamento__c) records.get('FormaPagamento'))); 
            records.put('DadosCorretor', CreateTestData.createDadosCorretor((Account) records.get('AccountPessoaFisica')));
            records.put('Contrato', CreateTestData.createContract((Account) records.get('AccountPessoaFisica'), (Product2) records.get('ProdutoComercial'), (Parceiro__c) records.get('Parceiro'), (RamoSeguro__c) records.get('RamoSeguro'), (FormaPagamento__c) records.get('FormaPagamento'), (DadosCorretor__c) records.get('DadosCorretor')));
            records.put('CanalDistribuicao', CreateTestData.createCanalDistribuicao());            
            records.put('Modalidade', CreateTestData.createModalidade((RamoSeguro__c) records.get('RamoSeguro')));
            records.put('Proposta', CreateTestData.createProposta((RamoSeguro__c) records.get('RamoSeguro'), (Product2) records.get('ProdutoComercial'), (Account) records.get('AccountPessoaFisica'), (DadosCorretor__c) records.get('DadosCorretor'), orcamento, (Modalidade__c) records.get('Modalidade')));
            records.put('ContratanteContrato', CreateTestData.createContratanteContrato((Contract) records.get('Contrato'), (Account) records.get('AccountPessoaFisica'), (FormaPagamento__c) records.get('FormaPagamento')));

            ContratanteContrato__c contratanteContrato = ((ContratanteContrato__c) records.get('ContratanteContrato'));
            contratanteContrato.FormaPagamento__c = ((FormaPagamento__c) records.get('FormaPagamento')).Id;
            contratanteContrato.Conta__c = ((Account) records.get('AccountPessoaFisica')).Id;
            contratanteContrato.FormaPagamento__r = (FormaPagamento__c) records.get('FormaPagamento');
            contratanteContrato.Conta__r = (Account) records.get('AccountPessoaFisica');

            update contratanteContrato;

            Contract contract = (Contract) records.get('Contrato');
            contract.Empresa__c = '1';
            contract.RamoSeguro__c = ((RamoSeguro__c) records.get('RamoSeguro')).Id;
            contract.RamoSeguro__r = (RamoSeguro__c) records.get('RamoSeguro');
            contract.RamoSeguro__r.Codigo__c = '1391';
            contract.Proposta__c = ((Quote) records.get('Proposta')).Id;
            contract.Proposta__r = (Quote) records.get('Proposta');
            contract.Proposta__r.NumeroProposta__c = '00052493';
            contract.Proposta__r.Origem__c = '18';

            update contract;
           
            ConsultarDadosContratoTO.DadosContratoTO dadosContrato = ContractFacade.getInstance().consultarProposta(jsonString);
                
            Test.stopTest();
            
        }

        @isTest static void testarMapeiaPayloadContratoParaTipoNovo() {       

            Test.startTest();
    
            Account conta = new Account(
                Name = 'testeAcc', 
                Cpf__c = '09638381051',
                Cnpj__c = '38057572000180',
                Phone = '11 900000000'
            );
    
            insert conta;
    
            Contract contratoOriginal = new Contract(
                        Name = 'testeCtr',
                        StartDate = System.today(),
                        VigenciaFinal__c = System.today().addYears(1),
                        DataEmissao__c = System.today(),
                        NumeroApolice__c = '000001834',
                        AccountId = conta.Id,
                        Endosso__c = '0',
                        NumeroProposta__c = '00052493'    
            );
    
            Product2 produtoComercial = [SELECT Id, Name FROM Product2 WHERE Name = 'Nome Produto Comercial'];
            produtoComercial.Name = 'Produto teste';

            update produtoComercial;

            RamoSeguro__c ramoSeguro = CreateTestData.createRamoSeguro(conta);
            DadosCorretor__c dadosCorretor = CreateTestData.createDadosCorretor(conta);
            CanalDistribuicao__c canalDistribuicao = CreateTestData.createCanalDistribuicao();

            String payloadName = 'PayloadOrcamento001';
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
            Blob payloadEntrada = sr.Body;
       
            Opportunity orcamento = new Opportunity(
                    StageName = 'Em criação',
                    CurrencyIsoCode = 'BRL',
                    Name = 'ARQ-10006760',
                    CloseDate = System.today().addDays(19),
                    VigenciaInicial__c = System.today(),
                    VigenciaFinal__c = System.today().addDays(2),
                    Produto__c = produtoComercial.Id,
                    Probability = 10.0,
                    RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
                    AccountId = conta.Id,
                    Numero__c = '10006762',
                    CanalDistribuicao__c = canalDistribuicao.Id,
                    Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
            );

            insert orcamento;

            Modalidade__c modalidade  = CreateTestData.createModalidade(ramoSeguro);
            Quote cotacao = CreateTestData.createProposta(ramoSeguro, produtoComercial, conta, dadosCorretor, orcamento, modalidade);
            cotacao.Tipo__c = 'Novo';

            update cotacao;
            
            upsert contratoOriginal;

            Product2 produtoTecnico = [SELECT Id, Name FROM Product2 WHERE Name = 'Nome Produto Tecnico'];
            GarantiaProduto__c garantiaProduto = CreateTestData.createGarantiaProdutoWithProdutoTecnico(CreateTestData.createGarantia(), produtoTecnico, ramoSeguro);
            GarantiaProposta__c garantiaProposta = CreateTestData.createGarantiaProposta(CreateTestData.createGarantia(), cotacao, garantiaProduto);

            Map<String, String> mapPropostaApolice = new Map<String, String>();
            mapPropostaApolice.put(cotacao.NumeroProposta__c, contratoOriginal.NumeroApolice__c);

            FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
            ContratanteProposta__c contratanteProposta = TestDataFactory.gerarContratanteProposta(conta, cotacao, formaPagamento);

            contratanteProposta.Conta__c = conta.Id;
            contratanteProposta.PremioIntegral__c = 1000;
            contratanteProposta.TaxaTotal__c = 100;
            contratanteProposta.Recorrencia__c = false;
            contratanteProposta.Valor_PrimeiraParcela__c = 1.2;
            contratanteProposta.Valor_DemaisParcelas__c = 1;
            contratanteProposta.DescontoAgravoPercentualTecnico__c = 1;
            contratanteProposta.DescontoAgravoPercentualComercial__c = 1;
            contratanteProposta.DescontoAgravoMonetarioComercial__c = 1;
            contratanteProposta.DescontoAgravoMonetarioTecnico__c = 1;
            contratanteProposta.DescontoAgravoPercentualInformado__c = 1;
            contratanteProposta.DescontoAgravoMonetarioInformado__c = 1;
            contratanteProposta.DescontoAgravoPercentualFormaPagto__c = 1;
            contratanteProposta.DescontoAgravoMonetarioFormaPagto__c = 1;

            update contratanteProposta;

            GrupoProposta__c grupoProposta = TestDataFactory.gerarGrupoProposta(contratanteProposta);
            grupoProposta.TipoCalculo__c = 'GLO';
			grupoProposta.QuantidadeVidas__c = 1;
			grupoProposta.Descricao__c = '1';
			grupoProposta.PremioPuro__c = 1;
			grupoProposta.PremioTotal__c = 1;
			grupoProposta.PremioIntegral__c = 1;
			grupoProposta.TaxaPura__c = 1;
			grupoProposta.PremioComercial__c = 1;
			grupoProposta.TaxaComercial__c = 1;
			grupoProposta.TaxaTotal__c = 1;

            update grupoProposta;

            Garantia__c garantia = CreateTestData.createGarantia();
            
            GarantiasGrupoProposta__c garantiasGrupoProposta = TestDataFactory.gerarGarantiaGrupoProposta(garantia, grupoProposta);
            garantiasGrupoProposta.Capital__c = 1;
			garantiasGrupoProposta.GarantiaProduto__c = garantiaProduto.Id;
			garantiasGrupoProposta.Percentual__c = 100;
			garantiasGrupoProposta.PremioComercial__c = 1;
			garantiasGrupoProposta.PremioPuro__c = 1;
			garantiasGrupoProposta.PremioTotal__c = 1;
			garantiasGrupoProposta.PremioIntegral__c = 1;
			garantiasGrupoProposta.TaxaComercial__c = 1;
			garantiasGrupoProposta.TaxaPura__c = 1;
			garantiasGrupoProposta.TaxaTotal__c = 1;
			garantiasGrupoProposta.Valor__c = 1;
			garantiasGrupoProposta.ValorCotacao__c = 1;
			garantiasGrupoProposta.CurrencyIsoCode = 'BRL';

            update garantiasGrupoProposta;

            ContratoTO.PayloadTO retorno = ContractFacade.getInstance().mapeiaPayloadContrato(cotacao, mapPropostaApolice);

            
            Test.stopTest();            
        }

        @isTest static void conCtrRem(){
            String jsonString = '{"empresa": "1","sucursal": "1","ramo": "1391","apolice": "000016160","endosso": "0","numeroparcela": 1}'; 
            String retorno = '{"data":[{"idexterno":"800DP000003ybhtYAA_a0fDP000007sfO0YAI","idfatura":null,"codigoparceiro":null,"origemproposta":18,"idproposta":"18-00052538","numeropropostaporto":"00052538","numerofatura":null,"responsavelfinanceiro":"001L000001akRknIAE","tiporesponsavelpagamento":"CON","seguradosalesforce":"a0fDP000007sfO0YAI","vidasalesforce":null,"datapagamento":null,"datavencimento":"2023-03-12T00:00:00.000Z","datapagamentoparceiro":null,"dataemissao":"2023-03-01T00:00:00.000Z","datacancelamento":"2023-03-01T00:00:00.000Z","numeroparcela":1,"status":"CANCELADA","titulo":"","produto":"VI-PESSOASSSSS2","valoriof":"0.65","valorliquido":"151.81","valorparcela":"152.46","valorrestituicao":null,"valorpago":null,"empresa":"1","sucursal":"35","ramo":"1391","apolice":"000002667","endosso":"1","quantidadevidacontrato":null,"dataatualizacao":"2023-03-01T00:00:00.000Z","antecipacaocomissao":"P","datacobertura":"2023-06-10T00:00:00.000Z","valoragenciamento":"151.79","statusIntegracao":"PENDENTE","processarintegracaoantares":null,"dataintegracaoantares":null,"id":133569}],"meta":{"dataExecucao":"2023-03-02T12:32:08.130Z","servico":"Consultar parcelas do contrato ","statusHttp":200,"mensagem":"Ok"}}';

            prepararDadosConCtrRem();
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));
            ContractFacade.getInstance().consultarContrato(jsonString);
            Test.stopTest();
        }

        private static void prepararDadosConCtrRem(){
            Product2 produtoComercial = [SELECT Id, Name, NumeroSusep__c  FROM Product2 WHERE Name = 'Nome Produto Comercial'];
            Product2 produtoTecnico = [SELECT Id, Name FROM Product2 WHERE Name = 'Nome Produto Tecnico'];

            Map<String, SObject> records = new Map<String, SObject>();

            records.put('AccountPessoaFisica', (Account) new AccountFactory.PessoaFisica().createRecord());
            records.put('RamoSeguro', CreateTestData.createRamoSeguro((Account) records.get('AccountPessoaFisica')));
            records.put('RamoAtividade', CreateTestData.createRamoAtividade('Teste'));
            records.put('AccountPessoaJuridica', CreateTestData.createAccountWithRecordTypeAndRamoAtividade('PessoaJuridica', (RamoAtividade__c) records.get('RamoAtividade')));
            records.put('FormaPagamento', CreateTestData.createFormaPagamento());
            records.put('Parceiro', CreateTestData.createParceiro((Account) records.get('AccountPessoaJuridica'), (FormaPagamento__c) records.get('FormaPagamento'))); 
            records.put('DadosCorretor', CreateTestData.createDadosCorretor((Account) records.get('AccountPessoaFisica')));
            records.put('Contrato', CreateTestData.createContract((Account) records.get('AccountPessoaFisica'), produtoComercial, (Parceiro__c) records.get('Parceiro'), (RamoSeguro__c) records.get('RamoSeguro'), (FormaPagamento__c) records.get('FormaPagamento'), (DadosCorretor__c) records.get('DadosCorretor')));
            records.put('CanalDistribuicao', CreateTestData.createCanalDistribuicao());            
            records.put('Modalidade', CreateTestData.createModalidade((RamoSeguro__c) records.get('RamoSeguro')));
            records.put('ContratanteContrato', CreateTestData.createContratanteContrato((Contract) records.get('Contrato'), (Account) records.get('AccountPessoaFisica'), (FormaPagamento__c) records.get('FormaPagamento')));
            records.put('Garantia', CreateTestData.createGarantia());
            records.put('GarantiaProduto', CreateTestData.createGarantiaProdutoWithProdutoTecnico((Garantia__c) records.get('Garantia'), produtoTecnico, (RamoSeguro__c) records.get('RamoSeguro')));

            Account contaPF = (Account) records.get('AccountPessoaFisica');
            Account contaPJ = (Account) records.get('AccountPessoaJuridica');
            CanalDistribuicao__c canalDistribuicao = (CanalDistribuicao__c) records.get('CanalDistribuicao');
            DadosCorretor__c dadosCorretor = (DadosCorretor__c) records.get('DadosCorretor');            
            Contract contrato = (Contract) records.get('Contrato');

            String payloadName = 'PayloadOrcamento001';
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
            Blob payloadEntrada = sr.Body;
            
            Opportunity orcamento = new Opportunity(
                    StageName = 'Em criação',
                    CurrencyIsoCode = 'BRL',
                    Name = 'ARQ-10006723',
                    CloseDate = System.today().addDays(20),
                    VigenciaInicial__c = System.today(),
                    VigenciaFinal__c = System.today().addDays(1),
                    Produto__c = produtoComercial.Id,
                    Probability = 10.0,
                    RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
                    AccountId = contaPF.Id,
                    Numero__c = '10006723',
                    CanalDistribuicao__c = canalDistribuicao.Id,
                    Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
            );
    
            insert orcamento;

            records.put('Proposta', CreateTestData.createProposta((RamoSeguro__c) records.get('RamoSeguro'), produtoComercial, (Account) records.get('AccountPessoaFisica'), (DadosCorretor__c) records.get('DadosCorretor'), orcamento, (Modalidade__c) records.get('Modalidade')));
            Quote proposta = (Quote) records.get('Proposta');

            RamoSeguro__c ramoSeguro = (RamoSeguro__c) records.get('RamoSeguro');
            FormaPagamento__c formaPagamento = (FormaPagamento__c) records.get('FormaPagamento');
            Parceiro__c parceiro = (Parceiro__c) records.get('Parceiro');
            ContratanteContrato__c contratanteContrato = (ContratanteContrato__c) records.get('ContratanteContrato');
            Garantia__c garantia = (Garantia__c) records.get('Garantia');
            GarantiaProduto__c garantiaProduto =  (GarantiaProduto__c) records.get('GarantiaProduto');
            Modalidade__c modalidade = (Modalidade__c) records.get('Modalidade');

            contaPF.Pescod__c = '11581547';
            update contaPF;

            orcamento.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id;
            update orcamento;

            proposta.Name = '18-00052538';
            proposta.NumeroProposta__c = '00052538';
            proposta.Modalidade__c = modalidade.Id;
            proposta.Modalidade__r = modalidade;
            proposta.OpportunityId = orcamento.Id;

            update proposta;

            contrato.Nome_Social__c = 'Teste nome';
            contrato.Name = '1-1-1391-000016160-0';
            contrato.Empresa__c = '1';
            contrato.DataEmissao__c = System.today();
            contrato.Proposta__c = proposta.Id;
            contrato.RamoSeguro__c = ramoSeguro.Id;
            contrato.RamoSeguro__r = ramoSeguro;
            contrato.Sucursal__c = '1';
            contrato.Endosso__c = '0';
            contrato.Origem__c = '18';
            contrato.VigenciaFinal__c = Date.valueOf('2025-07-22');
            contrato.FormaPagamento__c = formaPagamento.Id;
            contrato.FormaPagamento__r = formaPagamento;
            contrato.CodigoCorretor__c = dadosCorretor.Id;
            contrato.CodigoCorretor__r = dadosCorretor;
            contrato.Tipo__c = 'Novo';
            contrato.Produto__c = produtoComercial.Id;
            contrato.AccountId = contaPF.Id;
            contrato.Account = contaPF;
            contrato.CanalDistribuicao__c = canalDistribuicao.Id;
            contrato.CodigoRamo__c = '1391';
            contrato.IdExterno__c = '1-1-1391-000016160-0';
            contrato.ImprimirCertificadoSeguro__c = false;
            contrato.MeioComercializacao__c = 'SFC';
            contrato.NumeroApolice__c = '000016160';
            contrato.Oportunidade__c = orcamento.Id;
            contrato.Parceiro__c = 'CDF';
            contrato.Parceria__c = parceiro.Id;
            contrato.PremioComercial__c = 9435.18000;
            contrato.PremioPuro__c = 3774.07000;
            contrato.PremioTotal__c = 9471.03000;
            contrato.ValorIOF__c = 35.85;
            contrato.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Contract', 'VidaIndividual').Id;
            contrato.Seguradora__c = contaPJ.Id;
            contrato.Status = 'Emitido';
            contrato.Produto__r = produtoComercial;
            

            update contrato;

            TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
            tipoRemuneracao.Name = 'CORRETAGEM';

            update tipoRemuneracao;

            RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
            remuneracaoContrato.TipoRemuneracao__r = tipoRemuneracao;
            remuneracaoContrato.Percentual__c = 30.00;

            update remuneracaoContrato;

            contratanteContrato.IOF__c = 35.85000;
            contratanteContrato.PremioComercial__c = 9435.18000;
            contratanteContrato.PremioPuro__c = 3774.07000;
            contratanteContrato.PremioTotal__c = 9471.03000;
            contratanteContrato.DescontoAgravoMonetarioTecnico__c = 0.00;
            contratanteContrato.DescontoAgravoPercentualTecnico__c = 0.00;
            contratanteContrato.QuantidadeParcelas__c = 6;
            contratanteContrato.Conta__r = contaPF;
            contratanteContrato.FormaPagamento__r = formaPagamento;

            update contratanteContrato;

            GarantiaContrato__c garantiaContrato = TestDataFactory.gerarGarantiaContrato(contrato, garantiaProduto);
            garantiaContrato.IOF__c = 1.01000;
            garantiaContrato.Capital__c = 10000.00;
            garantiaContrato.Garantia__c = garantia.Id;
            garantiaContrato.PremioComercial__c = 266.00;
            garantiaContrato.PremioIntegral__c = 0.00000;
            garantiaContrato.PremioPuro__c = 106.40;
            garantiaContrato.PremioTotal__c = 267.01;
            garantiaContrato.TaxaComercial__c = 0.02660;
            garantiaContrato.TaxaPura__c = 0.01064;
            garantiaContrato.TaxaTotal__c = 0.02670108;
            garantiaContrato.CurrencyIsoCode = 'BRL';
            garantiaContrato.DescontoAgravoMonetarioComercial__c = 0.00;
            garantiaContrato.DescontoAgravoMonetarioInformado__c = 0.00;
            garantiaContrato.DescontoAgravoMonetarioTecnico__c = 0.00;
            garantiaContrato.DescontoAgravoPercentualComercial__c = 0.00;
            garantiaContrato.DescontoAgravoPercentualInformado__c = 0.00;
            garantiaContrato.DescontoAgravoPercentualTecnico__c = 0.00;
           
            update garantiaContrato;

            FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
            favorecidoRemuneracaoContrato.Conta__c = contaPF.Id;
            favorecidoRemuneracaoContrato.CorretorLider__c = true;
            favorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
            favorecidoRemuneracaoContrato.Susep__c = 'p5005j';
            favorecidoRemuneracaoContrato.SusepEmissao__c = 'p5005j';
            favorecidoRemuneracaoContrato.SusepOrcamento__c = 'p5005j';
            favorecidoRemuneracaoContrato.DadosCorretor__c = dadosCorretor.Id;
            favorecidoRemuneracaoContrato.Papel__c = 'Corretor';
            favorecidoRemuneracaoContrato.Participacao__c = 100;

            insert favorecidoRemuneracaoContrato;
        }
        //ANNVI-55 - FIM
}