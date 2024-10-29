public class ApoliceController {
    
    //3404 - INICIO VARIAVEIS
    public String renderAs { get; private set; }
    public Contract contrato {get; private set; }
    public ContratanteContrato__c contratante {get; private set;}
    public Endereco__c endereco {get; private set;}
    public GrupoContrato__c grupo {get; private set;}
    public SeguradoContrato__c segurado {get; private set;}
    public FavorecidoRemuneracaoContrato__c corretor {get; private set;}
    public List<GarantiaContratanteContrato__c> garantiaContratanteContrato {get; private set;}
    public GarantiaProduto__c garantiaProduto {get; private set;} // PLV - 4250
    public List<GarantiaContratanteContrato__c> assistenciasBeneficios {get; private set;}
    public Garantia__c garantia {get; private set;}
    public RamoGarantia__c ramoGarantia {get; private set;}
    public List<BeneficiarioSeguradoContrato__c> beneficiarios {get; private set;}
    public List<wrapGarantiaContratante> lWrapGarantiaContratante {get; private set;}
    public List<wrapAssistenciasBeneficios> lWrapAssistenciasBeneficios {get; private set;}
    public List<wrapBeneficiarios> lWrapBeneficiarios {get; private set;}
    //header
    public String nomeProduto                   {get; set;}
    public String codigoProduto                 {get; set;} //AV-86 INICIO/FIM
    public String numeroSusep                   {get; set;}
    public String numeroApolice                 {get; set;}
    public String origemViagem                  {get; set;}
    public String destinoViagem                 {get; set;}
    public String periodoViagem                 {get; set;}
    public String numeroProposta                {get; set;}
    public String vigenciaInicio                {get; set;}
    public String vigenciaFinal                 {get; set;}
    public String dataEmissao                   {get; set;}
    public String tituloPDF                     {get; set;} // PLV 5053 INICIO/FIM
    //Dados do Segurado
    public String nomeSegurado                  {get; set;}
    public String emailSegurado                 {get; set;}
    public String enderecoSegurado              {get; set;}
    public String bairroSegurado                {get; set;}
    public String cidadeSegurado                {get; set;}
    public String estadoSegurado                {get; set;}
    public String complementoSegurado           {get; set;}
    public String docSegurado                   {get; set;}
    public String cepSegurado                   {get; set;}
    public String dataNascSegurado              {get; set;}
    //Dados do Corretor
    public String corretorLider                 {get; set;}
    public String telCorretor                   {get; set;}
    public String susepPortoCorretor            {get; set;}
    public String emailCorretor                 {get; set;}
    public String susepOficialCorretor          {get; set;}
    //Coberturas -> lWrapGarantiaContratante
    //Assistencias e beneficios
    //Beneficiario -> lWrapBeneficiarios
    //Valores e Pagamentos
    public String formaPagamento                {get; set;}
    public String valorLiquidoTotal             {get; set;}
    public Decimal valorTotalAssistencia        {get; set;}
    public String valorTotalAssistenciaConvert  {get; set;}
    public String valorIof                      {get; set;}
   // public String valorIofSegurado               {get; set;}
    public String valorTotal                    {get; set;}
    public String periocidadePagamento          {get; set;}
    public Decimal qtdParcelas                  {get; set;}
    public String valorParcela                  {get; set;}
    public String valorTotalS                   {get; set;}
    //Disposições Gerais
    public String ambitoTerritorial             {get; set;}//PLV - 4250 inicio/fim
    //Condições Gerais
    public String data                          {get; set;}
    public String local                         {get; set;}
    //AV-86 INICIO
    public Boolean exibirPagamentos             {get; set;} 
    public Boolean exibirObservacaoVidaOn       {get; set;}
    public Boolean ocultarObservacaoVidaOn      {get; set;}
    public Boolean exibirCoberturasVidaOn       {get; set;}
    public Boolean ocultarCoberturasVidaOn      {get; set;}
    //AV-86 FIM
    //3404 - FIM VARIAVEIS
    //LECVPV 189 - INICIO
    public Boolean hasSocialName                {get; set;} 
    public String  nomeSocial                   {get; set;}
    //LECVPV 189 - FIM
    public ApoliceController() {
        
        //Iniciando listas
        lWrapGarantiaContratante = new List<wrapGarantiaContratante>(); 
        lWrapBeneficiarios = new List<wrapBeneficiarios>();
        lWrapAssistenciasBeneficios = new List<wrapAssistenciasBeneficios>();
        
        List<String> lGarantias = new List<String>();
        
        Map<String,String> mPageParam = ApexPages.currentPage().getParameters();
        this.renderAs = mPageParam.containsKey('renderAs') ?  mPageParam.get('renderAs') : '';
        //PLV-3746 - INICIO
        string contratoID;
        if (!mPageParam.containsKey('contratoId') && !mPageParam.containsKey('token')) {
            return;
        }
        if(mPageParam.containsKey('contratoId')){
           contratoID = mPageParam.get('contratoId');
        }
        if(mPageParam.containsKey('token')){
           CryptoToken c = new CryptoToken();  
           String chave = mPageParam.get('token');
           system.debug('chave'+chave);
           chave = chave.replace(' ','+');
           String chaveDescript = c.decrypt(chave);
           String dadosDoc = chaveDescript;
           String[] trataChave = dadosDoc.split('\\|');
           contratoID = trataChave[0];
          	system.debug('chave'+chave);
        	system.debug('contratoID'+contratoID);
        }
        
        //informações de contrato

        contrato = [SELECT Id, DataEmissao__c, StartDate, VigenciaFinal__c, Tipo__c,CodigoRamo__c,
                    Account.Name, Account.PEP__pc, Account.Sexo__pc, PremioTotal__c,Sucursal__c,
                    Account.CPF__pc, Account.PersonBirthdate, Account.PersonEmail,
                    Account.PersonMobilePhone, Account.BillingStreet, IdExterno__c,
                    Account.BillingCity, Account.BillingState, PremioComercial__c,
                    Account.BillingPostalCode, Account.BillingCountry, Seguradora__r.Cnpj__c,
                    Produto__r.name, NumeroApolice__c, Origem__c, PaisesDestino__c, Proposta__r.QuoteNumber,
                    Produto__r.ProductCode, Produto__r.NumeroSusep__c, Produto__r.RegistroSusep__c, Name,  Proposta__r.email,Proposta__r.Name, //AV-86 INICIO/FIM
                    (SELECT Id FROM RemuneracoesContrato__r WHERE TipoRemuneracao__r.Codigo__c = 'COR')
                    FROM Contract
                    WHERE Id = : contratoID];  
        //PLV-3746 - FIM
        if (contrato == null || contrato.RemuneracoesContrato__r == null || contrato.RemuneracoesContrato__r.isEmpty()) {return;}
        
        //informações de corretor
        corretor = [SELECT Id, Conta__r.Name, Conta__r.Phone, Conta__r.PersonEmail, 
                    DadosCorretor__r.Name, CorretorLider__c, Conta__r.SusepPrincipal__c,
                    Conta__r.Email__c, Conta__r.CodigoSusepCorretor__c, Name, Susep__c, SusepOficialCorretor__c
                    FROM FavorecidoRemuneracaoContrato__c
                    WHERE RemuneracaoContrato__c = :contrato.RemuneracoesContrato__r.get(0).Id
                    AND CorretorLider__c = true];     

        //informações de contratante
        //PLV-4816 - INÍCIO
        contratante = [SELECT Id, FormaPagamento__r.name, PremioComercial__c, 
                       IOF__c, PremioTotal__c, QuantidadeParcelas__c, Conta__c
                       FROM ContratanteContrato__c
                       WHERE Contrato__c =: contrato.Id];
                               
        endereco =[SELECT Id, TipoEndereco__c, Bairro__c, Cidade__c, logradouro__c,
        Estado__c, Complemento__c, CEP__c,Numero__c
        FROM Endereco__c where Conta__c =: contratante.Conta__c AND MaisAtual__c = true limit 1];
        //PLV-4816 - FIM

        grupo = [SELECT Id
                 FROM GrupoContrato__c
                 WHERE ContratanteContrato__c =: contratante.Id];

        // PLV-4848 INICIO
        segurado = [SELECT Id, Conta__r.Name, conta__r.cpf__c, conta__r.Email__c, IOF__c,
                    conta__r.BillingStreet, conta__r.BillingCity, conta__r.BillingState,
                    Conta__r.NomeSocial__c, //LECVPV 189 - INICIO/FIM
                    conta__r.BillingPostalCode, conta__r.PersonBirthdate, bairroResidencial__c, cepResidencial__c, CidadeResidencial__c, ComplementoResidencial__c, logradouroResidencial__c, numeroResidencial__c, paisResidencial__c, UFResidencial__c 
                    FROM SeguradoContrato__c
                    WHERE GrupoContrato__c =: grupo.Id];
        // PLV-4848 FIM

        beneficiarios = [SELECT Id, Nome__c, NomeSocial__c, CpfCnpj__c, Conta__r.Email__c, //LECVPV 189-FIX02 - INICIO/FIM
                         Conta__r.BillingStreet, Conta__r.BillingCity, 
                         Conta__r.BillingState, Conta__r.BillingPostalCode,
                         Conta__r.PersonBirthdate, TipoBeneficiario__c, GrauParentesco__c, Participacao__c
                         FROM BeneficiarioSeguradoContrato__c
                         WHERE SeguradoContrato__c =: segurado.Id];
        
        //PLV-3884 - INICIO - Adicionar CurrencyIsoCode nas consultas
        garantiaContratanteContrato = [SELECT Id, Garantia__c, garantia__r.Name, capital__c, valor__c, CurrencyIsoCode,
                                       ContratanteContrato__r.Contrato__r.VigenciaFinal__c,ContratanteContrato__r.Contrato__r.StartDate,
                                       GarantiaProduto__r.TipoCaracteristicaEspecial__c,GarantiaProduto__r.LimiteMinimoCaracteristicaEspecial__c,
                                       GarantiaProduto__r.LimiteMaximoCaracteristicaEspecial__c,
                                       //PLV-3884 - INICIO - Campos alterados de moeda para numero
                                       PremioTotal__c,
                                       //PLV-3884 - FIM
                                       Garantia__r.Tipo__c, GarantiaProduto__r.TipoGarantia__c,GarantiaProduto__r.RamoSeguro__r.Codigo__c,
                                       // PLV-3882 - ADICIONADO GarantiaProduto__r.VigenciaGarantia__c, ContratanteContrato__r.Contrato__r.DataEmissao__c
                                       Garantia__r.Sigla__c, garantiaProduto__r.OrdemPrioridade__c, GarantiaProduto__r.VigenciaGarantia__c, ContratanteContrato__r.Contrato__r.DataEmissao__c
                                       FROM GarantiaContratanteContrato__c
                                       WHERE ContratanteContrato__c =: contratante.Id AND GarantiaProduto__r.TipoGarantia__c = 'Cobertura' ORDER BY garantiaProduto__r.OrdemPrioridade__c ASC];
        system.debug('garantiaContratanteContrato: '+garantiaContratanteContrato);
        //AV-86 Remoção de query em debug
        assistenciasBeneficios = [SELECT Id, Garantia__c, garantia__r.Name, capital__c, valor__c,CurrencyIsoCode,
                                  ContratanteContrato__r.Contrato__r.VigenciaFinal__c,ContratanteContrato__r.Contrato__r.StartDate,
                                  GarantiaProduto__r.TipoCaracteristicaEspecial__c,GarantiaProduto__r.LimiteMinimoCaracteristicaEspecial__c,
                                  GarantiaProduto__r.LimiteMaximoCaracteristicaEspecial__c,
                                  //PLV-3884 - INICIO - Campos alterados de moeda para numero
                                  PremioTotal__c,
                                  //PLV-3884 - FIM
                                  Garantia__r.Tipo__c, GarantiaProduto__r.TipoGarantia__c,GarantiaProduto__r.RamoSeguro__r.Codigo__c,
                                  // PLV-3882 - ADICIONADO GarantiaProduto__r.VigenciaGarantia__c, ContratanteContrato__r.Contrato__r.DataEmissao__c
                                  Garantia__r.Sigla__c, garantiaProduto__r.OrdemPrioridade__c, GarantiaProduto__r.VigenciaGarantia__c, ContratanteContrato__r.Contrato__r.DataEmissao__c
                                  FROM GarantiaContratanteContrato__c
                                  WHERE ContratanteContrato__c =: contratante.Id AND (GarantiaProduto__r.TipoGarantia__c = 'Assistência' OR GarantiaProduto__r.TipoGarantia__c ='Benefício')ORDER BY garantiaProduto__r.OrdemPrioridade__c ASC];   
         //PLV-3884 - FIM - Adicionar CurrencyIsoCode nas consultas
        
        
        
        //popula variaveis da apolice
        tituloPDF = contrato.Tipo__c.toUpperCase() == 'ENDOSSO' ? 'Endosso de Apólice de Seguro Viagem' : 'Apólice de Seguro Viagem'; //PLV-5053 INICIO/FIM 
        nomeProduto = contrato.Produto__r.Name;
        codigoProduto = contrato.Produto__r.ProductCode; //AV-86 INICIO/FIM
        numeroSusep = contrato.Produto__r.NumeroSusep__c;
        numeroApolice = contrato.Sucursal__c+'.'+contrato.CodigoRamo__c+'.'+contrato.NumeroApolice__c;
        origemViagem = 'Brasil';
        destinoViagem = contrato.PaisesDestino__c;
        //SVEP-61 FIX01 INICIO
        Integer days = contrato.StartDate.daysBetween(contrato.VigenciaFinal__c) + 1;
        periodoViagem = days > 1 ? String.valueOf(days) + ' dias' : String.valueOf(days) + ' dia';
        //SVEP-61 FIX01 FIM
        numeroProposta = (contrato.Proposta__r.Name).replace('-','.');
        vigenciaInicio = String.ValueOf(contrato.StartDate.format());
        vigenciaFinal = String.ValueOf(contrato.VigenciaFinal__c.format());
        dataEmissao = String.ValueOf(contrato.DataEmissao__c.format());
        
        //segurado
        nomeSegurado = segurado.Conta__r.Name;
         //LECVPV 189 - INICIO
        this.hasSocialName = String.isEmpty(segurado.Conta__r.NomeSocial__c) ? false : true;
        this.nomeSocial = segurado.Conta__r.NomeSocial__c;
         //LECVPV 189 - FIM
        if(Test.isRunningTest()){
            dataNascSegurado = system.today().addDays(-1).format();
        }else{
            dataNascSegurado = segurado.conta__r.PersonBirthdate.format();
        }
        if(segurado.Conta__r.cpf__c != null){
            docSegurado = segurado.conta__r.cpf__c;
        }else if(segurado.Conta__r.CPF__pc != null){
            docSegurado = segurado.Conta__r.CPF__pc;
        }else{
            docSegurado = segurado.Conta__r.Cnpj__c;
        }
        emailSegurado = contrato.Account.PersonEmail;

        // PLV-4848 INICIO
        enderecoSegurado =          segurado.logradouroResidencial__c + ', ' + segurado.numeroResidencial__c; //PLV-4816 - INÍCIO/FIM
        bairroSegurado =            segurado.bairroResidencial__c;
        cidadeSegurado =            segurado.CidadeResidencial__c;
        estadoSegurado =            segurado.UFResidencial__c;
        complementoSegurado =       segurado.ComplementoResidencial__c;
        cepSegurado =               segurado.cepResidencial__c;
        // PLV-4848 FIM

        //corretor
        corretorLider = corretor.Conta__r.Name;
        telCorretor = corretor.Conta__r.phone;
        susepPortoCorretor = corretor.Susep__c;
        emailCorretor = corretor.Conta__r.email__c;
        susepOficialCorretor = corretor.SusepOficialCorretor__c;
        
        //coberturas
        if(lWrapGarantiaContratante.isEmpty()){
            lWrapGarantiaContratante = new List<wrapGarantiaContratante>();
            for(GarantiaContratanteContrato__C gcc: garantiaContratanteContrato){
                
                lWrapGarantiaContratante.add(new wrapGarantiaContratante(gcc));
                
                
                system.debug('TAMANHO DA lWrapGarantiaContratante:::'+lWrapGarantiaContratante.size());
                system.debug('lWrapGarantiaContratante::: valores: '+lWrapGarantiaContratante);
                

            }
            if(lWrapGarantiaContratante.size()==1 ){
                for(wrapGarantiaContratante a: lWrapGarantiaContratante){
                    if(a.codigoRamoCobertura ==null)
                        lWrapGarantiaContratante.clear();
                    break;
                }                    
            }           
        }
        //assitencia e beneficios
        if(lWrapAssistenciasBeneficios.isEmpty()){
            Decimal Aux = 0;

            lWrapAssistenciasBeneficios = new List<wrapAssistenciasBeneficios>();
            
            for(garantiaContratanteContrato__c assist: assistenciasBeneficios){
                
                lWrapAssistenciasBeneficios.add(new wrapAssistenciasBeneficios(assist));
                if(assist.PremioTotal__c != null){
                    Aux = Aux + assist.PremioTotal__c;
                }else{
                    Aux= Aux+0;
                }
            }
            //PLV-3884 - INICIO  Ajuste para moeda
            valorTotalAssistenciaConvert = Aux != null ? trataValores(Aux.format(), 'BRL') :'R$ 0,00';
            //PLV-3884 - FIM
            
            system.debug('lWrapAssistenciasBeneficios size::'+lWrapAssistenciasBeneficios.size());
            if(lWrapAssistenciasBeneficios.size()==1 && lWrapAssistenciasBeneficios[0].tipoAssistencia == null && lWrapAssistenciasBeneficios[0].validadeAssistencia == null){
                system.debug('entrou no clear');
                    lWrapAssistenciasBeneficios.clear();
            }
        } 
        
        
        //beneficiario
        if(lWrapBeneficiarios.isEmpty()){
            
            lWrapBeneficiarios = new List<wrapBeneficiarios>();
            
            for(BeneficiarioSeguradoContrato__c bene: beneficiarios){
                
                lWrapBeneficiarios.add(new wrapBeneficiarios(bene));
                
            }
            system.debug('lWrapBeneficiarios:: '+lWrapBeneficiarios);
        }
        
        //valores e pagamentos
        //PLV - 3884 Inicio Ajuste Moeda
        Decimal premioTotalContrato = contrato.PremioTotal__c!=null?contrato.PremioTotal__c.setScale(2):0;
        Decimal valorTotalF = premioTotalContrato!=null?premioTotalContrato:0;
        Decimal valorLiquidoTotalBeneficiario  = contrato.PremioComercial__c !=null ? contrato.PremioComercial__c : 0;
        Decimal totalIofParcela = premioTotalContrato - valorLiquidoTotalBeneficiario;

        qtdParcelas = contratante.QuantidadeParcelas__c;
        valorParcela = valorTotalF > 0 ? qtdParcelas != null ? trataValores(((Decimal)valorTotalF/qtdParcelas).SetScale(2).format(), 'BRL'):'0' : '-'; //PLV - 4947 INICIO/FIM
        formaPagamento = contratante.FormaPagamento__r.name;
        valorLiquidoTotal = trataValores(contrato.PremioComercial__c.format(), 'BRL'); 
        valorIof = contratante.IOF__c != null?trataValores(contratante.IOF__c.format(), 'BRL') : 'R$ 0,00';
        valorTotalS = contratante.PremioTotal__c!=null?trataValores(contratante.PremioTotal__c.format(), 'BRL'):'R$ 0,00';        
       
        //valorIofSegurado = segurado.IOF__c != null? trataValores(segurado.IOF__c.format(), 'BRL') : 'R$ 0,00';
        
        
        periocidadePagamento = 'Mensal';	
        //PLV - 3884 FIM Ajuste Moeda

        //AV-86 INICIO
        exibirPagamentos = !codigoProduto.toUpperCase().equals('VIAGEM-PRATA'); 
        Boolean isViagemVidaON = codigoProduto.toUpperCase().equals('VIAGEM-PRATA');
        this.ocultarObservacaoVidaOn = !isViagemVidaON;
        this.exibirObservacaoVidaOn = isViagemVidaON;
        this.ocultarCoberturasVidaOn = !isViagemVidaON;
        this.exibirCoberturasVidaOn = isViagemVidaON;
        //AV-86 FIM

    	//PLV - 4250 inicio
        Set<Id> garantiaProdutoId = new Set<Id>();
        for(GarantiaContratanteContrato__c g: garantiaContratanteContrato){
            garantiaProdutoId.add(g.GarantiaProduto__c);
        }
        system.debug('garantiaProdutoId: '+garantiaProdutoId);
        garantiaProduto = [SELECT Id, toLabel(ambitoTerritorial__c),CaracteristicaGarantia__c FROM GarantiaProduto__c WHERE Id IN:garantiaProdutoId AND CaracteristicaGarantia__c = 'Principal' Limit 1]; 
        //disposições gerais

        ambitoTerritorial = garantiaProduto.ambitoTerritorial__c;
        //PLV - 4250 fim     
        //condições gerais
        data = contrato.DataEmissao__c.format();
        local = 'São Paulo';        
        
        contract contrato1 = [ SELECT ID, NUMEROAPOLICE__C, Sucursal__c FROM CONTRACT WHERE ID =: CONTRATO.ID];
        system.debug('Sucursal__c :'+contrato1.Sucursal__c);
    }
    public class wrapGarantiaContratante{
        
        //Variaveis coberturas
        public String nomeCobertura {get; set;}
        public String validadeCobertura {get; set;}
        public String capitalSeguradoCobertura {get; set;} 
        public String codigoRamoCobertura {get;set;}
        public String valorSeguroCobertura {get;set;}
        public Decimal Ordem {get;set;}

        public wrapGarantiaContratante(garantiaContratanteContrato__c gcc){
            
            if(gcc.GarantiaProduto__r.TipoGarantia__c == 'Cobertura'){
                
                codigoRamoCobertura = gcc.GarantiaProduto__r.RamoSeguro__r.Codigo__c;
                system.debug('SIGLA:: '+gcc.Garantia__r.Sigla__c);
                system.debug('ID::'+gcc.Garantia__c);
                if(gcc.Garantia__r.Sigla__c == 'IPA'){
                    nomeCobertura = gcc.Garantia__r.Name+' até (*)';
                }else{
                    nomeCobertura = gcc.Garantia__r.Name;
                }           	
                // PLV-3882 - INICIO
                if(nomeCobertura == 'Cancelamento de Viagem'){
                    if(gcc.GarantiaProduto__r.VigenciaGarantia__c == 'Mesma da apólice')
                        validadeCobertura = gcc.ContratanteContrato__r.Contrato__r.startDate.format() +' - '+gcc.ContratanteContrato__r.Contrato__r.VigenciaFinal__c.format() ;
                    else if(gcc.GarantiaProduto__r.VigenciaGarantia__c == 'Contratação até fim da apólice')
                    validadeCobertura = gcc.ContratanteContrato__r.Contrato__r.DataEmissao__c.format() + ' - ' + gcc.ContratanteContrato__r.Contrato__r.VigenciaFinal__c.format() ;
                    else if(gcc.GarantiaProduto__r.VigenciaGarantia__c == 'Contratação até início da apólice')
                    validadeCobertura = gcc.ContratanteContrato__r.Contrato__r.DataEmissao__c.format() + ' - ' + gcc.ContratanteContrato__r.Contrato__r.startDate.format() ;
                    else
                        validadeCobertura = gcc.ContratanteContrato__r.Contrato__r.startDate.format() +' - '+gcc.ContratanteContrato__r.Contrato__r.VigenciaFinal__c.format() ;
                }else{
                    validadeCobertura = gcc.ContratanteContrato__r.Contrato__r.startDate.format() +' - '+gcc.ContratanteContrato__r.Contrato__r.VigenciaFinal__c.format() ;
                }
                // PLV-3882 - FIM

                
                
                //PLV - 3884 Inicio Ajuste Moeda 
                capitalSeguradoCobertura = gcc.Capital__c != null ? ApoliceController.trataValores(gcc.Capital__c.format(), gcc.CurrencyIsoCode) : null;
               	//PLV - 3884 fim Ajuste Moeda
                 
                if(gcc.GarantiaProduto__r.TipoCaracteristicaEspecial__c != null){
                    capitalSeguradoCobertura = capitalSeguradoCobertura +' ('
                        +gcc.GarantiaProduto__r.LimiteMinimoCaracteristicaEspecial__c+' - '
                        +gcc.GarantiaProduto__r.LimiteMaximoCaracteristicaEspecial__c+ ' '+
                        +gcc.GarantiaProduto__r.TipoCaracteristicaEspecial__c+ ')';
                }
                
                //PLV-3884 - INICIO 
                valorSeguroCobertura = gcc.PremioTotal__c != null ? ApoliceController.trataValores(gcc.PremioTotal__c.format(), 'BRL') : ' - ';
                //PLV-3884 - FIM
                
                Ordem = gcc.GarantiaProduto__r.OrdemPrioridade__c;
            }
        }

    }
    public class wrapAssistenciasBeneficios{
        
        
        //Variaveis Assistências e beneficios
        public String nomeAssistencia {get;set;}
        public String validadeAssistencia {get;set;}
        public String valorAssistencia {get;set;}
        public String tipoAssistencia {get;set;}
        
       public wrapAssistenciasBeneficios(garantiaContratanteContrato__c assist){
             
           system.debug('assist: '+assist.Id);
           system.debug('assisttype: '+assist.GarantiaProduto__r.tipoGarantia__C);
           system.debug('assist preimiototal: '+assist.PremioTotal__c);

           if(assist.GarantiaProduto__r.TipoGarantia__c == 'Assistência' || assist.GarantiaProduto__r.TipoGarantia__c == 'Benefício'){
               system.debug('Adicionou');
                if(assist.Garantia__r.Sigla__c == 'IPA'){
                    nomeAssistencia = assist.Garantia__r.Name+' até (*)';
                }else{
                    nomeAssistencia = assist.Garantia__r.Name;
                }    
                tipoAssistencia = assist.GarantiaProduto__r.TipoGarantia__c;

                // PLV-3882 - INICIO
                if(nomeAssistencia == 'Porto Viaje Bem'){
                    if(assist.GarantiaProduto__r.VigenciaGarantia__c == 'Mesma da apólice')
                        validadeAssistencia = assist.ContratanteContrato__r.Contrato__r.startDate.format() +' - '+assist.ContratanteContrato__r.Contrato__r.VigenciaFinal__c.format();
                    else if(assist.GarantiaProduto__r.VigenciaGarantia__c == 'Contratação até fim da apólice')
                    validadeAssistencia = assist.ContratanteContrato__r.Contrato__r.DataEmissao__c.format() + ' - ' + assist.ContratanteContrato__r.Contrato__r.VigenciaFinal__c.format() ;
                    else if(assist.GarantiaProduto__r.VigenciaGarantia__c == 'Contratação até início da apólice')
                    validadeAssistencia = assist.ContratanteContrato__r.Contrato__r.DataEmissao__c.format() + ' - ' + assist.ContratanteContrato__r.Contrato__r.startDate.format() ;
                    else
                        validadeAssistencia = assist.ContratanteContrato__r.Contrato__r.startDate.format() +' - '+assist.ContratanteContrato__r.Contrato__r.VigenciaFinal__c.format();
                }else{
                    validadeAssistencia = assist.ContratanteContrato__r.Contrato__r.startDate.format() +' - '+assist.ContratanteContrato__r.Contrato__r.VigenciaFinal__c.format();
                }
                // PLV-3882 - FIM
                
                
                //PLV-3884 - INICIO Ajuste Moeda
                valorAssistencia = assist.PremioTotal__c != null ?ApoliceController.trataValores(assist.PremioTotal__c.format(), 'BRL') : ' - ';
                //PLV-3884 - FIM Ajuste Moeda
                
            }
        }
    }   
    public class wrapBeneficiarios{
        
        public String nomeBeneficiario {get; set;}
        public String nomeSocialBeneficiario {get; set;} //LECVPV 189-FIX02 - INICIO/FIM
        public String tipoBeneficiario {get;set;}
        public String grauParentesco {get; set;}
        public String participacao {get; set;}
        
        public wrapBeneficiarios(BeneficiarioSeguradoContrato__c bsc){
            
            //para o viagem não há nome então deve-se trazer o tipo.
            tipoBeneficiario = bsc.TipoBeneficiario__c;
            nomeBeneficiario = bsc.Nome__c;
            nomeSocialBeneficiario = bsc.NomeSocial__c; //LECVPV 189-FIX02 - INICIO/FIM
            grauParentesco = bsc.GrauParentesco__c;
            participacao = bsc.Participacao__c != null ? string.ValueOf(bsc.Participacao__c).replace('.',',') : null;
            
        }
    }    
    
    public PageReference doAction(){
        return new PageReference('/');
    }
    
    //PLV-3884 - INICIO - Ajuste nas moedas estrangeiras
    public static String trataValores(string valor, string moeda){
        if(valor.contains(',')){
            string v = valor.substring(valor.indexOf(','),valor.length());
            if(v.length() == 2){
                if(moeda == 'BRL'){
                    valor = 'R$ '+valor +'0'; 
                }else if(moeda == 'USD'){
                    valor = 'US$ '+valor +'0';
                }else If(moeda == 'EUR'){
                    valor = '€ '+valor +'0';
                }
            }else{
                if(moeda == 'BRL'){
                    valor = 'R$ '+valor; 
                }else if(moeda == 'USD'){
                    valor = 'US$ '+valor;
                }else If(moeda == 'EUR'){
                    valor = '€ '+valor;
                }
            }
        }else if (valor.contains('.')){ 
            string v = valor.substring(valor.indexOf('.'),valor.length());
            if(v.length() == 2){
                if(moeda == 'BRL'){
                    valor = 'R$ '+valor +'0'; 
                }else if(moeda == 'USD'){
                    valor = 'US$ '+valor +'0';
                }else If(moeda == 'EUR'){
                    valor = '€ '+valor +'0';
                }
            }else{
                if(moeda == 'BRL'){
                    valor = 'R$ '+valor+',00'; 
                }else if(moeda == 'USD'){
                    valor = 'US$ '+valor+',00';
                }else If(moeda == 'EUR'){
                    valor = '€ '+valor+',00';
                }
            }
        }else{
            if(moeda == 'BRL'){
                valor = 'R$ '+valor+',00';
            }else if(moeda == 'USD'){
                valor = 'US$ '+valor+',00';
            }else If(moeda == 'EUR'){
                valor = '€ '+valor+',00';
            }            
        }
        
        return valor;
    }
    //PLV-3884 - FIM - Ajuste nas moedas estrangeiras
    public ApexPages.StandardController stdController {get; set;}
    /*public pageReference downloadPdf() {
        if (!Test.isRunningTest()) {//when accessing by a record
            if (ApexPages.currentPage().getParameters().get('doNotSavePDF') == null) {
                ApexPages.currentPage().getParameters().put('doNotSavePDF', 'true');
                Blob certificatePdf = ApexPages.currentPage().getContent();
                System.debug('certificatepdf henrique: ' +certificatePdf );
                Attachment file = new Attachment(parentId = stdController.getId(), Name='test.pdf', body=certificatePdf);
                insert file;
            }
        
            PageReference page = stdController.view();
            page.setRedirect(true);
            return page;
        }
        else {return null;}
    }*/
}