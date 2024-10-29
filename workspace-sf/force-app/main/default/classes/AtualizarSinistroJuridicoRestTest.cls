// POR062-1 - INICIO
@IsTest
public class AtualizarSinistroJuridicoRestTest {
    private static final String EMPRESA = '1';
    private static final String RAMO = '1369';
    private static final String ANO = System.now().format('yyyy');
    private static final String NUMERO_CASO = '500092';
    private static final String COBERTURA1 = 'DBAG';
    private static final String COBERTURA2 = 'DMHO';

    @TestSetup
    static void setup()
    {
        List<ContadorCodigo__c> contadoresCodigo = new List<ContadorCodigo__c>();
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().getRecord();
        contadoresCodigo.add(contadorTecnico);
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().getRecord();
        contadoresCodigo.add(contadorComercial);
        insert contadoresCodigo;
        
        RamoAtividade__c ramoAtividade = (RamoAtividade__c) new RamoAtividadeFactory().createRecord();

        List<Account> contas = new List<Account>();
        Account contaParceiro = (Account) new AccountFactory.PessoaJuridica(ramoAtividade).getRecord();
        contaParceiro.Name = 'ASSISTCARD';
        contas.add(contaParceiro);
        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();
        contas.add(conta);
        insert contas;

        //PLV-3904 - INICIO
        List<Garantia__c> garantias = new List<Garantia__c>();
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().getRecord();
        garantia.Sigla__c = COBERTURA1;
        garantias.add(garantia);
        
        Garantia__c garantia2 = new Garantia__c(
            Name = COBERTURA2,
            Status__c = 'Ativo',
            Sigla__c = COBERTURA2,
            Tipo__c = 'Cobertura',
            VigenciaInicial__c = System.today(),
            TipoEvento__c = 'Morte'
        );
        garantias.add(garantia2);
        insert garantias;
            
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        List<RamoGarantia__c> ramoGarantias = new List<RamoGarantia__c>();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).getRecord();
        ramoGarantias.add(ramoGarantia);
        RamoGarantia__c ramoGarantia2 = new RamoGarantia__c(
            Garantia__c = garantia2.Id,
            RamoSeguro__c = ramoSeguro.Id
        );
        ramoGarantias.add(ramoGarantia2);
        insert ramoGarantias;

        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        List<Product2> products = new List<Product2>();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        Recordtype rcT = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico');
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).getRecord();
        update garanProdTec;
        GarantiaProduto__c gproduto = new GarantiaProduto__c(
            Garantia__c = garantia2.Id,
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
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
        garanProdCom.VigenciaGarantia__c = 'Contratação até fim da apólice';
        update garanProdCom;
        
        
        Recordtype REC_ID_GarantiaProdutoCom = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial');
        GarantiaProduto__c garanProdCom2 =  new GarantiaProduto__c(
            Garantia__c = garantia2.Id,
            GarantiaProduto__c = gproduto.Id,
            Produto__c = produtoComercial.Id,
            OrdemPrioridade__c = 2,
            RecordTypeId = REC_ID_GarantiaProdutoCom.Id,
            TipoGarantia__c = 'Cobertura',
            TipoCapital__c = 'Capital uniforme',
            RamoSeguro__c = ramoSeguro.Id,
            TipoCaracteristicaEspecial__c = 'Cestas',
            LimiteMaximoCaracteristicaEspecial__c = 1000000001,
            LimiteMinimoCaracteristicaEspecial__c = 10,
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1',
            Obrigatoria__c = true,
            PrazoMaximoLiquidacao__c = 10,
            TipoPrazoMaximoLiquidacao__c = 'Dia',
            PrazoAvisoSinistro__c = 20,
            TipoPrazoAvisoSinistro__c = 'Ano',
            OrigemSinistroBeneficio__c = 'Acidente', //PLV-3777 - INICIO/FIM
            //PLV-3046 - INICIO
            LimiteCapitalMinimo__c = 200,
            LimiteCapitalMaximo__c = 900000001,
            currencyIsoCode = 'BRL'
            //PLV-3046 - FIM
        );
        insert garanProdCom2;
        //PLV-3904 - FIM

        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();

        Parceiro__c parceiroPrestadora = (Parceiro__c) new ParceiroFactory(contaParceiro, formaPagamento).createRecord();
        parceiroPrestadora.status__c = 'Ativo';
        parceiroPrestadora.Sucursal__c = '1';
        parceiroPrestadora.ramo__c = RAMO;
        parceiroPrestadora.empresa__c = EMPRESA;
        update parceiroPrestadora;

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiroPrestadora).createRecord();
        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(Contrato__c = contrato.Id, Conta__c = conta.Id, Tipo__c = 'Principal'); 
        insert contratanteContrato;

        GrupoContrato__c grupoContrato = (GrupoContrato__c) new GrupoFactory(contratanteContrato).createRecord();
        SeguradoContrato__c seguradoContrato = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupoContrato).createRecord(); 
        //PLV-3904 - INICIO
        seguradoContrato.VigenciaInicial__c = system.today();
        seguradoContrato.VigenciaFinal__c = system.today().addMonths(1);
        update seguradoContrato;
        //PLV-3904 - FIM
        
        List<GarantiaContrato__c> garantiasContrato = new List<GarantiaContrato__c>();
        GarantiaContrato__c garantiaContrato1 = new GarantiaContrato__c(
            Contrato__c = contrato.Id, Garantia__c = garantia.Id, Capital__c = 10000.00, TipoCapital__c = 'Capital uniforme'
        );
        garantiasContrato.add(garantiaContrato1);
        GarantiaContrato__c garantiaContrato2 = new GarantiaContrato__c(
            Contrato__c = contrato.Id, Garantia__c = garantia2.Id, Capital__c = 20000.00, TipoCapital__c = 'Capital uniforme'
        );
        garantiasContrato.add(garantiaContrato2);
        insert garantiasContrato;

        List<GarantiaSeguradoContrato__c> garantiasSeguradoContrato = new List<GarantiaSeguradoContrato__c>();
        GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(seguradoContrato,garantia).getRecord();
        garantiasSeguradoContrato.add(garantiaSeguradoContrato);
        
        GarantiaSeguradoContrato__c garantiaSeguradoContrato2 = new GarantiaSeguradoContrato__c(
            SeguradoContrato__c = seguradoContrato.Id,
            Garantia__c = garantia2.Id,
            GarantiaProduto__c = garanProdCom2.id,
            //PLV-4559 - INICIO
        	Tipo_de_limite_de_utilizacao__c = 'Dia(s)', //PLV-5747 INICIO/FIM
        	Limite_de_Uso__c = 900        
            //PLV-4559 -FIM
        );
        garantiasSeguradoContrato.add(garantiaSeguradoContrato2);
        insert garantiasSeguradoContrato;
        
        garantiaSeguradoContrato.GarantiaProduto__c = garanProdCom.id;
        //PLV-4559 - INICIO
        garantiaSeguradoContrato.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
        garantiaSeguradoContrato.Limite_de_Uso__c = 900;        
        //PLV-4559 -FIM
        update garantiaSeguradoContrato;

        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();
        favRemCont.Papel__c = 'Corretor';
		favRemCont.Susep__c = 'P5005J';
		update favRemCont;     

		proposta.Produto__c = produtoComercial.Id;
        proposta.Status = 'Contratada';
        proposta.Parceiro__c = '';
        proposta.MeioComercializacao__c = 'CO2';
        proposta.tipo__c = 'Novo';
        proposta.Massificados__c = false;
        update proposta;
        
        contrato.NumeroApolice__c = '002353575';
        contrato.Name = '12345';
        contrato.MeioComercializacao__c = 'CO2';
        contrato.ModalidadeSeguro__c = modalidade.Id;
        contrato.Proposta__c = proposta.Id;
        contrato.Produto__c = produtoComercial.Id;
        contrato.Tipo__c = 'Novo';
        contrato.Status = 'Emitido';
        update contrato;

        conta.Cpf__c = '398.169.840-16';
        update conta;

        //Criando Caso Atendimento Sinistro
        Contact contato = (Contact) new ContactFactory().createRecord();
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, conta).getRecord();
        //Atualizando o status do caso para 'Avisado'
        casoSinistro.ContactId = contato.id;
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSeguradoContrato.id;
        casoSinistro.NumeroSinistro__c = String.format('{0}.{1}.{2}.{3}', new String[] { EMPRESA, RAMO, ANO, NUMERO_CASO });
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Com Pendências';
        casoSinistro.Segurado_do_Contrato__c = seguradoContrato.id;
        casoSinistro.ProcessaNumeroSinistro__c = true;
        casoSinistro.RamoSplit__c = 1369;
        insert casoSinistro;

        PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro,garantiaSeguradoContrato).createRecord();
    }

    public static SinistroJuridicoBO.Request retornarBody()
    {
        SinistroJuridicoBO.Request consulta = new SinistroJuridicoBO.Request();
        consulta.ano = ANO;
        consulta.numero = NUMERO_CASO;
        consulta.ramo = RAMO;
        consulta.cobertura = COBERTURA1;
        consulta.empresa = EMPRESA;
        return consulta;
    }

    @isTest
    static void atualizarSinistrosTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.valor = 100;
        body.movimento = 22;
        body.matricula = 'ABCXPTO';

        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assertEquals(Integer.valueOf(body.ano), response.ano); 
        System.assertEquals(Integer.valueOf(body.ramo), response.ramo);
        System.assertEquals(Decimal.valueOf(body.numero), response.numero);
    }

    @isTest
    static void jurosTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.valor = 100;
        body.movimento = 52;
        body.matricula = 'ABCXPTO';

        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assertEquals(Integer.valueOf(body.ano), response.ano); 
        System.assertEquals(Integer.valueOf(body.ramo), response.ramo);
        System.assertEquals(Decimal.valueOf(body.numero), response.numero);
    }

    @isTest
    static void correcaoMonetariaTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.valor = 100;
        body.movimento = 62;
        body.matricula = 'ABCXPTO';

        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assertEquals(Integer.valueOf(body.ano), response.ano); 
        System.assertEquals(Integer.valueOf(body.ramo), response.ramo);
        System.assertEquals(Decimal.valueOf(body.numero), response.numero);
    }

    @isTest
    static void avisadoMenosTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.valor = 100;
        body.movimento = 22;
        body.matricula = 'ABCXPTO';

        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AtualizarSinistroJuridicoRest.processarPost();
        
        SinistroJuridicoBO.Request body2 = retornarBody();
        body.valor = 50;
        body.movimento = 22;
        body.matricula = 'ABCXPTO';

        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assertEquals(Integer.valueOf(body.ano), response.ano); 
        System.assertEquals(Integer.valueOf(body.ramo), response.ramo);
        System.assertEquals(Decimal.valueOf(body.numero), response.numero);
    }


    @IsTest
    public static void reabrirSinistroTest(){
    	RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.valor = 100;
        body.movimento = 22;
        body.matricula = 'ABCXPTO';
        String msg = body.validar('AtualizarSinistro'); // LECVPV-201 INICIO/FIM
        
		Test.startTest();
        Case caso = [SELECT Id FROM Case WHERE RecordType.DeveloperName='Sinistro' LIMIT 1];
        
        //PLV-4198 - Inicio
        List<PagamentoGarantia__c> lstPagamentoGarantia = [
            SELECT Id, Fase__c, Status_do_pagamento__c FROM PagamentoGarantia__c WHERE Caso__c=: caso.Id
        ];
        for( PagamentoGarantia__c pagamentoGarantia : lstPagamentoGarantia ) {
            pagamentoGarantia.Fase__c = 'Em análise';
            pagamentoGarantia.Status_do_pagamento__c='Cancelado';
        }
        update lstPagamentoGarantia;
        //PLV-4198 - Fim
        
        caso.Status = 'Fechado';
        caso.Status_Dependente__c = 'Cancelado';
        caso.Motivos_de_recusa__c ='4';
		update caso;

        //PLV-4632 - INICIO/FIM
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        //PLV-4632 - INICIO/FIM

        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assertEquals(Integer.valueOf(body.ano), response.ano);
        System.assertEquals(Integer.valueOf(body.ramo), response.ramo);
        System.assertEquals(Decimal.valueOf(body.numero), response.numero);
        System.assertEquals('',msg); // LECVPV-201 INICIO/FIM
        System.assertEquals(0, response.resultado);//0 significa sucesso
    }

    @isTest
    static void jogarFechadoTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.valor = 0;
        body.movimento = 24;
        body.matricula = 'ABCXPTO';
        body.cobertura = COBERTURA1; 

        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
       Test.startTest();
        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assertEquals(Integer.valueOf(body.ano), response.ano);
        System.assertEquals(Integer.valueOf(body.ramo), response.ramo);
        System.assertEquals(Decimal.valueOf(body.numero), response.numero);
        System.assertEquals(0, response.resultado); 
        //PLV-4624 - FIM
    }

    @isTest
    public static void garantiaNaoEstaNoContratoTest() {
    	RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.valor = 100;
        body.movimento = 22;
        body.matricula = 'ABCXPTO';
        body.cobertura = 'TC';
        
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assert(response.mensagem != '');
        System.assertEquals(Integer.valueOf(body.ano), response.ano);
        System.assertEquals(Integer.valueOf(body.ramo), response.ramo);
        System.assertEquals(Decimal.valueOf(body.numero), response.numero);
        System.assertEquals(1, response.resultado);//0 significa que validou
    }

    @isTest
    public static void consultarSinistroErroAnoTest() {
    	RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.ano = '';
        
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assertEquals(1,response.resultado);//Esperando erro caso ano não tenha sido preenchido significa que todas as validações estão ativas
    }

    //PLV-4624 INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    @isTest
    public static void avaliarvalor() {
    	RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.valor = 1000;
        body.movimento = 22;
        body.matricula = 'ABCXPTO';
        body.cobertura = COBERTURA1; 
        
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assertEquals(1,[SELECT Id FROM PagamentoGarantia__c].size());
        System.assertEquals(Integer.valueOf(body.ano), response.ano);
        System.assertEquals(Integer.valueOf(body.ramo), response.ramo);
        System.assertEquals(Decimal.valueOf(body.numero), response.numero);
    }


    @IsTest
    public static void reabrirSinistro25Test(){
    	RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.valor = 150;
        body.movimento = 22;
        body.matricula = 'ABCXPTO';
		
        Test.startTest();
        Case caso = [SELECT Id FROM Case WHERE RecordType.DeveloperName='Sinistro' LIMIT 1];
        
        //PLV-4198 - Inicio
        List<PagamentoGarantia__c> lstPagamentoGarantia = [
            SELECT Id, Fase__c, Status_do_pagamento__c FROM PagamentoGarantia__c WHERE Caso__c=: caso.Id
        ];
        for( PagamentoGarantia__c pagamentoGarantia : lstPagamentoGarantia ) {
            pagamentoGarantia.Fase__c = 'Em análise';
            pagamentoGarantia.Status_do_pagamento__c='Cancelado';
        }
        update lstPagamentoGarantia;
        //PLV-4198 - Fim
        
        caso.Status = 'Fechado';
        caso.Status_Dependente__c = 'Cancelado';
        caso.Motivos_de_recusa__c ='4';
		update caso;

        //PLV-4632 - INICIO/FIM
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        //PLV-4632 - INICIO/FIM
        
        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assertEquals(Integer.valueOf(body.ano), response.ano);
        System.assertEquals(Integer.valueOf(body.ramo), response.ramo);
        System.assertEquals(Decimal.valueOf(body.numero), response.numero);
        System.assertEquals(0, response.resultado);//0 significa sucesso
    }
    //PLV-4624 FIM - PEDRO AUGUSTO BRAZ - SYS4B

    //LECVP-216 - INICIO
    @IsTest
    public static void reabrirSinistro22Test(){
    	RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.valor = 150;
        body.movimento = 22;
        body.matricula = 'ABCXPTO';
		
        Test.startTest();
        Case caso = [SELECT Id FROM Case WHERE RecordType.DeveloperName='Sinistro' LIMIT 1];
        
        //PLV-4198 - Inicio
        List<PagamentoGarantia__c> lstPagamentoGarantia = [
            SELECT Id, Name, Fase__c, Status_do_pagamento__c FROM PagamentoGarantia__c WHERE Caso__c=: caso.Id
        ];
        for( PagamentoGarantia__c pagamentoGarantia : lstPagamentoGarantia ) {
            pagamentoGarantia.Fase__c = 'Fechado';
            pagamentoGarantia.Status_do_pagamento__c='Cancelado';
            pagamentoGarantia.Name = 'TestGarantia';
        }
        update lstPagamentoGarantia;
        //PLV-4198 - Fim
        
        caso.Status = 'Fechado';
        caso.Status_Dependente__c = 'Cancelado';
        caso.Motivos_de_recusa__c ='4';
		update caso;

        //PLV-4632 - INICIO/FIM
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        //PLV-4632 - INICIO/FIM
        
        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assertEquals(Integer.valueOf(body.ano), response.ano);
        System.assertEquals(Integer.valueOf(body.ramo), response.ramo);
        System.assertEquals(Decimal.valueOf(body.numero), response.numero);
        System.assertEquals(0, response.resultado);//0 significa sucesso
    }
    //LECVP-216 - FIM
    
    @isTest
    public static void mensagensDeErro() {
    	RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/atualizarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AtualizarSinistroJuridicoRest.processarPost();
        Test.stopTest();
        SinistroJuridicoBO.ResponseAtualizar response = (SinistroJuridicoBO.ResponseAtualizar) JSON.deserialize(
            res.responseBody.toString(), SinistroJuridicoBO.ResponseAtualizar.class
        );
        System.assertEquals(1,response.resultado);//Esperando erro caso ano não tenha sido preenchido significa que todas as validações estão ativas
    }

    @isTest
    static void reabrirCasoTest()
    {
        SinistroJuridicoBO.Request sinistro = new SinistroJuridicoBO.Request();
        Case registro = AtualizarSinistroJuridicoRest.reabrirCaso(new Case(), sinistro);
		System.assertEquals('Em Regulação', registro.Status, 'reabrirCasoTest(0): Valor diferente do esperado.');
		System.assertEquals('Avisado', registro.Status_Dependente__c, 'reabrirCasoTest(1): Valor diferente do esperado.');
		System.assertNotEquals(null, registro.DataReabertura__c, 'reabrirCasoTest(2): Valor diferente do esperado.');
		System.assertEquals(
            'Sinistros reabertos judicialmente', registro.MotivosReabertura__c, 'reabrirCasoTest(3): Valor diferente do esperado.'
        );
		System.assertEquals(
            'API - Reabertura Jurídico - Matricula: ' + sinistro.matricula, registro.ConsideracoesReabertura__c,
            'reabrirCasoTest(4): Valor diferente do esperado.'
        );
		System.assertEquals('49', registro.Motivos_de_recusa__c, 'reabrirCasoTest(5): Valor diferente do esperado.');
    }

    @isTest
    static void fecharCasoTest()
    {
        Case registro = AtualizarSinistroJuridicoRest.fecharCaso(new Case());
		System.assertEquals('Fechado', registro.Status, 'fecharCasoTest(0): Valor diferente do esperado.');
		System.assertEquals('Cancelado', registro.Status_Dependente__c, 'fecharCasoTest(1): Valor diferente do esperado.');
		System.assertEquals('49', registro.Motivos_de_recusa__c, 'fecharCasoTest(5): Valor diferente do esperado.');
    }
}
// POR062-1 - FIM