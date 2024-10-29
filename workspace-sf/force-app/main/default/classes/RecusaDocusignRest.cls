/** Classe responsável pelo serviço de atualização dos dados da recusa de sinistro
 * @historia PLV-4635
 * @author Guilherme Azevedo
 * @version 1.0
*/
//PLV-4635 INICIO
@RestResource(urlMapping='/caso/salvarRecusaSinistroDocusign')
global class RecusaDocusignRest {

    private static String validationMessage;

    //++++++++++++++++++++++++
    // HTTP METHODS
    //++++++++++++++++++++++++
    
    @HttpPost
    global static void doSalvarDadosRecusaSinistro() {
        Response res = new Response();

        try {
            
            System.debug('RecusaDocusignRest => requestBody => ' + RestContext.request.requestBody.toString());

            DocusignServiceEntity request = (DocusignServiceEntity) JSON.deserialize(RestContext.request.requestBody.toString(), DocusignServiceEntity.class);

            System.debug('RecusaDocusignRest => request => ' + JSON.serializePretty(request, true));

            if(isValid(request)) {
                saveSinistro(request);
            }

            res.doSucesso();

        } catch (Exception ex) {
            res.doBadRequest(ex);
        }
    }

    //++++++++++++++++++++++++
    // PRIVATE METHODS
    //++++++++++++++++++++++++

    private static void saveSinistro(DocusignServiceEntity request) {
        Case sinistro = new Case();

        sinistro.Id = request.id_salesforce;

        if (request.DocuSignEnvelopeInformation != null && request.DocuSignEnvelopeInformation.EnvelopeStatus != null) {

            DocusignServiceEntity.EnvelopeStatus envelopeStatus = request.DocuSignEnvelopeInformation.EnvelopeStatus;

            sinistro.EnvelopeIdDocusign__c = envelopeStatus.EnvelopeId;
            sinistro.EmailDocusign__c = envelopeStatus.Email;

            if (!String.isBlank(envelopeStatus.Delivered)) {
                String dataLeitura = envelopeStatus.Delivered.replace('T', ' ').replace('Z', '');
                sinistro.DiaHoraLeituraDocusign__c = Datetime.valueOf(dataLeitura);
            }    
        } 

        update sinistro;
    }

    private static Boolean isValid(DocusignServiceEntity request) {
        validationMessage = '';

        if (String.isBlank(request.id_salesforce)) {
            validationMessage = 'O atributo "id_salesforce" é obrigatório.';
        }
        else if (request.DocuSignEnvelopeInformation == null 
            || (request.DocuSignEnvelopeInformation != null && request.DocuSignEnvelopeInformation.EnvelopeStatus == null)) {
            validationMessage = 'Os atributos "DocuSignEnvelopeInformation" e/ou "EnvelopeStatus" são obrigatórios.';
        } 

        return String.isBlank(validationMessage);
    }

    //++++++++++++++++++++++++
    // INNER CLASSES
    //++++++++++++++++++++++++

    public class Response {
        public String status;
        public String mensagem;

        //++++++++++++++++++++++++
        // PUBLIC METHODS
        //++++++++++++++++++++++++ 

        public void doBadRequest(Exception ex) {
            System.debug('RecusaDocusignRest >> doBadRequest >> Exception : ' + ex.getMessage() + ', ' + ex.getStackTraceString()); 
            status = 'FAIL';
            mensagem = 'Erro ao processar a request = Mensagem : ' + ex.getMessage() + ', Linha : ' + ex.getLineNumber() + ', Trace : ' + ex.getStackTraceString();
            setResponse(getJSON(), 400);
        } 
    
        public void doSucesso() {
            status = 'OK';
            mensagem = !String.isBlank(validationMessage) ? validationMessage : 'Sucesso';
            setResponse(getJSON(), 200);
        }
    
        //++++++++++++++++++++++++
        // PRIVATE METHODS
        //++++++++++++++++++++++++

        private void setResponse(Blob respondeBody, Integer statusCode) {
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = respondeBody;
            RestContext.response.statusCode = statusCode;
        }
    
        private Blob getJSON() {
            return Blob.valueOf(JSON.serializePretty(this, true));
        }
    }
    //PLV-4635 FIM
}