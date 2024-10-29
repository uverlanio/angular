/**
 * @description       : 
 * @author            : giordano.menezes@globant.com
 * @group             : 
 * @last modified on  : 02-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class QuoteDAO
{
    private static final QuoteDAO instancia = new QuoteDAO();    
    private QuoteDAO(){}    
    public static QuoteDAO getInstance(){ return instancia; }

    // PLV-2312 INICIO
    // PLV-2486 INICIO
    // PLV-3362 INICIO - Adicionado novos campos na busca
    public List<Quote> buscarPropostasPorId(Set<Id> setPropostasIds)
    {
        return
        [
                SELECT
                        Id,
                        Name,
                        NumeroProposta__c,
                        NumeroPropostaUnico__c,
                        CartaoCredito__c,
                        ContactId,
                        ContractId,
                        Contract.NumeroApolice__c,
                        DataCriacaoPortal__c,
                        DataEmissao__c,
                        Tarifa__c, // PLV-4666
                        DLL__c, // PLV-4666
                        DataProtocolo__c,
                        DiasAnalise__c,
                        Discount,
                        DataEndosso__c, //PLV-4686 - INÍCIO/FIM
                        // PLV-4488 INICIO
                        Email__c,
                        SiglaTipoEndosso__c,
                        // PLV-4488 FIM
                        Email,
                        //PLV-5022 - INICIO
                        DataInicioPendencia__c, 
                        DataFimPendencia__c, 
                        TotalDiasPausados__c, 
                        DataInicioResseguro__c, 
                        DataFimResseguro__c,
                        Nome_do_contratante__c,
                        NomeSocial__c,  // LECVPV-184 INICIO/FIM
                        CodigoMotivoDevolucao__c, 
                        Account.Cpf__c,
                        IntegrouNaoCLienteBCP__c,
                        Segmento__c,
                        isAPI__c,
                        //PLV-5022 - FIM
                        Empresa__c,
                        CanalDistribuicao__c,
                        GrandTotal,
                        ImprimirCertificadoSeguro__c,
                        InformacaoBancaria__c,
                        IOF__c,
                        IPCA__c,
                        Modalidade__c,
                        OpportunityId,
                        Phone,
                        PremioParcela__c,
                        QuantidadeParcelas__c,
                        RecordTypeId,
                        Reenquadramento__c,
                        ResponsavelFinanceiro__c,
                        TipoCusteio__c,
                        TipoCusteioEstipulante__c,
                        TipoCusteioSegurado__c,
                        TecnicoResponsavel__c,
                        AccountId,
                        MeioComercializacao__c,
                        Produto__c,
                        Status,
                        Origem__c,
                        DataCalculo__c,
                        TipoVigencia__c,
                        VigenciaInicial__c,
                        VigenciaFinal__c,
                        VigenciaFinalAlterada__c, //PLV-4684 INICIO/FIM
                        Tipo__c,
                        ValorPremio__c,
                        TipoEvento__c,
                        InformacoesEvento__c,
                        TipoViagem__c,
                        RamoSeguro__c,
                        CodigoCorretor__c,
                        Description,
                        FormaPagamento__c,
                        IdContratoParceiro__c,
                        IdContratanteParceiro__c,
                        Parceiro__c,
                        Massificados__c,
                        AdditionalAddress,
                        AdditionalName,
                        BillingAddress,
                        BillingName,
                        CanalDistribuicao__r.Sigla__c,
                        CanalDistribuicao__r.Name,
                        Produto__r.ProductCode,
                        Produto__r.Description,
                        Produto__r.NumeroSusep__c,
                        Produto__r.Empresa__r.CodigoEmpresa__c,
                        Produto__r.Empresa__r.Name,
                        Produto__r.Empresa__c,
                        Produto__r.Segmento__c,//4544 - Inicio/Fim
                        Produto__r.Name,
                        HistoricoStatus__c,
                        CodigoCorretor__r.Name,
                        CodigoCorretor__r.SucursalVinculo__c,
                        CodigoCorretor__r.CodigoSucursalVinculo__c, //PLV-4515 - INICIO/FIM
                        Empresa__r.CodigoEmpresa__c,
                        RamoSeguro__r.Codigo__c,
                        RamoSeguro__r.Name,
                        Empresa__r.Sucursal__c,
                        Account.Idade__c,
                        Account.NomeSocial__c, // LECVPV-188 INICIO/FIM
                        Account.PersonEmail, //PLV-4587 FIX 2 INICIO/FIM
                        RecordType.DeveloperName,
                        Empresa__r.Name,
                        Modalidade__r.Codigo__c,
                        Modalidade__r.Descricao__c,
                        Opportunity.Numero__c,
                        Opportunity.NumeroOferta__c,
                        CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c,
                        Opportunity.NumeroPortal__c,
                        Opportunity.CanalDistribuicao__c,
                        Opportunity.CanalDistribuicao__r.Sigla__c,
                        Opportunity.HaControlePublico__c,
                        Opportunity.EventoLocalFechadoDelimitado__c,
                        Opportunity.ViagemAventura__c,
                        Opportunity.UtilizaMoto__c,
                        Opportunity.IncluiPaisEuropeu__c,
                        Opportunity.PossuiTrackageBagagem__c,
                        Opportunity.QuantidadePassageirosNaoIdosos__c,
                        Opportunity.QuantidadePassageirosIdosos__c,
                        Opportunity.PaisesDestino__c,
                        Opportunity.CupomDesconto__c,   // AV-664 INICIO/FIM 
                        CupomDesconto__c,               // AV-664 INICIO/FIM 
            			//PLV-2146 - INÍCIO
            			Opportunity.DescontoAgravoPercentualFormaPagto__c,
                        Opportunity.DescontoAgravoMonetarioFormaPagto__c,
                        Opportunity.DescontoAgravoPercentualParcelamento__c,
                        Opportunity.DescontoAgravoMonetarioParcelamento__c,
            			//PLV-2146 - FIM
                        Opportunity.Produto__r.LimiteTotalCarregamento__c,//PLV-4851
                        Produto__r.LimiteTotalCarregamento__c,//PLV-4851
                        Payload__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        TipoEndosso__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,
                        NumeroRecalculosEfetivos__c, //PLV-4544 - Inicio/Fim
                        EntradaNegocio__c,
                        QuantidadePassageiros070Anos__c,
                        ViagemAventura__c,
                        UtilizaMoto__c,
                        PaisesDestino__c,
                        VidasEntre7190Anos__c,
                        IncluiPaisEuropeu__c,
                        //PLV-2146 - INÍCIO
                        DescontoAgravoPercentualFormaPagto__c,
                        DescontoAgravoMonetarioFormaPagto__c,
                        DescontoAgravoPercentualParcelamento__c,
                        DescontoAgravoMonetarioParcelamento__c,
                        //PLV-2146 - FIM
                        //PLV-3888 - fix1 - Inicio - Incluir campo Chave_de_Agrupamento__c
                        Chave_de_Agrupamento__c,
                        //PLV-3888
                        //PLV-4441 - INICIO
                        FormaReceberApolice__c,
                        TermoGuarda__c,
                        TermoResponsabilidade__c,
                        AssinaturaEletronica__c,
                        PorQuantoTempoQuerGarantirRenda__c,
                        DependentesFinanceiros__c,
                        TipoContrato__c,
                        //PLV-4441 - FIM
                        ScoreFraude__c, // PLV-4416 - INICIO - FIM 
                        ScoreSerasa__c, //PLV - 4388 - INICIO/FIM - Gustavo Pereira SYS4b

                        //PLV-4694 - INICIO
                        TipoDescontoAgravo__c,
                        Produto__r.PremioMinimo__c,
                        Opcao__c,
                        //PLV-4694 - FIM
                        Senha__c, // MGRC-505 INICIO-FIM
                        DistributionPublicUrl__c, // MGRC-505 INICIO-FIM
                        (
                        SELECT
                                Id,
                                Name,
                                Empresa__c,
                                Sucursal__c,
                                RamoSeguro__c,
                                RamoSeguro__r.Id,
                                RamoSeguro__r.Codigo__c,
                                Endosso__c,
                                NumeroApolice__c,
                                Status,
                                Massificados__c
                        FROM
                                Contratos__r
                ),
                (
                        SELECT
                                Id,
                                Garantia__c,
                                //PLV-4851 - INICIO
                                Garantia__r.Name,
                                TipoDescontoAgravo__c,
                                GarantiaProduto__r.PercentualCapitalMaximo__c,
                                GarantiaProduto__r.PercentualCapitalMinimo__c,
                                GarantiaProduto__r.PercentualDescontoMaximo__c,
                                GarantiaProduto__r.PercentualDescontoMinimo__c,
                                GarantiaProduto__r.LimiteCapitalMaximo__c,
                                GarantiaProduto__r.LimiteCapitalMinimo__c,
                                GarantiaProduto__r.PercentualAgravoMaximo__c,
                                GarantiaProduto__r.PercentualAgravoMinimo__c,
                                GarantiaProduto__r.CaracteristicaGarantia__c,
                                GarantiaProduto__r.Obrigatoria__c,
                                //PLV-4851 - FIM
                                Garantia__r.Sigla__c, //PLV-4544 - Inicio/Fim
                                GarantiaProduto__c,
                                LimiteCapital__c ,
                                Proposta__c,
                                TipoCapital__c,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                DataSorteio__c,
                                Capital__c,
                                PremioPuro__c,
                                PremioComercial__c,
                                PremioTotal__c,
                                PremioIntegral__c, //PLV-5351 INICIO/FIM
                                TaxaPura__c,
                                TaxaComercial__c,
                                TaxaTotal__c,
                                DataSolicitacaoCapitalizacao__c,
                                StatusCapitalizacao__c,
                                VersaoTitulo__c,
                                NumeroTitulo__c,
                                LoteCapitalizacao__c,
                                DescontoAgravoPercentualTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                                DescontoAgravoMonetarioFormaPagto__c,//PLV-4701 - Inicio/Fim
                                IOF__c,//PLV-4689 - Inicio/Fim
                                GarantiaProduto__r.OrdemPrioridade__c,
                                FranquiaGarantia__c, // PLV-4598 INICIO/FIM
                                //PLV-3731 - INICIO
                                ValorCotacao__c,
                    			//PLV-3731 - FIM
                                //PLV-4626 - INICIO
                                Tipo_de_limite_de_utilizacao__c,
                                Limite_de_Uso__c,
                                //PLV-4626 - FIM                    
                                CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                                //PLV - 4694 INICIO
                                GarantiaProduto__r.Modalidade__c,
                                franquiaGarantia__r.GarantiaProduto__r.Garantia__r.Sigla__c,
                                franquiaGarantia__r.Franquia__r.CodigoFranquia__c
                                //PLV - 4694 FIM
                        FROM
                                GarantiasProposta__r
                ),
                (
                        SELECT
                                Id,
                                Codigo__c,
                                DataConclusao__c,
                                Descricao__c,
                                // INICIO | PLV-4647-VI-Guilherme Brito
                                MensagemCliente__c,
                                MensagemInterna__c,
                                MensagemRepresentante__c,
                                Procedimento__c,
                                //FIM| PLV-4647-VI-Guilherme Brito */
                                Origem__c,
                                Parecer__c, //PLV-4790 FIX 9
                                Proposta__c,
                                RecordTypeId,
                                Severidade__c,
                                Status__c,
                                Tipo__c,
                                //PLV-5022 - INICIO
                                MomentoAnalise__c, 
                                DataInicioPendencia__c,
                                DataFimPendencia__c,
                                Data_inicio_resseguro__c,
                                Data_fim_resseguro__c,
                                //PLV-5022 - FIM
                                Setor__c, //PLV-5111 - FIX01 - INICIO/FIM
                                Area__c
                                
                        FROM
                                CriticasProposta__r
                        ORDER BY DataInicioPendencia__c ASC//PLV-5022 - INICIO/FIM
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
                FROM
                        Quote
                WHERE
                        Id IN :setPropostasIds
        ];
    }
    // PLV-2486 FIM
    // PLV-2312 FIM
    // PLV-3362 FIM 

    // PLV-2312 INICIO
    public List<Quote> verificarPropostasMassificados(){
        return [
                SELECT
                        Id
                FROM
                        Quote
                WHERE
                        Status = 'Disponível para contratação'
                AND
                        MeioComercializacao__c = 'ARQ'
                AND
                        Massificados__c = true
        ];
    }
    // PLV-2312 FIM

    // PLV-2372 INICIO
    public List<Quote> buscarPropostasCancelamentoPendentesPorContratoOriginal(Set<Id> setContratoId){
        return [
                SELECT
                        Id,
                        Name,
                        Status,
                        Tipo__c,
                        OpportunityId,
                        Opportunity.Id
                FROM
                        Quote
                WHERE
                        ContractId =: setContratoId
                AND
                        Tipo__c = 'Cancelamento'
                AND
                        Status NOT IN ('Contratada', 'Devolvida')
        ];
    }
    // PLV-2372 FIM

    public List<Quote> obterPropostaPorNumero(String name)
    {
        return
        [
                SELECT
                        Id,
                        CanalDistribuicao__c,
                        Name,
                        NumeroProposta__c,
                        CartaoCredito__c,
                        ContactId,
                        ContractId,
                        DataCriacaoPortal__c,
                        DataEmissao__c,
                        DataProtocolo__c,
                        DiasAnalise__c,
                        Discount,
                        Email,
                        Empresa__c,
                        GrandTotal,
                        ImprimirCertificadoSeguro__c,
                        InformacaoBancaria__c,
                        IOF__c,
                        IPCA__c,
                        Modalidade__c,
                        OpportunityId,
                        Phone,
                        PremioParcela__c,
                        PremioInformado__c,
                        QuantidadeParcelas__c,
                        RecordTypeId,
                        Reenquadramento__c,
                        ResponsavelFinanceiro__c,
                        TipoCusteio__c,
                        TipoCusteioEstipulante__c,
                        TipoCusteioSegurado__c,
                        TecnicoResponsavel__c,
                        AccountId,
                        MeioComercializacao__c,
                        Produto__c,
                        Status,
                        Origem__c,
                        DataCalculo__c,
                        TipoVigencia__c,
                        VigenciaInicial__c,
                        VigenciaFinal__c,
                        VigenciaFinalAlterada__c, //PLV-4684 INICIO/FIM
                        Tipo__c,
                        ValorPremio__c,
                        TipoEvento__c,
                        InformacoesEvento__c,
                        TipoViagem__c,
                        RamoSeguro__c,
                        CodigoCorretor__c,
                        Description,
                        FormaPagamento__c,
                        IdContratoParceiro__c,
                        IdContratanteParceiro__c,
                        Parceiro__c,
                        AdditionalAddress,
                        AdditionalName,
                        BillingAddress,
                        BillingName,
                        Account.Idade__c,
                        Produto__r.Id,
                        Produto__r.Name,
                        Produto__r.ProductCode,
                        Produto__r.Description,
                        Produto__r.Empresa__r.CodigoEmpresa__c,
                        Produto__r.NumeroSusep__c,
                        RamoSeguro__r.Codigo__c,
                        RamoSeguro__r.Name,
                        Modalidade__r.Codigo__c,
                        Modalidade__r.Descricao__c,
                        Account.CodigoEmpresa__c,
                        Account.Cnpj__c,
                        Account.Cpf__c,
                        Account.RecordType.DeveloperName,
                        Account.Sexo__c,
                        Account.EstadoCivil__c,
                        ResponsavelFinanceiro__r.Cnpj__c,
                        ResponsavelFinanceiro__r.Cpf__c,
                        ResponsavelFinanceiro__r.RecordType.DeveloperName,
                        ResponsavelFinanceiro__r.Sexo__c,
                        ResponsavelFinanceiro__r.EstadoCivil__c,
                        ResponsavelFinanceiro__r.Name,
                        FormaPagamento__r.Codigo__c,
                        InformacaoBancaria__r.Banco__c,
                        InformacaoBancaria__r.Agencia__c,
                        InformacaoBancaria__r.NumeroConta__c,
            			//PLV-3918-FIX6 - INICIO
            			//PLV-3918-FIX7 - INICIO
                        InformacaoBancaria__r.Digito__c,
                        //PLV-3918-FIX7 - FIM
            			//PLV-3918-FIX6 - FIM
                        Empresa__r.CodigoEmpresa__c,
                        Account.Sucursal__c,
                        Account.CodigoSusepCia__c,
                        Account.NumeroContratoParceiro__c,
                        Account.NumeroContratoPrestador__c,
                        Account.NumeroContratoRespresentante__c,
                        CodigoCorretor__r.Name,
                        Contract.Name,
                        Contract.Endosso__c,
                        Opportunity.StageName,
                        HistoricoStatus__c,
                        Contract.CodigoCorretor__r.CodigoSucursalVinculo__c,
                        Contract.FormaPagamento__r.Codigo__c,
                        Contract.Empresa__c,
                        Contract.Status,
                        Opportunity.PremioPuro__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoMonetarioFormaPagto__c,//PLV-4701 - Inicio/Fim
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        Opportunity.Numero__c,
                (
                        SELECT
                                Id,
                                Name,
                                Endosso__c,
                                NumeroApolice__c
                        FROM
                                Contratos__r
                ),
				//PLV-4464 - INICIO
				Account.Pescod__c,
				//PLV-4464 - FIM
				//PLV 4736 Inicio
				( SELECT					
					Id,					
					Participacao__c,
					Percentual__c,					
					TipoRemuneracao__c
					FROM RemuneracoesProposta__r where TipoRemuneracao__r.name = 'CORRETAGEM' )
				//PLV 4736 Fim
                FROM
                        Quote
                WHERE
                        NumeroProposta__c = :name
        ];
    }

    public List<Quote> obterPropostaPorName(String name)
    {
        return
        [
                SELECT
                        Id,
                        // PLV-4488 FIX
                        Segmento__c, //II-165 FIX02 INICIO/FIM
                        PorQuantoTempoQuerGarantirRenda__c,
                        CanalDistribuicao__c,
                        Name,
                        Lote__c,
                        NumeroProposta__c,
                        CartaoCredito__c,
                        ContactId,
                        ContractId,
                        Contract.Sucursal__c,
                        Contract.CodigoRamo__c,
                        Contract.NumeroApolice__c,
                        DataCriacaoPortal__c,
                        DataEmissao__c,
                        DataProtocolo__c,
                        DiasAnalise__c,
                        Discount,
                       CodigoMotivoDevolucao__c, //II-48 FIX03 INICIO-FIM
                        DataLimitePagamento__c,  // VIAG-141 INICIO-FIM
                        Email,
                        Empresa__c,
                        GrandTotal,
                        ImprimirCertificadoSeguro__c,
                        InformacaoBancaria__c,
                        IOF__c,
                        IPCA__c,
                        Modalidade__c,
                        OpportunityId,
                        Phone,
                        PremioParcela__c,
                        PremioInformado__c,
                        QuantidadeParcelas__c,
                        RecordTypeId,
                        Reenquadramento__c,
                        ResponsavelFinanceiro__c,
                        TipoCusteio__c,
                        TipoCusteioEstipulante__c,
                        TipoCusteioSegurado__c,
                        TecnicoResponsavel__c,
                        AccountId,
                        MeioComercializacao__c,
                        Produto__c,
                        Status,
                        Origem__c,
                        DataCalculo__c,
                        TipoVigencia__c,
                        VigenciaInicial__c,
                        VigenciaFinal__c,
                        VigenciaFinalAlterada__c, //PLV-4684 INICIO/FIM
                        Tipo__c,
                        ValorPremio__c,
                        TipoEvento__c,
                        InformacoesEvento__c,
                        TipoViagem__c,
                        RamoSeguro__c,
                        CodigoCorretor__c,
                        Description,
                        FormaPagamento__c,
                        IdContratoParceiro__c,
                        IdContratanteParceiro__c,
                        Parceiro__c,
                        AdditionalAddress,
                        AdditionalName,
                        BillingAddress,
                        BillingName,
                        Account.Idade__c,
                        Produto__r.Id,
                        Produto__r.Name,
                        Produto__r.ProductCode,
                        Produto__r.Description,
                        Produto__r.Empresa__r.CodigoEmpresa__c,
                        Produto__r.NumeroSusep__c,
                        Produto__r.CodigoPrecificaProduto__c, //II-165 INICIO/FIM
                        RamoSeguro__r.Codigo__c,
                        RamoSeguro__r.Name,
                        Modalidade__r.Codigo__c,
                        Modalidade__r.Descricao__c,
                        Account.CodigoEmpresa__c,
                        Account.Cnpj__c,
                        Account.Cpf__c,
                        Account.RecordType.DeveloperName,
                        Account.Sexo__c,
                        Account.EstadoCivil__c,
                        ResponsavelFinanceiro__r.Cnpj__c,
                        ResponsavelFinanceiro__r.Cpf__c,
                        ResponsavelFinanceiro__r.RecordType.DeveloperName,
                        ResponsavelFinanceiro__r.Sexo__c,
                        ResponsavelFinanceiro__r.EstadoCivil__c,
                        ResponsavelFinanceiro__r.Name,
                        FormaPagamento__r.Codigo__c,
                        InformacaoBancaria__r.Banco__c,
                        InformacaoBancaria__r.Agencia__c,
                        InformacaoBancaria__r.NumeroConta__c,
            			//PLV-3918-FIX6 - INICIO
            			//PLV-3918-FIX7 - INICIO
                        InformacaoBancaria__r.Digito__c,
                        //PLV-3918-FIX7 - FIM
            			//PLV-3918-FIX6 - FIM
                        Empresa__r.CodigoEmpresa__c,
                        Account.Sucursal__c,
                        Account.CodigoSusepCia__c,
                        Account.NumeroContratoParceiro__c,
                        Account.NumeroContratoPrestador__c,
                        Account.NumeroContratoRespresentante__c,
                        //PLV-2675 - Inicio - Incluir campo do objeto código corretor para utilizar na classe PropostaGenericaBuilder
                        CodigoCorretor__r.SucursalVinculo__c,
                        //PLV-2675 - Fim
                        CodigoCorretor__r.Name,
                        CodigoCorretor__r.CodigoSucursalVinculo__c, //PLV-4515-FIX - INICIO/FIM
                        Contract.Name,
                        Contract.Endosso__c,
                        Opportunity.StageName,
                        HistoricoStatus__c,
                        Contract.CodigoCorretor__r.CodigoSucursalVinculo__c,
                        Contract.FormaPagamento__r.Codigo__c,
                        Contract.Empresa__c,
                        Contract.Status,
                        Opportunity.PremioPuro__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoMonetarioFormaPagto__c,//PLV-4701 - Inicio/Fim
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        Senha__c, // MGRC-505 INICIO-FIM
                        DistributionPublicUrl__c, // MGRC-505 INICIO-FIM
                        voucherPdfDownloadUrl__c, // MGRC-624 INICIO-FIM
						//PLV-3888 - Inicio - Incluir campo Chave_de_Agrupamento__c
						Chave_de_Agrupamento__c,
						//PLV-3888
                        Opportunity.Numero__c,
                (
                        SELECT
                                Id,
                                Name,
                                Endosso__c,
                                NumeroApolice__c
                        FROM
                                Contratos__r
                )
                FROM
                        Quote
                WHERE
                        Name = :name
        ];
    }

    //PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
    public List<Quote> obterListaPropostasPorName(Set<String> setPropostas)
    {
        return
        [
                SELECT
                        Name,
                        Id,
                        CanalDistribuicao__c,
segmento__c, //PLV-5857 INICIO/FIM
                        // Name,
                        NumeroProposta__c,
                        FaseStatus__c, // PLV-4606-FIX
                        CartaoCredito__c,
                        ContactId,
                        ContractId,
                        Contract.Sucursal__c,
                        Contract.CodigoRamo__c,
                        Contract.NumeroApolice__c,
                        Opportunity.CupomDesconto__c,   //VIAG-232
                        CupomDesconto__c,               //VIAG-232
                        DataCriacaoPortal__c,
                        DataEmissao__c,
                        DataProtocolo__c,
                        DiasAnalise__c,
                        Discount,
                        DataLimitePagamento__c,
                        Email,
                        Empresa__c,
                        GrandTotal,
                        ImprimirCertificadoSeguro__c,
                        InformacaoBancaria__c,
                        IOF__c,
                        IPCA__c,
                        Modalidade__c,
                        OpportunityId,
                        Phone,
                        PremioParcela__c,
                        PremioInformado__c,
                        QuantidadeParcelas__c,
                        RecordTypeId,
                        Reenquadramento__c,
                        ResponsavelFinanceiro__c,
                        TipoCusteio__c,
                        TipoCusteioEstipulante__c,
                        TipoCusteioSegurado__c,
                        TecnicoResponsavel__c,
                        AccountId,
                        MeioComercializacao__c,
                        Produto__c,
                        Status,
                        Origem__c,
                        DataCalculo__c,
                        TipoVigencia__c,
                        VigenciaInicial__c,
                        VigenciaFinal__c,
                        VigenciaFinalAlterada__c, //PLV-4684 INICIO/FIM
                        Tipo__c,
                        ValorPremio__c,
                        TipoEvento__c,
                        InformacoesEvento__c,
                        TipoViagem__c,
                        RamoSeguro__c,
                        CodigoCorretor__c,
                        Description,
                        FormaPagamento__c,
                        IdContratoParceiro__c,
                        IdContratanteParceiro__c,
                        Parceiro__c,
                        AdditionalAddress,
                        AdditionalName,
                        BillingAddress,
                        BillingName,                        
                        Account.Idade__c,
                        Produto__r.Id,
                        Produto__r.Name,
                        Produto__r.ProductCode,
                        Produto__r.Description,
                        Produto__r.Empresa__r.CodigoEmpresa__c,
                        Produto__r.NumeroSusep__c,
                        Produto__r.CodigoPrecificaProduto__c, //II-165 INICIO/FIM
                        RamoSeguro__r.Codigo__c,
                        RamoSeguro__r.Name,
                        Modalidade__r.Codigo__c,
                        Modalidade__r.Descricao__c,
                        Account.CodigoEmpresa__c,
                        Account.Cnpj__c,
                        Account.Cpf__c,
                        Account.RecordType.DeveloperName,
                        Account.Sexo__c,
                        Account.EstadoCivil__c,
                        ResponsavelFinanceiro__r.Cnpj__c,
                        ResponsavelFinanceiro__r.Cpf__c,
                        ResponsavelFinanceiro__r.RecordType.DeveloperName,
                        ResponsavelFinanceiro__r.Sexo__c,
                        ResponsavelFinanceiro__r.EstadoCivil__c,
                        ResponsavelFinanceiro__r.Name,
                        FormaPagamento__r.Codigo__c,
                        InformacaoBancaria__r.Banco__c,
                        InformacaoBancaria__r.Agencia__c,
                        InformacaoBancaria__r.NumeroConta__c,
            			//PLV-3918-FIX6-INICIO
            			//PLV-3918-FIX7-INICIO
                        InformacaoBancaria__r.Digito__c,
            			//PLV-3918-FIX7-FIM
            			//PLV-3918-FIX6 - FIM
                        Empresa__r.CodigoEmpresa__c,
                        Account.Sucursal__c,
                        Account.CodigoSusepCia__c,
                        Account.NumeroContratoParceiro__c,
                        Account.NumeroContratoPrestador__c,
                        Account.NumeroContratoRespresentante__c,
                        //PLV-2675 - Inicio - Incluir campo do objeto código corretor para utilizar na classe PropostaGenericaBuilder
                        CodigoCorretor__r.SucursalVinculo__c,
                        //PLV-2675 - Fim
                        CodigoCorretor__r.CodigoSucursalVinculo__c, //PLV-4515 - INICIO/FIM
                        CodigoCorretor__r.Name,
                        Contract.Name,
                        Contract.Endosso__c,
                        Opportunity.StageName,
                        HistoricoStatus__c,
                        Contract.CodigoCorretor__r.CodigoSucursalVinculo__c,
                        Contract.FormaPagamento__r.Codigo__c,
                        Contract.Empresa__c,
                        Contract.Status,
                        Opportunity.PremioPuro__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoMonetarioFormaPagto__c,//PLV-4701 - Inicio/Fim
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        Opportunity.Numero__c,
                        Senha__c, // MGRC-505 INICIO-FIM
                        DistributionPublicUrl__c, // MGRC-505 INICIO-FIM
            		ReaproveitarAssinatura__c,
                (
                        SELECT
                                Id,
                                Name,
                                Endosso__c,
                                NumeroApolice__c
                        FROM
                                Contratos__r
                )
                FROM
                        Quote
                WHERE
                        Name = :setPropostas
        ];
    }
    //PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista

    // PLV-2372-29 INICIO Remocao de metodo nao utilizado
    // PLV-2372-29 FIM Remocao de metodo nao utilizado

    public List<Contract> obterContratoPorQuoteName(String name)
    {
        return
        [
                SELECT
                        Id,
                        Parceiro__c,
                        Produto__c,
                        Proposta__r.Id,
                        Proposta__r.Name,
                        Proposta__r.AccountId,
                        Proposta__r.Account.Idade__c,
                        Proposta__r.Account.Cnpj__c,
                        Proposta__r.Account.Cpf__c,
                        Proposta__r.Account.RecordType.DeveloperName,
                        Proposta__r.Account.Sexo__c,
                        Proposta__r.Account.EstadoCivil__c,
                        Proposta__r.Account.Sucursal__c,
                        Proposta__r.Account.CodigoSusepCia__c,
                        Proposta__r.Account.NumeroContratoParceiro__c,
                        Proposta__r.Account.NumeroContratoPrestador__c,
                        Proposta__r.Account.NumeroContratoRespresentante__c,
                        Proposta__r.AdditionalAddress,
                        Proposta__r.AdditionalName,
                        Proposta__r.BillingAddress,
                        Proposta__r.BillingName,
                        Proposta__r.CanalDistribuicao__c,
                        Proposta__r.CartaoCredito__c,
                        Proposta__r.CodigoCorretor__c,
                        Proposta__r.CodigoCorretor__r.Name,
                        Proposta__r.ContactId,
                        Proposta__r.ContractId,
                        Proposta__r.Contract.Name,
                        Proposta__r.Contract.Endosso__c,
                        Proposta__r.Contract.CodigoCorretor__r.CodigoSucursalVinculo__c,
                        Proposta__r.Contract.FormaPagamento__r.Codigo__c,
                        Proposta__r.Contract.Empresa__c,
                        Proposta__r.Contract.Status,
                        Proposta__r.Contract.Produto__c,
                        Proposta__r.Contract.Produto__r.ProductCode,
                        Proposta__r.CustoApolice__c,
                        Proposta__r.DataCalculo__c,
                        Proposta__r.DataCriacaoPortal__c,
                        Proposta__r.DataEmissao__c,
                        Proposta__r.DataProtocolo__c,
                        Proposta__r.DescontoAgravoPercentualTecnico__c,
                        Proposta__r.DescontoAgravoPercentualComercial__c,
                        Proposta__r.DescontoAgravoMonetarioComercial__c,
                        Proposta__r.DescontoAgravoMonetarioTecnico__c,
                        Proposta__r.DescontoAgravoPercentualInformado__c,
                        Proposta__r.DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoMonetarioFormaPagto__c,//PLV-4701 - Inicio/Fim
                        Proposta__r.Description,
                        Proposta__r.DiasAnalise__c,
                        Proposta__r.Discount,
                        Proposta__r.Email,
                        Proposta__r.Empresa__c,
                        Proposta__r.Empresa__r.CodigoEmpresa__c,
                        Proposta__r.FormaPagamento__c,
                        Proposta__r.FormaPagamento__r.Codigo__c,
                        Proposta__r.HistoricoStatus__c,
                        Proposta__r.GrandTotal,
                        Proposta__r.IdContratoParceiro__c,
                        Proposta__r.IdContratanteParceiro__c,
                        Proposta__r.ImprimirCertificadoSeguro__c,
                        Proposta__r.InformacoesEvento__c,
                        Proposta__r.InformacaoBancaria__c,
                        Proposta__r.InformacaoBancaria__r.Banco__c,
                        Proposta__r.InformacaoBancaria__r.Agencia__c,
                        Proposta__r.InformacaoBancaria__r.NumeroConta__c,
            			//PLV-3918-FIX6-INICIO
            			//PLV-3918-FIX7-INICIO
                        Proposta__r.InformacaoBancaria__r.Digito__c,
            			//PLV-3918-FIX7-FIM
            			//PLV-3918-FIX6-FIM
                        Proposta__r.IOF__c,
                        Proposta__r.IPCA__c,
                        Proposta__r.MeioComercializacao__c,
                        Proposta__r.Modalidade__c,
                        Proposta__r.Modalidade__r.Codigo__c,
                        Proposta__r.Modalidade__r.Descricao__c,
                        Proposta__r.NumeroProposta__c,
                        Proposta__r.Origem__c,
                        Proposta__r.OpportunityId,
                        Proposta__r.Opportunity.PremioPuro__c,
                        Proposta__r.Opportunity.StageName,
                        Proposta__r.Parceiro__c,
                        Proposta__r.Payload__c,
                        Proposta__r.Phone,
                        Proposta__r.PremioParcela__c,
                        Proposta__r.PremioInformado__c,
                        Proposta__r.Produto__c,
                        Proposta__r.Produto__r.Id,
                        Proposta__r.Produto__r.Name,
                        Proposta__r.Produto__r.ProductCode,
                        Proposta__r.Produto__r.Description,
                        Proposta__r.Produto__r.Empresa__r.CodigoEmpresa__c,
                        Proposta__r.Produto__r.NumeroSusep__c,
                        Proposta__r.QuantidadeParcelas__c,
                        Proposta__r.RamoSeguro__c,
                        Proposta__r.RamoSeguro__r.Codigo__c,
                        Proposta__r.RamoSeguro__r.Name,
                        Proposta__r.RecordTypeId,
                        Proposta__r.Reenquadramento__c,
                        Proposta__r.ResponsavelFinanceiro__c,
                        Proposta__r.ResponsavelFinanceiro__r.Cnpj__c,
                        Proposta__r.ResponsavelFinanceiro__r.Cpf__c,
                        Proposta__r.ResponsavelFinanceiro__r.RecordType.DeveloperName,
                        Proposta__r.ResponsavelFinanceiro__r.Sexo__c,
                        Proposta__r.ResponsavelFinanceiro__r.EstadoCivil__c,
                        Proposta__r.ResponsavelFinanceiro__r.Name,
                        Proposta__r.Status,
                        Proposta__r.Tipo__c,
                        Proposta__r.TipoCusteio__c,
                        Proposta__r.TipoCusteioEstipulante__c,
                        Proposta__r.TipoCusteioSegurado__c,
                        Proposta__r.TipoEvento__c,
                        Proposta__r.TipoVigencia__c,
                        Proposta__r.TipoViagem__c,
                        Proposta__r.TecnicoResponsavel__c,
                        Proposta__r.ValorPremio__c,
                        Proposta__r.VigenciaInicial__c,
                        Proposta__r.VigenciaFinal__c,
                        Status
                FROM
                        Contract
                WHERE
                        Proposta__r.Name =: name
        ];
    }

    // PLV-2312-28 INICIO Remocao de metodo nao utilizado
    // PLV-2312-28 FIM Remocao de metodo nao utilizado

    public List<RemuneracaoProposta__c> buscarRemuneracaoProposta (Set<Id> quoteId)
    {
        return
        [
                SELECT
                        Id,
                        Name,
                        TipoRemuneracao__c,
                        TipoRemuneracao__r.Name,
                        TipoRemuneracao__r.Codigo__c,
                        RemuneracaoProduto__c,
                        // PLV-4337 - INICIO
                        // PLV-4234 - INICIO
                        Porcentagem_de_Retencao__c,
                        // PLV-4234 - FIM
                        // PLV-4337 - FIM
                        BonusCampanha__c, //II-167 INICIO/FIM
                        Percentual__c,
                (
                        SELECT
                                Id,
                                Conta__c,
                                CorretorLider__c,
                                Papel__c,
                                Participacao__c,
                                RemuneracaoProposta__c,
                                Susep__c,
                                SusepEmissao__c,
                                SusepOficialCorretor__c,
                                SusepOrcamento__c,
                    			AntecipacaoComissao__c, //PLV-4344
                                Conta__r.Name,
                                Conta__r.Sexo__c,
                                Conta__r.Cnpj__c,
                                Conta__r.Cpf__c,
                                Conta__r.RecordTypeId,
                                Conta__r.EstadoCivil__c,
                                DadosCorretor__c,
                                DadosCorretor__r.SucursalVinculo__c,
                                DadosCorretor__r.CodigoSucursalVinculo__c,
                                DadosCorretor__r.Name
                        FROM
                                FavorecidosRemuneracaodaProposta__r
                )
                FROM
                        RemuneracaoProposta__c
                WHERE
                        Proposta__c =: quoteId
        ];
    }

    public List<Opportunity> buscarRemuneracaoOrcamentoNoOrcamento (Set<Id> setQuoteId)
    {
        return
        [
                SELECT
                        Id,
                (
                        SELECT
                                Id,
                                TipoRemuneracao__c,
                                TipoRemuneracao__r.Name,
                                Percentual__c
                        FROM
                                RemuneracoesOrcamento__r
                )
                FROM
                        Opportunity
                WHERE
                        Id IN (SELECT OpportunityId FROM Quote WHERE Id =: setQuoteId)
        ];
    }

    public List<ContratanteProposta__c> buscarContratantesPropostaPorIdProposta(Set<Id> setProposta)
    {
        return
        [
                SELECT
                        Id,
                        Proposta__c,
                        TipoResponsavelPagamento__c,                        
                        FormaPagamento__r.Codigo__c,
                        QuantidadeParcelas__c,
                        PlanoParcelamento__r.DescricaoMeioRecebimento__c,
                        Conta__c,
                        Conta__r.Name,
                        Conta__r.NomeSocial__c, //LECVPV-184 - INICIO/FIM
                        Conta__r.RecordTypeId,
                        Conta__r.Papel__c,
                        Conta__r.Email__c,
                        Conta__r.Cpf__c,
                        Conta__r.Cnpj__c,
                        Conta__r.ServicosParceiro__c,
                        Conta__r.Sexo__c,
                        Conta__r.ServicosPrestador__c,
                        Conta__r.CodigoSusepCorretor__c,
                        Conta__r.Sucursal__c,
                        Conta__r.CodigoSusepCia__c,
                        Conta__r.NumeroContratoParceiro__c,
                        Conta__r.NumeroContratoPrestador__c,
                        Conta__r.NumeroContratoRespresentante__c,
                        Conta__r.IdExterno__c,
                        Conta__r.Profissao__c,
                        Conta__r.EstadoCivil__c,
                        Conta__r.Pep__c,
                        Conta__r.CurrencyIsoCode,
                        Conta__r.PersonAssistantPhone,
                        Conta__r.PersonBirthdate,
                        Conta__r.PersonHomePhone,
                        Conta__r.PersonOtherPhone,
                        Conta__r.PersonMobilePhone, // PLV-4601-FIX2
                        Conta__r.Phone,
                        Conta__r.Fax,
                        ResponsavelPagamento__c,
                        ResponsavelPagamento__r.Id,
                        ResponsavelPagamento__r.Name,
                        ResponsavelPagamento__r.Email__c,
                        ResponsavelPagamento__r.RecordTypeId,
                        ResponsavelPagamento__r.Papel__c,
                        ResponsavelPagamento__r.Cpf__c,
                        ResponsavelPagamento__r.Cnpj__c,
                        ResponsavelPagamento__r.ServicosParceiro__c,
                        ResponsavelPagamento__r.Sexo__c,
                        ResponsavelPagamento__r.ServicosPrestador__c,
                        ResponsavelPagamento__r.CodigoSusepCorretor__c,
                        ResponsavelPagamento__r.Sucursal__c,
                        ResponsavelPagamento__r.CodigoSusepCia__c,
                        ResponsavelPagamento__r.NumeroContratoParceiro__c,
                        ResponsavelPagamento__r.NumeroContratoPrestador__c,
                        ResponsavelPagamento__r.NumeroContratoRespresentante__c,
                        ResponsavelPagamento__r.IdExterno__c,
                        ResponsavelPagamento__r.Profissao__c,
                        ResponsavelPagamento__r.EstadoCivil__c,
                        ResponsavelPagamento__r.PersonAssistantPhone,
                        ResponsavelPagamento__r.PersonBirthdate,
                        ResponsavelPagamento__r.PersonHomePhone,
                        ResponsavelPagamento__r.PersonOtherPhone,
                        ResponsavelPagamento__r.PersonMobilePhone, // PLV-4601-FIX2
                        ResponsavelPagamento__r.Phone,
                        ResponsavelPagamento__r.Fax,
                        Tipo__c,
                        IOF__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                        TaxaPura__c,
                        TaxaComercial__c,
                        TaxaTotal__c,

                        numero__c,
                        VencimentoPrimeiraParcela__c,
                        Recorrencia__c, //TKCL-473 INICIO/FIM
                        Valor_PrimeiraParcela__c, //TKCL-473 INICIO/FIM
                        Valor_DemaisParcelas__c, //TKCL-473 INICIO/FIM
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoMonetarioFormaPagto__c//PLV-4701 - Inicio/Fim
                FROM
                        ContratanteProposta__c
                WHERE
                        Proposta__c IN :setProposta
        ];
    }
 // João: versão antiga que sera descontinuada
 public List<SeguradoProposta__c> buscarListVidaProposta(Set<Id> setQuote)
 {
     return
     [
             SELECT
                     Id,
                     Conta__r.Name,
                     GrupoProposta__c,
                     Numero__c,
                     GrupoProposta__r.Name,
                     GrupoProposta__r.ContratanteProposta__c,
                     GrupoProposta__r.ContratanteProposta__r.Id,
                     GrupoProposta__r.ContratanteProposta__r.Conta__r.Name,
                     GrupoProposta__r.ContratanteProposta__r.Proposta__c,
             (
                     SELECT
                             CpfCnpj__c,
                             TipoBeneficiario__c,
                             Conta__c,
                             Nome__c,
                             NomeSocial__c, // LECVPV-184 INICIO/FIM
                             Participacao__c,
                             Id,
                             CpfPep__c,
                             GrauParentesco__c,
                             BeneficiarioGrauParentescoOutros__c, //PLV-5231 - INICIO/FIM
                             GrauParentescoPep__c,
                             ImprimirCertificadoSeguro__c,
                             NomePessoaPep__c,
                             Pep__c,
                             SeguradoProposta__c,
                             //PLV-4441 INICIO
                             MotivoSemCpfCnpj__c,
                             Data_de_Nascimento__c,
                             PercentualIndenizacao__c,
                             Sexo__c
                             //PLV-4441 FIM
                     FROM
                             BeneficiariosSeguradosProposta__r
             )
             FROM
                     SeguradoProposta__c
             WHERE
                     GrupoProposta__r.ContratanteProposta__r.Proposta__c =: setQuote
     ];
 }

    public List<SeguradoProposta__c> buscarListSeguradoProposta(Set<Id> setQuote)
    {
        return
        [
                SELECT
                        Id,
                        Conta__r.Name,
                        GrupoProposta__c,
                        GrupoProposta__r.Name,
                        GrupoProposta__r.ContratanteProposta__c,
                        GrupoProposta__r.ContratanteProposta__r.Id,
                        GrupoProposta__r.ContratanteProposta__r.Conta__r.Name,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__c,
                        DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoMonetarioFormaPagto__c,//PLV-4701 - Inicio/Fim
                (
                        SELECT
                                CpfCnpj__c,
                                TipoBeneficiario__c,
                                Conta__c,
                                Nome__c,
                                NomeSocial__c, // LECVPV-184 INICIO/FIM
                                //PLV-4441 INICIO
                                Participacao__c,
                                GrauParentesco__c,
                                BeneficiarioGrauParentescoOutros__c, //PLV-5231 - INICIO/FIM
                                SeguradoProposta__c,
                                Data_de_Nascimento__c,
                                PercentualIndenizacao__c,
                                Sexo__c
                                //PLV-4441 FIM
                        FROM
                                BeneficiariosSeguradosProposta__r
                )
                FROM
                        SeguradoProposta__c
                WHERE
                        GrupoProposta__r.ContratanteProposta__r.Proposta__c =: setQuote
        ];
    }
    //RVI-4998 - INICIO
    public List<BeneficiarioSeguradoProposta__c> buscarBeneficiariosSeguradosProposta(Set<Id> setQuote)
    {
        return
        [
                SELECT
                        Id
                FROM
                        BeneficiarioSeguradoProposta__c
                WHERE
                        SeguradoProposta__r.GrupoProposta__r.ContratanteProposta__r.Proposta__c =: setQuote
        ];
    }
    //RVI-4998 - FIM

    public List<PerguntaQuestionario__c> buscarPerguntasQuestionario(Set<Id> setQuestionario)
    {
        return
        [
                SELECT
                        Id,
                        Name,
                        Numero__c,
                        Questionario__c,
                        Obrigatorio__c, // PLV-4797 INICIO/FIM SYS4B ODEMIR
                        Pergunta__c,
                        Pergunta__r.Name,
                        Pergunta__r.TipoResposta__c,
                        Pergunta__r.OpcoesResposta__c,
                        ProximaPergunta__r.Id,
                        ProximaPergunta__r.Name,
                        ProximaPergunta__r.Numero__c,
                        ProximaPergunta__r.Pergunta__c,
                        ProximaPergunta__r.Pergunta__r.Name,
                        ProximaPergunta__r.Pergunta__r.TipoResposta__c,
                        ProximaPergunta__r.Pergunta__r.OpcoesResposta__c,
                (
                        SELECT
                                Id,
                                SeguradoProposta__c,
                                Resposta__c,
                                Status__c
                        FROM
                                RespostasQuestionario__r
                )
                FROM
                        PerguntaQuestionario__c
                WHERE
                        Questionario__c =: setQuestionario
                ORDER BY
                        Numero__c
        ];
    }
    public List<QuestionarioProduto__c> buscarQuestionarioPrioritario(Set<Id> setGarantiaProdutoId)
    {
        return
        [
                SELECT
                        Questionario__c,
                        Prioridade__c,
                        LimiteCapitalMinimo__c,
                        LimiteCapitalMaximo__c,
                        GarantiaProduto__r.Garantia__r.Sigla__c,
                        GarantiaProduto__r.GarantiaProduto__r.Garantia__r.Sigla__c
                FROM
                        QuestionarioProduto__c
                WHERE
                        GarantiaProduto__c =: setGarantiaProdutoId
                ORDER BY
                        Prioridade__c
        ];
    }

    public List<GrupoProposta__c> buscarGrupoProposta (Set<Id> setGrupoPropostaId)
    {
        return
        [
                SELECT
                        Id,
                        ContratanteProposta__c,
                        ContratanteProposta__r.Proposta__c
                FROM
                        GrupoProposta__c
                WHERE
                        Id =: setGrupoPropostaId
        ];
    }

    public List<GarantiaProposta__c> buscarGarantiasProposta(Id quoteId)
    {
        return
        [
                SELECT
                        Id,
                        Proposta__c,
                        GarantiaProduto__c
                FROM
                        GarantiaProposta__c
                WHERE
                        Proposta__c =: quoteId
        ];
    }

    //PLV-4998 - INICIO
    public List<GarantiaProposta__c> buscarGarantiasProposta(Set<Id> quoteIds)
    {
        return
        [
                SELECT
                        Id,
                        Proposta__c,
                        GarantiaProduto__c
                FROM
                        GarantiaProposta__c
                WHERE
                        Proposta__c =: quoteIds
        ];
    }
    //PLV-4998 - FIM

    public List<Product2> buscarProduto(List<Id> listProduto)
    {
        return
        [
                SELECT
                        Id,
                (
                        SELECT
                                Id,
                                QuantidadeParcelas__c,
                                FormaPagamento__c,
                                FormaPagamento__r.Codigo__c
                        FROM
                                CondicoesCobranca__r
                )
                FROM
                        Product2
                WHERE
                        Id =: listProduto
        ];
    }

    // PLV-2312-28 INICIO Remocao de metodo nao utilizado
    // PLV-2312-28 FIM Remocao de metodo nao utilizado

    public List<Account> buscarContas(Set<Id> setAccountId)
    {
        return
        [
                SELECT
                        Id,
                        Name,
                (
                        SELECT
                                Id,
                                CartoPortoSeguro__c
                        FROM
                                CartoesCredito__r
                ),
                (
                        SELECT
                                Id,
                                Name
                        FROM
                                InformacoesBancarias__r
                )
                FROM
                        Account
                WHERE
                        Id =: setAccountId
        ];
    }

    // PLV-2312-28 INICIO
    public List<SeguradoProposta__c> buscarListSeguradosPropostaByQuote(Set<Id> setQuote)
    {
        return
        [
                SELECT
                        Id,
                        Conta__c,
                        Conta__r.PersonBirthdate,
                        Conta__r.Fumante__c,
                        Conta__r.Profissao__r.Codigo__c,
                        Conta__r.RegimeTrabalho__c,
                        Conta__r.Renda__c,
                        Conta__r.Sexo__c,
                        Conta__r.Email__c,
                        Conta__r.Name,
                        EnderecoBoleto__c,
                        FormaPagamento__c,
                        GrupoProposta__c,
                        Numero__c,
                        QuantidadeParcelas__c,
                        ResponsavelPagamento__c,
                        ResponsavelPagamento__r.PersonMobilePhone, // PLV-4601-FIX2
                        VencimentoPrimeiraParcela__c,
                        TipoResponsavelPagamento__c,
                        PremioPuro__c,
                        PremioComercial__c,
                        PremioTotal__c,
                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                        TaxaPura__c,
                        TaxaComercial__c,
                        TaxaTotal__c,
                        IOF__c,
                        TipoCusteio__c,
                        CartaoCredito__c,
                        PlanoParcelamento__c,
                        PorcentagemParticipacaoSegurado__c,
                        IPCA__c,
                        Reenquadramento__c,
                        PorcentagemParticipacaoVida__c,
                        PremioParcela__c,
                        InformacaoBancaria__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoMonetarioFormaPagto__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoPercentualParcelamento__c,//PLV-4810 - INICIO/FIM SYS4B odemir
                        DescontoAgravoMonetarioParcelamento__c,//PLV-4810 - INICIO/FIM SYS4B odemir
                        EmailResponsavel__c,//PLV-4911 - INICIO/FIM PEDRO AUGUSTO BRAZ
                        // PLV-4844 INICIO
                        logradouroResidencial__c,
                        numeroResidencial__c,
                        ComplementoResidencial__c,
                        bairroResidencial__c,
                        CidadeResidencial__c,
                        UFResidencial__c,
                        paisResidencial__c,
                        cepResidencial__c,// PLV-4844 FIM
                        VigenciaInicial__c,
                        VigenciaFinal__c,
                        //PLV-4441 - INICIO
                        profissao__c,
                        RegimeTrabalho__c,
                        FaixaRenda__c,
                        NomeResponsavel__c,
                        CpfResponsavel__c,
                        VinculoComSegurado__c,
                        PEP__c,
                        ResponsavelFinanceiroSeguro__c,
                        TipoPessoaRelacionamentoProximo__c,
                        NomePessoaRelacionamentoProximo__c,
                        CpfPessoaRelacionamentoProximo__c,
                        GrauParentesco__c,
                        Fumante__c,
                        TemDependentes__c,
                        //PLV-4441 - FIM
                        Pais_Residente__c, //PLV-4874 - Inicio/Fim
                        //PLV-4694 - INICIO
                        GrupoProposta__r.QuantidadeVidas__c,
                        GrupoProposta__r.Numero__c,
                        GrupoProposta__r.Name,
                        GrupoProposta__r.ContratanteProposta__r.Tipo__c,
                        GrupoProposta__r.ContratanteProposta__r.Numero__c,
                        Conta__r.Nacionalidade__c,
                        PaisDeOrigem__c, //PLV-5231 INICIO/FIM
                        Conta__r.EstadoCivil__c,
                        //PLV-4694 - FIM
                        //PLV-4600 INICIO
                        NomeContatoEmergencia__c,
                        TelefoneContatoEmergencia__c,
                        //PLV-4600 FIM
                        //PLV - 4690 - INICIO -  GUSTAVO DA SILVA PEREIRA SYS4B
                        Nome_do_segurado__c,
                        NomeSocial_do_Segurado__c, // LECVPV-184 INICIO/FIM
                        EmpresaTrabalhaSocio__c,
                        RamoAtividade__c , // PLV-4810  INICIO/FIM SYS4B ODEMIR
                        Renda__c,
                        Email__c,
                        Celular__c,
                        Telefone_residencial__c,
                        Telefone_comercial__c,
                        Endereco_residencial__c,
                        Endereco_comercial__c,
                        Endereco_veraneio__c,
                        Endereco_de_recado__c,
                        Melhor_periodo_para_contato__c,
                        //PLV - 4690 - FIM -  GUSTAVO DA SILVA PEREIRA SYS4B
                        // PLV - 4594 - INICIO   ODEMIR SYS4B
                        IntegracaoPEP__c,
                        CargoPEP__c,
                        UltimaConsultaPEP__c,
                        DataAtualizacaoPEP__c,
                        // PLV - 4594 - FIM   ODEMIR SYS4B
                        CicloVacinal__c, //PLV-5127 INICIO/FIM
             		//PLV-5098 - FIX-02 INICIO - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH
                        tipoEmpresa__c,
                        numeroCnpj__c,
                        qtdFuncionarios__c,
                        //PLV-5098 - FIX-02 FIM - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH   
                        GrupoRisco__c, //PLV-5161 - INICIO/FIM                        
                (
                        SELECT
                                Conta__c,
                                CpfCnpj__c,
                                CpfPep__c,
                                GrauParentesco__c,
                                BeneficiarioGrauParentescoOutros__c, //PLV-5231 - INICIO/FIM
                                GrauParentescoPep__c,
                                ImprimirCertificadoSeguro__c,
                                MotivoSemCpfCnpj__c,
                                Nome__c,
                                NomeSocial__c, // LECVPV-184 INICIO/FIM
                                NomePessoaPep__c,
                                Participacao__c,
                                Pep__c,
                                TipoBeneficiario__c,
                                //PLV-4441 - INICIO
                                SeguradoProposta__c,
                                Data_de_Nascimento__c,
                                PercentualIndenizacao__c,
                                Sexo__c
                                //PLV-4441 - FIM
                        FROM
                                BeneficiariosSeguradosProposta__r
                ),
                (
                        SELECT
                                Id,
                                Name,
                                Capital__c,
                                SeguradoProposta__c,
                                Percentual__c,
                                Valor__c,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                ValorCotacao__c,
                                PremioPuro__c,
                                PremioComercial__c,
                                PremioTotal__c,
                                PremioIntegral__c, //PLV-5351 INICIO/FIM
                                CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                                TaxaPura__c,
                                TaxaComercial__c,
                                TaxaTotal__c,
                                Garantia__c,
                                Garantia__r.Sigla__c, //PLV-4544 - Inicio/Fim
                                GarantiaProduto__c,
                                DescontoAgravoPercentualTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioTecnico__c,
                                //PLV-4626 - INICIO
                                Tipo_de_limite_de_utilizacao__c,
                                Limite_de_Uso__c,
                                //PLV-4626 - FIM                    
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                                DescontoAgravoMonetarioFormaPagto__c,//PLV-4701 - Inicio/Fim
                                IOF__c,//PLV-4689 - Inicio/Fim
                                DescontoAgravoMonetarioInformado__c,
                                ValorDias__c //PLV-4830 - Inicio/Fim
                        FROM
                                GarantiasSeguradoProposta__r
                )
                FROM
                        SeguradoProposta__c
                WHERE
                        GrupoProposta__r.ContratanteProposta__r.Proposta__c =: setQuote
        ];
    }
    // PLV-2312-28 FIM

    // PLV-2312-28 INICIO
    public List<GrupoProposta__c> buscarListGrupoPropostaByQuote(Set<Id> setQuote)
    {
        return
        [
                SELECT
                        Id,
                        Descricao__c,
                        Name,
                        Numero__c,
                        QuantidadeVidas__c ,
                        ContratanteProposta__c,
                        TipoCalculo__c,
                        PremioPuro__c,
                        PremioComercial__c,
                        PremioTotal__c,
                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                        TaxaPura__c,
                        TaxaComercial__c,
                        TaxaTotal__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoMonetarioFormaPagto__c,//PLV-4701 - Inicio/Fim
                        IOF__c,//PLV-4689 - Inicio/Fim
                (
                        SELECT
                                Id,
                                Capital__c,
                                GarantiaReferenciada__c,
                                GrupoProposta__c,
                                Percentual__c,
                                Valor__c,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                ValorCotacao__c,
                                PremioPuro__c,
                                PremioComercial__c,
                                PremioTotal__c,	
                                PremioIntegral__c, //PLV-5351 INICIO/FIM	
                                CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                                TaxaPura__c,
                                TaxaComercial__c,
                                TaxaTotal__c,
                                Garantia__c,
                                Garantia__r.Sigla__c, //PLV-4544 - Inicio/Fim
                                GarantiaProduto__c,
                                DescontoAgravoPercentualTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                                DescontoAgravoMonetarioFormaPagto__c,//PLV-4701 - Inicio/Fim
                                IOF__c,//PLV-4689 - Inicio/Fim
                                DescontoAgravoMonetarioInformado__c
                    	FROM
                                GarantiasGrupoProposta__r
                )
                FROM
                        GrupoProposta__c
                WHERE
                        ContratanteProposta__r.Proposta__c =: setQuote
        ];
    }
    // PLV-2312-28 FIM

    // PLV-2312-28 INICIO Remocao de metodo nao utilizado
    // PLV-2312-28 FIM Remocao de metodo nao utilizado


    // PLV-2312-28 INCIO Remocao de metodo nao utilizado
    public List<ContratanteProposta__c> buscarContratantesPropostaByQuote(Set<Id> setQuote)
    {
        return
        [
                SELECT
                        Id,
                        Bairro__c,
                        BairroCorrespondencia__c,
                        Cep__c,
                        CEPCorrespondencia__c,
                        Cidade__c,
                        CidadeCorrespondencia__c,
                        Complemento__c,
                        ComplementoCorrespondencia__c,
                        Conta__c,
                        //PLV-4813 INICIO
                        Conta__r.Recordtype.DeveloperName,
                        Conta__r.Cnpj__c,
                        Conta__r.Cpf__c,
                        //PLV-4813 FIM
                        Conta__r.PersonMobilePhone, // PLV-4601-FIX2
                        EnderecoBoleto__c,
                        Estado__c,
                        EstadoCorrespondencia__c,
                        FormaPagamento__c,
                        Logradouro__c,
                        LogradouroCorrespondencia__c,
                        NumeroCorrespondencia__c,
                        NumeroEndereco__c,
                        Numero__c,
                        Pais__c,
                        PaisCorrespondencia__c,
                        Proposta__c,
                        QuantidadeParcelas__c,
                        ResponsavelPagamento__c,
                        ResponsavelPagamento__r.PersonMobilePhone, // PLV-4601-FIX2
                        Tipo__c,
                        TipoEndereco__c,
                        TipoEnderecoCorrespondencia__c,
                        TipoLogradouro__c,
                        TipoLogradouroCorrespondencia__c,
                        TipoResponsavelPagamento__c,
                        VencimentoPrimeiraParcela__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                        TaxaPura__c,
                        IOF__c,
                        TipoCusteio__c,
                        CartaoCredito__c,
                        PlanoParcelamento__c,
                        PorcentagemParticipacaoSegurado__c,
                        IPCA__c,
                        Reenquadramento__c,
                        PorcentagemParticipacaoVida__c,
                        PremioParcela__c,
                        InformacaoBancaria__c,
                        FormaInfoCartao__c,  // RVI-248 - INICIO/FIM
                        PremioTotal__c,
                        TaxaComercial__c,
                        TaxaTotal__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                        DescontoAgravoMonetarioFormaPagto__c,//PLV-4701 - Inicio/Fim
                        //PLV-4440 - INICIO
                        VencimentoDemaisParcelas__c,
                        Valor_PrimeiraParcela__c, //TKCL-473 INICIO/FIM
                        Valor_DemaisParcelas__c, //TKCL-473 INICIO/FIM
                        VigenciaInicial__c,
                        //PLV-4440 - FIM
                        //PLV - 4690 - INICIO -  GUSTAVO DA SILVA PEREIRA SYS4B
                        Nome_do_segurado__c,
                        NomeSocial_do_Segurado__c, // LECVPV-184 INICIO/FIM
                        Email__c,
                        Celular__c,
                        Telefone__c,
                        Telefone_Outro__c,
                        Forma_de_receber_apolice__c,
                        //PLV - 4690 - FIM -  GUSTAVO DA SILVA PEREIRA SYS4B
                        Recorrencia__c,//TKCL 460 INICIO/FIM

                (
                        SELECT
                                Id,
                                Name,
                                Capital__c,
                                ContratanteProposta__c,
                                Percentual__c,
                                Valor__c,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                ValorCotacao__c,
                                PremioPuro__c,
                                PremioComercial__c,
                                PremioTotal__c,
                                PremioIntegral__c, //PLV-5351 INICIO/FIM
                                CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                                TaxaPura__c,
                                TaxaComercial__c,
                                TaxaTotal__c,
                                Garantia__c,
                                Garantia__r.Sigla__c, //PLV-4544 - Inicio/Fim
                                GarantiaProduto__c,
                                DescontoAgravoPercentualTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualInformado__c,
                                IOF__c,//PLV-4689 - Inicio/Fim
                                DescontoAgravoMonetarioInformado__c,//PLV-4701 - Inicio/Fim
                                DescontoAgravoPercentualFormaPagto__c,//PLV-4701 - Inicio/Fim
                                DescontoAgravoMonetarioFormaPagto__c//PLV-4701 - Inicio/Fim

                        FROM
                                GarantiasContratanteProposta__r
                )
                FROM
                        ContratanteProposta__c
                WHERE
                        Proposta__c IN :setQuote
        ];
    }
    
    // TST
    // PLV-2372 INICIO
    // PLV-2567 INICIO
    public List<Quote> buscarPropostasCancelamentoPorContratoOriginal(Set<Id> setContratoId){
        return [
                SELECT
                        Id,
                        Name,
                        Status,
                        Tipo__c,
                        OpportunityId,
                        Opportunity.Id
                FROM
                        Quote
                WHERE
                        ContractId =: setContratoId
                AND
                        Tipo__c = 'Cancelamento'
        ];
    }
    // PLV-2567 FIM
    // PLV-2372 FIM
    // TST


    // PLV-2312-28 FIM Remocao de metodo nao utilizado

}