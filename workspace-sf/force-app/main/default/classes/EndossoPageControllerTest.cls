@isTest
//plv - 4014 inicio
public class EndossoPageControllerTest {
    @TestSetup
    static void setup(){
        
        TestDataFactory.gerarDadosSetup();
        SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
        sCripto.Name = 'Senha';
        sCripto.Senha__c = 'TesteCrypto';
        insert sCripto;
        
        
    }
    @IsTest
    public static void dadosTest(){
        Account contaTeste = TestDataFactory.gerarConta();
        Endereco__c endereco = TestDataFactory.gerarEndereco(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        Garantia__c garantiaPVB = TestDataFactory.gerarGarantia();
        garantiaPVB.Name = 'Porto Viaje Bem';
        update garantiaPVB;
        Garantia__c garantiaCV = TestDataFactory.gerarGarantia();
        garantiaCV.Name = 'Cancelamento de Viagem';
        update garantiaCV;
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSegurado);
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        Map<String,List<SObject>> mapListSObject = TestDataFactory.gerarProdutoComercialAtivo(false);
        produtoCom.Status__c ='ativo';
        update produtoCom;
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoCom);
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__C parceiro = TestDataFactory.gerarParceiro(contaTeste, formaPagamento);
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoCom);
        Opportunity opp = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        InformacaoBancaria__c InformacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaTeste);
        RemuneracaoProdutoParceiro__c RemuneracaoProdutoParceiro = TestDataFactory.gerarRemuneracaoProdutoParceiro(tipoRemuneracao, produtoParceiro, 20);
        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(contaTeste, 20.00, 'Corretor', true, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);        
        system.debug('favorecidoRemuneracao: '+favorecidoRemuneracao.RemuneracaoProdutoParceiro__c); 
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, opp, modalidade);
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
        favorecidoRemuneracaoContrato.Conta__c = contaTeste.Id;
        favorecidoRemuneracaoContrato.CorretorLider__c = TRUE;
        favorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
        favorecidoRemuneracaoContrato.Susep__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepEmissao__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepOrcamento__c='p5005j';
        favorecidoRemuneracaoContrato.DadosCorretor__c = dadosCorretor.Id;
        favorecidoRemuneracaoContrato.Papel__c ='Corretor';
        favorecidoRemuneracaoContrato.Participacao__c =100;
        insert favorecidoRemuneracaoContrato;
        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaTeste, contaTeste);
        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c segurado = TestDataFactory.gerarSeguradoContrato(grupoContrato, contaTeste);
        
        ParcelamentoContratoTO parcelamentoContrato = new ParcelamentoContratoTO();
        
        ParcelamentoContratoTO.MetaTO meta = new ParcelamentoContratoTO.MetaTO();
        meta.dataExecucao = '';
        meta.servico = '';
        meta.statusHttp = 0;
        meta.mensagem = '';
        
        List<ParcelamentoContratoTO.DataTO> lstData = new List<ParcelamentoContratoTO.DataTO>();
        ParcelamentoContratoTO.DataTO data = new ParcelamentoContratoTO.DataTO();
        data.idfatura = 0;
        data.status = '';
        data.endosso = '';
        data.idexterno = '';
        data.valorparcela = '';
        data.seguradosalesforce = '';
        data.vidasalesforce = '';
        data.valoriof = '';
        data.id = 0;
        data.empresa = '';
        data.ramo = '';
        data.numeroparcela = 1;
        data.apolice = '';
        data.responsavelfinanceiro = '';
        data.titulo = '';
        data.origemproposta = 1;
        data.idparceiro = '';
        data.datavencimento = '';
        data.contrato = '';
        data.numeroproposta = '';
        data.valorliquido = '';
        data.sucursal = '';
        
        lstData.add(data);
        
        parcelamentoContrato.meta = meta;
        parcelamentoContrato.data = lstData;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(parcelamentoContrato), 200, 'OK'));
        
        PageReference pdf = Page.EndossoPage;
        Map<String,String> mPDFParam = pdf.getParameters();
        mPDFParam.put('contratoId', contrato.Id);
        CryptoToken c = new CryptoToken();      
        String cri = c.encrypt(contrato.Id+'|Endosso_1_1_1369_000002430_0_Test2');
        mPDFParam.put('token', cri);
        mPDFParam.put('renderAs', 'pdf');
        String parc = '{"meta":{"statusHttp":200,"servico":"Buscar parcelas do contrato por segurado ou vida","mensagem":"OK","dataExecucao":"2020-07-20T17:57:56.806Z"},"data":[{"vidasalesforce":null,"valorparcela":"-3.98","valorliquido":"-3.99","valoriof":"0.01","titulo":"","sucursal":"1","status":"A RESTITUIR","seguradosalesforce":"a0fL0000007WpVxIAK","responsavelfinanceiro":"001L000001TgdMuIAJ","ramo":"1369","origemproposta":18,"numeroproposta":null,"numeroparcela":1,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002Oo23IAC_a0fL0000007WpVxIAK","id":110297,"endosso":"1","empresa":"1","datavencimento":"2020-07-23T00:00:00.000Z","dataPagamentoParceiro":null,"contrato":null,"apolice":"000005928"}]}';
        mPDFParam.Put('retornoParcelas',parc);
        String parcO = '{"meta":{"statusHttp":200,"servico":"Buscar parcelas do contrato por segurado ou vida","mensagem":"OK","dataExecucao":"2020-07-20T17:57:56.806Z"},"data":[{"vidasalesforce":null,"valorparcela":"-3.98","valorliquido":"-3.99","valoriof":"0.01","titulo":"","sucursal":"1","status":"A RESTITUIR","seguradosalesforce":"a0fL0000007WpVxIAK","responsavelfinanceiro":"001L000001TgdMuIAJ","ramo":"1369","origemproposta":18,"numeroproposta":null,"numeroparcela":1,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002Oo23IAC_a0fL0000007WpVxIAK","id":110297,"endosso":"1","empresa":"1","datavencimento":"2020-07-23T00:00:00.000Z","dataPagamentoParceiro":null,"contrato":null,"apolice":"000005928"}]}';
        mPDFParam.Put('retornoParcelaOriginal',parcO);
        Test.setCurrentPage(pdf);
        ApexPages.StandardController sc = new ApexPages.standardController(contrato);
        EndossoPageController apc = new EndossoPageController();
        apc.doAction();       
    }
    @isTest
    public static void  others(){
        
        decimal a = 2000.6;
        String valor = a.format();
        
        EndossoPageController.trataValores(valor, 'BRL');
        EndossoPageController.trataValores(valor, 'USD');
        EndossoPageController.trataValores(valor, 'EUR');
        
        integer b = 2000;
        String valor2 = b.format();
        
        EndossoPageController.trataValores(valor2, 'BRL');
        EndossoPageController.trataValores(valor2, 'USD');
        EndossoPageController.trataValores(valor2, 'EUR');
        
        String valor3 = '200,00';
        EndossoPageController.trataValores(valor3, 'BRL');
        EndossoPageController.trataValores(valor3, 'USD');
        EndossoPageController.trataValores(valor3, 'EUR');
        
        EndossoPageController.Parcelas parc = new EndossoPageController.Parcelas();
        parc.Id = 1234;
        parc.dataVencimento = string.valueof(system.today());
        parc.dataPagamentoParceiro = string.valueof(system.today());
        parc.numeroParcela ='1';
        parc.titulo = 'a';
        parc.valorTotal = 'a';
        parc.valorIOF = 'a';
        parc.valorLiquido = 'a';
        parc.status = 'a';
        EndossoPageController c = new EndossoPageController();
        c.vigenciaApolice = '';
        c.vigenciaPremioPago = '';
        c.dataCancelamento = '';
        c.periodoRestituir = ''; 
        c.premioPago = '';
        c.premioRestituir = '';
        
    }
    
    
}
//plv - 4014 fim