/*
*  @author Joao Fabiano - SYS4B
*  @Descrição: Gerador de PDF do Voucher do Seguro - Usando informações do objeto Contract.
*/
//ZSVEP-41-INICIO
public with sharing class VoucherPdfGenerator { //ProposalPdfGenerator
    private static final VoucherPdfGenerator instance = new VoucherPdfGenerator();
    
    public static VoucherPdfGenerator getInstance(){
        return instance;
    }

    public void criarVoucher(List<Contract> contractListParameter) {

        System.debug('XXX - contractListParameter' + JSON.serialize(contractListParameter));
        
        List<Contract> contractList = new List<Contract>();
        Set<Id> productSetId = new Set<Id>();
        
        for (Contract contrato : contractListParameter) {
            // PLV-3186 INICIO
            // if (TriggerHelper.isChanged(contrato, 'Status') && contrato.Status == 'Disponível para contratação' && contrato.Tipo__c != 'Cancelamento') { //PLV-3872 - INICIO/FIM - Inibir geracao de documentos em caso de cancelamento unitario
                contractList.add(contrato);
                productSetId.add(contrato.Produto__c);
                System.debug('contractList' + contractList);
                System.debug('productSetId' + productSetId);

            // }
        }
        
        if (contractList.isEmpty()) return;
        
        Map<Id,Product2> mProduto = new Map<Id,Product2>(
            [SELECT Id, GerarVoucher__c FROM Product2 WHERE Id = :productSetId]
        );
        
        Set<Id> sContractId = new Set<Id>();
        
        for (Contract contrato : contractList) {
            
            System.debug('contrato.Produto__c =====' + contrato.Produto__c);
            if(!mProduto.isEmpty()){//FCVEP-29 - INICIO
                System.debug('mProduto.get(contrato.Produto__c).GerarVoucher__c =====' + mProduto.get(contrato.Produto__c).GerarVoucher__c);
                if (mProduto.containsKey(contrato.Produto__c) && mProduto.get(contrato.Produto__c).GerarVoucher__c) {
                    // PLV-3186 FIM
                    //CH-5031619 - INICIO
                    if(contrato.Segmento__c != 'VidaIndividual' && contrato.Segmento__c != 'Massificados'){
                        sContractId.add(contrato.Id);
                    }
                    //CH-5031619 - FIM
                }
            }//FCVEP-29 - FIM
        }
        System.debug('sContractId =====' + sContractId);
        if (sContractId.isEmpty()) return;
        
        if (System.isFuture() || System.isBatch() || System.isQueueable()) {
            criarVoucherSync(sContractId); 
        }
        else {
            criarVoucherAsync(sContractId);            
        }        
    }
    
    @future(callout=true)
    public static void criarVoucherAsync(Set<Id> psPropostaId) {        
        criarVoucherSync(psPropostaId);       
    }

    public static void criarVoucherSync(Set<Id> psPropostaId) {
            System.debug('psPropostaId' + psPropostaId);
        Map<Id,ContentVersion> mContentVersion = new Map<Id,ContentVersion>();
        
        //PLV-3601 - INICIO
        Map<Id,Contract> mapContract = new Map<Id,Contract>();
        List<Contract> listContract = [SELECT Id, NumeroProposta__c, Origem__c, Produto__r.GerarVoucher__c FROM Contract WHERE id IN:(psPropostaId)]; //PLV - 4440  INICIO/FIM adcionado gerarvouchers na query
        //PLV - 4440  INICIO Ajuste gerarVoucher produto
        Boolean nGerarVoucher = true;
        for(Contract pContract : listContract){
            mapContract.put(pContract.Id,pContract);
            if(!pContract.Produto__r.GerarVoucher__c){
                nGerarVoucher = false;
                break;
            }
        } 
        if(!nGerarVoucher)return;
        //PLV - 4440  FIM Ajuste gerarVoucher produto
        //PLV-3601 - FIM
        
        for (Id propostaId : psPropostaId) {
            
            PageReference pdf = Page.VoucherContractPage;
            Map<String,String> mPDFParam = pdf.getParameters();
            mPDFParam.put('propostaId', propostaId);
            mPDFParam.put('renderAs', 'pdf');
            //PLV-3601 - INICIO
            string nomeVoucher;
            nomeVoucher = mapContract.get(propostaId).Origem__c+'_'+mapContract.get(propostaId).NumeroProposta__c;
            ContentVersion file = new ContentVersion(
                Title = 'Voucher_'+nomeVoucher,
                VersionData = Test.IsRunningTest() ? Blob.valueOf('TEST') : pdf.getContentAsPDF(),
                PathOnClient ='/voucher.pdf',
                origin = 'H'
            );
            //PLV-3601 - FIM
            
            mContentVersion.put(propostaId, file);
        }
        
        if (mContentVersion.isEmpty()) return;
        
        insert mContentVersion.values();
        //PLV-3601 - INICIO
        Map<Id, ContentVersion> mContentVersionInserted = new Map<Id, ContentVersion>(
            [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id IN :mContentVersion.values()]
        );
        //PLV-3601 - FIM
        List<ContentDocumentLink> lContentDocumentLink = new List<ContentDocumentLink>();
        //PLV3601 - INICIO
        List<ControleIntegracao__c>lControleIntegracao = new list<ControleIntegracao__c>();
        //PLV3601 - FIM
        for (Id propostaId : psPropostaId) {
            
            ContentDocumentLink fileLink = new ContentDocumentLink(
                LinkedEntityId = propostaId,
                ContentDocumentId = mContentVersionInserted.get(mContentVersion.get(propostaId).Id).ContentDocumentId,
                ShareType = 'V'
            );
            
            lContentDocumentLink.add(fileLink);
            //PLV-3601 - INICIO
            ControleIntegracao__c controleIntegracao = new ControleIntegracao__c(
                IdObjeto__c = propostaId+'_'+mContentVersionInserted.get(mContentVersion.get(propostaId).Id).Id,
                Status__c = 'Pendente',
                DataCriacaoRegistro__c = Date.today(),
                CodigoIntegracao__c = '85',
                // PLV - 4599 - INICIO - HENRIQUE R. META
                Objeto__c = 'Contract',
                // PLV - 4599 - FIM - HENRIQUE R. META]
                // PLV - 4599 FIX - INICIO - HENRIQUE R. META
                Pasta_ECM__c = 'Enterprise:Corporativo:Vida:Voucher Viagem'
                // PLV - 4599 FIX - FIM - HENRIQUE R. META
            );
            lControleIntegracao.add(controleIntegracao);
            //PLV-3601 - FIM
        }
        
        insert lContentDocumentLink; 
        
        //PLV-3601 - INICIO
        insert lControleIntegracao;
        //PLV-3601 - FIM
        
        //PLV-3395 - INICIO
        //PLV-3601 - INICIO (MELHORIA NESTE PROCESSO)
        //List<ContentVersion> lContentVersion = [SELECT Id,Title, ContentDocumentId FROM ContentVersion WHERE Id IN :mContentVersion.values()];
        List<ContentVersion> lContentVersion = mContentVersionInserted.values();
        //PLV-3601 - FIM
        // removido o campo VoucherPdfDownloadUrl__c do select abaixo - checar como ajustar
        List<Contract> contractList = [SELECT Id, Account.PersonEmail, Senha__c,  DistributionPublicUrl__c from Contract where id IN: psPropostaId]; // MGRC-505 INICIO/FIM
        List<Contract> q2update = new List<Contract>();
        List<ContentDistribution> lContentDistribution2Insert = new List<ContentDistribution>();
        system.debug('contentversion: ' + lcontentversion);
        system.Debug('contract: ' + contractList);
        
        
        for(ContentVersion cvv: lContentVersion){	
            ContentDistribution cd = new ContentDistribution (
                Name = cvv.Title,
                ContentVersionId = cvv.id,
                PreferencesPasswordRequired = true  // MGRC-505 INICIO/FIM
            );
            lContentDistribution2Insert.add(cd);
            
            system.debug('cd: '+cd);
        }
        //Ponto de atençao
        // QuoteTriggerHandler.sendEmailVou = true; // MGRC-505-FIX INICIO/FIM
        insert lContentDistribution2Insert;
        
        
        List <ContentDocumentLink> mContentDocumentLink = new List <ContentDocumentLink>([select LinkedEntityId,ContentDocumentId 
                                                                                        from ContentDocumentLink 
                                                                                        where LinkedEntityId in: (psPropostaId)]); 
        Map <ID, ID> mContractContent = new Map<ID,ID>();
        List<string> lcontentDocument = new List<string>();
        for(ContentDocumentLink obj : mContentDocumentLink){
            
            mContractContent.put(obj.ContentDocumentId,obj.LinkedEntityId);
            lcontentDocument.add(obj.ContentDocumentId);
        }
        Map <ID,ContentDistribution> lContentDistribution = new map<ID,ContentDistribution>([select ContentDocumentId,ContentVersionId, PdfDownloadUrl, Password, DistributionPublicUrl from ContentDistribution where ContentDocumentId in : (lcontentDocument) ]); // MGRC-505 INICIO/FIM
        system.debug('map contrato + id documento'+mContractContent);
        system.debug('ID contentDoc'+lcontentDocument);
        system.debug('link para contrato' + lContentDistribution);
        map <ID,String> contractURL = new map <ID,String>();
        map <ID,String> contractSenha = new map <ID,String>(); // MGRC-505 INICIO/FIM
        map <ID,String> contractDistributionPublicUrl = new map <ID,String>(); // MGRC-505 INICIO/FIM
        //PLV-3744 - INICIO
        Map<String,String> versionxProposta = new Map<String,String>();
        String baseURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1].Endpoint;
        baseURL += [SELECT NomeCredencial__c,NomeToken__c,Endpoint__c,DeveloperName FROM Servico__mdt WHERE DeveloperName='Consultar_ArquivoSF' LIMIT 1].Endpoint__c;
        
        for(String key : mContentVersion.keyset()){
            versionxProposta.put((String)mContentVersion.get(key).Id,key);
        }
        //PLV-3744 - FIM
        system.debug('TESTE QUEBRA'+mContentVersionInserted);
        for(ID idkey : lContentDistribution.keyset()){
            if(mContractContent.containsKey(lContentDistribution.get(idkey).ContentDocumentId) && 
            mContentVersionInserted.containsKey(lContentDistribution.get(idkey).ContentVersionId)){ //PLV-4803 - FIX - INICIO/FIM
                //PLV-3744 - INICIO
                
                /*system.debug('encontrou contrato ID Contrato'+mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId));  
                contractURL.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).PdfDownloadUrl);*/
                system.debug('>>> '+idKey);
                system.debug('>>>2 '+versionxProposta.get(lContentDistribution.get(idkey).ContentVersionId));
                system.debug('>>>2 '+lContentDistribution.get(idkey).ContentVersionId);
                //system.debug('>>>3 '+mContentVersionInserted.get(lContentDistribution.get(idkey).ContentVersionId).Title);
                String token = Util.encryptDocPublicURL(versionxProposta.get(lContentDistribution.get(idkey).ContentVersionId),
                                                        mContentVersionInserted.get(lContentDistribution.get(idkey).ContentVersionId).Title+'.pdf');
                system.debug('>>>4 '+token);
                contractURL.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),token);
                //PLV-3744 - FIM
                contractSenha.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).Password); // MGRC-505 INICIO/FIM
                contractDistributionPublicUrl.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).DistributionPublicUrl); // MGRC-505 INICIO/FIM
            }
            system.debug('DocumentoID' + lContentDistribution.get(idkey).ContentDocumentId);
        }
        system.debug('URL COM ID DO CONTRATO'+contractURL);
        
        for(Contract prop: contractList){
            if(contractURL.containsKey(prop.Id))
                system.debug('contrato:' + prop.Id);
            //PLV-3744 - INICIO
            // Checar esse campo
            // prop.VoucherPdfDownloadUrl__c = baseURL + contractURL.get(prop.Id);
            //PLV-3744 - FIM
            prop.Senha__c = contractSenha.get(prop.Id); // MGRC-505 INICIO/FIM
            prop.DistributionPublicUrl__c = contractDistributionPublicUrl.get(prop.Id); // MGRC-505 INICIO/FIM
            if(prop.Account.PersonEmail != null)
                prop.email__c = prop.Account.PersonEmail;
            q2update.add(prop);
        }
        update(q2update);
        system.debug('c2update: '+q2update);
    
        
        //PLV -3305 - FIM
    }
}
//ZSVEP-41-FIM