public with sharing class SeguradoOrcamentoDAO {
	private static final SeguradoOrcamentoDAO instancia = new SeguradoOrcamentoDAO();
    private SeguradoOrcamentoDAO() {}
    public static SeguradoOrcamentoDAO getInstance(){ return instancia; }
	
	public List<SeguradoOrcamento__c> listarSeguradoOrcamento (Set<Id> segGrupos)
	{
		return 
		[
			SELECT
				Afastado__c,
				CID__c,
				Conta__c,
				CPF__c,
				DataNascimento__c,
				GrupoOrcamento__c,
				IOF__c,
				Name,
				Numero__c,
				PremioComercial__c,
				PremioPuro__c,
				TaxaComercial__c ,
				TaxaPura__c
			FROM
				SeguradoOrcamento__c
			WHERE
				GrupoOrcamento__c IN :segGrupos
		];
	}
}