public with sharing class DadosCorretorDAO 
{
	private static final DadosCorretorDAO instancia = new DadosCorretorDAO();
    private DadosCorretorDAO(){}
    public static DadosCorretorDAO getInstance(){ return instancia; }

	public List<DadosCorretor__c> buscarCorretorPorSusep (Set<String> setSuseps)
	{
		return 
		[
			Select 
				Id, 
				Name,
				CodigoSucursalDestinoCheque__c,
				NomeCorretor__c,
				SucursalVinculo__c,
				SucursalDestinoCheque__c,
				Tipo__c
				, SusepOficialCorretor__c //PLV-5235 - INICIO/FIM
			From 
				DadosCorretor__c 
			Where 
				Name IN: setSuseps
		];
	}
	
	//INICIO | PLV-2179-27- remover duplicidade
	public List<DadosCorretor__c> listarDadosCorretorPorCodigo(Set<String> setNames)
	{
		return 
		[
			SELECT 
				Name, 
				CodigoSucursalDestinoCheque__c, 
				NomeCorretor__c, 
				SucursalVinculo__c, 
				SucursalDestinoCheque__c, 
				Tipo__c, 
				CreatedDate 
			FROM 
				DadosCorretor__c 
			WHERE 
				Name IN: setNames
            ORDER BY 
				CreatedDate DESC
		];
	}
	//FIM | PLV-2179-27- remover duplicidade
}