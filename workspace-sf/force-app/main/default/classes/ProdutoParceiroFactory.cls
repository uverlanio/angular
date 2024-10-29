/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-08
 * @description ProdutoParceiro__c Factory Class
 */
@isTest
public class ProdutoParceiroFactory extends SObjectFactory{
	private static ProdutoParceiro__c staticRecord;

	private static ProdutoParceiro__c getRecordStatic(Parceiro__c parceiro, Product2 produto){

		if(staticRecord == null){
			staticRecord = new ProdutoParceiro__c(
			Parceiro__c = parceiro.Id,
        	Produto__c = produto.Id);
		}
		return staticRecord;
	}

	public ProdutoParceiroFactory(){

		this(
			(Parceiro__c) new ParceiroFactory().createRecord(),
			(Product2) new ProdutoFactory.ProdutoComercial().createRecord()
		);
	}

	public ProdutoParceiroFactory(Parceiro__c parceiro, Product2 produto) {

		super(getRecordStatic(parceiro, produto));
	}
}