// PLV - 4014 inicio
public class EndossoPageController {
    
    private final String TIPOPROPOSTA_CANCELAMENTO = 'Cancelamento'; //PLV-5133 - INICIO/FIM

    public String renderAs { get; private set; }
    public Contract contrato {get; private set; }
    public ContratanteContrato__c contratante {get; private set;}
    public ContratanteContrato__c contratanteOriginal {get; private set;}//plv-4014 fix 2 inicio/fim
    
    //public Endereco__c endereco {get; private set;} //PLV-4847 - Inicio/Fim
    public GrupoContrato__c grupo {get; private set;}
    public SeguradoContrato__c segurado {get; private set;}
    public Contract contratoOriginal { get; private set;} //plv-4014 fix 1 inicio/fim
    public FavorecidoRemuneracaoContrato__c corretor {get; private set;}
    //header
    public String nomeProduto       {get; set;}
    public String registroSusep     {get; set;} // RVI-98-INICIO/FIM
    public String nomeEmpresa       {get; set;} // RVI-98-INICIO/FIM
    public String cnpjEmpresa       {get; set;} // RVI-98-INICIO/FIM
    public String nome1             {get; set;} // RVI-98-INICIO/FIM
    public String cargo1            {get; set;} // RVI-98-INICIO/FIM
    public String descricaoCargo1   {get; set;} // RVI-98-INICIO/FIM
    public String nome2             {get; set;} // RVI-98-INICIO/FIM
    public String cargo2            {get; set;} // RVI-98-INICIO/FIM
    public String descricaoCargo2   {get; set;} // RVI-98-INICIO/FIM
    public String numeroSusep       {get; set;}
    public String numeroApolice     {get; set;}
    public String origemViagem      {get; set;}
    public String destinoViagem     {get; set;}
    public String periodoViagem     {get; set;}
    public String numeroProposta    {get; set;}
    public String vigenciaInicio    {get; set;}
    public String vigenciaFinal     {get; set;}
    public String dataEmissao       {get; set;}
    //public String tipoEndosso       {get; set;} //PLV-4459 - INICIO/FIM  //PLV-5133 - INICIO/FIM
    public String descrTipoEndosso  {get; set;} //PLV-5133 - INICIO/FIM
    public Boolean isViagem         {get; set;} //PLV-5052 - INICIO/FIM
    //Dados do Segurado
    public String nomeSegurado {get; set;}
    public String emailSegurado {get; set;}
    public String enderecoSegurado {get; set;}
    public String bairroSegurado {get; set;}
    public String cidadeSegurado {get; set;}
    public String estadoSegurado {get; set;}
    public String complementoSegurado {get; set;}
    public String docSegurado {get; set;}
    public String cepSegurado {get; set;}
    public String dataNascSegurado {get; set;}
    //Dados do Corretor
    public String corretorLider {get; set;}
    public String telCorretor {get; set;}
    public String susepPortoCorretor {get; set;}
    public String emailCorretor {get; set;}
    public String susepOficialCorretor {get; set;}
    //demonstrativo do premio e vigencia
    public String vigenciaApolice {get; set;}
    public String vigenciaPremioPago {get; set;}
    public String dataCancelamento {get; set;}
    public String periodoRestituir {get; set;} 
    public String premioPago {get; set;}
    public String premioRestituir {get; set;} 
    //Disposições Gerais
    //Condições Gerais
    public String data {get;set;}
    public String local {get;set;}

    //Textos
    public String fraseDescritiva { get; set; }  //PLV-5133 - INICIO/FIM

    //LECVPV 189 - INICIO
    public Boolean hasSocialName                {get; set;} 
    public String  nomeSocial                   {get; set;}
    //LECVPV 189 - FIM
    
    public EndossoPageController() {
        
        List<String> lGarantias = new List<String>();
        List<Parcelas> lstParcelas = new List<Parcelas>();
        
        
        Map<String,String> mPageParam = ApexPages.currentPage().getParameters();
        this.renderAs = mPageParam.containsKey('renderAs') ?  mPageParam.get('renderAs') : '';
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
        //PLV-5052 INICIO
        contrato = [
            SELECT 
                Id,
                Name,
                IdExterno__c,
                NumeroApolice__c,
                Tipo__c,
                Sucursal__c,
                CodigoRamo__c,
                DataEmissao__c,
                StartDate,
                VigenciaFinal__c,
                PremioIntegral__c, //PLV-5351 INICIO/FIM
                PremioTotal__c,
                PremioComercial__c,
                Origem__c,
                PaisesDestino__c,
                Account.Name,
                Account.PEP__pc,
                Account.Sexo__pc,
                Account.CPF__pc,
                Account.PersonBirthdate,
                Account.PersonEmail,
                Account.PersonMobilePhone,
                Account.BillingStreet,
                Account.BillingCity,
                Account.BillingState,
                Account.BillingPostalCode,
                Account.BillingCountry,
                Seguradora__r.Cnpj__c,
                Produto__r.Name,
                Produto__r.Segmento__c,
                Produto__r.RegistroSusep__c, // RVI-98-INICIO/FIM
                Produto__r.Empresa__r.Name, // RVI-98-INICIO/FIM
                Produto__r.Empresa__r.Cnpj__c, // RVI-98-INICIO/FIM
                Produto__r.NumeroSusep__c,
                Proposta__r.QuoteNumber,
                Proposta__r.email,Proposta__r.Name,
               //PLV-5133 - INICIO    
               //TipoEndosso__c,
                Proposta__r.Tipo__c, 
                Proposta__r.TipoEndosso__c,
                Empresa__c,   
                Proposta__r.RamoSeguro__r.Codigo__c,
                //PLV-5133 - FIM
                (SELECT Id FROM RemuneracoesContrato__r WHERE TipoRemuneracao__r.Codigo__c = 'COR')
            FROM Contract
            WHERE Id = : contratoID
        ];  
        //PLV-5052 FIM
        if (contrato == null || contrato.RemuneracoesContrato__r == null || contrato.RemuneracoesContrato__r.isEmpty()) {return;}
        
        
        
        //informações de corretor
        corretor = [SELECT Id, Conta__r.Name, Conta__r.Phone, Conta__r.PersonEmail, 
                    DadosCorretor__r.Name, CorretorLider__c, Conta__r.SusepPrincipal__c,
                    Conta__r.Email__c, Conta__r.CodigoSusepCorretor__c, Name, Susep__c, SusepOficialCorretor__c
                    FROM FavorecidoRemuneracaoContrato__c
                    WHERE RemuneracaoContrato__c = :contrato.RemuneracoesContrato__r.get(0).Id
                    AND CorretorLider__c = true];     
        
        //PLV-4847 - Inicio
        /*
        endereco	 =[SELECT Id, TipoEndereco__c, Bairro__c, Cidade__c, logradouro__c,
                       Estado__c, Complemento__c, CEP__c,Numero__c
                       FROM Endereco__c where Conta__c =: contrato.AccountId AND MaisAtual__c = true limit 1];
        */
        //PLV-4847 - Fim
        
        //informações de contratante
        contratante = [SELECT Id, FormaPagamento__r.name, PremioComercial__c, PremioIntegral__c, //PLV-5351 INICIO/FIM
                       IOF__c, PremioTotal__c, QuantidadeParcelas__c
                       FROM ContratanteContrato__c
                       WHERE Contrato__c =: contrato.Id];
        
        grupo = [SELECT Id
                 FROM GrupoContrato__c
                 WHERE ContratanteContrato__c =: contratante.Id];
        
        //PLV - 4847- Inicio
        segurado = [SELECT  Id, Conta__r.Name, conta__r.cpf__c, conta__r.Email__c, 
                            conta__r.BillingStreet, conta__r.BillingCity, conta__r.BillingState, 
                            conta__r.BillingPostalCode, conta__r.PersonBirthdate, logradouroResidencial__c, 
                            numeroResidencial__c, ComplementoResidencial__c, cepResidencial__c, BairroResidencial__c, 
                            UFResidencial__c, CidadeResidencial__c, paisResidencial__c,
                            Conta__r.NomeSocial__c //LECVPV 189 - INICIO/FIM  
                    FROM    SeguradoContrato__c
                    WHERE   GrupoContrato__c =: grupo.Id];
        //PLV - 4847- Fim
        
        //plv-4014 fix 1 inicio
        //PLV-5133 - INICIO
        String nomeContratoOriginal = ContractDAO.getInstance().buscarNameUltimoContratoNaoCad(
                    contrato.NumeroApolice__c, 
                    contrato.Empresa__C, 
                    contrato.Sucursal__c, 
                    contrato.Proposta__r.RamoSeguro__r.Codigo__c); 
        //PLV-5133 - FIM
        
        system.debug('nome contrato: '+nomeContratoOriginal);
        
        contratoOriginal = [SELECT Id, DataEmissao__c, StartDate, VigenciaFinal__c, Tipo__c,CodigoRamo__c,
                            Account.Name, Account.PEP__pc, Account.Sexo__pc, PremioTotal__c, PremioIntegral__c, //PLV-5351 INICIO/FIM
                            Sucursal__c,
                            Account.CPF__pc, Account.PersonBirthdate, Account.PersonEmail,
                            Account.PersonMobilePhone, Account.BillingStreet, IdExterno__c,
                            Account.BillingCity, Account.BillingState, PremioComercial__c,
                            Account.BillingPostalCode, Account.BillingCountry, Seguradora__r.Cnpj__c,
                            Produto__r.name, NumeroApolice__c, Origem__c, PaisesDestino__c, Proposta__r.QuoteNumber,
                            Produto__r.NumeroSusep__c, Name,  Proposta__r.email,Proposta__r.Name, toLabel(TipoEndosso__c), //PLV-4459 - INICIO/FIM
                            (SELECT Id FROM RemuneracoesContrato__r WHERE TipoRemuneracao__r.Codigo__c = 'COR')
                            FROM Contract
                            WHERE Name =: nomeContratoOriginal ];
        
        //plv-4014 fix 2 inicio
        contratanteOriginal = [SELECT Id, FormaPagamento__r.name, PremioComercial__c, PremioIntegral__c, //PLV-5351 INICIO/FIM
                               IOF__c, PremioTotal__c, QuantidadeParcelas__c
                               FROM ContratanteContrato__c
                               WHERE Contrato__c =: contratoOriginal.Id];
        //plv-4014 fix 2 inicio
        
        
        //valores contrato original
        String vigenciaInicialOriginal = String.ValueOf(contratoOriginal.StartDate.format());
        String vigenciaFinalOriginal = String.ValueOf(contratoOriginal.VigenciaFinal__c.format());
        String destinoOriginal = contratoOriginal.PaisesDestino__c;
        //plv-4014 fix 1 fim
        nomeProduto = contrato.Produto__r.Name;
        numeroSusep = contrato.Produto__r.NumeroSusep__c; 
        numeroApolice = contrato.Sucursal__c+'.'+contrato.CodigoRamo__c+'.'+contrato.NumeroApolice__c;
        registroSusep = contrato.Produto__r.RegistroSusep__c; // RVI-98-INICIO/FIM
        nomeEmpresa = contrato.Produto__r.Empresa__r.Name; // RVI-98-INICIO/FIM
        cnpjEmpresa = contrato.Produto__r.Empresa__r.Cnpj__c; // RVI-98-INICIO/FIM
        origemViagem = 'Brasil';
        destinoViagem = destinoOriginal;//plv-4014 fix 1 inicio/fim
        Integer periodoI = (contratoOriginal.StartDate).daysBetween(contratoOriginal.VigenciaFinal__c)+1; //PLV-4154 FIX - INICIO/FIM
        periodoViagem = String.ValueOf(((contratoOriginal.StartDate).daysBetween(contratoOriginal.VigenciaFinal__c)+1)) +' Dias(s)'; //PLV-4154 - INICIO/FIM - Alterado para data do contrato original
        numeroProposta = (contrato.Proposta__r.Name).replace('-','.');
        vigenciaInicio = vigenciaInicialOriginal;//plv-4014 fix 1 inicio/fim
        vigenciaFinal = vigenciaFinalOriginal;//plv-4014 fix 1 inicio/fim
        dataEmissao = String.ValueOf(contrato.DataEmissao__c.format());
        //tipoEndosso = contrato.TipoEndosso__c;//PLV-4459 - INICIO/FIM //PLV-5133 - INICIO/FIM
        descrTipoEndosso = buscarDescrTipoEndosso(contrato.Proposta__r.TipoEndosso__c); //PLV-5133 - INICIO/FIM
        // RVI-98-INICIO
        Map<String,dadosDocumentosPDF__mdt> assinatura = contractDAO.getInstance().buscarAssinatura();
        cargo1 = assinatura.get('Assinatura1').Cargo__c;
        descricaoCargo1 = assinatura.get('Assinatura1').Descricao_do_cargo__c;
        nome1 = assinatura.get('Assinatura1').Nome__c;
        cargo2 = assinatura.get('Assinatura2').Cargo__c;
        descricaoCargo2 = assinatura.get('Assinatura2').Descricao_do_cargo__c;
        nome2 = assinatura.get('Assinatura2').Nome__c;
        // RVI-98-FIM

        System.debug('Assinatura1 ' + assinatura.get('Assinatura1'));
        System.debug('Assinatura2 ' + assinatura.get('Assinatura2'));


        nomeSegurado = segurado.Conta__r.Name;

        //LECVPV 189 - INICIO
        this.hasSocialName = String.isEmpty(segurado.Conta__r.NomeSocial__c) ? false : true;
        this.nomeSocial = segurado.Conta__r.NomeSocial__c;
         //LECVPV 189 - FIM

        isViagem = contrato.Produto__r.Segmento__c == 'Viagem';//PLV-5052 - INICIO/FIM

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

        //PLV-4847 - Inicio
        enderecoSegurado    = segurado.logradouroResidencial__c + ', ' + segurado.numeroResidencial__c;
        bairroSegurado      = segurado.BairroResidencial__c;
        cidadeSegurado      = segurado.CidadeResidencial__c;
        estadoSegurado      = segurado.UFResidencial__c;
        complementoSegurado = segurado.ComplementoResidencial__c;
        cepSegurado         = segurado.cepResidencial__c;

        //PLV-4847 - Fim
        
        //corretor
        corretorLider = corretor.Conta__r.Name;
        telCorretor = corretor.Conta__r.phone;
        susepPortoCorretor = corretor.Susep__c;
        emailCorretor = corretor.Conta__r.email__c;
        susepOficialCorretor = corretor.SusepOficialCorretor__c;
        
		//plv-4014 fix 9 inicio
        //demonstrativo do premio e vigencia inicio
        Decimal valorRestituir = 0;
        Decimal valorPago = 0;
        Decimal valorTotal = 0;
        integer numeroParcelasPagas = 0;
        //PLV-4588-INICIO
        ParcelamentoContratoTO retornoParcelas = ContractFacade.getInstance().ObterParcelasContratoSegurado(contratante.Id);
        ParcelamentoContratoTO retornoParcelasOriginal = ContractFacade.getInstance().ObterParcelasContratoSegurado(contratanteOriginal.Id);
        
        if(mPageParam.containsKey('retornoParcelas')){
            
            system.debug('mPageParam: '+mPageParam);
            
            String retornoParcela = mPageParam.get('retornoParcelas');
            String retornoParcelaOriginal = mPageParam.get('retornoParcelasOriginal'); 
            
            system.debug('retornoParcela: '+retornoParcela);
            system.debug('retornoParcelaOriginal: '+retornoParcelaOriginal);
            if(retornoParcela != null && retornoParcela != ''){
                ParcelaEndosso parcela = ParcelaEndosso.parse(retornoParcela);
                system.debug('t: '+parcela.data);
                for(integer i = 0; i<parcela.data.size(); i++){
                    if(parcela.data[i].status == 'ARESTITUIR'){
                        valorRestituir += decimal.ValueOf(parcela.data[i].valorParcela); // PLV - 3298 Inicio/fim
                    }
                }
            }
            if(retornoParcelaOriginal != null && retornoParcelaOriginal != ''){
                ParcelaEndosso parcela = ParcelaEndosso.parse(retornoParcelaOriginal);
                system.debug('t: '+parcela.data);
                for(integer i = 0; i<parcela.data.size(); i++){
                    if(parcela.data[i].status == 'PAGA'){
                        valorPago += decimal.ValueOf(parcela.data[i].valorParcela);
                        numeroParcelasPagas ++; 
                    }
                    valorTotal += decimal.ValueOf(parcela.data[i].valorParcela);
                }
            }
            
            
            
        }else{
            Parcelas parcela 	= new Parcelas();
            ParcelamentoContratoTO retornoContranteOriginal = ContractFacade.getInstance().ObterParcelasContratoSegurado(contratanteOriginal.id);
            
            if(!retornoContranteOriginal.data.isEmpty())
            {
                for(ParcelamentoContratoTO.DataTO item: retornoContranteOriginal.data)
                {
                    if(item.status == 'PAGA'){
                        valorPago += decimal.ValueOf(item.valorParcela);
                        numeroParcelasPagas ++;
                    }
                    valorTotal += decimal.ValueOf(item.valorParcela);
                }
            }
            system.debug('retornoContranteOriginal: '+retornoContranteOriginal);
            
            
            ParcelamentoContratoTO retorno = ContractFacade.getInstance().ObterParcelasContratoSegurado(contratante.id);
            
            
            system.debug('retoro: '+retorno);
            
            if(!retorno.data.isEmpty())
            {
                for(ParcelamentoContratoTO.DataTO item: retorno.data)
                {
                    if(item.status == 'A RESTITUIR'){
                        valorRestituir += decimal.ValueOf(item.valorParcela); // PLV - 3298 Inicio/fim
                    }
                }
            }
        }
        vigenciaApolice = vigenciaInicio +' a '+vigenciaFinal;
        dataCancelamento = String.valueOf(contrato.StartDate.format()); //PLV-4154 - INICIO/FIM - Ajuste na data de cancelamento
        
		//PLV-4154 FIX - INICIO	
        Integer numeroParcelas = Integer.ValueOf(contratanteOriginal.QuantidadeParcelas__c);
        Decimal numeroParcelasD = Decimal.ValueOf(numeroParcelas); 
        system.debug('numeroParcelasD: '+numeroParcelasD);
        //Dias entre vigencia inicial e final
        system.debug('vigenciaInicio: '+vigenciaInicio);
        system.debug('vigenciaFinal: '+vigenciaFinal);
        Decimal numeroDias = date.parse(vigenciaInicio).daysBetween(date.parse(vigenciaFinal));
        system.debug('numeroDias: '+numeroDias);
        numeroDias = numeroDias + 1; 
        system.debug('numeroDias: '+numeroDias);
        //Pegar o resultado do numeroDias e dividir pelo numero de parcelas total
        Decimal resultadoNumeroParcelas = numeroDias/numeroParcelasD;
        system.debug('resultadoNumeroParcelas: '+resultadoNumeroParcelas);
        //Pegar o resultado do resultadoNumeroParcelas e multiplicar pelo numero de parcelas pagas, para obter os dias de parcelas pagas
        Decimal resultadoNumeroParcelasPagas = (resultadoNumeroParcelas*numeroParcelasPagas);
        system.debug('numeroParcelasPagas: '+numeroParcelasPagas);
        system.debug('resultadoNumeroParcelasPagas: '+resultadoNumeroParcelasPagas);
        //vigencia do premio pago é o inicio da vigencia ate o "inicio da vigencia mais os dias pagos"
        //PLV 4154 - ajuste 05/08 inicio 
        vigenciaPremioPago = resultadoNumeroParcelasPagas == 0 ? '' : vigenciaInicio +' a '+ ((date.parse(vigenciaInicio).addDays(integer.ValueOf(resultadoNumeroParcelasPagas))) > date.parse(vigenciaFinal)? vigenciaFinal : (date.parse(vigenciaInicio).addDays(integer.ValueOf(resultadoNumeroParcelasPagas))).format()); // PLV - 4154 INICIO/FIM
        system.debug('vigenciaPremioPago: '+vigenciaPremioPago);
        //data do cancelmaneto é a data da emissão do novo contrato
        Date datacanc = date.parse(contrato.StartDate.format()); // PLV - 4154 INICIO/FIM alterado data cancelamento para data de inicio do contrato de endosso
        system.debug('datacanc: '+datacanc);
        //Calculo do numero de dias usado - valor entre inicio  da vigencia e dia do cancelamento
        Integer diasUsados = date.parse(vigenciaInicio).daysBetween(datacanc);
        system.debug('diasUsados: '+diasUsados);
        //Se valor pago for maior que 0 (ou seja foi pago algum valor), o periodo será preenchido
        Integer periodoR = 0;
        // Se a data de cancelamento for menor que a vigência (ou seja não foi usado o seguro) mas foi pago os dias a restituir são os mesmo dias de parcelas pagas
        // Se a data de cancelamento foi maior ou igual a vigência ele será restituido dos dias não usado, mas que foram pagos
        if(datacanc < date.parse(vigenciaInicio)){
            if(resultadoNumeroParcelasPagas ==0){
                periodoR = 0;
            }else{
                // se o periodoR for maior que o periodo da viagem, o valor a inserir será o periodo da viagem 
                // primeira parte é dias entre data inicial e data inicial adicionando os dias PAGOS, 
                // se for menor que o periodo da viagem eu aprensento o valor, se for maior (por calculos de numeros quebrados)
                // adiciona o periodo da viagem que é o limite do periodoR.
                periodoR = date.parse(vigenciaInicio).daysBetween(date.parse(vigenciaInicio).addDays(integer.ValueOf(resultadoNumeroParcelasPagas))) < periodoI? date.parse(vigenciaInicio).daysBetween(date.parse(vigenciaInicio).addDays(integer.ValueOf(resultadoNumeroParcelasPagas))):periodoI ;
            }
        }else{
            if(resultadoNumeroParcelasPagas ==0){
                periodoR = 0;
            }else{
                periodoR = integer.ValueOf(resultadoNumeroParcelasPagas) - diasUsados;
            }
        }
        //periodoR = datacanc < date.parse(vigenciaInicio) ? resultadoNumeroParcelasPagas == 0 ? 0 : date.parse(vigenciaInicio).daysBetween(date.parse(vigenciaInicio).addDays(resultadoNumeroParcelasPagas)) : resultadoNumeroParcelasPagas == 0 ? 0 : resultadoNumeroParcelasPagas - diasUsados;
        system.debug('periodoR: '+periodoR);
        //Dias restituição
        periodoRestituir = periodoR == 0? 'Não há': periodoR+' dias ';
        system.debug('periodoRestituir: '+periodoRestituir);
        //Valor do premio que foi pago 
        premioPago = resultadoNumeroParcelasPagas == 0 ? trataValores('0', 'BRL') : trataValores(valorPago.format(), 'BRL');
        //PLV 4154 - ajuste 05/08  fim
        //Valor do premio que sera restituido
        premioRestituir = resultadoNumeroParcelasPagas == 0 ? 'Não há' : trataValores(valorRestituir.format(), 'BRL');
		//PLV-4154 FIX - INICIO/FIM
        system.debug('premioRestituir: '+premioRestituir);
        //demonstrativo do premio e vigencia fim
		//plv-4014 fix 9 fim
        //condições gerais
        data = contrato.DataEmissao__c.format();
        local = 'São Paulo';        
        
        contract contrato1 = [ SELECT ID, NUMEROAPOLICE__C, Sucursal__c FROM CONTRACT WHERE ID =: CONTRATO.ID];
        system.debug('Sucursal__c :'+contrato1.Sucursal__c);

        //PLV-5133 - INICIO
        //Textos
        fraseDescritiva = buscarFraseDescritiva(contrato);
        //PLV-5133 - FIM

    }

    //PLV-5133 - INICIO
    private String buscarFraseDescritiva(Contract contratoRef) {
        if (contratoRef.Proposta__r.Tipo__c == TIPOPROPOSTA_CANCELAMENTO) {
            return ((TipoDeEndosso__mdt) MetadataDAO.getInstance().buscarTipoEndosso(contratoRef.Proposta__r.TipoEndosso__c)).FrasePadrao__c;
        } else {
            //Para os outros tipos de Endossos usar frase padrão
            return Label.Endosso_Descricao_Padrao;
        }
    }

    // RVI-98-INICIO
    private static Map<String,dadosDocumentosPDF__mdt> buscarAssinatura(){
        List<dadosDocumentosPDF__mdt> assinaturas = [SELECT Cargo__c,Descricao_do_cargo__c,Nome__c,DeveloperName FROM dadosDocumentosPDF__mdt];
        Map<String,dadosDocumentosPDF__mdt> mapAssinatura = new Map<String,dadosDocumentosPDF__mdt>();
        for(dadosDocumentosPDF__mdt assinatura : assinaturas){
            mapAssinatura.put(assinatura.DeveloperName,assinatura);
        }
        return mapAssinatura;
    }
    // RVI-98-FIM

    private String buscarDescrTipoEndosso(String siglaTipoEndosso) {

        List<Schema.PicklistEntry> tiposEndosso = Quote.TipoEndosso__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry tipoEndosso: tiposEndosso) {
            if (tipoEndosso.getValue() == siglaTipoEndosso && tipoEndosso.isActive()) {
                return tipoEndosso.getLabel();
            }
        }

        return '';
    }
    //PLV-5133 - FIM
    
    public PageReference doAction(){
        return new PageReference('/');
    }
    public class Parcelas{
        public Integer id { get; set; }
        public String dataVencimento { get; set; }
        public String dataPagamentoParceiro { get; set; }
        public String numeroParcela { get; set; }
        public String titulo { get; set; }
        public String valorTotal { get; set; }
        public String valorIOF { get; set; }
        public String valorLiquido { get; set; }
        public String status { get; set; }
        
    }    
    
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
    
}
// PLV - 4014 FIM