/*
 * Criação do metodo buscaDadosContaSeg
 * Avanxo
 * Data da criação: 27/02/2019
 * 
*/
public with sharing class SeguradoContratoDAO {
	
	private static final SeguradoContratoDAO instancia = new SeguradoContratoDAO();
	private SeguradoContratoDAO() {}
	public static SeguradoContratoDAO getInstance(){ return instancia; }

	public SeguradoContrato__c obterVida(String id)
	{
		return
		[
			Select
				Id,
				GrupoContrato__c,
				GrupoContrato__r.ContratanteContrato__c
			From
				SeguradoContrato__c
			Where
				Id = :id 
			LIMIT 1
		];
	}
    
    public Map<Id,Account> buscaDadosContaSeg(Set<Id> sIdAcc){
        
        Map<Id,Account> mapAcc = new Map<Id,Account>();
        
        for(Account acc : [SELECT Id, Name, Cpf__c, Cnpj__c, RecordTypeId FROM Account WHERE Id IN :sIdAcc]){
            mapAcc.put(acc.Id, acc);
        }
        
        return mapAcc;
    }
}