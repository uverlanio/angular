/*********************************************************************************************************************************************************************
@description  Factory para teste de geração de dados iniciais no processo de contratação
@author Isabela Fin - Avanxo
@date 13/01/2020
@Classe criada por conta da história PLV-2146      
**********************************************************************************************************************************************************************/
public class CondicaoCobrancaFactory {
    private static Map<String,CondicaoCobranca__c> mStaticRecord = new Map<String,CondicaoCobranca__c>();    
    private static CondicaoCobranca__c getRecordCondicaoCobranca(Product2 produto, FormaPagamento__c formaPagamento){
        if(!mStaticRecord.containsKey('CondicaoCobranca')){
            mStaticRecord.put('CondicaoCobranca', new CondicaoCobranca__c(
                TipoPagamento__c = 'ADC',
            	QuantidadeParcelas__c = '1',
            	PercentualDescontoAgravo__c = 5,
            	Produto__c = produto.Id,
            	FormaPagamento__c = formaPagamento.Id));
        }
        return mStaticRecord.get('CondicaoCobranca');
    }
    
    public class CondicaoCobranca extends SObjectFactory {
        public CondicaoCobranca() {
            this(
                (Product2) new ProdutoFactory.ProdutoComercial().createRecord(),
                (FormaPagamento__c) new FormaPagamentoFactory().createRecord()
            );
        }
        public CondicaoCobranca(Product2 produto, FormaPagamento__c formaPagamento) {
            super(getRecordCondicaoCobranca(produto, formaPagamento));
        }
    }
}