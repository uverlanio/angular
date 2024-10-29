//INICIO | PLV-4391     
/*
*  @author Squad Avanxo 
*  @Descrição: EndossoSeguroDeVidaIndividualController
*/
public class EndossoSeguroDeVidaIndividualController {

    //Id da pagina
    public Id ctrId                                                     {get; set;}    

    public FavorecidoRemuneracaoContrato__c corretor                    {get; set;}
    public Endereco__c endereco                                         {get; set;}
    public Contract contract                                            {get; set;}
    public Boolean morte                                                {get; set;}
    public Boolean invalidez                                            {get; set;}
    
    public List<BeneficiarioSeguradoContrato__c> beneficiarios          {get; private set;}
    public List<GarantiaContrato__c> carencias                          {get; private set;}    
    public ContratanteContrato__c contratante                           {get; set;}
    public GrupoContrato__c grupo                                       {get; set;}
    public SeguradoContrato__c segurado                                 {get; set;}    
    public String numeroProposta                                        {get; set;}  
    
    public List<GarantiaContratanteContrato__c> garantias               {get; set;}
    //Valores e Pagamentos
    public String valorLiquidoTotal                                     {get; set;}
    public String valorTotalAssistenciaConvert                          {get; set;}
    public String valorIof                                              {get; set;}
    public String periocidadePagamento                                  {get; set;}
    public String valorTotalS                                           {get; set;}
    public String mock                                                  {get; set;}
    public List<wrapGarantiaContratante> wrapGarantias                  {get; set;}    
    public List<wrapBeneficiario> wrapBeneficiarios                     {get; set;}
    public List<wrapCarencia> wrapCarencias                             {get; set;}
    public List<wrapAssistenciasBeneficios> lWrapAssistenciasBeneficios {get; set;}
 
    public EndossoSeguroDeVidaIndividualController() 
    {    
        String contractNome = ApexPages.currentPage().getParameters().get('nomeContract'); 
        this.ctrId = buscaIdContract(contractNome);
        
        //validação token
        if(this.ctrId == null)
        {
            String token = ApexPages.currentPage().getParameters().get('token');
            System.debug('TESTING' +token);
            token = token.replace(' ','+');

            CryptoToken c = new CryptoToken();                     
            
            String chaveDescript = c.decrypt(token);  
            String[] trataChave = chaveDescript.split('\\|');
            this.ctrId = Id.valueof(trataChave[0]);               
         }       
        
        this.contract =  buscaContract(this.ctrId);
         if(this.contract.Produto__r.Segmento__c != 'Individual'){
            CalloutException e = new CalloutException();
            e.setMessage('Contrato informado não pertence ao segmento Individual');
            throw e;
         }
        
        this.numeroProposta = (contract.Proposta__r.Name); 
        this.endereco = buscaEndereco(this.contract.AccountId);
        this.corretor = buscarCorretor(this.contract);
        this.garantias  = buscaGarantias(this.ctrId); 
        this.beneficiarios  = buscaBeneficiarios(this.ctrId); 
        this.carencias  = buscaCarencias(this.ctrId);                 

        this.lWrapAssistenciasBeneficios = new List<wrapAssistenciasBeneficios>();
        Decimal Aux = 0;
        for(GarantiaContratanteContrato__c assist: this.garantias){
            if(assist.PremioTotal__c != null){
                Aux = Aux + assist.PremioTotal__c;
            }
            this.valorTotalAssistenciaConvert = Aux != null ? trataValores(Aux.format(), 'BRL') :'-';
            if(assist.GarantiaProduto__r.TipoGarantia__c != 'Cobertura'){
                this.lWrapAssistenciasBeneficios.add(new wrapAssistenciasBeneficios(assist));
            }
            //Validacion texto Disposicoes
            if(assist.Garantia__r.Name.contains('Morte')){
                this.morte = true;
            }
             //Validacion texto Disposicoes
            if(assist.Garantia__r.Name.contains('Invalidez Permanente Total')
            || assist.Garantia__r.Name.contains('Parcial por Acidente')){
                this.invalidez = true;
            }
        }

        this.wrapGarantias = new List<wrapGarantiaContratante>();
        for(GarantiaContratanteContrato__c cobertura: garantias){
            if(cobertura.GarantiaProduto__r.TipoGarantia__c == 'Cobertura'){
                this.wrapGarantias.add(new wrapGarantiaContratante(cobertura));
            }
        }
        this.mock = 'Em construção';

        this.wrapBeneficiarios = new List<wrapBeneficiario>();
        for(BeneficiarioSeguradoContrato__c beneficiario: beneficiarios){            
            this.wrapBeneficiarios.add(new wrapBeneficiario(beneficiario));            
        }

        this.wrapCarencias = new List<wrapCarencia>();
        for(GarantiaContrato__c carencia: carencias){           
            this.wrapCarencias.add(new wrapCarencia(carencia));            
        }
       
        valoresYpagamentos();
    
        
    }

    private FavorecidoRemuneracaoContrato__c buscarCorretor(Contract contrato){
        //informações de corretor
        return  [SELECT Id, Conta__r.Name, Conta__r.Phone, Conta__r.PersonEmail, 
                    DadosCorretor__r.Name, CorretorLider__c, Conta__r.SusepPrincipal__c,
                    Conta__r.Email__c, Conta__r.CodigoSusepCorretor__c, Name, Susep__c, SusepOficialCorretor__c
                    FROM FavorecidoRemuneracaoContrato__c
                    WHERE RemuneracaoContrato__c = :contrato.RemuneracoesContrato__r.get(0).Id
                    AND CorretorLider__c = true];          
    }

    //PLV-5247 INICIO
    private Endereco__c buscaEndereco (Id accountId) {
        return [SELECT Id, TipoEndereco__c, Bairro__c, Cidade__c, logradouro__c,
        Estado__c, Complemento__c, CEP__c,Numero__c
        FROM Endereco__c WHERE Conta__c =:accountId AND MaisAtual__c = true AND TipoEndereco__c = 'Residencial'];
    }
    //PLV-5247 FIM

    private id buscaIdContract (String nomeContract)    {
       
        if(string.isBlank(nomeContract))
        {
            return null;
        }
        Contract contract =[SELECT ID, Name from Contract where Name =: nomeContract];
        return contract.id;       
        
    }

    private Contract buscaContract(Id contractId){
        return [SELECT  Produto__r.Segmento__c,
        (Select Id, FormaPagamento__r.name, PremioComercial__c, IOF__c, PremioTotal__c, QuantidadeParcelas__c, PremioIntegral__c FROM ContratantesContrato__r), //PLV-5153 INICIO/FIM
        Id, DataEmissao__c, StartDate, VigenciaFinal__c, Tipo__c,CodigoRamo__c,
        AccountId, Account.Name, Account.PEP__pc, Account.Sexo__pc, PremioTotal__c,Sucursal__c, PremioIntegral__c, //PLV-5153 INICIO/FIM
        Account.Cpf__c, Account.PersonBirthdate, Account.PersonEmail,
        Account.PersonMobilePhone, Account.BillingStreet, IdExterno__c,
        Account.BillingCity, Account.BillingState, PremioComercial__c,
        Account.BillingPostalCode, Account.BillingCountry, Seguradora__r.Cnpj__c,
        Produto__r.name, NumeroApolice__c, Origem__c, PaisesDestino__c, Proposta__r.QuoteNumber,
        Produto__r.NumeroSusep__c, Name,  Proposta__r.email,Proposta__r.Name, Proposta__r.NumeroProposta__c,
        (SELECT Id FROM RemuneracoesContrato__r WHERE TipoRemuneracao__r.Codigo__c = 'COR')
        FROM Contract
        WHERE Id = : contractId];  
    }
    public List<GarantiaContratanteContrato__c> buscaGarantias(Id contractId){
        return [SELECT GarantiaProduto__r.TipoGarantia__c, Garantia__r.Name, ContratanteContrato__r.Contrato__r.startDate , 
        ContratanteContrato__r.Contrato__r.VigenciaFinal__c, Capital__c ,PremioTotal__c, CurrencyIsoCode, GarantiaProduto__r.RamoSeguro__r.Codigo__c
        FROM GarantiaContratanteContrato__c   WHERE ContratanteContrato__r.Contrato__r.Id=: contractId];
    }

    public List<BeneficiarioSeguradoContrato__c> buscaBeneficiarios(Id contractId){        
        contratante = [SELECT Id FROM ContratanteContrato__c WHERE Contrato__c =: contractId];        
        grupo = [SELECT Id FROM GrupoContrato__c WHERE ContratanteContrato__c =: contratante.Id];        
        segurado = [SELECT Id FROM SeguradoContrato__c WHERE GrupoContrato__c =: grupo.Id];
        
        return [SELECT Id, Nome__c, Conta__r.PersonBirthdate, GrauParentesco__c, Participacao__c
                FROM BeneficiarioSeguradoContrato__c WHERE SeguradoContrato__c =: segurado.Id];
    }    
    
    public List<GarantiaContrato__c> buscaCarencias(Id contractId){ 

        Map<Id, GarantiaContrato__c> franquiaGarantiaProdutoMap = new Map<Id, GarantiaContrato__c>(); 
        List<GarantiaContrato__c> lstDescGarantiasProduto = new List<GarantiaContrato__c>(); 
        
        List<GarantiaContrato__c> lstGarantiasProduto = [SELECT GarantiaProduto__r.Id, GarantiaProduto__r.Name, 
                                                         Garantia__r.Name, FranquiaGarantia__r.Franquia__r.Descricao__c, 
                                                         FranquiaGarantia__r.Franquia__r.Id FROM GarantiaContrato__c
                                                         WHERE Contrato__c =: contractId 
                                                         AND GarantiaProduto__r.TipoGarantia__c = 'Cobertura'
                                                         AND FranquiaGarantia__r.Franquia__r.Descricao__c != null];                                                       
        
        for(GarantiaContrato__c franquiaGarantiaProduto : lstGarantiasProduto){
            franquiaGarantiaProdutoMap.put(franquiaGarantiaProduto.FranquiaGarantia__r.Franquia__r.Id, franquiaGarantiaProduto);
        }
        
        lstDescGarantiasProduto.addAll(franquiaGarantiaProdutoMap.Values());        
      
        return lstDescGarantiasProduto;   
    }

    private void valoresYpagamentos(){
        
       this.periocidadePagamento = this.mock;	

       this.valorTotalS = this.contract.ContratantesContrato__r[0].PremioTotal__c!=null? trataValores(this.contract.ContratantesContrato__r[0].PremioTotal__c.format(), 'BRL'):'-';   
       this.valorIof = this.contract.ContratantesContrato__r[0].IOF__c != null? trataValores(this.contract.ContratantesContrato__r[0].IOF__c.format(), 'BRL') : '-';
       this.valorLiquidoTotal = (this.contract.PremioComercial__c != null)?  trataValores(this.contract.PremioComercial__c.format(), 'BRL'):'-'; 
      
   }

   public static String trataValores(string valor, string moeda){
    if(valor.contains(',')){
        string v = valor.substring(valor.indexOf(','),valor.length());
        if(v.length() == 2){
            if(moeda == 'BRL'){
                valor = 'R$ '+valor +'0'; 
            }
        }else{
            if(moeda == 'BRL'){
                valor = 'R$ '+valor; 
            }
        }
    }else if (valor.contains('.')){ 
        string v = valor.substring(valor.indexOf('.'),valor.length());
            if(moeda == 'BRL'){
                valor = 'R$ '+valor+',00'; 
            }else if(moeda == 'USD'){
                valor = 'US$ '+valor+',00';
            }
        
    }else{
        if(moeda == 'BRL'){
            valor = 'R$ '+valor+',00';
        }else if(moeda == 'USD'){
            valor = 'US$ '+valor+',00';
        }           
    }
    
    return valor;
}  
   
    public class wrapGarantiaContratante{
        
        //Variaveis coberturas
        public String nomeCobertura {get; set;}
        public String validadeCobertura {get; set;}
        public String capitalSeguradoCobertura {get; set;} 
        public String valorSeguroCobertura {get;set;}
        public String ramoCobertura {get;set;}

        public wrapGarantiaContratante(garantiaContratanteContrato__c gcc){
            if(gcc.GarantiaProduto__r.TipoGarantia__c == 'Cobertura'){
                nomeCobertura = gcc.Garantia__r.Name;
                validadeCobertura = gcc.ContratanteContrato__r.Contrato__r.startDate.format() +'-'+gcc.ContratanteContrato__r.Contrato__r.VigenciaFinal__c.format() ;
                capitalSeguradoCobertura = gcc.Capital__c != null ? trataValores(gcc.Capital__c.format(), gcc.CurrencyIsoCode) : '-';
               	valorSeguroCobertura = gcc.PremioTotal__c != null ? trataValores(gcc.PremioTotal__c.format(), 'BRL') : ' - ';
                ramoCobertura = gcc.GarantiaProduto__r.RamoSeguro__r.Codigo__c;
            }
        }
    }
   
    public class wrapAssistenciasBeneficios{
        
        public String nomeAssistencia {get;set;}
        public String validadeAssistencia {get;set;}
        public String valorAssistencia {get;set;}
        
       public wrapAssistenciasBeneficios(garantiaContratanteContrato__c assist){ 
            nomeAssistencia = nomeAssistencia = assist.Garantia__r.Name;
            validadeAssistencia = assist.ContratanteContrato__r.Contrato__r.startDate.format() +' - '+assist.ContratanteContrato__r.Contrato__r.VigenciaFinal__c.format();
            valorAssistencia = assist.PremioTotal__c != null ? trataValores(assist.PremioTotal__c.format(), 'BRL') : ' - ';                                            
        }
    }   

    public class wrapBeneficiario{
        
        //Variaveis de beneficiários
        public String nomeBeneficiario              {get; set;}
        public String nascBeneficiario              {get; set;}
        public String grauParentescoBeneficiario    {get; set;} 
        public String percentualBeneficiario        {get; set;}

        public wrapBeneficiario(BeneficiarioSeguradoContrato__c bfc){            
            nomeBeneficiario = bfc.Nome__c != null ? bfc.Nome__c : '-';
            nascBeneficiario = String.valueOf(bfc.Conta__r.PersonBirthdate) != null ? String.valueOf(bfc.Conta__r.PersonBirthdate) : '-';
            grauParentescoBeneficiario = bfc.GrauParentesco__c != null ? bfc.GrauParentesco__c : '-';
            percentualBeneficiario = bfc.Participacao__c != null ? string.ValueOf(bfc.Participacao__c).replace('.',',') : '-';            
        }
    }

    public class wrapCarencia{
        
        //Variaveis de carências
        public String descricaoCarencia              {get; set;}

        public wrapCarencia(GarantiaContrato__c car){        
            descricaoCarencia = car.FranquiaGarantia__r.Franquia__r.Descricao__c != null ? car.FranquiaGarantia__r.Franquia__r.Descricao__c : '-';
        }
    }
}