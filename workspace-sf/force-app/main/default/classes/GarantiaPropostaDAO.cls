public with sharing class GarantiaPropostaDAO 
{
	private static final GarantiaPropostaDAO instancia = new GarantiaPropostaDAO();
	private GarantiaPropostaDAO(){}
	public static GarantiaPropostaDAO getInstance(){ return instancia; }

	public List<GarantiaProposta__c> buscarGruposPropostaPorIds(Set<Id> propostaKey)
	{
		return 
		[
			SELECT
				Id,
				Name,
				NumeroSorte__c,
				NumeroSerie__c,
				Proposta__c,
				TipoCapital__c,
				Capital__c,
				Garantia__c,
				GarantiaProduto__c,
				LimiteCapital__c,
				Garantia__r.Sigla__c,
				Garantia__r.Name,
				Garantia__r.Status__c,
				Garantia__r.Tipo__c,
				Garantia__r.TipoEvento__c,
				Garantia__r.VigenciaInicial__c,
				Garantia__r.Descricao__c,
				PremioPuro__c,
				PremioComercial__c,
				PremioIntegral__c, //PLV-5351 INICIO/FIM
				PremioTotal__c,
				CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
				TaxaPura__c,
				TaxaComercial__c,
				TaxaTotal__c,
				Proposta__r.Tipo__c // RVI-143 - INICIO/FIM
			FROM
				GarantiaProposta__c
			WHERE 
				Proposta__c IN :propostaKey
		];
 	}

}