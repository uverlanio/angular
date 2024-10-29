public class PesquisaGarantiaSegContratoController {

	@AuraEnabled
	public static String pesquisaGarantiaSegContrato(String recordId, String term){
		String search = term.trim();
		String searchTerm = '%'+search+'%';
		PagamentoGarantia__c vPagGaran = [SELECT Id, Caso__r.Segurado_do_contrato__c 
											FROM PagamentoGarantia__c 
											WHERE Id = :recordId];

		if(vPagGaran.Caso__r.Segurado_do_contrato__c == null) return 'Sem segurado';

		if(search == null || search == ''){
			List<GarantiaSeguradoContrato__c> lstGaranSegComp = [SELECT Id, Name, Capital__c, Garantia__r.Name 
																	FROM GarantiaSeguradoContrato__c 
																	WHERE SeguradoContrato__c = :vPagGaran.Caso__r.Segurado_do_contrato__c];

			return String.valueOf(JSON.serialize(lstGaranSegComp));
		} else {
			List<GarantiaSeguradoContrato__c> lstGaranSegComParam = [SELECT Id, Name, Capital__c, Garantia__r.Name 
																	FROM GarantiaSeguradoContrato__c 
																	WHERE SeguradoContrato__c = :vPagGaran.Caso__r.Segurado_do_contrato__c
																	AND Nomenclatura_Pesquisa_Garantia_Segurado__c LIKE :searchTerm];

			if(lstGaranSegComParam.isEmpty()) return 'Sem garantia';

			return String.valueOf(JSON.serialize(lstGaranSegComParam));
		}

	}

	@AuraEnabled
	public static void updatePagamentoGarantia(String recordId, String garanSeg){
		
		PagamentoGarantia__c pagGaran = new PagamentoGarantia__c();
		GarantiaSeguradoContrato__c garanSegCon = (GarantiaSeguradoContrato__c)JSON.deserialize(garanSeg, GarantiaSeguradoContrato__c.class);

		pagGaran.Id = recordId;
		pagGaran.Garantia_do_segurado_do_contrato__c = garanSegCon.Id;
		pagGaran.Capital__c = garanSegCon.Capital__c;

		update pagGaran;
	}

	@AuraEnabled
	public static String buscaNomePagamentoGarantia (String recordId){

		PagamentoGarantia__c vPagGaran = [SELECT Id, Name 
											FROM PagamentoGarantia__c 
											WHERE Id = :recordId];

		return vPagGaran.Name;
	}

}