// POR062-1 - INICIO
@isTest
class BeneficiarioGarantiaDAOTest {
    @TestSetup
    static void setup(){
		Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaFisica).createRecord();
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
		ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
		FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaFisica, formaPagamento).createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaFisica, produtoComercial, parceiro).createRecord();
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaFisica, grupo).createRecord();
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(
            segurado, garantia
        ).createRecord();
		InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
		PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
		pag.Valor_indenizado__c = 50;
		update pag;
		BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(
            contaFisica, infoBan, pag
        ).createRecord();
    }

    @isTest
    static void buscarPorIdDePagamentosDeGarantiaTest() {
        Test.startTest(); //INICIO/FIM - LECVPV-218
        List<BeneficiarioGarantia__c> beneficiarios = [SELECT Pagamento_de_garantia__c FROM BeneficiarioGarantia__c];
        Set<Id> idsPagamentoGarantia = Util.recuperarIdsPorCampoDeSObject(
            beneficiarios, Schema.BeneficiarioGarantia__c.Pagamento_de_garantia__c
        );
        //Test.startTest(); //INICIO/FIM - LECVPV-218
        beneficiarios = BeneficiarioGarantiaDAO.getInstance().buscarPorIdDePagamentosDeGarantia(idsPagamentoGarantia);
        Test.stopTest();
        System.assertNotEquals(0, beneficiarios.size());
    }
}
// POR062-1 - FIM