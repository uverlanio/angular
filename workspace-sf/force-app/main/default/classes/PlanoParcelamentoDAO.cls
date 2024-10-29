public with sharing class PlanoParcelamentoDAO 
{
	private static final PlanoParcelamentoDAO instance = new PlanoParcelamentoDAO();
	public static PlanoParcelamentoDAO getInstance() { return instance; }
	private PlanoParcelamentoDAO() { }

	public List<PlanoParcelamento__c> listar()
	{
		return 
		[
			SELECT
				Id,
				DescricaoMeioRecebimento__c,
				CodigoMeioRecebimento__c,
				FormaPagamento__c,
				IdExterno__c,
				IdFormaPagamento__c,
				Name,
				NumeroParcela__c
			FROM
				PlanoParcelamento__c
		];

	}
}