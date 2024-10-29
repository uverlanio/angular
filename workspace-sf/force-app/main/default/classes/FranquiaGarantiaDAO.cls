public with sharing class FranquiaGarantiaDAO 
{
	private static final FranquiaGarantiaDAO instancia = new FranquiaGarantiaDAO();
	private FranquiaGarantiaDAO(){}
	public static FranquiaGarantiaDAO getInstance(){ return instancia; }

	public List<FranquiaGarantia__c> buscarFranquiasGarantia (Set<Id> garantiaProduto)
	{
		return 
		[
			SELECT
				Id,
				Franquia__c,
				FranquiaGarantia__c,
				GarantiaProduto__c,
				PermiteAlterarProdutoComercial__c,
				RecordTypeId,
				Franquia__r.Descricao__c
	
			FROM
				FranquiaGarantia__c
			WHERE
				GarantiaProduto__c IN : garantiaProduto
		];
	}

	//PLV-5259 - INICIO
	public Map<String, List<FranquiaGarantia__c>> buscarMapFranquiasGarantia(Set<Id> setGarantiasProduto)
	{
		List<FranquiaGarantia__c> franquias = buscarFranquiasGarantia(setGarantiasProduto);
		Map<String, List<FranquiaGarantia__c>> mapFranquias = new Map<String, List<FranquiaGarantia__c>>();

		for(FranquiaGarantia__c franquia : franquias)
		{
			if(mapFranquias.containsKey(franquia.GarantiaProduto__c))
			{
				List<FranquiaGarantia__c> lstFranquias = mapFranquias.get(franquia.GarantiaProduto__c);
				lstFranquias.add(franquia);
			}
			else 
			{
				List<FranquiaGarantia__c> lstFranquias = new List<FranquiaGarantia__c>();
				lstFranquias.add(franquia);
				mapFranquias.put(franquia.GarantiaProduto__c, lstFranquias);
			}
		}
		return mapFranquias;
	}
	//PLV-5259 - FIM
}