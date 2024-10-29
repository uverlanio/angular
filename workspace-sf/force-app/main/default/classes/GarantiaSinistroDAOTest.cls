//PLV - 5316 INÍCIO
@isTest
public class GarantiaSinistroDAOTest {
    
    @isTest
    public static void getGarantiaSinistroTest() {
        
        //Criando caso de Sinistro
        //Criando Conta
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        //Criando Caso de Atendimento
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro(contaPessoal).createRecord();
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        //PLV-4535 - FIX 6 INICIO
        casoSinistro.DataDocumentacaoCompleta__c = system.today();
        update casoSinistro;

		//Criando contato
		Contact contato = (Contact) new ContactFactory().createRecord();
		
		//Criando Contrato
		//Criando Produto Comercial
		//Criando ProdutoTecnico
		//Criando Contador Codigo
		ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
		ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
		Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
		
		//Ativar o Produto Tecnico
		produtoTecnico.Status__c = 'Em ativação';
		produtoTecnico.NumeroSusep__c = '123';
		produtoTecnico.VersaoRenovacao__c = 'Versão atual';
		update produtoTecnico;

		produtoTecnico.Status__c = 'Ativo';
		update produtoTecnico;

		Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
		//Criando Parceiro	
		//Criando Forma de Pagamento
		FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
		Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
		Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();		
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
		RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
		RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
		
		GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
		GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

		//Criando Garantia do Segurado do Contrato
		//Criando Garantia

		//Criando Contratante
		ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
		//Criando Grupo
		GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
		//Criando Segurado

        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        
        GarantiaSinistroDAO.GarantiaDAO gDAO = new GarantiaSinistroDAO.GarantiaDAO();
        gDAO.caseId = casoSinistro.Id;
        
        Test.startTest();
        	GarantiaSinistroDAO.getInstance().getGarantiaSinistro();
        Test.stopTest();
    }
}
//PLV - 5316 FIM