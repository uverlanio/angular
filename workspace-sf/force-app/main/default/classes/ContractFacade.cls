/**
 * ContractFacade
 * @author Eric Tunú @ 08/08/2f018
 *
 **/
public with sharing class ContractFacade extends ServiceBase
{
    private String nomeEndpoint = 'ConsultarParcelasContrato';

    private static final ContractFacade instancia = new ContractFacade();
    public static ContractFacade getInstance(){ return instancia; }
    public static ContractBO bo = ContractBO.getInstance();
    private static HerokuService service = HerokuService.getInstance();
    private static Map<String, String> mapEstadoCivil = new Map<String, String>
    {
        'Casado (a)' => 'CAS',
        'Divorciado(a)' => 'DIV',
        'Solteiro (a)' => 'SOL',
        'Viúvo(a)' => 'VIU', 
        'Separado(a)' => 'SEP', 
        'União estável' => 'UNI'
    };

    //PLV-5033 INICIO
    @TestVisible
    private Map<Id, String> mapRenda {get;set;}  
    private Map<Id, String> mapExposta {get;set;} 
    //PLV-5033 FIM

    private ContractFacade() { }

    public Boolean atualizarParcelaContrato(Integer id, String status){

        ParcelaContratoTO parcelaContratoTO = new ParcelaContratoTO();
        parcelaContratoTO.id = id;
        parcelaContratoTO.status = status;

        return service.atualizarParcelaContrato(parcelaContratoTO);

    }

    public ParcelamentoContratoTO obterParcelasContratoSegurado(String id)
    {
        System.debug('ContractFacade>> ObterParcelasContratoSegurado');

        ParcelamentoContratoTO	objPayload = new ParcelamentoContratoTO(); //PLV-4949 FIX 1 - INÍCIO/FIM
        SeguradoContrato__c    segurado;
        ContratanteContrato__c     contratante;
        String                  chave;

        //identifica origem
        system.debug('ContractFacade >>ObterParcelasContratoSegurado >> id: ' + id);

        // Buscar dados do contratante
        try
        {
            contratante = ContratanteContratoDAO.getInstance().obterContratoPorId(id);
        }
        catch(Exception e)
        {
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
        }


        if(contratante == null) // Buscar parc3elas por segurado
        {
            segurado = SeguradoContratoDAO.getInstance().obterVida(id);
            System.debug('ContractFacade >>ObterParcelasContratoSegurado >> segurado '+ segurado);

            contratante = ContratanteContratoDAO.getInstance().obterContratoPorId(segurado.GrupoContrato__r.ContratanteContrato__c);
            System.debug('ContractFacade >>ObterParcelasContratoSegurado >> contratante '+ contratante);

            chave = contratante.Contrato__c + '_' + segurado.Id;
        }
        else                // Buscar parcelas por Contratante
        {
            System.debug('ContractFacade >>ObterParcelasContratoSegurado >> contratante '+ contratante);
            chave = contratante.Contrato__c + '_' +  contratante.Id;
        }

            System.debug('ContractFacade >>ObterParcelasContratoSegurado >> chave: '+ chave);

            if(!Test.isRunningTest()){
                //PLV-4949 FIX 3 - INÍCIO
                try{
                    objPayload = HerokuService.getInstance().consultarParcelasContrato(chave);
                }catch(Exception e){

                    List<public_parcelacontrato__x> parcelas = [ 
                        SELECT 
                        id__c, 
                        datavencimento__c,
                        numeroparcela__c, 
                        valoriof__c, 
                        valorliquido__c, 
                        idfatura__c, 
                        idexterno__c, 
                        status__c, 
                        valorparcela__c
                        FROM public_parcelacontrato__x WHERE idexterno__c = :chave
                    ];
                    ParcelamentoContratoTO parcelaToReturn = new ParcelamentoContratoTO();
		            parcelaToReturn.data = new List<ParcelamentoContratoTO.DataTO>();

                    for (public_parcelacontrato__x parcela : parcelas){
			            ParcelamentoContratoTO.DataTO dataToReturn = new ParcelamentoContratoTO.DataTO(); 
                        dataToReturn.id = integer.valueOf(parcela.id__c);
                        dataToReturn.datavencimento = String.valueOf(parcela.datavencimento__c);
                        dataToReturn.numeroparcela = integer.valueOf(parcela.numeroparcela__c);
                        dataToReturn.valoriof = String.valueOf(parcela.valoriof__c);
                        dataToReturn.valorliquido = String.valueOf(parcela.valorliquido__c);
                        dataToReturn.idfatura = integer.valueOf(parcela.idfatura__c);
                        dataToReturn.idexterno = parcela.idexterno__c;
                        dataToReturn.status = parcela.status__c;
                        dataToReturn.valorliquido = String.valueOf(parcela.valorliquido__c);
                        dataToReturn.valorparcela = String.valueOf(parcela.valorparcela__c);
			            parcelaToReturn.data.add(dataToReturn);
                    }
                    objPayload = parcelaToReturn;
                }
                //PLV-4949 FIX 3 - FIM
            }
            //PLV-4678 - Inicio
            else{
                String payloadTest = '{"meta":{"statusHttp":200,"servico":"Buscar parcelas do contrato por segurado ou vida","mensagem":"OK","dataExecucao":"2021-01-13T14:36:16.381Z"},"data":[{"vidasalesforce":null,"valorparcela":"11.62","valorliquido":"11.53","valoriof":"0.09","titulo":"","sucursal":"1","status":"PAGA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":1,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113847,"endosso":"0","empresa":"1","datavencimento":"2021-01-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":"2021-01-10T00:00:00.000Z","contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"PAGA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":2,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113848,"endosso":"0","empresa":"1","datavencimento":"2021-02-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":"2021-01-10T00:00:00.000Z","contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"PAGA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":3,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113849,"endosso":"0","empresa":"1","datavencimento":"2021-03-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":"2021-01-10T00:00:00.000Z","contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"PAGA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":4,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113850,"endosso":"0","empresa":"1","datavencimento":"2021-04-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":"2021-01-09T00:00:00.000Z","contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":5,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113851,"endosso":"0","empresa":"1","datavencimento":"2021-05-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":6,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113852,"endosso":"0","empresa":"1","datavencimento":"2021-06-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":7,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113853,"endosso":"0","empresa":"1","datavencimento":"2021-07-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":8,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113854,"endosso":"0","empresa":"1","datavencimento":"2021-08-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":9,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113855,"endosso":"0","empresa":"1","datavencimento":"2021-09-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":10,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113856,"endosso":"0","empresa":"1","datavencimento":"2021-10-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":11,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113857,"endosso":"0","empresa":"1","datavencimento":"2021-11-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":12,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113858,"endosso":"0","empresa":"1","datavencimento":"2021-12-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"}]}';
                objPayload = (ParcelamentoContratoTO)JSON.deserialize(payloadTest, ParcelamentoContratoTO.class);
            }
            //PLV-4678 - Fim

        return objPayload;
    }

    public String recompraTituloCapitalizacao()
    {
        // Inicia o batch
        Database.executeBatch(new TitulosRecompraBatch(), 300);
        return 'Ok';
    }

    public ConsultarDadosContratoTO.DadosContratoTO consultarContrato(String jsonString)
    {
        System.debug('Inicio consultarContrato');

        // Declaracao de variaveis
        ConsultarDadosContratoTO.DadosContratoTO retorno = new ConsultarDadosContratoTO.DadosContratoTO();
        retorno.statusChamada = 0;
        retorno.descricaoErro = '';

        //PLV-5128 - INCIO

        ServiceTO.ParametroConsultaContratoPorApoliceTO tempParApolice;
        try {
            tempParApolice = (ServiceTO.ParametroConsultaContratoPorApoliceTO) JSON.deserialize(jsonString, ServiceTO.ParametroConsultaContratoPorApoliceTO.class);
        } catch (JSONException e) {
            retorno.statusChamada = -1;
            retorno.descricaoErro = 'Parâmetro(s) inválido(s) (Empresa/Sucursal/Ramo/Apolice/Endosso/Numero Parcela)';
            return retorno;
        }

        // verifica parametros e busca dados contrato

        if(String.isBlank(tempParApolice.empresa) ||
                String.isBlank(tempParApolice.sucursal) ||
                String.isBlank(tempParApolice.ramo) ||
                String.isBlank(tempParApolice.apolice) ||
                String.isBlank(tempParApolice.endosso) ||
                tempParApolice.numeroparcela == null)
        {
            retorno.statusChamada = -1;
            retorno.descricaoErro = 'Valor(es) não informado(s) (Empresa/Sucursal/Ramo/Apolice/Endosso/Numero Parcela)';
            return retorno;
        }

        //PLV-5128 - FIM

        System.debug('===> Inicio processo de consulta');

        //--- busca dados das parcelas

        retorno = criarConsultaApolice(tempParApolice);

        System.debug('===>  Fim processo de consulta');


        return retorno;
    }

    public ConsultarDadosContratoTO.DadosContratoTO consultarProposta(String jsonString)
    {
        System.debug('Inicio consultarContrato');

        // Declaracao variaveis
        ConsultarDadosContratoTO.DadosContratoTO retorno = new ConsultarDadosContratoTO.DadosContratoTO();
        retorno.statusChamada = 0;
        retorno.descricaoErro = '';

        // verifica parametros e busca dados contrato
        ServiceTO.ParametroConsultaContratoPorPropostaTO tempParProposta = (ServiceTO.ParametroConsultaContratoPorPropostaTO) JSON.deserialize(jsonString, ServiceTO.ParametroConsultaContratoPorPropostaTO.class);

        if(String.isBlank(tempParProposta.empresa) ||
                String.isBlank(tempParProposta.ramo) ||
                String.isBlank(tempParProposta.origem) ||
                String.isBlank(tempParProposta.proposta))
        {
            System.debug('Erro de parâmetros');
            retorno.statusChamada = -1;
            retorno.descricaoErro = 'Erro de parâmetros (Empresa/Ramo/Origem/Proposta) ou (Empresa/Sucursal/Ramo/Apolice/Endosso)';
            return retorno;
        }

        System.debug('===> Inicio processo de consulta');

        //--- busca dados das parcelas
        retorno = criarConsultaProposta(tempParProposta);

        System.debug('===>  Fim processo de consulta');

        return retorno;
    }

    @testVisible // RVI-255 - INICIO/FIM
    private ConsultarDadosContratoTO.DadosContratoTO criarConsultaProposta(ServiceTO.ParametroConsultaContratoPorPropostaTO tempPar)
    {
        ConsultarDadosContratoTO.DadosContratoTO retorno = new ConsultarDadosContratoTO.DadosContratoTO();
        retorno.proposta = new ConsultarDadosContratoTO.PropostaTO();
        String nomeSegurado;
        String formaPagamento;
        Integer quantidadeParcelas;
        Decimal valorIof;
        String codigoCorretorLider;
        String modalidade;

        try {

            System.debug('===> Inicio consulta por proposta');

            List<Contract> lstcontrato = ContractDAO.getInstance().buscarContratoPorProposta(tempPar.empresa, tempPar.ramo, tempPar.origem, tempPar.proposta);

            System.debug('HENRIQUE lstcontrato: ' + lstcontrato);
            System.debug('HENRIQUE tempPar: ' + tempPar);
            System.debug('HENRIQUE lstcontrato.size(): ' + lstcontrato.size());
            //if(lstcontrato.size()>0)
            if(!lstcontrato.isEmpty())
            {
                System.debug('ENTROU NO IF ');
                Contract contrato = lstcontrato[0];
                System.debug('HENRIQUE contrato: ' + contrato);

                if(Test.isRunningTest()){//ANNVI-55 - INICIO
                    String mock = '{ "data": [], "meta": { "dataExecucao": "2024-07-19T13:43:29.311Z", "servico": "Consultar parcelas do contrato ", "statusHttp": 200, "mensagem": "Ok" } }';
                    ConsultarDadosContratoTO.DadosParcelasTO tempListParcelas = (ConsultarDadosContratoTO.DadosParcelasTO) JSON.deserialize(mock, ConsultarDadosContratoTO.DadosParcelasTO.class);
                    valorIof = calcularIof(tempListParcelas.data);
                }
                else if(!String.isBlank(contrato.Name))//ANNVI-55 - FIM
                {
                    ConsultarDadosContratoTO.DadosParcelasTO tempListParcelas = HerokuService.getInstance().buscarParcelasContratoPorApolice(contrato.Name);
                    valorIof = calcularIof(tempListParcelas.data);
                }

                //--- buscar dados do segurado
                ContratanteContrato__c contratante = buscarDadosContratante(contrato);
                nomeSegurado        = contratante.Conta__r.Name;
                formaPagamento      = contratante.FormaPagamento__r.Codigo__c;
                if(contratante.QuantidadeParcelas__c != null)
                    quantidadeParcelas = Integer.valueOf(contratante.QuantidadeParcelas__c);

                System.debug('===> Inserindo dados');

                // Losada: busca dados do corretor principal
                for(RemuneracaoContrato__c  remContr : ContractDAO.getInstance().buscarRemuneracaoContratoPorId(new Set<Id>{contrato.Id}))
                {
                    for(FavorecidoRemuneracaoContrato__c  remfav : remContr.FavorecidosContrato__r)
                    {
                        if(remfav.CorretorLider__c)
                        {
                          codigoCorretorLider = remfav.DadosCorretor__r.Name;
                        }
                    }
                }

                for(GarantiaContrato__c garantiaContrato : ContractDAO.getInstance().buscarGarantiaContratoPorId(new Set<Id>{contrato.Id}))
                {
                    if(garantiaContrato.GarantiaProduto__r.OrdemPrioridade__c == 1)
                        modalidade = garantiaContrato.GarantiaProduto__r.Modalidade__r.Codigo__c;
                }

                //RVI-197 - INICIO
                if (modalidade == null || modalidade == '' || modalidade.Length() == 0) 
                { 
                    Contract modQt =  [SELECT Proposta__r.Modalidade__r.Codigo__c FROM Contract WHERE Id =: contrato.Id  LIMIT 1];
                    modalidade = String.valueOf(modQt.Proposta__r.Modalidade__r.Codigo__c);
                }
                //RVI-197 - FIM

                retorno.proposta.empresa                     = contrato.Empresa__c;
                retorno.proposta.origemProposta              = contrato.Proposta__r.Origem__c;
                retorno.proposta.numeroProposta              = String.valueOf(contrato.Proposta__r.NumeroProposta__c);
                retorno.proposta.codigoOperacaoComissoes     = '';
                retorno.proposta.dataEmissaoDocumento        = contrato.DataEmissao__c;
                retorno.proposta.codigoRamoSeguro            = contrato.RamoSeguro__r.Codigo__c;
                retorno.proposta.codigoSubramo               = '0';
                retorno.proposta.sucursalEmissaoSeguro       = contrato.Sucursal__c;
                retorno.proposta.numeroApolice               = contrato.Name;
                retorno.proposta.numeroEndosso               = contrato.Endosso__c;
                retorno.proposta.dataInicioVigencia          = contrato.StartDate;
                retorno.proposta.dataFinalVigencia           = contrato.VigenciaFinal__c;
                retorno.proposta.premioLiquido               = (contrato.ValorPremio__c == null ? 0 : contrato.ValorPremio__c - valorIof);
                retorno.proposta.valorAdicionalFracionamento =  0;
                retorno.proposta.quantidadeParcelas          = quantidadeParcelas;
                retorno.proposta.statusProposta              = '7';
                //        retorno.proposta.taxaOficialComissao         =
                retorno.proposta.dataBaseCalculo             = contrato.DataEmissao__c;
                retorno.proposta.nomeSegurado                = nomeSegurado;
                retorno.proposta.descontoEmissaoEspecial     = 0;
                retorno.proposta.corretorPrincipal           = codigoCorretorLider;
                retorno.proposta.codigoFormaPagamento        = formaPagamento;
                retorno.proposta.premioBruto                 = contrato.ValorPremio__c;
                retorno.proposta.modalidadeSeguro            = modalidade;


                System.debug('===> Fim consulta por proposta');
            }
        }
        catch(Exception e)
        {
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e);
        }

        return retorno;
    }

    private ConsultarDadosContratoTO.DadosContratoTO criarConsultaApolice(ServiceTO.ParametroConsultaContratoPorApoliceTO paramApoliceTO)
    {
        System.debug('===> Inicio consulta por apolice');
        System.debug('paramApoliceTO'+paramApoliceTO); //PLV-4465-FIX2 - INICIO/FIM
        ConsultarDadosContratoTO.DadosContratoTO retorno = new ConsultarDadosContratoTO.DadosContratoTO();
        retorno.apolice = new List<ConsultarDadosContratoTO.ApoliceTO>();
        ConsultarDadosContratoTO.DadosParcelasTO lstParcelasTO;
		ConsultarDadosContratoTO.DadosParcelasTO lstParcelasTORetorno; //PLV 4835 Inicio/Fim

        List<Contract> lstcontrato;
        List<Contract> lstcontratoOriginal;
        String  [] codigoCorretor = new String[]{'','',''};
        Decimal [] participacaoCorretor=new Decimal[]{null,null,null};
        ConsultarDadosContratoTO.ParcelasTO parcelaSelecionada = new ConsultarDadosContratoTO.ParcelasTO();

        Contract contratoOriginal;

        String endossoAnterior;
        String nomeSegurado;
        String formaPagamento;
        String tipoMovimento;
        Integer quantidadeParcelas;
        Decimal valorIof;
        String modalidade;

		//PLV-4736-Fix2 Inicio
		Boolean agenciamneto = false; 
		Integer percentual;
            Integer percentualAgenciamento; //INICIO/FIM - PLV-4660 - Guilherme Brito - FIX 3
		//PLV-4736-Fix2 Fim

        retorno.statusChamada = 0;
        retorno.descricaoErro = '';

        try
        {

            // PLV-3384 - INICIO            
            //PLV 4835 Inicio
                //lstParcelasTORetorno = HerokuService.getInstance().buscarParcelasContratoPorApolice(String.valueOf(paramApoliceTO.apolice).leftPad(9, '0')); //PLV-4660 FIX 4 - INÍCIO/FIM
                lstParcelasTORetorno = HerokuService.getInstance().buscarParcelasContratoPorApoliceEndosso(String.valueOf(paramApoliceTO.apolice).leftPad(9, '0'), String.valueOf(paramApoliceTO.endosso)); //PLV-4660 FIX 4 - INÍCIO/FIM

                //PLV 4835 Fim
                String nameContrato = ContractBO.getInstance().gerarNameContrato(paramApoliceTO.empresa, paramApoliceTO.sucursal, paramApoliceTO.ramo, String.valueOf(paramApoliceTO.apolice).leftPad(9, '0'), paramApoliceTO.endosso);
                // PLV-3384 - FIM

			//PLV 4835 Inicio
			List<ConsultarDadosContratoTO.ParcelasTO> lstParcelasTONova = new List<ConsultarDadosContratoTO.ParcelasTO>(); 
            
            
			if(paramApoliceTO.numeroparcela != 0){
				for(ConsultarDadosContratoTO.ParcelasTO parcela : lstParcelasTORetorno.data){
				System.debug('paramApoliceTO.numeroparcela = ' + paramApoliceTO.numeroparcela);
				System.debug('parcela = ' + parcela.numeroparcela);
					if(paramApoliceTO.numeroparcela == parcela.numeroparcela){
					System.debug('Entrou If');					
						//lstParcelasTO = lstParcelasTORetorno;
						lstParcelasTO = new ConsultarDadosContratoTO.DadosParcelasTO();
						lstParcelasTO.meta = lstParcelasTORetorno.meta;
						//lstParcelasTO.data = new List<ConsultarDadosContratoTO.ParcelasTO>();
						lstParcelasTONova.add(parcela);
						System.debug('teste = ' + lstParcelasTONova);
						lstParcelasTO.data = lstParcelasTONova;
					}
				}
			}else{
				lstParcelasTO = lstParcelasTORetorno;
			}			
			//PLV 4835 Fim
			
			lstcontrato = ContractDAO.getInstance().buscarContratoPorName(nameContrato);
            
            if(lstParcelasTO != null && lstcontrato.size() > 0) //PLV-5128 - INICIO/FIM
            {
                Contract contrato = lstcontrato[0];

                //PLV-5128 - FIX01 - INICIO
                if (contrato.Tipo__c == 'Endosso' && contrato.PremioTotal__c < 0 && paramApoliceTO.numeroparcela > 0) {
                    retorno.descricaoErro = 'Apolice não encontrada';
                    return retorno;
                }
                //PLV-5128 - FIX01 - FIM
                
                valorIof = calcularIof(lstParcelasTO.data);

                carregarDadosCorretor(contrato, codigoCorretor,participacaoCorretor);

                //--- Buscar dados do segurado
                ContratanteContrato__c contratante = buscarDadosContratante(contrato);
                nomeSegurado        = contratante.Conta__r.Name;
                formaPagamento      = contratante.FormaPagamento__r.Codigo__c;
                if(contratante.QuantidadeParcelas__c != null)
                    quantidadeParcelas = Integer.valueOf(contratante.QuantidadeParcelas__c);

                if(contrato.Tipo__c=='Cancelamento')   
                    endossoAnterior = buscarEndossoAnterior(contrato.Name);

                    tipoMovimento = defineTipoMovimento(contrato, paramApoliceTO.numeroparcela, lstParcelasTORetorno.data); //PLV-4601-FIX4 - HENRIQUE R. META INICIO/FIM

                    lstcontratoOriginal = ContractDAO.getInstance().buscarContratoPorName(contrato.ContratoOriginal__r.Name); // PLV-4601-FIX5

                if(lstcontratoOriginal.size()>0)
                    contratoOriginal = lstcontratoOriginal[0];

                //--- Monta dados padrão
                ConsultarDadosContratoTO.ApoliceTO detalhe = new ConsultarDadosContratoTO.ApoliceTO();


                //-- Busca Modalidade do contrato
                for(GarantiaContrato__c garantiaContrato : ContractDAO.getInstance().buscarGarantiaContratoPorId(new Set<Id>{contrato.Id}))
                {
                    if(garantiaContrato.GarantiaProduto__r.OrdemPrioridade__c == 1)
                        modalidade = garantiaContrato.GarantiaProduto__r.Modalidade__r.Codigo__c;
                }

                //RVI-197 - INICIO
                if (modalidade == null || modalidade == '' || modalidade.Length() == 0) 
                { 
                    Contract modCtr =  [SELECT CodigoModalidade__c FROM Contract WHERE Id =: contrato.Id  LIMIT 1];
                    modalidade = String.valueOf(modCtr.CodigoModalidade__c);
                }
                //RVI-197 - FIM
               
				// PLV_3384 - Inicio
				RemuneracaoContrato__c rc = [SELECT Id, Contrato__c FROM RemuneracaoContrato__c WHERE Contrato__c =: contrato.Id and TipoRemuneracao__r.Name = 'CORRETAGEM']; //PLV-4465 - FIX1 - INICIO/FIM
				FavorecidoRemuneracaoContrato__c frc = [SELECT Id, Susep__c, RemuneracaoContrato__c, Participacao__c FROM FavorecidoRemuneracaoContrato__c WHERE RemuneracaoContrato__c =: rc.id and corretorLider__c = true]; //PLV- 4709

				//PLV-4736-Fix2 Inicio
				List<RemuneracaoContrato__c> listRcTotal = [SELECT Id, Contrato__c, Percentual__c, TipoRemuneracao__r.Name FROM RemuneracaoContrato__c WHERE Contrato__c =: contrato.Id ];				
                    System.debug('listRcTotal.Id = ' + listRcTotal);	
                    //INICIO - PLV-4660 - Guilherme Brito - FIX 3	
				for(RemuneracaoContrato__c remuneracaoContra : listRcTotal){
					if(remuneracaoContra.TipoRemuneracao__r.Name == 'AGENCIAMENTO'){
                            percentualAgenciamento = Integer.valueOf(remuneracaoContra.Percentual__c);
					}
				}
                    if(percentualAgenciamento != 0) {
                        agenciamneto = true;
                    }
                    //FIM - PLV-4660 - Guilherme Brito - FIX 3	
				//PLV-4736-Fix2 Fim

				List<FavorecidoRemuneracaoContrato__c> frcOutros = [SELECT Id, Susep__c, RemuneracaoContrato__c, Participacao__c FROM FavorecidoRemuneracaoContrato__c WHERE RemuneracaoContrato__c =: rc.id and corretorLider__c != true]; //PLV- 4709 
				// PLV_3384 - Fim

                    detalhe.empresa                     = contrato.Empresa__c;
                    // PLV-4601-FIX3 INICIO
                    if(contratoOriginal!=null) 
                        detalhe.endossoReferencia           = contratoOriginal.Endosso__c; //INÍCIO/FIM - PLV-4660 - GUILHERME BRITO
                    // PLV-4601-FIX3 FIM
                detalhe.codigoRamoSeguro            = contrato.RamoSeguro__r.Codigo__c;
                detalhe.codigoSubRamo               = '0';
                detalhe.sucursalEmissaoSeguro       = contrato.Sucursal__c;
                detalhe.modalidadeSeguro            = modalidade;
                detalhe.numeroApolice               = contrato.Name; //PLV-4709-Fix4 Inicio/Fim
                detalhe.numeroEndosso               = contrato.Endosso__c;
                    //PLV-4601-FIX4 - HENRIQUE R. META INICIO
                    if(contratoOriginal!=null) 
                    detalhe.numeroEndossoReferencia     = contratoOriginal.Endosso__c;
                    //PLV-4601-FIX4 - HENRIQUE R. META FIM
                detalhe.dataEmissaoDocumento        = contrato.DataEmissao__c != null ? contrato.DataEmissao__c.format() : null; //ANNVI-55 - INICIO/FIM
                if(contratoOriginal!=null)
                    detalhe.dataEmissaoApolice      = contratoOriginal.DataEmissao__c.format();
                detalhe.dataInicioVigencia          = contrato.StartDate.format();
                detalhe.dataFinalVigencia           = contrato.VigenciaFinal__c.format()  ;
                detalhe.codigoFormaPagamento        = formaPagamento;
                detalhe.moedaPremio                 = 'R$';
                detalhe.codigoTaxaComissao          = '1';
                detalhe.origemProposta              = contrato.Proposta__r.Origem__c;
                detalhe.numeroProposta              = contrato.Proposta__r.Name; //PLV-4709-Fix4 Inicio/Fim
                //detalhe.flagComissaoNegociada       = 'N'; //PLV-4465-FIX2 - INICIO/FIM
                detalhe.percentualParticipacaoCia   = 100; //PLV-4736-Fix3 Inicio/Fim
                detalhe.descontoEmissaoEspecial     = 0;
                detalhe.codigoOperacaoComissoes     = '0';
                detalhe.nomeSegurado                = nomeSegurado;
                detalhe.flagNotaComplementar        = '0';
                detalhe.tipoMovimento               = tipoMovimento;
                detalhe.quantidadeParcelas          = quantidadeParcelas;
                detalhe.valorAdicionalFracionamento = 0;
                //PLV- 4709 Inicio
				
				detalhe.corretorCodigoDerivadoSUSEP1    = frc.Susep__c;
				detalhe.percentualParticipacaoCorretor1 = frc.Participacao__c;
				
				//PLV-4709 Fix4 Inicio
				if(!frcOutros.isEmpty() && frcOutros.size() == 1){
					System.debug('If 1 ');
					detalhe.corretorCodigoDerivadoSUSEP2    = frcOutros[0].Susep__c;
					detalhe.percentualParticipacaoCorretor2 = frcOutros[0].Participacao__c;
					detalhe.corretorCodigoDerivadoSUSEP3    = null;
					detalhe.percentualParticipacaoCorretor3 = null;
				}
				if(!frcOutros.isEmpty() && frcOutros.size() == 2){
					System.debug('If 2 ');
					detalhe.corretorCodigoDerivadoSUSEP2    = frcOutros[0].Susep__c;
					detalhe.percentualParticipacaoCorretor2 = frcOutros[0].Participacao__c;
					detalhe.corretorCodigoDerivadoSUSEP3    = frcOutros[1].Susep__c;
					detalhe.percentualParticipacaoCorretor3 = frcOutros[1].Participacao__c;
				}
				if(frcOutros.isEmpty()){
					detalhe.corretorCodigoDerivadoSUSEP2    = null;
				 	detalhe.percentualParticipacaoCorretor2 = null;
					detalhe.corretorCodigoDerivadoSUSEP3    = null;
					detalhe.percentualParticipacaoCorretor3 = null;
				}
				//PLV-4709 Fix4 Fim

                /*detalhe.corretorCodigoDerivadoSUSEP2    = frcOutros[1].Susep__c;
                detalhe.percentualParticipacaoCorretor2 = frcOutros[1].Participacao__c;
                detalhe.corretorCodigoDerivadoSUSEP3    = frcOutros[2].Susep__c;
                detalhe.percentualParticipacaoCorretor3 = frcOutros[2].Participacao__c;*/

				//PLV- 4709 Fim
                detalhe.taxaOficialComissao             = carregarTaxaComissao(contrato);
                detalhe.susep                           = contrato.Produto__r.NumeroSusep__c;

                //detalhe.parcela                     = 0; //PLV-4465-FIX2 - INICIO/FIM                             
                detalhe.premioLiquido               = (contrato.PremioComercial__c == 0 ? calculaPremioLiquido(contrato.PremioTotal__c, contrato.ValorIOF__c) : contrato.PremioComercial__c).setscale(2); //PLV-4660 FIX 4 - INÍCIO/FIM
                // PLV_3384 - Inicio
				detalhe.susep1                      = frc.Susep__c; //PLV-4465-FIX2 - INICIO/FIM
				// PLV_3384 - Fim
                detalhe.dataBaseCalculo             = null;
				//PLV-4464 Inicio
				if(contrato.Account.Pescod__c != null || contrato.Account.Pescod__c != ''){
					detalhe.codigoPessoaBCP				= contrato.Account.Pescod__c;
				}else{
					detalhe.codigoPessoaBCP				= ' ';
				}				
				//PLV-4464 Fim
                            

            // PLV-3384 - INICIO
                system.debug('lstParcelasTO.data'  + lstParcelasTO.data);
                Map<Integer, ConsultarDadosContratoTO.ParcelasTO> mapParcelasTemp = new Map<Integer, ConsultarDadosContratoTO.ParcelasTO>();
                detalhe.parcelas = new List<ConsultarDadosContratoTO.ParcelasTO>();
                
                //PLV-4709 - INICIO
                Integer numeroParcelaEntada = paramApoliceTO.numeroparcela;
                detalhe.parcela = numeroParcelaEntada; //PLV-4709 - INICIO/FIM
                //PLV-4465-FIX2 - INICIO
                    /*if(numeroParcelaEntada <= 0){
                        numeroParcelaEntada = 1;
                    }*/
                //PLV-4709 - FIM
                //PLV-4465-FIX2 - FIM
                    // PLV-4601-FIX3 - INICIO
                    //PLV-5128 - INICIO
                    detalhe.parcelaCanceladaInicial = '';
                    for(ConsultarDadosContratoTO.ParcelasTO parcela : lstParcelasTORetorno.data){
                        //INÍCIO - PLV-4660 - GUILHERME BRITO                   
                        if(parcela.status == 'CANCELADA') {
                            detalhe.parcelaCanceladaInicial = string.valueOf(parcela.numeroparcela);
                            break;
                        }
                        //FIM - PLV-4660 - GUILHERME BRITO
                    }
                    //PLV-5128 - FIM
                    // PLV-4601-FIX3 - FIM
                for(ConsultarDadosContratoTO.ParcelasTO parcela : lstParcelasTO.data)
                {
                    ConsultarDadosContratoTO.ParcelasTO parcelaTO = new ConsultarDadosContratoTO.ParcelasTO();
                    //PLV-4709-FIX1-INICIO
                    if(parcela.numeroparcela == 1){
                        detalhe.flagComissaoNegociada =  parcela.antecipacaocomissao; 
                    }                    
                    //PLV-4709-FIX1-FIM
                    parcelaTO.numeroparcela = parcela.numeroparcela;
                    //PLV-4465-FIX2 - INICIO
                    if(parcela.numeroparcela == numeroParcelaEntada){
                        detalhe.flagComissaoNegociada       = parcela.antecipacaocomissao;

                        detalhe.premioLiquido = Decimal.valueOf(parcela.valorliquido);  //PLV-4709 - INICIO/FIM
                        if(detalhe.flagComissaoNegociada == null || detalhe.flagComissaoNegociada == ''){
                            detalhe.flagComissaoNegociada = 'N';
                        }
                        detalhe.parcela = parcela.numeroparcela;
                        //parcelaTO.antecipacaocomissao = parcela.antecipacaocomissao; 
                    }
                    //PLV-4465-FIX2 - INICIO/FIM
                    
					//PLV-4736-Fix2 Inicio
					System.debug('agenciamneto = ' + agenciamneto);
					System.debug('percentual = ' + percentual);
					System.debug('parcela.valorliquido = ' + parcela.valorliquido);
					if(parcela.valorliquido != null && agenciamneto == true && percentual == 100){
						System.debug('parcela.numeroparcela = ' + parcela.numeroparcela);
						if(parcela.numeroparcela == 1){
							parcelaTO.valorparcela  = '0';	
                            //PLV-4709 FIX 5 INICIO
                            if(numeroParcelaEntada != 0) {
                                detalhe.premioLiquido = 0;					
                            }
                            //PLV-4709 FIX 5 FIM						
						}						
					}
                    
                        //INICIO - PLV-4660 - Guilherme Brito - FIX 3
                        if(parcela.valorliquido != null && agenciamneto == false)
                            parcelaTO.valorparcela  = parcela.valorliquido;
                        //PLV-4736-Fix2 Inicio                                        
                        if(parcela.datapagamento != null)
                            parcelaTO.datapagamento = Date.valueOf(parcela.datapagamento).format();

                        Decimal saldoCorrespondente = 0;
                        
                        if(agenciamneto == true && detalhe.quantidadeParcelas < 12) {
                            if((parcela.numeroparcela == 1 && percentualAgenciamento == 100) || (parcela.numeroparcela <= 2 && percentualAgenciamento == 200)) {
                                Decimal valorAgenc = (contratante.PremioComercial__c/12);
                                Decimal valorLiquido = decimal.valueOf(parcela.valorliquido);
                                
                                saldoCorrespondente =  valorLiquido - valorAgenc;
                                
                                if(valorLiquido <= valorAgenc)
                                    saldoCorrespondente = 0;
    
                                saldoCorrespondente = saldoCorrespondente.setScale(2);
                            }
                        }
                        
                        parcelaTO.valorparcela = saldoCorrespondente > 0 ? string.valueOf(saldoCorrespondente) : parcela.valorliquido;

                        if(detalhe.quantidadeParcelas == 12) {
                           if(percentualAgenciamento == 100 && parcela.numeroparcela == 1) {
                                parcelaTO.valorparcela = string.valueOf(0);
                            } else if(percentualAgenciamento == 200 && (parcela.numeroparcela == 1 || parcela.numeroparcela == 2)) {
                                parcelaTO.valorparcela = string.valueOf(0);
                            }
                        }
                        
                        if(parcela.numeroparcela == numeroParcelaEntada){
                            detalhe.premioLiquido = decimal.valueOf(parcelaTO.valorparcela);
                        }
                        detalhe.premioLiquido = parcela.status.equalsIgnoreCase('A RESTITUIR') ? parcela.valorrestituicao!=null ? Decimal.valueOf(parcela.valorrestituicao) : 0 : detalhe.premioLiquido;//PLV-4601 - INICIO/FIM
                        detalhe.premioLiquido = parcela.status.equalsIgnoreCase('A RESTITUIR') && detalhe.premioLiquido > 0 ? detalhe.premioLiquido * -1 : detalhe.premioLiquido;//PLV-4601 - INICIO/FIM
                        //PLV-5128 - INICIO
                        if (tipoMovimento == '30' && detalhe.premioLiquido < 0) detalhe.premioLiquido = 0.00;
                        //PLV-5128 - FIM
                        //FIM - PLV-4660 - Guilherme Brito - FIX 3

                        // PLV-4601-FIX3 - INICIO
                        
                        // PLV-4601-FIX3 - FIM
                        
                        //FIM - PLV-4660 - GUILHERME BRITO
					//PLV-4835 - INICIO/FIM 
                                        
                    system.debug('parcelaTO:'  + parcelaTO);
                    mapParcelasTemp.put(parcela.numeroparcela, parcelaTO);
                }
                //PLV  4835 Inicio
                //for(Integer i = 1; mapParcelasTemp.values().size() > detalhe.parcelas.size(); i++)
                    //detalhe.parcelas.add(mapParcelasTemp.get(i));
					
					for(ConsultarDadosContratoTO.ParcelasTO parcelasTo : mapParcelasTemp.values()){
						detalhe.parcelas.add(parcelasTo);
					}
					//PLV  4835 Fim
                system.debug('detalhe.parcelas:'  + detalhe.parcelas);
                
            // PLV-3384 - FIM

                retorno.apolice.add(detalhe);
            }

            // INICIO | PLV-2248-28
            if(retorno.apolice.size() == 0)
               retorno.descricaoErro = 'Apolice não encontrada';
            // FIM | PLV-2248-28
        }
        catch(Exception e)
        {
            retorno.statusChamada = 1;
            retorno.descricaoErro = 'ERRO:' + e.getLineNumber() + ': ' + e.getMessage();

            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
            //throw new ContractException(e.getLineNumber() + ': ' + e);
        }

        return retorno;
    }

    private Decimal calcularIof(List<ConsultarDadosContratoTO.ParcelasTO> parcelas)
    {
        Decimal valorIof = 0;

        for(ConsultarDadosContratoTO.ParcelasTO parcela : parcelas)
        {
            valorIof += Decimal.valueOf(parcela.valoriof);
        }

        System.debug('Valor IOF: ' + valorIof);

        return valorIof;
    }

    private ContratanteContrato__c buscarDadosContratante(Contract contrato)
    {
        ContratanteContrato__c retorno;

        for(ContratanteContrato__c contratante : contrato.ContratantesContrato__r)
        {
            if(contratante.Tipo__c == 'Principal')
            {
                retorno = contratante;
                break;
            }
        }
        return retorno;
    }

    private Decimal buscarPremioContrato(Contract contrato)
    {
        Decimal premio = 0;

        for(ContratanteContrato__c segurado : contrato.ContratantesContrato__r)
        {
            premio += segurado.PremioTotal__c;
        }
        return premio;
    }
    
    private String buscarEndossoAnterior(String apolice)
    {
        Long EndossoAnterior = -1;

        //--- buscar endosso anterior
        for(Contract obj : contractDAO.getInstance().buscarPorNumeroApolice(new Set<String>{apolice}))
        {
            if(obj.Status == 'Emitido' && !String.isBlank(obj.Endosso__c) && EndossoAnterior < Long.valueOf(obj.Endosso__c))
            {
                EndossoAnterior = Long.valueOf(obj.Endosso__c);
            }
        }

        return String.valueOf(EndossoAnterior);
    }

        //PLV-4601-FIX4 - HENRIQUE R. META INICIO
        private String defineTipoMovimento(Contract contrato,integer numeroparcela, List<ConsultarDadosContratoTO.ParcelasTO> lstParcelasTO)
        {
            
            ConsultarDadosContratoTO.ParcelasTO parcela = null;
            for(ConsultarDadosContratoTO.ParcelasTO forParcela : lstParcelasTO ){
                if(forParcela.numeroParcela == numeroparcela){
                    parcela = forParcela;
                }
            }

            String tipoMovimento;
            
            // PLV-4601-FIX - INICIO - HENRIQUE R. META FIM
            if(('Novo'.equalsIgnoreCase(contrato.Tipo__c) || 'Renovacao'.equalsIgnoreCase(contrato.Tipo__c))){ //RVI-49 - INICIO/FIM
                if(parcela == null || numeroparcela == 0){
                    tipoMovimento = '1'; 
                }else if( parcela.numeroparcela > 0){
                    tipoMovimento = '6';
                }
            }else if(contrato.Tipo__c == 'Cancelamento'){
                // RVI-255-INICIO
                if(contrato.PremioTotal__c < 0 && numeroparcela == 0){
                    tipoMovimento = '33';
                }else if(parcela == null || numeroparcela == 0){
                    tipoMovimento = '20';
                // RVI-255-FIM
                }else if(parcela.numeroparcela > 0){
                    tipoMovimento = '4';
                }
            }else if(contrato.Tipo__c == 'Endosso'){
                //PLV-5128 - FIX01 - INICIO
                if (contrato.PremioTotal__c >= 0) {
                    if (numeroparcela > 0) {
                        tipoMovimento = '6';
                    }else {
                        tipoMovimento = '30';
                    }
                // RVI-255-INICIO
                }else if (contrato.PremioTotal__c < 0 && numeroparcela == 0 ){
                    tipoMovimento = '33';
                // RVI-255-FIM
                }else if (numeroparcela <= 0) {
                    tipoMovimento = '30';
                }
                //PLV-5128 - FIX01 - FIM
            }
            // PLV-4601-FIX - FIM - HENRIQUE R. META FIM
            return tipoMovimento;
        }
        //PLV-4601-FIX - HENRIQUE R. META FIM

    private void carregarDadosCorretor(Contract contrato, String [] codigoCorretor, Decimal [] participacaoCorretor)
    {
        Integer cont = 0;

        for(RemuneracaoContrato__c remuneracao : contrato.RemuneracoesContrato__r)
        {
            codigoCorretor[cont] = '';//remuneracao.DadosCorretor__r.Name;
            participacaoCorretor[cont] = null;//remuneracao.P__c;

            cont++;
        }
    }

    @TestVisible
    private Decimal carregarTaxaComissao(Contract contrato)
    {
        Decimal premio = 0;

        for(RemuneracaoContrato__c remuneracao : contrato.RemuneracoesContrato__r)
        {
            if(remuneracao.Percentual__c != null)
                premio += remuneracao.Percentual__c;
        }

        return premio;
    }

    // PLV-2804 INICIO
    public ContratoTO.PayloadTO mapeiaPayloadContrato(Quote cotacao, Map<String, String> mapPropostaApolice)
    {
        system.debug('ContractFacade >> mapeiaPayloadContrato>> Inicio');
        try
        {
            // Lista os tipode de registro do objeto conta
            Map<String, RecordType> mapRecordType = new Map<String, RecordType>();
            for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Account'))
                mapRecordType.put(tipo.Id, tipo);

            // Cria as instancias do objeto que será deserializado no json de envio ao CIV massificados...
            ContratoTO.PayloadTO payloadEnvioContrato                        = new ContratoTO.PayloadTO();
            payloadEnvioContrato.contrato                                    = new ContratoTO();
            payloadEnvioContrato.contrato.geracaoApolice                     = new ContratoTO.GeracaoapoliceTO();
            payloadEnvioContrato.contrato.remuneracoes                       = new List<ContratoTO.remuneracoesTO>();
            payloadEnvioContrato.contrato.Contratantes                       = new List<ContratoTO.ContratantesTO>();
            payloadEnvioContrato.contrato.precificacao                       = new ContratoTO.PrecificacaoTO();
            // PLV-4488
            payloadEnvioContrato.contrato.alteracoesEndosso                  = new List<ContratoTO.AlteracoesEndosso>(); 

            List<RemuneracaoProposta__c> lstRemuneracaoProposta     = QuoteDAO.getInstance().buscarRemuneracaoProposta(new Set<Id>{cotacao.Id});
            List<GarantiaProduto__c> lstGarantiasProdutoProposta    = GarantiaProdutoDAO.getInstance().buscarGarantiasProdutoPorProdutoId(new Set<Id>{cotacao.Produto__c});


            system.debug('ContractFacade >> mapeiaPayloadContrato>> lista remuneracoes: ' + lstRemuneracaoProposta);
            system.debug('ContractFacade >> mapeiaPayloadContrato>> lista garantias Produto Proposta: ' + lstGarantiasProdutoProposta);

            payloadEnvioContrato.contrato.codigoEmpresa  = cotacao.Produto__r.Empresa__r.CodigoEmpresa__c;
            payloadEnvioContrato.contrato.nomeEmpresa    = cotacao.Produto__r.Empresa__r.Name;

            for(RemuneracaoProposta__c  remProp : lstRemuneracaoProposta)
            {
                for(FavorecidoRemuneracaoProposta__c  remfav : remProp.FavorecidosRemuneracaodaProposta__r)
                {
                    if(remfav.CorretorLider__c)
                        payloadEnvioContrato.contrato.codigoSucursal = remfav.DadosCorretor__r.CodigoSucursalVinculo__c;
                }
            }

            // Verifica se eh uma proposta de cancelamento
            // caso seja, o numero da apólice deve ser enviado
            // e o endosso tem que ser o último do contrato +1
            
            //POR062-99 - INICIO
            List<Contract> contratoOriginal = new List<Contract>();
            List<Contract> contrato = [ select Id, Name from Contract where NumeroProposta__c = :cotacao.NumeroProposta__c];

            contratoOriginal = [ 
                    SELECT ID, Name, ContratoOriginal__r.Name, ContratoOriginal__r.StartDate, ContratoOriginal__r.VigenciaFinal__c FROM Contract where name = :contrato[0].Name
                ];
            
            System.debug('CONTRATO ORIGINAL: ' + JSON.serialize(contratoOriginal));    
            // PLV-5393-FIX01-INICIO
                     
                /*ContractBO.RetornoDadosEndossoTO retornoDadosEndossoTO = ContractBO.getInstance().buscarUltimoEndossoApolice(payloadEnvioContrato.contrato.codigoEmpresa, 
                // payloadEnvioContrato.contrato.codigoSucursal, // PLV-4660 
                cotacao.Contract.Sucursal__c, // PLV-4660 
                cotacao.RamoSeguro__r.Codigo__c, //PLV-3460 Fix 5 - INICIO/FIM
                cotacao.Contract.NumeroApolice__c);*/
            
            //PLV -5393-FIX01-FIM

            //PLV-2334-27 INICIO
            if(cotacao.Tipo__c == 'Cancelamento'){

                //POR062-99 - INICIO
                ContractBO.RetornoDadosEndossoTO retornoDadosEndossoTO = ContractBO.getInstance().buscarUltimoEndossoApolice(payloadEnvioContrato.contrato.codigoEmpresa, // PLV-5393-INICIO-FIM
                // payloadEnvioContrato.contrato.codigoSucursal, // PLV-4660 
                cotacao.Contract.Sucursal__c, // PLV-4660 
                cotacao.RamoSeguro__r.Codigo__c, //PLV-3460 Fix 5 - INICIO/FIM
                cotacao.Contract.NumeroApolice__c);
                System.debug('cotacao.Contract.NumeroApolice__c ' + cotacao.Contract.NumeroApolice__c);
                payloadEnvioContrato.contrato.numeroApolice = Integer.valueOf(cotacao.Contract.NumeroApolice__c);
                payloadEnvioContrato.contrato.numeroEndosso = retornoDadosEndossoTO.numeroEndosso;
                //POR062-99 - FIM
                
                payloadEnvioContrato.contrato.vigenciaInicial = String.valueOf(retornoDadosEndossoTO.objContrato.StartDate); 	
                payloadEnvioContrato.contrato.vigenciaFinal = String.valueOf(retornoDadosEndossoTO.objContrato.VigenciaFinal__c);
                //PLV-2334-27 FINAL	
                
                //POR062-99 - INICIO
                if(!contratoOriginal.isEmpty()){                               
                    payloadEnvioContrato.contrato.vigenciaInicialContratoOriginal = String.valueOf(contratoOriginal[0].ContratoOriginal__r.StartDate);
                    payloadEnvioContrato.contrato.vigenciaFinalContratoOriginal = String.valueOf(contratoOriginal[0].ContratoOriginal__r.VigenciaFinal__c);	
                }
                //POR062-99 - FIM
                System.debug('==> Novo Endosso: ' + payloadEnvioContrato.contrato.numeroEndosso);
            }// PLV-5393-FIX01-INICIO
            else if(cotacao.Tipo__c == 'Endosso' && !contratoOriginal.isEmpty()){ 
                ContractBO.RetornoDadosEndossoTO retornoDadosEndossoTO = ContractBO.getInstance().buscarUltimoEndossoApolice(payloadEnvioContrato.contrato.codigoEmpresa, // PLV-5393-INICIO-FIM
                // payloadEnvioContrato.contrato.codigoSucursal, // PLV-4660 
                cotacao.Contract.Sucursal__c, // PLV-4660 
                cotacao.RamoSeguro__r.Codigo__c, //PLV-3460 Fix 5 - INICIO/FIM
                cotacao.Contract.NumeroApolice__c);
                payloadEnvioContrato.contrato.vigenciaInicial = String.valueOf(cotacao.VigenciaInicial__c);
                payloadEnvioContrato.contrato.vigenciaFinal   = String.valueOf(cotacao.VigenciaFinal__c);
                System.debug('CONTRATO ORIGINAL HENRIQUE: ' + JSON.serialize(contratoOriginal));                   
                payloadEnvioContrato.contrato.vigenciaInicialContratoOriginal = String.valueOf(contratoOriginal[0].ContratoOriginal__r.StartDate);
                payloadEnvioContrato.contrato.vigenciaFinalContratoOriginal = String.valueOf(contratoOriginal[0].ContratoOriginal__r.VigenciaFinal__c);	
                payloadEnvioContrato.contrato.numeroEndosso = retornoDadosEndossoTO.numeroEndosso; // PLV-5393-INICIO-FIM
                payloadEnvioContrato.contrato.numeroApolice = Integer.valueOf(cotacao.Contract.NumeroApolice__c); //POR062-99 INICIO / FIM
                //POR062-99 - FIM                
            }// PLV-5393-FIX01-FIM
            else 
            {
                System.debug('ENTROU AQUI HENRIQUE 2:');
                    //PLV-2334-27 INICIO
                    payloadEnvioContrato.contrato.vigenciaInicial = String.valueOf(cotacao.VigenciaInicial__c);
                    payloadEnvioContrato.contrato.vigenciaFinal   = String.valueOf(cotacao.VigenciaFinal__c);
                    //PLV-2334-27 FINAL

                
                System.debug('cotacao VEP-529>>>>' + cotacao);
                System.debug('mapPropostaApolice VEP-529>>>>' + mapPropostaApolice);
                payloadEnvioContrato.contrato.numeroApolice = Integer.valueOf(mapPropostaApolice.get(cotacao.NumeroProposta__c));
                // PLV-4488 INICIO

                
                //PLV-5190 - INICIO
                //List<Contract> listContractNew = [SELECT id, CreatedDate, Endosso__c FROM Contract WHERE Proposta__c =: cotacao.Id];

                //if(listContractNew != null && listContractNew.size() > 0 && listContractNew[0].Endosso__c != null && Integer.valueOf(listContractNew[0].Endosso__c) > 0){ 
                //    payloadEnvioContrato.contrato.numeroEndosso   = Integer.valueOf(listContractNew[0].Endosso__c);
                //}else{
                //    payloadEnvioContrato.contrato.numeroEndosso   = 0;
                //}

                payloadEnvioContrato.contrato.numeroEndosso = retornarNumeroEndosso( [SELECT id, Endosso__c FROM Contract WHERE Proposta__c =: cotacao.Id] );
                System.debug('==> Novo Endosso 2 HENRIQUE: ' + payloadEnvioContrato.contrato.numeroEndosso);
                //PLV-5190 - FIM

                // PLV-4488 FIM
            }   

            //payloadEnvioContrato.contrato.codigoSucursal = cotacao.CodigoCorretor__r.SucursalVinculo__c ?? '36';
             // antes vnha do corretor, porem não existe mais corretor no contrato
            payloadEnvioContrato.contrato.ramoSeguro         = cotacao.RamoSeguro__r.Codigo__c;
            payloadEnvioContrato.contrato.nomeRamoSeguro     = cotacao.RamoSeguro__r.Name;

            payloadEnvioContrato.contrato.CodigoOrigemDoMovimentoBCP         = cotacao.RamoSeguro__r.CodigoOrigemDoMovimentoBCP__c; // PLV-3855  
            




            if(cotacao.Origem__c != null)
                payloadEnvioContrato.contrato.origem = Integer.valueOf(cotacao.Origem__c);
            else
                payloadEnvioContrato.contrato.origem = 0;

            system.debug('ContractFacade >> mapeiaPayloadContrato>> mapeamento payload contrato (raiz): ');

            payloadEnvioContrato.contrato.numero                 = String.valueOf(cotacao.NumeroProposta__c);
            payloadEnvioContrato.contrato.segmento               = QuoteBO.buscaSegmento(cotacao.RecordType.DeveloperName) == 'VI' ? 'Vida Individual': 'Vida Em Grupo';
            payloadEnvioContrato.contrato.meioComercializacao    = (cotacao.MeioComercializacao__c == null ? '' : cotacao.MeioComercializacao__c);
            payloadEnvioContrato.contrato.dataCalculo            = String.valueOf(cotacao.DataCalculo__c);
            payloadEnvioContrato.contrato.codigoProdutoVida      = String.valueOf(cotacao.Produto__r.ProductCode);
            payloadEnvioContrato.contrato.nomeProduto            = String.valueOf(cotacao.Produto__r.Name);
            payloadEnvioContrato.contrato.numeroSusepProduto     = String.valueOf(cotacao.Produto__r.NumeroSusep__c);
            payloadEnvioContrato.contrato.tipoVigencia           = (cotacao.TipoVigencia__c == null ? '' : cotacao.TipoVigencia__c);
           
            //PLV-2334-27 INICIO
            //payloadEnvioContrato.contrato.vigenciaInicial        = String.valueOf(cotacao.VigenciaInicial__c);
            //payloadEnvioContrato.contrato.vigenciaFinal          = String.valueOf(cotacao.VigenciaFinal__c);
            //PLV-2334-27 FINAL
            
            payloadEnvioContrato.contrato.tipoSeguro             = (cotacao.Tipo__c == null ? '' : cotacao.Tipo__c);
            payloadEnvioContrato.contrato.valorPremio            = (cotacao.ValorPremio__c == null ? 0 : cotacao.ValorPremio__c);
            payloadEnvioContrato.contrato.parceiro               = String.valueOf(cotacao.Parceiro__c);
            payloadEnvioContrato.contrato.idContratoParceiro     = String.valueOf(cotacao.IdContratoParceiro__c);
            payloadEnvioContrato.contrato.idContratanteParceiro  = String.valueOf(cotacao.IdContratanteParceiro__c);
            payloadEnvioContrato.contrato.canalDistribuicao      = String.valueOf(cotacao.CanalDistribuicao__r.Sigla__c);
            payloadEnvioContrato.contrato.nomeCanalDistribuicao  = String.valueOf(cotacao.CanalDistribuicao__r.Name);
            payloadEnvioContrato.contrato.tipoEndosso            = cotacao.TipoEndosso__c;


            //PLV-5033 - INICIO
            // preenche o nó de data de inclusão para o BCP
            payloadEnvioContrato.contrato.dataInclusao = (cotacao.Tipo__c == 'Novo' || cotacao.Tipo__c == 'Renovacao') ? Datetime.now().format('dd/MM/yyyy') : cotacao.Contract.DataEmissao__c.format(); //RVI-49 - INICIO/FIM
            
            // preenche o nó de data de alteração para o BCP
            payloadEnvioContrato.contrato.dataAlteracao = Datetime.now().format('dd/MM/yyyy');

            //PLV-5033 - FIM

            // preeche o nó de geração de apólice
            payloadEnvioContrato.contrato.geracaoApolice = parseDadosGeracaoApolice(cotacao.Produto__r.NumeroSusep__c);

            // preenche os dados de remuneração
            payloadEnvioContrato.contrato.remuneracoes = parseDadosRemuneracao(cotacao.Opportunity.CanalDistribuicao__r.Sigla__c, cotacao.Produto__r.NumeroSusep__c, cotacao.Empresa__r.Sucursal__c, lstRemuneracaoProposta, mapRecordType );

            // obtem os dados do segurado da proposta
            List<ContratanteProposta__c> lstContratanteProposta = QuoteDAO.getInstance().buscarContratantesPropostaPorIdProposta(new Set<Id>{cotacao.Id});
            payloadEnvioContrato.contrato.Contratantes = parseDadosContratantes(lstContratanteProposta, cotacao.RamoSeguro__c, mapRecordType);

            // Obtem os dados de precificação e monta o nó
            payloadEnvioContrato.contrato.precificacao = parseDadosPrecificacao(cotacao, lstContratanteProposta);

            //Preenche os dados de alteraçõesEndosso
            payloadEnvioContrato.contrato.alteracoesEndosso = parseDadosAlteracoesEndosso(cotacao); // INICIO/FIM | PLV-4614-VI-Guilherme Brito / Vinícius Caetano
            System.debug('payloadEnvioContrato-----------------');
            System.debug(payloadEnvioContrato);
            return payloadEnvioContrato;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento contrato)');
        }
    }

    //PLV-5190 - INICIO
    @TestVisible
    private Integer retornarNumeroEndosso(List<Contract> listContractNew) {
                
        if (listContractNew.size() == 0 ) {
            return 0;
        }

        String sEndosso = listContractNew[0].Endosso__c;
        System.debug('==> no. endosso: ' + sEndosso);

        if (sEndosso == null) {
            return 0;
        }

        if (Integer.valueOf(sEndosso) <= 0) {
            return 0;
        }

        return Integer.valueOf(sEndosso);
    }
    //PLV-5190 - FIM

    // INICIO | PLV-4614-VI-Guilherme Brito / Vinícius Caetano

    private List<ContratoTo.AlteracoesEndosso> parseDadosAlteracoesEndosso(Quote cotacao)
    {
        try
        {   //POR062-99 - INICIO  
            String listSigla = '';
            System.debug('Contrato da cotacao: ' + cotacao.Contract);
            if(Test.isRunningTest()){
                listSigla = 'CAD';
            }else{
                listSigla = [SELECT Id, SiglaTipoEndosso__c FROM Quote WHERE Id =: cotacao.Id].SiglaTipoEndosso__c;
            }
            //POR062-99 - FIM  
            if(listSigla != null){

                system.debug('>>>>>>>>>>>>>>>>>>> listSigla ' + listSigla);
                //Mock pois não existe o campo para retornar os tipos de endosso
                //List<String> mockEndossoList = new List<String>{'DES', 'PRM', 'CAD'};
                // Testando erro
                // List<String> mockEndossoList = new List<String>{'DES', 'XYZ', 'CAD'};
                Set<String> endossoList = new Set<String>();
                endossoList.addAll(listSigla.split(';'));
                system.debug('>>>>>>>>>>>>>>>>>>> endossoList ' + endossoList);
                
                List<ContratoTO.AlteracoesEndosso> lstEndosso = new List<ContratoTO.AlteracoesEndosso>();
                
                for(TipoDeEndosso__mdt tipoEndossoMetadata : [SELECT Id, Prioridade__c, SiglaSalesforce__c, TipoEndossoBCP__c FROM TipoDeEndosso__mdt ORDER BY Prioridade__c ASC]){
                    if(tipoEndossoMetadata.TipoEndossoBCP__c != null && endossoList.contains(tipoEndossoMetadata.SiglaSalesforce__c)){
                        ContratoTO.AlteracoesEndosso endosso = new ContratoTO.AlteracoesEndosso();
                        endosso.sigla = tipoEndossoMetadata.SiglaSalesforce__c;
                        endosso.codigoBCP = Integer.valueOf(tipoEndossoMetadata.TipoEndossoBCP__c);
                        endosso.ordem = Integer.valueOf(tipoEndossoMetadata.Prioridade__c);
                        
                        lstEndosso.add(endosso);
                    } else {
                        system.debug('Houve um erro ao identificar o código do endosso incluído');
                    }
                }
                system.debug('Tamanho da lista: ' + lstEndosso.size());
                return lstEndosso;
            }else{
                return null;
            }

        } catch(Exception e) {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Ocorreu um erro:\nClasse: ContractFacade \nMétodo: parseDadosAlteracoesEndosso)');
        }
    }
    // FIM | PLV-4614-VI-Guilherme Brito / Vinícius Caetano

    // PLV-2804 FIM
    @TestVisible
    private List<ContratoTO.ContratantesTO> parseDadosContratantes(List<ContratanteProposta__c> lstContratanteProposta, Id idRamo, Map<String, RecordType> mapRecordType)
    {
        try
        {
            List<ContratoTO.ContratantesTO> lstContratantes = new List<ContratoTO.ContratantesTO>();
            Map<Id,Endereco__c>          mapEnderecos = new Map<Id, Endereco__c>();
            Set<Id>                      setIdContas  = new Set<Id>();

            // Otem os endereços ligados as contas relacionadas aos segurado
            System.debug('==> Vinicius Lista Contratante ' + lstContratanteProposta);
            for(ContratanteProposta__c segurado: lstContratanteProposta)
            {
                setIdContas.add(segurado.Conta__c);
            }

            for(Endereco__c endereco: EnderecoDAO.getInstance().buscarEnderecoContas(setIdContas))
            {
                mapEnderecos.put(endereco.Conta__c, endereco);
            }
            
            //inclui Contratantes
            
            // PLV-5033 - INICIO
            mapRenda = new Map<Id,String>();
            mapExposta = new Map<Id,String>();
            // PLV-5033 - FIM
             
            for(ContratanteProposta__c contratante : lstContratanteProposta)
            {
                ContratoTO.ContratantesTO contratanteTO   = new ContratoTO.ContratantesTO();
                contratanteTO.pessoa                   = new ContratoTO.PessoaTO();

                contratanteTO.tipo         = contratante.Tipo__c;
                contratanteTO.numero       = Integer.valueOf(contratante.Numero__c);
                contratanteTO.pessoa.nome  = contratante.Conta__r.Name;
                contratanteTO.pessoa.nomeSocial = contratante.Conta__r.NomeSocial__c; //LECVPV 192 - INICIO/FIM
                contratanteTO.pessoa.email = contratante.Conta__r.Email__c;

                if(mapRecordType.get(String.valueOf(contratante.Conta__r.RecordTypeId)).Name == 'Pessoa física')
                {
                    contratanteTO.pessoa.tipo = 'FIS';
                    contratanteTO.pessoa.dadosPessoaFisica                         = new ContratoTO.DadospessoafisicaTO();

                    String cpf = contratante.Conta__r.Cpf__c.replace('.','').replace('-','');

                    contratanteTO.pessoa.dadosPessoaFisica.numeroCpf               = cpf.substring(0, 9);
                    contratanteTO.pessoa.dadosPessoaFisica.digitoCpf               = cpf.substring(9, 11);

                    if( !String.isBlank(contratante.Conta__r.Sexo__c))  contratanteTO.pessoa.dadosPessoaFisica.sexo  = contratante.Conta__r.Sexo__c.substring(0,1); // PLV-3723

                    contratanteTO.pessoa.dadosPessoaFisica.estadoCivil             = mapEstadoCivil.get(contratante.Conta__r.EstadoCivil__c);
                    contratanteTO.pessoa.dadosPessoaFisica.dataNascimento          = String.valueOf(contratante.Conta__r.PersonBirthdate);

                }
                else if(mapRecordType.get(String.valueOf(contratante.Conta__r.RecordTypeId)).Name == 'Pessoa jurídica')
                {
                    contratanteTO.pessoa.tipo = 'JUR';
                    contratanteTO.pessoa.dadosPessoaJuridica              = new ContratoTO.DadospessoajuridicaTO();
                    String cnpj = contratante.Conta__r.Cnpj__c.replace('.','').replace('/','').replace('-','');
                    contratanteTO.pessoa.dadosPessoaJuridica.ordemCnpj    = cnpj.substring(0,8);
                    contratanteTO.pessoa.dadosPessoaJuridica.numeroCnpj   = cnpj.substring(8,12);
                    contratanteTO.pessoa.dadosPessoaJuridica.digitoCnpj   = cnpj.substring(12,14);
                }

                contratanteTO.pessoa.enderecos = this.parseDadosEnderecos(mapEnderecos.values(), contratante.Conta__c);
                contratanteTO.pessoa.telefones = this.parseDadosTelefone(contratante.Conta__r);

                System.debug('Contratante.Responsalvel Vinicius'+ contratante.ResponsavelPagamento__c);

                //inclui dados de pagamento....
                if(contratante.ResponsavelPagamento__c != null)
                {
                    contratanteTO.dadosPagamento = this.parseDadosPagamento('Contratante', contratante, null, mapRecordType);
                }
                contratanteTO.grupos = this.parseDadosGrupo(GrupoPropostaDAO.getInstance().buscarGruposPropostaPorIds(new Set<Id>{contratante.Id}), contratante.Proposta__c, idRamo, mapRecordType);
                
                //PLV-5033 - INICIO
                contratanteTO.pessoa.faixaRenda = 6;
                if(mapRenda.containsKey(contratante.Conta__c)){
                    String faixaRenda = mapRenda.get(contratante.Conta__c);
                    if(faixaRenda == '2500'){
                        contratanteTO.pessoa.faixaRenda = 2;
                    }
                    else if(faixaRenda == '4000'){
                        contratanteTO.pessoa.faixaRenda = 3;
                    }
                    else if(faixaRenda == '8000'){
                        contratanteTO.pessoa.faixaRenda = 4;
                    }
                    else{
                        contratanteTO.pessoa.faixaRenda = 5;
                    }
                }
                if(mapExposta.containsKey(contratante.Conta__c)){
                    String exposta = mapExposta.get(contratante.Conta__c);
                    if(exposta == 'Sim'){
                        contratanteTO.pessoa.pessoaExpostaPoliticamente = 1;
                    }
                    else if(exposta == 'Não'){
                        contratanteTO.pessoa.pessoaExpostaPoliticamente = 2;
                    }
                    else if(exposta == 'RelacionamentoProximo'){
                        contratanteTO.pessoa.pessoaExpostaPoliticamente = 3;
                    }
                }
                //PLV-5033 - FIM
                
                lstContratantes.add(contratanteTO);
            }

            return lstContratantes;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento Contratantes)');
        }
    }

    private ContratoTO.GeracaoapoliceTO parseDadosGeracaoApolice(String numeroSusep)
    {
        try
        {
            ContratoTO.GeracaoapoliceTO geracaoApolice              = new ContratoTO.GeracaoapoliceTO();

            geracaoApolice.arquivo                                  = new ContratoTO.ArquivoTO();
            geracaoApolice.arquivo.cabecalho                        = new ContratoTO.CabecalhoTO();
            geracaoApolice.arquivo.observacoes                      = new ContratoTO.ObservacoesTO();

            geracaoApolice.idAplicacaoUtilizadora                               = '100';
            geracaoApolice.unidadeNegocio                                       = '4';
            geracaoApolice.centroDeCustoPagador                                 = '0000';
            geracaoApolice.nomeArquivoJasper                                    = 'VIDA/Individual/Apolice_Endosso_V3.jasper';
            geracaoApolice.nomeDiretorioArquivo                                 = '671433';
            geracaoApolice.nomeRelatorioGerado                                  = 'SUCURSAL-RAMO-APOL';
            geracaoApolice.tipoExtensaoGerada                                   = 'pdf';
            geracaoApolice.leituraApartir                                       = '/report';
            geracaoApolice.assinaturaDiretor                                    = '../imagens/assinaturas/assinaturaPresidenteDiretor.png';
            geracaoApolice.fileSystem                                           = 'ECM';

            //geracaoApolice.arquivo.codigoCondicaoGeral                          =
            geracaoApolice.arquivo.numeroProcessoSusepCNSP315                   = numeroSusep;
            geracaoApolice.arquivo.exibirMensagemRenovacao                      = 'S';
            geracaoApolice.arquivo.cabecalho.image                              = '../imagens/logos/Vida_Previdencia.gif';
            geracaoApolice.arquivo.textoInformativo                             = 'Invalidez Permanente Total ou Parcial por Acidente (***)De acordo com a Tabela de Invalidez Permanente Total ou Parcial constante nas Condições Gerais';
            geracaoApolice.arquivo.unidadeOperacional                           = '100 VIDA E PREVIDENCIA';
            geracaoApolice.arquivo.mensagemProcessoSusep                        = 'As condições contratuais/regulamento deste produto protocolizadas pela sociedade/entidade junto à Susep poderão ser consultadas no endereço eletrônico www.susep.gov.br, de acordo com o número de processo constante da apólice, proposta, bilhete, certificado ou no título de capitalização. Telefone SUSEP: 0800 021 8484.'; //POR062-5 - FIX-02 - INICIO/FIM
            geracaoApolice.arquivo.mensagemAssistenciaFuneral                   = 'Atendimento Assistência Funeral - 24 horas (11) 4196-8181 ou 0800 727 9393. Ligação Gratuita.';
            geracaoApolice.arquivo.observacoes.condicoesGerais                  = 'As informações contidas nas Condições Gerais anexas, estão relacionadas à total abrangência do produto. As Garantias e Capitais contratados neste seguro, estão discriminados no corpo da Apólice';

            return geracaoApolice;

        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento dados geracao apolice)');
        }
    }

    @TestVisible
    private List<ContratoTO.RemuneracoesTO> parseDadosRemuneracao(String canal, String numeroSusep, String sucursal, List<RemuneracaoProposta__c> lstRemoneracao, Map<String, RecordType> mapRecordType)
    {
        try
        {
            List<ContratoTO.remuneracoesTO> remuneracoes = new List<ContratoTO.remuneracoesTO>();

            for(RemuneracaoProposta__c rem : lstRemoneracao)
            {
                ContratoTO.remuneracoesTO remuneracao   = new ContratoTO.remuneracoesTO();
                remuneracao.favorecidos                 = new List<ContratoTO.FavorecidosTO>();

                remuneracao.tipoRemuneracao             = rem.TipoRemuneracao__r.Name;
                remuneracao.percentual                  = Integer.valueOf(rem.Percentual__c);
                
                for(FavorecidoRemuneracaoProposta__c item : rem.FavorecidosRemuneracaodaProposta__r)
                {
                    ContratoTO.FavorecidosTO favorecido     = new ContratoTO.FavorecidosTO();
                    
                    favorecido.papel                        = item.Papel__c;
                    favorecido.participacao                 = item.Participacao__c;
                    favorecido.pessoa                       = new ContratoTO.PessoaTO();
                    favorecido.pessoa.nome                  = item.Conta__r.Name;
                    favorecido.corretorLider                = item.CorretorLider__c;// == true ? 'S': 'N';
                    favorecido.susepOficialCorretor         = item.SusepOficialCorretor__c;
                    favorecido.susepEmissao                 = item.SusepEmissao__c;
                    favorecido.susepOrcamento               = item.SusepOrcamento__c;
                    favorecido.susep                        = item.susep__c; //PLV-3572 - INICIO/FIM

                    if(mapRecordType.get(String.valueOf(item.Conta__r.RecordTypeId)).Name == 'Pessoa física')
                    {
                        favorecido.pessoa.tipo = 'FIS';
                        favorecido.pessoa.dadosPessoaFisica = new ContratoTO.DadospessoafisicaTO();

                        String cpf = item.Conta__r.Cpf__c.replace('.','').replace('-','');

                        favorecido.pessoa.dadosPessoaFisica.numeroCpf               = cpf.substring(0, 9);
                        favorecido.pessoa.dadosPessoaFisica.digitoCpf               = cpf.substring(9, 11);

                        if( !String.isBlank(item.Conta__r.Sexo__c))  favorecido.pessoa.dadosPessoaFisica.sexo    =   item.Conta__r.Sexo__c.substring(0,1); // PLV-3723

                        favorecido.pessoa.dadosPessoaFisica.estadoCivil             = mapEstadoCivil.get(item.Conta__r.EstadoCivil__c);
                    }
                    else if(mapRecordType.get(String.valueOf(item.Conta__r.RecordTypeId)).Name == 'Pessoa jurídica')
                    {
                        favorecido.pessoa.tipo = 'JUR';
                        favorecido.pessoa.dadosPessoaJuridica              = new ContratoTO.DadospessoajuridicaTO();
                        String cnpj = item.Conta__r.Cnpj__c.replace('.','').replace('/','').replace('-','');
                        favorecido.pessoa.dadosPessoaJuridica.ordemCnpj    = cnpj.substring(0,8);
                        favorecido.pessoa.dadosPessoaJuridica.numeroCnpj   = cnpj.substring(8,12);
                        favorecido.pessoa.dadosPessoaJuridica.digitoCnpj   = cnpj.substring(12,14);
                    }

                    remuneracao.favorecidos.add(favorecido);
                }
                remuneracoes.add(remuneracao);
            }

            return remuneracoes;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento dados remuneração)');
        }
    }

    private ContratoTO.DadospagamentoTO parseDadosPagamento(String objeto, ContratanteProposta__c contratante, SeguradoProposta__c segurado, Map<String, RecordType> mapRecordType)
    {
        Account responsavelPGTO;
        String tipoResponsavelPagamento;
        Integer quantidadeParcelas;
        //PLV-3393 - INICIO - Integração BCP
        Integer codigo;        
        //PLV-3393 - FIM - Integração BCP

        if(objeto == 'Contratante')
        {
            tipoResponsavelPagamento = contratante.TipoResponsavelPagamento__c;
            quantidadeParcelas      = Integer.valueOf(contratante.QuantidadeParcelas__c);
            responsavelPGTO         = contratante.ResponsavelPagamento__r;
            //PLV-3393 - INICIO - Integração BCP
            if(contratante.FormaPagamento__r != null){
            	codigo                  = Integer.valueOf(contratante.formaPagamento__r.codigo__c); 
            }    
            //PLV-3393 - FIM - Integração BCP
        }
        else if(objeto == 'Segurado')
        {
            tipoResponsavelPagamento    = segurado.TipoResponsavelPagamento__c;
            quantidadeParcelas          = Integer.valueOf(segurado.QuantidadeParcelas__c);
            responsavelPGTO             = segurado.ResponsavelPagamento__r;
        }

        try
        {
            ContratoTO.DadospagamentoTO  dadosPGTO    = new ContratoTO.DadospagamentoTO();
            Map<Id,Endereco__c>          mapEnderecos = new Map<Id, Endereco__c>();
            Set<Id>                      setIdContas  = new Set<Id>();

            // Otem os endereços ligados as contas relacionadas aos segurado
            setIdContas.add(ResponsavelPGTO.id);

            for(Endereco__c endereco: EnderecoDAO.getInstance().buscarEnderecoContas(setIdContas))
                mapEnderecos.put(endereco.Conta__c, endereco);

            dadosPGTO.tipoResponsavelPagamento      = tipoResponsavelPagamento;
            dadosPGTO.quantidadeParcelas            = quantidadeParcelas;
            dadosPGTO.responsavelPagamento          = new ContratoTO.ResponsavelpagamentoTO();
            dadosPGTO.responsavelPagamento.nome     = ResponsavelPGTO.Name;
            //dadosPGTO.responsavelPagamento.email    = ResponsavelPGTO.Email__c;

            //PLV-3393 - INICIO - Integração BCP
            if(objeto == 'Contratante'){
                dadosPGTO.formaPagamento = new ContratoTO.FormaPagamentoTO();
                dadosPGTO.formaPagamento.codigo  = codigo;             
            }    
            //PLV-3393 - FIM - Integração BCP

            if(mapRecordType.get(String.valueOf(ResponsavelPGTO.RecordTypeId)).Name  == 'Pessoa jurídica')
            {
                dadosPGTO.responsavelPagamento.tipo = 'JUR';
                dadosPGTO.responsavelPagamento.dadosPessoaJuridica = new ContratoTO.DadospessoajuridicaTO();
                String cnpj = ResponsavelPGTO.Cnpj__c.replace('.','').replace('/','').replace('-','');
                dadosPGTO.responsavelPagamento.dadosPessoaJuridica.ordemCnpj    = cnpj.substring(0,8);
                dadosPGTO.responsavelPagamento.dadosPessoaJuridica.numeroCnpj   = cnpj.substring(8,12);
                dadosPGTO.responsavelPagamento.dadosPessoaJuridica.digitoCnpj   = cnpj.substring(12,14);
            }
            system.debug('parceseguradosGrupo >> parseDadosPagamento');
            dadosPGTO.responsavelPagamento.enderecos = this.parseDadosEnderecos(mapEnderecos.values(), ResponsavelPGTO.Id);
            dadosPGTO.responsavelPagamento.telefones = this.parseDadosTelefone(ResponsavelPGTO);

            // system.debug('INICIA PARCE DE PARCELAS: ');
            // system.debug('INICIA PARCE DE PARCELAS: ' + segurado);
            if(objeto == 'Contratante')
            {
                dadosPGTO.parcelas = this.parseDadosParcelas(
                        Integer.valueOf(contratante.QuantidadeParcelas__c),
                        contratante.IOF__c,
                        contratante.PremioComercial__c,
                        contratante.FormaPagamento__r.Codigo__c,
                        contratante.VencimentoPrimeiraParcela__c
                );
            }
            else if(objeto == 'Segurado')
            {
                dadosPGTO.parcelas = this.parseDadosParcelas(
                        Integer.valueOf(segurado.QuantidadeParcelas__c),
                        segurado.IOF__c,
                        segurado.PremioComercial__c,
                        segurado.FormaPagamento__r.Codigo__c,
                        segurado.VencimentoPrimeiraParcela__c
                );
            }

            return dadosPGTO;

        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento Dados pagamento)');
        }
    }

    private List<ContratoTO.ParcelasTO> parseDadosParcelas(Integer quantidadeParcelas, Decimal iof, Decimal valor, String codFormaPgto, Date vencPrimeiraParc)
    {
        try
        {
            ContractBO bo = ContractBO.getInstance();

            List<ContratoTO.ParcelasTO> parcelas = new List<ContratoTO.ParcelasTO>();
            for(Integer i = 0; i < quantidadeParcelas; i++)
            {
                ContratoTO.ParcelasTO parcela 	= new ContratoTO.ParcelasTO();

                parcela.meioPagamento           = codFormaPgto;
                parcela.numeroParcela           = i;
                parcela.valorIOF                = bo.calcularValor(quantidadeParcelas, 0, iof);
                parcela.valorParcela            = bo.calcularValor(quantidadeParcelas, 0, valor);
                parcela.dataVencimentoParcela   = String.valueOf(vencPrimeiraParc.addMonths(i));

                parcelas.add(parcela);
            }
            return parcelas;

        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento parcelas)');
        }
    }

    @TestVisible
    private List<ContratoTO.GruposTO> parseDadosGrupo(List<GrupoProposta__c> gruposProp, Id idProposta, Id idRamo, Map<String, RecordType> mapRecordType)
    {
        try
        {
            List<ContratoTO.GruposTO> grupos = new List<ContratoTO.GruposTO>();

            for(GrupoProposta__c grupoP : gruposProp)
            {
                ContratoTO.GruposTO grupo = new ContratoTO.GruposTO();

                grupo.numero = 1;

                grupo.nome 		= grupoP.Name;
                if(grupoP.Descricao__c != null)
                    grupo.numero 	= Integer.valueOf(grupoP.Descricao__c);
                if(grupoP.QuantidadeVidas__c != null)
                    grupo.qtdeVidas = Integer.valueOf(grupoP.QuantidadeVidas__c);

                grupo.segurados = this.parceseguradosGrupo(SeguradoPropostaDAO.getInstance().buscarGruposPropostaPorIds(new Set<Id>{grupoP.Id}), idProposta, idRamo, mapRecordType);

                grupos.add(grupo);
            }

            return grupos;

        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento dados grupo)');
        }
    }
    @TestVisible
    private List<ContratoTO.SeguradosTO> parceseguradosGrupo(List<SeguradoProposta__c> seguradosGrupo, Id idProposta, Id idRamo, Map<String, RecordType> mapRecordType)
    {
        try
        {

            List<ContratoTO.SeguradosTO> segurados = new List<ContratoTO.SeguradosTO>();
            for(SeguradoProposta__c seguradoGP : seguradosGrupo)
            {
                ContratoTO.SeguradosTO segurado = new ContratoTO.SeguradosTO();
                segurado.numero 			= Integer.valueOf(seguradoGP.Numero__c);
                
                segurado.pessoa 			= new ContratoTO.PessoaTO();

                segurado.pessoa.nome        = seguradoGP.Conta__r.Name;
                segurado.pessoa.nomeSocial  = seguradoGP.Conta__r.NomeSocial__c; //LECVPV 192 - INICIO/FIM

                System.debug('mapRecordType => ' + JSON.serialize(mapRecordType));
                System.debug('seguradosGrupo => ' + JSON.serialize(seguradoGP));

                segurado.pessoa.email        = seguradoGP.Conta__r.Email__c;

                if(mapRecordType.get(String.valueOf(seguradoGP.Conta__r.RecordTypeId)).Name == 'Pessoa física')
                {
                    segurado.pessoa.tipo = 'FIS';
                    segurado.pessoa.dadosPessoaFisica               = new ContratoTO.DadospessoafisicaTO();
                    String cpf = seguradoGP.Conta__r.Cpf__c.replace('.','').replace('-','');
                    segurado.pessoa.dadosPessoaFisica.numeroCpf     = cpf.substring(0, 9);
                    segurado.pessoa.dadosPessoaFisica.digitoCpf     = cpf.substring(9, 11);

                    if( !String.isBlank(seguradoGP.Conta__r.Sexo__c) )  segurado.pessoa.dadosPessoaFisica.sexo   = seguradoGP.Conta__r.Sexo__c.substring(0,1); // PLV-3723

                    segurado.pessoa.dadosPessoaFisica.estadoCivil   = mapEstadoCivil.get(seguradoGP.Conta__r.EstadoCivil__c);
                    //PLV-3572 - INICIO - Enviar para BCP dados do segurado
                    segurado.pessoa.dadosPessoaFisica.dataNascimento          = String.valueOf(seguradoGP.Conta__r.PersonBirthdate);
                    segurado.pessoa.dadosPessoaFisica.email                   = seguradoGP.conta__r.PersonEmail;
                    //PLV-3572 - FIM - Enviar para BCP dados do segurado
                }
                else if(mapRecordType.get(String.valueOf(seguradoGP.Conta__r.RecordTypeId)).Name == 'Pessoa jurídica')
                {
                    segurado.pessoa.tipo = 'JUR';
                    segurado.pessoa.dadosPessoaJuridica              = new ContratoTO.DadospessoajuridicaTO();
                    String cnpj = seguradoGP.Conta__r.Cnpj__c.replace('.','').replace('/','').replace('-','');
                    segurado.pessoa.dadosPessoaJuridica.ordemCnpj    = cnpj.substring(0,8);
                    segurado.pessoa.dadosPessoaJuridica.numeroCnpj   = cnpj.substring(8,12);
                    segurado.pessoa.dadosPessoaJuridica.digitoCnpj   = cnpj.substring(12,14);
                }

                if(seguradoGP.ResponsavelPagamento__c != null)
                    segurado.dadosPagamento   = this.parseDadosPagamento('Segurado', null, seguradoGP, mapRecordType);
                System.debug('Danilo seguradoGP.Id' + String.valueOf(seguradoGP.Id)); 
                segurado.beneficiarios     = this.parseDadosBeneficiarioSegurado(BeneficiarioSeguradoPropostaDAO.getInstance().buscarBeneficiariosSeguradoProposta(new Set<String>{String.valueOf(seguradoGP.Id)}));
                segurado.coberturas	    = this.parseDadosCoberturas(GarantiaPropostaDAO.getInstance().buscarGruposPropostaPorIds(new Set<Id>{idProposta}), idRamo);
                system.debug('parceseguradosGrupo >> telefone');
                segurado.pessoa.telefones = this.parseDadosTelefone(seguradoGP.Conta__r);

                segurados.add(segurado);

                //PLV-5033 - INICIO

                if( mapRenda == null )
                {                    
                    mapRenda = new Map<Id,String>();            
                }


                if( mapExposta == null )
                {                                       
                    mapExposta = new Map<Id,String>();
                }


                mapRenda.put(seguradoGP.Conta__c, seguradoGP.FaixaRenda__c);
                mapExposta.put(seguradoGP.Conta__c, seguradoGP.PEP__c);
                //PLV-5033 - FIM
            }

            return segurados;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento segurados grupo)');
        }        
    }

    @testVisible
    private List<ContratoTO.BeneficiariosTO> parseDadosBeneficiarioSegurado(List<BeneficiarioSeguradoProposta__c> beneficiariosVida)
    {
        try
        {
            List<ContratoTO.BeneficiariosTO> beneficiarios;

            for(BeneficiarioSeguradoProposta__c beneficiarioVP : beneficiariosVida)
            {
                ContratoTO.BeneficiariosTO beneficiario = new ContratoTO.BeneficiariosTO();
                beneficiario.nome                       = beneficiarioVP.Nome__c;
                beneficiario.cpfCnpj                    = beneficiarioVP.CpfCnpj__c;
                beneficiario.participacao               = beneficiarioVP.Participacao__c;
                beneficiario.Pep                        = beneficiarioVP.Pep__c;
                beneficiario.grauParentesco             = beneficiarioVP.GrauParentesco__c;
                beneficiario.tipoBeneficiario           = beneficiarioVP.TipoBeneficiario__c;

                if(beneficiarios == null)
                    beneficiarios = new List<ContratoTO.BeneficiariosTO>();
                beneficiarios.add(beneficiario);
            }

            return beneficiarios;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            //throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento beneficiarios segurado)');
           
        }
        return null;
    }

    @testVisible
    List<ContratoTO.CoberturasTO> parseDadosCoberturas(List<GarantiaProposta__c> garantias, Id idRamoSeguro)
    {
        try
        {
            List<ContratoTO.CoberturasTO> coberturas;

            //PLV-5259 - INICIO
            Set<Id> idsGarantiaProduto = new Set<Id>();
            System.debug('Danilo garantias ' + garantias);
            for(GarantiaProposta__c garantia : garantias)
            {
                idsGarantiaProduto.add(garantia.GarantiaProduto__c);
            } 
            System.debug('Danilo idsGarantiaProduto ' + idsGarantiaProduto);
            Map<String, List<CarenciaGarantia__c>> mapCarenciasGarantia = CarenciaGarantiaDAO.getInstance().buscarMapCarenciasGarantia(idsGarantiaProduto);
            Map<String, List<FranquiaGarantia__c>> mapFranquiasGarantia = FranquiaGarantiaDAO.getInstance().buscarMapFranquiasGarantia(idsGarantiaProduto);            

            for(GarantiaProposta__c garantia : garantias)
            {
                ContratoTO.CoberturasTO cobertura = new ContratoTO.CoberturasTO();
             
                cobertura.sigla                             = garantia.Garantia__r.Sigla__c;
                cobertura.clausulaReducaoFranquiaAcidente   = 'SIM';
                cobertura.valor                             = garantia.Capital__c;
                cobertura.descricaoGarantia                 = garantia.Garantia__r.Name;
                cobertura.numeroSorte                       = garantia.NumeroSorte__c;
                cobertura.numeroSerie                       = garantia.NumeroSerie__c;
                System.debug('Danilo garantia.GarantiaProduto__c:' + garantia.GarantiaProduto__c);
                System.debug('Danilo mapCarenciasGarantia:' + mapCarenciasGarantia);
                System.debug('Danilo mapCarenciasGarantia.get(garantia.GarantiaProduto__c):' + mapCarenciasGarantia.get(garantia.GarantiaProduto__c));
                
                //PLV-5392 INICIO
                if(mapCarenciasGarantia.get(garantia.GarantiaProduto__c) != null){
                    for(CarenciaGarantia__c carenciaGar :  mapCarenciasGarantia.get(garantia.GarantiaProduto__c))
                    {
                    ContratoTO.CarenciasTO carencia = new ContratoTO.CarenciasTO();
                    carencia.descricao = carenciaGar.Carencia__r.Descricao__c;

                    if(cobertura.carencias == null) cobertura.carencias = new List<ContratoTO.CarenciasTO>();

                    cobertura.carencias.add(carencia);
                    }
                }
                
                if(mapFranquiasGarantia.get(garantia.GarantiaProduto__c) != null){
                    for(FranquiaGarantia__c franquiaGar :  mapFranquiasGarantia.get(garantia.GarantiaProduto__c))
                    {
                    ContratoTO.FranquiasTO franquia = new ContratoTO.FranquiasTO();
                    franquia.descricao = franquiaGar.Franquia__r.Descricao__c;

                    if(cobertura.franquias == null) cobertura.franquias = new List<ContratoTO.FranquiasTO>();

                    cobertura.franquias.add(franquia);
                    }                
                }
                //PLV-5392 FIM

                if(coberturas == null) coberturas = new List<ContratoTO.CoberturasTO>();

                coberturas.add(cobertura);
                //PLV-5259 - FIM
            }

            return coberturas;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento coberturas)');
        }
    }

    // PLV-2335 - Inicio - RollBack
    @TestVisible public List<ContratoTO.TelefonesTO> parseDadosTelefone (Account conta) //POR062-99 INICIO - FIM
    {
        try
        {
            List<ContratoTO.TelefonesTO> telefones;

            if(conta.Phone != null)//CEL
            {
                ContratoTO.TelefonesTO t = new ContratoTO.TelefonesTO();
                String telefone = conta.Phone.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');

                t.tipoTelefone = 'CEL';
                //PLV-3723 Inicio 
                t.dddTelefone = telefone.substring(0, 2);
                t.numeroTelefone = telefone.substring(2, telefone.length());
                //PLV-3723 FIM

                if(telefones == null)
                    telefones = new List<ContratoTO.TelefonesTO>();

                telefones.add(t);
            }

            if(conta.PersonHomePhone != null)//RES
            {
                String telefoneP = conta.PersonHomePhone.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');

                ContratoTO.TelefonesTO t = new ContratoTO.TelefonesTO();
                t.tipoTelefone = 'RES';
                //PLV-3723 Inicio 
                t.dddTelefone = telefoneP.substring(0, 2);
                t.numeroTelefone = telefoneP.substring(2, telefoneP.length());
                //PLV-3723 FIM

                if(telefones == null)
                    telefones = new List<ContratoTO.TelefonesTO>();

                telefones.add(t);
            }

            if(conta.PersonOtherPhone != null)//COM
            {
                String telefoneP = conta.PersonOtherPhone.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');

                ContratoTO.TelefonesTO t = new ContratoTO.TelefonesTO();
                t.tipoTelefone = 'COM';
                //PLV-3723 Inicio 
                t.dddTelefone = telefoneP.substring(0, 2);
                t.numeroTelefone = telefoneP.substring(2, telefoneP.length());
                //PLV-3723 FIM

                if(telefones == null)
                    telefones = new List<ContratoTO.TelefonesTO>();

                telefones.add(t);
            }

            if(conta.Fax != null)//FAX
            {
                String telefoneP = conta.Fax.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');

                ContratoTO.TelefonesTO t = new ContratoTO.TelefonesTO();
                t.tipoTelefone = 'Fax';
                //PLV-3723 Inicio 
                t.dddTelefone = telefoneP.substring(0, 2);
                t.numeroTelefone = telefoneP.substring(2, telefoneP.length());
                //PLV-3723 FIM

                if(telefones == null)
                    telefones = new List<ContratoTO.TelefonesTO>();

                telefones.add(t);
            }
            
            // LECVP-69 - Inicio
            if(conta.PersonMobilePhone != null)//PersonMobilePhone
            {
                String telefoneP = conta.PersonMobilePhone.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');

                ContratoTO.TelefonesTO t = new ContratoTO.TelefonesTO();
                t.tipoTelefone = 'CEL';
                t.dddTelefone = telefoneP.substring(0, 2);
                t.numeroTelefone = telefoneP.substring(2, telefoneP.length());

                if(telefones == null)
                    telefones = new List<ContratoTO.TelefonesTO>();

                telefones.add(t);
            }
            // LECVP-69 - Fim

            return telefones;

        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento telefone)');
        }
    }
    // PLV-2335 - Fim

    @TestVisible //ANNVI- 55 - INICIO/FIM
    private List<ContratoTO.EnderecosTO> parseDadosEnderecos(List<Endereco__c> lstEnderecos, Id idConta)
    {
        List<ContratoTO.EnderecosTO> enderecos;

        try
        {
            for(Endereco__c endSeg : lstEnderecos)
            {
                system.debug('endSeg: '+ endSeg);
                if(endSeg.Conta__c == idConta)
                {
                    ContratoTO.EnderecosTO endSegurado = new ContratoTO.EnderecosTO();

                    endSegurado.tipoLogradouro      = endSeg.TipoLogradouro__c;
                    endSegurado.cidade              = endSeg.Cidade__c;
                    endSegurado.tipoEndereco        = endSeg.TipoEndereco__c;
                    endSegurado.logradouro          = endSeg.Logradouro__c;
                    endSegurado.bairro              = endSeg.Bairro__c;
                    endSegurado.cep                 = endSeg.CEP__c.substring(0, 5);
                    endSegurado.uf                  = endSeg.Estado__c;
                    endSegurado.numeroLogradouro    = endSeg.Numero__c;
                    endSegurado.paisResidencia      = 'BRA';//endSeg.Pais__c; - PLV 4362 alterado para hardcode por enquanto pois é necessário enviar a sigla
                    endSegurado.complementoCep      = endSeg.CEP__c.substring(5, 8);
                    //PLV-5033 - INICIO
                    endSegurado.complemento =  (String.isBlank(endSeg.Complemento__c)) ? '' : endSeg.Complemento__c;
                    //PLV-5033 - FIM
                    if(enderecos == null)
                        enderecos = new List<ContratoTO.EnderecosTO>();

                    enderecos.add(endSegurado);
                }
            }

            return enderecos;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento endereço)');
        }
    }

    @TestVisible // PLV-5249 - INÍCIO e FIM
    private ContratoTO.PrecificacaoTO parseDadosPrecificacao(Quote cotacao, List<ContratanteProposta__c> lstContratanteProposta)
    {
        system.debug('ContractFacade >> parseDadosPrecificacao');

        system.debug('ContractFacade >> parseDadosPrecificacao >> iof: ' + cotacao.IOF__c);
        ContratoTO.PrecificacaoTO precificacao = new ContratoTO.PrecificacaoTO();

        precificacao.premio             = new ContratoTO.PremioTO();
        precificacao.taxa               = new ContratoTO.TaxaTO();
        precificacao.Contratantes          = new List<ContratoTO.ContratantesTO>();
        precificacao.coberturas         = new List<ContratoTO.CoberturasTO>();

        precificacao.custoApolice       = 0;
        precificacao.iof                = cotacao.IOF__c;
        precificacao.juros              = 0;
        precificacao.encargos           = 0;

        precificacao.premio.puro        = 0;
        precificacao.premio.integral    = 0; //PLV-5351 INICIO/FIM
        precificacao.premio.comercial   = 0;
        precificacao.premio.total       = 0;

        precificacao.taxa.pura          = 0;
        precificacao.taxa.comercial     = 0;
        precificacao.taxa.Total         = 0;
        
        // PLV-5249 - INÍCIO

        // Conjunto de Ids dos Contratantes da Proposta.
        Set<Id> idsContratanteProposta = new Set<Id>();
        
        for(ContratanteProposta__c contratante : lstContratanteProposta)
        {
            idsContratanteProposta.add(contratante.Id);
        } 
        // Mapa dos Grupos dos Contratantes da Proposta.
        Map<String, List<GrupoProposta__c>> mapGrupos = GrupoPropostaDAO.getInstance().buscarMapGruposPropostaPorIds(idsContratanteProposta);

        // Conjunto de Ids dos Grupos da Proposta.
        Set<Id> idsGrupoProposta = new Set<Id>();

        for(ContratanteProposta__c contratante : lstContratanteProposta)
        {
            for(GrupoProposta__c grupo : mapGrupos.get(contratante.Id))
            {
                idsGrupoProposta.add(grupo.Id);
            }
        }

        Map<String, List<GarantiasGrupoProposta__c>> mapgarantiasgrupo = GarantiasGrupoPropostaDAO.getInstance().mapGarantiasVida(idsGrupoProposta);

        // Lista de Garantias da Proposta.
        List<GarantiaProposta__c> lstGarantiasProposta = GarantiaPropostaDAO.getInstance().buscarGruposPropostaPorIds(new Set<Id>{cotacao.Id});

        system.debug('ContractFacade >> parseDadosPrecificacao >> Contratantes: ' + lstContratanteProposta);
        for(ContratanteProposta__c contratante : lstContratanteProposta)
        {
            system.debug('ContractFacade >> parseDadosPrecificacao >> contratante: ' + contratante);

            precificacao.premio.puro        = precificacao.premio.puro      + ((contratante.PremioPuro__c != null) ? contratante.PremioPuro__c : 0);
            precificacao.premio.comercial   = precificacao.premio.comercial + ((contratante.PremioComercial__c != null) ? contratante.PremioComercial__c : 0);
            precificacao.premio.total       = precificacao.premio.total != null ? precificacao.premio.total : 0  + contratante.PremioTotal__c != null ? contratante.PremioTotal__c : 0;
            precificacao.taxa.pura          = precificacao.taxa.pura        + ((contratante.TaxaPura__c != null) ? contratante.TaxaPura__c : 0);
            precificacao.taxa.comercial     = precificacao.taxa.comercial   + ((contratante.TaxaComercial__c != null) ? contratante.TaxaComercial__c : 0);
            precificacao.taxa.total         = precificacao.taxa.total != null ? precificacao.taxa.total : 0 + contratante.TaxaTotal__c != null ? contratante.TaxaTotal__c : 0;

            ContratoTO.ContratantesTO ContratanteTO = new ContratoTO.ContratantesTO();
            ContratanteTO.grupos                 = new List<ContratoTO.GruposTO>();
            ContratanteTO.coberturas             = new List<ContratoTO.CoberturasTO>();
            ContratanteTO.premio                 = new ContratoTO.PremioTO();
            ContratanteTO.taxa                   = new ContratoTO.TaxaTO();

            ContratanteTO.premio.puro      = contratante.PremioPuro__c;
            ContratanteTO.premio.comercial = contratante.PremioComercial__c;
            ContratanteTO.premio.total     = contratante.PremioTotal__c;
            ContratanteTO.premio.integral  = contratante.PremioIntegral__c; //PLV-5351 INICIO/FIM
            ContratanteTO.taxa.pura        = contratante.TaxaPura__c;
            ContratanteTO.taxa.comercial   = contratante.TaxaComercial__c;
            ContratanteTO.taxa.Total       = contratante.TaxaTotal__c;
            ContratanteTO.iof              = contratante.IOF__c;

            // quando vier mais de um segurado, mudar a rotina p/ trabalhar com bookAPI
            for(GrupoProposta__c grupo : mapGrupos.get(contratante.Id))
            {
                ContratoTO.GruposTO grupoTO = new ContratoTO.GruposTO();
                grupoTO.segurados           = new List<ContratoTO.SeguradosTO>();
                grupoTO.coberturas          = new List<ContratoTO.CoberturasTO>();
                grupoTO.premio              = new ContratoTO.PremioTO();
                grupoTO.taxa                = new ContratoTO.TaxaTO();

                grupoTO.premio.puro      = grupo.PremioPuro__c;
                grupoTO.premio.integral  = grupo.PremioIntegral__c; //PLV-5351 INICIO/FIM
                grupoTO.premio.comercial = grupo.PremioComercial__c;
                grupoTO.premio.total     = grupo.PremioTotal__c;
                grupoTO.taxa.pura        = grupo.TaxaPura__c;
                grupoTO.taxa.comercial   = grupo.TaxaComercial__c;
                grupoTO.taxa.total       = grupo.TaxaTotal__c;
                //grupoTO.iof              = grupo.IOF__c;

                //List<GarantiasGrupoProposta__c> lstgarantiagrupo = GarantiasGrupoPropostaDAO.getInstance().listaGarantiasVida(new Set<Id>{grupo.Id});

                for(GarantiasGrupoProposta__c garantiagrupo : mapgarantiasgrupo.get(grupo.Id))
                {
                    ContratoTO.CoberturasTO coberturaTO = new ContratoTO.CoberturasTO();
                    coberturaTO.premio                  = new ContratoTO.PremioTO();
                    coberturaTO.taxa                    = new ContratoTO.TaxaTO();

                    coberturaTO.sigla                   = garantiagrupo.GarantiaReferenciada__r.Sigla__c;
                    coberturaTO.capital                 = garantiagrupo.Capital__c;
                    //coberturaTO.iof                     = garantiagrupo.IOF__c;

                    coberturaTO.premio.puro             = garantiagrupo.PremioPuro__c;
                    coberturaTO.premio.integral         = garantiagrupo.PremioIntegral__c; //PLV-5351 INICIO/FIM
                    coberturaTO.premio.comercial        = garantiagrupo.PremioComercial__c;
                    coberturaTO.premio.total            = garantiagrupo.PremioTotal__c;                    
                    coberturaTO.taxa.pura               = garantiagrupo.TaxaPura__c;
                    coberturaTO.taxa.comercial          = garantiagrupo.TaxaComercial__c;
                    coberturaTO.taxa.total              = garantiagrupo.TaxaTotal__c;

                    grupoTO.coberturas.add(coberturaTO);
                }

                // for(SeguradoProposta__c segurado : SeguradoPropostaDAO.getInstance().buscarGruposPropostaPorIds(new Set<Id>{grupo.Id}))
                // {
                //    ContratoTO.SeguradosTO seguradoTO = new ContratoTO.SeguradosTO();
                //    seguradoTO.coberturas         = new List<ContratoTO.CoberturasTO>();
                //    seguradoTO.premio             = new ContratoTO.PremioTO();
                //    seguradoTO.taxa               = new ContratoTO.TaxaTO();

                //    seguradoTO.premio.puro      = segurado.PremioPuro__c;
                //    seguradoTO.premio.comercial = segurado.PremioComercial__c;
                //    seguradoTO.premio.total     = segurado.PremioTotal__c;
                //    seguradoTO.taxa.pura        = segurado.TaxaPura__c;
                //    seguradoTO.taxa.comercial   = segurado.TaxaComercial__c;
                //    seguradoTO.taxa.total       = segurado.TaxaTotal__c;
                    //seguradoTO.iof              = segurado.IOF__c;


                    // for(GarantiasGrupoProposta__c garantiagrupo : lstgarantiagrupo)
                    // {
                    //     if(garantiagrupo.SeguradoProposta__c == segurado.Id)
                    //     {
                    //         ContratoTO.CoberturasTO coberturaTO = new ContratoTO.CoberturasTO();
                    //         coberturaTO.premio                  = new ContratoTO.PremioTO();
                    //         coberturaTO.taxa                    = new ContratoTO.TaxaTO();

                    //         coberturaTO.sigla            = garantiagrupo.GarantiaReferenciada__r.Sigla__c;
                    //         coberturaTO.capital          = garantiagrupo.Capital__c;
                    //         //coberturaTO.iof                     = garantiagrupo.IOF__c;
                    //         coberturaTO.premio.puro      = garantiagrupo.PremioPuro__c;
                    //         coberturaTO.premio.comercial = garantiagrupo.PremioComercial__c;
                    //         coberturaTO.premio.total     = garantiagrupo.PremioTotal__c;
                    //         coberturaTO.taxa.pura        = garantiagrupo.TaxaPura__c;
                    //         coberturaTO.taxa.comercial   = garantiagrupo.TaxaComercial__c;
                    //         coberturaTO.taxa.total       = garantiagrupo.TaxaTotal__c;
                    //         //coberturaTO.taxa.total      = garantiagrupo.
                    //         seguradoTO.coberturas.add(coberturaTO);
                    //     }
                    // }
                    // grupoTO.segurados.add(seguradoTO);
                //}
                ContratanteTO.grupos.add(grupoTO);
            }

            precificacao.Contratantes.add(ContratanteTO);

            for(GarantiaProposta__c garantiaProp : lstGarantiasProposta) // PLV-5249 - FIM
            {
                ContratoTO.CoberturasTO coberturaTO = new ContratoTO.CoberturasTO();
                coberturaTO.premio                  = new ContratoTO.PremioTO();
                coberturaTO.taxa                    = new ContratoTO.TaxaTO();

                coberturaTO.sigla                   = garantiaProp.Garantia__r.Sigla__c;
                coberturaTO.capital                 = garantiaProp.Capital__c;
                //coberturaTO.iof                     = garantiaProp.IOF__c;

                coberturaTO.premio.puro             = garantiaProp.PremioPuro__c;
                coberturaTO.premio.comercial        = garantiaProp.PremioComercial__c;
                coberturaTO.premio.integral         = garantiaProp.PremioIntegral__c; //PLV-5351 INICIO/FIM
                coberturaTO.taxa.pura               = garantiaProp.TaxaPura__c;
                coberturaTO.taxa.comercial          = garantiaProp.TaxaComercial__c;

                //garantia do nó de precificação igual garantia do segurado
                ContratanteTO.coberturas.add(coberturaTO);
                precificacao.coberturas.add(coberturaTO);
            }
        }

        return precificacao;
    }
        
        public class ContractException extends Exception {}

        //PLV-4660 FIX 4 - INÍCIO
        @TestVisible public Decimal calculaPremioLiquido(Decimal premioTotal, Decimal valorIof){ //POR062-99 INICIO - FIM
            
            if(premioTotal != null && valorIof != null){
                try{
                    // PLV-4601-FIX3 INICIO
                    if(premioTotal == 0){
                        return 0;
                    }
                    // PLV-4601-FIX3 FIM
                    
                    Decimal result  = (premioTotal - valorIof);
                    return result.setscale(2);
                }
                catch(exception e){
                    return 0;
                }
            }else{
                return 0;
            }
        }
        
        //PLV-4660 FIX 4 - FIM
}