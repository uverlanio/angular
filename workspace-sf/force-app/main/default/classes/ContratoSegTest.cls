//PLV-4603 - Inicio - Isabela Fin - Globant
//PLV-2780 - Inicio - Criar Parcelas do Contrato
@isTest
public class ContratoSegTest {
    @testSetup
    public static void setup(){
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();

        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        ParametroVigencia__c parametroCom = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaComercial(produtoComercial).createRecord(); //PLV-5768 INICIO/FIM

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();    
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, contaPessoal).createRecord();
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, contaPessoal, dadosCorretor, orcamento, modalidade).createRecord();

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).getRecord();
        contrato.Proposta__c = proposta.Id;
        contrato.VigenciaFinal__c = date.today(); //INICIO/FIM - PLV-4696 - Guilherme Brito
        contrato.Produto__c = produtoComercial.Id; //PLV-5768 INICIO/FIM
        insert contrato;

        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).getRecord();
        contratante.QuantidadeParcelas__c = 3;
        contratante.ResponsavelPagamento__c = contaPessoal.Id;
        contratante.VencimentoPrimeiraParcela__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
        contratante.VencimentoDemaisParcelas__c = '3';
        contratante.PremioComercial__c = 10000; //PLV-4794
        insert contratante;

        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
    }
    @isTest
    public static void contratoSeg() {
		List<Contract> lContratos = [SELECT Id FROM Contract LIMIT 1];
        lContratos = ContractDAO.getInstance().buscarContratos(new Set<Id>{lContratos[0].Id});

        ContractBO contratoBO = ContractBO.getInstance();
        //PLV-4438 - Inicio
        //PLV-4344-Fix - Inicio
        List<BusinessHours> lstTest = new List<BusinessHours>();
        Map<Id, Boolean> mapTest = new Map<Id, Boolean>();
        contratoBO.gerarParcelasContrato(lContratos, lstTest, mapTest);
        //PLV-4344-Fix - Fim
        //PLV-4438 - Fim
    }
}
//PLV-2780 - Fim - Criar Parcelas do Contrato
//PLV-4603 - Fim - Isabela Fin - Globant