//INICIO | PLV-4261-4262-VIAGEM 
/*
*  @author Squad Avanxo 
*  @Descrição: Controller OrcamentoPage
*/
public class OrcamentoController {

    //Id da pagina
    public Id oppId                                         { get; set; }    
    //custom label
	//public static String desconto = System.Label.DescontoPagamentoCartao; //PLV-4571 INICIO - FIM
    //header
    public String nomeSegurado                              {get; set;}
    public String origem                                    {get; set;}
    public String destino                                   {get; set;}
    public String numeroOrcamento                           {get; set;}
    public String moedaOrcamento                            {get; set;}
    public String moedaOrigem                               {get; set;} // VIAG-140 INICIO/FIM
    public String dataOrcamento                             {get; set;} 
    public String passageiroAte70                           {get; set;}  
    public String passageiroAte90                           {get; set;}  
    public String praticaAventura                           {get; set;} 
    public String duracaoViagem                             {get; set;}
    public String dataSaida                                 {get; set;}
    public String dataRetorno                               {get; set;}
    public String plano                                     {get; set;}
    // PLV-4829 INCIO
    public String premioTotal                               {get; set;}
    public String pagamentoCartao                           {get; set;}
    // PLV-4829 FIM
    // AV-662 INICIO    
    public String cupomDesconto                             {get; set;}
    // AV-662 FIM
    //Corretor
    public String nomeCorretora                             {get; set;}
    public String emailCorretora                            {get; set;}
    public String susep                                     {get; set;}
    public String telefoneCorretora                         {get; set;}
  
    //VIAG-VIAG-174 INICIO KAYMON
    public String parcelamento                              {get;set;}
    public List<ParcelamentoWrapper> lstParcelamentoW       {get;set;}
    public List<String> lstPorto                            {get;set;}
    public List<String> lstDemaisBandeira                   {get;set;}
    public Map<String, String> mapParcelamentoPorto         {get;set;}
    public Map<String, String> mapParcelamentoPorto_2       {get;set;}
    public Map<String, String> mapParcelamentoPorto_3       {get;set;}
    public Integer SizeOfMapParcelamentoPorto_2 { 
        get { return mapParcelamentoPorto_2.size(); } 
    } 
    public Integer SizeOfMapParcelamentoPorto_3 { 
        get { return mapParcelamentoPorto_3.size(); } 
    } 
    public Map<String, String> mapDemaisBandeira            {get;set;}
    public Map<String, String> mapDemaisBandeira_2          {get;set;}
    public Map<String, String> mapDemaisBandeira_3          {get;set;}
    public Integer SizeOfMapDemaisBandeira_2 { 
        get { return mapDemaisBandeira_2.size(); } 
    } 
    public Integer SizeOfMapDemaisBandeira_3 { 
        get { return mapDemaisBandeira_3.size(); } 
    }
    public Integer qtdParcelamentoPorto                     {get;set;}
    public Integer qtdParcelamentoDB                        {get;set;}
    //VIAG-VIAG-174 FIM KAYMON
    //VIAG-241 INICIO KAYMON
    public Map<String, String> siglaCoberturaMap            {get;set;}
    public String coberturas                                {get;set;}
    public List<CoberturaWrapper> lstCoberturaW             {get;set;}
    public List<String> orcamentoSet                        {get;set;}
    public Map<String, String> orcValorCabecalhoMap         {get;set;}
    public String OrcamentoSelecionado                      {get;set;}
    public Map<String, String> coberturaMapFinal            {get;set;}
    public List<OrcamentoClass.CoberturaNomeClass> coberturaNomeList {get;set;}
    public List<OrcamentoClass.CoberturaNomeClass> coberturaNomeComOferta {get;set;} //VIAG-310 INICIO/FIM KAYMON
    //public List<OrcamentoClass.CoberturaNomeClass> coberturaNomeList_2 {get;set;} //VIAG-253 INICIO/FIM KAYMON
    public Map<String, String> orcamentoMap                 {get;set;}
    public Map<String, List<String>> siglaOrcamentoMap      {get;set;}
    //VIAG-241 FIM KAYMON
    //VIAG-253 INICIO KAYMON
    public String moedaNome                                 {get;set;}
    //VIAG-253 FIM KAYMON

    //Garantia
    public List<GarantiaOrcamento__c> lstGarantia           {get; set;}
    public List<GarantiaOrcamento__c> lstGarantia2          {get; set;}
    public List<GarantiaOrcamento__c> lstGarantia3          {get; set;}  
    
    //PLV-4500 - INICIO
    public String nomeSeguradoPDF                           {get; set;}
    public String nomeSocialSeguradoPDF                     {get; set;} //LECVPV 189-FIX03 - INICIO/FIM
    public Boolean hasSocialName                            {get; set;} //HOTFIX - LECVPV 189
    public String origemSeguradoPDF                         {get; set;}
    public String valorCotacaoSeguradoPDF                   {get; set;}
    //PLV-4500 - FIM

    public String mensagemErro                              {get; set;} // PLV-4882 INICIO/FIM
    
    //AV-86 - INICIO
    public Boolean exibirDadosCorretor                      {get; set;}  
    public Boolean exibirPagamentoTotal                     {get; set;}
    public Boolean exibirPagamentoTotalVidaON               {get; set;}  
    public Boolean exibirPagamentoCartao                    {get; set;}  
    public Boolean exibirObservacaoPagamento                {get; set;}  
    //AV-86 - FINAL

       
    public OrcamentoController(){

        String oppNum = ApexPages.currentPage().getParameters().get('numeroOrcamento');
        this.oppId = buscaIdOpp(oppNum);

        //PLV-5412 INICIO
        //PLV-4050 - INICIO
        this.nomeSeguradoPDF = ApexPages.currentPage().getParameters().get('nomePDF');
        this.nomeSocialSeguradoPDF = ApexPages.currentPage().getParameters().get('nomeSocialPDF'); //LECVPV 189-FIX03 - INICIO/FIM
        this.hasSocialName = String.isEmpty(nomeSocialSeguradoPDF) ? false : true; //HOTFIX - LECVPV 189
        this.origemSeguradoPDF = ApexPages.currentPage().getParameters().get('origemPDF');
        this.valorCotacaoSeguradoPDF = ApexPages.currentPage().getParameters().get('cotacaoPDF');        
        //PLV-4050 - FIM  
        //PLV-5412 FIM 

        // VIAG-140 - INICIO
        this.moedaOrigem = ApexPages.currentPage().getParameters().get('moedaOrigem');        
        // VIAG-140 - FIM

        // PLV-4829 INCIO
        // PLV-4882 INCIO
        this.premioTotal = this.getPremioValue(new List<String>{'62'});
        this.pagamentoCartao = this.getPremioValue(new List<String>{'97'});
        // PLV-4882 FIM
        // PLV-4829 FIM

        //VIAG-VIAG-174 INICIO KAYMON
        System.debug('numeroOrcamento '+oppNum);
        try {
            if (ApexPages.currentPage().getParameters().get('parcelamentoPDF') != null) {
                this.parcelamento = ApexPages.currentPage().getParameters().get('parcelamentoPDF');
                
                lstParcelamentoW = (List<ParcelamentoWrapper>) ParcelamentoWrapper.parse(this.parcelamento);
    
                mapParcelamentoPorto    = new Map<String, String>();
                mapParcelamentoPorto_2  = new Map<String, String>();
                mapParcelamentoPorto_3  = new Map<String, String>();
                mapDemaisBandeira       = new Map<String, String>();
                mapDemaisBandeira_2     = new Map<String, String>(); 
                mapDemaisBandeira_3     = new Map<String, String>();
                this.qtdParcelamentoDB = 0;
                this.qtdParcelamentoPorto = 0;
                String valorPrimeiraParcela='';
                String valorDemaisParcelas='';

                for (ParcelamentoWrapper p : lstParcelamentoW) {
                    try {
                        valorDemaisParcelas = p.valorDemaisParcelas.replace('.', ',');                        
                    } catch (Exception e) {
                        System.debug('replace error: '+e.getStackTraceString() + ' '+e.getMessage());
                    }
                    try {
                        valorPrimeiraParcela = p.valorPrimeiraParcela.replace('.', ',');
                    } catch (Exception e) {
                        System.debug('replace error: '+e.getStackTraceString() + ' '+e.getMessage());
                    }
   
                    if (p.opcao==0) {
                        if (p.qtdParcelas == 1) {
                            mapDemaisBandeira.put(String.valueOf(p.qtdParcelas)+'x', valorPrimeiraParcela);
                        } else if (p.qtdParcelas > 1 && p.qtdParcelas <= 4) {
                            mapDemaisBandeira.put(String.valueOf(p.qtdParcelas)+'x', valorDemaisParcelas);
                        } else if (p.qtdParcelas >= 5 && p.qtdParcelas <= 8) {
                            mapDemaisBandeira_2.put(String.valueOf(p.qtdParcelas)+'x', valorDemaisParcelas);
                        } else if (p.qtdParcelas > 8) {
                            String parc = '';
                            if (p.qtdParcelas==9)
                                parc = '0'+p.qtdParcelas+'x';
                            else
                                parc = p.qtdParcelas+'x';
                            mapDemaisBandeira_3.put(parc, valorDemaisParcelas);
                        }
                        if (p.qtdParcelas > this.qtdParcelamentoDB) {
                            this.qtdParcelamentoDB = p.qtdParcelas;
                        }
                    } else if (p.opcao==1) {
                        if (p.qtdParcelas == 1) {
                            mapParcelamentoPorto.put(String.valueOf(p.qtdParcelas)+'x', valorPrimeiraParcela);
                        } else if (p.qtdParcelas > 1 && p.qtdParcelas <= 4) {
                            mapParcelamentoPorto.put(String.valueOf(p.qtdParcelas)+'x', valorDemaisParcelas);
                        } else if (p.qtdParcelas >= 5 && p.qtdParcelas <= 8) {
                            mapParcelamentoPorto_2.put(String.valueOf(p.qtdParcelas)+'x', valorDemaisParcelas);
                        } else if (p.qtdParcelas > 8) {
                            String parc = '';
                            if (p.qtdParcelas==9) {
                                parc = '0'+p.qtdParcelas+'x';
                            } else {
                                parc = p.qtdParcelas+'x';
                            }
                            mapParcelamentoPorto_3.put(parc, valorDemaisParcelas);
                        }
                        if (p.qtdParcelas > this.qtdParcelamentoPorto) {
                            this.qtdParcelamentoPorto = p.qtdParcelas;
                        }
                    }
                }
            }

        } catch (Exception e) {
            System.debug('error '+ e.getMessage()+ ' '+e.getStackTraceString());
        }
        //VIAG-VIAG-174 FIM KAYMON
        //VIAG-241 INICIO KAYMON
        try {
            this.coberturas = null;
            Map<String, List<String>> cobeturaMap = new Map<String, List<String>>();
            orcValorCabecalhoMap = new Map<String, String>();
            Set<String> planosSet = new Set<String>();
            siglaCoberturaMap = new Map<String, String>();
            siglaCoberturaMap = getCoberturas();
            coberturaNomeList = new List<OrcamentoClass.CoberturaNomeClass>();
            coberturaNomeComOferta = new List<OrcamentoClass.CoberturaNomeClass>();//VIAG-310 INICIO/FIM KAYMON
            // coberturaNomeList_2 = new List<OrcamentoClass.CoberturaNomeClass>();
            Set<String> cobSiglaSet = siglaCoberturaMap.keySet();
            List<String> coberturaSiglaList = new List<String>(cobSiglaSet);
            orcamentoSet = new List<String>();
            //coberturaSiglaList.sort(); //VIAG-253 INICIO/FIM KAYMON
            if (ApexPages.currentPage().getParameters().get('coberturasPDF') != null) {
                this.coberturas = ApexPages.currentPage().getParameters().get('coberturasPDF');
                lstCoberturaW = (List<CoberturaWrapper>) CoberturaWrapper.parse(this.coberturas);
                orcamentoMap = new Map<String, String>();
                Map<String, String> orcamentoValorMap = new Map<String, String>();
                coberturaMapFinal = new Map<String, String>();
                siglaOrcamentoMap = new Map<String, List<String>>();
                for (String s : coberturaSiglaList) {
                    String nome = siglaCoberturaMap.get(s);
                    OrcamentoClass.CoberturaNomeClass c = new OrcamentoClass.CoberturaNomeClass();
                    c.nome = nome;
                    c.sigla = s;
                    if (c.sigla=='DMHO') {
                        try {
                            coberturaNomeList.add(0, c);
                        } catch (Exception e) {
                            coberturaNomeList.add(c);
                        }
                    } else {
                        coberturaNomeList.add(c);
                        //VIAG-253 INICIO KAYMON - conforme combinado previamente, não haverá controle/tratamento sobre quantidade de registros
                        // if (coberturaNomeList.size() < 28 || (coberturaSiglaList.size() >= 28 && coberturaNomeList.size() < 48 )) {
                        //     coberturaNomeList.add(c);
                        // } else {
                        //     coberturaNomeList_2.add(c);
                        // }
                        //VIAG-253 FIM KAYMON
                    }
                }
                //VIAG-253-FIX_3 INICIO KAYMON
                List<String> orcamentoBySiglaList = new List<String>();
                for (CoberturaWrapper cw : lstCoberturaW) {
                    cw.selecionado = cw.orcamento == oppNum ? true : false;
                    orcamentoSet.add(cw.orcamento);
                }
                
                if (lstCoberturaW.size() > 1) {
                    for (Integer i = 0; i < lstCoberturaW.size(); i++) {
                        if (lstCoberturaW[i].selecionado) {
                            orcamentoSet.remove(i);
                            orcamentoSet.add(0, lstCoberturaW[i].orcamento);
                            break;
                        }
                    }
                }
                //VIAG-253-FIX_3 FIM KAYMON
                for (CoberturaWrapper cw : lstCoberturaW) { //VIAG-253 INICIO/FIM KAYMON
                    if (cw.selecionado) {
                        OrcamentoSelecionado = cw.orcamento;
                    }
                    
                    String valorPremioFormatado = getValorFormatado(cw.premioTotal); //VIAG-253 INICIO/FIM KAYMON
                    orcValorCabecalhoMap.put(cw.orcamento, cw.rotulo+' '+valorPremioFormatado);//VIAG-253 INICIO/FIM KAYMON
                    for (CoberturaWrapper.Coberturas c : cw.coberturas) {
                        orcamentoMap.put(c.sigla+cw.orcamento, cw.orcamento);
                        String valorFormatado = c.valor==null ? 'Sim' : c.moeda+ ' '+String.valueOf(c.valorFormatado);
                        orcamentoValorMap.put(c.sigla+cw.orcamento, valorFormatado);

                        if (siglaOrcamentoMap.containsKey(c.sigla)) {
                            orcamentoBySiglaList = siglaOrcamentoMap.get(c.sigla);
                            orcamentoBySiglaList.add(cw.orcamento);
                            siglaOrcamentoMap.put(c.sigla, orcamentoBySiglaList);
                        } else {
                            siglaOrcamentoMap.put(c.sigla, new List<String>{cw.orcamento});
                        }
                    }
                }

                // List<String> listOrc = new List<String>();
                Boolean coberturaTemOrcamento = false;
                for (OrcamentoClass.CoberturaNomeClass cn : coberturaNomeList) {
                    Integer index =coberturaNomeList.indexOf(cn);
                    List<String> listOrc = new List<String>();
                    coberturaTemOrcamento = false;
                    for (String orc : orcamentoSet) {
                        if (siglaOrcamentoMap.containsKey(cn.sigla)) {
                            listOrc = siglaOrcamentoMap.get(cn.sigla);
                            if (!listOrc.contains(orc)) {
                                listOrc.add(orc);
                            }
                            siglaOrcamentoMap.put(cn.sigla, listOrc);
                        } else {
                            siglaOrcamentoMap.put(cn.sigla, new List<String>{orc});
                        }
                        if(!orcamentoMap.containsKey(cn.sigla+orc)){
                            coberturaMapFinal.put(cn.sigla+orc, '-');
                        } else {
                            String valorFormatado = orcamentoValorMap.get(cn.sigla+orc) != null ? orcamentoValorMap.get(cn.sigla+orc) : '-';
                            coberturaMapFinal.put(cn.sigla+orc,valorFormatado);
                            //VIAG-310 INICIO KAYMON
                            if (valorFormatado != '-') {
                                coberturaTemOrcamento = true;
                            }
                        }
                    }

                    if (coberturaTemOrcamento == true) 
                        coberturaNomeComOferta.add(cn);
                    //VIAG-310 FIM KAYMON
                }

                // List<String> listOrc2 = new List<String>();
                // for (OrcamentoClass.CoberturaNomeClass cn : coberturaNomeList_2) {
                //     listOrc2 = new List<String>();
                //     for (String orc : orcamentoSet) {
                //         if (siglaOrcamentoMap.containsKey(cn.sigla)) {
                //             listOrc2 = siglaOrcamentoMap.get(cn.sigla);
                //             if (!listOrc2.contains(orc)) {
                //                 listOrc2.add(orc);
                //             }
                //             siglaOrcamentoMap.put(cn.sigla, listOrc2);
                //         } else {
                //             siglaOrcamentoMap.put(cn.sigla, new List<String>{orc});
                //         }
                //         if(!orcamentoMap.containsKey(cn.sigla+orc)){
                //             coberturaMapFinal.put(cn.sigla+orc, '-');
                //         } else {
                //             String valorFormatado = orcamentoValorMap.get(cn.sigla+orc) != null ? orcamentoValorMap.get(cn.sigla+orc) : '-';
                //             coberturaMapFinal.put(cn.sigla+orc,valorFormatado);
                //         } 
                //     }
                // }

                List<String> orcamentoCheckList = new List<String>();
                for (String checkOrc : orcamentoSet) {
                    for (String key : siglaOrcamentoMap.keySet()) {
                        if (!siglaOrcamentoMap.get(key).contains(checkOrc)) {
                            orcamentoCheckList = siglaOrcamentoMap.get(key);
                            orcamentoCheckList.add(checkOrc);
                            siglaOrcamentoMap.put(key, orcamentoCheckList);
                        }
                    }
                }
            } else {
                System.debug('Parametro coberturasPDF não econtrado');
            }
        } catch (Exception e) {
            System.debug('error '+ e.getMessage()+ ' '+e.getStackTraceString());
        }
        //VIAG-241 FIM KAYMON
        //validação token
        
        // PLV-4882 INICIO
        String token = ApexPages.currentPage().getParameters().get('token');
        if(this.oppId == null && token != null) {            
            token = token.replace(' ','+');

            CryptoToken c = new CryptoToken();                     
            
            String chaveDescript = c.decrypt(token);  
            String[] trataChave = chaveDescript.split('\\|');
            if(!trataChave.isEmpty()) this.oppId = Id.valueof(trataChave[0]);               
         }       

        Opportunity opp = buscarOpp(this.oppId); 
        //AV-86 - INICIO
        if(opp != null){
            Boolean isViagemVidaON = opp.Produto__r.ProductCode.toUpperCase().equals('VIAGEM-PRATA');
            this.exibirDadosCorretor = !isViagemVidaON;
            this.exibirPagamentoTotal = !isViagemVidaON;
            this.exibirPagamentoCartao = !isViagemVidaON;
            this.exibirObservacaoPagamento = !isViagemVidaON;

            if(isViagemVidaON) this.exibirPagamentoTotalVidaON = true;

            this.moedaNome = obterMoedaNome(opp.CurrencyIsoCode);//VIAG-253 KAYMON
        } 

        //AV-86 - FINAL
        
        // PLV-4882 INICIO
        this.mensagemErro = opp != null ? '' : 'Orçamento em elaboração. Por favor, tente novamente.' ;

        if(this.mensagemErro == ''){
            if(opp.Produto__c == null){
                this.mensagemErro = 'Orçamento em elaboração. Por favor, tente novamente.';
            }else if(opp.Produto__c != null && opp.Produto__r.Segmento__c.toLowerCase() != 'viagem'){
                this.mensagemErro = 'O orçamento ' + oppNum + ' não é um orçamento do segmento Viagem';
            }else{
                this.lstGarantia = garantia(oppId);
                //VIAG-215 INICIO
                if(opp.Segmento__c == 'Viagem'){
                    this.lstGarantia = ordenarGarantias(this.lstGarantia);
                }
                //VIAG-215 FIM
                insertTableDadosCobertura();
            }
        }
        // PLV-4882 FIM
    }
    //VIAG-253 INICIO KAYMON
    /*public boolean getIsSecondPage(){
        return this.coberturaNomeList_2.size() > 0;
    }*/
    //VIAG-253 FIM KAYMON
    //VIAG-241 INICIO KAYMON
    private Map<String, String> getCoberturas () {
        try {
            Map<String, String> siglaNomecoberturaMap = new Map<String, String>();
            //VIAG-310 INICIO KAYMON
            for (AggregateResult gp : [SELECT
                GarantiaProduto__r.Garantia__r.Sigla__c sig,
                GarantiaProduto__r.Garantia__r.status__c,
                GarantiaProduto__r.Garantia__r.name nam
                FROM
                OfertaGarantiaProduto__c
                WHERE
                Oferta__r.Produto__r.Segmento__c ='Viagem'
                AND Oferta__r.Produto__r.Status__c  = 'Ativo'
                AND GarantiaProduto__r.Garantia__r.status__c = 'Ativo'
                AND Oferta__r.Status__c = 'Ativo'
                GROUP BY
                GarantiaProduto__r.Garantia__r.Sigla__c,
                GarantiaProduto__r.Garantia__r.status__c,
                GarantiaProduto__r.Garantia__r.name
                ORDER BY
                GarantiaProduto__r.Garantia__r.name]) {
                    if(!siglaNomecoberturaMap.containsKey(gp.get('sig').toString())) siglaNomecoberturaMap.put(gp.get('sig').toString(), gp.get('nam').toString());  
            }
            //VIAG-310 FIM KAYMON
            return siglaNomecoberturaMap;
        } catch (Exception e) {
            System.debug('Erro ao obter coberturas '+e.getMessage() + ' - '+ e.getStackTraceString());
            return null;
        }
    }
    //VIAG-241 FIM KAYMON
    // PLV-4882 INICIO
    @testVisible
    private id buscaIdOpp (String numeroOpp) {
       
        if(string.isBlank(numeroOpp)) return null;

        List<Opportunity > lstOpp = [
            SELECT ID, Numero__c 
            FROM Opportunity 
            WHERE Numero__c =: numeroOpp 
            LIMIT 1
        ];

        if(!lstOpp.isEmpty()) return lstOpp[0].id;
        
        return null;        
    }
    //VIAG-253 INICIO KAYMON
    public String getValorFormatado(String valor) {
        try {
            String v = valor.split(' ')[1];
            System.debug('valor: '+v);
            String s = ( Decimal.valueOf(v==null||v.trim()==''?'0':v).setScale(2) + 0.001 ).format();
            String p = s.substring(0,s.length()-1);
            System.debug(p);
            return p;
        } catch (Exception e) {
            System.debug('Erro ao formatar valor \''+valor+': '+e.getStackTraceString()+ ' - '+e.getMessage());
            return '-';
        }
    }
    //VIAG-253 FIM KAYMON

    //VIAG-241 INICIO KAYMON
    public String obterMoedaNome(String siglaMoeda) {
        if (siglaMoeda==null) return null; 

        switch on siglaMoeda {
            when 'USD' {
                return 'Dólar';
            }
            when 'EUR' {
                return 'Euro';
            }
            when 'BRL' {
                return 'Real';
            }
            when else {
                System.debug('Moeda desconhecida: '+siglaMoeda);
                return '';
            }
        }
    }
    //VIAG-241 FIM KAYMON

	@testVisible
    private Opportunity buscarOpp(Id oppId) {         
        if(oppId == null)return null;

        Opportunity opp;
        try {
            opp = [
                SELECT
                    Account.Name,
                    Numero__c,
                    Produto__r.Segmento__c,
                    PremioTotal__c,
                    Produto__r.Name,
                    Produto__r.ProductCode, //AV-86 - INICIO/FINAL  
                    VigenciaInicial__c,
                    VigenciaFinal__c,
                    QuantidadeDias__c,
                    ViagemAventura__c,
                    QuantidadePassageiros070Anos__c,
                    VidasEntre7190Anos__c,
                    CreatedDate,
                    ContadorOrcamento__c, 
                    MoedaOrcamento__c, 
                    CurrencyIsoCode, 
                    CupomDesconto__c, // AV-662 - INICIO/FINAL
                    Origem__c, 
                    PaisesDestino__c, 
                    CodigoCorretor__r.NomeCorretor__r.Name,
                    CodigoCorretor__r.NomeCorretor__r.Email__c, 
                    CodigoCorretor__r.NomeCorretor__r.Phone,
                    CodigoCorretor__r.NomeCorretor__r.SusepPrincipal__c,
                    CodigoCorretor__r.Name, //PLV-5412 INICIO/FIM
                    Segmento__c //VIAG-215
                FROM Opportunity 
                WHERE Id =: oppId limit 1
            ];
        } catch (Exception e) {
            System.debug('Não foi encontrado o orçamento id ' + oppId);
            return null;
        }
        // PLV-4882 FIM
        // AV-662 INICIO
        if (opp.CupomDesconto__c != '') {
            List<Cupom__c> cupom = new List<Cupom__c>();
            cupom = [Select Id, Percentual__c from Cupom__c where Codigo__c =: opp.CupomDesconto__c Limit 1];
            if (cupom.size() >0 ) {
                cupomDesconto =  String.valueOf(cupom[0].Percentual__c) == null ? '' : String.valueOf(cupom[0].Percentual__c) + '%' ; // AV-662 INICIO/FIM
            } else {
                cupomDesconto = '';
            }
         
        } 

        // AV-662 FIM


        //PLV-4500 - INICIO
        nomeSegurado = (opp.Account.Name == null || opp.Account.Name == '') ? nomeSeguradoPDF : opp.Account.Name;        
        origem = (opp.Origem__c == null || opp.Origem__c == '') ? origemSeguradoPDF : opp.Origem__c;
        //PLV-4500 - FIM        
        destino = opp.PaisesDestino__c;
        numeroOrcamento = opp.ContadorOrcamento__c;
        //PLV-4500 - INICIO
        moedaOrcamento = (String.valueOf(opp.MoedaOrcamento__c) == null || String.valueOf(opp.MoedaOrcamento__c) == '') ? valorCotacaoSeguradoPDF : String.valueOf(opp.MoedaOrcamento__c);        
        //PLV-4500 - FIM        
        // VIAG-140 - INICIO
        if (moedaOrcamento != null || moedaOrcamento !='') {
          moedaOrigem  = (String.valueOf(moedaOrigem) == null || String.valueOf(moedaOrigem) == '') ? '' : trataValores(moedaOrcamento, moedaOrigem);         
         }
         //System.debug('moedaOrigem Nova>> '+  moedaOrigem + 'Valor :'+ moedaOrcamento );
       
         // VIAG-140 - FIM    

        dataOrcamento = opp.CreatedDate.day() + '/' + opp.CreatedDate.month() + '/' + opp.CreatedDate.year();
        passageiroAte70 = String.valueOf(opp.QuantidadePassageiros070Anos__c);
        passageiroAte90 = String.valueOf(opp.VidasEntre7190Anos__c);
        duracaoViagem = opp.QuantidadeDias__c > 1 ? String.valueOf(opp.QuantidadeDias__c) + ' dias' : String.valueOf(opp.QuantidadeDias__c) + ' dia'; //SVEP-61 FIX01 INICIO/FIM
        praticaAventura = opp.ViagemAventura__c ? 'Sim' : 'Não';        
        dataSaida = opp.VigenciaInicial__c == null ? '  ----   ' : opp.VigenciaInicial__c.day() + '/' + opp.VigenciaInicial__c.month() + '/' + opp.VigenciaInicial__c.year();
        dataRetorno = opp.VigenciaFinal__c == null ? '  ----   ' : opp.VigenciaFinal__c.day() + '/' + opp.VigenciaFinal__c.month() + '/' + opp.VigenciaFinal__c.year();
        plano = opp.Produto__r.Name;

       
        //PLV-4829 INCIO/FIM REMOÇÃO DE BLOCO DE CÓDIGO

        //CORRETORA
        nomeCorretora = opp.CodigoCorretor__r.NomeCorretor__r.Name ;
        emailCorretora =  opp.CodigoCorretor__r.NomeCorretor__r.Email__c;
        susep = opp.CodigoCorretor__r.NomeCorretor__r.SusepPrincipal__c == null ? opp.CodigoCorretor__r.Name : opp.CodigoCorretor__r.NomeCorretor__r.SusepPrincipal__c; //PLV-5412 INICIO/FIM
        //susep =   opp.CodigoCorretor__r.NomeCorretor__r.SusepPrincipal__c;
        telefoneCorretora =  opp.CodigoCorretor__r.NomeCorretor__r.Phone;
        return opp;
    }

    public List<GarantiaOrcamento__c> garantia (id oppId)    {
       
        return [ SELECT ID, Orcamento__c, Orcamento__r.NumeroOferta__c, Garantia__r.Sigla__c, Garantia__r.Name, Capital__c from GarantiaOrcamento__c where Orcamento__c =: oppId]; //VIAG-215     
    } 

    //VIAG-215 INÍCIO
    public void insertTableDadosCobertura() {
        this.lstGarantia2 = new List<GarantiaOrcamento__c>();
        this.lstGarantia3 = new List<GarantiaOrcamento__c>();
        GarantiaOrcamento__c GarantiaLinha = new GarantiaOrcamento__c();
    
        Integer numeroTotalGarantias = lstGarantia.size();
        Integer numeroDivisaoGarantia = numeroTotalGarantias / 2;
        Integer restoDivisao = Math.mod(numeroTotalGarantias, 2);
    
        for (GarantiaOrcamento__c a : this.lstGarantia) {
            if (a.Capital__c == null) {
                a.Capital__c = 0;
            }
    
            if (numeroDivisaoGarantia > 0 || (restoDivisao > 0 && numeroDivisaoGarantia == 0)) {
                lstGarantia2.add(a);
                numeroDivisaoGarantia--;
            } else {
                lstGarantia3.add(a);
            }
        }

        if (restoDivisao != 0) {
            lstGarantia3.add(GarantiaLinha);
        }

    }
    //VIAG-215 FIM     

    // PLV-4829 INCIO
    private String getPremioValue(List<String> lstLabels){
        for(String label : lstLabels) if(ApexPages.currentPage().getParameters().get(label) != null ) return ApexPages.currentPage().getParameters().get(label);

        return '-';
    }
    // PLV-4829 FIM

//VIAG-140 - INICIO - Ajuste nas moedas estrangeiras
public static String trataValores(string valor, string moeda){
   if (valor.contains('.')){ 
        decimal valorNovo = (decimal.valueOf(valor)).setscale(2,system.RoundingMode.DOWN);
        //  VIAG-253 - INICIO
        valor = valorNovo.toString().replace('.', ',');
        //  if(moeda == 'USD'){
        //         valor = 'US$ '+  valorNovo;
        //     }else If(moeda == 'EUR'){
        //         valor = '€ '+  valorNovo;
        //     }
       //  VIAG-253 - FIM
    }

       
    return valor;
}

//VIAG-215 INICIO
    private class MetadadoGarantias {
        String nomeCampo;
        List<String> ordemGarantias;

        MetadadoGarantias(String nomeCampo, List<String> ordemGarantias) {
            this.nomeCampo = nomeCampo;
            this.ordemGarantias = ordemGarantias;
        }
    }

    public static List<GarantiaOrcamento__c> ordenarGarantias(List<GarantiaOrcamento__c> listaGarantias) {
        // Obtém o valor do metadado Constantes
        MetadadoGarantias metadado = obterMetadado('Garantias_Principais');

        // Cria um mapa para armazenar a ordem das garantias principais
        Map<String, Integer> ordemGarantiasPrincipais = new Map<String, Integer>();
        for (Integer i = 0; i < metadado.ordemGarantias.size(); i++) {
            ordemGarantiasPrincipais.put(metadado.ordemGarantias[i], i);
        }

        // Ordena a lista usando sort() com uma classe de comparação
        listaGarantias.sort(new GarantiaComparator(ordemGarantiasPrincipais));

        return listaGarantias;
    }

    private static MetadadoGarantias obterMetadado(String nomeCampo) {
        // Consulta SOQL para obter o valor do metadado
        Constante__mdt metadata = [SELECT Valor__c FROM Constante__mdt WHERE Atributo__c = 'Garantia' AND DeveloperName = :nomeCampo LIMIT 1];

        // Processa os valores obtidos do metadado
        List<String> ordemGarantias = new List<String>();
        if (metadata != null && metadata.Valor__c != null) {
            ordemGarantias = metadata.Valor__c.split('\\|');
        }

        return new MetadadoGarantias(nomeCampo, ordemGarantias);
    }

    private class GarantiaComparator implements Comparator<GarantiaOrcamento__c> {
        Map<String, Integer> ordemGarantiasPrincipais;

        GarantiaComparator(Map<String, Integer> ordemGarantiasPrincipais) {
            this.ordemGarantiasPrincipais = ordemGarantiasPrincipais;
        }

        public Integer compare(GarantiaOrcamento__c a, GarantiaOrcamento__c b) {
            Integer ordemA = ordemGarantiasPrincipais.containsKey(a.Garantia__r.Sigla__c)
                ? ordemGarantiasPrincipais.get(a.Garantia__r.Sigla__c)
                : 1000000;
            Integer ordemB = ordemGarantiasPrincipais.containsKey(b.Garantia__r.Sigla__c)
                ? ordemGarantiasPrincipais.get(b.Garantia__r.Sigla__c)
                : 1000000;

            if (ordemA < ordemB) {
                return -1;
            } else if (ordemA > ordemB) {
                return 1;
            } else {
                // Se as ordens são iguais, ordena alfabeticamente
                return a.Garantia__r.Name.compareTo(b.Garantia__r.Name);
            }
        }
    }
//VIAG-215 FIM


// VIAG-140 - FIM - Ajuste nas moedas estrangeiras


    
}
//FIM | PLV-4261-4262-VIAGEM