/**
    * AssisFuneralCtr
    * @author Matheus Meneses,Rogerio Menezes,Veronice Boesing,Romeu Bonfim@ 29/03/2023
    *
    **/
    public with sharing class AssisFuneralCtr {

        public AssisFuneralCtr() {
                
        }
    
        //II-21 INCIO
        public List<GarantiaProduto__c> getGarantiaProduto() {
            List<GarantiaProduto__c> garantiaProdutos = [SELECT Id, Garantia__c, Garantia__r.Sigla__c FROM GarantiaProduto__c WHERE Garantia__r.Sigla__c = 'AFE'];
            return garantiaProdutos;
        }
        //II-21 FIM
    
        public void insertGarantiaContratanteCtr(Set<Id> idContratos, Garantia__c afe, List<GarantiaProduto__c> garantiaProdutoList){ //II-21 INCIO-FIM
    
            List<GarantiaContratanteContrato__c> garantiaContratanteCtr = [SELECT Id, Garantia__r.Sigla__c, Garantia__r.Name, ContratanteContrato__r.Contrato__c,
                                                                               ContratanteContrato__c 
                                                                            FROM GarantiaContratanteContrato__c
                                                                            WHERE ContratanteContrato__r.Contrato__c IN: idContratos];
    
            Map<Id, List<GarantiaContratanteContrato__c>> assurancesIndexedByContract = new Map<Id, List<GarantiaContratanteContrato__c>>();
    
            for(GarantiaContratanteContrato__c gcc1 : garantiaContratanteCtr){
    
                if(!assurancesIndexedByContract.containsKey(gcc1.ContratanteContrato__r.Contrato__c)){
                    assurancesIndexedByContract.put(
                        gcc1.ContratanteContrato__r.Contrato__c,
                        new List<GarantiaContratanteContrato__c>()
                    );
                }
    
                assurancesIndexedByContract.get(gcc1.ContratanteContrato__r.Contrato__c).add(gcc1);
            }                                             
    
            for (Id contractId : assurancesIndexedByContract.keySet()) {
                
                List<GarantiaContratanteContrato__c> garantiasContratanteCtr = assurancesIndexedByContract.get(contractId);
                List<GarantiaContratanteContrato__c> garantiasContratanteCtrAtualizadas = new List<GarantiaContratanteContrato__c>();
            
                for (GarantiaContratanteContrato__c gcc : garantiasContratanteCtr) {
            
                    if (gcc.Garantia__r.Sigla__c != afe.Sigla__c) {
                        
                        GarantiaContratanteContrato__c newGcc = new GarantiaContratanteContrato__c(
                            Garantia__c = afe.Id,
                            ContratanteContrato__c = gcc.ContratanteContrato__c,
                            Capital__c = 0,
                            IOF__c = 0,
                            DescontoAgravoMonetarioComercial__c = 0.0,
                            GarantiaProduto__c = garantiaProdutoList[0].Id //II-21 INCIO-FIM
                        );
                        
                        if(!garantiasContratanteCtrAtualizadas.contains(newGcc)){
                            garantiasContratanteCtrAtualizadas.add(newGcc);
                        }
                        
                    } else {
                        garantiasContratanteCtrAtualizadas.add(gcc);
                    }
                }
                
                assurancesIndexedByContract.put(contractId, garantiasContratanteCtrAtualizadas);
            }      
            
            List<GarantiaContratanteContrato__c> gccList = new List<GarantiaContratanteContrato__c>();
    
            for (List<GarantiaContratanteContrato__c> gccList2 : assurancesIndexedByContract.values()) {
                gccList.addAll(gccList2);
            }
    
            upsert gccList; //II-21 INCIO-FIM
        }
    
        public void insertGarantiaGrupoContratanteCtr(Set<Id> idContratos, Garantia__c afe, List<GarantiaProduto__c> garantiaProdutoList){ //II-21 INCIO-FIM
    
            List<GarantiaGrupoContrato__c> garantiaGrupoContratanteCtr = [SELECT Id, Garantia__r.Sigla__c, Garantia__r.Name, 
                                                                            GrupoContrato__r.ContratanteContrato__r.Contrato__c
                                                                            FROM GarantiaGrupoContrato__c
                                                                            WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c IN: idContratos];
    
            Map<Id, List<GarantiaGrupoContrato__c>> assurancesIndexedByContract = new Map<Id, List<GarantiaGrupoContrato__c>>();
    
            for(GarantiaGrupoContrato__c ggctr : garantiaGrupoContratanteCtr){
    
                if(!assurancesIndexedByContract.containsKey(ggctr.GrupoContrato__r.ContratanteContrato__r.Contrato__c)){
                    assurancesIndexedByContract.put(
                        ggctr.GrupoContrato__r.ContratanteContrato__r.Contrato__c,
                        new List<GarantiaGrupoContrato__c>()
                    );
                }
    
                assurancesIndexedByContract.get(ggctr.GrupoContrato__r.ContratanteContrato__r.Contrato__c).add(ggctr);
            }                                             
    
            for (Id contractId : assurancesIndexedByContract.keySet()) {
                
                List<GarantiaGrupoContrato__c> garantiasGrupoContratanteCtr = assurancesIndexedByContract.get(contractId);
                List<GarantiaGrupoContrato__c> garantiasGrupoContratanteCtrAtualizadas = new List<GarantiaGrupoContrato__c>();
            
                for (GarantiaGrupoContrato__c ggctr2 : garantiasGrupoContratanteCtr) {
            
                    if (ggctr2.Garantia__r.Sigla__c != afe.Sigla__c) {
                        
                        GarantiaGrupoContrato__c newGgctr = new GarantiaGrupoContrato__c(
                            Garantia__c = afe.Id,
                            GrupoContrato__c = ggctr2.GrupoContrato__c,
                            Capital__c = 0,
                            IOF__c = 0,
                            GarantiaProduto__c = garantiaProdutoList[0].Id //II-21 INCIO-FIM
                        );
                        
                        if(!garantiasGrupoContratanteCtrAtualizadas.contains(newGgctr)){
                            garantiasGrupoContratanteCtrAtualizadas.add(newGgctr);
                        }
                        
                    } else {
                        garantiasGrupoContratanteCtrAtualizadas.add(ggctr2);
                    }
                }
                
                assurancesIndexedByContract.put(contractId, garantiasGrupoContratanteCtrAtualizadas);
            }      
            
            List<GarantiaGrupoContrato__c> ggctrList = new List<GarantiaGrupoContrato__c>();
    
            for (List<GarantiaGrupoContrato__c> ggctrList2 : assurancesIndexedByContract.values()) {
                ggctrList.addAll(ggctrList2);
            }
    
            upsert ggctrList; //II-21 INCIO-FIM
        }
    
        public void insertGarantiaSeguradoCtr(Set<Id> idContratos, Garantia__c afe, List<GarantiaProduto__c> garantiaProdutoList){ //II-21 INCIO-FIM
    
            List<GarantiaSeguradoContrato__c> garantiaSeguradoCtr = [SELECT Id, Garantia__r.Sigla__c, Garantia__r.Name, SeguradoContrato__c,
                                                                            SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c
                                                                            FROM GarantiaSeguradoContrato__c
                                                                            WHERE SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c IN: idContratos];
    
            Map<Id, List<GarantiaSeguradoContrato__c>> assurancesIndexedByContract = new Map<Id, List<GarantiaSeguradoContrato__c>>();
    
            for(GarantiaSeguradoContrato__c gsctr : garantiaSeguradoCtr){
    
                if(!assurancesIndexedByContract.containsKey(gsctr.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c)){
                    assurancesIndexedByContract.put(
                        gsctr.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c,
                        new List<GarantiaSeguradoContrato__c>()
                    );
                }
    
                assurancesIndexedByContract.get(gsctr.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c).add(gsctr);
            }                                             
    
            for (Id contractId : assurancesIndexedByContract.keySet()) {
                
                List<GarantiaSeguradoContrato__c> garantiasSeguradoCtr = assurancesIndexedByContract.get(contractId);
                List<GarantiaSeguradoContrato__c> garantiasSeguradoCtrAtualizadas = new List<GarantiaSeguradoContrato__c>();
            
                for (GarantiaSeguradoContrato__c gsctr2 : garantiasSeguradoCtr) {
            
                    if (gsctr2.Garantia__r.Sigla__c != afe.Sigla__c) {
                        
                        GarantiaSeguradoContrato__c newGsctr = new GarantiaSeguradoContrato__c(
                            Garantia__c = afe.Id,
                            SeguradoContrato__c = gsctr2.SeguradoContrato__c,
                            Capital__c = 0,
                            IOF__c = 0,
                            Limite_de_Uso__c = 0,
                            PremioTotal__c = 0,
                            PremioComercial__c = 0,
                            PremioPuro__c = 0,
                            GarantiaProduto__c = garantiaProdutoList[0].Id //II-21 INCIO-FIM
                        );
                        
                        if(!garantiasSeguradoCtrAtualizadas.contains(newGsctr))
                        {
                            garantiasSeguradoCtrAtualizadas.add(newGsctr);
                        }
                        
                    }else
                    {
                        garantiasSeguradoCtrAtualizadas.add(gsctr2);
                    }
                }
                
                assurancesIndexedByContract.put(contractId, garantiasSeguradoCtrAtualizadas);
            }      
            
            List<GarantiaSeguradoContrato__c> gsctrList = new List<GarantiaSeguradoContrato__c>();
    
            for (List<GarantiaSeguradoContrato__c> gsctrList2 : assurancesIndexedByContract.values()) {
                gsctrList.addAll(gsctrList2);
            }
    
            upsert gsctrList; //II-21 INCIO-FIM
        }
    
        public void insertAssurance(Map<Id, List<GarantiaContrato__c>> assuranceIndexedByCtr, Garantia__c afe, List<GarantiaProduto__c> garantiaProdutoList){ //II-21 INCIO-FIM
            
            Set<id> IdsContract = new Set<id>();
            id contractId;
    
            for(Id contratoId : assuranceIndexedByCtr.keySet()){
    
                GarantiaContrato__c newGarantiaContrato = new GarantiaContrato__c(
                    Garantia__c = afe.Id,
                    Contrato__c = contratoId,
                    Capital__c = 0,
                    IOF__c = 0,
                    Limite_de_Uso__c = 0,
                    GarantiaProduto__c = garantiaProdutoList[0].Id //II-21 INCIO-FIM
                );
                
                IdsContract.add(contratoId);
                contractId = contratoId;
    
                assuranceIndexedByCtr.put(
                    contratoId,
                    new List<GarantiaContrato__c>()
                );
    
                assuranceIndexedByCtr.get(contratoId).add(newGarantiaContrato);
                                
            }
    
            System.debug('SetIdsContratc' + IdsContract);        
    
            List<GarantiaContrato__c> garantiasToInsert = new List<GarantiaContrato__c>();
    
            for (List<GarantiaContrato__c> garantiasCtr : assuranceIndexedByCtr.values())
            {
                garantiasToInsert.addAll(garantiasCtr);
            }
    
            removeContentDocumentLink(IdsContract);
            upsert garantiasToInsert; //II-21 INCIO-FIM
            //this.idContrato.add(contractId);
            System.debug('garantiasToInsert' + garantiasToInsert);
            System.debug('IdsContract' + IdsContract);
            //criarApoliceSync(IdsContract);
        }
    
        public static Map<Id, List<GarantiaContrato__c>> getAssuranceMap(List<GarantiaContrato__c> garantiasContrato){
    
            Map<Id, List<GarantiaContrato__c>> assuranceIndexedByContract = new Map<Id, List<GarantiaContrato__c>>();
                
            for(GarantiaContrato__c gc : garantiasContrato){
    
                if(!assuranceIndexedByContract.containsKey(gc.Contrato__c)) {
                    assuranceIndexedByContract.put(gc.Contrato__c, new List<GarantiaContrato__c>());
                }   
    
                assuranceIndexedByContract.get(gc.Contrato__c).add(gc);
            }
    
            return assuranceIndexedByContract;
        }
    
        public void removeContentDocumentLink(Set<Id> idsSobject){
    
            if(idsSobject == null || idsSobject.isEmpty()){
                return;
            }
    
            String query = 'SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted FROM ContentDocumentLink WHERE LinkedEntityId IN (';
    
            for(Id id : idsSobject){
                query += '\'' + id + '\',';
            }
            
            query = query.removeEnd(',') + ')';
    
            List<ContentDocumentLink> contentDocLinks = Database.query(query);
            
            if(!contentDocLinks.isEmpty()){
                delete contentDocLinks;
            }                                                                        
        }
    
        public static void criarApoliceSync(Set<Id> psContratoId) {
            system.debug('contrato >>>>>>>> '+psContratoId);
            Map<Id,ContentVersion> mContentVersion = new Map<Id,ContentVersion>();
            
            Map<Id,Contract> mapContract = new Map<Id,Contract>();
    
            List<Contract> listContract = [SELECT Id, Name, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c, Produto__c, Produto__r.Segmento__c 
                                        FROM Contract WHERE id IN:(psContratoId)];
    
            for(Contract pcontract : listContract){
                mapContract.put(pcontract.Id,pcontract);
            }        
    
            for (Id contratoId : psContratoId) {
                PageReference pdf = null;
                String title = null;
                if(mapContract.get(contratoId).Produto__c != null && mapContract.get(contratoId).Produto__r.Segmento__c == 'Individual'){
                    pdf = Page.ApoliceVidaIndividual;
                    pdf.getParameters().put('nomeContract', mapContract.get(contratoId).Name);
                    title = 'Apolice_Individual_';
                }
                else {
                    pdf = Page.ApolicePage;
                    Map<String,String> mPDFParam = pdf.getParameters();
                    mPDFParam.put('contratoId', contratoId);
                    mPDFParam.put('renderAs', 'pdf');
                    title = 'Apolice_';
                }
    
                string nomeApolice;
                nomeApolice = mapContract.get(contratoId).Empresa__c+'_'+mapContract.get(contratoId).Sucursal__c+'_'+mapContract.get(contratoId).CodigoRamo__c+'_'+mapContract.get(contratoId).NumeroApolice__c+'_'+mapContract.get(contratoId).Endosso__c;
                ContentVersion file = new ContentVersion(
                    Title = title+nomeApolice,
                    VersionData = Test.IsRunningTest() ? Blob.valueOf('TEST') : pdf.getContentAsPDF(),
                    PathOnClient ='/apolice.pdf',
                    origin = 'H'
                );
                mContentVersion.put(contratoId, file);
            }
            system.debug('mContentVersion'+mContentVersion);
            if (mContentVersion.isEmpty()) return;
            
            insert mContentVersion.values();
    
            Map<Id, ContentVersion> mContentVersionInserted = new Map<Id, ContentVersion>(
                [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id IN :mContentVersion.values()]
            );
            
            List<ContentDocumentLink> lContentDocumentLink = new List<ContentDocumentLink>();
            
            List<ControleIntegracao__c>lControleIntegracao = new list<ControleIntegracao__c>();
          
            
            for (Id contratoId : psContratoId) {
                
                ContentDocumentLink fileLink = new ContentDocumentLink(
                    LinkedEntityId = contratoId,
                    ContentDocumentId = mContentVersionInserted.get(mContentVersion.get(contratoId).Id).ContentDocumentId,
                    ShareType = 'V'
                );
                
                lContentDocumentLink.add(fileLink);
                
                ControleIntegracao__c controleIntegracao = new ControleIntegracao__c(
                    IdObjeto__c = contratoId+'_'+mContentVersionInserted.get(mContentVersion.get(contratoId).Id).Id,
                    Status__c = 'Pendente',
                    DataCriacaoRegistro__c = Date.today(),
                    CodigoIntegracao__c = '85',
                    Objeto__c = 'Contract',
                    Pasta_ECM__c = 'Enterprise:Corporativo:Vida:Contrato:Apolice'
                    
                );
                lControleIntegracao.add(controleIntegracao);
            }
            
            insert lContentDocumentLink;
            
            insert lControleIntegracao;
            
            List<ContentVersion> lContentVersion = mContentVersionInserted.values();
            List<Contract> c = [SELECT Id, ApolicePdfDownloadUrl__c, Proposta__r.Account.PersonEmail from contract where id IN: psContratoId]; 
            List<Contract> c2update = new List<Contract>();
            List<ContentDistribution> lContentDistribution2Insert = new List<ContentDistribution>();
            system.debug('contentversion: '+lcontentversion);
            system.Debug('contract: '+c);
            
            
            for(ContentVersion cvv: lContentVersion){	
                ContentDistribution cd = new ContentDistribution (
                    Name = cvv.Title,
                    ContentVersionId = cvv.id
                );
                lContentDistribution2Insert.add(cd);
            
                system.debug('cd: '+cd);
            }
            insert lContentDistribution2Insert;
            
                    
            List <ContentDocumentLink> mContentDocumentLink = new List <ContentDocumentLink>([select LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId in: (psContratoId)]); 
            Map <ID, ID> mContractContent = new Map<ID,ID>();
            List<string> lcontentDocument = new List<string>();
            for(ContentDocumentLink obj : mContentDocumentLink){
            
                mContractContent.put(obj.ContentDocumentId,obj.LinkedEntityId);
                lcontentDocument.add(obj.ContentDocumentId);
            }
            
            Map <ID,ContentDistribution> lContentDistribution = new map<ID,ContentDistribution>([select ContentDocumentId,ContentVersionId, PdfDownloadUrl from ContentDistribution where ContentDocumentId in : (lcontentDocument) ]);
            map <ID,String> contractURL = new map <ID,String>();
    
            Map<String,String> versionxContract = new Map<String,String>();
            String baseURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1].Endpoint;
            baseURL += [SELECT NomeCredencial__c,NomeToken__c,Endpoint__c,DeveloperName FROM Servico__mdt WHERE DeveloperName='Consultar_ArquivoSF' LIMIT 1].Endpoint__c;
            
            for(String key : mContentVersion.keyset()){
                versionxContract.put((String)mContentVersion.get(key).Id,key);
            }
            
            for(ID idkey : lContentDistribution.keyset())
            {
                if(mContractContent.containsKey(lContentDistribution.get(idkey).ContentDocumentId)){
                    String token = Util.encryptDocPublicURL(versionxContract.get(lContentDistribution.get(idkey).ContentVersionId),
                    mContentVersionInserted.get(lContentDistribution.get(idkey).ContentVersionId).Title+'.pdf');
                    contractURL.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId), token);
                }
            }
            
            
            for(Contract contr: c){
            if(contractURL.containsKey(contr.Id))
                    contr.ApolicePdfDownloadUrl__c = baseURL + contractURL.get(contr.Id);
                    if(contr.Proposta__r.Account.PersonEmail != null)
                        contr.email__c = contr.Proposta__r.Account.PersonEmail;
                    c2update.add(contr);
            }
            update(c2update);            
        }
    }