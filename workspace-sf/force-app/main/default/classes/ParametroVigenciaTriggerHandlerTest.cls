@isTest
private class ParametroVigenciaTriggerHandlerTest {

	@testSetup 
	static void setup(){
        TestDataFactory.gerarDadosSetup();

        Account conta = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
            LastName = 'Teste2',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '00478394659',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = Date.valueOf('1980-12-24'),
            EstadoCivil__c = 'Solteiro (a)'
        );
        insert conta;

        Opportunity oportunidade = new Opportunity(
            Name = 'Teste Contrato',
            StageName = 'Em criação',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
            AccountId = conta.Id,
            CloseDate = Date.today()
        );
        insert oportunidade;

        Product2 produtoTec = new Product2(
                Name = 'Nome Produto Teste Versao',
                Status__c = 'Em criação',
                ProductCode = '201700001',
                VigenciaInicial__c = System.today().addDays(3),
                TipoCapital__c = 'Capital uniforme',
                Segmento__c = 'Coletivo',
                TipoResponsavelPagamento__c = 'PAR',
                NumeroSusep__c = '12345',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
                Versao__c                       = 1,
                VersaoMaxima__c                 = true,
                VersaoRenovacao__c              = 'Versão atual'
        );

        insert produtoTec;

        produtoTec.Status__c = 'Em ativação';
        produtoTec.NumeroSusep__c = '1234x';
        update produtoTec;

        produtoTec.Status__c = 'Ativo';
        update produtoTec;

	}

    @isTest
    private static void testarErrosParametroTecnicoDeterminado() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigencia;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                Tipo__c = 'Determinado',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro, 'Deveria ter ocorrido um erro de parametro de vigência com dados faltantes');
        System.assertEquals(true, mensagemErro.contains('Obrigatório preencher o tipo de período, o período máximo e mínimo de vigência.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroTecnicoPeriodico() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigencia;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                Tipo__c = 'Periódico',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro, 'Deveria ter ocorrido um erro de parametro de vigência com dados faltantes');
        System.assertEquals(true, mensagemErro.contains('Obrigatório preencher os períodos de cobertura mínimo e máximo e periodicidade.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialSemProduto() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Periódico',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            PeriodoCoberturaMinimo__c = 0,
            Periodicidade__c = 'Anos',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Periódico',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('O produto não pode ser alterado.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialDiferente() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Periódico',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            PeriodoCoberturaMinimo__c = 0,
            Periodicidade__c = 'Anos',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Determinado',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('O tipo de parâmetro de vigência não pode ser alterado.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialDeterminadoDiaMinimo() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Determinado',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            PeriodoMinimoVigencia__c = 1,
            PeriodoMaximoVigencia__c = 2,
            Periodicidade__c = 'Anos',
            TipoPeriodo__c = 'Anos',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Determinado',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                PeriodoMinimoVigencia__c = 366,
                PeriodoMaximoVigencia__c = 730,
                Periodicidade__c = 'Dias',
                TipoPeriodo__c = 'Dias',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Período mínimo de vigência acima do limite técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialDeterminadoDiaMaximo() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Determinado',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            PeriodoMinimoVigencia__c = 1,
            PeriodoMaximoVigencia__c = 2,
            Periodicidade__c = 'Anos',
            TipoPeriodo__c = 'Anos',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Determinado',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                PeriodoMinimoVigencia__c = 364,
                PeriodoMaximoVigencia__c = 732,
                Periodicidade__c = 'Dias',
                TipoPeriodo__c = 'Dias',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Período máximo de vigência acima do limite técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialDeterminadoAnoMinimo() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Determinado',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            PeriodoMinimoVigencia__c = 365,
            PeriodoMaximoVigencia__c = 730,
            Periodicidade__c = 'Dias',
            TipoPeriodo__c = 'Dias',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Determinado',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                PeriodoMinimoVigencia__c = 2,
                PeriodoMaximoVigencia__c = 2,
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Período mínimo de vigência acima do limite técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialDeterminadoAnoMaximo() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Determinado',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            PeriodoMinimoVigencia__c = 365,
            PeriodoMaximoVigencia__c = 730,
            Periodicidade__c = 'Dias',
            TipoPeriodo__c = 'Dias',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Determinado',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                PeriodoMinimoVigencia__c = 1,
                PeriodoMaximoVigencia__c = 3,
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Período máximo de vigência acima do limite técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialPeriodicoDiaMinimo() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Periódico',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            PeriodoCoberturaMinimo__c = 1,
            PeriodoCoberturaMaximo__c = 2,
            Periodicidade__c = 'Anos',
            TipoPeriodo__c = 'Anos',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Periódico',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                PeriodoCoberturaMinimo__c = 366,
                PeriodoCoberturaMaximo__c = 730,
                Periodicidade__c = 'Dias',
                TipoPeriodo__c = 'Dias',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Período de cobertura mínimo está acima do limite técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialPeriodicoDiaMaximo() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Periódico',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            PeriodoCoberturaMinimo__c = 1,
            PeriodoCoberturaMaximo__c = 2,
            Periodicidade__c = 'Anos',
            TipoPeriodo__c = 'Anos',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Periódico',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                PeriodoCoberturaMinimo__c = 364,
                PeriodoCoberturaMaximo__c = 732,
                Periodicidade__c = 'Dias',
                TipoPeriodo__c = 'Dias',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Período de cobertura máximo está acima do limite técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialPeriodicoAnoMinimo() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Periódico',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            PeriodoCoberturaMinimo__c = 365,
            PeriodoCoberturaMaximo__c = 730,
            Periodicidade__c = 'Dias',
            TipoPeriodo__c = 'Dias',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Periódico',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                PeriodoCoberturaMinimo__c = 2,
                PeriodoCoberturaMaximo__c = 2,
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Período de cobertura mínimo está acima do limite técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialPeriodicoAnoMaximo() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Periódico',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            PeriodoCoberturaMinimo__c = 365,
            PeriodoCoberturaMaximo__c = 730,
            Periodicidade__c = 'Dias',
            TipoPeriodo__c = 'Dias',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Periódico',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                PeriodoCoberturaMinimo__c = 1,
                PeriodoCoberturaMaximo__c = 3,
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Período de cobertura máximo está acima do limite técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialVitalicioResgate() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Vitalício',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            ModeloResgate__c = 'Percentual do capital',
            PrazoAplicacaoReajuste__c = '1',
            PrazoMinimoCancelamento__c = '1',
            IndiceReajuste__c = 'IGP-M',
            Periodicidade__c = 'Dias',
            TipoPeriodo__c = 'Dias',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Vitalício',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                ModeloResgate__c = 'Valor de prêmio pago',
                PrazoAplicacaoReajuste__c = '1',
                PrazoMinimoCancelamento__c = '1',
                IndiceReajuste__c = 'IGP-M',
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Modelo de resgate diferente do parâmetro técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialVitalicioRajuste() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Vitalício',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            ModeloResgate__c = 'Percentual do capital',
            PrazoAplicacaoReajuste__c = '1',
            PrazoMinimoCancelamento__c = '1',
            IndiceReajuste__c = 'IGP-M',
            Periodicidade__c = 'Dias',
            TipoPeriodo__c = 'Dias',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Vitalício',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                ModeloResgate__c = 'Percentual do capital',
                PrazoAplicacaoReajuste__c = '2',
                PrazoMinimoCancelamento__c = '1',
                IndiceReajuste__c = 'IGP-M',
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Prazo para aplicação de reajuste diferente do parâmetro técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialVitalicioCancelamento() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Vitalício',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            ModeloResgate__c = 'Percentual do capital',
            PrazoAplicacaoReajuste__c = '1',
            PrazoMinimoCancelamento__c = '1',
            IndiceReajuste__c = 'IGP-M',
            Periodicidade__c = 'Dias',
            TipoPeriodo__c = 'Dias',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Vitalício',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                ModeloResgate__c = 'Percentual do capital',
                PrazoAplicacaoReajuste__c = '1',
                PrazoMinimoCancelamento__c = '2',
                IndiceReajuste__c = 'IGP-M',
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Prazo mínimo de cancelamento diferente do parâmetro técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarErrosParametroComercialVitalicioIndice() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        parametroVigenciaTecnico = new ParametroVigencia__c(
            Tipo__c = 'Vitalício',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
            ModeloResgate__c = 'Percentual do capital',
            PrazoAplicacaoReajuste__c = '1',
            PrazoMinimoCancelamento__c = '1',
            IndiceReajuste__c = 'IGP-M',
            Periodicidade__c = 'Dias',
            TipoPeriodo__c = 'Dias',
            PeriodoMaximoInadimplencia__c = 30
        );
        insert parametroVigenciaTecnico;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Vitalício',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                ModeloResgate__c = 'Percentual do capital',
                PrazoAplicacaoReajuste__c = '1',
                PrazoMinimoCancelamento__c = '1',
                IndiceReajuste__c = 'IPCA',
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, ocorrreuErro);
        System.assertEquals(true, mensagemErro.contains('Índice de reajuste diferente do parâmetro técnico.'), 'Mensagem incorreta: ' + mensagemErro);
    }

    @isTest
    private static void testarParametroComercial() {
        Boolean ocorrreuErro;
        String mensagemErro;
        ParametroVigencia__c parametroVigenciaTecnico;
        ParametroVigencia__c parametroVigencia;

        ocorrreuErro = false;
        mensagemErro = '';

        Test.startTest();
        try {
            parametroVigenciaTecnico = new ParametroVigencia__c(
                Tipo__c = 'Determinado',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
                PeriodoMinimoVigencia__c = 1,
                PeriodoMaximoVigencia__c = 2,
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigenciaTecnico;

            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Determinado',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                PeriodoMinimoVigencia__c = 1,
                PeriodoMaximoVigencia__c = 2,
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;

            parametroVigenciaTecnico = new ParametroVigencia__c(
                Tipo__c = 'Periódico',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
                PeriodoCoberturaMinimo__c = 1,
                PeriodoCoberturaMaximo__c = 2,
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigenciaTecnico;

            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Periódico',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                PeriodoCoberturaMinimo__c = 1,
                PeriodoCoberturaMaximo__c = 2,
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;

            parametroVigenciaTecnico = new ParametroVigencia__c(
                Tipo__c = 'Vitalício',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
                ModeloResgate__c = 'Percentual do capital',
                PrazoAplicacaoReajuste__c = '1',
                PrazoMinimoCancelamento__c = '1',
                IndiceReajuste__c = 'IGP-M',
                Periodicidade__c = 'Dias',
                TipoPeriodo__c = 'Dias',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigenciaTecnico;

            parametroVigencia = new ParametroVigencia__c(
                ParametroVigencia__c = parametroVigenciaTecnico.Id,
                Tipo__c = 'Vitalício',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                Produto__r = new Product2(Name = 'Nome Produto Teste Versao'),
                ModeloResgate__c = 'Percentual do capital',
                PrazoAplicacaoReajuste__c = '1',
                PrazoMinimoCancelamento__c = '1',
                IndiceReajuste__c = 'IGP-M',
                Periodicidade__c = 'Anos',
                TipoPeriodo__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
            );
            insert parametroVigencia;
        }
        catch(DmlException e) {
            ocorrreuErro = true;
            mensagemErro = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(false, ocorrreuErro, mensagemErro);
        System.assertEquals(true, String.isBlank(mensagemErro));
    }
    //PLV-3460 Fix 5 - INICIO - Metodo criado para cobrir a trigger no momento de update
    @isTest
    public static void atualizarRegistro(){

        Product2 produtoTecnico = [SELECT Id, Status__c,GerarVoucher__c FROM Product2 WHERE ProductCode = '201700001' LIMIT 1]; //PLV - 4440 INICIO / FIM
        ParametroVigencia__c parametroTec = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaTecnico(produtoTecnico).createRecord();
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        ParametroVigencia__c parametroCom = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaComercial(produtoComercial).createRecord();
        parametroCom.ParametroVigencia__c = parametroTec.Id;
        Test.startTest();
        update parametroCom;
        Test.stopTest();
    }
    //PLV-3460 Fix 5 - FIM
	
}