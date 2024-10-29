@IsTest
public class ConsultaAcumuloCapitalRestTest {
    //PLV-4503 INICIO
    @TestSetup
    static void makeData() {
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord(); 
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();  
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord(); 
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;

        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;

        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
        
        garanProdCom.VigenciaGarantia__c = 'Contratação até fim da apólice';
        update garanProdCom;
        
        Recordtype rcT = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico');
        
        GarantiaProduto__c gproduto = new GarantiaProduto__c(
            Garantia__c = garantia.Id,
            Produto__c = produtoTecnico.Id,
            RamoSeguro__c = ramoSeguro.Id,
            OrdemPrioridade__c = 2,
            RecordTypeId = rcT.Id,
            TipoGarantia__c = 'Cobertura',
            TipoCapital__c = 'Capital uniforme',
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1'
        );
        insert gproduto; 

        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        RamoAtividade__c ramoAtividade = (RamoAtividade__c) new RamoAtividadeFactory().createRecord();
        
        Account contaParceiro = (Account) new AccountFactory.PessoaJuridica(ramoAtividade).createRecord();
        contaParceiro.Name = 'ASSISTCARD';
        update contaParceiro;

        Parceiro__c parceiroPrestadora = (Parceiro__c) new ParceiroFactory(contaParceiro, formaPagamento).createRecord();
        parceiroPrestadora.status__c = 'Ativo';
        parceiroPrestadora.Sucursal__c = '1';
        parceiroPrestadora.ramo__c = '1396';
        parceiroPrestadora.empresa__c = '1';
        update parceiroPrestadora;

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiroPrestadora).createRecord();
        contrato.Status = 'Emitido';
        update contrato;

        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(Contrato__c = contrato.Id, Conta__c = conta.Id, Tipo__c = 'Principal'); 
        insert contratanteContrato;

        GrupoContrato__c grupoContrato = (GrupoContrato__c) new GrupoFactory(contratanteContrato).createRecord();
        SeguradoContrato__c seguradoContrato = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupoContrato).createRecord(); 
        seguradoContrato.VigenciaInicial__c = system.today();
        seguradoContrato.VigenciaFinal__c = system.today().addMonths(1);
        update seguradoContrato;
        
        insert new GarantiaContrato__c(GarantiaProduto__c = gproduto.Id, Contrato__c = contrato.Id, Garantia__c = garantia.Id, Capital__c = 10000.00);
    } 

    @IsTest
    static void consultaAcumuloCapitalBadRequestTest() {        
        ConsultaAcumuloCapitalRest.Request reqBody = new ConsultaAcumuloCapitalRest.Request();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/contrato/consultaAcumuloCapital'; 

        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();

        //Request
        ConsultaAcumuloCapitalRest.consultaAcumuloCapital();

        //Response
        ConsultaAcumuloCapitalRest.Response respBody = (ConsultaAcumuloCapitalRest.Response) JSON.deserialize(
            res.responseBody.toString(), ConsultaAcumuloCapitalRest.Response.class
        ); 

        System.assertEquals('FAIL', respBody.status);
        System.assertEquals(400, res.statusCode);

        Test.stopTest();
    }

    @IsTest
    static void consultaAcumuloCapitalSucessoTest() {        
        ConsultaAcumuloCapitalRest.Request reqBody = new ConsultaAcumuloCapitalRest.Request();
        reqBody.cpf = '43891231814';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/contrato/consultaAcumuloCapital'; 

        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();

        //Request
        ConsultaAcumuloCapitalRest.consultaAcumuloCapital();

        //Response
        ConsultaAcumuloCapitalRest.Response respBody = (ConsultaAcumuloCapitalRest.Response) JSON.deserialize(
            res.responseBody.toString(), ConsultaAcumuloCapitalRest.Response.class
        );  

        System.assertEquals('OK', respBody.status);
        System.assertEquals('Sucesso', respBody.mensagem);
        System.assertEquals(0, respBody.coberturas.size()); //PLV-4923 INICIO / FIM

        Test.stopTest();
    }

    @IsTest
    static void consultaAcumuloCapitalLegadoSemAcumuloTest() {        
        ConsultaAcumuloCapitalRest.Request reqBody = new ConsultaAcumuloCapitalRest.Request();
        reqBody.cpf = '43891231814';
        reqBody.coberturasLegado = new List<ConsultaAcumuloCapitalRest.Cobertura>();
        reqBody.coberturasPortal = new List<ConsultaAcumuloCapitalRest.Cobertura>();
        ConsultaAcumuloCapitalRest.Cobertura cobertura = new ConsultaAcumuloCapitalRest.Cobertura();
        cobertura.sigla = 'DEF';
        cobertura.valor = 666;
        reqBody.coberturasLegado.add(cobertura);
        reqBody.coberturasPortal.add(cobertura);


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/contrato/consultaAcumuloCapital'; 

        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();

        //Request
        ConsultaAcumuloCapitalRest.consultaAcumuloCapital();

        //Response
        ConsultaAcumuloCapitalRest.Response respBody = (ConsultaAcumuloCapitalRest.Response) JSON.deserialize(
            res.responseBody.toString(), ConsultaAcumuloCapitalRest.Response.class
        );  

        System.assertEquals('OK', respBody.status);
        System.assertEquals('Sucesso', respBody.mensagem);
        System.assertEquals(1, respBody.coberturas.size()); //PLV-4923 INICIO / FIM

        Test.stopTest();
    }

    @IsTest
    static void consultaAcumuloCapitalLegadoComAcumuloTest() {        
        ConsultaAcumuloCapitalRest.Request reqBody = new ConsultaAcumuloCapitalRest.Request();
        reqBody.cpf = '43891231814';
        reqBody.coberturasLegado = new List<ConsultaAcumuloCapitalRest.Cobertura>();
        reqBody.coberturasPortal = new List<ConsultaAcumuloCapitalRest.Cobertura>();
        ConsultaAcumuloCapitalRest.Cobertura cobertura = new ConsultaAcumuloCapitalRest.Cobertura();
        cobertura.sigla = 'ABC';
        cobertura.valor = 10000;
        reqBody.coberturasLegado.add(cobertura);
        reqBody.coberturasPortal.add(cobertura);


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/contrato/consultaAcumuloCapital'; 

        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();

        //Request
        ConsultaAcumuloCapitalRest.consultaAcumuloCapital();

        //Response
        ConsultaAcumuloCapitalRest.Response respBody = (ConsultaAcumuloCapitalRest.Response) JSON.deserialize(
            res.responseBody.toString(), ConsultaAcumuloCapitalRest.Response.class
        );  

        System.assertEquals('OK', respBody.status);
        System.assertEquals('Sucesso', respBody.mensagem);
        System.assertEquals(1, respBody.coberturas.size());
        System.assertEquals(20000, respBody.coberturas[0].valor); //PLV-4923 INICIO - FIM

        Test.stopTest();
    }
    //PLV-4503 FIM
}