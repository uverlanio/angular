//PLV_2583 - INICIO - Ajuste na busca de coberturas no objeto "Garantia Relacionada"
/**
 * Controller para o componente CriarGarantiaRelacionada.cmp
 * @author Mariana Ribeiro Lial @ 02/01/2020
 *
 **/
public class CriarGarantiaRelacionadaController {
	
    public class GarantiaWrapper{
		@AuraEnabled public String id {get;set;}
		@AuraEnabled public String Name {get;set;}
		@AuraEnabled public String GarantiaName {get;set;}

		public GarantiaWrapper(){
			this.id = '';
			this.Name = '';	
			this.GarantiaName = '';
		}
	}
    
    @AuraEnabled
	public static List<CriarGarantiaRelacionadaController.GarantiaWrapper> pesquisaGarantiaProduto(String recordId, String term){
		String search = term.trim();
		String searchTerm = '%'+search+'%';
		GarantiaProduto__c garantia = [SELECT Id, Name, Produto__c
												FROM GarantiaProduto__c 
												WHERE Id = :recordId LIMIT 1];
   		System.debug('garantia: '+ garantia);
		if(search == null || search == ''){

			return null;
		} else {
			List<GarantiaProduto__c> lGarantiaProduto = [SELECT Id, Name, Garantia__r.Name , Produto__c
												FROM GarantiaProduto__c 
												WHERE Produto__c =: garantia.Produto__c
                                                AND Garantia__r.Name LIKE :searchTerm
                                                ORDER BY Name ASC];
            
            system.debug('lGarantiaProduto: '+lGarantiaProduto);
            
            List<CriarGarantiaRelacionadaController.GarantiaWrapper> lstGarantias = new List<CriarGarantiaRelacionadaController.GarantiaWrapper>();
            
            if(!(lGarantiaProduto.isEmpty())){
                for(GarantiaProduto__c g: lGarantiaProduto){
                    CriarGarantiaRelacionadaController.GarantiaWrapper garantiaNova = new CriarGarantiaRelacionadaController.GarantiaWrapper();
                    garantiaNova.id = g.Id;
                    garantiaNova.Name = g.Name;
                    garantiaNova.GarantiaName = g.Garantia__r.Name;
                    lstGarantias.add(garantiaNova);
            	}
                
                system.debug('lstGarantias: '+lstGarantias);
            
                if(lstGarantias.isEmpty()) return null;
                
                return lstGarantias;
            }else{
                return null;
            }
            
		}

	}
    
    @AuraEnabled
	public static String buscaNomeGarantiaProduto (String recordId){

		GarantiaProduto__c lGarantiaProduto = [SELECT Id, Name 
											FROM GarantiaProduto__c 
											WHERE Id = :recordId];

		return lGarantiaProduto.Name;
	}
    
    @AuraEnabled
	public static String salvarGarantias (String garantiaId, String recordTyp, String GarantiaRelacionada, String tipoDependencia, Boolean acumulativa, Boolean incremento ){
		
        try {
            Id recordTypeId = Schema.SObjectType.GarantiaRelacionada__c.getRecordTypeInfosByDeveloperName().get(recordTyp).getRecordTypeId();
            GarantiaRelacionada__c lGarantia = new GarantiaRelacionada__c();
            lGarantia.RecordTypeId = recordTypeId;
            lGarantia.GarantiaProduto__c = (id)garantiaId;
            lGarantia.GarantiaRelacionada__c = (id)GarantiaRelacionada;
            if(tipoDependencia != 'no'){
                lGarantia.TipoDependencia__c = tipoDependencia;
            }
            lGarantia.Acumulativa__c = acumulativa;
            lGarantia.Incremento__c = incremento;
            
            insert lGarantia;
            return 'Sucesso';
        }
        catch(Exception e) {
            System.debug('######## ERRO: ' + e.getLineNumber() + ', ' + e.getMessage());
            return 'ERROR '+ e.getLineNumber() + ', ' + e.getMessage();
        }	
	}
    
    @AuraEnabled
	public static List<String> getPickListLabelIntoList(){
		List<String> tipoList = new List<String>();
		List<Schema.PicklistEntry> values = GarantiaRelacionada__c.TipoDependencia__c.getDescribe().getPicklistValues();
		for(Schema.PicklistEntry v : values) {
			tipoList.add(v.getLabel());
            System.debug('moeda: '+v.getLabel());
		}
		return tipoList;
	}
}
//PLV_2583 - FIM - Ajuste na busca de coberturas no objeto "Garantia Relacionada"