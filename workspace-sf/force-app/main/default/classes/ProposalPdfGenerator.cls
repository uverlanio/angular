/*
*  @author Joao Fabiano - SYS4B
*  @Descrição: Gerador de PDF da Proposta Individual - Usando informações do objeto Contract
*/
public with sharing class ProposalPdfGenerator {

    @InvocableMethod
    public static void gerarPDFPropostaSync(List<Id> contractIdList){
    System.debug('GERAR PDF PROPOSTA - ATRAVÉS DE CONTRATO (2024)');

    List<Contract> contractList = [SELECT Id, Name, Segmento__c, NumeroPropostaUnico__c FROM Contract WHERE Id IN: contractIdList AND Segmento__c != 'Viagem'];

    try{
        Map<Id, ContentVersion> mapContentVersion = new Map<Id, ContentVersion>();
        List<ContentDocumentLink> listContentDocumentLink = new List<ContentDocumentLink>();
        for(Contract contract : contractList){
            // Criar um novo
            PageReference pdf = Page.GeraPropostaPorContrato;
            pdf.getParameters().put('numContract', contract.NumeroPropostaUnico__c);
            pdf.setRedirect(true);

            ContentVersion file = new ContentVersion(
                Title = 'Proposta_' + (contract.NumeroPropostaUnico__c).replace('-','_'),
                VersionData = Test.IsRunningTest() ? Blob.valueOf('TEST') : pdf.getContentAsPDF(),
                PathOnClient = 'Proposta_' + (contract.NumeroPropostaUnico__c).replace('-','_') + '.pdf',
                origin = 'H'
            );

            mapContentVersion.put(contract.Id, file);
        }

        insert mapContentVersion.values();
        //ok acima 1

        Map<Id, ContentVersion> mContentVersionInserted = new Map<Id, ContentVersion>(
            [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id IN :mapContentVersion.values()]
        );
        List<ContentDocumentLink> lContentDocumentLink = new List<ContentDocumentLink>();
        
        List<ControleIntegracao__c> listCI = new List<ControleIntegracao__c>();
        for(Contract contract : contractList){
            ContentDocumentLink fileLink = new ContentDocumentLink(
                    LinkedEntityId = contract.Id,
                    ContentDocumentId = mContentVersionInserted.get(mapContentVersion.get(contract.Id).Id).ContentDocumentId,
                    ShareType = 'V'
                );
            listContentDocumentLink.add(fileLink);

            ControleIntegracao__c controleIntegracao = new ControleIntegracao__c(
                IdObjeto__c = contract.Id+'_'+mContentVersionInserted.get(mapContentVersion.get(contract.Id).Id).Id,
                Status__c = 'Pendente',
                DataCriacaoRegistro__c = Date.today(),
                CodigoIntegracao__c = '85',

                Objeto__c = 'Contract',

                Pasta_ECM__c = 'Enterprise:Corporativo:Vida:Proposta Seguro Novo'

            );

            listCI.add(controleIntegracao);
        }

        insert listContentDocumentLink;
        insert listCI;

        // ok acima 2 - com ressalvas na linha 59


        List<ContentVersion> lContentVersion = mContentVersionInserted.values();

        List<ContentDistribution> lContentDistribution2Insert = new List<ContentDistribution>();
          
        for(ContentVersion cvv: lContentVersion){	
            ContentDistribution cd = new ContentDistribution (
                Name = cvv.Title,
                ContentVersionId = cvv.id, 
                PreferencesPasswordRequired = true
            );
            lContentDistribution2Insert.add(cd);
        }
        insert lContentDistribution2Insert;

        // ok acima 3

        List <ContentDocumentLink> mContentDocumentLink = new List <ContentDocumentLink>([select LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId in: (contractIdList)]); 
        Map <ID, ID> mContractContent = new Map<ID,ID>();
        List<string> lcontentDocument = new List<string>();
        for(ContentDocumentLink obj : mContentDocumentLink){
        
            mContractContent.put(obj.ContentDocumentId,obj.LinkedEntityId);
            lcontentDocument.add(obj.ContentDocumentId);
        }

        Map <ID,ContentDistribution> lContentDistribution = new map<ID,ContentDistribution>([select ContentDocumentId,ContentVersionId, PdfDownloadUrl, Password, DistributionPublicUrl from ContentDistribution where ContentDocumentId in : (lcontentDocument) ]);
        Map <ID,String> contractURL = new map <ID,String>();
        Map<String,String> versionxContract = new Map<String,String>();
        map <ID,String> SenhaContent = new map <ID,String>();
        map <ID,String> DistributionPublicUrlContent = new map <ID,String>();
        String baseURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1].Endpoint;
        baseURL += [SELECT NomeCredencial__c,NomeToken__c,Endpoint__c,DeveloperName FROM Servico__mdt WHERE DeveloperName='Consultar_ArquivoSF' LIMIT 1].Endpoint__c;
        
        for(String key : mapContentVersion.keyset()){
            versionxContract.put((String)mapContentVersion.get(key).Id,key);
        }

        for(ID idkey : lContentDistribution.keyset()){

            if(mContractContent.containsKey(lContentDistribution.get(idkey).ContentDocumentId)){
                String token = Util.encryptDocPublicURL(versionxContract.get(lContentDistribution.get(idkey).ContentVersionId),
                mContentVersionInserted.get(lContentDistribution.get(idkey).ContentVersionId).Title+'.pdf');
                contractURL.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),token);
                 SenhaContent.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).Password);
                DistributionPublicUrlContent.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).DistributionPublicUrl);
             
            }
        }
        System.debug('>>1 contractURL ' + JSON.serialize(contractURL));
        System.debug('>>2 lContentDistribution ' + JSON.serialize(lContentDistribution));
        System.debug('>>3 mContractContent ' + JSON.serialize(mContractContent));
        System.debug('>>4 mapContentVersion ' + JSON.serialize(mapContentVersion));
        System.debug('>>4 lcontentDocument ' + JSON.serialize(lcontentDocument)); 

        }catch(Exception e){
            System.debug('gerarApoliceProposta ERROR ' + e.getMessage());
        }
    }
}