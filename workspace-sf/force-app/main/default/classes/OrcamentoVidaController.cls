/*INICIO | PLV-4301-4302-Vida 

*  @author Squad Avanxo 
*  @Descrição: Pagina de orcamentoVidaPage
*/
public class OrcamentoVidaController {

    //Id da pagina
   public Id oppId                                          {get; set;}

    //Opportunity
    public Opportunity opp                                  {get; set;}
    public Decimal totalGarantia                            {get; set;}      
    public String periodoViagem                             {get; set;}

     //Garantia
   public List<GarantiaOrcamento__c> lstGarantia            {get; set;}
   public Boolean doencasGraves                            {get; set;}
   public Boolean incapacidadeTemporaria                   {get; set;} 
   
   //PLV-4677 INICIO 
   public String nomeSegurado {get; set;} 
   public String nomeSocialSegurado {get; set;} //LECVPV 189-FIX02 - INICIO/FIM
   public Boolean hasSocialName {get; set;} //HOTFIX - LECVPV 189
   public Date dataNascimento {get; set;}
   public String fumante {get; set;}
   public String sexo {get; set;}
   public String dependentes {get; set;}
   public String ocupacaoTrabalho {get; set;}
   public String formaTrabalho {get; set;}
   public String faixaRenda  {get; set;}    
   
   public String premioTotal  {get; set;}    
   public String premioLiquido  {get; set;}    
   public String premioMensal  {get; set;}    
   public String premioIOF  {get; set;}
   public Datetime dataOrcamento {get; set;}    //ANNVI-119 - INICIO/FIM
   public static Boolean isPeriodoAcelera {get; set;} //ANNVI-218 - INICIO/FIM

   public List<Garantia> garantias  {get; set;}
   //PLV-4677 FIM

  //PLV-5118 - INICIO
  public String  cicloVacinal             { get; set; }
  //public Date ultimaVacinaCicloVacinal    { get; set; }
  public Boolean hasVaccination           { get; set; }
  //public Boolean hasVaccinationDate       { get; set; }    
  //PLV-5118 - FIM

  public Boolean completeVaccinationCycle {get;set;} //PLV-5145 - INICIO/FIM  
  
  //PLV-5070 INICIO
  public Boolean mensagemFranquiaNormal {get; set;} 
  public Boolean mensagemFranquiaReduzida {get; set;} 
  public Boolean diagnosticoCancer {get; set;}
  public String  codigoComissao {get; set;}
  //PLV-5070 FIM

  private SeguradoOrcamento__c segurado {get; set;} // PLV-5139 - FIX01 - INICIO/FIM

  // TKCL-461 - INICIO
  public Boolean isCodigoPrecificacaoAPTLMKT                                      {get; set;}
  // TKCL-461 - FIM

  //II-65 INICIO
  public Map<String, Map<String, String>> jsonData { get; set; }
  public List<String> paymentMethods { get; set; }
  public List<Integer> months { get; set; } // II-134 - INICIO/FIM
  public String  numeroOrc {get; set;}
  //II-65 FIM

   public OrcamentoVidaController(){    
       //PLV-4677 INICIO
      //PLV-5118 - INICIO
      //II-65 INICIO
       String oppNum = ApexPages.currentPage().getParameters().get('numeroOrcamento'); 
       //II-65 FIM
       this.numeroOrc = String.valueOf(oppNum);
       this.nomeSegurado = ApexPages.currentPage().getParameters().get('nomeSeguradoPDF').toUppercase();
       this.nomeSocialSegurado = ApexPages.currentPage().getParameters().get('nomeSocialSeguradoPDF').toUppercase();//LECVPV 189-FIX02 - INICIO/FIM
       this.hasSocialName = String.isEmpty(nomeSocialSegurado) ? false : true; //HOTFIX - LECVPV 189
       this.dataNascimento = date.valueOf(ApexPages.currentPage().getParameters().get('nascimentoSeguradoPDF'));
       this.fumante = ApexPages.currentPage().getParameters().get('fumanteSeguradoPDF').toUppercase();
       this.sexo = ApexPages.currentPage().getParameters().get('sexoSeguradoPDF').toUppercase();
       this.dependentes = ApexPages.currentPage().getParameters().get('dependenteSeguradoPDF')== 'true' ? 'SIM' : 'NAO';
       this.ocupacaoTrabalho = buscaProfissao(ApexPages.currentPage().getParameters().get('ocupacaoSeguradoPDF'));   
       this.formaTrabalho = ApexPages.currentPage().getParameters().get('formaTrabalhoSeguradoPDF').toUppercase();
       //PLV-5118 - FIM
       this.garantias = new List<Garantia>();
       //PLV-4677 FIM      
       this.oppId = buscaIdOpp(oppNum);
      //PLV-5118 - INICIO
      this.hasVaccination = true;
      //this.hasVaccinationDate = true;  
      //PLV-5118 - FIM

      this.completeVaccinationCycle = false; //PLV-5145 - INICIO/FIM

      // TKCL-461 - INICIO
      this.isCodigoPrecificacaoAPTLMKT = false; 
      // TKCL-461 - FIM
       
       //validação token
       if(this.oppId == null){
           String token = ApexPages.currentPage().getParameters().get('token');
           token = token.replace(' ','+');

           CryptoToken c = new CryptoToken();                     
           
           String chaveDescript = c.decrypt(token);  
           String[] trataChave = chaveDescript.split('\\|');
           this.oppId = Id.valueof(trataChave[0]);               
        }  

        this.opp = buscarOpp(this.oppId);

        //ANNVI-119 - INICIO
        dataOrcamento = ajustarHora(this.opp);
        //ANNVI-119 - FIM
        //ANNVI-218 - INICIO
        periodoAcelera();
        //ANNVI-218 - FIM


        boolean isIndividual = (opp != null && opp.Produto__c != null && opp.Produto__r.Segmento__c == 'Individual');   
        // TKCL-461 - INICIO
        this.verificaCodigoPrecificacaoAPTLMKT(this.oppId);
        // TKCL-461 - FIM
        if(!isIndividual)
       { 
           CalloutException e = new CalloutException();
           e.setMessage('O orçamento ' + oppNum + ' não é um orcamento do segmento Individual');
           throw e; 
       }

        this.segurado = getSegurado(this.opp.id); //PLV-5139 - FIX01 - INICIO/FIM

        this.lstGarantia = garantia(oppId);          
        this.periodoViagem = opp.VigenciaInicial__c != null && opp.DataVencimento__c !=null  ?  String.ValueOf(((this.opp.VigenciaInicial__c).daysBetween(this.opp.DataVencimento__c)+1)) +' dia(s)':'';                     
        this.codigoComissao = comissaoCorretagemCodigo(oppId); //PLV-5070 INICIO/FIM
        //Soma total garantias
        this.totalGarantia = 0;

        for (GarantiaOrcamento__c gar : this.lstGarantia){
            //Soma total garantias
            if(gar.PremioTotal__c != null)
            {
               gar.PremioTotal__c = (gar.PremioTotal__c/12).setScale(2); //PLV-5070 INICIO FIM
               this.totalGarantia = this.totalGarantia + gar.PremioTotal__c;
            }
     
            //PLV-5162 - INICIO - Ajuste temporário - Adicionar 'Plus' para cobertura IPA
            if(gar.Garantia__r.Name.toLowerCase().contains('invalidez permanente total ou parcial')){
                gar.Garantia__r.Name += ' Plus';
            }
            //PLV-5162 - FIM
            //PLV-5139 - FIX01 - INICIO
            else if (gar.Garantia__r.Sigla__c == 'DIH' || gar.Garantia__r.Sigla__c == 'DIA'){    
                List<GarantiaSeguradoOrcamento__c>  garantiasSegurado = this.segurado.GarantiasSeguradoOrcamento__r;
                System.debug('HENRIQUE GARANTIA ' +garantiasSegurado );
                Integer dias = (Integer)( garantiasSegurado.size() > 0 ? garantiasSegurado[0].Limite_de_Uso__c : null) ;
                gar.Garantia__r.Name += ( 
                            dias == null  
                                ? ''
                                : ' (' + dias.format() + ' dia' + (dias == 1 ? '': 's') +  ')' 
                            );
            }
            //PLV-5139 - FIX01 - FIM
            
            //Validação texto Observação
            if(gar.Garantia__r.Name.contains('Doenças Graves')){
               this.doencasGraves = true;
            }

            //PLV-5070 INICIO
            if(gar.Garantia__r.Name.contains('Diagnóstico de Câncer')){
                this.diagnosticoCancer = true;
            }
            //PLV-5070 FIM

            //Validação texto Observação
            if(gar.Garantia__r.Name.contains('Incapacidade Temporária')){
               this.incapacidadeTemporaria = true;
                //PLV-5070 INICIO
                if(gar.FranquiaGarantia__c != null){
                    this.mensagemFranquiaNormal = gar.FranquiaGarantia__r.CodigoFranquia__c.toUppercase() == 'FR_NORMAL' ? true : false;
                    this.mensagemFranquiaReduzida = gar.FranquiaGarantia__r.CodigoFranquia__c.toUppercase() == 'FR_REDUZIDA' ? true : false;
                }
                //PLV-5070 FIM
            }

            this.garantias.add(new Garantia(gar)); //PLV-4677 INICIO/FIM
        }
        //PLV-4677 INICIO
        if(opp.PremioTotal__c != null){             
           this.opp.PremioTotal__c = this.opp.PremioTotal__c.setScale(2); 
        } else {
            Decimal premioTotalNulo = 0;
            this.opp.PremioTotal__c = premioTotalNulo.setScale(2);
        }

        this.faixaRenda = getSegurado(this.opp.id).FaixaRenda__c;

        //PLV-5224 - INICIO 
        //PLV-5224 - FIX01 - INICIO 
        /*String ppremioTotal =  ApexPages.currentPage().getParameters().get('inputPremioTotalPDF');
        String ppremioMensal =  ApexPages.currentPage().getParameters().get('inputPremioMensalPDF');      
        System.debug('>>>ppremioTotal ' + ppremioTotal);
        System.debug('>>>ppremioMensal ' + ppremioMensal);
        if (ppremioTotal == '0' || ppremioTotal == '' || ppremioTotal == null) {
            this.premioTotal = OrcamentoVidaController.convertBRValue(opp.PremioTotal__c);
        } 
        else {
            this.premioTotal = OrcamentoVidaController.convertBRValue(Decimal.valueOf(ppremioTotal));
        }
        if (ppremioMensal == '0' || ppremioMensal == '' || ppremioMensal == null) {
            this.premioMensal = 'R$ ' + OrcamentoVidaController.convertBRValue(this.totalGarantia);//PLV-5070 INICIO/FIM
        }
        else {
            this.premioMensal = OrcamentoVidaController.convertBRValue(Decimal.valueOf(ppremioMensal));
        }*/

        this.premioTotal = OrcamentoVidaController.convertBRValue(opp.PremioTotal__c);
        this.premioMensal = 'R$ ' + OrcamentoVidaController.convertBRValue(this.totalGarantia);//PLV-5070 INICIO/FIM
        //PLV-5224 - FIX01 - FIM
        //PLV-5224 - FIM
        this.premioLiquido = 'R$ ' + OrcamentoVidaController.convertBRValue(opp.PremioComercial__c);
        this.premioIOF = 'R$ ' + OrcamentoVidaController.convertBRValue(opp.Iof__c);
        //PLV-4677 FIM

       //PLV-5118 - INICIO
       //this.ultimaVacinaCicloVacinal = getSegurado(this.opp.id).UltimaVacinaCicloVacinal__c != null ? getSegurado(this.opp.id).UltimaVacinaCicloVacinal__c : null; 
       this.cicloVacinal = getSegurado(this.opp.id).CicloVacinal__c; 
       if(this.cicloVacinal == 'Não iniciado') this.hasVaccination = false;                       
       //this.hasVaccinationDate = this.ultimaVacinaCicloVacinal != null ? true : false;  
       //PLV-5118 - FIM

       //PLV-5145 - INICIO
       if(hasVaccination == true && this.cicloVacinal == 'Completo'){
           this.completeVaccinationCycle = true;
        }  
        //PLV-5145 - FIM

        //II-65 INÍCIO
        String jsonString = ApexPages.currentPage().getParameters().get('formasPagamento'); 
        if(jsonString != null){
            jsonData = new Map<String, Map<String, String>>();
            Map<String, Object> parsedData = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Map<String, Object> cardData = (Map<String, Object>)parsedData.get(numeroOrc);
            paymentMethods = new List<String>(cardData.keySet());
            Set<Integer> monthsSet = new Set<Integer>();
            // for(Integer i = 1; i <= 12; i++){
            //     months.add(String.valueOf(i));
            // }
            // II-134 - INICIO - MarceloRatton
            for(String paymentMethod : paymentMethods){
                Object cardDataValue = (Object) (cardData.get(paymentMethod));
                Map<String, Object> untypedMap = (Map<String, Object>)cardDataValue;
                for(Integer i = 1; i <= 12; i++){
                    if (untypedMap.containsKey(String.valueOf(i))) {
                        monthsSet.add(i);
                    }
                }
            }
            months= new List<Integer>(monthsSet);
            months.sort();
            // II-134 FIM
            for(String paymentMethod : paymentMethods){
                Object cardDataValue = (Object) (cardData.get(paymentMethod));
                Map<String, Object> untypedMap = (Map<String, Object>)cardDataValue;
                
                // Initialize a new Map<String, String> to store the transformed values
                Map<String, String> resultMap = new Map<String, String>();
                // for (String key : untypedMap.keySet()) {
                // II-134 - INICIO
                for (Integer key : months) { 
                    String originalValue = (untypedMap.containsKey(String.valueOf(key)))? String.valueOf(untypedMap.get(String.valueOf(key))): '-'; 
                    resultMap.put(String.valueOf(key), originalValue);
                }
                // II-134 - FIM
                jsonData.put(paymentMethod, resultMap);
            }
        }
        //II-65 FIM
        //II-133 - INICIO
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=OrcamentoVidaPage.pdf');
        //II-133 - FIM
   } 

   //TKCL-461 - INICIO
   private void verificaCodigoPrecificacaoAPTLMKT(Id oppoId){
    Opportunity opportunity = null;
    try{
        opportunity = [
            SELECT 
                Id,
                Produto__r.CodigoPrecificaProduto__c,
                Produto__r.Segmento__c 
            FROM 
                Opportunity 
            WHERE Id = :oppoId
            LIMIT 1
        ];

    this.isCodigoPrecificacaoAPTLMKT = opportunity.Produto__r.CodigoPrecificaProduto__c.equals('APTLMKT') ? false : true;
    } catch(Exception e){
        
        }
    }
    //TKCL-461 - FIM
   
   private id buscaIdOpp (String numeroOpp) {
      
       if(string.isBlank(numeroOpp))
       {
           return null;
       }
       Opportunity opp =[SELECT ID, Numero__c from Opportunity where Numero__c =: numeroOpp];
       return opp.id;       
   }

   private Opportunity buscarOpp(Id oppId){   
    
       return [SELECT  Account.Name, Account.Sexo__c, Account.PersonBirthdate, 
                       Account.Fumante__c, FaixaRenda__c, Account.Profissao__r.Name, Dependentes__c,
                       Account.RegimeTrabalho__c, ContadorOrcamento__c, CreatedDate, PremioTotal__c,
                       CodigoCorretor__r.NomeCorretor__r.Name, CodigoCorretor__r.NomeCorretor__r.Email__c, 
                       CodigoCorretor__r.NomeCorretor__r.Phone, CodigoCorretor__r.NomeCorretor__r.SusepPrincipal__c,
                       Iof__c, Numero__c, PremioComercial__c, DataVencimento__c, VigenciaInicial__c, Produto__r.Segmento__c
                       ,Produto__c,//PLV-5070 INICIO/FIM

                    // RVI-42- INICIO
                       Produto__r.Empresa__r.Name, 
                       Produto__r.Empresa__r.Cnpj__c, 
                       Produto__r.NumeroSusep__c 
                    // RVI-42- FIM

                       FROM Opportunity WHERE Id =: oppId limit 1]; 
   }

   private List<GarantiaOrcamento__c> garantia (id oppId)    {
      
       //PLV-5070 INICIO
       return [ SELECT ID, Orcamento__c, Orcamento__r.NumeroOferta__c,Orcamento__r.Produto__c ,Garantia__r.Name,Garantia__r.Sigla__c, Capital__c, PremioTotal__c, GarantiaProduto__r.OrdemPrioridade__c,FranquiaGarantia__r.CodigoFranquia__c  FROM GarantiaOrcamento__c WHERE Orcamento__c =: oppId ORDER BY GarantiaProduto__r.OrdemPrioridade__c ASC];       
       //PLV-5070 FIM
    } 

   //PLV-4677 INICIO 
   private String buscaProfissao (String codigoOcupacao){
      
       if(codigoOcupacao == null || string.isBlank(codigoOcupacao))
       {
           return null;
       }
       
       Profissao__c prof;

       try { 
           prof = [SELECT  NomeFantasia__c 
           FROM Profissao__c 
           WHERE CodigoProfissao__c =: codigoOcupacao
           LIMIT 1];
           
       } catch (Exception e) {
           System.debug(e);
           return null;
       } 
       
       return prof.NomeFantasia__c.toUppercase();      
   }    


  //PLV-5118 - INICIO
   private SeguradoOrcamento__c getSegurado(Id oppId){
       SeguradoOrcamento__c segurado;
       try {
           //PLV-5139 - FIX01 - INICIO
           if (this.segurado <> null) {
               return this.segurado;
           }
           //PLV-5139 - FIX01 - FIM
           segurado = [
               SELECT ID, toLabel(FaixaRenda__c), toLabel(CicloVacinal__c) 
                , (SELECT id, Limite_de_Uso__c FROM GarantiasSeguradoOrcamento__r WHERE Tipo_de_limite_de_utilizacao__c IN ('Dias', 'Dia(s)') AND (Garantia__r.Sigla__c  = 'DIH' OR Garantia__r.Sigla__c  = 'DIA')) //PLV-5139 - FIX02 - INICIO/FIM //II-116 - INICIO/FIM
               FROM SeguradoOrcamento__c 
               WHERE GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c =: oppId
           ];
       } catch (Exception e) {
           System.debug(e);
       }

       return segurado;
   }
   //PLV-5118 - FIM

   public class Garantia{
       public String nome {get;set;}
       public String capital {get;set;}
       public String premio {get;set;}
       
       public Garantia(GarantiaOrcamento__c garantia){
           this.nome = garantia.Garantia__r.Name;
           this.capital = OrcamentoVidaController.convertBRValue(garantia.Capital__c);
           this.premio = OrcamentoVidaController.convertBRValue(garantia.PremioTotal__c);
       }
   }

   public static String convertBRValue(Decimal value){
       if(value == null || value == 0) return ' - ';
       value = value.setScale(2);
       String val = value.format();
       if(!val.contains(',')) val += ',00';
       else if((val.substring((val.length()-2),(val.length()))).contains(',')) val = val+'0';
       return val;
   }
   //PLV-4677 FIM 

    //PLV-5070 INICIO
    public static String comissaoCorretagemCodigo(Id oppId){
        String codigo;
        Map<String, String> mapRemuneracao = new Map<String, String>();
        List<RemuneracaoOrcamento__c> lstRemuneracao = [SELECT Id, Oportunidade__c, TipoRemuneracao__r.Name, Percentual__c 
                                                        FROM RemuneracaoOrcamento__c 
                                                        WHERE Oportunidade__c =:oppId];

        for(RemuneracaoOrcamento__c rem : lstRemuneracao){
            if(rem.TipoRemuneracao__r.Name == 'AGENCIAMENTO' && rem.Percentual__c == 0){
                mapRemuneracao.put(rem.TipoRemuneracao__r.Name, '000');
            }else if(rem.TipoRemuneracao__r.Name == 'CORRETAGEM' && rem.Percentual__c == 0){
                mapRemuneracao.put(rem.TipoRemuneracao__r.Name, '00');
            }else{
                mapRemuneracao.put(rem.TipoRemuneracao__r.Name,String.valueOf(rem.Percentual__c).replace('.00',''));
            }   
        }

        if(!mapRemuneracao.containsKey('AGENCIAMENTO')) mapRemuneracao.put('AGENCIAMENTO','000');

        system.debug('Map Remuneração '+ JSON.serialize(mapRemuneracao));
        
        return codigo = 'Código: '+ mapRemuneracao.get('CORRETAGEM')+'/'+ mapRemuneracao.get('AGENCIAMENTO');
    }
    //PLV-5070 FIM
    //ANNVI-119 - INICIO
    public static Datetime ajustarHora(Opportunity orcamento){
        
        Timezone tz = Timezone.getTimeZone('America/Sao_Paulo');
        Integer offSet = tz.getOffset(orcamento.CreatedDate);
        Datetime dataHora = System.now().addSeconds(offSet/1000);
        
       return dataHora;        
    }
    //ANNVI-119 - FIM
    //ANNVI-218 - INICIO
    public static void periodoAcelera() {
        Date today = Date.today();
        Date startDate = Date.newInstance(2024, 11, 04);
        Date endDate = Date.newInstance(2024, 11, 30);
        
        isPeriodoAcelera = today >= startDate && today <= endDate;
    }
    //ANNVI-218 - FIM
}

//FIM | PLV-4301-4302-Vida