public class ParceiroDAO
{

    private static final ParceiroDAO instancia = new ParceiroDAO();

    private ParceiroDAO(){}
    private static final String PRODUTO_COMERCIAL = 'ProdutoComercial';

    public static ParceiroDAO getInstance(){
        return instancia;
    }

    public List<Parceiro__c> buscarTodosParceiros(){
        return [
                SELECT
                        Id,
                        Name,
                        Codigo__c,
                        Conta__c,
                        Conta__r.Name,
                (
                        SELECT
                                Id,
                                Name,
                                Produto__c,
                                Produto__r.Name,
                                CodigoProdutoParceiro__c,
                                Sigla__c
                        FROM
                                ProdutosParceiro__r
                )
                FROM
                        Parceiro__c
        ];
    }

    public List<Parceiro__c> buscarParceirosPorIds(List<Id> setParceirosIds) {
        return [SELECT
                ApoliceFaturamento__c,
                Conta__c,
                DiaFaturamento__c,
                DiaPreFaturamento__c,
                Empresa__c,
                EndossoCobranca__c,
                EndossoBatimentoContabil__c,
                FaturaProdutosSeparados__c,
                FormaPagamento__c,
                Name,
                PossuiAnexoFatura__c,
                PrazoVencimento__c,
                Ramo__c,
                Sucursal__c,
                Status__c,
        (
                SELECT
                        Id,
                        Name,
                        Produto__c,
                        Produto__r.ProductCode,
                        Produto__r.CodigoPrecificaProduto__c, // PLV-5331 INÍCIO / FIM 
                        Produto__r.RecordTypeId,
                        Produto__r.RecordType.DeveloperName,
                        Parceiro__c
                FROM
                        ProdutosParceiro__r
        )
        FROM
                Parceiro__c
        WHERE
                Id IN :setParceirosIds];
    }

    public Parceiro__c obtemParceiro(String  idParceiro)
    {
        List<Parceiro__c> l = [SELECT
                Id,
                Codigo__c,
                ApoliceFaturamento__c,
                Conta__c,
                DiaFaturamento__c,
                DiaPreFaturamento__c,
                Empresa__c,
                EndossoCobranca__c,
                EndossoBatimentoContabil__c,
                FaturaProdutosSeparados__c,
                FormaPagamento__c,
                Name,
                PossuiAnexoFatura__c,
                PrazoVencimento__c,
                Ramo__c,
                Sucursal__c,
                Status__c,
                FormaPagamento__r.Codigo__c
        FROM
                Parceiro__c
        WHERE
                Codigo__c = :idParceiro OR SiglaParceiro__c = :idParceiro]; // VIAG-139 INICIO/FIM
        if(l.isEmpty())
            return null;
        else
                return l[0];
    }
// VIAG-139 INICIO
    public String  obtemParceiroSigla(String  idParceiro)
    {
        String ParceiroId = '';
        List<Parceiro__c> Parceiro = [SELECT Id  FROM  Parceiro__c  WHERE  Codigo__c =: idParceiro  OR   SiglaParceiro__c =: idParceiro Limit 1];
        if (Parceiro.size() >0 ) {
                ParceiroId = Parceiro[0].Id;
        } 
       return ParceiroId;
    }
 // VIAG-139 FIM

 public List<Product2> buscarProdutos(Set<Id> setProdutoId){
        return [
                SELECT
                        Id,
                        VigenciaInicial__c,
                        VigenciaFinal__c,
                        Status__c,
                        ProdutoVigente__c,
                        ProductCode,
                (
                        SELECT
                                Id,
                                Name,
                                LimiteMaximo__c,
                                LimiteMinimo__c,
                                Obrigatoria__c,
                                Produto__c,
                                TipoRemuneracao__c,
                                TipoRemuneracao__r.Name,
                                TipoRemuneracao__r.LimiteMinimo__c,
                                TipoRemuneracao__r.LimiteMaximo__c,
                                TipoRemuneracao__r.Codigo__c
                        FROM
                                RemuneracoesProduto__r
                )
                FROM
                        Product2
                WHERE
                        Id =: setProdutoId
        ];
    }

    public List<RemuneracaoProdutoParceiro__c> buscarRemuneracaoProdutosPorParceiro(Set<Id> setProdutoId, Id parceiroId)
    {
        return [
                SELECT
                        Id,
                        Name,
                        Percentual__c,
                        ProdutoParceiro__r.Parceiro__c,
                        TipoRemuneracao__c,
                        TipoRemuneracao__r.Name,
                        TipoRemuneracao__r.LimiteMinimo__c,
                        TipoRemuneracao__r.LimiteMaximo__c,
                        TipoRemuneracao__r.Codigo__c,
                        ProdutoParceiro__c,
                        ProdutoParceiro__r.Produto__c,
                        RemuneracaoProduto__c,
                (
                        SELECT
                                Id,
                                Name,
                                Conta__c,
                                Conta__r.Papel__c,
                                Conta__r.Name,
                                Conta__r.SusepPrincipal__c,
                                Conta__r.CodigoSusepCia__c,
                                Conta__r.CodigoSusepCorretor__c,
                                DadosCorretor__c,
                                DadosCorretor__r.Name,
                                Percentual__c,
                                Lider__c,
                                Papel__c
                        FROM
                                FavorecidosRemuneracao__r
                )

                FROM
                        RemuneracaoProdutoParceiro__c
                WHERE
                ProdutoParceiro__r.Produto__c IN: setProdutoId AND ProdutoParceiro__r.Parceiro__c = : parceiroId

        ];
    }

    public List<RemuneracaoProdutoParceiro__c> buscarRemuneracaoProdutoParceiro(Set<Id> setParceiroId){
        return [
                SELECT
                        Id,
                        Name,
                        Percentual__c,
                        TipoRemuneracao__c,
                        TipoRemuneracao__r.Name,
                        TipoRemuneracao__r.LimiteMinimo__c,
                        TipoRemuneracao__r.LimiteMaximo__c,
                        TipoRemuneracao__r.Codigo__c,
                        ProdutoParceiro__c,
                        ProdutoParceiro__r.Produto__c,
                        RemuneracaoProduto__c,
                (
                        SELECT
                                Id,
                                Name,
                                Conta__c,
                                Conta__r.Papel__c,
                                Conta__r.Name,
                                Conta__r.SusepPrincipal__c,
                                Conta__r.CodigoSusepCia__c,
                                Conta__r.CodigoSusepCorretor__c,
                                Percentual__c,
                                Lider__c,
                                Papel__c
                        FROM
                                FavorecidosRemuneracao__r
                )

                FROM
                        RemuneracaoProdutoParceiro__c
                WHERE
                        ProdutoParceiro__r.Parceiro__c =: setParceiroId
        ];
    }

    public List<Parceiro__c> buscarParceirosPorCodigo(Set<String> setParceiro) {
        return [SELECT
                Id,
                ApoliceFaturamento__c,
                Conta__c,
                Codigo__c,
                DiaFaturamento__c,
                DiaPreFaturamento__c,
                Empresa__c,
                EndossoCobranca__c,
                EndossoBatimentoContabil__c,
                FaturaProdutosSeparados__c,
                FormaPagamento__c,
                Name,
                PossuiAnexoFatura__c,
                PrazoVencimento__c,
                Ramo__c,
                Sucursal__c,
        (
                SELECT
                        Id,
                        Name,
                        Produto__c,
                        Produto__r.ProductCode,
                        Produto__r.CodigoPrecificaProduto__c, // PLV-5331 INÍCIO / FIM 
                        Produto__r.RecordTypeId,
                        Produto__r.RecordType.DeveloperName,
                        Parceiro__c,
                        Sigla__c,
                        CodigoProdutoParceiro__c
                FROM
                        ProdutosParceiro__r
        )
        FROM
                Parceiro__c
        WHERE Codigo__c =: setParceiro];
    }

    public List<ProdutoParceiro__c> buscarProdutosParceiro(Set<String> setCodigoParceiro, Set<String> setCodigoProduto) {
        return [
                SELECT
                        Id,
                        Name,
                        Produto__c,
                        Produto__r.ProductCode,
                        Produto__r.CodigoPrecificaProduto__c, // PLV-5331 INÍCIO / FIM 
                        Produto__r.RecordTypeId,
                        Produto__r.RecordType.DeveloperName,
                        Parceiro__c,
                        Parceiro__r.Name,
                        Parceiro__r.Codigo__c,
                        Sigla__c,
                        CodigoProdutoParceiro__c
                FROM
                        ProdutoParceiro__c
                WHERE
                        Parceiro__r.Codigo__c =: setCodigoParceiro
                AND
                        Produto__r.ProductCode =: setCodigoProduto

        ];
    }

    public List<ProdutoParceiro__c> buscarProdutosPorProductCode(Set<String> setProductCode){
        return [
                SELECT
                        Id,
                        CodigoProdutoParceiro__c,
                        Parceiro__c,
                        Parceiro__r.Codigo__c,
                        Produto__r.VersaoMaxima__c,
                        Produto__r.Versao__c,
                        Produto__r.ProductCode,
                        Produto__r.CodigoPrecificaProduto__c // PLV-5331 INÍCIO / FIM 
                FROM
                        ProdutoParceiro__c
                WHERE
                        Produto__r.ProductCode =: setProductCode
        ];
    }
   // VIAG-139 INICIO 
    public String buscarParceiroPorProductId(String setProdutoId){
     String siglaParceiro = '';
     List<ProdutoParceiro__c>  Sigla =  [
                SELECT 
                  Parceiro__r.SiglaParceiro__c
                FROM
                        ProdutoParceiro__c
                WHERE
                       Produto__r.Id =: setProdutoId 
                Limit 1
        ];
     
        if ( Sigla.size() >0 ) {
           siglaParceiro = Sigla[0].Parceiro__r.SiglaParceiro__c;
        } 
       return siglaParceiro;
    }
      // VIAG-139 FIM
}