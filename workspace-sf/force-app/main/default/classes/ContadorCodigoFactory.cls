/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-19
 * @description ContadorCodigo__c Factory Class
 */
 @isTest
public class ContadorCodigoFactory {
	private static Map<String,ContadorCodigo__c> mStaticRecord = new Map<String,ContadorCodigo__c>();

	private static ContadorCodigo__c getRecordProdutoTecnico(){

		if(!mStaticRecord.containsKey('ProdutoTecnico')){
			
			mStaticRecord.put('ProdutoTecnico', new ContadorCodigo__c(
				Numero__c = 1.0,
				Name = 'ProdutoTecnico') 
			);
		}
		return mStaticRecord.get('ProdutoTecnico');
	}

public class ProdutoTecnico extends SObjectFactory {

	public ProdutoTecnico() {

		super(getRecordProdutoTecnico());
	}
}

//---------------------------------------Pessoa Jurídica------------------------------------------------

	private static ContadorCodigo__c getRecordProdutoComercial(){

		if(!mStaticRecord.containsKey('ProdutoComercial')){

			mStaticRecord.put('ProdutoComercial', new ContadorCodigo__c(
				Numero__c = 2.0,
				Name = 'ProdutoComercial') 
			);
		}
		return mStaticRecord.get('ProdutoComercial');
	}

public class ProdutoComercial extends SObjectFactory {

	public ProdutoComercial() {

		super(getRecordProdutoComercial());
	}
}
    
    //PLV-3926 - INICIO
    private static ContadorCodigo__c getRecordNumeroOferta(){
		if(!mStaticRecord.containsKey('NumeroOferta')){
			mStaticRecord.put('NumeroOferta', new ContadorCodigo__c(
				Numero__c = 2.0,
				Name = 'NumeroOferta') 
			);
		}
		return mStaticRecord.get('NumeroOferta');
	}

    public class NumeroOferta extends SObjectFactory {
        public NumeroOferta() {
            super(getRecordNumeroOferta());
        }
    }
    //PLV-3926 - FIM
}