/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-13
 * @description Classe de Teste para a classe CasoWizardController
 */
@isTest
public class CasoWizardControllerTest {

	@isTest
	static void validarCasoWizardController(){
		Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();

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

        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();

		Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();
        contrato.Endosso__c = '0';
        contrato.NumeroApolice__c = '1234';
        update contrato;

        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
		SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo).createRecord();
		GarantiaSeguradoContrato__c garanSegCont = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();

		RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

		//PLV-3777 - INICIO
		garanSegCont.GarantiaProduto__c = garanProdCom.Id;
		update garanSegCont;
		//PLV-3777 - FIM
		//PLV-3904 - INICIO - PEDRO AUGUSTO - SYS4B
		garanProdCom.VigenciaGarantia__c = 'Contratação até fim da apólice';
		update garanProdCom;
		//PLV-3904 - FIM - PEDRO AUGUSTO - SYS4B

		Case caso = (Case) new CasoFactory.AtendimentoSinistro(conta).createRecord();

		Case caso2 = (Case) new CasoFactory.AtendimentoBeneficio(conta).createRecord();

		Test.startTest();
			List<String> retornos1 = CasoWizardController.validarpreenchimento('123');

			caso.Dataocorrencia__c = null;
			update caso;
			List<String> retornos2 = CasoWizardController.validarpreenchimento(caso.id);

			caso.Dataocorrencia__c = System.today();
			caso.Type = '';
			update caso;
			List<String> retornos3 = CasoWizardController.validarpreenchimento(caso.id);

			//PLV-3777 - INICIO
			caso.Type = 'Benefício';
			caso.Vitima__c = '';
			update caso;
			List<String> retornos4 = CasoWizardController.validarpreenchimento(caso.id);

			caso.Type = 'Sinistro';
			update caso;
			List<String> retornos5 = CasoWizardController.validarpreenchimento(caso.id);
			
			//Codigo removido por conta de Fix da historia PLV-3777

			String retornoAgg = CasoWizardController.pesquisacontratos(caso.Id, 'Acidente');

			list<Case> listaCasosRetorno = CasoWizardController.validarSinistroDuplicado(caso.Id, 'Acidente'); //PLV-3914 - INICIO/FIM

        CasoWizardController.criaCasoSinistro(caso.Id, new List<String>{garantia.Sigla__c + '--' + garantia.Name},'Acidente','[{"valor":"CV","price":"100"}]','');//PLV-4174 Adicionado novo parametro - INICIO/FIM//PLV-4938 - INICIO/FIM
			//PLV-3777 - FIM:
		Test.stopTest();

	}

}