/****
@description Classe contendo logica de preenchimento dos objetos de Orcamento, Proposta, Contrato e seus relacionados
@author Jeferson santana
@date 30/12/2020
-Classe criada por conta da historia PLV-4695    
*****/
public with sharing class EndossoOrcamentoVIService {
    private EndossoOrcamentoREST.Request req;
    private Double valorTotalpago = 0; //PLV-4695-FIX2 - INICIO/FIM
    private Double valorPremioTotal = 0; //PLV-5147 - FIX02 - INICIO/FIM
    private static OrcamentoBuilder orcamentoBuilder;
    private static OrcamentoGenericoBuilder orcamentoGenericoBuilder;
    private final String STATUS_PARCELA_PAGA = 'PAGA'; //PLV-5147 - FIX02 - INICIO/FIM

    // TKCL-601 - INICIO
    Contract contrato;  
    List<ContratanteContrato__c> lstContraCon; 
    List<EndossoOrcamentoVIResponse.ContratanteTO> contratanteContratoOriginal;
    List<SeguradoContrato__c> lstSeguradoCon; 
    List<EndossoOrcamentoVIResponse.DescontoAgravoTO> lDescontoAgravo; 
    List<GarantiaContrato__c> lstGaranCon; 
    Map<String, List<GarantiaContratanteContrato__c>> mapGarantiaContratanteContrato; 
    Map<String, List<GrupoContrato__c>> mapGrupoContrato; 
    Map<String, List<GarantiaSeguradoContrato__c>> mapGarantiaSeguradoContrato;     
    Map<String, List<GarantiaGrupoContrato__c>> mapGarantiaGrupoContrato; 
    Map<String, List<SeguradoContrato__c>> mapSeguradoContrato; 
    List<RemuneracaoContrato__c> lremuneracaoContrato; 
     // TKCL-601 - FIM
            // private static HerokuService herokuService;


    public EndossoOrcamentoVIService(EndossoOrcamentoREST.Request req){
        this.req = req;
        this.valorTotalpago = req.orcamento.premioPago; //PLV-4695-FIX2 - INICIO/FIM
    }

    
    public List<EndossoOrcamentoVIResponse.OfertaTO> gravaOrcamentoEndosso(){
        List<EndossoOrcamentoVIResponse.OfertaTO> retorno = new List<EndossoOrcamentoVIResponse.OfertaTO>();
        EndossoOrcamentoVIResponse.OrcamentoTO oferta = new EndossoOrcamentoVIResponse.OrcamentoTO();
        EmissaoTO.PayloadTO payload = new EmissaoTO.PayloadTO();
        payload.orcamento = req.orcamento;

        system.debug('req Danilo>>>>>' + req);

        //PLV-5147 - FIX02 - INICIO
        String sempresa = req.orcamento.empresa,
            ssucursal = req.orcamento.sucursal.format(),
            sramo = req.orcamento.ramo.format().replace('.',''),
            sapolice = req.orcamento.apolice,
            sDataCalculo = req.orcamento.dataCalculo,                 //PLV-5384 INICIO/FIM
            sDatavigenciaInicial = req.orcamento.vigenciaInicial,     //PLV-5384 INICIO/FIM
            sEndosso = req.orcamento.endosso;                         //FNPVVEP-51 INICIO/FIM

        
        system.debug('req.orcamento >>>' + JSON.serialize(req.orcamento));
        // ** Importante - execução de consulta a tabela public_parcelacontrato__x deve ser antes de qualquer
        //      atualizaçao nas tabelas por conta do callout ao heroku.
        if (req.orcamento.tipoSeguro == 'CAN') {
            Double auxValorTotPago = obterValorTotalPago(sempresa, ssucursal, sramo, sapolice, sDataCalculo, sDatavigenciaInicial, sEndosso); //PLV-5384 INICIO/FIM || FNPVVEP-51 INICIO/FIM
            System.debug('auxValorTotPago >> ' + auxValorTotPago + ' - endosso: >> ' + sEndosso);
            if (auxValorTotPago != 0) {
                system.debug('auxValorTotPago >> ' + auxValorTotPago.format());
                this.valorTotalpago = auxValorTotPago;
            }                              
        }
        //PLV-5147 - FIX02 - FIM 

                
        orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(false);

        Orcamento orcamento = orcamentoGenericoBuilder.montarOrcamento(payload, null, true);
        

        String numeroOrcamento = orcamento.orcamentoWrapper.sfOrcamento.Numero__c;
        system.debug('numeroOrcamento >> ' + numeroOrcamento);
        String idContrato = orcamento.orcamentoWrapper.sfOrcamento.ContractId;

        List<ContratanteOrcamento__c> lstContraOrc = [SELECT Id, Tipo__c, PremioComercial__c, PremioPuro__c, PremioTotal__c,
        PremioIntegral__c, //PLV-5351 INÍCIO/FIM
        TaxaComercial__c, TaxaPura__c, TaxaTotal__c FROM ContratanteOrcamento__c WHERE Orcamento__r.Numero__c = :numeroOrcamento];

        List<GrupoOrcamento__c> lstGrupoOrc = [SELECT Id, ContratanteOrcamento__c, Name, TipoCalculo__c, 
        QuantidadeVidas__c FROM GrupoOrcamento__c WHERE ContratanteOrcamento__r.Orcamento__r.Numero__c = :numeroOrcamento];

        List<GarantiaGrupoOrcamento__c> lstGaranGrupoOrc = [SELECT Id, Garantia__r.Sigla__c, GrupoOrcamento__c, PremioComercial__c, PremioPuro__c, PremioTotal__c,
        PremioIntegral__c, //PLV-5351 INÍCIO/FIM
        TaxaComercial__c, TaxaPura__c, TaxaTotal__c FROM GarantiaGrupoOrcamento__c WHERE GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.Numero__c = :numeroOrcamento];

        List<GarantiaContratanteOrcamento__c> lstGaranContraOrc = [SELECT Id,Garantia__r.Sigla__c,  ContratanteOrcamento__c, PremioComercial__c, PremioPuro__c, PremioTotal__c,
        PremioIntegral__c, //PLV-5351 INÍCIO/FIM
        TaxaComercial__c, TaxaPura__c, TaxaTotal__c FROM GarantiaContratanteOrcamento__c WHERE ContratanteOrcamento__r.Orcamento__r.Numero__c = :numeroOrcamento];
        
        List<SeguradoOrcamento__c> lstSeguradoOrc = [SELECT Id, GrupoOrcamento__c, 
                                                            PremioComercial__c, 
                                                            PremioPuro__c, 
                                                            PremioTotal__c,
                                                            TaxaComercial__c, 
                                                            PremioIntegral__c, //PLV-5351 INÍCIO/FIM
                                                            TaxaPura__c, 
                                                            TaxaTotal__c, 
                                                            Conta__r.Name, 
                                                            Conta__r.NomeSocial__c, // LECVPV-188(CANCELAMENTO) INICIO/FIM
                                                            Conta__r.Cpf__c,
                                                            Conta__r.Profissao__c, //PLV-4695-FIX1-INICIO/FIM
                                                            Conta__r.Profissao__r.Codigo__c,
                                                            Conta__r.Sexo__c,
                                                            Conta__r.Fumante__c,
                                                            Conta__r.PersonBirthdate,
                                                            Conta__r.RegimeTrabalho__c
                                                    FROM SeguradoOrcamento__c WHERE GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.Numero__c = :numeroOrcamento];

        List<GarantiaSeguradoOrcamento__c> lstGaranSeguradoOrc = [SELECT Id, CurrencyIsoCode, ValorCotacao__c, Garantia__r.Sigla__c, Valor__c, Quantidade__c, SeguradoOrcamento__c, Capital__c, PremioTotal__c //II-10 INICIO-FIM
                                    FROM GarantiaSeguradoOrcamento__c 
                                    WHERE SeguradoOrcamento__r.GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.Numero__c = :numeroOrcamento];
        
                                    //*************************************************** */  

        //PLV-5147 - FIX02 - INICIO
        GarantiaSeguradoContratoDAO daoGarSegContr = GarantiaSeguradoContratoDAO.getInstance();
        List<GarantiaSeguradoContrato__c> lstGaranSeguradoCon;
        if (req.orcamento.tipoSeguro != 'CAN') {
            lstGaranSeguradoCon = daoGarSegContr.buscarGarantiaSeguradoContrado(new Set<Id>{idContrato});
            system.debug('lstGaranSeguradoCon1 = ' + lstGaranSeguradoCon);
        } else { // == 'CAN')
            lstGaranSeguradoCon = daoGarSegContr.buscarGarantiaSeguradoContradoeEndosso(
                sempresa,
                ssucursal,
                sramo, 
                sapolice);
            system.debug('lstGaranSeguradoCon2 = ' + lstGaranSeguradoCon);
        }

        this.valorPremioTotal = calcularValorPremioTotal(lstGaranSeguradoCon);
        //PLV-5147 - FIX02 - FIM

                                    lstSeguradoCon = [SELECT  // TKCL-601 INICIO/FIM
                                                            Id, 
                                                            GrupoContrato__c, 
                                                            PremioIntegral__c, //PLV-5351 INICIO/FIM 
                                                            PremioComercial__c, 
                                                            PremioPuro__c, 
                                                            PremioTotal__c, 
                                                            TaxaComercial__c, 
                                                            TaxaPura__c, 
                                                            TaxaTotal__c, 
                                                            DescontoAgravoMonetarioFormaPagto__c,
                                                            DescontoAgravoPercentualFormaPagto__c,
                                                            TipoDescontoAgravo__c ,
                                                            Conta__r.PersonBirthdate, // TKCL-601 INICIO/FIM
                                                            Conta__r.Sexo__c  // TKCL-601 INICIO/FIM
                                                        FROM SeguradoContrato__c 
                                                        WHERE 
                                                        GrupoContrato__r.ContratanteContrato__r.Contrato__c = :idContrato];

        List<GarantiaGrupoContrato__c> lstGaranGrupoCon = [SELECT 
                                                                Id, 
                                                                Garantia__r.Sigla__c, 
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
                                                                Capital__c, //PLV-4695-FIX3-INICIO/FIM
                                                                TipoDescontoAgravo__c
                                                            FROM 
                                                            GarantiaGrupoContrato__c 
                                                            WHERE 
                                                            GrupoContrato__r.ContratanteContrato__r.Contrato__c = :idContrato];

        List<GrupoContrato__c> lstGrupoCon = [SELECT 
                                                    Id, 
                                                    ContratanteContrato__c, 
                                                    PremioIntegral__c, //PLV-5351 INICIO/FIM
                                                    PremioComercial__c, 
                                                    PremioPuro__c, 
                                                    PremioTotal__c,
                                                    TaxaComercial__c, 
                                                    TaxaPura__c, 
                                                    TaxaTotal__c,
                                                    DescontoAgravoMonetarioFormaPagto__c,
                                                    DescontoAgravoPercentualFormaPagto__c,
                                                    TipoDescontoAgravo__c
                                                FROM GrupoContrato__c 
                                                WHERE 
                                                ContratanteContrato__r.Contrato__c = :idContrato];

        List<GarantiaContratanteContrato__c> lstGaranContraCon = [SELECT 
                                                                        Id,Garantia__r.Sigla__c,  
                                                                        ContratanteContrato__c, 
                                                                        PremioComercial__c, 
                                                                        PremioPuro__c, 
                                                                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                                                                        PremioTotal__c,
                                                                        TaxaComercial__c, 
                                                                        TaxaPura__c, 
                                                                        TaxaTotal__c,
                                                                        DescontoAgravoMonetarioFormaPagto__c,
                                                                        DescontoAgravoPercentualFormaPagto__c,
                                                                        Capital__c, //PLV-4695-INICIO/FIM
                                                                        TipoDescontoAgravo__c 
                                                                    FROM GarantiaContratanteContrato__c 
                                                                    WHERE 
                                                                    ContratanteContrato__r.Contrato__c = :idContrato];

                                             lstContraCon = [SELECT   // TKCL-601 INICIO/FIM
                                                            Id, 
                                                            PremioComercial__c, 
                                                            PremioPuro__c, 
                                                            PremioTotal__c,
                                                            PremioIntegral__c, //PLV-5351 INICIO/FIM
                                                            TaxaComercial__c, 
                                                            TaxaPura__c, 
                                                            TaxaTotal__c,
                                                            DescontoAgravoMonetarioFormaPagto__c, 
                                                            DescontoAgravoPercentualFormaPagto__c, 
                                                            TipoDescontoAgravo__c 
                                                    FROM ContratanteContrato__c 
                                                    WHERE Contrato__c = :idContrato];

                             lstGaranCon = [SELECT Id, Garantia__r.Sigla__c, // TKCL-601 INICIO/FIM
                                                        PremioComercial__c, 
                                                        PremioPuro__c, 
                                                        PremioTotal__c,
                                                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                                                        TaxaComercial__c, 
                                                        TaxaPura__c, 
                                                        TaxaTotal__c,
                                                        DescontoAgravoMonetarioFormaPagto__c, 
                                                        DescontoAgravoPercentualFormaPagto__c,
                                                        Capital__c, //PLV-4695-FIX3-INICIO/FIM 
                                                        TipoDescontoAgravo__c,
                                                        IOF__c, //TKCL-601 - INICIO/FIM
                                                        Limite_de_Uso__c, //TKCL-601 - INICIO/FIM
                                                        Tipo_de_limite_de_utilizacao__c // TKCL-601 INICIO/FIM 
                                                FROM GarantiaContrato__c 
                                                WHERE Contrato__c = :idContrato];

        
                        contrato = [SELECT Id, VigenciaFinal__c, // TKCL-601 INICIO/FIM
                                    ValorIOF__c, StartDate, 
                                    Produto__r.ProductCode ,
                                    Produto__r.CodigoPrecificaProduto__c, //PLV-5392-INICIO/FIM
                                    PremioComercial__c, 
                                    PremioPuro__c, 
                                    PremioTotal__c,
                                    Name, //FNPVVEP-121 INICIO/FIM
                                    PremioIntegral__c, //PLV-5351 INICIO/FIM
                                    TaxaComercial__c, 
                                    TaxaPura__c, 
                                    TaxaTotal__c, 
                                    MeioComercializacao__c, 
                                    CanalDistribuicao__r.Sigla__c, 
                                    Proposta__r.TipoVigencia__c, 
                                    Proposta__r.DataCalculo__c, // TKCL-601 INICIO/FIM
                                    segmento__c,
                                    CodigoRamo__c, 
                                    Endosso__c, 
                                    Sucursal__c,
                                    Empresa__c, 
                                    NumeroApolice__c,
                                    DescontoAgravoPercentualFormaPagto__c, 
                                    DescontoAgravoMonetarioFormaPagto__c,
                                    DescontoAgravoPercentualTecnico__c, // TKCL-601 INICIO
                                    DescontoAgravoMonetarioTecnico__c, 
                                    DescontoAgravoPercentualComercial__c, 
                                    DescontoAgravoMonetarioComercial__c, 
                                    DescontoAgravoPercentualInformado__c, 
                                    DescontoAgravoMonetarioInformado__c, 
                                    DescontoAgravoPercentualParcelamento__c, 
                                    DescontoAgravoMonetarioParcelamento__c, // TKCL-601 FIM
                                    TipoDescontoAgravo__c,
                                    Oportunidade__r.Numero__c,
                                    Tarifa__c, //PLV-5300 - INICIO/FIM
                                    DLL__c,  // TKCL-601 INICIO/FIM
                                    Produto__r.Id, //PLV-5391 - INICIO/FIM
                                    Tipo__c // TKCL-601 INICIO/FIM
                            FROM Contract WHERE Id = :idContrato]; 
        //PLV-4695-FIX5 - INICIO
        Opportunity opp = [SELECT 
                                    Id, 
                                    Name, 
                                    Type, 
                                    NumeroOferta__c,
                                    DataCalculo__c, 
                                    Numero__c, TipoEndosso__C, 
                                    NumeroPortal__c, 
                                    EntradaNegocio__c,
                                    VigenciaInicial__c,
                                    VigenciaFinal__c
                            FROM Opportunity 
                            WHERE Numero__c =: numeroOrcamento LIMIT 1];
        //PLV-5695-FIX5 - FIM

        // TKCL-601 INICIO
        //PLV-4695-FIX4-INICIO
        String ramo = String.valueOf(payload.orcamento.ramo);
        String sucursal = String.valueOf(payload.orcamento.sucursal);
        lremuneracaoContrato =  [select    
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
        //PLV-4695-FIX4-FIM
        // TKCL-601 FIM

        // TKCL-601 INICIO
        mapGarantiaContratanteContrato = new Map<String, List<GarantiaContratanteContrato__c>>(); 
        mapGrupoContrato = new Map<String, List<GrupoContrato__c>>(); 
        mapGarantiaGrupoContrato = new Map<String, List<GarantiaGrupoContrato__c>>(); 
        mapSeguradoContrato = new Map<String, List<SeguradoContrato__c>>();
        mapGarantiaSeguradoContrato = new Map<String, List<GarantiaSeguradoContrato__c>>(); 
        // TKCL-601 FIM
        Map<String,GarantiaSeguradoContrato__c> mapSiglaGarantiaSeguradoContrato = new Map<String,GarantiaSeguradoContrato__c>();  //II-10 INICIO/FIM

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
        System.debug('lstGaranSeguradoCon: ><' + lstGaranSeguradoCon);
        for(GarantiaSeguradoContrato__c garantiaSegurado : lstGaranSeguradoCon){
            if(mapGarantiaSeguradoContrato.get(garantiaSegurado.SeguradoContrato__c) == null)
                mapGarantiaSeguradoContrato.put(garantiaSegurado.SeguradoContrato__c, new List<GarantiaSeguradoContrato__c>());
            List<GarantiaSeguradoContrato__c> listGarantia = mapGarantiaSeguradoContrato.get(garantiaSegurado.SeguradoContrato__c);
            listGarantia.add(garantiaSegurado);
            mapGarantiaSeguradoContrato.put(garantiaSegurado.SeguradoContrato__c, listGarantia);

            mapSiglaGarantiaSeguradoContrato.put(garantiaSegurado.Garantia__r.Sigla__c, garantiaSegurado); // II-10 INICIO/FIM
        }
        //system.debug('mapGarantiaSeguradoContrato = ' + mapGarantiaSeguradoContrato);
        //system.debug('mapSiglaGarantiaSeguradoContrato = ' + JSON.serialize(mapSiglaGarantiaSeguradoContrato)); // II-10 INICIO/FIM
        
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
         //PLV-4695-FIX1-INICIO
        List<SeguradoOrcamento__c>lsegurados = new list<SeguradoOrcamento__c>();
        for(SeguradoOrcamento__c segurado : lstSeguradoOrc){
            lsegurados.add(segurado);
            if(mapSeguradoOrcamento.get(segurado.GrupoOrcamento__c) == null)
                mapSeguradoOrcamento.put(segurado.GrupoOrcamento__c, new List<SeguradoOrcamento__c>());
            List<SeguradoOrcamento__c> listGarantia = mapSeguradoOrcamento.get(segurado.GrupoOrcamento__c);
            listGarantia.add(segurado);
            mapSeguradoOrcamento.put(segurado.GrupoOrcamento__c, listGarantia);
        }
        Map<Id,String> mGrupoProfissao = new Map<Id,String>{};
        Map<Id,String> mProfissaoContrato = new Map<Id,String>{}; //PLV-5842 INICIO/FIM
        if(lsegurados.size() > 0){
            
            //RVI-175 - INICIO
            //Set<Id> sProfissoes = new Set<Id>();
            //for(SeguradoOrcamento__c lseg : lsegurados){
                //sProfissoes.add(lseg.Conta__r.Profissao__c); 
            //}         
            //List<GrupoProfissoes__c> lGrupoProfissao = [select GrupoRisco__r.Name, Profissao__c  from GrupoProfissoes__c where profissao__c in: sProfissoes];
            
            List<SeguradoContrato__c> lGrupoProfissao = [SELECT id, Profissao__c, GrupoRisco__c FROM SeguradoContrato__c WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c = :idContrato];
            
            /*for(GrupoProfissoes__c lgrprof : lGrupoProfissao){
                
                mGrupoProfissao.put(lgrprof.Profissao__c,lgrprof.GrupoRisco__r.Name);
            }*/

            for(SeguradoContrato__c lgrprof : lGrupoProfissao){
                
                mGrupoProfissao.put(lgrprof.Profissao__c,lgrprof.GrupoRisco__c);
                mProfissaoContrato.put(idContrato, lgrprof.Profissao__c); //PLV-5842 INICIO/FIM
            }
            //RVI-175 - FIM

            system.debug('grupo profissoes'+mGrupoProfissao);
        }
        
        //PLV-4695-FIX1-FIM

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
        oferta.tipoSeguro = opp.Type == 'CAN' ? 'Cancelamento' : opp.Type;
        oferta.numeroOferta = opp.NumeroOferta__c;
        oferta.dataCalculo = String.valueOf(opp.DataCalculo__c); // Validar
        oferta.motivoCancelamento = opp.TipoEndosso__c;
        
        // Contratante do Orcamento
        Integer contadorContratanteOrcamento = 1;
        Integer contadorGrupoOrcamento = 1;
        Integer contadorSeguradoOrcamento = 1;
        oferta.contratantes = new List<EndossoOrcamentoVIResponse.ContratanteTO>();
        contratanteContratoOriginal  = new List<EndossoOrcamentoVIResponse.ContratanteTO>(); // TKCL-601 INICIO/FIM

        system.debug('lstContraOrc = ' + lstContraOrc);
        for(ContratanteOrcamento__c contratante : lstContraOrc){
            EndossoOrcamentoVIResponse.ContratanteTO contratanteOrcamento = new EndossoOrcamentoVIResponse.ContratanteTO();
            contratanteOrcamento.tipo = contratante.Tipo__c;
            contratanteOrcamento.numero = contadorContratanteOrcamento;
            contadorContratanteOrcamento++;
            
            if(mapGrupoOrcamento.get(contratante.Id) != null){
                if(contratanteOrcamento.grupos == null){
                    contratanteOrcamento.grupos = new List<EndossoOrcamentoVIResponse.GrupoTO>();
                }

                // GrupoOrcamento__c grupo = mapGrupoOrcamento.get(contratante.Id);
                for(GrupoOrcamento__c grupo : mapGrupoOrcamento.get(contratante.Id)){
                    EndossoOrcamentoVIResponse.GrupoTO grupoOrcamento = new EndossoOrcamentoVIResponse.GrupoTO();
                    grupoOrcamento.numero = contadorGrupoOrcamento;
                    contadorGrupoOrcamento++;
                    grupoOrcamento.nome = grupo.Name;
                    //grupoOrcamento.tipoCalculo = grupo.TipoCalculo__c;
                    grupoOrcamento.qtdeVidas = Integer.valueOf(grupo.QuantidadeVidas__c);

                    // Segurados
                    if(mapSeguradoOrcamento.get(grupo.Id) != null){
                        if(grupoOrcamento.segurados == null){
                            grupoOrcamento.segurados = new List<EndossoOrcamentoVIResponse.SeguradoTO>();
                        }
                        
                        // SeguradoOrcamento__c seguradoOrcamento = mapSeguradoOrcamento.get(grupo.Id);
                        for(SeguradoOrcamento__c seguradoOrcamento : mapSeguradoOrcamento.get(grupo.Id)){
                            String profissaoSegurado; //PLV-5842 INICIO/FIM
                            EndossoOrcamentoVIResponse.SeguradoTO seguradoDoOrcamento = new EndossoOrcamentoVIResponse.SeguradoTO();
                            seguradoDoOrcamento.numero = contadorSeguradoOrcamento;
                            //nó pessoa
                            EndossoOrcamentoVIResponse.PessoaTO pes = new EndossoOrcamentoVIResponse.PessoaTO();
                            pes.tipo = (seguradoOrcamento.Conta__r.Cpf__c != null || seguradoOrcamento.Conta__r.Cpf__c != '') ? 'FIS' : 'JUR';
                            pes.nome = seguradoOrcamento.Conta__r.Name; 
                            pes.nomeSocial = seguradoOrcamento.Conta__r.NomeSocial__c; // LECVPV-188(CANCELAMENTO) INICIO/FIM
                            seguradoDoOrcamento.pessoa = pes;
                            //no dadospessoa fisica
                            EndossoOrcamentoVIResponse.DadosPessoaTO dadosPes = new EndossoOrcamentoVIResponse.DadosPessoaTO();
                            dadosPes.dataNascimento = seguradoOrcamento.Conta__r.PersonBirthdate;
                            String fumante = seguradoOrcamento.Conta__r.Fumante__c;
                            //PLV-4695 Inicio
							If(fumante != null){
								fumante = fumante.trim();
								dadosPes.fumante = (fumante.toUpperCase() == 'SIM') ? true : false;
							}else{
								dadosPes.fumante = false;
                            }																								                            
                            //dadosPes.grupoProfissao = mGrupoProfissao.get(seguradoOrcamento.Conta__r.Profissao__c); //PLV-4695-FIX1-INICIO/FIM
                            //PLV-5482 INICIO
                            System.debug('Danilo mProfissaoContrato: ' + mProfissaoContrato);
                            System.debug('Danilo idContrato ' + idContrato);
                            profissaoSegurado = (mProfissaoContrato.get(idContrato) != null) ? mProfissaoContrato.get(idContrato): '"';
                            dadosPes.grupoProfissao = (mGrupoProfissao.get(profissaoSegurado) != null) ? mGrupoProfissao.get(profissaoSegurado) : ''; //PLV-4695-FIX1-INICIO/FIM Aki	//II-142 INICIO/FIM
                            //dadosPes.grupoProfissao = (mGrupoProfissao.get(seguradoOrcamento.Conta__r.Profissao__c) != null) ? mGrupoProfissao.get(seguradoOrcamento.Conta__r.Profissao__c) : '""'; //PLV-4695-FIX1-INICIO/FIM Aki														
							//PLV-4695 Fim
							dadosPes.profissao = profissaoSegurado;
                            //PLV-5842 FIM
                            dadosPes.sexo = seguradoOrcamento.Conta__r.Sexo__c;
                            dadosPes.regimeTrabalho = seguradoOrcamento.Conta__r.RegimeTrabalho__c;
                            
                            seguradoDoOrcamento.pessoa.dadosPessoaFisica = dadosPes;

                            contadorSeguradoOrcamento++;
                            
                            if(mapGarantiaSeguradoOrcamento.get(seguradoOrcamento.Id) != null){
                                if(seguradoDoOrcamento.coberturas == null){
                                    seguradoDoOrcamento.coberturas = new List<EndossoOrcamentoVIResponse.CoberturaTO>();
                                }
                                // GarantiaSeguradoOrcamento__c garantiaSeguradoOrcamento = mapGarantiaSeguradoOrcamento.get(seguradoOrcamento.Id);
                                for(GarantiaSeguradoOrcamento__c garantiaSeguradoOrcamento : mapGarantiaSeguradoOrcamento.get(seguradoOrcamento.Id)){
                                    // System.debug('Garantia_Orcamento - SIGLA: '+  garantiaSeguradoOrcamento.Garantia__r.Sigla__c);
                                    // System.debug('Garantia_Orcamento - Capital: '+  garantiaSeguradoOrcamento.Capital__c);            
                                    GarantiaSeguradoContrato__c garantiaSegContrato = mapSiglaGarantiaSeguradoContrato.get( garantiaSeguradoOrcamento.Garantia__r.Sigla__c); // II-10 INICIO/FIM
                                    //PLV-4695-FIX3 - INICIO
                                    if((garantiaSeguradoOrcamento.Capital__c != null && garantiaSeguradoOrcamento.Capital__c > 0) || 
                                        (garantiaSeguradoOrcamento.Capital__c != null && garantiaSeguradoOrcamento.Capital__c == 0 && 
                                         garantiaSegContrato != null && garantiaSegContrato.PremioTotal__c > 0)) { //II-10 INICIO-FIM //II-10-FIX01 INICIO-FIM
                                            EndossoOrcamentoVIResponse.CoberturaTO gtSeguradoOrcamento = new EndossoOrcamentoVIResponse.CoberturaTO();
                                            gtSeguradoOrcamento.sigla = garantiaSeguradoOrcamento.Garantia__r.Sigla__c;
                                            //gtSeguradoOrcamento.valor = garantiaSeguradoOrcamento.Valor__c;
                                            gtSeguradoOrcamento.valor = garantiaSeguradoOrcamento.Capital__c;
                                            gtSeguradoOrcamento.moeda = garantiaSeguradoOrcamento.CurrencyIsoCode;
                                            gtSeguradoOrcamento.franquia = 'FR_NORMAL';
                                            //gtSeguradoOrcamento.cotacaoMoeda = garantiaSeguradoOrcamento.ValorCotacao__c;
                                            gtSeguradoOrcamento.quantidade = (Integer.valueOf(garantiaSeguradoOrcamento.Quantidade__c) != null) ? Integer.valueOf(garantiaSeguradoOrcamento.Quantidade__c) : 0;
                                            seguradoDoOrcamento.coberturas.add(gtSeguradoOrcamento);
                                    }
                                    //PLV-4695-FIX3 - FIM
                                    
                                }
                            }
                            grupoOrcamento.segurados.add(seguradoDoOrcamento);
                        }
                        contratanteOrcamento.grupos.add(grupoOrcamento);
                    }
                }
                oferta.contratantes = new List<EndossoOrcamentoVIResponse.ContratanteTO>();
                oferta.contratantes.add(contratanteOrcamento);
                contratanteContratoOriginal.add(contratanteOrcamento);
            }
        }
        
        // Contrato
        oferta.contratoOriginal = ('APTLMKT'.equals(contrato.Produto__r.CodigoPrecificaProduto__c) || 'VIDA_ON'.equals(contrato.Produto__r.CodigoPrecificaProduto__c))  ?  montaContratoOriginalAPTLMKT() :  montaContratoOriginalGeral(); // VIDA-30 - INICIO/FIM
        //oferta.contratoOriginal = 'APTLMKT'.equals(contrato.Produto__r.CodigoPrecificaProduto__c) ?  montaContratoOriginalAPTLMKT() :  montaContratoOriginalGeral(); // TKCL-601 INICIO/FIM

        EndossoOrcamentoVIResponse.ResultadoIntegracaoTO noresultaIntegracao = new EndossoOrcamentoVIResponse.ResultadoIntegracaoTO(); 
        oferta.resultadoIntegracoes = noresultaIntegracao;
        List<EndossoOrcamentoVIResponse.VersoesCalculoTO> lVersoes = new List<EndossoOrcamentoVIResponse.VersoesCalculoTO>();
        EndossoOrcamentoVIResponse.VersoesCalculoTO versoesObj = new EndossoOrcamentoVIResponse.VersoesCalculoTO();
        //PLV-5384 INICIO FIX-02
        versoesObj.tipo = (contrato.TipoDescontoAgravo__c != null) ? contrato.TipoDescontoAgravo__c :'FPG';
        versoesObj.opcao = 1;
        versoesObj.descontoAgravo = contrato.DescontoAgravoPercentualFormaPagto__c; //PLV-5745 INICIO/FIM

        //PLV-5384 FIM FIX-02
        lVersoes.add(versoesObj);
        oferta.versoesCalculos = lVersoes;
        System.debug('oferta.versoesCalculos>>>>> ' + oferta.versoesCalculos);
        System.debug('lVersoes>>>>> ' + lVersoes);
        System.debug('versoesObj>>>>> ' + versoesObj);
        System.debug('oferta>>>>> ' + oferta);
        //PLV-4695-FIX4-INICIO
        List<EndossoOrcamentoVIResponse.RemuneracoesTO> lRemuneracoes = new List<EndossoOrcamentoVIResponse.RemuneracoesTO>();
        //PLV-4695-FIX4-FIM
        if(lremuneracaoContrato.size() > 0){
            for(RemuneracaoContrato__c rem : lremuneracaoContrato){
                EndossoOrcamentoVIResponse.RemuneracoesTO noRemuneracoes = new EndossoOrcamentoVIResponse.RemuneracoesTO();
                noRemuneracoes.percentual = rem.Percentual__c;
                noRemuneracoes.tipoRemuneracao = rem.TipoRemuneracao__r.Codigo__c;
                lRemuneracoes.add(noRemuneracoes);
                System.debug('lRemuneracoes>>>>> ' + lRemuneracoes);
            }     
        }
        oferta.vigenciaInicial = opp.VigenciaInicial__c; //PLV-4695-FIX5-INICIO/FIM
        oferta.vigenciaFinal = opp.VigenciaFinal__c; //PLV-4695-FIX5-INICIO/FIM
        oferta.qtdDiasVigencia = opp.DataCalculo__c.daysBetween(opp.VigenciaFinal__c) + 1; //PLV-5833 INICIO/FIM
        System.debug('oferta.qtdDiasVigencia >> ' + oferta.qtdDiasVigencia);
        oferta.canalDistribuicao = contrato.CanalDistribuicao__r.Sigla__c;
        oferta.meioComercializacao =  contrato.MeioComercializacao__c;
        oferta.tipoVigencia = contrato.Proposta__r.TipoVigencia__c; 
        oferta.codigoProdutoVida = contrato.Produto__r.CodigoPrecificaProduto__c; //PLV-5391 - INICIO/FIM
        oferta.numeroPortal = (opp.NumeroPortal__c != null) ? opp.NumeroPortal__c : '0';
        oferta.segmento = contrato.segmento__c;
        oferta.entradaNegocio = 123; //(opp.EntradaNegocio__c != null) ? Integer.valueOf(opp.EntradaNegocio__c) : 0;          
        oferta.ordemPortal = 1;
        oferta.dataEndosso = (payload.orcamento.dataEndosso != null) ? date.valueOf(payload.orcamento.dataEndosso) : Date.today(); //PLV-4686 - INÍCIO/FIM - Guilherme Brito
        oferta.remuneracoes = lRemuneracoes;
       

        EndossoOrcamentoVIResponse.OfertaTO retornoOferta = new EndossoOrcamentoVIResponse.OfertaTO();
        retornoOferta.orcamento = oferta;
        retorno.add(retornoOferta);
        system.debug('TESTE PLV-4695 json SERIALIZE'+JSON.serialize(retorno, true)); //PLV-4695 - INICIO/FIM
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

 
    private EndossoOrcamentoVIResponse.ContratoGenericoTO montaContratoOriginalGeral() {    // TKCL-601 INICIO/FIM
        System.debug('contratoGERALTESTE ><' + contrato);
        EndossoOrcamentoVIResponse.ContratoTO contratoOriginal = new EndossoOrcamentoVIResponse.ContratoTO();
        //FNPVVEP-121 INICIO
        Contract buscaVigenciaContratoOriginal;
		String numeroApolice = contrato.Name; 
		String numeroApoliceOriginal;
		if(numeroApolice != null){
			System.debug('ENTROU NESSE IF AGORA AQUI');
			numeroApoliceOriginal = numeroApolice.substring(0, numeroApolice.length() - 1) + '0';
        	buscaVigenciaContratoOriginal = [ SELECT Id, StartDate FROM Contract WHERE NAME =: numeroApoliceOriginal];
		}
        //FNPVVEP-121 /FIM
        contratoOriginal.contratantes = contratanteContratoOriginal;
        //contratoOriginal.premioTotal = Integer.valueOf(contrato.PremioTotal__c);
        //contratoOriginal.premioPago = Double.valueOf(payload.orcamento.premioPago);
        contratoOriginal.vigenciaInicial = String.valueOf(contrato.StartDate);
        contratoOriginal.vigenciaFinal = String.valueOf(contrato.VigenciaFinal__c);
        contratoOriginal.qtdDiasVigencia = contrato.StartDate.daysBetween(contrato.VigenciaFinal__c) + 1; //PLV-5833 INICO-FIM
        System.debug('contratoOriginal.qtdDiasVigencia >> ' + contratoOriginal.qtdDiasVigencia);
        contratoOriginal.codigoProdutoVida = contrato.Produto__r.CodigoPrecificaProduto__c; //PLV-5392-INICIO/FIM
        contratoOriginal.numeroOrcamento =  contrato.Oportunidade__r.Numero__c;
        contratoOriginal.endosso = Integer.valueOf(contrato.Endosso__c);
        contratoOriginal.ramo = Integer.valueOf(contrato.CodigoRamo__c);
        contratoOriginal.apolice = contrato.NumeroApolice__c;
        contratoOriginal.sucursal = Integer.valueOf(contrato.Sucursal__c);
        contratoOriginal.empresa = Integer.valueOf(contrato.Empresa__c); 
        contratoOriginal.vigenciaInicialOriginal = buscaVigenciaContratoOriginal.StartDate != null ? String.valueOf(buscaVigenciaContratoOriginal.StartDate) : null; //FNPVVEP-121 INICIO/FIM
        contratoOriginal.tarifa = contrato.Tarifa__c; //PLV-5300 - INICIO/FIM       
        
        EndossoOrcamentoVIResponse.ResultadoIntegracaoTO resultaIntegracaoCO = new EndossoOrcamentoVIResponse.ResultadoIntegracaoTO();    
        contratoOriginal.resultadoIntegracoes = resultaIntegracaoCO;

        // Garantia do Contrato
        contratoOriginal.precificacao = new EndossoOrcamentoVIResponse.PrecificacaoTO();
        contratoOriginal.precificacao.iof = contrato.ValorIOF__c;
        contratoOriginal.precificacao.juros = 0;
        contratoOriginal.precificacao.encargos = 0;
        contratoOriginal.precificacao.custoDeApolice = 0;
        contratoOriginal.precificacao.premio = new EndossoOrcamentoVIResponse.PremioTO();
        //contratoOriginal.precificacao.taxa = new EndossoOrcamentoVIResponse.TaxaTO();
        contratoOriginal.precificacao.premio.comercial = contrato.PremioComercial__c;
        contratoOriginal.precificacao.premio.total = (req.orcamento.tipoSeguro == 'CAN' ? (contrato.PremioIntegral__c == null ? contrato.PremioTotal__c : contrato.PremioIntegral__c) : contrato.PremioTotal__c); // contrato.PremioTotal__c; //PLV-5147 - FIX02 - INICIO/FIM //PLV-5384 INICIO/FIM
        contratoOriginal.precificacao.premio.premioPago = this.valorTotalpago; //PLV-4695-FIX2 - INICIO/FIM
        contratoOriginal.precificacao.premio.puro = contrato.PremioPuro__c;
        //contratoOriginal.precificacao.premio.integral = contrato.PremioIntegral__c; //PLV-5351 INICIO/FIM //PLV-5384 INICIO/FIM
        //contratoOriginal.precificacao.Taxa.comercial = contrato.TaxaComercial__c;
        //contratoOriginal.precificacao.Taxa.total = contrato.TaxaTotal__c;
        //contratoOriginal.precificacao.Taxa.pura = contrato.TaxaPura__c;
        lDescontoAgravo = new List<EndossoOrcamentoVIResponse.DescontoAgravoTO>(); //TKCL-601 INICIO/FIM
        EndossoOrcamentoVIResponse.DescontoAgravoTO objDescontoAgravo = new EndossoOrcamentoVIResponse.DescontoAgravoTO();
        objDescontoAgravo.monetario = contrato.DescontoAgravoMonetarioFormaPagto__c;
        objDescontoAgravo.percentual = contrato.DescontoAgravoPercentualFormaPagto__c;
        objDescontoAgravo.tipo = (contrato.TipoDescontoAgravo__c != null) ? contrato.TipoDescontoAgravo__c :'FPG';
        lDescontoAgravo.add(objDescontoAgravo);
        System.debug('objDescontoAgravo: ' + objDescontoAgravo);
        contratoOriginal.precificacao.descontoAgravo = lDescontoAgravo;
        System.debug('contratoOriginal.precificacao.descontoAgravo: ' + contratoOriginal.precificacao.descontoAgravo);
        
        contratoOriginal.precificacao.coberturas = new List<EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO>();
        for(GarantiaContrato__c garantia : lstGaranCon){
            if ((garantia.Capital__c != null && garantia.Capital__c > 0) || 
                (garantia.Capital__c != null && garantia.Capital__c == 0 && 
                 garantia.PremioTotal__c!=null && garantia.PremioTotal__c > 0)) { //II-10-FIX01 INICIO-FIM //PLV-4695-FIX3-INICIO/FIM
                EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO cobertura = new EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO();
                cobertura.sigla = garantia.Garantia__r.Sigla__c;
                cobertura.premio = new EndossoOrcamentoVIResponse.PremioTO();
                //cobertura.taxa = new EndossoOrcamentoVIResponse.TaxaTO();
                //cobertura.premio.integral = garantia.PremioIntegral__c; //PLV-5351 INICIO/FIM //PLV-5384 INICIO/FIM FIX-01
                cobertura.premio.comercial = garantia.PremioComercial__c;
                cobertura.premio.puro = garantia.PremioPuro__c;
                cobertura.premio.total = (req.orcamento.tipoSeguro == 'CAN' ? (garantia.PremioIntegral__c == null ? garantia.PremioTotal__c : garantia.PremioIntegral__c) : garantia.PremioTotal__c); //PLV-5384 INICIO/FIM FIX-01
                cobertura.premio.premioPago = (this.valorTotalpago > 0) ? garantia.PremioTotal__c : 0; //PLV-5708 INICIO/FIM FIX-04
                //cobertura.taxa.total = garantia.TaxaComercial__c;
                //cobertura.taxa.pura = garantia.TaxaPura__c;
                //cobertura.taxa.comercial = garantia.TaxaTotal__c;
                cobertura.iof = 0.0;
                
                List<EndossoOrcamentoVIResponse.DescontoAgravoTO> lDescontoAgravoCobertura = new List<EndossoOrcamentoVIResponse.DescontoAgravoTO>();
                EndossoOrcamentoVIResponse.DescontoAgravoTO objDescontoAgravoCobertura = new EndossoOrcamentoVIResponse.DescontoAgravoTO();
                objDescontoAgravoCobertura.monetario = garantia.DescontoAgravoMonetarioFormaPagto__c;
                objDescontoAgravoCobertura.percentual = garantia.DescontoAgravoPercentualFormaPagto__c;
                objDescontoAgravoCobertura.tipo = (garantia.TipoDescontoAgravo__c != null) ? garantia.TipoDescontoAgravo__c :'FPG';
                lDescontoAgravoCobertura.add(objDescontoAgravo);
                cobertura.descontoAgravo = lDescontoAgravoCobertura;

                
                contratoOriginal.precificacao.coberturas.add(cobertura);
            }
           
        }

        // Contratante do Contrato, Garantia do Contratante do Contrato Grupo do Contratante do Contrato
        Integer contadorContratanteContrato = 1;
        Integer contadorGrupoContrato = 1;
        Integer contadorSeguradoContrato = 1;

        for(ContratanteContrato__c contratante : lstContraCon){
           
            EndossoOrcamentoVIResponse.ContratantesPrecificacaoTO contratanteContrato = new EndossoOrcamentoVIResponse.ContratantesPrecificacaoTO();
            contratanteContrato.premio = new EndossoOrcamentoVIResponse.PremioTO();
            //contratanteContrato.taxa = new EndossoOrcamentoVIResponse.TaxaTO();
            contratanteContrato.numero = contadorContratanteContrato;
            contratanteContrato.iof = contrato.ValorIOF__c;
            contadorContratanteContrato++;
            //contratanteContrato.premio.integral = contratante.PremioIntegral__c; //PLV-5351 INICIO/FIM //PLV-5384 INICIO/FIM FIX-01
            contratanteContrato.premio.comercial = contratante.PremioComercial__c;
            contratanteContrato.premio.puro = contratante.PremioPuro__c;
            contratanteContrato.premio.total = (req.orcamento.tipoSeguro == 'CAN' ? (contratante.PremioIntegral__c == null ? contratante.PremioTotal__c : contratante.PremioIntegral__c) : contratante.PremioTotal__c); //PLV-5384 INICIO/FIM FIX-01
            contratanteContrato.premio.premioPago = this.valorTotalpago; //PLV-4893 - INÍCIO/FIM

            //contratanteContrato.taxa.total = contratante.TaxaComercial__c;
            //contratanteContrato.taxa.pura = contratante.TaxaPura__c;
            //contratanteContrato.taxa.comercial = contratante.TaxaTotal__c;
            EndossoOrcamentoVIResponse.DescontoAgravoTO objDescontoAgravoContratanteContrato = new EndossoOrcamentoVIResponse.DescontoAgravoTO();
            List<EndossoOrcamentoVIResponse.DescontoAgravoTO> lDescontoAgravoContratanteContrato = new List<EndossoOrcamentoVIResponse.DescontoAgravoTO>();
            objDescontoAgravoContratanteContrato.monetario = contratante.DescontoAgravoMonetarioFormaPagto__c;
            objDescontoAgravoContratanteContrato.percentual = contratante.DescontoAgravoPercentualFormaPagto__c;
            objDescontoAgravoContratanteContrato.tipo = (contratante.TipoDescontoAgravo__c != null) ? contratante.TipoDescontoAgravo__c : 'FPG';
            lDescontoAgravoContratanteContrato.add(objDescontoAgravoContratanteContrato);
            contratanteContrato.descontoAgravo = lDescontoAgravoContratanteContrato;

            if(mapGarantiaContratanteContrato.get(contratante.Id) != null){
                if(contratanteContrato.coberturas == null){
                    contratanteContrato.coberturas = new List<EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO>();
                }
                // GarantiaContratanteContrato__c garantia = mapGarantiaContratanteContrato.get(contratante.Id);
                for(GarantiaContratanteContrato__c garantia : mapGarantiaContratanteContrato.get(contratante.Id)){
                    if ((garantia.Capital__c != null && garantia.Capital__c > 0) || 
                        (garantia.Capital__c != null && garantia.Capital__c == 0 && 
                         garantia.PremioTotal__c!=null && garantia.PremioTotal__c > 0)) { //II-10-FIX01 INICIO-FIM  //PLV-4695-FIX3-INICIO/FIM
                        EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO coberturaContrato = new EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO();
                        coberturaContrato.premio = new EndossoOrcamentoVIResponse.PremioTO();
                        //coberturaContrato.taxa = new EndossoOrcamentoVIResponse.TaxaTO();
                        coberturaContrato.sigla = garantia.Garantia__r.Sigla__c;
                        coberturaContrato.iof = 0;
                        //coberturaContrato.premio.integral = garantia.PremioIntegral__c; //PLV-5351 INICIO/FIM //PLV-5384 INICIO/FIM FIX-01
                        coberturaContrato.premio.comercial = garantia.PremioComercial__c;
                        coberturaContrato.premio.puro = garantia.PremioPuro__c;
                        coberturaContrato.premio.total = (req.orcamento.tipoSeguro == 'CAN' ? (garantia.PremioIntegral__c == null ? garantia.PremioTotal__c : garantia.PremioIntegral__c) : garantia.PremioTotal__c); //PLV-5384 INICIO/FIM FIX-01
                        coberturaContrato.premio.premioPago = (this.valorTotalpago > 0) ? garantia.PremioTotal__c : 0; //PLV-5708 INICIO/FIM FIX-04
                        //coberturaContrato.taxa.total = garantia.TaxaComercial__c;
                        //coberturaContrato.taxa.pura = garantia.TaxaPura__c;
                        //coberturaContrato.taxa.comercial = garantia.TaxaTotal__c;

                        EndossoOrcamentoVIResponse.DescontoAgravoTO objDescontoAgravoCoberturaContrato = new EndossoOrcamentoVIResponse.DescontoAgravoTO();
                        List<EndossoOrcamentoVIResponse.DescontoAgravoTO> lDescontoAgravoCoberturaContrato = new List<EndossoOrcamentoVIResponse.DescontoAgravoTO>();
                        objDescontoAgravoCoberturaContrato.monetario = garantia.DescontoAgravoMonetarioFormaPagto__c;
                        objDescontoAgravoCoberturaContrato.percentual = garantia.DescontoAgravoPercentualFormaPagto__c;
                        objDescontoAgravoCoberturaContrato.tipo = (garantia.TipoDescontoAgravo__c != null) ? garantia.TipoDescontoAgravo__c : 'FPG';
                        lDescontoAgravoCoberturaContrato.add(objDescontoAgravoCoberturaContrato);
                        coberturaContrato.descontoAgravo = lDescontoAgravoCoberturaContrato;

                        contratanteContrato.coberturas.add(coberturaContrato);
                    }
                }
                
                
            }
            
            if(mapGrupoContrato.get(contratante.Id) != null){
                if(contratanteContrato.grupos == null){
                    contratanteContrato.grupos = new List<EndossoOrcamentoVIResponse.GruposPrecificacaoTO>();
                }
                // GrupoContrato__c grupo = mapGrupoContrato.get(contratante.Id);
                for(GrupoContrato__c grupo : mapGrupoContrato.get(contratante.Id)){
                    EndossoOrcamentoVIResponse.GruposPrecificacaoTO grupoContrato = new EndossoOrcamentoVIResponse.GruposPrecificacaoTO();
                    grupoContrato.premio = new EndossoOrcamentoVIResponse.PremioTO();
                    //grupoContrato.taxa = new EndossoOrcamentoVIResponse.TaxaTO();
                    grupoContrato.iof = 0.0; 
                    grupoContrato.numero = contadorGrupoContrato;
                    contadorGrupoContrato++;
                    //grupoContrato.premio.integral = grupo.PremioIntegral__c; //PLV-5384 INICIO/FIM FIX-01
                    grupoContrato.premio.comercial = grupo.PremioComercial__c;
                    grupoContrato.premio.puro = grupo.PremioPuro__c;
                    grupoContrato.premio.total = (req.orcamento.tipoSeguro == 'CAN' ? (grupo.PremioIntegral__c == null ? grupo.PremioTotal__c : grupo.PremioIntegral__c) : grupo.PremioTotal__c); //PLV-5384 INICIO/FIM FIX-01
                    grupoContrato.premio.premioPago = this.valorTotalpago; //PLV-4893 - INÍCIO/FIM
                    
                    EndossoOrcamentoVIResponse.DescontoAgravoTO objDescontoAgravoGrupo = new EndossoOrcamentoVIResponse.DescontoAgravoTO();
                    List<EndossoOrcamentoVIResponse.DescontoAgravoTO> lDescontoAgravoGrupo = new List<EndossoOrcamentoVIResponse.DescontoAgravoTO>();
                    objDescontoAgravoGrupo.monetario = contratante.DescontoAgravoMonetarioFormaPagto__c;
                    objDescontoAgravoGrupo.percentual = contratante.DescontoAgravoPercentualFormaPagto__c;
                    objDescontoAgravoGrupo.tipo = (contratante.TipoDescontoAgravo__c != null) ? contratante.TipoDescontoAgravo__c : 'FPG';
                    lDescontoAgravoGrupo.add(objDescontoAgravoGrupo);
                    grupoContrato.descontoAgravo = lDescontoAgravoGrupo;
                    //grupoContrato.taxa.total = grupo.TaxaComercial__c;
                    //grupoContrato.taxa.pura = grupo.TaxaPura__c;
                    //grupoContrato.taxa.comercial = grupo.TaxaTotal__c;
                    
                    // Coberturas
                    if(mapGarantiaGrupoContrato.get(grupo.Id) != null){
                        if(grupoContrato.coberturas == null){
                            grupoContrato.coberturas = new List<EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO>();
                        }
                        // GarantiaGrupoContrato__c garantiaGrupo = mapGarantiaGrupoContrato.get(grupo.Id);
                        for(GarantiaGrupoContrato__c garantiaGrupo : mapGarantiaGrupoContrato.get(grupo.Id)){
                            system.debug('garantiaGrupo.Capital__c >< ' + garantiaGrupo.Capital__c);
                            system.debug('garantiaGrupo.PremioTotal__c >< ' + garantiaGrupo.PremioTotal__c);
                            if ((garantiaGrupo.Capital__c != null && garantiaGrupo.Capital__c > 0) ||
                                (garantiaGrupo.Capital__c != null && garantiaGrupo.Capital__c == 0 && 
                                 garantiaGrupo.PremioTotal__c!=null && garantiaGrupo.PremioTotal__c > 0)) { //II-10-FIX01 INICIO-FIM //PLV-4695-FIX3-INICIO/FIM
                                system.debug('Entrou if 830');
                                EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO garantiaGrupoContrato = new EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO();
                                garantiaGrupoContrato.premio = new EndossoOrcamentoVIResponse.PremioTO();
                                //garantiaGrupoContrato.taxa = new EndossoOrcamentoVIResponse.TaxaTO();
                                garantiaGrupoContrato.sigla = garantiaGrupo.Garantia__r.Sigla__c; 
                                garantiaGrupoContrato.iof = 0;
                                //garantiaGrupoContrato.premio.integral = garantiaGrupo.PremioIntegral__c; //PLV-5384 INICIO/FIM FIX-01
                                garantiaGrupoContrato.premio.comercial = garantiaGrupo.PremioComercial__c;
                                garantiaGrupoContrato.premio.puro = garantiaGrupo.PremioPuro__c;
                                garantiaGrupoContrato.premio.total = (req.orcamento.tipoSeguro == 'CAN' ? (garantiaGrupo.PremioIntegral__c == null ? garantiaGrupo.PremioTotal__c : garantiaGrupo.PremioIntegral__c) : garantiaGrupo.PremioTotal__c); //PLV-5384 INICIO/FIM FIX-01
                                garantiaGrupoContrato.premio.premioPago = (this.valorTotalpago > 0) ? garantiaGrupo.PremioTotal__c : 0; //PLV-5708 INICIO/FIM FIX-04
                                //garantiaGrupoContrato.taxa.total = garantiaGrupo.TaxaComercial__c;
                                //garantiaGrupoContrato.taxa.pura = garantiaGrupo.TaxaPura__c;
                                //garantiaGrupoContrato.taxa.comercial = garantiaGrupo.TaxaTotal__c; 
                                
                                EndossoOrcamentoVIResponse.DescontoAgravoTO objDescontoAgravoGrupoCobertura = new EndossoOrcamentoVIResponse.DescontoAgravoTO();
                                List<EndossoOrcamentoVIResponse.DescontoAgravoTO> lDescontoAgravoGrupoCobertura = new List<EndossoOrcamentoVIResponse.DescontoAgravoTO>();
                                objDescontoAgravoGrupoCobertura.monetario = garantiaGrupo.DescontoAgravoMonetarioFormaPagto__c;
                                objDescontoAgravoGrupoCobertura.percentual = garantiaGrupo.DescontoAgravoPercentualFormaPagto__c;
                                objDescontoAgravoGrupoCobertura.tipo = (garantiaGrupo.TipoDescontoAgravo__c != null) ? garantiaGrupo.TipoDescontoAgravo__c : 'FPG';
                                lDescontoAgravoGrupoCobertura.add(objDescontoAgravoGrupoCobertura);
                                garantiaGrupoContrato.descontoAgravo = lDescontoAgravoGrupoCobertura;
                                
                                grupoContrato.coberturas.add(garantiaGrupoContrato);
                            }
                        }
                        
                    }
                    // Segurados
                    if(mapSeguradoContrato.get(grupo.Id) != null){
                        if(grupoContrato.segurados == null){
                            grupoContrato.segurados = new List<EndossoOrcamentoVIResponse.SeguradosPrecificacaoTO>();
                        }
                        // SeguradoContrato__c seguradoContrato = mapSeguradoContrato.get(grupo.Id);
                        for(SeguradoContrato__c seguradoContrato : mapSeguradoContrato.get(grupo.Id)){
                            EndossoOrcamentoVIResponse.SeguradosPrecificacaoTO seguradoDoContrato = new EndossoOrcamentoVIResponse.SeguradosPrecificacaoTO();
                            seguradoDoContrato.numero = contadorSeguradoContrato;
                            contadorSeguradoContrato++;
                            seguradoDoContrato.iof = contrato.ValorIOF__c;
                            seguradoDoContrato.premio = new EndossoOrcamentoVIResponse.PremioTO();
                            //seguradoDoContrato.taxa = new EndossoOrcamentoVIResponse.TaxaTO();
                            System.debug('seguradoContrato Danilo ' + seguradoContrato); //PLV-5351 INICIO/FIM
                            seguradoDoContrato.premio.comercial = seguradoContrato.PremioComercial__c;
                            seguradoDoContrato.premio.puro = seguradoContrato.PremioPuro__c;
                            seguradoDoContrato.premio.total = (req.orcamento.tipoSeguro == 'CAN' ? (seguradoContrato.PremioIntegral__c == null ? seguradoContrato.PremioTotal__c : seguradoContrato.PremioIntegral__c) : seguradoContrato.PremioTotal__c); //PLV-5384 INICIO/FIM FIX-01
                            //seguradoDoContrato.premio.integral = seguradoContrato.PremioIntegral__c; //PLV-5351 INÍCIO/FIM //PLV-5384 INICIO/FIM FIX-01
                            seguradoDoContrato.premio.premioPago = this.valorTotalpago; //PLV-4893 - INÍCIO/FIM
                            //seguradoDoContrato.taxa.total = seguradoContrato.TaxaComercial__c;
                            //seguradoDoContrato.taxa.pura = seguradoContrato.TaxaPura__c;
                            //seguradoDoContrato.taxa.comercial = seguradoContrato.TaxaTotal__c;
                            
                            EndossoOrcamentoVIResponse.DescontoAgravoTO objDescontoAgravoGpsegurado = new EndossoOrcamentoVIResponse.DescontoAgravoTO();
                            List<EndossoOrcamentoVIResponse.DescontoAgravoTO> lDescontoAgravoGrupoSegurado = new List<EndossoOrcamentoVIResponse.DescontoAgravoTO>();
                            objDescontoAgravoGpsegurado.monetario = seguradoContrato.DescontoAgravoMonetarioFormaPagto__c;
                            objDescontoAgravoGpsegurado.percentual = seguradoContrato.DescontoAgravoPercentualFormaPagto__c;
                            objDescontoAgravoGpsegurado.tipo = (seguradoContrato.TipoDescontoAgravo__c != null) ? seguradoContrato.TipoDescontoAgravo__c : 'FPG';
                            lDescontoAgravoGrupoSegurado.add(objDescontoAgravoGpsegurado);
                            seguradoDoContrato.descontoAgravo = lDescontoAgravoGrupoSegurado;

                            if(mapGarantiaSeguradoContrato.get(seguradoContrato.Id) != null){
                                if(seguradoDoContrato.coberturas == null){
                                    seguradoDoContrato.coberturas = new List<EndossoOrcamentoVIResponse.CoberturasPrecificacaoGrupoTO>();
                                }
                                // GarantiaSeguradoContrato__c GarantiaSeguradoContrato = mapGarantiaSeguradoContrato.get(seguradoContrato.Id);
                                for(GarantiaSeguradoContrato__c GarantiaSeguradoContrato : mapGarantiaSeguradoContrato.get(seguradoContrato.Id)){
                                    //PLV-4695-FIX3-INICIO
                                    if ((GarantiaSeguradoContrato.Capital__c != null && GarantiaSeguradoContrato.Capital__c > 0) || 
                                        (GarantiaSeguradoContrato.Capital__c != null && GarantiaSeguradoContrato.Capital__c == 0 && 
                                        GarantiaSeguradoContrato.PremioTotal__c!=null && GarantiaSeguradoContrato.PremioTotal__c > 0)) { //II-10-FIX01 INICIO-FIM
                                        EndossoOrcamentoVIResponse.CoberturasPrecificacaoGrupoTO gtSeguradoContrato = new EndossoOrcamentoVIResponse.CoberturasPrecificacaoGrupoTO();
                                        gtSeguradoContrato.premio = new EndossoOrcamentoVIResponse.PremioTO();
                                        gtSeguradoContrato.taxa = new EndossoOrcamentoVIResponse.TaxaTO();
                                        gtSeguradoContrato.sigla = GarantiaSeguradoContrato.Garantia__r.Sigla__c;
                                        System.debug('GarantiaSeguradoContrato.IOF__c> ' + GarantiaSeguradoContrato.IOF__c);
                                        gtSeguradoContrato.iof = GarantiaSeguradoContrato.IOF__c != null ? double.valueOf(GarantiaSeguradoContrato.IOF__c) : 0; //PLV-4961 - INÍCIO/FIM
                                        gtSeguradoContrato.capitalContratacao = 0.0;
                                        gtSeguradoContrato.premio.comercial = GarantiaSeguradoContrato.PremioComercial__c;
                                        gtSeguradoContrato.premio.puro = GarantiaSeguradoContrato.PremioPuro__c;
                                        gtSeguradoContrato.premio.total = (req.orcamento.tipoSeguro == 'CAN' ? (GarantiaSeguradoContrato.PremioIntegral__c == null || GarantiaSeguradoContrato.PremioIntegral__c == 0 ? ((this.valorTotalpago > 0) ? GarantiaSeguradoContrato.PremioTotal__c: 0) : GarantiaSeguradoContrato.PremioIntegral__c) : ((this.valorTotalpago > 0) ? GarantiaSeguradoContrato.PremioTotal__c : 0));  //PLV-5708 INICIO/FIM FIX-04 //PLV-5384 INICIO/FIM FIX-01 //RVI-316 INICIO/FIM
                                        //gtSeguradoContrato.premio.integral = GarantiaSeguradoContrato.PremioIntegral__c; //PLV-5147 - FIX02 - INICIO //PLV-5384 INICIO/FIM FIX-01
                                        
                                        if (req.orcamento.tipoSeguro != 'CAN') {
                                            gtSeguradoContrato.premio.premioPago = this.valorTotalpago; //PLV-4893 - INÍCIO/FIM 
                                        }
                                        //PLV-5147 - FIX02 - FIM
                                        gtSeguradoContrato.taxa.total = GarantiaSeguradoContrato.TaxaComercial__c;
                                        gtSeguradoContrato.taxa.pura = GarantiaSeguradoContrato.TaxaPura__c;
                                        gtSeguradoContrato.taxa.comercial = GarantiaSeguradoContrato.TaxaTotal__c;
                                        
    
                                        EndossoOrcamentoVIResponse.DescontoAgravoTO objDescontoAgravoSeguradogarantia = new EndossoOrcamentoVIResponse.DescontoAgravoTO();
                                        List<EndossoOrcamentoVIResponse.DescontoAgravoTO> lDescontoAgravoGrupoSeguradoGarantia = new List<EndossoOrcamentoVIResponse.DescontoAgravoTO>();
                                        objDescontoAgravoSeguradogarantia.monetario = GarantiaSeguradoContrato.DescontoAgravoMonetarioFormaPagto__c;
                                        objDescontoAgravoSeguradogarantia.percentual = GarantiaSeguradoContrato.DescontoAgravoPercentualFormaPagto__c;
                                        objDescontoAgravoSeguradogarantia.tipo = (GarantiaSeguradoContrato.TipoDescontoAgravo__c != null) ? GarantiaSeguradoContrato.TipoDescontoAgravo__c : 'FPG';
                                        lDescontoAgravoGrupoSeguradoGarantia.add(objDescontoAgravoSeguradogarantia);
                                        gtSeguradoContrato.descontoAgravo = lDescontoAgravoGrupoSeguradoGarantia;
                                        seguradoDoContrato.coberturas.add(gtSeguradoContrato);
                                        System.debug('gtSeguradoContrato Danilo: '+ gtSeguradoContrato);
                                    }
                                    //PLV-4695-FIX3-FIM
                              


                                }
                            }
                            grupoContrato.segurados.add(seguradoDoContrato);
                        }
                    }
                    contratanteContrato.grupos.add(grupoContrato);
                }
            }
            contratoOriginal.precificacao.contratantes = new List<EndossoOrcamentoVIResponse.ContratantesPrecificacaoTO>();
            contratoOriginal.precificacao.contratantes.add(contratanteContrato);   
        }
        String jsonignorenullvalues = JSON.serialize(contratoOriginal,true);
        contratoOriginal = (EndossoOrcamentoVIResponse.ContratoTO) JSON.deserialize(jsonignorenullvalues, EndossoOrcamentoVIResponse.ContratoTO.class);
        System.debug('Giordano contratoOriginal - Cancelamento GERAL: '+ JSON.serialize(contratoOriginal,true));
        return contratoOriginal;
    }

    // TKCL-601 INICIO
    private EndossoOrcamentoVIResponse.ContratoGenericoTO montaContratoOriginalAPTLMKT() {
        System.debug('contratoAPTLMKTESTE ><' + contrato);
        EndossoOrcamentoVIResponse.ContratoTO_APTLMK contratoOriginalAP = new EndossoOrcamentoVIResponse.ContratoTO_APTLMK();
        contratoOriginalAP.tarifa = contrato.Tarifa__c;
        contratoOriginalAP.dataCalculo = contrato.Proposta__r.DataCalculo__c;
        contratoOriginalAP.vigenciaInicial = String.valueOf(contrato.StartDate);
        contratoOriginalAP.vigenciaFinal = String.valueOf(contrato.VigenciaFinal__c);
        contratoOriginalAP.numeroOrcamento = Test.isRunningTest() ? 00005555 : Integer.valueOf(contrato.Oportunidade__r.Numero__c);
        contratoOriginalAP.tipoSeguro = contrato.Tipo__c;
        contratoOriginalAP.qtdDiasVigencia = contrato.StartDate.daysBetween(contrato.VigenciaFinal__c) + 1;

        contratoOriginalAP.dadosPessoaFisica = new EndossoOrcamentoVIResponse.DadosPessoaTO();
        contratoOriginalAP.dadosPessoaFisica.sexo = (lstSeguradoCon != null && lstSeguradoCon.size() > 0) ? handleNullString(lstSeguradoCon[0].Conta__r.Sexo__c) : '';
        contratoOriginalAP.dadosPessoaFisica.dataNascimento = lstSeguradoCon[0].Conta__r.PersonBirthdate;

        contratoOriginalAP.precificacao = new EndossoOrcamentoVIResponse.PrecificacaoTO();
        contratoOriginalAP.precificacao.iof = contrato.ValorIOF__c;
        contratoOriginalAP.precificacao.juros = 0;
        contratoOriginalAP.precificacao.encargos = 0;
        contratoOriginalAP.precificacao.custoDeApolice = 0;

        contratoOriginalAP.precificacao.premio = new EndossoOrcamentoVIResponse.PremioTO();
        contratoOriginalAP.precificacao.premio.comercial = contrato.PremioComercial__c;
        contratoOriginalAP.precificacao.premio.total = (req.orcamento.tipoSeguro == 'CAN' ? (contrato.PremioIntegral__c == null ? contrato.PremioTotal__c : contrato.PremioIntegral__c) : contrato.PremioTotal__c);
        contratoOriginalAP.precificacao.premio.premioPago = this.valorTotalpago; 
        contratoOriginalAP.precificacao.premio.puro = contrato.PremioPuro__c;

        lDescontoAgravo = new List<EndossoOrcamentoVIResponse.DescontoAgravoTO>(); 

        EndossoOrcamentoVIResponse.DescontoAgravoTO objDescontoAgravo = new EndossoOrcamentoVIResponse.DescontoAgravoTO();
        objDescontoAgravo.monetario = contrato.DescontoAgravoMonetarioFormaPagto__c;
        objDescontoAgravo.percentual = contrato.DescontoAgravoPercentualFormaPagto__c;
        objDescontoAgravo.tipo = (contrato.TipoDescontoAgravo__c != null) ? contrato.TipoDescontoAgravo__c :'FPG';
        lDescontoAgravo.add(objDescontoAgravo);
        contratoOriginalAP.precificacao.descontoAgravo = lDescontoAgravo;

        contratoOriginalAP.precificacao.coberturas = new List<EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO>();
        contratoOriginalAP.coberturas = new List<EndossoOrcamentoVIResponse.CoberturaTO>();
        contratoOriginalAP.retornosCalculoOriginal = new List<EndossoOrcamentoVIResponse.RetornosCalculoOriginalTO>();
        EndossoOrcamentoVIResponse.RetornosCalculoOriginalTO retornoCalculoOriginal = new EndossoOrcamentoVIResponse.RetornosCalculoOriginalTO();
        retornoCalculoOriginal.precificacao = new EndossoOrcamentoVIResponse.PrecificacaoTO();
        retornoCalculoOriginal.precificacao.coberturas = new List<EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO>();
      
        for(GarantiaContrato__c garantia : lstGaranCon){
            if ((garantia.Capital__c != null && garantia.Capital__c > 0) || 
                (garantia.Capital__c != null && garantia.Capital__c == 0 && 
                 garantia.PremioTotal__c!=null && garantia.PremioTotal__c > 0)) { //II-10-FIX01 INICIO-FIM 
                EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO coberturaprecificacao = new EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO();
                coberturaprecificacao.sigla = garantia.Garantia__r.Sigla__c;          
                List<EndossoOrcamentoVIResponse.DescontoAgravoTO> lDescontoAgravoCobertura = new List<EndossoOrcamentoVIResponse.DescontoAgravoTO>();
                EndossoOrcamentoVIResponse.DescontoAgravoTO objDescontoAgravoCobertura = new EndossoOrcamentoVIResponse.DescontoAgravoTO();
                objDescontoAgravoCobertura.monetario = garantia.DescontoAgravoMonetarioFormaPagto__c;
                objDescontoAgravoCobertura.percentual = garantia.DescontoAgravoPercentualFormaPagto__c;
                objDescontoAgravoCobertura.tipo = (garantia.TipoDescontoAgravo__c != null) ? garantia.TipoDescontoAgravo__c :'FPG';
                lDescontoAgravoCobertura.add(objDescontoAgravo);
                coberturaprecificacao.descontoAgravo = lDescontoAgravoCobertura;
                
                EndossoOrcamentoVIResponse.CoberturaTO cobertura = new EndossoOrcamentoVIResponse.CoberturaTO();
                cobertura.sigla = garantia.Garantia__r.Sigla__c;
                cobertura.valor = garantia.Capital__c;
                cobertura.unidade = garantia.Tipo_de_limite_de_utilizacao__c;
                cobertura.quantidade = garantia.Limite_de_Uso__c;

                EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO coberturaNoPrecificacao = new EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO();
                coberturaNoPrecificacao.sigla = garantia.Garantia__r.Sigla__c;
                coberturaNoPrecificacao.descontoAgravo = lDescontoAgravoCobertura;

                EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO coberturaNoRetornosCalculo = new EndossoOrcamentoVIResponse.CoberturasPrecificacaoTO();
                coberturaNoRetornosCalculo.sigla = garantia.Garantia__r.Sigla__c;
                coberturaNoRetornosCalculo.iof = garantia.IOF__c == null? 0.0 : garantia.IOF__c;
                coberturaNoRetornosCalculo.premio = new EndossoOrcamentoVIResponse.PremioTO();
                coberturaNoRetornosCalculo.premio.puro = garantia.PremioPuro__c == null ? 0.0 : garantia.PremioPuro__c;
                coberturaNoRetornosCalculo.premio.comercial = garantia.PremioComercial__c == null ? 0.0 : garantia.PremioComercial__c;
                coberturaNoRetornosCalculo.premio.puroCarregado = garantia.PremioComercial__c == null ? 0.0 : garantia.PremioComercial__c;  
                coberturaNoRetornosCalculo.premio.total = garantia.PremioTotal__c == null ? 0.0 : garantia.PremioTotal__c;
                coberturaNoRetornosCalculo.taxa = new EndossoOrcamentoVIResponse.TaxaTO();
                coberturaNoRetornosCalculo.taxa.comercial = garantia.TaxaComercial__c == null ? 0.0 : garantia.TaxaComercial__c;
                coberturaNoRetornosCalculo.taxa.pura = garantia.TaxaPura__c == null ? 0.0 : garantia.TaxaPura__c;
                coberturaNoRetornosCalculo.taxa.total = garantia.TaxaTotal__c == null ? 0.0 : garantia.TaxaTotal__c;
                coberturaNoRetornosCalculo.descontoAgravo = lDescontoAgravoCobertura;

                contratoOriginalAP.coberturas.add(cobertura);
                contratoOriginalAP.precificacao.coberturas.add(coberturaNoPrecificacao);
                retornoCalculoOriginal.precificacao.coberturas.add(coberturaNoRetornosCalculo);
            }
        }

        List<EndossoOrcamentoVIResponse.RemuneracoesTO> lRemuneracoes = new List<EndossoOrcamentoVIResponse.RemuneracoesTO>();

        if(lremuneracaoContrato.size() > 0){
            for(RemuneracaoContrato__c rem : lremuneracaoContrato){
                EndossoOrcamentoVIResponse.RemuneracoesTO noRemuneracoes = new EndossoOrcamentoVIResponse.RemuneracoesTO();
                noRemuneracoes.percentual = rem.Percentual__c;
                noRemuneracoes.tipoRemuneracao = rem.TipoRemuneracao__r.Codigo__c;
                lRemuneracoes.add(noRemuneracoes);
            }      
        }
        contratoOriginalAP.remuneracoes = lRemuneracoes;

        //II-10 INICIO FIX02
        contratoOriginalAP.versoesCalculos = new List<EndossoOrcamentoVIResponse.VersoesCalculoTO>();
        EndossoOrcamentoVIResponse.VersoesCalculoTO versoesObj = new EndossoOrcamentoVIResponse.VersoesCalculoTO();
        versoesObj.tipo = (contrato.TipoDescontoAgravo__c != null) ? contrato.TipoDescontoAgravo__c :'FPG';
        versoesObj.opcao = 1;
        versoesObj.descontoAgravo = contrato.DescontoAgravoPercentualFormaPagto__c;
        contratoOriginalAP.versoesCalculos.add(versoesObj);
        //contratoOriginalAP.versoesCalculos.add(new EndossoOrcamentoVIResponse.VersoesCalculoTO());
        //II-10 FIM FIX02

        retornoCalculoOriginal.tarifa = contrato.Tarifa__c; 
        retornoCalculoOriginal.dlls = new List<String>();
        retornoCalculoOriginal.dlls.add(contrato.DLL__c);

        retornoCalculoOriginal.precificacao.premio = new EndossoOrcamentoVIResponse.PremioTO();
        retornoCalculoOriginal.precificacao.premio.puro = contrato.PremioPuro__c == null ? 0.0 : contrato.PremioPuro__c;
        retornoCalculoOriginal.precificacao.premio.comercial = contrato.PremioComercial__c == null ? 0.0 : contrato.PremioComercial__c;
        retornoCalculoOriginal.precificacao.premio.puroCarregado = contrato.PremioComercial__c == null ? 0.0 : contrato.PremioComercial__c;  
        retornoCalculoOriginal.precificacao.premio.total = contrato.PremioTotal__c == null ? 0.0 : contrato.PremioTotal__c;

        retornoCalculoOriginal.precificacao.premio.descontoAgravo = lDescontoAgravo;

        contratoOriginalAP.retornosCalculoOriginal.add(retornoCalculoOriginal);

        String jsonignorenullvalues = JSON.serialize(contratoOriginalAP,true);
        contratoOriginalAP = (EndossoOrcamentoVIResponse.ContratoTO_APTLMK) JSON.deserialize(jsonignorenullvalues, EndossoOrcamentoVIResponse.ContratoTO_APTLMK.class);
        System.debug('Giordano contratoOriginal - Cancelamento APTLMKT: '+ JSON.serialize(contratoOriginalAP,true));

        return contratoOriginalAP;
    }
    // TKCL-601 FIM

    //PLV-4695 -FIX2 - INICIO
     //retirado metodo buscavalorPago
    //PLV-4695-FIX2 - FIM

    //PLV-5147 - FIX02 - INICIO
    //PLV-5384 INICIO
    private Decimal obterValorTotalPago(String sempresa, String ssucursal, String sramo, String sapolice, String sDataCalculo, String sDatavigenciaInicial, String sEndosso) {

        List<public_parcelacontrato__x> parcs 
            = [SELECT  idexterno__c, valorpago__c, endosso__c
                FROM public_parcelacontrato__x
                WHERE apolice__c =:sapolice
                    AND endosso__c =:sEndosso
                    AND ramo__c =:sramo
                    AND sucursal__c =:ssucursal
                    AND empresa__c =:sempresa
                    AND status__c =:STATUS_PARCELA_PAGA ];

        Double auxValorTotPago = 0;

        if(sDataCalculo == sDatavigenciaInicial){
            for (public_parcelacontrato__x parc : parcs) {
                auxValorTotPago = auxValorTotPago + parc.valorpago__c;
            }
            system.debug('sDataCalculo == sDatavigenciaInicial -'+  auxValorTotPago);
        }else{
            Integer parcslenght = parcs.size();
            for (public_parcelacontrato__x parc : parcs){
                if(parc.endosso__c == String.valueOf(parcslenght) && parc.valorpago__c != null){
                    auxValorTotPago = parc.valorpago__c;
                }else{
                    parcslenght = parcslenght - 1;
                }
            }
        }
        
        return auxValorTotPago;
    }
    //PLV-5384 FIM
    private Double calcularValorPremioTotal(List<GarantiaSeguradoContrato__c> lstGarSegContr) {

        Double valorTotAux = 0;
        for (GarantiaSeguradoContrato__c obj : lstGarSegContr){
            valorTotAux = valorTotAux + obj.PremioTotal__c;
        }
        return valorTotAux;
    }
    //PLV-5147 - FIX02 - FIM

    // TKCL-601 INÍCIO
    private String handleNullString(String strg){
        return strg == null ? '' : strg;
    }
    // TKCL-601 FIM
}