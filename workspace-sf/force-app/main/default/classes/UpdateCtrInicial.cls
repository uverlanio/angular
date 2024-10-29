/*******************************************************************************************************************************
* Classe service para atualização do campo ContratoInicial__c
* @author Squad Novos Ares
* @date 08/06/2022
* Classe criada por conta da história RVI-105
******************************************************************************************************************************/

public class UpdateCtrInicial implements
    Database.Batchable<sObject>, Database.Stateful {    
    
	public Integer recordsProcessed = 0;
    
	public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id,                                     '   +
            '       Empresa__c,                             '   + 
            '       Sucursal__c,                            '   +
            '       CodigoRamo__c,                          '   + 
            '       NumeroApolice__c,                       '   +
			'       Endosso__c,                             '   +
			'       Name			                        '   + 
            'FROM   Contract                     		    '   +
            'WHERE  Endosso__c = \'0\'           		    '   +
			'AND    Tipo__c <> \'Cancelamento\'  		    '   +
            'AND    Status  <> \'Cancelado\'     		    '   +            
            'AND    Segmento__c = \'Individual\' 		    '   +
			'AND    StatusRenovacao__c = \'Não Renovado\'   '   +
            'AND    CodigoRamo__c <> \'1377\'               '   +
			'AND    NumeroApolice__c <> null                '   +
			'ORDER BY NumeroApolice__c DESC, Endosso__c ASC '
        );
    }
	
    public void execute(Database.BatchableContext bc, List<Contract> scope){
        
		Set<String> filtrCTR = new Set<String>();
		Map<String, Contract> mapCTR = new Map<String, Contract>();
		List<Contract> lstToUpdate = new List<Contract>();
		
		if (scope.size() == 0) {
            System.debug('Nenhum Contrato encontrado para atualização com os parâmetros informados');
            return;
        }
		
		for(Contract ctr : scope){    			
			filtrCTR.add('%'+ctr.Empresa__c+'-'+ctr.Sucursal__c+'-'+ctr.CodigoRamo__c+'-'+ctr.NumeroApolice__c+'%');
		}
		
		List<Contract> lstREN = [SELECT Id, Name, ContratoInicial__c  
                        FROM Contract 
                        WHERE Endosso__c > '0' 
                        AND StatusRenovacao__c = 'Não Renovado' 
                        AND Segmento__c = 'Individual' 
						AND Tipo__c != 'Cancelamento' 
						AND Status != 'Cancelado' 
                        AND Name like :filtrCTR
						ORDER BY NumeroApolice__c DESC, Endosso__c ASC];      

        if (lstREN.size() == 0) {
            System.debug('Não existe(m) endosso(s) para o(s) contrato(s)');            
            return;
        }
		
		for(Contract ctrREN : lstREN){
			mapCTR.put(ctrREN.Name, ctrREN);
		}
		
		for(Contract ctrOrig : scope){                         
			for (String key : mapCTR.keySet()) {                
				String keyCTR = ctrOrig.Empresa__c+'-'+ctrOrig.Sucursal__c+'-'+ctrOrig.CodigoRamo__c+'-'+ctrOrig.NumeroApolice__c;				    
				String keyEND = key.split('-')[0]+'-'+key.split('-')[1]+'-'+key.split('-')[2]+'-'+key.split('-')[3];		
				if(keyCTR == keyEND){
					mapCTR.get(key).ContratoInicial__c = ctrOrig.Id;                
					lstToUpdate.add(mapCTR.get(key)); 
                    recordsProcessed = recordsProcessed + 1;					
				}				    
			}
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