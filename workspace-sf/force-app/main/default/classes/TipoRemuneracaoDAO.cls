/**
 * TipoRemuneracaoDAO
 * @author Eric Tunu @ 15/06/2018
 *
 **/
public with sharing class TipoRemuneracaoDAO 
{
	private static final TipoRemuneracaoDAO instance = new TipoRemuneracaoDAO();
	public static TipoRemuneracaoDAO getInstance() { return instance; }


	public List<TipoRemuneracao__c> listar(Set<String> setTipoRemuneracao) 
	{
		return 
		[
			SELECT 
				Id, 
				Name, 
				Codigo__c,
				Descricao__c, 
				LimiteMinimo__c, 
				LimiteMaximo__c, 
				ModeloRecuperacao__c 
			FROM 
				TipoRemuneracao__c 
			WHERE 
				Codigo__c IN : setTipoRemuneracao
		];
	}

	//PLV2365: INICIO
	public List<TipoRemuneracao__c> buscarTipoRemuneracao() 
	{
		return 
		[
			SELECT 
				Id, 
				Name, 
				Codigo__c,
				Descricao__c, 
				LimiteMinimo__c, 
				LimiteMaximo__c, 
				ModeloRecuperacao__c 
			FROM 
				TipoRemuneracao__c 
		];
	}
	//PLV2365: FIM

}