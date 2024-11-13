@IsTest
public class ConsultaAcumuloCapitalBusinessTest { 
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
    static void getAcumuloCapitalCoberturasByCpfComLegadoTest() {
        ConsultaAcumuloCapitalRest.Request req = new ConsultaAcumuloCapitalRest.Request();
        req.cpf = '43891231814';
        req.coberturasLegado = new List<ConsultaAcumuloCapitalRest.Cobertura>();
        req.coberturasPortal = new List<ConsultaAcumuloCapitalRest.Cobertura>();
        ConsultaAcumuloCapitalRest.Cobertura cobertura = new ConsultaAcumuloCapitalRest.Cobertura();
        cobertura.sigla = 'ABC';
        cobertura.valor = 10000;
        req.coberturasLegado.add(cobertura);
        req.coberturasPortal.add(cobertura);

        Test.startTest();
        ConsultaAcumuloCapitalRest.Response res = ConsultaAcumuloCapitalBusiness.getAcumuloCapitalCoberturasByCpf(req);
        
        System.assertEquals(1, res.coberturas.size());
        System.assertEquals(20000, res.coberturas[0].valor); //PLV-4923 INICIO / FIM

        Test.stopTest();
    }

    

    @IsTest
    static void getAcumuloCapitalCoberturasByCpfSemLegadoTest() {
        ConsultaAcumuloCapitalRest.Request req = new ConsultaAcumuloCapitalRest.Request();
        req.cpf = '43891231814';

        Test.startTest();
        ConsultaAcumuloCapitalRest.Response res = ConsultaAcumuloCapitalBusiness.getAcumuloCapitalCoberturasByCpf(req);
        //PLV-4923 INICIO
        System.assertEquals(0, res.coberturas.size());
        //PLV-4923 FIM
        Test.stopTest();
    }
    //PLV-4503 FIM
    //ANNVI-151 - INICIO
    @IsTest
    static void garsCtrSemCancelTest(){

        Test.startTest();

        Account conta = [SELECT Id FROM Account LIMIT 1];

        Product2 produtoTecnico = TestDataFactory.gerarProdutoTecnico();
        produtoTecnico.Status__c = 'Ativo';
        produtoTecnico.Segmento__c ='Individual';
        update produtoTecnico;

        Product2 produtoComercial = TestDataFactory.gerarProdutoComericial(produtoTecnico);
        produtoComercial.Status__c ='Ativo';
        produtoComercial.Segmento__c ='Individual';        
        update produtoComercial;

        RamoSeguro__c ramoSeguro = [SELECT Id FROM RamoSeguro__c LIMIT 1];
        DadosCorretor__c dadosCorretor = [SELECT Id FROM DadosCorretor__c LIMIT 1];
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoComercial, ramoSeguro, conta, dadosCorretor, proposta);
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        garantia.Sigla__c = 'ABC';
        update garantia;

        GarantiaProduto__c garantiaProdutTecnico = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTecnico, garantia, ramoSeguro);
        GarantiaProduto__c garantiaProdutoComercial = TestDataFactory.gerarGarantiaProdutoComercial(produtoComercial, garantia, garantiaProdutTecnico, ramoSeguro);
        GarantiaContrato__c garantiaContrato = TestDataFactory.gerarGarantiaContrato(contrato, garantiaProdutoComercial);
        garantiaContrato.Capital__c = 10000;
        update garantiaContrato;

        contrato.Tipo__c = 'Novo';
        contrato.Status = 'Emitido';
        contrato.StartDate = System.today();
        contrato.VigenciaFinal__c = System.today();

        garantiaContrato.Contrato__r = contrato;
        garantiaContrato.Garantia__r = garantia;
        update garantiaContrato.Contrato__r;
        System.debug('garantiaContrato: ' + JSON.serializePretty(garantiaContrato));

        ConsultaAcumuloCapitalRest.Request req = new ConsultaAcumuloCapitalRest.Request();
        req.cpf = '43891231814';

        req.coberturasPortal = new List<ConsultaAcumuloCapitalRest.Cobertura>();
        ConsultaAcumuloCapitalRest.Cobertura cobertura = new ConsultaAcumuloCapitalRest.Cobertura();
        cobertura.sigla = 'ABC';
        cobertura.valor = 10000;
        req.coberturasPortal.add(cobertura);

        ConsultaAcumuloCapitalRest.Response res = ConsultaAcumuloCapitalBusiness.getAcumuloCapitalCoberturasByCpf(req);
        System.debug('res: ' + JSON.serialize(res));

        System.assertEquals('ABC', res.coberturas[0].sigla);
        System.assertEquals(20000, res.coberturas[0].valor);

        contrato.Tipo__c = 'Cancelamento';
        contrato.Endosso__c = '1';
        contrato.Name = contrato.Name.substring(0, contrato.Name.length() - 1) + contrato.Endosso__c;
        update garantiaContrato.Contrato__r;

        res = ConsultaAcumuloCapitalBusiness.getAcumuloCapitalCoberturasByCpf(req);
            
        System.assertEquals('ABC', res.coberturas[0].sigla);
        System.assertEquals(10000, res.coberturas[0].valor);

        Test.stopTest();        
    }
    //ANNVI-151 - FIM
}