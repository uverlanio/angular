/**
 * @historia PLV-4635
 * @author Guilherme Azevedo
 * @version 1.0
*/
//PLV-4635 INICIO
@isTest
public class DocusignServiceEntityTest {

    static testMethod void entityParseTest() {
        String jsonStr = '{"id_salesforce":"500L000000GSJ2kIAH","DocuSignEnvelopeInformation":{"xmlns:xsd":"http://www.w3.org/2001/XMLSchema","xmlns":"http://www.docusign.net/API/3.0","TimeZone":"Pacific Standard Time","DocumentPDFs":{"DocumentPDF":[{"DocumentID":"1","DocumentType":"CONTENT","PDFBytes":"PDFCONTENT","Name":"Proposta.pdf"},{"DocumentType":"SUMMARY","PDFBytes":"PDFCONTENT","Name":"CertificateOfCompletion_93399ba5-cfec-41f2-9b5c-cabf20d7ba5d.pdf"}]},"EnvelopeStatus":{"Email":"iskander.bittencourt@portoseguro.com.br","AuthoritativeCopy":false,"ACHolderLocation":"DocuSign","ACStatusDate":"2020-11-17T11:45:18.863","SigningLocation":"Online","RecipientStatuses":{"RecipientStatus":{"Status":"Completed","Email":"iskander.bittencourt@globant.com","UserName":"Iskander Bittencourt","RecipientId":"0575d25c-9659-40dc-a57e-f68c5b634ca5","Delivered":"2020-11-17T11:46:10.633","Signed":"2020-11-17T11:46:14.07","TabStatuses":{"TabStatus":{"Status":"Signed","TabType":"SignHere","XPosition":"852","YPosition":"319","PageNumber":"1","DocumentID":"1","TabLabel":"Signature 1_SignHere_c6a19b27-aa82-48b1-9593-64957854c267_0575d25c-9659-40dc-a57e-f68c5b634ca5","TabName":""}},"AccountStatus":"Active","Type":"Signer","CustomFields":"","RecipientIPAddress":"179.153.91.8","RoutingOrder":"1","DeclineReason":{"xsi:nil":true},"Sent":"2020-11-17T11:45:19.487"}},"Created":"2020-11-17T11:45:18.863","ACHolderEmail":"iskander.bittencourt@portoseguro.com.br","DocumentStatuses":{"DocumentStatus":{"TemplateName":"","ID":"1","Sequence":"1","Name":"Proposta.pdf"}},"ACStatus":"Original","Sent":"2020-11-17T11:45:19.52","Status":"Completed","EnvelopeIdStamping":true,"TimeGenerated":"2020-11-17T11:46:36.7063322","UserName":"Iskander Bittentcourt","EnvelopeID":"93399ba5-cfec-41f2-9b5c-cabf20d7ba5d","Delivered":"2020-11-17T11:46:10.883","Signed":"2020-11-17T11:46:14.07","Subject":"Assinatura da proposta - Seguro de Vida","SenderIPAddress":"54.204.253.56","EnvelopePDFHash":"","AutoNavigation":true,"CustomFields":{"CustomField":[{"Required":false,"Value":"4490906","Show":false,"CustomFieldType":"Text","Name":"AccountId"},{"Required":false,"Value":"Porto Seguro","Show":false,"CustomFieldType":"Text","Name":"AccountName"},{"Required":false,"Value":"demo","Show":false,"CustomFieldType":"Text","Name":"AccountSite"}]},"ACHolder":"Iskander Bittentcourt","Completed":"2020-11-17T11:46:14.07"},"xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance","TimeZoneOffset":"-8"}}';

        Test.startTest();
        DocusignServiceEntity request = (DocusignServiceEntity) JSON.deserialize(jsonStr, DocusignServiceEntity.class);
        Test.stopTest();
    }
    //PLV-4635 FIM
}