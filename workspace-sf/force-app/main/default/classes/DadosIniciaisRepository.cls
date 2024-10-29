public class DadosIniciaisRepository {

    public static Contract getOriginalContract (String numApolice){
        return [
            SELECT Id              
                , StartDate
                , Nome_Social__c // LECVPV-188 INICIO/FIM
                , DataEndosso__c
                , VigenciaFinal__c
                , PremioTotal__c
                , ValorIOF__c
                , Tipo__c 
                , Produto__c
                , TaxaPura__c
                , TaxaComercial__c
                , TaxaTotal__c
                , PremioComercial__c
                , PremioPuro__c
                , PremioIntegral__c 
                , Produto__r.ProductCode
                , AccountId
                , Proposta__c
                , Proposta__r.DataCalculo__c 
                , NumeroApolice__c
                , Tarifa__c
                , DLL__c 
                , DescontoAgravoPercentualTecnico__c
                , DescontoAgravoMonetarioTecnico__c
                , DescontoAgravoPercentualComercial__c
                , DescontoAgravoMonetarioComercial__c
                , DescontoAgravoPercentualFormaPagto__c
                , DescontoAgravoMonetarioFormaPagto__c
                , DescontoAgravoPercentualInformado__c
                , DescontoAgravoMonetarioInformado__c
                , DescontoAgravoPercentualParcelamento__c
                , DescontoAgravoMonetarioParcelamento__c
            FROM Contract
            WHERE NAME =: numApolice
        ];
    }

    public static List<GarantiaContrato__c> getOriginalGuarantee(Id originalContractId){
        return [
            SELECT Id
                , Garantia__r.Sigla__c
                , GarantiaProduto__r.QuantidadeMaximaContratacao__c
                , capital__c
                , TaxaPura__c
                , TaxaComercial__c
                , TaxaTotal__c
                , PremioComercial__c
                , PremioPuro__c
                , PremioTotal__c
                , PremioIntegral__c 
                , IOF__c
                , DescontoAgravoPercentualTecnico__c
                , DescontoAgravoMonetarioTecnico__c
                , DescontoAgravoPercentualComercial__c
                , DescontoAgravoMonetarioComercial__c
                , DescontoAgravoPercentualFormaPagto__c
                , DescontoAgravoMonetarioFormaPagto__c
                , DescontoAgravoPercentualInformado__c
                , DescontoAgravoMonetarioInformado__c
                , Limite_de_Uso__c
                , Tipo_de_limite_de_utilizacao__c
            FROM GarantiaContrato__c
            WHERE Contrato__c =: originalContractId
        ];
    }

    public static List<FranquiaGarantia__c> getFranchiseGuarantee(Set<String> siglaCobertura, Id productId){
        return [
            SELECT Id
                , Franquia__r.CodigoFranquia__c
                , Franquia_Padrao__c
                , GarantiaProduto__r.Garantia__r.Sigla__c
                , GarantiaProduto__r.QuantidadeMaximaContratacao__c         
            FROM FranquiaGarantia__c
            WHERE Franquia_Padrao__c = true 
                AND GarantiaProduto__r.Garantia__r.Sigla__c  IN: siglaCobertura
                AND GarantiaProduto__r.Produto__c =: productId
        ];
    }

    public static ContratanteContrato__c getContractorOfContract(Id originalContractId ){
        return [
            SELECT Id,
                CartaoCredito__c,
                CartaoCredito__r.Bandeira__c,
                CartaoCredito__r.CartoPortoSeguro__c,
                CartaoCredito__r.NomeTitular__c,
                CartaoCredito__r.Vencimento__c,
                CartaoCredito__r.VencimentoCriptografado__c,
                CartaoCredito__r.Ticket__c,
                Conta__c,
                CpfCnpj__c,
                DescontoAgravoMonetarioComercial__c,
                DescontoAgravoMonetarioFormaPagto__c,
                DescontoAgravoMonetarioInformado__c,
                DescontoAgravoMonetarioTecnico__c,
                DescontoAgravoPercentualComercial__c,
                DescontoAgravoPercentualFormaPagto__c,
                DescontoAgravoPercentualInformado__c,
                DescontoAgravoPercentualTecnico__c,
                DiasPagamento__c,
                FormaPagamento__c,
                FormaPagamento__r.Codigo__c,
                FormaPagamento__r.Name,
                InformacaoBancaria__c,
                InformacaoBancaria__r.Agencia__c,
                InformacaoBancaria__r.Banco__c,
                InformacaoBancaria__r.Digito__c,
                InformacaoBancaria__r.NumeroConta__c,
                InformacaoBancaria__r.TipoPessoa__c,
                IOF__c,
                Name,
                Nome__c,
                NomeContratante__c,
                NomeSocial_do_Contratante__c, // LECVPV-188 INICIO/FIM
                Numero__c,
                PlanoParcelamento__c,
                PlanoParcelamento__r.CodigoMeioRecebimento__c,
                PremioComercial__c,
                PremioIntegral__c,
                PremioPuro__c,
                PremioTotal__c,
                QuantidadeParcelas__c,
                ResponsavelPagamento__c,
                ResponsavelPagamento__r.Email__c,
                ResponsavelPagamento__r.Cpf__c,
                ResponsavelPagamento__r.Name,
                ResponsavelPagamento__r.PersonHomePhone,
                ResponsavelPagamento__r.PersonMobilePhone,
                ResponsavelPagamento__r.Phone,
                TaxaComercial__c,
                TaxaPura__c,
                TaxaTotal__c,
                TipoResponsavelPagamento__c,
                Tipo__c,
                VencimentoDemaisParcelas__c,
                VencimentoPrimeiraParcela__c,
                VigenciaInicial__c
            FROM ContratanteContrato__c
            WHERE Contrato__c = :originalContractId
        ];
    }

    public static GrupoContrato__c getGroupContract(Id contractorId){
        return [ 
            SELECT Id,
                DescontoAgravoMonetarioComercial__c,
                DescontoAgravoMonetarioFormaPagto__c,
                DescontoAgravoMonetarioInformado__c,
                DescontoAgravoMonetarioTecnico__c,
                DescontoAgravoPercentualComercial__c,
                DescontoAgravoPercentualFormaPagto__c,
                DescontoAgravoPercentualInformado__c,
                DescontoAgravoPercentualTecnico__c,
                IOF__c,
                Name,
                Numero__c,
                PremioComercial__c,
                PremioIntegral__c,
                PremioPuro__c,
                PremioTotal__c,
                QuantidadeVidas__c,
                TaxaComercial__c,
                TaxaPura__c,
                TaxaTotal__c,
                TipoCalculo__c
            FROM GrupoContrato__c
            WHERE ContratanteContrato__c = :contractorId
        ];
    }

    public static SeguradoContrato__c getContractInsured(Id grupoOriginalId){
        return[
            SELECT 
                Id, 
                Numero__c, 
                Conta__c,
                melhorPeriodo__c,
                PEP__c,
                email__c,
                CPF__c,
                logradouroResidencial__c,
                numeroResidencial__c,
                BairroResidencial__c,
                ComplementoResidencial__c,
                CidadeResidencial__c,
                paisResidencial__c,
                cepResidencial__c,
                UFResidencial__c,
                EstadoCivil__c,
                Nome__c,
                NomeSocial__c, // LECVPV-188 INICIO/FIM
                NomeSocial_do_Segurado__c, // LECVPV-188 INICIO/FIM
                RendaMensal__c,
                Celular__c,
                TelefoneResidencial__c,
                TelefoneComercial__c,
                DocumentoIdentificacao__c,
                Nacionalidade__c,
                PaisDeOrigem__c,
                OrgaoExpedidorDocumento__c,
                TipoDocIdentificacao__c,
                DataExpedicaoDocumentoIdentificacao__c,
                IOF__c,
                Profissao__r.CodigoProfissao__c,
                Conta__r.Profissao__r.CodigoProfissao__c,
                Conta__r.Fumante__c,
                Conta__r.PersonBirthdate,
                Conta__r.Sexo__c,
                Conta__r.RegimeTrabalho__c,
                Conta__r.CPF__c,
                Conta__r.NomeSocial__c, // LECVPV-188 INICIO/FIM
                DescontoAgravoPercentualTecnico__c,
                DescontoAgravoPercentualInformado__c,
                DescontoAgravoPercentualFormaPagto__c,
                DescontoAgravoPercentualComercial__c,
                DescontoAgravoMonetarioTecnico__c,
                DescontoAgravoMonetarioInformado__c,
                DescontoAgravoMonetarioFormaPagto__c,
                DescontoAgravoMonetarioComercial__c,
                PremioPuro__c,
                PremioTotal__c,
                PremioIntegral__c,
                PremioComercial__c,
                TaxaComercial__c,
                TaxaPura__c,
                TaxaTotal__c,
                LogradouroComercial__c,
                NumeroComercial__c,
                BairroComercial__c,
                ComplementoComercial__c,
                CidadeComercial__c,
                UFComercial__c,
                PaisComercial__c,
                CEPComercial__c,
                CicloVacinal__c, 
                    (SELECT 
                        ID,
                        TipoBeneficiario__c,
                        Participacao__c,
                        GrauParentesco__c,
                        BeneficiarioGrauParentescoOutros__c,
                        MotivoSemCpfCnpj__c,
                        Data_de_Nascimento__c,
                        PercentualIndenizacao__c,
                        CpfCnpj__c,
                        Nome__c,
                        NomeSocial__c, // LECVPV-188 INICIO/FIM
                        Sexo__c,
                        ImprimirCertificadoSeguro__c
                    FROM Benefici_rios_dos_segurados_do_contrato__r)
            FROM SeguradoContrato__c WHERE GrupoContrato__c =: grupoOriginalId
        ];
    }

    public static List<RemuneracaoContrato__c> getContractRemuneration(Id originalContractId){
        return[
            SELECT 
                Id, 
                Percentual__c, 
                TipoRemuneracao__c,
                TipoRemuneracao__r.Codigo__c,
                    (SELECT 
                        ID,
                        Papel__c,
                        Conta__c,
                        Participacao__c,
                        CorretorLider__c,
                        Susep__c,
                        AntecipacaoComissao__c,
                        Conta__r.Name
                    FROM FavorecidosContrato__r)
            FROM  RemuneracaoContrato__c 
            WHERE Contrato__c = :originalContractId
        ];
    }

    public static List<FavorecidoRemuneracaoContrato__c> getFavoredContractRemuneration(List<RemuneracaoContrato__c> originalRemuneration){
        return[
            SELECT Id, 
                Papel__c, 
                Participacao__c, 
                CorretorLider__c, 
                Susep__c, 
                AntecipacaoComissao__c, 
                Conta__c, 
                RemuneracaoContrato__c 
            FROM FavorecidoRemuneracaoContrato__c WHERE RemuneracaoContrato__c IN :originalRemuneration
        ];
    }

    public static List<Account> getAccountsWithIdInSet(Set<Id> accountIds){
        return[
            SELECT Id, 
                Type,Renda__c, 
                Name, 
                Cnpj__c , 
                Cpf__c, 
                RecordTypeId, 
                Sexo__c, 
                Profissao__c, 
                RegimeTrabalho__c, 
                PersonBirthdate  
            FROM Account 
            WHERE Id IN :accountIds
        ];
    }

    public static List<GrupoProfissoes__c> getProfessionsGroupByCode(String professionCode){
        return[
            SELECT Id, 
                GrupoRisco__c, 
                GrupoRisco__r.Name
            FROM GrupoProfissoes__c 
            WHERE Profissao__r.CodigoProfissao__c =: professionCode
        ];
    }
}