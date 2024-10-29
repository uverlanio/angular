public with sharing class CustomMetadataTypesDAO 
{
	private static CustomMetadataTypesDAO instance = new CustomMetadataTypesDAO();
	public static CustomMetadataTypesDAO getInstance(){	return instance; }
	public CustomMetadataTypesDAO() {}

	public List<MeioComercializacao__mdt> obtemMeiosComercializacaoValidacoes()
	{
		return 
		[ 
			SELECT 
				MasterLabel, 
				DeveloperName,
				PersisteValidacoes__c 
			FROM 
				MeioComercializacao__mdt 
			WHERE 
				PersisteValidacoes__c = :true
		];
	}
}