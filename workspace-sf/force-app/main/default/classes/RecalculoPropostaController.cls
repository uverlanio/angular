/****
@description Classe de controle do componente de recalculo da proposta
@author Isabela Fin - Globant / Pedro Braz - Sys4b
@date 30/10/2020
@Classe referente a historia PLV-4544      
*****/
global without sharing class RecalculoPropostaController { //FNPVVEP-126 INICIO-FIM

    RecalculoPropostaTO to = new RecalculoPropostaTO();
    private static Map<String, List<SObject>> mapSObjectsToDML;
    //II-166 - INICIO
    private static AltFormPgtoTO.FormaPagamentoTO formaPagtoTO = new AltFormPgtoTO.FormaPagamentoTO();
    private static AltFormPgtoDAO altFormPgtoDAO = new AltFormPgtoDAO();
    private static AltFormPgtoBO altFormPgtoBO = new AltFormPgtoBO();
    //II-166 - FIM

    @AuraEnabled
    public static RecalculoPropostaTO.Proposta dtoProposta(String quoteId){
        RecalculoPropostaTO.Proposta toReturn = new RecalculoPropostaTO.Proposta();
        //Criar o select da quote
        Quote cotacao = [SELECT Id
                        , name
                        , PremioTotal__c
                        , Produto__c
                        , Produto__r.ProductCode
                        , Produto__r.LimiteTotalCarregamento__c //PLV-4851
                        , VigenciaInicial__c //PLV-4851
                        , VigenciaFinal__c //PLV-4851
                        , CurrencyIsoCode
                        , (SELECT Id
                                , Garantia__r.Name
                                , Garantia__r.Sigla__c
                                , Capital__c
                                , TipoDescontoAgravo__c
                                , PremioTotal__c
                                , DescontoAgravoPercentualTecnico__c	
                                , DescontoAgravoMonetarioTecnico__c
                                , DescontoAgravoPercentualFormaPagto__c
                                , DescontoAgravoMonetarioFormaPagto__c
                                , GarantiaProduto__r.PercentualCapitalMaximo__c
                                , GarantiaProduto__r.PercentualCapitalMinimo__c
                                , GarantiaProduto__r.PercentualDescontoMaximo__c
                                , GarantiaProduto__r.PercentualDescontoMinimo__c
                                , GarantiaProduto__r.LimiteCapitalMaximo__c
                                , GarantiaProduto__r.LimiteCapitalMinimo__c
                                , GarantiaProduto__r.PercentualAgravoMaximo__c
                                , GarantiaProduto__r.PercentualAgravoMinimo__c
                                , GarantiaProduto__r.CaracteristicaGarantia__c
                                , GarantiaProduto__r.Obrigatoria__c
                                , CurrencyIsoCode
                            FROM GarantiasProposta__r
                        )
                        //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
                        , (SELECT Id
                                , Name
                                , Porcentagem_de_Retencao__c
                                , Percentual__c
                                , Participacao__c
                                , Papel__c
                                , TipoRemuneracao__c
                                , TipoRemuneracao__r.Name
                                , TipoRemuneracao__r.Codigo__c
                                , TipoRemuneracao__r.Descricao__c
                                , TipoRemuneracao__r.LimiteMaximo__c
                                , TipoRemuneracao__r.LimiteMinimo__c
                                , TipoRemuneracao__r.ModeloRecuperacao__c
                                , RemuneracaoProduto__c
                                , RemuneracaoProduto__r.Name
                                , RemuneracaoProduto__r.LimiteMaximo__c
                                , RemuneracaoProduto__r.LimiteMinimo__c
                                , RemuneracaoProduto__r.Obrigatoria__c
                                , RemuneracaoProduto__r.ParcelasAgenciamento__c
                                , RemuneracaoProduto__r.TipoRemuneracao__c
                                , RemuneracaoProduto__r.VersaoAnterior__c
                                , RemuneracaoProduto__r.TipoEvento__c
                                , RemuneracaoProduto__r.Produto__c
                                
                                
                            FROM RemuneracoesProposta__r
                        )
                        //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        FROM Quote WHERE Id =:quoteId];
        //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        List<RemuneracaoCanal__c> remuneracoesProduto = [SELECT Id
                                                                    ,Name
                                                                    , LimiteMaximo__c
                                                                    , LimiteMinimo__c
                                                                    , ParcelasAgenciamento__c
                                                                    , TipoRemuneracao__c
                                                                    , TipoRemuneracao__r.Name
                                                                    , TipoRemuneracao__r.Codigo__c
                                                                    , ProdutoCanal__r.Produto__c
                                                                    FROM RemuneracaoCanal__c
                                                                    WHERE ProdutoCanal__r.Produto__c =:cotacao.Produto__c];

        Map<String,RemuneracaoCanal__c> mapNomeXRemuneracaoProduto = new Map<String,RemuneracaoCanal__c>();

        for(RemuneracaoCanal__c rem : remuneracoesProduto){
            mapNomeXRemuneracaoProduto.put(rem.TipoRemuneracao__r.Codigo__c, rem);
        }
        //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

        List<SeguradoProposta__c> segurados = [SELECT Profissao__c, Profissao__r.Limite_de_capital_maximo__c 
                                        FROM SeguradoProposta__c
                                        WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c = :cotacao.Id];
        Profissao__c profissao = null;
        if(segurados.size() > 0){
            if(segurados[0].Profissao__r != null){
                profissao = segurados[0].Profissao__r;
            }
        }

        toReturn.id = cotacao.id;
        toReturn.numero = cotacao.name;
        toReturn.premioTotal = cotacao.PremioTotal__c;
        toReturn.tipoDescontoAgravo = 'Porcentagem';
        toReturn.isoCode = cotacao.CurrencyIsoCode;
        toReturn.tipoOpcoes = new List<String>{'Porcentagem','Monetário'};
        toReturn.LimiteTotalCarregamento    = cotacao.Produto__r.LimiteTotalCarregamento__c;//PLV-4851 - INICIO/FIM
        toReturn.VigenciaInicial            = cotacao.VigenciaInicial__c;//PLV-4851 - INICIO/FIM
        toReturn.VigenciaFinal              = cotacao.VigenciaFinal__c;//PLV-4851 - INICIO/FIM
        toReturn.garantias = new List<RecalculoPropostaTO.Garantias>();

        for(GarantiaProposta__c gp : cotacao.GarantiasProposta__r){
            RecalculoPropostaTO.Garantias gar = new RecalculoPropostaTO.Garantias();
            gar.id                          =   gp.Id;
            gar.contratado                  =   true;
            gar.name                        =   gp.Garantia__r.Name;
            gar.cobertura                   =   gp.Garantia__r.Sigla__c;
            gar.capital                     =   gp.Capital__c;
            gar.premioAtual                 =   gp.PremioTotal__c;
            gar.tipoOpcoes                  =   new List<String>{'Porcentagem','Monetário'};
            gar.descontoAgravo              =   0;
            gar.isoCode                     =   gp.CurrencyIsoCode;
            gar.tipoDescontoAgravo          =   'Porcentagem';
            gar.limiteCapitalMinimo         =   gp.GarantiaProduto__r.LimiteCapitalMinimo__c;
            gar.limiteCapitalMaximo         =   gp.GarantiaProduto__r.LimiteCapitalMaximo__c;
            gar.caracteristica              =   gp.GarantiaProduto__r.CaracteristicaGarantia__c;
            gar.obrigatorio                 =   gp.GarantiaProduto__r.Obrigatoria__c;
            
            if(gar.caracteristica == 'Principal' && profissao != null){
                if(profissao.Limite_de_capital_maximo__c < gar.limiteCapitalMinimo) {
                    continue; //Não adiciona garantia
                } else {
                    gar.limiteCapitalMaximo = profissao.Limite_de_capital_maximo__c < gar.limiteCapitalMaximo ? profissao.Limite_de_capital_maximo__c : gar.limiteCapitalMaximo;
                }
            }
            
            gar.percentualCapitalMinimo     =   gp.GarantiaProduto__r.PercentualCapitalMinimo__c;
            gar.percentualCapitalMaximo     =   gp.GarantiaProduto__r.PercentualCapitalMaximo__c;
            gar.percentualAgravoMinimo      =   gp.GarantiaProduto__r.PercentualAgravoMinimo__c;
            gar.percentualAgravoMaximo      =   gp.GarantiaProduto__r.PercentualAgravoMaximo__c;
            gar.percentualDescontoMinimo    =   gp.GarantiaProduto__r.PercentualDescontoMinimo__c;
            gar.percentualDescontoMaximo    =   gp.GarantiaProduto__r.PercentualDescontoMaximo__c;

            toReturn.garantias.add(gar);
        }

        //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        toReturn.remuneracoes = new List<RecalculoPropostaTO.Remuneracoes>();
        for(RemuneracaoProposta__c remProposta : cotacao.RemuneracoesProposta__r){
            RemuneracaoCanal__c remuProduto= mapNomeXRemuneracaoProduto.get(remProposta.TipoRemuneracao__r.Codigo__c);
            System.debug('remuProduto AQUI'+ remuProduto);
            if(remuProduto==null) continue;
            RecalculoPropostaTO.Remuneracoes rem = new RecalculoPropostaTO.Remuneracoes();
            rem.id                          =   remProposta.Id;
            rem.tipoRemuneracao             =   remuProduto.TipoRemuneracao__r.Name;
            rem.codigo                      =   remProposta.TipoRemuneracao__r.Codigo__c;
            rem.limiteMaximo                =   remuProduto.LimiteMaximo__c!=null? remuProduto.LimiteMaximo__c : 0;
            rem.limiteMinimo                =   remuProduto.LimiteMinimo__c!=null? remuProduto.LimiteMinimo__c : 0;
            rem.percentual                  =   Integer.valueOf(remProposta.Percentual__c);
            //rem.obrigatorio                 =   remProposta.RemuneracaoProduto__r.Obrigatoria__c;
            rem.simbolo                     =   '%';
            rem.opcoes                      = new List<Integer>();
            System.debug('tipoRemuneracao ===' + rem.tipoRemuneracao);
            if(rem.tipoRemuneracao =='AGENCIAMENTO'){
                Integer qtd = (Integer)(rem.limiteMaximo / 100);
                for (Integer i = 0; i<=qtd; i++) {
                    rem.opcoes.add(i*100);
                }
                rem.simbolo = '';
            }
            toReturn.remuneracoes.add(rem);
        }
        //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

        return toReturn;
    }

    @AuraEnabled
    public static String dtoEntradaCalculo(RecalculoPropostaTO.Proposta pPropostToCalc){
        System.debug('pPropostToCalc'+pPropostToCalc);
        QuoteDAO dao = QuoteDAO.getInstance();
        List<Quote> listQuote = dao.buscarPropostasPorId(new Set<Id>{pPropostToCalc.id});
        List<SeguradoProposta__c> listSeguradoProposta = dao.buscarListSeguradosPropostaByQuote(new Set<Id>{pPropostToCalc.id});
        if(listQuote==null || listQuote.isEmpty()) return 'Erro ao obter cotação';
        Quote cotacaoSelecionada = listQuote[0];
        
        RecalculoPropostaTO propostaToSend = new RecalculoPropostaTO();
        propostaToSend.calculos = new List<RecalculoPropostaTO.CalculosTO>();
        //montar informação sobre o calculo
        propostaToSend.calculos.add(new RecalculoPropostaTO.CalculosTO().dtoCalculo(cotacaoSelecionada,listSeguradoProposta,pPropostToCalc));
        System.debug('propostaToSend Danilo '+ JSON.serialize(propostaToSend,true));
        return JSON.serialize(propostaToSend,true); //PLV - 4694 INICIO/FIM
    }

    @AuraEnabled
    public static RecalculoPropostaTo.Proposta dtoResponseCalculo(String jsonResponse, RecalculoPropostaTo.Proposta modificada) {
        RecalculoPropostaTO.Proposta recalculada = new RecalculoPropostaTO.Proposta();
        EmissaoTO.OfertasTO payloadResponse = (EmissaoTO.OfertasTO) JSON.deserialize(jsonResponse, EmissaoTO.OfertasTO.class);
        system.debug('payloadResponse serializado '+ JSON.serialize(payloadResponse));
        Map<String, RecalculoPropostaTO.Garantias> mapGarantiasModificadas = new Map<String, RecalculoPropostaTO.Garantias>();
        for(RecalculoPropostaTO.Garantias garantia :modificada.garantias) {
            mapGarantiasModificadas.put(garantia.cobertura, garantia);
        }

        //modificada -> recalculada
        recalculada.id = modificada.id;
        recalculada.numero = modificada.numero;
        recalculada.tipoDescontoAgravo = modificada.tipoDescontoAgravo;
        recalculada.tipoOpcoes = modificada.tipoOpcoes;
        recalculada.descontoAgravo = modificada.descontoAgravo == null ? 0 : modificada.descontoAgravo;
        recalculada.isoCode = modificada.isoCode;

        //sinapse response -> recalculada
        recalculada.premioTotal = payloadResponse.retornosCalculo[0].precificacao.premio.total;
        recalculada.garantias = new List<RecalculoPropostaTO.Garantias>();

        for(EmissaoTO.CoberturaTO cobertura :payloadResponse.retornosCalculo[0].precificacao.coberturas) {
            RecalculoPropostaTO.Garantias garantia = new RecalculoPropostaTO.Garantias();
            if(mapGarantiasModificadas.containsKey(cobertura.sigla)){
                //sinapse response -> recalculada
                garantia.premioAtual = cobertura.premio.total;
                garantia.cobertura = cobertura.sigla;
                
                //modificada -> recalculada
                RecalculoPropostaTO.Garantias garantiaModificada = mapGarantiasModificadas.get(cobertura.sigla);
                garantia.id = garantiaModificada.id;
                garantia.contratado = true;
                garantia.name = garantiaModificada.name;
                garantia.capital = garantiaModificada.capital;
                garantia.tipoOpcoes = garantiaModificada.tipoOpcoes;
                garantia.descontoAgravo = garantiaModificada.descontoAgravo == null ? 0 : garantiaModificada.descontoAgravo;
                garantia.isoCode = garantiaModificada.isoCode;
                garantia.tipoDescontoAgravo = garantiaModificada.tipoDescontoAgravo;
                recalculada.garantias.add(garantia);
            }
        }

        recalculada.remuneracoes = modificada.remuneracoes; //PLV-4851 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

        return recalculada;
    }

    @AuraEnabled
    public static Map<String,Object> carregarDadosProposta(String propostaId){

        Map<String,Object> mapToReturn = new Map<String,Object>();
        mapToReturn.put('propostaId',propostaId);
        try {

            Map<String,Object> verifyEdit =  verifyEdit(propostaId);

            //II-175 FIX01 INCIO
            RecalculoPropostaTO.Proposta proposta = dtoProposta(propostaId); 
            if((Boolean)verifyEdit.get('canEdit')){
            //RecalculoPropostaTO.Proposta proposta = dtoProposta(propostaId); 
            mapToReturn.put('canEdit',true);
            mapToReturn.put('original',proposta);
            mapToReturn.put('modificada',proposta);
            }else{
                mapToReturn.put('original',proposta); 
                mapToReturn.put('modificada',proposta); 
                mapToReturn.put('canEdit',false);
                mapToReturn.put('mensagem',(String)verifyEdit.get('mensagem'));
                //mapToReturn.put('MomentoAnalise__c',ctrProp[0].MomentoAnalise__c);
            }
            //II-175 FIX01 FIM
            return mapToReturn;
        }catch (Exception e) {
            //RecalculoPropostaTO.Proposta proposta = dtoProposta(propostaId); 
            mapToReturn.put('sucesso',false);
            mapToReturn.put('mensagem','Erro carregarDadosProposta');
            mapToReturn.put('stacktrace',e.getStackTraceString() + ' - ' + e.getMessage());
            return mapToReturn;
        }
    }
    

    public static Map<String,Object> verifyEdit(String propostaId){
        Map<String,Object> mapToReturn = new Map<String,Object>();

        List<CriticaProposta__c> listCriticas = popularTabelaCriticas(propostaId);
        List<String> mensagem = new List<String>();
        Boolean temRecalculo = false;
        Boolean demaisLiberadas = true;
        //PLV-5311-FIX-INICIO
        for(CriticaProposta__c cp : listCriticas){
            if(cp.MomentoAnalise__c=='Recalculo') temRecalculo = true;
            //if(cp.MomentoAnalise__c=='Recalculo' && cp.Status__c != 'Pendente' && temRecalculo == true){
                //mensagem.add('Critica de Recálculo não permite edição: '+ cp.Status__c);
           // }
            if(cp.MomentoAnalise__c == 'Recalculo' && temRecalculo == true && cp.Status__c == 'Pendente'){ 
                demaisLiberadas = true;
                break;
                System.debug('Caiu no else if' + temRecalculo);
            }else{
                demaisLiberadas = false;
                System.debug('Caiu no else' + temRecalculo);
                System.debug('else p Danilo: ' + cp);
            }
                //PLV-5311 INICIO
                //if(cp.MomentoAnalise__c <> 'Recalculo'){
                //    System.debug('critica p Danilo: ' + cp);
                 //   demaisLiberadas = false;
                ///}
                //PLV-5311 FIM
            
        } //PLV-5311-FIX-FIM

        if(!temRecalculo) mensagem.add('A proposta não possuí crítica de Recálculo Pendente');
        if(!demaisLiberadas) mensagem.add('Não existem críticas aptas para Recálculo'); //PLV-5311-FIX-INICIO/FIM
        if(!getCanEdit()) mensagem.add('Seu perfil não permite acesso a funcionalidade');

        mapToReturn.put('canEdit',mensagem.isEmpty());
        mapToReturn.put('mensagem',String.join(mensagem,'; '));

        return mapToReturn;
    }

	public static Boolean getCanEdit(){
		List<String> permitidos = new List<String>();
		permitidos.add('Emissão');
		permitidos.add('Aceitação');
		permitidos.add('Processos e Projetos');
		permitidos.add('Administrador Porto');
		permitidos.add('Administrador do sistema');
		permitidos.add('System Administrator');
        //permitidos.add('Api Perfil1544480744794');
        permitidos.add('RecalculoPropostaOut Perfil'); //FNPVVEP-126 INICIO-FIM

		String perfilAtual = [SELECT Id,Name FROM Profile WHERE Id=:Userinfo.getProfileId()].Name;
		return permitidos.contains(perfilAtual);
	}


    @AuraEnabled
    public static Map<String,Object> calcular(String requisicao, Boolean alteracaoFormPag, String descontoAgravo){ //II-175 INICIO/FIM
        System.debug('requisicao >> ' + requisicao);
        Map<String,Object> parsed = new Map<String,Object>();
        Map<String,Object> mapToReturn = new Map<String,Object>();
        try {
            parsed = (Map<String,Object>) JSON.deserializeUntyped(requisicao);
            System.debug('mapToReturn >> ' + mapToReturn);
            System.debug('parsed >> ' + parsed);
        } catch (Exception e) {
            mapToReturn.put('sucesso',false);
            mapToReturn.put('mensagem','Erro ao deserializar requisição');
            mapToReturn.put('stacktrace',e.getStackTraceString());
            return mapToReturn;
        }

        RecalculoPropostaTO.Proposta modificada = (RecalculoPropostaTO.Proposta) JSON.deserialize(JSON.serialize(parsed.get('modificada')),RecalculoPropostaTO.Proposta.class);
        System.debug('modificada >> ' + modificada);
        
        //PLV-5161 - INICIO
        Quote proposta = [select id, produto__c from quote where id = :modificada.id ];
        Product2 produto = [select id, (select id, TipoRemuneracao__r.Codigo__c, LimiteMaximo__c, LimiteMinimo__c from RemuneracoesProduto__r) 
                            from Product2 where id =: proposta.produto__c LIMIT 1];
        //produto.RemuneracoesProduto__r = List<RemuneracaoProduto__c>
        Map<String, RemuneracaoProduto__c> mapRemuneracoes = new Map<String, RemuneracaoProduto__c>();
        for (RemuneracaoProduto__c remuneracao : produto.RemuneracoesProduto__r){
            mapRemuneracoes.put(remuneracao.TipoRemuneracao__r.Codigo__c, remuneracao);
        }
        //
        //PLV-5161 - FIM

        mapToReturn.put('modificada', parsed.get('modificada'));
        //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ
        System.debug(LoggingLevel.ERROR,'modificada >>>>>>>>');
        Map<String,Object> validarPercentuais = validarPercentuais(modificada, mapRemuneracoes); //PLV-5161 - INICIO/FIM ADICIONADO PARAMETROS
        System.debug('validarPercentuais >> ' + validarPercentuais);
        if((Boolean)validarPercentuais.get('valido')==false){
            mapToReturn.put('sucesso',false);
            mapToReturn.put('mensagem',validarPercentuais.get('mensagem'));
            return mapToReturn;
        }
        System.debug('mapToReturn <<>> ' + validarPercentuais);
        // II-54 - INICIO
        String payloadCalculo = dtoEntradaCalculo(modificada);
        //II-175 INICIO
        RecalculoPropostaTO recalculoProp = (RecalculoPropostaTO) JSON.deserialize(payloadCalculo, RecalculoPropostaTO.class);
        System.debug('recalculoProp des <>' + recalculoProp);
        if(alteracaoFormPag){
            System.debug('entrou if alteracao Pag <<>> ');
            if(recalculoProp != null){
                System.debug('entrou if calculosTO <<>> ');
                RecalculoPropostaTO.VersoesCalculos versoesCalculo = recalculoProp.calculos.get(0).versoesCalculos.get(0);
                //RecalculoPropostaTO.VersoesCalculos versoesCalculo = calculosTO.versoesCalculos.get(0);
                versoesCalculo.descontoAgravo = Decimal.valueOf(descontoAgravo);
            }
        }
        payloadCalculo = JSON.serialize(recalculoProp);
        //II-175 FIM

        System.debug('payloadCalculo <<>> ' + payloadCalculo);
        mapToReturn.put('jsonModificada',payloadCalculo);
        System.debug('mapToReturn <<1>> ' + mapToReturn);
        // II-54 - FIM
        //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ
        

        //enviar para o CIV o JSON modificado
        // II-54 - INICIO
        System.debug('JSON ENVIO >> '+ payloadCalculo);
        String jsonResponse = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.RECALCULO_PROPOSTA, payloadCalculo);//MGRC-1278 - INICIO/FIM
        system.debug('JSON RESPONSE CIV >>> '+ jsonResponse);
        // II-54 - FIM
        RecalculoPropostaTo.Proposta recalculada = new RecalculoPropostaTo.Proposta();
        try{
            recalculada = dtoResponseCalculo(jsonResponse, modificada);
            // II-54 - INICIO
            String jsonResponseAjustado = JSON.serialize(ajustarResponseDescontoAgravo(payloadCalculo,jsonResponse),true);
            mapToReturn.put('jsonResponseRecalculo',jsonResponseAjustado);
            System.debug('jsonResponseRecalculo >> ' + jsonResponseAjustado);
            System.debug('recalculada >> '+ JSON.serialize(recalculada));
            // II-54 - FIM
        } catch (Exception e) {
            system.debug('erro jvbds '+ e.getLineNumber() + ' ' + e.getMessage());
            mapToReturn.put('sucesso',false);
            mapToReturn.put('mensagem','Erro ao realizar de-para com objeto de resultados.');
            mapToReturn.put('stacktrace',e.getStackTraceString() + ' - ' + e.getMessage());
            return mapToReturn;
        }
        
        mapToReturn.put('recalculada', recalculada);
        mapToReturn.put('sucesso', true);
        mapToReturn.put('mensagem', '');
        mapToReturn.put('stacktrace', '');
        return mapToReturn;
    }

    // II-54 - INICIO
    // método que faz o ajuste do payload para desconsiderar o percentual de descontoagravo da proposta que o sinapse manda na resposta apenas como valor referencial, quando ocorre solicitacao de agravo nas garantias.
    // assim será gravado como desconto agravo tecnico dos objetos de proposta, contratante, grupo e segurado, apenas os valores solicitados de agravo da proposta total e nao das garantias.
    private static EmissaoTO.PayloadTO ajustarResponseDescontoAgravo(String payloadEntrada, String jsonAjustar) {
        EmissaoTO.PayloadTO responseAjustar =  (EmissaoTO.PayloadTO) JSON.deserialize(jsonAjustar, EmissaoTO.PayloadTO.class);
        List<RecalculoPropostaTO.DescontoagravoTO> descAgravoEntrada = ((RecalculoPropostaTO) JSON.deserialize(payloadEntrada,RecalculoPropostaTO.class)).calculos[0].precificacao.descontoAgravo;
        Decimal agravoProposta = 0.0; // percentual de agravo solicitado da proposta total
        Decimal descAgravoFPG = 0.0; // desconto agravo da forma de pagamento
        for (RecalculoPropostaTO.DescontoagravoTO dAgravo : descAgravoEntrada) {
            if ('TEC'.equals(dAgravo.tipo)) {
                agravoProposta = dAgravo.percentual;
            }
        }
        List<RecalculoPropostaTO.VersoesCalculos> versoesCalculoEntrada = ((RecalculoPropostaTO) JSON.deserialize(payloadEntrada,RecalculoPropostaTO.class)).calculos[0].versoesCalculos;
        for (RecalculoPropostaTO.VersoesCalculos vCalculo : versoesCalculoEntrada) {
            if ('FPG'.equals(vCalculo.tipo)) {
                descAgravoFPG = vCalculo.descontoAgravo;
            }
        }
        System.debug('AgravoTotal >>>'+ agravoProposta);
        System.debug('descFPG >>>'+ descAgravoFPG);   
        List<EmissaoTO.DescontoagravoTO> descAgravoProposta = responseAjustar.retornosCalculo[0].precificacao.descontoAgravo;
        List<EmissaoTO.DescontoagravoTO> descAgravoContratante = responseAjustar.retornosCalculo[0].precificacao.contratantes[0].descontoAgravo;
        List<EmissaoTO.DescontoagravoTO> descAgravoGrupo = responseAjustar.retornosCalculo[0].precificacao.contratantes[0].grupos[0].descontoAgravo;
        List<EmissaoTO.DescontoagravoTO> descAgravoSegurado = responseAjustar.retornosCalculo[0].precificacao.contratantes[0].grupos[0].segurados[0].descontoAgravo;
        
        EmissaoTO.DescontoagravoTO descontoAgravoAjustarProposta = getAgravoTecnico(descAgravoProposta);
        EmissaoTO.DescontoagravoTO descontoAgravoAjustarContratante = getAgravoTecnico(descAgravoContratante);
        EmissaoTO.DescontoagravoTO descontoAgravoAjustarGrupo = getAgravoTecnico(descAgravoGrupo);
        EmissaoTO.DescontoagravoTO descontoAgravoAjustarSegurado = getAgravoTecnico(descAgravoSegurado);
        
        Decimal monetario;
        Decimal percentual;
        if (agravoProposta == 0.0) {
            monetario = 0.0; 
            percentual = 0.0;
        } else {
            final Decimal premioBase = responseAjustar.retornosCalculo[0].precificacao.premio.puroCarregado;
            monetario =(premioBase * (1 + descAgravoFPG/100) * (agravoProposta/100)).setScale(2,RoundingMode.HALF_UP);
            percentual = (monetario/premioBase*100).setScale(2,RoundingMode.HALF_UP);
        }
        System.debug('ajuste monetario >>'+ percentual);
        System.debug('ajuste percentual >>>'+ monetario);
        if (descontoAgravoAjustarProposta != null) {
            descontoAgravoAjustarProposta.monetario = monetario;
            descontoAgravoAjustarProposta.percentual = percentual;
        }
        if (descontoAgravoAjustarContratante != null) {
            descontoAgravoAjustarContratante.monetario = monetario;
            descontoAgravoAjustarContratante.percentual = percentual;
        }
        if (descontoAgravoAjustarGrupo != null) {
            descontoAgravoAjustarGrupo.monetario = monetario;
            descontoAgravoAjustarGrupo.percentual = percentual;
        }
        if (descontoAgravoAjustarSegurado != null) {
            descontoAgravoAjustarSegurado.monetario = monetario;
            descontoAgravoAjustarSegurado.percentual = percentual;
        }

        return responseAjustar;
    }

    static private EmissaoTO.DescontoagravoTO getAgravoTecnico( List<EmissaoTO.DescontoagravoTO> listAgravos) {
        for (EmissaoTO.DescontoagravoTO dAgravo : listAgravos) {
            if ('TEC'.equals(dAgravo.tipo)) {
                return dAgravo;
            }
        }
        return null;
    }
    // II-54 - FIM

    @AuraEnabled
    public static Map<String,Object> gravarCalculo(String requisicao, Boolean altFormPag){ //II-175 INICIO/FIM
        System.debug('request>>'+JSON.serialize(requisicao));
        System.debug('request2>>'+requisicao);
        System.debug('altFormPag gravarCalculo >>' + altFormPag);
        Map<String,Object> mapToReturn = new Map<String,Object>();
        try {
            Boolean gravou = alteraEstruturaPropostaOrcamentoSync(requisicao, true, altFormPag); //II-175 INICIO/FIM
            //if(!gravou) alteraEstruturaPropostaOrcamentoAsync(requisicao);
        } catch (Exception e) {
            mapToReturn.put('sucesso',false);
            mapToReturn.put('mensagem',e.getMessage());
            mapToReturn.put('stacktrace',e.getStackTraceString() + ' - ' + e.getMessage());
            System.debug('StackTrace >> ' + e.getStackTraceString() + ' - ' + e.getMessage());
            return mapToReturn;
        }

        mapToReturn.put('sucesso',true);

        return mapToReturn;
    }

    @future
    public static void alteraEstruturaPropostaOrcamentoAsync(String requisicao, Boolean altFormPag){ //II-175 INICIO/FIM
        Boolean gravou = alteraEstruturaPropostaOrcamentoSync(requisicao, true, altFormPag); //II-175 INICIO/FIM
        System.debug('GRAVOU ASYNC? ' + gravou);
    }

    public static Boolean alteraEstruturaPropostaOrcamentoSync(String requisicao, Boolean allOrOne, Boolean altFormPag){ //II-175 INICIO/FIM 
        System.debug('altFormPag >>> estrutura ' + altFormPag);
        try{
            Map<String,Object> parsed = new Map<String,Object>();
            //RecalculoPropostaTO.Proposta original = new RecalculoPropostaTO.Proposta();
            RecalculoPropostaTO.Proposta modificada = new RecalculoPropostaTO.Proposta();
            EmissaoTO.OfertasTO payloadResponse = new EmissaoTO.OfertasTO();
           
            parsed = (Map<String,Object>) JSON.deserializeUntyped(requisicao);
            //System.debug('original >> ' + parsed.get('original'));
            //original = (RecalculoPropostaTO.Proposta) JSON.deserialize(JSON.serialize(parsed.get('original')),RecalculoPropostaTO.Proposta.class); //erro
            System.debug('modificada >> ' + JSON.serialize(parsed.get('modificada')));
            modificada = (RecalculoPropostaTO.Proposta) JSON.deserialize(JSON.serialize(parsed.get('modificada')),RecalculoPropostaTO.Proposta.class);
            //System.debug('jsonResponseRecalculo >> ' + JSON.serialize(parsed.get('jsonResponseRecalculo')));
            System.debug('parsed >> ' + parsed.get('jsonResponseRecalculo'));
            System.debug('deserialize Reponse calculo >> ' + String.valueOf(parsed.get('jsonResponseRecalculo')));
            //II-166 - INICIO
            //II-175 - INICIO
            if(Test.isRunningTest()){
                payloadResponse = (EmissaoTO.OfertasTO) JSON.deserialize(String.valueOf(parsed.get('jsonResponseRecalculo')), EmissaoTO.OfertasTO.class); // II-54 - INICIO/FIM 
            }else{
                payloadResponse = (EmissaoTO.OfertasTO) JSON.deserialize(JSON.serialize(parsed.get('jsonResponseRecalculo')),EmissaoTO.OfertasTO.class);
            }
            //II-166 - FIM
            System.debug('payloadResponse << >> ' + payloadResponse);
            //PROPOSTA
            /*Map<String, GarantiaProposta__c> mapGarantiaProposta = new Map<String, GarantiaProposta__c>();
            Map<String, GarantiaContratanteProposta__c> mapGarantiaContratanteProposta = new Map<String, GarantiaContratanteProposta__c>();
            Map<String, GarantiasGrupoProposta__c> mapGarantiaGrupoProposta = new Map<String, GarantiasGrupoProposta__c>();
            Map<String, GarantiaSeguradoProposta__c> mapGarantiaSeguradoProposta = new Map<String, GarantiaSeguradoProposta__c>();*/

            mapSObjectsToDML = new Map<String, List<SObject>>(); //Reinicializa mapa de DML
            Map<String,RecalculoPropostaTO.Garantias> siglaXgarantia = new Map<String,RecalculoPropostaTO.Garantias>();

            for(RecalculoPropostaTO.Garantias g :modificada.garantias){
                siglaXgarantia.put(g.cobertura,g);
            }
            
            EmissaoTO.RetornoCalculoTO retornoCalculo = payloadResponse.retornosCalculo[0];
            
            Quote proposta = QuoteDAO.getInstance().buscarPropostasPorId(new Set<Id>{modificada.id})[0];
            List<ContratanteProposta__c> contratantesProposta = QuoteDAO.getInstance().buscarContratantesPropostaByQuote(new Set<Id>{proposta.Id});
            List<GrupoProposta__c> gruposProposta = QuoteDAO.getInstance().buscarListGrupoPropostaByQuote(new Set<Id>{proposta.Id});
            List<SeguradoProposta__c> seguradosProposta = QuoteDAO.getInstance().buscarListSeguradosPropostaByQuote(new Set<Id>{proposta.Id});
            
            //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
            Map<String,RecalculoPropostaTO.Remuneracoes> mapRemuneracoes = new Map<String,RecalculoPropostaTO.Remuneracoes>();
            for(RecalculoPropostaTO.Remuneracoes r :modificada.remuneracoes){
                mapRemuneracoes.put(r.tipoRemuneracao,r);
            }
            
            List<RemuneracaoProposta__c> listRemuneracaoProposta = new List<RemuneracaoProposta__c>();
            for(RemuneracaoProposta__c r : proposta.RemuneracoesProposta__r){
                System.debug(JSON.serialize(r));
                if(mapRemuneracoes.containsKey(r.TipoRemuneracao__r.Name))
                listRemuneracaoProposta.add(new RemuneracaoProposta__c(Id=r.Id, Percentual__c=mapRemuneracoes.get(r.TipoRemuneracao__r.Name).percentual));
            }

            mapSObjectsToDML.put('RemuneracaoProposta__c|Update',listRemuneracaoProposta);
            //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
            /*for(GarantiaProposta__c gP :proposta.GarantiasProposta__r) mapGarantiaProposta.put(gP.Proposta__c, gP);

            if(!contratantesProposta.isEmpty()){
                for(GarantiaContratanteProposta__c gCP :contratantesProposta[0].GarantiasContratanteProposta__r) mapGarantiaContratanteProposta.put(gCP.ContratanteProposta__c, gCP);
            }
            if(!gruposProposta.isEmpty()){
                for(GarantiasGrupoProposta__c gGP :gruposProposta[0].GarantiasGrupoProposta__r) mapGarantiaGrupoProposta.put(gGP.GrupoPoposta__c, gGP);
            }
            if(!seguradosProposta.isEmpty()){
                for(GarantiaSeguradoProposta__c gSP :seguradosProposta[0].GarantiasSeguradoProposta__r) mapGarantiaSeguradoProposta.put(gSP.SeguradoProposta__c, gSP);
            }*/
            //PLV-4694 - INICIO - PEDRO AUGUSTO BRAZ
            obj(new List<SObject>{proposta}, JSON.serialize(retornoCalculo.precificacao));
            if(!proposta.GarantiasProposta__r.isEmpty()){
                objGarantia(((List<SObject>)((List<GarantiaProposta__c>)proposta.GarantiasProposta__r)), JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]), siglaXgarantia, altFormPag); //FNPVVEP-168 INICIO/FIM
            }
            if(!contratantesProposta.isEmpty()){
                obj(new List<SObject>{contratantesProposta[0]}, JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]));
                if(!contratantesProposta[0].GarantiasContratanteProposta__r.isEmpty()){
                    //objGarantia(((List<SObject>)((List<GarantiaContratanteProposta__c>)contratantesProposta[0].GarantiasContratanteProposta__r)), JSON.serialize(retornoCalculo.precificacao.contratantes[0]), siglaXgarantia);
                    objGarantia(((List<SObject>)((List<GarantiaContratanteProposta__c>)contratantesProposta[0].GarantiasContratanteProposta__r)), JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]), siglaXgarantia, altFormPag); //FNPVVEP-168 INICIO/FIM
                }
            }
            if(!gruposProposta.isEmpty()){
                obj(new List<SObject>{gruposProposta[0]}, JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0])); 
                if(!gruposProposta[0].GarantiasGrupoProposta__r.isEmpty()){
                    objGarantia(((List<SObject>)((List<GarantiasGrupoProposta__c>)gruposProposta[0].GarantiasGrupoProposta__r)), JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]), siglaXgarantia, altFormPag); //FNPVVEP-168 INICIO/FIM
                }
            }
            if(!seguradosProposta.isEmpty()){
                obj(new List<SObject>{seguradosProposta[0]}, JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]));
                if(!seguradosProposta[0].GarantiasSeguradoProposta__r.isEmpty()){
                    objGarantia(((List<SObject>)((List<GarantiaSeguradoProposta__c>)seguradosProposta[0].GarantiasSeguradoProposta__r)), JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]), siglaXgarantia, altFormPag); //FNPVVEP-168 INICIO/FIM
                }
            }
            //PLV-4694 - FIM - PEDRO AUGUSTO BRAZ


            //ORCAMENTO
            /*Map<Id, GarantiaOrcamento__c> mapGarantiaOrcamento = new Map<Id, GarantiaOrcamento__c>();
            Map<Id, GarantiaContratanteOrcamento__c> mapGarantiaContratanteOrcamento = new Map<Id, GarantiaContratanteOrcamento__c>();
            Map<Id, GarantiaGrupoOrcamento__c> mapGarantiaGrupoOrcamento = new Map<Id, GarantiaGrupoOrcamento__c>();
            Map<Id, GarantiaSeguradoOrcamento__c> mapGarantiaSeguradoOrcamento = new Map<Id, GarantiaSeguradoOrcamento__c>();*/

            if(proposta.OpportunityId != null){
                Opportunity orcamento = OpportunityDAO.getInstance().buscarOportunidadesPorId(new Set<Id>{proposta.OpportunityId})[0];
                List<ContratanteOrcamento__c> contratantesOrcamento = OpportunityDAO.getInstance().buscarContratantesOrcamento(new Set<Id>{orcamento.Id});
                List<GrupoOrcamento__c> gruposOrcamento = OpportunityDAO.getInstance().buscarGruposOrcamentoPorOrcamento(new Set<Id>{orcamento.Id});
                List<SeguradoOrcamento__c> seguradosOrcamento = OpportunityDAO.getInstance().buscarSeguradosOrcamentoPorOrcamento(new Set<Id>{orcamento.Id});
                //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
                List<RemuneracaoOrcamento__c> listRemuneracaoOrcamento = new List<RemuneracaoOrcamento__c>();
                for(RemuneracaoOrcamento__c r : orcamento.RemuneracoesOrcamento__r){
                    if(mapRemuneracoes.containsKey(r.TipoRemuneracao__r.Name))
                    listRemuneracaoOrcamento.add(new RemuneracaoOrcamento__c(Id=r.Id, Percentual__c=mapRemuneracoes.get(r.TipoRemuneracao__r.Name).percentual));
                }
                mapSObjectsToDML.put('RemuneracaoOrcamento__c|Update',listRemuneracaoOrcamento);
                //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
                /*for(GarantiaOrcamento__c gO :orcamento.CoberturasOrcamento__r) mapGarantiaOrcamento.put(gO.Orcamento__c, gO);

                if(!contratantesOrcamento.isEmpty()){
                    for(GarantiaContratanteOrcamento__c gCO :contratantesOrcamento[0].GarantiasContratanteOrcamento__r) mapGarantiaContratanteOrcamento.put(gCO.ContratanteOrcamento__c, gCO);
                }
                if(!gruposOrcamento.isEmpty()){
                    for(GarantiaGrupoOrcamento__c gGO :gruposOrcamento[0].GruposGarantiaOrcamento__r) mapGarantiaGrupoOrcamento.put(gGO.GrupoOrcamento__c, gGO);
                }
                if(!seguradosOrcamento.isEmpty()){
                    for(GarantiaSeguradoOrcamento__c gSO :seguradosOrcamento[0].GarantiasSeguradoOrcamento__r) mapGarantiaSeguradoOrcamento.put(gSO.SeguradoOrcamento__c, gSO);
                }*/
                //PLV-4694 - INICIO - PEDRO AUGUSTO BRAZ
                obj(new List<SObject>{orcamento}, JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]));
                if(!orcamento.CoberturasOrcamento__r.isEmpty()){
                    objGarantia(((List<SObject>)((List<GarantiaOrcamento__c>)orcamento.CoberturasOrcamento__r)), JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]), siglaXgarantia, altFormPag); //FNPVVEP-168 INICIO/FIM
                }
                if(!contratantesOrcamento.isEmpty()){
                    obj(new List<SObject>{contratantesOrcamento[0]}, JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]));
                    if(!contratantesOrcamento[0].GarantiasContratanteOrcamento__r.isEmpty()){
                        //objGarantia(((List<SObject>)((List<GarantiaContratanteOrcamento__c>)contratantesOrcamento[0].GarantiasContratanteOrcamento__r)), JSON.serialize(retornoCalculo.precificacao.contratantes[0]), siglaXgarantia);
                        objGarantia(((List<SObject>)((List<GarantiaContratanteOrcamento__c>)contratantesOrcamento[0].GarantiasContratanteOrcamento__r)), JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]), siglaXgarantia, altFormPag); //FNPVVEP-168 INICIO/FIM
                    }
                }
                if(!gruposOrcamento.isEmpty()){
                    obj(new List<SObject>{gruposOrcamento[0]}, JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]));
                    if(!gruposOrcamento[0].GruposGarantiaOrcamento__r.isEmpty()){
                        objGarantia(((List<SObject>)((List<GarantiaGrupoOrcamento__c>)gruposOrcamento[0].GruposGarantiaOrcamento__r)), JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]), siglaXgarantia, altFormPag); //FNPVVEP-168 INICIO/FIM
                    }
                }
                if(!seguradosOrcamento.isEmpty()){
                    obj(new List<SObject>{seguradosOrcamento[0]}, JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0])); 
                    if(!seguradosOrcamento[0].GarantiasSeguradoOrcamento__r.isEmpty()){
                        objGarantia(((List<SObject>)((List<GarantiaSeguradoOrcamento__c>)seguradosOrcamento[0].GarantiasSeguradoOrcamento__r)), JSON.serialize(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]), siglaXgarantia, altFormPag); //FNPVVEP-168 INICIO/FIM
                    }
                }
                //PLV-4694 - FIM - PEDRO AUGUSTO BRAZ
            }


            //Estrutura percorrendo payload (Viagem/VG)
            /*for(EmissaoTO.CoberturaTO cPropostaOrcamento){
            }
            for(EmissaoTO.ContratanteTO contratante: obj.contratantes){
                for(EmissaoTO.CoberturaTO cContrantante :contratante.coberturas){
                }
                for(EmissaoTO.GrupoTO grupo :contratante.grupos){
                    for(EmissaoTO.CoberturaTO cGrupo :grupo.coberturas){
                    }
                    for(EmissaoTO.SeguradoTO segurado :grupo.segurados){
                        for(EmissaoTO.CoberturaTO cSegurado :segurado.coberturas){
                        }
                    }
                }
            }*/
            Boolean sucesso = true;
            System.debug('altFormPag >>> dml ' + altFormPag);
            realizaDML(allOrOne, sucesso, altFormPag); //II-175 INICIO/FIM
            return sucesso;
        } catch(Exception e) {
            System.debug('Erro ao executar mapeamento/DML');
            System.debug('StackTrace >> ' + e.getStackTraceString() + ' - ' + e.getMessage());
            return false;
        }
    }

    public static void obj(List<SObject> sObjs, String pObj){
        
        Map<String, Object> objPayload = (Map<String, Object>) JSON.deserializeUntyped(pObj);
        String nomeSObject = String.valueOf(sObjs[0].getSObjectType());
       
        for(SObject sObj : sObjs){
            
            if(objPayload.get('descontoAgravo') != null){
                List<EmissaoTO.DescontoagravoTO> dAs = (List<EmissaoTO.DescontoagravoTO>) JSON.deserialize(JSON.serialize(objPayload.get('descontoAgravo')), List<EmissaoTO.DescontoagravoTO>.class);
                System.debug('DAS LIST +++' + dAs);
                for(EmissaoTO.DescontoagravoTO dA : dAs) {
                    if(nomeSObject == 'Opportunity' || nomeSObject.contains('Orcamento')) {
                        if(nomeSObject == 'Opportunity'){
                            if(dA.tipo == 'TEC') { 
                                sObj.put('DescontoAgravoPercentualTecnico__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                sObj.put('DescontoAgravoMonetarioTecnico__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'COM') {
                                sObj.put('DescontoAgravoPercentualComercial__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                sObj.put('DescontoAgravoMonetarioComercial__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'BAT') {
                                sObj.put('DescontoAgravoPercentualInformado__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                sObj.put('DescontoAgravoMonetarioInformado__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'FPG') {
                                sObj.put('DescontoAgravoPercentualFormaPagto__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                sObj.put('DescontoAgravoMonetarioFormaPagto__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'TPR') {
                                sObj.put('DescontoAgravoPercentualParcelamento__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                sObj.put('DescontoAgravoMonetarioParcelamento__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            }
                        } else {
                            if(dA.tipo == 'TEC') { 
                                sObj.put('DescontoAgravoPercentualTecnico__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                sObj.put('DescontoAgravoMonetarioTecnico__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'COM') {
                                sObj.put('DescontoAgravoPercentualComercial__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                sObj.put('DescontoAgravoMonetarioComercial__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'BAT') {
                                sObj.put('DescontoAgravoPercentualInformado__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                sObj.put('DescontoAgravoMonetarioInformado__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            }
                        }                    
                    } else if(nomeSObject == 'Quote' || nomeSObject.contains('Proposta')) {
                        if(dA.tipo == 'TEC') {
                            sObj.put('DescontoAgravoPercentualTecnico__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                            sObj.put('DescontoAgravoMonetarioTecnico__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                        } else if(dA.tipo == 'COM') {
                            sObj.put('DescontoAgravoPercentualComercial__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                            sObj.put('DescontoAgravoMonetarioComercial__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                        } else if(dA.tipo == 'BAT') {
                            sObj.put('DescontoAgravoPercentualInformado__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                            sObj.put('DescontoAgravoMonetarioInformado__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                        } else if(dA.tipo == 'FPG') {
                            sObj.put('DescontoAgravoPercentualFormaPagto__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                            sObj.put('DescontoAgravoMonetarioFormaPagto__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                        } else if(dA.tipo == 'TPR') {
                            sObj.put('DescontoAgravoPercentualParcelamento__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                            sObj.put('DescontoAgravoMonetarioParcelamento__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                        }
                    }
                }
            }
           
            if(nomeSObject == 'Quote'){
                Integer num = sObj.get('NumeroRecalculosEfetivos__c') == null ? 0 : Integer.valueOf(sObj.get('NumeroRecalculosEfetivos__c'));
                sObj.put('NumeroRecalculosEfetivos__c',(num+1));
            }

            if(objPayload.get('premio') != null){
                Map<String, Object> premio = (Map<String, Object>) objPayload.get('premio');
                sObj.put('PremioComercial__c', premio.get('comercial') == null ? null : (Decimal) premio.get('comercial'));
                sObj.put('PremioPuro__c', premio.get('puro') == null ? null : (Decimal) premio.get('puro'));
                sObj.put('PremioTotal__c', premio.get('total') == null ? null : (Decimal) premio.get('total'));
            }
            if(objPayload.get('taxa') != null){
                Map<String, Object> taxa = (Map<String, Object>) objPayload.get('taxa');
                sObj.put('TaxaComercial__c', taxa.get('comercial') == null ? null : (Decimal) taxa.get('comercial'));
                sObj.put('TaxaPura__c', taxa.get('pura') == null ? null : (Decimal) taxa.get('pura'));
                sObj.put('TaxaTotal__c', taxa.get('total') == null ? null : (Decimal) taxa.get('total'));
            }
            sObj.put('IOF__c', (Decimal) objPayload.get('iof') == null ? 0 : (Decimal) objPayload.get('iof'));//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

            if(mapSObjectsToDML.containsKey(nomeSObject + '|Update')){
                mapSObjectsToDML.get(nomeSObject + '|Update').add(sObj);
            } else {
                mapSObjectsToDML.put(nomeSObject + '|Update', new List<SObject>{sObj});
            }
        }
    }
    //PLV-4694 - INICIO - PEDRO AUGUSTO BRAZ
    public static void objGarantia(List<SObject> sObjs, String pObj, Map<String,RecalculoPropostaTO.Garantias> siglaXgarantia, Boolean altFormPag){ //FNPVVEP-168 INICIO/FIM
        
        Map<String, Object> objPayload = (Map<String, Object>) JSON.deserializeUntyped(pObj);
        String nomeSObject = String.valueOf(sObjs[0].getSObjectType());

        Map<String, EmissaoTO.CoberturaTO> mapCoberturasPayload = new Map<String, EmissaoTO.CoberturaTO>();
        for(EmissaoTO.CoberturaTO gPayload :(List<EmissaoTO.CoberturaTO>) JSON.deserialize(JSON.serialize(objPayload.get('coberturas')),List<EmissaoTO.CoberturaTO>.class)){
            mapCoberturasPayload.put(gPayload.sigla, gPayload);
        }
        
        for(SObject garantiaSObj :sObjs){
            Garantia__c garantia = (Garantia__c) garantiaSObj.getSobject('Garantia__r');
            if(garantia != null){
                if(!mapCoberturasPayload.containsKey(garantia.Sigla__c)) {
                    if(mapSObjectsToDML.containsKey(nomeSObject + '|Delete')){
                        mapSObjectsToDML.get(nomeSObject + '|Delete').add(garantiaSObj);
                    } else {
                        mapSObjectsToDML.put(nomeSObject + '|Delete', new List<SObject>{garantiaSObj});
                    }
                } else {
                    EmissaoTO.CoberturaTO gPayload = mapCoberturasPayload.get(garantia.Sigla__c);
                    for(EmissaoTO.DescontoAgravoTO dA :gPayload.descontoAgravo) {
                        if(nomeSObject.contains('Orcamento')){
                            if(dA.tipo == 'TEC') {
                                garantiaSObj.put('DescontoAgravoPercentualTecnico__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                garantiaSObj.put('DescontoAgravoMonetarioTecnico__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'COM') {
                                garantiaSObj.put('DescontoAgravoPercentualComercial__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                garantiaSObj.put('DescontoAgravoMonetarioComercial__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'BAT') {
                                garantiaSObj.put('DescontoAgravoPercentualInformado__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                garantiaSObj.put('DescontoAgravoMonetarioInformado__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            }
                        }else{
                            if(dA.tipo == 'TEC' && !altFormPag) { //FNPVVEP-168 INICIO/FIM
                                garantiaSObj.put('DescontoAgravoPercentualTecnico__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                garantiaSObj.put('DescontoAgravoMonetarioTecnico__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'COM') {
                                garantiaSObj.put('DescontoAgravoPercentualComercial__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                garantiaSObj.put('DescontoAgravoMonetarioComercial__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'BAT') {
                                garantiaSObj.put('DescontoAgravoPercentualInformado__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                garantiaSObj.put('DescontoAgravoMonetarioInformado__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'FPG') {
                                garantiaSObj.put('DescontoAgravoPercentualFormaPagto__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                garantiaSObj.put('DescontoAgravoMonetarioFormaPagto__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            } else if(dA.tipo == 'TPR') {
                                garantiaSObj.put('DescontoAgravoPercentualParcelamento__c', dA.percentual == null ? null : (Decimal) dA.percentual);
                                garantiaSObj.put('DescontoAgravoMonetarioParcelamento__c', dA.monetario == null ? null : (Decimal) dA.monetario);
                            }
                        }
                    }
                    if(gPayload.premio != null){
                        garantiaSObj.put('PremioComercial__c', gPayload.premio.comercial == null ? null : gPayload.premio.comercial);
                        garantiaSObj.put('PremioPuro__c', gPayload.premio.puro == null ? null : gPayload.premio.puro);
                        garantiaSObj.put('PremioTotal__c', gPayload.premio.total == null ? null : gPayload.premio.total);
                    }
                    if(gPayload.taxa != null){
                        garantiaSObj.put('TaxaComercial__c', gPayload.taxa.comercial == null ? null : gPayload.taxa.comercial);
                        garantiaSObj.put('TaxaPura__c', gPayload.taxa.pura==null ? null : gPayload.taxa.pura );
                        garantiaSObj.put('TaxaTotal__c', gPayload.taxa.total==null ? null : gPayload.taxa.total);
                    }
                    if(siglaXgarantia.containsKey(garantia.Sigla__c)){
                        garantiaSObj.put('Capital__c', (Decimal) siglaXgarantia.get(garantia.Sigla__c).capital);
                    }
                    garantiaSObj.put('IOF__c', gPayload.iof == null ? 0 : gPayload.iof);//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

                    if(mapSObjectsToDML.containsKey(nomeSObject + '|Update')){
                        mapSObjectsToDML.get(nomeSObject + '|Update').add(garantiaSObj);
                    } else {
                        mapSObjectsToDML.put(nomeSObject + '|Update', new List<SObject>{garantiaSObj});
                    }
                }
            }
        }
    }
    //PLV-4694 - FIM - PEDRO AUGUSTO BRAZ
    
    public static Boolean realizaDML(Boolean allOrOne,Boolean sucesso , Boolean altFormPag){ //II-175 INICIO/FIM
        List<SObject> listSObjDML = new List<SObject>();
        List<Database.DeleteResult> drList = new List<Database.DeleteResult>();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        List<String> mensagens = new List<String>();
        String operacao;
        Savepoint sp = Database.setSavepoint();
        //PLV-4694 - INICIO - PEDRO AUGUSTO BRAZ
        String [] nomesSObjsMaster = new String[] {'Opportunity'
                                                    ,'Quote'
                                                    ,'ContratanteProposta__c'
                                                    ,'GrupoProposta__c'
                                                    ,'SeguradoProposta__c'
                                                    ,'ContratanteOrcamento__c'
                                                    ,'GrupoOrcamento__c'
                                                    ,'SeguradoOrcamento__c'//PLV-4851 - INICIO/FIM
                                                    ,'RemuneracaoProposta__c'//PLV-4851 - INICIO/FIM
                                                    ,'RemuneracaoOrcamento__c'};//PLV-4851 - INICIO/FIM

        String [] nomesSObjsGarantias = new String[] {'GarantiaProposta__c',
                                                      'GarantiaContratanteProposta__c',
                                                      'GarantiasGrupoProposta__c',
                                                      'GarantiaSeguradoProposta__c',
                                                      'GarantiaOrcamento__c',
                                                      'GarantiaContratanteOrcamento__c',
                                                      'GarantiaGrupoOrcamento__c',
                                                      'GarantiaSeguradoOrcamento__c'};
        //PLV-4694 - FIM - PEDRO AUGUSTO BRAZ
        //Atualizar proposta e orcamento
        operacao = 'Update';
        
        String propostaId = mapSObjectsToDML.get('Quote|Update')[0].Id;
        mapSObjectsToDML.get('Quote|Update')[0].put('GerarPDF__c',true);
        //mapSObjectsToDML.get('Quote|Update')[0].put('ProcessBaseTime__c',System.Now().addMinutes(2));

        

        //Atualizar garantias
        for(String obj :nomesSObjsGarantias){
            if(mapSObjectsToDML.containsKey(obj + '|' + operacao)){
                listSObjDML.addAll(mapSObjectsToDML.get(obj + '|' + operacao));
            }
        }
        if(!listSObjDML.isEmpty()){
            srList = Database.update(listSObjDML, allOrOne);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {           
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Ocorreu o seguinte erro:');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Campos afetados: ' + err.getFields());
                        mensagens.add('[AG-'+err.getStatusCode()+'] - '+err.getMessage() +' | '+err.getFields() );
                    }
                    sucesso = false;
                }
            }
            listSObjDML.clear();
            srList.clear();
        }

        for(String obj :nomesSObjsMaster){
            if(mapSObjectsToDML.containsKey(obj + '|' + operacao)){
                listSObjDML.addAll(mapSObjectsToDML.get(obj + '|' + operacao));
            }
        }
        if(!listSObjDML.isEmpty()){
            srList = Database.update(listSObjDML, allOrOne);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {           
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Ocorreu o seguinte erro:');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Campos afetados: ' + err.getFields());
                        mensagens.add('[A-'+err.getStatusCode()+'] - '+err.getMessage() +' | '+err.getFields() );
                    }
                    sucesso = false;
                }
            }
            listSObjDML.clear();
            srList.clear();
        }
        
        //Deletar garantias
        operacao = 'Delete';
        for(String obj :nomesSObjsGarantias){
            if(mapSObjectsToDML.containsKey(obj + '|' + operacao)){
                listSObjDML.addAll(mapSObjectsToDML.get(obj + '|' + operacao));
            }
        }
        if(!listSObjDML.isEmpty()){
            drList = Database.delete(listSObjDML, allOrOne);
            for (Database.DeleteResult dr : drList) {
                if (!dr.isSuccess()) {           
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('Ocorreu o seguinte erro:');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Campos afetados: ' + err.getFields());
                        mensagens.add('[D-'+err.getStatusCode()+'] - '+err.getMessage() +' | '+err.getFields() );
                    }
                    sucesso=false;
                }
            }
        }
        //PLV-5403 - INICIO
        if(sucesso){
            /*
            //PLV-4883 - INICIO - PEDRO AUGUSTO BRAZ
            if(!Test.isRunningTest())
            sendBatch();
            //PLV-4883 - FIM - PEDRO AUGUSTO BRAZ
        }else{
            Database.rollback(sp);
            sucesso = false;
            throw new AuraHandledException (String.join(mensagens,'; '));
        }

        return sucesso;
    }
    //PLV-4883 - INICIO - PEDRO AUGUSTO BRAZ
    @future(callout=true)
    public static void sendBatch(){
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 3); 
        String ss = String.valueOf(Datetime.now().second());
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        Map<String,Object> mapToSend = new Map<String,Object>();
        UserTools.Request requestToSend = new UserTools.Request();
        requestToSend.batch = new List<UserTools.innerBatch>(); 
        UserTools.innerBatch batch = new UserTools.innerBatch();
        batch.tempo = nextFireTime;
        batch.name = 'BatchGerarPDF';
        batch.descricao = 'BatchGerarPDF - Temporario - 3 minutos ' + String.valueOf(Datetime.now());
        batch.agendado = true;
        requestToSend.batch.add(batch);
        
        mapToSend.put('api','/services/apexrest/usertools');
        mapToSend.put('metodo','POST');
        mapToSend.put('payload',requestToSend);
        mapToSend.put('stripnull',true);
        String ResponseBody =  CIVServices.getInstance().proxyAutomacao(JSON.serialize(mapToSend));
        Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
        if(responseMap.containsKey('responsebody')){
            //responseMap = (Map<String,Object>) responseMap.get('responsebody'); //PLV-5403 INICIO-FIM
            responseMap = (Map<String,Object>) responseMap.get('responsebody'); //PLV-5403
            if(!(Boolean)responseMap.get('sucesso')){            
                throw new AuraHandledException ((String)responseMap.get('mensagem'));               
            }
        }else {
            throw new AuraHandledException ('Resposta do Agendamento não recebida!');
        }
    }
    //PLV-4883 - FIM - PEDRO AUGUSTO BRAZ */
            System.debug('propostaId -====='+ propostaId);
            System.debug('mensagens -====='+ mensagens);
            Map<String,Object> processCriticas = processCriticas(propostaId,mensagens, altFormPag); //II-175 INICIO/FIM
            if((Boolean)processCriticas.get('sucesso')==true){
                // PLV-4544 FIX INICIO
                String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().minute() + 3); 
                String ss = String.valueOf(Datetime.now().second());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                BatchGerarPDF batch = new BatchGerarPDF(); 
                JobsAgendados__c jb = new JobsAgendados__c();
                jb.Name = 'BatchGerarPDF'+propostaId;
                jb.jobId__c = System.schedule('BatchGerarPDF - Temporario - 3 minutos ' + String.valueOf(Datetime.now()), nextFireTime, batch);
                insert jb;
                // PLV-4544 FIX FIM
            }else{
                Database.rollback(sp);
                throw new AuraHandledException (JSON.serialize(processCriticas.get('mensagem')));//PLV-4851 - INICIO/FIM
            }
        }else{
            Database.rollback(sp);
            throw new AuraHandledException (String.join(mensagens,'; '));//PLV-4851 - INICIO/FIM
        }

        return sucesso;
    }
    //PLV-5403 - FIM
    
    public class RecalculoException extends Exception {}

    public static Map<String,Object> processCriticas(String propostaId,List<String> mensagens, Boolean altFormPag){ //II-175 INICIO/FIM
        Map<String,Object> mapToReturn = new Map<String,Object>();
        System.debug('altFormPag criticas > ' + altFormPag);
        List<CriticaProposta__c> lCritica = [SELECT Id from CriticaProposta__c WHERE MomentoAnalise__c='Recalculo' AND Status__c='Pendente' AND Proposta__c =:propostaId LIMIT 1];

        List<Quote> lDocusign =  [SELECT Id, RealizarEnvioDocusign__c from Quote WHERE RealizarEnvioDocusign__c = false AND Id =:propostaId LIMIT 1]; //PLV-5403 INICIO-FIM

        //lIBERAR A CRÍTICA DE RECALCULO
        if(lCritica!=null && lCritica.size()>0){
            
            if(mensagens==null || mensagens.size()==0){
                lCritica[0].Status__c='Liberado';
                lDocusign[0].RealizarEnvioDocusign__c = true; //PLV-5403 INICIO-FIM
            }
            lCritica[0].ErrosRecalculo__c = mensagens.size()==0 ? '' : String.join(mensagens,'; ');
            
            CriticaProposta__c cpToCreate = new CriticaProposta__c();
            cpToCreate.Proposta__c =propostaId;
            cpToCreate.Status__c ='Pendente';
            cpToCreate.Origem__c ='Salesforce';
            cpToCreate.Tipo__c ='Analise';
            cpToCreate.Integracao__c ='DOCUSIGN';
            cpToCreate.Area__c ='Emissão';
            // PLV-4552 - INICIO - RESPOSÁVEL PELO ENVIO DO TEMPLATE DE EMAIL Acao__c
            cpToCreate.Acao__c = 'agravo'; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
            cpToCreate.MomentoAnalise__c = 'Recalculo';
            cpToCreate.Descricao__c = 'Código 0113 - Assinatura Docusign Recálculo';//PLV-4851 - INICIO/FIM - FIX - 4
            cpToCreate.Codigo__c = '113';//PLV-4851 - INICIO/FIM - FIX - 4
            cpToCreate.Setor__c = 'Emissão';
            // PLV-4552 - FIM
            lCritica.add(cpToCreate);
            
            
            try {
            	//II-175 INICIO
                if(!altFormPag){
                    upsert lCritica;
                    update lDocusign; //PLV-5403 INICIO-FIM
                }
                //II-175 FIM
                mapToReturn.put('sucesso', true);
                mapToReturn.put('mensagem', mensagens);
                
                System.debug('mapToReturn ====='+ mapToReturn);
                return mapToReturn;
                
            } catch (Exception e) {
                mapToReturn.put('sucesso', false);
                mapToReturn.put('mensagem',   'Erro no update de criticas: '+e.getStackTraceString() + ' - ' + e.getMessage());
            }
            
        }else{
            //II-175 FIX01 INICIO
            if(altFormPag){
                mapToReturn.put('sucesso', true);
            }else{
                mapToReturn.put('sucesso', false);
            }
            //II-175 FIX01 FIM
            mapToReturn.put('mensagem',   'Não existe crítica de recalculo pendente');
        }

        return mapToReturn;
    }
    
    @AuraEnabled
    public static List<CriticaProposta__c> popularTabelaCriticas(String propostaId){
        return [SELECT Name, Area__c, MomentoAnalise__c, Status__c, MensagemInterna__c, MensagemCliente__c //INICIO/FIM | PLV-4647-VI-Guilherme Brito
                FROM CriticaProposta__c
                WHERE Proposta__c = :propostaId
                ORDER BY Name];
    }

    //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    @AuraEnabled
    public static Map<String,Object> validarPercentuais(RecalculoPropostaTO.Proposta proposta, Map<String, RemuneracaoProduto__c> mapRemuneracoes){ //PLV-5161 - INICIO/FIM ADICIONADO PARAMETROS 
        System.debug(LoggingLevel.ERROR,'validarPercentuais inicio');
        Map<String,Object> mapToReturn = new Map<String,Object>();
        
        List<String> listMensagem = new List<String>();
        Set<Id> setOrcamentoId = new Set<Id>();
        RecalculoPropostaTO.Remuneracoes remuneracaoOrcamentoAgenciamento;
        List<RecalculoPropostaTO.Remuneracoes> listRemuneracaoOrcamentoRestantes = new List<RecalculoPropostaTO.Remuneracoes>();
        Date vigenciaInicial = proposta.VigenciaInicial ;
        Date vigenciaFinal = proposta.VigenciaFinal;
        Decimal limiteTotalCarregamento = proposta.LimiteTotalCarregamento;
        String mensagem = '';
        Decimal totalCarregamentoCalculado;

        if(limiteTotalCarregamento == null){
            mapToReturn.put('mensagem','Limite total de carregamento não informado no produto');
            mapToReturn.put('valido',false);
            return mapToReturn;
        }

        for(RecalculoPropostaTO.Remuneracoes remuneracao : proposta.remuneracoes){
            if(remuneracao.tipoRemuneracao=='AGENCIAMENTO')
                remuneracaoOrcamentoAgenciamento = remuneracao;
            else {
                listRemuneracaoOrcamentoRestantes.add(remuneracao);
            }
        }

        // calculo do termo 1
        //PLV-5161 - INICIO
        //Agenciamento
        /*
        Decimal termo1 = 0;
        if(remuneracaoOrcamentoAgenciamento != null){
            // Calcula a quantidade de meses entre a vigencia inicial e final
            Integer quantidadeMeses = RemuneracaoOrcamentoBO.getInstance().calcularQuantidadeMesesEntreDatas(vigenciaInicial, vigenciaFinal);
            if(quantidadeMeses != 0 && remuneracaoOrcamentoAgenciamento.percentual != null)
                termo1 = remuneracaoOrcamentoAgenciamento.percentual / quantidadeMeses;
        }

        // calculo do termo 2
        //corretagem
        Decimal termo2 = 0;
        Decimal somatoriaPercentuais = 0;
        for(RecalculoPropostaTO.Remuneracoes remuneracaoOrcamento : listRemuneracaoOrcamentoRestantes){
            if(remuneracaoOrcamento.percentual == null) continue;
            somatoriaPercentuais += remuneracaoOrcamento.percentual;
        }

        termo2 = somatoriaPercentuais * (100 - termo1) / 100;
        totalCarregamentoCalculado = termo1 + termo2;
        */
        // Validação final
        for(RecalculoPropostaTO.Remuneracoes remuneracao: proposta.remuneracoes){
            if(!mapRemuneracoes.containsKey(remuneracao.codigo)) continue;
            RemuneracaoProduto__c remuracaoProduto = mapRemuneracoes.get(remuneracao.codigo);
            if(remuracaoProduto.LimiteMaximo__c < remuneracao.percentual) {
                System.debug(LoggingLevel.ERROR,'INVALIDO');
                mapToReturn.put('mensagem','Percentual de carregamento (' + remuneracao.percentual +') acima do limite do produto comercial (' + remuracaoProduto.LimiteMaximo__c.setScale(2) + ')');
                mapToReturn.put('valido',false);
            }else if(remuracaoProduto.LimiteMinimo__c > remuneracao.percentual){
                System.debug(LoggingLevel.ERROR,'INVALIDO');
                mapToReturn.put('mensagem','Percentual de carregamento (' + remuneracao.percentual +') abaixo do limite do produto comercial (' + remuracaoProduto.LimiteMinimo__c.setScale(2) + ')');
                mapToReturn.put('valido',false);
            }else{
                System.debug(LoggingLevel.ERROR,'VALIDO');
                mapToReturn.put('valido',true);
            }
        }
        //PLV-5161 - FIM

        return mapToReturn;
    }
    //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
    //II-166 - INICIO
    @AuraEnabled
    public static Map<String,Object> dadosFormaPagamento(String propostaId){

        Map<String,Object> mapDadosFormaPgto = new Map<String,Object>();

        try{
            
            List<ContratanteProposta__c> lcttProp = altFormPgtoDAO.consultarContrProp(propostaId);

            formaPagtoTO.proposta = lcttProp[0].Proposta__r.Name;
            formaPagtoTO.formaPagamentoAtual = lcttProp[0].FormaPagamento__r.Name;
            formaPagtoTO.codFormPag = lcttProp[0].FormaPagamento__r.Codigo__c; //II-174 FIX01 INICIO/FIM
            formaPagtoTO.valorPremioAtual = lcttProp[0].PremioTotal__c;

            mapDadosFormaPgto.put('proposta', formaPagtoTO.proposta);
            mapDadosFormaPgto.put('formaPagamentoAtual', formaPagtoTO.formaPagamentoAtual);
            mapDadosFormaPgto.put('valorPremioAtual', formaPagtoTO.valorPremioAtual);
            mapDadosFormaPgto.put('produtoId', lcttProp[0].Proposta__r.Produto__c);
            mapDadosFormaPgto.put('vencimentoDemaisParcelas', lcttProp[0].VencimentoDemaisParcelas__c);
            mapDadosFormaPgto.put('quantidadeParcelas', lcttProp[0].QuantidadeParcelas__c); //II-206 FIX01 INICIO/FIM
            mapDadosFormaPgto.put('codFormPag', formaPagtoTO.codFormPag); //II-174 FIX01 INICIO/FIM
            mapDadosFormaPgto.put('cliente', lcttProp[0].Nome_do_segurado__c); //FNPVVEP-147 INICIO/FIM
            mapDadosFormaPgto.put('produto', lcttProp[0].Proposta__r.Produto__r.Name); //FNPVVEP-147 INICIO/FIM

                    return mapDadosFormaPgto;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String,Object> qtdeParcelas(String proposta, String produtoId){

        Map<String,Object> mapCodParc = new Map<String,Object>();
        Map<FormaPagamento__c, String> qtdParcelas = new Map<FormaPagamento__c, String>();
        String agenciamento = 'AGENCIAMENTO';

        try {

            if(proposta == null || produtoId == null){
                throw new RecalculoException();
            }
            
            List<RemuneracaoProposta__c> rp = altFormPgtoDAO.agencPercMaiorQZero(proposta, agenciamento);

            Map<String, CondicaoCobranca__c> mapLCC = new Map<String,CondicaoCobranca__c>(); 
            
            List<CondicaoCobranca__c> condCobList = altFormPgtoDAO.consultarQtdeParcelas(produtoId);

            for (CondicaoCobranca__c condicaoCobranca : condCobList) {
                String formaPagamentoCodigo = condicaoCobranca.FormaPagamento__r.Codigo__c;
                mapLCC.put(formaPagamentoCodigo, condicaoCobranca);
            }

            for(CondicaoCobranca__c cc : mapLCC.values()){
                if(!rp.isEmpty()){
                    cc = altFormPgtoBO.montarParcelas(cc, rp[0].Percentual__c);
                }
                cc = altFormPgtoBO.montarParcelas(cc, 0);
                qtdParcelas.put(cc.FormaPagamento__r, cc.QuantidadeParcelas__c);
            }

            for(FormaPagamento__c fp: qtdParcelas.keySet()){
                mapCodParc.put(fp.Codigo__c, qtdParcelas.get(fp));
            }
            mapCodParc.put('RemuneracaoProposta__c >< ', rp[0].Id);
            mapCodParc.put('CondicaoCobranca__c >< ', condCobList[0].Id);
        return mapCodParc;
        } catch (Exception e) {
            mapCodParc.put('sucesso',false);
            mapCodParc.put('mensagem','Erro qtdeParcelas');
            mapCodParc.put('stacktrace',e.getStackTraceString() + ' - ' + e.getMessage());
            return mapCodParc;
            //throw new AuraHandledException(e.getMessage());
        }
    }
	
	//FNPVVEP-147 INICIO
    @AuraEnabled
    public static Map<String,String> verificarCodEmpresa(String proposta){

        Map<String,String> mapRecorrenciaProduto = new Map<String,String>();

        try {
            Quote prop = altFormPgtoDAO.verificarCodProdEmp(proposta);
            String codProduto = prop.Produto__r.ProductCode;
            Integer codEmp = prop.Produto__r.Empresa__r != null ? Integer.valueOf(prop.Produto__r.Empresa__r.CodigoEmpresa__c) : Integer.valueOf(prop.Account.CodigoEmpresa__c);
            String segmento = prop.Produto__r.Segmento__c;
            Boolean recorrente = MetadataDAO.getInstance().existsInMetadata(segmento, codProduto, codEmp);
            
            mapRecorrenciaProduto.put('produtoRecorrente', String.valueOf(recorrente));
            mapRecorrenciaProduto.put('codigoEmpresa', String.valueOf(codEmp));
            return mapRecorrenciaProduto;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //FNPVVEP-147 FIM
    //II-172 - INICIO
    @AuraEnabled
    public static Map<String, Object> getEnderecos(String cep){
        
        
        Map<String, Object> mapCEP = new Map<String, Object>();

        if(cep == ''){
            throw new RecalculoException('CEP inválido.');
        }

            List<String> splitCep = cep.split('-');
            String cepPrefixo = splitCep.get(0);
            String cepSufixo = splitCep.get(1);

        try {
            // String retorno = CIVServices.getInstance().consultarCEP(cepPrefixo, cepSufixo);
            String retorno = SensediaServices.getInstance().consultarCEP(cepPrefixo, cepSufixo);
            if(retorno != null){
                List<AltFormPgtoTO.EnderecoTO> enderecos = altFormPgtoBO.getEnderecos(cepPrefixo, cepSufixo, retorno);
                mapCEP.put('enderecos', enderecos);  
            }else{
                throw new RecalculoException('CEP não encontrado.');
            }
            return mapCEP;
        } catch (Exception e) {
            return mapCEP;
        }
    }
//II-172 - FIM
    //II-176 - INICIO
    @AuraEnabled
    public static Boolean verificaAntecipacao(String propostaId){
        
        //try {
            System.debug('propostaId' + propostaId);
            Boolean fraseAntecipacao = false;
            Quote prop = altFormPgtoDAO.getQuote(propostaId);
            String idProduto = prop.Produto__c;
            String nameProp = prop.Name;
            List<AntecipacaoComissao__c> antecipacao = altFormPgtoDAO.verificaAntecipacaoProd(idProduto);
            List<RemuneracaoProposta__c> remProp = altFormPgtoDAO.getRemProp(nameProp);
            String antecipacaoTipo;

            if (!antecipacao.isEmpty() && !remProp.isEmpty()) {
                for (AntecipacaoComissao__c ant : antecipacao) {
                    antecipacaoTipo = ant.TipoEvento__c == 'Seguro Novo' ? 'Novo' : ant.TipoEvento__c == 'Renovação' ? 'Renovacao' : ant.TipoEvento__c == 'Endosso' ? ant.TipoEvento__c : '';
                    if (antecipacaoTipo == prop.Tipo__c) {
                        for (RemuneracaoProposta__c rem : remProp) {
                            if(rem.TipoRemuneracao__r.Name == 'CORRETAGEM' && (rem.Percentual__c <= ant.LimiteMaximo__c && rem.Percentual__c >= ant.LimiteMinimo__c)) {
                                fraseAntecipacao = true;
                            }else if(rem.TipoRemuneracao__r.Name == 'AGENCIAMENTO' && rem.Percentual__c > 0){
                                return false;
                            }
                        }
                    }
                }
            }

            return fraseAntecipacao;
        // } catch (Exception e) {
        //     throw new AuraHandledException(e.getMessage());
        // }
    }

    @AuraEnabled
    public static void atualizaFavorecidoProposta(String propostaId, Boolean antecipar){
        
        try {
            Quote prop = altFormPgtoDAO.getQuote(propostaId);
            String nameProp = prop.Name;
            List<RemuneracaoProposta__c> remProp = altFormPgtoDAO.getRemProp(nameProp);
            Set<Id> idRemuneracao = new Set<Id>();
            for(RemuneracaoProposta__c rem : remProp){
                if(rem.TipoRemuneracao__r.Name == 'CORRETAGEM'){
                    idRemuneracao.add(rem.id);
                }
            }

            List<FavorecidoRemuneracaoProposta__c> favRemProp = altFormPgtoDAO.verificaFavRemuneracaoProd(idRemuneracao);
            List<FavorecidoRemuneracaoProposta__c> favRemPropUpdate = new List<FavorecidoRemuneracaoProposta__c>();

            for(FavorecidoRemuneracaoProposta__c fav : favRemProp){
                if(fav.AntecipacaoComissao__c != antecipar){
                    fav.AntecipacaoComissao__c = antecipar;
                    favRemPropUpdate.add(fav);
                }
            }

            if (!favRemPropUpdate.isEmpty()) {
                update favRemPropUpdate;
            }


        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

	//II-175 INICIO
    @AuraEnabled
    public static  Map<String, String> verificaCondicaoCobranca(String propostaId, String qtdParcelas, String newFormPag) {
        Map<String, String> resultado = new Map<String, String>();
        try {
            Boolean antecipaComissao = false;
            Boolean antecipaFavorecido = false;
            Quote prop = altFormPgtoDAO.getQuote(propostaId);
            String idProduto = prop.Produto__c;
            String nameProp = prop.Name;
            Decimal descontoAgravo;
            List<ContratanteProposta__c> contratanteProp = altFormPgtoDAO.consultarContrProp(propostaId);
            List<RemuneracaoProposta__c> remProp = altFormPgtoDAO.getRemProp(nameProp);
            List<CondicaoCobranca__c> condicaoCobranca = altFormPgtoDAO.consultarQtdeParcelas(idProduto);
            Set<Id> idRemuneracao = new Set<Id>();
            
            for(RemuneracaoProposta__c rem : remProp){
                if(rem.TipoRemuneracao__r.Name == 'CORRETAGEM'){
                    idRemuneracao.add(rem.id);
                }
            }
    
            List<FavorecidoRemuneracaoProposta__c> favRemProp = altFormPgtoDAO.verificaFavRemuneracaoProd(idRemuneracao);
            List<FavorecidoRemuneracaoProposta__c> favRemPropUpdate = new List<FavorecidoRemuneracaoProposta__c>();
    
            for(CondicaoCobranca__c cond : condicaoCobranca){
                if(cond.FormaPagamento__r.Codigo__c == newFormPag){
                    String quantidadeParcelas = cond.QuantidadeParcelas__c;
                    List<String> parcelasList = quantidadeParcelas.split(';');
                    system.debug('parcelasList ><' + parcelasList);
                    system.debug('descontoAgravo ><' + descontoAgravo);
                    system.debug('qtdParcelas ><' + qtdParcelas);
                    if(parcelasList.contains(qtdParcelas)){
                        system.debug('entrou if parcelas ><');
                        descontoAgravo = cond.PercentualDescontoAgravo__c;
                        if(cond.AntecipacaoComissao__c){
                            system.debug('entrou if antecipa true ><');
                            antecipaComissao = true;
                        }
                    }
                    system.debug('descontoAgravo dps ><' + descontoAgravo);
                    //descontoAgravo = cond.PercentualDescontoAgravo__c;
                }
            }

            for(FavorecidoRemuneracaoProposta__c fav : favRemProp){
                antecipaFavorecido = fav.AntecipacaoComissao__c;
            }
    
            resultado.put('antecipaComissao', String.valueOf(antecipaComissao));
            resultado.put('descontoAgravo', String.valueOf(descontoAgravo));
            resultado.put('antecipaFavorecido', String.valueOf(antecipaFavorecido));

            return resultado;
        } catch (Exception e) {
            throw new AuraHandledException('Ocorreu um erro ao verificar a condição de cobrança: ' + e.getMessage());
        }
    }
    //II-175 FIM
    //II-176 - FIM

    //II-206 INICIO
    @AuraEnabled
    public static void atualizaResponsavelFinanceiro(String propostaId, String responsavelFinJSON) {

        List<ContratanteProposta__c> contratanteProp = altFormPgtoDAO.consultarContrProp(propostaId);
        //II-206 FIX01 INICIO
        GrupoProposta__c grupo = altFormPgtoDAO.getGrupoProposta(contratanteProp[0].Id);
        SeguradoProposta__c segurado = altFormPgtoDAO.getSeguradoProposta(grupo.Id);
        if(String.isBlank(responsavelFinJSON)){
            if(contratanteProp[0].ResponsavelPagamento__c != contratanteProp[0].Conta__c){
                contratanteProp[0].ResponsavelPagamento__c = contratanteProp[0].Conta__c;
                segurado.VinculoComSegurado__c = '';
                update contratanteProp;
                update segurado;
            } //II-206 FIX01 FIM 
        }else{
            RecalculoPropostaTO.ResponsavelFinWrapper responsavelFin = (RecalculoPropostaTO.ResponsavelFinWrapper) JSON.deserialize(responsavelFinJSON, RecalculoPropostaTO.ResponsavelFinWrapper.class);
            List<Account> contaRespFin = altFormPgtoDAO.getAccountByCPF(responsavelFin.cpfResponsavel);
            String nomeCompleto = responsavelFin.responsavel;
            String[] partesNome = nomeCompleto.split(' ');

            String firstName = partesNome[0]; 
            String lastName = partesNome[partesNome.size() - 1];
            Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PessoaFisica' LIMIT 1].Id;
            if(!contratanteProp.isEmpty()){
                if(contratanteProp[0].ResponsavelPagamento__r.Cpf__c == responsavelFin.cpfResponsavel && !contaRespFin.isEmpty()){
                    Account contaResponsavelFinanceiro = contaRespFin[0];
                    if(compararResponsavelFin(contaResponsavelFinanceiro, responsavelFin, contratanteProp)){
                        contaResponsavelFinanceiro.PersonMobilePhone = responsavelFin.telefone1;
                        contaResponsavelFinanceiro.PersonHomePhone = responsavelFin.telefone2;
                        contaResponsavelFinanceiro.PersonEmail = responsavelFin.email;
                        contaResponsavelFinanceiro.EstadoCivil__c = responsavelFin.estadoCivil;
                        contratanteProp[0].ResponsavelPagamento__c = contaResponsavelFinanceiro.Id;
                        update contaResponsavelFinanceiro;
                        update contratanteProp;
                    }
                    //II-206 FIX01 INICIO
                    segurado.VinculoComSegurado__c = responsavelFin.vinculoSegurado;
                    update segurado;
                    //II-206 FIX01 FIM
                    inserirEndereco(contaResponsavelFinanceiro.Id, responsavelFinJSON);
                }else if(!contaRespFin.isEmpty()){
                    Account contaResponsavelFinanceiro = contaRespFin[0];
                    if(compararResponsavelFin(contaResponsavelFinanceiro, responsavelFin, contratanteProp)){
                        contaResponsavelFinanceiro.PersonMobilePhone = responsavelFin.telefone1;
                        contaResponsavelFinanceiro.PersonHomePhone = responsavelFin.telefone2;
                        contaResponsavelFinanceiro.PersonEmail = responsavelFin.email;
                        contaResponsavelFinanceiro.EstadoCivil__c = responsavelFin.estadoCivil;
                        update contaResponsavelFinanceiro;
                    }
                    //II-206 FIX01 INICIO
                    segurado.VinculoComSegurado__c = responsavelFin.vinculoSegurado;
                    update segurado;
                    //II-206 FIX01 FIM
                    contratanteProp[0].ResponsavelPagamento__c = contaResponsavelFinanceiro.Id;
                    update contratanteProp;
                    inserirEndereco(contaResponsavelFinanceiro.Id, responsavelFinJSON);
                }else if(contaRespFin.isEmpty()){
                    Account newAccount = new Account(
                        FirstName = firstName,
                        LastName = lastName,
                        Cpf__c = responsavelFin.cpfResponsavel,
                        PersonMobilePhone = responsavelFin.telefone1,
                        PersonHomePhone = responsavelFin.telefone2,
                        RecordTypeId = recordTypeId,
                        PersonEmail = responsavelFin.email,
                        Sexo__c = responsavelFin.sexo,
                        EstadoCivil__c = responsavelFin.estadoCivil,
                        PersonBirthdate = responsavelFin.nascimento
                    );
                    insert newAccount;
                    contratanteProp[0].ResponsavelPagamento__c = newAccount.Id;
                    //II-206 FIX01 INICIO
                    segurado.VinculoComSegurado__c = responsavelFin.vinculoSegurado;
                    update segurado;
                    //II-206 FIX01 FIM
                    update contratanteProp;
                    inserirEndereco(newAccount.Id, responsavelFinJSON);
                }
            }
        }
    }

    public static Boolean compararResponsavelFin(Account contaResponsavelFinanceiro, RecalculoPropostaTO.ResponsavelFinWrapper responsavelFin, List<ContratanteProposta__c> contratanteProposta) {
        Boolean atualizar = false;

        if (contaResponsavelFinanceiro.PersonMobilePhone != responsavelFin.telefone1) {
            atualizar = true;
        }
        if (contaResponsavelFinanceiro.PersonHomePhone != responsavelFin.telefone2) {
            atualizar = true;
        }
        if (contaResponsavelFinanceiro.PersonEmail != responsavelFin.email) {
            atualizar = true;
        }
        if (contaResponsavelFinanceiro.EstadoCivil__c != responsavelFin.estadoCivil) {
            atualizar = true;
        }
        if (contratanteProposta[0].ResponsavelPagamento__c != contaResponsavelFinanceiro.Id) {
            atualizar = true;
        }
        
        return atualizar;
    }

    public static void inserirEndereco(Id accountId, String responsavelFinJSON) {
        RecalculoPropostaTO.ResponsavelFinWrapper responsavelFin = (RecalculoPropostaTO.ResponsavelFinWrapper) JSON.deserialize(responsavelFinJSON, RecalculoPropostaTO.ResponsavelFinWrapper.class);
        
        Endereco__c NewEndereco = new Endereco__c(
            TipoEndereco__c = responsavelFin.tipoEndereco,
            CEP__c = responsavelFin.cep,
            Numero__c = responsavelFin.numero,
            Cidade__c = responsavelFin.cidade,
            Conta__c = accountId,
            Logradouro__c = responsavelFin.logradouro,
            Complemento__c = responsavelFin.complemento,
            Bairro__c = responsavelFin.bairro,
            Estado__c = responsavelFin.estado,
            MaisAtual__c = true
        );
        insert NewEndereco;
    }

    @AuraEnabled
    public static void atualizaCartao(String numero, String nome, String vencimento, String codigo, String propostaId, String produtoId, String melDtPgto, String qtdParcelas, String premioTotalNovo, String idCartao){ //ANNVI-91 INICIO/FIM //FNPVVEP-146 INICIO/FIM
        
        List<ContratanteProposta__c> contratanteProp = altFormPgtoDAO.consultarContrProp(propostaId);
        Boolean cartaoPorto = false;
        if(codigo == '98' || codigo == '97'){
            cartaoPorto = true;
        }
        if(!contratanteProp.isEmpty()){
            String conta = contratanteProp[0].ResponsavelPagamento__c;
            String idExterno = conta + numero;

            List<CartaoCredito__c> existingCard = altFormPgtoDAO.getCartao(conta, idExterno);

            CartaoCredito__c newCardCred;
            if(existingCard.isEmpty()){
                if(!Test.isRunningTest()){
                    newCardCred = new CartaoCredito__c(
                    Conta__c = conta,
                    NumeroCartao__c = numero,
                    NomeTitular__c = nome,
                    Vencimento__c = vencimento,
                    CartoPortoSeguro__c = cartaoPorto,
                    Ticket__c = idCartao //FNPVVEP-146 INICIO/FIM
                    );
                    insert newCardCred;
                }else{
                    String ticket = 'adb4df68-f1af-4036-b724-7dd3bd8be6b9';
                    newCardCred = new CartaoCredito__c(
                    Conta__c = conta,
                    NumeroCartao__c = numero,
                    NomeTitular__c = nome,
                    Vencimento__c = vencimento,
                    CartoPortoSeguro__c = cartaoPorto,
                    Ticket__c = ticket
                    );
                }
            }else{
                newCardCred = existingCard[0];
            }

            contratanteProp[0].CartaoCredito__c = newCardCred.id;
            contratanteProp[0].InformacaoBancaria__c = null;
            update contratanteProp;
            atualizaContratante(produtoId, codigo, propostaId, melDtPgto, qtdParcelas, premioTotalNovo); //ANNVI-91 INICIO/FIM FIX-01
        }
    }

    @AuraEnabled
    public static void atualizaADC(String banco, String agencia, String contaCorrente, String digito, String codigo, String cpf1, String propostaId, String produtoId, String melDtPgto, String qtdParcelas, String premioTotalNovo){ //ANNVI-91 INICIO/FIM
        List<ContratanteProposta__c> contratanteProp = altFormPgtoDAO.consultarContrProp(propostaId);
        if(!contratanteProp.isEmpty()){
            String conta = contratanteProp[0].ResponsavelPagamento__c;

            List<InformacaoBancaria__c > existingADC = altFormPgtoDAO.getADC(conta, contaCorrente);
            List<Banco__c > bancos = altFormPgtoDAO.getBanco(banco);

            InformacaoBancaria__c newADC;
            if(existingADC.isEmpty()){
                newADC = new InformacaoBancaria__c(
                    Conta__c = conta,
                    NumeroConta__c = contaCorrente,
                    BancoNew__c = bancos[0].id,
                    Agencia__c = agencia,
                    TipoPessoa__c = cpf1 != '' ? 'fisica' : '',
                    Digito__c = digito
                    
                );
                insert newADC;
            }else{
                newADC = existingADC[0];
            }

            contratanteProp[0].informacaoBancaria__c = newADC.id;
            contratanteProp[0].CartaoCredito__c = null;
            update contratanteProp;
            atualizaContratante(produtoId, codigo, propostaId, melDtPgto, qtdParcelas, premioTotalNovo); //ANNVI-91 INICIO/FIM FIX-01
        }
    }

    @AuraEnabled
    public static void atualizaBoleto(String codigo, String propostaId, String produtoId, String melDtPgto, String qtdParcelas, String premioTotalNovo){ //ANNVI-91 INICIO/FIM
        System.debug('melDtPgto' + melDtPgto);
        System.debug('qtdParcelas' + qtdParcelas);

        List<ContratanteProposta__c> contratanteProp = altFormPgtoDAO.consultarContrProp(propostaId);
        if(!contratanteProp.isEmpty()){
            contratanteProp[0].informacaoBancaria__c = null;
            contratanteProp[0].CartaoCredito__c = null;
            update contratanteProp;
            atualizaContratante(produtoId, codigo, propostaId, melDtPgto, qtdParcelas, premioTotalNovo); //ANNVI-91 INICIO/FIM FIX-01
        }
    }

    public static void atualizaContratante(String produtoId, String codigo, String propostaId, String melDtPgto, String qtdParcelas, String premioTotalNovo) { //ANNVI-91 INICIO/FIM FIX-01
        System.debug('melDtPgto' + melDtPgto);
        System.debug('qtdParcelas' + qtdParcelas);

        Id newFormPag;
        List<CondicaoCobranca__c> condicaoCobranca = altFormPgtoDAO.consultarQtdeParcelas(produtoId);
        List<ContratanteProposta__c> contratanteProp = altFormPgtoDAO.consultarContrProp(propostaId);
        if(!condicaoCobranca.isEmpty()){
            for(CondicaoCobranca__c cond : condicaoCobranca){
                if(cond.FormaPagamento__r.Codigo__c == codigo){
                    newFormPag = cond.FormaPagamento__r.Id;
                    break;
                }
            }
        }
        Integer qtdParcelasInt = Integer.valueOf(qtdParcelas);
        PlanoParcelamento__c planoParc = altFormPgtoDAO.getPlanoParcelamento(qtdParcelasInt, newFormPag);
        
        //ANNVI-91 INICIO
        Decimal valorParcela;
        Decimal primeiraParcela;

        for (Integer totalParcelamento = 1; totalParcelamento <= qtdParcelasInt; totalParcelamento++) {
            valorParcela = (Decimal.valueOf(premioTotalNovo) / totalParcelamento).setScale(2,RoundingMode.FLOOR);
            primeiraParcela = Decimal.valueOf(premioTotalNovo) - ((totalParcelamento - 1) * valorParcela);    
        }
        //ANNVI-91 FIM

        if(!contratanteProp.isEmpty()){
            contratanteProp[0].FormaPagamento__c = newFormPag;
            contratanteProp[0].PlanoParcelamento__c = planoParc.id;
            contratanteProp[0].VencimentoDemaisParcelas__c = melDtPgto;
            contratanteProp[0].QuantidadeParcelas__c = qtdParcelasInt;
            //ANNVI-91 INICIO
            contratanteProp[0].Valor_DemaisParcelas__c = valorParcela;
            contratanteProp[0].Valor_PrimeiraParcela__c = primeiraParcela;
            //ANNVI-91 FIM
            update contratanteProp;
        }
    }

    @AuraEnabled
    public static String consultaBancos() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{"bancosConveniados":"true"}');
        RestContext.request = req;
    
        ConsultaBancoREST.Response result = ConsultaBancoREST.consultar();
        List<ConsultaBancoREST.ConsultaBancoTO> bancos = result.data.Bancos;
        String bancosString = JSON.serialize(bancos);

        return bancosString;
    }
    //II-206 FIM
    //II-206 FIX01 INICIO
    @AuraEnabled
    public static Map<String,String> dadosResponsavelFinanceiro(String propostaId){

        Map<String,String> mapDadosSegurado = new Map<String,String>();
        String isResponsavel = '';
        String semNumero = '';
        List<ContratanteProposta__c> lcttProp = altFormPgtoDAO.consultarContrProp(propostaId);
        if(!lcttProp.isEmpty()){
            ContratanteProposta__c contratante = lcttProp[0];
            List<Endereco__c> listEndereco = altFormPgtoDAO.consultaEndereco(contratante.ResponsavelPagamento__c);
            GrupoProposta__c grupo = altFormPgtoDAO.getGrupoProposta(contratante.Id);
            SeguradoProposta__c segurado = altFormPgtoDAO.getSeguradoProposta(grupo.Id);
            Endereco__c endereco;
            if (listEndereco.size() > 1) {
                for (Endereco__c address : listEndereco) {
                    if (address.TipoEndereco__c == 'Residencial') {
                        endereco = address;
                        break;
                    }
                }
            } else if (listEndereco.size() == 1) {
                endereco = listEndereco[0];
            }
            isResponsavel = (contratante.conta__c == contratante.ResponsavelPagamento__c) ? 'true' : 'false';
            semNumero = (endereco.Numero__c != '') ? 'Sim' : 'Não';

            contratante.ResponsavelPagamento__r.Sexo__c = (contratante.ResponsavelPagamento__r.Sexo__c == 'MASC') ? 'Masculino' : (contratante.ResponsavelPagamento__r.Sexo__c == 'FEM') ? 'Feminino' : '';

            mapDadosSegurado.put('isResponsavel', (isResponsavel != null) ? isResponsavel : '');
            mapDadosSegurado.put('nomeResponsavel', (contratante.ResponsavelPagamento__r.Name != null) ? contratante.ResponsavelPagamento__r.Name : '');
            mapDadosSegurado.put('cpfResponsavel', (contratante.ResponsavelPagamento__r.Cpf__c != null) ? contratante.ResponsavelPagamento__r.Cpf__c : '');
            mapDadosSegurado.put('vinculoResponsavel', (segurado.VinculoComSegurado__c != null) ? segurado.VinculoComSegurado__c : '');
            mapDadosSegurado.put('sexo', (contratante.ResponsavelPagamento__r.Sexo__c != null) ? contratante.ResponsavelPagamento__r.Sexo__c : '');
            mapDadosSegurado.put('nascimento', (contratante.ResponsavelPagamento__r.PersonBirthdate != null) ? String.valueOf(contratante.ResponsavelPagamento__r.PersonBirthdate) : '');
            mapDadosSegurado.put('estadoCivil', (contratante.ResponsavelPagamento__r.EstadoCivil__c != null) ? contratante.ResponsavelPagamento__r.EstadoCivil__c : '');
            mapDadosSegurado.put('email', (contratante.ResponsavelPagamento__r.PersonEmail != null) ? contratante.ResponsavelPagamento__r.PersonEmail : '');
            mapDadosSegurado.put('cep', (endereco.CEP__c != null) ? endereco.CEP__c : '');
            mapDadosSegurado.put('tipoEndereco', (endereco.TipoEndereco__c != null) ? endereco.TipoEndereco__c : '');
            mapDadosSegurado.put('logradouro', (endereco.Logradouro__c != null) ? endereco.Logradouro__c : '');
            mapDadosSegurado.put('bairro', (endereco.Bairro__c != null) ? endereco.Bairro__c : '');
            mapDadosSegurado.put('cidade', (endereco.Cidade__c != null) ? endereco.Cidade__c : '');
            mapDadosSegurado.put('estado', (endereco.Estado__c != null) ? endereco.Estado__c : '');
            mapDadosSegurado.put('complemento', (endereco.Complemento__c != null) ? endereco.Complemento__c : '');
            mapDadosSegurado.put('semNumero', (semNumero != null) ? semNumero : '');
            mapDadosSegurado.put('numero', (endereco.Numero__c != null) ? endereco.Numero__c : '');
            mapDadosSegurado.put('telefone', (contratante.ResponsavelPagamento__r.PersonMobilePhone != null) ? contratante.ResponsavelPagamento__r.PersonMobilePhone : '');
            mapDadosSegurado.put('telefone2', (contratante.ResponsavelPagamento__r.PersonHomePhone != null) ? contratante.ResponsavelPagamento__r.PersonHomePhone : '');
        }
        return mapDadosSegurado;
    }
    //II-206 FIX01 FIM
    //FNPVVEP-126 INICIO
    @AuraEnabled
    public static String decryptId(String propostaId) {
        List<Encryption_Key__mdt> metadadoKey = [SELECT
            Key__c
        FROM
            Encryption_Key__mdt
        WHERE Name__c = 'Key Recalculo'];
        
        Blob key = EncodingUtil.convertFromHex(metadadoKey[0].Key__c);
        Blob converted = EncodingUtil.convertFromHex(propostaId);
        System.debug('decryptId >' + propostaId);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES192', key, converted);
        return decryptedBlob.toString();
    }
    //FNPVVEP-126 FIM

    //FNPVVEP-146 INICIO
    @AuraEnabled
    public static String callTokenizacao(String cardJson, String recordId, String codigoEmpresa) {
        Map<String, Object> payload = createPayload(cardJson, recordId, codigoEmpresa);
        String payloadJson = JSON.serialize(payload);

        RestResponse restResponse = RestContext.response;
        API_Link_de_Pagamento__mdt metadados = MetadataDAO.getInstance().apiLinkDePgto('Token_Cartao');
        APTlmkGeraLinkPgtoCartaoCreditoService service = new APTlmkGeraLinkPgtoCartaoCreditoService();
  
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HttpResponse tokenResponse = service.getToken(metadados);

        if(tokenResponse.getStatusCode() != 200){                
            restResponse.statusCode = tokenResponse.getStatusCode(); 
			return tokenResponse.getBody(); 
        }      

        TokenApiLinkPgtoCartaoCredito tokenApiLinkPgtoCartaoCredito = new TokenApiLinkPgtoCartaoCredito(tokenResponse.getBody());
		HttpResponse urlResponse = new HttpResponse();
        urlResponse = service.getLinkPgtoCartaoCredito(payloadJson, metadados, tokenApiLinkPgtoCartaoCredito);
        return urlResponse.getBody();
    }

    public static Map<String, Object> createPayload(String cardJson, String recordId, String codigoEmpresa) {
 
        Map<String, Object> cardData = (Map<String, Object>) JSON.deserializeUntyped(cardJson);
        ContratanteProposta__c contratante = AltFormPgtoDAO.getContratante(recordId);
        Map<String, Object> payload = new Map<String, Object>();
        

        String numeroCartao = ((String) cardData.get('numero')).replaceAll('\\s+', '');
        Map<String, Object> dataVencimento = (Map<String, Object>) cardData.get('dataVencimento');
        String mesVencimento = (String) dataVencimento.get('mes');
        String anoVencimento = (String) dataVencimento.get('ano');
        

        payload.put('numero', numeroCartao);
        payload.put('dataVencimento', new Map<String, Object>{
            'mes' => mesVencimento,
            'ano' => anoVencimento
        });
    
        Map<String, Object> cliente = new Map<String, Object>();
        cliente.put('documento', new Map<String, Object>{
            'tipo' => 'cpf', 
            'numero' => contratante.ResponsavelPagamento__r.Cpf__c
        });
        cliente.put('primeiroNome', contratante.ResponsavelPagamento__r.FirstName);
        cliente.put('ultimoNome', contratante.ResponsavelPagamento__r.LastName);
        payload.put('cliente', cliente);
    
        payload.put('preferencial', true); 
        payload.put('codigoVerificacao', '000'); 
        payload.put('salvarCartao', true); 
    

        payload.put('codProduto', codigoEmpresa == '14' 
            ? '8b4da283-389d-47d5-83f0-fd8fc6d02708' 
            : '32'); 

        Quote quote = AltFormPgtoDAO.getQuoteById(recordId);
        String idExterno = quote.Name.replace('-', ''); 
        payload.put('idExterno', idExterno);

        return payload;
    }
    //FNPVVEP-146 FIM

}

//II-166 - FIM