// POR062-1 - INICIO
@isTest
class PagamentoGarantiaDAOTest {
    private static final String SIGLA = 'DBAG';

    @TestSetup
    static void setup() {
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;

        RamoAtividade__c ramoAtividade = (RamoAtividade__c) new RamoAtividadeFactory().createRecord();
        Account contaParceiro = (Account) new AccountFactory.PessoaJuridica(ramoAtividade).createRecord();
        contaParceiro.Name = 'ASSISTCARD';
        update contaParceiro;

        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();

        Parceiro__c parceiroPrestadora = (Parceiro__c) new ParceiroFactory(contaParceiro, formaPagamento).createRecord();
        parceiroPrestadora.status__c = 'Ativo';
        parceiroPrestadora.Sucursal__c = '1';
        parceiroPrestadora.ramo__c = '1396';
        parceiroPrestadora.empresa__c = '1';
        update parceiroPrestadora;

        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        garantia.Sigla__c = PagamentoGarantiaDAOTest.SIGLA;
        update garantia;
        Garantia__c garantia2 = new Garantia__c(
				Name = 'DMHO',
				Status__c = 'Ativo',
				Sigla__c = 'DMHO',
				Tipo__c = 'Cobertura',
				VigenciaInicial__c = System.today(),
				TipoEvento__c = 'Morte');
        insert garantia2;

        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        RamoGarantia__c ramoGarantia2 = new RamoGarantia__c(
            Garantia__c = garantia2.Id,
            RamoSeguro__c = ramoSeguro.Id
        );
        insert ramoGarantia2;

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiroPrestadora).createRecord();
        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(Contrato__c = contrato.Id, Conta__c = conta.Id, Tipo__c = 'Principal'); 
        insert contratanteContrato;
        GrupoContrato__c grupoContrato = (GrupoContrato__c) new GrupoFactory(contratanteContrato).createRecord();
        SeguradoContrato__c seguradoContrato = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupoContrato).createRecord(); 
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, conta).createRecord();

        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
        garanProdCom.VigenciaGarantia__c = 'Contratação até fim da apólice';
        update garanProdCom;

        GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(seguradoContrato, garantia).createRecord();
        garantiaSeguradoContrato.GarantiaProduto__c = garanProdCom.id;
        garantiaSeguradoContrato.Tipo_de_limite_de_utilizacao__c = 'Dia(s)';
        garantiaSeguradoContrato.Limite_de_Uso__c = 900;
        update garantiaSeguradoContrato;

        PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSeguradoContrato).createRecord();
    }

    @isTest
    static void buscarPorIdDeCasoECoberturaTest() {
        List<PagamentoGarantia__c> pagamentosGarantia = [SELECT Caso__c FROM PagamentoGarantia__c];
        Set<Id> idsPagamentoGarantia = Util.recuperarIdsPorCampoDeSObject(pagamentosGarantia, Schema.PagamentoGarantia__c.Caso__c);
        Test.startTest();
        List<PagamentoGarantia__c> pagamentosRecuperados = PagamentoGarantiaDAO.getInstance().buscarPorIdDeCasoECobertura(
            idsPagamentoGarantia, new Set<String> { PagamentoGarantiaDAOTest.SIGLA }
        );
        Test.stopTest();
        System.assert(pagamentosRecuperados.size() > 0);
    }

    @isTest
    static void buscarPorIdDeCaso() {

        Map<Id, Case> idsCaso = new Map<Id, Case>([SELECT Id FROM Case]);

        Test.startTest();
        List<PagamentoGarantia__c> pagamentosRecuperados = PagamentoGarantiaDAO.getInstance().buscarPorCaso(idsCaso.keySet());
        Test.stopTest();

        System.assert(pagamentosRecuperados.size() > 0);
    }

    //II-Kevin
    @isTest
    static void buscarCasoParaAtualizarFaseStatusTest() {

        Case caso = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        List<PagamentoGarantia__c> pagamentosRecuperados = PagamentoGarantiaDAO.getInstance().buscarCasoParaAtualizarFaseStatus(caso.id);
        Test.stopTest();
    }

    @isTest
    static void buscarCasosBySetIdTest() {

        Case caso = [SELECT Id FROM Case LIMIT 1];

        Map<Id, Case> idsCaso = new Map<Id, Case>([SELECT Id FROM Case]);

        Test.startTest();
        List<PagamentoGarantia__c> pagamentosRecuperados = PagamentoGarantiaDAO.getInstance().buscarCasosBySetId(idsCaso.keySet());
        Test.stopTest();
    }

    @isTest
    static void buscarTipoMovEGarantiasTest() {

        Set<Id> garantiasId = new Set<Id>(); 
        Set<String> tipoMovimento = new Set<String>(); 
        
        Test.startTest();
        List<MovimentoSinistro__c> result = PagamentoGarantiaDAO.getInstance().buscarTipoMovEGarantias(garantiasId, tipoMovimento);
        Test.stopTest();
    }

    //II-Kevin
}
// POR062-1 - FIM