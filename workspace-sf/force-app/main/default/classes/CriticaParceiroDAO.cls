public with sharing class CriticaParceiroDAO 
{
	private static final CriticaParceiroDAO instancia = new CriticaParceiroDAO();
	private CriticaParceiroDAO(){}
	public static CriticaParceiroDAO getInstance(){ return instancia; }

	public List<CriticaParceiro__c> buscarCriticasParceiro(Set<String> setIdsParceiros)
	{
		return 
		[
			SELECT
				Id,
				Rotulo__c,
				CodigoCriticaMotorRegras__c,
				IdentificacaoCampo__c,
				Mensagem__c,
				Name,
				Parceiro__c,
				Parceiro__r.Codigo__c,
				TipoRegistro__c
			FROM
				CriticaParceiro__c
			WHERE
				Parceiro__r.Codigo__c =: setIdsParceiros
		];
	}
}