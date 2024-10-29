//ZSVEP-76-INICIO
@IsTest
public class CancelamentoManualBatchTest {
    
    @testSetup
    public static void setupUnit(){
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
	    Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();
        
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);
        
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        contratante.Numero__c = 123;
        contratante.IOF__c = 10;
        contratante.Contrato__c = contrato.Id;
        update contratante;
        
	    GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        grupo.Numero__c = 123;
        update grupo;
        
	    SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo).createRecord();
        segurado.Numero__c = 123;
        update segurado;
        
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();    
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
     	
       	contrato.Empresa__c = '1';
        contrato.Sucursal__c = '1';
        contrato.NumeroApolice__c = '12345';
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c = contrato.StartDate.addMonths(3);  
        contrato.MeioComercializacao__c = 'ARQ';
        contrato.Proposta__c = proposta.Id;
        contrato.RamoSeguro__c = ramoSeguro.Id;
        contrato.Status = 'Emitido';
        update contrato;
    }

    @IsTest
    public static void testBatchCancelamento(){
        List<String> lstTest = new List<String>();
        lstTest.add('1234');
        ServiceTO.ParamOrcamentoCalculoTO param = new ServiceTO.ParamOrcamentoCalculoTO();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(param), 200, 'OK'));
        Test.startTest();
    	CancelamentoManualBatch btc = new CancelamentoManualBatch(lstTest);
        database.executeBatch(btc);
        Test.stopTest();
    }
}
//ZSVEP-76-FIM