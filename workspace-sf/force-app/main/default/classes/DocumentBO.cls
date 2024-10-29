public class DocumentBO {
	private static final DocumentBO instance = new DocumentBO();
	private static DocumentDAO dao = DocumentDAO.getInstance();

	public static DocumentBO getInstance() {
		return instance;
	}

	private DocumentBO() { }

	public List<ContentDocumentLink> buscarContentDocumentPorLinkedEntityId(Id linkedEntityId){
		return dao.buscarContentDocumentPorLinkedEntityId(linkedEntityId);
	}

	public List<ContentVersion> buscarContentVersionPorContentDocumentId(Set<Id> contentDocumentIds){
		return dao.buscarContentVersionPorContentDocumentId(contentDocumentIds);
	}

	public List<ContentVersion> buscarContentVersionPorId(Set<Id> contentVersionIds){
		return dao.buscarContentVersionPorId(contentVersionIds);
	}

	public List<DocumentoProduto__c> buscarDocumentosProduto(Set<Id> produtosIds){
		return dao.buscarDocumentosProduto(produtosIds);	
	}
}