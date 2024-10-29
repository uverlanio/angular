/**
 * @historia PLV-4635
 * @author Guilherme Azevedo
 * @version 1.0
*/
//PLV-4635 INICIO
@isTest
public with sharing class RecusaDocusignRestTest {
    
    @TestSetup
    static void makeData() {
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, conta).createRecord();
    }

    

    @isTest
    static void testSaveRecusaSinistro() {
        Case sinistro = [SELECT ID FROM CASE WHERE RECORDTYPE.DEVELOPERNAME = 'Sinistro' LIMIT 1];
        String jsonStr = '{"id_salesforce":"' + sinistro.Id + '","DocuSignEnvelopeInformation":{"xmlns:xsd":"http://www.w3.org/2001/XMLSchema","xmlns":"http://www.docusign.net/API/3.0","TimeZone":"Pacific Standard Time","DocumentPDFs":{"DocumentPDF":[{"DocumentID":"1","DocumentType":"CONTENT","PDFBytes":"PDFCONTENT","Name":"Proposta.pdf"},{"DocumentType":"SUMMARY","PDFBytes":"PDFCONTENT","Name":"CertificateOfCompletion_93399ba5-cfec-41f2-9b5c-cabf20d7ba5d.pdf"}]},"EnvelopeStatus":{"Email":"iskander.bittencourt@portoseguro.com.br","AuthoritativeCopy":false,"ACHolderLocation":"DocuSign","ACStatusDate":"2020-11-17T11:45:18.863","SigningLocation":"Online","RecipientStatuses":{"RecipientStatus":{"Status":"Completed","Email":"iskander.bittencourt@globant.com","UserName":"Iskander Bittencourt","RecipientId":"0575d25c-9659-40dc-a57e-f68c5b634ca5","Delivered":"2020-11-17T11:46:10.633","Signed":"2020-11-17T11:46:14.07","TabStatuses":{"TabStatus":{"Status":"Signed","TabType":"SignHere","XPosition":"852","YPosition":"319","PageNumber":"1","DocumentID":"1","TabLabel":"Signature 1_SignHere_c6a19b27-aa82-48b1-9593-64957854c267_0575d25c-9659-40dc-a57e-f68c5b634ca5","TabName":""}},"AccountStatus":"Active","Type":"Signer","CustomFields":"","RecipientIPAddress":"179.153.91.8","RoutingOrder":"1","DeclineReason":{"xsi:nil":true},"Sent":"2020-11-17T11:45:19.487"}},"Created":"2020-11-17T11:45:18.863","ACHolderEmail":"iskander.bittencourt@portoseguro.com.br","DocumentStatuses":{"DocumentStatus":{"TemplateName":"","ID":"1","Sequence":"1","Name":"Proposta.pdf"}},"ACStatus":"Original","Sent":"2020-11-17T11:45:19.52","Status":"Completed","EnvelopeIdStamping":true,"TimeGenerated":"2020-11-17T11:46:36.7063322","UserName":"Iskander Bittentcourt","EnvelopeID":"93399ba5-cfec-41f2-9b5c-cabf20d7ba5d","Delivered":"2020-11-17T11:46:10.883","Signed":"2020-11-17T11:46:14.07","Subject":"Assinatura da proposta - Seguro de Vida","SenderIPAddress":"54.204.253.56","EnvelopePDFHash":"","AutoNavigation":true,"CustomFields":{"CustomField":[{"Required":false,"Value":"4490906","Show":false,"CustomFieldType":"Text","Name":"AccountId"},{"Required":false,"Value":"Porto Seguro","Show":false,"CustomFieldType":"Text","Name":"AccountName"},{"Required":false,"Value":"demo","Show":false,"CustomFieldType":"Text","Name":"AccountSite"}]},"ACHolder":"Iskander Bittentcourt","Completed":"2020-11-17T11:46:14.07"},"xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance","TimeZoneOffset":"-8"}}';

        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/caso/salvarRecusaSinistroDocusign';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonStr);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    RecusaDocusignRest.doSalvarDadosRecusaSinistro();
        Test.stopTest();
        
        RecusaDocusignRest.Response respBody = (RecusaDocusignRest.Response) JSON.deserialize(
            res.responseBody.toString(), RecusaDocusignRest.Response.class
        ); 

        System.debug('response => ' + respBody);
        
		System.assertEquals('Sucesso', respBody.mensagem);
		System.assertEquals('OK', respBody.status);
        System.assertEquals(200, res.statusCode);
    }

    @isTest
    static void testSaveRecusaSinistroSemId() {
        String jsonStr = '{"DocuSignEnvelopeInformation":{"xmlns:xsd":"http://www.w3.org/2001/XMLSchema","xmlns":"http://www.docusign.net/API/3.0","TimeZone":"Pacific Standard Time","DocumentPDFs":{"DocumentPDF":[{"DocumentID":"1","DocumentType":"CONTENT","PDFBytes":"PDFCONTENT","Name":"Proposta.pdf"},{"DocumentType":"SUMMARY","PDFBytes":"PDFCONTENT","Name":"CertificateOfCompletion_93399ba5-cfec-41f2-9b5c-cabf20d7ba5d.pdf"}]},"EnvelopeStatus":{"Email":"iskander.bittencourt@portoseguro.com.br","AuthoritativeCopy":false,"ACHolderLocation":"DocuSign","ACStatusDate":"2020-11-17T11:45:18.863","SigningLocation":"Online","RecipientStatuses":{"RecipientStatus":{"Status":"Completed","Email":"iskander.bittencourt@globant.com","UserName":"Iskander Bittencourt","RecipientId":"0575d25c-9659-40dc-a57e-f68c5b634ca5","Delivered":"2020-11-17T11:46:10.633","Signed":"2020-11-17T11:46:14.07","TabStatuses":{"TabStatus":{"Status":"Signed","TabType":"SignHere","XPosition":"852","YPosition":"319","PageNumber":"1","DocumentID":"1","TabLabel":"Signature 1_SignHere_c6a19b27-aa82-48b1-9593-64957854c267_0575d25c-9659-40dc-a57e-f68c5b634ca5","TabName":""}},"AccountStatus":"Active","Type":"Signer","CustomFields":"","RecipientIPAddress":"179.153.91.8","RoutingOrder":"1","DeclineReason":{"xsi:nil":true},"Sent":"2020-11-17T11:45:19.487"}},"Created":"2020-11-17T11:45:18.863","ACHolderEmail":"iskander.bittencourt@portoseguro.com.br","DocumentStatuses":{"DocumentStatus":{"TemplateName":"","ID":"1","Sequence":"1","Name":"Proposta.pdf"}},"ACStatus":"Original","Sent":"2020-11-17T11:45:19.52","Status":"Completed","EnvelopeIdStamping":true,"TimeGenerated":"2020-11-17T11:46:36.7063322","UserName":"Iskander Bittentcourt","EnvelopeID":"93399ba5-cfec-41f2-9b5c-cabf20d7ba5d","Delivered":"2020-11-17T11:46:10.883","Signed":"2020-11-17T11:46:14.07","Subject":"Assinatura da proposta - Seguro de Vida","SenderIPAddress":"54.204.253.56","EnvelopePDFHash":"","AutoNavigation":true,"CustomFields":{"CustomField":[{"Required":false,"Value":"4490906","Show":false,"CustomFieldType":"Text","Name":"AccountId"},{"Required":false,"Value":"Porto Seguro","Show":false,"CustomFieldType":"Text","Name":"AccountName"},{"Required":false,"Value":"demo","Show":false,"CustomFieldType":"Text","Name":"AccountSite"}]},"ACHolder":"Iskander Bittentcourt","Completed":"2020-11-17T11:46:14.07"},"xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance","TimeZoneOffset":"-8"}}';

        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/caso/salvarRecusaSinistroDocusign';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonStr);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    RecusaDocusignRest.doSalvarDadosRecusaSinistro();
        Test.stopTest();
        
        RecusaDocusignRest.Response respBody = (RecusaDocusignRest.Response) JSON.deserialize(
            res.responseBody.toString(), RecusaDocusignRest.Response.class
        ); 

        System.debug('response => ' + respBody);
        
		System.assertEquals('O atributo "id_salesforce" é obrigatório.', respBody.mensagem);
		System.assertEquals('OK', respBody.status);
        System.assertEquals(200, res.statusCode);
    }

    @isTest
    static void testSaveRecusaSinistroSemAtributos() {
        Case sinistro = [SELECT ID FROM CASE WHERE RECORDTYPE.DEVELOPERNAME = 'Sinistro' LIMIT 1];
        String jsonStr = '{"id_salesforce":"' + sinistro.Id + '","X_DocuSignEnvelopeInformation":{"xmlns:xsd":"http://www.w3.org/2001/XMLSchema","xmlns":"http://www.docusign.net/API/3.0","TimeZone":"Pacific Standard Time","DocumentPDFs":{"DocumentPDF":[{"DocumentID":"1","DocumentType":"CONTENT","PDFBytes":"PDFCONTENT","Name":"Proposta.pdf"},{"DocumentType":"SUMMARY","PDFBytes":"PDFCONTENT","Name":"CertificateOfCompletion_93399ba5-cfec-41f2-9b5c-cabf20d7ba5d.pdf"}]},"EnvelopeStatus":{"Email":"iskander.bittencourt@portoseguro.com.br","AuthoritativeCopy":false,"ACHolderLocation":"DocuSign","ACStatusDate":"2020-11-17T11:45:18.863","SigningLocation":"Online","RecipientStatuses":{"RecipientStatus":{"Status":"Completed","Email":"iskander.bittencourt@globant.com","UserName":"Iskander Bittencourt","RecipientId":"0575d25c-9659-40dc-a57e-f68c5b634ca5","Delivered":"2020-11-17T11:46:10.633","Signed":"2020-11-17T11:46:14.07","TabStatuses":{"TabStatus":{"Status":"Signed","TabType":"SignHere","XPosition":"852","YPosition":"319","PageNumber":"1","DocumentID":"1","TabLabel":"Signature 1_SignHere_c6a19b27-aa82-48b1-9593-64957854c267_0575d25c-9659-40dc-a57e-f68c5b634ca5","TabName":""}},"AccountStatus":"Active","Type":"Signer","CustomFields":"","RecipientIPAddress":"179.153.91.8","RoutingOrder":"1","DeclineReason":{"xsi:nil":true},"Sent":"2020-11-17T11:45:19.487"}},"Created":"2020-11-17T11:45:18.863","ACHolderEmail":"iskander.bittencourt@portoseguro.com.br","DocumentStatuses":{"DocumentStatus":{"TemplateName":"","ID":"1","Sequence":"1","Name":"Proposta.pdf"}},"ACStatus":"Original","Sent":"2020-11-17T11:45:19.52","Status":"Completed","EnvelopeIdStamping":true,"TimeGenerated":"2020-11-17T11:46:36.7063322","UserName":"Iskander Bittentcourt","EnvelopeID":"93399ba5-cfec-41f2-9b5c-cabf20d7ba5d","Delivered":"2020-11-17T11:46:10.883","Signed":"2020-11-17T11:46:14.07","Subject":"Assinatura da proposta - Seguro de Vida","SenderIPAddress":"54.204.253.56","EnvelopePDFHash":"","AutoNavigation":true,"CustomFields":{"CustomField":[{"Required":false,"Value":"4490906","Show":false,"CustomFieldType":"Text","Name":"AccountId"},{"Required":false,"Value":"Porto Seguro","Show":false,"CustomFieldType":"Text","Name":"AccountName"},{"Required":false,"Value":"demo","Show":false,"CustomFieldType":"Text","Name":"AccountSite"}]},"ACHolder":"Iskander Bittentcourt","Completed":"2020-11-17T11:46:14.07"},"xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance","TimeZoneOffset":"-8"}}';

        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/caso/salvarRecusaSinistroDocusign';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonStr);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    RecusaDocusignRest.doSalvarDadosRecusaSinistro();
        Test.stopTest();
        
        RecusaDocusignRest.Response respBody = (RecusaDocusignRest.Response) JSON.deserialize(
            res.responseBody.toString(), RecusaDocusignRest.Response.class
        ); 

        System.debug('response => ' + respBody);
        
		System.assertEquals('Os atributos "DocuSignEnvelopeInformation" e/ou "EnvelopeStatus" são obrigatórios.', respBody.mensagem);
		System.assertEquals('OK', respBody.status);
        System.assertEquals(200, res.statusCode);
    }

    @isTest
    static void testSaveRecusaSinistroException() {
        //Invalid SALESFORCE_ID exception
        String jsonStr = '{"id_salesforce":"123456789","DocuSignEnvelopeInformation":{"xmlns:xsd":"http://www.w3.org/2001/XMLSchema","xmlns":"http://www.docusign.net/API/3.0","TimeZone":"Pacific Standard Time","DocumentPDFs":{"DocumentPDF":[{"DocumentID":"1","DocumentType":"CONTENT","PDFBytes":"PDFCONTENT","Name":"Proposta.pdf"},{"DocumentType":"SUMMARY","PDFBytes":"PDFCONTENT","Name":"CertificateOfCompletion_93399ba5-cfec-41f2-9b5c-cabf20d7ba5d.pdf"}]},"EnvelopeStatus":{"Email":"iskander.bittencourt@portoseguro.com.br","AuthoritativeCopy":false,"ACHolderLocation":"DocuSign","ACStatusDate":"2020-11-17T11:45:18.863","SigningLocation":"Online","RecipientStatuses":{"RecipientStatus":{"Status":"Completed","Email":"iskander.bittencourt@globant.com","UserName":"Iskander Bittencourt","RecipientId":"0575d25c-9659-40dc-a57e-f68c5b634ca5","Delivered":"2020-11-17T11:46:10.633","Signed":"2020-11-17T11:46:14.07","TabStatuses":{"TabStatus":{"Status":"Signed","TabType":"SignHere","XPosition":"852","YPosition":"319","PageNumber":"1","DocumentID":"1","TabLabel":"Signature 1_SignHere_c6a19b27-aa82-48b1-9593-64957854c267_0575d25c-9659-40dc-a57e-f68c5b634ca5","TabName":""}},"AccountStatus":"Active","Type":"Signer","CustomFields":"","RecipientIPAddress":"179.153.91.8","RoutingOrder":"1","DeclineReason":{"xsi:nil":true},"Sent":"2020-11-17T11:45:19.487"}},"Created":"2020-11-17T11:45:18.863","ACHolderEmail":"iskander.bittencourt@portoseguro.com.br","DocumentStatuses":{"DocumentStatus":{"TemplateName":"","ID":"1","Sequence":"1","Name":"Proposta.pdf"}},"ACStatus":"Original","Sent":"2020-11-17T11:45:19.52","Status":"Completed","EnvelopeIdStamping":true,"TimeGenerated":"2020-11-17T11:46:36.7063322","UserName":"Iskander Bittentcourt","EnvelopeID":"93399ba5-cfec-41f2-9b5c-cabf20d7ba5d","Delivered":"2020-11-17T11:46:10.883","Signed":"2020-11-17T11:46:14.07","Subject":"Assinatura da proposta - Seguro de Vida","SenderIPAddress":"54.204.253.56","EnvelopePDFHash":"","AutoNavigation":true,"CustomFields":{"CustomField":[{"Required":false,"Value":"4490906","Show":false,"CustomFieldType":"Text","Name":"AccountId"},{"Required":false,"Value":"Porto Seguro","Show":false,"CustomFieldType":"Text","Name":"AccountName"},{"Required":false,"Value":"demo","Show":false,"CustomFieldType":"Text","Name":"AccountSite"}]},"ACHolder":"Iskander Bittentcourt","Completed":"2020-11-17T11:46:14.07"},"xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance","TimeZoneOffset":"-8"}}';

        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/caso/salvarRecusaSinistroDocusign';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonStr);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    RecusaDocusignRest.doSalvarDadosRecusaSinistro();
        Test.stopTest();
        
        RecusaDocusignRest.Response respBody = (RecusaDocusignRest.Response) JSON.deserialize(
            res.responseBody.toString(), RecusaDocusignRest.Response.class
        ); 

        System.debug('response => ' + respBody);

		System.assertEquals('FAIL', respBody.status);
        System.assertEquals(400, res.statusCode);
    }
    //PLV-4635 FIM
}