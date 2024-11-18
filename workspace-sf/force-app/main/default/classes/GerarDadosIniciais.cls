/*********************************************************************************************************************************************************************
@description  Classe para geração de dados iniciais no processo de contratação
@author Isabela Fin - Avanxo
@date 10/01/2020
@Classe criada por conta da história PLV-2146
@Bloco de geração de conta removido por conta de Fix da história PLV-2146
*******************************************************'***************************************************************************************************************/
public without sharing class GerarDadosIniciais {
	private static final GerarDadosIniciais instance = new GerarDadosIniciais();
    private static final ProductBO produtoBO = ProductBO.getInstance();
    private String numeroOferta; //PLV-3317 - INÍCIO/FIM

    private String cicloVacinalNovo { get; set; } // PLV-5150 - FIX02 - INICIO/FIM - 
    private String cicloVacinalOriginal { get; set; } // PLV-5150 - FIX02 - INICIO/FIM - 
    
    private final Integer ctOpcaoRen = 0; // RVI-193 - INICIO/FIM
    Contract buscaVigenciaContratoOriginal; //FNPVVEP-21 INICIO/FIM
    // TKCL-584 INICIO
    Contract buscacontratoOriginal; 
    Opportunity opp; 
    GrupoProfissoes__c grupoProfissoes;
    List<GerarDadosIniciaisTO.VersaoCalculoTO> versoesCalculo; 
    Map<String,GerarDadosIniciaisTO.CoberturaTO> mapSiglaxGarantiaContrato; 
    Map<String,GerarDadosIniciaisTO.CoberturaTO> mapSiglaxGarantiaContrato2;
    RecordType rt;
    Map<String, FranquiaGarantia__c> mapFranquiaGarantia; 
    ContratanteContrato__c contratanteOriginal; 
    GrupoContrato__c grupoOriginal; 
    SeguradoContrato__c seguradoOriginal; 
    List<RemuneracaoContrato__c> remuneracaoOriginal; 
    // TKCL-584 FIM
    
    public static GerarDadosIniciais getInstance() {
        return instance;
    }
    public String gerarDadosIniciais(String payload) {
        System.debug('EntrouDadosIniciais');
        System.debug(payload);
        
        String jsonRetorno;
        
        gerarNumeroOferta(); //PLV-3317 - INÍCIO/FIM
        //Percorre o Jason e deserializa 
        System.debug('JSON >>> ' + payload.replace('\n',''));
        GerarDadosIniciaisTO.PayloadTO payloadTO = (GerarDadosIniciaisTO.PayloadTO) JSON.deserialize(payload, GerarDadosIniciaisTO.PayloadTO.class);
        System.debug('JSON payloadTO >>>> ' + payloadTO);
        System.debug('PayloadTo em json: '+JSON.serialize(payloadTO));
        String codigoCupom = payLoadTO.orcamentos[0].cupom;

         //PLV-5150 - FIX02 - INICIO
         if (payloadTO.orcamentos.size() > 0) {
             this.cicloVacinalNovo = payloadTO.orcamentos[0].cicloVacinal;
         }
         //PLV-5150 - FIX02 - FIM

        //Faz uma lista de Oportunidade(Orçamento)
        List<Opportunity> lOportunidade = new List<Opportunity>();
        
        Integer qtdOrcamentos = payloadTO.orcamentos.size();

        //Percorre a lista de Orçamento e adiciona a Lista lOportunidade
        for (GerarDadosIniciaisTO.OrcamentoTO orcamento: payloadTO.orcamentos) {
            System.debug('Percorre o Orçamento e adiciona a Lista lOportunidade >>>>' + orcamento);

            Opportunity oportunidade = new Opportunity();

            oportunidade.Name = 'GERAR';
            //Campos Obrigatórios
            oportunidade.MeioComercializacao__c = orcamento.meioComercializacao;
            oportunidade.CloseDate = System.today() + 30;
            oportunidade.StageName = 'Em criação';
            oportunidade.NumeroOferta__c = numeroOferta; //PLV-3317 - INÍCIO/FIM
            // AV-664 INICIO
            if (payLoadTO.orcamentos[0].cupom !='') {
            oportunidade.CupomDesconto__c = payLoadTO.orcamentos[0].cupom;
            }
            // AV-664 FIM
            lOportunidade.add(oportunidade);
        }
      
        insert lOportunidade;
        System.debug('Lista lOportunidade2 >>>>' + lOportunidade);

        //RVI-312 - INICIO
        List<ContratanteContrato__c> ctesCtr = new List<ContratanteContrato__c>();
        Set<Id> ctesCtrId = new Set<Id>();
        //RVI-312 - FIM

        //PLV-2715 Fix 2 - Inicio - Ajuste na geração de número orçamento
        
        List<GerarDadosIniciaisTO.OfertaTO> lstOfertas = new List<GerarDadosIniciaisTO.OfertaTO>();
        integer i = 0;
        
        //PLV-2146 FIX - INICIO - Inserção de ordenação  por id na query
        //for (Opportunity oportunidade: [SELECT Id, Name, Numero__c, NumeroOferta__c FROM Opportunity WHERE Id =: lOportunidade ORDER BY Id]) { //PLV-3317 - INÍCIO/FIM - Inserção de campo NumeroOferta__c na query
        //PLV-2146 FIX - FIM - Inserção de ordenação  por id na query

        //PLV-4168 - V.I - INICIO
        //PLV-4498 - inicio
        for (Opportunity oportunidade : [
            SELECT ContratoRenovado__c, Id, Name, Numero__c, NumeroOferta__c, RamoOrcamento__c, DescontoAgravoPercentualTecnico__c, // RVI-193 - INICIO/FIM
            DescontoAgravoPercentualComercial__c, DescontoAgravoMonetarioTecnico__c, DescontoAgravoMonetarioComercial__c, 
                (SELECT DescontoAgravoPercentualTecnico__c,DescontoAgravoPercentualComercial__c, 
                DescontoAgravoMonetarioTecnico__c, DescontoAgravoMonetarioComercial__c,
                Garantia__r.sigla__c,Limite_de_uso__c//PLV-4889
                FROM CoberturasOrcamento__r)
            FROM Opportunity 
            WHERE Id = :lOportunidade
            ORDER BY Id]
        ){ 
            System.debug('BRUNO OPPORTUNITY' + oportunidade.ContratoRenovado__c);
            //PLV-4498 - Fim
            //PLV-4168 - V.I - FIM
            //Busca produto por código e datas de vigência inicial e final
            //PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
            Product2 produto = new Product2();

            //PLV-5331 INÍCIO
            ProductDAO produtoDao = ProductDAO.getInstance();
            // System.debug('Logando código do produto antigo abaixo');
            // System.debug(payloadTO.orcamentos[i].codigoProdutoVida);
            // System.debug('Logando código do produto antigo acima');
            // System.debug('Logando código do produto novo abaixo');
            // System.debug(lstProdPrec[0].ProductCode);
            // System.debug('Logando código do produto novo acima');
            // Product2 prodPrec = new Product2(); 
            
            // if('eds'.equalsIgnoreCase(payloadTO.orcamentos[0].tipoSeguro)){
            //     prodPrec = produtoBO.buscarProdutoPorDataCalculo(payloadTO.orcamentos[i].codigoProdutoVida, payloadTO.orcamentos[i].dataCalculo);
            // }
            // else{
            //     prodPrec = produtoDao.buscProdPrecDtCalc(payloadTO.orcamentos[i].codigoProdutoVida, payLoadTO.orcamentos[i].idProdutoSf);
            // }

            //PLV-5331 INÍCIO
            system.debug('payLoadTO abaixo');
            system.debug(payLoadTO.orcamentos[i].codigoProdutoVida);
            system.debug(payLoadTO.orcamentos[i].idProdutoSf);
            system.debug('>>>TituloCupom:' + payLoadTO.orcamentos[i].cupom);
       
            
            system.debug('BRUNO 1 >>>> ' + payloadTO);
            //system.debug('BRUNO 2 >>>> ' + payloadTO.orcamentos[0].contratoOriginal.apolice);
            system.debug('payLoadTO acima');
            Product2 prodPrec = produtoDao.buscProdPrecDtCalc(payLoadTO.orcamentos[i].codigoProdutoVida, payLoadTO.orcamentos[i].idProdutoSf);
            System.debug('payloadTO.orcamentos[0].tipoSeguro <<<' + payloadTO.orcamentos[0].tipoSeguro);
            Contract produtoOriginal; //ANNVI-258 - INICIO/FIM
            if('eds'.equalsIgnoreCase(payloadTO.orcamentos[0].tipoSeguro)){
                String numeroApolice = gerarNumeroApolice(payloadTO);
                produtoOriginal = [SELECT Id, Produto__c,Produto__r.Status__c,Produto__r.ProductCode, Produto__r.ProdutoEndosso__c, Produto__r.ProdutoRenovacao__c FROM Contract WHERE NAME =: numeroApolice]; //ANNVI-258 - INICIO/FIM
                if(produtoOriginal.Produto__r.ProdutoEndosso__c!=null){
                    produto = ProductDAO.getInstance().buscarProdutoEndosso(produtoOriginal.Produto__r.ProdutoEndosso__c);
                }else{
                    produto = produtoBO.buscarProdutoPorDataCalculo(prodPrec.ProductCode, payloadTO.orcamentos[i].dataCalculo); //PLV-5331 INÍCIO / FIM
                    // produto = produtoBO.buscarProdutoPorDataCalculo(payloadTO.orcamentos[i].codigoProdutoVida, payloadTO.orcamentos[i].dataCalculo); //PLV-5331 INÍCIO / FIM
                }
            }else{
                System.debug('prodPrec.ProductCode ' + prodPrec.ProductCode);
                System.debug('payloadTO.orcamentos[i].dataCalculo >>> ' + payloadTO.orcamentos[i].dataCalculo);
                produto = produtoBO.buscarProdutoPorDataCalculo(prodPrec.ProductCode, payloadTO.orcamentos[i].dataCalculo); //PLV-5331 INÍCIO / FIM
                // produto = produtoBO.buscarProdutoPorDataCalculo(payloadTO.orcamentos[i].codigoProdutoVida, payloadTO.orcamentos[i].dataCalculo); //PLV-5331 INÍCIO / FIM
            }

            //PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
            Set<Decimal> setCondicaoCobranca       = new Set<Decimal>();
            //PLV-3729 - INICIO - Índice monetário
            Set<String>  setMoedasGarantiasProduto = new Set<String>();
            GerarDadosIniciaisTO.MoedasCotacaoTO moedasCotacaoTO = new GerarDadosIniciaisTO.MoedasCotacaoTO();
            //PLV-3729 - FIM - Índice monetário
            Map<Decimal, CondicaoCobranca__c> mapCondicaoCobranca = new Map<Decimal, CondicaoCobranca__c>();
            
            Map<String, Decimal> mapDescAgrvRenovAltBoleto = new Map<String, Decimal>(); // RVI-312-FIX01 INICIO/FIM
            //insere as outras opções encontradas nas condições de cobrança

            System.debug('produto rogerio>>>> ' + produto);
            System.debug('CondicoesCobranca__r rogerio>>>> ' + produto.CondicoesCobranca__r);
            for(CondicaoCobranca__c condicaoCobranca : produto.CondicoesCobranca__r){
                setCondicaoCobranca.add(condicaoCobranca.PercentualDescontoAgravo__c != null ? condicaoCobranca.PercentualDescontoAgravo__c : 0);
                mapCondicaoCobranca.put(condicaoCobranca.PercentualDescontoAgravo__c != null ? condicaoCobranca.PercentualDescontoAgravo__c : 0, condicaoCobranca);
                // RVI-312-FIX01 INICIO
                // Considerando aqui que Boleto será sempre a forma de pagamento usada ao alterar na renovação.
                if ('Boleto'.equalsIgnoreCase(condicaoCobranca.TipoPagamento__c)) {
                    mapDescAgrvRenovAltBoleto.put(condicaoCobranca.QuantidadeParcelas__c,condicaoCobranca.PercentualDescontoAgravo__c);
                }
               // RVI-312-FIX01 FIM
            }
            //PLV-3729 - INICIO - Índice monetário
            for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r){              
                if(garantiaProduto.currencyIsoCode != 'BRL')
                    setMoedasGarantiasProduto.add(garantiaProduto.currencyIsoCode);          
            }
            moedasCotacaoTO.dataInicio = Date.Valueof(payloadTO.orcamentos[i].dataCalculo).addDays(-6);
            moedasCotacaoTO.dataCalculo = payloadTO.orcamentos[i].dataCalculo;
            moedasCotacaoTO.moedasGarantias = setMoedasGarantiasProduto;              
            //PLV-3729 - FIM
            System.debug('setCondicaoCobranca rogerio>>>> ' + setCondicaoCobranca);
            System.debug('mapCondicaoCobranca rogerio>>>> ' + mapCondicaoCobranca);
            List<Decimal> listDescontoAgravo = new List<Decimal>();
           
            listDescontoAgravo.addAll(setCondicaoCobranca);
            //Lista criada para ordenação de produtos -> campo "opcao"
            listDescontoAgravo.sort();
            
            versoesCalculo = new List<GerarDadosIniciaisTO.VersaoCalculoTO>(); // TKCL-584-FIX01 INICIO/FIM
            //PLV-3318 - INICIO
            //GerarDadosIniciaisTO.VersaoCalculoTO versaoCalculoSemDesconto =  new GerarDadosIniciaisTO.VersaoCalculoTO();
            
            Integer contadorOpcao = listDescontoAgravo.size()-1;
            //Integer contadorOpcao = 0;
            //Cria primeira opção, que é sem desconto
            //versaoCalculoSemDesconto.descontoAgravo = 0;
           	//versaoCalculoSemDesconto.opcao = contadorOpcao;
            //Código removido para PLV-2146 (FIX)
            //versoesCalculo.add(versaoCalculoSemDesconto);

            // Ponto de Ajuste - Início
            // RVI-193-INICIO
            String tipoDoSeguro = payloadTO.orcamentos[0].tipoSeguro;
            String ctrOrRen = payloadTO.orcamentos[0].idContratoRenovado;
            
            System.debug('tipoDoSeguro >>>> ' + tipoDoSeguro);
            System.debug('ctrOrRen >>>> ' + ctrOrRen);
            System.debug('listDescontoAgravo rogerio>>>> ' + listDescontoAgravo); 
      
            for(Decimal descontoAgravo : listDescontoAgravo) {
                //if(descontoAgravo != 0) {
                    // RVI-193 - INICIO
                    GerarDadosIniciaisTO.VersaoCalculoTO versaoCalculoDesconto =  new GerarDadosIniciaisTO.VersaoCalculoTO();
                    GerarDadosIniciaisTO.VersaoCalculoTO versaoCalculo =  new GerarDadosIniciaisTO.VersaoCalculoTO();                    
                    if (tipoDoSeguro == 'Renovacao') {
                        versaoCalculo.opcao = ctOpcaoRen;
                        //RVI-312 - INICIO
                        Boolean formaPgtoAlt = verificarAltPgto(ctrOrRen);
                        if(formaPgtoAlt){
                            ContratanteContrato__c cteCtr = ajustaDescAgrvRenovAltFormaPagto(ctrOrRen,mapDescAgrvRenovAltBoleto); // RVI-312-FIX01 INICIO/FIM
                            if(cteCtr.Id != null && !ctesCtrId.contains(cteCtr.Id)){
                                ctesCtrId.add(cteCtr.Id);                 
                                ctesCtr.add(cteCtr);                                                                
                            }
                            versaoCalculo.descontoAgravo = cteCtr.DescontoAgravoPercentualFormaPagto__c;
                        }else{//RVI-312 - FIM
                            versaoCalculo.descontoAgravo = getDiscCtrOrg(ctrOrRen);
                        }//RVI-312 - INICIO/FIM
                       // versaoCalculo.ListDescontoAgravo = getDiscCtrOrgX(ctrOrRen);
                        versaoCalculo.tipo = 'FPG';
                        versoesCalculo.add(versaoCalculo);  
                        System.debug('versoesCalculoRen >>>> ' + versoesCalculo);  
                        System.debug('ListDescontoAgravo >>>> ' + versaoCalculo.ListDescontoAgravo); 
                        break;
                    } else if (tipoDoSeguro == 'EDS') { //ANNVI-258 - INICIO
                        
                        versaoCalculo.opcao = ctOpcaoRen;
                        
                        Boolean formaPgtoAlt = verificarAltPgto(produtoOriginal.Id);
                        if (formaPgtoAlt) {
                            ContratanteContrato__c cteCtr = ajustaDescAgrvRenovAltFormaPagto(produtoOriginal.Id, mapDescAgrvRenovAltBoleto); // RVI-312-FIX01 INICIO/FIM
                            Date dtInicioAcelera = Date.newInstance(2024, 11, 04);

                            Map<String, String> codigosDescontoMap = new Map<String, String>();
                            codigosDescontoMap.put('DESC_DEZ_PORCENTO', '62,70');
                            codigosDescontoMap.put('DESC_CINCO_PORCENTO', '97,98');
                            codigosDescontoMap.put('SEM_DESCONTO', '41,52');
                            Datetime cteCtrCreatDt = !Test.isRunningTest() ? cteCtr.CreatedDate : System.today().addYears(-1);

                            if (cteCtrCreatDt < dtInicioAcelera) {
                                System.debug('Código forma de pagamento: ' + cteCtr.FormaPagamento__r.Codigo__c);
                                
                                if (codigosDescontoMap.get('DESC_DEZ_PORCENTO').contains(cteCtr.FormaPagamento__r.Codigo__c)) {
                                    versaoCalculo.descontoAgravo = 10;
                                } else if (codigosDescontoMap.get('DESC_CINCO_PORCENTO').contains(cteCtr.FormaPagamento__r.Codigo__c)) {
                                    versaoCalculo.descontoAgravo = 5;
                                } else if (codigosDescontoMap.get('SEM_DESCONTO').contains(cteCtr.FormaPagamento__r.Codigo__c)) {
                                    versaoCalculo.descontoAgravo = 0;
                                }
                            }

                            if (cteCtr.Id != null && !ctesCtrId.contains(cteCtr.Id)) {
                                ctesCtrId.add(cteCtr.Id);
                                ctesCtr.add(cteCtr);
                            }
                            versaoCalculo.descontoAgravo = cteCtr.DescontoAgravoPercentualFormaPagto__c;
                        }else{
                            versaoCalculo.descontoAgravo = getDiscCtrOrg(produtoOriginal.Id);                       
                            versaoCalculo.tipo = 'FPG';
                            versoesCalculo.add(versaoCalculo);                            
                            break;
                        }
                    } else { //ANNVI-258 - FIM
                        CondicaoCobranca__c condicaoCobranca = mapCondicaoCobranca.get(descontoAgravo);
                        versaoCalculo.opcao = contadorOpcao;
                        versaoCalculo.descontoAgravo = condicaoCobranca.PercentualDescontoAgravo__c != null ? condicaoCobranca.PercentualDescontoAgravo__c : 0;
                        //versaoCalculo.tipo = contadorOpcao != 0 ? 'FPG' : null; //condicaoCobranca.TipoPagamento__c;
                        versaoCalculo.tipo = 'FPG';
                        versoesCalculo.add(versaoCalculo);
                        System.debug('versoesCalculo >>>> ' + versoesCalculo);
                        //AV-623 INICIO
                        Decimal ValorDescontoCupom = getValorDescontoCupom(payloadTO);
                        if (ValorDescontoCupom != 0 ) {
                            versaoCalculoDesconto.opcao = contadorOpcao;
                            versaoCalculoDesconto.descontoAgravo = (ValorDescontoCupom)*-1;  
                            versaoCalculoDesconto.tipo = 'CUP';
                            versoesCalculo.add(versaoCalculoDesconto);
                        }
                        //AV-623 FIM
                    
                        System.debug('>>>versoesCalculo>>> ' + versoesCalculo);
                        contadorOpcao--;
                    }    
                     // RVI-193 - FIM
                //}                
            }
            // Ponto de Ajuste - Fim

            //PLV-3318 - FIM
            //Montagem do json de retorno

            //PLV-4168 - V.I - INICIO
            GerarDadosIniciaisTO.PrecificacaoTO precificacaoTO;
            if(produto.Segmento__c == 'Individual'){
                system.debug('Entrou Segmento');
                GerarDadosIniciaisTO.PremioTO premioProduto = new GerarDadosIniciaisTO.PremioTO();
                if(produto.PremioMinimo__c != null) premioProduto.minimo = produto.PremioMinimo__c;

                System.debug('preencherRetornoPrecificacaoOrcamento opp>> ' + oportunidade);
                List<GerarDadosIniciaisTO.DescontoAgravoTO> listaDescontoAgravoOrcamento = this.preencherRetornoPrecificacaoOrcamento(oportunidade);
                List<GerarDadosIniciaisTO.CoberturaTO> listaCoberturasOrcamento = this.preencherRetornoPrecificacaoCoberturasOrcamento(oportunidade);//PLV-4666 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

                precificacaoTO = new GerarDadosIniciaisTO.PrecificacaoTO();
                if(premioProduto.minimo != null) precificacaoTO.premio = premioProduto;
                if(!listaDescontoAgravoOrcamento.isEmpty()) precificacaoTO.descontoAgravo.addAll(listaDescontoAgravoOrcamento);
                if(!listaCoberturasOrcamento.isEmpty()) precificacaoTO.coberturas.addAll(listaCoberturasOrcamento);
            }
            //PLV-4168 - V.I - FIM
            GerarDadosIniciaisTO.RegraTO regra = new GerarDadosIniciaisTO.RegraTO();
            regra.versoesCalculo = versoesCalculo;
            GerarDadosIniciaisTO.OrcamentoRetornoTO orcamentoRetorno = new GerarDadosIniciaisTO.OrcamentoRetornoTO();
			orcamentoRetorno.numeroOrcamento = oportunidade.Numero__c;
            orcamentoRetorno.ordemPortal = payloadTO.orcamentos[i].ordemPortal; //PLV-2146 FIX - INICIO/FIM - Devolução de ordemPortal (campo sem alterações, não salvo no SF)
            orcamentoRetorno.numeroOferta = oportunidade.NumeroOferta__c; //PLV-3317 - INÍCIO/FIM


            System.debug('XXX - TIPO SEGURO: ' + JSON.serialize(payloadTO));

            //PLV - 4487 - VI - INICIO - Gustavo Pereira SYS4B
            //PLV - 4655 - VI - INICIO - GUSTAVO PEREIRA SYS4B         
            if('eds'.equalsIgnoreCase(payloadTO.orcamentos[0].tipoSeguro)){
                //Bloco Alterado
                //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B                 
                orcamentoRetorno.contratoOriginal = gerarcontratoOriginal(payloadTO);                
                //PLV - 4626 - VI - FIM - GUSTAVO PEREIRA SYS4B                
                orcamentoRetorno.numeroOferta = payloadTO.orcamentos[0].numeroOferta;       
                orcamentoRetorno.contratantes =  payloadTO.orcamentos[0].contratantes;                
                orcamentoRetorno.canalDistribuicao = payloadTO.orcamentos[0].canalDistribuicao;
                orcamentoRetorno.dataEndosso = payloadTO.orcamentos[0].dataEndosso; //PLV-4666 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

            }
            //PLV - 4487 - VI - FIM - Gustavo Pereira SYS4B
            //PLV - 4655 - VI - FIM - GUSTAVO PEREIRA SYS4B
            //PLV-5355 INICIO
            Boolean isIndividual = produtoDao.buscProductIndividual(payloadTO.orcamentos[i].codigoProdutoVida);
            System.debug('isIndividual Danilo: ' + isIndividual);
            //PLV-4403 INICIO
            //!* Orçamento de VI precisa retornar vigência ao Sinapse           
            if (isIndividual && produto.ParametrosVigencia__r.size() > 0){  // AV-478 INICIO/FIM  
            //PLV-5355 FIM              
                //!* Receber os parametros de vigencia pelo Produto
                ParametroVigencia__c param;

                for (ParametroVigencia__c vigencia : produto.ParametrosVigencia__r) {
                    if (vigencia.Tipo__c == 'Periódico') {
                        param = vigencia;
                        break;
                    }
                }

                if (param != null && payloadTO.orcamentos[i].dataCalculo != null 
                    && param.PeriodoCoberturaMinimo__c != null && param.PeriodoCoberturaMaximo__c != null
                    && param.PeriodoCoberturaMinimo__c == param.PeriodoCoberturaMaximo__c) {
                    Date dataCalculo = Date.valueof(payloadTO.orcamentos[i].dataCalculo);
                    //RVI-160 - INICIO
                    //orcamentoRetorno.vigenciaInicial = dataCalculo;
                    orcamentoRetorno.vigenciaInicial = payloadTO.orcamentos[0].tipoSeguro == 'Renovacao' ? payloadTO.orcamentos[0].vigenciaInicial : dataCalculo;
                    //RVI-160 - FIM
                    //PLV-4739 INICIO
                    System.debug('orcamentoRetorno.vigenciaInicial Danilo>>>>' + orcamentoRetorno.vigenciaInicial);
                    System.debug('orcamentoRetorno.vigenciaFinal Danilo>>>>' + orcamentoRetorno.vigenciaFinal);
                    //RVI-160 INICIO - Correcao calculo vigencia final
                    //orcamentoRetorno.vigenciaFinal = dataCalculo.addYears(Integer.valueOf(param.PeriodoCoberturaMinimo__c)).addDays(-1);
                    orcamentoRetorno.vigenciaFinal = payloadTO.orcamentos[0].tipoSeguro == 'Renovacao' ? payloadTO.orcamentos[0].vigenciaInicial.addYears(Integer.valueOf(param.PeriodoCoberturaMinimo__c)).addDays(-1) : dataCalculo.addYears(Integer.valueOf(param.PeriodoCoberturaMinimo__c)).addDays(-1);					
                    //RVI-160 FIM - Correcao calculo vigencia final
                    orcamentoRetorno.qtdDiasVigencia =  payloadTO.orcamentos[0].tipoSeguro == 'EDS' ? null : orcamentoRetorno.vigenciaInicial.daysBetween(orcamentoRetorno.vigenciaFinal) + 1; // PLV-4655 INICIO/FIM
                    System.debug('orcamentoRetorno.qtdDiasVigencia Danilo>>>>' + orcamentoRetorno.qtdDiasVigencia);
                    //PLV-4739 FIM
                }
                //RVI-160 - INICIO
                if(payloadTO.orcamentos[0].tipoSeguro == 'Renovacao'){
                    orcamentoRetorno.vigenciaFinal = orcamentoRetorno.vigenciaInicial.addYears(Integer.valueOf(param.PeriodoCoberturaMinimo__c)).addDays(-1);
                }else{
                    orcamentoRetorno.vigenciaFinal = orcamentoRetorno.contratoOriginal==null ? orcamentoRetorno.vigenciaFinal : Date.valueOf( orcamentoRetorno.contratoOriginal.vigenciaFinal);//PLV-4889
                }
                //RVI-160 - FIM
            }
            //PLV-4403 FIM

           System.debug('orcamentoRetorno ' + orcamentoRetorno);
            GerarDadosIniciaisTO.OfertaTO oferta = new GerarDadosIniciaisTO.OfertaTO();
            oferta.orcamento = orcamentoRetorno;
            oferta.regra = regra;
            oferta.moedasCotacao = moedasCotacaoTO; //PLV-3729 - INICIO/FIM - Índice monetário

            System.debug('Gilberto - PrecificacaoTO>> ' + precificacaoTO);
            System.debug('Gilberto - PrecificacaoTO != null >> ' + precificacaoTO != null);

            //RVI-225 - INICIO
            // System.debug('  orcamentoRetorno.contratoOriginal ' + JSON.serialize(orcamentoRetorno.contratoOriginal));
            // if(orcamentoRetorno.contratoOriginal != null){
 
            //     GerarDadosIniciaisTO.ContratoOriginalRetornoTO contrato = orcamentoRetorno.contratoOriginal;

            //     if(contrato.precificacao.descontoAgravo.size() > 0){
            //         System.debug('test22/12 - 1>> ' + JSON.serialize(contrato.precificacao.descontoAgravo));
            //         precificacaoTO.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
            //         List<GerarDadosIniciaisTO.DescontoAgravoTO> descontosAgravo = contrato.precificacao.descontoAgravo;
                    
            //         precificacaoTO.descontoAgravo.addAll(descontosAgravo);
            //     }
            // }
            // System.debug('test22/12 - 2>> ' + JSON.serialize(precificacaoTO));
            //RVI-225 - FIM

            if(precificacaoTO != null) oferta.precificacao = precificacaoTO; //PLV-4168 - V.I - INICIO/FIM
            lstOfertas.add(oferta);
            System.debug('Gilberto - oferta.precificacao>> ' + oferta.precificacao);
            
            System.debug('numero gerado >>>>' + orcamentoRetorno.numeroOrcamento);
            i++;
        }
        //RVI-312 - INICIO
        if(!ctesCtr.isEmpty()){
            update ctesCtr;
        }
        //RVI-312 - FIM
        //PLV-5134-INICIO
        system.debug('lstOfertas[] = ' + JSON.serialize(lstOfertas));
        system.debug('lstOfertas.isEmpty() = ' + lstOfertas.isEmpty());
        if(!lstOfertas.isEmpty() && lstOfertas[0].orcamento.contratantes != null){
            limparDIT(lstOfertas);
        }
        //PLV-5134-FIM
        //PLV-5066 INICIO
        Boolean tipoEndossoCad;
        if(!lstOfertas.isEmpty() && lstOfertas[0].orcamento.dataEndosso != null){

            tipoEndossoCad = this.checkTipoEndossoIsOnlyCad(payload, lstOfertas[0]);

            GerarDadosIniciaisTO.EndossoTO endosso = new GerarDadosIniciaisTO.EndossoTO();
            endosso.cad = tipoEndossoCad;

            lstOfertas[0].orcamento.tiposEndosso = endosso;
        }
        //PLV-5066 FIM
        GerarDadosIniciaisTO.RetornoTO retorno = new GerarDadosIniciaisTO.RetornoTO();
        retorno.ofertas = lstOfertas;
        String Retornocupom = ValidaCupom(payloadTO);
        //PLV-5461 INÍCIO
        if (Retornocupom == 'SUCESSO'){
            jsonRetorno = JSON.serialize(retorno, true); 
        } else {
             jsonRetorno = ('{ "data":{}, "erro": "'+Retornocupom+'"}'); 
         }
        //PLV-5461 FIM
        system.debug('jsonRetorno = ' + JSON.serialize(jsonRetorno));
        return jsonRetorno;
    }
    //PLV-3317 - INÍCIO

    //RVI-312 - INICIO
    public boolean verificarAltPgto(Id contratoId){
        Contract ctr = [
            SELECT Id, AlteraFormaPagto__c FROM Contract where Id = :contratoId
        ];

        return ctr.AlteraFormaPagto__c;
    }
    //RVI-3212 - FIM



    public void gerarNumeroOferta(){
        ContadorCodigo__c confNumOferta = [SELECT Numero__c FROM ContadorCodigo__c WHERE Name = 'NumeroOferta' FOR UPDATE];
        Integer numOferta = Integer.valueOf(confNumOferta.Numero__c);
        numOferta++;
        confNumOferta.Numero__c = numOferta;
        update confNumOferta;
        numeroOferta = String.valueOf(numOferta).leftPad(10,'0');
    }
    //PLV-3317 - FIM

    //PLV-4168 - V.I - INICIO
    public List<GerarDadosIniciaisTO.DescontoAgravoTO> preencherRetornoPrecificacaoOrcamento(Opportunity oportunidade){

        List<GerarDadosIniciaisTO.DescontoAgravoTO> listaDescontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();

        if(oportunidade.DescontoAgravoPercentualTecnico__c != null){
            GerarDadosIniciaisTO.DescontoAgravoTO descontoAgravoPT = new GerarDadosIniciaisTO.DescontoAgravoTO();
            descontoAgravoPT.percentual = oportunidade.DescontoAgravoPercentualTecnico__c;
            descontoAgravoPT.tipo = 'TEC';
            listaDescontoAgravo.add(descontoAgravoPT);
        }
        if(oportunidade.DescontoAgravoPercentualComercial__c != null){
            GerarDadosIniciaisTO.DescontoAgravoTO descontoAgravoPC = new GerarDadosIniciaisTO.DescontoAgravoTO();
            descontoAgravoPC.percentual = oportunidade.DescontoAgravoPercentualComercial__c;
            descontoAgravoPC.tipo = 'COM';
            listaDescontoAgravo.add(descontoAgravoPC);
        }
        if(oportunidade.DescontoAgravoMonetarioTecnico__c != null){
            GerarDadosIniciaisTO.DescontoAgravoTO descontoAgravoMT = new GerarDadosIniciaisTO.DescontoAgravoTO();
            descontoAgravoMT.monetario = oportunidade.DescontoAgravoMonetarioTecnico__c;
            descontoAgravoMT.tipo = 'TEC';
            listaDescontoAgravo.add(descontoAgravoMT);
        }
        if(oportunidade.DescontoAgravoMonetarioComercial__c != null){
            GerarDadosIniciaisTO.DescontoAgravoTO descontoAgravoMC = new GerarDadosIniciaisTO.DescontoAgravoTO();
            descontoAgravoMC.monetario = oportunidade.DescontoAgravoMonetarioComercial__c;
            descontoAgravoMC.tipo = 'COM';
            listaDescontoAgravo.add(descontoAgravoMC);
        }
        System.debug('Gilberto listaDescontoAgravo>> '+listaDescontoAgravo);
        return listaDescontoAgravo;       
    }
    //PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    public List<GerarDadosIniciaisTO.CoberturaTO> preencherRetornoPrecificacaoCoberturasOrcamento(Opportunity oportunidade){
    
        List<GerarDadosIniciaisTO.CoberturaTO> ListaCoberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();

        if(oportunidade.CoberturasOrcamento__r.isEmpty()) return ListaCoberturas;

        for(GarantiaOrcamento__c garantiaOrcamento : oportunidade.CoberturasOrcamento__r){
            
            if(String.isBlank(garantiaOrcamento.Garantia__r.Sigla__c)) continue;
            
            GerarDadosIniciaisTO.CoberturaTO coberturaObj = new GerarDadosIniciaisTO.CoberturaTO();
            coberturaObj.sigla = garantiaOrcamento.Garantia__r.Sigla__c;
            coberturaObj.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
   
            if(garantiaOrcamento.DescontoAgravoPercentualTecnico__c != null){
                GerarDadosIniciaisTO.DescontoAgravoTO descontoAgravoPT = new GerarDadosIniciaisTO.DescontoAgravoTO();
                descontoAgravoPT.percentual = garantiaOrcamento.DescontoAgravoPercentualTecnico__c;
                descontoAgravoPT.tipo = 'TEC';
                coberturaObj.descontoAgravo.add(descontoAgravoPT);
            }
            if(garantiaOrcamento.DescontoAgravoPercentualComercial__c != null){
                GerarDadosIniciaisTO.DescontoAgravoTO descontoAgravoPC = new GerarDadosIniciaisTO.DescontoAgravoTO();
                descontoAgravoPC.percentual = garantiaOrcamento.DescontoAgravoPercentualComercial__c;
                descontoAgravoPC.tipo = 'COM';
                coberturaObj.descontoAgravo.add(descontoAgravoPC);
            }
            if(garantiaOrcamento.DescontoAgravoMonetarioTecnico__c != null){
                GerarDadosIniciaisTO.DescontoAgravoTO descontoAgravoMT = new GerarDadosIniciaisTO.DescontoAgravoTO();
                descontoAgravoMT.monetario = garantiaOrcamento.DescontoAgravoMonetarioTecnico__c;
                descontoAgravoMT.tipo = 'TEC';
                coberturaObj.descontoAgravo.add(descontoAgravoMT);
            }
            if(garantiaOrcamento.DescontoAgravoMonetarioComercial__c != null){
                GerarDadosIniciaisTO.DescontoAgravoTO descontoAgravoMC = new GerarDadosIniciaisTO.DescontoAgravoTO();
                descontoAgravoMC.monetario = garantiaOrcamento.DescontoAgravoMonetarioComercial__c;
                descontoAgravoMC.tipo = 'COM';
                coberturaObj.descontoAgravo.add(descontoAgravoMC);
            }
            ListaCoberturas.add(coberturaObj);
        }
        System.debug('Gilberto ListaCoberturas>> '+ListaCoberturas);
        return ListaCoberturas;
    }
    //PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
    //PLV - 4487 - VI - INICIO - Gustavo Pereira SYS4B
    //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B
    // PLV-4655 - INICIO ALTERADO METODO INTEIRO
    //PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    public GerarDadosIniciaisTO.ContratoOriginalRetornoTO gerarcontratoOriginal(GerarDadosIniciaisTO.PayloadTO payloadTO){
        String numeroApolice = gerarNumeroApolice(payloadTO);
        //FNPVVEP-21 INICIO
        String numeroApoliceOriginal;
        if(numeroApolice.length() > 0){
            numeroApoliceOriginal = numeroApolice.substring(0, numeroApolice.length() - 1) + '0';
        }
        buscaVigenciaContratoOriginal = [ SELECT Id, StartDate FROM Contract WHERE NAME =: numeroApoliceOriginal];
        //FNPVVEP-21 FIM
        buscacontratoOriginal = DadosIniciaisRepository.getOriginalContract(numeroApolice);
        System.debug('XXX - buscacontratoOriginal:  '+ JSON.serialize(buscacontratoOriginal));
        System.debug('XXX - numeroApoliceOriginal:  '+ numeroApoliceOriginal);
        System.debug('XXX - numeroApolice:  '+ numeroApolice);
        System.debug('XXX - buscacontratoOriginal.StartDate:  '+ buscacontratoOriginal.StartDate);
        System.debug('XXX - buscaVigenciaContratoOriginal.StartDate:  '+ buscaVigenciaContratoOriginal.StartDate);        

        Quote cotacao = [SELECT Id, OpportunityId FROM Quote WHERE Id =: buscaContratoOriginal.Proposta__c];
     
        opp = [SELECT Id, Numero__c FROM Opportunity WHERE Id =: cotacao.OpportunityId]; //TKCL-584 INICIO/FIM

        Account conta = [SELECT Id, RecordTypeId, cpf__c FROM Account WHERE Id =: buscacontratoOriginal.AccountId];

        rt = [SELECT Id, DeveloperName FROM RecordType WHERE Id =: conta.RecordTypeId]; //TKCL-584 INICIO/FIM
               
        List<GarantiaContrato__c> buscarGarantiaOriginal = DadosIniciaisRepository.getOriginalGuarantee(buscacontratoOriginal.Id);
        System.debug('XXX - buscarGarantiaOriginal:  '+ JSON.serialize(buscarGarantiaOriginal));

        
        mapSiglaxGarantiaContrato = gerarNoCobertura(JSON.serialize(buscarGarantiaOriginal)); // TKCL-584 INICIO/FIM
        mapSiglaxGarantiaContrato2 = gerarNoCobertura(JSON.serialize(buscarGarantiaOriginal)); // TKCL-584 INICIO/FIM
         
        mapFranquiaGarantia = new Map<String, FranquiaGarantia__c>(); //TKCL-584 INICIO/FIM

        System.debug('XXX - mapSiglaxGarantiaContrato:  '+ JSON.serialize(mapSiglaxGarantiaContrato.keyset()));
        System.debug('XXX - buscacontratoOriginal.Produto__c:  '+ JSON.serialize(buscacontratoOriginal.Produto__c));
        
        List<FranquiaGarantia__c> listFranquiaGarantia = DadosIniciaisRepository.getFranchiseGuarantee(mapSiglaxGarantiaContrato.keyset(), buscacontratoOriginal.Produto__c);
        System.debug('XXX - listFranquiaGarantia:  '+ JSON.serialize(listFranquiaGarantia));


        for(FranquiaGarantia__c fg : listFranquiaGarantia){
            mapFranquiaGarantia.put(fg.GarantiaProduto__r.Garantia__r.Sigla__c, fg);
        }

        for(GerarDadosIniciaisTO.CoberturaTO cobertura : mapSiglaxGarantiaContrato.values()){
            FranquiaGarantia__c fg = mapFranquiaGarantia.get(cobertura.sigla);
            if(fg==null) continue;
            cobertura.franquia = fg.Franquia__r.CodigoFranquia__c;
            cobertura.quantidade = fg.GarantiaProduto__r.QuantidadeMaximaContratacao__c ;
        }
      
        contratanteOriginal = DadosIniciaisRepository.getContractorOfContract(buscacontratoOriginal.Id);
        System.debug('XXX - contratanteOriginal:  '+ JSON.serialize(contratanteOriginal));

        grupoOriginal = DadosIniciaisRepository.getGroupContract(contratanteOriginal.Id);
        System.debug('XXX - grupoOriginal:  '+ JSON.serialize(grupoOriginal));

        seguradoOriginal = DadosIniciaisRepository.getContractInsured(grupoOriginal.Id);
        System.debug('XXX - seguradoOriginal:  '+ JSON.serialize(seguradoOriginal));

        remuneracaoOriginal = DadosIniciaisRepository.getContractRemuneration(buscacontratoOriginal.Id);
        System.debug('XXX - remuneracaoOriginal:  '+ JSON.serialize(remuneracaoOriginal));

        //PLV-4715 FIM

        Map<Id, RemuneracaoContrato__c> mapTipoRemuneracao = new Map<Id, RemuneracaoContrato__c>();
        for(RemuneracaoContrato__c remuneracao : remuneracaoOriginal){
            mapTipoRemuneracao.put(remuneracao.TipoRemuneracao__c, remuneracao);
        }
        
        Map<Id, TipoRemuneracao__c> tipoRemuneracaoOriginal = new Map<Id, TipoRemuneracao__c>([SELECT Id, codigo__c FROM TipoRemuneracao__c WHERE Id IN : mapTipoRemuneracao.keySet()]);

        List<FavorecidoRemuneracaoContrato__c> favorecidosOriginal = DadosIniciaisRepository.getFavoredContractRemuneration(remuneracaoOriginal);
        System.debug('XXX - favorecidosOriginal:  '+ JSON.serialize(favorecidosOriginal));


        Set<Id> idsPessoas = new Set<Id>();

        for(FavorecidoRemuneracaoContrato__c favorecido : favorecidosOriginal){
            idsPessoas.add(favorecido.Conta__c);
        }
        
        List<Account> pessoas = DadosIniciaisRepository.getAccountsWithIdInSet(idsPessoas);
        System.debug('XXX - pessoas:  '+ JSON.serialize(pessoas));


        //PLV-4587 INICIO
        List<GrupoProfissoes__c> gProfissoes;
        gProfissoes = DadosIniciaisRepository.getProfessionsGroupByCode(payloadTO.orcamentos[0].contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.profissao);
        System.debug('XXX - gProfissoes:  '+ JSON.serialize(gProfissoes));

        if (gProfissoes.size() > 0) {
            grupoProfissoes = gProfissoes.get(0);
        }
        
        //PLV-4587 FIM
        // TKCL-584 INICIO
        //VIDA-176 - INICIO/FIM
        return ('APTLMKT'.equals(payloadTO.orcamentos[0].codigoProdutoVida) || 'VIDA_ON'.equals(payloadTO.orcamentos[0].codigoProdutoVida))
        ? gerarContratoOriginalRetornoTO_APTLMKT(payloadTO) : gerarContratoOriginalRetornoTO_Geral(payloadTO);
        //VIDA-176 - INICIO/FIM
        
        // return 'APTLMKT'.equals(payloadTO.orcamentos[0].codigoProdutoVida) ?
        // gerarContratoOriginalRetornoTO(payloadTO) : gerarContratoOriginalRetornoTO_Geral(payloadTO);
        // TKCL-584 FIM
   }      
    //PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
    // PLV-4655 - FIM ALTERADO METODO INTEIRO
    //PLV - 4487 - VI - FIM - Gustavo Pereira SYS4B
    //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B 

    //PLV-4168 - V.I - FIM

    // TKCL-584 INICIO
    private GerarDadosIniciaisTO.ContratoOriginalRetornoTO gerarContratoOriginalRetornoTO_Geral(GerarDadosIniciaisTO.PayloadTO payloadTO) {

        GerarDadosIniciaisTO.ContratoOriginalRetornoTO contratoOriginal = new GerarDadosIniciaisTO.ContratoOriginalRetornoTO();

        //POPULA CONTRATO ORIGINAL RAIZ
        contratoOriginal.vigenciaFinal = String.valueOf(buscacontratoOriginal.VigenciaFinal__c);
        contratoOriginal.vigenciaInicial = String.valueOf(buscacontratoOriginal.StartDate);
        contratoOriginal.vigenciaInicialOriginal = String.valueOf(buscaVigenciaContratoOriginal.StartDate); //FNPVVEP-21 INICIO/FIM
        contratoOriginal.numeroOrcamento = Integer.ValueOf(opp.Numero__c);

    //contratoOriginal.endosso = payloadTO.orcamentos[0].contratoOriginal.endosso;
    // PLV-5169
        contratoOriginal.endosso = geraVersaoEndosso(buscacontratoOriginal.NumeroApolice__c);
        contratoOriginal.apolice = payloadTO.orcamentos[0].contratoOriginal.apolice;
        contratoOriginal.sucursal = payloadTO.orcamentos[0].contratoOriginal.sucursal;
        contratoOriginal.codigoProdutoVida = buscacontratoOriginal.Produto__r.ProductCode;
        contratoOriginal.empresa = payloadTO.orcamentos[0].contratoOriginal.empresa;
        contratoOriginal.ramo = payloadTO.orcamentos[0].contratoOriginal.ramo;
        contratoOriginal.tarifa = buscaContratoOriginal.Tarifa__c; //PLV-5303 INICIO / FIM
        //RVI-229 INICIO
        contratoOriginal.tipoSeguro = buscaContratoOriginal.Tipo__c;
        contratoOriginal.dataCalculo = buscaContratoOriginal.Proposta__r.DataCalculo__c;
        //RVI-229 FIM
        //PLV-4715 INICIO
        contratoOriginal.remuneracoes = new List<GerarDadosIniciaisTO.RemuneracaoContratoTO>();
        for(RemuneracaoContrato__c remOriginal : remuneracaoOriginal){
            GerarDadosIniciaisTO.RemuneracaoContratoTO remuneracao = new GerarDadosIniciaisTO.RemuneracaoContratoTO();
            remuneracao.percentual = remOriginal.Percentual__c;
            remuneracao.tipoRemuneracao = remOriginal.TipoRemuneracao__r.Codigo__c;

            remuneracao.favorecidos = new List<GerarDadosIniciaisTO.FavorecidosTO>();
            for(FavorecidoRemuneracaoContrato__c favorecidoOriginal : remOriginal.FavorecidosContrato__r){
                GerarDadosIniciaisTO.FavorecidosTO favorecido = new GerarDadosIniciaisTO.FavorecidosTO();

                favorecido.papel = favorecidoOriginal.Papel__c;
                favorecido.participacao = favorecidoOriginal.Participacao__c;
                favorecido.corretorLider = favorecidoOriginal.CorretorLider__c;
                favorecido.susep = favorecidoOriginal.Susep__c;
                favorecido.antecipacaoComissao = favorecidoOriginal.AntecipacaoComissao__c;

                favorecido.pessoa = new GerarDadosIniciaisTO.PessoaTO();
                favorecido.pessoa.nome = favorecidoOriginal.Conta__r.Name;
                remuneracao.favorecidos.add(favorecido);
            }

            contratoOriginal.remuneracoes.add(remuneracao);
        }
        //PLV-4715 FIM
    
        //POPULA PRECIFICACAO CONTRATO ORIGINAL
        contratoOriginal.precificacao = new GerarDadosIniciaisTO.PrecificacaoContratoOriginalTO();
        contratoOriginal.precificacao.juros = 0;
        contratoOriginal.precificacao.iof = buscacontratoOriginal.ValorIOF__c == null ? 0.0 : buscacontratoOriginal.ValorIOF__c; // PLV-4666 - INICIO / FIM
        contratoOriginal.precificacao.encargos = 0;
        contratoOriginal.precificacao.custoDeApolice = 0;
        contratoOriginal.precificacao.premio = new GerarDadosIniciaisTO.PremioTO();
        contratoOriginal.precificacao.premio.integral = buscaContratoOriginal.PremioIntegral__c == null ? 0.0 : buscaContratoOriginal.PremioIntegral__c; //PLV-5351 INICIO/FIM
        contratoOriginal.precificacao.premio.comercial = buscacontratoOriginal.PremioComercial__c == null ? 0.0 : buscacontratoOriginal.PremioComercial__c; 
        contratoOriginal.precificacao.premio.puro = buscacontratoOriginal.PremioPuro__c == null ? 0.0 : buscacontratoOriginal.PremioPuro__c;
        contratoOriginal.precificacao.premio.total = buscacontratoOriginal.PremioTotal__c == null ? 0.0 : buscacontratoOriginal.PremioTotal__c;

        contratoOriginal.precificacao.premio.premioPago = payloadTO.orcamentos[0].contratoOriginal.premioPago == null ? 0 : payloadTO.orcamentos[0].contratoOriginal.premioPago;
    
        //DESCONTO AGRAVO PRECIFICACAO
        List<GerarDadosIniciaisTO.DescontoAgravoTO> lDescontoPrecificacao = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        
        contratoOriginal.tarifa = buscacontratoOriginal.Tarifa__c;
        System.debug('buscacontratoOriginal.DescontoAgravoMonetarioTecnico__c>> '+ buscacontratoOriginal.DescontoAgravoMonetarioTecnico__c);
        if(buscacontratoOriginal.DescontoAgravoMonetarioTecnico__c != null){
            GerarDadosIniciaisTO.DescontoAgravoTO descontoPrecificacao = new GerarDadosIniciaisTO.DescontoAgravoTO();
            descontoPrecificacao.percentual = buscacontratoOriginal.DescontoAgravoPercentualTecnico__c; 
            //FNPVVEP-71 INICIO
            //descontoPrecificacao.monetario = buscacontratoOriginal.DescontoAgravoMonetarioTecnico__c;
            descontoPrecificacao.monetario = 0;
            //FNPVVEP-71 FIM
            descontoPrecificacao.tipo = 'TEC';        
            lDescontoPrecificacao.add(descontoPrecificacao);
        }
        if(buscacontratoOriginal.DescontoAgravoMonetarioFormaPagto__c != null){
            GerarDadosIniciaisTO.DescontoAgravoTO descontoPrecificacao = new GerarDadosIniciaisTO.DescontoAgravoTO();
            descontoPrecificacao.percentual = buscacontratoOriginal.DescontoAgravoPercentualFormaPagto__c;
            descontoPrecificacao.monetario = buscacontratoOriginal.DescontoAgravoMonetarioFormaPagto__c;
            descontoPrecificacao.tipo = 'FPG';        
            lDescontoPrecificacao.add(descontoPrecificacao);
        }
        
        contratoOriginal.precificacao.descontoAgravo = lDescontoPrecificacao;
        System.debug('contratoOriginal.precificacao.descontoAgravo>> ' + contratoOriginal.precificacao.descontoAgravo);

        //COBERTURAS PRECIFICACAO
        contratoOriginal.precificacao.coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();
        contratoOriginal.precificacao.coberturas.addAll(mapSiglaxGarantiaContrato.values());
        System.debug('contratoOriginal.precificacao.coberturas>> ' + contratoOriginal.precificacao.coberturas);
        System.debug('mapSiglaxGarantiaContrato.values() ' + mapSiglaxGarantiaContrato.values());
        //System.debug('contratoOriginal.precificacao.coberturas.descontoAgravo>> ' + contratoOriginal.precificacao.coberturas.descontoAgravo);
        for(GerarDadosIniciaisTO.CoberturaTO cobertura : contratoOriginal.precificacao.coberturas){
            cobertura.capitalContratacao = cobertura.valor;
            cobertura.valor=null;
            cobertura.franquia = null;
            cobertura.quantidade = null;
            System.debug('cobertura.descontoAgravo>> ' + cobertura.descontoAgravo);
            //FNPVVEP-71 INICIO
            List<GerarDadosIniciaisTO.DescontoAgravoTO> descontoAgravoList = cobertura.descontoAgravo;
            for (GerarDadosIniciaisTO.DescontoAgravoTO descontoAgravo : descontoAgravoList) {
                if (descontoAgravo.tipo.equals('TEC')) {
                    descontoAgravo.monetario = 0;
                }
            }
            //FNPVVEP-71 FIM
        }
        List<GerarDadosIniciaisTO.ContratanteTO> contratantesPrecificacao = new List<GerarDadosIniciaisTO.ContratanteTO>();
        contratantesPrecificacao.add(gerarNoContratante(contratanteOriginal));

        List<GerarDadosIniciaisTO.GrupoTO> gruposPrecificacao = new List<GerarDadosIniciaisTO.GrupoTO>();
        gruposPrecificacao.add(gerarNoGrupo(grupoOriginal));

        List<GerarDadosIniciaisTO.SeguradoTO> seguradosPrecificacao = new List<GerarDadosIniciaisTO.SeguradoTO>();

        seguradosPrecificacao.add(gerarNoSegurado(seguradoOriginal));
        seguradosPrecificacao[0].coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();
        seguradosPrecificacao[0].coberturas.addAll(contratoOriginal.precificacao.coberturas);


        gruposPrecificacao[0].segurados = seguradosPrecificacao;
        contratantesPrecificacao[0].grupos = gruposPrecificacao;
        contratoOriginal.precificacao.contratantes = contratantesPrecificacao;

        //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B - FIX 1	
        //CODIGO REMOVIDO

        // POPULA CONTRATANTE CONTRATO ORIGINAL
        contratoOriginal.contratantes = new List<GerarDadosIniciaisTO.ContratanteTO>();
        GerarDadosIniciaisTO.ContratanteTO contratante = new GerarDadosIniciaisTO.ContratanteTO();
        contratante = gerarNoContratante(contratanteOriginal);
        contratante.tipo = contratanteOriginal.Tipo__c == 'Principal' ? 'PRI' : 'Dependente';
        
        // PLV-4715 INICIO
        contratante.pessoa = new GerarDadosIniciaisTO.PessoaTO(contratanteOriginal);
        contratante.pessoa.tipo = rt.DeveloperName ==  'PessoaFisica' ? 'FIS' : 'JUR'; //PLV-4813 INICIO/FIM
        // PLV-4715 FIM

        
        // POPULA GRUPO DO CONTRATANTE CONTRATO ORIGINAL
        contratante.grupos = new List<GerarDadosIniciaisTO.GrupoTO>();
        GerarDadosIniciaisTO.GrupoTO grupo = new GerarDadosIniciaisTO.GrupoTO();
        grupo = gerarNoGrupo(grupoOriginal); //PLV - 4666 - FIX 1 - HENRIQUE R. META INÍCIO/FIM
        grupo.numero = 1;
        grupo.nome = grupoOriginal.Name;
        grupo.qtdeVidas = Integer.ValueOf(grupoOriginal.QuantidadeVidas__c);
            
        // POPULA SEGURADO DO GRUPO DO CONTRATANTE CONTRATO ORIGINAL
        grupo.segurados = new List<GerarDadosIniciaisTO.SeguradoTO>();
        GerarDadosIniciaisTO.SeguradoTO segurado = montarSeguradoContratoOriginal(); //TKCL-584 INICIO/FIM
        contratante.dadosPagamento = new GerarDadosIniciaisTO.DadosPagamentoTO(contratanteOriginal);
    
        grupo.segurados.add(segurado);
        contratante.grupos.add(grupo);
        contratoOriginal.contratantes.add(contratante);

        //PLV - 4626 - VI - FIM - GUSTAVO PEREIRA SYS4B - FIX 1	     
        //  Decimal premioPagoTotal = 0;
        //  for(ParcelasContratoController.Parcelamento to : ParcelasContratoController.obterParcelas(contratanteOriginal.id)){
        //      if(to.status == 'PAGA'){
        //          premioPagoTotal += Decimal.valueOf(to.valorTotal);
        //      }
        //  }
        //  contratoOriginal.precificacao.premio.premioPago = premioPagoTotal == null ? 0 : premioPagoTotal;  
        
        //PLV-5134 INICIO
        for(GerarDadosIniciaisTO.CoberturaTO cobertura : contratoOriginal.contratantes[0].grupos[0].segurados[0].coberturas){
            if(cobertura.sigla == 'DIT'){
                cobertura.quantidade = 0; 
            } 
        }
        //PLV-5134 FIM
        system.debug('ZZZ - contratoOriginal' + JSON.serialize(contratoOriginal));
        return contratoOriginal;
    }

    // TKCL-584 INICIO
    private GerarDadosIniciaisTO.ContratoOriginalRetornoTO gerarContratoOriginalRetornoTO_APTLMKT(GerarDadosIniciaisTO.PayloadTO payloadTO) {

        GerarDadosIniciaisTO.ContratoOriginalRetornoTO contratoOriginal = new GerarDadosIniciaisTO.ContratoOriginalRetornoTO();

        contratoOriginal.tarifa = buscaContratoOriginal.Tarifa__c; 
        // RVI-229 INICIO
        contratoOriginal.tipoSeguro = buscaContratoOriginal.Tipo__c;
        contratoOriginal.dataCalculo = buscaContratoOriginal.Proposta__r.DataCalculo__c;
        // RVI-229 FIM
        contratoOriginal.vigenciaFinal = String.valueOf(buscacontratoOriginal.VigenciaFinal__c);
        contratoOriginal.vigenciaInicial = String.valueOf(buscacontratoOriginal.StartDate);
        contratoOriginal.qtdDiasVigencia = buscacontratoOriginal.StartDate.daysBetween(buscacontratoOriginal.VigenciaFinal__c) + 1; //TKCL-584 INICIO/FIM
        contratoOriginal.numeroOrcamento = Integer.ValueOf(opp.Numero__c);
        // TKCL-584-FIX01 INICIO
        contratoOriginal.endosso = payloadTO.orcamentos[0].contratoOriginal.endosso;
        contratoOriginal.apolice = payloadTO.orcamentos[0].contratoOriginal.apolice;
        contratoOriginal.sucursal = payloadTO.orcamentos[0].contratoOriginal.sucursal;
        contratoOriginal.empresa = payloadTO.orcamentos[0].contratoOriginal.empresa;
        contratoOriginal.ramo = payloadTO.orcamentos[0].contratoOriginal.ramo;
        // TKCL-584-FIX01 FIM
        // contratoOriginal.cicloVacinal = handleNullString(seguradoOriginal.CicloVacinal__c) == '' ? '0' : seguradoOriginal.CicloVacinal__c;
        //II-25 INICIO
            // contratoOriginal.dadosPessoaFisica = new GerarDadosIniciaisTO.DadosPessoaFisicaTO();
            // contratoOriginal.dadosPessoaFisica.sexo = handleNullString(seguradoOriginal.Conta__r.Sexo__c);
            // contratoOriginal.dadosPessoaFisica.dataNascimento = String.valueOf(seguradoOriginal.Conta__r.PersonBirthdate);
        
            contratoOriginal.segurados = new List<GerarDadosIniciaisTO.Segurado_NovoTO>();
            GerarDadosIniciaisTO.Segurado_NovoTO segurado = new GerarDadosIniciaisTO.Segurado_NovoTO();
            segurado.nome = seguradoOriginal.Nome__c;
            segurado.nomeSocial = seguradoOriginal.NomeSocial__c; // LECVPV-188 INICIO/FIM
            segurado.rendaMensal = seguradoOriginal.RendaMensal__c;
            segurado.pessoaExpostaPoliticamente = seguradoOriginal.PEP__c;
            segurado.email = seguradoOriginal.email__c;

            segurado.enderecos = new List<EmissaoTO.EnderecoTO>();

            EmissaoTO.EnderecoTO seguradoEndereco = new EmissaoTO.EnderecoTO();
            seguradoEndereco.tipoEndereco = 'Residencial'; //PLV-4813 INICIO/FIM
            seguradoEndereco.logradouro =  handleNullString(seguradoOriginal.logradouroResidencial__c);
            seguradoEndereco.numeroLogradouro =  handleNullString(seguradoOriginal.numeroResidencial__c);
            seguradoEndereco.complemento =  handleNullString(seguradoOriginal.ComplementoResidencial__c);
            seguradoEndereco.bairro =  handleNullString(seguradoOriginal.BairroResidencial__c);
            seguradoEndereco.cidade =  handleNullString(seguradoOriginal.CidadeResidencial__c);
            seguradoEndereco.uf =  handleNullString(seguradoOriginal.UFResidencial__c);
            seguradoEndereco.paisResidencia =  handleNullString(seguradoOriginal.paisResidencial__c);
            seguradoEndereco.cep =  handleNullString(seguradoOriginal.cepResidencial__c);
            seguradoEndereco.complementoCep = '';
            segurado.enderecos.add(seguradoEndereco);

            segurado.telefones = new List<EmissaoTO.TelefoneTO>();

            EmissaoTO.TelefoneTO seguradoOriginalTelCelular = new EmissaoTO.TelefoneTO();
            seguradoOriginalTelCelular.tipoTelefone = 'Celular';
            seguradoOriginalTelCelular.numeroTelefone = handleNullString(seguradoOriginal.Celular__c);
            segurado.telefones.add(seguradoOriginalTelCelular);
            
            EmissaoTO.TelefoneTO seguradoOriginalTelResidencial = new EmissaoTO.TelefoneTO();
            seguradoOriginalTelResidencial.tipoTelefone = 'Residencial';
            seguradoOriginalTelResidencial.numeroTelefone= handleNullString(seguradoOriginal.TelefoneResidencial__c);
            segurado.telefones.add(seguradoOriginalTelResidencial);
    
            EmissaoTO.TelefoneTO seguradoOriginalTelComercial = new EmissaoTO.TelefoneTO();
            seguradoOriginalTelComercial.tipoTelefone = 'Comercial';
            seguradoOriginalTelComercial.numeroTelefone= handleNullString(seguradoOriginal.TelefoneComercial__c);
            segurado.telefones.add(seguradoOriginalTelComercial);
        
            segurado.dadosPessoaFisica = new GerarDadosIniciaisTO.DadosPessoaFisicaTO();
            segurado.dadosPessoaFisica.sexo = handleNullString(seguradoOriginal.Conta__r.Sexo__c);
            segurado.dadosPessoaFisica.dataNascimento = String.valueOf(seguradoOriginal.Conta__r.PersonBirthdate);
            //segurado.dadosPessoaFisica.profissao = g != null && g.GrupoRisco__c != null  ? seguradoOriginal.Profissao__r.CodigoProfissao__c!=null ? seguradoOriginal.Profissao__r.CodigoProfissao__c : seguradoOriginal.Conta__r.Profissao__r.CodigoProfissao__c!=null ? seguradoOriginal.Conta__r.Profissao__r.CodigoProfissao__c : '' : '';
            segurado.dadosPessoaFisica.resideBrasil = seguradoOriginal.paisResidencial__c != null ? seguradoOriginal.paisResidencial__c.toLowercase() == 'brasil' || seguradoOriginal.paisResidencial__c.toLowercase() == 'brazil' : false;
            segurado.dadosPessoaFisica.paisResidente = handleNullString(seguradoOriginal.paisResidencial__c);
            segurado.dadosPessoaFisica.nacionalidade = handleNullString(seguradoOriginal.Nacionalidade__c);
            segurado.dadosPessoaFisica.estadoCivil =  handleNullString(seguradoOriginal.EstadoCivil__c);

            if(String.isNotBlank(seguradoOriginal.Cpf__c) ||  String.isNotBlank(seguradoOriginal.Conta__r.Cpf__c)){
            String cpfSeguradoOriginal = seguradoOriginal.Cpf__c!=null ? seguradoOriginal.Cpf__c.replace('.','').replace('-', '') :seguradoOriginal.Conta__r.Cpf__c.replace('.','').replace('-', '');
            segurado.dadosPessoaFisica.numeroCpf = cpfSeguradoOriginal.substring(0, cpfSeguradoOriginal.length() - 2);
            segurado.dadosPessoaFisica.digitoCpf = cpfSeguradoOriginal.replace('.','').replace('-', '').right(2);
            }else{
            segurado.dadosPessoaFisica.numeroCpf = '';
            segurado.dadosPessoaFisica.digitoCpf =  '';
            }   


            segurado.beneficiarios = new List<GerarDadosIniciaisTO.BeneficiarioTO>();
            for(BeneficiarioSeguradoContrato__c beneficiarioOriginal : seguradoOriginal.Benefici_rios_dos_segurados_do_contrato__r){
            GerarDadosIniciaisTO.BeneficiarioTO beneficiario = new GerarDadosIniciaisTO.BeneficiarioTO();
            beneficiario.tipoBeneficiario = beneficiarioOriginal.TipoBeneficiario__c;
            beneficiario.nome = beneficiarioOriginal.Nome__c;
            beneficiario.nomeSocial = beneficiarioOriginal.NomeSocial__c; // LECVPV-188 INICIO/FIM
            beneficiario.cpf = beneficiarioOriginal.CpfCnpj__c;
            beneficiario.nascimento = beneficiarioOriginal.Data_de_Nascimento__c;
            beneficiario.sexoBeneficiario =  beneficiarioOriginal.Sexo__c;
            beneficiario.grauParentesco = beneficiarioOriginal.GrauParentesco__c;
            beneficiario.grauParentescoOutros = beneficiarioOriginal.BeneficiarioGrauParentescoOutros__c;
            beneficiario.percentualIndenizacao = beneficiarioOriginal.PercentualIndenizacao__c;
            segurado.beneficiarios.add(beneficiario);
            }

            contratoOriginal.segurados.add(segurado);

            contratoOriginal.dadosPagamento = new GerarDadosIniciaisTO.DadosPagamentoTO(contratanteOriginal);
        // II-25 FIM


        contratoOriginal.remuneracoes = new List<GerarDadosIniciaisTO.RemuneracaoContratoTO>();
        for(RemuneracaoContrato__c remOriginal : remuneracaoOriginal){
            GerarDadosIniciaisTO.RemuneracaoContratoTO remuneracao = new GerarDadosIniciaisTO.RemuneracaoContratoTO();
            remuneracao.percentual = remOriginal.Percentual__c;
            remuneracao.tipoRemuneracao = remOriginal.TipoRemuneracao__r.Codigo__c;
            contratoOriginal.remuneracoes.add(remuneracao);
        }
        //II-10 FIX02 INICIO
        List<GerarDadosIniciaisTO.VersaoCalculoTO> versoesCalculoFiltrado = new List<GerarDadosIniciaisTO.VersaoCalculoTO>();
        if(versoesCalculo != null && !versoesCalculo.isEmpty()){
            for(GerarDadosIniciaisTO.VersaoCalculoTO vCal : versoesCalculo){
                if(vCal.descontoAgravo == buscacontratoOriginal.DescontoAgravoPercentualFormaPagto__c){
                    versoesCalculoFiltrado.add(vCal);
                }
            }
            contratoOriginal.versoesCalculos = versoesCalculoFiltrado;
        }
        //contratoOriginal.versoesCalculos = versoesCalculo;
        //II-10 FIX02 FIM

        contratoOriginal.precificacao = new GerarDadosIniciaisTO.PrecificacaoContratoOriginalTO();
        List<GerarDadosIniciaisTO.DescontoAgravoTO> lDescontoPrecificacao = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();

        if(buscacontratoOriginal.DescontoAgravoMonetarioTecnico__c != null){
            GerarDadosIniciaisTO.DescontoAgravoTO descontoPrecificacao = new GerarDadosIniciaisTO.DescontoAgravoTO();
            descontoPrecificacao.percentual = buscacontratoOriginal.DescontoAgravoPercentualTecnico__c; 
            descontoPrecificacao.monetario = buscacontratoOriginal.DescontoAgravoMonetarioTecnico__c;
            descontoPrecificacao.tipo = 'TEC';        
            lDescontoPrecificacao.add(descontoPrecificacao);
        }
        if(buscacontratoOriginal.DescontoAgravoMonetarioFormaPagto__c != null){
            GerarDadosIniciaisTO.DescontoAgravoTO descontoPrecificacao = new GerarDadosIniciaisTO.DescontoAgravoTO();
            descontoPrecificacao.percentual = buscacontratoOriginal.DescontoAgravoPercentualFormaPagto__c;
            descontoPrecificacao.monetario = buscacontratoOriginal.DescontoAgravoMonetarioFormaPagto__c;
            descontoPrecificacao.tipo = 'FPG';        
            lDescontoPrecificacao.add(descontoPrecificacao);
        }
        
        contratoOriginal.precificacao.descontoAgravo = lDescontoPrecificacao;
        contratoOriginal.coberturas = new List< GerarDadosIniciaisTo.CoberturaTO>(); 
        contratoOriginal.precificacao.coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();

        List<GerarDadosIniciaisTO.CoberturaTO> coberturasNoRetornosCalculo = new List<GerarDadosIniciaisTO.CoberturaTO>();

        for (GerarDadosIniciaisTO.CoberturaTO coberturaTO: mapSiglaxGarantiaContrato.values()) {
            
            GerarDadosIniciaisTo.CoberturaTO coberturaNoPrecificacao = new  GerarDadosIniciaisTo.CoberturaTO();
            coberturaNoPrecificacao.sigla = coberturaTO.sigla;
            coberturaNoPrecificacao.descontoAgravo = coberturaTO.descontoAgravo;
            contratoOriginal.precificacao.coberturas.add(coberturaNoPrecificacao);

            GerarDadosIniciaisTo.CoberturaTO coberturaNoRaiz = new  GerarDadosIniciaisTo.CoberturaTO();
            coberturaNoRaiz.sigla = coberturaTO.sigla;
            coberturaNoRaiz.valor = coberturaTO.valor;
            coberturaNoRaiz.quantidade = coberturaTO.quantidade;
            coberturaNoRaiz.unidade = handleNullString(coberturaTO.unidade);
            contratoOriginal.coberturas.add(coberturaNoRaiz);

            GerarDadosIniciaisTo.CoberturaTO coberturaNoRetornosCalculo = new  GerarDadosIniciaisTo.CoberturaTO();

            coberturaNoRetornosCalculo.sigla = coberturaTO.sigla;
            coberturaNoRetornosCalculo.iof = coberturaTO.iof;
            coberturaNoRetornosCalculo.premio = coberturaTO.premio; // verificar puroCarregado
            coberturaNoRetornosCalculo.descontoAgravo = coberturaTO.descontoAgravo;
            coberturaNoRetornosCalculo.taxa = coberturaTO.taxa;
            coberturasNoRetornosCalculo.add(coberturaNoRetornosCalculo);
        } 

        contratoOriginal.precificacao.premio = new GerarDadosIniciaisTO.PremioTO();
        contratoOriginal.precificacao.premio.integral = buscaContratoOriginal.PremioIntegral__c == null ? 0.0 : buscaContratoOriginal.PremioIntegral__c; 
        contratoOriginal.precificacao.premio.comercial = buscacontratoOriginal.PremioComercial__c == null ? 0.0 : buscacontratoOriginal.PremioComercial__c; 
        contratoOriginal.precificacao.premio.puro = buscacontratoOriginal.PremioPuro__c == null ? 0.0 : buscacontratoOriginal.PremioPuro__c;
        contratoOriginal.precificacao.premio.total = buscacontratoOriginal.PremioTotal__c == null ? 0.0 : buscacontratoOriginal.PremioTotal__c;
        contratoOriginal.precificacao.premio.premioPago = payloadTO.orcamentos[0].contratoOriginal.premioPago == null ? 0 : payloadTO.orcamentos[0].contratoOriginal.premioPago;

        contratoOriginal.retornosCalculoOriginal = new List<GerarDadosIniciaisTO.RetornosCalculoOriginalTO>();

        GerarDadosIniciaisTO.RetornosCalculoOriginalTO retornoCalculoOriginal = new GerarDadosIniciaisTO.RetornosCalculoOriginalTO();
        retornoCalculoOriginal.tarifa = buscaContratoOriginal.Tarifa__c; 
        retornoCalculoOriginal.dlls = new List<String>();
        retornoCalculoOriginal.dlls.add(buscaContratoOriginal.DLL__c);
    
        retornoCalculoOriginal.precificacao = new GerarDadosIniciaisTO.PrecificacaoTO();
        retornoCalculoOriginal.precificacao.premio = new GerarDadosIniciaisTO.PremioTO();
        retornoCalculoOriginal.precificacao.premio.puro = buscacontratoOriginal.PremioPuro__c == null ? 0.0 : buscacontratoOriginal.PremioPuro__c;
        retornoCalculoOriginal.precificacao.premio.comercial = buscacontratoOriginal.PremioComercial__c == null ? 0.0 : buscacontratoOriginal.PremioComercial__c;
        retornoCalculoOriginal.precificacao.premio.puroCarregado = buscacontratoOriginal.PremioComercial__c == null ? 0.0 : buscacontratoOriginal.PremioComercial__c;  
        retornoCalculoOriginal.precificacao.premio.total = buscacontratoOriginal.PremioTotal__c == null ? 0.0 : buscacontratoOriginal.PremioTotal__c;

        retornoCalculoOriginal.precificacao.premio.descontoAgravo = lDescontoPrecificacao;
        retornoCalculoOriginal.precificacao.coberturas = coberturasNoRetornosCalculo;

        contratoOriginal.retornosCalculoOriginal.add(retornoCalculoOriginal);
        String jsonignorenullvalues = JSON.serialize(contratoOriginal,true);
        contratoOriginal = (GerarDadosIniciaisTO.ContratoOriginalRetornoTO) JSON.deserialize(jsonignorenullvalues, GerarDadosIniciaisTO.ContratoOriginalRetornoTO.class);

        System.debug('Giordano contrato Original APTLMKT: '+ JSON.serialize(contratoOriginal,true));

        return contratoOriginal;
    }

    // PLV-4715 INICIO
    private String handleNullString(String strg){
        return strg == null ? '' : strg;
    }
    // PLV-4715 FIM
    //PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    public String gerarNumeroApolice (GerarDadosIniciaisTO.PayloadTO payloadTO){
        ContractDAO contractDao = ContractDAO.getInstance(); //PLV-5169 - INICIO/FIM
        String numeroApolice;
        String numeroEndosso;

        //PLV-5169 inicio  
        Contract premioContrato = contractDao.findByContractFields(payloadTO.orcamentos[0].contratoOriginal.apolice
                                                                    , payloadTO.orcamentos[0].contratoOriginal.sucursal
                                                                    , payloadTO.orcamentos[0].contratoOriginal.ramo
                                                                    , payloadTO.orcamentos[0].contratoOriginal.endosso
                                                                    , payloadTO.orcamentos[0].contratoOriginal.empresa);
     
        if (premioContrato.PremioTotal__c == 0) {
            Contract premioContrato1 = contractDao.findByPolicyNumberAndTotalAward(payloadTO.orcamentos[0].contratoOriginal.apolice);
            numeroEndosso = premioContrato1.Endosso__c;  
        } else {
            numeroEndosso = payloadTO.orcamentos[0].contratoOriginal.endosso;
        }
        //PLV-5169 FIM 
            numeroApolice = payloadTO.orcamentos[0].contratoOriginal.empresa +'-'+
            payloadTO.orcamentos[0].contratoOriginal.sucursal +'-'+
            payloadTO.orcamentos[0].contratoOriginal.ramo +'-'+
            payloadTO.orcamentos[0].contratoOriginal.apolice +'-'+
            numeroEndosso;
        
        system.debug('>>>>NumeroApolice-Composto>>>'+numeroApolice);
        return numeroApolice;
    }
     //PLV-5169 inicio 
    public static string geraVersaoEndosso(String NumeroApolice) {
        Contract PremioContrato = [Select Id, Name, Endosso__c, PremioTotal__c, NumeroApolice__c from Contract where NumeroApolice__c =:NumeroApolice  order by CreatedDate desc limit 1];
        system.debug('>>>>NumeroApolice-Composto>>>'+ PremioContrato.Endosso__c);
        return PremioContrato.Endosso__c;
    }
    //PLV-5169 FIM
    
    public static GerarDadosIniciaisTO.GrupoTO gerarNoGrupo(GrupoContrato__c objGrupo){
                   
        GerarDadosIniciaisTO.GrupoTO Grupo = new GerarDadosIniciaisTO.GrupoTO();
        Grupo.iof = objGrupo.IOF__c;
        Grupo.numero = 1;

        Grupo.premio = new GerarDadosIniciaisTO.PremioTO();
        Grupo.premio.integral = objGrupo.PremioIntegral__c != null ? objGrupo.PremioIntegral__c : 0; //PLV-5351 INICIO/FIM
        Grupo.premio.comercial = objGrupo.PremioComercial__c !=null ? objGrupo.PremioComercial__c : 0 ;
        Grupo.premio.puro = objGrupo.PremioPuro__c !=null ? objGrupo.PremioPuro__c : 0 ;
        Grupo.premio.total = objGrupo.PremioTotal__c !=null ? objGrupo.PremioTotal__c : 0 ;
        
        Grupo.taxa = new GerarDadosIniciaisTO.TaxaTO();
        Grupo.taxa.comercial = objGrupo.TaxaComercial__c != null ? objGrupo.TaxaComercial__c : 0;
        Grupo.taxa.pura = objGrupo.TaxaPura__c != null ? objGrupo.TaxaPura__c : 0;
        Grupo.taxa.total = objGrupo.TaxaTotal__c != null ? objGrupo.TaxaTotal__c : 0;
        

        Grupo.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        if(objGrupo.DescontoAgravoPercentualFormaPagto__c !=null || objGrupo.DescontoAgravoMonetarioFormaPagto__c!=null){
            GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
            dA.monetario = objGrupo.DescontoAgravoMonetarioFormaPagto__c;
            dA.percentual = objGrupo.DescontoAgravoPercentualFormaPagto__c;
            dA.tipo = 'FPG';
            Grupo.descontoAgravo.add(dA);
        }
        if(objGrupo.DescontoAgravoPercentualInformado__c !=null || objGrupo.DescontoAgravoMonetarioInformado__c!=null){
            GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
            dA.monetario = objGrupo.DescontoAgravoPercentualInformado__c;
            dA.percentual = objGrupo.DescontoAgravoMonetarioInformado__c;
            dA.tipo = 'BAT';
            Grupo.descontoAgravo.add(dA);
        }
        if(objGrupo.DescontoAgravoPercentualTecnico__c !=null || objGrupo.DescontoAgravoMonetarioTecnico__c!=null){
            GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
            dA.monetario = objGrupo.DescontoAgravoPercentualTecnico__c;
            dA.percentual = objGrupo.DescontoAgravoMonetarioTecnico__c;
            dA.tipo = 'TEC';
            Grupo.descontoAgravo.add(dA);
        }
        return Grupo;
    }

    // TKCL-584 INICIO
    private GerarDadosIniciaisTO.SeguradoTO montarSeguradoContratoOriginal() {
        GerarDadosIniciaisTO.SeguradoTO segurado = gerarNoSegurado(seguradoOriginal);
        segurado.pessoa = new GerarDadosIniciaisTO.PessoaTO();
        segurado.pessoa.tipo = rt.DeveloperName ==  'PessoaFisica' ? 'FIS' : 'JUR';

        // PLV-4715 INICIO
        // segurado.pessoa.nome = payloadTO.orcamentos[0].contratantes[0].grupos[0].segurados[0].pessoa.nome;
        // segurado.pessoa.rendaMensal = payloadTO.orcamentos[0].contratantes[0].grupos[0].segurados[0].pessoa.rendaMensal; //PLV-4655 fix 1 - INICIO
        segurado.pessoa.nome = handleNullString(seguradoOriginal.Nome__c);
        segurado.pessoa.nomeSocial = handleNullString(seguradoOriginal.NomeSocial__c); // LECVPV-188 INICIO/FIM 
        try {
            segurado.pessoa.rendaMensal = seguradoOriginal.RendaMensal__c != null ? Decimal.valueOf(seguradoOriginal.RendaMensal__c) : 0; 
        } catch (Exception e) {
            segurado.pessoa.rendaMensal = 0;
            System.debug('Erro on parsing segurado.pessoa.rendaMensal');
        } 
        segurado.pessoa.melhorPeriodo = handleNullString(seguradoOriginal.melhorPeriodo__c);
        segurado.pessoa.pessoaExpostaPoliticamente = seguradoOriginal.PEP__c;
        segurado.pessoa.email = handleNullString(seguradoOriginal.email__c);
        
        segurado.pessoa.enderecos = new List<EmissaoTO.EnderecoTO>();

        EmissaoTO.EnderecoTO seguradoEnderecoResidencial = new EmissaoTO.EnderecoTO();
        seguradoEnderecoResidencial.tipoEndereco = 'Residencial'; //PLV-4813 INICIO/FIM
        seguradoEnderecoResidencial.logradouro =  handleNullString(seguradoOriginal.logradouroResidencial__c);
        seguradoEnderecoResidencial.numeroLogradouro =  handleNullString(seguradoOriginal.numeroResidencial__c);
        seguradoEnderecoResidencial.complemento =  handleNullString(seguradoOriginal.ComplementoResidencial__c);
        seguradoEnderecoResidencial.bairro =  handleNullString(seguradoOriginal.BairroResidencial__c);
        seguradoEnderecoResidencial.cidade =  handleNullString(seguradoOriginal.CidadeResidencial__c);
        seguradoEnderecoResidencial.uf =  handleNullString(seguradoOriginal.UFResidencial__c);
        seguradoEnderecoResidencial.paisResidencia =  handleNullString(seguradoOriginal.paisResidencial__c);
        seguradoEnderecoResidencial.cep =  handleNullString(seguradoOriginal.cepResidencial__c);
        seguradoEnderecoResidencial.complementoCep = '';
        segurado.pessoa.enderecos.add(seguradoEnderecoResidencial);
        
        EmissaoTO.EnderecoTO seguradoEnderecoComercial = new EmissaoTO.EnderecoTO();
        seguradoEnderecoComercial.tipoEndereco = 'PES';
        seguradoEnderecoComercial.logradouro =  handleNullString(seguradoOriginal.LogradouroComercial__c);
        seguradoEnderecoComercial.numeroLogradouro =  handleNullString(seguradoOriginal.NumeroComercial__c);
        seguradoEnderecoComercial.complemento =  handleNullString(seguradoOriginal.ComplementoComercial__c);
        seguradoEnderecoComercial.bairro =  handleNullString(seguradoOriginal.BairroComercial__c);
        seguradoEnderecoComercial.cidade =  handleNullString(seguradoOriginal.CidadeComercial__c);
        seguradoEnderecoComercial.uf =  handleNullString(seguradoOriginal.UFComercial__c);
        seguradoEnderecoComercial.paisResidencia =  handleNullString(seguradoOriginal.PaisComercial__c);
        seguradoEnderecoComercial.cep =  handleNullString(seguradoOriginal.CEPComercial__c);
        seguradoEnderecoComercial.complementoCep = '';
        segurado.pessoa.enderecos.add(seguradoEnderecoComercial);
        
        segurado.pessoa.telefones = new List<EmissaoTO.TelefoneTO>();

        EmissaoTO.TelefoneTO seguradoOriginalTelCelular = new EmissaoTO.TelefoneTO();
        seguradoOriginalTelCelular.tipoTelefone = 'Celular';
        seguradoOriginalTelCelular.numeroTelefone = handleNullString(seguradoOriginal.Celular__c);
        segurado.pessoa.telefones.add(seguradoOriginalTelCelular);
        
        EmissaoTO.TelefoneTO seguradoOriginalTelResidencial = new EmissaoTO.TelefoneTO();
        seguradoOriginalTelResidencial.tipoTelefone = 'Residencial';
        seguradoOriginalTelResidencial.numeroTelefone= handleNullString(seguradoOriginal.TelefoneResidencial__c);
        segurado.pessoa.telefones.add(seguradoOriginalTelResidencial);

        EmissaoTO.TelefoneTO seguradoOriginalTelComercial = new EmissaoTO.TelefoneTO();
        seguradoOriginalTelComercial.tipoTelefone = 'Comercial';
        seguradoOriginalTelComercial.numeroTelefone= handleNullString(seguradoOriginal.TelefoneComercial__c);
        segurado.pessoa.telefones.add(seguradoOriginalTelComercial);
        // PLV-4715 FIM

        segurado.pessoa.dadosPessoaFisica = new GerarDadosIniciaisTO.DadosPessoaFisicaTO(true); //TKCL-584 INICIO/FIM
        
        //PLV-4587 INICIO        
        segurado.pessoa.dadosPessoaFisica.profissao = grupoProfissoes != null && grupoProfissoes.GrupoRisco__c != null  ? seguradoOriginal.Profissao__r.CodigoProfissao__c!=null ? seguradoOriginal.Profissao__r.CodigoProfissao__c : seguradoOriginal.Conta__r.Profissao__r.CodigoProfissao__c!=null ? seguradoOriginal.Conta__r.Profissao__r.CodigoProfissao__c : '' : '';
        System.debug('segmento final .. '+segurado.pessoa.dadosPessoaFisica.profissao);
        segurado.pessoa.dadosPessoaFisica.grupoProfissao = grupoProfissoes != null && grupoProfissoes.GrupoRisco__c != null ? grupoProfissoes.GrupoRisco__r.Name : ''; 
        System.debug('grupoProfissao fianl .. '+segurado.pessoa.dadosPessoaFisica.grupoProfissao);    
        //PLV-4587 FIM
        segurado.pessoa.dadosPessoaFisica.sexo = handleNullString(seguradoOriginal.Conta__r.Sexo__c);
        segurado.pessoa.dadosPessoaFisica.fumante = 'SIM'.equalsIgnoreCase(seguradoOriginal.Conta__r.Fumante__c)? true : false;
        segurado.pessoa.dadosPessoaFisica.dataNascimento = String.valueOf(seguradoOriginal.Conta__r.PersonBirthdate);
        segurado.pessoa.dadosPessoaFisica.regimeTrabalho =  handleNullString(seguradoOriginal.Conta__r.RegimeTrabalho__c);
        // PLV-5150 - FIX02 - INICIO
        //segurado.pessoa.dadosPessoaFisica.CicloVacinalEnd =  ( handleNullString(seguradoOriginal.CicloVacinal__c) == '' ? '0' : seguradoOriginal.CicloVacinal__c ); // PLV-5150 - FIX01 - INICIO/FIM
        this.cicloVacinalOriginal =  ( handleNullString(seguradoOriginal.CicloVacinal__c) == '' ? '0' : seguradoOriginal.CicloVacinal__c ); // PLV-5150 - FIX01 - INICIO/FIM
        // PLV-5150 - FIX02 - FIM

        // PLV-4715 INICIO
        segurado.pessoa.dadosPessoaFisica.docIdentificacao = handleNullString(seguradoOriginal.DocumentoIdentificacao__c);
        segurado.pessoa.dadosPessoaFisica.paisResidente = handleNullString(seguradoOriginal.paisResidencial__c);
        segurado.pessoa.dadosPessoaFisica.resideBrasil = seguradoOriginal.paisResidencial__c != null ? seguradoOriginal.paisResidencial__c.toLowercase() == 'brasil' || seguradoOriginal.paisResidencial__c.toLowercase() == 'brazil' : false;
        segurado.pessoa.dadosPessoaFisica.estadoCivil = handleNullString(seguradoOriginal.EstadoCivil__c);
        segurado.pessoa.dadosPessoaFisica.nacionalidade =  handleNullString(seguradoOriginal.Nacionalidade__c);
        segurado.pessoa.dadosPessoaFisica.paisDeOrigem =  handleNullString(seguradoOriginal.PaisDeOrigem__c); //PLV-5231 INICIO/FIM
        segurado.pessoa.dadosPessoaFisica.orgaoExpedidor = handleNullString(seguradoOriginal.OrgaoExpedidorDocumento__c);
        segurado.pessoa.dadosPessoaFisica.tipoDocIdentificacao = handleNullString(seguradoOriginal.TipoDocIdentificacao__c);
        segurado.pessoa.dadosPessoaFisica.dataExpedicao = seguradoOriginal.DataExpedicaoDocumentoIdentificacao__c;

        if(String.isNotBlank(seguradoOriginal.Cpf__c) ||  String.isNotBlank(seguradoOriginal.Conta__r.Cpf__c)){
            String cpfSeguradoOriginal = seguradoOriginal.Cpf__c!=null ? seguradoOriginal.Cpf__c.replace('.','').replace('-', '') :seguradoOriginal.Conta__r.Cpf__c.replace('.','').replace('-', '');
            segurado.pessoa.dadosPessoaFisica.numeroCpf = cpfSeguradoOriginal.substring(0, cpfSeguradoOriginal.length() - 2);
            segurado.pessoa.dadosPessoaFisica.digitoCpf = cpfSeguradoOriginal.replace('.','').replace('-', '').right(2);
        }else{
            System.debug('Segurado do contrato não possui CPF cadastrado');
            segurado.pessoa.dadosPessoaFisica.numeroCpf = '';
            segurado.pessoa.dadosPessoaFisica.digitoCpf =  '';
        }        

        segurado.beneficiarios = new List<GerarDadosIniciaisTO.BeneficiarioTO>();
        for(BeneficiarioSeguradoContrato__c beneficiarioOriginal : seguradoOriginal.Benefici_rios_dos_segurados_do_contrato__r){
            segurado.beneficiarios.add(new GerarDadosIniciaisTO.BeneficiarioTO(beneficiarioOriginal));
        }
        segurado.coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();
        segurado.coberturas.addAll(mapSiglaxGarantiaContrato2.values());
        
        for (GerarDadosIniciaisTO.CoberturaTO cobertura : segurado.coberturas) {
            cobertura.capitalContratacao = null;
            FranquiaGarantia__c fg = mapFranquiaGarantia.get(cobertura.sigla);
            //cobertura.quantidade = fg!=null ? fg.GarantiaProduto__r.QuantidadeMaximaContratacao__c : 0;//PLV-4889 - INICIO/FIM - PEDRO AUGUSTO BRAZ
            cobertura.franquia = fg!=null ? fg.Franquia__r.CodigoFranquia__c : '';
            cobertura.descontoAgravo = null;
            cobertura.taxa = null;
            cobertura.premio = null;
        }
        return segurado;
    }
    // TKCL-584 FIM


    public static GerarDadosIniciaisTO.SeguradoTO gerarNoSegurado(SeguradoContrato__c objSegurado){

        
        GerarDadosIniciaisTO.SeguradoTO segurado = new GerarDadosIniciaisTO.SeguradoTO();
        segurado.iof = objSegurado.IOF__c;
        segurado.numero = 1;

        segurado.premio = new GerarDadosIniciaisTO.PremioTO();
        segurado.premio.integral = objSegurado.PremioIntegral__c != null ? objSegurado.PremioIntegral__c : 0 ; //PLV-5351 INICIO/FIM
        segurado.premio.comercial = objSegurado.PremioComercial__c !=null ? objSegurado.PremioComercial__c : 0 ;
        segurado.premio.puro = objSegurado.PremioPuro__c !=null ? objSegurado.PremioPuro__c : 0 ;
        segurado.premio.total = objSegurado.PremioTotal__c !=null ? objSegurado.PremioTotal__c : 0 ;
        
        segurado.taxa = new GerarDadosIniciaisTO.TaxaTO();
        segurado.taxa.comercial = objSegurado.TaxaComercial__c != null ? objSegurado.TaxaComercial__c : 0;
        segurado.taxa.pura = objSegurado.TaxaPura__c != null ? objSegurado.TaxaPura__c : 0;
        segurado.taxa.total = objSegurado.TaxaTotal__c != null ? objSegurado.TaxaTotal__c : 0;
        

        segurado.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        if(objSegurado.DescontoAgravoPercentualFormaPagto__c !=null || objSegurado.DescontoAgravoMonetarioFormaPagto__c!=null){
            GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
            dA.monetario = objSegurado.DescontoAgravoMonetarioFormaPagto__c; dA.percentual = objSegurado.DescontoAgravoPercentualFormaPagto__c;
            dA.tipo = 'FPG'; segurado.descontoAgravo.add(dA);
        }
        if(objSegurado.DescontoAgravoPercentualInformado__c !=null || objSegurado.DescontoAgravoMonetarioInformado__c!=null){
            GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
            dA.monetario = objSegurado.DescontoAgravoPercentualInformado__c; dA.percentual = objSegurado.DescontoAgravoMonetarioInformado__c;
            dA.tipo = 'BAT'; segurado.descontoAgravo.add(dA);
        }
        if(objSegurado.DescontoAgravoPercentualTecnico__c !=null || objSegurado.DescontoAgravoMonetarioTecnico__c!=null){
            GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
            dA.monetario = objSegurado.DescontoAgravoPercentualTecnico__c; dA.percentual = objSegurado.DescontoAgravoMonetarioTecnico__c;
            dA.tipo = 'TEC'; segurado.descontoAgravo.add(dA);
        }
        return segurado;
    }


    public static GerarDadosIniciaisTO.ContratanteTO gerarNoContratante(ContratanteContrato__c objContratante){
        
        GerarDadosIniciaisTO.ContratanteTO contratante = new GerarDadosIniciaisTO.ContratanteTO();
        contratante.iof = objContratante.IOF__c;
        contratante.numero = 1;
        
        contratante.premio = new GerarDadosIniciaisTO.PremioTO();
        contratante.premio.integral = objContratante.PremioIntegral__c != null ? objContratante.PremioIntegral__c : 0 ; //PLV-5351 INICIO/FIM 
        contratante.premio.comercial = objContratante.PremioComercial__c !=null ? objContratante.PremioComercial__c : 0 ;
        contratante.premio.puro = objContratante.PremioPuro__c !=null ? objContratante.PremioPuro__c : 0;
        contratante.premio.total = objContratante.PremioTotal__c !=null ? objContratante.PremioTotal__c : 0;
        
        contratante.taxa = new GerarDadosIniciaisTO.TaxaTO();
        contratante.taxa.comercial = objContratante.TaxaComercial__c != null ? objContratante.TaxaComercial__c : 0;
        contratante.taxa.pura = objContratante.TaxaPura__c != null ? objContratante.TaxaPura__c : 0;
        contratante.taxa.total = objContratante.TaxaTotal__c != null ? objContratante.TaxaTotal__c : 0;
        

        contratante.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        if(objContratante.DescontoAgravoPercentualFormaPagto__c !=null || objContratante.DescontoAgravoMonetarioFormaPagto__c!=null){
            GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO(); 
            dA.monetario = objContratante.DescontoAgravoMonetarioFormaPagto__c; dA.percentual = objContratante.DescontoAgravoPercentualFormaPagto__c;
            dA.tipo = 'FPG'; contratante.descontoAgravo.add(dA);
        }
        if(objContratante.DescontoAgravoPercentualInformado__c !=null || objContratante.DescontoAgravoMonetarioInformado__c!=null){
            GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
            dA.monetario = objContratante.DescontoAgravoPercentualInformado__c; dA.percentual = objContratante.DescontoAgravoMonetarioInformado__c;
            dA.tipo = 'BAT'; contratante.descontoAgravo.add(dA);
        }
        if(objContratante.DescontoAgravoPercentualTecnico__c !=null || objContratante.DescontoAgravoMonetarioTecnico__c!=null){
            GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
            dA.monetario = objContratante.DescontoAgravoPercentualTecnico__c; dA.percentual = objContratante.DescontoAgravoMonetarioTecnico__c;
            dA.tipo = 'TEC'; contratante.descontoAgravo.add(dA);
        }
        return contratante;
    }


    public static Map<String,GerarDadosIniciaisTO.CoberturaTO> gerarNoCobertura(String pObj){
        
        if(String.isBlank(pObj)) return null;
        List<SObject> listCoberturas = (List<SObject>) JSON.deserialize(pObj,List<SObject>.class);
        if(listCoberturas==null ||listCoberturas.size()==0) return null;
        String nomeSObject = String.valueOf(listCoberturas[0].getSObjectType());
        if(!nomeSObject.containsIgnoreCase('garantia')) return null;
        
        Map<String,GerarDadosIniciaisTO.CoberturaTO> mapToReturn = new Map<String,GerarDadosIniciaisTO.CoberturaTO>();
        for(SObject obj : listCoberturas){
            Garantia__c garantia = (Garantia__c) obj.getSobject('Garantia__r');
            GerarDadosIniciaisTO.CoberturaTO cobertura = new GerarDadosIniciaisTO.CoberturaTO();
            cobertura.sigla = garantia.Sigla__c;
            cobertura.valor = (Decimal)obj.get('Capital__c');
            
            cobertura.premio = new GerarDadosIniciaisTO.PremioTO();
            cobertura.premio.integral = obj.get('PremioIntegral__c') != null ? (Decimal) obj.get('PremioIntegral__c') : 0 ; //PLV-5351 INICIO/FIM
            cobertura.premio.comercial = obj.get('PremioComercial__c') !=null ? (Decimal) obj.get('PremioComercial__c') : 0 ;
            cobertura.premio.puro = obj.get('PremioPuro__c') !=null ? (Decimal) obj.get('PremioPuro__c') : 0 ;
            cobertura.premio.total = obj.get('PremioTotal__c') !=null ? (Decimal) obj.get('PremioTotal__c') : 0 ;
            
            cobertura.taxa = new GerarDadosIniciaisTO.TaxaTO();
            cobertura.taxa.comercial = obj.get('TaxaComercial__c') != null ? (Decimal) obj.get('TaxaComercial__c') : 0;
            cobertura.taxa.pura = obj.get('TaxaPura__c') != null ? (Decimal) obj.get('TaxaPura__c') : 0;
            cobertura.taxa.total = obj.get('TaxaTotal__c') != null ? (Decimal) obj.get('TaxaTotal__c') : 0;
            
            cobertura.iof = obj.get('IOF__c') != null ? (Decimal) obj.get('IOF__c') : 0;
            
            cobertura.quantidade = obj.get('Limite_de_Uso__c') != null ? (Decimal) obj.get('Limite_de_Uso__c') : 0;//PLV-4889 - INICIO/FIM - PEDRO AUGUSTO BRA

            cobertura.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
            if((Decimal)obj.get('DescontoAgravoPercentualFormaPagto__c') !=null || (Decimal)obj.get('DescontoAgravoMonetarioFormaPagto__c')!=null){
                GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
                dA.monetario = (Decimal)obj.get('DescontoAgravoMonetarioFormaPagto__c'); dA.percentual = (Decimal)obj.get('DescontoAgravoPercentualFormaPagto__c');
                dA.tipo = 'FPG'; cobertura.descontoAgravo.add(dA);
            }
            if((Decimal)obj.get('DescontoAgravoPercentualInformado__c') !=null || (Decimal)obj.get('DescontoAgravoMonetarioInformado__c')!=null){
                GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
                dA.monetario = (Decimal)obj.get('DescontoAgravoPercentualInformado__c'); dA.percentual = (Decimal)obj.get('DescontoAgravoMonetarioInformado__c');
                dA.tipo = 'BAT'; cobertura.descontoAgravo.add(dA);
            }
            if((Decimal)obj.get('DescontoAgravoPercentualTecnico__c') !=null || (Decimal)obj.get('DescontoAgravoMonetarioTecnico__c')!=null){
                GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();  dA.monetario = (Decimal)obj.get('DescontoAgravoMonetarioTecnico__c');//PLV-5676-INICIO
                dA.percentual = (Decimal)obj.get('DescontoAgravoPercentualTecnico__c'); dA.tipo = 'TEC';  cobertura.descontoAgravo.add(dA);//PLV-5676-FIM
            }
            /*if((Decimal)obj.get('DescontoAgravoPercentualParcelamento__c') !=null || (Decimal)obj.get('DescontoAgravoMonetarioParcelamento__c')!=null){
                GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
                dA.monetario = (Decimal)obj.get('DescontoAgravoMonetarioParcelamento__c');
                dA.percentual = (Decimal)obj.get('DescontoAgravoPercentualParcelamento__c');
                dA.tipo = 'TPR';
                cobertura.descontoAgravo.add(dA);
            }

            if((Decimal)obj.get('DescontoAgravoPercentualComercial__c') !=null || (Decimal)obj.get('DescontoAgravoMonetarioComercial__c')!=null){
                GerarDadosIniciaisTO.DescontoAgravoTO dA = new GerarDadosIniciaisTO.DescontoAgravoTO();
                dA.monetario = (Decimal)obj.get('DescontoAgravoPercentualComercial__c');
                dA.percentual = (Decimal)obj.get('DescontoAgravoMonetarioComercial__c');
                dA.tipo = 'COM';
                cobertura.descontoAgravo.add(dA);
            }*/

            mapToReturn.put(cobertura.sigla, cobertura);
        }

        return mapToReturn;

    }
    //PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

    //PLV-5066 INICIO
    public Boolean checkTipoEndossoIsOnlyCad(String request, GerarDadosIniciaisTO.OfertaTO proposta){
        System.debug('Gior Proposta: '+ JSON.serialize(proposta));
        System.debug('Gior request: '+ request);
        String novoSeguradoString = JSON.serialize(proposta.orcamento.contratantes[0].grupos[0].segurados[0]);
        // TKCL-584 INICIO
        GerarDadosIniciaisTO.SeguradoTO seguradoTO = proposta.orcamento.contratoOriginal.contratantes != null && !proposta.orcamento.contratoOriginal.contratantes.isEmpty() ?
            proposta.orcamento.contratoOriginal.contratantes[0].grupos[0].segurados[0] : montarSeguradoContratoOriginal(); 
        String seguradoOriginalString = JSON.serialize(seguradoTO);
        // TKCL-584 FIM
        system.debug('novoSeguradoString : ' + novoSeguradoString);
        system.debug('seguradoOriginalString : ' + seguradoOriginalString);
        system.debug('cicloVacinalNovo : ' + cicloVacinalNovo);
        system.debug('cicloVacinalOriginal : ' + cicloVacinalOriginal);        

        EmissaoTO.SeguradoTO novoSegurado = (EmissaoTO.SeguradoTO)JSON.deserialize(novoSeguradoString, EmissaoTO.SeguradoTO.class);
        EmissaoTO.SeguradoTO seguradoOriginal = (EmissaoTO.SeguradoTO)JSON.deserialize(seguradoOriginalString, EmissaoTO.SeguradoTO.class);

        Boolean endossoCad = true;
        Map<String,Decimal> mapNovaCobertura = new Map<String,Decimal> ();
        Map<String,Decimal> mapOrigCobertura = new Map<String,Decimal> ();

        if(
            novoSegurado.pessoa.nome                                        != seguradoOriginal.pessoa.nome ||
            novoSegurado.pessoa.nomeSocial                                  != seguradoOriginal.pessoa.nomeSocial || // LECVPV-188 INICIO/FIM
            novoSegurado.pessoa.dadosPessoaFisica.regimeTrabalho            != seguradoOriginal.pessoa.dadosPessoaFisica.regimeTrabalho ||
            novoSegurado.pessoa.rendaMensal                                 != seguradoOriginal.pessoa.rendaMensal 
        ) endossoCad = true;
        

        if(novoSegurado.coberturas != null) {
            for(EmissaoTO.CoberturaTO newCobertura : novoSegurado.coberturas) mapNovaCobertura.put(newCobertura.sigla, newCobertura.valor);
            
            for(EmissaoTO.CoberturaTO origCobertura : seguradoOriginal.coberturas) mapOrigCobertura.put(origCobertura.sigla, origCobertura.valor);
            
            for(String siglaCob : mapNovaCobertura.keySet()) {
                //PLV-5099 INICIO
                System.debug('RAFA SIGLACOB: ' + siglaCob);
                System.debug('RAFA ORIGCOBERTURA: ' + mapOrigCobertura.get(siglaCob));
                System.debug('RAFA NOVACOBERTURA: ' + mapNovaCobertura.get(siglaCob));
                //System.debug('RAFA UTIL: ' + Util.truncateNumber(mapOrigCobertura.get(siglaCob)));
                
                if(!mapOrigCobertura.containsKey(siglaCob)) return false;
                else if(Util.truncateNumber(mapOrigCobertura.get(siglaCob)) != mapNovaCobertura.get(siglaCob)) return false;
                //PLV-5099 FIM
            }

            for(String siglaCob : mapOrigCobertura.keySet()){ if(!mapNovaCobertura.containsKey(siglaCob)) return false; }
        }

        // II-25 INÍCIO
        if(
            novoSegurado.pessoa.dadosPessoaFisica.dataNascimento.substring(0,10)  != seguradoOriginal.pessoa.dadosPessoaFisica.dataNascimento ||
            novoSegurado.pessoa.dadosPessoaFisica.sexo                            != seguradoOriginal.pessoa.dadosPessoaFisica.sexo
        ) return false;

        Map<String, Object> mapRequest = (Map<String, Object>) JSON.deserializeUntyped(request);
        List<Object> lOrcamentos = (List<Object>) mapRequest.get('orcamentos');
       //   System.debug('Gior codProdutoVida: '+ ((Map<String, Object>) lOrcamentos[0]).get('codigoProdutoVida'));            
        if (!'APTLMKT'.equals(((Map<String, Object>) lOrcamentos[0]).get('codigoProdutoVida')) && (
            novoSegurado.pessoa.dadosPessoaFisica.fumante                         != seguradoOriginal.pessoa.dadosPessoaFisica.fumante || // PLV-5150 - FIX02 - INICIO/FIM
            cicloVacinalNovo                                                      != cicloVacinalOriginal   // PLV-5150 - FIX02 - INICIO/FIM
            //|| // PLV-5150 - FIX01 - INICIO/FIM
            //novoSegurado.pessoa.dadosPessoaFisica.CicloVacinal                    != seguradoOriginal.pessoa.dadosPessoaFisica.CicloVacinal //PLV-5150 - INICIO/FIM  // PLV-5150 - FIX01 - INICIO/FIM
        )) return false;
        // II-25 FIM

        if(mapNovaCobertura.containsKey('DIT') && novoSegurado.pessoa.dadosPessoaFisica.profissao != seguradoOriginal.pessoa.dadosPessoaFisica.profissao) return false;

        Map<String, String> dicioCorretagem = new Map<String, String>{'COR'=>'CORRETAGEM', 'AGE'=>'AGENCIAMENTO'};
        Map<String, Decimal> remuneracoesOriginal = new Map<String, Decimal>();
        Map<String, Decimal> remuneracoesProposta = new Map<String, Decimal>();
        List<String> validarRemuneracao = new List<String>{'CORRETAGEM'};

        try {

            for(GerarDadosIniciaisTO.RemuneracaoContratoTO rec : proposta.orcamento.contratoOriginal.remuneracoes) remuneracoesOriginal.put(dicioCorretagem.get(rec.tipoRemuneracao), rec.percentual);

        } catch (Exception e) { System.debug('Erro na análise de remunerações do contrato original'+ e); }

        try {
            Map<String, Object> mpRequest = (Map<String, Object>) JSON.deserializeUntyped(request);
            List<Object> lstOrcamentos = (List<Object>) mpRequest.get('orcamentos');
            Map<String, Object> orcamento = (Map<String, Object>) lstOrcamentos[0];
            List<Object> remuneracoes = (List<Object>) orcamento.get('remuneracoes');

            for(Object recObj : remuneracoes){
                Map<String, Object> rec = (Map<String, Object>) recObj;

                remuneracoesProposta.put((String) rec.get('tipoRemuneracao'), (Decimal) rec.get('percentual'));
            }
        } catch (Exception e) { System.debug('Erro na análise de remunerações da proposta'+ e); } 

        for(String tipoRemuneracao : validarRemuneracao) { 

            if(remuneracoesOriginal.get(tipoRemuneracao) != remuneracoesProposta.get(tipoRemuneracao)) 
            return false; 
        }
        
        return endossoCad;
    }
    //PLV-5066 FIM
    //PLV-5134 INICIO
    public void limparDIT(List<GerarDadosIniciaisTO.OfertaTO> lstOfertas){
        for(GerarDadosIniciaisTO.CoberturaTO cobertura : lstOfertas[0].orcamento.contratantes[0].grupos[0].segurados[0].coberturas){
            if(cobertura.sigla == 'DIT') {
                cobertura.quantidade = 0;
            } 
        }
    }
    //PLV-5134 FIM
    //AV-623 INICIO
   
    public Decimal getValorDescontoCupom(GerarDadosIniciaisTO.PayloadTO payloadTO) {
         Decimal ValorDescontoCupom = 0;
         String Cupom = payLoadTO.orcamentos[0].cupom;
         Date dataHoje = System.today();
         system.debug('>>>ValorCupomFinal: '+ Cupom);
         if (Cupom  != null || Cupom != '' ){
             List<Cupom__c> retornaCupom = NEW List<Cupom__c>();
             retornaCupom = [SELECT Id, Percentual__c,Vigencia_Final__c,Vigencia_Inicial__c FROM Cupom__c WHERE Codigo__c =: Cupom Limit 1];
            if (retornaCupom.size() > 0 ) {
                if ((dataHoje >= retornaCupom[0].Vigencia_Inicial__c) && (dataHoje <= retornaCupom[0].Vigencia_Final__c)) {
                       ValorDescontoCupom = retornaCupom[0].Percentual__c;
                }       
            } 
         } else {
           ValorDescontoCupom = 0;  
         }
        
         return ValorDescontoCupom;
    }  
   
    //AV-623 FIM
    //PLV-5461 - INICIO 
  
    public String ValidaCupom(GerarDadosIniciaisTO.PayloadTO payloadTO){
        
        String meioComerciliazacao = payLoadTO.orcamentos[0].meioComercializacao;
        date Vigencia = payLoadTO.orcamentos[0].dataCalculo;
        Date dataHoje = System.today();
        String Cupom = payLoadTO.orcamentos[0].cupom;
        System.debug('Valor Cupom>>>>>'+Cupom);
        if ((Cupom == null) || String.IsEmpty(Cupom)){
           Cupom = 'SUCESSO';
        } else {
       
        List<Cupom__c> retornaCupom = NEW List<Cupom__c>();
        String CodigoCupom = Cupom.toUppercase();
        retornaCupom = [SELECT
                        Id, Codigo__c,Descricao__c,IsDeleted,Limite_de_Utilizacao__c,Name,OwnerId,Percentual__c,Vigencia_Final__c,Vigencia_Inicial__c
                        FROM Cupom__c 
                        WHERE Codigo__c =: CodigoCupom AND Vigencia_Inicial__c <=: dataHoje and Vigencia_Final__c >=: dataHoje Limit 1]; //VIAG-266 INICIO/FIM KAYMON
        
        if (retornaCupom.size() > 0 ) {
            if ((dataHoje < retornaCupom[0].Vigencia_Inicial__c) || (dataHoje > retornaCupom[0].Vigencia_Final__c)) {
                 	Cupom = 'CUPOM EXPIRADO'; 
            } else {    
                if (retornaCupom[0].Limite_de_Utilizacao__c > 0) {
                   // Cupom__c CupomToUpdate = [SELECT Limite_de_Utilizacao__c FROM Cupom__c WHERE Id =: retornaCupom[0].Id FOR UPDATE ];
                   // CupomToUpdate.Limite_de_Utilizacao__c = retornaCupom[0].Limite_de_Utilizacao__c - 1;
                   // update CupomToUpdate;
                    Cupom = 'SUCESSO';
                    
                } else {
                    Cupom = 'CUPOM EXCEDIDO';
                }
            }               
        } else {
                   Cupom = 'CUPOM INVALIDO';
        }
      } 
        return Cupom;    
        
    }
    // PLV5461- fim

    // RVI-193-INICIO
    public Decimal getDiscCtrOrg(String idContract){
        ContratanteContrato__c contCtr = [SELECT DescontoAgravoPercentualFormaPagto__c 
        FROM ContratanteContrato__c 
        WHERE Contrato__c  =: idContract 
        LIMIT 1]; 
        Decimal descCtr = contCtr.DescontoAgravoPercentualFormaPagto__c;
        return descCtr;
    }
    // RVI-193-FIM

    //RVI-312 - INICIO
    // RVI-312-FIX01 - INICIO
    public ContratanteContrato__c ajustaDescAgrvRenovAltFormaPagto(String contratoId, Map<String, Decimal> mapCondicaoCobranca){

        // List<Constante__mdt> constante = MetadataDAO.getInstance().buscarConstante('QTD_PARC_BOLETO');
        // Integer qtdDescBoleto = Integer.valueOf(constante[0].Valor__c);

        ContratanteContrato__c cteCtr = [
            SELECT 
                Id,
                QuantidadeParcelas__c,
                DescontoAgravoPercentualFormaPagto__c,
                Contrato__r.Proposta__c,
                FormaPagamento__r.Codigo__c, //ANNVI-258 - INICIO
                CreatedDate //ANNVI-258 - FIM
            FROM
                ContratanteContrato__c
            WHERE
                Contrato__c  =: contratoId
        ];


        for (String plano: mapCondicaoCobranca.keySet()) {
            for (String parcela : plano.split(';')) {
                if (cteCtr.QuantidadeParcelas__c == Integer.valueOf(parcela)) {
                    cteCtr.DescontoAgravoPercentualFormaPagto__c =  mapCondicaoCobranca.get(plano);
                }
            }
        }

        // if(cteCtr.QuantidadeParcelas__c <= 4){
        //     cteCtr.DescontoAgravoPercentualFormaPagto__c = qtdDescBoleto;
        // }else{
        //     cteCtr.DescontoAgravoPercentualFormaPagto__c = qtdDescBoleto = 0;
        // }
        return cteCtr;
    }
    // RVI-312-FIX01 - FIM
    //RVI-312 - FIM

    /*// RVI-225-INICIO
    public List<ContratanteContrato__c> getDiscCtrOrgX(String idContract){
        ContratanteContrato__c contCtr = [SELECT DescontoAgravoPercentualFormaPagto__c,
        DescontoAgravoMonetarioTecnico__c,DescontoAgravoPercentualTecnico__c
        FROM ContratanteContrato__c 
        WHERE Contrato__c  =: idContract 
        LIMIT 1]; 
        List<ContratanteContrato__c> descCtr = New List<ContratanteContrato__c>();
        descCtr.add(contCtr);
        return descCtr;
    }
    // RVI-225-FIM */
}