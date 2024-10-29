public class GerarApolicePDF{
    public static void criarApoliceASync(Set<Id> setIdsContrato){
        Map<Id, ContentVersion> mapContentVersion = new Map<Id, ContentVersion>();        
        Map<Id, Contract> mapContract = new Map<Id, Contract>();

        List<Contract> listContract = [SELECT Id, Name, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c, Produto__c, Produto__r.Segmento__c, Senha__c, DistributionPublicUrl__c FROM Contract WHERE id = :setIdsContrato]; // MGRC-505 INICIO/FIM

        for(Contract pcontract : listContract){
            mapContract.put(pcontract.Id,pcontract);
        }

        for (Id contratoId : setIdsContrato){
            PageReference pdf = null;
            String title = null;

            if(mapContract.get(contratoId).Produto__c != null && mapContract.get(contratoId).Produto__r.Segmento__c == 'Individual'){
                 /*pdf = Page.ApoliceVidaIndividual;
                pdf.getParameters().put('nomeContract', mapContract.get(contratoId).Name);
                title = 'Apolice_Individual_';*/
            }else{
                pdf = Page.ApolicePage;
                Map<String, String> mPDFParam = pdf.getParameters();
 
                mPDFParam.put('contratoId', contratoId);
                mPDFParam.put('renderAs', 'pdf');
                title = 'DEBUG_';
            }

            String nomeApolice;
            nomeApolice = mapContract.get(contratoId).Empresa__c+'_'+mapContract.get(contratoId).Sucursal__c+'_'+mapContract.get(contratoId).CodigoRamo__c+'_'+mapContract.get(contratoId).NumeroApolice__c+'_'+mapContract.get(contratoId).Endosso__c;
            System.debug('nomeApolice>> ' + nomeApolice);
            ContentVersion file = new ContentVersion(
                Title = title+nomeApolice,
                VersionData = Test.IsRunningTest() ? Blob.valueOf('TEST') : pdf.getContentAsPDF(), //!IMPORTANT
                PathOnClient ='/apolice.pdf',
                origin = 'H'
            );
            mapContentVersion.put(contratoId, file);
        }

        if (mapContentVersion.isEmpty()) return;
        
        insert mapContentVersion.values();
        system.debug('inseriu');
        Map<Id, ContentVersion> mapContentVersionInserted = new Map<Id, ContentVersion>(
            [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id = :mapContentVersion.values()]
        );
        
        List<ContentDocumentLink> listContentDocumentLink = new List<ContentDocumentLink>();
        List<ControleIntegracao__c> listControleIntegracao = new list<ControleIntegracao__c>();
        
        for (Id contratoId : setIdsContrato) {
            ContentDocumentLink fileLink = new ContentDocumentLink(
                LinkedEntityId = contratoId,
                ContentDocumentId = mapContentVersionInserted.get(mapContentVersion.get(contratoId).Id).ContentDocumentId,
                ShareType = 'V'
            );
            listContentDocumentLink.add(fileLink);

            ControleIntegracao__c controleIntegracao = new ControleIntegracao__c(
                IdObjeto__c = contratoId+'_'+mapContentVersionInserted.get(mapContentVersion.get(contratoId).Id).Id,
                Status__c = 'Pendente',
                DataCriacaoRegistro__c = Date.today(),
                CodigoIntegracao__c = '85',
                Objeto__c = 'Contract',
                Pasta_ECM__c = 'Enterprise:Corporativo:Vida:Contrato:Apolice'                
            );
            listControleIntegracao.add(controleIntegracao);
        }
        
        insert listContentDocumentLink;
        insert listControleIntegracao;
        
        List<ContentVersion> listContentVersion = mapContentVersionInserted.values();
        List<Contract> c = [SELECT Id, ApolicePdfDownloadUrl__c, Proposta__r.Account.PersonEmail, Senha__c, DistributionPublicUrl__c FROM Contract WHERE id = :setIdsContrato]; // MGRC-505 INICIO/FIM
        List<Contract> c2update = new List<Contract>();
        List<ContentDistribution> listContentDistribution = new List<ContentDistribution>();
        
        for(ContentVersion cv: listContentVersion){	
            ContentDistribution cd = new ContentDistribution (
                Name = cv.Title,
                ContentVersionId = cv.id
           //     PreferencesPasswordRequired = true  // MGRC-505 INICIO/FIM
            );
            listContentDistribution.add(cd);        
        }
        insert listContentDistribution;
        
        List <ContentDocumentLink> listDocumentLink = new List <ContentDocumentLink>([SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :setIdsContrato]); 
        Map<Id, Id> mapContractContent = new Map<Id, Id>();
        List<String> listContentDocument = new List<String>();

        for(ContentDocumentLink cdl : listDocumentLink){
            mapContractContent.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            listContentDocument.add(cdl.ContentDocumentId);
        }

        Map <Id, ContentDistribution> mapContentDistribution = new Map<Id, ContentDistribution>([SELECT ContentDocumentId, ContentVersionId, PdfDownloadUrl, Password, DistributionPublicUrl  FROM ContentDistribution WHERE ContentDocumentId = :listContentDocument]);
        Map <Id, String> contractURL = new map <Id, String>();
              
////////////////////////////////////////////////

        Map <String, String> versionxContract = new Map<String, String>();
      //  Map <ID,String> contractSenha = new map <ID,String>(); // MGRC-505 INICIO/FIM
     //   Map <ID,String> contractDistributionPublicUrl = new map <ID,String>(); // MGRC-505 INICIO/FIM
       
        String baseURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1].Endpoint;
        baseURL += [SELECT NomeCredencial__c, NomeToken__c, Endpoint__c, DeveloperName FROM Servico__mdt WHERE DeveloperName='Consultar_ArquivoSF' LIMIT 1].Endpoint__c;
        
        for(String key : mapContentVersion.keyset()){
            versionxContract.put((String)mapContentVersion.get(key).Id,key);
        }
        
        for(Id idkey : mapContentDistribution.keyset()){
            if(mapContractContent.containsKey(mapContentDistribution.get(idkey).ContentDocumentId)){
                String token = Util.encryptDocPublicURL(versionxContract.get(mapContentDistribution.get(idkey).ContentVersionId),
                mapContentVersionInserted.get(mapContentDistribution.get(idkey).ContentVersionId).Title+'.pdf');
                contractURL.put(mapContractContent.get(mapContentDistribution.get(idkey).ContentDocumentId),token);    
             //   contractSenha.put(mapContractContent.get(mapContentDistribution.get(idkey).ContentDocumentId),mapContractContent.get(mapContentDistribution.get(idkey).Password)); // MGRC-505 INICIO/FIM
             //   contractDistributionPublicUrl.put(mapContractContent.get(mapContentDistribution.get(idkey).ContentDocumentId),mapContractContent.get(mapContentDistribution.get(idkey).DistributionPublicUrl)); // MGRC-505 INICIO/FIM
                
          
            }
        }
        
        for(Contract contr: c){
            if(contractURL.containsKey(contr.Id)){
                contr.ApolicePdfDownloadUrl__c = baseURL + contractURL.get(contr.Id);
              //  contr.Senha__c = contractSenha.get(contr.Id); // MGRC-505 INICIO/FIM
              //  contr.DistributionPublicUrl__c = contractDistributionPublicUrl.get(contr.Id); // MGRC-505 INICIO/FIM
            }

            if(contr.Proposta__r.Account.PersonEmail != null){
                contr.email__c = contr.Proposta__r.Account.PersonEmail;
            }

            c2update.add(contr);
        }

        update(c2update);
    }
}