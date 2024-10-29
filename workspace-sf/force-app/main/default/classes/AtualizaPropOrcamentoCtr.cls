/**
 * @description       : Métodos usados para realizar a lógica do BatchAtualizaPropostaOrcamento - RVI-265
 * @author            : Kevin Vogado e Matheus Meneses (GLOBANT)
 * @last modified on  : 24-08-2023
 * @last modified by  : Bruno Filipe
**/

public with sharing class AtualizaPropOrcamentoCtr {

    public static Map<String, String> camposToPut = new Map<String, String>{
        'PercSusepLider__c'    => 'SusepAtual__c',
        'PercPriCoCorretor__c' => 'SusepPriCoCorretagem__c',
        'PercSegCoCorretor__c' => 'SusepSegCoCorretagem__c',
        'PercTerCoCorretor__c' => 'SusepTerCoCorretagem__c',
        'PercQuaCoCorretor__c' => 'SusepQuaCoCorretagem__c',
        'PercQuiCoCorretor__c' => 'SusepQuiCoCorretagem__c'
    };
    
    public static List<String> camposSusep = new List<String>{
        'SusepAtual__c', 
        'SusepPriCoCorretagem__c', 
        'SusepSegCoCorretagem__c', 
        'SusepTerCoCorretagem__c', 
        'SusepQuaCoCorretagem__c', 
        'SusepQuiCoCorretagem__c'
    };

    public static void criarFavorecidoProposta(TransferenciaCorretagem__c tc, List<RemuneracaoProposta__c> remuneracoes, Map<String, Decimal> campoTransferenciaCorretagemMap, List<FavorecidoRemuneracaoProposta__c> favRelatedToProposta ) {
        Map<String, Object> camposPopulados = tc.getPopulatedFieldsAsMap();

        for(String key : camposPopulados.keySet()){
            if(camposToPut.containsKey(key)){
                campoTransferenciaCorretagemMap.put(camposToPut.get(key), (Decimal) camposPopulados.get(key));
            }
        }

        for(String campo : camposSusep){

            if(camposPopulados.containsKey(campo)){

                DadosCorretor__c dados = (DadosCorretor__c) camposPopulados.get(campo.replace('__c', '__r'));

                Boolean isLider = campo == 'SusepAtual__c' ? true : false; 

                FavorecidoRemuneracaoProposta__c favorecido = new FavorecidoRemuneracaoProposta__c(
                    DadosCorretor__c = dados.Id,
                    Susep__c = dados.Name,
                    Papel__c = 'Corretor',
                    Participacao__c = campoTransferenciaCorretagemMap.get(campo),
                    Conta__c = dados.NomeCorretor__c,
                    CorretorLider__c = isLider
                );

                for (RemuneracaoProposta__c remuneracao : remuneracoes) {
                    favorecido.RemuneracaoProposta__c = remuneracao.Id;
                    break;
                }
       
                favRelatedToProposta.add(favorecido);
            }
        }
    }

    public static Map<Id, List<RemuneracaoProposta__c>> getRemuneracaoMappedByProposta(List<FavorecidoRemuneracaoProposta__c> favRelatedToProposta){

        Map<Id, List<RemuneracaoProposta__c>> remuneracaoMappedByProposta = new Map<Id, List<RemuneracaoProposta__c>>();

        for(FavorecidoRemuneracaoProposta__c fv : favRelatedToProposta){
            
            remuneracaoMappedByProposta.put(
                fv.RemuneracaoProposta__r.Proposta__c,
                new List<RemuneracaoProposta__c>()
            );
    
            remuneracaoMappedByProposta.get(fv.RemuneracaoProposta__r.Proposta__c).add(fv.RemuneracaoProposta__r);
        }

        return remuneracaoMappedByProposta;
    }

    public static Map<Id, List<TransferenciaCorretagem__c>> getTransferenciaIndexedByContract(List<TransferenciaCorretagem__c> transferencias){

        Map<Id, List<TransferenciaCorretagem__c>> transferenciaIndexedByContract = new Map<Id, List<TransferenciaCorretagem__c>>();

        for (TransferenciaCorretagem__c tc : transferencias) {
            if(tc != null){
                if (tc.ContratoTransferido__c != null) { 
                    if (!transferenciaIndexedByContract.containsKey(tc.ContratoTransferido__c)) {
                        transferenciaIndexedByContract.put(tc.ContratoTransferido__c, new List<TransferenciaCorretagem__c>());
                    }
                    transferenciaIndexedByContract.get(tc.ContratoTransferido__c).add(tc);
                }
            }
        }
    
        return transferenciaIndexedByContract;
    }   

    public static Map<Id, List<FavorecidoRemuneracaoProposta__c>> getFavorecidosMappedByProposta (Set<Id> idsPropostas){
        Map<Id, List<FavorecidoRemuneracaoProposta__c>> favorecidosMappedByProposta = new Map<Id, List<FavorecidoRemuneracaoProposta__c>>();

        for(FavorecidoRemuneracaoProposta__c favorecido : [SELECT Id, Name, Susep__c, RemuneracaoProposta__c, RemuneracaoProposta__r.Name, Conta__r.Name, RemuneracaoProposta__r.Proposta__c, RemuneracaoProposta__r.Proposta__r.Opportunity.CodigoCorretor__r.Name
                FROM FavorecidoRemuneracaoProposta__c
                WHERE RemuneracaoProposta__r.Proposta__c IN : idsPropostas
                AND RemuneracaoProposta__r.TipoRemuneracao__r.Name = 'CORRETAGEM'
            ])
        {
            System.debug('Entrou no for do getFavorecidosMappedByProposta');
            Id propostaId = favorecido.RemuneracaoProposta__r.Proposta__c;

            // if(!favorecidosMappedByProposta.containsKey(propostaId)) {
            //     favorecidosMappedByProposta.put(propostaId, new List<FavorecidoRemuneracaoProposta__c>());
            // }
            
            if(!favorecidosMappedByProposta.containsKey(propostaId) && favorecidosMappedByProposta != null) {
                favorecidosMappedByProposta.put(propostaId, new List<FavorecidoRemuneracaoProposta__c>());
            }

            // favorecidosMappedByProposta.get(propostaId).add(favorecido);
            System.debug('getFavorecidosMappedByProposta favorecido.Susep__c '+ favorecido.Susep__c);
            System.debug('getFavorecidosMappedByProposta favorecido.RemuneracaoProposta__r.Proposta__r.Opportunity.CodigoCorretor__r.Name ' +favorecido.RemuneracaoProposta__r.Proposta__r.Opportunity.CodigoCorretor__r.Name);
            if(favorecido.Susep__c == favorecido.RemuneracaoProposta__r.Proposta__r.Opportunity.CodigoCorretor__r.Name){
                favorecidosMappedByProposta.get(propostaId).add(favorecido); 
                System.debug('favorecido.Susep__c');
            }

        }
        return favorecidosMappedByProposta;
    }
    
    public static Map<String, List<TransferenciaCorretagem__c>> getTransfIndexedBySusepName(List<TransferenciaCorretagem__c> transfCarteira){

        Map<String, List<TransferenciaCorretagem__c>> transfIndexedByContract =  new Map<String, List<TransferenciaCorretagem__c>>();

        for(TransferenciaCorretagem__c tc : transfCarteira){
            if(tc.TransferirCarteira__c == true){

                if(!transfIndexedByContract.containsKey(tc.SusepOriginal__r.Name)){
                    transfIndexedByContract.put(tc.SusepOriginal__r.Name, new List<TransferenciaCorretagem__c>());
                }

                transfIndexedByContract.get(tc.SusepOriginal__r.Name).add(tc);
            }
        }

        return transfIndexedByContract;
    }

    public static void removeContentDocumentLink(Set<Id> idsSobject){

        if(idsSobject == null || idsSobject.isEmpty()){
            return;
        }

        String query = 'SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted FROM ContentDocumentLink WHERE LinkedEntityId IN (';

        for(Id id : idsSobject){
            query += '\'' + String.escapeSingleQuotes(id) + '\',';
            System.debug('query > ' + query);
        }
        
        query = query.removeEnd(',') + ')';
        System.debug('query >> ' + query);

        List<ContentDocumentLink> contentDocLinks = Database.query(query);
        System.debug('contentDocLinks >>' + contentDocLinks);
        
        if(!contentDocLinks.isEmpty()){
            delete contentDocLinks;
        }                                                                        
    }

    public static void atualizarDescricaoOportunidade(TransferenciaCorretagem__c tc, Opportunity orcamento ){
        Map<String, Object> camposPopulados = tc.getPopulatedFieldsAsMap();

        for(String campo : camposSusep) {
            if(camposPopulados.containsKey(campo)){
                DadosCorretor__c dados = (DadosCorretor__c) camposPopulados.get(campo.replace('__c', '__r'));
                orcamento.CodigoCorretor__c = dados.Id;
            }
            break;    
        }
    }

    public void insertFavRemuneracaoProposta(List<TransferenciaCorretagem__c> transferencias){

        Set<Id> oppyIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> quoteIdCorreta = new Set<Id>();
        Set<Id> contratoRenovado = new Set<Id>();
        Set<Id> contratosTransfCarteira= new Set<Id>();

        List<String> suseps = new List<String>();
        List<Opportunity> orcamentoToUpdateCarteira = new List<Opportunity>();
        List<Opportunity> orcamentoToUpdateIndividual = new List<Opportunity>();
        List<FavorecidoRemuneracaoProposta__c> inserirFavorecidos = new list<FavorecidoRemuneracaoProposta__c>();
        List<FavorecidoRemuneracaoProposta__c> lstfavDeleteIndividual = new list<FavorecidoRemuneracaoProposta__c>();

        Map<Id, Opportunity> mapUpdOppCarteira = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapUpdOppIndividual = new Map<Id, Opportunity>();
        Map<Id, Opportunity> orcamentoIndexByProp = new Map<Id, Opportunity>();
        Map<String, Decimal> campoTransferenciaCorretagemMap = new Map<String, Decimal>();
        Map<Id, FavorecidoRemuneracaoProposta__c> mapDeleteFavorecidoRemProp = new Map<Id, FavorecidoRemuneracaoProposta__c>();

        List<Quote> propostas = [SELECT Id, CodigoCorretor__c, CodigoCorretor__r.Name, ContratoRenovado__c, Status, Tipo__c, OpportunityId, Opportunity.CodigoCorretor__c, Opportunity.CodigoCorretor__r.Name, Opportunity.ContratoRenovado__c,
                                (SELECT Id, Name FROM RemuneracoesProposta__r)
                                  FROM Quote
                                  WHERE Status = 'Em análise' 
                                  AND Tipo__c = 'Renovacao'
                                  AND LiberarContratoRenovacao__c = true];

        if(!propostas.isEmpty()){
            for(Quote qt : propostas){
                quoteIds.add(qt.Id);

                oppyIds.add(qt.OpportunityId);
                
                contratoRenovado.add(qt.ContratoRenovado__c);
            }
        }
    
        List<Contract> lstContratos = [SELECT Id, Proposta__r.Tipo__c, Proposta__r.ContratoRenovado__c, Proposta__r.Name, CodigoCorretor__r.Name, (SELECT Id, ContratoTransferido__c FROM DadosContratoTransferido__r) 
        FROM Contract WHERE Id IN :contratoRenovado];
        
        id contractId;
        Id contratoTransferidoId;
        for(Contract contract : lstContratos){
            contractId = contract.Id;
            
            List<TransferenciaCorretagem__c> TransferenciaCorretagem = contract.DadosContratoTransferido__r;
            for (TransferenciaCorretagem__c dadosContratoTransferido : TransferenciaCorretagem) {
                contratoTransferidoId = dadosContratoTransferido.ContratoTransferido__c;
                System.debug('Contrato Transferido => ' + contratoTransferidoId);
            } 
            if(contractId != contratoTransferidoId){    
                contratosTransfCarteira.add(contract.Id);
                System.debug('Contratos => ' + contratosTransfCarteira);
            }
        }

        Map<Id, Opportunity> lstopprtunityListOpp = new Map<Id, Opportunity>(
            [SELECT Id, CodigoCorretor__c, CodigoCorretor__r.Name 
            FROM Opportunity 
            WHERE Id IN :oppyIds AND StageName = 'Disponível para contratação']
        );

        for(Quote prop : propostas){
           for(Id orcamentoId : lstopprtunityListOpp.keySet()) {
                if(prop.OpportunityId == orcamentoId){
                    orcamentoIndexByProp.put(prop.Id, lstopprtunityListOpp.get(orcamentoId));
                }
           }
        }

        System.debug('Transferências => '+ transferencias);
        Map<String, List<TransferenciaCorretagem__c>> transfCarteiraBySusepName = getTransfIndexedBySusepName(transferencias);

        Map<Id, List<TransferenciaCorretagem__c>> transfIndexByContract = getTransferenciaIndexedByContract(transferencias);

        Map<Id, List<FavorecidoRemuneracaoProposta__c>> favorecidosMappedByProposta = getFavorecidosMappedByProposta(quoteIds);
        System.debug('favorecidosMappedByProposta Danilo '+favorecidosMappedByProposta);
        System.debug('propostas Danilo '+propostas);
        for(Quote qt : propostas){

            List<FavorecidoRemuneracaoProposta__c> favRelatedToProposta = favorecidosMappedByProposta.get(qt.Id);
                        
            Map<Id, List<RemuneracaoProposta__c>> remuneracaoMappedByProposta = getRemuneracaoMappedByProposta(favRelatedToProposta);
                        
            List<RemuneracaoProposta__c> remuneracoes = remuneracaoMappedByProposta.get(qt.Id);
            System.debug('favRelatedToProposta '+ favRelatedToProposta);
            for(FavorecidoRemuneracaoProposta__c frc : favRelatedToProposta){
                if(frc.Susep__c != null){
                    suseps.add(frc.Susep__c);
                }
            }
            
            quoteIdCorreta.add(qt.Id);
            
            if(!transfIndexByContract.isEmpty() && transfIndexByContract.containsKey(qt.ContratoRenovado__c)){

                List<TransferenciaCorretagem__c> transf = transfIndexByContract.get(qt.ContratoRenovado__c);
                System.debug('suseps >>'+ suseps);
                System.debug('transf >>'+ transf);
                for(TransferenciaCorretagem__c tc : transf){
                    if(suseps.contains(tc.CodCor__c)){
                        System.debug('Contrato Renovado - Individual => '+qt.ContratoRenovado__c);

                        lstfavDeleteIndividual.addAll(favRelatedToProposta);
                        favRelatedToProposta.clear();  
                        
                        criarFavorecidoProposta(tc, remuneracoes, campoTransferenciaCorretagemMap, favRelatedToProposta);   
                        System.debug('Cria Remunerações - Individual => ' + remuneracoes + 'Cria Favorecidos - Individual => '+ favRelatedToProposta);

                        inserirFavorecidos.addAll(favRelatedToProposta);
                        System.debug('Add Favorecidos - Individual => ' + inserirFavorecidos);
                        
                        Opportunity orcamento = orcamentoIndexByProp.get(qt.Id);
                        if(orcamento != null){
                            atualizarDescricaoOportunidade(tc, orcamento); 
                            orcamentoToUpdateIndividual.add(orcamento);
                            System.debug('Add Orcamento - Individual => ' + orcamentoToUpdateIndividual);
                        }
                    }
                }   
            }

            if(transfCarteiraBySusepName != null){
                
                for(String nameSusep: transfCarteiraBySusepName.keySet()){

                    if(suseps.contains(nameSusep)){

                        List<TransferenciaCorretagem__c> transfCarteira = transfCarteiraBySusepName.get(nameSusep);
                        
                        for(TransferenciaCorretagem__c tc : transfCarteira){
                            
                            System.debug('Contratos com Transferencia - Fora do If => '+contratosTransfCarteira);
                            if( tc.SusepOriginal__r.Name.equals(qt.CodigoCorretor__r.Name) &&  
                                tc.SusepOriginal__r.Name.equals(qt.Opportunity.CodigoCorretor__r.Name) &&
                                contratosTransfCarteira.contains(qt.ContratoRenovado__c) && 
                                contratosTransfCarteira.contains(qt.Opportunity.ContratoRenovado__c) &&
                                qt.ContratoRenovado__c != contratoTransferidoId) { 

                                System.debug('Transferência - Carteira => '+transfCarteira);
                                System.debug('Contrato Renovado - Carteira => '+qt.ContratoRenovado__c);
                                
                                lstfavDeleteIndividual.addAll(favRelatedToProposta);
                                favRelatedToProposta.clear();  
                                    
                                criarFavorecidoProposta(tc, remuneracoes, campoTransferenciaCorretagemMap, favRelatedToProposta);
                                System.debug('Cria Remunerações - Carteira => ' + remuneracoes + 'Cria Favorecido - Carteira => '+ favRelatedToProposta);
                                
                                inserirFavorecidos.addAll(favRelatedToProposta);
                                System.debug('favRelatedToProposta: ' + System.JSON.serializePretty(favRelatedToProposta)) ;
                                System.debug('Add Favorecido - Carteira => ' + inserirFavorecidos); 

                                Opportunity orcamento = orcamentoIndexByProp.get(qt.Id);
                                if(orcamento != null){
                                    atualizarDescricaoOportunidade(tc, orcamento);     
                                    orcamentoToUpdateCarteira.add(orcamento);
                                    System.debug('Add Orçamento - Carteira => ' + orcamentoToUpdateCarteira);
                                }
                            }    
                        }
                    }
                }
            }
            System.debug('JSON - Favorecido => ' + JSON.serialize(favRelatedToProposta));  
        }

        removeContentDocumentLink(quoteIdCorreta);

        mapUpdOppIndividual.putAll(orcamentoToUpdateIndividual);
        System.debug('Update Orçamento - Individual => ' + mapUpdOppIndividual.values());  
        
        if(mapUpdOppIndividual.size()>0) {
            update mapUpdOppIndividual.values();
        }

        mapUpdOppCarteira.putAll(orcamentoToUpdateCarteira);
        System.debug('Update Orçamento - Carteira => ' + mapUpdOppCarteira.values());  
        if(mapUpdOppCarteira.size()>0) {
            update mapUpdOppCarteira.values();
        }

        mapDeleteFavorecidoRemProp.putAll(lstfavDeleteIndividual);
        if(mapDeleteFavorecidoRemProp.size()>0){
            System.debug('Delete Favorecido - Original => ' + mapDeleteFavorecidoRemProp);  
            delete mapDeleteFavorecidoRemProp.values();
        }
        
        if(!inserirFavorecidos.isEmpty()){
            System.debug('Insert Favorecido => ' + inserirFavorecidos); 
            insert inserirFavorecidos;
        }

        QuoteBO.gerarPDFPropostaSync(new List<Id>(quoteIdCorreta));
        
        System.debug('New PDF - Proposta Renovação => ' + quoteIdCorreta);  
    }
}