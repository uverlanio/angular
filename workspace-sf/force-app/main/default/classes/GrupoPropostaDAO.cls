public with sharing class GrupoPropostaDAO 
{
	private static final GrupoPropostaDAO instancia = new GrupoPropostaDAO();
	private GrupoPropostaDAO(){}
	public static GrupoPropostaDAO getInstance(){ return instancia; }

	public List<GrupoProposta__c> buscarGruposPropostaPorIds(Set<Id> setSegurados)
	{
		return [
			SELECT
				Id,
				TipoCalculo__c,
				ContratanteProposta__c,
				QuantidadeVidas__c,
				Name,
				Descricao__c,
				PremioPuro__c,
				PremioTotal__c,
				PremioIntegral__c, //PLV-5351 INICIO/FIM
				TaxaPura__c,
				PremioComercial__c,
				TaxaComercial__c,
				TaxaTotal__c
			FROM
				GrupoProposta__c
			WHERE 
				ContratanteProposta__c IN :setSegurados
		];
 	}

	// PLV-5249 - INÍCIO 
	public Map<String, List<GrupoProposta__c>> buscarMapGruposPropostaPorIds(Set<Id> setSegurados)
	{
		List<GrupoProposta__c> gruposProposta = buscarGruposPropostaPorIds(setSegurados);
		Map<String, List<GrupoProposta__c>> mapGruposPropostas = new Map<String, List<GrupoProposta__c>>();

		for(GrupoProposta__c grupoProposta : gruposProposta)
		{
			if(mapGruposPropostas.containsKey(grupoProposta.ContratanteProposta__c))
			{
				List<GrupoProposta__c> lstGrupoProposta = mapGruposPropostas.get(grupoProposta.ContratanteProposta__c);
				lstGrupoProposta.add(grupoProposta);
			}
			else 
			{
				List<GrupoProposta__c> lstGrupoProposta = new List<GrupoProposta__c>();
				lstGrupoProposta.add(grupoProposta);
				mapGruposPropostas.put(grupoProposta.ContratanteProposta__c, lstGrupoProposta);
			}
		}
		return mapGruposPropostas;
	}
	// PLV-5249 - FIM
}