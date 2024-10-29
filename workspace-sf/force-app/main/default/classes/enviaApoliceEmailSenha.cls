public with sharing class enviaApoliceEmailSenha {
 

     @AuraEnabled
     public static List<ContentDistribution> enviaApolice(String recordId){
        ContentDocumentLink  conteudo = [Select Id, ContentDocument.CreatedDate, 
                ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.FileType  from ContentDocumentLink 
        where LinkedEntityId =: recordId];

        List<ContentDistribution>  linkexterno = new List<ContentDistribution>();
        linkexterno =[SELECT Name, CreatedDate, DistributionPublicUrl,PreferencesLinkLatestVersion,PdfDownloadUrl,Password, ExpiryDate FROM ContentDistribution where Name=: conteudo.ContentDocument.Title  Order By CreatedDate Desc Limit 1] ;

        System.debug('linkexterno.DistributionPublicUrl: '+ linkexterno[0].DistributionPublicUrl + ' Name:'+ linkexterno[0].Name); 
     
       return  linkexterno;
    }

    
    
}