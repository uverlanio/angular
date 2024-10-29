/**
 * FormaPagamentoDAO
 * @author Eric Tunú @ 14/06/2018
 *
 **/
public with sharing class FormaPagamentoDAO 
{
	private static final FormaPagamentoDAO instance = new FormaPagamentoDAO();
	public static FormaPagamentoDAO getInstance() { return instance; }
	private FormaPagamentoDAO() { }

	// public FormaPagamento__c obter(String codigo)
	// {
	// 	return 
	// 	[
	// 		SELECT
	// 			Id,
	// 			Codigo__c,
	// 			Name		
	// 		FROM
	// 			FormaPagamento__c
	// 		WHERE
	// 			Codigo__c = :codigo
	// 		LIMIT 1		
	// 	];
	// }

	public List<FormaPagamento__c> listar(Set<String> codigo)
	{
		return 
		[
			SELECT
				Id,
				Codigo__c,
				Name		
			FROM
				FormaPagamento__c
			WHERE
				Codigo__c IN :codigo
		];
	}

	// public List<FormaPagamento__c> buscarFormasPagamentoPorRamoSeguro(Set<Id> idsRamoSeguro) {
	// 	return [
	// 		SELECT
	// 			Id,
	// 			Name,
	// 			Codigo__c,
	// 			RamoSeguro__c,
	// 			RamoSeguro__r.Name,
	// 			RamoSeguro__r.Codigo__c,
	// 			Modalidade__c,
	// 			Modalidade__r.Codigo__c,
	// 			(
	// 				SELECT
	// 					Id,
	// 					Name,
	// 					NumeroParcela__c,
	// 					CodigoMeioRecebimento__c,
	// 					DescricaoMeioRecebimento__c,
	// 					IdExterno__c
	// 				FROM
	// 					PlanosParcelamento__r
	// 			)
	// 		FROM
	// 			FormaPagamento__c
	// 		WHERE
	// 			RamoSeguro__c IN :idsRamoSeguro
	// 	];
	// }

	public List<FormaPagamento__c> buscarFormasPagamentoPorIds(Set<Id> idsFormaPagamento) {
		return [
			SELECT
				Id,
				Name,
				Codigo__c,
				RamoSeguro__c,
				RamoSeguro__r.Name,
				RamoSeguro__r.Codigo__c,
				Modalidade__c,
				Modalidade__r.Codigo__c,
				(
					SELECT
						Id,
						Name,
						NumeroParcela__c,
						CodigoMeioRecebimento__c,
						DescricaoMeioRecebimento__c,
						IdExterno__c
					FROM
						PlanosParcelamento__r
				)
			FROM
				FormaPagamento__c
			WHERE
				Id IN :idsFormaPagamento
		];
	}

	//RVI-171 - INICIO
	public static Map<String, PlanoParcelamento__c> retPlan(Set<Id> produto, String codFpPg) {

		Set<Id> stIdd = new Set<Id>();
		Map<String, PlanoParcelamento__c> mapPlanParc = new Map<String, PlanoParcelamento__c>();

		List<CondicaoCobranca__c> lstCdc = [SELECT Id, Name, FormaPagamento__r.Id, FormaPagamento__r.Codigo__c, Produto__c, QuantidadeParcelas__c 
		                                    FROM CondicaoCobranca__c
		                                    WHERE FormaPagamento__r.Codigo__c =:codFpPg
		                                    AND Produto__c IN :produto];                                   

		for (CondicaoCobranca__c cdcCba : lstCdc)
		{
		    stIdd.add(cdcCba.FormaPagamento__r.Id);
		}

		List<PlanoParcelamento__c> lstPcl = [SELECT Id, Name, NumeroParcela__c, FormaPagamento__c, FormaPagamento__r.Name FROM PlanoParcelamento__c
		                                     WHERE FormaPagamento__c IN :stIdd];

		for(PlanoParcelamento__c plc : lstPcl)
		{
		    String chaveParc = String.valueOf(plc.NumeroParcela__c + plc.FormaPagamento__r.Name);
		    mapPlanParc.put(chaveParc, plc);
		}
		return mapPlanParc;
	}  
	//RVI-171 - FIM
}