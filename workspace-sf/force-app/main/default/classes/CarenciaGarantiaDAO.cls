public with sharing class CarenciaGarantiaDAO 
{
	private static final CarenciaGarantiaDAO instancia = new CarenciaGarantiaDAO();
	private CarenciaGarantiaDAO(){}
	public static CarenciaGarantiaDAO getInstance(){ return instancia; }

	public List<CarenciaGarantia__c> buscarCarenciasGarantia (Set<Id> garantiaProduto)
	{
		return 
		[
			SELECT
				Id,
				Carencia__c,
				CarenciaGarantia__c,
				GarantiaProduto__c,
				PermiteAlterarProdutoComercial__c,
				RecordTypeId,
				Carencia__r.Descricao__c
	
			FROM
				CarenciaGarantia__c
			WHERE
				GarantiaProduto__c IN : garantiaProduto
		];
	}

	//PLV-5259 - INICIO
	public Map<String, List<CarenciaGarantia__c>> buscarMapCarenciasGarantia(Set<Id> setGarantiasProduto)
	{
		List<CarenciaGarantia__c> carencias = buscarCarenciasGarantia(setGarantiasProduto);
		Map<String, List<CarenciaGarantia__c>> mapCarencias = new Map<String, List<CarenciaGarantia__c>>();

		for(CarenciaGarantia__c carencia : carencias)
		{
			if(mapCarencias.containsKey(carencia.GarantiaProduto__c))
			{
				List<CarenciaGarantia__c> lstCarencias = mapCarencias.get(carencia.GarantiaProduto__c);
				lstCarencias.add(carencia);
			}
			else 
			{
				List<CarenciaGarantia__c> lstCarencias = new List<CarenciaGarantia__c>();
				lstCarencias.add(carencia);
				mapCarencias.put(carencia.GarantiaProduto__c, lstCarencias);
			}
		}
		return mapCarencias;
	}
	//PLV-5259 - FIM
}