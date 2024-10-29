/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelos testes no objeto Quote
 *
 **************************************************************************************************************************************************************************/

@isTest
private class QuoteComplementoTest {

    public static final QuoteBO bo = QuoteBO.getInstance();

    @TestSetup
    static void setup(){
        TestDataFactory.gerarDadosSetup();
	    // PLV-2312-28 INICIO
        TestDataFactory.gerarProposta(true);
	    // PLV-2312-28 FIM
    }

    @IsTest
    static void testValidarDadosPagamentoContratantePropostaSemCartaoCredito(){
        // Recupera dados
        Quote proposta = [SELECT Id, Produto__c FROM Quote LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 WHERE Id =: proposta.Produto__c LIMIT 1];
        String erroEsperado = '';

        // Apaga todos os contratantes da Proposta para gerar um novo
        List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
        delete listContratantePropostaParaDeletar;

        // Apaga todas as condicoes de cobranca
        List<CondicaoCobranca__c> listCondicaoCobranca = [SELECT Id FROM CondicaoCobranca__c];
        delete listCondicaoCobranca;

        // altera a forma de pagamento para cartao de credito
        formaPagamento.Codigo__c = 'CAT';
        // não é permitido esta alteração: formaPagamento.Name = 'Cartão de Crédito';
        update formaPagamento;

        // cria uma condicao de cobraca para cartao de credito
        CondicaoCobranca__c condicaoCobranca = new CondicaoCobranca__c(
            FormaPagamento__c = formaPagamento.Id,
            QuantidadeParcelas__c = '5',
            Produto__c = produto.Id
        );
        insert condicaoCobranca;

        // Apaga os cartões de credito do responsavel pelo pagamento
        List<CartaoCredito__c> listCartaoCredito = [SELECT Id FROM CartaoCredito__c WHERE Conta__c =: conta.Id];
        delete listCartaoCredito;

        // Gera um contratante da proposta
        ContratanteProposta__c contratanteProposta = new ContratanteProposta__c(
            Conta__c = conta.Id,
            Proposta__c = proposta.Id,
            Tipo__c = 'Principal',
            TipoEndereco__c = 'Residencial',
            Cep__c = '03020-000',
            TipoLogradouro__c = 'Rua',
            Logradouro__c = '15',
            NumeroEndereco__c = '15',
            Bairro__c = 'Osasco',
            Cidade__c = 'São Paulo',
            Estado__c = 'SP',
            Pais__c = 'Brasil',
            ResponsavelPagamento__c = conta.Id,
            FormaPagamento__c = formaPagamento.Id,
            PremioTotal__c = 10
        );

        Test.startTest();

        try{
            // Insere o contratante
            insert contratanteProposta;
        }catch (Exception e){
            erroEsperado = e.getMessage();
        }

        Test.stopTest();

        System.debug('====> Erro esperado: ' + erroEsperado);

        // Valida se o contratante foi criado
        System.assert(erroEsperado.contains('Insert failed'));
        System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        System.assert(erroEsperado.contains('Para cartão de crédito é necessário ter um cartão cadastrado!'));
    }

    @IsTest
    static void testValidarDadosPagamentoContratantePropostaSemCartaoCreditoPorto(){
        // Recupera dados
        Quote proposta = [SELECT Id, Produto__c FROM Quote LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 WHERE Id =: proposta.Produto__c LIMIT 1];
        String erroEsperado = '';

        // Apaga todos os contratantes da Proposta para gerar um novo
        List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
        delete listContratantePropostaParaDeletar;

        // Apaga todas as condicoes de cobranca
        List<CondicaoCobranca__c> listCondicaoCobranca = [SELECT Id FROM CondicaoCobranca__c];
        delete listCondicaoCobranca;

        // altera a forma de pagamento para cartao de credito
        formaPagamento.Codigo__c = 'CPO';
        update formaPagamento;

        // cria uma condicao de cobraca para cartao de credito
        CondicaoCobranca__c condicaoCobranca = new CondicaoCobranca__c(
            FormaPagamento__c = formaPagamento.Id,
            QuantidadeParcelas__c = '5',
            Produto__c = produto.Id
        );
        insert condicaoCobranca;

        // Apaga os cartões de credito do responsavel pelo pagamento
        List<CartaoCredito__c> listCartaoCredito = [SELECT Id FROM CartaoCredito__c WHERE Conta__c =: conta.Id];
        delete listCartaoCredito;

        // Gera um contratante da proposta
        ContratanteProposta__c contratanteProposta = new ContratanteProposta__c(
            Conta__c = conta.Id,
            Proposta__c = proposta.Id,
            Tipo__c = 'Principal',
            TipoEndereco__c = 'Residencial',
            Cep__c = '03020-000',
            TipoLogradouro__c = 'Rua',
            Logradouro__c = '15',
            NumeroEndereco__c = '15',
            Bairro__c = 'Osasco',
            Cidade__c = 'São Paulo',
            Estado__c = 'SP',
            Pais__c = 'Brasil',
            ResponsavelPagamento__c = conta.Id,
            FormaPagamento__c = formaPagamento.Id,
            PremioTotal__c = 10
        );

        Test.startTest();

        try{
            // Insere o contratante
            insert contratanteProposta;
        }catch (Exception e){
            erroEsperado = e.getMessage();
        }

        Test.stopTest();

        // Valida se o contratante foi criado
        System.assert(erroEsperado.contains('Insert failed'));
        System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        System.assert(erroEsperado.contains('Para pagamento no cartão de crédito Porto é necessário ter um cartão Porto cadastrado!'));
    }


    @IsTest
    static void testValidarDadosPagamentoContratantePropostaSemInformacaoBancaria(){
        // Recupera dados
        Quote proposta = [SELECT Id, Produto__c FROM Quote LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 WHERE Id =: proposta.Produto__c LIMIT 1];
        String erroEsperado = '';

        // Apaga todos os contratantes da Proposta para gerar um novo
        List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
        delete listContratantePropostaParaDeletar;

        // Apaga todas as condicoes de cobranca
        List<CondicaoCobranca__c> listCondicaoCobranca = [SELECT Id FROM CondicaoCobranca__c];
        delete listCondicaoCobranca;

        // altera a forma de pagamento para cartao de credito
        formaPagamento.Codigo__c = 'ADC';
        update formaPagamento;

        // cria uma condicao de cobraca para cartao de credito
        CondicaoCobranca__c condicaoCobranca = new CondicaoCobranca__c(
            FormaPagamento__c = formaPagamento.Id,
            QuantidadeParcelas__c = '5',
            Produto__c = produto.Id
        );
        insert condicaoCobranca;

        // Apaga os cartões de credito do responsavel pelo pagamento
        List<InformacaoBancaria__c> listInformacaoBancaria = [SELECT Id FROM InformacaoBancaria__c WHERE Conta__c =: conta.Id];
        delete listInformacaoBancaria;

        // Gera um contratante da proposta
        ContratanteProposta__c contratanteProposta = new ContratanteProposta__c(
            Conta__c = conta.Id,
            Proposta__c = proposta.Id,
            Tipo__c = 'Principal',
            TipoEndereco__c = 'Residencial',
            Cep__c = '03020-000',
            TipoLogradouro__c = 'Rua',
            Logradouro__c = '15',
            NumeroEndereco__c = '15',
            Bairro__c = 'Osasco',
            Cidade__c = 'São Paulo',
            Estado__c = 'SP',
            Pais__c = 'Brasil',
            ResponsavelPagamento__c = conta.Id,
            FormaPagamento__c = formaPagamento.Id,
            PremioTotal__c = 10
        );

        Test.startTest();

        try{
            // Insere o contratante
            insert contratanteProposta;
        }catch (Exception e){
            erroEsperado = e.getMessage();
        }

        Test.stopTest();

        // Valida se o contratante foi criado
        System.assert(erroEsperado.contains('Insert failed'));
        System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        System.assert(erroEsperado.contains('Para débito em conta é necessário ter uma informação bancária cadastrada!'));
    }

    @IsTest
    static void testValidarDadosPagamentoVidaProposta(){
        // Recupera dados
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
        GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];

        // Apaga todos os contratantes da Proposta para gerar um novo
        List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
        delete listVidaPropostaParaDeletar;

        Test.startTest();
        // Gera uma segurado do grupo da proposta
        SeguradoProposta__c vidaProposta = TestDataFactory.gerarSeguradoProposta(conta,grupoProposta,formaPagamento);
        Test.stopTest();

        // Valida se a segurado foi criada
        List<SeguradoProposta__c> listVidaProposta = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
        System.assert(listVidaProposta.size() > 0);
        System.assert(vidaProposta.Id != null);
    }

    @IsTest
    static void testValidarDadosPagamentoVidaPropostaSemInformacaoBancaria(){
        // Recupera dados
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
        GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
        String erroEsperado = '';

        // Apaga todos os contratantes da Proposta para gerar um novo
        List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
        delete listVidaPropostaParaDeletar;

        // Atualiza a forma de pagamento
        formaPagamento.Codigo__c = 'ADC';
        update formaPagamento;

        List<InformacaoBancaria__c> listInformacaoBancaria = [SELECT Id FROM InformacaoBancaria__c WHERE Conta__c =: conta.Id];
        delete listInformacaoBancaria;

        SeguradoProposta__c vidaGrupoProposta = new SeguradoProposta__c(
            Conta__c = conta.Id,
            FormaPagamento__c = formaPagamento.Id,
            PremioTotal__c = 10,
            QuantidadeParcelas__c = 1,
            GrupoProposta__c = grupoProposta.Id,
            ResponsavelPagamento__c = conta.Id
        );

        Test.startTest();
        // Gera uma segurado do grupo da proposta
        try{
            insert vidaGrupoProposta;
        }catch (Exception e){
            erroEsperado = e.getMessage();
        }
        Test.stopTest();

        // Valida se a segurado foi criada
        System.assert(erroEsperado.contains('Insert failed'));
        System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        System.assert(erroEsperado.contains('Para débito em conta é necessário ter uma informação bancária cadastrada!'));
    }

    @IsTest
    static void testValidarDadosPagamentoVidaPropostaSemCartaoCredito(){
        // Recupera dados
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
        GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
        String erroEsperado = '';

        // Apaga todos os contratantes da Proposta para gerar um novo
        List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
        delete listVidaPropostaParaDeletar;

        // Atualiza a forma de pagamento
        formaPagamento.Codigo__c = 'CAT';
        update formaPagamento;

        List<CartaoCredito__c> listCartaoCredito = [SELECT Id FROM CartaoCredito__c WHERE Conta__c =: conta.Id];
        delete listCartaoCredito;

        SeguradoProposta__c vidaGrupoProposta = new SeguradoProposta__c(
            Conta__c = conta.Id,
            FormaPagamento__c = formaPagamento.Id,
            PremioTotal__c = 10,
            QuantidadeParcelas__c = 1,
            GrupoProposta__c = grupoProposta.Id,
            ResponsavelPagamento__c = conta.Id
        );

        Test.startTest();
        // Gera uma segurado do grupo da proposta
        try{
            insert vidaGrupoProposta;
        }catch (Exception e){
            erroEsperado = e.getMessage();
        }
        Test.stopTest();

        // Valida se a segurado foi criada
        System.assert(erroEsperado.contains('Insert failed'));
        System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        System.assert(erroEsperado.contains('Para cartão de crédito é necessário ter um cartão cadastrado!'));
    }
    @IsTest
    static void testValidarDadosPagamentoVidaPropostaSemCartaoCreditoPorto(){
        // Recupera dados
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
        GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
        String erroEsperado = '';

        // Apaga todos os contratantes da Proposta para gerar um novo
        List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
        delete listVidaPropostaParaDeletar;

        // Atualiza a forma de pagamento
        formaPagamento.Codigo__c = 'CPO';
        update formaPagamento;

        List<CartaoCredito__c> listCartaoCredito = [SELECT Id FROM CartaoCredito__c WHERE Conta__c =: conta.Id];
        delete listCartaoCredito;

        SeguradoProposta__c vidaGrupoProposta = new SeguradoProposta__c(
            Conta__c = conta.Id,
            FormaPagamento__c = formaPagamento.Id,
            PremioTotal__c = 10,
            QuantidadeParcelas__c = 1,
            GrupoProposta__c = grupoProposta.Id,
            ResponsavelPagamento__c = conta.Id
        );

        Test.startTest();
        // Gera uma segurado do grupo da proposta
        try{
            insert vidaGrupoProposta;
        }catch (Exception e){
            erroEsperado = e.getMessage();
        }
        Test.stopTest();

        // Valida se a segurado foi criada
        System.assert(erroEsperado.contains('Insert failed'));
        System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        System.assert(erroEsperado.contains('Para pagamento no cartão de crédito Porto é necessário ter um cartão Porto cadastrado!'));
    }


}