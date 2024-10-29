/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-31-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//INICIO | PLV-4368     
/*
*  @author Squad Avanxo 
*  @Descrição: ApoliceVidaIndividualController
*/
public class ApoliceVidaIndividualController {

    //Id da pagina
    public Id ctrId                                                         {get; set; }    

    public FavorecidoRemuneracaoContrato__c corretor                        {get; set;}
    public List<FavorecidoRemuneracaoContrato__c> corretores                {get; set;}//II-157 - INICIO/FIM
    public WrapEndereco endereco                                            {get; set;}
    public Contract contract                                                {get; set;}
    public Boolean morte                                                    {get; set;}
    public Boolean invalidez                                                {get; set;}

    //PLV-4817 INICIO
    //Valores e Pagamentos
    public String valorLiquidoTotal                                         {get; set;}
    public String valorTotalAssistenciaConvert                              {get; set;}
    public String valorIof                                                  {get; set;}
    public String periocidadePagamento                                      {get; set;}
    public String valorTotalS                                               {get;set;}

    public List<String> lstCarenciasFranquias                               {get; set;}
    public String formaPagamento                                            {get; set;} 
    public String quantidadeParcelas                                        {get; set;} //PLV 5032 INICIO / FIM 
    public String banco                                                     {get; set;} //II-125 INICIO-FIM 
    public String agencia                                                   {get; set;} //II-125 INICIO-FIM 
    public String numeroConta                                               {get; set;} //II-125 INICIO-FIM 
    public List<WrapBeneficiarios> lstBeneficiario                          {get; set;}
    public String beneneficiarioText                                        {get; set;}
    public String ultimaParcela      										{get; set;}
    public String primeiraParcela      										{get; set;}
    public List<WrapCobertura> wrapGarantias                                {get; set;}
    public List<WrapCobertura> lWrapAssistenciasBeneficios                  {get; set;}
    private Set<Id> setGarantiaProdutoId									{get; set;}
    private Decimal sumAssist 												{get; set;}
    //PLV-4817 FIM

    //PLV-4864-INICIO
    public String data                                                      {get; set;}
    public String local                                                     {get; set;}
    //PLV-4864-FIM

    //PLV-5032 INICIO 
    public String pageTitle                                                 {get; set;}
    //PLV-5032 FIM

    //PLV-5120 - INICIO
    public SeguradoContrato__c dadosVacinacao                               {get; set;}
    public Boolean hasVaccination                                           {get; set;}
    //public Boolean hasVaccinationDate                                       {get; set;}
    //PLV-5120 - FIM

    public boolean completeVaccinationCycle                                 {get; set;} //PLV-5145 INICIO/FIM

    //PLV-5231 - INICIO
    public WrapBeneficiarios grauParentescoOutros                           {get;set;}      
    public WrapBeneficiarios parentesco                                     {get;set;}   
    public SeguradoContrato__c dadosDocIdentificacao                        {get;set;}
    public Boolean hasRne                                                   {get;set;}
    public Boolean hasClasse                                                {get;set;}
    //public Boolean hasGrauParentescoOutros                                  {get;set;}
    public Boolean hasRG                                                    {get;set;} //PLV-5231 - FIX01 - INICIO/FIM
    //PLV-5231 - FIM

    // TKCL-246 - INICIO
    public Boolean isCodigoPrecificacaoAPTLMKT                                      {get; set;}
    // TKCL-246 - FIM
    
    public Boolean isGarantAFE                                               {get;set;} //PLV-5795 - INICIO/FIM

    //AV-697 INICIO
    public Boolean ocultarCicloVacinal                                              {get; set;} 
    //AV-697 FIM
    //RVI-41 Inicio    
    public String nome1             {get; set;} 
    public String cargo1            {get; set;} 
    public String descricaoCargo1   {get; set;} 
    public String nome2             {get; set;} 
    public String cargo2            {get; set;} 
    public String descricaoCargo2   {get; set;} 
    //RVI-41 Fim

    //PLV-5843 INICIO
    public String telCorretor                   {get; set;}
    public String emailCorretor                 {get; set;}
    //PLV-5843 FIM
    
    //II-66 INÍCIO
    public List<public_parcelacontrato__x>  lstParcelas                      {get; set;}
    //II-66 FIM

    //LECVPV 189 - INICIO
    public Boolean hasSocialName                {get; set;} 
    public String  nomeSocial                   {get; set;}
    //LECVPV 189 - FIM

    public static String numeroReemissao                {get;set;} //FCVEP-39 - INICIO/FIM

    public  ApoliceVidaIndividualController() 
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
        
         // TKCL-246 - INICIO
        this.isCodigoPrecificacaoAPTLMKT = false; 
          // TKCL-246 - FIM

        this.contract =  buscaContract(this.ctrId);
        inserirNumeroReemissao(contract); //FCVEP-39 INICIO/FIM
        System.debug('XXX - CONTRATO: ' + JSON.serialize(this.contract));

        //LECVPV 189 - INICIO
        this.hasSocialName = String.isEmpty(contract.Account.NomeSocial__c) ? false : true;
        this.nomeSocial = contract.Account.NomeSocial__c;
         //LECVPV 189 - FIM

        this.verificaCodigoPrecificacaoAPTLMKT(this.ctrId);
        
         if(this.contract.Produto__r.Segmento__c != 'Individual'){
            CalloutException e = new CalloutException();
            e.setMessage('Contrato informado não pertence ao segmento Individual');
            throw e;
         }
        this.pageTitle = this.contract.tipo__c == 'Endosso' ? 'Endosso de Apólice Individual de Seguros de Pessoas:' : 'Apólice Individual de Seguros de Pessoas:';  // PLV - 5032 - INICIO / FIM        
        this.endereco = buscaEndereco(this.contract.AccountId);
              
        this.corretor = buscarCorretor(this.contract);
        this.corretores = buscarCorretores(this.contract); //II-157 - INICIO/FIM

        //PLV-5120 - INICIO
        this.hasVaccination = true;
        //this.hasVaccinationDate = true;
        this.dadosVacinacao = getSegurado(this.contract.Id);    
        if(this.dadosVacinacao.CicloVacinal__c == 'Não iniciado') this.hasVaccination = false; 
        //if(this.dadosVacinacao.UltimaVacinaCicloVacinal__c == null) this.hasVaccinationDate = false; 
        //PLV-5120 - FIM
        
        //PLV-5145 - INICIO
        this.completeVaccinationCycle = false; 
        if(hasVaccination == true && this.dadosVacinacao.CicloVacinal__c == 'Completo'){
                this.completeVaccinationCycle = true;
        }  
         //PLV-5145 - FIM
        
        //AV-697 INICIO
        System.debug('Alexandre produto: ' + contract.Produto__r.Name);
        Boolean isVidaON = contract.Produto__r.Name.equals('Porto Vida ON');
        this.ocultarCicloVacinal = !isVidaON;
        //AV-697 FIM
        //PLV-5231 - INICIO
        //this.dadosDocIdentificacao = getSegurado(this.contract.Id);
        //Boolean isRne = dadosDocIdentificacao.tipoDocIdentificacao__c.equals('rne');
        system.debug('Danilo tipo docIdentificao>>>>>>>>>>> '+ this.contract.Account.tipoDocIdentificacao__c);
        if (this.contract.Account.tipoDocIdentificacao__c != null) {
            Boolean isRne = this.contract.Account.tipoDocIdentificacao__c.toLowerCase().equals('rne');
            this.hasRne = false;
            if(isRne) this.hasRne = true;
    
            Boolean isClasse = this.contract.Account.tipoDocIdentificacao__c.toLowerCase().equals('classe');
            this.hasClasse = false;
            if(isClasse) this.hasClasse = true;
    
            //PLV-5231 - FIX01 - INICIO
            Boolean isRG = this.contract.Account.tipoDocIdentificacao__c.toLowerCase().equals('rg');
            this.hasRG = false;
            if(isRG) this.hasRG = true;
        } else {
         this.contract.Account.tipoDocIdentificacao__c = '';   
        }
        //PLV-5231 - FIX01 - FIM

        //Boolean isGrauParentescoOutros = ben.parentesco.equals('Outros');
        //this.hasGrauParentescoOutros = false;
        //if(isGrauParentescoOutros) this.hasGrauParentescoOutros = true;
        //PLV-5231 - FIM

		//PLV-4817 INICIO
		this.morte = false;
        this.invalidez = false;
        this.lstBeneficiario = this.getBeneficiarios(this.ctrId);
        this.beneneficiarioText = this.lstBeneficiario.isEmpty() ? 'Herdeiros legais - Conforme artigo 792 do código civil' : '';

        this.sumAssist = 0;
        
        this.setGarantiaProdutoId = new Set<Id>();
        this.lstCarenciasFranquias = new List<String>();
        
        System.debug('This.Contract>>>>>>>>>>> '+ this.contract);
        System.debug('this.contract.GarantiasContrato__r >>>>> '+ this.contract.GarantiasContrato__r);
        System.debug('dadosVacinacao.GarantiasSeguradoContrato__r >>>>>> '+ dadosVacinacao.GarantiasSeguradoContrato__r);
        this.setupGarantias(this.contract.GarantiasContrato__r, dadosVacinacao.GarantiasSeguradoContrato__r); //PLV-5139 - INICIO/FIM

        for(String carencia: getCarancias(setGarantiaProdutoId )) this.lstCarenciasFranquias.add(carencia);
        
        //PLV-5032 INICIO
        setupValoresPagamentos(this.sumAssist, this.contract); 
        //PLV-5032 FIM
                
        //PLV-4817 FIM

        //PLV-4864-INICIO
        data = this.contract.DataEmissao__c.format();
        local = 'São Paulo';        
        //PLV-4864-FIM
        //RVI-41-INICIO
        Map<String,dadosDocumentosPDF__mdt> assinatura = contractDAO.getInstance().buscarAssinatura();
        cargo1 = assinatura.get('Assinatura1').Cargo__c;
        descricaoCargo1 = assinatura.get('Assinatura1').Descricao_do_cargo__c;
        nome1 = assinatura.get('Assinatura1').Nome__c;
        cargo2 = assinatura.get('Assinatura2').Cargo__c;
        descricaoCargo2 = assinatura.get('Assinatura2').Descricao_do_cargo__c;
        nome2 = assinatura.get('Assinatura2').Nome__c;
        //RVI-41-FIM

        //PLV-5843 INICIO
        telCorretor = String.isBlank(String.valueOf(corretor.Conta__r.phone)) ? corretor.Conta__r.PersonHomePhone : corretor.Conta__r.phone;
        emailCorretor = String.isBlank(String.valueOf(corretor.Conta__r.email__c)) ? corretor.Conta__r.PersonEmail : corretor.Conta__r.email__c;
        //PLV-5843 FIM

        //II-66 INÍCIO
        lstParcelas = getParcelasContratoPdf(this.contract);
        //II-66 FIM
    }

    private FavorecidoRemuneracaoContrato__c buscarCorretor(Contract contrato){
        //informações de corretor
        return  [SELECT Id, Conta__r.Name, Conta__r.Phone, Conta__r.PersonEmail, 
                    DadosCorretor__r.Name, CorretorLider__c, Conta__r.SusepPrincipal__c,
                    Conta__r.Email__c, Conta__r.CodigoSusepCorretor__c, Name, Susep__c, SusepOficialCorretor__c,  //PLV-5843 INICIO/FIM
                    Conta__r.PersonHomePhone //PLV-5843 INICIO/FIM
                    FROM FavorecidoRemuneracaoContrato__c
                    WHERE RemuneracaoContrato__c = :contrato.RemuneracoesContrato__r.get(0).Id
                    AND CorretorLider__c = true];          
    }

   //II-157 - INICIO
   private List<FavorecidoRemuneracaoContrato__c> buscarCorretores(Contract contrato){
    
    List<FavorecidoRemuneracaoContrato__c> listaFRC = new List<FavorecidoRemuneracaoContrato__c>();    
    List<FavorecidoRemuneracaoContrato__c> lTemp = [
            SELECT 
                Id,
                Conta__r.Name,
                Conta__r.Phone,
                Conta__r.PersonEmail, 
                DadosCorretor__r.Name,
                CorretorLider__c,
                Conta__r.SusepPrincipal__c,
                Conta__r.Email__c,
                Conta__r.CodigoSusepCorretor__c,
                Name,
                Susep__c,
                SusepOficialCorretor__c,
                Conta__r.PersonHomePhone
            FROM 
                FavorecidoRemuneracaoContrato__c
            WHERE 
                RemuneracaoContrato__c IN :contrato.RemuneracoesContrato__r //II-157 - INICIO/FIM
            ];

    for(FavorecidoRemuneracaoContrato__c frc : lTemp){
        if(frc.CorretorLider__c){
            listaFRC.add(frc);
        }
    }

    for(FavorecidoRemuneracaoContrato__c frc : lTemp){
        if(!frc.CorretorLider__c){
            listaFRC.add(frc);
        }
    }
    return listaFRC;
}
   //II-157 - FIM
    
    //PLV-5438 INICIO
    //PLV-5247 INICIO
   public WrapEndereco buscaEndereco(Id accountId) {
        List <SeguradoContrato__c> lstEndereco = new List <SeguradoContrato__c>();
        WrapEndereco WEndereco = new  WrapEndereco();
        integer scoreresidencial = 0;
        integer scorecomercial = 0;
        lstEndereco = [SELECT 
                           BairroComercial__c,BairroResidencial__c,CEPComercial__c,cepResidencial__c,CidadeComercial__c,
                           CidadeResidencial__c,ComplementoComercial__c,ComplementoResidencial__c,Conta__c,EnderecoComercial__c,
                           EnderecoResidencial__c,LogradouroComercial__c,logradouroResidencial__c, NumeroComercial__c,numeroResidencial__c,
                           PaisComercial__c,paisResidencial__c,UFComercial__c,UFResidencial__c 
                           FROM SeguradoContrato__c 
                           WHERE Conta__c =: accountId order By Name desc
                          ];
     system.debug(lstEndereco.size());
    if (lstEndereco.size() > 0 ) {
       if ( !string.isBlank(lstEndereco[0].logradouroResidencial__c) || !string.isBlank(lstEndereco[0].cepResidencial__c)) {
           scoreresidencial = scoreresidencial+1; 
       }
       if (!string.isBlank(lstEndereco[0].CidadeResidencial__c) || !string.isBlank(lstEndereco[0].UFResidencial__c)){
          scoreresidencial = scoreresidencial+1; 
       }    
       if (!string.isBlank(lstEndereco[0].BairroResidencial__c) || !string.isBlank(lstEndereco[0].numeroResidencial__c)) {
          scoreresidencial = scoreresidencial+1;   
       }
       if (!string.isBlank(lstEndereco[0].LogradouroComercial__c) || !string.isBlank(lstEndereco[0].CEPComercial__c)){ 
           scorecomercial = scorecomercial+1; 
       }
       if (!string.isBlank(lstEndereco[0].CidadeComercial__c) || !string.isBlank(lstEndereco[0].UFComercial__c)){ 
          scorecomercial = scorecomercial+1; 
       }    
       if (!string.isBlank(lstEndereco[0].BairroComercial__c) || !string.isBlank(lstEndereco[0].NumeroComercial__c)) {
          scorecomercial = scorecomercial+1;
       }
      system.debug(scoreresidencial + 'e scoreresidencial' +  scorecomercial);
     if ((scoreresidencial > 0) ||  (scorecomercial >0)) {
         if ( scoreresidencial >= scorecomercial ) {
               WEndereco.Bairro =    lstEndereco[0].BairroResidencial__c;
               WEndereco.Cidade =    lstEndereco[0].CidadeResidencial__c;
               WEndereco.Logradouro =lstEndereco[0].logradouroResidencial__c ;
               WEndereco.Estado =    lstEndereco[0].UFResidencial__c;
               WEndereco.Complemento = lstEndereco[0].ComplementoResidencial__c;
               WEndereco.CEP =       lstEndereco[0].cepResidencial__c;
               WEndereco.Numero =    lstEndereco[0].numeroResidencial__c; 
           } else {
               WEndereco.Bairro =      lstEndereco[0].BairroComercial__c;
               WEndereco.Cidade =      lstEndereco[0].CidadeComercial__c;
               WEndereco.Logradouro =  lstEndereco[0].LogradouroComercial__c;
               WEndereco.Estado =      lstEndereco[0].UFComercial__c;
               WEndereco.Complemento = lstEndereco[0].ComplementoComercial__c;
               WEndereco.CEP =         lstEndereco[0].CEPComercial__c;
               WEndereco.Numero =      lstEndereco[0].NumeroComercial__c; 
           }
         } else{
               WEndereco.Bairro ='Não Informado';
               WEndereco.Cidade ='Não Informado';
               WEndereco.Logradouro ='Não Informado';
               WEndereco.Estado ='Não Informado';
               WEndereco.Complemento ='Não Informado';
               WEndereco.CEP ='Não Informado';
               WEndereco.Numero ='Não Informado';
         } 
       } else {
               WEndereco.Bairro ='Não Informado';
               WEndereco.Cidade ='Não Informado';
               WEndereco.Logradouro ='Não Informado';
               WEndereco.Estado ='Não Informado';
               WEndereco.Complemento ='Não Informado';
               WEndereco.CEP ='Não Informado';
               WEndereco.Numero ='Não Informado';
     }
       system.debug('O endereço eh>>>'+ WEndereco);                                       
       return WEndereco;
      }   
    //PLV-5247 FIM
   //PLV-5438  FIM
    private id buscaIdContract (String nomeContract)    {
       
        if(string.isBlank(nomeContract))
        {
            return null;
        }
        Contract contract =[SELECT ID, Name from Contract where Name =: nomeContract];
        return contract.id;       
        
    }

    //PLV-4817 INICIO
    private List<String> getCarancias(Set<Id> setGarantiaProdutoId ){
        if(setGarantiaProdutoId.isEmpty()) return new List<String>();

        List<CarenciaGarantia__c> result = [
            SELECT ID, Carencia__c, Carencia__r.Descricao__c
            FROM CarenciaGarantia__c WHERE GarantiaProduto__c IN :setGarantiaProdutoId AND Carencia__c != null
        ];

        Map<Id, String> mpCarencia = new Map<Id, String>();

        for(CarenciaGarantia__c carencia : result) mpCarencia.put(carencia.Carencia__c, carencia.Carencia__r.Descricao__c);
        
        return mpCarencia.isEmpty() ? new List<String>() : mpCarencia.values();
    }

    private List<WrapBeneficiarios> getBeneficiarios(Id idContract){
        List<WrapBeneficiarios> response = new List<WrapBeneficiarios>();

        if(idContract == null ) return response;

        List<BeneficiarioSeguradoContrato__c> records = [
            SELECT 
                Nome__c,
                NomeSocial__c, //LECVPV 189-FIX02 - INICIO/FIM 
                TipoBeneficiario__c,
                GrauParentesco__c,
                BeneficiarioGrauParentescoOutros__c, //PLV-5231 INICIO/FIM
                Data_de_Nascimento__c,
                Participacao__c
            FROM BeneficiarioSeguradoContrato__c 
            WHERE SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c =: idContract
        ];

        for(BeneficiarioSeguradoContrato__c ben : records){
            if(ben.TipoBeneficiario__c	== 'Herdeiros legais, conforme artigo 792 do código civil.') continue;
            response.add(new WrapBeneficiarios(ben));
        }


        return response;
    }

    private Contract buscaContract(Id contractId){
        Contract response = null;
        try {
            
            response =  [
                SELECT 
                    Id, 
                    Name,  
                    Produto__r.Segmento__c,
                    DataEmissao__c, 
                    StartDate, 
                    VigenciaFinal__c, 
                    Tipo__c,
                    CodigoRamo__c,
                    AccountId, 
                    Account.Name,
                    Account.NomeSocial__c, //LECVPV 189 - INICIO/FIM
                    Account.PEP__pc, 
                    Account.Sexo__pc, 
                    PremioPuro__c,
                    PremioTotal__c,
                    Sucursal__c,
                    Observacoes__c, //PLV - 5034 INICIO / FIM
                    ContratoOriginal__c,//PLV - 5032 INICIO / FIM 
                    Endosso__c, //PLV - 5032 INICIO / FIM 
                    Account.Cpf__c, 
                    Account.PersonBirthdate, 
                    Account.PersonEmail,
                    Account.PersonMobilePhone, 
                    Account.BillingStreet, 
                    Account.tipoDocIdentificacao__c, //PLV5231 - INICIO / FIM
                    IdExterno__c,
                    Account.BillingCity, 
                    Account.BillingState, 
                    PremioComercial__c,
                    Account.BillingPostalCode, 
                    Account.BillingCountry, 
                    Account.DocIndentificacao__c, //PLV-5231 - INICIO/FIM
                    Seguradora__r.Cnpj__c,
                    Produto__r.name, 
                    NumeroApolice__c, 
                    Origem__c, PaisesDestino__c, 
                    Proposta__r.QuoteNumber,
                    Produto__r.NumeroSusep__c,
                    Produto__r.RegistroSusep__c, // RVI-41-INICIO/FIM
                    Produto__r.Empresa__r.Name, // RVI-41-INICIO/FIM
                    Produto__r.Empresa__r.Cnpj__c, // RVI-41-INICIO/FIM 
                    Proposta__r.email,
                    Proposta__r.Name, 
                    Proposta__r.NumeroProposta__c,
                    (SELECT Id FROM RemuneracoesContrato__r WHERE TipoRemuneracao__r.Codigo__c = 'COR'), //II-125 INICIO
                    (Select 
                        Id, 
                        FormaPagamento__r.name, 
                        PremioComercial__c, 
                        PremioPuro__c,
                        IOF__c, 
                        PremioTotal__c, 
                        QuantidadeParcelas__c,
                        VencimentoDemaisParcelas__c,
                        InformacaoBancaria__r.Agencia__c, 
                        InformacaoBancaria__r.Digito__c, 
                        InformacaoBancaria__r.NumeroConta__c, 
                        InformacaoBancaria__r.BancoNew__r.Name
                    FROM ContratantesContrato__r),
                    //II-125 FIM
                    (SELECT 
                        GarantiaProduto__r.TipoGarantia__c, 
                        Garantia__r.Name,
                        Garantia__r.Sigla__c, //PLV-5162 - INICIO/FIM
                        Capital__c ,
                        PremioPuro__c,
                        PremioTotal__c, 
                        CurrencyIsoCode, 
                        GarantiaProduto__r.RamoSeguro__r.Codigo__c,
                        GarantiaProduto__r.Garantia__r.Sigla__c, //teste
                        FranquiaGarantia__c,
                        GarantiaProduto__c,
                        FranquiaGarantia__r.Franquia__c,
                        FranquiaGarantia__r.Franquia__r.Descricao__c
                        FROM GarantiasContrato__r
                        //PLV-5139 - INICIO
                        ORDER BY GarantiaProduto__r.OrdemPrioridade__c,
                                Name
                        //PLV-5139 - FIM
                        )
                    FROM Contract
                    WHERE Id = : contractId
                    LIMIT 1
                ];
        } catch (Exception e) {
            
        }

        return response;
    }

     // TKCL-246 - INICIO
    private void verificaCodigoPrecificacaoAPTLMKT(Id contractId){
        Contract contract = null;
        try{
            contract = [
                SELECT 
                    Id,
                    Produto__r.CodigoPrecificaProduto__c 
                FROM 
                    Contract
                WHERE Id = :contractId
                LIMIT 1
            ];
            System.debug('HENRIQUE CONTRACT : ' + contract.Produto__r.CodigoPrecificaProduto__c);
        this.isCodigoPrecificacaoAPTLMKT = contract.Produto__r.CodigoPrecificaProduto__c.equals('APTLMKT') ? true : false;
        System.debug ('HENRIQUE IS CODIGO: ' + isCodigoPrecificacaoAPTLMKT);

        } catch(Exception e){
            
        }       
    }
     // TKCL-246 - FIM

    public static String trataValores(string valor, string moeda){
        if(valor.contains(',')){
            string v = valor.substring(valor.indexOf(','),valor.length());
            if(v.length() == 2){
                if(moeda == 'BRL'){
                    valor = 'R$ '+ valor +'0'; 
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
    
    private void setupGarantias(List<GarantiaContrato__c> lstGarantias, List<GarantiaSeguradoContrato__c> garantiasSeguradoDIH ){ //PLV-5139 - INICIO/FIM
        this.lWrapAssistenciasBeneficios = new List<WrapCobertura>();
        this.wrapGarantias = new List<WrapCobertura>();

        Map<Id, String> mpFranquia = new Map<Id, String>();
        System.debug('lstGarantias >>>' + lstGarantias);
        System.debug('garantiasSeguradoDIH >>>' + garantiasSeguradoDIH);
        for(GarantiaContrato__c garantia: lstGarantias){
            setGarantiaProdutoId.add(garantia.GarantiaProduto__c);
            
            if(garantia.Garantia__r.Name.contains('Morte')) this.morte = true;

            //PLV-5162 - INICIO - Ajuste temporário - Adicionar 'Plus' para cobertura IPA
            if(garantia.Garantia__r.Sigla__c == 'IPA'){
                garantia.Garantia__r.Name +=' Plus';
            }
            //PLV-5139 - INICIO
            else if (garantia.Garantia__r.Sigla__c == 'DIH' || garantia.Garantia__r.Sigla__c == 'DIA'){ //TKCL-246 INICIO/FIM FIX01                
                Integer dias = (Integer)( garantiasSeguradoDIH.size() > 0 ? garantiasSeguradoDIH[0].ValorDias__c : null) ;
                garantia.Garantia__r.Name += ( 
                            dias == null  
                                ? ''
                                : ' (' + dias.format() + ' dia' + (dias == 1 ? '': 's') +  ')' 
                            );
            }
            //PLV-5139 - FIM
            //PLV-5162 - FIM
            
            if(garantia.Garantia__r.Name.contains('Invalidez Permanente Total') || garantia.Garantia__r.Name.contains('Parcial por Acidente')){
                this.invalidez = true;
                garantia.Garantia__r.Name += '*';
            }

            //PLV-5795 - INICIO
            Boolean isGarantAFE = false;
            if (garantia.Garantia__r.Sigla__c == 'AFE')
            {
                this.isGarantAFE = true;
            } 
            //PLV-5795 - INICIO

            if(garantia.GarantiaProduto__r.TipoGarantia__c != 'Cobertura'){
                System.debug('garantia.GarantiaProduto__r.TipoGarantia__c ' + garantia.GarantiaProduto__r.TipoGarantia__c);
                sumAssist += garantia.PremioTotal__c != null ? garantia.PremioTotal__c : 0;
                this.lWrapAssistenciasBeneficios.add(new WrapCobertura(garantia, this.contract.startDate, this.contract.VigenciaFinal__c));
                System.debug('lWrapAssistenciasBeneficios >>> ' + this.lWrapAssistenciasBeneficios);
            }
            else{
                this.wrapGarantias.add(new WrapCobertura(garantia, this.contract.startDate, this.contract.VigenciaFinal__c));
                System.debug('wrapGarantias >>> ' + this.wrapGarantias);
            }
            
            if(garantia.FranquiaGarantia__c != null && garantia.FranquiaGarantia__r.Franquia__c != null){
                mpFranquia.put(garantia.FranquiaGarantia__r.Franquia__c, garantia.FranquiaGarantia__r.Franquia__r.Descricao__c);
            }

            
        }
        
        for(String val : mpFranquia.values()) this.lstCarenciasFranquias.add(val);
    }

    // PLV 5032 - INICIO
    private void setupValoresPagamentos(Decimal sumAssist, Contract contrato) {
        Decimal valorTotal = contrato.ContratantesContrato__r[0].PremioTotal__c; 

        this.formaPagamento = '-';
        this.periocidadePagamento = '-';
        this.quantidadeParcelas = '-';
        //II-125 INICIO
        this.banco = '-';
        this.agencia = '-';
        this.numeroConta = '-';
        //II-125 FIM
        this.valorTotalAssistenciaConvert = '-';
        this.ultimaParcela = ' - ';
        this.primeiraParcela = ' - ';
        this.valorIof = '-';

        this.valorTotalAssistenciaConvert = sumAssist > 0 ? trataValores(sumAssist.format(), 'BRL') : '-';

        this.valorTotalS = contrato.ContratantesContrato__r[0].PremioTotal__c!=null ? trataValores(contrato.ContratantesContrato__r[0].PremioTotal__c.format(), 'BRL'):'-';   

        if(valorTotal > 0) {
            this.valorLiquidoTotal = (contrato.PremioComercial__c != null) ?  trataValores(contrato.PremioComercial__c.format(), 'BRL'):'-';

            this.formaPagamento = contrato.ContratantesContrato__r[0].FormaPagamento__r.Name;
            this.periocidadePagamento = contrato.ContratantesContrato__r[0].VencimentoDemaisParcelas__c + '';
            this.quantidadeParcelas =  contrato.ContratantesContrato__r[0].QuantidadeParcelas__c + '';
            this.valorIof = contrato.ContratantesContrato__r[0].IOF__c != null ? trataValores(contrato.ContratantesContrato__r[0].IOF__c.format(), 'BRL') : '-';
            //II-125 INICIO
            this.banco = contrato.ContratantesContrato__r[0].InformacaoBancaria__r.BancoNew__r.Name;
            this.agencia = contrato.ContratantesContrato__r[0].InformacaoBancaria__r.Agencia__c;
            this.numeroConta = contrato.ContratantesContrato__r[0].InformacaoBancaria__r.NumeroConta__c + '-' + contrato.ContratantesContrato__r[0].InformacaoBancaria__r.Digito__c;
            //II-125 FIM

            try {
                ParcelamentoContratoTO parcelas = contrato.Endosso__c == '0' ? getParcelasContrato(contrato) : getParcelasVigenteContrato(contrato);

                this.primeiraParcela = trataValores(Decimal.valueOf(parcelas.data[0].valorparcela).format(), 'BRL');
                this.ultimaParcela = parcelas.data.size() > 1 ? trataValores(Decimal.valueOf(parcelas.data[parcelas.data.size() - 1].valorparcela).format(), 'BRL') : ' - ';

            } catch (Exception e) { System.debug('Erro parcelas:'); System.debug(e); }

        }
        else if(valorTotal < 0){
            this.valorTotalS = '-' + this.valorTotalS.replace('-', '');
            this.valorLiquidoTotal = this.valorTotalS;
        }       
        
    } 

    private ParcelamentoContratoTO getParcelasVigenteContrato(Contract contrato){
        Set<String> setChaves = new Set<String>();
        Map<String, List<public_parcelacontrato__x>> mpParcelas = new Map<String, List<public_parcelacontrato__x>>();

        List<Contract> lstContratos = [
            SELECT 
                Id,  
                CreatedDate, 
                PremioComercial__c,
                Endosso__c ,
                (SELECT Id, PremioTotal__c, FormaPagamento__r.Name, VencimentoDemaisParcelas__c, QuantidadeParcelas__c, IOF__c FROM ContratantesContrato__r)
            FROM Contract
            WHERE NumeroApolice__c =: contrato.NumeroApolice__c 
            ORDER BY CreatedDate DESC
        ];

        for(Contract ctr : lstContratos){
            if(Integer.valueOf(ctr.Endosso__c) > Integer.valueOf(contrato.Endosso__c)) continue;            

            setChaves.add(ctr.Id + '_' + ctr.ContratantesContrato__r[0].id);
        }

        List<public_parcelacontrato__x> lstParcelas = [ 
            SELECT 
                Id__c, 
                Datavencimento__c,
                Numeroparcela__c, 
                Valoriof__c, 
                Valorliquido__c, 
                Idfatura__c, 
                Idexterno__c, 
                Status__c, 
                Valorparcela__c
            FROM public_parcelacontrato__x 
            WHERE idexterno__c in: setChaves
        ];

        for(public_parcelacontrato__x parcela : lstParcelas){
            if(!mpParcelas.containsKey(parcela.idexterno__c)) mpParcelas.put(parcela.idexterno__c, new List<public_parcelacontrato__x>());

            mpParcelas.get(parcela.idexterno__c).add(parcela);
        }

        for(String chave : setChaves){
            System.debug('Processando chave: '+chave);
            List<public_parcelacontrato__x> parcelasChave = mpParcelas.get(chave);

            if(parcelasChave == null || parcelasChave.isEmpty()) continue;


            return ParcelamentoContratoTO.DTOParcelaContrato(parcelasChave);

        }

        return null;
    }

    private ParcelamentoContratoTO getParcelasContrato(Contract contrato){
        String chave = contrato.Id + '_' + contrato.ContratantesContrato__r[0].id;

        List<public_parcelacontrato__x> parcelasTemp = [ 
            SELECT 
                Id__c, 
                Datavencimento__c,
                Numeroparcela__c, 
                Valoriof__c, 
                Valorliquido__c, 
                Idfatura__c, 
                Idexterno__c, 
                Status__c, 
                Valorparcela__c
            FROM public_parcelacontrato__x 
            WHERE idexterno__c = :chave
        ];

        return ParcelamentoContratoTO.DTOParcelaContrato(parcelasTemp);
    }
    // PLV 5032 - FIM

    //PLV-5120 - INICIO
    //PLV-5231 - INICIO
    private SeguradoContrato__c getSegurado(Id ctrId){
        SeguradoContrato__c segurado;
        try {
            segurado = [
                SELECT ID, toLabel(FaixaRenda__c), toLabel(CicloVacinal__c), tipoDocIdentificacao__c
//PLV-5139 - INICIO
                    , (   SELECT ID, ValorDias__c 
                    FROM GarantiasSeguradoContrato__r 
                    WHERE Garantia__r.Sigla__c = 'DIH' OR Garantia__r.Sigla__c = 'DIA') //TKCL-246 INICIO/FIM FIX01 
//PLV-5139 - FIM
                FROM SeguradoContrato__c 
                WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c =: ctrId
            ];
        } catch (Exception e) {
            System.debug(e);
        }

        return segurado;
    }    
    //PLV-5231 - FIM
    //PLV-5120 - FIM

    //II-66 INÍCIO
    private List<public_parcelacontrato__x> getParcelasContratoPdf(Contract contrato){
        String chave = contrato.Id + '_' + contrato.ContratantesContrato__r[0].id;
        System.debug('Apolice PDF Parcelas');
        System.debug([ 
            SELECT 
                Id__c, 
                Datavencimento__c,
                Numeroparcela__c, 
                Valoriof__c, 
                Valorliquido__c, 
                Idfatura__c, 
                Idexterno__c, 
                Status__c, 
                Valorparcela__c
            FROM public_parcelacontrato__x 
            WHERE idexterno__c = :chave
        ]);
        return  [ 
            SELECT 
                Id__c, 
                Datavencimento__c,
                Numeroparcela__c, 
                Valoriof__c, 
                Valorliquido__c, 
                Idfatura__c, 
                Idexterno__c, 
                Status__c, 
                Valorparcela__c
            FROM public_parcelacontrato__x 
            WHERE idexterno__c = :chave
        ];
    }
    //II-66 FIM
    //FCVEP-39 - INICIO
    public static void inserirNumeroReemissao(Contract contrato){

        List<Contract> lContrato;

        if(contrato != null){
            lContrato = [SELECT Id, Sucursal__c, CodigoRamo__c, NumeroApoliceFiltro__c FROM Contract WHERE Id = :contrato.Id];

            if(!lContrato.isEmpty() && lContrato[0].NumeroApoliceFiltro__c != null){
                numeroReemissao = lContrato[0].Sucursal__c + '.' + lContrato[0].CodigoRamo__c + '.' + lContrato[0].NumeroApoliceFiltro__c; 
            }
        }else{
           numeroReemissao = '';
        }
    }
    //FCVEP-39 - FIM

    @testVisible
    private class WrapCobertura{
        public String nome             			{get; set;}
        public String validade        			{get; set;}
        public String capital  					{get; set;} 
        public String valorSeguroCobertura      {get;set;}
        public String ramoCobertura             {get;set;}
        public String valor      				{get;set;}

        public WrapCobertura(GarantiaContrato__c gcc, Date vigenciaInicial, Date vigenciaFinal){
            this.nome = gcc.Garantia__r.Name;
            this.validade = vigenciaInicial.format() + '-' + vigenciaFinal.format();
            this.capital = gcc.Capital__c != null ? trataValores(gcc.Capital__c.format(), gcc.CurrencyIsoCode) : '-';
            this.valorSeguroCobertura = gcc.PremioTotal__c != null ? trataValores(gcc.PremioTotal__c.format(), 'BRL') : ' - ';
            this.ramoCobertura = gcc.GarantiaProduto__r.RamoSeguro__r.Codigo__c;
            this.valor = gcc.PremioTotal__c != null && gcc.PremioTotal__c > 0 ? trataValores(gcc.PremioTotal__c.format(), 'BRL') : ' Assistência gratuita '; //PLV-5139 - FIX03 - INICIO/FIM
        }
    }

    public class WrapBeneficiarios{
        public String nome          {get;set;}
        public String nomeSocial    {get;set;}//LECVPV 189-FIX02 - INICIO/FIM
        public String parentesco    {get;set;}
        public String grauParentescoOutros  {get;set;} //PLV-5231 - INICIO/FIM
        public String participacao    {get;set;}
        public String dataNascimento  {get;set;}

        public WrapBeneficiarios(BeneficiarioSeguradoContrato__c ben){
            this.nome = ben.Nome__c;
            this.nomeSocial = ben.NomeSocial__c;//LECVPV 189-FIX02 - INICIO/FIM
            this.parentesco = ben.GrauParentesco__c;
            this.grauParentescoOutros = ben.BeneficiarioGrauParentescoOutros__c !=null ? '('+ ben.BeneficiarioGrauParentescoOutros__c +')': ''; //PLV-5231 - INICIO/FIM
            this.participacao = ben.Participacao__c != null ? ben.Participacao__c + '%' : '';
            this.dataNascimento = ben.Data_de_Nascimento__c != null ? ben.Data_de_Nascimento__c.format() : '';
        }

    }
   // PLV-4817 FIM
    public class WrapEndereco {
        public String Bairro      {get;set;}
        public String Cidade      {get;set;}
        public String Logradouro  {get;set;}
        public String Estado      {get;set;}
        public String Complemento {get;set;}
        public String CEP         {get;set;}
        public String Numero      {get;set;}
    }
}