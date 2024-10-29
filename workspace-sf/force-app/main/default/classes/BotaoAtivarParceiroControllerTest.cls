/**
 * Created by Alessandro Ponte on 20/09/2018.
 */

@IsTest
private class BotaoAtivarParceiroControllerTest {
    @TestSetup
    static void testSetup(){
        TestDataFactory.gerarDadosSetup();
        TestDataFactory.gerarProdutoComercialAtivo(false);

         // PLV-4472 INICIO
        Account contaParceiro = new Account(Name = 'ParceiroTeste', IdExterno__c = '74586138825', Cnpj__c = '08.370.609/0001-64');
        insert contaParceiro;

        Account contaCorretor = new Account(Name = 'ContaCorretor', Papel__c = 'Corretor', IdExterno__c = '38012786532', Cnpj__c = '38.579.897/0001-22' );
        insert contaCorretor;
         // PLV-4472 FIM

        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__c parceiro = TestDataFactory.gerarParceiro(contaParceiro,formaPagamento);
    }

    @IsTest
    static void testParceiroJaAtivado(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        parceiro.Status__c = 'Ativo';
        update parceiro;

        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        // Espera a mensagem de que o parceiro já está ativo
        System.assert( retorno.mensagens.contains('Parceiro já esta Ativo!') );

    }

    @IsTest
    static void testParceiroSemProdutoComercial(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.assert( retorno.mensagens.contains('Relacionar pelo menos um produto comercial ao parceiro') );

    }

    @IsTest
    static void testParceiroComProdutoTecnico(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoTecnico = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoTecnico'];


        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoTecnico);

        parceiro = [SELECT Id, (SELECT Id,Produto__r.ProductCode FROM ProdutosParceiro__r) FROM Parceiro__c LIMIT 1];


        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.assert( retorno.mensagens.contains('Produto ' + parceiro.ProdutosParceiro__r[0].Produto__r.ProductCode + ' não é um produto comercial!') );

    }

    @IsTest
    static void testParceiroSemRemuneracao(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoComercial = [ SELECT Id, ProductCode FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.debug('retorno --------------------- ' + retorno);

        System.assert( retorno.mensagens.contains('Remuneracao no parceiro não cadastrada para o Produto ' + produtoComercial.ProductCode) );

    }

    @IsTest
    static void testParceiroComProdutoInativo(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoComercial = [ SELECT Id, ProductCode, (SELECT Id,TipoRemuneracao__c,TipoRemuneracao__r.Id FROM RemuneracoesProduto__r) FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];
        produtoComercial.Status__c = 'Em criação';
        update produtoComercial;

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro =
            TestDataFactory.gerarRemuneracaoProdutoParceiro(produtoComercial.RemuneracoesProduto__r[0].TipoRemuneracao__r,produtoParceiro,100);

        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.assert( retorno.mensagens.contains('Produto ' +  produtoComercial.ProductCode + ' não está ativo e/ou vigente') );

    }

    @IsTest
    static void testParceiroComProdutoSemVigencia(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoComercial = [ SELECT Id, ProductCode, (SELECT Id,TipoRemuneracao__c,TipoRemuneracao__r.Id FROM RemuneracoesProduto__r) FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];
        // PLV-3673  -  INICIO
        produtoComercial.VigenciaInicial__c = system.today().addDays(2);
        produtoComercial.VigenciaFinal__c = system.today().addDays(30);
        // PLV-3673  -  FIM
        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro =
            TestDataFactory.gerarRemuneracaoProdutoParceiro(produtoComercial.RemuneracoesProduto__r[0].TipoRemuneracao__r,produtoParceiro,100);

        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.assert( retorno.mensagens.contains('Produto ' +  produtoComercial.ProductCode + ' não está ativo e/ou vigente') );

    }

    @IsTest
    static void testParceiroComRemuneracaoNaoPermitida(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoComercial = [ SELECT Id, ProductCode, (SELECT Id, TipoRemuneracao__c, TipoRemuneracao__r.Id, TipoRemuneracao__r.Name FROM RemuneracoesProduto__r) FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('PRO-LABORE', 5, 50, 'Integral');

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro =
            TestDataFactory.gerarRemuneracaoProdutoParceiro(tipoRemuneracao, produtoParceiro, 100);
        remuneracaoProdutoParceiro = [SELECT Id,TipoRemuneracao__c,TipoRemuneracao__r.Name FROM RemuneracaoProdutoParceiro__c WHERE Id =: remuneracaoProdutoParceiro.Id];

        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.assert( retorno.mensagens.contains('Remuneração ' + remuneracaoProdutoParceiro.TipoRemuneracao__r.Name + ' não permitida pelo produto') );

    }

    @IsTest
    static void testParceiroSemFavorecidos(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoComercial = [ SELECT Id, ProductCode, (SELECT Id, TipoRemuneracao__c, TipoRemuneracao__r.Id, TipoRemuneracao__r.Name FROM RemuneracoesProduto__r) FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro =
            TestDataFactory.gerarRemuneracaoProdutoParceiro(produtoComercial.RemuneracoesProduto__r[0].TipoRemuneracao__r, produtoParceiro, 100);
        remuneracaoProdutoParceiro = [SELECT Id,TipoRemuneracao__c,TipoRemuneracao__r.Name FROM RemuneracaoProdutoParceiro__c WHERE Id =: remuneracaoProdutoParceiro.Id];

        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.assert( retorno.mensagens.contains('Informar os favorecidos da Remuneração ' + remuneracaoProdutoParceiro.TipoRemuneracao__r.Name) );

    }

    @IsTest
    static void testParceiroSemLiderCorretagem(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoComercial = [ SELECT Id, ProductCode, (SELECT Id, TipoRemuneracao__c, TipoRemuneracao__r.Id, TipoRemuneracao__r.Name FROM RemuneracoesProduto__r) FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro =
            TestDataFactory.gerarRemuneracaoProdutoParceiro(produtoComercial.RemuneracoesProduto__r[0].TipoRemuneracao__r, produtoParceiro, 100);
        remuneracaoProdutoParceiro = [SELECT Id,TipoRemuneracao__c,TipoRemuneracao__r.Name FROM RemuneracaoProdutoParceiro__c WHERE Id =: remuneracaoProdutoParceiro.Id];
        Account conta = [SELECT Id,Name FROM Account WHERE Papel__c = 'Corretor' LIMIT 1];

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);
        InformacaoBancaria__c informacaoBancaria = TestDataFactory.gerarInformacaoBancaria(conta);
        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(conta, 100.00,'Corretor', false, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);

        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.assert( retorno.mensagens.contains('Informar um líder para a remuneração de corretagem') );

    }

    @IsTest
    static void testParceiroComMaisDeUmLiderCorretagem(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoComercial = [ SELECT Id, ProductCode, (SELECT Id, TipoRemuneracao__c, TipoRemuneracao__r.Id, TipoRemuneracao__r.Name FROM RemuneracoesProduto__r) FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro =
            TestDataFactory.gerarRemuneracaoProdutoParceiro(produtoComercial.RemuneracoesProduto__r[0].TipoRemuneracao__r, produtoParceiro, 100);
        remuneracaoProdutoParceiro = [SELECT Id,TipoRemuneracao__c,TipoRemuneracao__r.Name FROM RemuneracaoProdutoParceiro__c WHERE Id =: remuneracaoProdutoParceiro.Id];
        Account conta = [SELECT Id,Name FROM Account WHERE Papel__c = 'Corretor' LIMIT 1];

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);
        InformacaoBancaria__c informacaoBancaria = TestDataFactory.gerarInformacaoBancaria(conta);

        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(conta, 90.00, 'Corretor', true, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);
        FavorecidoRemuneracao__c favorecidoRemuneracao2 = TestDataFactory.gerarFavorecidoRemuneracao(conta, 10.00, 'Corretor', true, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);

        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.assert( retorno.mensagens.contains('Informar somente um líder para a remuneração de corretagem') );

    }

    @IsTest
    static void testParceiroComFavorecidoComPapelInvalido(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoComercial = [ SELECT Id, ProductCode, (SELECT Id, TipoRemuneracao__c, TipoRemuneracao__r.Id, TipoRemuneracao__r.Name FROM RemuneracoesProduto__r) FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro =
            TestDataFactory.gerarRemuneracaoProdutoParceiro(produtoComercial.RemuneracoesProduto__r[0].TipoRemuneracao__r, produtoParceiro, 100);
        remuneracaoProdutoParceiro = [SELECT Id,TipoRemuneracao__c,TipoRemuneracao__r.Name FROM RemuneracaoProdutoParceiro__c WHERE Id =: remuneracaoProdutoParceiro.Id];

        Account conta = [SELECT Id,Name,Papel__c FROM Account WHERE Papel__c = 'Corretor'];
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);

        InformacaoBancaria__c informacaoBancaria = TestDataFactory.gerarInformacaoBancaria(conta);

        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(conta, 90.00, 'Corretor', true, remuneracaoProdutoParceiro, dadosCorretor, informacaoBancaria);
        FavorecidoRemuneracao__c favorecidoRemuneracao2 = TestDataFactory.gerarFavorecidoRemuneracao(conta, 10.00, 'Agenciador', false, remuneracaoProdutoParceiro, null, informacaoBancaria);

        favorecidoRemuneracao2 = [SELECT Id,Conta__c,Conta__r.Name FROM FavorecidoRemuneracao__c  WHERE Id =: favorecidoRemuneracao2.Id];

        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.assert( retorno.mensagens.contains('Papel do favorecido(a) ' + favorecidoRemuneracao2.Conta__r.Name + ' não vínculado a conta!') );

    }

    @IsTest
    static void testParceiroComParticipacaoMaiorQue100(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoComercial = [ SELECT Id, ProductCode, (SELECT Id, TipoRemuneracao__c, TipoRemuneracao__r.Id, TipoRemuneracao__r.Name FROM RemuneracoesProduto__r) FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro =
            TestDataFactory.gerarRemuneracaoProdutoParceiro(produtoComercial.RemuneracoesProduto__r[0].TipoRemuneracao__r, produtoParceiro, 100);
        remuneracaoProdutoParceiro = [SELECT Id,TipoRemuneracao__c,TipoRemuneracao__r.Name FROM RemuneracaoProdutoParceiro__c WHERE Id =: remuneracaoProdutoParceiro.Id];
        Account conta = [SELECT Id,Name FROM Account WHERE Papel__c = 'Corretor' LIMIT 1];

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);
        InformacaoBancaria__c informacaoBancaria = TestDataFactory.gerarInformacaoBancaria(conta);

        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(conta, 90.00, 'Corretor', true, remuneracaoProdutoParceiro, dadosCorretor, informacaoBancaria);
        FavorecidoRemuneracao__c favorecidoRemuneracao2 = TestDataFactory.gerarFavorecidoRemuneracao(conta, 20.00, 'Corretor', false, remuneracaoProdutoParceiro, dadosCorretor, informacaoBancaria);

        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.assert( retorno.mensagens.contains('A somatória do percentual dos favorecidos da remuneração ' + remuneracaoProdutoParceiro.TipoRemuneracao__r.Name + ' é diferente de 100%') );

    }

    @IsTest
    static void testParceiroComRemuneracaoForaDosLimites(){

        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoComercial = [ SELECT Id, ProductCode, (SELECT Id, TipoRemuneracao__c, TipoRemuneracao__r.Id, TipoRemuneracao__r.Name, TipoRemuneracao__r.LimiteMinimo__c FROM RemuneracoesProduto__r) FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro =
            TestDataFactory.gerarRemuneracaoProdutoParceiro(produtoComercial.RemuneracoesProduto__r[0].TipoRemuneracao__r, produtoParceiro, 1.0);
        remuneracaoProdutoParceiro = [SELECT Id,TipoRemuneracao__c,TipoRemuneracao__r.Name FROM RemuneracaoProdutoParceiro__c WHERE Id =: remuneracaoProdutoParceiro.Id];
        Account conta = [SELECT Id,Name FROM Account WHERE Papel__c = 'Corretor' LIMIT 1];

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);
        InformacaoBancaria__c informacaoBancaria = TestDataFactory.gerarInformacaoBancaria(conta);

        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(conta, 80.00, 'Corretor', true, remuneracaoProdutoParceiro, dadosCorretor, informacaoBancaria);
        FavorecidoRemuneracao__c favorecidoRemuneracao2 = TestDataFactory.gerarFavorecidoRemuneracao(conta, 20.00, 'Corretor', false, remuneracaoProdutoParceiro, dadosCorretor, informacaoBancaria);

        RetornoAcaoBotaoTO retorno = ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        System.assert( retorno.mensagens.contains('Percentual da remuneração ' + remuneracaoProdutoParceiro.TipoRemuneracao__r.Name + ' fora dos limites') );

    }

    @IsTest
    static void TestParceiroAtivado (){
        Parceiro__c parceiro = [SELECT Id FROM Parceiro__c LIMIT 1];
        Product2 produtoComercial = [ SELECT Id, ProductCode, (SELECT Id, TipoRemuneracao__c, TipoRemuneracao__r.Id, TipoRemuneracao__r.Name, TipoRemuneracao__r.LimiteMinimo__c FROM RemuneracoesProduto__r) FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro =
            TestDataFactory.gerarRemuneracaoProdutoParceiro(produtoComercial.RemuneracoesProduto__r[0].TipoRemuneracao__r, produtoParceiro, 10.0);
        remuneracaoProdutoParceiro = [SELECT Id,TipoRemuneracao__c,TipoRemuneracao__r.Name FROM RemuneracaoProdutoParceiro__c WHERE Id =: remuneracaoProdutoParceiro.Id];
        Account conta = [SELECT Id,Name FROM Account WHERE Papel__c = 'Corretor' LIMIT 1];

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);
        InformacaoBancaria__c informacaoBancaria = TestDataFactory.gerarInformacaoBancaria(conta);

        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(conta, 80.00, 'Corretor', true, remuneracaoProdutoParceiro, dadosCorretor, informacaoBancaria);
        FavorecidoRemuneracao__c favorecidoRemuneracao2 = TestDataFactory.gerarFavorecidoRemuneracao(conta, 20.00, 'Corretor', false, remuneracaoProdutoParceiro, dadosCorretor, informacaoBancaria);

        Test.startTest();

        RetornoAcaoBotaoTO retorno = (RetornoAcaoBotaoTO)JSON.deserialize(BotaoAtivarParceiroController.ativarParceiro(parceiro.Id),RetornoAcaoBotaoTO.class);

        System.assert( retorno.mensagens.contains('Parceiro ativado com sucesso!') );
    }
}