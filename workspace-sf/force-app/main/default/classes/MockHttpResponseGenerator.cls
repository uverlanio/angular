@isTest
global class MockHttpResponseGenerator {
    
    global class IntegracaoSubscricaoSampleMedSuccess implements HttpCalloutMock {

        global HTTPResponse respond(HTTPRequest req) {  
                        
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"errors":[],"success":1,"total":1,"successEntries":[{"ApplicantsProduct":[{"id_on_origin":"AFF","capital_id":1001,"value":10000},{"id_on_origin":"CAN","capital_id":1001,"value":100000},{"id_on_origin":"IPA","capital_id":1001,"value":60000},{"id_on_origin":"BAS","capital_id":1001,"value":60000}],"Applicant":{"birthday":"1994-01-01","__product_group_id":1,"city":"SAO PAULO","sex":2,"__on_demand_applicant_data_hash":"0Q0L0000000Q4xYKAS","state":"SP","codproposal":"18-000287811","questionnaire_id":"4","company_id":"2","id":"70","questionnaire_url":"https://portosegurodev-subauto-questionario.samplemed.com.br?id=4c45311d0c6ae23fa2aaaf8abe1d251ec0ee76257cbd00d46615f829ae1dc46a"}}]}');
            res.setStatusCode(200); 
            return res;
        }
    }

    global class IntegracaoSubscricaoSampleMedFail implements HttpCalloutMock {

        global HTTPResponse respond(HTTPRequest req) {              
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"errors":[{"ApplicantsProduct":[{"id_on_origin":"AFF","capital_id":1001,"value":10000},{"id_on_origin":"CAN","capital_id":1001,"value":100000},{"id_on_origin":"IPA","capital_id":1001,"value":60000},{"id_on_origin":"BAS","capital_id":1001,"value":60000}],"Applicant":{"birthday":"1994-01-01","__product_group_id":1,"city":"SAO PAULO","sex":2,"__on_demand_applicant_data_hash":"0Q0L0000000Q4xYKAS","state":"SP","codproposal":"18-000287811"},"validationErrors":{"codproposal":["The proposal code must be unique."]}}],"success":0,"total":1,"successEntries":[]}');
            res.setStatusCode(200); 
            return res;
        }
    }
}