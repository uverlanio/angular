//II-154 - INICIO
@isTest
public class CasoRestStatusTest {

    @isTest
    static void casoStatusTest(){

        RestRequest restReq = new RestRequest();        
        RestResponse res = new RestResponse();
	    restReq.requestUri ='/services/apexrest/caso/status/*';
	    restReq.httpMethod = 'POST';
	    restReq.requestBody = Blob.valueOf('1');
	    RestContext.response = res;
	    RestContext.request = restReq;

        String batchId = Database.executeBatch(new BatchGerarPDF());

        Test.startTest();
        String status = CasoRestStatus.consultarJobs(batchId);
        Test.stopTest();

        Assert.isNotNull(status, 'Success');
    }

    @isTest
    static void casoStatusExcptTest(){

        RestRequest restReq = new RestRequest();        
        RestResponse res = new RestResponse();
	    restReq.requestUri ='/services/apexrest/caso/status/*';
	    restReq.httpMethod = 'POST';
	    restReq.requestBody = Blob.valueOf('1');
	    RestContext.response = res;
	    RestContext.request = restReq;

        String batchId = null;

        Test.startTest();
        String exceptionMessage = CasoRestStatus.consultarJobs(batchId);
        Test.stopTest();

        Assert.isNotNull(exceptionMessage, 'List has no rows for assignment to SObject');

    }
}
//II-154 - FIM