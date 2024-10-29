@isTest	
public class EventTriggerTest {

    static testmethod void testPreventAccDel(){
        
        Event eventRecord = new Event();
        
        eventRecord.Subject = 'Call';
        eventRecord.DurationInMinutes = 60;
        eventRecord.ActivityDateTime = System.today().addDays(1);
            
        insert eventRecord;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Processos e Projetos'];
		User U = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        try{
            delete eventRecord;
        }catch(DMLexception e){
            system.assert(e.getMessage().contains('Você não pode deletar Compromissos'),'Você não pode deletar Compromissos');                       
        }
    }
}