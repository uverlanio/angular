//PLV-4921 - INICIO
@isTest
public class DocumentBOTest {
    @testSetup
    private static void setup(){
        
        List<ContentVersion> content = new List<ContentVersion>();
        ContentVersion file = new ContentVersion(
            Title = 'Proposta',
            VersionData = Blob.valueOf('TEST'), 
            PathOnClient = 'Proposta' + '.pdf',
            origin = 'H'
        );
        insert file;
    }
    @isTest
    private static void buscarContentVersionPorContentDocumentId (){
        
        List<ContentVersion> content = new List<ContentVersion>();
        
        List<ContentVersion> contenttemp = [Select Id, ContentDocumentId, Title, PathOnClient, VersionData, IsMajorVersion From ContentVersion ];
        if(contenttemp.size() > 0) {
            content = DocumentBO.getInstance().buscarContentVersionPorContentDocumentId(new Set<Id>{contenttemp[0].ContentDocumentId});
        }
        System.assert(content.size() > 0);
        
    }
    @isTest
    private static void buscarContentVersionPorId (){
        
        List<ContentVersion> content = new List<ContentVersion>();
        
        List<ContentVersion> contenttemp = [Select Id, ContentDocumentId, Title, PathOnClient, VersionData, IsMajorVersion From ContentVersion ];
        if(contenttemp.size() > 0) {
            content = DocumentBO.getInstance().buscarContentVersionPorId(new Set<Id>{contenttemp[0].Id});
        }
        System.assert(content.size() > 0);
    }
}
//PLV-4921 - FIM