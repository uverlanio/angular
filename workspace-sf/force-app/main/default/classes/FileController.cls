/*******************************************************************************************************************************
* Classe responsável por Criar arquivos e associá-los à um registro
* @author Isabela - Globant
* @Date 04/02/2020
* @ModifiedAt 05/02/2020
* Classe criada por conta da história PLV-2146
******************************************************************************************************************************/
public without sharing class FileController {
    //PLV-4891 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    @future
    public static void createTextFile(String fileName, String fileBody, String recordId, String extensao){
        createTextFileSync(fileName,fileBody,recordId,extensao);
    }

    public static Map<String,String> createTextFileSync(String fileName, String fileBody, String recordId, String extensao){
        Map<String,String> mapToReturn = new Map<String,String>();
        ContentVersion content = new ContentVersion();
        content.Title = fileName;
        content.PathOnClient = '/' + content.Title + extensao;
        Blob bodyBlob = Blob.valueOf(fileBody);
        content.VersionData = bodyBlob;
        content.origin = 'H';
        
        insert content;
        
        String contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: content.Id].ContentDocumentId;
        
        ContentDocumentLink arquivo = new ContentDocumentLink();
        arquivo.Visibility = 'AllUsers';
        arquivo.LinkedEntityId = recordId;
        arquivo.ContentDocumentId = contentDocId;
        arquivo.ShareType = 'V';
        
        insert arquivo;

        mapToReturn.put('contentId', content.id);
        mapToReturn.put('documentId', arquivo.id);
        return mapToReturn;
    }
    //PLV-4891 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

    //PLV-4393 - Início
    /*
    @future
    public static void deleteFile(String fileNameSearchString, List<Id> lstRecordId){

        List<Id> lstContentDocId = new List<Id>();

        for( ContentDocumentLink contentDocLink : [ SELECT  Id, LinkedEntityId, ContentDocumentId 
                                                    FROM    ContentDocumentLink 
                                                    WHERE   LinkedEntityId IN : lstRecordId ]){
            lstContentDocId.add(contentDocLink.ContentDocumentId);
        }
        

        ContentDocument[] lstContentDocument = [SELECT Id 
                                              	FROM 	ContentDocument 
                                              	WHERE   Id IN : lstContentDocId
                                                AND     Title LIKE : fileNameSearchString
                                        ];


        delete lstContentDocument;

    }
	*/
    //PLV-4393 - Fim
}