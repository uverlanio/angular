/****
@description Classe contendo logica de preenchimento dos objetos de Orcamento, Proposta, Contrato e seus relacionados
@author Diego Zampieri - Globant
@date 22/07/2020
-Classe criada por conta da historia PLV-3926    
*****/
public with sharing class EndossoOrcamentoService {
    private Double valorTotalpago = 0; //PLV-4738 - INICIO/FIM
    private EndossoOrcamentoREST.Request req;

    private static OrcamentoBuilder orcamentoBuilder;
    private static OrcamentoGenericoBuilder orcamentoGenericoBuilder;
    
    // private static HerokuService herokuService;


    public EndossoOrcamentoService(EndossoOrcamentoREST.Request req){
        this.req = req;
        this.valorTotalpago = req.orcamento.premioPago; //PLV-4738 - INICIO/FIM
    }

    public List<EndossoOrcamentoResponse.OfertaTO> gravaOrcamentoEndosso(){
        List<EndossoOrcamentoResponse.OfertaTO> retorno = new List<EndossoOrcamentoResponse.OfertaTO>();
        EndossoOrcamentoResponse.OrcamentoTO oferta = new EndossoOrcamentoResponse.OrcamentoTO();
        EmissaoTO.PayloadTO payload = new EmissaoTO.PayloadTO();
        payload.orcamento = req.orcamento;
        
        System.debug('CARLOS - payload ' + payload);
        
        orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(false);

        // ConsultaParcelaTO consultaParcela = new ConsultaParcelaTO();
        // consultaParcela.sucursal = payload.orcamento.sucursal;
        // consultaParcela.ramo     = payload.orcamento.ramo;
        // consultaParcela.empresa  = payload.orcamento.empresa;
        // consultaParcela.apolice  = payload.orcamento.apolice;

        // String retornoConsultaParcelasPagas = HerokuService.getInstance().consultaParcelaPaga(JSON.serialize(consultaParcela)); // premioPago
        // System.debug('Carlos = retornoConsultaParcelasPagas' + retornoConsultaParcelasPagas);
        // RetornoParcelasTO parcelasPagas = (RetornoParcelasTO) JSON.deserialize(retornoConsultaParcelasPagas, RetornoParcelasTO.class);

        Orcamento orcamento = orcamentoGenericoBuilder.montarOrcamento(payload, null, true);
        
        
        String numeroOrcamento = orcamento.orcamentoWrapper.sfOrcamento.Numero__c;
        String idContrato = orcamento.orcamentoWrapper.sfOrcamento.ContractId;

        List<ContratanteOrcamento__c> lstContraOrc = [SELECT Id, Tipo__c, PremioComercial__c,  PremioPuro__c, PremioIntegral__c, //PLV-5351 INICIO/FIM
        PremioTotal__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c FROM ContratanteOrcamento__c WHERE Orcamento__r.Numero__c = :numeroOrcamento];

        List<GrupoOrcamento__c> lstGrupoOrc = [SELECT Id, ContratanteOrcamento__c, Name, TipoCalculo__c, QuantidadeVidas__c FROM GrupoOrcamento__c WHERE ContratanteOrcamento__r.Orcamento__r.Numero__c = :numeroOrcamento];

        List<GarantiaGrupoOrcamento__c> lstGaranGrupoOrc = [SELECT Id, Garantia__r.Sigla__c, GrupoOrcamento__c, PremioComercial__c, PremioIntegral__c, //PLV-5351 INICIO/FIM
        PremioPuro__c, PremioTotal__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c FROM GarantiaGrupoOrcamento__c WHERE GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.Numero__c = :numeroOrcamento];

        List<GarantiaContratanteOrcamento__c> lstGaranContraOrc = [SELECT Id,Garantia__r.Sigla__c,  ContratanteOrcamento__c, PremioComercial__c, PremioIntegral__c, //PLV-5351 INICIO/FIM
        PremioPuro__c, PremioTotal__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c FROM GarantiaContratanteOrcamento__c WHERE ContratanteOrcamento__r.Orcamento__r.Numero__c = :numeroOrcamento];
        //PLV-4738 - INICIO
        List<SeguradoOrcamento__c> lstSeguradoOrc = [SELECT 
                                                            Id, 
                                                            GrupoOrcamento__c, 
                                                            PremioComercial__c, 
                                                            PremioIntegral__c, //PLV-5351 INICIO/FIM
                                                            PremioPuro__c, 
                                                            PremioTotal__c,
                                                            TaxaComercial__c, 
                                                            TaxaPura__c, 
                                                            TaxaTotal__c,
                                                            Conta__r.Name, 
                                                            Conta__r.Cpf__c,
                                                            Conta__r.Profissao__c,
                                                            Conta__r.Profissao__r.Codigo__c,
                                                            Conta__r.Sexo__c,
                                                            Conta__r.Fumante__c,
                                                            Conta__r.PersonBirthdate,
                                                            Conta__r.RegimeTrabalho__c
                                                    FROM SeguradoOrcamento__c
                                                    WHERE 
                                                    GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.Numero__c = :numeroOrcamento];
        
        List<GarantiaSeguradoOrcamento__c> lstGaranSeguradoOrc = [SELECT 
                                                                        Id, 
                                                                        CurrencyIsoCode, 
                                                                        ValorCotacao__c, 
                                                                        Garantia__r.Sigla__c, 
                                                                        Valor__c, 
                                                                        Quantidade__c, 
                                                                        SeguradoOrcamento__c, 
                                                                        Capital__c
                                                                    FROM GarantiaSeguradoOrcamento__c 
                                                                    WHERE 
                                                                    SeguradoOrcamento__r.GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.Numero__c = :numeroOrcamento];
        //PLV-4738 - FIM
                                    //*************************************************** */  
        //PLV-4738 - INICIO
        List<GarantiaSeguradoContrato__c> lstGaranSeguradoCon = [SELECT 
                                                                        Id, 
                                                                        SeguradoContrato__c, 
                                                                        PremioComercial__c, 
                                                                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                                                                        PremioPuro__c, 
                                                                        PremioTotal__c,
                                                                        TaxaComercial__c, 
                                                                        TaxaPura__c, 
                                                                        TaxaTotal__c, 
                                                                        Garantia__r.Sigla__c,
                                                                        DescontoAgravoMonetarioFormaPagto__c,
                                                                        DescontoAgravoPercentualFormaPagto__c,
                                                                        TipoDescontoAgravo__c  
                                                                    FROM GarantiaSeguradoContrato__c 
                                                                    WHERE SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c = :idContrato];
        //PLV-4738 - FIM
        //PLV-4738 - INICIO
        List<SeguradoContrato__c> lstSeguradoCon = [SELECT 
                                                            Id, 
                                                            GrupoContrato__c, 
                                                            PremioComercial__c, 
                                                            PremioIntegral__c, //PLV-5351 INICIO/FIM
                                                            PremioPuro__c, 
                                                            PremioTotal__c,
                                                            TaxaComercial__c, 
                                                            TaxaPura__c, 
                                                            TaxaTotal__c,
                                                            DescontoAgravoMonetarioFormaPagto__c,
                                                            DescontoAgravoPercentualFormaPagto__c,
                                                            TipoDescontoAgravo__c 
                                                    FROM SeguradoContrato__c 
                                                    WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c = :idContrato];
        //PLV-4738 - FIM
        List<GarantiaGrupoContrato__c> lstGaranGrupoCon = [SELECT Id, Garantia__r.Sigla__c, GrupoContrato__c, PremioComercial__c, PremioIntegral__c, //PLV-5351 INICIO/FIM 
        PremioPuro__c, PremioTotal__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c FROM GarantiaGrupoContrato__c WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c = :idContrato];

        List<GrupoContrato__c> lstGrupoCon = [SELECT Id, ContratanteContrato__c, PremioComercial__c, PremioIntegral__c, //PLV-5351 INICIO/FIM
        PremioPuro__c, PremioTotal__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c FROM GrupoContrato__c WHERE ContratanteContrato__r.Contrato__c = :idContrato];

        List<GarantiaContratanteContrato__c> lstGaranContraCon = [SELECT Id,Garantia__r.Sigla__c,  ContratanteContrato__c, PremioComercial__c, PremioIntegral__c, //PLV-5351 INICIO/FIM
        PremioPuro__c, PremioTotal__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c FROM GarantiaContratanteContrato__c WHERE ContratanteContrato__r.Contrato__c = :idContrato];
        //PLV-4738 - INICIO
        List<ContratanteContrato__c> lstContraCon = [SELECT 
                                                            Id,
                                                            PremioComercial__c, 
                                                            PremioPuro__c, 
                                                            PremioIntegral__c, //PLV-5351 INICIO/FIM
                                                            PremioTotal__c,
                                                            TaxaComercial__c, 
                                                            TaxaPura__c, 
                                                            TaxaTotal__c,
                                                            DescontoAgravoMonetarioFormaPagto__c, 
                                                            DescontoAgravoPercentualFormaPagto__c, 
                                                            TipoDescontoAgravo__c 
                                                    FROM ContratanteContrato__c 
                                                    WHERE Contrato__c = :idContrato];
       
        List<GarantiaContrato__c> lstGaranCon = [SELECT Id, Garantia__r.Sigla__c, PremioComercial__c, PremioPuro__c, PremioTotal__c,
                                                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                                                        TaxaComercial__c, TaxaPura__c, TaxaTotal__c, DescontoAgravoMonetarioFormaPagto__c, 
                                                        DescontoAgravoPercentualFormaPagto__c, 
                                                        TipoDescontoAgravo__c  
                                                FROM GarantiaContrato__c WHERE Contrato__c = :idContrato];
         //PLV-4738 - FIM
        system.debug('Danilo lstGaranCon' + lstGaranCon);
        //PLV-4695 - INICIO
        //PLV-4738 - INICIO
        Contract contrato = [SELECT 
                                    Id, 
                                    VigenciaFinal__c, 
                                    ValorIOF__c, 
                                    StartDate, 
                                    Produto__r.ProductCode ,
                                    PremioComercial__c, 
                                    PremioIntegral__c, //PLV-5351 INICIO/FIM
                                    PremioPuro__c, 
                                    PremioTotal__c,
                                    TaxaComercial__c, 
                                    TaxaPura__c, 
                                    TaxaTotal__c, 
                                    MeioComercializacao__c, 
                                    CanalDistribuicao__r.Sigla__c, 
                                    Proposta__r.TipoVigencia__c, 
                                    segmento__c,
                                    CodigoRamo__c, 
                                    Endosso__c, 
                                    Sucursal__c,
                                    Empresa__c, 
                                    NumeroApolice__c,
                                    DescontoAgravoPercentualFormaPagto__c, 
                                    DescontoAgravoMonetarioFormaPagto__c,
                                    TipoDescontoAgravo__c,
                                    Oportunidade__r.Numero__c,
                                    Tarifa__c //PLV-5300 - INICIO/FIM
                            FROM Contract 
                            WHERE Id = :idContrato]; 
            
        
        Opportunity opp = [SELECT 
                                    Id, 
                                    Name, 
                                    Type, 
                                    NumeroOferta__c, 
                                    DataCalculo__c, 
                                    Numero__c, 
                                    TipoEndosso__C, 
                                    NumeroPortal__c, 
                                    EntradaNegocio__c,
                                    VigenciaInicial__c,
                                    VigenciaFinal__c,
                                    Produto__r.ProductCode
                            FROM Opportunity 
                            WHERE 
                                Numero__c =: numeroOrcamento LIMIT 1];
        //PLV-4738 - FIM
        //PLV-4695 - FIM
        Map<String, List<GarantiaContratanteContrato__c>> mapGarantiaContratanteContrato = new Map<String, List<GarantiaContratanteContrato__c>>();
        Map<String, List<GrupoContrato__c>> mapGrupoContrato = new Map<String, List<GrupoContrato__c>>();
        Map<String, List<GarantiaGrupoContrato__c>> mapGarantiaGrupoContrato = new Map<String, List<GarantiaGrupoContrato__c>>();
        Map<String, List<SeguradoContrato__c>> mapSeguradoContrato = new Map<String, List<SeguradoContrato__c>>();
        Map<String, List<GarantiaSeguradoContrato__c>> mapGarantiaSeguradoContrato = new Map<String, List<GarantiaSeguradoContrato__c>>();

        Map<String, List<GarantiaContratanteOrcamento__c>> mapGarantiaContratanteOrcamento = new Map<String, List<GarantiaContratanteOrcamento__c>>();
        Map<String, List<GrupoOrcamento__c>> mapGrupoOrcamento = new Map<String, List<GrupoOrcamento__c>>();
        Map<String, List<GarantiaGrupoOrcamento__c>> mapGarantiaGrupoOrcamento = new Map<String, List<GarantiaGrupoOrcamento__c>>();
        Map<String, List<SeguradoOrcamento__c>> mapSeguradoOrcamento = new Map<String, List<SeguradoOrcamento__c>>();
        Map<String, List<GarantiaSeguradoOrcamento__c>> mapGarantiaSeguradoOrcamento = new Map<String, List<GarantiaSeguradoOrcamento__c>>();

        for(GarantiaContratanteContrato__c garantia : lstGaranContraCon){
            if(mapGarantiaContratanteContrato.get(garantia.ContratanteContrato__c) == null)
                mapGarantiaContratanteContrato.put(garantia.ContratanteContrato__c, new List<GarantiaContratanteContrato__c>());
            List<GarantiaContratanteContrato__c> listGarantia = mapGarantiaContratanteContrato.get(garantia.ContratanteContrato__c);
            listGarantia.add(garantia);
            mapGarantiaContratanteContrato.put(garantia.ContratanteContrato__c, listGarantia);
        }
        for(GrupoContrato__c grupo : lstGrupoCon){
            if(mapGrupoContrato.get(grupo.ContratanteContrato__c) == null)
                mapGrupoContrato.put(grupo.ContratanteContrato__c, new List<GrupoContrato__c>());
            List<GrupoContrato__c> listGarantia = mapGrupoContrato.get(grupo.ContratanteContrato__c);
            listGarantia.add(grupo);
            mapGrupoContrato.put(grupo.ContratanteContrato__c, listGarantia);
        }
        for(GarantiaGrupoContrato__c grupo : lstGaranGrupoCon){
            if(mapGarantiaGrupoContrato.get(grupo.GrupoContrato__c) == null)
                mapGarantiaGrupoContrato.put(grupo.GrupoContrato__c, new List<GarantiaGrupoContrato__c>());
            List<GarantiaGrupoContrato__c> listGarantia = mapGarantiaGrupoContrato.get(grupo.GrupoContrato__c);
            listGarantia.add(grupo);
            mapGarantiaGrupoContrato.put(grupo.GrupoContrato__c, listGarantia);
        }
        for(SeguradoContrato__c segurado : lstSeguradoCon){
            if(mapSeguradoContrato.get(segurado.GrupoContrato__c) == null)
                mapSeguradoContrato.put(segurado.GrupoContrato__c, new List<SeguradoContrato__c>());
            List<SeguradoContrato__c> listGarantia = mapSeguradoContrato.get(segurado.GrupoContrato__c);
            listGarantia.add(segurado);
            mapSeguradoContrato.put(segurado.GrupoContrato__c, listGarantia);
        }
        for(GarantiaSeguradoContrato__c garantiaSegurado : lstGaranSeguradoCon){
            if(mapGarantiaSeguradoContrato.get(garantiaSegurado.SeguradoContrato__c) == null)
                mapGarantiaSeguradoContrato.put(garantiaSegurado.SeguradoContrato__c, new List<GarantiaSeguradoContrato__c>());
            List<GarantiaSeguradoContrato__c> listGarantia = mapGarantiaSeguradoContrato.get(garantiaSegurado.SeguradoContrato__c);
            listGarantia.add(garantiaSegurado);
            mapGarantiaSeguradoContrato.put(garantiaSegurado.SeguradoContrato__c, listGarantia);
        }
        
        for(GarantiaContratanteOrcamento__c garantia : lstGaranContraOrc){
            if(mapGarantiaContratanteOrcamento.get(garantia.ContratanteOrcamento__c) == null)
                mapGarantiaContratanteOrcamento.put(garantia.ContratanteOrcamento__c, new List<GarantiaContratanteOrcamento__c>());
            List<GarantiaContratanteOrcamento__c> listGarantia = mapGarantiaContratanteOrcamento.get(garantia.ContratanteOrcamento__c);
            listGarantia.add(garantia);
            mapGarantiaContratanteOrcamento.put(garantia.ContratanteOrcamento__c, listGarantia);
        }
        for(GrupoOrcamento__c grupo : lstGrupoOrc){
            if(mapGrupoOrcamento.get(grupo.ContratanteOrcamento__c) == null)
                mapGrupoOrcamento.put(grupo.ContratanteOrcamento__c, new List<GrupoOrcamento__c>());
            List<GrupoOrcamento__c> listGarantia = mapGrupoOrcamento.get(grupo.ContratanteOrcamento__c);
            listGarantia.add(grupo);
            mapGrupoOrcamento.put(grupo.ContratanteOrcamento__c, listGarantia);
        }
        for(GarantiaGrupoOrcamento__c grupo : lstGaranGrupoOrc){
            if(mapGarantiaGrupoOrcamento.get(grupo.GrupoOrcamento__c) == null)
                mapGarantiaGrupoOrcamento.put(grupo.GrupoOrcamento__c, new List<GarantiaGrupoOrcamento__c>());
            List<GarantiaGrupoOrcamento__c> listGarantia = mapGarantiaGrupoOrcamento.get(grupo.GrupoOrcamento__c);
            listGarantia.add(grupo);
            mapGarantiaGrupoOrcamento.put(grupo.GrupoOrcamento__c, listGarantia);
        }
        for(SeguradoOrcamento__c segurado : lstSeguradoOrc){
            if(mapSeguradoOrcamento.get(segurado.GrupoOrcamento__c) == null)
                mapSeguradoOrcamento.put(segurado.GrupoOrcamento__c, new List<SeguradoOrcamento__c>());
            List<SeguradoOrcamento__c> listGarantia = mapSeguradoOrcamento.get(segurado.GrupoOrcamento__c);
            listGarantia.add(segurado);
            mapSeguradoOrcamento.put(segurado.GrupoOrcamento__c, listGarantia);
        }
        for(GarantiaSeguradoOrcamento__c garantiaSegurado : lstGaranSeguradoOrc){
            if(mapGarantiaSeguradoOrcamento.get(garantiaSegurado.SeguradoOrcamento__c) == null)
                mapGarantiaSeguradoOrcamento.put(garantiaSegurado.SeguradoOrcamento__c, new List<GarantiaSeguradoOrcamento__c>());
            List<GarantiaSeguradoOrcamento__c> listGarantia = mapGarantiaSeguradoOrcamento.get(garantiaSegurado.SeguradoOrcamento__c);
            listGarantia.add(garantiaSegurado);
            mapGarantiaSeguradoOrcamento.put(garantiaSegurado.SeguradoOrcamento__c, listGarantia);
        }
        
        // Oferta
        oferta.orcnum = opp.Name;
        oferta.numeroOrcamento = opp.Numero__c;
        // PLV-3298 - INICIO FIX
        oferta.tipoSeguro = opp.Type == 'CAN' ? 'Cancelamento' : opp.Type;
        // PLV-3298 - FIM FIX
        oferta.numeroOferta = opp.NumeroOferta__c;
        oferta.dataCalculo = String.valueOf(opp.DataCalculo__c); // Validar
        oferta.motivoCancelamento = opp.TipoEndosso__c;
        
        // Contratante do Orcamento
        Integer contadorContratanteOrcamento = 1;
        Integer contadorGrupoOrcamento = 1;
        Integer contadorSeguradoOrcamento = 1;
        oferta.contratantes = new List<EndossoOrcamentoResponse.ContratanteTO>();

        for(ContratanteOrcamento__c contratante : lstContraOrc){
            EndossoOrcamentoResponse.ContratanteTO contratanteOrcamento = new EndossoOrcamentoResponse.ContratanteTO();
            contratanteOrcamento.tipo = contratante.Tipo__c;
            contratanteOrcamento.numero = contadorContratanteOrcamento;
            contadorContratanteOrcamento++;
            
            if(mapGrupoOrcamento.get(contratante.Id) != null){
                if(contratanteOrcamento.grupos == null){
                    contratanteOrcamento.grupos = new List<EndossoOrcamentoResponse.GrupoTO>();
                }

                // GrupoOrcamento__c grupo = mapGrupoOrcamento.get(contratante.Id);
                for(GrupoOrcamento__c grupo : mapGrupoOrcamento.get(contratante.Id)){
                    EndossoOrcamentoResponse.GrupoTO grupoOrcamento = new EndossoOrcamentoResponse.GrupoTO();
                    grupoOrcamento.numero = contadorGrupoOrcamento;
                    contadorGrupoOrcamento++;
                    grupoOrcamento.nome = grupo.Name;
                    grupoOrcamento.tipoCalculo = (grupo.TipoCalculo__c != null) ? grupo.TipoCalculo__c : '' ; //PLV-4738 - INICIO/FIM
                    grupoOrcamento.qtdeVidas = Integer.valueOf(grupo.QuantidadeVidas__c);

                    // Segurados
                    if(mapSeguradoOrcamento.get(grupo.Id) != null){
                        if(grupoOrcamento.segurados == null){
                            grupoOrcamento.segurados = new List<EndossoOrcamentoResponse.SeguradoTO>();
                        }
                        // SeguradoOrcamento__c seguradoOrcamento = mapSeguradoOrcamento.get(grupo.Id);
                        for(SeguradoOrcamento__c seguradoOrcamento : mapSeguradoOrcamento.get(grupo.Id)){
                            EndossoOrcamentoResponse.SeguradoTO seguradoDoOrcamento = new EndossoOrcamentoResponse.SeguradoTO();
                            seguradoDoOrcamento.numero = contadorSeguradoOrcamento;

                            //PLV-4738 - INICIO
                             //nó pessoa
                             EndossoOrcamentoResponse.PessoaTO pes = new EndossoOrcamentoResponse.PessoaTO();
                             pes.tipo = (seguradoOrcamento.Conta__r.Cpf__c != null || seguradoOrcamento.Conta__r.Cpf__c != '') ? 'FIS' : 'JUR';
                             pes.nome = seguradoOrcamento.Conta__r.Name; 
                             pes.redaMensal = '';
                             seguradoDoOrcamento.pessoa = pes;
                             //no dadospessoa fisica
                             EndossoOrcamentoResponse.DadosPessoaTO dadosPes = new EndossoOrcamentoResponse.DadosPessoaTO();
                             dadosPes.dataNascimento = seguradoOrcamento.Conta__r.PersonBirthdate;
                             String fumante = seguradoOrcamento.Conta__r.Fumante__c;
                             //PLV-4695 Inicio
							 if(fumante != null){
								fumante = fumante.trim();
								dadosPes.fumante = (fumante.toUpperCase() == 'SIM') ? true : false;
							 }else{
								dadosPes.fumante = false;
							 }
							 //PLV-4695 Fim					                             							 
                             dadosPes.grupoProfissao = '';
                             dadosPes.profissao = seguradoOrcamento.Conta__r.Profissao__r.Codigo__c;
                             dadosPes.sexo = seguradoOrcamento.Conta__r.Sexo__c;
                             dadosPes.regimeTrabalho = seguradoOrcamento.Conta__r.RegimeTrabalho__c;
                             
                             seguradoDoOrcamento.pessoa.dadosPessoaFisica = dadosPes;

                            //PLV-4738 - FIM

                            contadorSeguradoOrcamento++;
                            
                            if(mapGarantiaSeguradoOrcamento.get(seguradoOrcamento.Id) != null){
                                if(seguradoDoOrcamento.coberturas == null){
                                    seguradoDoOrcamento.coberturas = new List<EndossoOrcamentoResponse.CoberturaTO>();
                                }
                                // GarantiaSeguradoOrcamento__c garantiaSeguradoOrcamento = mapGarantiaSeguradoOrcamento.get(seguradoOrcamento.Id);
                                for(GarantiaSeguradoOrcamento__c garantiaSeguradoOrcamento : mapGarantiaSeguradoOrcamento.get(seguradoOrcamento.Id)){
                                    EndossoOrcamentoResponse.CoberturaTO gtSeguradoOrcamento = new EndossoOrcamentoResponse.CoberturaTO();
                                    gtSeguradoOrcamento.sigla = garantiaSeguradoOrcamento.Garantia__r.Sigla__c;
                                    gtSeguradoOrcamento.valor = garantiaSeguradoOrcamento.Capital__c;
                                    gtSeguradoOrcamento.moeda = garantiaSeguradoOrcamento.CurrencyIsoCode;
                                    gtSeguradoOrcamento.cotacaoMoeda = garantiaSeguradoOrcamento.ValorCotacao__c;
                                    gtSeguradoOrcamento.cobrado = '';

                                    //gtSeguradoOrcamento.quantidade = Integer.valueOf(garantiaSeguradoOrcamento.Quantidade__c); //PLV-4738 - INICIO/FIM
                                    seguradoDoOrcamento.coberturas.add(gtSeguradoOrcamento);
                                }
                            }
                            grupoOrcamento.segurados.add(seguradoDoOrcamento);
                        }
                        contratanteOrcamento.grupos.add(grupoOrcamento);
                    }
                }
                oferta.contratantes = new List<EndossoOrcamentoResponse.ContratanteTO>();
                oferta.contratantes.add(contratanteOrcamento);
            }
        }
        
        // Contrato
        //PLV-4738 - INICIO
        oferta.contratoOriginal = new EndossoOrcamentoResponse.ContratoTO();
        //oferta.contratoOriginal.premioTotal = Integer.valueOf(contrato.PremioTotal__c);
        //oferta.contratoOriginal.premioPago = Double.valueOf(payload.orcamento.premioPago);
        oferta.contratoOriginal.vigenciaInicial = String.valueOf(contrato.StartDate);
        oferta.contratoOriginal.vigenciaFinal = String.valueOf(contrato.VigenciaFinal__c);
        oferta.contratoOriginal.codigoProdutoVida = contrato.Produto__r.ProductCode; 
        oferta.contratoOriginal.numeroOrcamento =  contrato.Oportunidade__r.Numero__c;
        oferta.contratoOriginal.endosso = Integer.valueOf(contrato.Endosso__c);
        oferta.contratoOriginal.ramo = Integer.valueOf(contrato.CodigoRamo__c);
        oferta.contratoOriginal.apolice = contrato.NumeroApolice__c;
        oferta.contratoOriginal.sucursal = Integer.valueOf(contrato.Sucursal__c);
        oferta.contratoOriginal.empresa = Integer.valueOf(contrato.Empresa__c);  
        EndossoOrcamentoResponse.VersoesCalculoTO versoesObjOriginal = new EndossoOrcamentoResponse.VersoesCalculoTO();
        List<EndossoOrcamentoResponse.VersoesCalculoTO> lVersoesoriginal = new List<EndossoOrcamentoResponse.VersoesCalculoTO>();
        versoesObjOriginal.tipo = 'FPG';
        versoesObjOriginal.opcao = 1;
        versoesObjOriginal.descontoAgravo = 0.0;
        lVersoesoriginal.add(versoesObjOriginal);
        oferta.contratoOriginal.versoesCalculos = lVersoesoriginal;

        EndossoOrcamentoResponse.ResultadoIntegracaoTO noresultaIntegracaoOriginal = new EndossoOrcamentoResponse.ResultadoIntegracaoTO(); 
        noresultaIntegracaoOriginal.IndiceMonetario = new EndossoOrcamentoResponse.IndiceMonetarioTO();
        EndossoOrcamentoResponse.ItensCotacaoTO objItensCotacaoOriginal = new EndossoOrcamentoResponse.ItensCotacaoTO();
        List<EndossoOrcamentoResponse.ItensCotacaoTO> lItensCotacaoOriginal = new List<EndossoOrcamentoResponse.ItensCotacaoTO>();
        objItensCotacaoOriginal.cotacao = '';
        objItensCotacaoOriginal.dataCotacao = 0;
        objItensCotacaoOriginal.moedaDestino = '';
        objItensCotacaoOriginal.moedaOrigem = '';
        lItensCotacaoOriginal.add(objItensCotacaoOriginal);
        noresultaIntegracaoOriginal.IndiceMonetario.ItensCotacao = lItensCotacaoOriginal;
        
        oferta.contratoOriginal.resultadoIntegracoes = noresultaIntegracaoOriginal;

        //PLV-4738 - FIM
        
        // Garantia do Contrato
        //PLV-4738 - INICIO
        oferta.contratoOriginal.precificacao = new EndossoOrcamentoResponse.PrecificacaoTO();
        oferta.contratoOriginal.precificacao.iof = contrato.ValorIOF__c;
        oferta.contratoOriginal.precificacao.premio = new EndossoOrcamentoResponse.PremioTO();
        //oferta.contratoOriginal.precificacao.taxa = new EndossoOrcamentoResponse.TaxaTO();
        oferta.contratoOriginal.precificacao.premio.comercial = contrato.PremioComercial__c;
        oferta.contratoOriginal.precificacao.premio.total = contrato.PremioTotal__c;
        oferta.contratoOriginal.precificacao.premio.puro = contrato.PremioPuro__c;
        oferta.contratoOriginal.precificacao.premio.premioPago = this.valorTotalpago;
        //oferta.contratoOriginal.precificacao.Taxa.comercial = contrato.TaxaComercial__c;
        //oferta.contratoOriginal.precificacao.Taxa.total = contrato.TaxaTotal__c;
        //oferta.contratoOriginal.precificacao.Taxa.pura = contrato.TaxaPura__c;
        oferta.contratoOriginal.precificacao.custoDeApolice = 0;
        oferta.contratoOriginal.precificacao.iof = contrato.ValorIOF__c;
        oferta.contratoOriginal.precificacao.juros = 0;
        oferta.contratoOriginal.precificacao.encargos = 0;

       
        List<EndossoOrcamentoResponse.DescontoAgravoTO> lDescontoAgravo = new List<EndossoOrcamentoResponse.DescontoAgravoTO>();
        EndossoOrcamentoResponse.DescontoAgravoTO objDescontoAgravo = new EndossoOrcamentoResponse.DescontoAgravoTO();
        objDescontoAgravo.monetario = contrato.DescontoAgravoMonetarioFormaPagto__c;
        objDescontoAgravo.percentual = contrato.DescontoAgravoPercentualFormaPagto__c;
        objDescontoAgravo.tipo = (contrato.TipoDescontoAgravo__c != null) ? contrato.TipoDescontoAgravo__c :'FPG';
        lDescontoAgravo.add(objDescontoAgravo);
        oferta.contratoOriginal.precificacao.descontoAgravo = lDescontoAgravo;


        oferta.contratoOriginal.precificacao.coberturas = new List<EndossoOrcamentoResponse.CoberturasPrecificacaoTO>();
        for(GarantiaContrato__c garantia : lstGaranCon){     
            EndossoOrcamentoResponse.CoberturasPrecificacaoTO cobertura = new EndossoOrcamentoResponse.CoberturasPrecificacaoTO();
            cobertura.sigla = garantia.Garantia__r.Sigla__c;
            cobertura.premio = new EndossoOrcamentoResponse.PremioTO();
            cobertura.taxa = new EndossoOrcamentoResponse.TaxaTO();
            cobertura.premio.integral = garantia.PremioIntegral__c; //PLV-5351 INICIO/FIM
            cobertura.premio.comercial = garantia.PremioComercial__c;
            cobertura.premio.puro = garantia.PremioPuro__c;
            cobertura.premio.total = garantia.PremioTotal__c;
            cobertura.taxa.total = garantia.TaxaComercial__c;
            cobertura.taxa.pura = garantia.TaxaPura__c;
            cobertura.taxa.comercial = garantia.TaxaTotal__c;

            cobertura.iof = 0.0;
            cobertura.capitalContratacao = 0;

            List<EndossoOrcamentoResponse.DescontoAgravoTO> lDescontoAgravoCobertura = new List<EndossoOrcamentoResponse.DescontoAgravoTO>();
            EndossoOrcamentoResponse.DescontoAgravoTO objDescontoAgravoCobertura = new EndossoOrcamentoResponse.DescontoAgravoTO();
            objDescontoAgravoCobertura.monetario = garantia.DescontoAgravoMonetarioFormaPagto__c;
            objDescontoAgravoCobertura.percentual = garantia.DescontoAgravoPercentualFormaPagto__c;
            objDescontoAgravoCobertura.tipo = (garantia.TipoDescontoAgravo__c != null) ? garantia.TipoDescontoAgravo__c :'FPG';
            lDescontoAgravoCobertura.add(objDescontoAgravo);
            cobertura.descontoAgravo = lDescontoAgravoCobertura;

            oferta.contratoOriginal.precificacao.coberturas.add(cobertura);
        }
        //PLV-4738 - FIM

        // Contratante do Contrato, Garantia do Contratante do Contrato Grupo do Contratante do Contrato
        Integer contadorContratanteContrato = 1;
        Integer contadorGrupoContrato = 1;
        Integer contadorSeguradoContrato = 1;

        for(ContratanteContrato__c contratante : lstContraCon){
            EndossoOrcamentoResponse.ContratantesPrecificacaoTO contratanteContrato = new EndossoOrcamentoResponse.ContratantesPrecificacaoTO();
            contratanteContrato.premio = new EndossoOrcamentoResponse.PremioTO();
             //PLV-4738 - INICIO
            //contratanteContrato.taxa = new EndossoOrcamentoResponse.TaxaTO();
            contratanteContrato.iof = contrato.ValorIOF__c;
            contratanteContrato.numero = contadorContratanteContrato;
            contadorContratanteContrato++;
            contratanteContrato.premio.integral = contratante.PremioIntegral__c; //PLV-5351 INICIO/FIM
            contratanteContrato.premio.comercial = contratante.PremioComercial__c;
            contratanteContrato.premio.puro = contratante.PremioPuro__c;
            contratanteContrato.premio.total = contratante.PremioTotal__c;
            contratanteContrato.premio.premioPago =  this.valorTotalpago; //PLV-4893 - INÍCIO/FIM
            
            //contratanteContrato.taxa.total = contratante.TaxaComercial__c;
            //contratanteContrato.taxa.pura = contratante.TaxaPura__c;
            //contratanteContrato.taxa.comercial = contratante.TaxaTotal__c;

           
            EndossoOrcamentoResponse.DescontoAgravoTO objDescontoAgravoContratanteContrato = new EndossoOrcamentoResponse.DescontoAgravoTO();
            List<EndossoOrcamentoResponse.DescontoAgravoTO> lDescontoAgravoContratanteContrato = new List<EndossoOrcamentoResponse.DescontoAgravoTO>();
            objDescontoAgravoContratanteContrato.monetario = contratante.DescontoAgravoMonetarioFormaPagto__c;
            objDescontoAgravoContratanteContrato.percentual = contratante.DescontoAgravoPercentualFormaPagto__c;
            objDescontoAgravoContratanteContrato.tipo = (contratante.TipoDescontoAgravo__c != null) ? contratante.TipoDescontoAgravo__c : 'FPG';
            lDescontoAgravoContratanteContrato.add(objDescontoAgravoContratanteContrato);
            contratanteContrato.descontoAgravo = lDescontoAgravoContratanteContrato;
            
            /*if(mapGarantiaContratanteContrato.get(contratante.Id) != null){
                if(contratanteContrato.coberturas == null){
                    contratanteContrato.coberturas = new List<EndossoOrcamentoResponse.CoberturasPrecificacaoTO>();
                }
                // GarantiaContratanteContrato__c garantia = mapGarantiaContratanteContrato.get(contratante.Id);
                for(GarantiaContratanteContrato__c garantia : mapGarantiaContratanteContrato.get(contratante.Id)){
                    EndossoOrcamentoResponse.CoberturasPrecificacaoTO coberturaContrato = new EndossoOrcamentoResponse.CoberturasPrecificacaoTO();
                    coberturaContrato.premio = new EndossoOrcamentoResponse.PremioTO();
                    coberturaContrato.taxa = new EndossoOrcamentoResponse.TaxaTO();
                    coberturaContrato.sigla = garantia.Garantia__r.Sigla__c; // Validar
                    coberturaContrato.premio.comercial = garantia.PremioComercial__c;
                    coberturaContrato.premio.puro = garantia.PremioPuro__c;
                    coberturaContrato.premio.total = garantia.PremioTotal__c;
                    coberturaContrato.taxa.total = garantia.TaxaComercial__c;
                    coberturaContrato.taxa.pura = garantia.TaxaPura__c;
                    coberturaContrato.taxa.comercial = garantia.TaxaTotal__c;
                    contratanteContrato.coberturas.add(coberturaContrato);
                }
            }*/
             //PLV-4738 - FIM      
            if(mapGrupoContrato.get(contratante.Id) != null){
                if(contratanteContrato.grupos == null){
                    contratanteContrato.grupos = new List<EndossoOrcamentoResponse.GruposPrecificacaoTO>();
                }
                // GrupoContrato__c grupo = mapGrupoContrato.get(contratante.Id);
                //PLV-4738 - INICIO
                for(GrupoContrato__c grupo : mapGrupoContrato.get(contratante.Id)){
                    EndossoOrcamentoResponse.GruposPrecificacaoTO grupoContrato = new EndossoOrcamentoResponse.GruposPrecificacaoTO();
                    grupoContrato.premio = new EndossoOrcamentoResponse.PremioTO();
                    grupoContrato.iof = 0;
                    //grupoContrato.taxa = new EndossoOrcamentoResponse.TaxaTO();
                    grupoContrato.numero = contadorGrupoContrato;
                    contadorGrupoContrato++;
                    grupoContrato.premio.integral = grupo.PremioIntegral__c;
                    grupoContrato.premio.comercial = grupo.PremioComercial__c;
                    grupoContrato.premio.puro = grupo.PremioPuro__c;
                    grupoContrato.premio.total = grupo.PremioTotal__c;
                    grupoContrato.premio.premioPago = this.valorTotalpago; //PLV-4893 - INÍCIO/FIM
                    //grupoContrato.taxa.total = grupo.TaxaComercial__c;
                    //grupoContrato.taxa.pura = grupo.TaxaPura__c;
                    //grupoContrato.taxa.comercial = grupo.TaxaTotal__c;

                    EndossoOrcamentoResponse.DescontoAgravoTO objDescontoAgravoGrupo = new EndossoOrcamentoResponse.DescontoAgravoTO();
                    List<EndossoOrcamentoResponse.DescontoAgravoTO> lDescontoAgravoGrupo = new List<EndossoOrcamentoResponse.DescontoAgravoTO>();
                    objDescontoAgravoGrupo.monetario = contratante.DescontoAgravoMonetarioFormaPagto__c;
                    objDescontoAgravoGrupo.percentual = contratante.DescontoAgravoPercentualFormaPagto__c;
                    objDescontoAgravoGrupo.tipo = (contratante.TipoDescontoAgravo__c != null) ? contratante.TipoDescontoAgravo__c : 'FPG';
                    lDescontoAgravoGrupo.add(objDescontoAgravoGrupo);
                    grupoContrato.descontoAgravo = lDescontoAgravoGrupo;

                    // Coberturas
                    /*
                    if(mapGarantiaGrupoContrato.get(grupo.Id) != null){
                        if(grupoContrato.coberturas == null){
                            grupoContrato.coberturas = new List<EndossoOrcamentoResponse.CoberturasPrecificacaoTO>();
                        }
                        // GarantiaGrupoContrato__c garantiaGrupo = mapGarantiaGrupoContrato.get(grupo.Id);
                        for(GarantiaGrupoContrato__c garantiaGrupo : mapGarantiaGrupoContrato.get(grupo.Id)){
                            EndossoOrcamentoResponse.CoberturasPrecificacaoTO garantiaGrupoContrato = new EndossoOrcamentoResponse.CoberturasPrecificacaoTO();
                            garantiaGrupoContrato.premio = new EndossoOrcamentoResponse.PremioTO();
                            garantiaGrupoContrato.taxa = new EndossoOrcamentoResponse.TaxaTO();
                            garantiaGrupoContrato.sigla = garantiaGrupo.Garantia__r.Sigla__c; // Validar
                            garantiaGrupoContrato.premio.comercial = garantiaGrupo.PremioComercial__c;
                            garantiaGrupoContrato.premio.puro = garantiaGrupo.PremioPuro__c;
                            garantiaGrupoContrato.premio.total = garantiaGrupo.PremioTotal__c;
                            garantiaGrupoContrato.taxa.total = garantiaGrupo.TaxaComercial__c;
                            garantiaGrupoContrato.taxa.pura = garantiaGrupo.TaxaPura__c;
                            garantiaGrupoContrato.taxa.comercial = garantiaGrupo.TaxaTotal__c;
                            grupoContrato.coberturas.add(garantiaGrupoContrato);
                        }
                        
                    }*/
                    //PLV-4738 - FIM
                    // Segurados
                    if(mapSeguradoContrato.get(grupo.Id) != null){
                        if(grupoContrato.segurados == null){
                            grupoContrato.segurados = new List<EndossoOrcamentoResponse.SeguradosPrecificacaoTO>();
                        }
                        //PLV-4738 - INICIO
                        // SeguradoContrato__c seguradoContrato = mapSeguradoContrato.get(grupo.Id);
                        for(SeguradoContrato__c seguradoContrato : mapSeguradoContrato.get(grupo.Id)){
                            EndossoOrcamentoResponse.SeguradosPrecificacaoTO seguradoDoContrato = new EndossoOrcamentoResponse.SeguradosPrecificacaoTO();
                            seguradoDoContrato.numero = contadorSeguradoContrato;
                            contadorSeguradoContrato++;
                            seguradoDoContrato.premio = new EndossoOrcamentoResponse.PremioTO();
                            //seguradoDoContrato.taxa = new EndossoOrcamentoResponse.TaxaTO();
                            seguradoDoContrato.premio.integral = seguradoContrato.PremioIntegral__c; //PLV-5351 INICIO/FIM
                            seguradoDoContrato.premio.comercial = seguradoContrato.PremioComercial__c;
                            seguradoDoContrato.premio.puro = seguradoContrato.PremioPuro__c;
                            seguradoDoContrato.premio.total = seguradoContrato.PremioTotal__c;
                            seguradoDoContrato.premio.premioPago = this.valorTotalpago; //PLV-4893 - INÍCIO/FIM
                            //seguradoDoContrato.taxa.total = seguradoContrato.TaxaComercial__c;
                            //seguradoDoContrato.taxa.pura = seguradoContrato.TaxaPura__c;
                            //seguradoDoContrato.taxa.comercial = seguradoContrato.TaxaTotal__c;
                            seguradoDoContrato.iof = 0;
                            EndossoOrcamentoResponse.DescontoAgravoTO objDescontoAgravoGpsegurado = new EndossoOrcamentoResponse.DescontoAgravoTO();
                            List<EndossoOrcamentoResponse.DescontoAgravoTO> lDescontoAgravoGrupoSegurado = new List<EndossoOrcamentoResponse.DescontoAgravoTO>();
                            objDescontoAgravoGpsegurado.monetario = seguradoContrato.DescontoAgravoMonetarioFormaPagto__c;
                            objDescontoAgravoGpsegurado.percentual = seguradoContrato.DescontoAgravoPercentualFormaPagto__c;
                            objDescontoAgravoGpsegurado.tipo = (seguradoContrato.TipoDescontoAgravo__c != null) ? seguradoContrato.TipoDescontoAgravo__c : 'FPG';
                            lDescontoAgravoGrupoSegurado.add(objDescontoAgravoGpsegurado);
                            seguradoDoContrato.descontoAgravo = lDescontoAgravoGrupoSegurado;

                            if(mapGarantiaSeguradoContrato.get(seguradoContrato.Id) != null){
                                if(seguradoDoContrato.coberturas == null){
                                    seguradoDoContrato.coberturas = new List<EndossoOrcamentoResponse.CoberturasPrecificacaoTO>();
                                }
                                // GarantiaSeguradoContrato__c GarantiaSeguradoContrato = mapGarantiaSeguradoContrato.get(seguradoContrato.Id);
                                for(GarantiaSeguradoContrato__c GarantiaSeguradoContrato : mapGarantiaSeguradoContrato.get(seguradoContrato.Id)){
                                    if(GarantiaSeguradoContrato.PremioTotal__c != null){
                                        EndossoOrcamentoResponse.CoberturasPrecificacaoTO gtSeguradoContrato = new EndossoOrcamentoResponse.CoberturasPrecificacaoTO();
                                        gtSeguradoContrato.premio = new EndossoOrcamentoResponse.PremioTO();
                                        gtSeguradoContrato.taxa = new EndossoOrcamentoResponse.TaxaTO();
                                        gtSeguradoContrato.sigla = GarantiaSeguradoContrato.Garantia__r.Sigla__c;
                                        gtSeguradoContrato.premio.integral = GarantiaSeguradoContrato.PremioIntegral__c; //PLV-5351 INICIO/FIM
                                        gtSeguradoContrato.premio.comercial = GarantiaSeguradoContrato.PremioComercial__c;
                                        gtSeguradoContrato.premio.puro = GarantiaSeguradoContrato.PremioPuro__c;
                                        gtSeguradoContrato.premio.total = GarantiaSeguradoContrato.PremioTotal__c;
                                        gtSeguradoContrato.premio.premioPago = this.valorTotalpago; //PLV-4893 - INÍCIO/FIM
                                        gtSeguradoContrato.taxa.total = GarantiaSeguradoContrato.TaxaComercial__c;
                                        gtSeguradoContrato.taxa.pura = GarantiaSeguradoContrato.TaxaPura__c;
                                        gtSeguradoContrato.taxa.comercial = GarantiaSeguradoContrato.TaxaTotal__c;
                                        
                                        gtSeguradoContrato.iof = 0.0;
                                        gtSeguradoContrato.capitalContratacao = 0;

                                        EndossoOrcamentoResponse.DescontoAgravoTO objDescontoAgravoSeguradogarantia = new EndossoOrcamentoResponse.DescontoAgravoTO();
                                        List<EndossoOrcamentoResponse.DescontoAgravoTO> lDescontoAgravoGrupoSeguradoGarantia = new List<EndossoOrcamentoResponse.DescontoAgravoTO>();
                                        objDescontoAgravoSeguradogarantia.monetario = GarantiaSeguradoContrato.DescontoAgravoMonetarioFormaPagto__c;
                                        objDescontoAgravoSeguradogarantia.percentual = GarantiaSeguradoContrato.DescontoAgravoPercentualFormaPagto__c;
                                        objDescontoAgravoSeguradogarantia.tipo = (GarantiaSeguradoContrato.TipoDescontoAgravo__c != null) ? GarantiaSeguradoContrato.TipoDescontoAgravo__c : 'FPG';
                                        lDescontoAgravoGrupoSeguradoGarantia.add(objDescontoAgravoSeguradogarantia);
                                        gtSeguradoContrato.descontoAgravo = lDescontoAgravoGrupoSeguradoGarantia;

                                        seguradoDoContrato.coberturas.add(gtSeguradoContrato);
                                    }
                                }
                            }
                            grupoContrato.segurados.add(seguradoDoContrato);
                        }
                        //PLV-4738 - FIM
                    }
                    contratanteContrato.grupos.add(grupoContrato);
                }
            }
            oferta.contratoOriginal.precificacao.contratantes = new List<EndossoOrcamentoResponse.ContratantesPrecificacaoTO>();
            oferta.contratoOriginal.precificacao.contratantes.add(contratanteContrato);
        }
        //PLV-4738 - INICIO
        EndossoOrcamentoResponse.ResultadoIntegracaoTO noresultaIntegracao = new EndossoOrcamentoResponse.ResultadoIntegracaoTO(); 
        noresultaIntegracao.IndiceMonetario = new EndossoOrcamentoResponse.IndiceMonetarioTO();
        EndossoOrcamentoResponse.ItensCotacaoTO objItensCotacao = new EndossoOrcamentoResponse.ItensCotacaoTO();
        List<EndossoOrcamentoResponse.ItensCotacaoTO> lItensCotacao = new List<EndossoOrcamentoResponse.ItensCotacaoTO>();
        objItensCotacao.cotacao = '';
        objItensCotacao.dataCotacao = 0;
        objItensCotacao.moedaDestino = '';
        objItensCotacao.moedaOrigem = '';
        lItensCotacao.add(objItensCotacao);
        noresultaIntegracao.IndiceMonetario.ItensCotacao = lItensCotacao;
        
        oferta.resultadoIntegracoes = noresultaIntegracao;
        List<EndossoOrcamentoResponse.VersoesCalculoTO> lVersoes = new List<EndossoOrcamentoResponse.VersoesCalculoTO>();
        EndossoOrcamentoResponse.VersoesCalculoTO versoesObj = new EndossoOrcamentoResponse.VersoesCalculoTO();
        versoesObj.tipo = 'FPG';
        versoesObj.opcao = 1;
        versoesObj.descontoAgravo = 0.0;
        lVersoes.add(versoesObj);
        oferta.versoesCalculos = lVersoes;
           
        List<EndossoOrcamentoResponse.RemuneracoesTO> lRemuneracoes = new List<EndossoOrcamentoResponse.RemuneracoesTO>();
        //PLV-4738-FIX4-INICIO
        String ramo = String.valueOf(payload.orcamento.ramo);
        String sucursal = String.valueOf(payload.orcamento.sucursal);
        List<RemuneracaoContrato__c> lremuneracaoContrato = [select 
                                                                        TipoRemuneracao__r.Codigo__c, 
                                                                        Percentual__c,
                                                                        Contrato__r.VigenciaFinal__c, 
                                                                        Contrato__r.StartDate, 
                                                                        Contrato__r.CanalDistribuicao__r.Sigla__c,
                                                                        Contrato__r.TipoViagem__c,
                                                                        Contrato__r.MeioComercializacao__c
                                                                from RemuneracaoContrato__c 
                                                                where 
                                                                Contrato__r.NumeroApolice__c =: payload.orcamento.apolice and
                                                                Contrato__r.CodigoRamo__c =: ramo and
                                                                Contrato__r.Sucursal__c =: sucursal
                                                                ];
        //PLV-4738-FIX4-FIM
        if(lremuneracaoContrato.size() > 0){
            for(RemuneracaoContrato__c rem : lremuneracaoContrato){
                EndossoOrcamentoResponse.RemuneracoesTO noRemuneracoes = new EndossoOrcamentoResponse.RemuneracoesTO();
                noRemuneracoes.percentual = rem.Percentual__c;
                noRemuneracoes.tipoRemuneracao = rem.TipoRemuneracao__r.Codigo__c;
                lRemuneracoes.add(noRemuneracoes);
            }
                
        }
        oferta.vigenciaInicial = opp.VigenciaInicial__c;
        oferta.vigenciaFinal = opp.VigenciaFinal__c;
        oferta.codigoProdutoVida = opp.Produto__r.ProductCode;
        oferta.remuneracoes = lRemuneracoes;

        //PLV-4738 - FIM
        
        EndossoOrcamentoResponse.OfertaTO retornoOferta = new EndossoOrcamentoResponse.OfertaTO();
        retornoOferta.orcamento = oferta;
        retorno.add(retornoOferta);
        system.debug('Retorno>>. ' + JSON.serialize(retorno));
        return retorno;
    }
    public String gerarNumeroOferta(){
        ContadorCodigo__c confNumOferta = [SELECT Numero__c FROM ContadorCodigo__c WHERE Name = 'NumeroOferta' FOR UPDATE];
        Integer numOferta = Integer.valueOf(confNumOferta.Numero__c);
        numOferta++;
        confNumOferta.Numero__c = numOferta;
        update confNumOferta;
        return String.valueOf(numOferta).leftPad(10,'0');
    }  
}