/*******************************************************************************************************************************
* Classe service para atualização do campo PrimeiroContratoRenovacao__c
* @author Squad Novos Ares
* @date 22/06/2022
* Classe criada por conta da história RVI-45
******************************************************************************************************************************/

public class UpdCpCtrRenova implements
    Database.Batchable<sObject>, Database.Stateful {    
     
	public Integer recordsProcessed = 0;
    
	public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id,                                     '   +
			'       Name,			                        '   + 
            '       PrimeiroContratoRenovacao__c,           '   + 
            '       ContratoRenovado__c                     '   +
            'FROM   Contract                     		    '   +
            'WHERE  ContratoRenovado__c <> null             '   +
            'AND    PrimeiroContratoRenovacao__c = null     '   +            
            'AND    Tipo__c = \'Renovacao\'  		        '   +
            'AND    CodigoRamo__c <> \'1377\'               '   +
            'AND    Status  <> \'Cancelado\'     		    '   +            
            'AND    Segmento__c = \'Individual\' 		    '   
        );                
    }
	
    public void execute(Database.BatchableContext bc, List<Contract> scope){

		List<Contract> lstToUpdate = new List<Contract>();
		
		if (scope.size() == 0) {
            System.debug('Nenhum Contrato encontrado para atualização com os parâmetros informados');
            return;
        }
        
		for(Contract ctrOrig : scope){       
            ctrOrig.PrimeiroContratoRenovacao__c = ctrOrig.ContratoRenovado__c;
            recordsProcessed = recordsProcessed + 1;					
		}
		
		if(lstToUpdate.size() > 0){
			update lstToUpdate;
		}        
    }
	
    public void finish(Database.BatchableContext bc){
        System.debug('Total Registros Processados = ' + recordsProcessed);
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        System.debug('Id Job AsyncApexJob = ' + job.Id);
        System.debug('Status Job AsyncApexJob = ' + job.Status);
        System.debug('Numero Erros Job AsyncApexJob = ' + job.NumberOfErrors);
    }
}