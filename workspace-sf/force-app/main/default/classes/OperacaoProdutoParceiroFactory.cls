/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-08
 * @description OperacaoProdutoParceiro__c Factory Class
 */
@isTest
public class OperacaoProdutoParceiroFactory extends SObjectFactory{
	private static OperacaoProdutoParceiro__c staticRecord;

	private static OperacaoProdutoParceiro__c getRecordStatic(ProdutoParceiro__c prodParc){

		if(staticRecord == null){
			staticRecord = new OperacaoProdutoParceiro__c(
				ProdutoParceiro__c = prodParc.Id,
        		Tipo__c = 'Sinistro',
        		Sigla__c = 'ETQ',
        		Direcao__c = 'Entrada',
        		OperacaoParceiro__c = 'EST',
        		PastaArquivamento__c = '/testeAVX');
		}
		return staticRecord;
	}

	public OperacaoProdutoParceiroFactory(){

		this(
			(ProdutoParceiro__c) new ProdutoParceiroFactory().createRecord()
		);
	}

	public OperacaoProdutoParceiroFactory(ProdutoParceiro__c prodParc) {

		super(getRecordStatic(prodParc));
	}
}