/**
 * @author Isabela (Globant) & Jeferson (Sys4B)
 * @date 2020-03-28
 * @description DocumentoEcmController
 * Classe criada por conta da história PLV-3413
 */
public class DocumentoEcmController {
    @TestVisible private static List<public_arquivoecm__x> mockedRequests = new List<public_arquivoecm__x>();
    public class BlobWrapper{
        @AuraEnabled public String Body;
        @AuraEnabled public String Type;
        @AuraEnabled public String Disposition;
        @AuraEnabled public String Error;
    }
	@AuraEnabled
    public static BlobWrapper getBase64Info(String idEcm){
        BlobWrapper response = new BlobWrapper();
        HttpResponse resposta = RestECM.buscarArquivoECM(idEcm);
        if(resposta != null){
            if(resposta.getStatusCode() == 200) {
                response.Disposition = resposta.getHeader('Content-Disposition');
                Blob valueBody = resposta.getBodyAsBlob();
                response.Body = EncodingUtil.base64Encode(valueBody);
                response.Type = resposta.getHeader('Content-Type');
            }
            else{
                response.Error = 'Arquivo não encontrado no ECM.';
            }
        }
        else{
            response.Error = 'Não foi possível realizar a conexão para a busca do arquivo. Entre em contato com o administrador.';
        }
        return response;
    }
	@AuraEnabled
    public static List<public_arquivoecm__x> consultarArquivoEcm(Id recordId){
        List<public_arquivoecm__x> arquivos = (!mockedRequests.isEmpty()) ? mockedRequests : [
            SELECT idsf__c, nomearquivo__c, idecm__c, status__c 
            FROM public_arquivoecm__x 
            WHERE idsf__c = :recordId AND status__c = 'CRIADO'
            ORDER BY nomearquivo__c];
        return arquivos;
    }
}