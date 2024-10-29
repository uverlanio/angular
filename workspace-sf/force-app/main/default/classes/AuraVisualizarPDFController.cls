public class AuraVisualizarPDFController {
    public AuraVisualizarPDFController() {}

    @AuraEnabled
    public static String getPropostaName(String recordId){
        return [SELECT Id, Name FROM Quote WHERE Id =: recordId].Name;
    }
}