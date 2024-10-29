/**
 * @description       : 
 * @author            : giordano.menezes@globant.com
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//PLV-3649 - INICIO - Criação da classe para executar o servico de gravar orcamento
public with sharing class GravarOrcamentoService {
    
    private GravarOrcamentoRest.Request req;
    
    public GravarOrcamentoService(GravarOrcamentoRest.Request req) {
        this.req = req;
    }
    
    public ServiceTO.PayRetornoOfertasTO getComplemento(){
        Set<String> setCodigoProduto = new Set<String>(); //PLV-4854 - INÍCIO/FIM
        ServiceTO.PayRetornoOfertasTO ofertasRetorno = new ServiceTO.PayRetornoOfertasTO();
        EmissaoTO.PayloadTO payload = new EmissaoTO.PayloadTO();
        payload.ofertas = req.ofertas;
        system.debug('REQ::: '+req);
        ofertasRetorno = ValidaRegrasGarantiaSniper.validaGarantias(payload);

        String tpSeg = ''; //RVI-165-INICIO/FIM

        system.debug('payload serializado>> ' + JSON.serialize(payload.ofertas));
		
        // PLV-4840 remoção de bloco de código

        // PLV-5331 INÍCIO
        ProductDAO produtoDao = ProductDAO.getInstance();
        // PLV-5331 FIM
        
        Map<String,Opportunity> mapOpp = new Map<String,Opportunity>();

        Set<String> setIdProdutoVida = new Set<String>(); //PLV-5331 - INÍCIO/FIM
        Set<String> setIdOfertas = new Set<String>(); //PLV-5331 - INÍCIO/FIM
        
        for(EmissaoTO.OfertasTO oferta : req.ofertas){
            // PLV-5331 INÍCIO
            // Product2 prodPrec = produtoDao.buscProdPrecDtCalc(oferta.orcamento.codigoProdutoVida, 
            // oferta.orcamento.idProdutoSf);
            // system.debug('prodPrec no for: '+prodPrec.ProductCode);
            // PLV-5331 FIM
            mapOpp.put(oferta.orcamento.numeroOrcamento, new Opportunity());
            //PLV-4854 - INÍCIO
            // setCodigoProduto.add(oferta.orcamento.codigoProdutoVida); // PLV-5331 INÍCIO / FIM
            // setCodigoProduto.add(prodPrec.ProductCode); // PLV-5331 INÍCIO / FIM
            setIdProdutoVida.add(oferta.orcamento.codigoProdutoVida);// PLV-5331 INÍCIO / FIM
            setIdOfertas.add(oferta.orcamento.idProdutoSf);// PLV-5331 INÍCIO / FIM
            System.debug('BRUNO 1 >>>' + oferta);
            System.debug('BRUNO 2 >>>' + oferta.orcamento);
        }
        // PLV-5331 INÍCIO
        List<Product2> lstprodPrec = produtoDao.buscProdPrecDtCalcList(setIdProdutoVida, setIdOfertas);

        for(Product2 prodPrec : lstprodPrec){
            
            setCodigoProduto.add(prodPrec.CodigoPrecificaProduto__c); //ANNVI-224 - INICIO/FIM
        }
        // PLV-5331 FIM
        Map<String, Map<String, GarantiaProduto__c>> garantiasProdutoMapByCodigoProduto = getGarantiasProdutoMapByCodigoProduto(setCodigoProduto);
        //PLV-4854 - FIM
        for(Opportunity opp : [
            SELECT Id, Name, Numero__c 
            FROM Opportunity 
            WHERE Numero__c IN :mapOpp.keySet()
        ]){
            mapOpp.put(opp.Numero__c, opp);
        }
        List < ServiceTO.OfertaTO > ofertas = new List < ServiceTO.OfertaTO > ();

        //VIAG-148-FIX02-INICIO
        Set<Id> idProduto = new Set<Id>();
        for(EmissaoTO.OfertasTO oferta: req.ofertas){
            idProduto.add(oferta.orcamento.idProdutoSf);
        }

        Map<Id,Product2> mapRetornoIdProd = produtoDao.buscarProdPorCod(idProduto);

        for (EmissaoTO.OfertasTO oferta: req.ofertas) {
            //PLV-4854 - INÍCIO
            Map<String, GarantiaProduto__c> garantiasBySiglaMap;

            // PLV-5331 INÍCIO
            //Product2 prodPrec = produtoDao.buscProdPrecDtCalc(oferta.orcamento.codigoProdutoVida, 
            //oferta.orcamento.idProdutoSf);
            Product2 prodPrec;
            if(mapRetornoIdProd.containsKey(oferta.orcamento.idProdutoSf)){
                prodPrec = mapRetornoIdProd.get(oferta.orcamento.idProdutoSf);
            }
            // PLV-5331 FIM
            //VIAG-148-FIX02-FIM
            // PLV-5331 INÍCIO
            // if (garantiasProdutoMapByCodigoProduto.containsKey(oferta.orcamento.codigoProdutoVida)) {
            //     garantiasBySiglaMap = garantiasProdutoMapByCodigoProduto.get(oferta.orcamento.codigoProdutoVida);
            // }
            
            if (garantiasProdutoMapByCodigoProduto.containsKey(prodPrec.ProductCode)) {
                garantiasBySiglaMap = garantiasProdutoMapByCodigoProduto.get(prodPrec.ProductCode);
            }
            // PLV-5331 FIM
            //PLV-4854 - FIM
            
            tpSeg = oferta.orcamento.tipoSeguro; //RVI-165-INICIO/FIM
            Opportunity opp = mapOpp.get(oferta.orcamento.numeroOrcamento);
            System.debug('Danilo opp GravarOrcamentoService: ' + opp);
            if(opp == null || opp.Id == null) continue;
            
            //PLV-5066 - INICIO
            Boolean zerarPremio = this.zerarPremioOrcamento(oferta);
            if(zerarPremio){
              this.ajustarPremioEndossoCadastral(oferta);
            }    
            //PLV-5066 - FIM

            //PLV-3649 FIX - INICIO
            FileController.createTextFile(opp.Name + '_' + Datetime.now().format('dd-MM-yyyy_HH:mm:ss') + '_' + 'entradaServico', JSON.serialize(oferta), opp.Id, '.min.json');
            //PLV-3649 FIX - FIM 
            
            ServiceTO.OfertaTO ofertaRetorno = new ServiceTO.OfertaTO();
            system.debug('oferta:: '+oferta);
            ofertaRetorno.orcamento = this.gerarRetornoOrcamento(oferta, garantiasBySiglaMap); //PLV-4854 - INÍCIO/FIM
            system.debug('Orcamento::: '+ofertaRetorno.orcamento);
            ofertaRetorno.parcelamentos = this.gerarRetornoParcelamento(oferta);
            system.debug('ofertaRetorno.parcelamentos .. '+ofertaRetorno.parcelamentos);
            ofertaRetorno.retornoAceitacao = this.gerarRetornoCriticasODM(oferta);
            system.debug('ofertaRetorno.retornoAceitacao .. '+ofertaRetorno.retornoAceitacao);
            //PLV-5066 - INICIO
            ofertaRetorno.retornosCalculo = new List<EmissaoTO.RetornoCalculoTO>();
            //EmissaoTO.RetornoCalculoTO retTeste = new EmissaoTO.RetornoCalculoTO();
            //retTeste.orcnum = 'Teste Tiago';
            //ofertaRetorno.retornosCalculo.add(retTeste);
            if(zerarPremio){
                System.debug('HENRIQUE ENTROU AQUI ZERAR PREMIO');
                System.debug('oferta.retornosCalculo Henrique: ' + JSON.serialize(oferta.retornosCalculo));
                ofertaRetorno.retornosCalculo = oferta.retornosCalculo;
            }
            //PLV-5066 - FIM
            Boolean recusa = false;
            system.debug('ofertaRetorno.retornoAceitacao.analises .. '+ofertaRetorno.retornoAceitacao.analises);
            system.debug('ofertaRetorno.retornoAceitacao.recusas .. '+ofertaRetorno.retornoAceitacao.recusas);
            system.debug('ofertaRetorno.retornoAceitacao.pendencias .. '+ofertaRetorno.retornoAceitacao.pendencias);
            if(!ofertaRetorno.retornoAceitacao.analises.isEmpty() || !ofertaRetorno.retornoAceitacao.recusas.isEmpty() || !ofertaRetorno.retornoAceitacao.pendencias.isEmpty()) recusa = true;
            System.debug('recusa && ofertaRetorno.orcamento.varConsultivo');
            //System.debug(recusa && ofertaRetorno.orcamento.varConsultivo); //PLV-4780 INICIO/FIM
            //if(recusa && ofertaRetorno.orcamento.varConsultivo) continue; //PLV-4698 INICIO/FIM
          
           /* // VIAG-148 INICIO
            List<Profissao__c> profissoes = new List<Profissao__c>();
                          
                String codigoProfissao;
                // VIAG-148 INICIO
                List<EmissaoTO.DadosPessoaFisicaTO> dadosPessoaFisica = new  List<EmissaoTO.DadosPessoaFisicaTO>  ();
                if (oferta.orcamento.segmento != 'Viagem') {
                    for(EmissaoTO.DadosPessoaFisicaTO dados: dadosPessoaFisica){
                        if(dados.profissao !=null){
                            codigoProfissao = dados.profissao;
                        }
                    }
    
    
                 profissoes = [SELECT Id, Limite_de_capital_maximo__c,LimiteCapital__c  FROM Profissao__c WHERE Status__c ='Ativo' AND CodigoProfissao__c =: codigoProfissao];
                    
                } 
            

           // VIAG-148  FIM  */


            this.gerarRetornoRegras(ofertaRetorno, oferta, prodPrec);
            system.debug('ofertaRetorno processada ' + JSON.serialize(ofertaRetorno));
            system.debug('oferta processada ' + JSON.serialize(oferta));
            ofertaRetorno.orcamento.varConsultivo = false;
            
            FileController.createTextFile(opp.Name + '_' + Datetime.now().format('dd-MM-yyyy_HH:mm:ss') + '_' + 'retornoServico', JSON.serialize(ofertaRetorno), opp.Id, '.min.json');
            
            ofertas.add(ofertaRetorno);
            //Chamada para a queueable que faz a gravação dos dados do Orçamento.
            System.enqueueJob(new GravarOrcamentoQueueable(oferta));
        }
        system.debug('ofertasRetorno.ofertas .. '+ofertasRetorno.ofertas);
        ofertasRetorno.ofertas = ofertas;
        system.debug('ofertasRetorno: '+JSON.serialize(ofertasRetorno));


        //PLV-4840 INICIO
        System.debug('BRUNO 3 >>>>' + tpSeg);
        ofertasRetorno = this.validaIdadeGarantiasVI(ofertasRetorno, tpSeg); //RVI-165-INICIO/FIM
        

        System.debug('ofertasRetorno Danilo::' + JSON.serialize(ofertasRetorno));
        if(ofertasRetorno.retornoValidacaoProduto != null && 
           ofertasRetorno.retornoValidacaoProduto.recusas != null && 
           !ofertasRetorno.retornoValidacaoProduto.recusas.isEmpty()){
            return ofertasRetorno;
        }
        //PLV-4840 FIM
        
        return ofertasRetorno;   
    }
    
    public ServiceTO.OrcamentoTO gerarRetornoOrcamento(EmissaoTO.OfertasTO oferta, Map<String, GarantiaProduto__c> garantiasBySiglaMap) { //PLV-4854 - INÍCIO/FIM
        
        ServiceTO.OrcamentoTO orcamento = new ServiceTO.OrcamentoTO();
        
        orcamento.numeroPortal = oferta.orcamento.numeroPortal;
        orcamento.numeroOrcamento = oferta.orcamento.numeroOrcamento;   
        orcamento.ordemPortal = oferta.orcamento.ordemPortal;
        orcamento.varConsultivo = oferta.orcamento.varConsultivo;
        //PLV-4790 FIX 8 INICIO
        orcamento.ramoSeguro = getRamoSeguroOrcamento(oferta, garantiasBySiglaMap); //PLV-4854 - INÍCIO/FIM
        System.debug('gerarRetornoOrcamento => ' + orcamento);
        //PLV-4790 FIX 8 FIM
        
        return orcamento;
    }

    //PLV-4854 - INÍCIO
    private Integer getRamoSeguroOrcamento(EmissaoTO.OfertasTO oferta, Map<String, GarantiaProduto__c> garantiasBySiglaMap) {
        Integer codigoRamo = 0;
        Decimal prioridade = 9999999;
        List<EmissaoTO.CoberturaTO> coberturas; //PLV-4854 FIX 4 - INÍCIO/FIM

        if (garantiasBySiglaMap != null && garantiasBySiglaMap.values().size() > 0) {
            
            if (oferta != null && oferta.orcamento != null ) {
                try {
                    //PLV-4854 FIX 4 - INÍCIO
                    if(oferta.orcamento.contratantes[0].grupos[0].segurados != null && oferta.orcamento.contratantes[0].grupos[0].segurados.size() > 0){
                        coberturas = oferta.orcamento.contratantes[0].grupos[0].segurados[0].coberturas;
                    }
                    else{
                        coberturas = oferta.orcamento.contratantes[0].grupos[0].coberturas;
                    }
                    //PLV-4854 FIX 4 - FIM

                    if (coberturas != null && coberturas.size() > 0) {
                        List<GarantiaProduto__c> garantiasSelecionadas = new List<GarantiaProduto__c>();

                        for (EmissaoTO.CoberturaTO cobertura : coberturas) {
                            if (garantiasBySiglaMap.containsKey(cobertura.sigla)) {
                                garantiasSelecionadas.add(garantiasBySiglaMap.get(cobertura.sigla));
                            }
                        }

                        if (garantiasSelecionadas.size() > 0) {

                            for (GarantiaProduto__c garantiaProduto : garantiasSelecionadas) {

                                if (garantiaProduto.OrdemPrioridade__c < prioridade) {
                                    prioridade = garantiaProduto.OrdemPrioridade__c;
                        
                                    if (garantiaProduto.RamoSeguro__r != null) {
                                        codigoRamo = Integer.valueOf(garantiaProduto.RamoSeguro__r.Codigo__c);
                                    }
                                }
                            }
                        }
                    }
                }
                catch (Exception ex) {
                    System.debug('getRamoSeguroOrcamento : Exception : ' + ex.getMessage() + ', ' + ex.getStackTraceString());
                    throw new GravarOrcamentoServiceException('Erro ao recuperar o Código do Ramo das Garantias do Produto. ' + ex.getMessage() + ', ' + ex.getStackTraceString());
                }
            }
        }

        System.debug('getRamoSeguroOrcamento => ' + codigoRamo);

        return codigoRamo;
    }

    private Map<String, Map<String, GarantiaProduto__c>> getGarantiasProdutoMapByCodigoProduto(Set<String> codigosProduto) {
        Map<String, Map<String, GarantiaProduto__c>> result = new Map<String, Map<String, GarantiaProduto__c>>();

        if (codigosProduto != null && codigosProduto.size() > 0) {
            List<Product2> produtos = [
                SELECT Id
                    ,ProductCode
                    ,CodigoPrecificaProduto__c // PLV-5331 INÍCIO / FIM
                    ,(
                        SELECT Id
                            ,Garantia__r.Sigla__c
                            ,OrdemPrioridade__c
                            ,RamoSeguro__c
                            ,RamoSeguro__r.Codigo__c
                        FROM GarantiasProduto__r
                        WHERE Garantia__r.Sigla__c <> NULL
                    )
                FROM Product2
                // WHERE ProductCode IN :codigosProduto // PLV-5331 INÍCIO / FIM
                WHERE CodigoPrecificaProduto__c IN :codigosProduto // PLV-5331 INÍCIO / FIM
                LIMIT 2000
            ]; 

            if (produtos.size() > 0) {

                for (Product2 produto : produtos) {
                    
                    if (!result.containsKey(produto.ProductCode) && produto.GarantiasProduto__r.size() > 0) {
                        Map<String, GarantiaProduto__c> mapGarantiasByProduto = new Map<String, GarantiaProduto__c>();
                        
                        for (GarantiaProduto__c garantia : produto.GarantiasProduto__r) {
                            mapGarantiasByProduto.put(garantia.Garantia__r.Sigla__c, garantia);
                        }

                        if (mapGarantiasByProduto.values().size() > 0) {
                            result.put(produto.ProductCode, mapGarantiasByProduto);
                        }
                    }
                }
            }
        }

        
        System.debug('getGarantiasProdutoMapByCodigoProduto => ' + JSON.serialize(result));

        return result;
    }
    //PLV-4854 - FIM
    
    //PLV-4744 INICIO
    //PLV-4666 - INICIO
    private List<String> getQtdParcelamento(CondicaoCobranca__c condicao, Boolean hasAgenciamento, Boolean endosso) {
        List<String> result = new List<String>();
        system.debug('getQtdParcelamento .. hasAgenciamento .. '+hasAgenciamento);
        system.debug('getQtdParcelamento .. condicao .. QuantidadeParcelas .. '+condicao.QuantidadeParcelas__c);
        if(!endosso){
            if (hasAgenciamento && condicao.QuantidadeParcelas__c != null) {
                for (String qtdParcela : condicao.QuantidadeParcelas__c.split('\\;')) {
                    if (Integer.valueOf(qtdParcela) == 12) result.add(qtdParcela);
                    if (Integer.valueOf(qtdParcela) == 11 && condicao.TipoPagamento__c != 'ADC' && condicao.TipoPagamento__c != 'Boleto' ) result.add(qtdParcela); // PLV-4795 INICIO/FIM 
                }
            }else {
                result = condicao.QuantidadeParcelas__c.split('\\;');
                System.debug('RESULT ## 1 ::' + result);//!
            }
        }else{
            result = condicao.QuantidadeParcelas__c.split('\\;');
            System.debug('RESULT ## 2 ::' + result);//!
        }

        return result;
    }
    //PLV-4666 - FIM

    private Boolean hasAgenciamento(EmissaoTO orcamento) {        
        for (EmissaoTO.RemuneracaoTO remu : orcamento.remuneracoes) {
            if (remu.tipoRemuneracao == 'AGENCIAMENTO' && remu.percentual > 0) {
                return true;
            }
        }

        return false;
    }
    @TestVisible
    private List < ServiceTO.ParcelamentoTO > gerarRetornoParcelamento(EmissaoTO.OfertasTO orcamento) {
        Boolean hasAgenciamento = hasAgenciamento(orcamento.orcamento);
        //PLV-4744 FIM
        system.debug('orcamentoJSON:: '+JSON.serialize(orcamento));
        
        Map < String, Integer > versaocalculo = new map < string, integer > ();
        
        for (EmissaoTO.VersoesCalculo mversao: orcamento.orcamento.versoesCalculos) {
            // AV-698 INICIO
             if (mversao.tipo == 'FPG' ) {
            string valorDesconto = String.valueOf(mversao.descontoAgravo);
            versaocalculo.put(valorDesconto, mversao.opcao);
             } else {
                continue;
             }
            // AV-698 FIM
        }
        
        System.debug(LoggingLevel.Error,'versaocalculo >>'+JSON.serialize(versaocalculo));
        
        List < EmissaoTO.RetornoCalculoTO > retornoCalculov = new List < EmissaoTO.RetornoCalculoTO > ();
        
        EmissaoTO.RetornoCalculoTO retornoCalculo = new EmissaoTO.RetornoCalculoTO();
        if (orcamento.retornosCalculo != null && !orcamento.retornosCalculo.isEmpty()) {
            
            retornoCalculov = orcamento.retornosCalculo;
            system.debug('retornoCalculov: '+retornoCalculov);
            
        } else {
            return null;
        }

        Product2 produto = null;
        Map<String,Decimal> mapPremioMinimo =  new Map<String, Decimal>();
        system.debug('codigoProdutoVida valor: '+orcamento.orcamento.codigoProdutoVida); 
        if(orcamento.orcamento.codigoProdutoVida !=null && orcamento.orcamento.codigoProdutoVida != ''){
            try {
                produto = [SELECT 
                    ID,CodigoPrecificaProduto__c,(SELECT Id, FormaPagamento__c, PremioMinimoParcela__c, FormaPagamento__r.Codigo__c  FROM PremiosMinimoProduto__r) 
                    FROM Product2
                    // WHERE ProductCode =: orcamento.orcamento.codigoProdutoVida // PLV-5331 INÍCIO / FIM
                    WHERE CodigoPrecificaProduto__c =: orcamento.orcamento.codigoProdutoVida // PLV-5331 INÍCIO / FIM
                    AND Id =: orcamento.orcamento.idProdutoSf // RVI-215-INICIO/FIM
                    Limit 1
                ];

                for(PremioMinimoProduto__c premio : produto.PremiosMinimoProduto__r ){
                    mapPremioMinimo.put(premio.FormaPagamento__r.Codigo__c, premio.PremioMinimoParcela__c);
                }
            } catch (Exception e) {

                produto = null;
            }
        }
        system.debug('Map mapPremioMinimo >> '+ JSON.serialize(mapPremioMinimo));
        //Buscar condições de cobrança atreladas ao produto

        // PLV-5331 INÍCIO
        ProductDAO produtoDao = ProductDAO.getInstance();
        Product2 prodPrec = produtoDao.buscProdPrecDtCalc(orcamento.orcamento.codigoProdutoVida, orcamento.orcamento.idProdutoSf);
        // PLV-5331 FIM
        system.debug('prodPrec GravarOrcamentoService: '+prodPrec);
        // Integer codigoEmpresa = produtoDao.buscarCodigoEmpresa(orcamento.orcamento.idProdutoSf); // II-24
        // List < CondicaoCobranca__c > condicoesCobrancas = ContratanteOrcamentoDAO.getInstance().buscarCondicaoCobranca(orcamento.orcamento.codigoProdutoVida); // PLV-5331 INÍCIO / FIM
        List < CondicaoCobranca__c > condicoesCobrancas = ContratanteOrcamentoDAO.getInstance().buscarCondicaoCobranca(prodPrec.ProductCode); // PLV-5331 INÍCIO / FIM
        system.debug('Query Condição '+ JSON.serialize(condicoesCobrancas));
        ParametroVigencia__c parametroVigencia = [SELECT ParcelamentoAposFinalVigencia__c
                                                  FROM ParametroVigencia__c
                                                //   WHERE Produto__r.ProductCode =: orcamento.orcamento.codigoProdutoVida // PLV-5331 INÍCIO / FIM
                                                  WHERE Produto__r.ProductCode =: prodPrec.ProductCode // PLV-5331 INÍCIO / FIM
                                                  LIMIT 1
                                                 ];
        System.debug('gerarRetornoParcelamento .. condicoesCobrancas .. '+condicoesCobrancas);
        System.debug('Rogerio parametroVigencia: '+ parametroVigencia.ParcelamentoAposFinalVigencia__c);
        if (parametroVigencia.ParcelamentoAposFinalVigencia__c) {
            //Instaciação se um set de formas de pagamento 
            Set < Id > sFormaPagamento = new Set < Id > ();
            for (CondicaoCobranca__c cond: condicoesCobrancas) {
                sFormaPagamento.add(cond.FormaPagamento__c);
            }
            
            List < ServiceTO.ParcelamentoTO > parcelamentos = new List < ServiceTO.ParcelamentoTO > ();
            
            
            Map < String, Set < PlanoParcelamento__c >> planoMap = new Map < String, Set < PlanoParcelamento__c >> ();
            // VIAG-148 INICIO
            List<PlanoParcelamento__c> Parcela = new List<PlanoParcelamento__c>();
            Parcela = [SELECT Id, FormaPagamento__c,
            CodigoMeioRecebimento__c,
            DescricaoMeioRecebimento__c,
            NumeroParcela__c    
            FROM PlanoParcelamento__c
            WHERE FormaPagamento__c IN: sFormaPagamento
            ORDER BY NumeroParcela__c
           ];
          
                for (PlanoParcelamento__c plano: Parcela) {
                if (!planoMap.containsKey(plano.FormaPagamento__c)) planoMap.put(plano.FormaPagamento__c, new Set < PlanoParcelamento__c > ());
                    planoMap.get(plano.FormaPagamento__c).add(plano);
                }
         
            // VIAG-148 FIM
            //Atribuição das variavéis na tag parcelamento
            Integer opcao;
            for (CondicaoCobranca__c condicao: condicoesCobrancas) {
                System.debug('condicao ' + JSON.serialize(condicao));
                //PLV-3318 - INICIO 
                Decimal perDesconto = condicao.PercentualDescontoAgravo__c;
                System.debug('Rogerio perDesconto: ' + perDesconto);                
                for (String valor: versaocalculo.keySet()) {
                    System.debug('Rogerio valor: ' + valor);
                    if (Decimal.valueOf(valor) == perDesconto) {
                        opcao = versaocalculo.get(valor);
                        System.debug('Rogerio retornoCalculov: ' + retornoCalculov);
                        for (Integer y = 0; y < retornoCalculov.size(); y++) {
                            if (retornoCalculov[y].opcao == opcao) {
                                system.debug('retornoCalculov[y].opcao: '+retornoCalculov[y].opcao);
                                system.debug('opcao: '+opcao);
                                retornoCalculo = retornoCalculov[y];
                                system.debug('retornoCalculo: '+retornoCalculo);
                                break;
                            }
                        }
                        
                    }
                }
                
                List < PlanoParcelamento__c > planoList = new List < PlanoParcelamento__c > (planoMap.get(condicao.FormaPagamento__c));
                
                Decimal valorParcela;
                //PLV-4744 INICIO
                List<String> arrQuantidadeParc = getQtdParcelamento(condicao, hasAgenciamento,orcamento.orcamento.tipoSeguro.equalsIgnoreCase('eds'));//PLV-4666 - INICIO/FIM
                //PLV-4744 FIM
                Integer qtTotal = arrQuantidadeParc.size();
                Integer totalParcelamento;
                Decimal primeiraParcela;
                
                for (Integer x = 0; x < qtTotal; x++) {
                    ServiceTO.ParcelamentoTO parcelamento = new ServiceTO.ParcelamentoTO();
                    
                    totalParcelamento = Integer.ValueOf(arrQuantidadeParc[x]);
                    System.debug('totalParcelamento' + totalParcelamento);
                    //system.debug('retornoCalculo.precificacao.premio.total: '+retornoCalculo.precificacao.premio.total);
                    // II-24-FIX02 INICIO
                    valorParcela = (retornoCalculo.precificacao.premio.total / totalParcelamento).setScale(2,RoundingMode.FLOOR);      
                    // primeiraParcela = (retornoCalculo.precificacao.premio.total - ((totalParcelamento - 1) * (retornoCalculo.precificacao.premio.total / totalParcelamento).SetScale(2))).SetScale(2);
                    primeiraParcela = retornoCalculo.precificacao.premio.total - ((totalParcelamento - 1) * valorParcela); 
                    // valorParcela = (retornoCalculo.precificacao.premio.total / totalParcelamento).setScale(2);
                    // II24-FIX02 FIM               
                    System.debug('valor Parcela '+ valorParcela );
                    system.debug('primeira Parcela' + primeiraParcela);
                    parcelamento.valorPrimeiraParcela = '' + primeiraParcela;
                    //PLV-4960 - INICIO
                    if(produto != null){
                        Decimal premioMin;
                        System.debug('TEsteee++' + mapPremioMinimo.get(condicao.FormaPagamento__r.Codigo__c));
                        premioMin = mapPremioMinimo.get(condicao.FormaPagamento__r.Codigo__c);
                        if(premioMin == null) continue;
                        else if(primeiraParcela < premioMin) continue;
                        else if(valorParcela < premioMin) continue;
                    }
                    //PLV-4960 - FIM
                    parcelamento.qtdParcelas = totalParcelamento;
                    system.debug('>>>planoList'+planoList);
                    parcelamento.meioRecebimentoPrimeiraParcela = '' + planoList[0].CodigoMeioRecebimento__c;
                    if (totalParcelamento > 1) {
                        parcelamento.valorDemaisParcelas = '' + valorParcela;
                        parcelamento.meioRecebimentoDemaisParcelas = '' + planoList[1].CodigoMeioRecebimento__c;
                    }
                    // II24-FIX02 INICIO
                    //TKCL 441 FIX03  INICIO
                    //   System.debug('Segmento ++++' + orcamento.orcamento.segmento);
                    //   System.debug('codigoProdutoVida ++++' + orcamento.orcamento.codigoProdutoVida);
                    //   System.debug('codigoEmpresa ++++' + orcamento.orcamento.codigoEmpresa);
                    //   if(primeiraParcela < valorParcela && MetadataDAO.getInstance().existsInMetadata(orcamento.orcamento.segmento
                    //                                                                                   ,orcamento.orcamento.codigoProdutoVida
                    //                                                                                   ,orcamento.orcamento.codigoEmpresa)//RVI-240-INICIO/FIM
                    //   ){
                    //      parcelamento.valorPrimeiraParcela = '' + valorParcela;
                    //      parcelamento.valorDemaisParcelas = '' + primeiraParcela;
                    //   }
                    //TKCL 441 FIX03  FIM
                    // II24-FIX02 FIM
                    parcelamento.idFormaPagamento = condicao.FormaPagamento__c;
                    parcelamento.juros = Integer.valueof(retornoCalculo.precificacao.juros);
                    parcelamento.iof = retornoCalculo.precificacao.iof;
                    parcelamento.encargos = Integer.valueof(retornoCalculo.precificacao.encargos);
                    //parcelamento.custoapolice = Integer.valueOf(retornoCalculo.precificacao.custoApolice);
                    parcelamento.custoapolice = 0;
                    parcelamento.descricao = condicao.FormaPagamento__r.Name;
                    //PLV-3571 - INÍCIO
                    parcelamento.nomeFormaPagamento = condicao.NomeFormaPagamento__c;
                    //PLV-3571 - FIM
                    //PLV-4344 - Inicio - Ajuste de organizacao do codigo e inserir opcao de antecipacao de comissao para exibicao no portal
                    parcelamento.codigo = Integer.valueOf(condicao.FormaPagamento__r.Codigo__c);
                    parcelamento.agrupamento = condicao.TipoPagamento__c;
                    parcelamento.descontoAgravo = condicao.PercentualDescontoAgravo__c;
                    parcelamento.opcao = opcao;
                    parcelamento.antecipacaoComissao = condicao.AntecipacaoComissao__c;
                    //PLV-4344 - Fim

                    // parcelamento.limiteValorParcela= condicao.LimiteValorParcela__c; // ANNVI-48 - INICIO/FIM
                    
                    parcelamentos.add(parcelamento);
                    
                }
                
            }
            return parcelamentos;
        }

        //Criar código com a lógica necessária
        //Pegar a diferença em dias das vigencias (utilizar MonthsBetween)
        Integer diasDeVigencia = Date.valueOf(orcamento.orcamento.vigenciaInicial).DaysBetween(Date.valueOf(orcamento.orcamento.vigenciaFinal));
        System.debug('RESULT ## 3 ::' + diasDeVigencia);//!
        Integer mesesDeVigencia = DiasDeVigencia / 30;
        System.debug('RESULT ## 4 ::' + mesesDeVigencia);//!
        if (mesesDeVigencia == 0) mesesDeVigencia = 1;
        
        
        //Colocar Forma Pagamento
        Map < Id, List < Integer >> mQuantidadeParcelas = new Map < Id, List < Integer >> ();
        
        for (CondicaoCobranca__c conCobranca: condicoesCobrancas) {
            List < Integer > lParcela;
            if (mQuantidadeParcelas.containsKey(conCobranca.FormaPagamento__c)) {
                lParcela = mQuantidadeParcelas.get(conCobranca.FormaPagamento__c);
            } else {
                lParcela = new List < Integer > ();
            }
            
            for (String parcela: conCobranca.QuantidadeParcelas__c.split(';')) {
                System.debug('RESULT ## 5 ::' + mesesDeVigencia);//!
                if (Integer.valueOf(parcela) <= mesesDeVigencia) {
                    lParcela.add(Integer.valueOf(parcela));
                    System.debug('RESULT ## 6 ::' + lParcela);//!
                }
            }
            if (!lParcela.isEmpty()) {
                mQuantidadeParcelas.put(conCobranca.FormaPagamento__c, lParcela);
            }
        }
        
        //Validar map
        if (mQuantidadeParcelas.isEmpty()) return null;

        system.debug('mapParcelas '+ JSON.serialize(mQuantidadeParcelas));
        
        Map < String, Set < PlanoParcelamento__c >> planoMap = new Map < String, Set < PlanoParcelamento__c >> ();
        // VIAG-148 INICIO
        List<PlanoParcelamento__c> Parcela= new List<PlanoParcelamento__c>();
        Parcela = [SELECT Id, FormaPagamento__c,
        CodigoMeioRecebimento__c,
        DescricaoMeioRecebimento__c,
        NumeroParcela__c
        FROM PlanoParcelamento__c
        WHERE FormaPagamento__c IN: mQuantidadeParcelas.keySet()
        ORDER BY NumeroParcela__c];
        
           for (PlanoParcelamento__c plano: Parcela ) {
                                              
                                              if (!planoMap.containsKey(plano.FormaPagamento__c)) planoMap.put(plano.FormaPagamento__c, new Set < PlanoParcelamento__c > ());
                                              planoMap.get(plano.FormaPagamento__c).add(plano);
                                          }
       
       // VIAG-148 FIM
        List < ServiceTO.ParcelamentoTO > parcelamentos = new List < ServiceTO.ParcelamentoTO > ();
        
        Integer opcao;
        system.debug('plano parcelamento Map '+ JSON.serialize(planoMap));
        System.debug('Ale condicoesCobrancas: ' + condicoesCobrancas);
        System.debug('Ale retornoCalculov[y]: ' + retornoCalculov);
        for (CondicaoCobranca__c condicao: condicoesCobrancas) {
            // RVI-193 - INICIO
            System.debug('Filipe orcamento.orcamento.tipoSeguro ' + orcamento.orcamento.tipoSeguro);
            if(orcamento.orcamento.tipoSeguro != 'Renovacao'){                       
                System.debug('Ale PercentualDescontoAgravo__c: ' + condicao.PercentualDescontoAgravo__c);
                Decimal perDesconto = condicao.PercentualDescontoAgravo__c;
                for (String valor: versaocalculo.keySet()) {
                    System.debug('Ale valor: ' + valor);
                    System.debug('Ale perDesconto: ' + perDesconto);
                    if (Decimal.valueOf(valor) == perDesconto) {
                        opcao = versaocalculo.get(valor);
                        for (Integer y = 0; y < retornoCalculov.size(); y++) {
                            System.debug('Ale opcao: ' + opcao);
                            System.debug('Ale retornoCalculov[y].opcao: ' + retornoCalculov[y].opcao);
                            //mock pra passar orcamento entrando na integradora
                            // retornoCalculov[y].opcao = 1;
                            // opcao = 1;
                            if (retornoCalculov[y].opcao == opcao) {
                                retornoCalculo = retornoCalculov[y];
                                break;
                            }
                        }                    
                    }
                }
            } else {
                retornoCalculo = retornoCalculov[0];
            }
            System.debug('Filipe retornoCalculo ' + retornoCalculo);
            System.debug('Filipe retornoCalculov ' + retornoCalculov);
            // RVI-193 - FIM

            if (planoMap.containsKey(condicao.FormaPagamento__c)) {
                
                List < PlanoParcelamento__c > planoList = new List < PlanoParcelamento__c > (planoMap.get(condicao.FormaPagamento__c));
                
                Decimal valorParcela;
                //PLV-4744 INICIO
                List<String> arrQuantidadeParc = getQtdParcelamento(condicao, hasAgenciamento,orcamento.orcamento.tipoSeguro.equalsIgnoreCase('eds'));//PLV-4666 - INICIO/FIM
                //PLV-4744 FIM                
                Integer qtTotal = arrQuantidadeParc.size();
                Integer totalParcelamento;
                Decimal primeiraParcela;

                //PLV-4668 INICIO
                String segmento  = orcamento.orcamento.segmento;
                String tipoSeguro = orcamento.orcamento.tipoSeguro;

                Decimal limiteParcela = null;
                
                if(segmento.equalsIgnoreCase('individual') && tipoSeguro.equalsIgnoreCase('eds')){ //PLV-4668 FIX2 INICIO/FIM
                    System.debug('###ENDOSSO###');
                    Double premioTotal = retornoCalculo.precificacao.premio.total;
                    
                    if(premioTotal > 0){
                        //System.debug('vigencia final' + orcamento.orcamento.contratoOriginal.vigenciaFinal);

                        Date vigenciaInicial = Date.valueOf(orcamento.orcamento.contratoOriginal.vigenciaInicial);
                        //Date hoje = Date.valueOf(orcamento.orcamento.contratoOriginal.vigenciaFinal);
                        Date hoje = System.today();
                        Date vigenciaFinal = Date.valueOf(orcamento.orcamento.contratoOriginal.vigenciaFinal);
                        Integer diasLimiteVigencia = hoje.DaysBetween(vigenciaFinal);
                        //PLV-4668 FIX INICIO
                        if(diasLimiteVigencia <= 120){
                            limiteParcela = 1;  
                        }else if(diasLimiteVigencia >= 60 ){
                        //PLV-4668 FIX FIM

                            Integer mes = 1;
                            while (vigenciaInicial <= vigenciaFinal) {
                                vigenciaInicial = vigenciaInicial.addMonths(1);
                                if (hoje < vigenciaInicial)
                                        break;
                                mes++;
                            }

                            System.debug(mes);
                            //PLV-5221-INICIO
                            // limiteParcela = 12 - mes - 2;
                            if(condicao.TipoPagamento__c == 'ADC' || condicao.TipoPagamento__c == 'Boleto'){
                                limiteParcela = 12 - mes;
                                System.debug('ADC - Boleto::' + limiteParcela);
                            } else {
                                limiteParcela = 11 - mes;
                                System.debug('Cartão Porto - Demais Bandeiras::' + limiteParcela);
                            }
                            //PLV-5221-FIM
                            
                        }else{
                            limiteParcela = 1;
                        }
                    }else if(premioTotal < 0){
                        limiteParcela = 1;
                    }else{
                        limiteParcela = 0;
                    }
                }
                //PLV-4668 FIM
                
                for (Integer x = 0; x < qtTotal; x++) {

                    if(orcamento.orcamento.meioComercializacao != 'HUB' && condicao.NomeFormaPagamento__c == 'PRIMEIRA COMPRA') continue;//VIAG-222

                    totalParcelamento = Integer.ValueOf(arrQuantidadeParc[x]);
                    
                    if(limiteParcela != null && limiteParcela < totalParcelamento) continue; //PLV-4668 INICIO/FIM
                    
                    if (totalParcelamento <= mesesDeVigencia) {
                        ServiceTO.ParcelamentoTO parcelamento = new ServiceTO.ParcelamentoTO();
                        //System.debug('Rogerio Entrou');
                        //PLV-4203 - Inicio
                        //System.debug('Rogerio retornoCalculo: ' + retornoCalculo);
                        //System.debug('Rogerio precificacao: ' + retornoCalculo.precificacao);
                        //System.debug('Rogerio premio: ' + retornoCalculo.precificacao.premio);
                        //System.debug('Rogerio total: ' + retornoCalculo.precificacao.premio.total);
                        //System.debug('Rogerio totalParcelamento: ' + totalParcelamento);
                        
                        // RVI-193 - INICIO
                        // System.debug('totalParcelamentoFilipe: ' + totalParcelamento);
                        // System.debug('retornoCalculoFilipe: ' + retornoCalculo);
                        // if(retornoCalculo != null){
                            // II-24 INICIO
                              // primeiraParcela = (retornoCalculo.precificacao.premio.total - ((totalParcelamento - 1) * (retornoCalculo.precificacao.premio.total / totalParcelamento).SetScale(2))).SetScale(2);
                              // System.debug('totalParcelamentoFilipe: ' + totalParcelamento);
                              // System.debug('retornoCalculoFilipe: ' + retornoCalculo);
                            // II-24 FIM
                            System.debug('Rogerio retornoCalculo: ' + retornoCalculo);
                            //System.debug('Rogerio primeiraParcela: ' + primeiraParcela);
                            //PLV-4203 - Fim
                            // II-24 INICIO
                            // II-24-FIX01 INICIO
                            // valorParcela = MetadataDAO.getInstance().existsInMetadata(orcamento.orcamento.segmento
                            //                                                           ,orcamento.orcamento.codigoProdutoVida
                            //                                                          ,codigoEmpresa)  // II-24 INICIO/FIM
                            //                && condicao.FormaPagamento__r.Codigo__c == '70'
                            // ? (retornoCalculo.precificacao.premio.total / totalParcelamento).setScale(2,RoundingMode.FLOOR)
                            // : (retornoCalculo.precificacao.premio.total / totalParcelamento).setScale(2).setScale(2);
                            System.debug('totalParcelamento henrique : ' +  totalParcelamento);
                            System.debug( 'retornoCalculo.precificacao.premio.total Henrique: ' + retornoCalculo.precificacao.premio.total);
                            valorParcela = (retornoCalculo.precificacao.premio.total / totalParcelamento).setScale(2,RoundingMode.FLOOR);
                           // II-24-FIX01 FIM
                            System.debug('HENRIQUE valorParcela: ' + valorParcela);

                            primeiraParcela = retornoCalculo.precificacao.premio.total - ((totalParcelamento - 1) * valorParcela);
                            System.debug('HENRIQUE PRIMEIRA PARCELA: ' + primeiraParcela);
                            System.debug('HENRIQUE PREMIO TOTAL: ' + retornoCalculo.precificacao.premio.total);
                            System.debug('totalParcelamentoFilipe: ' + totalParcelamento);
                            System.debug('retornoCalculoFilipe: ' + retornoCalculo);
                            //TKCL 441 FIX03  INICIO
                            // Decimal auxiliar = null;
                            // if(primeiraParcela < valorParcela && orcamento.orcamento.codigoProdutoVida == 'APTLMKT' && condicao.FormaPagamento__r.Codigo__c == '70'){
                            //     auxiliar = primeiraParcela;
                            //     primeiraParcela = valorParcela;
                            //     valorParcela = auxiliar;
                            //     System.debug('Rogerio Passou');
                            // }
                            //TKCL 441 FIX03  FIM
                            // II-24 FIM
                        // }
                        // RVI-193 - FIM

                        //PLV-4960 - INICIO
                        if(produto != null){
                            Decimal premioMin;
                            premioMin = mapPremioMinimo.get(condicao.FormaPagamento__r.Codigo__c);
                            if(premioMin == null) continue;
                            else if(primeiraParcela < premioMin) continue;
                            else if(valorParcela < premioMin) continue;
                        }
                        //PLV-4960 - FIM
                        parcelamento.valorPrimeiraParcela = '' + primeiraParcela;
                        parcelamento.qtdParcelas = totalParcelamento;
                        parcelamento.meioRecebimentoPrimeiraParcela = '' + planoList[0].CodigoMeioRecebimento__c;
                        if (totalParcelamento > 1) {
                            parcelamento.valorDemaisParcelas = '' + valorParcela;
                            parcelamento.meioRecebimentoDemaisParcelas = '' + planoList[1].CodigoMeioRecebimento__c;
                        }
                        
                        parcelamento.idFormaPagamento = condicao.FormaPagamento__c;
                        parcelamento.juros = Integer.valueof(retornoCalculo.precificacao.juros);
                        parcelamento.iof = retornoCalculo.precificacao.iof;
                        parcelamento.encargos = Integer.valueof(retornoCalculo.precificacao.encargos);
                        parcelamento.custoapolice = 0;
                        parcelamento.descricao = condicao.FormaPagamento__r.Name;
                        parcelamento.codigo = Integer.valueOf(condicao.FormaPagamento__r.Codigo__c);
                        parcelamento.agrupamento = condicao.TipoPagamento__c;
                        parcelamento.descontoAgravo = condicao.PercentualDescontoAgravo__c;
                        parcelamento.opcao = opcao;
                        parcelamento.nomeFormaPagamento = condicao.NomeFormaPagamento__c; //PLV-4203 - Inicio/Fim - Inserir nome da forma de pagamento
                        parcelamento.antecipacaoComissao = condicao.AntecipacaoComissao__c; //PLV-4344 - Inicio/Fim - Inserir opcao de antecipacao de comissao para exibicao no portal
                        
                        // parcelamento.limiteValorParcela = condicao.LimiteValorParcela__c; // ANNVI-48 - INICIO/FIM

                        parcelamentos.add(parcelamento);
                    }
                    
                }
                
            }
        }
        return parcelamentos;
    }
    
    private ServiceTO.RetornoAceitacaoTO gerarRetornoCriticasODM(EmissaoTO.OfertasTO oferta){
        ServiceTO.RetornoAceitacaoTO retornoCriticas = new ServiceTO.RetornoAceitacaoTO();
        List<ServiceTO.AnaliseTO> analises = new List<ServiceTO.AnaliseTO>();
        List<ServiceTO.AvisoTO> avisos = new List<ServiceTO.AvisoTO>();
        List<ServiceTO.RecusaTO> recusas = new List<ServiceTO.RecusaTO>();
        List<ServiceTO.PendenciaTO> pendencias = new List<ServiceTO.PendenciaTO>();
        //PLV-4260 - INICIO - PEDRO AUGUSTO - SYS4B
        List<ServiceTO.DecisaoTO> decisoes = new List<ServiceTO.DecisaoTO>();
        //PLV-4260 - FIM - PEDRO AUGUSTO - SYS4B
        
        if(oferta.retornoAceitacao == null) return retornoCriticas;
        
        if(oferta.retornoAceitacao.analises != null){
            for(EmissaoTO.AnaliseTO analise : oferta.retornoAceitacao.analises){
                ServiceTO.MensagenTO mensagem = new ServiceTO.MensagenTO();
                ServiceTO.AnaliseTO vAnalise = new ServiceTO.AnaliseTO();
                //PLV-4698 INICIO
                mensagem.cliente = analise.mensagens != null && analise.mensagens.cliente != null ? analise.mensagens.cliente : 'Oferta indisponível, em análise pela organização';
                vAnalise.descricao = analise.descricao;
                vAnalise.codigo = analise.codigo;
                //PLV-4698 FIM 
                vAnalise.mensagens = mensagem;
                analises.add(vAnalise);
            }
        }
        
        if(oferta.retornoAceitacao.avisos != null){
            for(EmissaoTO.AvisoTO aviso : oferta.retornoAceitacao.avisos){
                ServiceTO.MensagenTO mensagem = new ServiceTO.MensagenTO();
                ServiceTO.AvisoTO vAviso = new ServiceTO.AvisoTO();
                //PLV-4698 INICIO
                mensagem.cliente = aviso.mensagens != null && aviso.mensagens.cliente != null ? aviso.mensagens.cliente : 'Oferta indisponível, em análise pela organização';
                vAviso.descricao = aviso.descricao;
                vAviso.codigo = aviso.codigo;
                //PLV-4698 FIM
                vAviso.mensagens = mensagem;
                avisos.add(vAviso);
            }
        }
        
        if(oferta.retornoAceitacao.pendencias != null){
            for(EmissaoTO.PendenciaTO pendencia : oferta.retornoAceitacao.pendencias){
                ServiceTO.MensagenTO mensagem = new ServiceTO.MensagenTO();
                ServiceTO.PendenciaTO vPendencia = new ServiceTO.PendenciaTO();
                //PLV-4698 INICIO
                mensagem.cliente = pendencia.mensagens != null && pendencia.mensagens.cliente != null ? pendencia.mensagens.cliente : 'Oferta indisponível, em análise pela organização';
                vPendencia.descricao = pendencia.descricao;
                vPendencia.codigo = pendencia.codigo;
                //PLV-4698 FIM
                vPendencia.mensagens = mensagem;
                pendencias.add(vPendencia);
            }
        }
        
        if(oferta.retornoAceitacao.recusas != null){
            for(EmissaoTO.RecusaTO recusa : oferta.retornoAceitacao.recusas){
                ServiceTO.MensagenTO mensagem = new ServiceTO.MensagenTO();
                ServiceTO.RecusaTO vRecusa = new ServiceTO.RecusaTO();
                //PLV-4698 INICIO
                mensagem.cliente = recusa.mensagens != null && recusa.mensagens.cliente != null ? recusa.mensagens.cliente : 'Oferta indisponível, em análise pela organização';
                vRecusa.descricao = recusa.descricao;
                vRecusa.codigo = recusa.codigo;
                //PLV-4698 FIM
                vRecusa.mensagens = mensagem;
                recusas.add(vRecusa);
            }
        }
        //PLV-4260 - INICIO - PEDRO AUGUSTO - SYS4B
        if(oferta.retornoAceitacao.decisoes != null){
            for(EmissaoTO.DecisaoTO Edecisoes : oferta.retornoAceitacao.decisoes){
                ServiceTO.DecisaoTO vdecisoes = new ServiceTO.DecisaoTO();
                vdecisoes = (ServiceTO.DecisaoTO) JSON.deserialize(JSON.serialize(Edecisoes),ServiceTO.DecisaoTO.class);
                //PLV-4698 INICIO
                vdecisoes.descricao = Edecisoes.descricao;
                vdecisoes.codigo = Edecisoes.codigo;
                //PLV-4698 FIM
                
                decisoes.add(vdecisoes);
            }
        }
        //PLV-4260 - FIM - PEDRO AUGUSTO - SYS4B

        retornoCriticas.analises = analises;
        retornoCriticas.avisos = avisos;
        retornoCriticas.recusas = recusas;
        retornoCriticas.pendencias = pendencias;
        retornoCriticas.decisoes = decisoes;
        return retornoCriticas;
        
    }
    //VIAG-148 INICIO-FIM
    private void gerarRetornoRegras(ServiceTO.OfertaTO retorno, EmissaoTO.OfertasTO oferta, Product2 prodPrec){
        
        system.debug('retorno> ' + retorno);
        system.debug('oferta> ' + oferta);
        List<String> coberturasLideres = new List<String>();
        List<ServiceTO.CoberturaRetornoOfertaTO> coberturas = new List<ServiceTO.CoberturaRetornoOfertaTO>();
        // 4104 - inicio
        Decimal valorSugestaoOfertaMAP;
        Decimal valorSugestaoOfertaBAS;
        Decimal novoValor;

        List<Profissao__c> profissoes = new List<Profissao__c>();
        Set<String> coberturasfiltro = new set<String>();
        
        Map<String,String> coberturaFranquia = new Map<String,String>(); //PLV-4887 - INICIO/FIM
        
        
        if(oferta.orcamento.contratantes[0].grupos[0].segurados != null){	
            System.debug('oferta.orcamento.contratantes.isEmpty(): '+ oferta.orcamento.contratantes.isEmpty());
            if(oferta.orcamento.contratantes.isEmpty()) return;
            
            List<EmissaoTO.ContratanteTO> contratantes = oferta.orcamento.contratantes;
            
            List<EmissaoTO.GrupoTO> grupos = new List<EmissaoTO.GrupoTO>();
            for(EmissaoTO.ContratanteTO contratante: contratantes){
                if(contratante.grupos.isEmpty()) continue;
                grupos.addAll(contratante.grupos);
            }
            
            if(grupos.isEmpty()) return;
            
            List<EmissaoTO.SeguradoTO> segurados = new List<EmissaoTO.SeguradoTO>();
            for(EmissaoTO.GrupoTO grupo: grupos){
                if(grupo.segurados != null){
                    if(grupo.segurados.isEmpty()) continue;           
                    segurados.addAll(grupo.segurados);
                }
            }
            if(segurados.isEmpty()) return;
            List<EmissaoTO.PessoaTO> pessoa = new List<EmissaoTO.PessoaTO>();
            for(EmissaoTO.SeguradoTO segurado: segurados){
                if(segurado.pessoa != null){
                    pessoa.add(segurado.pessoa);
                }
            }
            List<EmissaoTO.DadosPessoaFisicaTO> dadosPessoaFisica = new  List<EmissaoTO.DadosPessoaFisicaTO>  ();
         //VIAG-148 INICIO
            for(EmissaoTO.PessoaTO p: pessoa){
                if(p.dadosPessoaFisica != null){
                    dadosPessoaFisica.add(p.dadosPessoaFisica);
                }
            }
             
            String codigoProfissao;
           
            if (oferta.orcamento.segmento != 'Viagem') {
                for(EmissaoTO.DadosPessoaFisicaTO dados: dadosPessoaFisica){
                    if(dados.profissao !=null){
                        codigoProfissao = dados.profissao;
                    }
                }
           

                if(codigoProfissao != '') profissoes = [SELECT Id, Limite_de_capital_maximo__c,LimiteCapital__c  FROM Profissao__c WHERE Status__c ='Ativo' AND CodigoProfissao__c =: codigoProfissao];//VIDA-175 INICIO/FIM

            }
           // VIAG-148 FIM 

            List<EmissaoTO.CoberturaTO> coberturasSegurado = new List<EmissaoTO.CoberturaTO>();
            for(EmissaoTO.SeguradoTO segurado: segurados){
                if(segurado.coberturas.isEmpty()) continue;
                coberturasSegurado.addAll(segurado.coberturas);
            }
            
            //PLV-4840 INICIO
            if(!coberturasSegurado.isEmpty()){
                for(EmissaoTO.CoberturaTO cobertura : coberturasSegurado){
                    coberturasfiltro.add(cobertura.sigla);
                    if(cobertura.franquia!=null)  coberturaFranquia.put(cobertura.sigla,cobertura.franquia); //PLV-4887 - INICIO/FIM
                }
            }
            //PLV-4840 FIM
        }
		// 4104 - fim 
        
        GarantiaProduto__c garantiaProduto = null;
        //PLV-4319-VI - INICIO
        //MAPEAR QUEM SÃO AS FRANQUIAS A SEREM INPUTADAS NAS COBERTURAS
        
        // PLV-5331 VIAG-148 INÍCIO
      // ProductDAO produtoDao = ProductDAO.getInstance();
     //  Product2 prodPrec = produtoDao.buscProdPrecDtCalc(oferta.orcamento.codigoProdutoVida, oferta.orcamento.idProdutoSf);
      // VIAG -148 FIM 
      
          
       
       
       
        // PLV-5331 FIM
        Id profissaoId = oferta.orcamento.segmento != 'Viagem' ? (!profissoes.isEmpty() ? profissoes.get(0).Id : null) : null; //VIDA-175 INICIO-FIM

        // VIAG -148 FIM
        // List<GarantiaProduto__c> listGarantiaProduto = GarantiaProdutoDAO.getInstance().buscaGarantiasProdutos(new Set<String>{oferta.orcamento.codigoProdutoVida}, profissaoId); // PLV-5331 INÍCIO / FIM
        List<GarantiaProduto__c> listGarantiaProduto = GarantiaProdutoDAO.getInstance().buscaGarantiasProdutos(new Set<String>{prodPrec.ProductCode}, profissaoId); // PLV-5331 INÍCIO / FIM
        //PLV-4831 - FIM
        //VIDA-175 - INICIO
        Set<Id> setIdGarantias = new Set<Id>();
        for (GarantiaProduto__c garantia : listGarantiaProduto) {
            if (garantia.Id != null) {
                setIdGarantias.add(garantia.Id);
            }
        }
        //VIDA-175 - FIM

        // VIAG-148 INICIO
       List<FranquiaGarantia__c> listFranquiaGarantia = GarantiaProdutoDAO.getInstance().buscarGarantiasProdutolistFranquiaGarantia(setIdGarantias);

       List<CarenciaGarantia__c> listCarenciaGarantia = GarantiaProdutoDAO.getInstance().buscarGarantiasProdutolistCarenciaGarantia(setIdGarantias);

       // VIAG-148 FIM
       /*
        List<FranquiaGarantia__c> listFranquiaGarantia = [SELECT Id
                                                                , GarantiaProduto__c
                                                                , Franquia_padrao__c
                                                                , Franquia__r.Descricao__c
                                                                , Franquia__r.CodigoFranquia__c
                                                            FROM FranquiaGarantia__c
                                                            WHERE GarantiaProduto__c IN: setIdGarantias];
        System.debug('Rogerio listFranquiaGarantia: ' + listFranquiaGarantia);                                                   
        List<CarenciaGarantia__c> listCarenciaGarantia = [SELECT Id
                                                                , GarantiaProduto__c
                                                                , Carencia__r.Descricao__c
                                                                , Carencia__r.CodigoCarencia__c
                                                            FROM CarenciaGarantia__c
                                                            WHERE GarantiaProduto__c IN: setIdGarantias];
       
        */
        Map<String,List<FranquiaGarantia__c>> garantiaprodutoFranquias = new Map<String,List<FranquiaGarantia__c>>();
        Map<String,List<CarenciaGarantia__c>> garantiaprodutoCarencias = new Map<String,List<CarenciaGarantia__c>>();
        
        for(FranquiaGarantia__c fr : listFranquiaGarantia){
            if(!garantiaprodutoFranquias.containsKey(fr.GarantiaProduto__c)) {
                System.debug('Rogerio EntrouNoIF: ' + listFranquiaGarantia);
                garantiaprodutoFranquias.put(fr.GarantiaProduto__c, new List<FranquiaGarantia__c>()); 
            }
            System.debug('Rogerio EntrouNoElse: ' + listFranquiaGarantia);
            garantiaprodutoFranquias.get(fr.GarantiaProduto__c).add(fr);
        }
        for(CarenciaGarantia__c cg : listCarenciaGarantia){
            if(!garantiaprodutoCarencias.containsKey(cg.GarantiaProduto__c)) {
                garantiaprodutoCarencias.put(cg.GarantiaProduto__c, new List<CarenciaGarantia__c>()); 
            }
            garantiaprodutoCarencias.get(cg.GarantiaProduto__c).add(cg);
        }
        // VIAG-148 INICIO-FIM
        List<GarantiaRelacionada__c> garantiasRelacionadas = GarantiaProdutoDAO.getInstance().buscarGarantiasProdutolistGarantiaRelacionada(setIdGarantias);

        //INICIO - PLV-4831
        /*
        List<GarantiaRelacionada__c> garantiasRelacionadas = [
        SELECT
        Id,
        Name, 
        GarantiaProduto__r.Garantia__r.Name, 
        GarantiaProduto__r.Garantia__r.Sigla__c,
        TipoDependencia__c, 
        GarantiaProduto__c,
        GarantiaRelacionada__r.Garantia__r.Name,
        GarantiaRelacionada__r.Garantia__r.Sigla__c
        FROM GarantiaRelacionada__c
        WHERE GarantiaProduto__c IN: setIdGarantias];
        system.debug('Guilherme> ' + garantiasRelacionadas);
       */

        //PLV-4840 INICIO
        Integer idade;

        try {
            idade = ValidaRegrasGarantiaSniper.converterDataComtracosParaIdade( oferta.orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.dataNascimento);
       } catch (Exception e) {}
        //PLV-4840 FIM
        //FIM - PLV-4831
        // cria nó de regras
        for(GarantiaProduto__c garantia : listGarantiaProduto){

            //PLV-4840 INICIO
            // if(idade != null){
            if(idade != null && oferta.orcamento.tipoSeguro == 'Novo'){//RVI-165-INICIO/FIM //FNPVVEP-83 INICIO/FIM
                if(garantia.LimiteIdadeMinimo__c > idade || garantia.LimiteIdadeMaximo__c < idade){
                    continue;
                }
            }
            //PLV-4840 FIM


            //PLV-4319-VI - FIM
            if(garantia.Produto__r.Status__c!='Ativo') continue;
            system.debug('garantia:::::: '+garantia);
            if(garantiaProduto == null){
                garantiaProduto = garantia;
            }else if(garantia.CaracteristicaGarantia__c == 'Principal'){
                if(garantia.OrdemPrioridade__c < garantiaProduto.OrdemPrioridade__c){
                    garantiaProduto = garantia;
                }else if(garantiaProduto.CaracteristicaGarantia__c != 'Principal'){
                    garantiaProduto = garantia;
                }
            }else if(garantiaProduto.CaracteristicaGarantia__c != 'Principal'){
                if(garantia.OrdemPrioridade__c < garantiaProduto.OrdemPrioridade__c){
                    garantiaProduto = garantia;
                }
            }
            
            if(garantia.CaracteristicaGarantia__c == 'Principal')
             {
                coberturasLideres.add(garantia.Garantia__r.Sigla__c);
            }
            
            ServiceTO.CoberturaRetornoOfertaTO cobertura = new ServiceTO.CoberturaRetornoOfertaTO();
            cobertura.sigla         = garantia.Garantia__r.Sigla__c;
            // PLV-4116 - INICIO
            cobertura.caracteristica = garantia.CaracteristicaGarantia__c;
            // PLV-4116 - FIM
            cobertura.agrupamento = garantia.AgrupamentoCoberturas__c;//VIAG-265 - INICIO/FIM     
            cobertura.tipoGarantia  = garantia.TipoGarantia__c; //PLV-4325 - INICIO/FIM - Campo incluido no json de retorno
            cobertura.prioridade    = garantia.OrdemPrioridade__c;
            cobertura.nome          = garantia.Garantia__r.Name;
            cobertura.tipo          = garantia.TipoLimiteCapital__c;
            cobertura.obrigatorio   = garantia.Obrigatoria__c;
            cobertura.ramo          = garantia.RamoSeguro__r.Codigo__c;//PLV-4416 - INICIO/FIM
            cobertura.formaExibicaoCapital = garantia.FormaExibicaoCapital__c; //II-139 INICIO-FIM
            //PLV-4869 - FIX 1 INÍCIO
            cobertura.includentes = new List<String>(); 
            cobertura.excludentes = new List<String>(); 
            for(GarantiaRelacionada__c tipoGarantiaRelacionada :garantiasRelacionadas) {
               if(tipoGarantiaRelacionada.GarantiaProduto__r.Garantia__r.Sigla__c == cobertura.sigla && tipoGarantiaRelacionada.TipoDependencia__c == 'Includente') {
                   //PLV-4869 - FIX 4 INÍCIO
                    if(!cobertura.includentes.contains(tipoGarantiaRelacionada.GarantiaRelacionada__r.Garantia__r.Sigla__c)){
                        cobertura.includentes.add(tipoGarantiaRelacionada.GarantiaRelacionada__r.Garantia__r.Sigla__c);
                    }
                }
                if(tipoGarantiaRelacionada.GarantiaProduto__r.Garantia__r.Sigla__c == cobertura.sigla && tipoGarantiaRelacionada.TipoDependencia__c == 'Excludente') {
                    if(!cobertura.excludentes.contains(tipoGarantiaRelacionada.GarantiaRelacionada__r.Garantia__r.Sigla__c)){
                        cobertura.excludentes.add(tipoGarantiaRelacionada.GarantiaRelacionada__r.Garantia__r.Sigla__c);
                    }
                    //PLV-4869 - FIX 4 FIM
                } 
            }
            //PLV-4869 - FIX 1 FIM

            //PLV - 4104 inicio
            //PLV-4319-VI - INICIO
            cobertura.filtrada = oferta.orcamento.segmento == 'Viagem' ? true : oferta.orcamento.segmento=='Individual' ? coberturasfiltro.contains(garantia.Garantia__r.Sigla__c) : false;
            if(String.isNotBlank(garantia.TipoCaracteristicaEspecial__c)){
                ServiceTO.CaracteristicaEspecialTO caracteristicaespecial = new ServiceTO.CaracteristicaEspecialTO();
                caracteristicaespecial.limiteMinimo       = garantia.LimiteMinimoCaracteristicaEspecial__c;
                caracteristicaespecial.limiteMaximo       = garantia.LimiteMaximoCaracteristicaEspecial__c;
                caracteristicaespecial.tipo               = garantia.TipoCaracteristicaEspecial__c;
                cobertura.caracteristicaespecial = caracteristicaespecial;
            }
            
            if(garantiaprodutoFranquias.containsKey(garantia.Id)){
                System.debug('Rogerio EntrouAQUI: ');
                cobertura.franquias = new List<ServiceTO.FranquiaTO>();
                for(FranquiaGarantia__c fg : garantiaprodutoFranquias.get(garantia.Id)){
                    ServiceTO.FranquiaTO franquiaToadd = new ServiceTO.FranquiaTO();
                    franquiaToadd.padrao = fg.Franquia_padrao__c;
                    franquiaToadd.descricao = fg.Franquia__r.Descricao__c;
                    franquiaToadd.valor = fg.Franquia__r.CodigoFranquia__c;
                    franquiaToadd.selecionado = coberturaFranquia.containsKey(garantia.Garantia__r.Sigla__c) ? coberturaFranquia.get(garantia.Garantia__r.Sigla__c) ==  fg.Franquia__r.CodigoFranquia__c : fg.Franquia_padrao__c; //PLV-4887 - INICIO/FIM
                    franquiaToadd.name = fg.Franquia__r.Name; //II-73
                    cobertura.franquias.add(franquiaToadd);
                }
                System.debug('Rogerio cobertura.franquias: '+ cobertura.franquias);
            }
            if(garantiaprodutoCarencias.containsKey(garantia.Id)){
                cobertura.carencias = new List<ServiceTO.CarenciaTO>();
                for(CarenciaGarantia__c cg : garantiaprodutoCarencias.get(garantia.Id)){
                    ServiceTO.CarenciaTO carenciaToAdd = new ServiceTO.CarenciaTO();
                    //carenciaToAdd.padrao = cg.Carencia_padrao__c;//AINDA NÃO TEM O CAMPO PARA FALAR QUAL É A PADRÃO
                    carenciaToAdd.descricao = cg.Carencia__r.Descricao__c;
                    carenciaToAdd.valor = cg.Carencia__r.CodigoCarencia__c;
                    cobertura.carencias.add(carenciaToAdd);
                }
            }
            //PLV-4319-VI - FIM
            
            //PLV-4549 - Inicio - Ajuste de indentacao
            System.debug('profissao size: '+ profissoes.size());
            if(profissoes!=null && profissoes.size() > 0){ //PLV-4854-FIX2 - INICIO/FIM
                for(Profissao__c p: profissoes){
                    if(p.LimiteCapital__c == null){
                        p.LimiteCapital__c = 0;
                    }
                    //Cenário 1
                    if(p.Limite_de_capital_maximo__c >= garantia.LimiteCapitalMinimo__c && p.Limite_de_capital_maximo__c <= garantia.LimiteCapitalMaximo__c){       
                       cobertura.limiteMaximo = p.Limite_de_capital_maximo__c;
                       novoValor = p.Limite_de_capital_maximo__c;
                       
                    //Cenário 2    
                    }else if(p.Limite_de_capital_maximo__c >= garantia.LimiteCapitalMinimo__c && p.Limite_de_capital_maximo__c <= garantia.LimiteCapitalMaximo__c){
                        cobertura.limiteMaximo  = p.Limite_de_capital_maximo__c;

                    //Cenário 3
                    }else if(p.Limite_de_capital_maximo__c > garantia.LimiteCapitalMaximo__c){
                        cobertura.limiteMaximo = garantia.LimiteCapitalMaximo__c;
                    
                    //Cenário 4    
                    }else if(p.Limite_de_capital_maximo__c < garantia.LimiteCapitalMinimo__c ){
                        //erro                                        
                    }
                    cobertura.limiteMinimo  = garantia.LimiteCapitalMinimo__c;
                }
            }else{
                cobertura.limiteMinimo  = garantia.LimiteCapitalMinimo__c;
                cobertura.limiteMaximo  = garantia.LimiteCapitalMaximo__c;
            }
            //PLV-4549 - Fim - Ajuste de indentacao
	    //PLV - 4104 fim 	
            cobertura.descricao = garantia.Garantia__r.Descricao__c;
            
            coberturas.add(cobertura);
        }

        
        retorno.regras = new ServiceTO.RegrasRetornoOfertaTO();
        retorno.regras.coberturasLideres = coberturasLideres;
        retorno.regras.coberturas        = coberturas;
        
        if(oferta.orcamento.contratantes[0].grupos[0].segurados != null){	
            if(oferta.orcamento.contratantes.isEmpty()) return;
            
            List<EmissaoTO.ContratanteTO> contratantes = oferta.orcamento.contratantes;
            
            List<EmissaoTO.GrupoTO> grupos = new List<EmissaoTO.GrupoTO>();
            for(EmissaoTO.ContratanteTO contratante: contratantes){
                if(contratante.grupos.isEmpty()) continue;
                grupos.addAll(contratante.grupos);
            }
            
            if(grupos.isEmpty()) return;
            
            List<EmissaoTO.SeguradoTO> segurados = new List<EmissaoTO.SeguradoTO>();
            for(EmissaoTO.GrupoTO grupo: grupos){
                if(grupo.segurados != null){
                    if(grupo.segurados.isEmpty()) continue;           
                    segurados.addAll(grupo.segurados);
                }
            }
            
            if(segurados.isEmpty()) return;
            
            List<EmissaoTO.CoberturaTO> coberturasSegurado = new List<EmissaoTO.CoberturaTO>();
            for(EmissaoTO.SeguradoTO segurado: segurados){
                if(segurado.coberturas.isEmpty()) continue;
                coberturasSegurado.addAll(segurado.coberturas);
            }
            
            if(coberturasSegurado.isEmpty()) return;
            
            /* // PLV-4797 INICIO  SYS4B ODEMIR -- CODIGO COMENTADO  POIS NAO VAI USAR MAIS PRODUTO RELACIONADO A PERGUNTAS
            Map<String,Double> mapSiglaCapital = new Map<String,Double>();
            for(EmissaoTO.CoberturaTO coberSeg: coberturasSegurado){
                
                mapSiglaCapital.put(coberSeg.sigla, coberSeg.valor);
            }
            //Buscar questionários atrelados ao produto
            //PLV-4260 - INICIO - PEDRO AUGUSTO - SYS4B
            List<QuestionarioProduto__c> questionario = null;
            if(oferta.orcamento.segmento=='Viagem'){
                questionario = [SELECT    id, Questionario__c,Questionario__r.Codigo__c, GarantiaProduto__r.Garantia__r.Sigla__c,
                                                          Prioridade__c
                                                          FROM      QuestionarioProduto__c 
                                                          WHERE     Produto__r.ProductCode =: oferta.orcamento.codigoProdutoVida  
                                                          AND       LimiteCapitalMinimo__c <= :mapSiglaCapital.values() 
                                                          AND       LimiteCapitalMaximo__c >= :mapSiglaCapital.values()
                                                          AND       GarantiaProduto__r.Garantia__r.Sigla__c IN :mapSiglaCapital.keySet()
                                                          ORDER BY  Prioridade__c ASC
                                                          LIMIT 1
                                                         ];
            }else{
                //PLV-4698 QUEST - INÍCIO
                List<String> codigoQuestionario = new List<String>(); 
                if(oferta.retornoAceitacao.decisoes!=null){
                    for(EmissaoTO.DecisaoTO decisao : oferta.retornoAceitacao.decisoes){
                        if(decisao.tipo=='RISCO'){
                            codigoQuestionario.add(decisao.acao); 
                        }
                    }
                }
                if(codigoQuestionario != null && !codigoQuestionario.isEmpty()){
                questionario = [SELECT    id, Questionario__c,Questionario__r.Codigo__c, GarantiaProduto__r.Garantia__r.Sigla__c,
                                                          Prioridade__c
                                                          FROM      QuestionarioProduto__c 
                                                          WHERE     Produto__r.ProductCode =: oferta.orcamento.codigoProdutoVida  
                                                          AND       GarantiaProduto__r.Garantia__r.Sigla__c IN :mapSiglaCapital.keySet()
                                                          AND Questionario__r.Codigo__c IN :codigoQuestionario
                                                          ORDER BY  Prioridade__c ASC
                                                          LIMIT 1
                                                         ];
                }
               //PLV-4698 QUEST - FIM
            }
            //PLV-4260 - FIM - PEDRO AUGUSTO - SYS4B
            //PLV-4260 - FIX 02/10/2020  - INICIO
            if(questionario!=null && !questionario.isEmpty()){
                System.debug('questionario[0].Questionario__c> ' + questionario[0].Questionario__c);
                List<PerguntaQuestionario__c> pergQuest = new List<PerguntaQuestionario__c>();
                pergQuest = [ SELECT  Id, Pergunta__r.Pergunta__c, Pergunta__r.TipoResposta__c, 
                             Pergunta__r.OpcoesResposta__c, 
                             Obrigatorio__c, // PLV-4797 INICIO/FIM SYS4B
                             ProximaPergunta__c, numero__c //PLV-4771 - INÍCIO/FIM
                             FROM    PerguntaQuestionario__c 
                             WHERE   Questionario__c = :questionario[0].Questionario__c];
            
                List<ServiceTO.QuestionarioTO> questTO = new List<ServiceTO.QuestionarioTO>();
                
                for(PerguntaQuestionario__c perguntaQuest: pergQuest){
                    ServiceTO.QuestionarioTO quest = new ServiceTO.QuestionarioTO();
                    quest.idPergunta = perguntaQuest.Id;
                    quest.pergunta = perguntaQuest.Pergunta__r.Pergunta__c;
                    quest.tipoResposta = perguntaQuest.Pergunta__r.TipoResposta__c;
                    quest.opcoesRespostas = perguntaQuest.Pergunta__r.OpcoesResposta__c;
                    //PLV-4771 - INÍCIO
                    //quest.proximaPergunta = perguntaQuest.ProximaPergunta__c; 
                    quest.ordenacao = perguntaQuest.numero__c;
                    System.debug('pergunta> ' + quest);
                    //PLV-4771 - FIM
                    quest.obrigatorio = perguntaQuest.obrigatorio__c; // PLV-4797 INICIO/FIM SYS4B ODEMIR
                    questTO.add(quest);
                }
            
                //add questionarios nas regras da oferta
                retorno.regras.questionarios = questTO;
                //PLV-4260 - INICIO - PEDRO AUGUSTO - SYS4B
                retorno.regras.idquestionario = !questionario.isEmpty() ? questionario[0].Questionario__c : null;
                //PLV-4260 - FIM - PEDRO AUGUSTO - SYS4B
            }else{
                 retorno.regras.questionarios = new List<ServiceTO.QuestionarioTO>();
                 retorno.regras.idquestionario = null;
            }//PLV-4260 - FIX 02/10/2020  - FIM

            */  // PLV-4797 FIM  SYS4B ODEMIR -- CODIGO COMENTADO  POIS NAO VAI USAR MAIS PRODUTO RELACIONADO A PERGUNTAS

            // PLV-4797 INICIO SYS4B ODEMIR

            List<ServiceTO.QuestionarioTO> questTO = new List<ServiceTO.QuestionarioTO>();
            retorno.regras.idquestionario = null;
            retorno.regras.questionarios = questTO;
            List<String> codigoQuestionario = new List<String>(); 
            if(oferta?.retornoAceitacao?.decisoes!=null){
                for(EmissaoTO.DecisaoTO decisao : oferta.retornoAceitacao.decisoes){
                    if(decisao.tipo=='RISCO'){
                        codigoQuestionario.add(decisao.acao); 
                    }
                }
            }
            if(codigoQuestionario != null && !codigoQuestionario.isEmpty()){
              // VIAG-148 INICIO
              List <PerguntaQuestionario__c> PerguntaQ = new List <PerguntaQuestionario__c>();
              PerguntaQ = [ SELECT  Id, Pergunta__r.Pergunta__c, Pergunta__r.TipoResposta__c, 
              Pergunta__r.OpcoesResposta__c,
              justificarPergunta__c, // ANNVI-17 INICIO/FIM 
              Obrigatorio__c, // PLV-4797 INICIO/FIM SYS4B
              Questionario__c,
              Questionario__r.Codigo__c, //PLV-4790 INICIO/FIM
              ProximaPergunta__c, numero__c //PLV-4771 - INÍCIO/FIM
              FROM    PerguntaQuestionario__c 
              WHERE   Questionario__r.Codigo__c IN :codigoQuestionario order by numero__c asc];


                for(PerguntaQuestionario__c perguntaQuest: PerguntaQ){
                    ServiceTO.QuestionarioTO quest = new ServiceTO.QuestionarioTO();
                    quest.idPergunta = perguntaQuest.numero__c != null ? String.valueOf(perguntaQuest.numero__c) : null; //PLV-4790 INICIO/FIM
                    quest.pergunta = perguntaQuest.Pergunta__r.Pergunta__c;
                    quest.tipoResposta = perguntaQuest.Pergunta__r.TipoResposta__c;
                    quest.opcoesRespostas = perguntaQuest.Pergunta__r.OpcoesResposta__c; 
                    quest.justificarPergunta = perguntaQuest.justificarPergunta__c;// ANNVI-17 INICIO/FIM 
                    //PLV-4771 - INÍCIO
                    //quest.proximaPergunta = perguntaQuest.ProximaPergunta__c; 
                    quest.ordenacao = perguntaQuest.numero__c;
                    System.debug('pergunta> ' + quest);
                    //PLV-4771 - FIM
                    quest.obrigatorio = perguntaQuest.obrigatorio__c; // PLV-4797 INICIO/FIM SYS4B ODEMIR
                    questTO.add(quest);
                    retorno.regras.idquestionario=perguntaQuest.Questionario__r.Codigo__c; //PLV-4790 INICIO/FIM
                }
      
                // VIAG-148 FIM
               
            }
            

           // PLV-4797 FIM SYS4B ODEMIR


        }
        
        // cria nó de remunerações
        
        //RVI-315-INCIO
        //PLV-4344 - Inicio
        Set<Id> idsRemu = new Set<Id>();
        Map<String, RemuneracaoProduto__c> mapRemuneracaoProduto = new Map<String, RemuneracaoProduto__c>();
        
        for(RemuneracaoProduto__c remuneracaoProduto : RemuneracaoProdutoDAO.getInstance().buscarRemuneracaoProdutoPorProdutCode(new Set<String>{oferta.orcamento.codigoProdutoVida}))
        {
            System.debug('REMUNERACAO HENRIQUE PARTE FOR: ' +remuneracaoProduto );
            mapRemuneracaoProduto.put(remuneracaoProduto.TipoRemuneracao__r.Name, remuneracaoProduto);
            idsRemu.add(remuneracaoProduto.Id);
        }
        
        Map<String, List<AntecipacaoComissao__c>> mapListAntecipacaoComissao = new Map<String, List<AntecipacaoComissao__c>>();
       
       
        // VIAG-148 INICIO
       List <AntecipacaoComissao__c> Antecipa = new List <AntecipacaoComissao__c>();
       Antecipa = [SELECT Id, LimiteMaximo__c, LimiteMinimo__c, TipoEvento__c, RemuneracaoProduto__c FROM AntecipacaoComissao__c WHERE RemuneracaoProduto__c IN :idsRemu];

        for(AntecipacaoComissao__c ac : Antecipa){
            if(mapListAntecipacaoComissao.containsKey(ac.RemuneracaoProduto__c))
                mapListAntecipacaoComissao.get(ac.RemuneracaoProduto__c).add(ac);
            else
                mapListAntecipacaoComissao.put(ac.RemuneracaoProduto__c, new List<AntecipacaoComissao__c>{ac});
        }
        //PLV-4344 - Fim
         // VIAG-148 FIM
        List<ServiceTO.RemuneracaoRetornoOfertaTO> remuneracoesRetorno = new List<ServiceTO.RemuneracaoRetornoOfertaTO>();
        
        for(EmissaoTO.RemuneracaoTO remuneracao : oferta.orcamento.remuneracoes)
        {
            System.debug('ENTROU NO FOR');
            System.debug('remuneracao henrique: ' + remuneracao);
            System.debug('mapa de remuneracao: ' + mapRemuneracaoProduto);
            if(mapRemuneracaoProduto.containsKey(remuneracao.tipoRemuneracao))
            {
                System.debug('HENRIQUE ENTROU NESSE PRIMEIRO IF');
                RemuneracaoProduto__c remuneracaoProduto = mapRemuneracaoProduto.get(remuneracao.tipoRemuneracao);
                System.debug('remuneracaoProduto Henrique: ' +remuneracaoProduto );
                ServiceTO.RemuneracaoRetornoOfertaTO remuneracaoRetorno = new ServiceTO.RemuneracaoRetornoOfertaTO();
                
                remuneracaoRetorno.tipoRemuneracao = remuneracaoProduto.TipoRemuneracao__r.Name;
                remuneracaoRetorno.obrigatorio     = remuneracaoProduto.Obrigatoria__c;
                remuneracaoRetorno.limiteMinimo    = remuneracaoProduto.LimiteMinimo__c;
                remuneracaoRetorno.limiteMaximo    = remuneracaoProduto.LimiteMaximo__c;
                
                //PLV-4344 - Inicio
                if(mapListAntecipacaoComissao.containsKey(remuneracaoProduto.Id)){
                    List<ServiceTO.AntecipacaoComissaoTO> listAntecipacaoRetorno = new List<ServiceTO.AntecipacaoComissaoTO>();
                    for(AntecipacaoComissao__c antecipacao : mapListAntecipacaoComissao.get(remuneracaoProduto.Id)){
                        ServiceTO.AntecipacaoComissaoTO antecipacaoRetorno = new ServiceTO.AntecipacaoComissaoTO();
                        antecipacaoRetorno.tipoevento = antecipacao.TipoEvento__c;
                        antecipacaoRetorno.limiteMaximo = antecipacao.LimiteMaximo__c;
                        antecipacaoRetorno.limiteMinimo = antecipacao.LimiteMinimo__c;
                        listAntecipacaoRetorno.add(antecipacaoRetorno);
                    }
                    remuneracaoRetorno.antecipacaoComissoes = listAntecipacaoRetorno;
                }                
                //PLV-4344 - Fim

                remuneracoesRetorno.add(remuneracaoRetorno);
            }
            
        }
        
        retorno.regras.remuneracoes = remuneracoesRetorno;
        //RVI-315-FIM

        // ANNI-16-INICIO
        String susep = req.ofertas[0].orcamento.susepOrcamento;
        List<CoCorretagem__c> listCocorretagem = [SELECT  
                                                        PercentualCoCorretagem__c, 
                                                        PercentualTransmissao__c, 
                                                        SusepDeCoCorretagem__c, 
                                                        SusepDeCoCorretagemLider__c, 
                                                        SusepTransmissao__c, 
                                                        SusepTransmissaoLider__c FROM CoCorretagem__c WHERE SusepTransmissao__c =: susep];

        if(listCocorretagem.size() > 0){

            List<ServiceTO.CocorretagemOfertaTO> retornoCocorretagem = new List<ServiceTO.CocorretagemOfertaTO>(); 

            for (CoCorretagem__c corretagem : listCocorretagem) {

                ServiceTO.CocorretagemOfertaTO corretagemTo  = new ServiceTO.CocorretagemOfertaTO();

                corretagemTo.susepTransmissao = corretagem.SusepTransmissao__c;
                corretagemTo.coCorretagem = corretagem.SusepDeCoCorretagem__c;
                corretagemTo.transmissaoLider = corretagem.SusepTransmissaoLider__c;
                corretagemTo.corretagemLider = corretagem.SusepDeCoCorretagemLider__c ;
                corretagemTo.percentualTransmissao = corretagem.PercentualTransmissao__c  ;
                corretagemTo.percentualCoCorretagem =  corretagem.PercentualCoCorretagem__c;

                 
                retornoCocorretagem.add(corretagemTo);
       
            }

            retorno.regras.cocorretagem = retornoCocorretagem;

        }  
         // ANNI-16-FIM
    }

    //PLV-4840 INICIO
    
    private ServiceTO.PayRetornoOfertasTO validaIdadeGarantiasVI(ServiceTO.PayRetornoOfertasTO payload, String tpSeg){ //RVI-165-INICIO/FIM
        system.debug('payload Idade: '+payload);
        system.debug('payload.ofertas idade: '+payload.ofertas);
        if(payload.ofertas.isEmpty()) return payload;
            
        ServiceTO.PayRetornoOfertasTO retorno = new ServiceTO.PayRetornoOfertasTO();
        List<ServiceTO.OfertaTO> lstofertas = new List<ServiceTO.OfertaTO>();

        for (ServiceTO.OfertaTO oferta : payload.ofertas) { 
            system.debug('oferta.regras.coberturas: '+oferta.regras.coberturas);
            if(oferta.regras.coberturas.isEmpty()) continue;
            lstofertas.add(oferta);
            System.debug('BRUNO 4 >>>>' + oferta);
        }
        
        retorno.ofertas = lstofertas;
        
        //if(retorno.ofertas == null || retorno.ofertas.isEmpty()){ //RVI-165-INICIO/FIM
        if(retorno.ofertas == null || retorno.ofertas.isEmpty() && tpSeg != 'Renovacao'){ //RVI-165-INICIO/FIM 
            
            retorno.retornoValidacaoProduto = new ServiceTO.RetornoValidacaoProdutoTO();
            retorno.retornoValidacaoProduto.recusas = new List<ServiceTO.RecusaTO>();

            ServiceTO.RecusaTO recusaIdade = new ServiceTO.RecusaTO();

            recusaIdade.codigo = 60; //Integer       
            recusaIdade.mensagens = new ServiceTO.MensagenTO();
            recusaIdade.mensagens.interna = 'Oferta fora dos limites de idade permitidos.';
            recusaIdade.mensagens.cliente = 'Oferta fora dos limites de idade permitidos.';
            recusaIdade.mensagens.representante = 'Oferta fora dos limites de idade permitidos.';
            recusaIdade.descricao = 'Oferta fora dos limites de idade permitidos.'; //String     
            recusaIdade.area = 'area'; //String       
            recusaIdade.procedimento ='procedimento' ; //String       
            recusaIdade.severidade = 1; //Integer       

            retorno.retornoValidacaoProduto.recusas.add(recusaIdade);
            retorno.ofertas = new List <ServiceTO.OfertaTO>();
        }
        
        system.debug('Wander retorno');
        return retorno;
    }
    //PLV-4840 FIM

    //PLV-5066 - INICIO
    private Boolean zerarPremioOrcamento(EmissaoTO.OfertasTO oferta){
        EmissaoTO.TipoEndossoTO tiposEndosso = oferta.orcamento.tiposEndosso;
        EmissaoTO.RemuneracaoTO remuneracaoOrcamento = this.pegarRemuneracaoCorretagem(oferta.orcamento.remuneracoes);
        EmissaoTO.RemuneracaoTO remuneracaoOriginal = (oferta.orcamento.contratoOriginal == null) ? new EmissaoTO.RemuneracaoTO() : this.pegarRemuneracaoCorretagem(oferta.orcamento.contratoOriginal.remuneracoes);
        Boolean manter = this.manterParcelamento(oferta.orcamento.contratantes);
        return tiposEndosso != null && tiposEndosso.cad && manter && remuneracaoOrcamento.percentual == remuneracaoOriginal.percentual;
    }

    private Boolean manterParcelamento(List<EmissaoTO.ContratanteTO> contratantes){
        Boolean manterParcelaRetorno = false;
        for(EmissaoTO.ContratanteTO contratante : contratantes){
            if(contratante.manterPlanoParcelamento != null && contratante.manterPlanoParcelamento){
                manterParcelaRetorno = true;
                break;
            }
        }
        return manterParcelaRetorno;
    }

    private EmissaoTO.RemuneracaoTO pegarRemuneracaoCorretagem(List<EmissaoTO.RemuneracaoTO> remuneracoes){
        EmissaoTO.RemuneracaoTO remuneracaoRetorno = null;
        for(EmissaoTO.RemuneracaoTO remuneracao : remuneracoes){
            if(remuneracao.tipoRemuneracao == 'CORRETAGEM' || remuneracao.tipoRemuneracao == 'COR'){
                remuneracaoRetorno = remuneracao;
                break;
            }
        }
        return remuneracaoRetorno;
    }

    private void ajustarPremioEndossoCadastral(EmissaoTO.OfertasTO oferta){
        for(EmissaoTO.RetornoCalculoTO retornoCalculo : oferta.retornosCalculo){
            EmissaoTO.PrecificacaoTO precificacao = retornoCalculo.precificacao;
            precificacao.iof =  0;
            precificacao.juros = 0;
            precificacao.custoApolice = 0;
            precificacao.custoDeApolice = 0;
            precificacao.encargos = 0;
            //Taxa
            if(precificacao.taxa != null){
                this.ajustarTaxa(precificacao.taxa);
            }
            //Premio
            if(precificacao.premio != null){
               this.ajustarPremio(precificacao.premio);
            }
            //Desconto Agravo
            if(precificacao.descontoAgravo != null && precificacao.descontoAgravo.size() > 0){
                for(EmissaoTO.DescontoagravoTO descontoAgravo : precificacao.descontoAgravo){
                    this.ajustarDescontoAgravo(descontoAgravo);
                }
            }
            //Coberturas
            if(precificacao.coberturas != null && precificacao.coberturas.size() > 0){
                for(EmissaoTO.CoberturaTO cobertura : precificacao.coberturas){
                    this.ajustarCobertura(cobertura, true);
                }
            }
            //Contratantes
            if(precificacao.contratantes != null && precificacao.contratantes.size() > 0){
                for(EmissaoTO.ContratanteTO contratante : precificacao.contratantes){
                    this.ajustarContratante(contratante);
                }
            }


        }
        
    }
    
    private void ajustarTaxa(EmissaoTO.TaxaTO taxa){
        taxa.pura = 0;
        taxa.mensal = 0;
        taxa.anual = 0;
        taxa.puroInterno = 0;
        taxa.puroResseguro = 0;
        taxa.comercial = 0;
        taxa.total = 0;
    }

    private void ajustarPremio(EmissaoTO.PremioTO premio){
        premio.informado = 0;
        premio.puro = 0;
        premio.puroDesconto = 0;
        premio.puroInterno = 0;
        premio.puroResseguro = 0;
        premio.premioPago = 0;
        premio.comercial = 0;
        premio.comercialDesconto = 0;
        premio.total = 0;
    }

    private void ajustarDescontoAgravo(EmissaoTO.DescontoagravoTO descontoAgravo){
        descontoAgravo.percentual = 0;
        descontoAgravo.monetario = 0;
    }
    
    private void ajustarCobertura(EmissaoTO.CoberturaTO cobertura, Boolean ajustarCapital){
        cobertura.capital = 0;
        cobertura.iof = 0;
        cobertura.valor = 0;
        cobertura.agravo = 0;
        cobertura.desconto = 0;
        cobertura.valorDescontoAgravo = 0;
        cobertura.percentual = 0;
        cobertura.percentualIndenizacaoEspecial = 0;
        cobertura.percentualFilhos = 0;
        cobertura.importancia = 0;
        if(ajustarCapital){
            cobertura.capitalContratacao = 0;
        }
        cobertura.caracteristicaespecialvalor = 0;
        if(cobertura.premio != null){
            this.ajustarPremio(cobertura.premio);
        }
        if(cobertura.taxa != null){
            this.ajustarTaxa(cobertura.taxa);
        }
        if(cobertura.descontoAgravo != null && cobertura.descontoAgravo.size() > 0){
            for(EmissaoTO.DescontoagravoTO descontoAgravo : cobertura.descontoAgravo){
                this.ajustarDescontoAgravo(descontoAgravo);
            }
        }

    }

    private void ajustarContratante(EmissaoTO.ContratanteTO contratante){
        contratante.iof = 0;
        if(contratante.premio != null){
            this.ajustarPremio(contratante.premio);
        }
        if(contratante.taxa != null){
            this.ajustarTaxa(contratante.taxa);
        }
        if(contratante.coberturas != null && contratante.coberturas.size() > 0){
            for(EmissaoTO.CoberturaTO cobertura : contratante.coberturas){
                this.ajustarCobertura(cobertura, true);
            }
        }
        if(contratante.grupos != null && contratante.grupos.size() > 0){
            for(EmissaoTO.GrupoTO grupo : contratante.grupos){
                this.ajustarGrupo(grupo);
            }
        }
        if(contratante.descontoAgravo != null && contratante.descontoAgravo.size() > 0){
            for(EmissaoTO.DescontoagravoTO descontoAgravo : contratante.descontoAgravo){
                this.ajustarDescontoAgravo(descontoAgravo);
            }
        }
    }
    
    private void ajustarGrupo(EmissaoTO.GrupoTO grupo){
       // grupo.qtdeVidas = 0;  // II-25 - INICIO/FIM
        grupo.saldoDevedor = 0;
        grupo.valorDoBem = 0;
        grupo.agravo = 0;
        grupo.desconto = 0;
        grupo.valorDescontoAgravo = 0;
        grupo.iof = 0;
        grupo.tarifa = 0;
        if(grupo.premio != null){
            this.ajustarPremio(grupo.premio);
        }
        if(grupo.taxa != null){
            this.ajustarTaxa(grupo.taxa);
        }
        if(grupo.segurados != null && grupo.segurados.size() > 0){
            for(EmissaoTO.SeguradoTO segurado : grupo.segurados){
                this.ajustarSegurado(segurado);
            }
        }
        if(grupo.coberturas != null && grupo.coberturas.size() > 0){
            for(EmissaoTO.CoberturaTO cobertura : grupo.coberturas){
                this.ajustarCobertura(cobertura, true);
            }
        }
        if(grupo.descontoAgravo != null && grupo.descontoAgravo.size() > 0){
            for(EmissaoTO.DescontoagravoTO descontoAgravo : grupo.descontoAgravo){
                this.ajustarDescontoAgravo(descontoAgravo);
            }
        }
    }

    private void ajustarSegurado(EmissaoTO.SeguradoTO segurado){
        segurado.iof = 0;
        segurado.limiteProfissao = 0;
        if(segurado.premio != null){
            this.ajustarPremio(segurado.premio);
        }
        if(segurado.taxa != null){
            this.ajustarTaxa(segurado.taxa);
        }
        System.debug('Gilberto segurado.coberturas>>>' + segurado.coberturas) ;
        if(segurado.coberturas != null && segurado.coberturas.size() > 0){
            System.debug('Dentro do IF Gilberto segurado.coberturas>>>' + segurado.coberturas) ;
            for(EmissaoTO.CoberturaTO cobertura : segurado.coberturas){
                this.ajustarCobertura(cobertura, false);
            }
        }
        if(segurado.descontoAgravo != null && segurado.descontoAgravo.size() > 0){
            for(EmissaoTO.DescontoagravoTO descontoAgravo : segurado.descontoAgravo){
                this.ajustarDescontoAgravo(descontoAgravo);
            }
        }
    }

    //PLV-5066 - FIM

    public class GravarOrcamentoServiceException extends Exception {} //PLV-4790 FIX 8 INICIO/FIM
}

//PLV-3649 - FIM