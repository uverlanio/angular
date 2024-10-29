/**************************************************************************************************************************************************************************
 *
 *  Classe responsável pela busca de dados do objeto de Opportunity
 *
 **************************************************************************************************************************************************************************/
public  class OpportunityDAO
{
    private static final OpportunityDAO instancia = new OpportunityDAO();
    private OpportunityDAO() {    }
    public static OpportunityDAO getInstance(){ return instancia; }

    //INICIO | PLV-2355-SNIPER

    public Opportunity obterOportunidadesPorNumeroComPrefixo(String numero)
    {
        List<Opportunity> lista =  [
                Select
                        RecordType.Name,
                        AccountId,
            		Account.IdExterno__c,
                        Amount,
                        CampaignId,
                        CanalDistribuicao__c,
                        CapitalSegurado__c,
                        Tarifa__c,// PLV-4666
                        DLL__c, // PLV-4666
                        CloseDate,
                        CodigoCorretor__c,
                        Congenere__c,
                        ConnectionReceivedId,
                        ConnectionSentId,
                        ContractId,
                        Contract.Id,
                        Contract.Name,
                        Contract.Endosso__c,
                        Contract.NumeroApolice__c,
                        Contract.Empresa__c,
                        Contract.Sucursal__c,
                        Contract.CodigoRamo__c,
                        Contract.Proposta__r.Empresa__r.Cnpj__c,
                        Contract.Proposta__r.Account.Sucursal__c,
                        Contract.Proposta__r.RamoSeguro__r.Codigo__c,
                        Contract.Proposta__r.Contract.Name,
                        Contract.Proposta__r.Contract.Endosso__c,
                        Contract.Proposta__r.Id,
                        Contract.Proposta__r.Name,
                        Contract.Proposta__r.NumeroProposta__c,
                        Contract.Proposta__r.CartaoCredito__c,
                        Contract.Proposta__r.ContactId,
                        Contract.Proposta__r.ContractId,
                        Contract.Proposta__r.DataCriacaoPortal__c,
                        Contract.Proposta__r.DataEmissao__c,
                        Contract.Proposta__r.DataProtocolo__c,
                        Contract.Proposta__r.DiasAnalise__c,
                        Contract.Proposta__r.Discount,
                        Contract.Proposta__r.Email,
                        Contract.Proposta__r.Empresa__c,
                        Contract.Proposta__r.CanalDistribuicao__c,
                        Contract.Proposta__r.GrandTotal,
                        Contract.Proposta__r.ImprimirCertificadoSeguro__c,
                        Contract.Proposta__r.InformacaoBancaria__c,
                        Contract.Proposta__r.IOF__c,
                        Contract.Proposta__r.IPCA__c,
                        Contract.Proposta__r.Modalidade__c,
                        Contract.Proposta__r.OpportunityId,
                        Contract.Proposta__r.Phone,
                        Contract.Proposta__r.PremioParcela__c,
                        Contract.Proposta__r.QuantidadeParcelas__c,
                        Contract.Proposta__r.RecordTypeId,
                        Contract.Proposta__r.Reenquadramento__c,
                        Contract.Proposta__r.ResponsavelFinanceiro__c,
                        Contract.Proposta__r.TipoCusteio__c,
                        Contract.Proposta__r.TipoCusteioEstipulante__c,
                        Contract.Proposta__r.TipoCusteioSegurado__c,
                        Contract.Proposta__r.TecnicoResponsavel__c,
                        Contract.Proposta__r.AccountId,
                        Contract.Proposta__r.MeioComercializacao__c,
                        Contract.Proposta__r.Produto__c,
                        Contract.Proposta__r.Status,
                        Contract.Proposta__r.Origem__c,
                        Contract.Proposta__r.DataCalculo__c,
                        Contract.Proposta__r.TipoVigencia__c,
                        Contract.Proposta__r.VigenciaInicial__c,
                        Contract.Proposta__r.VigenciaFinal__c,
                        Contract.Proposta__r.Tipo__c,
                        Contract.Proposta__r.ValorPremio__c,
                        Contract.Proposta__r.TipoEvento__c,
                        Contract.Proposta__r.InformacoesEvento__c,
                        Contract.Proposta__r.TipoViagem__c,
                        Contract.Proposta__r.RamoSeguro__c,
                        Contract.Proposta__r.CodigoCorretor__c,
                        Contract.Proposta__r.Description,
                        Contract.Proposta__r.FormaPagamento__c,
                        Contract.Proposta__r.IdContratoParceiro__c,
                        Contract.Proposta__r.IdContratanteParceiro__c,
                        Contract.Proposta__r.Parceiro__c,
                        Contract.Proposta__r.AdditionalAddress,
                        Contract.Proposta__r.AdditionalName,
                        Contract.Proposta__r.BillingAddress,
                        Contract.Proposta__r.BillingName,
                        Contract.Proposta__r.CanalDistribuicao__r.Sigla__c,
                        Contract.Proposta__r.CanalDistribuicao__r.Name,
                        Contract.Proposta__r.Produto__r.ProductCode,
                        Contract.Proposta__r.Produto__r.Description,
                        Contract.Proposta__r.Produto__r.NumeroSusep__c,
                        Contract.Proposta__r.Produto__r.Empresa__r.CodigoEmpresa__c,
                        Contract.Proposta__r.Produto__r.Empresa__r.Name,
                        Contract.Proposta__r.Produto__r.Empresa__c,
                        Contract.Proposta__r.Produto__r.Name,
                        Contract.Proposta__r.HistoricoStatus__c,
                        Contract.Proposta__r.CodigoCorretor__r.Name,
                        Contract.Proposta__r.CodigoCorretor__r.SucursalVinculo__c,
                        Contract.Proposta__r.Empresa__r.CodigoEmpresa__c,
                        Contract.Proposta__r.RamoSeguro__r.Name,
                        Contract.Proposta__r.Empresa__r.Sucursal__c,
                        Contract.Proposta__r.Account.Idade__c,
                        Contract.Proposta__r.RecordType.DeveloperName,
                        Contract.Proposta__r.Empresa__r.Name,
                        Contract.Proposta__r.Modalidade__r.Codigo__c,
                        Contract.Proposta__r.Modalidade__r.Descricao__c,
                        Contract.Proposta__r.Opportunity.Numero__c,
                        Contract.Proposta__r.Opportunity.NumeroPortal__c,
                        Contract.Proposta__r.Opportunity.CanalDistribuicao__c,
                        Contract.Proposta__r.Opportunity.CanalDistribuicao__r.Sigla__c,
                        Contract.Proposta__r.Opportunity.HaControlePublico__c,
                        Contract.Proposta__r.Opportunity.EventoLocalFechadoDelimitado__c,
                        Contract.Proposta__r.Opportunity.ViagemAventura__c,
                        Contract.Proposta__r.Opportunity.UtilizaMoto__c,
                        Contract.Proposta__r.Opportunity.IncluiPaisEuropeu__c,
                        Contract.Proposta__r.Opportunity.PossuiTrackageBagagem__c,
                        Contract.Proposta__r.Opportunity.QuantidadePassageirosNaoIdosos__c,
                        Contract.Proposta__r.Opportunity.QuantidadePassageirosIdosos__c,
                        //PLV-3879 - INICIO
                        Contract.Proposta__r.Opportunity.PaisesDestino__c,
                        //PLV-3879 - FIM
                        Contract.Proposta__r.Payload__c,
                        Contract.Proposta__r.PremioIntegral__c, //PLV-5351 INICIO/FIM
                        Contract.Proposta__r.PremioComercial__c,
                        Contract.Proposta__r.PremioPuro__c,
                        Contract.Proposta__r.PremioTotal__c,
                        Contract.Proposta__r.TaxaComercial__c,
                        Contract.Proposta__r.TaxaPura__c,
                        Contract.Proposta__r.TaxaTotal__c,
                        Contract.Proposta__r.DescontoAgravoPercentualTecnico__c,
                        Contract.Proposta__r.DescontoAgravoPercentualComercial__c,
                        Contract.Proposta__r.DescontoAgravoMonetarioComercial__c,
                        Contract.Proposta__r.DescontoAgravoMonetarioTecnico__c,
                        Contract.Proposta__r.DescontoAgravoPercentualInformado__c,
                        Contract.Proposta__r.DescontoAgravoMonetarioInformado__c,
                        CorretorPrincipal__c,
                        CreatedById,
                        CreatedDate,
                        CurrencyIsoCode,
                        CusteioSegurado__c,
                        CusteioSubEstipulante__c,
                        CustoApolice__c,
                        CupomDesconto__c, // AV-664 INICIO/FIM
                        DataCalculo__c,
                        DataCriacaoPortal__c,
                        Dependentes__c,
                        DescontoAgravoComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoPercentualFormaPagto__c, //PLV-5800 FIX02 INICIO-FIM
                        DescontoAgravoMonetarioFormaPagto__c, //PLV-5800 FIX02 INICIO-FIM
                        DescontoPremioComercial__c,
                        DescontoPremioPuro__c,
                        Description,
                        Destino__c,
                        Encargos__c,
                        // 2610 - INICIO
                        EntradaNegocio__c,
                        // 2610 - FIM
                        EventoLocalFechadoDelimitado__c,
                        ExpectedRevenue,
                        FaixaIdade__c,
                        FaixaRenda__c,
                        Fiscal,
                        FiscalQuarter,
                        FiscalYear,
                        ForecastCategory,
                        ForecastCategoryName,
                        FormaCusteio__c,
                        FormaPagamento__c,
                        FormaTrabalho__c,
                        HaControlePublico__c,
                        HasOpenActivity,
                        HasOpportunityLineItem,
                        HasOverdueTask,
                        Id,
                        IncluiPaisEuropeu__c,
                        InformacoesEvento__c,
                        Iof__c,
                        IsClosed,
                        IsDeleted,
                        IsPrivate,
                        IsWon,
                        Juros__c,
                        JustificativasPareceres__c,
                        LastActivityDate,
                        LastModifiedById,
                        LastModifiedDate,
                        LastReferencedDate,
                        LastViewedDate,
                        LeadSource,
                        LivreEscolha__c,
                        MeioComercializacao__c,
                        MultiploSalarial__c,
                        Name,
                        NextStep,
                        NumeroPortal__c,
                        Numero__c,
                        ObservacoesGerais__c,
                        OrcamentoAfastamento__c,
                        Origem__c,
                        OwnerId,
                        //PLV-3879 - INICIO
                        PaisesDestino__c,
                        //PLV-3879 - FIM
                        Payload__c,
                        Percentual__c,
                        PossuiAfastados__c,
                        PossuiTrackageBagagem__c,
                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                        PremioComercial__c,
                        PremioInformado__c,
                        PremioPuroInterno__c,
                        PremioPuroResseguro__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        PrestadoresServicosEstagiarios__c,
                        Pricebook2Id,
                        Probability,
                        Produto__c,
                        //PLV-3285 - INICIO - Incluido para consultar ramo, modalidade e empresa
                        Produto__r.ProductCode,
                        //PLV-3285 - FIM
                        ProtecaoParaQuem__c,
                        QuantidadeDias__c,
                        QuantidadeFuncionarios__c,
                        QuantidadeMotoboys__c,
                        QuantidadeMotoristas__c,
                        QuantidadeParcelas__c,
                        QuantidadePassageiros070Anos__c,
                        QuantidadePassageirosIdosos__c,
                        QuantidadePassageirosNaoIdosos__c,
                        QuantidadePassageiros__c,
                        QuantidadeSocios__c,
                        QuantidadeVidas__c,
                        RamoOrcamento__c,//PLV-4693 INICIO/FIM
                        RecordTypeId,
                        Sinistralidade__c,
                        StageName,
                        SyncedQuoteId,
                        SystemModstamp,
                        TaxaAnual__c,
                        TaxaComercial__c,
                        TaxaMensal__c,
                        TaxaPuraInterna__c,
                        TaxaPuraResseguro__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        TaxaVigencia__c,
                        TempoPermanencia__c,
                        TipoAdesao__c,
                        TipoCalculo__c,
                        TipoDescontoAgravo__c,
                        TipoEvento__c,
                        TipoEndosso__c,
                        TipoProtecao__c,
                        TipoSegurado__c,
                        TipoViagem__c,
                        TipoVigencia__c,
                        TotalOpportunityQuantity,
                        Total__c,
                        TransferenciaCongenere__c,
                        Type,
                        UtilizaMoto__c,
                        ViagemAventura__c,
                        VidasEntre7074Anos__c,
                        VidasEntre7190Anos__c,
                        VigenciaFinal__c,
                        VigenciaFinalAlterada__c, //PLV-4684 INICIO/FIM
                        VigenciaInicial__c,
                        VigenciaMenor365Dias__c,
                (
                        SELECT
                                Id,
                                Empresa__r.Cnpj__c,
                                Account.Sucursal__c,
                                RamoSeguro__r.Codigo__c,
                                Contract.Name,
                                Contract.Endosso__c,
                                Tipo__c
                        FROM
                                Quotes
                        //WHERE
                        //    Status__c = :'Devolvida'
                        LIMIT 1
                ),
                (
                        SELECT
                                Id,
                                ImprimirCodigoOperacao__c,
                                Name,
                                Percentual__c,
                                TipoRemuneracao__c,
                                TipoRemuneracao__r.Codigo__c, //II-167 INICIO/FIM
                                // PLV-4234 INICIO
                                Porcentagem_de_Retencao__c
                                // PLV-4234 FIM

                        FROM
                                RemuneracoesOrcamento__r
                ),
                (
                        SELECT
                                Bairro__c,
                                CEP__c,
                                Cidade__c,
                                Complemento__c,
                                // PLV-4675 INICIO
                                Conta__r.Name,
                                Conta__r.PersonMobilePhone,
                                Conta__r.PersonHomePhone,
                                Conta__r.Phone,
                                // PLV-4675 FIM
                                Conta__c,
                                Conta__r.LastName,
                                Conta__r.NomeSocial__c,  // LECVPV-184 INICIO/FIM
                                Conta__r.PersonEmail,
                                Conta__r.Cnpj__c,
                                Conta__r.Cpf__c,
                                Conta__r.IdExterno__c,
                                Conta__r.Rg__c,
                                Conta__r.DataExpedicao__c,
                                Conta__r.OrgaoExpedidor__c,
                                Conta__r.PersonBirthDate,
                                Conta__r.EstadoCivil__c,
                                Conta__r.Nacionalidade__c,
                                Conta__r.Profissao__c,
                                Conta__r.Sexo__c,
                                Conta__r.ParentId,
                                Conta__r.RecordTypeId,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c,
                                Estado__c,
                                Id,
                                IOF__c,
                                Logradouro__c,
                                Name,
                                NumeroEndereco__c,
                                Numero__c,
                                Orcamento__c,
                                Pais__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                PremioIntegral__c, //PLV-5351 INICIO/FIM
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
                                TipoDescontoAgravo__c,
                                TipoEndereco__c,
                                TipoLogradouro__c,
                                Tipo__c
                        FROM
                                ContratantesOrcamento__r
                ),
                (
                        SELECT
                                Capital__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c,
                                DescontoAgravo__c,
                                GarantiaProduto__c,
                                //GarantiaProduto__r.Modalidade__c,
                                Garantia__c,
                                //PLV-3455 - INICIO - Incluído a sigla da garantia
                                Garantia__r.Sigla__c,
                                //PLV-3455 - FIM
                                Id,
                    		//PLV-3731 - INICIO
                                ValorCotacao__c,
                    		//PLV-3731 - FIM
                                LimiteCapital__c,
                                Name,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                Orcamento__c,
                                Percentual__c,
                                PremioIntegral__c, //PLV-5351 INICIO/FIM
                                PremioComercialDesconto__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                PremioPuroDesconto__c,
                                PremioPuroInterno__c,
                                PremioPuroResseguro__c,
                                CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                                TaxaAnual__c,
                                TaxaComercial__c,
                                TaxaMensal__c,
                                TaxaPura__c,
                                TaxaPuroInterno__c,
                                TaxaPuroResseguro__c,
                                TaxaTotal__c,
                                TipoCapital__c,
                                TipoDescontoAgravo__c,
                                IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                    			//PLV-4620 FIX 2 INICIO
                    			Tipo_de_limite_de_utilizacao__c,
                    			Limite_de_Uso__c
                    			//PLV-4620 FIX 2 FIM
                        FROM
                                CoberturasOrcamento__r
                ),
                (
                        SELECT
                                Area__c,
                                Codigo__c,
                                DataConclusao__c,
                                Descricao__c,
                                Id,
                                Justificativa__c,
                                //INICIO | PLV-4647-VI-Guilherme Brito
                                MensagemCliente__c,
                                MensagemInterna__c,
                                MensagemRepresentante__c,
                                Procedimento__c,
                                //FIM| PLV-4647-VI-Guilherme Brito
                                Name,
                                Orcamento__c,
                                Origem__c,
                                Severidade__c,
                                Status__c,
                                Tipo__c
                        FROM
                                CriticaOrcamentos__r
                )
                From
                        Opportunity
                Where
                        Numero__c = :numero
                LIMIT 1 
        ];

        return (lista.size() > 0) ? lista[0] : null;
    }

    //FIM | PLV-2355-SNIPER

    public Opportunity obterOportunidadesPorNumero(String numero)
    {
        List<Opportunity> lista =  [
                Select
                        RecordType.Name,
                        AccountId,
                        Amount,
                        CampaignId,
                        CanalDistribuicao__c,
                        CapitalSegurado__c,
                        CloseDate,
                        CodigoCorretor__c,
                        Congenere__c,
                        ConnectionReceivedId,
                        ConnectionSentId,
                        ContractId,
                        Contract.Id,
                        Contract.Name,
                        Contract.Endosso__c,
                        Contract.NumeroApolice__c,
                        Contract.Empresa__c,
                        Contract.Sucursal__c,
                        Contract.CodigoRamo__c,
                        Contract.Proposta__r.Empresa__r.Cnpj__c,
                        Contract.Proposta__r.Account.Sucursal__c,
                        Contract.Proposta__r.RamoSeguro__r.Codigo__c,
                        Contract.Proposta__r.Contract.Name,
                        Contract.Proposta__r.Contract.Endosso__c,
                        Contract.Proposta__r.Id,
                        Contract.Proposta__r.Name,
                        Contract.Proposta__r.NumeroProposta__c,
                        Contract.Proposta__r.CartaoCredito__c,
                        Contract.Proposta__r.ContactId,
                        Contract.Proposta__r.ContractId,
                        Contract.Proposta__r.DataCriacaoPortal__c,
                        Contract.Proposta__r.DataEmissao__c,
                        Contract.Proposta__r.DataProtocolo__c,
                        Contract.Proposta__r.DiasAnalise__c,
                        Contract.Proposta__r.Discount,
                        Contract.Proposta__r.Email,
                        Contract.Proposta__r.Empresa__c,
                        Contract.Proposta__r.CanalDistribuicao__c,
                        Contract.Proposta__r.GrandTotal,
                        Contract.Proposta__r.ImprimirCertificadoSeguro__c,
                        Contract.Proposta__r.InformacaoBancaria__c,
                        Contract.Proposta__r.IOF__c,
                        Contract.Proposta__r.IPCA__c,
                        Contract.Proposta__r.Modalidade__c,
                        Contract.Proposta__r.OpportunityId,
                        Contract.Proposta__r.Phone,
                        Contract.Proposta__r.PremioParcela__c,
                        Contract.Proposta__r.QuantidadeParcelas__c,
                        Contract.Proposta__r.RecordTypeId,
                        Contract.Proposta__r.Reenquadramento__c,
                        Contract.Proposta__r.ResponsavelFinanceiro__c,
                        Contract.Proposta__r.TipoCusteio__c,
                        Contract.Proposta__r.TipoCusteioEstipulante__c,
                        Contract.Proposta__r.TipoCusteioSegurado__c,
                        Contract.Proposta__r.TecnicoResponsavel__c,
                        Contract.Proposta__r.AccountId,
                        Contract.Proposta__r.MeioComercializacao__c,
                        Contract.Proposta__r.Produto__c,
                        Contract.Proposta__r.Status,
                        Contract.Proposta__r.Origem__c,
                        Contract.Proposta__r.DataCalculo__c,
                        Contract.Proposta__r.TipoVigencia__c,
                        Contract.Proposta__r.VigenciaInicial__c,
                        Contract.Proposta__r.VigenciaFinal__c,
                        Contract.Proposta__r.Tipo__c,
                        Contract.Proposta__r.ValorPremio__c,
                        Contract.Proposta__r.TipoEvento__c,
                        Contract.Proposta__r.InformacoesEvento__c,
                        Contract.Proposta__r.TipoViagem__c,
                        Contract.Proposta__r.RamoSeguro__c,
                        Contract.Proposta__r.CodigoCorretor__c,
                        Contract.Proposta__r.Description,
                        Contract.Proposta__r.FormaPagamento__c,
                        Contract.Proposta__r.IdContratoParceiro__c,
                        Contract.Proposta__r.IdContratanteParceiro__c,
                        Contract.Proposta__r.Parceiro__c,
                        Contract.Proposta__r.AdditionalAddress,
                        Contract.Proposta__r.AdditionalName,
                        Contract.Proposta__r.BillingAddress,
                        Contract.Proposta__r.BillingName,
                        Contract.Proposta__r.CanalDistribuicao__r.Sigla__c,
                        Contract.Proposta__r.CanalDistribuicao__r.Name,
                        Contract.Proposta__r.Produto__r.ProductCode,
                        Contract.Proposta__r.Produto__r.Description,
                        Contract.Proposta__r.Produto__r.NumeroSusep__c,
                        Contract.Proposta__r.Produto__r.Empresa__r.CodigoEmpresa__c,
                        Contract.Proposta__r.Produto__r.Empresa__r.Name,
                        Contract.Proposta__r.Produto__r.Empresa__c,
                        Contract.Proposta__r.Produto__r.Name,
                        Contract.Proposta__r.HistoricoStatus__c,
                        Contract.Proposta__r.CodigoCorretor__r.Name,
                        Contract.Proposta__r.CodigoCorretor__r.SucursalVinculo__c,
                        Contract.Proposta__r.Empresa__r.CodigoEmpresa__c,
                        Contract.Proposta__r.RamoSeguro__r.Name,
                        Contract.Proposta__r.Empresa__r.Sucursal__c,
                        Contract.Proposta__r.Account.Idade__c,
                        Contract.Proposta__r.RecordType.DeveloperName,
                        Contract.Proposta__r.Empresa__r.Name,
                        Contract.Proposta__r.Modalidade__r.Codigo__c,
                        Contract.Proposta__r.Modalidade__r.Descricao__c,
                        Contract.Proposta__r.Opportunity.Numero__c,
                        Contract.Proposta__r.Opportunity.NumeroPortal__c,
                        Contract.Proposta__r.Opportunity.CanalDistribuicao__c,
                        Contract.Proposta__r.Opportunity.CanalDistribuicao__r.Sigla__c,
                        Contract.Proposta__r.Opportunity.HaControlePublico__c,
                        Contract.Proposta__r.Opportunity.EventoLocalFechadoDelimitado__c,
                        Contract.Proposta__r.Opportunity.ViagemAventura__c,
                        Contract.Proposta__r.Opportunity.UtilizaMoto__c,
                        Contract.Proposta__r.Opportunity.IncluiPaisEuropeu__c,
                        Contract.Proposta__r.Opportunity.PossuiTrackageBagagem__c,
                        Contract.Proposta__r.Opportunity.QuantidadePassageirosNaoIdosos__c,
                        Contract.Proposta__r.Opportunity.QuantidadePassageirosIdosos__c,
                        //PLV-3879 - INICIO
                        Contract.Proposta__r.Opportunity.PaisesDestino__c,
                        //PLV-3879 - FIM
                        Contract.Proposta__r.Payload__c,
                        Contract.Proposta__r.PremioComercial__c,
                        Contract.Proposta__r.PremioPuro__c,
                        Contract.Proposta__r.PremioTotal__c,
                        Contract.Proposta__r.TaxaComercial__c,
                        Contract.Proposta__r.TaxaPura__c,
                        Contract.Proposta__r.TaxaTotal__c,
                        Contract.Proposta__r.DescontoAgravoPercentualTecnico__c,
                        Contract.Proposta__r.DescontoAgravoPercentualComercial__c,
                        Contract.Proposta__r.DescontoAgravoMonetarioComercial__c,
                        Contract.Proposta__r.DescontoAgravoMonetarioTecnico__c,
                        Contract.Proposta__r.DescontoAgravoPercentualInformado__c,
                        Contract.Proposta__r.DescontoAgravoMonetarioInformado__c,
                        CorretorPrincipal__c,
                        CreatedById,
                        CreatedDate,
                        CurrencyIsoCode,
                        CusteioSegurado__c,
                        CusteioSubEstipulante__c,
                        CustoApolice__c,
                        DataCalculo__c,
                        DataCriacaoPortal__c,
                        Dependentes__c,
                        DescontoAgravoComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoPremioComercial__c,
                        DescontoPremioPuro__c,
                        Description,
                        Destino__c,
                        Encargos__c,
                        EventoLocalFechadoDelimitado__c,
                        ExpectedRevenue,
                        FaixaIdade__c,
                        FaixaRenda__c,
                        Fiscal,
                        FiscalQuarter,
                        FiscalYear,
                        ForecastCategory,
                        ForecastCategoryName,
                        FormaCusteio__c,
                        FormaPagamento__c,
                        FormaTrabalho__c,
                        HaControlePublico__c,
                        HasOpenActivity,
                        HasOpportunityLineItem,
                        HasOverdueTask,
                        Id,
                        IncluiPaisEuropeu__c,
                        InformacoesEvento__c,
                        Iof__c,
                        IsClosed,
                        IsDeleted,
                        IsPrivate,
                        IsWon,
                        Juros__c,
                        JustificativasPareceres__c,
                        LastActivityDate,
                        LastModifiedById,
                        LastModifiedDate,
                        LastReferencedDate,
                        LastViewedDate,
                        LeadSource,
                        LivreEscolha__c,
                        MeioComercializacao__c,
                        MultiploSalarial__c,
                        Name,
                        Nome_Social__c, // LECVPV-188(CANCELAMENTO) INICIO/FIM
                        NextStep,
                        NumeroPortal__c,
                        Numero__c,
                        ObservacoesGerais__c,
                        OrcamentoAfastamento__c,
                        Origem__c,
                        OwnerId,
                        //PLV-3879 - INICIO
                        PaisesDestino__c,
                        //PLV-3879 - FIM
                        Payload__c,
                        Percentual__c,
                        PossuiAfastados__c,
                        PossuiTrackageBagagem__c,
                        PremioComercial__c,
                        PremioInformado__c,
                        PremioPuroInterno__c,
                        PremioPuroResseguro__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        PrestadoresServicosEstagiarios__c,
                        Pricebook2Id,
                        Probability,
                        Produto__c,
                        ProtecaoParaQuem__c,
                        QuantidadeDias__c,
                        QuantidadeFuncionarios__c,
                        QuantidadeMotoboys__c,
                        QuantidadeMotoristas__c,
                        QuantidadeParcelas__c,
                        QuantidadePassageiros070Anos__c,
                        QuantidadePassageirosIdosos__c,
                        QuantidadePassageirosNaoIdosos__c,
                        QuantidadePassageiros__c,
                        QuantidadeSocios__c,
                        QuantidadeVidas__c,
                        RecordTypeId,
                        Sinistralidade__c,
                        StageName,
                        SyncedQuoteId,
                        SystemModstamp,
                        TaxaAnual__c,
                        TaxaComercial__c,
                        TaxaMensal__c,
                        TaxaPuraInterna__c,
                        TaxaPuraResseguro__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        TaxaVigencia__c,
                        TempoPermanencia__c,
                        TipoAdesao__c,
                        TipoCalculo__c,
                        TipoDescontoAgravo__c,
                        TipoEvento__c,
                        TipoEndosso__c,
                        TipoProtecao__c,
                        TipoSegurado__c,
                        TipoViagem__c,
                        TipoVigencia__c,
                        TotalOpportunityQuantity,
                        Total__c,
                        TransferenciaCongenere__c,
                        Type,
                        UtilizaMoto__c,
                        ViagemAventura__c,
                        VidasEntre7074Anos__c,
                        VidasEntre7190Anos__c,
                        VigenciaFinal__c,
                        VigenciaInicial__c,
                        VigenciaMenor365Dias__c,
                        // PLV-4606 - INICIO
                        PorQuantoTempoQuerGarantirRenda__c,
                        Produto__r.ProductCode,
                        EntradaNegocio__c,
                        RamoOrcamento__c,
                        Segmento__c,
                        CanalDistribuicao__r.Sigla__c,
                        // PLV-4606 - FIM
                (
                        SELECT
                                Id,
                                Empresa__r.Cnpj__c,
                                Account.Sucursal__c,
                                RamoSeguro__r.Codigo__c,
                                Contract.Name,
                                Contract.Endosso__c,
                                Tipo__c
                        FROM
                                Quotes
                        //WHERE
                        //    Status__c = :'Devolvida'
                        LIMIT 1
                ),
                (
                        SELECT
                                Id,
                                ImprimirCodigoOperacao__c,
                                Name,
                                Percentual__c,
                                TipoRemuneracao__c,
                                TipoRemuneracao__r.Codigo__c // PLV-4606
                        FROM
                                RemuneracoesOrcamento__r
                ),
                (
                        SELECT
                                Bairro__c,
                                CEP__c,
                                Cidade__c,
                                Complemento__c,
                                Conta__c,
                                Conta__r.LastName,
                                Conta__r.PersonEmail,
                                Conta__r.Cnpj__c,
                                Conta__r.Cpf__c,
                                Conta__r.IdExterno__c,
                                Conta__r.Rg__c,
                                Conta__r.DataExpedicao__c,
                                Conta__r.OrgaoExpedidor__c,
                                Conta__r.PersonBirthDate,
                                Conta__r.EstadoCivil__c,
                                Conta__r.Nacionalidade__c,
                                Conta__r.Profissao__c,
                                Conta__r.Sexo__c,
                                Conta__r.ParentId,
                                Conta__r.RecordTypeId,
                                // PLV-4606 INICIO
                                Conta__r.MelhorPeriodoContato__c,
                                Conta__r.Pep__c,
                                Conta__r.Type,
                                Conta__r.Renda__c,
                                Conta__r.Name,
                                Conta__r.NomeSocial__c, // LECVPV-188(CANCELAMENTO) INICIO/FIM
                                Conta__r.Profissao__r.Id,
                                Conta__r.PaisResidencia__c,
                                Conta__r.Profissao__r.Codigo__c,
                                Conta__r.DocIndentificacao__c,
                                Conta__r.ResideBrasil__c,
                                Conta__r.Fumante__c,
                                Conta__r.Idade__c,
                                Conta__r.TipoDocidentificacao__c,
                                Conta__r.RegimeTrabalho__c,
                                Conta__r.PersonHomePhone,
                                Conta__r.Phone,
                                Conta__r.PersonMobilePhone,
                                // PLV-4606 FIM
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c,
                                Estado__c,
                                Id,
                                IOF__c,
                                Logradouro__c,
                                Name,
                                NumeroEndereco__c,
                                Numero__c,
                                Orcamento__c,
                                Orcamento__r.PremioTotal__c, //PLV-3989 - INICIO/FIM - Premio total para fins de parcelamento
                                Pais__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
                                TipoDescontoAgravo__c,
                                TipoEndereco__c,
                                TipoLogradouro__c,
                                Tipo__c
                        FROM
                                ContratantesOrcamento__r
                ),
                (
                        SELECT
                                Capital__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c,
                                DescontoAgravo__c,
                                GarantiaProduto__c,
                                Garantia__c,
                                Id,
                                IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                LimiteCapital__c,
                                Name,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                Orcamento__c,
                                Percentual__c,
                                PremioComercialDesconto__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                PremioPuroDesconto__c,
                                PremioPuroInterno__c,
                                PremioPuroResseguro__c,
                                CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                                TaxaAnual__c,
                                TaxaComercial__c,
                                TaxaMensal__c,
                                TaxaPura__c,
                                TaxaPuroInterno__c,
                                TaxaPuroResseguro__c,
                                TaxaTotal__c,
                                TipoCapital__c,
                                TipoDescontoAgravo__c
                        FROM
                                CoberturasOrcamento__r
                ),
                (
                        SELECT
                                Area__c,
                                Codigo__c,
                                DataConclusao__c,
                                Descricao__c,
                                Id,
                                Justificativa__c,
                                // INICIO | PLV-4647-VI-Guilherme Brito
                                MensagemCliente__c,
                                MensagemInterna__c,
                                MensagemRepresentante__c,
                                Procedimento__c,
                                //FIM| PLV-4647-VI-Guilherme Brito
                                Name,
                                Orcamento__c,
                                Origem__c,
                                Severidade__c,
                                Status__c,
                                Tipo__c
                        FROM
                                CriticaOrcamentos__r
                )
                From
                        Opportunity
                Where
                        Numero__c = :numero
                LIMIT 1
        ];

        return (lista.size() > 0) ? lista[0] : null;
    }

    public List<Opportunity> buscarOportunidadesPorId(Set<Id> oportunidadeIds)
    {
        return
        [
                SELECT
                        Id,
                        Name,
                        //PLV2365: INICIO
                        ContadorOrcamento__c,
                        NumeroPortal__c,
                        //PLV2365: FIM
                        AccountId,
                        Account.Name,
                        Account.Cnpj__c,
                        Account.Cpf__c,
                        Account.RamoAtividade__c,
                        Account.PersonBirthdate,
                        Account.Idade__c,
                        Account.Sexo__c,
                        Account.Fumante__c,
                        Account.Profissao__c,
                        Account.Renda__c,
                        Account.RecordType.DeveloperName,
                        CanalDistribuicao__c,
                        CustoApolice__c,
                        CloseDate,
                        DataCalculo__c,
                        DescontoAgravoComercial__c,
                        DescontoPremioPuro__c,
                        DescontoPremioComercial__c,
                        Description,
                        Encargos__c,

                        /*
                        Endereco__c,
                        Endereco__r.CEP__c,
                        Endereco__r.TipoEndereco__c,
                        *
                        Campo comentado para deletar Lookup Endereco__c de Opportunity
                        Sprint 13, PLV-952
                        Histórias relacionadas - PLV-953/959/999
                        */
                        IOF__c,
                        Juros__c,
                        JustificativasPareceres__c,
                        MeioComercializacao__c,
                        OwnerId,
                        Payload__c,
                        Percentual__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioPuroInterno__c,
                        PremioPuroResseguro__c,
                        PremioInformado__c,
                        PremioTotal__c,
                        Probability,
                        Produto__c,
                        Produto__r.ProductCode,
                        Produto__r.Name,
                        QuantidadeDias__c,
                        RecordTypeId,
                        RecordType.DeveloperName,
                        StageName,
                        TaxaAnual__c,
                        TaxaComercial__c,
                        TaxaMensal__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        TaxaPuraResseguro__c,
                        TaxaPuraInterna__c,
                        VigenciaFinal__c,
                        VigenciaInicial__c,
                        //PLV-4544 - Inicio
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoPercentualFormaPagto__c,
                        DescontoAgravoMonetarioFormaPagto__c,
                        DescontoAgravoPercentualParcelamento__c,
                        DescontoAgravoMonetarioParcelamento__c,
                        //PLV-4544 - Fim
                (
                        SELECT
                                Id,
                                Orcamento__c,
                                Status__c,
                                Area__c
                        FROM
                                CriticaOrcamentos__r
                ),
                (
                        SELECT
                                Capital__c,
                                IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                DescontoAgravo__c,
                                Garantia__c,
                                Garantia__r.Sigla__c, //PLV-4544 - Inicio/Fim
                                GarantiaProduto__c,
                                LimiteCapital__c,
                                NumeroSorte__c,
                                NumeroSerie__c,
                                Orcamento__c,
                                Percentual__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                PremioComercialDesconto__c,
                                PremioPuroDesconto__c,
                                PremioPuroResseguro__c,
                                PremioPuroInterno__c,
                                CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                                TaxaAnual__c,
                                TaxaComercial__c,
                                TaxaMensal__c,
                                TaxaPura__c,
                                TaxaPuroInterno__c,
                                TaxaTotal__c,
                                TipoCapital__c,
                                TaxaPuroResseguro__c
                        FROM
                                CoberturasOrcamento__r
                ),
                (
                        SELECT
                                Id,
                                Percentual__c,
                                TipoRemuneracao__c,//PLV-4851 - INICIO/FIM
                                TipoRemuneracao__r.Name,//PLV-4851 - INICIO/FIM
                                TipoRemuneracao__r.Codigo__c//PLV-4851 - INICIO/FIM
                        FROM
                                RemuneracoesOrcamento__r
                ),
                (
                        SELECT
                                Id,
                                Conta__r.Name,
                                Conta__r.Idade__c,
                                Conta__r.Cpf__c,
                                Conta__r.Cnpj__c,
                                Conta__r.RecordType.DeveloperName,
                                Conta__r.PersonAssistantPhone,
                                Conta__r.PersonHomePhone,
                                Conta__r.Phone,
                                Conta__r.FirstName,
                                Conta__r.LastName,
                                Conta__r.PersonEmail,
                                conta__r.ramoatividade__r.NumeroCnae__c,
                                conta__r.ramoatividade__r.NomeAtividadeCnae__c,
                                Conta__r.Sexo__c,
                                Conta__r.Profissao__c,
                                Conta__r.Pep__c,
                                Conta__r.EstadoCivil__c,
                                Conta__r.PersonBirthdate,
                                Conta__r.OrgaoExpedidor__c,
                                Conta__r.Rg__c,
                                Conta__r.DataExpedicao__c,
                                Conta__r.Nacionalidade__c,
                                Tipo__c,
                                Bairro__c,
                                Cidade__c,
                                Complemento__c,
                                Conta__c,
                                Estado__c,
                                IOF__c,
                                Logradouro__c,
                                Numero__c,
                                NumeroEndereco__c,
                                Orcamento__c,
                                Pais__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
                                TipoEndereco__c,
                                TipoLogradouro__c
                        FROM
                                ContratantesOrcamento__r
                )

                From
                        Opportunity
                Where
                        Id IN: oportunidadeIds
        ];
    }

    public List<Opportunity> buscarOportunidadesPorNumero(Set<String> setNumero){
        return [
                Select
                        Id,
                        Name,
                        AccountId,
                        Account.Name,
                        Account.Cnpj__c,
                        Account.Cpf__c,
                        Account.RamoAtividade__c,
                        Account.PersonBirthdate,
                        Account.Idade__c,
                        Account.Sexo__c,
                        Account.Fumante__c,
                        Account.Profissao__c,
                        Account.Renda__c,
                        Account.RecordType.DeveloperName,
                        CanalDistribuicao__c,
                        DescontoAgravoComercial__c,
                        JustificativasPareceres__c,
                        OwnerId,
                        Payload__c,
                        Percentual__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioPuroInterno__c,
                        PremioPuroResseguro__c,
                        PremioInformado__c,
                        PremioTotal__c,
                        Produto__c,
                        Produto__r.ProductCode,
                        Produto__r.Name,
                        RecordTypeId,
                        RecordType.DeveloperName,
                        StageName,
                        TaxaAnual__c,
                        TaxaComercial__c,
                        TaxaMensal__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        Juros__c,
                        IOF__c,
                        Encargos__c,
                        CustoApolice__c,
                        DescontoPremioPuro__c,
                        DescontoPremioComercial__c,
                        TaxaPuraResseguro__c,
                        TaxaPuraInterna__c,
                (
                        SELECT
                                Id,
                                Orcamento__c,
                                Status__c,
                                Area__c
                        FROM
                                CriticaOrcamentos__r
                ),
                (
                        SELECT
                                Capital__c,
                                DescontoAgravo__c,
                                Garantia__c,
                                GarantiaProduto__c,
                                LimiteCapital__c,
                                NumeroSorte__c,
                                NumeroSerie__c,
                                Orcamento__c,
                                Percentual__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                PremioComercialDesconto__c,
                                PremioPuroDesconto__c,
                                PremioPuroResseguro__c,
                                PremioPuroInterno__c,
                                CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                                TaxaAnual__c,
                                TaxaComercial__c,
                                TaxaMensal__c,
                                TaxaPura__c,
                                TaxaPuroInterno__c,
                                TaxaTotal__c,
                                TipoCapital__c,
                                TaxaPuroResseguro__c
                        FROM
                                CoberturasOrcamento__r
                ),
                (
                        SELECT
                                Id,
                                Percentual__c,
                                TipoRemuneracao__c
                        FROM
                                RemuneracoesOrcamento__r
                ),
                (
                        SELECT
                                Id,
                                Conta__r.Name,
                                Conta__r.Idade__c,
                                Conta__r.Cpf__c,
                                Conta__r.Cnpj__c,
                                Conta__r.RecordType.DeveloperName,
                                Conta__r.PersonAssistantPhone,
                                Conta__r.PersonHomePhone,
                                Conta__r.Phone,
                                Conta__r.FirstName,
                                Conta__r.LastName,
                                Conta__r.PersonEmail,
                                conta__r.ramoatividade__r.NumeroCnae__c,
                                conta__r.ramoatividade__r.NomeAtividadeCnae__c,
                                Conta__r.Sexo__c,
                                Conta__r.Profissao__c,
                                Conta__r.Pep__c,
                                Conta__r.EstadoCivil__c,
                                Conta__r.PersonBirthdate,
                                Conta__r.OrgaoExpedidor__c,
                                Conta__r.Rg__c,
                                Conta__r.DataExpedicao__c,
                                Conta__r.Nacionalidade__c,
                                Tipo__c,
                                Bairro__c,
                                Cidade__c,
                                Complemento__c,
                                Conta__c,
                                Estado__c,
                                IOF__c,
                                Logradouro__c,
                                Numero__c,
                                NumeroEndereco__c,
                                Orcamento__c,
                                Pais__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
                                TipoEndereco__c,
                                TipoLogradouro__c
                        FROM
                                ContratantesOrcamento__r
                )

                FROM
                        Opportunity
                WHERE
            //PLV-2422 -Inicio - Mudança no código devido alteração de regra de negócio 
                        Numero__c IN: setNumero
            //PLV-2422 - Fim - Mudança no código devido alteração de regra de negócio
        ];
    }

    public List<Product2> buscarRemuneracoesProduto (Set<Id> setOrcamento){

        return [
                SELECT
                        Id,
                (
                        SELECT
                                Id,
                                TipoRemuneracao__c,
                                Obrigatoria__c
                        FROM
                                RemuneracoesProduto__r
                )
                FROM
                        Product2
                WHERE
                        Id IN (SELECT Produto__c FROM Opportunity WHERE Id =: setOrcamento)
        ];
    }

    public List<Opportunity> buscarOrcamentosPorId(Set<Id> oportunidadeIds){
        return [
                Select
                        Id,
                        Name,
                        RecordTypeId,
                        RecordType.DeveloperName,
                        Numero__c,
                        Produto__c,
                        Produto__r.ProductCode,
                        Produto__r.Name,
                        MeioComercializacao__c,
                        VigenciaInicial__c,
                        VigenciaFinal__c,
                        TipoAdesao__c,
                        ObservacoesGerais__c,
                        TipoEvento__c,
                        TipoViagem__c,
                        ViagemAventura__c,
                        Utilizamoto__c,
                        //PLV-3879 - INICIO
                        PaisesDestino__c,
                        //PLV-3879 - FIM
                        Transferenciacongenere__c,
                        TipoVigencia__c,
                        Type,
                        //PLV2365: INICIO
                        DataCalculo__c,
                        //PLV2365: FIM
                        DescontoAgravoComercial__c,
                        Percentual__c,
                        HaControlePublico__c,
                        EventoLocalFechadoDelimitado__c,
                        InformacoesEvento__c,
                        IncluiPaisEuropeu__c,
                        PossuiTrackageBagagem__c,
                        QuantidadePassageirosNaoIdosos__c,
                        QuantidadePassageirosIdosos__c,
                        Congenere__c,
                        TempoPermanencia__c,
                        Sinistralidade__c,
                        Taxavigencia__c,
                        CanalDistribuicao__c,
                        //PLV2365: INICIO
                        CanalDistribuicao__r.Sigla__c,
                        //PLV2365: FIM
                        DataCriacaoPortal__c,
                        NumeroPortal__c,
                        CloseDate,
                        //PLV2365: INICIO
                        EntradaNegocio__c,
                        //PLV2365: FIM
                (
                        SELECT
                                Id,
                                Conta__r.Name,
                                Conta__r.Idade__c,
                                Conta__r.Cpf__c,
                                Conta__r.Cnpj__c,
                                Conta__r.RecordType.DeveloperName,
                                Conta__r.PersonAssistantPhone,
                                Conta__r.PersonHomePhone,
                                Conta__r.Phone,
                                Conta__r.FirstName,
                                Conta__r.LastName,
                                Conta__r.PersonEmail,
                                conta__r.ramoatividade__r.NumeroCnae__c,
                                conta__r.ramoatividade__r.NomeAtividadeCnae__c,
                                Conta__r.Sexo__c,
                                Conta__r.Profissao__c,
                                Conta__r.Pep__c,
                                Conta__r.EstadoCivil__c,
                                Conta__r.PersonBirthdate,
                                Conta__r.OrgaoExpedidor__c,
                                Conta__r.Rg__c,
                                Conta__r.DataExpedicao__c,
                                Conta__r.Nacionalidade__c,
                                Tipo__c,
                                Bairro__c,
                                Cidade__c,
                                Complemento__c,
                                Conta__c,
                                Estado__c,
                                IOF__c,
                                Logradouro__c,
                                Numero__c,
                                NumeroEndereco__c,
                                Orcamento__c,
                                Pais__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
                                TipoEndereco__c,
                                TipoLogradouro__c
                        FROM
                                ContratantesOrcamento__r
                ),
                (
                        SELECT
                                Id,
                                Percentual__c,
                                TipoRemuneracao__c
                        FROM
                                RemuneracoesOrcamento__r
                )
                From
                        Opportunity
                Where
                        Id IN: oportunidadeIds
        ];
    }

    public List<GrupoOrcamento__c> buscarGruposOrcamento(Id oportunidadeId){
        return [
                SELECT
                        Id,
                        Name,
                        Descricao__c,
                        QuantidadeVidas__c,
                        ContratanteOrcamento__c,
                        ContratanteOrcamento__r.Orcamento__c,
                        ContratanteOrcamento__r.Orcamento__r.Name,
                        //PLV2365: INICIO
                        Numero__c,
                        //PLV-4544 - Inicio
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,
                        //PLV-4544 - Fim
                (
                    SELECT
                        Id,
                        GrupoOrcamento__c,
                        Conta__c,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        Name,
                        Numero__c
                    FROM
                        SeguradosOrcamento__r
                ),
                //PLV2365: FIM

                (
                        SELECT
                                Id,
                                Valor__c,
                                GarantiaProduto__r.Garantia__r.Sigla__c,
                                Quantidade__c,
                                ClausulaReducaoFranquiaAcidente__c,
                                //PLV-4544 - Inicio
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
                                IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                DescontoAgravoPercentualTecnico__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoMonetarioInformado__c,
                                //PLV-4544 - Fim
                                Capital__c
                        FROM
                                GruposGarantiaOrcamento__r
                )
                FROM
                        GrupoOrcamento__c

                WHERE
                        ContratanteOrcamento__r.Orcamento__c =: oportunidadeId

                ORDER BY
                        Id DESC
        ];
    }

    public List<GarantiaOrcamento__c> buscarGarantiasOrcamento(Set<Id> setOrcamentoId){
        return [
                SELECT
                        Id,
                        Capital__c,
                        PremioComercial__c,
                        PremioComercialDesconto__c,
                        PremioPuro__c,
                        PremioPuroDesconto__c,
                        PremioPuroInterno__c,
                        PremioPuroResseguro__c,
                        PremioTotal__c,
                        CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                        TaxaAnual__c,
                        TaxaComercial__c,
                        TaxaMensal__c,
                        TaxaPura__c,
                        TaxaPuroInterno__c,
                        TaxaPuroResseguro__c,
                        TaxaTotal__c,
                        DescontoAgravo__c,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        Percentual__c,
                        Garantia__c,
                        Garantia__r.Name,
                        Garantia__r.Sigla__c,
                        LimiteCapital__c,
                        Name,
                        Orcamento__c,
                        TipoCapital__c,
                        Orcamento__r.PremioComercial__c,
                        Orcamento__r.PremioPuro__c,
                        Orcamento__r.PremioPuroInterno__c,
                        Orcamento__r.PremioPuroResseguro__c,
                        Orcamento__r.PremioTotal__c,
                        Orcamento__r.TaxaAnual__c,
                        Orcamento__r.TaxaComercial__c,
                        Orcamento__r.TaxaMensal__c,
                        Orcamento__r.TaxaPura__c,
                        Orcamento__r.TaxaTotal__c,
                        GarantiaProduto__c,
                        GarantiaProduto__r.Garantia__r.Name,
                        GarantiaProduto__r.Garantia__r.Sigla__c,
                        //PLV-4620 FIX 2 INICIO
                        Tipo_de_limite_de_utilizacao__c,
                        Limite_de_Uso__c
                        //PLV-4620 FIX 2 FIM            
                FROM
                        GarantiaOrcamento__c
                WHERE
                        Orcamento__c IN: setOrcamentoId
        ];

    }

    public List<ContratanteOrcamento__c> buscarContratantesOrcamento(Set<Id> setOrcamentoId){
        return [
                SELECT
                        Id,
                        Conta__c,
                        Conta__r.Name,
                        TaxaPura__c,
                        TaxaComercial__c,
                        TaxaTotal__c,
                        PremioPuro__c,
                        PremioComercial__c,
                        PremioTotal__c,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        Tipo__c,
                        Conta__r.Idade__c,
                        Conta__r.Cpf__c,
                        Conta__r.Cnpj__c,
                        Conta__r.RecordType.DeveloperName,
                        Conta__r.PersonAssistantPhone,
                        Conta__r.PersonHomePhone,
                        Conta__r.Phone,
                        Conta__r.FirstName,
                        Conta__r.LastName,
                        Conta__r.PersonEmail,
                        conta__r.ramoatividade__r.NumeroCnae__c,
                        conta__r.ramoatividade__r.NomeAtividadeCnae__c,
                        Conta__r.sexo__c,
                        Conta__r.profissao__c,
                        Conta__r.pep__c,
                        Conta__r.EstadoCivil__c,
                        Conta__r.PersonBirthdate,
                        Conta__r.OrgaoExpedidor__c,
                        Conta__r.rg__c,
                        Conta__r.DataExpedicao__c,
                        Conta__r.Nacionalidade__c,
                        Conta__r.IdExterno__c,
                        Numero__c,
                (
                        SELECT
                                Id,
                                Name,
                                Numero__c,
                                IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                DescontoAgravo__c,
                                Percentual__c,
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                QuantidadeVidas__c,
                                CodigoArquivo__c,
                                TipoCalculo__c
                        FROM
                                GruposOrcamento__r
                ),
                (
                        SELECT
                                Id,
                                Capital__c,
                                PremioComercial__c,
                                PremioComercialDesconto__c,
                                PremioPuro__c,
                                PremioPuroDesconto__c,
                                PremioPuroInterno__c,
                                PremioPuroResseguro__c,
                                PremioTotal__c,
                                CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                                IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                TaxaAnual__c,
                                TaxaComercial__c,
                                TaxaMensal__c,
                                TaxaPura__c,
                                TaxaPuroInterno__c,
                                TaxaPuroResseguro__c,
                                TaxaTotal__c,
                                DescontoAgravo__c,
                                Percentual__c,
                                Garantia__c,
                                Garantia__r.Name,
                                Garantia__r.Sigla__c,
                                GarantiaProduto__c,
                                GarantiaProduto__r.Garantia__r.Name,
                                GarantiaProduto__r.Garantia__r.Sigla__c
                        FROM
                                GarantiasContratanteOrcamento__r
                )
                FROM
                        ContratanteOrcamento__c
                WHERE
                        Orcamento__c IN : setOrcamentoId
        ];
    }



    public List<SeguradoOrcamento__c> buscarSeguradosOrcamentoPorGrupo(Id grupoOrcamentoId) {
        return [
                SELECT
                        Id,
                        Name,
                        CPF__c,
                        DataNascimento__c,
                        Afastado__c,
                        CID__c,
                        Numero__c
                // TODO: eric  as garantias do grupo não serao relacionadas com o segurado
                //,
                // (
                // SELECT
                //         Id,
                //         GarantiaOrcamento__r.Garantia__r.Sigla__c,
                //         GarantiaProduto__r.Garantia__r.Sigla__c,
                //         GarantiaReferenciada__c,
                //         DescontoAgravo__c,
                //         Valor__c,
                //         Percentual__c,
                //         IncluirIndenizacaoEspecial__c,
                //         PercentualIndenizacaoEspecial__c,
                //         IncluirFilhos__c,
                //         PercentualFilhos__c,
                //         ClausulaReducaoFranquiaAcidente__c,
                //         Quantidade__c,
                //         Capital__c
                // FROM
                //         GarantiasSeguradoOrcamento__r
                // )

                FROM
                        SeguradoOrcamento__c
                WHERE
                        GrupoOrcamento__c =: grupoOrcamentoId];
    }


    public List<GrupoOrcamento__c> buscarGruposDoOrcamento(Set<Id> setGrupos) {
        return [
                SELECT
                        Id,
                        DescontoAgravo__c,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        Percentual__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                (
                        SELECT
                                Id,
                                Capital__c,
                                PremioComercial__c,
                                PremioComercialDesconto__c,
                                PremioPuro__c,
                                PremioPuroDesconto__c,
                                PremioPuroInterno__c,
                                PremioPuroResseguro__c,
                                PremioTotal__c,
                                IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                                TaxaAnual__c,
                                TaxaComercial__c,
                                TaxaMensal__c,
                                TaxaPura__c,
                                TaxaPuroInterno__c,
                                TaxaPuroResseguro__c,
                                TaxaTotal__c,
                                DescontoAgravo__c,
                                Percentual__c,
                                GarantiaProduto__c,
                                GarantiaProduto__r.Garantia__r.Name,
                                GarantiaProduto__r.Garantia__r.Sigla__c,
                                Garantia__r.Name,
                                Garantia__r.Sigla__c
                        FROM
                                GruposGarantiaOrcamento__r

                )
                FROM
                        GrupoOrcamento__c
                WHERE
                        Id =: setGrupos
        ];
    }

    public List<GarantiaGrupoOrcamento__c> buscarGarantiasGrupoOrcamentoPorGrupo(Set<Id> setGrupoId){
        return [
                SELECT
                        Id,
                        Capital__c,
                        CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                        DescontoAgravo__c,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        GarantiaProduto__c,
                        GrupoOrcamento__c,
                        // TODO: eric  as garantias do grupo do orcamento não serao relacionadas com o segurado
                        //SeguradoOrcamento__c,
                        PremioComercial__c
                FROM
                        GarantiaGrupoOrcamento__c
                WHERE
                        GrupoOrcamento__c IN : setGrupoId
        ];
    }



    public List<GarantiaContratanteOrcamento__c> buscarGarantiasContratanteOrcamentoPorSegurados(Set<Id> setSeguradoId){
        return [
                SELECT
                        Id,
                        Capital__c,
                        CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                        DescontoAgravo__c,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        GarantiaProduto__c,
                        ContratanteOrcamento__c,
                        PremioComercial__c
                FROM
                        GarantiaContratanteOrcamento__c
                WHERE
                        ContratanteOrcamento__c IN: setSeguradoId
        ];
    }




    public List<GarantiaGrupoOrcamento__c> buscarTodasGarantiasGrupoOrcamento(Id oportunidadeId){
        return [
                SELECT
                        Id,
                        Capital__c,
                        DescontoAgravo__c,
                        GarantiaProduto__c,
                        GarantiaProduto__r.Garantia__r.Sigla__c,
                        GrupoOrcamento__c,
                        // TODO: eric  as garantias do grupo do orcamento não serao relacionadas com o segurado
                        //SeguradoOrcamento__c,
			PremioComercial__c,
                        Percentual__c,
                        IncluirIndenizacaoEspecial__c,
                        PercentualIndenizacaoEspecial__c,
                        IncluirFilhos__c,
                        PercentualFilhos__c,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        PremioPuro__c,
                        PremioComercialDesconto__c,
                        PremioPuroInterno__c,
                        PremioPuroResseguro__c,
                        PremioTotal__c,
                        CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                        Quantidade__c,
                        GrupoOrcamento__r.Numero__c,
                        GrupoOrcamento__r.ContratanteOrcamento__r.Numero__c
                FROM
                        GarantiaGrupoOrcamento__c
                WHERE
                        GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c = :oportunidadeId
        ];
    }



    // TODO: eric  as garantias do grupo do orcamento não serao relacionadas com o segurado
//   public List<GarantiaGrupoOrcamento__c> buscarTodasGarantiasVidaOrcamento(Id oportunidadeId){
//     return [
//             SELECT
//                     Id,
//                     Capital__c,
//                     DescontoAgravo__c,
//                     GarantiaProduto__c,
//                     GarantiaProduto__r.Garantia__r.Sigla__c,
//                     GrupoOrcamento__c,
//                     SeguradoOrcamento__c,
//                     PremioComercial__c,
//                     Percentual__c,
//                     IncluirIndenizacaoEspecial__c,
//                     PercentualIndenizacaoEspecial__c,
//                     IncluirFilhos__c,
//                     PercentualFilhos__c,
//                     TaxaComercial__c,
//                     TaxaPura__c,
//                     TaxaTotal__c,
//                     PremioPuro__c,
//                     PremioComercialDesconto__c,
//                     PremioPuroInterno__c,
//                     PremioPuroResseguro__c,
//                     PremioTotal__c,
//                     Quantidade__c,
//                     SeguradoOrcamento__r.Numero__c,
//                     SeguradoOrcamento__r.GrupoOrcamento__r.Numero__c,
//                     SeguradoOrcamento__r.GrupoOrcamento__r.ContratanteOrcamento__r.Numero__c
//             FROM
//                     GarantiaGrupoOrcamento__c
//             WHERE
//                     SeguradoOrcamento__r.GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c = :oportunidadeId
//     ];
//   }


    /******************************************** FINADA ORCAMENTO DAO ************************************************************/
    //TODO: UNIFICAR ESSES METODOS COM OS DE CIMA


    public List<GarantiaOrcamento__c> buscarGarantiasOrcamentoPorOrcamento(Set<Id> setOrcamentoIds) {
        return [SELECT
                Id,
                Orcamento__c,
                Garantia__c,
                LimiteCapital__c
        FROM
                GarantiaOrcamento__c
        WHERE
                Orcamento__c IN :setOrcamentoIds];
    }

    //PLV-4544 - Inicio
    public List<SeguradoOrcamento__c> buscarSeguradosOrcamentoPorOrcamento(Set<Id> setOrcamentoIds) {
        return [SELECT
                Id,
                GrupoOrcamento__c,
                Conta__c,
                IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                PremioComercial__c,
                PremioPuro__c,
                PremioTotal__c,
                TaxaComercial__c,
                TaxaPura__c,
                TaxaTotal__c,
                DescontoAgravoPercentualTecnico__c,
                DescontoAgravoMonetarioTecnico__c,
                DescontoAgravoPercentualComercial__c,
                DescontoAgravoMonetarioComercial__c,
                DescontoAgravoPercentualInformado__c,
                DescontoAgravoMonetarioInformado__c,
                (
                        SELECT 
                        Id,
                        Capital__c,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,
                        Garantia__r.Sigla__c
                        FROM GarantiasSeguradoOrcamento__r
                )
        FROM
                SeguradoOrcamento__c
        WHERE
                GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c IN :setOrcamentoIds];
    }

    public List<GrupoOrcamento__c> buscarGruposOrcamentoPorOrcamento(Set<Id> setOrcamentoIds) {
        return [
                SELECT
                        Id,
                        ContratanteOrcamento__c,
                        ContratanteOrcamento__r.Orcamento__c,
                        Descricao__c,
                        Name,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        PremioPuro__c,
                        PremioComercial__c,
                        PremioTotal__c,
                        TaxaPura__c,
                        TaxaComercial__c,
                        TaxaTotal__c,
                        QuantidadeVidas__c,
                        Percentual__c,
                        DescontoAgravo__c,
                        ContratanteOrcamento__r.Numero__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,
                        Numero__c,
                        (
                                SELECT 
                                        Id,
                                        Capital__c,
                                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                        PremioPuro__c,
                                        PremioComercial__c,
                                        PremioTotal__c,
                                        TaxaPura__c,
                                        TaxaComercial__c,
                                        TaxaTotal__c,
                                        DescontoAgravoPercentualTecnico__c,
                                        DescontoAgravoMonetarioTecnico__c,
                                        DescontoAgravoPercentualComercial__c,
                                        DescontoAgravoMonetarioComercial__c,
                                        DescontoAgravoPercentualInformado__c,
                                        DescontoAgravoMonetarioInformado__c,
                                        Garantia__r.Sigla__c
                                FROM GruposGarantiaOrcamento__r
                        )
                FROM
                        GrupoOrcamento__c
                WHERE
                        ContratanteOrcamento__r.Orcamento__c IN :setOrcamentoIds
        ];
    }
    //PLV-4544 - Fim


    public List<SeguradoOrcamento__c> buscarVidasOrcamentoPorOrcamento(Set<Id> setOrcamentoIds) {
        return [SELECT
                Id,
                GrupoOrcamento__c,
                GrupoOrcamento__r.ContratanteOrcamento__c,
                GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c,
                Conta__c,
                Name,
                //PLV-2826 - INICIO - Criar oportunidade sem conta
                GrupoOrcamento__r.ContratanteOrcamento__r.Conta__c,
                GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.AccountId                
                //PLV-2826 - FIM - Criar oportunidade sem conta
        FROM
                SeguradoOrcamento__c
        WHERE
                GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c IN :setOrcamentoIds];
    }


    public List<GarantiaGrupoOrcamento__c> buscarGarantiasGrupoOrcamentoPorOrcamento(Set<Id> setOrcamentoIds) {
        return [SELECT
                Id,
                GrupoOrcamento__c,
                GrupoOrcamento__r.ContratanteOrcamento__c,
                GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c,
                Name
        FROM
                GarantiaGrupoOrcamento__c
        WHERE
                GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c IN :setOrcamentoIds];
    }
    //ANNVI-41 INICIO
    public List<Opportunity> buscarProduPorNumero (String numeroOpp){
        return [SELECT
                Id,
                Produto__c
        FROM
                Opportunity 
        WHERE
                Numero__c  = :numeroOpp];
    }
    //ANNVI-41 FIM
}