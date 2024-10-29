/****
@description Classe de teste da controler do componente de recalculo da proposta
@author Isabela Fin - Globant / Pedro Braz - Sys4b
@date 13/11/2020
@Classe referente a historia PLV-4544      
*****/

@isTest
public class RecalculoPropostaControllerTest {
    @TestSetup
    static void setup(){
        
        SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
        sCripto.Name = 'Senha';
        sCripto.Senha__c = 'TesteCrypto';
        insert sCripto;

        Account contaPF = (Account) new AccountFactory.PessoaFisica().createRecord();
        Account contaPJ = (Account) new AccountFactory.PessoaJuridica().createRecord();
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        ContadorCodigo__c contCodigoNumOferta = (ContadorCodigo__c) new ContadorCodigoFactory.NumeroOferta().createRecord();

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().getRecord();
        garantia.Sigla__c = 'MAP';
        garantia.Name = 'Morte Acidental';
        insert garantia;

        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        // produtoTecnico.LimiteTotalCarregamento__c = 60;//PLV-4851 - INICIO/FIM
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        //produtoComercial.LimiteTotalCarregamento__c = 50;//PLV-4851 - INICIO/FIM
        update produtoComercial;

        // 5311-FIX- INICIO
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();        
        ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoComercial);
        // 5311-FIX- FIM

        //PLV-5161 - INICO
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        tipoRemuneracao.codigo__c = 'COR';
        update tipoRemuneracao;
        RemuneracaoProduto__c rem = (RemuneracaoProduto__c) new RemuneracaoProdutoFactory(tipoRemuneracao,ProdutoComercial).createRecord();
        //PLV-5161 - FIM

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory().createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPJ).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord(); 

        GarantiaProduto__c garantiaProdutoTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garantiaProdutoCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garantiaProdutoTec, ramoSeguro).getRecord();
        garantiaProdutoCom.TipoGarantia__c = 'Cobertura';
        garantiaProdutoCom.ambitoTerritorial__c = 'TerritorioNacional';
        garantiaProdutoCom.CaracteristicaGarantia__c = 'Principal';
        garantiaProdutoCom.Garantia__c = garantia.Id;
        // PLV-5185 INICIO
        garantiaProdutoCom.PercentualAgravoMaximo__c = 0.6;
        garantiaProdutoCom.PercentualAgravoMinimo__c = 0.1;
        garantiaProdutoCom.PercentualCapitalMaximo__c = 0.6;
        garantiaProdutoCom.PercentualCapitalMinimo__c = 0.1;
        garantiaProdutoCom.PercentualDescontoMaximo__c = 0.6;
        garantiaProdutoCom.PercentualDescontoMinimo__c = 0.1;
        // PLV-5185 FIM
        insert garantiaProdutoCom;
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPF, formaPagamento).createRecord();
        
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, contaPF).createRecord();
        orcamento.StageName = 'Disponível para contratação';
        orcamento.NumeroOferta__c = '1234';
        orcamento.Origem__c = '18';
        update orcamento;
        insert new GarantiaOrcamento__c (
            Orcamento__c = orcamento.Id, 
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProdutoCom.Id
        );
        
        

        ContratanteOrcamento__c contratanteOrc = (ContratanteOrcamento__c) new contratanteOrcamentoFactory(orcamento).createRecord();
        insert new GarantiaContratanteOrcamento__c (
            ContratanteOrcamento__c = contratanteOrc.Id,
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProdutoCom.Id
        );
        
        GrupoOrcamento__c grupoOrc = (GrupoOrcamento__c) new grupoOrcamentoFactory(contratanteOrc).createRecord();
        insert new GarantiaGrupoOrcamento__c (
            GrupoOrcamento__c = grupoOrc.Id,
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProdutoCom.Id
        );

        SeguradoOrcamento__c seguradoOrc = (SeguradoOrcamento__c) new seguradoOrcamentoFactory(contaPF,grupoOrc).getRecord();
        seguradoOrc.Numero__c = 1;
        insert seguradoOrc;
        insert new GarantiaSeguradoOrcamento__c (
            SeguradoOrcamento__c = seguradoOrc.Id,
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProdutoCom.Id
        );
        
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, contaPJ, dadosCorretor, orcamento, modalidade).getRecord();
        proposta.Tipo__c = 'Novo';
        proposta.Status = 'Em análise';
        proposta.Parceiro__c = '';
        proposta.PorQuantoTempoQuerGarantirRenda__c = '24'; //PLV-4694 INICIO/
        insert proposta;
        insert new GarantiaProposta__c (
            Proposta__c = proposta.Id,
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProdutoCom.Id,
            // PLV-5185 INICIO
            Capital__c = 1, 
            PremioTotal__c = 1.0,
            TipoDescontoAgravo__c = 'Comercial',
            TaxaComercial__c = 2.0,
            TaxaPura__c = 2.1, 
            TaxaTotal__c = 2.2 
            // PLV-5185 FIM
        );

        ContratanteProposta__c contratanteProposta = (ContratanteProposta__c) new ContratantePropostaFactory(proposta, formaPagamento).getRecord();
        contratanteProposta.Conta__c = contaPJ.Id;
        insert contratanteProposta;
        insert new GarantiaContratanteProposta__c (
            ContratanteProposta__c = contratanteProposta.Id,
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProdutoCom.Id
        );

        GrupoProposta__c grupoProposta = new GrupoProposta__c(ContratanteProposta__c = contratanteProposta.Id, Name = 'TesteGrupoProposta');
        insert grupoProposta;
        insert new GarantiasGrupoProposta__c (
            GrupoProposta__c = grupoProposta.Id,
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProdutoCom.Id
        );
        SeguradoProposta__c seguradoProposta = new SeguradoProposta__c(Conta__c = contaPF.Id, GrupoProposta__c = grupoProposta.Id, Numero__c = 1,  CicloVacinal__c = '1');// PLV-5185 INICIO/FIM
        insert seguradoProposta;
        insert new GarantiaSeguradoProposta__c (
            SeguradoProposta__c = seguradoProposta.Id,
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProdutoCom.Id         
        );

        insert new CriticaProposta__c(MomentoAnalise__c='Recalculo', Status__c='Pendente', Proposta__c=proposta.Id);
        
        //II-166 - INICIO
        Account conta = TestDataFactory.gerarConta();
        dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);
        update dadosCorretor;
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(conta);

        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;

        orcamento = TestDataFactory.gerarOrcamentoObjeto(conta, produtoComercial, canalDistribuicao);
        update orcamento;

        Quote prop = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta('18','00324367'), //II-166 - INICIO
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18','00324367'),//II-166 - FIM
                Produto__c = produtoComercial.Id,
                RamoSeguro__c = ramoSegurado.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = conta.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC',
                OpportunityId = orcamento.Id,
                Origem__c = '18',
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = '00324367', //II-166 - INICIO/FIM
                Parceiro__c = '67708896000139'        
        );
        insert prop;

        //II-206 FIX01 - INICIO
        //II-206 - INICIO
        // Quote prop1 = new Quote(
        //         Name = QuoteBO.getInstance().gerarNameProposta('18','00324369'),
        //         NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18','00324369'),
        //         Produto__c = produtoComercial.Id,
        //         RamoSeguro__c = ramoSegurado.Id,
        //         Status = 'Novo',
        //         VigenciaInicial__c = System.today(),
        //         VigenciaFinal__c = System.today().addMonths(1),
        //         Empresa__c = contaPF.Id,
        //         CodigoCorretor__c = dadosCorretor.Id,
        //         DataCalculo__c = System.today(),
        //         DataCriacaoPortal__c = System.today(),
        //         TipoVigencia__c = 'Anual',
        //         MeioComercializacao__c = 'PMC',
        //         OpportunityId = orcamento.Id,
        //         Origem__c = '18',
        //         Modalidade__c = modalidade.Id,
        //         NumeroProposta__c = '00324369', 
        //         Parceiro__c = '67708896000139'        
        // );
        // insert prop1;
        //II-206 - FIM
        //II-206 FIX01 - FIM

        ContratanteProposta__c cp = TestDataFactory.gerarContratanteProposta(conta, prop, formaPagamento);
        cp.VencimentoDemaisParcelas__c = 'A cada 30 dias';
        cp.ResponsavelPagamento__c = conta.Id; //II-206 FIX01 - INICIO/FIM
        update cp;

        //II-206 - INICIO
        //II-206 FIX01 - INICIO
        // ContratanteProposta__c cp2 = TestDataFactory.gerarContratanteProposta(conta, prop1, formaPagamento);
        // cp2.VencimentoDemaisParcelas__c = 'A cada 30 dias';
        // cp2.ResponsavelPagamento__c = conta.Id;
        // update cp2;
        //II-206 FIX01 - FIM

        PlanoParcelamento__c planoParcelamento = new PlanoParcelamento__c(
                CodigoMeioRecebimento__c = '1234',
                DescricaoMeioRecebimento__c = 'RECEBIMENTO-BOLETO REGISTRADO',
                FormaPagamento__c = formaPagamento.id,
                NumeroParcela__c = 1               
        );
        insert planoParcelamento;

        //II-206 FIX01 - INICIO
        // Banco__c banconew = new Banco__c();
        // banconew.CodigoBanco__c = '237';
        // banconew.ConveniadoADC__c  = false;
        // banconew.Name = 'BANCO BRADESCO S.A.';
        // banconew.Ativo__c = true;
        // banconew.Name = '237 - BANCO BRADESCO S.A.';
        // insert banconew; 
        // GrupoProposta__c grupoProposta2 = new GrupoProposta__c(ContratanteProposta__c = cp.Id, Name = 'TesteGrupoProposta');
        // insert grupoProposta2;
        // insert new GarantiasGrupoProposta__c (
        //     GrupoProposta__c = grupoProposta2.Id,
        //     Garantia__c = garantia.Id,
        //     GarantiaProduto__c = garantiaProdutoCom.Id
        // );
        // SeguradoProposta__c seguradoProposta2 = new SeguradoProposta__c(Conta__c = conta.Id, GrupoProposta__c = grupoProposta2.Id, Numero__c = 1,  CicloVacinal__c = '1');
        // insert seguradoProposta2;
        // insert new GarantiaSeguradoProposta__c (
        //     SeguradoProposta__c = seguradoProposta2.Id,
        //     Garantia__c = garantia.Id,
        //     GarantiaProduto__c = garantiaProdutoCom.Id         
        // );
        //II-206 FIX01 - FIM
        //II-206 - FIM

        CondicaoCobranca__c cc = new CondicaoCobranca__c();
		cc.Produto__c = produtoTecnico.Id;
		cc.FormaPagamento__c = formaPagamento.Id;
		cc.QuantidadeParcelas__c = '1';
        cc.AntecipacaoComissao__c = true; //II-176 INICIO/FIM
		insert cc;

        TipoRemuneracao__c tipoRemun = new TipoRemuneracao__c(
            Name = 'AGENCIAMENTO',
            LimiteMinimo__c = 0,
            LimiteMaximo__c = 200,
            ModeloRecuperacao__c = 'Pro-rata'
        );

        insert tipoRemun;

        //II-176 INICIO
        TipoRemuneracao__c tipoRemun2 = new TipoRemuneracao__c(
            Name = 'CORRETAGEM',
            LimiteMinimo__c = 1,
            LimiteMaximo__c = 25,
            ModeloRecuperacao__c = 'Pro-rata'
        );

        insert tipoRemun2;
        //II-176 FIM

        RemuneracaoProposta__c remuneracaoProposta = new RemuneracaoProposta__c(
              TipoRemuneracao__c = tipoRemun2.Id, //II-176 INICIO/FIM
              Proposta__c = prop.Id,
              Percentual__c = 20 //II-176 INICIO/FIM
        );

        insert remuneracaoProposta;
        //II-166 - FIM

        //II-176 INICIO
        AntecipacaoComissao__c antecipacaoComissao = new AntecipacaoComissao__c(
            LimiteMaximo__c = 25,
            LimiteMinimo__c = 1,
            TipoEvento__c = 'Seguro Novo',
            RemuneracaoProduto__c = rem.Id
        );

        insert antecipacaoComissao;

        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c(
            Conta__c = conta.Id,           
            CorretorLider__c = true,
            Papel__c = 'Corretor',
            Participacao__c = 20.00,
            RemuneracaoProposta__c = remuneracaoProposta.Id,
            Susep__c = 'REN01J',
            SusepEmissao__c = 'REN01J',
            SusepOficialCorretor__c = '123',
            SusepOrcamento__c = 'REN01J',
            AntecipacaoComissao__c = true,
            DadosCorretor__c = dadosCorretor.Id
        );

        insert favorecidoRemuneracaoProposta;
        //II-176 FIM
    }


   //PLV-5311-FIX - INICIO
    @isTest
    static void testarRecalculo2(){
        Garantia__c garantia = [SELECT Id FROM Garantia__c LIMIT 1];
        garantia.Sigla__c = 'AFF';
        //garantia.Name = 'Morte Acidental';
        update garantia;

        Profissao__c profissao = ( Profissao__c ) new ProfissaoFactory().createRecord();
        profissao.Name = 'Atúario';
        profissao.Limite_de_capital_maximo__c = 0.5;
        update profissao;

        Quote propostaSF = [SELECT Id FROM Quote LIMIT 1];

        SeguradoProposta__c seguradoProposta= [SELECT Id FROM SeguradoProposta__c LIMIT 1];
        seguradoProposta.Profissao__c = profissao.Id;
        update seguradoProposta;

        TipoRemuneracao__c tipoRemuneracao = [SELECT Id FROM TipoRemuneracao__c][0];//II-166 - INICIO/FIM
        //tipoRemuneracao.Codigo__c = 'AGE';
        //tipoRemuneracao.Name = 'AGENCIAMENTO';
        update tipoRemuneracao;

        Product2 produtoComercial = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial'];

        RemuneracaoProduto__c remuneracaoProduto = [SELECT Id, TipoRemuneracao__c,ParcelasAgenciamento__c FROM RemuneracaoProduto__c];
        remuneracaoProduto.TipoRemuneracao__c = tipoRemuneracao.Id;
        remuneracaoProduto.Produto__c = produtoComercial.Id;
        //remuneracaoProduto.ParcelasAgenciamento__c = '1ª parcela;2ª parcela' ;
        update remuneracaoProduto;

        CanalDistribuicao__c canalDistribuicao = [SELECT Id FROM CanalDistribuicao__c ];

        ProdutoCanal__c produtoCanal = [SELECT Id FROM ProdutoCanal__c];

        RemuneracaoCanal__c remuneracaoCanal = new RemuneracaoCanal__c();
		remuneracaoCanal.ProdutoCanal__c = produtoCanal.Id;
		remuneracaoCanal.TipoRemuneracao__c = tipoRemuneracao.Id;        
        insert remuneracaoCanal;

        RemuneracaoProposta__c remuneracaoProposta = TestDataFactory.gerarRemuneracaoProposta(propostaSF, tipoRemuneracao);

        RecalculoPropostaTO.Proposta propostaModFake = RecalculoPropostaController.dtoProposta(propostaSF.Id);
        propostaModFake.remuneracoes = new List<RecalculoPropostaTO.Remuneracoes> ();
        RecalculoPropostaTO.Remuneracoes test = new RecalculoPropostaTO.Remuneracoes ();
        test.id = 'adsl';
        test.codigo = 'COR'; 
        test.limiteMaximo = 1.0;
        test.limiteMinimo = 0.0;    
        test.Name  = 'teste';
        test.obrigatorio = true;
        test.opcoes = new List<Integer>{1,2};
        test.simbolo = '';
		test.tipoRemuneracao = 'AGENCIAMENTO';
        test.percentual = 10;
        propostaModFake.remuneracoes.add(test); 
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadRecalculoProposta' LIMIT 1];
        String payload = sr.Body.toString();

        Map<String,Object> mapSerialize = new Map<String,Object>();
        List<String> mensagens  =new List<String>();
        
        mapSerialize.put('modificada',propostaModFake);
        System.debug('mapSerialize => '+ mapSerialize);
        System.Test.startTest();
        RecalculoPropostaController.carregarDadosProposta(propostaSF.Id);
        RecalculoPropostaController.verifyEdit(propostaSF.Id);
        //II-175 INICIO
        Boolean alteracaoFormPag = false;
        String descontoAgravo = '0';

        System.Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payload, 200, 'OK'));
        RecalculoPropostaController.calcular(JSON.serialize(mapSerialize), alteracaoFormPag, descontoAgravo);
        RecalculoPropostaController.processCriticas(propostaSF.Id, mensagens, alteracaoFormPag);
        
        mapSerialize.put('jsonResponseRecalculo',payload);
        RecalculoPropostaController.gravarCalculo(JSON.serialize(mapSerialize), alteracaoFormPag);
        //II-175 FIM
        System.Test.stopTest();
        //II-206 FIX01 - INICIO
        Integer numeroQueries = Limits.getQueries();
        System.debug('Número de queries feitas: ' + numeroQueries);
        //II-206 FIX01 - FIM
    }
    //PLV-5311-FIX - FIM*/

    //PLV-5161 - INICIO
    @isTest
    static void testarRecalculo(){
        Quote propostaSF = [SELECT Id FROM Quote LIMIT 1];
        RecalculoPropostaTO.Proposta propostaModFake = RecalculoPropostaController.dtoProposta(propostaSF.Id);
        propostaModFake.remuneracoes = new List<RecalculoPropostaTO.Remuneracoes> ();
        RecalculoPropostaTO.Remuneracoes test = new RecalculoPropostaTO.Remuneracoes ();
        test.id = 'adsl';
        test.codigo = 'COR'; 
        // PLV-5185 INICIO
        test.limiteMaximo = 1.0;
        test.limiteMinimo = 0.0;    
        test.Name  = 'teste';
        test.obrigatorio = true;
        test.opcoes = new List<Integer>{1,2};
        test.simbolo = '';
		test.tipoRemuneracao = 'CORRETAGEM';
		// PLV-5185 FIM
        test.percentual = 10;
        propostaModFake.remuneracoes.add(test); 
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadRecalculoProposta' LIMIT 1];
        String payload = sr.Body.toString();

        Map<String,Object> mapSerialize = new Map<String,Object>();
        
        mapSerialize.put('modificada',propostaModFake);
        System.debug('mapSerialize => '+ mapSerialize);
        System.Test.startTest();
        RecalculoPropostaController.carregarDadosProposta(propostaSF.Id);
        RecalculoPropostaController.verifyEdit(propostaSF.Id);
        //II-175 INICIO
        Boolean alteracaoFormPag = false;
        String descontoAgravo = '0';

        System.Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payload, 200, 'OK'));
        RecalculoPropostaController.calcular(JSON.serialize(mapSerialize), alteracaoFormPag, descontoAgravo);
        
        mapSerialize.put('jsonResponseRecalculo',payload);
        RecalculoPropostaController.gravarCalculo(JSON.serialize(mapSerialize), alteracaoFormPag);
        //II-175 FIM
        System.Test.stopTest();
    }

    @isTest
    static void testarRecalculo_erroMin(){
        Quote propostaSF = [SELECT Id FROM Quote LIMIT 1];
        RecalculoPropostaTO.Proposta propostaModFake = RecalculoPropostaController.dtoProposta(propostaSF.Id);
        propostaModFake.remuneracoes = new List<RecalculoPropostaTO.Remuneracoes> ();
        RecalculoPropostaTO.Remuneracoes test = new RecalculoPropostaTO.Remuneracoes ();
        test.id = 'adsl';
        test.codigo = 'COR';
		// PLV-5185 INICIO		
		test.tipoRemuneracao = 'CORRETAGEM';
		// PLV-5185 FIM
		test.percentual = 0;
        propostaModFake.remuneracoes.add(test);
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadRecalculoProposta' LIMIT 1];
        String payload = sr.Body.toString();

        Map<String,Object> mapSerialize = new Map<String,Object>();
        
        mapSerialize.put('modificada',propostaModFake);
        
        System.Test.startTest();
        RecalculoPropostaController.carregarDadosProposta(propostaSF.Id);
        RecalculoPropostaController.verifyEdit(propostaSF.Id);
        //II-175 INICIO
        Boolean alteracaoFormPag = false;
        String descontoAgravo = '0';

        System.Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payload, 200, 'OK'));
        RecalculoPropostaController.calcular(JSON.serialize(mapSerialize), alteracaoFormPag, descontoAgravo);
        
        mapSerialize.put('jsonResponseRecalculo',payload);
        RecalculoPropostaController.gravarCalculo(JSON.serialize(mapSerialize), alteracaoFormPag);
        //II-175 FIM
        System.Test.stopTest();
    }
    
    @isTest
    static void testarRecalculo_erroMax(){
        Quote propostaSF = [SELECT Id FROM Quote LIMIT 1];
        RecalculoPropostaTO.Proposta propostaModFake = RecalculoPropostaController.dtoProposta(propostaSF.Id);
        propostaModFake.remuneracoes = new List<RecalculoPropostaTO.Remuneracoes> ();
        RecalculoPropostaTO.Remuneracoes test = new RecalculoPropostaTO.Remuneracoes ();
        test.id = 'adsl';
        test.codigo = 'COR';
		// PLV-5185 INICIO		
		test.tipoRemuneracao = 'CORRETAGEM';
		// PLV-5185 FIM
		test.percentual = 1000; 
        propostaModFake.remuneracoes.add(test);
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadRecalculoProposta' LIMIT 1];
        String payload = sr.Body.toString();

        Map<String,Object> mapSerialize = new Map<String,Object>();
        
        mapSerialize.put('modificada',propostaModFake);
        
        System.Test.startTest();
        RecalculoPropostaController.carregarDadosProposta(propostaSF.Id);
        RecalculoPropostaController.verifyEdit(propostaSF.Id);
        //II-175 INICIO
        Boolean alteracaoFormPag = false;
        String descontoAgravo = '0';

        System.Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payload, 200, 'OK'));
        RecalculoPropostaController.calcular(JSON.serialize(mapSerialize), alteracaoFormPag, descontoAgravo);
        
        mapSerialize.put('jsonResponseRecalculo',payload);
        RecalculoPropostaController.gravarCalculo(JSON.serialize(mapSerialize), alteracaoFormPag);
        //II-175 FIM
        System.Test.stopTest();
    }
    
    @isTest
    static void testarRecalculo_erroLimiteTotalCarregamento(){
        Quote propostaSF = [SELECT Id FROM Quote LIMIT 1];
        RecalculoPropostaTO.Proposta propostaModFake = RecalculoPropostaController.dtoProposta(propostaSF.Id);
        propostaModFake.LimiteTotalCarregamento = null;
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadRecalculoProposta' LIMIT 1];
        String payload = sr.Body.toString();

        Map<String,Object> mapSerialize = new Map<String,Object>();
        
        mapSerialize.put('modificada',propostaModFake);
        
        System.Test.startTest();
        RecalculoPropostaController.carregarDadosProposta(propostaSF.Id);
        RecalculoPropostaController.verifyEdit(propostaSF.Id);
        //II-175 INICIO
        Boolean alteracaoFormPag = false;
        String descontoAgravo = '0';

        System.Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payload, 200, 'OK'));
        RecalculoPropostaController.calcular(JSON.serialize(mapSerialize), alteracaoFormPag, descontoAgravo);
        
        mapSerialize.put('jsonResponseRecalculo',payload);
        RecalculoPropostaController.gravarCalculo(JSON.serialize(mapSerialize), alteracaoFormPag);
        //II-175 FIM
        System.Test.stopTest();
    }
    //PLV-5161 - FIM
    //PLV-5185 - INICIO
    @isTest
    static void testarRecalculoErro(){
        Quote propostaSF = [SELECT Id FROM Quote LIMIT 1];
        RecalculoPropostaTO.Proposta propostaModFake = RecalculoPropostaController.dtoProposta(propostaSF.Id);
        propostaModFake.remuneracoes = new List<RecalculoPropostaTO.Remuneracoes> ();
        RecalculoPropostaTO.Remuneracoes test = new RecalculoPropostaTO.Remuneracoes ();
        test.id = 'adsl';
        test.codigo = 'COR';         
        test.limiteMaximo = 1.0;
        test.limiteMinimo = 0.0;    
        test.Name  = 'teste';		
		test.tipoRemuneracao = 'AGENCIAMENTO';		
        test.percentual = 10;
        propostaModFake.remuneracoes.add(test); 
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadRecalculoProposta' LIMIT 1];
        String payload = sr.Body.toString();

        Map<String,Object> mapSerialize = new Map<String,Object>();
        List<String> mensagens  =new List<String>();
        
        mapSerialize.put('modificada',propostaModFake);
        
        System.Test.startTest();
        RecalculoPropostaController.carregarDadosProposta(propostaSF.Id);
        RecalculoPropostaController.verifyEdit(propostaSF.Id);
        System.Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payload, 200, 'OK'));
        //II-175 INICIO
        Boolean alteracaoFormPag = false;
        String descontoAgravo = '0';

        RecalculoPropostaController.calcular(JSON.serialize(mapSerialize), alteracaoFormPag, descontoAgravo);
        RecalculoPropostaController.processCriticas(propostaSF.Id, mensagens, alteracaoFormPag);
        mapSerialize.put('jsonResponseRecalculo',payload);
        RecalculoPropostaController.gravarCalculo(JSON.serialize(mapSerialize), alteracaoFormPag);
        //II-175 FIM
        System.Test.stopTest();
    }
    //PLV-5185 - FIM

    //PLV-5311 - INICIO
    //Com Sigla
    @isTest
    static void testarRecalculoErro2(){
        Garantia__c garantia = [SELECT Id FROM Garantia__c LIMIT 1];
        garantia.Sigla__c = 'AFF';
        //garantia.Name = 'Morte Acidental';
        update garantia;

        Quote propostaSF = [SELECT Id FROM Quote LIMIT 1];
        RecalculoPropostaTO.Proposta propostaModFake = RecalculoPropostaController.dtoProposta(propostaSF.Id);
        propostaModFake.remuneracoes = new List<RecalculoPropostaTO.Remuneracoes> ();
        RecalculoPropostaTO.Remuneracoes test = new RecalculoPropostaTO.Remuneracoes ();
        test.id = 'adsl';
        test.codigo = 'COR';         
        test.limiteMaximo = 1.0;
        test.limiteMinimo = 0.0;    
        test.Name  = 'teste';		
		test.tipoRemuneracao = 'AGENCIAMENTO';		
        test.percentual = 10;
        propostaModFake.remuneracoes.add(test); 
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadRecalculoProposta' LIMIT 1];
        String payload = sr.Body.toString();

        Map<String,Object> mapSerialize = new Map<String,Object>();
        List<String> mensagens  =new List<String>();
        
        mapSerialize.put('modificada',propostaModFake);
        
        System.Test.startTest();
        RecalculoPropostaController.carregarDadosProposta(propostaSF.Id);
        RecalculoPropostaController.verifyEdit(propostaSF.Id);
        System.Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payload, 200, 'OK'));
        //II-175 INICIO
        Boolean alteracaoFormPag = false;
        String descontoAgravo = '0';
        RecalculoPropostaController.calcular(JSON.serialize(mapSerialize), alteracaoFormPag, descontoAgravo);
        RecalculoPropostaController.processCriticas(propostaSF.Id, mensagens, alteracaoFormPag);
        mapSerialize.put('jsonResponseRecalculo',payload);
        RecalculoPropostaController.gravarCalculo(JSON.serialize(mapSerialize), alteracaoFormPag);
        //II-175 FIM
        System.Test.stopTest();
    }
    //PLV-5311 - FIM
    //II-166 - INICIO
    @isTest
    static void dadosFormaPagamentoTest(){

        Map<String,Object> mapDadosFormaPgto = new Map<String,Object>();

        Test.startTest();

        Quote proposta = [SELECT Id FROM Quote LIMIT 1];

        mapDadosFormaPgto = RecalculoPropostaController.dadosFormaPagamento(proposta.Id);

        Test.stopTest();

        Assert.areEqual(true, !mapDadosFormaPgto.isEmpty(), 'Success');

    }

    @isTest
    static void qtdeParcelasTest(){

        Map<String,Object> mapCodParc = new Map<String,Object>();

        Test.startTest();

        Quote proposta = [SELECT Id, Name FROM Quote WHERE Name = '18-00324367'];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];

        mapCodParc = RecalculoPropostaController.qtdeParcelas(proposta.Name, produto.Id);

        Assert.areEqual(true, !mapCodParc.isEmpty(), 'Success');

        mapCodParc = new Map<String,Object>();
        mapCodParc = RecalculoPropostaController.qtdeParcelas(proposta.Name, '22222222');

        Assert.areEqual(false, mapCodParc.isEmpty(), 'Success');

        Test.stopTest();
    }

    @isTest
    static void dadosFormaPagamentoExcTest(){

        Map<String,Object> mapDadosFormaPgto = new Map<String,Object>();
        Boolean isException = false;

        try{
            Test.startTest();
            mapDadosFormaPgto = RecalculoPropostaController.dadosFormaPagamento(null);
            Test.stopTest();
        }catch(Exception e){
            isException = true;
        }

        Assert.areEqual(true, isException, 'Success');
    }

    @isTest
    static void qtdeParcelasExcTest(){

        Map<String,Object> mapCodParc = new Map<String,Object>();
        Boolean isException = false;

        try{
            Test.startTest();
            mapCodParc = RecalculoPropostaController.qtdeParcelas(null, null);
            Test.stopTest();
        }catch(Exception e){
            isException = true;
        }

        Assert.areEqual(false, isException, 'Success');
    }

    @isTest
    static void verCodEmpresaTest(){

        Test.startTest();

        Quote proposta = [SELECT Id, Name, Account.CodigoEmpresa__c FROM Quote WHERE Name = '18-00324367'];
        Account conta = proposta.Account;
        conta.CodigoEmpresa__c = '14';

        update conta;

        System.debug('Proposta: ' + JSON.serializePretty(proposta));
        Map<String, String> mapRetorno = RecalculoPropostaController.verificarCodEmpresa(proposta.Name);

        Test.stopTest();

        Assert.areEqual('14', mapRetorno.get('codigoEmpresa'), 'Success');
    }
    //II-166 - FIM
    //II-172 - INICIO
    @IsTest
    static void getEnderecoTest(){

        String cep = '12345-678';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(mockLogradouros()), 200, 'OK'));

        Test.startTest();
        
        Map<String, Object> mapCEP = RecalculoPropostaController.getEnderecos(cep);

        Assert.isNotNull(mapCEP, 'Success');

        try{
            Map<String, Object> mapCEPExc = RecalculoPropostaController.getEnderecos('');
        } catch(RecalculoPropostaController.RecalculoException e){
            Assert.areEqual('CEP inválido.', e.getMessage());
        }
        
        Test.stopTest();
    }

    @IsTest
    static void getEnderecoCepNaoEncTest(){

        String cep = '12345-678';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 200, 'OK'));
        
        Test.startTest();

        Map<String, Object> mapCEPExc1 = null;
        try{
            mapCEPExc1 = RecalculoPropostaController.getEnderecos(cep);
        } catch(Exception e){
            Assert.areEqual(true, mapCEPExc1 == null);
        }

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 200, 'OK'));

        try{
            Map<String, Object> mapCEPExc2 = RecalculoPropostaController.getEnderecos(cep);
        } catch(RecalculoPropostaController.RecalculoException e){            
            Assert.areEqual('CEP não encontrado.', e.getMessage());
        }
        
        Test.stopTest();
    }

    private static F5Service.ObjLogradouros mockLogradouros() {
        F5Service.ObjLogradouros response = new F5Service.ObjLogradouros();
        response.logradouros = new List<F5Service.Logradouros>();
    
        F5Service.Logradouros logradouro1 = new F5Service.Logradouros();
        logradouro1.nomeLogradouro = 'Rua A';
        logradouro1.bairro = new F5Service.Bairro();
        logradouro1.bairro.nomeBairro = 'Bairro A';
        logradouro1.localidade = new F5Service.Localidade();
        logradouro1.localidade.nomeLocalidade = 'Cidade A';
        logradouro1.localidade.estado = new F5Service.Estado();
        logradouro1.localidade.estado.nomeEstado = 'Estado A';
        logradouro1.localidade.estado.siglaEstado = 'EA';
    
        F5Service.Logradouros logradouro2 = new F5Service.Logradouros();
        logradouro2.nomeLogradouro = 'Rua B';
        logradouro2.bairro = new F5Service.Bairro();
        logradouro2.bairro.nomeBairro = 'Bairro B';
        logradouro2.localidade = new F5Service.Localidade();
        logradouro2.localidade.nomeLocalidade = 'Cidade B';
        logradouro2.localidade.estado = new F5Service.Estado();
        logradouro2.localidade.estado.nomeEstado = 'Estado B';
        logradouro2.localidade.estado.siglaEstado = 'EB';
    
        response.logradouros.add(logradouro1);
        response.logradouros.add(logradouro2);

        return response;
    }
    //II-172 - FIM
    //II-176 - INICIO
    @IsTest
    static void verificaAntecipacaoTest(){

        Test.startTest();

        Quote proposta = [SELECT Id, Produto__c, Name FROM Quote WHERE Name = '18-00324367' LIMIT 1];
        proposta.Tipo__c = 'Novo';
        update proposta;
        String idProduto = proposta.Produto__c;
        String nameProp = proposta.Name;

        RemuneracaoProduto__c remuneracaoProduto = [SELECT Id, TipoRemuneracao__c,ParcelasAgenciamento__c FROM RemuneracaoProduto__c];
        remuneracaoProduto.Produto__c = idProduto;
        update remuneracaoProduto;

        List<AntecipacaoComissao__c> antecipa = [SELECT Id, LimiteMaximo__c, LimiteMinimo__c, TipoEvento__c, RemuneracaoProduto__r.Produto__c FROM AntecipacaoComissao__c LIMIT 1];
        antecipa[0].RemuneracaoProduto__r.Produto__c = idProduto;
        update antecipa;

        System.debug('antecipa => '+ antecipa);
        List<RemuneracaoProposta__c> remProp = [SELECT Id FROM RemuneracaoProposta__c WHERE Proposta__r.Name =: nameProp LIMIT 1];
        System.debug('remProp => '+ remProp);

        RecalculoPropostaController.verificaAntecipacao(proposta.Id);

        Test.stopTest();
    }
    @IsTest
    static void atualizaFavorecidoPropostaTest(){

        Test.startTest();

        Quote proposta = [SELECT Id, Produto__c, Name FROM Quote WHERE Name = '18-00324367' LIMIT 1];
        proposta.Tipo__c = 'Novo';
        update proposta;
        String idProduto = proposta.Produto__c;
        String nameProp = proposta.Name;
        RemuneracaoProduto__c remuneracaoProduto = [SELECT Id, TipoRemuneracao__c,ParcelasAgenciamento__c FROM RemuneracaoProduto__c];
        remuneracaoProduto.Produto__c = idProduto;
        update remuneracaoProduto;
        List<AntecipacaoComissao__c> antecipa = [SELECT Id, LimiteMaximo__c, LimiteMinimo__c, TipoEvento__c, RemuneracaoProduto__r.Produto__c FROM AntecipacaoComissao__c LIMIT 1];
        antecipa[0].RemuneracaoProduto__r.Produto__c = idProduto;
        update antecipa;
        List<RemuneracaoProposta__c> remProp = [SELECT Id FROM RemuneracaoProposta__c WHERE Proposta__r.Name =: nameProp LIMIT 1];
        List<FavorecidoRemuneracaoProposta__c> favRemProp = [SELECT Id, AntecipacaoComissao__c FROM FavorecidoRemuneracaoProposta__c LIMIT 1];
        Boolean antecipar = false;
        RecalculoPropostaController.atualizaFavorecidoProposta(proposta.Id, antecipar);

        Test.stopTest();
    }

    @IsTest
    static void verificaCondicaoCobrancaTest(){

        Test.startTest();

        Quote proposta = [SELECT Id, Produto__c, Name FROM Quote WHERE Name = '18-00324367' LIMIT 1];
        proposta.Tipo__c = 'Novo';
        update proposta;
        String idProduto = proposta.Produto__c;
        String nameProp = proposta.Name;
        RemuneracaoProduto__c remuneracaoProduto = [SELECT Id, TipoRemuneracao__c,ParcelasAgenciamento__c FROM RemuneracaoProduto__c];
        remuneracaoProduto.Produto__c = idProduto;
        update remuneracaoProduto;
        List<AntecipacaoComissao__c> antecipa = [SELECT Id, LimiteMaximo__c, LimiteMinimo__c, TipoEvento__c, RemuneracaoProduto__r.Produto__c FROM AntecipacaoComissao__c LIMIT 1];
        antecipa[0].RemuneracaoProduto__r.Produto__c = idProduto;
        update antecipa;
        List<RemuneracaoProposta__c> remProp = [SELECT Id FROM RemuneracaoProposta__c WHERE Proposta__r.Name =: nameProp LIMIT 1];
        List<FavorecidoRemuneracaoProposta__c> favRemProp = [SELECT Id, AntecipacaoComissao__c FROM FavorecidoRemuneracaoProposta__c LIMIT 1];
        Boolean antecipar = false;
        List<CondicaoCobranca__c> condicao = [SELECT Id, FormaPagamento__r.Codigo__c, QuantidadeParcelas__c, AntecipacaoComissao__c, Produto__c FROM CondicaoCobranca__c LIMIT 1];
        condicao[0].Produto__c = idProduto;
        update condicao;

        RecalculoPropostaController.verificaCondicaoCobranca(proposta.Id, '1', '1234');

        Test.stopTest();
    }
    //II-176 - FIM

    //II-206 - INICIO
    //II-206 FIX01 - INICIO
    @IsTest
    static void atualizaResponsavelFinanceiroTest(){

        Test.startTest();
        Quote proposta = [SELECT Id, Produto__c, Name, AccountId FROM Quote WHERE Name = '18-00324367' LIMIT 1];
        proposta.Tipo__c = 'Novo';
        update proposta;
        String idContaProp = proposta.AccountId;
        String propostaId = proposta.Id;
        Account acc = [SELECT Id FROM Account WHERE id =: idContaProp LIMIT 1];
        ContratanteProposta__c contratante = [SELECT Id, ResponsavelPagamento__r.Cpf__c, Conta__c FROM ContratanteProposta__c WHERE Conta__c =: idContaProp LIMIT 1];
        String cpId = contratante.id;
        GrupoProposta__c grupoProposta2 = new GrupoProposta__c(ContratanteProposta__c = cpId, Name = 'TesteGrupoProposta');
        insert grupoProposta2;
        SeguradoProposta__c seguradoProposta2 = new SeguradoProposta__c(Conta__c = acc.Id, GrupoProposta__c = grupoProposta2.Id, Numero__c = 1,  CicloVacinal__c = '1');
        insert seguradoProposta2;

        RecalculoPropostaController.atualizaResponsavelFinanceiro(proposta.Id, '');

        Test.stopTest();
    }

    @IsTest
    static void atualizaResponsavelFinanceiroTest1(){

        Test.startTest();
        Quote proposta = [SELECT Id, Produto__c, Name, AccountId FROM Quote WHERE Name = '18-00324367' LIMIT 1];
        proposta.Tipo__c = 'Novo';
        update proposta;
        String idContaProp = proposta.AccountId;
        String propostaId = proposta.Id;
        Account acc = [SELECT Id FROM Account WHERE id =: idContaProp LIMIT 1];
        ContratanteProposta__c contratante = [SELECT Id, ResponsavelPagamento__r.Cpf__c, Conta__c FROM ContratanteProposta__c WHERE Conta__c =: idContaProp LIMIT 1];
        String cpId = contratante.id;
        GrupoProposta__c grupoProposta2 = new GrupoProposta__c(ContratanteProposta__c = cpId, Name = 'TesteGrupoProposta');
        insert grupoProposta2;
        SeguradoProposta__c seguradoProposta2 = new SeguradoProposta__c(Conta__c = acc.Id, GrupoProposta__c = grupoProposta2.Id, Numero__c = 1,  CicloVacinal__c = '1');
        insert seguradoProposta2;
        
        String responsavelFin = '{"responsavel":"CZESXWQ VAN DAS QWERTY","cpfResponsavel":"564.564.564-28","vinculoSegurado":"PAI","sexo":"Masculino","nascimento":"1997-09-19","estadoCivil":"Separado(a)","email":"giovanni.bruno.dasneves@riobc.com.br","confirmarEmail":"giovanni.bruno.dasneves@riobc.com.br","cep":"06332-147","tipoEndereco":"Comercial","logradouro":"Graviolas","bairro":"Vila Quintino","cidade":"São Paulo","estado":"SP","complemento":"","semNumero":"","numero":"","telefone1":"(11)94002-8923","telefone2":""}';

        RecalculoPropostaController.atualizaResponsavelFinanceiro(proposta.Id, responsavelFin);
        //RecalculoPropostaController.atualizaResponsavelFinanceiro(proposta.Id, responsavelFin1);
        Test.stopTest(); //II-206 FIX01 - INICIO/FIM
    }

    @IsTest
    static void atualizaResponsavelFinanceiroTest2(){

        Test.startTest();
        Quote proposta = [SELECT Id, Produto__c, Name, AccountId FROM Quote WHERE Name = '18-00324367' LIMIT 1];
        proposta.Tipo__c = 'Novo';
        update proposta;
        String idContaProp = proposta.AccountId;
        String propostaId = proposta.Id;
        Account acc = [SELECT Id FROM Account WHERE id =: idContaProp LIMIT 1];
        ContratanteProposta__c contratante = [SELECT Id, ResponsavelPagamento__r.Cpf__c, Conta__c FROM ContratanteProposta__c WHERE Conta__c =: idContaProp LIMIT 1];
        String cpId = contratante.id;
        GrupoProposta__c grupoProposta2 = new GrupoProposta__c(ContratanteProposta__c = cpId, Name = 'TesteGrupoProposta');
        insert grupoProposta2;
        SeguradoProposta__c seguradoProposta2 = new SeguradoProposta__c(Conta__c = acc.Id, GrupoProposta__c = grupoProposta2.Id, Numero__c = 1,  CicloVacinal__c = '1');
        insert seguradoProposta2;
        
        String responsavelFin1 = '{"responsavel":"CZESXWQ VAN DAS QWERTY","cpfResponsavel":"438.912.318-14","vinculoSegurado":"PAI","sexo":"Masculino","nascimento":"1997-09-19","estadoCivil":"Separado(a)","email":"giovanni.bruno.dasneves@riobc.com.br","confirmarEmail":"giovanni.bruno.dasneves@riobc.com.br","cep":"06332-147","tipoEndereco":"Comercial","logradouro":"Graviolas","bairro":"Vila Quintino","cidade":"São Paulo","estado":"SP","complemento":"","semNumero":"","numero":"","telefone1":"(11)94002-8923","telefone2":""}';

        RecalculoPropostaController.atualizaResponsavelFinanceiro(proposta.Id, responsavelFin1);
        Test.stopTest();
    }
    //II-206 FIX01 - FIM

    @IsTest
    static void atualizaCartaoTest(){

        Test.startTest();
        String numero = '5327 7742 6012 4958';
        String nome = 'Teste teste teste';
        String vencimento = '04/26';
        String codigo = '97'; 
        String melDtPgto = 'A cada 30 dias'; 
        String qtdParcelas = '1';
        String premioTotalNovo = '15.741'; //FNPVVEP-126 INICIO-FIM
        Quote proposta = [SELECT Id, Produto__c, Name, AccountId FROM Quote WHERE Name = '18-00324367' LIMIT 1];
        String produtoId = proposta.Produto__c;
        List<FormaPagamento__c> formaPag = [SELECT Id, Codigo__c FROM FormaPagamento__c LIMIT 1];
        formaPag[0].Codigo__c = codigo;
        update formaPag;
        List<CondicaoCobranca__c> condicao = [SELECT Id, FormaPagamento__r.Codigo__c, QuantidadeParcelas__c, AntecipacaoComissao__c, Produto__c FROM CondicaoCobranca__c LIMIT 1];
        condicao[0].Produto__c = produtoId;
        update condicao;
        List<PlanoParcelamento__c> planoParc = [SELECT Id, CodigoMeioRecebimento__c, DescricaoMeioRecebimento__c, FormaPagamento__c, NumeroParcela__c FROM PlanoParcelamento__c LIMIT 1]; 
        planoParc[0].FormaPagamento__c = formaPag[0].id;
        update planoParc;

        RecalculoPropostaController.atualizaCartao(numero, nome, vencimento, codigo, proposta.Id, produtoId, melDtPgto, qtdParcelas, premioTotalNovo, null); //FNPVVEP-126 INICIO-FIM //FNPVVEP-146 INICIO/FIM
        Test.stopTest();
    }

    @IsTest
    static void atualizaADCTest(){

        Test.startTest();
        Banco__c banconew = new Banco__c();
        banconew.CodigoBanco__c = '237';
        banconew.ConveniadoADC__c  = false;
        banconew.Name = 'BANCO BRADESCO S.A.';
        banconew.Ativo__c = true;
        banconew.Name = '237 - BANCO BRADESCO S.A.';
        insert banconew; 
        String banco = '237 - BANCO BRADESCO S.A.';
        String agencia = '1239';
        String contaCorrente = '0271004';
        String digito = '8';
        String codigo = '52';
        String cpf1 = '564.564.564-28';
        String melDtPgto = 'A cada 30 dias'; 
        String qtdParcelas = '1';
        String premioTotalNovo = '15.741'; //FNPVVEP-126 INICIO-FIM
        Quote proposta = [SELECT Id, Produto__c, Name, AccountId FROM Quote WHERE Name = '18-00324367' LIMIT 1];
        String produtoId = proposta.Produto__c;
        List<FormaPagamento__c> formaPag = [SELECT Id, Codigo__c FROM FormaPagamento__c LIMIT 1];
        formaPag[0].Codigo__c = codigo;
        update formaPag;
        List<CondicaoCobranca__c> condicao = [SELECT Id, FormaPagamento__r.Codigo__c, QuantidadeParcelas__c, AntecipacaoComissao__c, Produto__c FROM CondicaoCobranca__c LIMIT 1];
        condicao[0].Produto__c = produtoId;
        update condicao;
        List<PlanoParcelamento__c> planoParc = [SELECT Id, CodigoMeioRecebimento__c, DescricaoMeioRecebimento__c, FormaPagamento__c, NumeroParcela__c FROM PlanoParcelamento__c LIMIT 1]; 
        planoParc[0].FormaPagamento__c = formaPag[0].id;
        update planoParc;

        RecalculoPropostaController.atualizaADC(banco, agencia, contaCorrente, digito, codigo, cpf1, proposta.Id, produtoId, melDtPgto, qtdParcelas, premioTotalNovo); //FNPVVEP-126 INICIO-FIM
        Test.stopTest();
    }

    
    @IsTest
    static void atualizaBoletoTest(){

        Test.startTest();
        String codigo = '41';
        String melDtPgto = 'A cada 30 dias'; 
        String qtdParcelas = '1';
        String premioTotalNovo = '15.741'; //FNPVVEP-126 INICIO-FIM
        Quote proposta = [SELECT Id, Produto__c, Name, AccountId FROM Quote WHERE Name = '18-00324367' LIMIT 1];
        String produtoId = proposta.Produto__c;
        List<FormaPagamento__c> formaPag = [SELECT Id, Codigo__c FROM FormaPagamento__c LIMIT 1];
        formaPag[0].Codigo__c = codigo;
        update formaPag;
        List<CondicaoCobranca__c> condicao = [SELECT Id, FormaPagamento__r.Codigo__c, QuantidadeParcelas__c, AntecipacaoComissao__c, Produto__c FROM CondicaoCobranca__c LIMIT 1];
        condicao[0].Produto__c = produtoId;
        update condicao;
        List<PlanoParcelamento__c> planoParc = [SELECT Id, CodigoMeioRecebimento__c, DescricaoMeioRecebimento__c, FormaPagamento__c, NumeroParcela__c FROM PlanoParcelamento__c LIMIT 1]; 
        planoParc[0].FormaPagamento__c = formaPag[0].id;
        update planoParc;

        RecalculoPropostaController.atualizaBoleto(codigo, proposta.Id, produtoId, melDtPgto, qtdParcelas, premioTotalNovo); //FNPVVEP-126 INICIO-FIM
        Test.stopTest();
    }
    //II-206 FIX01 - INICIO
    @IsTest
    static void consultaBancosTest() {
        Test.startTest();
        String requestBody = '{"bancosConveniados":"true"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        
        String resultado = RecalculoPropostaController.consultaBancos();
        Test.stopTest();
    }
    //II-206 - FIM
    @IsTest 
    static void dadosResponsavelFinanceiroTest(){

        Test.startTest();
        Quote proposta = [SELECT Id, Produto__c, Name, AccountId FROM Quote WHERE Name = '18-00324367' LIMIT 1];
        String idContaProp = proposta.AccountId;
        String propostaId = proposta.Id;
        Account conta = [SELECT Id FROM Account WHERE id =: idContaProp LIMIT 1];
        List<ContratanteProposta__c> ctrprop = [SELECT Id, ResponsavelPagamento__c FROM ContratanteProposta__c WHERE Proposta__c =: propostaId LIMIT 1];
        ctrProp[0].ResponsavelPagamento__c = conta.Id;
        update ctrprop;
        String cpId = ctrprop[0].id;
        Endereco__c endereco = new Endereco__c();
        endereco.Pais__c = 'BR';
        endereco.Estado__c = 'SP';
        endereco.Logradouro__c = 'rua nossa';
        endereco.CEP__c = '06414-000';
        endereco.Cidade__c = 'Barueri';
        endereco.Conta__c = conta.Id;
        endereco.MaisAtual__c = true;
        insert endereco;
        GrupoProposta__c grupoProposta2 = new GrupoProposta__c(ContratanteProposta__c = cpId, Name = 'TesteGrupoProposta');
        insert grupoProposta2;
        SeguradoProposta__c seguradoProposta2 = new SeguradoProposta__c(Conta__c = conta.Id, GrupoProposta__c = grupoProposta2.Id, Numero__c = 1,  CicloVacinal__c = '1');
        insert seguradoProposta2;
        System.debug('endereco >> ' + endereco);
        System.debug('conta >> ' + conta);
        RecalculoPropostaController.dadosResponsavelFinanceiro(proposta.Id);
        Test.stopTest();
    }
    //II-206 FIX01 - INICIO

    //FNPVVEP-126 INICIO
    @isTest
    static void decryptIdTest() {
        Test.startTest();
        String idCriptografado = 'c70ed1c6b5549123ee524dfe1f3b201c99de8b5516133436291796ff1f06a06d55a78e7fac29cd08f8916dd8f05f1d1a';
        RecalculoPropostaController.decryptId(idCriptografado);
        Test.stopTest();
    }
    //FNPVVEP-126 FIM
    
    //FNPVVEP-146 INICIO
    @IsTest
    public static void testCallTokenizacao() {
        Test.startTest();
        String cardJson = '{"numero": "4111 1111 1111 1111", "dataVencimento": {"mes": "12", "ano": "2024"}}';
        String recordId = [SELECT Id FROM Quote LIMIT 1].Id;
        String codigoEmpresa = '14';
        String response = RecalculoPropostaController.callTokenizacao(cardJson, recordId, codigoEmpresa);
        System.assertEquals(APTlmkPgtoCartaoCreditoCalloutMock.gerarLinkMock().getBody(), response);
        Test.stopTest();
    }
    //FNPVVEP-146 FIM
    
}