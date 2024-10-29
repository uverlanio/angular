public with sharing class ModalidadeDAO {

	private static final ModalidadeDAO instance = new ModalidadeDAO();
	public static ModalidadeDAO getInstance() { return instance; }
	private ModalidadeDAO() { }
	

	public Modalidade__c obter(String modalidade) 
	{
		return 
		[
			SELECT 
				id, 
				Codigo__c
			FROM 
				Modalidade__c 
			WHERE 
				Codigo__c = :modalidade 
			LIMIT 1			
		];
	}
}