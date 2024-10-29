//PLV-5316 INÍCIO
public without sharing class GarantiaSinistroDAO {

	private static final GarantiaSinistroDAO instance = new GarantiaSinistroDAO();

	public static GarantiaSinistroDAO getInstance() {
		return instance;
	}

    public Id caseId {get;set;}

    public class GarantiaDAO { public Id caseId { get; set; } }
    
    public List<PagamentoGarantia__c> getGarantiaSinistro(){ 
        return [SELECT Id, Name, Caso__c FROM PagamentoGarantia__c WHERE Caso__c =: caseId];
    }
}
//PLV-5316 FIM