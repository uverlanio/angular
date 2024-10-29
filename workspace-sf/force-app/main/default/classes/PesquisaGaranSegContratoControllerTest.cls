/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-25
 * @description Componente PesquisaGarantia Classe de Teste
 */
@isTest
public class PesquisaGaranSegContratoControllerTest {

	@isTest
	static void validarPesquisaGarantia(){
		Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
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
	    Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
	    Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
	    ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
	    GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
	    SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
	    GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
	    garantiaSegurado.Capital__c = 10000;
	    update garantiaSegurado;

	    Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro(contaPessoal).createRecord();
	    Case caso = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
	    caso.Segurado_do_contrato__c = segurado.id;
	    update caso;

	    PagamentoGarantia__c pagGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(caso, garantiaSegurado).createRecord();

	    String json = (String) JSON.serialize(garantiaSegurado);

	    Test.startTest();
	    	PesquisaGarantiaSegContratoController.pesquisaGarantiaSegContrato(pagGarantia.id, '');
	    	PesquisaGarantiaSegContratoController.pesquisaGarantiaSegContrato(pagGarantia.id, garantia.Name);
	    	PesquisaGarantiaSegContratoController.updatePagamentoGarantia(pagGarantia.id, json);
	    	PesquisaGarantiaSegContratoController.buscaNomePagamentoGarantia(pagGarantia.id);
	    Test.stopTest();
	}
}