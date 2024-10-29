public with sharing class GarantiasGrupoPropostaDAO 
{
	private static final GarantiasGrupoPropostaDAO instancia = new GarantiasGrupoPropostaDAO();
	public static GarantiasGrupoPropostaDAO getInstance() { return instancia; }
	private GarantiasGrupoPropostaDAO() {}

	public List<GarantiasGrupoProposta__c> listaGarantiasVida (Set<Id> setIdGrupo)
	{
		return 
		[
			SELECT
				GarantiaReferenciada__r.Sigla__c,
				Capital__c,
				Garantia__c, //AV-36 - INICIO
				GarantiaProduto__c, //AV-36 - FIM
				Percentual__c,
				PremioComercial__c,
				PremioPuro__c,
				PremioTotal__c,
				PremioIntegral__c, //PLV-5351 INICIO/FIM
				TaxaComercial__c,
				TaxaPura__c,
				TaxaTotal__c,
				Valor__c,
				ValorCotacao__c,
				CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
				//SeguradoProposta__c,
				GrupoProposta__c
			FROM
				GarantiasGrupoProposta__c
			WHERE
				GrupoProposta__c =: setIdGrupo
		];
	}

	// PLV-5249 - INÍCIO
	public Map<String, List<GarantiasGrupoProposta__c>> mapGarantiasVida(Set<Id> setSegurados)
	{
		List<GarantiasGrupoProposta__c> garantiasGruposProposta = listaGarantiasVida(setSegurados);
		Map<String, List<GarantiasGrupoProposta__c>> mapGarantiasGruposPropostas = new Map<String, List<GarantiasGrupoProposta__c>>();

		for(GarantiasGrupoProposta__c garantiaGrupoProposta : garantiasGruposProposta)
		{
			if(mapGarantiasGruposPropostas.containsKey(garantiaGrupoProposta.GrupoProposta__c))
			{
				List<GarantiasGrupoProposta__c> lstGarantiasGrupoProposta = mapGarantiasGruposPropostas.get(garantiaGrupoProposta.GrupoProposta__c);
				lstGarantiasGrupoProposta.add(garantiaGrupoProposta);
			}
			else 
			{
				List<GarantiasGrupoProposta__c> lstGarantiasGrupoProposta = new List<GarantiasGrupoProposta__c>();
				lstGarantiasGrupoProposta.add(garantiaGrupoProposta);
				mapGarantiasGruposPropostas.put(garantiaGrupoProposta.GrupoProposta__c, lstGarantiasGrupoProposta);
			}
		}
		return mapGarantiasGruposPropostas;
	}
	// PLV-5249 - FIM
}