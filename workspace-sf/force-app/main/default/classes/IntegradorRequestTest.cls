@isTest
private class IntegradorRequestTest {

    @isTest
    public static void testSendRequest() {
        HttpCalloutMock mock = new MockHttpCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);

        IntegradorRequest integradorRequest = IntegradorRequest.getInstance();
        HttpResponse response = integradorRequest.sendRequest('token', 'GET', '{}', 'https://www.example.com', 'GET', new List<IntegradorRequest.Header>());

        System.assertEquals(200, response.getStatusCode());
        System.assertEquals('{"status": "success"}', response.getBody());
    }

    private class MockHttpCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"status": "success"}');
            return response;
        }
    }
}