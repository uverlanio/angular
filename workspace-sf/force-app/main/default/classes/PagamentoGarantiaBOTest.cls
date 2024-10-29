// POR062-1 - INICIO
@isTest
private class PagamentoGarantiaBOTest {


    @isTest static void testarFiltrarPorCasoECobertura(){

        Test.startTest();
        Case caso = new Case(
            Id = '500L000000GSvG0IAL'
        );

        PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
            Id = 'a1rL0000001pN6yIAE',
            Name = 'Assistência Funeral Individual',
            Caso__c = caso.Id
        );

        List<PagamentoGarantia__c> listaPagamentoGarantia = new List<PagamentoGarantia__c>();
        listaPagamentoGarantia.add(pagamentoGarantia);

        PagamentoGarantiaBO.getInstance().filtrarPorCasoECobertura(caso.Id, 'Assistência Funeral Individual', listaPagamentoGarantia);

        Test.stopTest();
    }

    @isTest
    static void fecharPagamentosDeCasoTest()
    {
        Id casoId = Util.gerarIdFalso(Schema.Case.getSObjectType());
        PagamentoGarantia__c pagamento = new PagamentoGarantia__c(
            Caso__c = casoId
        );
        List<PagamentoGarantia__c> pagamentos = PagamentoGarantiaBo.getInstance().fecharPagamentosDeCaso(casoId, new List<PagamentoGarantia__c> { pagamento });
        System.assertEquals('Fechado', pagamento.Fase__c);
        System.assertEquals(0, pagamento.Valor_indenizado__c);
    }

    //LECVP-193 - INICIO
    @isTest static void testarAtualizaValorIndenizado(){

        Test.startTest();
      
        PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
            Name = 'teste',
            Caso__c = '500L000000GS9L5IAL',
            Valor_indenizado__c = 10000
        );

        BeneficiarioGarantia__c beneficiarioGarantia = new BeneficiarioGarantia__c(
            ValorIndenizacao__c = 10000,
            Pagamento_de_garantia__c = pagamentoGarantia.Id
        );

        Test.stopTest();
    }
    //LECVP-193 - FIM

    // LECVPV-216 INICIO
    @isTest static void testarGerarMovimentoSinistroGarantiaUpdatecomAvisadoMais() {

        // Nesse teste com avisado mais, VALORINDENIZADO_NEW deve ser maior que VALORINDENIZADO_OLD 
        final Decimal VALORINDENIZADO_OLD = 10000;
        final Decimal VALORINDENIZADO_NEW = 20000;

        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();

        insert conta;

        RecordType rtAtendimento = [SELECT Id FROM RecordType WHERE DeveloperName = 'Atendimento' LIMIT 1];
        RecordType rtSinistro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sinistro' LIMIT 1];
        
        Test.startTest();

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
            Valor_indenizado__c = VALORINDENIZADO_OLD,
            Fase__c = 'Em Análise',
            Status_do_pagamento__c = 'Em Análise'
        );

        insert pagamentoGarantia;

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
             SinistroJudicial__c = false,
             TipoMovimento__c = 'Aviso',
             DescricaoMovimento__c = '1',
             SequenciaMovimento__c = '1',
             ValorMovimento__c = 1000,
             PagamentoGarantia__c = pagamentoGarantia.Id 
         );
 
         MovimentoSinistro__c movimento2 = new MovimentoSinistro__c(
              SinistroJudicial__c = false,
              TipoMovimento__c = 'Aviso',
              DescricaoMovimento__c = '2',
              SequenciaMovimento__c = '2',
              ValorMovimento__c = 2000,
              PagamentoGarantia__c = pagamentoGarantia.Id 
          );
 
         List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
         listaMovimentos.add(movimento);
         listaMovimentos.add(movimento2);
         insert listaMovimentos; 

        pagamentoGarantia.Valor_indenizado__c = VALORINDENIZADO_NEW;
        pagamentoGarantia.Fase__c = 'Fechado';
        pagamentoGarantia.Motivo_da_Recusa__c = '49';
        pagamentoGarantia.Status_do_pagamento__c = 'Recusado';

        update pagamentoGarantia;

        Test.stopTest();
         
         List<MovimentoSinistro__c> movimentosCriados = [SELECT Id, PagamentoGarantia__c, ValorMovimento__c, TipoMovimento__c, DescricaoMovimento__c, Caso__c 
         FROM MovimentoSinistro__c];
        
        // System.assertEquals(movimentosCriados.size(), 2);
        // System.assertEquals(movimentosCriados[0].DescricaoMovimento__c,'1');
        // System.assertEquals(movimentosCriados[0].ValorMovimento__c,VALORINDENIZADO_NEW*(-1));
        // System.assertEquals(movimentosCriados[1].DescricaoMovimento__c,'2');
        // System.assertEquals(movimentosCriados[1].ValorMovimento__c,VALORINDENIZADO_NEW-VALORINDENIZADO_OLD);

    }

    @isTest static void testarGerarMovimentoSinistroGarantiaUpdatecomAvisadoMenos() {

        // Nesse teste com avisado mais, VALORINDENIZADO_NEW deve ser menor que VALORINDENIZADO_OLD 
        final Decimal VALORINDENIZADO_OLD = 10000;
        final Decimal VALORINDENIZADO_NEW = 5000;

        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();

        insert conta;

        RecordType rtAtendimento = [SELECT Id FROM RecordType WHERE DeveloperName = 'Atendimento' LIMIT 1];
        RecordType rtSinistro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sinistro' LIMIT 1];
        
        Test.startTest();

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
            Valor_indenizado__c = VALORINDENIZADO_OLD,
            Fase__c = 'Em Análise',
            Status_do_pagamento__c = 'Em Análise'
        );

        insert pagamentoGarantia;

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
            SinistroJudicial__c = false,
            TipoMovimento__c = 'Aviso',
            DescricaoMovimento__c = '1',
            SequenciaMovimento__c = '1',
            ValorMovimento__c = 1000,
            PagamentoGarantia__c = pagamentoGarantia.Id 
        );

        MovimentoSinistro__c movimento2 = new MovimentoSinistro__c(
             SinistroJudicial__c = false,
             TipoMovimento__c = 'Aviso',
             DescricaoMovimento__c = '2',
             SequenciaMovimento__c = '2',
             ValorMovimento__c = 2000,
             PagamentoGarantia__c = pagamentoGarantia.Id 
         );

        List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
        listaMovimentos.add(movimento);
        listaMovimentos.add(movimento2);
        insert listaMovimentos; 

      //  update bene;

        // BeneficiarioGarantia__c bene2 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(conta, infoBan, pagamentoGarantia).createRecord();

        // bene2.InformarIndenizacao__c = 'Valor de Indenização';
		// bene2.ValorIndenizacao__c = 200.00; 

        // update bene2;

        pagamentoGarantia.Valor_indenizado__c = VALORINDENIZADO_NEW;
        pagamentoGarantia.Fase__c = 'Fechado';
        pagamentoGarantia.Motivo_da_Recusa__c = '49';
        pagamentoGarantia.Status_do_pagamento__c = 'Recusado';

        // LECVPV-216-FIX01 - INICIO
        PagamentoGarantiaTriggerHandler.gerarMovimento = true;
        PagamentoGarantiaTriggerHandler.isFirstTime = true;
        update pagamentoGarantia;
        PagamentoGarantiaTriggerHandler.gerarMovimento = false;
        PagamentoGarantiaTriggerHandler.isFirstTime = false;
        // LECVPV-216-FIX01 - FIM

        Test.stopTest();
         
         List<MovimentoSinistro__c> movimentosCriados = [SELECT Id, PagamentoGarantia__c, ValorMovimento__c, TipoMovimento__c, DescricaoMovimento__c, Caso__c 
         FROM MovimentoSinistro__c];
        
        // System.assertEquals(movimentosCriados.size(), 2);
        // System.assertEquals(movimentosCriados[0].DescricaoMovimento__c,'1');
        // System.assertEquals(movimentosCriados[0].ValorMovimento__c,VALORINDENIZADO_NEW*(-1));
        // System.assertEquals(movimentosCriados[1].DescricaoMovimento__c,'3');
        // System.assertEquals(movimentosCriados[1].ValorMovimento__c,VALORINDENIZADO_NEW-VALORINDENIZADO_OLD);

    }

      // LECVPV-216-FIX01 - INICIO
      @isTest static void testarAlteraValorProvisionadoMais() {

        // Nesse teste com avisado mais, VALORINDENIZADO_NEW deve ser maior que VALORINDENIZADO_OLD 
        final Decimal VALORINDENIZADO_OLD = 10000;
        final Decimal VALORINDENIZADO_NEW = 20000;

        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();

        insert conta;

        RecordType rtAtendimento = [SELECT Id FROM RecordType WHERE DeveloperName = 'Atendimento' LIMIT 1];
        RecordType rtSinistro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sinistro' LIMIT 1];
        
        Test.startTest();

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
            Valor_indenizado__c = VALORINDENIZADO_OLD,
            Fase__c = 'Em Análise',
            Status_do_pagamento__c = 'Em Análise'
        );

        insert pagamentoGarantia;

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
             SinistroJudicial__c = false,
             TipoMovimento__c = 'Aviso',
             DescricaoMovimento__c = '1',
             SequenciaMovimento__c = '1',
             ValorMovimento__c = 1000,
             PagamentoGarantia__c = pagamentoGarantia.Id 
         );
 
         MovimentoSinistro__c movimento2 = new MovimentoSinistro__c(
              SinistroJudicial__c = false,
              TipoMovimento__c = 'Aviso',
              DescricaoMovimento__c = '2',
              SequenciaMovimento__c = '2',
              ValorMovimento__c = 2000,
              PagamentoGarantia__c = pagamentoGarantia.Id 
          );
 
         List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
         listaMovimentos.add(movimento);
         listaMovimentos.add(movimento2);
         insert listaMovimentos; 

        pagamentoGarantia.Valor_indenizado__c = VALORINDENIZADO_NEW;

        PagamentoGarantiaTriggerHandler.gerarMovimento = true;
        PagamentoGarantiaTriggerHandler.isFirstTime = true;
        update pagamentoGarantia;
        PagamentoGarantiaTriggerHandler.gerarMovimento = false;
        PagamentoGarantiaTriggerHandler.isFirstTime = false;

        Test.stopTest();

    }

        @isTest static void testarAlteraValorProvisionadoMenos() {

        // Nesse teste com avisado mais, VALORINDENIZADO_NEW deve ser menor que VALORINDENIZADO_OLD  
        final Decimal VALORINDENIZADO_OLD = 10000;
        final Decimal VALORINDENIZADO_NEW = 5000;

        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();

        insert conta;

        RecordType rtAtendimento = [SELECT Id FROM RecordType WHERE DeveloperName = 'Atendimento' LIMIT 1];
        RecordType rtSinistro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sinistro' LIMIT 1];
        
        Test.startTest();

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
            Valor_indenizado__c = VALORINDENIZADO_OLD,
            Fase__c = 'Em Análise',
            Status_do_pagamento__c = 'Em Análise'
        );

        insert pagamentoGarantia;

        MovimentoSinistro__c movimento = new MovimentoSinistro__c(
                SinistroJudicial__c = false,
                TipoMovimento__c = 'Aviso',
                DescricaoMovimento__c = '1',
                SequenciaMovimento__c = '1',
                ValorMovimento__c = 1000,
                PagamentoGarantia__c = pagamentoGarantia.Id 
            );
    
            MovimentoSinistro__c movimento2 = new MovimentoSinistro__c(
                SinistroJudicial__c = false,
                TipoMovimento__c = 'Aviso',
                DescricaoMovimento__c = '2',
                SequenciaMovimento__c = '2',
                ValorMovimento__c = 2000,
                PagamentoGarantia__c = pagamentoGarantia.Id 
            );
    
            List<MovimentoSinistro__c> listaMovimentos = new List<MovimentoSinistro__c>();
            listaMovimentos.add(movimento);
            listaMovimentos.add(movimento2);
            insert listaMovimentos; 

        pagamentoGarantia.Valor_indenizado__c = VALORINDENIZADO_NEW;

        PagamentoGarantiaTriggerHandler.gerarMovimento = true;
        PagamentoGarantiaTriggerHandler.isFirstTime = true;
        update pagamentoGarantia;
        PagamentoGarantiaTriggerHandler.gerarMovimento = false;
        PagamentoGarantiaTriggerHandler.isFirstTime = false;

        Test.stopTest();

    }
    // LECVPV-216-FIX01 - FIM

    @isTest static void testarRecuperarPorSiglaeGarantiaTest() {

        final String SIGLAGARANTIA = 'AFF';

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
        garantia.Sigla__c = SIGLAGARANTIA;

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

        InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();

        BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(conta, infoBan, pagamentoGarantia).createRecord();

        bene.InformarIndenizacao__c = 'Valor de Indenização';
		bene.ValorIndenizacao__c = 50.00; 

        update pagamentoGarantia;

        List<PagamentoGarantia__c> garantias = [SELECT Id, Garantia_do_segurado_do_contrato__c, 
                                                Garantia_do_segurado_do_contrato__r.Garantia__c,
                                                Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c,
                                                Caso__c
                                                FROM PagamentoGarantia__c];

        Test.startTest();

        PagamentoGarantia__c pagamentoGarantiaTestar = PagamentoGarantiaBo.getInstance().recuperarPorCasoESigla(caso.Id, SIGLAGARANTIA, garantias);

        Test.stopTest();

        System.assertNotEquals(pagamentoGarantiaTestar.Id,null);
        System.assertEquals(pagamentoGarantiaTestar.Garantia_do_segurado_do_contrato__r?.Garantia__r?.Sigla__c,SIGLAGARANTIA);

    }


    // LECVPV-216 FIM
}
// POR062-1 - FIM