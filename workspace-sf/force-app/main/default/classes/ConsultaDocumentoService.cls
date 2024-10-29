/*******************************************************************************************************************************
* Consulta documento
* @author Carlos - Meta
* @date 05/04/2021
* Classe criada por conta da história PLV-4891
******************************************************************************************************************************/
public with sharing class ConsultaDocumentoService {

    private ConsultaDocumentoREST.ConsultaParam param;

    //PLV-5147 - INICIO
    private final List<String> tipoContrato = new List<String> {'Endosso','Renovacao','Cancelamento'}; //RVI-189 - INICIO/FIM
    private final String sufixoPadrao = '_localStorage';
    private final String sufixoEndosso = '_retornoServico';
    private final String sufixoRenovacao = '_entradaServico'; //PLV-5801 INICIO/FIM
    //PLV-5147 - FIM

    public ConsultaDocumentoService(ConsultaDocumentoREST.ConsultaParam param) {
        this.param = param;
    }

    public ConsultaDocumentoREST.DataTO consultar(){

        //PLV-5147 - INICIO        	
        System.debug('Y@ BUSCANDO DOCUMENTO ORCAMENTO ' + this.param);
        //PLV-5883 INICIO
        if(this.param.orcamento == null) {
            return null;
        }
        //PLV-5883 FIM
        Opportunity orcamento = [
            SELECT  Id, Type 
            FROM    Opportunity 
            WHERE   Numero__c = : this.param.orcamento 
            LIMIT   1];

        List<ContentDocumentLink> lstcontentDocumentLink = [
            SELECT 	Id, LinkedEntityId, ContentDocumentId 
            FROM 	ContentDocumentLink 
            WHERE 	LinkedEntityId IN (:orcamento.id)
        ];
        System.debug('lstcontentDocumentLink>> ' + JSON.serialize(lstcontentDocumentLink));
        
        List<Id> lstContentDocId = new List<Id>();
        for(ContentDocumentLink contentDocLink : lstcontentDocumentLink) {
            lstContentDocId.add(contentDocLink.ContentDocumentId);  
        }

        if( lstContentDocId.isEmpty() ) {
            return null;
        }

        System.debug('Y@ ENCONTROU DOCUMENTO');
        
        String searchString = '%' + (tipoContrato.contains(orcamento.Type)? sufixoEndosso : sufixoPadrao); //RVI-189 - INICIO/FIM
        System.debug('Daanilo: ' + searchString);
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        lstContentVersion = [	SELECT 	Id, ContentDocumentId, IsLatest, VersionData, Title, PathOnClient 
                                FROM 	ContentVersion 
                                WHERE 	ContentDocumentId IN : lstContentDocId
                                AND 	Title LIKE : searchString
                                AND 	IsLatest = TRUE
                                ORDER BY LastModifiedDate DESC 
                                LIMIT 	1];
        System.debug('lstContentVersion>> ' + JSON.serialize(lstContentVersion));
        if(lstContentVersion.size() == 0) {
            return null;
        }
            
        String localStorage = lstContentVersion[0].VersionData.toString();
        Map<String, Object> mapLG = (Map<String, Object>) JSON.deserializeUntyped(localStorage);
        
        ConsultaDocumentoREST.DataTO retorno = new ConsultaDocumentoREST.DataTO();
        retorno.ofertaPadrao = JSON.serialize(mapLG.get('jsonResponseCalculo'));
        retorno.localstorage = localStorage;
        
        return retorno;
        //PLV-5147 - FIM

    } 

}