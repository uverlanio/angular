// POR062-1 - INICIO
//LECVP-140 INICIO
@isTest
private class MovimentoSinistroBOTest {
    @isTest static void testarMapearListaMovimentosPorIdCaso(){

        Test.startTest();

        Case caso = new Case(
            Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
        );

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            Caso__c = caso.Id
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);

        MovimentoSinistroBO.getInstance().mapearListaMovimentosPorIdCaso(listaMovimentos);

        Test.stopTest();
    }

    @isTest static void testarRecuperarSequenciaMovimento(){

        Test.startTest();

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            SequenciaMovimento__c = '2'
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);

        MovimentoSinistroBO.getInstance().recuperarSequenciaMovimento(listaMovimentos);

        Test.stopTest();
    }

    @isTest static void testarCalcularValorFechamentoMovimentosAdministrativos(){

        Test.startTest();

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            SinistroJudicial__c = false,
            DescricaoMovimento__c = '2',
            ValorMovimento__c = 1000
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);

        MovimentoSinistroBO.getInstance().calcularValorFechamentoMovimentos(movimento,true); // LECVPV-140-FIX02 INICIO/FIM

        Test.stopTest();
    }

    @isTest static void testarCalcularValorFechamento(){

        Test.startTest();

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            SinistroJudicial__c = true,
            DescricaoMovimento__c = '1',
            ValorMovimento__c = 1000
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);

     //   MovimentoSinistroBO.getInstance().calcularValorFechamento(listaMovimentos);  // LECVPV-148 INICIO/FIM

        Test.stopTest();
    }

    @isTest static void testarCalcularValorReabertura(){

        Test.startTest();

        MovimentoSinistro__c movimento1 = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            SinistroJudicial__c = true,
            DescricaoMovimento__c = '22',
            ValorMovimento__c = 1000
        );

        MovimentoSinistro__c movimento2 = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            SinistroJudicial__c = true,
            DescricaoMovimento__c = '24',
            ValorMovimento__c = 1000
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento1);
        listaMovimentos.add(movimento2);

        MovimentoSinistroBO.getInstance().calcularValorReabertura(listaMovimentos);

        Test.stopTest();
    }

    @isTest static void testarCalcularValorIndenizado(){

        Test.startTest();

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            SinistroJudicial__c = true,
            DescricaoMovimento__c = '22',
            ValorMovimento__c = 1000
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);

        MovimentoSinistroBO.getInstance().calcularValorIndenizado(listaMovimentos);

        Test.stopTest();
    }

    @isTest static void testarCalcularValorJuros(){

        Test.startTest();

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            SinistroJudicial__c = true,
            DescricaoMovimento__c = '52',
            ValorMovimento__c = 1000
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);

        MovimentoSinistroBO.getInstance().calcularValorJuros(listaMovimentos, true);

        Test.stopTest();
    }

    @isTest static void testarCalcularValorCorrecao(){

        Test.startTest();
        
        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            SinistroJudicial__c = true,
            DescricaoMovimento__c = '62',
            ValorMovimento__c = 1000
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);

        MovimentoSinistroBO.getInstance().calcularValorCorrecao(listaMovimentos, true);

        Test.stopTest();
    }

    @isTest static void testarCriarMovimentoAdministrativoComMovimento(){

        Test.startTest();

        Case caso = new Case(
            Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
        );

        // LECVPV-140-FIX02 INICIO
        MovimentoSinistroBO.getInstance().criarMovimento(
            caso.Id,
            MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO,
            10, 
            '1',
            null,
            false
        );
        // LECVPV-140-FIX02 FIM

        Test.stopTest();
    }

    @isTest static void testarCriarMovimentoAdministrativoComDescricaoETipo(){

        Test.startTest();

        Case caso = new Case(
            Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
        );


        // LECVPV-140-FIX02 INICIO
        MovimentoSinistroBO.getInstance().criarMovimento(
            caso.Id,
            MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.descricao,
            MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.tipo,
            10, 
            '1',
            null,
            false
        );
        // LECVPV-140-FIX02 FIM

        Test.stopTest();
    }

    @isTest static void testarCriarMovimentoJuridicoComMovimento(){

        Test.startTest();

        Case caso = new Case(
            Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
        );


        // LECVPV-140-FIX02 INICIO
        MovimentoSinistroBO.getInstance().criarMovimento(
            caso.Id,
            MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO,
            10, 
            '1',
            null,
            true
        );
         // LECVPV-140-FIX02 FIM

        Test.stopTest();
    }

    @isTest static void testarCriarMovimentoJuridicoComDescricaoETipo(){

        Test.startTest();

        Case caso = new Case(
            Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
        );


         // LECVPV-140-FIX02 INICIO
        MovimentoSinistroBO.getInstance().criarMovimento(
            caso.Id,
            MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.descricao,
            MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.tipo,
            10, 
            '1',
            null,
            false
        );
         // LECVPV-140-FIX02 FIM

        Test.stopTest();
    }

    @isTest static void testarCriarMovimento(){

        Test.startTest();

        Case caso = new Case(
            Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
        );


        MovimentoSinistroBO.getInstance().criarMovimento(
            caso.Id,
            MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.descricao,
            MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.tipo,
            10, 
            '1',
            null,
            true
        );

        Test.stopTest();
    }

    // LECVPV-216 INICIO
    @isTest
    static void criarMovimentoEncerramentoAdministrativo() {
        Case caso = new Case(
            Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
        );

        Test.startTest();
        MovimentoSinistro__c mov1 =  MovimentoSinistroBO.getInstance().criarMovimentoEncerramentoAdministrativo(
            caso.Id,
            MovimentoSinistroTO.REATIVACAO.descricao,
            MovimentoSinistroTO.REATIVACAO.tipo,
            10, 
            '1',
            null
        );
        Test.stopTest();

        System.assertEquals(false, mov1.SinistroJudicial__c);
        System.assertEquals(10, mov1.ValorMovimento__c);
    }

    @isTest
    static void criarMovimentoEncerramentoJuridico() {
        Case caso = new Case(
            Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
        );

        Test.startTest();
        MovimentoSinistro__c mov1 =  MovimentoSinistroBO.getInstance().criarMovimentoEncerramentoJuridico(
            caso.Id,
            MovimentoSinistroTO.REATIVACAO.descricao,
            MovimentoSinistroTO.REATIVACAO.tipo,
            10, 
            '1',
            null
        );
        Test.stopTest();

        System.assertEquals(true, mov1.SinistroJudicial__c);
        System.assertEquals(10, mov1.ValorMovimento__c);
    }
    // LECVPV-216 FIM

    @isTest static void testarCriarMovimentosReativacaoAdministrativo(){

        Test.startTest();

        Case caso = new Case(
            Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
        );

        PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
            Id = Util.gerarIdFalso(Schema.PagamentoGarantia__c.getSObjectType()),
            Name = 'Assistência Funeral Individual',
            Caso__c = caso.Id
        );

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            SinistroJudicial__c = false,
            DescricaoMovimento__c = '1',
            ValorMovimento__c = 1000,
            PagamentoGarantia__c = pagamentoGarantia.Id
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);

        MovimentoSinistroBO.getInstance().criarMovimentosReativacaoJuridico(caso.Id, listaMovimentos); // LECVPV-140-FIX02 INICIO/FIM

        Test.stopTest();
    }

    @isTest static void testarCriarMovimentoFechamentoAdministrativoEReaberturaJuridicoComValorFechamento(){

        Test.startTest();

        //LECVP-216 - INICIO

        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();

        insert conta;

        Product2 produtoComercial = new Product2(
            Name = 'teste',
            NumeroSusep__c = '123',
            VersaoRenovacao__c = 'Versão atual',
            Status__c = 'Ativo'
        );
        
        RamoAtividade__c ramoAtividade = (RamoAtividade__c) new RamoAtividadeFactory().createRecord();
        Account contaParceiro = (Account) new AccountFactory.PessoaJuridica(ramoAtividade).getRecord();
        insert contaParceiro;
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();

        Parceiro__c parceiroPrestadora = new Parceiro__c(
            Status__c = 'Ativo',
            Sucursal__c = '1',
            Ramo__c = '1391',
            Empresa__c = '1',
            Conta__c = contaParceiro.Id,
            FormaPagamento__c = formaPagamento.Id,
            DiaFaturamento__c = '15',
            DiaPreFaturamento__c = '20',
            PrazoVencimento__c = '10',
            FaturaProdutosSeparados__c = 'Sim',
            PossuiAnexoFatura__c = 'Nao',
            SiglaParceiro__c = 'PAR'
        );

        insert parceiroPrestadora;

        Contract contrato =  new Contract(
            Name = 'teste',
            AccountId = conta.id,
            Produto__c = produtoComercial.Id,
            Parceria__c = parceiroPrestadora.id
        );

        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
            Contrato__c = contrato.Id,
            Conta__c = conta.Id,
            Tipo__c = 'Principal'
        );

        insert contratanteContrato;

        GrupoContrato__c grupoContrato = new GrupoContrato__c(
            ContratanteContrato__c = contratanteContrato.Id
        );

        insert grupoContrato;

        SeguradoContrato__c seguradoContrato = new SeguradoContrato__c(
            Conta__c = conta.Id,
            GrupoContrato__c = grupoContrato.Id,
            VigenciaInicial__c = system.today(),
            VigenciaFinal__c = system.today().addMonths(1)
        );
        
        insert seguradoContrato;

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().getRecord();
        garantia.Sigla__c = 'AFF';

        insert garantia;

        GarantiaSeguradoContrato__c garantiaSeguradoContrato = new GarantiaSeguradoContrato__c(
            SeguradoContrato__c = seguradoContrato.Id,
            Garantia__c = garantia.Id
        );

        insert garantiaSeguradoContrato;

        Case caso = new Case(
            Sinistro_Judicial__c = false,
            Origin = 'Atendimento'
        );

        insert caso;
       
        PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
            Name = 'Assistência Funeral Individual',
            Caso__c = caso.Id,
            Garantia_do_segurado_do_contrato__c = garantiaSeguradoContrato.Id            
        );

        insert pagamentoGarantia;

        //LECVP-216 - FIM

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
           // Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()), // LECVPV-148 INICIO/FIM
            SinistroJudicial__c = false,
            DescricaoMovimento__c = '1',
            SequenciaMovimento__c = '1',
            ValorMovimento__c = 1000,
            PagamentoGarantia__c = pagamentoGarantia.Id //LECVP-216 - INICIO / FIM
        );

        // LECVPV-148 INICIO
        MovimentoSinistro__c movimento2 = new MovimentoSinistro__c(
             SinistroJudicial__c = false,
             DescricaoMovimento__c = '2',
             SequenciaMovimento__c = '2',
             ValorMovimento__c = 2000,
             PagamentoGarantia__c = pagamentoGarantia.Id //LECVP-216 - INICIO / FIM
         );
         // LECVPV-148 INICIO

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);
        listaMovimentos.add(movimento2);
        insert listaMovimentos; // LECVPV-148 INICIO/FIM
 
        MovimentoSinistroBO.getInstance().criarMovimentoFechamento(caso.Id, listaMovimentos,false,true);  // LECVPV-140-FIX02 INICIO/FIM LECVPV-216 INICIO/FIM

        Test.stopTest();
    }

    @isTest static void testarCriarMovimentoFechamentoAdministrativoEReaberturaJuridicoSemValorFechamento(){

        Test.startTest();

        Case caso = new Case(
            Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
        );

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            SinistroJudicial__c = true,
            DescricaoMovimento__c = '1',
            SequenciaMovimento__c = '1',
            ValorMovimento__c = 0
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);

        MovimentoSinistroBO.getInstance().criarMovimentoFechamento(caso.Id, listaMovimentos,false, true);  // LECVPV-140-FIX02 INICIO/FIM LECVPV-216 INICIO/FIM

        Test.stopTest();
    }
     
    // LECVPV-216 INICIO
    @isTest static void testarCriarMovimentoFechamentoComJuroseCorrecao(){
                

        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();

        insert conta;

        Product2 produtoComercial = new Product2(
            Name = 'teste',
            NumeroSusep__c = '123',
            VersaoRenovacao__c = 'Versão atual',
            Status__c = 'Ativo'
        );
        
        RamoAtividade__c ramoAtividade = (RamoAtividade__c) new RamoAtividadeFactory().createRecord();
        Account contaParceiro = (Account) new AccountFactory.PessoaJuridica(ramoAtividade).getRecord();
        insert contaParceiro;
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();

        Parceiro__c parceiroPrestadora = new Parceiro__c(
            Status__c = 'Ativo',
            Sucursal__c = '1',
            Ramo__c = '1391',
            Empresa__c = '1',
            Conta__c = contaParceiro.Id,
            FormaPagamento__c = formaPagamento.Id,
            DiaFaturamento__c = '15',
            DiaPreFaturamento__c = '20',
            PrazoVencimento__c = '10',
            FaturaProdutosSeparados__c = 'Sim',
            PossuiAnexoFatura__c = 'Nao',
            SiglaParceiro__c = 'PAR'
        );

        insert parceiroPrestadora;

        Contract contrato =  new Contract(
            Name = 'teste',
            AccountId = conta.id,
            Produto__c = produtoComercial.Id,
            Parceria__c = parceiroPrestadora.id
        );

        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
            Contrato__c = contrato.Id,
            Conta__c = conta.Id,
            Tipo__c = 'Principal'
        );

        insert contratanteContrato;

        GrupoContrato__c grupoContrato = new GrupoContrato__c(
            ContratanteContrato__c = contratanteContrato.Id
        );

        insert grupoContrato;

        SeguradoContrato__c seguradoContrato = new SeguradoContrato__c(
            Conta__c = conta.Id,
            GrupoContrato__c = grupoContrato.Id,
            VigenciaInicial__c = system.today(),
            VigenciaFinal__c = system.today().addMonths(1)
        );
        
        insert seguradoContrato;

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().getRecord();
        garantia.Sigla__c = 'AFF';

        insert garantia;

        GarantiaSeguradoContrato__c garantiaSeguradoContrato = new GarantiaSeguradoContrato__c(
            SeguradoContrato__c = seguradoContrato.Id,
            Garantia__c = garantia.Id
        );

        insert garantiaSeguradoContrato;

        Case caso = new Case(
            Sinistro_Judicial__c = true,
            Origin = 'Atendimento'
        );

        insert caso;
       
        PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
            Name = 'Assistência Funeral Individual',
            Caso__c = caso.Id,
            Garantia_do_segurado_do_contrato__c = garantiaSeguradoContrato.Id,
            Fase__c = 'Em Análise'            
        );

        insert pagamentoGarantia;

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            SinistroJudicial__c = true,
            DescricaoMovimento__c = '1',
            SequenciaMovimento__c = '1',
            ValorMovimento__c = 1000,
            PagamentoGarantia__c = pagamentoGarantia.Id 
        );

        MovimentoSinistro__c movimento2 = new MovimentoSinistro__c(
             SinistroJudicial__c = true,
             DescricaoMovimento__c ='52',
             SequenciaMovimento__c = '2',
             ValorMovimento__c = 200,
             PagamentoGarantia__c = pagamentoGarantia.Id
         );

         MovimentoSinistro__c movimento3 = new MovimentoSinistro__c(
            SinistroJudicial__c = true,
            DescricaoMovimento__c ='62',
            SequenciaMovimento__c = '3',
            ValorMovimento__c = 50,
            PagamentoGarantia__c = pagamentoGarantia.Id
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);
        listaMovimentos.add(movimento2);
        listaMovimentos.add(movimento3);
        insert listaMovimentos; 

        Test.startTest();
 
        List<MovimentoSinistro__c> movsFechamento = MovimentoSinistroBO.getInstance().criarMovimentoFechamento(caso.Id, listaMovimentos,true, false); // LECVPV-216 INICIO/FIM

        Test.stopTest();

        Decimal total = 0;
        for (MovimentoSinistro__c mov: movsFechamento ) {
          total += mov.ValorMovimento__c;
        }
        System.assertEquals(movsFechamento.size(), 3);
        System.assertEquals(total, -1250);
    }
    //LECVPV-216 FIM

    //LECVPV-215 INICIO
    @isTest static void testarCriarMovimentoFechamentoGarantia() {

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
            Sinistro_Judicial__c = true,
            ParentId = casoAtendimento.Id
        );
            
        insert casoSinistro; 
        
        PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
            Name = 'Assistência Funeral Individual',
            Caso__c = casoSinistro.Id ,
            Valor_indenizado__c = 20000,
            Fase__c = 'Fechado',
            Motivo_da_Recusa__c = '49',
            Status_do_pagamento__c = 'Recusado'
        );
            
        insert pagamentoGarantia;
                
        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            SinistroJudicial__c = true,
            TipoMovimento__c = 'Aviso',
            DescricaoMovimento__c = '1',
            SequenciaMovimento__c = '1',
            ValorMovimento__c = 1000,
            PagamentoGarantia__c = pagamentoGarantia.Id 
        );
    
        MovimentoSinistro__c movimento2 = new MovimentoSinistro__c(
            SinistroJudicial__c = true,
            TipoMovimento__c = 'Aviso',
            DescricaoMovimento__c = '2',
            SequenciaMovimento__c = '2',
            ValorMovimento__c = 2000,
            PagamentoGarantia__c = pagamentoGarantia.Id 
        );

        MovimentoSinistro__c movimento3 = new MovimentoSinistro__c(
            SinistroJudicial__c = true,
            TipoMovimento__c = 'Aviso',
            DescricaoMovimento__c = '52',
            SequenciaMovimento__c = '3',
            ValorMovimento__c = 500,
            PagamentoGarantia__c = pagamentoGarantia.Id 
        );

        MovimentoSinistro__c movimento4 = new MovimentoSinistro__c(
            SinistroJudicial__c = true,
            TipoMovimento__c = 'Aviso',
            DescricaoMovimento__c = '62',
            SequenciaMovimento__c = '4',
            ValorMovimento__c = 100,
            PagamentoGarantia__c = pagamentoGarantia.Id 
        );
                
        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);
        listaMovimentos.add(movimento2);
        listaMovimentos.add(movimento3);
        listaMovimentos.add(movimento4);
        insert listaMovimentos; 
        
        Test.startTest();
            List<MovimentoSinistro__c> movimentosCriados = MovimentoSinistroBO.getInstance().criarMovimentoFechamentoGarantia(pagamentoGarantia.Id , 5, true, true);
        Test.stopTest();

        System.assertEquals(movimentosCriados.size(), 3);
        Decimal totalMovimentos = 0;
        for (MovimentoSinistro__c mov : movimentosCriados) {
            totalMovimentos += mov.ValorMovimento__c;
        }
        System.assertEquals(totalMovimentos, -3600);
    }
    // LECVPV-215 FIM

    // LECVPV-140-FIX02 INICIO
    // @isTest static void testarCriarMovFechaAdmEReabJur(){

    //     Test.startTest();

    //     Case caso1 = new Case(
    //         Id = Util.gerarIdFalso(Schema.Case.getSObjectType()),
    //         Sinistro_Judicial__c = true
    //     );

    //     Case caso2 = new Case(
    //         Id = Util.gerarIdFalso(Schema.Case.getSObjectType()),
    //         Sinistro_Judicial__c = false
    //     );

    //     Case caso3 = new Case(
    //         Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
    //     );        

    //     List<Case> listaCasos = new List<Case>();
    //     listaCasos.add(caso1);
    //     listaCasos.add(caso2);        

    //     MovimentoSinistro__c movimento = new MovimentoSinistro__c(
    //         Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
    //         Caso__c = caso3.Id
    //     );

    //     List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
    //     listaMovimentos.add(movimento);

    //     Map<Id, List<MovimentoSinistro__c>> movimentosPorIdCaso = new Map<Id, List<MovimentoSinistro__c>>();
    //     movimentosPorIdCaso.put(caso1.Id, listaMovimentos);         

    //     MovimentoSinistroBO.getInstance().criarMovFechaAdmEReabJur(listaCasos, movimentosPorIdCaso);

    //     movimentosPorIdCaso = new Map<Id, List<MovimentoSinistro__c>>();
    //     listaCasos = new List<Case>();
    //     listaCasos.add(caso3);
    //     movimentosPorIdCaso.put(caso3.Id, new List<MovimentoSinistro__c>());
    //     MovimentoSinistroBO.getInstance().criarMovFechaAdmEReabJur(listaCasos, movimentosPorIdCaso);        

    //     Test.stopTest();
    // }
    // LECVPV-140-FIX02 FIM

     // LECVPV-140-FIX02 INICIO
    // @isTest static void testarCriarMovFechaAdmEReabJur2(){

    //     Test.startTest();

    //     //LECVP-216 - INICIO

    //     Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();

    //     insert conta;

    //     Product2 produtoComercial = new Product2(
    //         Name = 'teste',
    //         NumeroSusep__c = '123',
    //         VersaoRenovacao__c = 'Versão atual',
    //         Status__c = 'Ativo'
    //     );
        
    //     RamoAtividade__c ramoAtividade = (RamoAtividade__c) new RamoAtividadeFactory().createRecord();
    //     Account contaParceiro = (Account) new AccountFactory.PessoaJuridica(ramoAtividade).getRecord();
    //     insert contaParceiro;
    //     FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();

    //     Parceiro__c parceiroPrestadora = new Parceiro__c(
    //         Status__c = 'Ativo',
    //         Sucursal__c = '1',
    //         Ramo__c = '1391',
    //         Empresa__c = '1',
    //         Conta__c = contaParceiro.Id,
    //         FormaPagamento__c = formaPagamento.Id,
    //         DiaFaturamento__c = '15',
    //         DiaPreFaturamento__c = '20',
    //         PrazoVencimento__c = '10',
    //         FaturaProdutosSeparados__c = 'Sim',
    //         PossuiAnexoFatura__c = 'Nao',
    //         SiglaParceiro__c = 'PAR'
    //     );

    //     insert parceiroPrestadora;

    //     Contract contrato =  new Contract(
    //         Name = 'teste',
    //         AccountId = conta.id,
    //         Produto__c = produtoComercial.Id,
    //         Parceria__c = parceiroPrestadora.id
    //     );

    //     ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
    //         Contrato__c = contrato.Id,
    //         Conta__c = conta.Id,
    //         Tipo__c = 'Principal'
    //     );

    //     insert contratanteContrato;

    //     GrupoContrato__c grupoContrato = new GrupoContrato__c(
    //         ContratanteContrato__c = contratanteContrato.Id
    //     );

    //     insert grupoContrato;

    //     SeguradoContrato__c seguradoContrato = new SeguradoContrato__c(
    //         Conta__c = conta.Id,
    //         GrupoContrato__c = grupoContrato.Id,
    //         VigenciaInicial__c = system.today(),
    //         VigenciaFinal__c = system.today().addMonths(1)
    //     );
        
    //     insert seguradoContrato;

    //     Garantia__c garantia = (Garantia__c) new GarantiaFactory().getRecord();
    //     garantia.Sigla__c = 'AFF';

    //     insert garantia;

    //     GarantiaSeguradoContrato__c garantiaSeguradoContrato = new GarantiaSeguradoContrato__c(
    //         SeguradoContrato__c = seguradoContrato.Id,
    //         Garantia__c = garantia.Id
    //     );

    //     insert garantiaSeguradoContrato;

    //     Case caso = new Case(
    //         Sinistro_Judicial__c = false,
    //         Origin = 'Atendimento'
    //     );

    //     insert caso;
       
    //     PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
    //         Name = 'Assistência Funeral Individual',
    //         Caso__c = caso.Id,
    //         Garantia_do_segurado_do_contrato__c = garantiaSeguradoContrato.Id            
    //     );

    //     insert pagamentoGarantia;

    //     //LECVP-216 - FIM

    //     MovimentoSinistro__c movimento = new MovimentoSinistro__c(
    //         Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
    //         Caso__c = Util.gerarIdFalso(Schema.Case.getSObjectType()),
    //         DescricaoMovimento__c = '2',
    //         ValorMovimento__c = 1000,
    //         PagamentoGarantia__c = pagamentoGarantia.Id //LECVP-216 - INICIO / FIM
    //     );

    //     List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
    //     listaMovimentos.add(movimento);

    //     Map<Id, List<MovimentoSinistro__c>> movimentosPorIdCaso = new Map<Id, List<MovimentoSinistro__c>>();
    //     List<Case> listaCasos = new List<Case>();
    //     listaCasos.add(caso);
    //     movimentosPorIdCaso.put(caso.Id, listaMovimentos);
    //     MovimentoSinistroBO.getInstance().criarMovFechaAdmEReabJur(listaCasos, movimentosPorIdCaso);

    //     Test.stopTest();
    // }
     // LECVPV-140-FIX02 FIM

    @isTest static void testarVerificarSeExistePagamentosIndenizacao(){

        Test.startTest();

        MovimentoSinistro__c movimento1 = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            DescricaoMovimento__c = '10'
        );

        MovimentoSinistro__c movimento2 = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            DescricaoMovimento__c = '4'
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento1);
        listaMovimentos.add(movimento2);

        MovimentoSinistroBO.getInstance().verificarSeExistePagamentosIndenizacao(listaMovimentos);

        Test.stopTest();
    }

    @isTest static void testarRecuperarUltimoMovFechamento(){

        Test.startTest();

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            DescricaoMovimento__c = '24'
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);

        MovimentoSinistroBO.getInstance().recuperarUltimoMovFechamento(listaMovimentos);

        Test.stopTest();
    }

    @isTest static void testarFiltraCobertura(){

        Test.startTest();

        Case caso = new Case(
            Id = Util.gerarIdFalso(Schema.Case.getSObjectType())
        );

        PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
            Id = Util.gerarIdFalso(Schema.PagamentoGarantia__c.getSObjectType()),
            Name = 'Assistência Funeral Individual',
            Caso__c = caso.Id
        );

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            Id = Util.gerarIdFalso(Schema.MovimentoSinistro__c.getSObjectType()),
            DescricaoMovimento__c = '24',
            PagamentoGarantia__c = pagamentoGarantia.Id
        );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);

        MovimentoSinistroBO.getInstance().filtrarCobertura(listaMovimentos, pagamentoGarantia.Id, true);
        MovimentoSinistroBO.getInstance().filtrarCobertura(listaMovimentos, pagamentoGarantia.Id, false);

        Test.stopTest();
    }    
}
// POR062-1 - FIM
//LECVP-140 FIM