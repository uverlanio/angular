public with sharing class ContratanteContratoDAO 
{
	private static final ContratanteContratoDAO instancia = new ContratanteContratoDAO();
	private ContratanteContratoDAO() {	}
	public static ContratanteContratoDAO getInstance(){ return instancia; }

	public ContratanteContrato__c obterContratoPorId(String contratoId)
	{
		return
		[
			Select
				Id,
				Contrato__c
			From
				ContratanteContrato__c
			Where
				Id = :contratoId 
			LIMIT 1
		];
	}
	//FCVEP-29 - INICIO
	public List<ContratanteContrato__c> obterContratCtr(String contratoId){
		return [
			SELECT
				Id,
				Contrato__c
			FROM
				ContratanteContrato__c
			WHERE
				Contrato__c = :contratoId 
		];
	}

	public List<public_parcelacontrato__x> obterParcCtr(String idExterno){
		return [
                	SELECT 
                        id__c, 
                        datavencimento__c,
                        status__c
                    FROM 
                        public_parcelacontrato__x
                    WHERE 
                        idexterno__c = :idExterno
                    ];
	}
 	//FCVEP-29 - FIM
}