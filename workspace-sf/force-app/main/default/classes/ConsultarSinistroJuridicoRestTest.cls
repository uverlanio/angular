/*******************************************************************************************************************************
* 
* @author Pedro Augusto - SYS4B
* @date 13/07/2020
* @modifiedAt 
* Classe criada por conta da história PLV-4046
* Teste Serviço para consultar sinistros Jurídicos
******************************************************************************************************************************/
@IsTest
public class ConsultarSinistroJuridicoRestTest {

    @TestSetup
    static void setup(){
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();

        //PLV-3904 - INICIO
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        garantia.Sigla__c = 'DBAG';
        update garantia;

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
        
        GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(seguradoContrato,garantia).createRecord();
        //PLV-3904 - INICIO
        garantiaSeguradoContrato.GarantiaProduto__c = garanProdCom.id;
        update garantiaSeguradoContrato;
        //PLV-3904 - FIM
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
        //1.1369.2020.500092
        consulta.ano ='2020';
        consulta.numero = '500092';
        consulta.ramo = '1369';

        return consulta;
    }

    @isTest
    static void consultarSinistrosTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        SinistroJuridicoBO.Request body = retornarBody();

        req.requestURI = '/services/apexrest/sinistro/consultarjuridico';
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        //Request
        ConsultarSinistroJuridicoRest.processarPost();

        //Response
        ConsultarSinistroJuridicoRest.Response response = (ConsultarSinistroJuridicoRest.Response) JSON.deserialize(
            res.responseBody.toString(), ConsultarSinistroJuridicoRest.Response.class
        );
        //Assertions
        // PLV-4624 - INICIO - PEDRO AUGUSTO BRAZ
        // COLEGA, SE VOCÊ MEXEU EM ALGO DO SINISTRO E ESSES ASSERTIONS PARARAM DE FUNCIONAR,
        // POR FAVOR, REVISE SUA MODIFICAÇÃO, OU ATUALIZE ESSE SERVIÇO/CLASSES DE TESTE, POIS OS ASSERTS VALIDAM SE O SERVIÇO ESTA FUNCIONANDO
        // O PRÓXIMO QUE COMENTAR OS ASSERTS E O SERVIÇO PARAR DE FUNCIONAR EM PRODUÇÃO QUE SE RESPONSABILIZE!
        System.assertEquals('',response.mensagem);
        // LECVPV-201 INICIO
        System.assert(response.sinistros!=null); 
        System.assertEquals(Integer.valueOf(body.ano), response.sinistros[0].ano);
        System.assertEquals(Integer.valueOf(body.ramo), response.sinistros[0].ramo);
        System.assertEquals(Decimal.valueOf(body.numero), response.sinistros[0].numero);
        // LECVPV-201 FIM
        // PLV-4624 - FIM - PEDRO AUGUSTO BRAZ
        Test.stopTest();
    }

    @IsTest
    public static void consultarSinistroErroAnoTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/sinistro/consultarjuridico';

        SinistroJuridicoBO.Request body = retornarBody();
        body.ano = '';

        req.requestBody = Blob.valueOf(JSON.serialize(body));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        //Request
        ConsultarSinistroJuridicoRest.processarPost();

        //Response
        ConsultarSinistroJuridicoRest.Response response = (ConsultarSinistroJuridicoRest.Response) JSON.deserialize(
            res.responseBody.toString(), ConsultarSinistroJuridicoRest.Response.class
        );

        //Assertions
        // PLV-4624 - INICIO - PEDRO AUGUSTO BRAZ
        // COLEGA, SE VOCÊ MEXEU EM ALGO DO SINISTRO E ESSES ASSERTIONS PARARAM DE FUNCIONAR,
        // POR FAVOR, REVISE SUA MODIFICAÇÃO, OU ATUALIZE ESSE SERVIÇO/CLASSES DE TESTE, POIS OS ASSERTS VALIDAM SE O SERVIÇO ESTA FUNCIONANDO
        // O PRÓXIMO QUE COMENTAR OS ASSERTS E O SERVIÇO PARAR DE FUNCIONAR EM PRODUÇÃO QUE SE RESPONSABILIZE!
        System.assertEquals(1,response.resultado);
        // PLV-4624 - FIM - PEDRO AUGUSTO BRAZ
        Test.stopTest();
    }
}