@isTest
public class TaskTriggerTest {
	
    static testmethod void testPreventAccDel(){
        Task taskRecord = new Task();
        taskRecord.Subject = 'Call';
        taskRecord.TipoComunicado__c ='Devolução';
        taskRecord.ActivityDate = System.today().addDays(1);
        
        insert taskRecord;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Processos e Projetos'];
		User U = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        try{
            delete taskRecord;
        }catch(DMLexception e){
            system.assert(e.getMessage().contains('Você não pode deletar tarefas'),'Você não pode deletar tarefas');                       
        }
    }
}