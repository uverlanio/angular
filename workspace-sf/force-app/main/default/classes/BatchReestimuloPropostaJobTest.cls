//ZSVEP-76-INICIO
@isTest
public class BatchReestimuloPropostaJobTest {
    
    @testSetup
    static void setup() {
        Opportunity opp = new Opportunity();
        opp.Name = 'asd';
        opp.StageName = 'Em criação';
        opp.CloseDate = System.today();
        insert opp;

        Quote quote = new Quote(
            Name = 'Test Quote',
            Status = 'Draft',
            OpportunityId = opp.Id
        );
        insert quote;
    }
    
    @isTest
    static void testExecute() {
        Quote quote = [SELECT Id, Name, Status FROM Quote LIMIT 1];
        
        BatchReestimuloPropostaJob job = new BatchReestimuloPropostaJob();
        job.quoteToUpdate = quote;
        
        Test.startTest();
        
        String cronExpression = '0 0 0 1 1 ? 2050'; // Agendar para uma data futura
        String jobId = System.schedule('Test BatchReestimuloPropostaJob', cronExpression, job);
        
        Test.stopTest();

        Quote updatedQuote = [SELECT Id, Name, Status FROM Quote WHERE Id = :quote.Id];
        System.assertEquals('Draft', updatedQuote.Status, 'The quote status should remain as Draft');
    }
}
//ZSVEP-76-FIM