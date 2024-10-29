/********************************************************************************************************************
* Classe ApoliceBatch para fix 
* @author Odemir Olivatti Sys4b
* @date 02/10/2021
* Classe Para gerar apolice para contratos que estao sem apolic e em estado  emitido .Complemento da  PLV-4816
* Execução
* No developer console->anonymous, executar
* System.enqueueJob(new ApoliceBatch());
* Aguardar o encerramento da fila, e verificar se as apolices foram geradas
*********************************************************************************************************************/


// PLV-4816 INICIO SYS4B
public  class ApoliceBatch  implements  Queueable{
 
    public  void execute(System.QueueableContext qc) {
         System.debug('executando');
         Set<Id> contratoIdSet = new Set<Id>();
         
        for (List<Contract> contracts:[SELECT Id, Name FROM Contract WHERE Segmento__c = 'Viagem' AND 
                                       ApolicePdfDownloadUrl__c = NULL AND Status='Emitido' AND Tipo__c != 'Endosso'
                                      AND Tipo__c != 'Cancelamento']) {
            System.debug('looop');
            System.debug('contracts.size()'+contracts.size());
            for(Contract c : contracts) {
                contratoIdSet.add(c.id); 
            }
        }
          System.debug('contracts.size()'+contratoIdSet.size());  
          if ( contratoIdSet.size() > 0 ){
              System.debug('INICIO PDF APOLICE');

            ContractBO.criarApoliceAsync(contratoIdSet);
          }
          
        
        
    }

}


// PLV-4816 FIM SYS4B