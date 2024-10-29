//FNPVVEP-126 INICIO
@isTest
public class RecalculoPropostaOutControllerTest {

    @testSetup
    static void setupData() {
        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();
    }

    @isTest
    static void EncryptIdTest() {

        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        RecalculoPropostaOutController.FlowInputs input = new RecalculoPropostaOutController.FlowInputs();
        input.recordId = proposta.Id;
        
        List<RecalculoPropostaOutController.EncryptedIdWrapper> result = RecalculoPropostaOutController.encryptId(new List<RecalculoPropostaOutController.FlowInputs>{ input });
        
        System.assertEquals(1, result.size());
        System.assertNotEquals(null, result[0].encryptedId);
    }
}
//FNPVVEP-126 FIM