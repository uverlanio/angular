@isTest
public class GarantiaRelacionadaFactory {

	private static Map<String, GarantiaRelacionada__c> relacionamento = new Map<String, GarantiaRelacionada__c>();

//--------------------------------------------------GaranRel Técnico------------------------------------------------------------

	private static GarantiaRelacionada__c getRecordGaranRelTec(GarantiaProduto__c garanProdTec, GarantiaProduto__c garanProdTec2){

		if(!relacionamento.containsKey('GaranRelTecnico')){
			Recordtype garanTec = RecordTypeBO.buscarTipoRegistro('GarantiaRelacionada__c', 'ProdutoTecnico');

			relacionamento.put('GaranRelTecnico', new GarantiaRelacionada__c(
				RecordTypeId = garanTec.Id,
                GarantiaProduto__c = garanProdTec.Id,
                GarantiaRelacionada__c = garanProdTec2.Id
				)
			);
		}
		return relacionamento.get('GaranRelTecnico');
	}

	public class ProdutoTecnico extends SObjectFactory {
		
		public ProdutoTecnico(GarantiaProduto__c garanProdTec, GarantiaProduto__c garanProdTec2) {

			super(getRecordGaranRelTec(garanProdTec, garanProdTec2));
   		}
  	}
    
//---------------------------------------------------GaranRel Comercial-------------------------------------------------
    
    private static GarantiaRelacionada__c getRecordGaranRelCom (GarantiaProduto__c garanProdCom, GarantiaProduto__c garanProdCom2){

		if(!relacionamento.containsKey('GaranRelComercial')){
			Recordtype garanCom = RecordTypeBO.buscarTipoRegistro('GarantiaRelacionada__c', 'ProdutoComercial');
			system.debug('TESTE '+garanProdCom.Produto__c);
            system.debug('TESTE2 '+garanProdCom2.Produto__c);
			relacionamento.put('GaranRelComercial', new GarantiaRelacionada__c(
				RecordTypeId = garanCom.Id,
                GarantiaProduto__c = garanProdCom.Id,
                GarantiaRelacionada__c = garanProdCom2.Id
				)
			);
		}
		return relacionamento.get('GaranRelComercial');
	}

	public class ProdutoComercial extends SObjectFactory {
		
		public ProdutoComercial(GarantiaProduto__c garanProdCom, GarantiaProduto__c garanProdCom2) {

			super(getRecordGaranRelCom(garanProdCom, garanProdCom2));
   		}
  	}
}