public class DocumentDAO {
	private static final DocumentDAO instance = new DocumentDAO();
	public static DocumentDAO getInstance() {
		return instance;
	}

	private DocumentDAO() { }

	public List<ContentDocumentLink> buscarContentDocumentPorLinkedEntityId(Id linkedEntityId){
		return [Select 
					Id, 
					LinkedEntityId, 
					ContentDocumentId, 
					ShareType 
				From 
					ContentDocumentLink 
				Where 
					LinkedEntityId =: linkedEntityId
		];
	}

	public List<ContentVersion> buscarContentVersionPorContentDocumentId(Set<Id> contentDocumentIds){
		return [Select 
					Id, 
					Title, 
					PathOnClient, 
					VersionData, 
					IsMajorVersion 
				From 
					ContentVersion 
				Where 
					ContentDocumentId IN: contentDocumentIds
			];
	}

	public List<ContentVersion> buscarContentVersionPorId(Set<Id> contentVersionIds){
		return [Select 
					ContentDocumentId 
				From 
					ContentVersion 
				Where 
					Id IN: contentVersionIds];
	}

	public List<DocumentoProduto__c> buscarDocumentosProduto(Set<Id> produtosIds){
		return [SELECT 
					Id, 
					Produto__c, 
					Documento__c,
					Tipo__c 
				FROM 
					DocumentoProduto__c 
				WHERE 
					Produto__c IN :produtosIds];
	}
}