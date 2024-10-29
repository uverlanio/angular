/****************************************************************************************************************************
 * Classe de Negocio implementada para o processo automático de gravar o arquivo de local Storage do orçamento original     *
 * no orçamento novo da renovação                                                                                           *
 * @author : Globant                                                                                                        *
 * @date 05/10/2022                                                                                                         *
 * Classe implementada tendo como origem a história RVI-189                                                                 *
 * Disparada através do Flow 'Gravar Arquivo LocalStorage Renovacao	'                                                       *
 * **************************************************************************************************************************/


public with sharing class SetLocalStorageOpptRenovacao {
    public static String itemFileName {get;set;}
    public static String itemRecordId {get;set;}
    
    public class FlowInputs {
        @InvocableVariable public String contratoRenovado ;
    }
    @invocableMethod
    public static void SetLocalStorageOpptRenovacao(List<FlowInputs> request) {
        String searchString = '%_localStorage';
        if(request[0].contratoRenovado <> null){
            Contract contratoOriginal = [SELECT Id, Proposta__r.Opportunity.Id 
                                        FROM Contract 
                                        WHERE Id =: request[0].contratoRenovado LIMIT 1 ];
        
            Contract contratoNovo;                            
            if(!Test.isRunningTest()){
                contratoNovo = [SELECT Id,
                Proposta__r.Opportunity.Id, Proposta__r.Opportunity.Name 
                FROM Contract 
                WHERE ContratoRenovado__c =: request[0].contratoRenovado LIMIT 1 ];
        
                itemFileName = contratoNovo.Proposta__r.Opportunity.Name;
                itemRecordId = contratoNovo.Proposta__r.Opportunity.id;
            }
            //Buscando o arquivo de localStorage do orçamento original
            List<ContentDocumentLink> lstcontentDocumentLink = [
                SELECT 	Id, LinkedEntityId, ContentDocumentId 
                FROM 	ContentDocumentLink 
                WHERE 	LinkedEntityId IN (:contratoOriginal.Proposta__r.Opportunity.id)
            ];

            List<Id> lstContentDocId = new List<Id>();
        
            for(ContentDocumentLink contentDocLink : lstcontentDocumentLink) {
                lstContentDocId.add(contentDocLink.ContentDocumentId);  
            }
        
            ContentVersion lstContentVersion = new ContentVersion();
        
            lstContentVersion = [SELECT Id, ContentDocumentId, IsLatest, VersionData, Title, PathOnClient 
                                FROM 	ContentVersion 
                                WHERE 	ContentDocumentId IN : lstContentDocId
                                AND 	Title LIKE : searchString
                                AND 	IsLatest = TRUE
                                ORDER BY LastModifiedDate DESC 
                                LIMIT 	1];
        
            //Montando a gravação do arquivo
            CreateFileREST.FileToInsert item = new CreateFileREST.FileToInsert();
            
            if(itemFileName <> null && itemRecordId <> null){
                item.fileName = itemFileName + '_' + Datetime.now().format('dd-MM-yyyy_HH:mm:ss') + '_localStorage';
                item.fileBody = lstContentVersion.VersionData.toString();
                item.recordId = itemRecordId;
                item.extensao = '.min.json';
                //Gravando arquivo
                FileController.createTextFileSync(item.fileName, JSON.serialize(item.fileBody), item.recordId, item.extensao); //RVI-189 FIX-01
            }
        }
    }
}