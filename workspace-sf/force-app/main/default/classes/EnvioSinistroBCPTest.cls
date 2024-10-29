// PLV-2015 Criação da classe
@IsTest
public class EnvioSinistroBCPTest {
    // PLV-4095 INICIO
    @IsTest
    static void envioSinistroBCPTest() {
        
        Contract contrato = (Contract) new ContratoFactory.ContratoFactorySemParam().createRecord();

        GarantiaContrato__c garContr = new GarantiaContrato__c( 
            Contrato__c = contrato.Id,
            Capital__c = 10000.00, 
            TipoCapital__c = 'Capital uniforme'
            );
        insert garContr;
        
        Case sinistroCase = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        sinistroCase.Id = null;
        sinistroCase.Contrato__c = contrato.Id;
        insert sinistroCase;

        Test.startTest();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/sinistro/bcp'; 
            req.params.put('caseId', sinistroCase.Id);
            req.params.put('edsTip', '1');
            req.httpMethod = 'GET';
            req.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req;
            RestContext.response = res;
            SinistroBCPRest.Response response = SinistroBCPRest.consultaSinistroBCP();
        Test.stopTest();  
    }
    // PLV-4095 FIM
}