public class CasoHistoricoMedico {

	@AuraEnabled
	public static List<Case> consultaHistorico(String recordId){
		system.debug('TF: '+recordId);

		Id recTypeSinistro = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro').Id;

		Case getCRM = [SELECT Id, CRM__c FROM Case WHERE Id = :recordId];

		List<Case> lstHistoricoMedico = [SELECT Id, 
										NumeroSinistro__c,
										Status,
										Parecer_medico__c,
										Status_Dependente__c,
										Garantia_do_segurado_do_contrato__c,
										Garantia_do_segurado_do_contrato__r.Name,
										Contrato__r.Sucursal__c,
										Contrato__r.RamoSeguro__r.Name,
										Contrato__r.NumeroApolice__c,
                                        Fraude__c,
                                        Nome_Medico__c,
                                        CRM__c
										FROM Case
										WHERE CRM__c =: getCRM.CRM__c AND Id != :recordId AND RecordTypeId = :recTypeSinistro AND NumeroSinistro__c !=: ''
										ORDER BY Data_sinistro_avisado__c DESC LIMIT 3];

		system.debug('TF: '+lstHistoricoMedico);
		system.debug('TF: CRM '+getCRM.CRM__c);

		if(getCRM.CRM__c == null){
			system.debug('entrou no if nulo');
			return null;
		}else{
			return lstHistoricoMedico;
		}

	}

}