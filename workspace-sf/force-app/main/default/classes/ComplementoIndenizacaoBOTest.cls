@isTest
class ComplementoIndenizacaoBOTest {
    @isTest
    static void criarComplementoTest()
    {
        SinistroJuridicoBO.Request sinistro = new SinistroJuridicoBO.Request();
        sinistro.movimento = 24;
		MovimentoSinistroTO.Movimento movimentoTO = MovimentoSinistroTO.MAPA_MOV_POR_VALOR.get(sinistro.movimento);
        Decimal valorComplemento = 1000;
		Id pagamentoGarantiaId = Util.gerarIdFalso(Schema.PagamentoGarantia__c.getSObjectType());
        String tipo = 'Juros';
        ComplementoIndenizacao__c complemento = ComplementoIndenizacaoBO.getInstance().criarComplemento(
            sinistro, valorComplemento, pagamentoGarantiaId, tipo // LECVPV-200 INICIO/FIM // LECVPV-216 INICIO/FIM
        );
        System.assertEquals(complemento.Valor__c, valorComplemento);
        System.assertEquals(movimentoTO.descricao, complemento.Descricao__c);
        System.assertEquals(tipo, complemento.TipoComplemento__c);
        System.assertEquals(pagamentoGarantiaId, complemento.PagamentoGarantia__c);
    }

    @isTest
    static void calcularValorComplementoPorTipoTest()
    {
        ComplementoIndenizacao__c cmp = new ComplementoIndenizacao__c(
            TipoComplemento__c = 'Juros',
            Valor__c = 1
        );
        List<ComplementoIndenizacao__c> complementos = new List<ComplementoIndenizacao__c>
        {
            cmp,
            new ComplementoIndenizacao__c(
                TipoComplemento__c = 'Atualização Monetária',
                Valor__c = 2
            )
        };
		String tipo = 'Juros';

        Test.startTest();
        Decimal valor = ComplementoIndenizacaoBO.getInstance().calcularValorComplementoPorTipo(complementos, tipo);
        Test.stopTest();
        System.assertEquals(1, valor);
    }

    // LECVPV-216 INICIO
    // @isTest
    // static void criarComplementoPorTipoTest()
    // {
    //     SinistroJuridicoBO.Request sinistro = new SinistroJuridicoBO.Request();
    //     sinistro.movimento = 24;
    //     ComplementoIndenizacao__c cmp = new ComplementoIndenizacao__c(
    //         TipoComplemento__c = 'Juros',
    //         Valor__c = 1
    //     );
    //     List<ComplementoIndenizacao__c> complementos = new List<ComplementoIndenizacao__c>
    //     {
    //         cmp,
    //         new ComplementoIndenizacao__c(
    //             TipoComplemento__c = 'Atualização Monetária',
    //             Valor__c = 2
    //         )
    //     };
	// 	String tipo = 'Juros';
    //     Id pagamentoGarantiaId = Util.gerarIdFalso(Schema.PagamentoGarantia__c.getSObjectType());

    //     Test.startTest();
    //     // LECVPV-200 INICIO
    //     ComplementoIndenizacao__c complementofechamento = ComplementoIndenizacaoBO.getInstance().criarComplementoPorTipo(
    //         sinistro, complementos, tipo, pagamentoGarantiaId, false, 1  
    //     );
    //     ComplementoIndenizacao__c complementopagamento = ComplementoIndenizacaoBO.getInstance().criarComplementoPorTipo(
    //         'Baixa Por Pagamento', complementos, tipo, pagamentoGarantiaId, true, 0.30  
    //     );
    //     Test.stopTest();
    //     System.assertEquals(-cmp.Valor__c, complementofechamento.Valor__c, 'criarComplementoPorTipoTest(0): Valor diferente do esperado.'); 
    //     System.assertEquals(-cmp.Valor__c*0.30, complementopagamento.Valor__c, 'criarComplementoPorTipoTest(0): Valor diferente do esperado.'); 
    //     // LECVPV-200 FIM
    // }
      // LECVPV-216 FIM

    @isTest
    static void criarComplementosDeFechamentoTest()
    {
        // LECVPV-216 INICIO
     //   SinistroJuridicoBO.Request sinistro = new SinistroJuridicoBO.Request();
      //  sinistro.movimento = 24;
        ComplementoIndenizacao__c cmp = new ComplementoIndenizacao__c(
            TipoComplemento__c = 'Juros',
            Valor__c = 1
        );
        List<ComplementoIndenizacao__c> complementos = new List<ComplementoIndenizacao__c>
        {
            cmp,
            new ComplementoIndenizacao__c(
                TipoComplemento__c = 'Atualização Monetária',
                Valor__c = 2
            )
        };
        Id pagamentoGarantiaId = Util.gerarIdFalso(Schema.PagamentoGarantia__c.getSObjectType());

        Test.startTest();
        List<ComplementoIndenizacao__c> complementosDeFechamento = ComplementoIndenizacaoBO.getInstance().criarComplementosDeFechamento(
            complementos, pagamentoGarantiaId
        );
        // LECVPV-216 FIM
        Test.stopTest();
        System.assertEquals(2, complementosDeFechamento.size());
        for(Integer index = 0; index < complementosDeFechamento.size(); index++)
        {
            ComplementoIndenizacao__c complemento = complementosDeFechamento.get(index);
            System.assertEquals((index == 0? 'Juros' : 'Atualização Monetária'), complemento.TipoComplemento__c);
            System.assertEquals(-(index == 0? 1 : 2), complemento.Valor__c);
        }
    }

    // LECVPV-200 INICIO
    @isTest
    static void criarComplementosBaixaPorPagamentoTest() {

        SinistroJuridicoBO.Request sinistrojuros = new SinistroJuridicoBO.Request();
        sinistrojuros.movimento = 52;
        SinistroJuridicoBO.Request sinistrocorrecao = new SinistroJuridicoBO.Request();
        sinistrocorrecao.movimento = 62;

        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();

        insert conta;

        RecordType rtAtendimento = [SELECT Id FROM RecordType WHERE DeveloperName = 'Atendimento' LIMIT 1];
        RecordType rtSinistro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sinistro' LIMIT 1];

        Case casoAtendimento = new Case(
            AccountId = conta.Id,
            Vitima__c = 'Segurado',
            Origin = 'Backoffice',
            Type = 'Sinistro',
            RecordTypeId = rtAtendimento.Id
        );

        insert casoAtendimento; 

        Case casoSinistro = new Case(
            AccountId = conta.Id,
            Origin = 'Backoffice',
            Type = 'Sinistro',
            RecordTypeId = rtSinistro.Id,
            Sinistro_Judicial__c = false,
            ParentId = casoAtendimento.Id
        );

        insert casoSinistro; 

        PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
            Name = 'Assistência Funeral Individual',
            Caso__c = casoSinistro.Id ,
            Valor_indenizado__c = 10000,
            Fase__c = 'Em Análise',
            Status_do_pagamento__c = 'Em Análise'
        );

        insert pagamentoGarantia;

     //   Id pagamentoGarantiaId = Util.gerarIdFalso(Schema.PagamentoGarantia__c.getSObjectType());
        List<ComplementoIndenizacao__c> complementosCriar = new List<ComplementoIndenizacao__c>();
        Decimal valorJuros = 3000;
        Decimal valorCorrecao = 1000;
        Decimal fator = 0.50;
        // LECVPV-216 INICIO
        ComplementoIndenizacao__c complementoJuros = ComplementoIndenizacaoBO.getInstance().criarComplemento(
            sinistrojuros, valorJuros, pagamentoGarantia.Id, 'Juros'
        );
        insert complementoJuros;

        ComplementoIndenizacao__c complementoCorrecao = ComplementoIndenizacaoBO.getInstance().criarComplemento(
            sinistrocorrecao, valorCorrecao, pagamentoGarantia.Id, 'Atualização Monetária'
        );

        insert complementoCorrecao;

        // LECVPV-216 FIM
        Test.startTest();  
            List<ComplementoIndenizacao__c> complementosBaixar = ComplementoIndenizacaoBO.getInstance().criarComplementosBaixaPorPagamento(fator,pagamentoGarantia.Id);
        Test.stopTest();

        Decimal valorComplementos = 0;
        for (ComplementoIndenizacao__c compl : complementosBaixar) {
            valorComplementos += compl.Valor__c;
        }
        System.assertEquals(2, complementosBaixar.size(),'A quantidade de complementos de baixa por pagamento deve ser igual aos complementos da Garantia(Nesse caso,2.)');
        System.assertEquals((valorJuros + valorCorrecao)*fator, valorComplementos*(-1),'O valor total dos complementos de baixa por pagamento criados não foi o esperado.');
    }
    // LECVPV-200 FIM
}