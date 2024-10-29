public with sharing class BackgroundConsoleDAO {
public static BackgroundConsoleDAO instance = new BackgroundConsoleDAO();
	private BackgroundConsoleDAO() {
		
	}

	public static BackgroundConsoleDAO getInstance(){
		return instance;
	}


	private Roteamento__c burcarRoteamentoPorId(Id routeId){
		Roteamento__c router = [ SELECT Id, OwnerId, Name, Orcamento__c FROM Roteamento__c where Id = :routeId ]; 
		return router;
	}

	public Opportunity burcarOportunidadePorRoteamentoId(Id routerId){
		Roteamento__c router = burcarRoteamentoPorId(routerId);
		Opportunity opp = [ SELECT Id, OwnerId, AccountId FROM Opportunity where Id = :router.Orcamento__c ];
		return opp;
	}
}