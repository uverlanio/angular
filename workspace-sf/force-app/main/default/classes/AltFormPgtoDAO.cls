//II-166 - INICIO
public without sharing class AltFormPgtoDAO { //FNPVVEP-126 INICIO-FIM

    public AltFormPgtoDAO() {}
    
    public List<ContratanteProposta__c> consultarContrProp(String propostaId){
        return [
            SELECT 
                Id, 
                FormaPagamento__r.Name,
                FormaPagamento__r.Codigo__c,
                Proposta__r.Produto__c, //II-206 INICIO
                Proposta__r.AccountId,
                Conta__c,
                ResponsavelPagamento__c,
                ResponsavelPagamento__r.Name, //II-206 INICIO FIX01
                ResponsavelPagamento__r.Cpf__c, 
                ResponsavelPagamento__r.Sexo__c, 
                ResponsavelPagamento__r.PersonBirthdate, 
                ResponsavelPagamento__r.EstadoCivil__c, 
                ResponsavelPagamento__r.PersonEmail, 
                ResponsavelPagamento__r.PersonMobilePhone,
                ResponsavelPagamento__r.PersonHomePhone, //II-206 FIM FIX01
                CartaoCredito__r.IdExterno__c,
                FormaPagamento__c,
                informacaoBancaria__c,
                CartaoCredito__c, //II-206 FIM
                PremioTotal__c,
                QuantidadeParcelas__c,
                VencimentoDemaisParcelas__c,
                Proposta__r.Name, //FNPVVEP-147 INICIO/FIM
                Proposta__r.Produto__r.Name, //FNPVVEP-147 INICIO/FIM
                Nome_do_segurado__c //FNPVVEP-147 INICIO/FIM
            FROM 
                ContratanteProposta__c 
            WHERE 
                Proposta__r.Id = :propostaId
            LIMIT 1
        ];
    }

    public List<CondicaoCobranca__c> consultarQtdeParcelas(String produtoId){
        return [
            SELECT 
                Id,
                FormaPagamento__r.Codigo__c,
                NomeFormaPagamento__c,
                QuantidadeParcelas__c,
                AntecipacaoComissao__c,
                FormaPagamento__c, //II-206 INICIO/FIM
                PercentualDescontoAgravo__c //II-175 INICIO/FIM
            FROM
                CondicaoCobranca__c
            WHERE 
                Produto__c  = :produtoId
        ];
    }

    public List<RemuneracaoProposta__c> agencPercMaiorQZero(String proposta, String tipoRemuneracao){
        return [
            SELECT 
                Id,
                Percentual__c
            FROM
                RemuneracaoProposta__c
            WHERE 
                Proposta__r.Name = :proposta
            AND 
                TipoRemuneracao__r.Name = :tipoRemuneracao
        ];
    }

    public Quote verificarCodProdEmp(String proposta){
    return  [
            SELECT 
                Id, 
                Produto__r.Segmento__c, //FNPVVEP-147 INICIO/FIM
                Produto__r.ProductCode, //FNPVVEP-147 INICIO/FIM
                Produto__r.Empresa__r.CodigoEmpresa__c, 
                Account.CodigoEmpresa__c,
                Tipo__c //II-176 INICIO-FIM
            FROM
                Quote 
            WHERE 
                Name = :proposta
        ];
    }
    //II-176 INICIO
    public List<AntecipacaoComissao__c> verificaAntecipacaoProd(String produto){
        return  [
                SELECT 
                    Id,
                    //ANNVI-41 INICIO
                    QuantidadeParcelas__c,
                    AntecipacaoAutomatica__c,
                    FormaPagamento__c,
                    FormaPagamento__r.Codigo__c,           //ANNVI-41 FIX-02 INICIO/FIM
                    //ANNVI-41 FIM 
                    LimiteMaximo__c,
                    LimiteMinimo__c,
                    TipoEvento__c
                FROM
                    AntecipacaoComissao__c  
                WHERE 
                    RemuneracaoProduto__r.Produto__c = :produto
        ];
    }
    
    //ANNVI-41 FIX-03 INICIO
    public List<AntecipacaoComissao__c> verificaAntecipacaoProdEventoNovo(String produto){
        return  [
                SELECT 
                    Id,
                    //ANNVI-41 INICIO
                    QuantidadeParcelas__c,
                    AntecipacaoAutomatica__c,
                    FormaPagamento__c,
                    FormaPagamento__r.Codigo__c,           //ANNVI-41 FIX-02 INICIO/FIM
                    //ANNVI-41 FIM 
                    LimiteMaximo__c,
                    LimiteMinimo__c,
                    TipoEvento__c
                FROM
                    AntecipacaoComissao__c  
                WHERE 
                    RemuneracaoProduto__r.Produto__c = :produto AND TipoEvento__c = 'Seguro Novo'
        ];
    }
    //ANNVI-41 FIX-03 FIM
    
    public List<FavorecidoRemuneracaoProposta__c> verificaFavRemuneracaoProd(Set<id> remuneracaoProp){
        return  [
                SELECT 
                    Id, 
                    AntecipacaoComissao__c
                FROM
                    FavorecidoRemuneracaoProposta__c   
                WHERE 
                    RemuneracaoProposta__c = :remuneracaoProp
        ];
    }

    public List<RemuneracaoProposta__c> getRemProp(String proposta){
        return [
            SELECT 
                Id,
                Percentual__c,
                TipoRemuneracao__c,
                TipoRemuneracao__r.Name
            FROM
                RemuneracaoProposta__c
            WHERE 
                Proposta__r.Name = :proposta
        ];
    }

    public Quote getQuote(String idProposta){
        return  [
                SELECT 
                    Id, 
                    Produto__c,
                    Tipo__c,
                    Name 
                FROM
                    Quote 
                WHERE 
                    Id = :idProposta
            ];
    }
    //II-176 FIM
    //II-206 INICIO
    public List<Account> getAccountByCPF(String cpf){
        return  [
                SELECT 
                    Id, 
                    PersonMobilePhone,
                    PersonHomePhone,
                    PersonEmail,
                    Sexo__c,
                    PersonBirthdate,
                    Cpf__c,
                    EstadoCivil__c
                FROM
                    Account 
                WHERE 
                    Cpf__c =: cpf
                    LIMIT 1
            ];
    }

    public PlanoParcelamento__c getPlanoParcelamento(Integer numeroParcelas, String formaPagamento){
        return  [
                SELECT 
                    Id
                FROM
                    PlanoParcelamento__c 
                WHERE 
                    NumeroParcela__c =: numeroParcelas
                    AND
                    FormaPagamento__c =: formaPagamento
                    LIMIT 1
            ];
    }

    public List<CartaoCredito__c> getCartao(String conta, String idExterno){
        return  [
                SELECT 
                    Id 
                FROM 
                    CartaoCredito__c 
                WHERE 
                    Conta__c = :conta 
                    AND
                    IdExterno__c = :idExterno
                    LIMIT 1
            ];
    }

    public List<InformacaoBancaria__c> getADC(String conta, String contaCorrente){
        return  [
                SELECT 
                    Id 
                FROM 
                    InformacaoBancaria__c  
                WHERE 
                    Conta__c = :conta 
                    AND
                    NumeroConta__c = :contaCorrente
                    LIMIT 1
            ];
    }

    public List<Banco__c> getBanco(String banco){
        return  [
                SELECT 
                    Id 
                FROM 
                    Banco__c  
                WHERE 
                    Name = :banco 
                    LIMIT 1
            ];
    }
    //II-206 FIM
    //II-206 FIX01 INICIO
    public List<Endereco__c> consultaEndereco(String conta){
        return  [
            SELECT 
                ID, 
                TipoEndereco__c, 
                CEP__c, 
                Logradouro__c, 
                Bairro__c, 
                Cidade__c, 
                Estado__c, 
                Complemento__c, 
                Numero__c 
            FROM 
                Endereco__c    
            WHERE 
                Conta__c = :conta 
            AND
                MaisAtual__c = true
            ];
    }

    public GrupoProposta__c getGrupoProposta(String contratante){
        return  [
            SELECT 
                Id
            FROM 
                GrupoProposta__c    
            WHERE 
                ContratanteProposta__c = :contratante LIMIT 1
                ];
    }

    public SeguradoProposta__c getSeguradoProposta(String grupo){
        return  [
            SELECT 
                Id, 
                VinculoComSegurado__c
            FROM 
                SeguradoProposta__c    
            WHERE 
                GrupoProposta__c = :grupo LIMIT 1
            ];
    }
    //II-206 FIX01 FIM

    //FNPVVEP-146 INICIO
    public ContratanteProposta__c getContratante(String recordId) {
        return [
            SELECT Id, ResponsavelPagamento__r.FirstName, ResponsavelPagamento__r.LastName, ResponsavelPagamento__r.Cpf__c 
            FROM ContratanteProposta__c
            WHERE Proposta__c =: recordId LIMIT 1
        ];
    }

    public Quote getQuoteById(String recordId) {
        return [
            SELECT Name 
            FROM Quote 
            WHERE Id = :recordId LIMIT 1
        ];
    }
    //FNPVVEP-146 FIM
}
//II-166 - FIM