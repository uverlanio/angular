global class BatchClonarRelacionadosProduto implements Database.Batchable<sObject>, Database.StateFul {
    
    global Product2 produtoTecnico { get; set; }
    Map<String, String> mapProdComercial = new Map<String, String>();
    Map<String, String> mapGarantiaProduto = new Map<String, String>();
    Map<String, String> mapParamVigencia = new Map<String, String>();
    Map<String, String> mapDocumentoProduto = new Map<String, String>();
    Map<String, String> mapComunicacaoProduto = new Map<String, String>();
    Map<String, String> mapRemuneracaoProduto = new Map<String, String>();
    Set<Id> setIdProdComercialAnterior = new Set<Id>();
    Set<Id> setIdGarantiaProdutoAnterior = new Set<Id>();
    Set<Id> setIdParamVigenciaAnterior = new Set<Id>();
    Set<Id> setIdDocumentoProdutoAnterior = new Set<Id>();
    Set<Id> setIdComunicacaoProdutoAnterior = new Set<Id>();
    Set<Id> setIdRemuneracaoProdutoAnterior = new Set<Id>();

    public BatchClonarRelacionadosProduto (Product2 prod){
        produtoTecnico = prod;
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM User limit 2';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> users) {
        try {
            clonarProdutosComerciais();
            
             /*  Relacionados a Produto Comercial (Product2)
                Os metodos abaixo dependem dos metodos clonarProdutosComerciais.
            */
            clonarGarantiasProduto();
            clonarParametrosVigencia();
            clonarQuestionarioProduto();
            clonarDocumentoProduto();
            clonarComunicacaoProduto();
            clonarRemuneracaoProduto();
            clonarPremioMinimoProduto();
            clonarProdutoAcordo();
            clonarCondicaoCobranca();
            clonarTerritorio();
            clonarDocumentos(setIdProdComercialAnterior, mapProdComercial); // ------------------------------------- TESTAR
            
            /*  Relacionados a GarantiaProduto__c
                Os metodos abaixo dependem dos metodos clonarProdutosComerciais e clonarGarantiasProduto().
            */
            
            clonarGarantiasRelacionadas(); // PLV-4414
            clonarParametroRenovacao();
            clonarGrupoRiscoGarantia();
            clonarRiscoGarantia();
            clonarFranquiaGarantia();
            clonarCarenciaGarantia();

            /*  Relacionados a ParametroVigencia__c
                Os metodos abaixo dependem dos metodos clonarProdutosComerciais e clonarParametrosVigencia().
            */

            clonarFaixaDevolucao();

            /*  Relacionados a DocumentoProduto__c
                Os metodos abaixo dependem dos metodos clonarProdutosComerciais e clonarDocumentoProduto().
            */

            clonarDocumentos(setIdDocumentoProdutoAnterior, mapDocumentoProduto); 
            
            /*  Relacionados a ComunicacaoProduto__c
            Os metodos abaixo dependem dos metodos clonarProdutosComerciais e clonarComunicacaoProduto().
            */

            clonarDocumentos(setIdComunicacaoProdutoAnterior, mapComunicacaoProduto); 

             /*  Relacionados a RemuneracaoProduto__c
            Os metodos abaixo dependem dos metodos clonarProdutosComerciais e clonarRemuneracaoProduto().
            */

            clonarRemuneracaoContrato();  
            clonarRemuneracaoProdutoParceiro();  

        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }
        
       
        // ------ Objetos relacionados ------ //
        

        
    }   
    
    global void finish(Database.BatchableContext BC) {
       
        
    }
    
    private void clonarRemuneracaoProdutoParceiro(){
        List<RemuneracaoProdutoParceiro__c> listRemuProParc = new List<RemuneracaoProdutoParceiro__c>();
        for(RemuneracaoProdutoParceiro__c remuProdParc : [SELECT Id, CurrencyIsoCode, ProdutoParceiro__c, TipoRemuneracao__c, Percentual__c, RemuneracaoProduto__c FROM RemuneracaoProdutoParceiro__c WHERE RemuneracaoProduto__c =: setIdRemuneracaoProdutoAnterior]){
            listRemuProParc.add(new RemuneracaoProdutoParceiro__c(
                CurrencyIsoCode = remuProdParc.CurrencyIsoCode,
                ProdutoParceiro__c = remuProdParc.ProdutoParceiro__c,
                TipoRemuneracao__c = remuProdParc.TipoRemuneracao__c,
                Percentual__c = remuProdParc.Percentual__c,
                RemuneracaoProduto__c = mapRemuneracaoProduto.get(remuProdParc.RemuneracaoProduto__c) != null ? mapRemuneracaoProduto.get(remuProdParc.RemuneracaoProduto__c) : null
            ));
        }
        Database.SaveResult[] srList = Database.insert(listRemuProParc, false);
        for (Database.SaveResult sr : srList) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('RemuneracaoProdutoParceiro__c fields that affected this error: ' + err.getFields());
                }
        }
    }
    
    private void clonarRemuneracaoContrato(){
        List<RemuneracaoContrato__c> listRemuContrato = new List<RemuneracaoContrato__c>();
        for(RemuneracaoContrato__c remuContrato : [SELECT Id, CurrencyIsoCode, Porcentagem_de_Retencao__c, Contrato__c, Percentual__c, TipoRemuneracao__c, RemuneracaoProduto__c FROM RemuneracaoContrato__c WHERE RemuneracaoProduto__c =: setIdRemuneracaoProdutoAnterior]){
            listRemuContrato.add(new RemuneracaoContrato__c(
                CurrencyIsoCode = remuContrato.CurrencyIsoCode,
                Porcentagem_de_Retencao__c = remuContrato.Porcentagem_de_Retencao__c,
                Contrato__c = remuContrato.Contrato__c,
                Percentual__c = remuContrato.Percentual__c,
                TipoRemuneracao__c = remuContrato.TipoRemuneracao__c,
                RemuneracaoProduto__c = mapRemuneracaoProduto.get(remuContrato.RemuneracaoProduto__c) != null ? mapRemuneracaoProduto.get(remuContrato.RemuneracaoProduto__c) : null
            ));
        }
        Database.SaveResult[] srRemuContrato = Database.insert(listRemuContrato, false);
        for (Database.SaveResult sr : srRemuContrato) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('RemuneracaoContrato__c fields that affected this error: ' + err.getFields());
                }
        }
    }

    private void clonarFaixaDevolucao(){
        List<FaixaDevolucao__c> listFaixa = new List<FaixaDevolucao__c>();
        for(FaixaDevolucao__c faixa : [SELECT Id, FaixaAte__c, CurrencyIsoCode, FaixaDe__c, FaixaDevolucao__c, ParametroVigencia__c, Percentual__c FROM FaixaDevolucao__c WHERE ParametroVigencia__c =: setIdParamVigenciaAnterior]){
            listFaixa.add(new FaixaDevolucao__c(
                FaixaAte__c = faixa.FaixaAte__c,
                CurrencyIsoCode = faixa.CurrencyIsoCode,
                FaixaDe__c = faixa.FaixaDe__c,
                FaixaDevolucao__c = faixa.FaixaDevolucao__c,
                Percentual__c = faixa.Percentual__c,
                ParametroVigencia__c = mapParamVigencia.get(faixa.ParametroVigencia__c) != null ? mapParamVigencia.get(faixa.ParametroVigencia__c) : null
            ));
        }
        Database.SaveResult[] srFaixa = Database.insert(listFaixa, false);
        for (Database.SaveResult sr : srFaixa) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('FaixaDevolucao__c fields that affected this error: ' + err.getFields());
                }
        }
    }
    // PLV-4414 - INICIO
    private void clonarGarantiasRelacionadas(){
        List<GarantiaRelacionada__c> listGarantiaRelacionada = new List<GarantiaRelacionada__c>();
        // PLV-4414-FIX5
        for(GarantiaRelacionada__c garantia : [SELECT Id, Acumulativa__c, CurrencyIsoCode, Dependencia__c, GarantiaProduto__c, GarantiaRelacionada__c, Incremento__c, TipoDependencia__c, ValidarRegrasProdutoComercial__c FROM GarantiaRelacionada__c WHERE GarantiaProduto__c =: setIdGarantiaProdutoAnterior]){
            listGarantiaRelacionada.add(new GarantiaRelacionada__c(
                Acumulativa__c = garantia.Acumulativa__c,
                CurrencyIsoCode = garantia.CurrencyIsoCode,
                Dependencia__c = garantia.Dependencia__c,
                // PLV-4414-FIX5
                // Garantia__c = garantia.Garantia__c,
                GarantiaRelacionada__c = garantia.GarantiaRelacionada__c,
                Incremento__c = garantia.Incremento__c,
                TipoDependencia__c = garantia.TipoDependencia__c,
                ValidarRegrasProdutoComercial__c = garantia.ValidarRegrasProdutoComercial__c,
                GarantiaProduto__c = mapGarantiaProduto.get(garantia.GarantiaProduto__c) != null ? mapGarantiaProduto.get(garantia.GarantiaProduto__c) : null
            ));
        }
        System.debug('Garantias Relacionadas ' + listGarantiaRelacionada);
        System.debug('Set garantia prod anterior ' + setIdGarantiaProdutoAnterior);
        Database.SaveResult[] srGarantiaRelacionada = Database.insert(listGarantiaRelacionada, false);
        for (Database.SaveResult sr : srGarantiaRelacionada) {
            if(sr.isSuccess()){
                System.debug('Successfully inserted Garantia Relacionada. Garantia Relacionada ID: ' + sr.getId());
            }
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('GarantiaRelacionada__c fields that affected this error: ' + err.getFields());
                }
        }
    }
    // PLV-4414 - FIM
    private void clonarParametroRenovacao(){
        List<ParametroRenovacao__c> listParam = new List<ParametroRenovacao__c>();
        for(ParametroRenovacao__c param : [SELECT Id, CurrencyIsoCode, GarantiaProduto__c, IdadeMaximaRenovacao__c, IdadeReducaoCapital__c, ParametroRenovacao__c, PercentualReducao__c, TipoSegurado__c, ValidarRegrasProdutoComercial__c FROM ParametroRenovacao__c WHERE GarantiaProduto__c =: setIdGarantiaProdutoAnterior]){
            listParam.add(new ParametroRenovacao__c(
                CurrencyIsoCode = param.CurrencyIsoCode,
                IdadeMaximaRenovacao__c = param.IdadeMaximaRenovacao__c,
                IdadeReducaoCapital__c = param.IdadeReducaoCapital__c,
                ParametroRenovacao__c = param.ParametroRenovacao__c,
                PercentualReducao__c = param.PercentualReducao__c,
                TipoSegurado__c = param.TipoSegurado__c,
                ValidarRegrasProdutoComercial__c = param.ValidarRegrasProdutoComercial__c,
                GarantiaProduto__c = mapGarantiaProduto.get(param.GarantiaProduto__c) != null ? mapGarantiaProduto.get(param.GarantiaProduto__c) : null
            ));
        }
        Database.SaveResult[] srParam = Database.insert(listParam, false);
        for (Database.SaveResult sr : srParam) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('ParametroRenovacao__c fields that affected this error: ' + err.getFields());
                }
        }
    }

    private void clonarGrupoRiscoGarantia(){
        List<GrupoRiscoGarantia__c> listGrupoRisco = new List<GrupoRiscoGarantia__c>();
        for(GrupoRiscoGarantia__c grupoRisco : [SELECT Id, CurrencyIsoCode, GarantiaProduto__c, GrupoRisco__c, Name FROM GrupoRiscoGarantia__c WHERE GarantiaProduto__c =: setIdGarantiaProdutoAnterior]){
            listGrupoRisco.add(new GrupoRiscoGarantia__c(
                CurrencyIsoCode = grupoRisco.CurrencyIsoCode,
                GrupoRisco__c = grupoRisco.GrupoRisco__c,
                Name = grupoRisco.Name,
                GarantiaProduto__c = mapGarantiaProduto.get(grupoRisco.GarantiaProduto__c) != null ? mapGarantiaProduto.get(grupoRisco.GarantiaProduto__c) : null
            ));
        }
        Database.SaveResult[] srCarencia = Database.insert(listGrupoRisco, false);
        for (Database.SaveResult sr : srCarencia) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('GrupoRiscoGarantia__c fields that affected this error: ' + err.getFields());
                }
        }
    }

    private void clonarRiscoGarantia(){
        List<RiscoGarantia__c> listRisco = new List<RiscoGarantia__c>();
        for(RiscoGarantia__c risco : [SELECT Id, CurrencyIsoCode, PercentualMaximo__c, GarantiaProduto__c, PermiteAlterarProdutoComercial__c, PercentualMinimo__c, QuantidadeRiscoMaxima__c, QuantidadeRiscoMinima__c, Risco__c, RiscoGarantia__c, TabelaRisco__c FROM RiscoGarantia__c WHERE GarantiaProduto__c =: setIdGarantiaProdutoAnterior]){
            listRisco.add(new RiscoGarantia__c(
                CurrencyIsoCode = risco.CurrencyIsoCode,
                PercentualMaximo__c = risco.PercentualMaximo__c,
                PermiteAlterarProdutoComercial__c = risco.PermiteAlterarProdutoComercial__c,
                PercentualMinimo__c = risco.PercentualMinimo__c,
                QuantidadeRiscoMaxima__c = risco.QuantidadeRiscoMaxima__c,
                QuantidadeRiscoMinima__c = risco.QuantidadeRiscoMinima__c,
                Risco__c = risco.Risco__c,
                RiscoGarantia__c = risco.RiscoGarantia__c,
                TabelaRisco__c = risco.TabelaRisco__c,
                GarantiaProduto__c = mapGarantiaProduto.get(risco.GarantiaProduto__c) != null ? mapGarantiaProduto.get(risco.GarantiaProduto__c) : null
            ));
        }
        Database.SaveResult[] srRisco = Database.insert(listRisco, false);
        for (Database.SaveResult sr : srRisco) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('RiscoGarantia__c fields that affected this error: ' + err.getFields());
                }
        }
    }

    private void clonarFranquiaGarantia(){
        List<FranquiaGarantia__c> listFranquia = new List<FranquiaGarantia__c>();
        for(FranquiaGarantia__c franquia : [SELECT Id, Franquia__c, CurrencyIsoCode, FranquiaGarantia__c, GarantiaProduto__c, PermiteAlterarProdutoComercial__c, TipoEmissao__c FROM FranquiaGarantia__c WHERE GarantiaProduto__c =: setIdGarantiaProdutoAnterior]){
            listFranquia.add(new FranquiaGarantia__c(
                CurrencyIsoCode = franquia.CurrencyIsoCode,
                Franquia__c = franquia.Franquia__c,
                FranquiaGarantia__c = franquia.FranquiaGarantia__c,
                PermiteAlterarProdutoComercial__c = franquia.PermiteAlterarProdutoComercial__c,
                TipoEmissao__c = franquia.TipoEmissao__c,
                GarantiaProduto__c = mapGarantiaProduto.get(franquia.GarantiaProduto__c) != null ? mapGarantiaProduto.get(franquia.GarantiaProduto__c) : null
            ));
        }
        Database.SaveResult[] srFranquia = Database.insert(listFranquia, false);
        for (Database.SaveResult sr : srFranquia) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('FranquiaGarantia__c fields that affected this error: ' + err.getFields());
                }
        }
    }

    private void clonarCarenciaGarantia(){
        List<CarenciaGarantia__c> listCarencia = new List<CarenciaGarantia__c>();
        for(CarenciaGarantia__c carencia : [SELECT Id, Carencia__c, CurrencyIsoCode, CarenciaGarantia__c, FormaCarencia__c, GarantiaProduto__c, LimitePercentual__c, LimiteValor__c, PermiteAlterarProdutoComercial__c, TipoEmissao__c, ValorBase__c FROM CarenciaGarantia__c WHERE GarantiaProduto__c =: setIdGarantiaProdutoAnterior]){
            listCarencia.add(new CarenciaGarantia__c(
                CurrencyIsoCode = carencia.CurrencyIsoCode,
                Carencia__c = carencia.Carencia__c,
                CarenciaGarantia__c = carencia.CarenciaGarantia__c,
                FormaCarencia__c = carencia.FormaCarencia__c,
                LimitePercentual__c = carencia.LimitePercentual__c,
                LimiteValor__c = carencia.LimiteValor__c,
                PermiteAlterarProdutoComercial__c = carencia.PermiteAlterarProdutoComercial__c,
                TipoEmissao__c = carencia.TipoEmissao__c,
                ValorBase__c = carencia.ValorBase__c,
                GarantiaProduto__c = mapGarantiaProduto.get(carencia.GarantiaProduto__c) != null ? mapGarantiaProduto.get(carencia.GarantiaProduto__c) : null
            ));
        }
        Database.SaveResult[] srCarencia = Database.insert(listCarencia, false);
        for (Database.SaveResult sr : srCarencia) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('CarenciaGarantia__c fields that affected this error: ' + err.getFields());
                }
        }
    }

    // private void clonarOferta(){
    //     List<Oferta__c> listOferta = new List<Oferta__c>();
    //     for(Oferta__c oferta : [SELECT Id, VigenciaInicio__c, CurrencyIsoCode, GerarDocumento__c, Customizavel__c, Produto__c, Status__c, Name, Versao__c FROM Oferta__c WHERE Produto__c =: produtoTecnico.VersaoAnterior__c]){
    //         oferta.Produto__c = mapProdComercial.get(oferta.Produto__c) != null ? mapProdComercial.get(oferta.Produto__c) : null;
    //         listOferta.add(oferta.clone(false, false, false, false));
    //     }
    //     Database.SaveResult[] srOferta = Database.insert(listOferta, false);
    //     for (Database.SaveResult sr : srOferta) {
    //             for(Database.Error err : sr.getErrors()) {
    //                 System.debug('Erro ao inserir registros clonados.');                    
    //                 System.debug(err.getStatusCode() + ': ' + err.getMessage());
    //                 System.debug('Oferta__c fields that affected this error: ' + err.getFields());
    //             }
    //     }
    // }

    private void clonarQuestionarioProduto(){
        List<QuestionarioProduto__c> listQuestionario = new List<QuestionarioProduto__c>();
        for(QuestionarioProduto__c quest : [SELECT Id, GarantiaProduto__c, LimiteCapitalMaximo__c, LimiteCapitalMinimo__c, CurrencyIsoCode, Prioridade__c, Produto__c, Questionario__c FROM QuestionarioProduto__c WHERE Produto__c =: setIdProdComercialAnterior]){
            quest.Produto__c = mapProdComercial.get(quest.Produto__c) != null ? mapProdComercial.get(quest.Produto__c) : null;
            listQuestionario.add(quest.clone(false, false, false, false));
        }
        Database.SaveResult[] srlistQuestionario = Database.insert(listQuestionario, false);
        for (Database.SaveResult sr : srlistQuestionario) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('QuestionarioProduto__c fields that affected this error: ' + err.getFields());
                }
        }
    }

    private void clonarPremioMinimoProduto(){
        List<PremioMinimoProduto__c> listPremioMinimo = new List<PremioMinimoProduto__c>();
        for(PremioMinimoProduto__c premioMinimo : [SELECT Id, FormaPagamento__c, CurrencyIsoCode, PeriodicidadePagamento__c, Produto__c, PremioMinimoProduto__c, PremioMinimoParcela__c, TipoContratacao__c, ValidarRegrasProdutoComercial__c  FROM PremioMinimoProduto__c WHERE Produto__c =: setIdProdComercialAnterior]){
            premioMinimo.Produto__c = mapProdComercial.get(premioMinimo.Produto__c) != null ? mapProdComercial.get(premioMinimo.Produto__c) : null;
            listPremioMinimo.add(premioMinimo.clone(false, false, false, false));
        }
        Database.SaveResult[] srlistPremioMinimo = Database.insert(listPremioMinimo, false);
        for (Database.SaveResult sr : srlistPremioMinimo) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('PremioMinimoProduto__c fields that affected this error: ' + err.getFields());
                }
        }
    }

    private void clonarProdutoAcordo(){
        List<ProdutoAcordo__c> listProdutoAcordo = new List<ProdutoAcordo__c>();
        for(ProdutoAcordo__c acordo : [SELECT Id, AcordoComercial__c, CurrencyIsoCode, Produto__c  FROM ProdutoAcordo__c WHERE Produto__c =: setIdProdComercialAnterior]){
            acordo.Produto__c = mapProdComercial.get(acordo.Produto__c) != null ? mapProdComercial.get(acordo.Produto__c) : null;
            listProdutoAcordo.add(acordo.clone(false, false, false, false));
        }
        Database.SaveResult[] srlistProdutoAcordo = Database.insert(listProdutoAcordo, false);
        for (Database.SaveResult sr : srlistProdutoAcordo) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('ProdutoAcordo__c fields that affected this error: ' + err.getFields());
                }
        }
    }

    private void clonarDocumentoProduto(){
        List<DocumentoProduto__c> listDoc = new List<DocumentoProduto__c>();
        for(DocumentoProduto__c doc : [SELECT Id, Descricao__c, Documento__c, MeioEnvio__c, CurrencyIsoCode, MomentoEnvio__c, Papel__c, Produto__c, Tipo__c FROM DocumentoProduto__c WHERE Produto__c =: setIdProdComercialAnterior]){
            doc.Produto__c = mapProdComercial.get(doc.Produto__c) != null ? mapProdComercial.get(doc.Produto__c) : null;
            doc.VersaoAnterior__c = doc.Id;
            listDoc.add(doc.clone(false, false, false, false));
        }
        Database.SaveResult[] srList = Database.insert(listDoc, false);
        for (Database.SaveResult sr : srList) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('DocumentoProduto__c fields that affected this error: ' + err.getFields());
                }
        }

        for(DocumentoProduto__c doc : listDoc){
            mapDocumentoProduto.put(doc.VersaoAnterior__c, doc.Id);
            setIdDocumentoProdutoAnterior.add(doc.VersaoAnterior__c);
        }
    }
    
    private void clonarCondicaoCobranca(){
        List<CondicaoCobranca__c> listCondicao = new List<CondicaoCobranca__c>();
        for(CondicaoCobranca__c condicao : [SELECT Id, FormaPagamento__c, NomeFormaPagamento__c, CurrencyIsoCode, PercentualDescontoAgravo__c, PercentualMaximo__c, Produto__c, PercentualMinimo__c, QuantidadeParcelas__c, RegiaoRestricao__c, TipoPagamento__c FROM CondicaoCobranca__c WHERE Produto__c =: setIdProdComercialAnterior]){
            condicao.Produto__c = mapProdComercial.get(condicao.Produto__c) != null ? mapProdComercial.get(condicao.Produto__c) : null;
            listCondicao.add(condicao.clone(false, false, false, false));
        }
        Database.SaveResult[] srList = Database.insert(listCondicao, false);
        for (Database.SaveResult sr : srList) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('CondicaoCobranca__c fields that affected this error: ' + err.getFields());
                }
        }
    }

    private void clonarComunicacaoProduto(){
        List<ComunicacaoProduto__c> listComunicacao = new List<ComunicacaoProduto__c>();
        for(ComunicacaoProduto__c comunicacao : [SELECT Id, CanalDistribuicao__c, Conteudo__c, InicioEnvio__c, MeioEnvio__c, CurrencyIsoCode, NomeAviso__c, Objetivo__c, Papel__c, Produto__c, TipoCliente__c, QuantidadeAvisos__c, TerminoEnvio__c FROM ComunicacaoProduto__c WHERE Produto__c =: setIdProdComercialAnterior]){
            comunicacao.Produto__c = mapProdComercial.get(comunicacao.Produto__c) != null ? mapProdComercial.get(comunicacao.Produto__c) : null;
            comunicacao.VersaoAnterior__c = comunicacao.Id;
            listComunicacao.add(comunicacao.clone(false, false, false, false));
        }
        Database.SaveResult[] srList = Database.insert(listComunicacao, false);
        for (Database.SaveResult sr : srList) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('ComunicacaoProduto__c fields that affected this error: ' + err.getFields());
                }
        }

        for(ComunicacaoProduto__c comuni : listComunicacao){
            mapComunicacaoProduto.put(comuni.VersaoAnterior__c, comuni.Id);
            setIdComunicacaoProdutoAnterior.add(comuni.VersaoAnterior__c);
        }
    }

    private void clonarTerritorio(){
        List<Territorio__c> listTerritorio = new List<Territorio__c>();
        for(Territorio__c territorio : [SELECT Id, Continente__c, Estado__c, GarantiaProduto__c, Municipio__c, CurrencyIsoCode, Pais__c, Produto__c, Territorio__c, Tipo__c FROM Territorio__c WHERE Produto__c =: setIdProdComercialAnterior]){
            territorio.Produto__c = mapProdComercial.get(territorio.Produto__c) != null ? mapProdComercial.get(territorio.Produto__c) : null;
            listTerritorio.add(territorio.clone(false, false, false, false));
        }
        Database.SaveResult[] srList = Database.insert(listTerritorio, false);
        for (Database.SaveResult sr : srList) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Territorio__c fields that affected this error: ' + err.getFields());
                }
        }
    }

    private void clonarRemuneracaoProduto(){
        List<RemuneracaoProduto__c> listRemuneracao = new List<RemuneracaoProduto__c>();
        for(RemuneracaoProduto__c remuneracao : [SELECT Id, CurrencyIsoCode, Produto__c, LimiteMaximo__c, LimiteMinimo__c, Obrigatoria__c, ParcelasAgenciamento__c, RemuneracaoProduto__c, TipoEvento__c, TipoRemuneracao__c FROM RemuneracaoProduto__c WHERE Produto__c =: setIdProdComercialAnterior]){
            remuneracao.Produto__c = mapProdComercial.get(remuneracao.Produto__c) != null ? mapProdComercial.get(remuneracao.Produto__c) : null;
            remuneracao.VersaoAnterior__c = remuneracao.Id;
            listRemuneracao.add(remuneracao.clone(false, false, false, false));
        }
        Database.SaveResult[] srList = Database.insert(listRemuneracao, false);
        for (Database.SaveResult sr : srList) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('RemuneracaoProduto__c fields that affected this error: ' + err.getFields());
                }
        }

        for(RemuneracaoProduto__c remu : listRemuneracao){
            mapRemuneracaoProduto.put(remu.VersaoAnterior__c, remu.Id);
            setIdRemuneracaoProdutoAnterior.add(remu.VersaoAnterior__c);
        }
    }

    private void clonarParametrosVigencia(){
        List<ParametroVigencia__c> listParamVigencia = new List<ParametroVigencia__c>();
        for(ParametroVigencia__c param : buscarParametrosVigenciaProduto(setIdProdComercialAnterior)){
            param.Produto__c = mapProdComercial.get(param.Produto__c) != null ? mapProdComercial.get(param.Produto__c) : null;
            param.VersaoAnterior__c = param.Id;
            listParamVigencia.add(param.clone(false, false, false, false));
        }
        Database.SaveResult[] srParametrosVigencia = Database.insert(listParamVigencia, false);
        for (Database.SaveResult sr : srParametrosVigencia) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('ParametroVigencia fields that affected this error: ' + err.getFields());
                }
        }
        
        for(ParametroVigencia__c param : listParamVigencia){
            mapParamVigencia.put(param.VersaoAnterior__c, param.Id);
            setIdParamVigenciaAnterior.add(param.VersaoAnterior__c);
        }
    }

    private void clonarGarantiasProduto(){
        List<GarantiaProduto__c> listGarantias = new List<GarantiaProduto__c>();
        for(GarantiaProduto__c garantia : buscarGarantiasProdutoPorProdutoId(setIdProdComercialAnterior)){
            garantia.Produto__c = mapProdComercial.get(garantia.Produto__c) != null ? mapProdComercial.get(garantia.Produto__c) : null;
            garantia.VersaoAnterior__c = garantia.Id;
            listGarantias.add(garantia.clone(false, false, false, false));
        }

        Database.SaveResult[] srGarantiasProduto = Database.insert(listGarantias, false);
        for (Database.SaveResult sr : srGarantiasProduto) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Erro ao inserir registros clonados.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('GarantiaProduto__c fields that affected this error: ' + err.getFields());
                }
        }

        for(GarantiaProduto__c garantia : listGarantias){
            mapGarantiaProduto.put(garantia.VersaoAnterior__c, garantia.Id);
            setIdGarantiaProdutoAnterior.add(garantia.VersaoAnterior__c);

        }
    }

    private void clonarProdutosComerciais(){
        List<Product2> listNewProdutoComercial = new List<Product2>();
        for(Product2 produtoComercial : getProdutosComerciaisById(produtoTecnico.VersaoAnterior__c)){
            produtoComercial.VigenciaInicial__c = produtoTecnico.VigenciaInicial__c; // validar
            produtoComercial.VigenciaFinal__c = produtoTecnico.VigenciaFinal__c; // validar
            produtoComercial.GerarVoucher__c = produtoTecnico.GerarVoucher__c; // validar
            produtoComercial.TipoResponsavelPagamento__c = produtoTecnico.TipoResponsavelPagamento__c; // validar
            produtoComercial.ProdutoTecnico__c = produtoTecnico.Id;
            produtoComercial.VersaoAnterior__c = produtoComercial.Id;
            // PLV-4290 - INICIO
            produtoComercial.Segmento__c = produtoTecnico.Segmento__c;
            // PLV-4290 - FIM
            produtoComercial.ProductCode = null;
            produtoComercial.Status__c = 'Em criação';
            produtoComercial.Versao__c += 1; 
            produtoComercial.VersaoParaRenovacaoDeContrato__c = produtoComercial.Versao__c; 
            produtoComercial.VersaoParaEndosso__c = produtoComercial.Versao__c; 
            //PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
            produtoComercial.ProdutoEndosso__c = produtoComercial.Id;
            produtoComercial.ProdutoRenovacao__c = produtoComercial.Id;
            //PLV-4666 - SIM - PEDRO AUGUSTO BRAZ - SYS4B
            listNewProdutoComercial.add(produtoComercial.clone(false, false, false, false));
        }

        Database.SaveResult[] srProdutoComercial = Database.insert(listNewProdutoComercial, false);
        for (Database.SaveResult sr : srProdutoComercial) {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Erro ao inserir registros clonados.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('ProdutoComercial__c fields that affected this error: ' + err.getFields());
            }
        }
        
        for(Product2 produtoComercial : listNewProdutoComercial){
            mapProdComercial.put(produtoComercial.VersaoAnterior__c, produtoComercial.Id);
            setIdProdComercialAnterior.add(produtoComercial.VersaoAnterior__c);
        }
    }

    private List<Product2> getProdutosComerciaisById(String idProduto){
        return  [SELECT Id, Name,ProductCode,RecordTypeId, Description, RecordType.DeveloperName,Empresa__c, LimiteTotalCarregamento__c, NumeroSusep__c, Ordenacao__c, ProdutoTecnico__c, ProdutoVigente__c, 
        RelacaoVidas__c, Segmento__c, Sigla__c, Status__c, TipoBeneficiario__c, TipoCapital__c, TipoResponsavelPagamento__c, VersaoAnterior__c, VersaoMaxima__c, VersaoRenovacao__c, Versao__c, 
        VigenciaFinal__c, VigenciaInicial__c, PercentualAgravoMaximo__c, PercentualAgravoMinimo__c, PercentualDescontoMaximo__c, PercentualDescontoMinimo__c, TipoDesconto__c, GerarVoucher__c, 
        ProductCodeLegado__c, VersaoParaEndosso__c, VersaoParaRenovacaoDeContrato__c,ProdutoEndosso__c,ProdutoRenovacao__c //PLV-4666 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
		FROM Product2 
		WHERE RecordType.DeveloperName =: 'ProdutoComercial' AND ProdutoTecnico__c =: idProduto AND Status__c = 'Ativo'];   
    }

    private List<ParametroVigencia__c> buscarParametrosVigenciaProduto(Set<Id> produtoIds){
        return [SELECT Id, Name,RecordTypeId,RecordType.Name, IdadeMaximaRenovacao__c, IndiceReajuste__c, ModeloResgate__c, ParametroVigencia__c, Periodicidade__c, PeriodoCoberturaMaximo__c, PeriodoCoberturaMinimo__c, 
        PeriodoMaximoInadimplenciaDeterminada__c, PeriodoMaximoInadimplenciaPeriodica__c, PeriodoMaximoInadimplenciaVitalicia__c, PrazoAplicacaoReajuste__c, PrazoAvisarRenovacao__c, 
        PrazoDesistenciaRenovacao__c, PrazoMinimoCancelamento__c, PrazoRetornoAviso__c, ProdutoRenovavel__c, Produto__c, QuantidadeRenovacaoesAnuencia__c, RenovaEsgotamentoIndenizacao__c, 
        TipoPeriodo__c, Tipo__c, VigenciaMinimaRenovacao__c, PeriodoMaximoInadimplencia__c, PeriodoMaximoVigencia__c, PeriodoMinimoVigencia__c, ParcelamentoAposFinalVigencia__c, VersaoAnterior__c,
        ValidadeProposta__c, ValidadeOrcamento__c FROM ParametroVigencia__c WHERE Produto__c IN : produtoIds];
    }

    private List<GarantiaProduto__c> buscarGarantiasProdutoPorProdutoId(Set<Id> produtoIds){
        return [SELECT Id, Garantia__c, Garantia__r.Descricao__c, Garantia__r.Name, Garantia__r.Sigla__c, CancelaDependentes__c, CancelaGarantia__c, CancelaSegurado__c, CapitalRiscos__c, 
        CaracteristicaGarantia__c, CodigoPlanoSusep__c, CodigoPromocao__c, ComunicarEtapasSinistro__c, 
        CustoCaracteristicaEspecial__c, DataSolicitacao__c, DemonstracaoCapital__c, DemonstracaoPremio__c, DependentesCancelar__c, Descricao__c, DocumentosAviso__c, FinalidadeRemissao__c, 
        FormaExibicaoCapital__c, FormaPagamento__c, GarantiaDeduzir__c, GarantiaLimitadora__c, GarantiaProduto__c, Intervalo__c, LimiteCapitalMaximo__c, LimiteCapitalMinimo__c, LimiteIdadeMaximo__c, 
        LimiteIdadeMinimo__c, LimiteMaximoCaracteristicaEspecial__c, LimiteMaximoUtilizacao__c, LimiteMinimoCaracteristicaEspecial__c, LimiteReintegracoes__c, Modalidade__c, 
        Obrigatoria__c, OrdemPrioridade__c, OrigemSinistroBeneficio__c, PassivelResseguro__c, PercentualAgravoMaximo__c, PercentualAgravoMinimo__c, PercentualCapitalMaximo__c, 
        PercentualCapitalMinimo__c, PercentualDescontoMaximo__c, PercentualDescontoMinimo__c, PercentualMaximoCancelamento__c, PeriodoRemissao__c, PermiteExibicao__c, PrazoAvisoSinistro__c, 
        PrazoMaximoLiquidacao__c, Produto__c, QuantidadeDependentes__c, QuantidadeMaximaContratacao__c, RamoSeguro__c, RiscosCobertos__c, Possui_reintegracao__c, TempoContagem__c, 
        TipoBeneficiario__c, TipoCapital__c, TipoCaracteristicaEspecial__c, TipoGarantia__c, TipoLimiteCapital__c, TipoPagamento__c, TipoPrazoAvisoSinistro__c, TipoPrazoMaximoLiquidacao__c, 
        TipoReintegracao__c, ValorFinal__c, ValorInicial__c, ValorTitulo__c, VersaoTitulo__c, Prestadora__c, ValorVidaAtiva__c, TipoCobranca__c, ValorServico__c, MomentoCancelamento__c, 
        ambitoTerritorial__c, VigenciaGarantia__c, RiscosExcluidos__c, VersaoAnterior__c FROM GarantiaProduto__c Where Produto__c IN: produtoIds];
    }

    private void clonarDocumentos(Set<Id> setIdParam, Map<String, String> mapObject){
        if(setIdParam.size() == 0)
            return;
        Map<String, ContentVersion> mapContentVersion = new Map<String, ContentVersion>();
		List<ContentDocumentLink> cloneLinksDocumentos = new List<ContentDocumentLink>();
		Set<Id> contentDocumentIds = new Set<Id>();
		Set<Id> contentVersionIds = new Set<Id>();
        DocumentBO docBO = DocumentBO.getInstance();
        Map<String, String> mapDoc = new Map<String, String>();

        //Recupera os links dos documetos do produto
        SYstem.debug('carlos ' + setIdParam);
		for(ContentDocumentLink link : [Select Id, LinkedEntityId, ContentDocumentId, ShareType From ContentDocumentLink Where LinkedEntityId IN: setIdParam]){
            contentDocumentIds.add(link.ContentDocumentId);
            mapDoc.put(link.ContentDocumentId, link.LinkedEntityId);
		}

		if(!contentDocumentIds.isEmpty()){
            //Gera clonagem do conteudo dos documentos
            
			for(ContentVersion documento : [Select Id, Title, PathOnClient, VersionData, IsMajorVersion, ContentDocumentId From ContentVersion Where ContentDocumentId IN: contentDocumentIds]){
				mapContentVersion.put(documento.ContentDocumentId, new ContentVersion(
						Title = documento.Title,
						PathOnClient = documento.PathOnClient,
						VersionData = documento.VersionData,
                        IsMajorVersion = documento.IsMajorVersion,
                        ContentDocumentId = documento.ContentDocumentId
				));
			}

			insert mapContentVersion.values();

			for(ContentVersion documento : mapContentVersion.values()){
				contentVersionIds.add(documento.Id);
			}

			//Gera links dos documentos no produto
			for(ContentVersion documento : docBO.buscarContentVersionPorId(contentVersionIds)){
				cloneLinksDocumentos.add( new ContentDocumentLink(
						LinkedEntityId = mapObject.get(mapDoc.get(documento.ContentDocumentId)),
						ContentDocumentId = documento.ContentDocumentId,
						ShareType = 'V'
				));
			}
            Database.SaveResult[] srDoc = Database.insert(cloneLinksDocumentos, false);
            for (Database.SaveResult sr : srDoc) {
                if(sr.success){
                    System.debug('id produto inserido: ' + sr.getId());
                }
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Erro ao inserir registros clonados.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Documento fields that affected this error: ' + err.getFields());
                    }
            }
		}
    }
}