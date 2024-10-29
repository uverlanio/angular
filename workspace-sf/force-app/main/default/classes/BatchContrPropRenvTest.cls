/****************************************************************************************************************************
 * Classe de teste implementada para o processo automático de liberação automática de Propostas do tipo Renovação         *
 * @author : Globant                                                                                                        *
 * @date 25/09/2023                                                                                                         *
 * Classe implementada tendo como origem a história RVI-297                                                              *                           *
 * **************************************************************************************************************************/
@isTest
 private class BatchContrPropRenvTest{

    @testSetup
    public static void gerarDadosTeste(){
        
        Account contaTeste = TestDataFactory.gerarConta();
        gerarEndereco(contaTeste.Id);
        //RVI-310 - INICIO
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        dadosCorretor.Name = 'P5005J';
        update dadosCorretor;
        //RVI-310 - FIM
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	      ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        update produtoCom;

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        orcamentoContratado.Type = 'Renovacao';        
        update orcamentoContratado;
        //RVI-310 - INICIO
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

      	Quote propostaTesteRen= TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        propostaTesteRen.Status = 'Em análise';
        propostaTesteRen.Tipo__c = 'Renovacao';
        propostaTesteRen.VigenciaInicial__c = System.today().addDays(10);
        propostaTesteRen.PaisesDestino__c = 'Brasil';
        propostaTesteRen.FaseStatus__c = 'Palavra final'; //RVI-247 - INICIO/FIM
        update propostaTesteRen;

        FormaPagamento__c pagamento = TestDataFactory.gerarFormaPagamento();
        ContratanteProposta__c contratantePropLiberada = TestDataFactory.gerarContratanteProposta(contaTeste, propostaTesteRen, pagamento);

        //RVI-170 - INICIO
        CriticaProposta__c criticaLibRenovacao = TestDataFactory.gerarCriticasPropostaRenovacao(propostaTesteRen, '154', 'Pendente');
        CriticaProposta__c criticaLibQuestVida = TestDataFactory.gerarCriticasPropostaRenovacao(propostaTesteRen, '124', 'Liberado');
        //RVI-247 - INICIO
        criticaLibRenovacao.MomentoAnalise__c = 'Palavra final';
        update criticaLibRenovacao;
        //RVI-247 - FIM
        //RVI-170 - FIM
        //RVI-310 - FIM
        
    }

    //RVI-104 - FIX01 - INICIO
    //RVI-297 INICIO
    @isTest
    public static void testLiberarCriticaRenovacao(){
      Test.startTest(); 
        BatchContrPropRenv batch = new BatchContrPropRenv();
        Boolean falhaEmAgendar = false;

        try{
            batch.liberarCriticaRenovacao();
        }catch(AsyncException a){
            System.debug('MENSAGEM: ' + A.getMessage());
            System.debug('CAUSA: ' + A.getCause());
            if(!a.getMessage().contains('agendado')){
                falhaEmAgendar = true;
            }
        }

        System.assertEquals(false, falhaEmAgendar);
        Test.stopTest();        
    }
        
    //RVI-310 INICIO
    @isTest
    public static void testLiberarCriticaRenovacaoCenario2(){
      
      Test.startTest();
      Account contaTeste2 = new Account(
              Name = 'Conta 41',
              CodigoEmpresa__c = '14',
              IdExterno__c = '13143510000160',
              Papel__c = 'Parceiro',
              Sexo__c = 'Masc',
              Cpf__c = '76466318095',
              Pis__c = '123456789',
              Cnpj__c = '13.143.510/0001-60',
              Inscricao_Municipal__c = '123456789',
              Nacionalidade__c = 'Brasileira',
              EstadoCivil__c = 'Casado (a)',
              Email__c = 'teste@teste.com.br'
      );
      insert contaTeste2;

      DadosCorretor__c dadosCorretor2 = new DadosCorretor__c(
              Name            = 'P5005J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor2;
      
      DadosCorretor__c dadosCorretor3 = new DadosCorretor__c(
              Name            = 'COL10J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor3;

      DadosCorretor__c dadosCorretor4 = new DadosCorretor__c(
              Name            = 'REN01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor4;

      DadosCorretor__c dadosCorretor5 = new DadosCorretor__c(
              Name            = 'REN01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor5;

      

      TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
        Name = 'CORRETAGEM',
        Codigo__c = 'COR',
        LimiteMinimo__c = 5,
        LimiteMaximo__c = 100,
        ModeloRecuperacao__c = 'Integral'
      );
      insert tipoRemuneracao;

      Product2 produtoTec = new Product2(
              Name = 'Nome Produto Tecnico',
              Status__c = 'Em criação',
              ProductCode = '201700001',
              VigenciaInicial__c = System.today().addDays(3),
              TipoCapital__c = 'Capital uniforme',
              Segmento__c = 'Individual',
              TipoResponsavelPagamento__c = 'PAR',
              NumeroSusep__c = '12345',
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
              Versao__c                       = 1,
              VersaoMaxima__c                 = true,
              VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoTec;

      produtoTec.Status__c = 'Ativo';
      update produtoTec;
      
      Product2 produtoCom = new Product2(
          ProdutoTecnico__c               = produtoTec.Id,
          Name                            = 'Nome Produto Comercial',
          Status__c                       = 'Em criação',
          ProductCode                    = '201700001',   
          VigenciaInicial__c              = System.today(),
          VigenciaFinal__c                = System.today().addDays(1),
          TipoCapital__c                  = 'Capital uniforme',
          Segmento__c                     = 'Individual',
          TipoResponsavelPagamento__c     = 'PAR',
          LimiteTotalCarregamento__c      = 200,
          NumeroSusep__c                  = '12345',
          RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
          Versao__c                       = 1,
          VersaoMaxima__c                 = true,
          VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoCom;
             
      produtoCom.Status__c = 'Ativo';
      update produtoCom;

      RamoSeguro__c ramoSegurado = new RamoSeguro__c(
              Name = 'Segurado',
              CodigoEmpresa__c = '214',
              Codigo__c = '2',
              Empresa__c = contaTeste2.Id,
              Status__c = 'Ativo',
              CodigoOrigemDoMovimentoBCP__c = '32'
      );
      insert ramoSegurado;

      CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
      canalDistribuicao.Name = 'Canal Distribuição Teste 001';
      canalDistribuicao.Status__c = 'Em ativação';
      canalDistribuicao.Sigla__c = 'EXE';
      insert canalDistribuicao;

      // Recupera o JSON que está no recurso estático;
      String payloadName = 'PayloadOrcamento001';
      StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
      Blob payloadEntrada = sr.Body;

      // OPORTUNIDADE DO TIPO Segurado DE GRUPO
      Opportunity orcamentoContratado2 = new Opportunity(
              StageName = 'Em criação',
              CurrencyIsoCode = 'BRL',
              Name = 'ARQ-00009769',
              CloseDate = System.today().addDays(20),
              VigenciaInicial__c = System.today(),
              VigenciaFinal__c = System.today().addDays(1),
              Produto__c = produtoCom.Id,
              Probability = 10.0,
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
              AccountId = contaTeste2.Id,
              Numero__c = '00009769',
              CanalDistribuicao__c = canalDistribuicao.Id,
              Type = 'Renovacao',
              Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
      );
      insert orcamentoContratado2;

      Opportunity orcamentoContratado3 = new Opportunity(
              StageName = 'Em criação',
              CurrencyIsoCode = 'BRL',
              Name = 'ARQ-00009569',
              CloseDate = System.today().addDays(20),
              VigenciaInicial__c = System.today(),
              VigenciaFinal__c = System.today().addDays(1),
              Produto__c = produtoCom.Id,
              Probability = 10.0,
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
              AccountId = contaTeste2.Id,
              Numero__c = '00009569',
              CanalDistribuicao__c = canalDistribuicao.Id,
              Type = 'Novo',
              Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
      );
      insert orcamentoContratado3;

      Modalidade__c modalidade = new Modalidade__c(
              RamoSeguro__c = ramoSegurado.Id,
              Name = 'Mod teste',
              Codigo__c = '0'
      );
      insert modalidade;

      String origem = '18';
      String numeroProposta = '00001910';
      Cupom__c cupom = new Cupom__c(
          Codigo__c = 'VALE50DESCONTO',
          Limite_de_Utilizacao__c	= 400,
          Meio_de_Comercializacao__c=	'SFC',
          Percentual__c	 = 5,
          Vigencia_Inicial__c = System.today(),
          Vigencia_Final__c = System.today().addMonths(8)
      );
      insert cupom;
      Quote propNova = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em criação',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = contaTeste2.Id,
            CodigoCorretor__c = dadosCorretor2.Id,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', 
            OpportunityId = orcamentoContratado3.Id,
            Origem__c = origem,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta,
            Parceiro__c = '67708896000139',
            email__c = 'abcd@qualqueremail.com',
            CupomDesconto__c = 'VALE50DESCONTO'

      );
      insert propNova;

      String empresa5 = '22';
      String sucursal5 = '999';
      String ramo5 = '2';
      String numeroApolice5 = '000000014889'; 
      String endosso5 = '0';

      Contract contrato5 = new Contract(
              Name = ContractBO.getInstance().gerarNameContrato(empresa5, sucursal5, ramo5, numeroApolice5, endosso5),
              Produto__c = produtoCom.Id,
              Oportunidade__c = orcamentoContratado2.Id,
              NumeroApolice__c = numeroApolice5,
              RamoSeguro__c = ramoSegurado.Id,
              Status = 'Em elaboração',
              Empresa__c = empresa5,
              CodigoCorretor__c = dadosCorretor2.Id,
              MeioComercializacao__c = 'PMC', 
              Proposta__c = propNova.Id,
              AccountId = contaTeste2.Id,
              StartDate = System.today(),
              VigenciaFinal__c = System.today().addDays(30),
              DataEmissao__c = System.today(),
              Endosso__c = endosso5,
              Sucursal__c = sucursal5,
              CodigoRamo__c = ramo5,
              PremioComercial__c = 15000.00,
              Parceiro__c = '67708896000139',
              CupomDesconto__c = cupom.codigo__c
      );
      insert contrato5;

      
      RemuneracaoContrato__c remuneracaoContrato2 = new RemuneracaoContrato__c(
              Contrato__c = contrato5.Id,
              TipoRemuneracao__c = tipoRemuneracao.Id
      );
      insert remuneracaoContrato2;
      remuneracaoContrato2.CurrencyIsoCode = 'BRL';
      remuneracaoContrato2.Percentual__c = 10;
      remuneracaoContrato2.Porcentagem_de_Retencao__c = 0;
      update remuneracaoContrato2;

      FavorecidoRemuneracaoContrato__c favRemCon2 = new FavorecidoRemuneracaoContrato__c();
      favRemCon2.Conta__c = contaTeste2.Id;
      favRemCon2.CorretorLider__c = true;
      favRemCon2.AntecipacaoComissao__c = true;
      favRemCon2.RemuneracaoContrato__c = remuneracaoContrato2.Id;
      favRemCon2.Papel__c = 'Corretor';
      favRemCon2.Susep__c = 'P5005J';
      insert favRemCon2;


      FavorecidoRemuneracaoContrato__c favRemCon3 = new FavorecidoRemuneracaoContrato__c();
      favRemCon3.Conta__c = contaTeste2.Id;
      favRemCon3.CorretorLider__c = true;
      favRemCon3.AntecipacaoComissao__c = true;
      favRemCon3.RemuneracaoContrato__c = remuneracaoContrato2.Id;
      favRemCon3.Papel__c = 'Corretor';
      favRemCon3.Susep__c = 'P5005J';
      insert favRemCon3;


      FavorecidoRemuneracaoContrato__c favRemCon4 = new FavorecidoRemuneracaoContrato__c();
      favRemCon4.Conta__c = contaTeste2.Id;
      favRemCon4.CorretorLider__c = true;
      favRemCon4.AntecipacaoComissao__c = true;
      favRemCon4.RemuneracaoContrato__c = remuneracaoContrato2.Id;
      favRemCon4.Papel__c = 'Corretor';
      favRemCon4.Susep__c = 'P5005J';
      insert favRemCon4;

      String numeroProposta4 = '00002910';
      Quote propostaTesteRen2= new Quote(
      
      Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta4),
      NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta4),
      Produto__c = produtoCom.Id,
      RamoSeguro__c = ramoSegurado.Id,
      Status = 'Em criação',
      VigenciaInicial__c = System.today(),
      VigenciaFinal__c = System.today().addMonths(1),
      Empresa__c = contaTeste2.Id,
      CodigoCorretor__c = dadosCorretor2.Id,
      DataCalculo__c = System.today(),
      DataCriacaoPortal__c = System.today(),
      TipoVigencia__c = 'Anual',
      MeioComercializacao__c = 'PMC', 
      OpportunityId = orcamentoContratado2.Id,
      Origem__c = origem,
      Modalidade__c = modalidade.Id,
      NumeroProposta__c = numeroProposta4,
      Parceiro__c = '67708896000139',
      email__c = 'abcd@qualqueremail.com',
      CupomDesconto__c = 'VALE50DESCONTO'
      );
      insert propostaTesteRen2;
      propostaTesteRen2.Status = 'Em análise';
      propostaTesteRen2.Tipo__c = 'Renovacao';
      propostaTesteRen2.VigenciaInicial__c = System.today().addDays(10);
      propostaTesteRen2.PaisesDestino__c = 'Brasil';
      propostaTesteRen2.FaseStatus__c = 'Palavra final';
      propostaTesteRen2.ContratoRenovado__c = String.ValueOf(contrato5.Id);
      update propostaTesteRen2;

      RemuneracaoProposta__c remuneracaoProposta = new RemuneracaoProposta__c(
              TipoRemuneracao__c = tipoRemuneracao.Id,
              Proposta__c = propostaTesteRen2.Id,
              Percentual__c = 100
      );
      insert remuneracaoProposta;

      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta2 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 40,
        RemuneracaoProposta__c = remuneracaoProposta.Id,
        Susep__c = 'P5005J',
        CorretorLider__c = true
      );
      insert favorecidoRemuneracaoProposta2;

      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta3 = new FavorecidoRemuneracaoProposta__c(
          Conta__c = contaTeste2.Id,
          Papel__c = 'Corretor',
          Participacao__c = 10,
          RemuneracaoProposta__c = remuneracaoProposta.Id,
          Susep__c = 'COL10J',
          CorretorLider__c = false
        );
        insert favorecidoRemuneracaoProposta3;
      
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta4 = new FavorecidoRemuneracaoProposta__c(
          Conta__c = contaTeste2.Id,
          Papel__c = 'Corretor',
          Participacao__c = 10,
          RemuneracaoProposta__c = remuneracaoProposta.Id,
          Susep__c = 'REN01J',
          CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta4;

      TransferenciaCorretagem__c transfCorreInd3 = new TransferenciaCorretagem__c(
        SusepAtual__c = dadosCorretor3.id,
        ContratoTransferido__c = contrato5.id,
        PercSusepLider__c = 50,
        SusepOriginal__c = dadosCorretor2.id,
        ValidoAte__c = System.today(),
        TransferirCarteira__c = false,
        SusepPriCoCorretagem__c = dadosCorretor2.id,
        PercPriCoCorretor__c = 10,
        SusepSegCoCorretagem__c = dadosCorretor3.id,
        PercSegCoCorretor__c = 10,
        SusepTerCoCorretagem__c = dadosCorretor3.id,
        PercTerCoCorretor__c = 30
      );
      insert transfCorreInd3;

      TransferenciaCorretagem__c transfCorreCart5 = new TransferenciaCorretagem__c(
          SusepAtual__c = dadosCorretor2.id,
          PercSusepLider__c = 50,
          SusepOriginal__c = dadosCorretor3.id,
          ValidoAte__c = System.today(),
          TransferirCarteira__c = true,
          SusepPriCoCorretagem__c = dadosCorretor4.id,
          PercPriCoCorretor__c = 10,
          SusepSegCoCorretagem__c = dadosCorretor4.id,
          PercSegCoCorretor__c = 10,
          SusepTerCoCorretagem__c = dadosCorretor4.id,
          PercTerCoCorretor__c = 10,
          SusepQuaCoCorretagem__c = dadosCorretor4.id,
          PercQuaCoCorretor__c = 10,
          SusepQuiCoCorretagem__c = dadosCorretor4.id,
          PercQuiCoCorretor__c = 10
      );
      insert transfCorreCart5;

      BatchContrPropRenv batch = new BatchContrPropRenv();
      Boolean falhaEmAgendar = false;

      try{
          batch.liberarCriticaRenovacao();
      }catch(AsyncException a){
          System.debug('MENSAGEM: ' + A.getMessage());
          System.debug('CAUSA: ' + A.getCause());
          if(!a.getMessage().contains('agendado')){
              falhaEmAgendar = true;
          }
      }

      System.assertEquals(false, falhaEmAgendar);
      Test.stopTest();         
    }

    @isTest
    public static void testLiberarCriticaRenovacaoDelete(){
    
      Account contaTeste2 = new Account(
              Name = 'Conta 41',
              CodigoEmpresa__c = '14',
              IdExterno__c = '13143510000160',
              Papel__c = 'Parceiro',
              Sexo__c = 'Masc',
              Cpf__c = '76466318095',
              Pis__c = '123456789',
              Cnpj__c = '13.143.510/0001-60',
              Inscricao_Municipal__c = '123456789',
              Nacionalidade__c = 'Brasileira',
              EstadoCivil__c = 'Casado (a)',
              Email__c = 'teste@teste.com.br'
      );
      insert contaTeste2;

      DadosCorretor__c dadosCorretor2 = new DadosCorretor__c(
              Name            = 'P5005J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor2;
      
      DadosCorretor__c dadosCorretor3 = new DadosCorretor__c(
              Name            = 'COL10J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor3;

      DadosCorretor__c dadosCorretor4 = new DadosCorretor__c(
              Name            = 'REN01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor4;

      TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
        Name = 'CORRETAGEM',
        Codigo__c = 'COR',
        LimiteMinimo__c = 5,
        LimiteMaximo__c = 100,
        ModeloRecuperacao__c = 'Integral'
      );
      insert tipoRemuneracao;

      Product2 produtoTec = new Product2(
              Name = 'Nome Produto Tecnico',
              Status__c = 'Em criação',
              ProductCode = '201700001',
              VigenciaInicial__c = System.today().addDays(3),
              TipoCapital__c = 'Capital uniforme',
              Segmento__c = 'Individual',
              TipoResponsavelPagamento__c = 'PAR',
              NumeroSusep__c = '12345',
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
              Versao__c                       = 1,
              VersaoMaxima__c                 = true,
              VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoTec;

      produtoTec.Status__c = 'Ativo';
      update produtoTec;
      
      Product2 produtoCom = new Product2(
          ProdutoTecnico__c               = produtoTec.Id,
          Name                            = 'Nome Produto Comercial',
          Status__c                       = 'Em criação',
          ProductCode                    = '201700001',   
          VigenciaInicial__c              = System.today(),
          VigenciaFinal__c                = System.today().addDays(1),
          TipoCapital__c                  = 'Capital uniforme',
          Segmento__c                     = 'Individual',
          TipoResponsavelPagamento__c     = 'PAR',
          LimiteTotalCarregamento__c      = 200,
          NumeroSusep__c                  = '12345',
          RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
          Versao__c                       = 1,
          VersaoMaxima__c                 = true,
          VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoCom;
             
      produtoCom.Status__c = 'Ativo';
      update produtoCom;

      RamoSeguro__c ramoSegurado = new RamoSeguro__c(
              Name = 'Segurado',
              CodigoEmpresa__c = '214',
              Codigo__c = '2',
              Empresa__c = contaTeste2.Id,
              Status__c = 'Ativo',
              CodigoOrigemDoMovimentoBCP__c = '32'
      );
      insert ramoSegurado;

      CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
      canalDistribuicao.Name = 'Canal Distribuição Teste 001';
      canalDistribuicao.Status__c = 'Em ativação';
      canalDistribuicao.Sigla__c = 'EXE';
      insert canalDistribuicao;

      // Recupera o JSON que está no recurso estático;
      String payloadName = 'PayloadOrcamento001';
      StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
      Blob payloadEntrada = sr.Body;

      // OPORTUNIDADE DO TIPO Segurado DE GRUPO
      Opportunity orcamentoContratado2 = new Opportunity(
              StageName = 'Em criação',
              CurrencyIsoCode = 'BRL',
              Name = 'ARQ-00009769',
              CloseDate = System.today().addDays(20),
              VigenciaInicial__c = System.today(),
              VigenciaFinal__c = System.today().addDays(1),
              Produto__c = produtoCom.Id,
              Probability = 10.0,
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
              AccountId = contaTeste2.Id,
              Numero__c = '00009769',
              CanalDistribuicao__c = canalDistribuicao.Id,
              Type = 'Renovacao',
              Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
      );
      insert orcamentoContratado2;

      Opportunity orcamentoContratado3 = new Opportunity(
              StageName = 'Em criação',
              CurrencyIsoCode = 'BRL',
              Name = 'ARQ-00009569',
              CloseDate = System.today().addDays(20),
              VigenciaInicial__c = System.today(),
              VigenciaFinal__c = System.today().addDays(1),
              Produto__c = produtoCom.Id,
              Probability = 10.0,
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
              AccountId = contaTeste2.Id,
              Numero__c = '00009569',
              CanalDistribuicao__c = canalDistribuicao.Id,
              Type = 'Novo',
              Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
      );
      insert orcamentoContratado3;

      Modalidade__c modalidade = new Modalidade__c(
              RamoSeguro__c = ramoSegurado.Id,
              Name = 'Mod teste',
              Codigo__c = '0'
      );
      insert modalidade;

      String origem = '18';
      String numeroProposta = '00001910';
      Cupom__c cupom = new Cupom__c(
          Codigo__c = 'VALE50DESCONTO',
          Limite_de_Utilizacao__c	= 400,
          Meio_de_Comercializacao__c=	'SFC',
          Percentual__c	 = 5,
          Vigencia_Inicial__c = System.today(),
          Vigencia_Final__c = System.today().addMonths(8)
      );
      insert cupom;
      Quote propNova = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em criação',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = contaTeste2.Id,
            CodigoCorretor__c = dadosCorretor2.Id,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', 
            OpportunityId = orcamentoContratado2.Id,
            Origem__c = origem,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta,
            Parceiro__c = '67708896000139',
            email__c = 'abcd@qualqueremail.com',
            CupomDesconto__c = 'VALE50DESCONTO'

      );
      insert propNova;

      String origem2 = '18';
      String numeroProposta2 = '00001930';
      Quote propNova2 = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem2,numeroProposta2),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem2,numeroProposta2),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em criação',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = contaTeste2.Id,
            CodigoCorretor__c = dadosCorretor2.Id,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', 
            OpportunityId = orcamentoContratado3.Id,
            Origem__c = origem2,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta2,
            Parceiro__c = '67708896000139',
            email__c = 'abcd@qualqueremail.com',
            CupomDesconto__c = 'VALE50DESCONTO'

      );
      insert propNova2;

      String empresa5 = '22';
      String sucursal5 = '999';
      String ramo5 = '2';
      String numeroApolice5 = '000000014889'; 
      String endosso5 = '0';

      Contract contrato5 = new Contract(
              Name = ContractBO.getInstance().gerarNameContrato(empresa5, sucursal5, ramo5, numeroApolice5, endosso5),
              Produto__c = produtoCom.Id,
              Oportunidade__c = orcamentoContratado2.Id,
              NumeroApolice__c = numeroApolice5,
              RamoSeguro__c = ramoSegurado.Id,
              Status = 'Em elaboração',
              Empresa__c = empresa5,
              CodigoCorretor__c = dadosCorretor2.Id,
              MeioComercializacao__c = 'PMC', 
              Proposta__c = propNova.Id,
              AccountId = contaTeste2.Id,
              StartDate = System.today(),
              VigenciaFinal__c = System.today().addDays(30),
              DataEmissao__c = System.today(),
              Endosso__c = endosso5,
              Sucursal__c = sucursal5,
              CodigoRamo__c = ramo5,
              PremioComercial__c = 15000.00,
              Parceiro__c = '67708896000139',
              CupomDesconto__c = cupom.codigo__c
      );
      insert contrato5;
      
      String numeroApolice4 = '000000014869'; 
      Contract contrato4 = new Contract(
              Name = ContractBO.getInstance().gerarNameContrato(empresa5, sucursal5, ramo5, numeroApolice4, endosso5),
              Produto__c = produtoCom.Id,
              Oportunidade__c = orcamentoContratado3.Id,
              NumeroApolice__c = numeroApolice4,
              RamoSeguro__c = ramoSegurado.Id,
              Status = 'Em elaboração',
              Empresa__c = empresa5,
              CodigoCorretor__c = dadosCorretor2.Id,
              MeioComercializacao__c = 'PMC',
              Proposta__c = propNova2.Id,
              AccountId = contaTeste2.Id,
              StartDate = System.today(),
              VigenciaFinal__c = System.today().addDays(30),
              DataEmissao__c = System.today(),
              Endosso__c = endosso5,
              Sucursal__c = sucursal5,
              CodigoRamo__c = ramo5,
              PremioComercial__c = 15000.00,
              Parceiro__c = '67708896000139',
              CupomDesconto__c = cupom.codigo__c
      );

      insert contrato4;

      RemuneracaoContrato__c remuneracaoContrato1 = new RemuneracaoContrato__c(
          Contrato__c = contrato4.Id,
          TipoRemuneracao__c = tipoRemuneracao.Id
      );
      insert remuneracaoContrato1;
      remuneracaoContrato1.CurrencyIsoCode = 'BRL';
      remuneracaoContrato1.Percentual__c = 10;
      remuneracaoContrato1.Porcentagem_de_Retencao__c = 0;
      update remuneracaoContrato1;

      RemuneracaoContrato__c remuneracaoContrato2 = new RemuneracaoContrato__c(
              Contrato__c = contrato5.Id,
              TipoRemuneracao__c = tipoRemuneracao.Id
      );
      insert remuneracaoContrato2;
      remuneracaoContrato2.CurrencyIsoCode = 'BRL';
      remuneracaoContrato2.Percentual__c = 10;
      remuneracaoContrato2.Porcentagem_de_Retencao__c = 0;
      update remuneracaoContrato2;
      FavorecidoRemuneracaoContrato__c favRemCon2 = new FavorecidoRemuneracaoContrato__c();
      favRemCon2.Conta__c = contaTeste2.Id;
      favRemCon2.CorretorLider__c = true;
      favRemCon2.AntecipacaoComissao__c = true;
      favRemCon2.RemuneracaoContrato__c = remuneracaoContrato2.Id;
      favRemCon2.Papel__c = 'Corretor';
      favRemCon2.Susep__c = 'P5005J';
      insert favRemCon2;


      FavorecidoRemuneracaoContrato__c favRemCon3 = new FavorecidoRemuneracaoContrato__c();
      favRemCon3.Conta__c = contaTeste2.Id;
      favRemCon3.CorretorLider__c = false;
      favRemCon3.AntecipacaoComissao__c = true;
      favRemCon3.RemuneracaoContrato__c = remuneracaoContrato2.Id;
      favRemCon3.Papel__c = 'Corretor';
      favRemCon3.Susep__c = 'P5005J';
      insert favRemCon3;

      FavorecidoRemuneracaoContrato__c favRemCon4 = new FavorecidoRemuneracaoContrato__c();
      favRemCon4.Conta__c = contaTeste2.Id;
      favRemCon4.CorretorLider__c = false;
      favRemCon4.AntecipacaoComissao__c = true;
      favRemCon4.RemuneracaoContrato__c = remuneracaoContrato2.Id;
      favRemCon4.Papel__c = 'Corretor';
      favRemCon4.Susep__c = 'P5005J';
      insert favRemCon4;

      FavorecidoRemuneracaoContrato__c favRemCon5 = new FavorecidoRemuneracaoContrato__c();
      favRemCon5.Conta__c = contaTeste2.Id;
      favRemCon5.CorretorLider__c = true;
      favRemCon5.AntecipacaoComissao__c = true;
      favRemCon5.RemuneracaoContrato__c = remuneracaoContrato1.Id;
      favRemCon5.Papel__c = 'Corretor';
      favRemCon5.Susep__c = 'P5005J';
      insert favRemCon5;

      String numeroProposta3 = '00002910';
      Quote propostaTesteRen2= new Quote(
      
      Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta3),
      NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta3),
      Produto__c = produtoCom.Id,
      RamoSeguro__c = ramoSegurado.Id,
      Status = 'Em criação',
      VigenciaInicial__c = System.today(),
      VigenciaFinal__c = System.today().addMonths(1),
      Empresa__c = contaTeste2.Id,
      CodigoCorretor__c = dadosCorretor2.Id,
      DataCalculo__c = System.today(),
      DataCriacaoPortal__c = System.today(),
      TipoVigencia__c = 'Anual',
      MeioComercializacao__c = 'PMC', 
      OpportunityId = orcamentoContratado2.Id,
      Origem__c = origem,
      Modalidade__c = modalidade.Id,
      NumeroProposta__c = numeroProposta3,
      Parceiro__c = '67708896000139',
      email__c = 'abcd@qualqueremail.com',
      CupomDesconto__c = 'VALE50DESCONTO'
      );
      insert propostaTesteRen2;
      propostaTesteRen2.Status = 'Em análise';
      propostaTesteRen2.Tipo__c = 'Renovacao';
      propostaTesteRen2.VigenciaInicial__c = System.today().addDays(10);
      propostaTesteRen2.PaisesDestino__c = 'Brasil';
      propostaTesteRen2.FaseStatus__c = 'Palavra final';
      propostaTesteRen2.ContratoRenovado__c = String.ValueOf(contrato5.Id);
      update propostaTesteRen2;

      RemuneracaoProposta__c remuneracaoProposta1 = new RemuneracaoProposta__c(
              TipoRemuneracao__c = tipoRemuneracao.Id,
              Proposta__c = propostaTesteRen2.Id,
              Percentual__c = 100
      );
      insert remuneracaoProposta1;

      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta2 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 40,
        RemuneracaoProposta__c = remuneracaoProposta1.Id,
        Susep__c = 'P5005J',
        CorretorLider__c = true
      );
      insert favorecidoRemuneracaoProposta2;
    
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta4 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 10,
        RemuneracaoProposta__c = remuneracaoProposta1.Id,
        Susep__c = 'REN01J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta4;

      TransferenciaCorretagem__c transfCorreInd3 = new TransferenciaCorretagem__c(
        SusepAtual__c = dadosCorretor3.id,
        ContratoTransferido__c = contrato5.id,
        PercSusepLider__c = 100,
        SusepOriginal__c = dadosCorretor2.id,
        ValidoAte__c = System.today(),
        TransferirCarteira__c = false
      );
      insert transfCorreInd3;

      TransferenciaCorretagem__c transfCorreCart3 = new TransferenciaCorretagem__c(
        SusepAtual__c = dadosCorretor4.id,
        PercSusepLider__c = 100,
        SusepOriginal__c = dadosCorretor2.id,
        ValidoAte__c = System.today(),
        TransferirCarteira__c = true
      );
      insert transfCorreCart3;

      Test.startTest(); 
      BatchContrPropRenv batch = new BatchContrPropRenv();
      Boolean falhaEmAgendar = false;

      try{
          batch.liberarCriticaRenovacao();
      }catch(AsyncException a){
          System.debug('MENSAGEM: ' + A.getMessage());
          System.debug('CAUSA: ' + A.getCause());
          if(!a.getMessage().contains('agendado')){
              falhaEmAgendar = true;
          }
      }

      System.assertEquals(false, falhaEmAgendar);
      Test.stopTest();   
    }
    @isTest
    public static void testLiberarCriticaRenovacaoCenario3(){
      
      Test.startTest(); 
      Account contaTeste2 = new Account(
              Name = 'Conta 41',
              CodigoEmpresa__c = '14',
              IdExterno__c = '13143510000160',
              Papel__c = 'Parceiro',
              Sexo__c = 'Masc',
              Cpf__c = '76466318095',
              Pis__c = '123456789',
              Cnpj__c = '13.143.510/0001-60',
              Inscricao_Municipal__c = '123456789',
              Nacionalidade__c = 'Brasileira',
              EstadoCivil__c = 'Casado (a)',
              Email__c = 'teste@teste.com.br'
      );
      insert contaTeste2;

      TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
        Name = 'CORRETAGEM',
        Codigo__c = 'COR',
        LimiteMinimo__c = 5,
        LimiteMaximo__c = 100,
        ModeloRecuperacao__c = 'Integral'
      );
      insert tipoRemuneracao;

      DadosCorretor__c dadosCorretor6 = new DadosCorretor__c(
              Name            = 'COL01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor6;

      DadosCorretor__c dadosCorretor7 = new DadosCorretor__c(
              Name            = 'P5006J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor7;

      Product2 produtoTec = new Product2(
              Name = 'Nome Produto Tecnico',
              Status__c = 'Em criação',
              ProductCode = '201700001',
              VigenciaInicial__c = System.today().addDays(3),
              TipoCapital__c = 'Capital uniforme',
              Segmento__c = 'Individual',
              TipoResponsavelPagamento__c = 'PAR',
              NumeroSusep__c = '12345',
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
              Versao__c                       = 1,
              VersaoMaxima__c                 = true,
              VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoTec;

      produtoTec.Status__c = 'Ativo';
      update produtoTec;
      
      Product2 produtoCom = new Product2(
          ProdutoTecnico__c               = produtoTec.Id,
          Name                            = 'Nome Produto Comercial',
          Status__c                       = 'Em criação',
          ProductCode                    = '201700001',   
          VigenciaInicial__c              = System.today(),
          VigenciaFinal__c                = System.today().addDays(1),
          TipoCapital__c                  = 'Capital uniforme',
          Segmento__c                     = 'Individual',
          TipoResponsavelPagamento__c     = 'PAR',
          LimiteTotalCarregamento__c      = 200,
          NumeroSusep__c                  = '12345',
          RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
          Versao__c                       = 1,
          VersaoMaxima__c                 = true,
          VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoCom;
             
      produtoCom.Status__c = 'Ativo';
      update produtoCom;

      RamoSeguro__c ramoSegurado = new RamoSeguro__c(
              Name = 'Segurado',
              CodigoEmpresa__c = '214',
              Codigo__c = '2',
              Empresa__c = contaTeste2.Id,
              Status__c = 'Ativo',
              CodigoOrigemDoMovimentoBCP__c = '32'
      );
      insert ramoSegurado;

      CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
      canalDistribuicao.Name = 'Canal Distribuição Teste 001';
      canalDistribuicao.Status__c = 'Em ativação';
      canalDistribuicao.Sigla__c = 'EXE';
      insert canalDistribuicao;

      // Recupera o JSON que está no recurso estático;
      String payloadName = 'PayloadOrcamento001';
      StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
      Blob payloadEntrada = sr.Body;

      // OPORTUNIDADE DO TIPO Segurado DE GRUPO
      Opportunity orcamentoContratado5 = new Opportunity(
              StageName = 'Em criação',
              CurrencyIsoCode = 'BRL',
              Name = 'ARQ-00002519',
              CloseDate = System.today().addDays(20),
              VigenciaInicial__c = System.today(),
              VigenciaFinal__c = System.today().addDays(1),
              Produto__c = produtoCom.Id,
              Probability = 10.0,
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
              AccountId = contaTeste2.Id,
              Numero__c = '00002519',
              CanalDistribuicao__c = canalDistribuicao.Id,
              Type = 'Novo',
              Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
      );
      insert orcamentoContratado5;

      
      Modalidade__c modalidade = new Modalidade__c(
              RamoSeguro__c = ramoSegurado.Id,
              Name = 'Mod teste',
              Codigo__c = '0'
      );
      insert modalidade;

      
      Cupom__c cupom = new Cupom__c(
          Codigo__c = 'VALE50DESCONTO',
          Limite_de_Utilizacao__c	= 400,
          Meio_de_Comercializacao__c=	'SFC',
          Percentual__c	 = 5,
          Vigencia_Inicial__c = System.today(),
          Vigencia_Final__c = System.today().addMonths(8)
      );
      insert cupom;

      String origem4 = '18';
      String numeroProposta6 = '00024930';
      Quote propNova4 = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem4,numeroProposta6),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem4,numeroProposta6),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em criação',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = contaTeste2.Id,
            CodigoCorretor__c = dadosCorretor6.Id,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', 
            OpportunityId = orcamentoContratado5.Id,
            Origem__c = origem4,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta6,
            Parceiro__c = '67708896000139',
            email__c = 'abcd@qualqueremail.com',
            CupomDesconto__c = 'VALE50DESCONTO'

      );
      insert propNova4;

      String empresa7 = '13';
      String sucursal7 = '999';
      String ramo7 = '2';
      String numeroApolice7 = '000000117689'; 
      String endosso7 = '0';

      Contract contrato7 = new Contract(
              Name = ContractBO.getInstance().gerarNameContrato(empresa7, sucursal7, ramo7, numeroApolice7, endosso7),
              Produto__c = produtoCom.Id,
              Oportunidade__c = orcamentoContratado5.Id,
              NumeroApolice__c = numeroApolice7,
              RamoSeguro__c = ramoSegurado.Id,
              Status = 'Em elaboração',
              Empresa__c = empresa7,
              CodigoCorretor__c = dadosCorretor6.Id,
              MeioComercializacao__c = 'PMC', 
              Proposta__c = propNova4.Id,
              AccountId = contaTeste2.Id,
              StartDate = System.today(),
              VigenciaFinal__c = System.today().addDays(30),
              DataEmissao__c = System.today(),
              Endosso__c = endosso7,
              Sucursal__c = sucursal7,
              CodigoRamo__c = ramo7,
              PremioComercial__c = 15000.00,
              Parceiro__c = '67708896000139',
              CupomDesconto__c = cupom.codigo__c
      );
      insert contrato7;

      RemuneracaoContrato__c remuneracaoContrato4 = new RemuneracaoContrato__c(
            Contrato__c = contrato7.Id,
            TipoRemuneracao__c = tipoRemuneracao.Id
      );
      insert remuneracaoContrato4;
      remuneracaoContrato4.CurrencyIsoCode = 'BRL';
      remuneracaoContrato4.Percentual__c = 10;
      remuneracaoContrato4.Porcentagem_de_Retencao__c = 0;
      update remuneracaoContrato4;

      FavorecidoRemuneracaoContrato__c favRemCon7 = new FavorecidoRemuneracaoContrato__c();
      favRemCon7.Conta__c = contaTeste2.Id;
      favRemCon7.CorretorLider__c = true;
      favRemCon7.AntecipacaoComissao__c = true;
      favRemCon7.RemuneracaoContrato__c = remuneracaoContrato4.Id;
      favRemCon7.Papel__c = 'Corretor';
      favRemCon7.Susep__c = 'COL01J';
      insert favRemCon7;

      
      String origem = '18';
      String numeroProposta7 = '00012310';
      Quote propostaTesteRen4= new Quote(
        Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta7),
        NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta7),
        Produto__c = produtoCom.Id,
        RamoSeguro__c = ramoSegurado.Id,
        Status = 'Em criação',
        VigenciaInicial__c = System.today(),
        VigenciaFinal__c = System.today().addMonths(1),
        Empresa__c = contaTeste2.Id,
        CodigoCorretor__c = dadosCorretor6.Id,
        DataCalculo__c = System.today(),
        DataCriacaoPortal__c = System.today(),
        TipoVigencia__c = 'Anual',
        MeioComercializacao__c = 'PMC', 
        OpportunityId = orcamentoContratado5.Id,
        Origem__c = origem,
        Modalidade__c = modalidade.Id,
        NumeroProposta__c = numeroProposta7,
        Parceiro__c = '67708896000139',
        email__c = 'abcd@qualqueremail.com',
        CupomDesconto__c = 'VALE50DESCONTO'
      );
      insert propostaTesteRen4;
      propostaTesteRen4.Status = 'Em análise';
      propostaTesteRen4.Tipo__c = 'Renovacao';
      propostaTesteRen4.VigenciaInicial__c = System.today().addDays(10);
      propostaTesteRen4.PaisesDestino__c = 'Brasil';
      propostaTesteRen4.FaseStatus__c = 'Palavra final';
      propostaTesteRen4.ContratoRenovado__c = String.ValueOf(contrato7.Id);
      update propostaTesteRen4;

      RemuneracaoProposta__c remuneracaoProposta3 = new RemuneracaoProposta__c(
        TipoRemuneracao__c = tipoRemuneracao.Id,
        Proposta__c = propostaTesteRen4.Id,
        Percentual__c = 100
      );
      insert remuneracaoProposta3;
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta7 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 50,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'P5006J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta7;
      
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta6 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 50,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'COL01J',
        CorretorLider__c = true
      );
      insert favorecidoRemuneracaoProposta6;
      
      
      TransferenciaCorretagem__c transfCorreInd4 = new TransferenciaCorretagem__c(
        SusepAtual__c = dadosCorretor7.id,
        ContratoTransferido__c = contrato7.id,
        PercSusepLider__c = 50,
        SusepOriginal__c = dadosCorretor6.id,
        ValidoAte__c = System.today(),
        TransferirCarteira__c = false,
        SusepPriCoCorretagem__c = dadosCorretor7.id,
        PercPriCoCorretor__c = 10,
        SusepSegCoCorretagem__c = dadosCorretor7.id,
        PercSegCoCorretor__c = 40
      );
      insert transfCorreInd4;

      BatchContrPropRenv batch = new BatchContrPropRenv();
      Boolean falhaEmAgendar = false;

      try{
          batch.liberarCriticaRenovacao();
      }catch(AsyncException a){
          System.debug('MENSAGEM: ' + A.getMessage());
          System.debug('CAUSA: ' + A.getCause());
          if(!a.getMessage().contains('agendado')){
              falhaEmAgendar = true;
          }
      }

      System.assertEquals(false, falhaEmAgendar);
      Test.stopTest();   
    }

    @isTest
    public static void testLiberarCriticaRenovacaoCenario4(){
      
      Test.startTest(); 
      Account contaTeste2 = new Account(
              Name = 'Conta 41',
              CodigoEmpresa__c = '14',
              IdExterno__c = '13143510000160',
              Papel__c = 'Parceiro',
              Sexo__c = 'Masc',
              Cpf__c = '76466318095',
              Pis__c = '123456789',
              Cnpj__c = '13.143.510/0001-60',
              Inscricao_Municipal__c = '123456789',
              Nacionalidade__c = 'Brasileira',
              EstadoCivil__c = 'Casado (a)',
              Email__c = 'teste@teste.com.br'
      );
      insert contaTeste2;

      TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
        Name = 'CORRETAGEM',
        Codigo__c = 'COR',
        LimiteMinimo__c = 5,
        LimiteMaximo__c = 100,
        ModeloRecuperacao__c = 'Integral'
      );
      insert tipoRemuneracao;

      DadosCorretor__c dadosCorretor6 = new DadosCorretor__c(
              Name            = 'COL01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor6;

      DadosCorretor__c dadosCorretor7 = new DadosCorretor__c(
              Name            = 'P5006J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor7;

      DadosCorretor__c dadosCorretor2 = new DadosCorretor__c(
              Name            = 'P5005J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor2;
      
      DadosCorretor__c dadosCorretor3 = new DadosCorretor__c(
              Name            = 'COL10J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor3;

      Product2 produtoTec = new Product2(
              Name = 'Nome Produto Tecnico',
              Status__c = 'Em criação',
              ProductCode = '201700001',
              VigenciaInicial__c = System.today().addDays(3),
              TipoCapital__c = 'Capital uniforme',
              Segmento__c = 'Individual',
              TipoResponsavelPagamento__c = 'PAR',
              NumeroSusep__c = '12345',
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
              Versao__c                       = 1,
              VersaoMaxima__c                 = true,
              VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoTec;

      produtoTec.Status__c = 'Ativo';
      update produtoTec;
      
      Product2 produtoCom = new Product2(
          ProdutoTecnico__c               = produtoTec.Id,
          Name                            = 'Nome Produto Comercial',
          Status__c                       = 'Em criação',
          ProductCode                    = '201700001',   
          VigenciaInicial__c              = System.today(),
          VigenciaFinal__c                = System.today().addDays(1),
          TipoCapital__c                  = 'Capital uniforme',
          Segmento__c                     = 'Individual',
          TipoResponsavelPagamento__c     = 'PAR',
          LimiteTotalCarregamento__c      = 200,
          NumeroSusep__c                  = '12345',
          RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
          Versao__c                       = 1,
          VersaoMaxima__c                 = true,
          VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoCom;
             
      produtoCom.Status__c = 'Ativo';
      update produtoCom;

      RamoSeguro__c ramoSegurado = new RamoSeguro__c(
              Name = 'Segurado',
              CodigoEmpresa__c = '214',
              Codigo__c = '2',
              Empresa__c = contaTeste2.Id,
              Status__c = 'Ativo',
              CodigoOrigemDoMovimentoBCP__c = '32'
      );
      insert ramoSegurado;

      CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
      canalDistribuicao.Name = 'Canal Distribuição Teste 001';
      canalDistribuicao.Status__c = 'Em ativação';
      canalDistribuicao.Sigla__c = 'EXE';
      insert canalDistribuicao;

      // Recupera o JSON que está no recurso estático;
      String payloadName = 'PayloadOrcamento001';
      StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
      Blob payloadEntrada = sr.Body;

      // OPORTUNIDADE DO TIPO Segurado DE GRUPO
      Opportunity orcamentoContratado5 = new Opportunity(
              StageName = 'Em criação',
              CurrencyIsoCode = 'BRL',
              Name = 'ARQ-00032519',
              CloseDate = System.today().addDays(20),
              VigenciaInicial__c = System.today(),
              VigenciaFinal__c = System.today().addDays(1),
              Produto__c = produtoCom.Id,
              Probability = 10.0,
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
              AccountId = contaTeste2.Id,
              Numero__c = '00002519',
              CanalDistribuicao__c = canalDistribuicao.Id,
              Type = 'Novo',
              Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
      );
      insert orcamentoContratado5;

      
      Modalidade__c modalidade = new Modalidade__c(
              RamoSeguro__c = ramoSegurado.Id,
              Name = 'Mod teste',
              Codigo__c = '0'
      );
      insert modalidade;

      
      Cupom__c cupom = new Cupom__c(
          Codigo__c = 'VALE50DESCONTO',
          Limite_de_Utilizacao__c	= 400,
          Meio_de_Comercializacao__c=	'SFC',
          Percentual__c	 = 5,
          Vigencia_Inicial__c = System.today(),
          Vigencia_Final__c = System.today().addMonths(8)
      );
      insert cupom;

      String origem4 = '18';
      String numeroProposta6 = '00024930';
      Quote propNova4 = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem4,numeroProposta6),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem4,numeroProposta6),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em criação',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = contaTeste2.Id,
            CodigoCorretor__c = dadosCorretor6.Id,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', 
            OpportunityId = orcamentoContratado5.Id,
            Origem__c = origem4,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta6,
            Parceiro__c = '67708896000139',
            email__c = 'abcd@qualqueremail.com',
            CupomDesconto__c = 'VALE50DESCONTO'

      );
      insert propNova4;

      String empresa7 = '13';
      String sucursal7 = '999';
      String ramo7 = '2';
      String numeroApolice7 = '000000117683'; 
      String endosso7 = '0';

      Contract contrato7 = new Contract(
              Name = ContractBO.getInstance().gerarNameContrato(empresa7, sucursal7, ramo7, numeroApolice7, endosso7),
              Produto__c = produtoCom.Id,
              Oportunidade__c = orcamentoContratado5.Id,
              NumeroApolice__c = numeroApolice7,
              RamoSeguro__c = ramoSegurado.Id,
              Status = 'Em elaboração',
              Empresa__c = empresa7,
              CodigoCorretor__c = dadosCorretor6.Id,
              MeioComercializacao__c = 'PMC', 
              Proposta__c = propNova4.Id,
              AccountId = contaTeste2.Id,
              StartDate = System.today(),
              VigenciaFinal__c = System.today().addDays(30),
              DataEmissao__c = System.today(),
              Endosso__c = endosso7,
              Sucursal__c = sucursal7,
              CodigoRamo__c = ramo7,
              PremioComercial__c = 15000.00,
              Parceiro__c = '67708896000139',
              CupomDesconto__c = cupom.codigo__c
      );
      insert contrato7;

      RemuneracaoContrato__c remuneracaoContrato4 = new RemuneracaoContrato__c(
            Contrato__c = contrato7.Id,
            TipoRemuneracao__c = tipoRemuneracao.Id
      );
      insert remuneracaoContrato4;
      remuneracaoContrato4.CurrencyIsoCode = 'BRL';
      remuneracaoContrato4.Percentual__c = 10;
      remuneracaoContrato4.Porcentagem_de_Retencao__c = 0;
      update remuneracaoContrato4;

      FavorecidoRemuneracaoContrato__c favRemCon7 = new FavorecidoRemuneracaoContrato__c();
      favRemCon7.Conta__c = contaTeste2.Id;
      favRemCon7.CorretorLider__c = true;
      favRemCon7.AntecipacaoComissao__c = true;
      favRemCon7.RemuneracaoContrato__c = remuneracaoContrato4.Id;
      favRemCon7.Papel__c = 'Corretor';
      favRemCon7.Susep__c = 'COL01J';
      insert favRemCon7;

      
      String origem = '18';
      String numeroProposta7 = '00012340';
      Quote propostaTesteRen4= new Quote(
        Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta7),
        NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta7),
        Produto__c = produtoCom.Id,
        RamoSeguro__c = ramoSegurado.Id,
        Status = 'Em criação',
        VigenciaInicial__c = System.today(),
        VigenciaFinal__c = System.today().addMonths(1),
        Empresa__c = contaTeste2.Id,
        CodigoCorretor__c = dadosCorretor6.Id,
        DataCalculo__c = System.today(),
        DataCriacaoPortal__c = System.today(),
        TipoVigencia__c = 'Anual',
        MeioComercializacao__c = 'PMC', 
        OpportunityId = orcamentoContratado5.Id,
        Origem__c = origem,
        Modalidade__c = modalidade.Id,
        NumeroProposta__c = numeroProposta7,
        Parceiro__c = '67708896000139',
        email__c = 'abcd@qualqueremail.com',
        CupomDesconto__c = 'VALE50DESCONTO'
      );
      insert propostaTesteRen4;
      propostaTesteRen4.Status = 'Em análise';
      propostaTesteRen4.Tipo__c = 'Renovacao';
      propostaTesteRen4.VigenciaInicial__c = System.today().addDays(10);
      propostaTesteRen4.PaisesDestino__c = 'Brasil';
      propostaTesteRen4.FaseStatus__c = 'Palavra final';
      propostaTesteRen4.ContratoRenovado__c = String.ValueOf(contrato7.Id);
      update propostaTesteRen4;

      RemuneracaoProposta__c remuneracaoProposta3 = new RemuneracaoProposta__c(
        TipoRemuneracao__c = tipoRemuneracao.Id,
        Proposta__c = propostaTesteRen4.Id,
        Percentual__c = 100
      );
      insert remuneracaoProposta3;
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta7 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 25,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'P5006J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta7;
      
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta6 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 25,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'COL01J',
        CorretorLider__c = true
      );
      insert favorecidoRemuneracaoProposta6;

      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta8 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 25,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'P5005J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta8;
      
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta9 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 25,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'COL10J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta9;
      
      
      TransferenciaCorretagem__c transfCorreInd4 = new TransferenciaCorretagem__c(
        SusepAtual__c = dadosCorretor7.id,
        ContratoTransferido__c = contrato7.id,
        PercSusepLider__c = 50,
        SusepOriginal__c = dadosCorretor6.id,
        ValidoAte__c = System.today(),
        TransferirCarteira__c = false,
        SusepPriCoCorretagem__c = dadosCorretor7.id,
        PercPriCoCorretor__c = 10,
        SusepSegCoCorretagem__c = dadosCorretor7.id,
        PercSegCoCorretor__c = 10,
        SusepTerCoCorretagem__c = dadosCorretor7.id,
        PercTerCoCorretor__c = 30
      );
      insert transfCorreInd4;

      BatchContrPropRenv batch = new BatchContrPropRenv();
      Boolean falhaEmAgendar = false;

      try{
          batch.liberarCriticaRenovacao();
      }catch(AsyncException a){
          System.debug('MENSAGEM: ' + A.getMessage());
          System.debug('CAUSA: ' + A.getCause());
          if(!a.getMessage().contains('agendado')){
              falhaEmAgendar = true;
          }
      }

      System.assertEquals(false, falhaEmAgendar);
      Test.stopTest();   
    }

    @isTest
    public static void testLiberarCriticaRenovacaoCenario5(){
      
      Test.startTest(); 
      Account contaTeste2 = new Account(
              Name = 'Conta 41',
              CodigoEmpresa__c = '14',
              IdExterno__c = '13143510000160',
              Papel__c = 'Parceiro',
              Sexo__c = 'Masc',
              Cpf__c = '76466318095',
              Pis__c = '123456789',
              Cnpj__c = '13.143.510/0001-60',
              Inscricao_Municipal__c = '123456789',
              Nacionalidade__c = 'Brasileira',
              EstadoCivil__c = 'Casado (a)',
              Email__c = 'teste@teste.com.br'
      );
      insert contaTeste2;

      TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
        Name = 'CORRETAGEM',
        Codigo__c = 'COR',
        LimiteMinimo__c = 5,
        LimiteMaximo__c = 100,
        ModeloRecuperacao__c = 'Integral'
      );
      insert tipoRemuneracao;

      DadosCorretor__c dadosCorretor6 = new DadosCorretor__c(
              Name            = 'COL01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor6;

      DadosCorretor__c dadosCorretor7 = new DadosCorretor__c(
              Name            = 'P5006J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor7;

      DadosCorretor__c dadosCorretor2 = new DadosCorretor__c(
              Name            = 'P5005J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor2;
      
      DadosCorretor__c dadosCorretor3 = new DadosCorretor__c(
              Name            = 'COL10J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor3;

      DadosCorretor__c dadosCorretor4 = new DadosCorretor__c(
              Name            = 'REN01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor4;

      Product2 produtoTec = new Product2(
              Name = 'Nome Produto Tecnico',
              Status__c = 'Em criação',
              ProductCode = '201700001',
              VigenciaInicial__c = System.today().addDays(3),
              TipoCapital__c = 'Capital uniforme',
              Segmento__c = 'Individual',
              TipoResponsavelPagamento__c = 'PAR',
              NumeroSusep__c = '12345',
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
              Versao__c                       = 1,
              VersaoMaxima__c                 = true,
              VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoTec;

      produtoTec.Status__c = 'Ativo';
      update produtoTec;
      
      Product2 produtoCom = new Product2(
          ProdutoTecnico__c               = produtoTec.Id,
          Name                            = 'Nome Produto Comercial',
          Status__c                       = 'Em criação',
          ProductCode                    = '201700001',   
          VigenciaInicial__c              = System.today(),
          VigenciaFinal__c                = System.today().addDays(1),
          TipoCapital__c                  = 'Capital uniforme',
          Segmento__c                     = 'Individual',
          TipoResponsavelPagamento__c     = 'PAR',
          LimiteTotalCarregamento__c      = 200,
          NumeroSusep__c                  = '12345',
          RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
          Versao__c                       = 1,
          VersaoMaxima__c                 = true,
          VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoCom;
             
      produtoCom.Status__c = 'Ativo';
      update produtoCom;

      RamoSeguro__c ramoSegurado = new RamoSeguro__c(
              Name = 'Segurado',
              CodigoEmpresa__c = '214',
              Codigo__c = '2',
              Empresa__c = contaTeste2.Id,
              Status__c = 'Ativo',
              CodigoOrigemDoMovimentoBCP__c = '32'
      );
      insert ramoSegurado;

      CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
      canalDistribuicao.Name = 'Canal Distribuição Teste 001';
      canalDistribuicao.Status__c = 'Em ativação';
      canalDistribuicao.Sigla__c = 'EXE';
      insert canalDistribuicao;

      // Recupera o JSON que está no recurso estático;
      String payloadName = 'PayloadOrcamento001';
      StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
      Blob payloadEntrada = sr.Body;

      // OPORTUNIDADE DO TIPO Segurado DE GRUPO
      Opportunity orcamentoContratado5 = new Opportunity(
              StageName = 'Em criação',
              CurrencyIsoCode = 'BRL',
              Name = 'ARQ-00032519',
              CloseDate = System.today().addDays(20),
              VigenciaInicial__c = System.today(),
              VigenciaFinal__c = System.today().addDays(1),
              Produto__c = produtoCom.Id,
              Probability = 10.0,
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
              AccountId = contaTeste2.Id,
              Numero__c = '00002519',
              CanalDistribuicao__c = canalDistribuicao.Id,
              Type = 'Novo',
              Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
      );
      insert orcamentoContratado5;

      
      Modalidade__c modalidade = new Modalidade__c(
              RamoSeguro__c = ramoSegurado.Id,
              Name = 'Mod teste',
              Codigo__c = '0'
      );
      insert modalidade;

      
      Cupom__c cupom = new Cupom__c(
          Codigo__c = 'VALE50DESCONTO',
          Limite_de_Utilizacao__c	= 400,
          Meio_de_Comercializacao__c=	'SFC',
          Percentual__c	 = 5,
          Vigencia_Inicial__c = System.today(),
          Vigencia_Final__c = System.today().addMonths(8)
      );
      insert cupom;

      String origem4 = '18';
      String numeroProposta6 = '00024930';
      Quote propNova4 = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem4,numeroProposta6),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem4,numeroProposta6),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em criação',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = contaTeste2.Id,
            CodigoCorretor__c = dadosCorretor6.Id,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', 
            OpportunityId = orcamentoContratado5.Id,
            Origem__c = origem4,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta6,
            Parceiro__c = '67708896000139',
            email__c = 'abcd@qualqueremail.com',
            CupomDesconto__c = 'VALE50DESCONTO'

      );
      insert propNova4;

      String empresa7 = '13';
      String sucursal7 = '999';
      String ramo7 = '2';
      String numeroApolice7 = '000000117683'; 
      String endosso7 = '0';

      Contract contrato7 = new Contract(
              Name = ContractBO.getInstance().gerarNameContrato(empresa7, sucursal7, ramo7, numeroApolice7, endosso7),
              Produto__c = produtoCom.Id,
              Oportunidade__c = orcamentoContratado5.Id,
              NumeroApolice__c = numeroApolice7,
              RamoSeguro__c = ramoSegurado.Id,
              Status = 'Em elaboração',
              Empresa__c = empresa7,
              CodigoCorretor__c = dadosCorretor6.Id,
              MeioComercializacao__c = 'PMC', 
              Proposta__c = propNova4.Id,
              AccountId = contaTeste2.Id,
              StartDate = System.today(),
              VigenciaFinal__c = System.today().addDays(30),
              DataEmissao__c = System.today(),
              Endosso__c = endosso7,
              Sucursal__c = sucursal7,
              CodigoRamo__c = ramo7,
              PremioComercial__c = 15000.00,
              Parceiro__c = '67708896000139',
              CupomDesconto__c = cupom.codigo__c
      );
      insert contrato7;

      RemuneracaoContrato__c remuneracaoContrato4 = new RemuneracaoContrato__c(
            Contrato__c = contrato7.Id,
            TipoRemuneracao__c = tipoRemuneracao.Id
      );
      insert remuneracaoContrato4;
      remuneracaoContrato4.CurrencyIsoCode = 'BRL';
      remuneracaoContrato4.Percentual__c = 10;
      remuneracaoContrato4.Porcentagem_de_Retencao__c = 0;
      update remuneracaoContrato4;

      FavorecidoRemuneracaoContrato__c favRemCon7 = new FavorecidoRemuneracaoContrato__c();
      favRemCon7.Conta__c = contaTeste2.Id;
      favRemCon7.CorretorLider__c = true;
      favRemCon7.AntecipacaoComissao__c = true;
      favRemCon7.RemuneracaoContrato__c = remuneracaoContrato4.Id;
      favRemCon7.Papel__c = 'Corretor';
      favRemCon7.Susep__c = 'COL01J';
      insert favRemCon7;

      
      String origem = '18';
      String numeroProposta7 = '00012340';
      Quote propostaTesteRen4= new Quote(
        Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta7),
        NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta7),
        Produto__c = produtoCom.Id,
        RamoSeguro__c = ramoSegurado.Id,
        Status = 'Em criação',
        VigenciaInicial__c = System.today(),
        VigenciaFinal__c = System.today().addMonths(1),
        Empresa__c = contaTeste2.Id,
        CodigoCorretor__c = dadosCorretor6.Id,
        DataCalculo__c = System.today(),
        DataCriacaoPortal__c = System.today(),
        TipoVigencia__c = 'Anual',
        MeioComercializacao__c = 'PMC', 
        OpportunityId = orcamentoContratado5.Id,
        Origem__c = origem,
        Modalidade__c = modalidade.Id,
        NumeroProposta__c = numeroProposta7,
        Parceiro__c = '67708896000139',
        email__c = 'abcd@qualqueremail.com',
        CupomDesconto__c = 'VALE50DESCONTO'
      );
      insert propostaTesteRen4;
      propostaTesteRen4.Status = 'Em análise';
      propostaTesteRen4.Tipo__c = 'Renovacao';
      propostaTesteRen4.VigenciaInicial__c = System.today().addDays(10);
      propostaTesteRen4.PaisesDestino__c = 'Brasil';
      propostaTesteRen4.FaseStatus__c = 'Palavra final';
      propostaTesteRen4.ContratoRenovado__c = String.ValueOf(contrato7.Id);
      update propostaTesteRen4;

      RemuneracaoProposta__c remuneracaoProposta3 = new RemuneracaoProposta__c(
        TipoRemuneracao__c = tipoRemuneracao.Id,
        Proposta__c = propostaTesteRen4.Id,
        Percentual__c = 100
      );
      insert remuneracaoProposta3;
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta7 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'P5006J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta7;
      
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta6 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'COL01J',
        CorretorLider__c = true
      );
      insert favorecidoRemuneracaoProposta6;

      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta8 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'P5005J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta8;
      
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta9 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'COL10J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta9;

      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta10 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'REN01J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta10;
      
      
      TransferenciaCorretagem__c transfCorreInd4 = new TransferenciaCorretagem__c(
        SusepAtual__c = dadosCorretor7.id,
        ContratoTransferido__c = contrato7.id,
        PercSusepLider__c = 50,
        SusepOriginal__c = dadosCorretor6.id,
        ValidoAte__c = System.today(),
        TransferirCarteira__c = false,
        SusepPriCoCorretagem__c = dadosCorretor7.id,
        PercPriCoCorretor__c = 10,
        SusepSegCoCorretagem__c = dadosCorretor7.id,
        PercSegCoCorretor__c = 10,
        SusepTerCoCorretagem__c = dadosCorretor7.id,
        PercTerCoCorretor__c = 10,
        SusepQuaCoCorretagem__c = dadosCorretor7.id,
        PercQuaCoCorretor__c = 20
      );
      insert transfCorreInd4;

      BatchContrPropRenv batch = new BatchContrPropRenv();
      Boolean falhaEmAgendar = false;

      try{
          batch.liberarCriticaRenovacao();
      }catch(AsyncException a){
          System.debug('MENSAGEM: ' + A.getMessage());
          System.debug('CAUSA: ' + A.getCause());
          if(!a.getMessage().contains('agendado')){
              falhaEmAgendar = true;
          }
      }

      System.assertEquals(false, falhaEmAgendar);
      Test.stopTest();   
    }

    @isTest
    public static void testLiberarCriticaRenovacaoCenario6(){
      
      Test.startTest(); 
      Account contaTeste2 = new Account(
              Name = 'Conta 41',
              CodigoEmpresa__c = '14',
              IdExterno__c = '13143510000160',
              Papel__c = 'Parceiro',
              Sexo__c = 'Masc',
              Cpf__c = '76466318095',
              Pis__c = '123456789',
              Cnpj__c = '13.143.510/0001-60',
              Inscricao_Municipal__c = '123456789',
              Nacionalidade__c = 'Brasileira',
              EstadoCivil__c = 'Casado (a)',
              Email__c = 'teste@teste.com.br'
      );
      insert contaTeste2;

      TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
        Name = 'CORRETAGEM',
        Codigo__c = 'COR',
        LimiteMinimo__c = 5,
        LimiteMaximo__c = 100,
        ModeloRecuperacao__c = 'Integral'
      );
      insert tipoRemuneracao;

      DadosCorretor__c dadosCorretor6 = new DadosCorretor__c(
              Name            = 'COL01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor6;

      DadosCorretor__c dadosCorretor7 = new DadosCorretor__c(
              Name            = 'P5006J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor7;

      DadosCorretor__c dadosCorretor2 = new DadosCorretor__c(
              Name            = 'P5005J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor2;
      
      DadosCorretor__c dadosCorretor3 = new DadosCorretor__c(
              Name            = 'COL10J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor3;

      DadosCorretor__c dadosCorretor4 = new DadosCorretor__c(
              Name            = 'REN01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor4;

      Product2 produtoTec = new Product2(
              Name = 'Nome Produto Tecnico',
              Status__c = 'Em criação',
              ProductCode = '201700001',
              VigenciaInicial__c = System.today().addDays(3),
              TipoCapital__c = 'Capital uniforme',
              Segmento__c = 'Individual',
              TipoResponsavelPagamento__c = 'PAR',
              NumeroSusep__c = '12345',
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
              Versao__c                       = 1,
              VersaoMaxima__c                 = true,
              VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoTec;

      produtoTec.Status__c = 'Ativo';
      update produtoTec;
      
      Product2 produtoCom = new Product2(
          ProdutoTecnico__c               = produtoTec.Id,
          Name                            = 'Nome Produto Comercial',
          Status__c                       = 'Em criação',
          ProductCode                    = '201700001',   
          VigenciaInicial__c              = System.today(),
          VigenciaFinal__c                = System.today().addDays(1),
          TipoCapital__c                  = 'Capital uniforme',
          Segmento__c                     = 'Individual',
          TipoResponsavelPagamento__c     = 'PAR',
          LimiteTotalCarregamento__c      = 200,
          NumeroSusep__c                  = '12345',
          RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
          Versao__c                       = 1,
          VersaoMaxima__c                 = true,
          VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoCom;
             
      produtoCom.Status__c = 'Ativo';
      update produtoCom;

      RamoSeguro__c ramoSegurado = new RamoSeguro__c(
              Name = 'Segurado',
              CodigoEmpresa__c = '214',
              Codigo__c = '2',
              Empresa__c = contaTeste2.Id,
              Status__c = 'Ativo',
              CodigoOrigemDoMovimentoBCP__c = '32'
      );
      insert ramoSegurado;

      CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
      canalDistribuicao.Name = 'Canal Distribuição Teste 001';
      canalDistribuicao.Status__c = 'Em ativação';
      canalDistribuicao.Sigla__c = 'EXE';
      insert canalDistribuicao;

      // Recupera o JSON que está no recurso estático;
      String payloadName = 'PayloadOrcamento001';
      StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
      Blob payloadEntrada = sr.Body;

      // OPORTUNIDADE DO TIPO Segurado DE GRUPO
      Opportunity orcamentoContratado5 = new Opportunity(
              StageName = 'Em criação',
              CurrencyIsoCode = 'BRL',
              Name = 'ARQ-00032519',
              CloseDate = System.today().addDays(20),
              VigenciaInicial__c = System.today(),
              VigenciaFinal__c = System.today().addDays(1),
              Produto__c = produtoCom.Id,
              Probability = 10.0,
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
              AccountId = contaTeste2.Id,
              Numero__c = '00002519',
              CanalDistribuicao__c = canalDistribuicao.Id,
              Type = 'Novo',
              Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
      );
      insert orcamentoContratado5;

      
      Modalidade__c modalidade = new Modalidade__c(
              RamoSeguro__c = ramoSegurado.Id,
              Name = 'Mod teste',
              Codigo__c = '0'
      );
      insert modalidade;

      
      Cupom__c cupom = new Cupom__c(
          Codigo__c = 'VALE50DESCONTO',
          Limite_de_Utilizacao__c	= 400,
          Meio_de_Comercializacao__c=	'SFC',
          Percentual__c	 = 5,
          Vigencia_Inicial__c = System.today(),
          Vigencia_Final__c = System.today().addMonths(8)
      );
      insert cupom;

      String origem4 = '18';
      String numeroProposta6 = '00024930';
      Quote propNova4 = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem4,numeroProposta6),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem4,numeroProposta6),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em criação',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = contaTeste2.Id,
            CodigoCorretor__c = dadosCorretor6.Id,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', 
            OpportunityId = orcamentoContratado5.Id,
            Origem__c = origem4,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta6,
            Parceiro__c = '67708896000139',
            email__c = 'abcd@qualqueremail.com',
            CupomDesconto__c = 'VALE50DESCONTO'

      );
      insert propNova4;

      String empresa7 = '13';
      String sucursal7 = '999';
      String ramo7 = '2';
      String numeroApolice7 = '000000117683'; 
      String endosso7 = '0';

      Contract contrato7 = new Contract(
              Name = ContractBO.getInstance().gerarNameContrato(empresa7, sucursal7, ramo7, numeroApolice7, endosso7),
              Produto__c = produtoCom.Id,
              Oportunidade__c = orcamentoContratado5.Id,
              NumeroApolice__c = numeroApolice7,
              RamoSeguro__c = ramoSegurado.Id,
              Status = 'Em elaboração',
              Empresa__c = empresa7,
              CodigoCorretor__c = dadosCorretor6.Id,
              MeioComercializacao__c = 'PMC', 
              Proposta__c = propNova4.Id,
              AccountId = contaTeste2.Id,
              StartDate = System.today(),
              VigenciaFinal__c = System.today().addDays(30),
              DataEmissao__c = System.today(),
              Endosso__c = endosso7,
              Sucursal__c = sucursal7,
              CodigoRamo__c = ramo7,
              PremioComercial__c = 15000.00,
              Parceiro__c = '67708896000139',
              CupomDesconto__c = cupom.codigo__c
      );
      insert contrato7;

      RemuneracaoContrato__c remuneracaoContrato4 = new RemuneracaoContrato__c(
            Contrato__c = contrato7.Id,
            TipoRemuneracao__c = tipoRemuneracao.Id
      );
      insert remuneracaoContrato4;
      remuneracaoContrato4.CurrencyIsoCode = 'BRL';
      remuneracaoContrato4.Percentual__c = 10;
      remuneracaoContrato4.Porcentagem_de_Retencao__c = 0;
      update remuneracaoContrato4;

      FavorecidoRemuneracaoContrato__c favRemCon7 = new FavorecidoRemuneracaoContrato__c();
      favRemCon7.Conta__c = contaTeste2.Id;
      favRemCon7.CorretorLider__c = true;
      favRemCon7.AntecipacaoComissao__c = true;
      favRemCon7.RemuneracaoContrato__c = remuneracaoContrato4.Id;
      favRemCon7.Papel__c = 'Corretor';
      favRemCon7.Susep__c = 'COL01J';
      insert favRemCon7;

      
      String origem = '18';
      String numeroProposta7 = '00012340';
      Quote propostaTesteRen4= new Quote(
        Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta7),
        NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta7),
        Produto__c = produtoCom.Id,
        RamoSeguro__c = ramoSegurado.Id,
        Status = 'Em criação',
        VigenciaInicial__c = System.today(),
        VigenciaFinal__c = System.today().addMonths(1),
        Empresa__c = contaTeste2.Id,
        CodigoCorretor__c = dadosCorretor6.Id,
        DataCalculo__c = System.today(),
        DataCriacaoPortal__c = System.today(),
        TipoVigencia__c = 'Anual',
        MeioComercializacao__c = 'PMC', 
        OpportunityId = orcamentoContratado5.Id,
        Origem__c = origem,
        Modalidade__c = modalidade.Id,
        NumeroProposta__c = numeroProposta7,
        Parceiro__c = '67708896000139',
        email__c = 'abcd@qualqueremail.com',
        CupomDesconto__c = 'VALE50DESCONTO'
      );
      insert propostaTesteRen4;
      propostaTesteRen4.Status = 'Em análise';
      propostaTesteRen4.Tipo__c = 'Renovacao';
      propostaTesteRen4.VigenciaInicial__c = System.today().addDays(10);
      propostaTesteRen4.PaisesDestino__c = 'Brasil';
      propostaTesteRen4.FaseStatus__c = 'Palavra final';
      propostaTesteRen4.ContratoRenovado__c = String.ValueOf(contrato7.Id);
      update propostaTesteRen4;

      RemuneracaoProposta__c remuneracaoProposta3 = new RemuneracaoProposta__c(
        TipoRemuneracao__c = tipoRemuneracao.Id,
        Proposta__c = propostaTesteRen4.Id,
        Percentual__c = 100
      );
      insert remuneracaoProposta3;
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta7 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'P5006J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta7;
      
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta6 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'COL01J',
        CorretorLider__c = true
      );
      insert favorecidoRemuneracaoProposta6;

      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta8 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'P5005J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta8;
      
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta9 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'COL10J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta9;
      
      TransferenciaCorretagem__c transfCorreInd4 = new TransferenciaCorretagem__c(
        SusepAtual__c = dadosCorretor7.id,
        ContratoTransferido__c = contrato7.id,
        PercSusepLider__c = 50,
        SusepOriginal__c = dadosCorretor6.id,
        ValidoAte__c = System.today(),
        TransferirCarteira__c = false,
        SusepPriCoCorretagem__c = dadosCorretor7.id,
        PercPriCoCorretor__c = 10,
        SusepSegCoCorretagem__c = dadosCorretor7.id,
        PercSegCoCorretor__c = 10,
        SusepTerCoCorretagem__c = dadosCorretor7.id,
        PercTerCoCorretor__c = 10,
        SusepQuaCoCorretagem__c = dadosCorretor7.id,
        PercQuaCoCorretor__c = 20
      );
      insert transfCorreInd4;

      BatchContrPropRenv batch = new BatchContrPropRenv();
      Boolean falhaEmAgendar = false;

      try{
          batch.liberarCriticaRenovacao();
      }catch(AsyncException a){
          System.debug('MENSAGEM: ' + A.getMessage());
          System.debug('CAUSA: ' + A.getCause());
          if(!a.getMessage().contains('agendado')){
              falhaEmAgendar = true;
          }
      }

      System.assertEquals(false, falhaEmAgendar);
      Test.stopTest();   
    }

    @isTest
    public static void testLiberarCriticaRenovacaoCenario7(){
      
      Test.startTest();
      Account contaTeste2 = new Account(
              Name = 'Conta 41',
              CodigoEmpresa__c = '14',
              IdExterno__c = '13143510000160',
              Papel__c = 'Parceiro',
              Sexo__c = 'Masc',
              Cpf__c = '76466318095',
              Pis__c = '123456789',
              Cnpj__c = '13.143.510/0001-60',
              Inscricao_Municipal__c = '123456789',
              Nacionalidade__c = 'Brasileira',
              EstadoCivil__c = 'Casado (a)',
              Email__c = 'teste@teste.com.br'
      );
      insert contaTeste2;

      DadosCorretor__c dadosCorretor2 = new DadosCorretor__c(
              Name            = 'P5005J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor2;
      
      DadosCorretor__c dadosCorretor3 = new DadosCorretor__c(
              Name            = 'COL10J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor3;

      DadosCorretor__c dadosCorretor4 = new DadosCorretor__c(
              Name            = 'REN01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor4;

      DadosCorretor__c dadosCorretor5 = new DadosCorretor__c(
              Name            = 'REN01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor5;

      

      TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
        Name = 'CORRETAGEM',
        Codigo__c = 'COR',
        LimiteMinimo__c = 5,
        LimiteMaximo__c = 100,
        ModeloRecuperacao__c = 'Integral'
      );
      insert tipoRemuneracao;

      Product2 produtoTec = new Product2(
              Name = 'Nome Produto Tecnico',
              Status__c = 'Em criação',
              ProductCode = '201700001',
              VigenciaInicial__c = System.today().addDays(3),
              TipoCapital__c = 'Capital uniforme',
              Segmento__c = 'Individual',
              TipoResponsavelPagamento__c = 'PAR',
              NumeroSusep__c = '12345',
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
              Versao__c                       = 1,
              VersaoMaxima__c                 = true,
              VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoTec;

      produtoTec.Status__c = 'Ativo';
      update produtoTec;
      
      Product2 produtoCom = new Product2(
          ProdutoTecnico__c               = produtoTec.Id,
          Name                            = 'Nome Produto Comercial',
          Status__c                       = 'Em criação',
          ProductCode                    = '201700001',   
          VigenciaInicial__c              = System.today(),
          VigenciaFinal__c                = System.today().addDays(1),
          TipoCapital__c                  = 'Capital uniforme',
          Segmento__c                     = 'Individual',
          TipoResponsavelPagamento__c     = 'PAR',
          LimiteTotalCarregamento__c      = 200,
          NumeroSusep__c                  = '12345',
          RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
          Versao__c                       = 1,
          VersaoMaxima__c                 = true,
          VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoCom;
             
      produtoCom.Status__c = 'Ativo';
      update produtoCom;

      RamoSeguro__c ramoSegurado = new RamoSeguro__c(
              Name = 'Segurado',
              CodigoEmpresa__c = '214',
              Codigo__c = '2',
              Empresa__c = contaTeste2.Id,
              Status__c = 'Ativo',
              CodigoOrigemDoMovimentoBCP__c = '32'
      );
      insert ramoSegurado;

      CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
      canalDistribuicao.Name = 'Canal Distribuição Teste 001';
      canalDistribuicao.Status__c = 'Em ativação';
      canalDistribuicao.Sigla__c = 'EXE';
      insert canalDistribuicao;

      // Recupera o JSON que está no recurso estático;
      String payloadName = 'PayloadOrcamento001';
      StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
      Blob payloadEntrada = sr.Body;

      Opportunity orcamentoContratado4 = new Opportunity(
              StageName = 'Em criação',
              CurrencyIsoCode = 'BRL',
              Name = 'ARQ-00002569',
              CloseDate = System.today().addDays(20),
              VigenciaInicial__c = System.today(),
              VigenciaFinal__c = System.today().addDays(1),
              Produto__c = produtoCom.Id,
              Probability = 10.0,
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
              AccountId = contaTeste2.Id,
              Numero__c = '00002569',
              CanalDistribuicao__c = canalDistribuicao.Id,
              Type = 'Novo',
              Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
      );
      insert orcamentoContratado4;


      Modalidade__c modalidade = new Modalidade__c(
              RamoSeguro__c = ramoSegurado.Id,
              Name = 'Mod teste',
              Codigo__c = '0'
      );
      insert modalidade;

      String origem = '18';
      String numeroProposta = '00001910';
      Cupom__c cupom = new Cupom__c(
          Codigo__c = 'VALE50DESCONTO',
          Limite_de_Utilizacao__c	= 400,
          Meio_de_Comercializacao__c=	'SFC',
          Percentual__c	 = 5,
          Vigencia_Inicial__c = System.today(),
          Vigencia_Final__c = System.today().addMonths(8)
      );
      insert cupom;

      String origem3 = '18';
      String numeroProposta3 = '00003930';
      Quote propNova3 = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem3,numeroProposta3),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem3,numeroProposta3),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em criação',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = contaTeste2.Id,
            CodigoCorretor__c = dadosCorretor5.Id,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', 
            OpportunityId = orcamentoContratado4.Id,
            Origem__c = origem3,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta3,
            Parceiro__c = '67708896000139',
            email__c = 'abcd@qualqueremail.com',
            CupomDesconto__c = 'VALE50DESCONTO'

      );
      insert propNova3;

      
      String empresa6 = '12';
      String sucursal6 = '999';
      String ramo6 = '2';
      String numeroApolice6 = '000000014689'; 
      String endosso6 = '0';

      Contract contrato6 = new Contract(
              Name = ContractBO.getInstance().gerarNameContrato(empresa6, sucursal6, ramo6, numeroApolice6, endosso6),
              Produto__c = produtoCom.Id,
              Oportunidade__c = orcamentoContratado4.Id,
              NumeroApolice__c = numeroApolice6,
              RamoSeguro__c = ramoSegurado.Id,
              Status = 'Em elaboração',
              Empresa__c = empresa6,
              CodigoCorretor__c = dadosCorretor5.Id,
              MeioComercializacao__c = 'PMC', 
              Proposta__c = propNova3.Id,
              AccountId = contaTeste2.Id,
              StartDate = System.today(),
              VigenciaFinal__c = System.today().addDays(30),
              DataEmissao__c = System.today(),
              Endosso__c = endosso6,
              Sucursal__c = sucursal6,
              CodigoRamo__c = ramo6,
              PremioComercial__c = 15000.00,
              Parceiro__c = '67708896000139',
              CupomDesconto__c = cupom.codigo__c
      );
      insert contrato6;

      RemuneracaoContrato__c remuneracaoContrato3 = new RemuneracaoContrato__c(
            Contrato__c = contrato6.Id,
            TipoRemuneracao__c = tipoRemuneracao.Id
      );
      insert remuneracaoContrato3;
      remuneracaoContrato3.CurrencyIsoCode = 'BRL';
      remuneracaoContrato3.Percentual__c = 10;
      remuneracaoContrato3.Porcentagem_de_Retencao__c = 0;
      update remuneracaoContrato3;

      FavorecidoRemuneracaoContrato__c favRemCon6 = new FavorecidoRemuneracaoContrato__c();
      favRemCon6.Conta__c = contaTeste2.Id;
      favRemCon6.CorretorLider__c = true;
      favRemCon6.AntecipacaoComissao__c = true;
      favRemCon6.RemuneracaoContrato__c = remuneracaoContrato3.Id;
      favRemCon6.Papel__c = 'Corretor';
      favRemCon6.Susep__c = 'REN01J';
      insert favRemCon6;

      String numeroProposta5 = '00002310';
      Quote propostaTesteRen3= new Quote(
        Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta5),
        NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta5),
        Produto__c = produtoCom.Id,
        RamoSeguro__c = ramoSegurado.Id,
        Status = 'Em criação',
        VigenciaInicial__c = System.today(),
        VigenciaFinal__c = System.today().addMonths(1),
        Empresa__c = contaTeste2.Id,
        CodigoCorretor__c = dadosCorretor5.Id,
        DataCalculo__c = System.today(),
        DataCriacaoPortal__c = System.today(),
        TipoVigencia__c = 'Anual',
        MeioComercializacao__c = 'PMC', 
        OpportunityId = orcamentoContratado4.Id,
        Origem__c = origem,
        Modalidade__c = modalidade.Id,
        NumeroProposta__c = numeroProposta5,
        Parceiro__c = '67708896000139',
        email__c = 'abcd@qualqueremail.com',
        CupomDesconto__c = 'VALE50DESCONTO'
      );
      insert propostaTesteRen3;
      propostaTesteRen3.Status = 'Em análise';
      propostaTesteRen3.Tipo__c = 'Renovacao';
      propostaTesteRen3.VigenciaInicial__c = System.today().addDays(10);
      propostaTesteRen3.PaisesDestino__c = 'Brasil';
      propostaTesteRen3.FaseStatus__c = 'Palavra final';
      propostaTesteRen3.ContratoRenovado__c = String.ValueOf(contrato6.Id);
      update propostaTesteRen3;

      
      RemuneracaoProposta__c remuneracaoProposta2 = new RemuneracaoProposta__c(
        TipoRemuneracao__c = tipoRemuneracao.Id,
        Proposta__c = propostaTesteRen3.Id,
        Percentual__c = 100
      );
      insert remuneracaoProposta2;

      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta5 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 100,
        RemuneracaoProposta__c = remuneracaoProposta2.Id,
        Susep__c = 'REN01J',
        CorretorLider__c = true
      );
      insert favorecidoRemuneracaoProposta5;

      TransferenciaCorretagem__c transfCorreInd6 = new TransferenciaCorretagem__c(
        SusepAtual__c = dadosCorretor3.id,
        ContratoTransferido__c = contrato6.id,
        PercSusepLider__c = 90,
        SusepOriginal__c = dadosCorretor5.id,
        ValidoAte__c = System.today(),
        TransferirCarteira__c = false,
        SusepPriCoCorretagem__c = dadosCorretor2.id,
        PercPriCoCorretor__c = 10
      );
      insert transfCorreInd6;

      TransferenciaCorretagem__c transfCorreCart3 = new TransferenciaCorretagem__c(
        SusepAtual__c = dadosCorretor4.id,
        PercSusepLider__c = 50,
        SusepOriginal__c = dadosCorretor5.id,
        ValidoAte__c = System.today(),
        TransferirCarteira__c = true,
        SusepPriCoCorretagem__c = dadosCorretor4.id,
        PercPriCoCorretor__c = 10,
        SusepSegCoCorretagem__c = dadosCorretor4.id,
        PercSegCoCorretor__c = 10,
        SusepTerCoCorretagem__c = dadosCorretor4.id,
        PercTerCoCorretor__c = 30
      );
      insert transfCorreCart3;
      
      BatchContrPropRenv batch = new BatchContrPropRenv();
      Boolean falhaEmAgendar = false;

      try{
          batch.liberarCriticaRenovacao();
      }catch(AsyncException a){
          System.debug('MENSAGEM: ' + A.getMessage());
          System.debug('CAUSA: ' + A.getCause());
          if(!a.getMessage().contains('agendado')){
              falhaEmAgendar = true;
          }
      }

      System.assertEquals(false, falhaEmAgendar);
      Test.stopTest();         
    }

    @isTest
    public static void testLiberarCriticaRenovacaoCenario8(){
      
      Test.startTest(); 
      Account contaTeste2 = new Account(
              Name = 'Conta 41',
              CodigoEmpresa__c = '14',
              IdExterno__c = '13143510000160',
              Papel__c = 'Parceiro',
              Sexo__c = 'Masc',
              Cpf__c = '76466318095',
              Pis__c = '123456789',
              Cnpj__c = '13.143.510/0001-60',
              Inscricao_Municipal__c = '123456789',
              Nacionalidade__c = 'Brasileira',
              EstadoCivil__c = 'Casado (a)',
              Email__c = 'teste@teste.com.br'
      );
      insert contaTeste2;

      TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
        Name = 'CORRETAGEM',
        Codigo__c = 'COR',
        LimiteMinimo__c = 5,
        LimiteMaximo__c = 100,
        ModeloRecuperacao__c = 'Integral'
      );
      insert tipoRemuneracao;

      DadosCorretor__c dadosCorretor6 = new DadosCorretor__c(
              Name            = 'COL01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor6;

      DadosCorretor__c dadosCorretor7 = new DadosCorretor__c(
              Name            = 'P5006J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor7;

      DadosCorretor__c dadosCorretor2 = new DadosCorretor__c(
              Name            = 'P5005J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor2;
      
      DadosCorretor__c dadosCorretor3 = new DadosCorretor__c(
              Name            = 'COL10J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor3;

      DadosCorretor__c dadosCorretor4 = new DadosCorretor__c(
              Name            = 'REN01J',
              NomeCorretor__c = contaTeste2.Id
      );
      insert dadosCorretor4;

      Product2 produtoTec = new Product2(
              Name = 'Nome Produto Tecnico',
              Status__c = 'Em criação',
              ProductCode = '201700001',
              VigenciaInicial__c = System.today().addDays(3),
              TipoCapital__c = 'Capital uniforme',
              Segmento__c = 'Individual',
              TipoResponsavelPagamento__c = 'PAR',
              NumeroSusep__c = '12345',
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
              Versao__c                       = 1,
              VersaoMaxima__c                 = true,
              VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoTec;

      produtoTec.Status__c = 'Ativo';
      update produtoTec;
      
      Product2 produtoCom = new Product2(
          ProdutoTecnico__c               = produtoTec.Id,
          Name                            = 'Nome Produto Comercial',
          Status__c                       = 'Em criação',
          ProductCode                    = '201700001',   
          VigenciaInicial__c              = System.today(),
          VigenciaFinal__c                = System.today().addDays(1),
          TipoCapital__c                  = 'Capital uniforme',
          Segmento__c                     = 'Individual',
          TipoResponsavelPagamento__c     = 'PAR',
          LimiteTotalCarregamento__c      = 200,
          NumeroSusep__c                  = '12345',
          RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
          Versao__c                       = 1,
          VersaoMaxima__c                 = true,
          VersaoRenovacao__c              = 'Versão atual'
      );
      insert produtoCom;
             
      produtoCom.Status__c = 'Ativo';
      update produtoCom;

      RamoSeguro__c ramoSegurado = new RamoSeguro__c(
              Name = 'Segurado',
              CodigoEmpresa__c = '214',
              Codigo__c = '2',
              Empresa__c = contaTeste2.Id,
              Status__c = 'Ativo',
              CodigoOrigemDoMovimentoBCP__c = '32'
      );
      insert ramoSegurado;

      CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
      canalDistribuicao.Name = 'Canal Distribuição Teste 001';
      canalDistribuicao.Status__c = 'Em ativação';
      canalDistribuicao.Sigla__c = 'EXE';
      insert canalDistribuicao;

      // Recupera o JSON que está no recurso estático;
      String payloadName = 'PayloadOrcamento001';
      StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
      Blob payloadEntrada = sr.Body;

      // OPORTUNIDADE DO TIPO Segurado DE GRUPO
      Opportunity orcamentoContratado5 = new Opportunity(
              StageName = 'Em criação',
              CurrencyIsoCode = 'BRL',
              Name = 'ARQ-00032519',
              CloseDate = System.today().addDays(20),
              VigenciaInicial__c = System.today(),
              VigenciaFinal__c = System.today().addDays(1),
              Produto__c = produtoCom.Id,
              Probability = 10.0,
              RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
              AccountId = contaTeste2.Id,
              Numero__c = '00002519',
              CanalDistribuicao__c = canalDistribuicao.Id,
              Type = 'Novo',
              Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
      );
      insert orcamentoContratado5;

      
      Modalidade__c modalidade = new Modalidade__c(
              RamoSeguro__c = ramoSegurado.Id,
              Name = 'Mod teste',
              Codigo__c = '0'
      );
      insert modalidade;

      
      Cupom__c cupom = new Cupom__c(
          Codigo__c = 'VALE50DESCONTO',
          Limite_de_Utilizacao__c	= 400,
          Meio_de_Comercializacao__c=	'SFC',
          Percentual__c	 = 5,
          Vigencia_Inicial__c = System.today(),
          Vigencia_Final__c = System.today().addMonths(8)
      );
      insert cupom;

      String origem4 = '18';
      String numeroProposta6 = '00024930';
      Quote propNova4 = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem4,numeroProposta6),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem4,numeroProposta6),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em criação',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = contaTeste2.Id,
            CodigoCorretor__c = dadosCorretor6.Id,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', 
            OpportunityId = orcamentoContratado5.Id,
            Origem__c = origem4,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta6,
            Parceiro__c = '67708896000139',
            email__c = 'abcd@qualqueremail.com',
            CupomDesconto__c = 'VALE50DESCONTO'

      );
      insert propNova4;

      String empresa7 = '13';
      String sucursal7 = '999';
      String ramo7 = '2';
      String numeroApolice7 = '000000117683'; 
      String endosso7 = '0';

      Contract contrato7 = new Contract(
              Name = ContractBO.getInstance().gerarNameContrato(empresa7, sucursal7, ramo7, numeroApolice7, endosso7),
              Produto__c = produtoCom.Id,
              Oportunidade__c = orcamentoContratado5.Id,
              NumeroApolice__c = numeroApolice7,
              RamoSeguro__c = ramoSegurado.Id,
              Status = 'Em elaboração',
              Empresa__c = empresa7,
              CodigoCorretor__c = dadosCorretor6.Id,
              MeioComercializacao__c = 'PMC', 
              Proposta__c = propNova4.Id,
              AccountId = contaTeste2.Id,
              StartDate = System.today(),
              VigenciaFinal__c = System.today().addDays(30),
              DataEmissao__c = System.today(),
              Endosso__c = endosso7,
              Sucursal__c = sucursal7,
              CodigoRamo__c = ramo7,
              PremioComercial__c = 15000.00,
              Parceiro__c = '67708896000139',
              CupomDesconto__c = cupom.codigo__c
      );
      insert contrato7;

      RemuneracaoContrato__c remuneracaoContrato4 = new RemuneracaoContrato__c(
            Contrato__c = contrato7.Id,
            TipoRemuneracao__c = tipoRemuneracao.Id
      );
      insert remuneracaoContrato4;
      remuneracaoContrato4.CurrencyIsoCode = 'BRL';
      remuneracaoContrato4.Percentual__c = 10;
      remuneracaoContrato4.Porcentagem_de_Retencao__c = 0;
      update remuneracaoContrato4;

      FavorecidoRemuneracaoContrato__c favRemCon7 = new FavorecidoRemuneracaoContrato__c();
      favRemCon7.Conta__c = contaTeste2.Id;
      favRemCon7.CorretorLider__c = true;
      favRemCon7.AntecipacaoComissao__c = true;
      favRemCon7.RemuneracaoContrato__c = remuneracaoContrato4.Id;
      favRemCon7.Papel__c = 'Corretor';
      favRemCon7.Susep__c = 'COL01J';
      insert favRemCon7;

      
      String origem = '18';
      String numeroProposta7 = '00012340';
      Quote propostaTesteRen4= new Quote(
        Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta7),
        NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta7),
        Produto__c = produtoCom.Id,
        RamoSeguro__c = ramoSegurado.Id,
        Status = 'Em criação',
        VigenciaInicial__c = System.today(),
        VigenciaFinal__c = System.today().addMonths(1),
        Empresa__c = contaTeste2.Id,
        CodigoCorretor__c = dadosCorretor6.Id,
        DataCalculo__c = System.today(),
        DataCriacaoPortal__c = System.today(),
        TipoVigencia__c = 'Anual',
        MeioComercializacao__c = 'PMC', 
        OpportunityId = orcamentoContratado5.Id,
        Origem__c = origem,
        Modalidade__c = modalidade.Id,
        NumeroProposta__c = numeroProposta7,
        Parceiro__c = '67708896000139',
        email__c = 'abcd@qualqueremail.com',
        CupomDesconto__c = 'VALE50DESCONTO'
      );
      insert propostaTesteRen4;
      propostaTesteRen4.Status = 'Em análise';
      propostaTesteRen4.Tipo__c = 'Renovacao';
      propostaTesteRen4.VigenciaInicial__c = System.today().addDays(10);
      propostaTesteRen4.PaisesDestino__c = 'Brasil';
      propostaTesteRen4.FaseStatus__c = 'Palavra final';
      propostaTesteRen4.ContratoRenovado__c = String.ValueOf(contrato7.Id);
      update propostaTesteRen4;

      RemuneracaoProposta__c remuneracaoProposta3 = new RemuneracaoProposta__c(
        TipoRemuneracao__c = tipoRemuneracao.Id,
        Proposta__c = propostaTesteRen4.Id,
        Percentual__c = 100
      );
      insert remuneracaoProposta3;
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta7 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'P5006J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta7;
      
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta6 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'COL01J',
        CorretorLider__c = true
      );
      insert favorecidoRemuneracaoProposta6;

      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta8 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'P5005J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta8;
      
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta9 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'COL10J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta9;

      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta10 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'REN01J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta10;
      
      //FNPVVEP-57 - INICIO  
      FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta11 = new FavorecidoRemuneracaoProposta__c(
        Conta__c = contaTeste2.Id,
        Papel__c = 'Corretor',
        Participacao__c = 20,
        RemuneracaoProposta__c = remuneracaoProposta3.Id,
        Susep__c = 'COL10J',
        CorretorLider__c = false
      );
      insert favorecidoRemuneracaoProposta11;
      //FNPVVEP-57 - FIM

      TransferenciaCorretagem__c transfCorreInd4 = new TransferenciaCorretagem__c(
        SusepAtual__c = dadosCorretor7.id,
        ContratoTransferido__c = contrato7.id,
        PercSusepLider__c = 50,
        SusepOriginal__c = dadosCorretor6.id,
        ValidoAte__c = System.today(),
        TransferirCarteira__c = false,
        SusepPriCoCorretagem__c = dadosCorretor7.id,
        PercPriCoCorretor__c = 10,
        SusepSegCoCorretagem__c = dadosCorretor7.id,
        PercSegCoCorretor__c = 10,
        SusepTerCoCorretagem__c = dadosCorretor7.id,
        PercTerCoCorretor__c = 10,
        SusepQuaCoCorretagem__c = dadosCorretor7.id,
        PercQuaCoCorretor__c = 10,
        SusepQuiCoCorretagem__c = dadosCorretor7.id,
        PercQuiCoCorretor__c = 10
      );
      insert transfCorreInd4;

      BatchContrPropRenv batch = new BatchContrPropRenv();
      Boolean falhaEmAgendar = false;

      try{
          batch.liberarCriticaRenovacao();
      }catch(AsyncException a){
          System.debug('MENSAGEM: ' + A.getMessage());
          System.debug('CAUSA: ' + A.getCause());
          if(!a.getMessage().contains('agendado')){
              falhaEmAgendar = true;
          }
      }

      System.assertEquals(false, falhaEmAgendar);
      Test.stopTest();   
    }

    // RVI-310 FIM
    //RVI-104 - FIX01 - FIM

    @isTest
        public static void testLiberarCriticaRenovacaoBatch(){
                
                Test.startTest(); 
                BatchContrPropRenv batch = new BatchContrPropRenv();
                Database.executeBatch(batch);     

                List<CriticaProposta__c> criticasLiberadas = [SELECT Id FROM CriticaProposta__c WHERE Codigo__c = '154'];      
                if (criticasLiberadas <> null) {
                System.assertEquals(1, criticasLiberadas.size());
                }
                Test.stopTest();
        }
    
    public static void gerarEndereco(Id accountId){
      Endereco__c endereco = new Endereco__c(
        Bairro__c = 'Bairro XYZ',
        CEP__c = '05572070',
        Cidade__c = 'São Paulo',
        Complemento__c = null,
        CurrencyIsoCode = 'BRL',
        EnderecoCobranca__c = false,
        Estado__c = 'AP',
        IdExterno__c = null,
        Logradouro__c = 'Rua XYZ',
        MaisAtual__c = false,
        Numero__c = '13',
        Pais__c = 'Brasil',
        TipoEndereco__c = 'Residencial',
        TipoLogradouro__c = null,
        Conta__c = accountId
      );

      insert endereco;
    }
    //RVI-297 FIM
}