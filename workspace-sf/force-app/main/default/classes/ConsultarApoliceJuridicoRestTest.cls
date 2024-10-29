@IsTest
public class ConsultarApoliceJuridicoRestTest {
    @TestSetup
    static void setup(){
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();

        //PLV-3904 - INICIO
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        garantia.Sigla__c = 'DBAG';
        update garantia;

        Garantia__c garantia2 = new Garantia__c(
				Name = 'DMHO',
				Status__c = 'Ativo',
				Sigla__c = 'DMHO',
				Tipo__c = 'Cobertura',
				VigenciaInicial__c = System.today(),
				TipoEvento__c = 'Morte');
        insert garantia2;

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        RamoGarantia__c ramoGarantia2 = new RamoGarantia__c(
            Garantia__c = garantia2.Id,
            RamoSeguro__c = ramoSeguro.Id
        );
        insert ramoGarantia2;

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


        System.debug('DIEGO: '+garantia.id+' - '+produtoTecnico.Id+' - '+ramoSeguro.Id);
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

        garanProdCom.VigenciaGarantia__c = 'Contratação até fim da apólice';
        update garanProdCom;

        System.debug('DIEGO 2: '+garantia2.id+' - '+produtoTecnico.Id+' - '+ramoSeguro.Id);
        Recordtype rcT = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico');

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
        System.debug('DIEGO: '+gproduto);

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
        // Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();
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
        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(Contrato__c = contrato.Id, Conta__c = conta.Id, Tipo__c = 'Principal');
        insert contratanteContrato;

        GrupoContrato__c grupoContrato = (GrupoContrato__c) new GrupoFactory(contratanteContrato).createRecord();
        SeguradoContrato__c seguradoContrato = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupoContrato).createRecord();
        //PLV-3904 - INICIO
        seguradoContrato.VigenciaInicial__c = system.today();
        seguradoContrato.VigenciaFinal__c = system.today().addMonths(1);
        update seguradoContrato;
        //PLV-3904 - FIM

        insert new GarantiaContrato__c(Contrato__c = contrato.Id, Garantia__c = garantia.Id, Capital__c = 10000.00, TipoCapital__c = 'Capital uniforme');
        insert new GarantiaContrato__c(Contrato__c = contrato.Id, Garantia__c = garantia2.Id, Capital__c = 20000.00, TipoCapital__c = 'Capital uniforme');
        System.debug('DIEGO: +'+[SELECT Id FROM GarantiaContrato__c]);
        GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(seguradoContrato,garantia).createRecord();
        garantiaSeguradoContrato.GarantiaProduto__c = garanProdCom.id;
        update garantiaSeguradoContrato;

        GarantiaSeguradoContrato__c garantiaSeguradoContrato2 = new GarantiaSeguradoContrato__c(
            SeguradoContrato__c = seguradoContrato.Id,
            Garantia__c = garantia2.Id,
            GarantiaProduto__c = garanProdCom2.id
        );
        insert garantiaSeguradoContrato2;

        System.debug('DIEGO: +1'+JSON.serialize(
            [
                SELECT Id
                    ,Garantia__r.Name
                    ,Garantia__r.Sigla__c
                    ,Garantia__r.Descricao__c
                    ,SeguradoContrato__R.GrupoContrato__r.ContratanteContrato__r.Contrato__c
                FROM GarantiaSeguradoContrato__c
            ]
        ));



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

        contrato.NumeroApolice__c = '2353575';
        contrato.Sucursal__c = '123456';
        contrato.CodigoRamo__c = '123456';
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
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, conta).createRecord();
        Contact contato = (Contact) new ContactFactory().createRecord();

        //Atualizando o status do caso para 'Avisado'
        casoSinistro.ContactId = contato.id;
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSeguradoContrato.id;
        casoSinistro.NumeroSinistro__c = '1.1369.2020.500092';
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Com Pendências';
        casoSinistro.Segurado_do_Contrato__c = seguradoContrato.id;
        casoSinistro.ProcessaNumeroSinistro__c = true;
        casoSinistro.RamoSplit__c = 1369;
        //casoSinistro.NumeroSinistroSplit__c = 500092; //PLV-4485
        //casoSinistro.AnoSinistroSplit__c = 2020; //PLV-4485
        update casoSinistro;

        PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro,garantiaSeguradoContrato).createRecord();
    }

    public static SinistroJuridicoBO.Request retornarBody(){

        SinistroJuridicoBO.Request consulta = new SinistroJuridicoBO.Request();

        consulta.ramo = '123456';
        consulta.apolice = 2353575;
        consulta.sucursal = 123456;

        return consulta;
    }

    @isTest
    static void consultarApoliceTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        SinistroJuridicoBO.Request body = retornarBody();

        req.requestURI = '/services/apexrest/sinistro/consultarapolice';
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        //Request
        ConsultarApoliceJuridicoRest.processarPost();

        //Response
        ConsultarApoliceJuridicoRest.Response response = (ConsultarApoliceJuridicoRest.Response) JSON.deserialize(
            res.responseBody.toString(), ConsultarApoliceJuridicoRest.Response.class
        );

        //Assertions
        // PLV-4624 - INICIO - PEDRO AUGUSTO BRAZ
        // COLEGA, SE VOCÊ MEXEU EM ALGO DO SINISTRO E ESSES ASSERTIONS PARARAM DE FUNCIONAR,
        // POR FAVOR, REVISE SUA MODIFICAÇÃO, OU ATUALIZE ESSE SERVIÇO/CLASSES DE TESTE, POIS OS ASSERTS VALIDAM SE O SERVIÇO ESTA FUNCIONANDO
        // O PRÓXIMO QUE COMENTAR OS ASSERTS E O SERVIÇO PARAR DE FUNCIONAR EM PRODUÇÃO QUE SE RESPONSABILIZE!
        System.assertEquals('',response.mensagem); //PLV-4485
        System.assertEquals(0, response.resultado); //PLV-4485
        // PLV-4624 - FIM - PEDRO AUGUSTO BRAZ

        Test.stopTest();
    }

    @isTest
    static void consultarApoliceSemContratoTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        SinistroJuridicoBO.Request body = retornarBody();
        body.ramo = '1';
        body.apolice = 1;
        body.sucursal = 1;

        req.requestURI = '/services/apexrest/sinistro/consultarapolice';
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        //Request
        ConsultarApoliceJuridicoRest.processarPost();

        //Response
        ConsultarApoliceJuridicoRest.Response response = (ConsultarApoliceJuridicoRest.Response) JSON.deserialize(
            res.responseBody.toString(), ConsultarApoliceJuridicoRest.Response.class
        );

        //Assertions
        //Assertions
        // PLV-4624 - INICIO - PEDRO AUGUSTO BRAZ
        // COLEGA, SE VOCÊ MEXEU EM ALGO DO SINISTRO E ESSES ASSERTIONS PARARAM DE FUNCIONAR,
        // POR FAVOR, REVISE SUA MODIFICAÇÃO, OU ATUALIZE ESSE SERVIÇO/CLASSES DE TESTE, POIS OS ASSERTS VALIDAM SE O SERVIÇO ESTA FUNCIONANDO
        // O PRÓXIMO QUE COMENTAR OS ASSERTS E O SERVIÇO PARAR DE FUNCIONAR EM PRODUÇÃO QUE SE RESPONSABILIZE!
        System.assertEquals(1, response.resultado);
        System.assertEquals('Apólice não localizada', response.mensagem);
        // PLV-4624 - FIM - PEDRO AUGUSTO BRAZ

        Test.stopTest();
    }
}