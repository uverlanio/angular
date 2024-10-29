/**
 * @author AVX - Leonardo Camacho
 * @date 2019-10-30
 * @description: RemuneracaoProduto__c Factory Class
 */
    
 @isTest
 public class RemuneracaoProdutoFactory extends SObjectFactory {

    private static RemuneracaoProduto__c staticRecord;

	private static RemuneracaoProduto__c getRecordStatic(TipoRemuneracao__c tipoRemuneracao, Product2 ProdutoComercial){

		if(staticRecord == null){
			staticRecord = new RemuneracaoProduto__c(
				Produto__c = ProdutoComercial.Id,
            	TipoRemuneracao__c = tipoRemuneracao.Id,
                LimiteMinimo__c = 1,
                LimiteMaximo__c = 45,
                TipoEvento__c = 'Endosso',
                Obrigatoria__c = true
                );
		}
		return staticRecord;
	}

	public RemuneracaoProdutoFactory(){

		this(
			(TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord(),
            (Product2) new ProdutoFactory.ProdutoComercial().createRecord()
		);
	}

	public RemuneracaoProdutoFactory(TipoRemuneracao__c tipoRemuneracao, Product2 ProdutoComercial) {

		super(getRecordStatic(tipoRemuneracao, ProdutoComercial));
	}
}