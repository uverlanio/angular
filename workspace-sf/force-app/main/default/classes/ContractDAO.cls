/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pela busca de dados do objeto de Contract
 *
 **************************************************************************************************************************************************************************/
public  class ContractDAO
{
    private static final ContractDAO instancia = new ContractDAO();

    private ContractDAO() {	}

    public static ContractDAO getInstance(){
        return instancia;
    }

    // PLV-2312-28 INICIO
    public List<Contract> buscarContratos(Set<Id> setContratoId){
        return
        [
                SELECT
                        Id,
                        Segmento__c, // PLV-4816-COMPLEMENTO
                        Parceiro__c,
                        AccountId,
                        Account.Name,
                        Account.IdExterno__c,
                        Empresa__c,
                        Sucursal__c,
                        CodigoModalidade__c, // PLV-4720
                        RamoSeguro__r.Codigo__c,
                        RamoSeguro__r.CodigoOrigemDoMovimentoBCP__c, // PVL-3855
                        RamoSeguro__c,
                        Name,
                        Endosso__c,
                        IdContrato__c,
                        IdContratoParceiro__c,
                        CodigoRamo__c,
                        // PLV-4606 - INICIO
                        Tarifa__c, 
                        DescontoAgravoPercentualFormaPagto__c,
                        DescontoAgravoMonetarioFormaPagto__c,
                        TipoDescontoAgravo__c,
                        Proposta__r.PremioTotal__c,
                        Proposta__r.CupomDesconto__c,  // AV-664 INICIO/FIM
                        // PLV-4606 - FIM
                        NumeroApolice__c,
                        Senha__c, //FNPVVEP-108 INICIO/FIM
                        DistributionPublicUrl__c, //FNPVVEP-108 INICIO/FIM
                        Account.PersonEmail, //FNPVVEP-108 INICIO/FIM
                        NumeroProposta__c,
                        Tipo__c,
                        Status,
                        StartDate,
                        VigenciaFinal__c,
                        CanalDistribuicao__r.Sigla__c,
                        CodigoCorretor__r.Name,
                        TipoEndosso__c,
                        DataEmissao__c,
                        //PLV-5883 INICIO
                        PremioPuro__c,
                        PremioComercial__c,
                        PremioTotal__c,
                        ValorIOF__c,
                        //PLV-5883 FIM
                        //PLV-4601 INICIO
                        NumeroPropostaUnico__c,
                        Account.Cpf__c,
                        Account.Cnpj__c,
                        Account.Tributavel__c,
                        ContratoOriginal__c,
                        ContratoOriginal__r.Id,
                        ContratoOriginal__r.StartDate, // PLV-4601-FIX2
                        ContratoOriginal__r.VigenciaFinal__c, // PLV-4601-FIX2
                        ContratoOriginal__r.PremioComercial__c, // PLV-4601-FIX2
                        ContratoOriginal__r.PremioTotal__c, // PLV-4601-FIX2
                        //PLV-4601 FIM
                        // PLV-4488 INICIO
                        SiglaTipoEndosso__c,
                        Proposta__r.SiglaTipoEndosso__c,
                        // PLV-4488 FIM
                        MeioComercializacao__c,
                        Produto__c,
            			//3458 - INICIO
            			origem__c,
            			//3458 - FIM
                        Produto__r.ProductCode,
                        Produto__r.CodigoPrecificaProduto__c, //PLV-5392-INICIO/FIM
                        Payload__c,
                        Proposta__c,
                        Proposta__r.Id,
                        Proposta__r.DataCalculo__c,
                        Proposta__r.IdContratoParceiro__c,
                        Proposta__r.IdContratanteParceiro__c,
                        Proposta__r.MeioComercializacao__c,
                        Proposta__r.Name,
                        Proposta__r.NumeroProposta__c,
                        Proposta__r.Parceiro__c,
                        Proposta__r.Origem__c,
                        Proposta__r.Tipo__c,
                        Proposta__r.TipoEndosso__c,
                        Proposta__r.TipoVigencia__c,
                        Proposta__r.Status,
                        Proposta__r.ValorPremio__c,
                        Proposta__r.CanalDistribuicao__r.Sigla__c,
                        Proposta__r.CanalDistribuicao__r.Name,
                        Proposta__r.Empresa__c,
                        Proposta__r.Empresa__r.Sucursal__c,
                        Proposta__r.IOF__c,
                        Proposta__r.Produto__c,
                        Proposta__r.Produto__r.Id,
                        Proposta__r.Produto__r.Name,
                        Proposta__r.Produto__r.ProductCode,
                        Proposta__r.Produto__r.Empresa__c,
                        Proposta__r.Produto__r.Empresa__r.CodigoEmpresa__c,
                        Proposta__r.Produto__r.Empresa__r.Name,
                        Proposta__r.Produto__r.NumeroSusep__c,
                        Proposta__r.OpportunityId,
                        Proposta__r.Opportunity.Id,
                        Proposta__r.Opportunity.CanalDistribuicao__r.Sigla__c,
                        Proposta__r.Opportunity.StageName,
                        Proposta__r.Opportunity.Numero__c,
                        Proposta__r.Opportunity.Name,
                        Proposta__r.Opportunity.MeioComercializacao__c,
                        Proposta__r.Contract.Id,
                        Proposta__r.Contract.Status,
                        Proposta__r.Contract.Name,
                        Proposta__r.Contract.Endosso__c,
                        Proposta__r.Contract.Empresa__c,
                        Proposta__r.Contract.NumeroApolice__c,
                        Proposta__r.Contract.NumeroProposta__c,
                        Proposta__r.Contract.RamoSeguro__c,
                        Proposta__r.Contract.RamoSeguro__r.Id,
                        Proposta__r.Contract.RamoSeguro__r.Codigo__c,
                        Proposta__r.Contract.Sucursal__c,
                        Proposta__r.Contract.Produto__c, // PLV-4660-FIX 2
                        Proposta__r.Contract.Parceiro__c, // PLV-4660
                        Proposta__r.Contract.DataEmissao__c, // PLV-5033 INICIO/FIM
                        Proposta__r.RamoSeguro__c,
                        Proposta__r.RamoSeguro__r.Name,
                        Proposta__r.RamoSeguro__r.Codigo__c,
                        Proposta__r.RamoSeguro__r.CodigoOrigemDoMovimentoBCP__c, // PVL-3855
                        Proposta__r.RamoSeguro__r.CodigoEmpresa__c, // PLV-4606
                        Proposta__r.RecordType.DeveloperName,
                        Proposta__r.VigenciaInicial__c,
                        Proposta__r.VigenciaFinal__c,
                        Proposta__r.Lote__c,
                        Proposta__r.NomeArquivo__c,
                        // PLV-4606 INICIO
                        Proposta__r.TermoGuarda__c,
                        Proposta__r.TermoResponsabilidade__c,
                        Proposta__r.AssinaturaEletronica__c,
                        Proposta__r.ScoreFraude__c,
                        Proposta__r.FormaReceberApolice__c,
                        Proposta__r.Modalidade__r.CodigoEmpresa__c,
                        // PLV-4606 FIM
                (
                        SELECT
                                Id,
                                // PLV-4606 - INICIO
                                Tipo__c, 
                                NomeSocial_do_Contratante__c, // LECVPV-188(CANCELAMENTO) INICIO/FIM
                                Numero__c, 
                                TaxaTotal__c, 
                                NomeContratante__c,
                                CpfCnpj__c,
                                Conta__r.RecordType.DeveloperName,
                                TipoDescontoAgravo__c,
                                DescontoAgravoPercentualTecnico__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualFormaPagto__c,
                                DescontoAgravoMonetarioFormaPagto__c,
                                PlanoParcelamento__c,
                                PlanoParcelamento__r.DescricaoMeioRecebimento__c,
                                PlanoParcelamento__r.CodigoMeioRecebimento__c,
                                // PLV-4606 - FIM
                                QuantidadeParcelas__c,
                                PremioTotal__c,
                                VencimentoPrimeiraParcela__c,
                                ResponsavelPagamento__c,
                                TipoResponsavelPagamento__c,
                                Conta__c,
                                PremioComercial__c,
                                PremioIntegral__c, //PLV-5351 - INICIO/FIM
                                PremioPuro__c,
                                TaxaComercial__c,
                                TaxaPura__c,
                                Contrato__c, //FNPVVEP-108 INICIO/FIM
                                //PLV-4438 - Inicio
                                VencimentoDemaisParcelas__c,
                                FormaPagamento__c,
                                FormaPagamento__r.Codigo__c,
                                FormaPagamento__r.Name,
                                //PLV-4438 - Fim
                    		IOF__c 
                        FROM
                                ContratantesContrato__r
                ),// PLV-4606 - INICIO
                (
                        SELECT 
                                Id,
                                Percentual__c,
                                TipoRemuneracao__r.Name
                        FROM
                                RemuneracoesContrato__r
                ),// PLV-4606 - FIM
                (
                        SELECT
                                id,
                                Capital__c,
                                GarantiaProduto__c,
                                Garantia__c,
                                Garantia__r.Sigla__c,
                                LimiteCapital__c,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                Percentual__c,
                                TipoCapital__c,
                                TipoDescontoAgravo__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                PremioIntegral__c, //PLV-5351 - INICIO/FIM
                                TaxaComercial__c,
                                IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                TaxaPura__c,
                                TaxaTotal__c,
                                CurrencyIsoCode, //PLV-3989 - INICIO/FIM
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c
                        FROM
                                GarantiasContrato__r
                )
                FROM
                        Contract
                WHERE
                        Id =: setContratoId
        ];
    }
    // PLV-2312-28 FIM

    // PLV-2312 INICIO
    public List<Contract> verificarContratosMassificados(){
        return [
                SELECT
                        Id
                FROM
                        Contract
                WHERE
                Status = 'Em elaboração'
                AND
                Massificados__c = true
        ];
    }
    // PLV-2312 FIM

    //PLV-2225-28 INICIO
    public List<SeguradoContrato__c> buscarSeguradoContratoPorContractId(Set<Id> setContratoId){
        return [
                SELECT
                        Id,
                        Name,
                        //PLV-5883 INICIO
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        IOF__c,
                        //PLV-5883 FIM
                        GrupoContrato__r.ContratanteContrato__r.Contrato__c
                FROM
                        SeguradoContrato__c
                WHERE
                        GrupoContrato__r.ContratanteContrato__r.Contrato__c IN: setContratoId
        ];
    }
    //PLV-2225-28 FIM

    public List<ProdutoParceiro__c> buscarProdutoDoParceiro(Set<String> setCodigoParceiro, Set<Id> setProdutos){
        return [
                SELECT
                        Id,
                        Parceiro__c,
                        Parceiro__r.Codigo__c,
                        Produto__c,
                        Produto__r.ProductCode,
                        CodigoProdutoParceiro__c
                FROM
                        ProdutoParceiro__c
                WHERE
                Produto__c IN : setProdutos
                AND
                Parceiro__r.Codigo__c IN : setCodigoParceiro         
        ];
    }

    // PLV-2312-28 INICIO
    public List<SeguradoContrato__c> buscarSeguradosContrato(Set<Id> setContratanteContrato){

        return [
                SELECT
                        Id,
                        GrupoContrato__r.ContratanteContrato__c,
                        QuantidadeParcelas__c,
                        Conta__c,
                        ResponsavelPagamento__c,
                        TipoResponsavelPagamento__c,
                        VencimentoPrimeiraParcela__c,
                        PremioIntegral__c, //PLV-5351 INICIO/FIM
                        PremioComercial__c,
                        PremioPuro__c,
                        TaxaComercial__c,
                        TaxaPura__c,
                        IOF__c,
                        PremioTotal__c
                FROM
                        SeguradoContrato__c
                WHERE
                        GrupoContrato__r.ContratanteContrato__c =: setContratanteContrato
        ];
    }
    // PLV-2312-28 FIM

    public List<Parceiro__c> buscarParceiros(Set<Id> setContaId){
        return [
                SELECT
                        Id,
                        Name,
                        Conta__c,
                        Sucursal__c,
                        Empresa__c,
                        Ramo__c,
                        Codigo__c
                FROM
                        Parceiro__c
                WHERE
                        Conta__c =: setContaId
        ];
    }

    public List<Contract> buscarContratosPorCodigo(List<String> codigos){
        return [
                SELECT
                        Id,
                        ContractNumber,
                        Proposta__c,
                        AccountId,
                        Account.Name,
                        RamoSeguro__c,
                        Name,
                        Endosso__c
                FROM
                        Contract
                WHERE
                        Name IN: codigos
        ];
    }

    // PLV-2312-28 INICIO Remocao de metodo nao utilizado
    // PLV-2312-28 INICIO Remocao de metodo nao utilizado

    public List<Contract> buscarPorNumeroApolice(Set<String> numerosApolice){
        return [
                SELECT
                        Id,
                        Name,
                        Status,
                        Endosso__c,
                        Proposta__r.Opportunity.Name,
                        Proposta__r.Produto__r.ProductCode,
                        Proposta__r.ValorPremio__c,
                        Proposta__r.Parceiro__c,
                        Proposta__r.VigenciaInicial__c,
                        Proposta__r.VigenciaFinal__c,
                        Proposta__r.TipoVigencia__c,
                        Proposta__r.IdContratoParceiro__c,
                        Proposta__r.IdContratanteParceiro__c,
                        Proposta__r.Modalidade__c,
                        Proposta__r.Modalidade__r.Codigo__c,
                        //Proposta__r.RecordType.DeveloperName,
                (
                        SELECT
                                Id,
                                Tipo__c,
                                TipoResponsavelPagamento__c,
                                ResponsavelPagamento__c
                        FROM
                                ContratantesContrato__r
                )
                FROM
                        Contract
                WHERE
                        Name IN :numerosApolice
        ];
    }

    // Comentado na QuoteBO
//    public List<Contract> buscarContratosPorId(Set<Id> Ids){
//        return [
//                SELECT
//                        Id,
//                        Name,
//                        Endosso__c,
//                        Status
//                FROM
//                        Contract
//                WHERE
//                        Id IN: Ids
//        ];
//    }

    public List<ContratanteContrato__c> buscarContratantesPorNumeroApolice(Set<String> numerosApolice){
        return [
                SELECT
                        Id,
                        Name,
                        Contrato__c,
                        Contrato__r.Name,
                        Conta__c,
                        Conta__r.Name,
                        Conta__r.PersonEmail,
                        Conta__r.Sexo__c,
                        Conta__r.Cpf__c,
                        Conta__r.Cnpj__c,
                        Conta__r.Nacionalidade__c,
                        Conta__r.EstadoCivil__c,
                        Conta__r.PersonBirthdate,
                        Conta__r.CNAE__c,
                        Conta__r.PersonHomePhone,
                        Conta__r.Phone,
                        Conta__r.PersonAssistantPhone,
                        QuantidadeParcelas__c,
                        VencimentoPrimeiraParcela__c,
                        TipoResponsavelPagamento__c,
                        ResponsavelPagamento__c,
                        Tipo__c
                FROM
                        ContratanteContrato__c
                WHERE
                        Contrato__r.Name IN :numerosApolice
        ];
    }

    public List<GrupoContrato__c> buscarGruposPorNumeroApolice(Set<String> numerosApolice){
        return [
                SELECT
                        Id,
                        Name,
                        QuantidadeVidas__c,
                        ContratanteContrato__c,
                (
                        SELECT
                                Id,
                                Name,
                                Conta__r.Name,
                                Conta__r.PersonEmail,
                                Conta__r.Sexo__c,
                                Conta__r.Cpf__c,
                                Conta__r.Cnpj__c,
                                Conta__r.CNAE__c,
                                Conta__r.Nacionalidade__c,
                                Conta__r.EstadoCivil__c,
                                Conta__r.PersonBirthdate
                        FROM
                                SeguradosContrato__r
                )

                FROM
                        GrupoContrato__c
                WHERE
                        ContratanteContrato__r.Contrato__r.Name IN :numerosApolice
        ];
    }

    public List<GrupoContrato__c> buscarGruposPorContratante(Set<String> setContratantes)
    {
        return [
                SELECT
                        Id,
                        Name,
                        QuantidadeVidas__c,
                        ContratanteContrato__c,
                        Descricao__c,
                        TipoCalculo__c,
                        Numero__c,
                        TipoDescontoAgravo__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        PremioIntegral__c, //PLV-5351 - INICIO/FIM
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoPercentualTecnico__c,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                (
                        SELECT
                                Id,
                                Name,
                                Conta__c,
                                EnderecoBoleto__c,
                                IOF__c,
                                IPCA__c,
                                PorcentagemParticipacaoSegurado__c,
                                PorcentagemParticipacaoVida__c,
                                QuantidadeParcelas__c,
                                Reenquadramento__c,
                                Numero__c,
                                TipoCusteio__c,
                                TipoDescontoAgravo__c,
                                TipoResponsavelPagamento__c,
                                VencimentoPrimeiraParcela__c,
                                PremioComercial__c,
                                PremioParcela__c,
                                PremioIntegral__c, //PLV-5351 - INICIO/FIM
                                PremioPuro__c,
                                PremioTotal__c,
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c

                        FROM
                                SeguradosContrato__r
                ),
                (
                        SELECT
                                Id,
                                IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                Capital__c,
                                GarantiaProduto__c,
                                Garantia__c,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                Percentual__c,
                                TipoDescontoAgravo__c,
                                ValorCotacao__c,
                                Valor__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioIntegral__c, //PLV-5351 - INICIO/FIM
                                PremioTotal__c,
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
				        CurrencyIsoCode, //PLV-3926 - INICIO/FIM
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c
                        FROM
                                GarantiasGrupoContrato__r
                )
                FROM
                        GrupoContrato__c
                WHERE
                        GrupoContrato__c.ContratanteContrato__c IN :setContratantes
        ];
    }

    public List<GarantiaContratanteContrato__c> buscarGarantiasContratante(Set<String> setContratantes)
    {
        return
        [
                SELECT
                        Id,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        ContratanteContrato__c,
                        Capital__c,
                        GarantiaProduto__c,
                        Garantia__c,
                        NumeroSerie__c,
                        NumeroSorte__c,
                        Percentual__c,
                        TipoDescontoAgravo__c,
                        ValorCotacao__c,
                        Valor__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        PremioIntegral__c, //PLV-5351 - INICIO/FIM
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
            			CurrencyIsoCode, //PLV-3926 - INICIO/FIM
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoPercentualTecnico__c
                FROM
                        GarantiaContratanteContrato__c
                WHERE
                        ContratanteContrato__c =: setContratantes
        ];
    }

    public List<GarantiaSeguradoContrato__c> buscarGarantiasSegurado(Set<String> setSegurados)
    {
        return
        [
                SELECT
                        Id,
                        IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        SeguradoContrato__c,
                        Capital__c,
                        GarantiaProduto__c,
                        Garantia__c,
                        NumeroSerie__c,
                        NumeroSorte__c,
                        Percentual__c,
                        TipoDescontoAgravo__c,
                        ValorCotacao__c,
                        Valor__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        PremioIntegral__c, //PLV-5351 - INICIO/FIM
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        TipoCapital__c, //PLV-4707 - Inicio/Fim
            			CurrencyIsoCode, //PLV-3926 - INICIO/FIM
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioInformado__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoPercentualTecnico__c
                FROM
                        GarantiaSeguradoContrato__c
                WHERE
                        SeguradoContrato__c =: setSegurados
        ];
    }

    public List<Contract> buscarContratoPorProposta(String empresa, String ramo, String origem, String proposta){
        return [
                SELECT
                        Id,
                        Name,
                        Empresa__c,
                        Proposta__r.Origem__c,
                        Proposta__r.NumeroProposta__c,
                        Proposta__r.Name,
                        DataEmissao__c,
                        RamoSeguro__r.Codigo__c,
                        Proposta__r.Modalidade__c,
                        Proposta__r.Modalidade__r.Codigo__c,
                        Sucursal__c,
                        Endosso__c,
                        StartDate,
                        EndDate,
                        VigenciaFinal__c,
                        FormaPagamento__r.Codigo__c,
                        ValorPremio__c,
                        Proposta__r.QuantidadeParcelas__c,
                        CodigoCorretor__r.Name,
                        Tipo__c,
                        TipoEndosso__c,
                (
                        SELECT
                                Id,
                                Conta__r.Name,
                                FormaPagamento__r.Codigo__c,
                                QuantidadeParcelas__c,
                                Tipo__c
                        FROM
                                ContratantesContrato__r
                )
                FROM
                        Contract
                WHERE
                Empresa__c =: empresa
                AND
                RamoSeguro__r.Codigo__c =: ramo
                AND
                Proposta__r.Origem__c =: origem
                AND
                Proposta__r.NumeroProposta__c =: proposta
        ];
    }

    public List<Contract> buscarContratoPorProposta(Set<Id> setId){
        return [
                SELECT
                        Id,
                        Contract.Name,
                        Contract.Endosso__c,
                        Contract.CodigoCorretor__r.CodigoSucursalVinculo__c,
                        Contract.FormaPagamento__r.Codigo__c,
                        Contract.Empresa__c,
                        Contract.Status,
						//PLV 4736 Inicio
						Contract.Sucursal__c,
						Contract.NumeroApolice__c,
						Contract.DataEmissao__c,
						Contract.PremioTotal__c,
						//PLV 4736 Fim
						//PLV-4736 Fix3 Inicio
						Contract.StartDate,
						Contract.VigenciaFinal__c
						//PLV-4736 Fix3 Fim
                FROM
                        Contract
                WHERE
                        Proposta__c =: setId
        ];
    }

     //PLV-5169 - INICIO
     public Contract findByContractFields(String apolice, String sucursal, String ramo, String endosso, String empresa){
        return [SELECT PremioTotal__c 
                FROM Contract 
                WHERE NumeroApolice__c =: apolice
                AND Sucursal__c =: sucursal
                AND CodigoRamo__c =: ramo
                AND Endosso__c =: endosso
                AND Empresa__c =: empresa
                ORDER BY Endosso__c 
                DESC LIMIT 1];
    }

    public Contract findByPolicyNumberAndTotalAward(String apolice){
        return [SELECT Id, Endosso__c
                FROM Contract
                WHERE NumeroApolice__c =: apolice
                AND PremioTotal__c != 0
                ORDER BY CreatedDate
                DESC LIMIT 1];
    }
   //PLV-5169 - FIM
   

    public List<Contract> buscarContratoPorName(String nameContrato){
        return [
                SELECT
                        Id,
                        Name,
                        Nome_Social__c, // LECVPV-188(CANCELAMENTO) INICIO/FIM
                        Empresa__c,
                        Proposta__r.Origem__c,
                        Proposta__r.Name,
						Proposta__r.NumeroProposta__c, //PLV-4736-Fix2 Inicio/Fim
                        DataEmissao__c,
                        RamoSeguro__r.Codigo__c,
                        Proposta__r.Modalidade__c,
                        Proposta__r.Modalidade__r.Codigo__c,
                        Sucursal__c,
                        Endosso__c,
                        Origem__c,
                        StartDate,
                        EndDate,
                        VigenciaFinal__c,
                        FormaPagamento__r.Codigo__c,
                        ValorPremio__c,
                        Proposta__r.QuantidadeParcelas__c,
                        CodigoCorretor__r.Name,
                        Tipo__c,
                        TipoEndosso__c,
                        Produto__r.NumeroSusep__c,
                        AccountId,
						//PLV-4464 Inicio
						Account.Pescod__c,
						//PLV-4464 Fim
                        CanalDistribuicao__c,
                        CodigoAnexoContrato__c,
                        CodigoCorretor__c,
                        CodigoRamo__c,
                        ContractNumber,
                        ContratoParceiro__c,
                        DadosEndosso__c,
                        Description,
                        FormaPagamento__c,
                        IdContrato__c,
                        IdExterno__c,
                        ImprimirCertificadoSeguro__c,
                        MeioComercializacao__c,
                        NumeroApolice__c,
                        Oportunidade__c,
                        Parceiro__c,
                        Parceria__c,
                        Payload__c,
                        PremioComercial__c,
                        PremioIntegral__c, //PLV-5351 - INICIO/FIM
                        PremioInformado__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        ValorIOF__c, //PLV-4660 FIX 4 - INÍCIO/FIM
                        Produto__c,
                        Proposta__c,
                        RamoSeguro__c,
                        RecordTypeId,
                        Seguradora__c,
                        Status,
                        TaxaComercial__c,
                        ContratoOriginal__r.DataEmissao__c, // PLV-4601-FIX4
                        ContratoOriginal__r.Endosso__c, // PLV-4601-FIX4
                        ContratoOriginal__r.Name, // PLV-4601-FIX3
                        ContratoOriginal__c, // PLV-4601-FIX3
                        TaxaPura__c,
                        TaxaTotal__c,
                        TipoRemuneracao__c,
                        Proposta__r.Opportunity.RecordTypeId,
                (
                        SELECT
                                Id,
                                Conta__r.Name,
                                Tipo__c,
                                FormaPagamento__r.Codigo__c,
                                Bairro__c,
                                CEP__c,
                                Cidade__c,
                                Complemento__c,
                                Conta__c,
                                TipoEndereco__c,
                                TipoLogradouro__c,
                                Estado__c,
                                Logradouro__c,
                                NumeroEndereco__c,
                                Numero__c,
                                Pais__c,
                                IOF__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                PremioIntegral__c, //PLV-5351 - INICIO/FIM
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
                                TipoDescontoAgravo__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c,
                                QuantidadeParcelas__c
                        FROM
                                ContratantesContrato__r
                ),
                (
                        SELECT
                                Id,
                                Percentual__c,
                                TipoRemuneracao__c
                        FROM
                                RemuneracoesContrato__r where TipoRemuneracao__r.Name = 'CORRETAGEM' //PLV 4709 Joao Santos
                        LIMIT 3
                ),
                (
                        SELECT
                                id,
                                IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                Capital__c,
                                GarantiaProduto__c,
                                Garantia__c,
                                LimiteCapital__c,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                Percentual__c,
                                TipoCapital__c,
                                TipoDescontoAgravo__c,
                                PremioComercial__c,
                                PremioIntegral__c, //PLV-5351 - INICIO/FIM
                                PremioPuro__c,
                                PremioTotal__c,
                                TaxaComercial__c,
                                ValorCotacao__c, //PLV-3989 - INICIO/FIM
                                TaxaPura__c,
                                TaxaTotal__c,
                                CurrencyIsoCode, //PLV-3989 - INICIO/FIM
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c
                        FROM
                                GarantiasContrato__r
                )
                FROM
                        Contract
                WHERE
                        Name =: nameContrato
        ];
    }

    public List<Contract> buscarPorNumeroApoliceEndosso(String numerosApolice, String endosso){
        return [
                SELECT
                        Id,
                        DataEmissao__c
                FROM
                        Contract
                WHERE
                Name =: numerosApolice
                AND Endosso__c =: endosso
        ];
    }

    // PLV-2372-29 INICIO
    public List<Contract> buscarContratosPorId(Set<Id> setContractId){
        return [
                SELECT
                        // Informacoes do contrato
                        Id,
                        NumeroApolice__c,
                        Status,
                        Endosso__c,
                        Produto__c,
                        //PLV-5884 FIX-02 INICIO
                        //PLV-5884 FIX-08 INICIO
                        IdContratoParceiro__c,
                        Parceiro__c, 
                        IdContratanteParceiro__c,
                        Description,
                        RamoSeguro__c,
                        ModalidadeSeguro__c,
                        TipoViagem__c,
                        Payload__c,
                        Seguradora__r.CodigoEmpresa__c,
                        PremioInformado__c,
                        //PLV-5884 FIX-08 FIM
                        VigenciaFinal__c,
                        AccountId,
                        StartDate, 
                        CanalDistribuicao__c,
                        MeioComercializacao__c,
                        //PLV-5884 FIX-02 FIM
                        // Informacoes de proposta
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
                        //Proposta__r.InformacaoBancaria__r.Banco__c,//PLV-4363 - INICIO/FIM
                        Proposta__r.InformacaoBancaria__r.Agencia__c,
                        Proposta__r.InformacaoBancaria__r.NumeroConta__c,
            			//PLV-3918-FIX6 - INICIO
            			//PLV-3918-FIX7 - INICIO
                        Proposta__r.InformacaoBancaria__r.Digito__c,
                        //PLV-3918-FIX7 - FIM
            			//PLV-3918-FIX6 - FIM
                        Proposta__r.IOF__c,
                        Proposta__r.CupomDesconto__c,  // AV-664 INICIO/FIM
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
                        Proposta__r.VigenciaFinal__c
                FROM
                        Contract
                WHERE
                        Id =: setContractId
        ];
    }
    // PLV-2372-29 FIM

    public List<GarantiaContrato__c> buscarGarantiaContratoPorId (Set<Id> setId){
        return [
                SELECT
                        Id,
                        Contrato__c,
                        GarantiaProduto__r.Modalidade__r.Codigo__c,
                        GarantiaProduto__r.OrdemPrioridade__c
                FROM
                        GarantiaContrato__c
                WHERE
                        Contrato__c = : setId
        ];
    }

    public List<RemuneracaoContrato__c> buscarRemuneracaoContratoPorId(Set<Id> setContratoId){
        return [
                SELECT
                        Id,
                        TipoRemuneracao__c,
                        TipoRemuneracao__r.Codigo__c, //PLV-4344-Fix - Inicio/Fim
                        TipoRemuneracao__r.Name,
                        RemuneracaoProduto__c,
                        Percentual__c,
                        Contrato__c, //PLV-4344-Fix - Inicio/Fim
                (
                        SELECT
                                Id,
                                Conta__c,
                                CorretorLider__c,
                                Papel__c,
                                Participacao__c,
                                RemuneracaoContrato__c,
                                Susep__c,
                                SusepEmissao__c,
                                SusepOficialCorretor__c,
                                SusepOrcamento__c,
                                Conta__r.Name,
                                Conta__r.Sexo__c,
                                Conta__r.Cnpj__c,
                                Conta__r.Cpf__c,
                                Conta__r.RecordTypeId,
                                Conta__r.EstadoCivil__c,
                                AntecipacaoComissao__c, //PLV-4344-Fix - Inicio/Fim
                                DadosCorretor__r.Name
                        FROM
                                FavorecidosContrato__r
                )
                FROM
                        RemuneracaoContrato__c
                WHERE
                        Contrato__c =: setContratoId
        ];
    }

    // PLV-2312-28 INICIO
     public List<Contract> buscarContratosAnteriores(Set<String> idsExternosContratos){ //PLV-3460 Fix 5 - INICIO/FIM  
	 	System.debug('idsExternosContratos ' + idsExternosContratos); //PLV-3460 Fix 5 - INICIO/FIM     
         return [
                SELECT
                        Id,
                        NumeroApolice__c,
                        CodigoRamo__c,
                        Endosso__c,
                        Sucursal__c,
                        Status,
                        Empresa__c,
                        RamoSeguro__c,
                        RamoSeguro__r.Codigo__c,
                        Tipo__c,
                        //PLV-2334-27 INICIO
                        StartDate,
                        VigenciaFinal__c
                        //PLV-2334-27 FINAL
                FROM
                        Contract
            	//PLV-3460 Fix 5 - INICIO
                WHERE	IdExterno__c LIKE : idsExternosContratos
             	AND	    Status = 'Emitido'
            	//PLV-3460 Fix 5 - FIM
        ];
    }
    // PLV-2312-28 FIM

    public List<CriticaContrato__c> buscarCriticaContratoByContrato(Set<Id> setContrato)
    {
        return
        [
                SELECT
                        Id
                FROM
                        CriticaContrato__c
                WHERE
                        Contrato__c IN :setContrato
        ];
    }

    public List<GarantiaSeguradoContrato__c> buscarGarantiasSeguradoContratoByContrato(Set<Id> setContrato)
    {
        return
        [
                SELECT
                        Id,
                        SeguradoContrato__c
                FROM
                        GarantiaSeguradoContrato__c
                WHERE
                        SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c IN :setContrato
        ];
    }

    public List<GarantiaGrupoContrato__c> buscarGarantiasGrupoContratoByContrato(Set<Id> setContrato)
    {
        return
        [
                SELECT
                        Id,
                        GrupoContrato__c
                FROM
                        GarantiaGrupoContrato__c
                WHERE
                        GrupoContrato__r.ContratanteContrato__r.Contrato__c IN :setContrato
        ];
    }

    public List<GarantiaContratanteContrato__c> buscarGarantiasContratanteContratoByContrato(Set<Id> setContrato)
    {
        return
        [
                SELECT
                        Id,
                        ContratanteContrato__c
                FROM
                        GarantiaContratanteContrato__c
                WHERE
                        ContratanteContrato__r.Contrato__c IN :setContrato
        ];
    }

    public List<SeguradoContrato__c> buscarListSeguradosContratoByContrato(Set<Id> setContrato)
    {
        return
        [
                SELECT
                        Id,
                        GrupoContrato__c,
                (
                        SELECT
                                Id,
                                SeguradoContrato__c
                        FROM
                                Benefici_rios_dos_segurados_do_contrato__r
                )

                FROM
                        SeguradoContrato__c
                WHERE
                        GrupoContrato__r.ContratanteContrato__r.Contrato__c =: setContrato
        ];
    }

    public List<GrupoContrato__c> buscarListGrupoContratoByContrato(Set<Id> setContrato)
    {
        return
        [
                SELECT
                        Id,
                        ContratanteContrato__c,
                        //PLV-5883 INICIO
                        IOF__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c
                        //PLV-5883 FIM
                FROM
                        GrupoContrato__c
                WHERE
                        ContratanteContrato__r.Contrato__c =: setContrato
        ];
    }

    public List<ContratanteContrato__c> buscarContratantesContratoByContrato(Set<Id> setContrato)
    {
        return
        [
                SELECT
                        Id
                FROM
                        ContratanteContrato__c
                WHERE
                        Contrato__c IN :setContrato
        ];
    }

    public Contract buscarContratoById(Id setContrato)
    { // analise 5331
        return
        [
                SELECT
                        Seguradora__c,
                        Parceria__c,
                        NumeroApolice__c,
                        CodigoRamo__c,
                        CanalDistribuicao__c,
                        AccountId,
                        Sucursal__c,
                        Endosso__c,
                        Empresa__c,
                        // PLV-1197-27 - Início
                        RamoSeguro__c,
                        RamoSeguro__r.Codigo__c,
                        Proposta__r.DataCalculo__c,
                        // PLV-1197-27 - Fim
                        RecordTypeId,
                        CodigoCorretor__c,
                        Description,
                        FormaPagamento__c,
                        Oportunidade__c,
                        Produto__c,
                        Proposta__c,
                        Status,
                        Tipo__c,
                        DataEmissao__c,
                        IdContratoParceiro__c,
                        IdContratanteParceiro__c,
                        Parceiro__c,
                        Payload__c,
                        StartDate,
                        VigenciaFinal__c,
                        MeioComercializacao__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioIntegral__c, //PLV-5351 - INICIO/FIM
                        PremioTotal__c,
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        Origem__c,
                        TipoEndosso__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoPercentualInformado__c,
                        Segmento__c, //PLV-4695-VI
                        DescontoAgravoMonetarioInformado__c,
                        Tarifa__c, //PLV-5300 - INICIO/FIM
                (
                        SELECT
                                Id
                        FROM
                                ContratantesContrato__r
                )
                FROM
                        Contract
                WHERE
                        Id =: setContrato
        ];
    }

    //PLV-3872 - INICIO - Criação da query para buscar os dados do contrato original
    public List<Contract> buscarContratoOriginalPorId(String idContrato){
        system.debug('teste ' + idContrato);
        return [
                SELECT
                        Id,
                        Name,
                        Empresa__c,
                        Proposta__r.Origem__c,
                        Proposta__r.Name,
                        DataEmissao__c,
                        RamoSeguro__r.Codigo__c,
                        Proposta__r.Modalidade__c,
                        Proposta__r.Modalidade__r.Codigo__c,
                        Sucursal__c,
                        Endosso__c,
                        Origem__c,
                        StartDate,
                        EndDate,
                        VigenciaFinal__c,
                        FormaPagamento__r.Codigo__c,
                        ValorPremio__c,
                        Proposta__r.QuantidadeParcelas__c,
                        CodigoCorretor__r.Name,
                        Tipo__c,
                        TipoEndosso__c,
                        Produto__r.NumeroSusep__c,
                        AccountId,
                        CanalDistribuicao__c,
                        CodigoAnexoContrato__c,
                        CodigoCorretor__c,
                        CodigoRamo__c,
                        ContractNumber,
                        ContratoParceiro__c,
                        DadosEndosso__c,
                        Description,
                        FormaPagamento__c,
                        IdContrato__c,
                        IdExterno__c,
                        ImprimirCertificadoSeguro__c,
                        MeioComercializacao__c,
                        NumeroApolice__c,
                        Oportunidade__c,
                        Parceiro__c,
                        Parceria__c,
                        Payload__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        PremioInformado__c,
                        PremioIntegral__c, //PLV-5351 - INICIO/FIM
                        Produto__c,
                        Proposta__c,
                        RamoSeguro__c,
                        RecordTypeId,
                        Seguradora__c,
                        Status,
                        TaxaComercial__c,

                        TaxaPura__c,
                        TaxaTotal__c,
                        TipoRemuneracao__c,
                        Proposta__r.Opportunity.RecordTypeId,
                (
                        SELECT
                                Id,
                                Conta__r.Name,
                                Tipo__c,
                                FormaPagamento__r.Codigo__c,
                                Bairro__c,
                                CEP__c,
                                Cidade__c,
                                Complemento__c,
                                Conta__c,
                                TipoEndereco__c,
                                TipoLogradouro__c,
                                Estado__c,
                                Logradouro__c,
                                NumeroEndereco__c,
                                Numero__c,
                                Pais__c,
                                ResponsavelPagamento__c,
                                TipoResponsavelPagamento__c,
                                PlanoParcelamento__c,
                                FormaPagamento__c,
                                CartaoCredito__c,
                                InformacaoBancaria__c,
                                IOF__c,
                                PremioComercial__c,
                                PremioIntegral__c, //PLV-5351 - INICIO/FIM
                                PremioPuro__c,
                                PremioTotal__c,
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
                                TipoDescontoAgravo__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c,
                                QuantidadeParcelas__c
                        FROM
                                ContratantesContrato__r
                ),
                (
                        SELECT
                                Id,
                                Percentual__c,
                                TipoRemuneracao__c
                        FROM
                                RemuneracoesContrato__r
                        LIMIT 3
                ),
                (
                        SELECT
                                id,
                                Capital__c,
                                GarantiaProduto__c,
                                Garantia__c,
                                LimiteCapital__c,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                Percentual__c,
                                TipoCapital__c,
                                TipoDescontoAgravo__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioIntegral__c, //PLV-5351 - INICIO/FIM
                                PremioTotal__c,
                                TaxaComercial__c,
                                ValorCotacao__c, 
                                TaxaPura__c,
                                TaxaTotal__c,
                                CurrencyIsoCode,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c
                        FROM
                                GarantiasContrato__r
                )
                FROM
                        Contract
                WHERE
                        Id =: idContrato
        ];
    }
    //PLV-3872 - FIM
    //PLV-4556 - INÍCIO
    public List<Contract> buscarContratosByName(Set<String> nameContrato)
    {
                return [
                        SELECT 
                                Id, 
                                Name, 
                                Empresa__c, 
                                Sucursal__c, 
                                RamoSeguro__r.Codigo__c, 
                                NumeroApolice__c, 
                                Proposta__r.DataCalculo__c, 
                                StartDate, 
                                MeioComercializacao__c, 
                                Status, 
                                StatusHeroku__c,
                                Segmento__c,
                                Endosso__c
                        FROM Contract WHERE Name IN: nameContrato 
                ];
    }
    //PLV-4556 - FIM

    //PLV-5133 - INICIO
    public String buscarNameUltimoContratoNaoCad(String apolice, String empresa, String sucursal, String ramo) {

                List<Contract> contratos = 
                        [SELECT 
                            id, Name, SiglaTipoEndosso__c
                        FROM Contract 
                        WHERE 
                            NumeroApolice__c =: apolice
                            AND Empresa__c =: empresa
                            AND Sucursal__c =: sucursal
                            AND CodigoRamo__c =: ramo
                        ORDER BY Endosso__c DESC
                    ];

                for (Contract c: contratos) {
                        
                        if (c.SiglaTipoEndosso__c == null || c.SiglaTipoEndosso__c == '') {
                                continue;
                        }

                        Boolean apenasCAD = true;
                        String[] tipos = c.SiglaTipoEndosso__c.split(';');
                        for (String t: tipos) {
                                if (t != 'CAD' && t != 'BEN') {
                                        apenasCAD = false;
                                        break;
                                }
                        }
                        if (!apenasCAD) {
                                return c.Name;
                        }
                }

                //Caso não encontrado, retorna o Name do Contrato original
                return ContractBO.getInstance().gerarNameContrato(empresa, sucursal,ramo, apolice, '0');

    }
    //PLV-5133 - FIM
     // RVI-41-INICIO
     public Map<String,dadosDocumentosPDF__mdt> buscarAssinatura(){
                List<dadosDocumentosPDF__mdt> assinaturas = [SELECT Cargo__c,Descricao_do_cargo__c,Nome__c,DeveloperName FROM dadosDocumentosPDF__mdt];
                Map<String,dadosDocumentosPDF__mdt> mapAssinatura = new Map<String,dadosDocumentosPDF__mdt>();
                for(dadosDocumentosPDF__mdt assinatura : assinaturas){
                        mapAssinatura.put(assinatura.DeveloperName,assinatura);
                }
                return mapAssinatura;
    }
    // RVI-41-FIM

    //LECVP-72 - INICIO
    public List<Contract> buscarPorNumPropostaUnico(String numeroPropostaUnico){
                return [
                        SELECT 
                                Id,
                                BCP_Ticket__c,
                                BCP_Data_Ticket__c
                                FROM
                                Contract
                        WHERE NumeroPropostaUnico__c = :numeroPropostaUnico
                        ];
    }

    public void inserirTcktBCPContrato(Contract contrato, BCPContratoTcktTO bCPContratoTcktTO){
                    
                contrato.BCP_Ticket__c = bCPContratoTcktTO.RespostaBCP?.numeroSequenciaControle;
                contrato.BCP_Data_Ticket__c = Datetime.now();            

                update contrato;
    }

    public List<Contract> buscarPorBCPTicket(Set<Id> idsContrato, Set<String> bcpTicket) {
                List<Contract> contratos = [
                        SELECT Id, BCP_Ticket__c, Proposta__c, Proposta__r.NumeroProposta__c, NumeroApolice__c
                        FROM Contract
                        WHERE Id IN :idsContrato AND BCP_Ticket__c IN :bcpTicket
                ];
                return contratos;
    }

    public List<Contract> buscar(Set<Id> idsContrato) {
                List<Contract> contratos = [
                        SELECT Id, BCP_Ticket__c
                        FROM Contract
                        WHERE Id IN :idsContrato
                ];
                return contratos;
    }
    //LECVP-72 - FIM

//////Lucas Sousa
    private String baseQuery(){
        return 'SELECT '+
            'Id, '+
            'AccountId, '+
            'Empresa__c, '+
            'Sucursal__c, '+
            'RamoSeguro__r.Codigo__c, '+
            'Numeroapolice__c, '+
            'Endosso__c, ' +
            'Status, ' +
            'DataEmissao__c, ' +
            'StartDate, ' +
            'VigenciaFinal__c, ' +
            'Proposta__r.NumeroProposta__c, ' +
            'Proposta__r.Origem__c, ' +
            'Parceria__r.SiglaParceiro__c,' +
            'Account.Cpf__c, ' +
            'Account.Name, ' +
            'Produto__c, ' +
            'Produto__r.Name, ' +
            'Produto__r.ProductCode, ' +
            'Account.PersonBirthdate, ' +
            'Account.Sexo__c, ' +
            'Proposta__r.Opportunity.CodigoCorretor__c, ' +
            'Proposta__r.Opportunity.CodigoCorretor__r.NomeCorretor__r.Name,  ' +
            'Proposta__r.Opportunity.CodigoCorretor__r.NomeCorretor__r.Email__c, ' +
            'PremioTotal__c, ' +
            'IdExterno__c, 	' +
            'ModalidadeSeguro__r.Name ' +
        'FROM Contract';
    }

    public List<Contract> findByStringQueryWithSegmentAndType(String segment, String type, String contractFilter){
        String stringQuery = baseQuery();
        stringQuery += ' Segmento__c = \''+segment+'\'';
        stringQuery += ' AND Tipo__c = \''+type+'\' ';
        stringQuery += contractFilter  + ' LIMIT 1000';
        System.debug('findByStringQueryWithSegmentAndType String Query: ' + stringQuery);

        return findByStringQuery(stringQuery);
    }

    public List<Contract> findByStringQueryWithProtuctAndStatus(Set<String> prodIdSet, String status, String contractFilter){
        String stringQuery = baseQuery();
        stringQuery += ' Produto__c IN :prodIdSet';
        stringQuery += ' AND Status = \''+status+'\'';
        stringQuery += contractFilter  + ' LIMIT 1000';
        System.debug('findByStringQueryWithProtuctAndStatus String Query: ' + stringQuery);

        return findByStringQuery(stringQuery);
    }

    public List<Contract> findByStringQueryWithStatusSegmentTypeAndDate(String status, String segment, String type, String stringDate, String contractFilter){
        String stringQuery = baseQuery();
        stringQuery += ' Status =  \''+status+'\'';
        stringQuery += ' AND Segmento__c = \''+segment+'\'';
        stringQuery += ' AND Tipo__c = \''+type+'\' ';
        stringQuery += ' AND StartDate <= '+ String.escapeSingleQuotes(stringDate);
        stringQuery += ' AND VigenciaFinal__c >= ' + String.escapeSingleQuotes(stringDate);
        stringQuery += contractFilter  + ' LIMIT 1000';
        System.debug('findByStringQueryWithStatusSegmentTypeAndDate String Query: ' + stringQuery);

        return findByStringQuery(stringQuery);
    }

    public List<Contract> findByStringQuery(String stringQuery){
        return (List<Contract>) Database.query(stringQuery);
    }
//////Lucas Sousa - END
}