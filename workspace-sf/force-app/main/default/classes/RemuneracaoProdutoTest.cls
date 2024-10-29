@isTest
private class RemuneracaoProdutoTest {

    @testSetup
    private static void setup() {
        List<ContadorCodigo__c> contadoresProduto = new List<ContadorCodigo__c>{
            new ContadorCodigo__c(Name='ProdutoTecnico', Numero__c = 0),
            new ContadorCodigo__c(Name='ProdutoComercial', Numero__c = 0)
        };
        insert contadoresProduto;
    }

    @isTest
    static void testeValidarTiposRemuneracaoExistentes() {
        String erro = '';

        Product2 produto = new Product2();
        produto.Name = 'Nome Produto 001';
        produto.Status__c = 'Em criação';
        produto.ProductCode = '201700001';
        produto.TipoResponsavelPagamento__c = 'SEG';
        insert produto;

        TipoRemuneracao__c tipoRemuneracao1 = new TipoRemuneracao__c();
        tipoRemuneracao1.Name = 'Remuneracao 1';
        tipoRemuneracao1.LimiteMinimo__c = 5;
        tipoRemuneracao1.LimiteMaximo__c = 50;
        insert tipoRemuneracao1;

        TipoRemuneracao__c tipoRemuneracao2 = new TipoRemuneracao__c();
        tipoRemuneracao2.Name = 'Remuneracao 2';
        tipoRemuneracao2.LimiteMinimo__c = 5;
        tipoRemuneracao2.LimiteMaximo__c = 50;
        insert tipoRemuneracao2;

        TipoRemuneracao__c tipoRemuneracao3 = new TipoRemuneracao__c();
        tipoRemuneracao3.Name = 'Remuneracao 3';
        tipoRemuneracao3.LimiteMinimo__c = 5;
        tipoRemuneracao3.LimiteMaximo__c = 50;
        insert tipoRemuneracao3;

        //Tenta inserir uma remuneracao
        RemuneracaoProduto__c remuneracao1 = new RemuneracaoProduto__c();
        remuneracao1.TipoRemuneracao__c = tipoRemuneracao1.Id;
        remuneracao1.Produto__c = produto.Id;
        insert remuneracao1;
        System.assert(remuneracao1.Id != null);

        //Tenta inserir outra remuneração, porém com o mesmo tipo
        RemuneracaoProduto__c remuneracao2 = new RemuneracaoProduto__c();
        remuneracao2.TipoRemuneracao__c = tipoRemuneracao1.Id;
        remuneracao2.Produto__c = produto.Id;
        
        erro = '';

        try{
            insert remuneracao2;
        }
        catch(Exception e){
            erro = e.getMessage();
        }

        System.assert(erro.indexOf('Este Tipo de Remuneração já está sendo utilizado em outra Remuneração do produto.') > -1);

        //Altera tipo e tenta inserir novamente
        remuneracao2.TipoRemuneracao__c = tipoRemuneracao2.Id;
        insert remuneracao2;
        System.assert(remuneracao2.Id != null);

        //Tenta atualizar para um tipo já utilizado
        remuneracao2.TipoRemuneracao__c = tipoRemuneracao1.Id;

        erro = '';

        try{
            update remuneracao2;
        }
        catch(Exception e){
            erro = e.getMessage();
        }

        System.assert(erro.indexOf('Este Tipo de Remuneração já está sendo utilizado em outra Remuneração do produto.') > -1);

        //Tenta atualizar para um tipo nao utilizado
        remuneracao2.TipoRemuneracao__c = tipoRemuneracao2.Id;

        erro = '';

        try{
            update remuneracao2;
        }
        catch(Exception e){
            erro = e.getMessage();
        }

        System.assertEquals(erro, '');

        //Valida DML em massa
        List<RemuneracaoProduto__c> remuneracoes = new List<RemuneracaoProduto__c>{remuneracao1, remuneracao2};
        remuneracao1.TipoRemuneracao__c = tipoRemuneracao3.Id;
        remuneracao2.TipoRemuneracao__c = tipoRemuneracao3.Id;

        erro = '';

        try{
            update remuneracoes;
        }
        catch(Exception e){
            erro = e.getMessage();
        }

        System.assert(erro.indexOf('Este Tipo de Remuneração já está sendo utilizado em outra Remuneração do produto.') > -1);

        remuneracao2.TipoRemuneracao__c = tipoRemuneracao2.Id;

        erro = '';

        try{
            update remuneracoes;
        }
        catch(Exception e){
            erro = e.getMessage();
        }

        System.assertEquals(erro, '');
    }

    @isTest
    static void testeValidarTiposRemuneracaoProdutoComercial() {
        Id rtProdTecnicoId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
        Id rtProdComercialId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
        Id rtRemuneracaoTecnicolId = RecordTypeBO.buscarTipoRegistro('RemuneracaoProduto__c', 'ProdutoTecnico').Id;
        Id rtRemuneracaoComercialId = RecordTypeBO.buscarTipoRegistro('RemuneracaoProduto__c', 'ProdutoComercial').Id;
        String erro = '';

        //Cria estrutura produto técnico 
        Product2 produtoTecnico = new Product2();
        produtoTecnico.Name = 'Nome Produto 001';
        produtoTecnico.Status__c = 'Em criação';
        produtoTecnico.ProductCode = '201700001';
        produtoTecnico.RecordTypeId = rtProdTecnicoId;
        produtoTecnico.TipoResponsavelPagamento__c = 'SEG';
        insert produtoTecnico;

        TipoRemuneracao__c tipoRemuneracao1 = new TipoRemuneracao__c();
        tipoRemuneracao1.Name = 'Remuneracao 1';
        tipoRemuneracao1.LimiteMinimo__c = 5;
        tipoRemuneracao1.LimiteMaximo__c = 50;
        insert tipoRemuneracao1;

        RemuneracaoProduto__c remuneracaoTecnica = new RemuneracaoProduto__c();
        remuneracaoTecnica.TipoRemuneracao__c = tipoRemuneracao1.Id;
        remuneracaoTecnica.Produto__c = produtoTecnico.Id;
        remuneracaoTecnica.RecordTypeId = rtRemuneracaoTecnicolId;
        insert remuneracaoTecnica;

        //Cria estrutura produto comercial e realiza as validações
        Product2 produtoComercial = new Product2();
        produtoComercial.Name = 'Nome Produto 001';
        produtoComercial.Status__c = 'Em criação';
        produtoComercial.ProductCode = '201700001';
        produtoComercial.RecordTypeId = rtProdComercialId;
        produtoComercial.TipoResponsavelPagamento__c = 'SEG';
        insert produtoComercial;

        //Tenta inserir remuneracao com um tipo diferente do produto técnico
        TipoRemuneracao__c tipoRemuneracao2 = new TipoRemuneracao__c();
        tipoRemuneracao2.Name = 'Remuneraca 2';
        tipoRemuneracao2.LimiteMinimo__c = 5;
        tipoRemuneracao2.LimiteMaximo__c = 50;
        insert tipoRemuneracao2;

        RemuneracaoProduto__c remuneracaoComercial = new RemuneracaoProduto__c();
        remuneracaoComercial.TipoRemuneracao__c = tipoRemuneracao2.Id;
        remuneracaoComercial.Produto__c = produtoComercial.Id;
        remuneracaoComercial.RecordTypeId = rtRemuneracaoComercialId;
        remuneracaoComercial.RemuneracaoProduto__c = remuneracaoTecnica.Id;

        erro = '';

        try{
            insert remuneracaoComercial;    
        }
        catch(Exception e){
            erro = e.getMessage();
        }

        System.assert(erro.indexOf('Este Tipo de Remuneração não existe no produto técnico. Não pode ser utilizado.') > -1);

        //Utiliza tipo der remuneração existente no produto técnico
        remuneracaoComercial.TipoRemuneracao__c = tipoRemuneracao1.Id;
        insert remuneracaoComercial;
        System.assert(remuneracaoComercial.Id != null);
    }
}