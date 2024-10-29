/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelos testes no objeto Quote
 *
 **************************************************************************************************************************************************************************/

 @isTest
 private class QuoteTest {
    public static final QuoteBO bo = QuoteBO.getInstance();
    //II-167 INICIO
    @TestSetup
    static void setup(){
         //PLV-5436 - INCIO
         //TestDataFactory.gerarDadosSetup();
         //PLV-3744 - INICIO
         //TestDataFactory.Token();
         //PLV-3744 - FIM 
         // PLV-2312-28 INICIO
         //TestDataFactory.gerarContrato(true);
         // PLV-2312-28 FIM

        //PLV-5776- INICIO
        Account contaTeste = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
            FirstName = 'FRANCIS',
            LastName = 'LIU',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '518.179.180-87',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = (Date.today()-7300),
            EstadoCivil__c = 'Solteiro (a)'
        );
        insert contaTeste;

        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = new Product2(
            Name = 'Nome Produto Tecnico',
            Status__c = 'Em criação',
            ProductCode = '201700001',
            VigenciaInicial__c = System.today().addDays(3),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Coletivo',
            TipoResponsavelPagamento__c = 'PAR',
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c= 'Versão atual'
        );
        insert produtoTec;
        produtoTec.Status__c = 'Ativo';
        update produtoTec;

        Product2 produtoCom = new Product2(
            ProdutoTecnico__c = produtoTec.Id,
            Name = 'Nome Produto Comercial',
            Status__c = 'Em criação',
            ProductCode = '201700001',            	
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Coletivo',
            TipoResponsavelPagamento__c = 'PAR',
            LimiteTotalCarregamento__c = 200,
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c = 'Versão atual'
        );
        insert produtoCom; //II-106 INICIO-FIM

        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;

        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        
        String origem = '18';
        String numeroProposta = '00006767';

        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
                Produto__c = produtoCom.Id,
                RamoSeguro__c = ramoSegurado.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = contaTeste.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC', //PLV-4550 INICIO/FIM
                OpportunityId = orcamentoContratado.Id,
                Origem__c = origem,
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = numeroProposta,
                Parceiro__c = '67708896000139',
                CupomDesconto__c = 'VALE50DESCONTO' // AV-664 FIM

        );
        insert proposta;

        System.debug('proposta ==>' + JSON.serialize(proposta));

        //II-167 INICIO
        RemuneracaoProposta__c corretagem = new RemuneracaoProposta__c(
            Proposta__c = proposta.Id,
            Percentual__c = 10            
        );
        insert corretagem;

        RemuneracaoProposta__c agenciamento = new RemuneracaoProposta__c(
            Proposta__c = proposta.Id,
            Percentual__c = 100            
        );
        insert agenciamento;

        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c(
            Conta__c = contaTeste.Id,           
            CorretorLider__c = true,
            Papel__c = 'Corretor',
            Participacao__c = 10.00,
            RemuneracaoProposta__c = corretagem.Id,
            Susep__c = 'REN01J',
            SusepEmissao__c = 'REN01J',
            SusepOficialCorretor__c = '123',
            SusepOrcamento__c = 'REN01J',
            AntecipacaoComissao__c = true,
            DadosCorretor__c = dadosCorretor.Id
        );

        insert favorecidoRemuneracaoProposta;
        //II-167 FIM

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta);
		contrato.Status = 'Emitido';
        contrato.Origem__c = '18';
        contrato.NumeroProposta__c = '00043752';
        update contrato;    

        //II-167 INICIO
        // RemuneracaoContrato__c corretagemContrato = new RemuneracaoContrato__c(
        //     Contrato__c = contrato.Id,
        //     Percentual__c = 10            
        // );
        // insert corretagem;
        //RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        // RemuneracaoContrato__c agenciamentoContrato = new RemuneracaoContrato__c(
        //     Contrato__c = contrato.Id,
        //     Percentual__c = 100            
        // );
        // insert agenciamento;
        //II-167 FIM

        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaTeste, contaTeste);

        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c segurado = TestDataFactory.gerarSeguradoContrato(grupoContrato, contaTeste);

        Garantia__c garantia = TestDataFactory.gerarGarantia();

        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSegurado);

        GarantiaProduto__c garantiaTecnica = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoSegurado);
        GarantiaProduto__c garantiaComercial = TestDataFactory.gerarGarantiaProdutoComercial(produtoCom, garantia, garantiaTecnica, ramoSegurado);
        GarantiaContrato__c garantiaContrato = TestDataFactory.gerarGarantiaContrato(contrato, garantiaComercial);

        //PLV-5776- FIM

        //  List<ContadorCodigo__c> contadoresProduto = new List<ContadorCodigo__c>
        //  {
        //      new ContadorCodigo__c(Name='ProdutoTecnico', Numero__c = 0),
        //      new ContadorCodigo__c(Name='ProdutoComercial', Numero__c = 0)
        //  };
        //  insert contadoresProduto;
         
        //  QueueableQTD__c qtdRecordDetails = (QueueableQTD__c) new QueueableQTDFactory().createRecord();
        //  QueueableQTD__c qtdRecordSend = qtdRecordDetails.clone();
        //  qtdRecordSend.Name = 'QueueableContractDetails';
        //  qtdRecordSend.Quantidade__c = 20;
        //  insert qtdRecordSend;
         
        //Account contaTeste = TestDataFactory.gerarConta();
        //DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        //RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        //Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        //Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
         
         
        //  Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        //  produtoTec.Status__c = 'Em ativação';
        //  produtoTec.Segmento__c = 'Individual';
        //  update produtoTec;
         
        //  produtoTec.Status__c = 'Ativo';
        //  update produtoTec;
         
        //  Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        //  produtoCom.Status__c ='Em ativação';
        //  produtoCom.Segmento__c = 'Individual';
        //  update produtoCom;
         
        //  produtoCom.Status__c ='Ativo';
        //  update produtoCom;
 
         //CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        

        //RVI-247 - FIX01 - INICIO
        //Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        // RVI-247 - FIX01 - INICIO/FIM
        //Opportunity orcamentoRenovado = [SELECT Id FROM Opportunity]; 
        // RVI-186-FIX02 - INICIO
        // Opportunity orcamentoRenovado = new Opportunity(
        //     StageName = 'Em criação',
        //     CurrencyIsoCode = 'BRL',
        //     Name = 'ARQ-00006790',
        //     CloseDate = System.today().addDays(20),
        //     VigenciaInicial__c = System.today(),
        //     VigenciaFinal__c = System.today().addDays(1),
        //     Produto__c = produtoCom.Id,
        //     Probability = 10.0,
        //     RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
        //     AccountId = contaTeste.Id,
        //     Numero__c = '00006790',
        //     CanalDistribuicao__c = canalDistribuicao.Id
        // );
        // insert orcamentoRenovado;
        // RVI-186-FIX02 - FIM

        //TKCL-246 FIX05 INICIO
        //  Product2 produtoTecTelemak = TestDataFactory.gerarProdutoTecnico();
        //  produtoTecTelemak.Status__c = 'Ativo';
        //  produtoTecTelemak.Segmento__c = 'Individual';
        //  produtoTecTelemak.ProductCode = '49';
        //  update produtoTecTelemak;
         
        //  Product2 produtoComTelemak = TestDataFactory.gerarProdutoComericial(produtoTecTelemak);
        //  produtoComTelemak.Status__c ='ativo';
        //  produtoComTelemak.Segmento__c = 'Individual';
        //  produtoComTelemak.ProductCode = 'APTLMKT'; 
        //  produtoComTelemak.CodigoPrecificaProduto__c = 'APTLMKT';
        //  update produtoComTelemak;
        //TKCL-246 FIX05 FIM
         
        //  Quote proposta = new Quote(            
        //      Name = '18-00006767',
        //      NumeroPropostaUnico__c = '00006767',
        //      DependentesFinanceiros__c = false,
        //      OpportunityId = orcamentoContratado.id,
        //      CodigoCorretor__c = dadosCorretor.Id,
        //      VigenciaInicial__c = System.today(),
        //      VigenciaFinal__c = System.today().addMonths(1),
        //      Produto__c = produtoCom.Id,
        //      RamoSeguro__c = ramoSegurado.Id,            
        //      Modalidade__c = modalidade.Id,
        //      Status = 'Em análise'
        //  );
        //  insert proposta;
 
        //  CriticaProposta__c critica1 = new CriticaProposta__c(
        //      Proposta__c = proposta.Id,
        //      Status__c = 'Pendente',
        //      Codigo__c = '71'
        //  );
        //  insert critica1;
 
        //  CriticaProposta__c critica2 = new CriticaProposta__c(
        //      Proposta__c = proposta.Id,
        //      Status__c = 'Pendente',
        //      Codigo__c = '74'
        //  );
        //  insert critica2;
 
        //  CriticaProposta__c critica3 = new CriticaProposta__c(
        //      Proposta__c = proposta.Id,
        //      Status__c = 'Pendente',
        //      Codigo__c = '78'
        //  );
        //  insert critica3;
         
        //  CriticaProposta__c critica4 = new CriticaProposta__c(
        //      Proposta__c = proposta.Id,
        //      Status__c = 'Pendente',
        //      Codigo__c = '109'
        //  );
        //  insert critica4;
         
        //  SeguradoContrato__c segurado = new SeguradoContrato__c(
        //      Conta__c = contaTeste.Id
        //  );
        //  insert segurado;
 
        //  RemuneracaoProposta__c corretagem = new RemuneracaoProposta__c(
        //      Proposta__c = proposta.Id,
        //      Percentual__c = 10            
        //  );
        //  insert corretagem;
 
        //  RemuneracaoProposta__c agenciamento = new RemuneracaoProposta__c(
        //      Proposta__c = proposta.Id,
        //      Percentual__c = 100            
        //  );
        //  insert agenciamento;
 
        //  Endereco__c enderecoRes = new Endereco__c(
        //      TipoEndereco__c = 'Residencial', 
        //      CEP__c = '11420410', 
        //      Logradouro__c = 'AVENIDA RIO BRANCO',
        //      Numero__c = '1400',
        //      Complemento__c = 'teste',
        //      Bairro__c = 'teste', 
        //      Cidade__c = 'teste',
        //      Estado__c ='SP',
        //      Conta__c = contaTeste.Id
        //  );
        //  insert enderecoRes;
 
        //  Endereco__c enderecoCom = new Endereco__c(
        //      TipoEndereco__c = 'Comercial', 
        //      CEP__c = '11420410', 
        //      Logradouro__c = 'AVENIDA RIO BRANCO',
        //      Numero__c = '1400',
        //      Complemento__c = 'teste',
        //      Bairro__c = 'teste', 
        //      Cidade__c = 'teste',
        //      Estado__c ='SP',
        //      Conta__c = contaTeste.Id
        //  );
        //  insert enderecoCom;

        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();

        ContratanteProposta__c contratante = new ContratanteProposta__c(
            Proposta__c = proposta.id,
            FormaPagamento__c = formaPagamento.Id,
            ResponsavelPagamento__c = contaTeste.Id,
            QuantidadeParcelas__c = 2            
        );
        insert contratante;
 
         GrupoProposta__c grupo = new GrupoProposta__c(
             ContratanteProposta__c = contratante.id
         );
         insert grupo;
 
        //  FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
 
        CondicaoCobranca__c condicaoCobranca = new CondicaoCobranca__c(
                Produto__c = produtoCom.Id,
                FormaPagamento__c = formaPagamento.Id,
                QuantidadeParcelas__c = '1;2;3;4;5;6;7;8;9;10',            	
                PercentualDescontoAgravo__c = 0            	
        );
        insert condicaoCobranca;


        //  SeguradoProposta__c seguradoProposta = TestDataFactory.gerarSeguradoProposta(contaTeste, grupo, formaPagamento);

        SeguradoProposta__c SeguradoProposta = new SeguradoProposta__c(
            Conta__c = contaTeste.Id,
            GrupoProposta__c = grupo.Id,            
            ResponsavelPagamento__c = contaTeste.Id,
            FormaPagamento__c = formaPagamento.Id,
            PremioTotal__c = 10,
            Renda__c = 4000,
            Nome_do_segurado__c = contaTeste.Name,
            TemDependentes__c = true,
            RegimeTrabalho__c = 'CLT',
            FaixaRenda__c = '20000',
            EnderecoBoleto__c = 'http://www.google.com.br',
            PremioComercial__c = 10,
            IOF__c = 1,
            Numero__c = 1
        );
        insert SeguradoProposta;        
 
        //  ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoCom);
        //  paramVigencia.VigenciaMinimaRenovacao__c = 90;
        //  paramVigencia.Tipo__c = 'Periódico';
        //  update paramVigencia;
 
        //  Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta);
        //  contrato.Oportunidade__c = orcamentoContratado.Id;
        //  contrato.NumeroPropostaUnico__c = '18-00001910';
        //  contrato.NumeroApolice__c = '000014419';
        //  contrato.Tipo__c = 'Novo';   //RVI-160 - INICIO/FIM
        //  contrato.Status = 'Emitido'; //RVI-160 - INICIO/FIM
        //  contrato.Endosso__c = '0';
        //  contrato.VigenciaFinal__c = System.today().addDays(30);		       		    		    
        //  contrato.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        //  contrato.CodigoRamo__c = '1391';
        //  contrato.Proposta__c = proposta.Id;
        //  contrato.AlteraFormaPagto__c = false; // RVI-186 - FIX02 - INICIO/FIM
        //  update contrato;
 
        //RVI-189-INICIO
        //  ContentVersion content=new ContentVersion(); 
        //  content.Title='Header_Picture1_localStorage'; 
        //  content.PathOnClient='/' + content.Title + '.jpg'; 
        //  Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        //  content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        //  content.origin = 'H';
        //  insert content;
                 
        //  ContentDocumentLink contentlink=new ContentDocumentLink();
        //  contentlink.LinkedEntityId=contrato.id;
        //  contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        //  contentlink.ShareType = 'I';
        //  contentlink.Visibility = 'AllUsers'; 
        //  contentlink.LinkedEntityId = orcamentoContratado.id;
        //  insert contentlink;
        //RVI-189-FIM
 
        //RVI-186 - FIX02 - INICIO
        //RVI-160 - INICIO
        //  Contract contratoRenovado = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta);
        //  contratoRenovado.Oportunidade__c = orcamentoRenovado.Id;
        //  contratoRenovado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';
        //  contratoRenovado.ContratoRenovado__c = contrato.Id;		
        //  contratoRenovado.NumeroPropostaUnico__c = '18-00001911';
        //  contratoRenovado.NumeroApolice__c = '000014419';
        //  contratoRenovado.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
        //  contratoRenovado.Status = 'Emitido';    //RVI-160 - INICIO/FIM
        //  contratoRenovado.Endosso__c = '1';
        //  contratoRenovado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        //  contratoRenovado.StatusRenovacao__c = 'Renovado'; //RVI-160 - INICIO/FIM
        //  contratoRenovado.CodigoRamo__c = '1391';
        //  contratoRenovado.Proposta__c = proposta.Id;
        //  update contratoRenovado;        
        //RVI-160 - FIM

        //  Contract contratoRenovado = new Contract();
        //  contratoRenovado.Oportunidade__c = orcamentoRenovado.Id;
        //  contratoRenovado.Produto__c = produtoCom.Id;
        //  contratoRenovado.RamoSeguro__c = ramoSegurado.Id;
        //  contratoRenovado.Status = 'Em elaboração' ;
        //  contratoRenovado.Empresa__c = '22';
        //  contratoRenovado.CodigoCorretor__c = dadosCorretor.Id;
        //  contratoRenovado.Proposta__c = proposta.Id;
        //  contratoRenovado.AccountId = contaTeste.Id;
        //  contratoRenovado.AlteraFormaPagto__c = false;
        //  contratoRenovado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
        //  contratoRenovado.PrimeiroContratoRenovacao__c = contrato.Id;		
        //  contratoRenovado.NumeroPropostaUnico__c = '18-00001912';
        //  contratoRenovado.NumeroApolice__c = '000014420';
        //  contratoRenovado.Tipo__c = 'Renovacao'; 
        //  contratoRenovado.Endosso__c = '1';
        //  contratoRenovado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        //  contratoRenovado.StatusRenovacao__c = 'Não Renovado'; 
        //  contratoRenovado.CodigoRamo__c = '1391';   
        //  contratoRenovado.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';  
        //  insert contratoRenovado;
        // RVI-186 - FIX02 - FIM
 
        //  Parceiro__c parceiro = new Parceiro__c(
        //      ApoliceFaturamento__c = '1',
        //      DiaFaturamento__c = '15',
        //      DiaPreFaturamento__c = '20',
        //      PrazoVencimento__c = '10',
        //      Conta__c = contaTeste.Id,
        //      FaturaProdutosSeparados__c = 'Sim',
        //      PossuiAnexoFatura__c = 'Nao',
        //      FormaPagamento__c = formaPagamento.Id,
        //      SiglaParceiro__c = 'PAR',
        //      Empresa__c = '12',
        //      Sucursal__c = '12',
        //      Ramo__c = '12'
        //  );
        //  insert parceiro;
 
        //PLV-5436 - FIM
    }
    //II-167 FIM


     @isTest
     private static void testAlterarStatusOrcamentoPropostaContrato(){


        List<Contract> listContrato = [SELECT Id, 
                                              Tipo__c, 
                                              Status, 
                                              DataEmissao__c, 
                                              Name, 
                                              IdExterno__c,
                                              SiglaTipoEndosso__c, //PLV-5776-INICIO-FIM-FIX02
                                              Endosso__c,
                                              Empresa__c, 
                                              Sucursal__c,
                                              NumeroApolice__c, 
                                              NumeroProposta__c, 
                                              RamoSeguro__r.Codigo__c, 
                                              Proposta__r.PremioTotal__c, 
                                              Proposta__r.Opportunity.Id, 
                                              Proposta__c 
                                        FROM Contract];
        

        List<ContratanteContrato__c> listContratanteContrato = new List<ContratanteContrato__c>();

        List<ContratanteProposta__c> listContratantesProposta = new List<ContratanteProposta__c>();

        Map<String, String> mapNumeroApolicePorProposta = (Map<String, String>) JSON.deserialize('{"00006767": "000000560"}', Map<String, String>.class);
        
        Test.startTest();
            QuoteBO.alterarStatusOrcamentoPropostaContrato(listContrato, listContratanteContrato, listContratantesProposta, mapNumeroApolicePorProposta, true);
        Test.stopTest();

     }

     @isTest
     private static void testAlterarStatusOrcamentoPropostaContratoNumeroApoliceNull(){


        List<Contract> listContrato = [SELECT Id, 
                                              Tipo__c, 
                                              Status, 
                                              DataEmissao__c, 
                                              Name, 
                                              IdExterno__c,
                                              SiglaTipoEndosso__c, //PLV-5776-INICIO-FIM-FIX02
                                              Endosso__c,
                                              Empresa__c, 
                                              Sucursal__c,
                                              NumeroApolice__c, 
                                              NumeroProposta__c, 
                                              RamoSeguro__r.Codigo__c, 
                                              Proposta__r.PremioTotal__c, 
                                              Proposta__r.Opportunity.Id, 
                                              Proposta__c 
                                        FROM Contract];

        for(Contract contrato : listContrato){
            contrato.NumeroApolice__c = '';
        }

        List<ContratanteContrato__c> listContratanteContrato = new List<ContratanteContrato__c>();

        List<ContratanteProposta__c> listContratantesProposta = new List<ContratanteProposta__c>();

        Map<String, String> mapNumeroApolicePorProposta = (Map<String, String>) JSON.deserialize('{"00006767": "000000560"}', Map<String, String>.class);
        
        Test.startTest();
            QuoteBO.alterarStatusOrcamentoPropostaContrato(listContrato, listContratanteContrato, listContratantesProposta, mapNumeroApolicePorProposta, true);
        Test.stopTest();


     }
    //  //II-25 - INICIO
    //  @isTest static void teste(){
    //     String payload = '{"vigenciaInicial":"2023-07-05","vigenciaFinal": "2024-07-04","versoesCalculos": [{ "tipo": "FPG", "opcao": 2, "descontoAgravo": -10.0 }],"tipoSeguro": "Novo","tarifa": "5/07/2023","sucursal": "1","segurados": [{  "telefones": [{ "tipoTelefone": "Celular", "numeroTelefone": "(11) 98115-1615" }  ],  "rendaMensal": "2222.00",  "pessoaExpostaPoliticamente": "Não",  "nome": "CLIENTE TESTE AAEFCF",  "enderecos": [{"uf": "PE","tipoEndereco": "Residencial","paisResidencia": "","numeroLogradouro": "","logradouro": "DIONISIO DE DEUS LIMA","complementoCep": "","complemento": "","cidade": "Araripina","cep": "56280-000","bairro": "Centro"}  ],  "dadosPessoaFisica": {"sexo": "MASC","resideBrasil": false,"profissao": "2111-05","paisResidente": "","nacionalidade": "","estadoCivil": "","dataNascimento": "1988-01-01"  },  "beneficiarios": [{"tipoBeneficiario": "Herdeiros legais, conforme artigo 792 do código civil."}  ]}],"retornosCalculoOriginal": [{  "tarifa": "5/07/2023",  "precificacao": {"premio": {"total": 246.36,"puroCarregado": 245.43,"puro": 47.94,"descontoAgravo": [  { "tipo": "TEC", "percentual": 0.0, "monetario": 0.0 },  { "tipo": "FPG", "percentual": 0.0, "monetario": 0.0 }],"comercial": 245.43},"coberturas": [{  "taxa": {"total": 0.00711906542307,"pura": 0.001941,"comercial": 0.00709211538461  },  "sigla": "AFI",  "premio": {"total": 35.6,"puro": 9.7,"integral": 0.0,"comercial": 35.46  },  "iof": 0.13,  "descontoAgravo": [{ "tipo": "FPG", "percentual": -5.0, "monetario": -1.87 },{ "tipo": "BAT", "percentual": 0.0, "monetario": 0.0 },{ "tipo": "TEC", "percentual": 0.0, "monetario": 0.0 }  ]},{  "taxa": { "total": 0.0, "pura": 0.0, "comercial": 0.0 },  "sigla": "CKUP",  "premio": {"total": 82.39,"puro": 3.24,"integral": 0.0,"comercial": 82.08  },  "iof": 0.31,  "descontoAgravo": [{ "tipo": "FPG", "percentual": -5.0, "monetario": -4.32 },{ "tipo": "BAT", "percentual": 0.0, "monetario": 0.0 },{ "tipo": "TEC", "percentual": 0.0, "monetario": 0.0 }  ]},{  "taxa": {"total": 0.00073354615384,"pura": 0.0002,"comercial": 0.00073076923076  },  "sigla": "IPA",  "premio": {"total": 36.68,"puro": 10.0,"integral": 0.0,"comercial": 36.54  },  "iof": 0.14,  "descontoAgravo": [{ "tipo": "FPG", "percentual": -5.0, "monetario": -1.92 },{ "tipo": "BAT", "percentual": 0.0, "monetario": 0.0 },{ "tipo": "TEC", "percentual": 0.0, "monetario": 0.0 }  ]},{  "taxa": {"total": 0.00183386538461,"pura": 0.0005,"comercial": 0.00182692307692  },  "sigla": "MAP",  "premio": {"total": 91.69,"puro": 25.0,"integral": 0.0,"comercial": 91.35  },  "iof": 0.35,  "descontoAgravo": [{ "tipo": "FPG", "percentual": -5.0, "monetario": -4.81 },{ "tipo": "BAT", "percentual": 0.0, "monetario": 0.0 },{ "tipo": "TEC", "percentual": 0.0, "monetario": 0.0 }  ]},{  "taxa": { "total": 0, "pura": 0, "comercial": 0 },  "sigla": "TELEMED",  "premio": {"total": 0.0,"puro": 0.0,"integral": 0.0,"comercial": 0.0  },  "iof": 0.0,  "descontoAgravo": [{ "tipo": "FPG", "percentual": 0.0, "monetario": 0.0 },{ "tipo": "BAT", "percentual": 0.0, "monetario": 0.0 },{ "tipo": "TEC", "percentual": 0.0, "monetario": 0.0 }  ]}]  },  "dlls": [null]}],"remuneracoes": [{ "tipoRemuneracao": "COR", "percentual": 40.0 },{ "tipoRemuneracao": "AGE", "percentual": 0.0 }],"ramo": "1381","qtdDiasVigencia": 366,"precificacao": {"premio": {  "total": 246.36,  "puro": 47.94,  "premioPago": 0.0,  "integral": 0.0,  "comercial": 245.43},"descontoAgravo": [  { "tipo": "TEC", "percentual": 0.0, "monetario": 0.0 }],"coberturas": [  {"sigla": "AFI","descontoAgravo": [{ "tipo": "TEC", "percentual": 0.0, "monetario": 0.0 }]  }]},"numeroOrcamento": 110718,"endosso": "0","empresa": "1","dataCalculo": "2023-07-05","dadosPagamento": {"vencimentoPrimeiraParcela": "2023-07-16","vencimentoDemaisParcelas": "A cada 30 dias","tipoResponsavelPagamento": "CON","responsavelFinanceiro": true,"quantidadeParcelas": 4,"idPlanoParcelamento": "a14L0000003lsCuIAI","formaPagamento": {  "planoParcelamento": {"quantidadeParcelas": 4,"idPlanoParcelamento": "1"  },  "idFormaPagamento": "a0aL0000007ApFBIA0",  "descricao": "",  "codigo": "41"},"descricao": "FRAC.1.A PARCELA CARNE","codigoMeioRecebimento": "O","codigoFormaPagamento": 41,"codigo": "41"},"coberturas": [{ "valor": 5000.0, "unidade": "", "sigla": "AFI", "quantidade": 0.0 }],"apolice": "000003924"}';
    //     PayloadNovIntTO.ContratoOriginalTO contrato = (PayloadNovIntTO.ContratoOriginalTO) JSON.deserialize(payload, PayloadNovIntTO.ContratoOriginalTO.class);
    //     System.debug('Contrato Nova Integração: ' + JSON.serializePretty(payload));
    //  }
     //II-25 - FIM
 
     //PLV-4612 INICIO

    //II-167 INICIO
    @isTest
    static void gerarRemuneracoesContratoTest() {
        Contract contrato = [SELECT Id FROM Contract LIMIT 1];
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        
        List<RemuneracaoProposta__c> listRemuneracaoProposta = [SELECT Id, RemuneracaoProduto__c, TipoRemuneracao__c, Porcentagem_de_Retencao__c, BonusCampanha__c, Percentual__c FROM RemuneracaoProposta__c];
        
        List<RemuneracaoContrato__c> listRemuneracaoContrato = [SELECT Id, RemuneracaoProduto__c, TipoRemuneracao__c, Porcentagem_de_Retencao__c, BonusCampanha__c, Percentual__c FROM RemuneracaoContrato__c];
        Map<Id, RemuneracaoContrato__c> mapRemuneracaoContratoPorRemuneracaoPropostaId = new Map<Id, RemuneracaoContrato__c>();
        Test.startTest();
        listRemuneracaoContrato = QuoteBO.gerarRemuneracoesContrato(contrato, listRemuneracaoProposta, listRemuneracaoContrato, mapRemuneracaoContratoPorRemuneracaoPropostaId);
        Test.stopTest();
    }
    
    @isTest
    static void gerarSeguradoContratoTest() {
        GrupoContrato__c grupo = [SELECT Id FROM GrupoContrato__c];
        Map<Id, GrupoContrato__c> mapGrupoContrato = new Map<Id, GrupoContrato__c>();
        SeguradoProposta__c seguradoProposta = [SELECT BairroComercial__c, bairroResidencial__c, CargoPEP__c, CartaoCredito__c, Celular__c, CEPComercial__c, cepResidencial__c, CicloVacinal__c, CidadeComercial__c, CidadeResidencial__c, ComplementoComercial__c, ComplementoResidencial__c, Conta__c, CpfPessoaRelacionamentoProximo__c, CpfResponsavel__c, DataAtualizacaoPEP__c, DescontoAgravoMonetarioComercial__c, DescontoAgravoMonetarioFormaPagto__c, DescontoAgravoMonetarioInformado__c, DescontoAgravoMonetarioParcelamento__c, DescontoAgravoMonetarioTecnico__c, DescontoAgravoPercentualComercial__c, DescontoAgravoPercentualFormaPagto__c, DescontoAgravoPercentualInformado__c, DescontoAgravoPercentualParcelamento__c, DescontoAgravoPercentualTecnico__c, Email__c, EmailResponsavel__c, EmpresaTrabalhaSocio__c, Endereco_comercial__c, Endereco_de_recado__c, Endereco_residencial__c, Endereco_veraneio__c, EnderecoBoleto__c, FaixaRenda__c, FormaPagamento__c, Fumante__c, GrauParentesco__c, GrupoProposta__c, GrupoRisco__c, Id, InformacaoBancaria__c, IntegracaoPEP__c, IOF__c, IPCA__c, LogradouroComercial__c, logradouroResidencial__c, Melhor_periodo_para_contato__c, Nome_Da_Empresa__c, Nome_do_segurado__c, NomeContatoEmergencia__c, NomePessoaRelacionamentoProximo__c, NomeResponsavel__c, Numero__c, numeroCnpj__c, NumeroComercial__c, numeroResidencial__c, Pais_Residente__c, PaisComercial__c, PaisDeOrigem__c, paisResidencial__c, PEP__c, PlanoParcelamento__c, PorcentagemParticipacaoSegurado__c, PorcentagemParticipacaoVida__c, PremioComercial__c, PremioIntegral__c, PremioParcela__c, PremioPuro__c, PremioTotal__c, Profissao__c, qtdFuncionarios__c, QuantidadeParcelas__c, Ramo_de_atividade__c, RamoAtividade__c, Reenquadramento__c, RegimeTrabalho__c, Renda__c, Reside_no_Brasil__c, ResponsavelFinanceiroSeguro__c, ResponsavelPagamento__c, SystemModstamp, TaxaComercial__c, TaxaPura__c, TaxaTotal__c, Telefone_comercial__c, Telefone_residencial__c, TelefoneContatoEmergencia__c, TemDependentes__c, TipoCusteio__c, TipoDescontoAgravo__c, tipoEmpresa__c, TipoPessoaRelacionamentoProximo__c, TipoResponsavelPagamento__c, UFComercial__c, UFResidencial__c, UltimaConsultaPEP__c, VencimentoPrimeiraParcela__c, VigenciaFinal__c, VigenciaInicial__c, VinculoComSegurado__c, NomeSocial_do_Segurado__c FROM SeguradoProposta__c]; // LECVPV-184 INICIO/FIM
        mapGrupoContrato.put(seguradoProposta.GrupoProposta__c, grupo);
        SeguradoContrato__c seguradoContrato = new SeguradoContrato__c();
        Test.startTest();
        seguradoContrato.GrupoContrato__c = mapGrupoContrato.get(seguradoProposta.GrupoProposta__c).Id;
        seguradoContrato = QuoteBO.gerarSeguradoContrato(mapGrupoContrato, seguradoProposta);
        Test.stopTest();
    }

    @isTest
    static void gerarHierarquiaGruposContratoTest() {
        Contract contrato = [SELECT Id FROM Contract LIMIT 1];
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        GrupoContrato__c grupo = [SELECT Id FROM GrupoContrato__c];
        ContratanteContrato__c contratante = [SELECT Id FROM ContratanteContrato__c];
        Map<Id, GrupoContrato__c> mapGrupoContrato = new Map<Id, GrupoContrato__c>();
        Map<Id, ContratanteContrato__c> mapContratanteContrato = new Map<Id, ContratanteContrato__c>();
        GrupoProposta__c grupoProposta = [SELECT Id, ContratanteProposta__c FROM GrupoProposta__c LIMIT 1];
        mapContratanteContrato.put(grupoProposta.ContratanteProposta__c, contratante);
        Test.startTest();
        Map<Id, GrupoContrato__c> hierarquiaGruposContrato = QuoteBO.gerarHierarquiaGruposContrato(proposta, mapContratanteContrato, mapGrupoContrato);
        Test.stopTest();
    }

    @isTest
    static void gerarFavorecidosRemuneracaoContratoTest() {
        Contract contrato = [SELECT Id FROM Contract LIMIT 1];
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        
        List<RemuneracaoProposta__c> listRemuneracaoProposta = [SELECT Id, RemuneracaoProduto__c, TipoRemuneracao__c, Porcentagem_de_Retencao__c, BonusCampanha__c, Percentual__c FROM RemuneracaoProposta__c];
        List<RemuneracaoContrato__c> listRemuneracaoContrato = [SELECT Id, RemuneracaoProduto__c, TipoRemuneracao__c, Porcentagem_de_Retencao__c, BonusCampanha__c, Percentual__c FROM RemuneracaoContrato__c];
        
        List<FavorecidoRemuneracaoContrato__c> listFavorecidosContrato = new List<FavorecidoRemuneracaoContrato__c>();
        Map<Id, RemuneracaoContrato__c> mapRemsContrato = new Map<Id, RemuneracaoContrato__c>();
        Test.startTest();
        listFavorecidosContrato = QuoteBO.gerarFavorecidosRemuneracaoContrato(listRemuneracaoProposta, listFavorecidosContrato, mapRemsContrato);
        Test.stopTest();
    }

    @isTest
    static void processarPropostaParaContratoTest() {
        List<Quote> proposta = [SELECT Id, NumeroProposta__c, Name, Status FROM Quote LIMIT 1];
        proposta[0].Status = 'Disponível para contratação';
        update proposta;
        QuoteBO quoteBOInstance = new QuoteBO();
        Test.startTest();
        List<Contract> listContrato = quoteBOInstance.processarPropostaParaContrato(proposta);
        Test.stopTest();
    }

    @IsTest
    static void testobterProposta(){

        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
        Test.startTest();
        QuoteBO.getInstance().obterProposta(proposta.Name);
        Test.stopTest();
    }
 
    @IsTest
    static void testbuscarListVidaProposta(){
    
        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
        Test.startTest();
        QuoteBO.getInstance().buscarListVidaProposta(proposta.Id);
        Test.stopTest();
    }
 
    @IsTest
    static void testbuscarPerguntasQuestionario(){

        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
        Test.startTest();
        QuoteBO.getInstance().buscarPerguntasQuestionario(proposta.Id);
        Test.stopTest();
    }

    @isTest
    static void testChamarCIVEmissao() {
        Contract contrato = [SELECT Id FROM Contract LIMIT 1];
        Set<Id> setContratoId = new Set<Id>();
        setContratoId.add(contrato.Id);
        
        Map<String, String> mapPropostaApolice = new Map<String, String>();
        QuoteBO quoteBOInstance = new QuoteBO();
        Test.startTest();
        quoteBOInstance.chamarCIVEmissao(setContratoId, mapPropostaApolice);
        quoteBOInstance.chamarCIVReenvio(setContratoId, mapPropostaApolice);
        Test.stopTest();
    }
    //II-167 FIM

     // II-25 INICIO
     @isTest
     static void testCheckTipoEndosso() {
         
         EmissaoTO.PayloadTO             payload             = new EmissaoTO.PayloadTO();
         EmissaoTO                       proposta            = new EmissaoTO();
         EmissaoTO                       contratoOriginal    = new EmissaoTO();
         EmissaoTO.RemuneracaoTO         remuneracao         = new EmissaoTO.RemuneracaoTO();
         EmissaoTO.ContratanteTO         contratante         = new EmissaoTO.ContratanteTO();
         EmissaoTO.DadosPagamentoTO      dadosPagamento      = new EmissaoTO.DadosPagamentoTO();
         EmissaoTO.GrupoTO               grupo               = new EmissaoTO.GrupoTO();
         EmissaoTO.SeguradoTO            segurados           = new EmissaoTO.SeguradoTO();
         EmissaoTO.BeneficiarioTO        beneficiario        = new EmissaoTO.BeneficiarioTO();
         EmissaoTO.CoberturaTO           cobertura1          = new EmissaoTO.CoberturaTO();
         EmissaoTO.CoberturaTO           cobertura2          = new EmissaoTO.CoberturaTO();
         EmissaoTO.PessoaTO              pessoa              = new EmissaoTO.PessoaTO();
         EmissaoTO.DadosPessoaFisicaTO   dadosPessoaFisica   = new EmissaoTO.DadosPessoaFisicaTO();
         EmissaoTO.TelefoneTO            telefones1          = new EmissaoTO.TelefoneTO();
         EmissaoTO.TelefoneTO            telefones2          = new EmissaoTO.TelefoneTO();
         EmissaoTO.TelefoneTO            telefones3          = new EmissaoTO.TelefoneTO();
         EmissaoTO.EnderecoTO            enderecos1          = new EmissaoTO.EnderecoTO();
         EmissaoTO.EnderecoTO            enderecos2          = new EmissaoTO.EnderecoTO();
 
         //dadosPessoaFisica
         dadosPessoaFisica.digitoCpf         = '87';
         dadosPessoaFisica.numeroCpf         = '518179180';
 
         //telefones
         telefones1.tipoTelefone             = 'RES';
         telefones1.numeroTelefone           = '99999999';
         telefones1.dddTelefone              = '12';
 
         telefones2.tipoTelefone             = 'CEL';
         telefones2.numeroTelefone           = '99999999';
         telefones2.dddTelefone              = '12';
 
         telefones3.tipoTelefone             = 'PES';
         telefones3.numeroTelefone           = '333333333';
         telefones3.dddTelefone              = '33';
 
         List<EmissaoTO.TelefoneTO> lsTelefones = new List<EmissaoTO.TelefoneTO>();
         lsTelefones.add(telefones1);
         lsTelefones.add(telefones2);
         lsTelefones.add(telefones3);
 
         //enderecos
         enderecos1.tipoEndereco             = 'RESIDENCIAL';
         enderecos1.uf                       = 'SP';
 
         enderecos2.tipoEndereco             = 'COMERCIAL';
         enderecos2.uf                       = 'SP';
 
         List<EmissaoTO.EnderecoTO> lsEnderecos = new List<EmissaoTO.EnderecoTO>();
         lsEnderecos.add(enderecos1);
         lsEnderecos.add(enderecos2);
 
         pessoa.dadosPessoaFisica            = dadosPessoaFisica;
         pessoa.telefones                    = lsTelefones;
         pessoa.enderecos                    = lsEnderecos;
         segurados.pessoa                    = pessoa;
 
         //coberturas
         cobertura1.sigla                    = 'DG10';
         cobertura1.valor                    = 100;
 
         cobertura2.sigla                    = 'DIH';
         cobertura2.valor                    = 100;
 
         List<EmissaoTO.CoberturaTO> lsCobertura = new List<EmissaoTO.CoberturaTO>();
         lsCobertura.add(cobertura1);
         lsCobertura.add(cobertura2);
 
         segurados.coberturas                = lsCobertura;
 
         //beneficiario
         beneficiario.nome = 'Ademir';
 
         List<EmissaoTO.BeneficiarioTO> lsBeneficiario = new List<EmissaoTO.BeneficiarioTO>();
         lsBeneficiario.add(beneficiario);
 
         segurados.beneficiarios             = lsBeneficiario;
 
         List<EmissaoTO.SeguradoTO> lsSegurados = new List<EmissaoTO.SeguradoTO>();
         lsSegurados.add(segurados);
 
         grupo.segurados                     = lsSegurados;
         
         List<EmissaoTO.GrupoTO> lsGrupo = new List<EmissaoTO.GrupoTO>();
         lsGrupo.add(grupo);
 
         contratante.grupos                  = lsGrupo;
 
         //dadoPagamento
         dadosPagamento.quantidadeParcelas   = 1;
         dadosPagamento.codigoFormaPagamento = 11;
         
         contratante.dadosPagamento          = dadosPagamento;
 
         List<EmissaoTO.ContratanteTO> lsContratante = new List<EmissaoTO.ContratanteTO>();
         lsContratante.add(contratante);
 
         contratoOriginal.contratantes       = lsContratante;
         proposta.contratantes               = lsContratante;
         
         //remuneracao
         remuneracao.tipoRemuneracao         = 'COR';
         remuneracao.percentual              = 25;
 
         List<EmissaoTO.RemuneracaoTO> lsRemuneracao = new List<EmissaoTO.RemuneracaoTO>();
         lsRemuneracao.add(remuneracao);
 
         contratoOriginal.remuneracoes       = lsRemuneracao;
         proposta.remuneracoes               = lsRemuneracao;
         proposta.contratoOriginal           = contratoOriginal;
         payload.proposta                    = proposta;
         
         test.startTest();
         
         QuoteBO.getInstance().checkTipoEndosso(payload);
 
         // II-25 INICIO
         contratoOriginal.contratantes = null;
         contratoOriginal.segurados = lsSegurados;
         segurados.dadosPessoaFisica = dadosPessoaFisica;
         segurados.telefones = lsTelefones;
         segurados.enderecos = lsEnderecos;
         contratoOriginal.coberturas = lsCobertura;
         contratoOriginal.dadosPagamento = dadosPagamento;
         QuoteBO.getInstance().checkTipoEndosso(payload);
         // II-25 FIM

         //PLV-5098 - FIX01 - INICIO
         proposta.segmento = 'Viagem';
         contratoOriginal.contratantes = lsContratante; // II-25 INICIO/FIM
         QuoteBO.getInstance().checkTipoEndosso(payload);
         //PLV-5098 - FIX01 - FIM

         
         test.stopTest();
 
     }
     // II-25 FIM

    // II-104 INICIO
    @IsTest
    static void testCallGerarPDFProposta() {

        Boolean bypass = false;
        List<Quote> listPropostas = [SELECT id, Produto__c, Status, GerarPDF__c FROM Quote LIMIT 1];
        Map<Id, Quote> mapOldPropostas = new Map<Id, Quote>();

        for (Quote proposta : listPropostas) {
            mapOldPropostas.put(proposta.Id, proposta);
        }

        listPropostas[0].Status = 'Contratada';
        update listPropostas;      

        Test.startTest();
        QuoteBO.callGerarPDFProposta(listPropostas, mapOldPropostas, bypass);
        Test.stopTest();
    }
    // II-104 FIM

    // II-106 INICIO
    @IsTest
    static void sendEmailPropostaRecusadaRenovacaoTest() {


        List<Quote> listPropostas = [SELECT id, Status, Produto__c FROM Quote LIMIT 1];
        Map<Id, Quote> mapOldPropostas = new Map<Id, Quote>();
        Set<Id> setIdProduto = new Set<Id>(); 
        List<Product2> lstProduct = new List<Product2>();

        for (Quote proposta : listPropostas) {
            mapOldPropostas.put(proposta.Id, proposta);
            setIdProduto.add(proposta.Produto__c);
        }

        listPropostas[0].Status = 'Recusada';
        listPropostas[0].CodigoMotivoDevolucao__c = '10';
        listPropostas[0].email__c = 'email@teste.com';
        listPropostas[0].Tipo__c = 'Renovacao';
        update listPropostas;

        lstProduct = [SELECT id, Segmento__c FROM Product2 WHERE id IN :setIdProduto];
        lstProduct[0].Segmento__c = 'Individual';
        update lstProduct;

        CriticaProposta__c criticaProposta = new CriticaProposta__c(
             Proposta__c = listPropostas[0].Id,
             Status__c = 'Recusado',
             Codigo__c = '666'
        );
        insert criticaProposta;

        QuoteBO bo = new QuoteBO();

        Test.startTest();
        bo.sendEmailPropostaRecusada(listPropostas, mapOldPropostas);
        Test.stopTest();
    }
    // II-106 FIM

    // II-106 INICIO
    @IsTest
    static void sendEmailPropostaRecusadaTest() {

        List<Quote> listPropostas = [SELECT id, Status, Produto__c FROM Quote LIMIT 1];
        Map<Id, Quote> mapOldPropostas = new Map<Id, Quote>();
        Set<Id> setIdProduto = new Set<Id>(); 
        List<Product2> lstProduct = new List<Product2>();

        for (Quote proposta : listPropostas) {
            mapOldPropostas.put(proposta.Id, proposta);
            setIdProduto.add(proposta.Produto__c);
        }

        listPropostas[0].Status = 'Recusada';
        listPropostas[0].CodigoMotivoDevolucao__c = '10';
        listPropostas[0].email__c = 'email@teste.com';
        listPropostas[0].Tipo__c = 'Novo';
        listPropostas[0].Origem__c = '18';
        listPropostas[0].NumeroProposta__c = '12349555';

        update listPropostas;

        lstProduct = [SELECT id, Segmento__c FROM Product2 WHERE id IN :setIdProduto];
        lstProduct[0].Segmento__c = 'Individual';
        update lstProduct;

        QuoteBO bo = new QuoteBO();

        Test.startTest();
        bo.sendEmailPropostaRecusada(listPropostas, mapOldPropostas);
        Test.stopTest();
    }
    // II-106 FIM
    
//      //PLV-4612 FIM
 
//      @IsTest
//      static void testValidarDadosPagamentoContratanteProposta(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
//          delete listContratantePropostaParaDeletar;
 
//          Test.startTest();
//          // Gera um contratante da proposta
//          ContratanteProposta__c seguradoProposta = TestDataFactory.gerarContratanteProposta(conta,proposta,formaPagamento);
//          Test.stopTest();
 
//          // Valida se o contratante foi criado
//          //PLV-3667 - INICIO - Ajuste para classe de teste
//          List<ContratanteProposta__c> listContratanteProposta = [SELECT Id, Complemento__c FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
//          ContratanteProposta__c contProposta = new ContratanteProposta__c();
//          contProposta.Id = listContratanteProposta[0].Id;
//          contProposta.Complemento__c = 'AAAA';
//          update contProposta;
//          //PLV-3667 - FIM
//          System.assert(listContratanteProposta.size() > 0);
//          System.assert(seguradoProposta.Id != null);
//      }
 
//      @IsTest
//      static void testValidarDadosPagamentoVidaProposta(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
//          delete listVidaPropostaParaDeletar;
 
//          Test.startTest();
//          // Gera uma vida do grupo da proposta
//          SeguradoProposta__c vidaProposta = TestDataFactory.gerarSeguradoProposta(conta,grupoProposta,formaPagamento);
//          Test.stopTest();
 
//          // Valida se a vida foi criada
//          List<SeguradoProposta__c> listVidaProposta = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
//          System.assert(listVidaProposta.size() > 0);
//          System.assert(vidaProposta.Id != null);
//      }
 
//      @IsTest
//      static void testValidarDadosPagamentoContratantePropostaSemCondicaoCobranca(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todas as condicoes de cobranca
//          List<CondicaoCobranca__c> listCondicaoCobranca = [SELECT Id FROM CondicaoCobranca__c];
//          delete listCondicaoCobranca;
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
//          delete listContratantePropostaParaDeletar;
 
//          Test.startTest();
//          // Gera um contratante da proposta
//          try{
//              ContratanteProposta__c seguradoProposta = TestDataFactory.gerarContratanteProposta(conta,proposta,formaPagamento);
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
//          Test.stopTest();
 
//          System.debug('====> Erro esperado: ' + erroEsperado);
 
//          // Valida se o contratante foi criado
//          // PARA O MASSIFICADOS, A CONFICAO DE PAGAMENTO VEM SEMPRE DO PARCEIRO. CORRIGIR PARA OS OUTROS PRODUTOS
//          //System.assert(erroEsperado.contains('Insert failed'));
//          //System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          //System.assert(erroEsperado.contains('Condição de cobrança não cadastrada no produto comercial!'));
//      }
 
//      @IsTest
//      static void testValidarDadosPagamentoContratantePropostaSemResponsavelPagamento(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
//          delete listContratantePropostaParaDeletar;
 
//          // Gera um contratante da proposta
//          ContratanteProposta__c seguradoProposta = new ContratanteProposta__c(
//              Conta__c = conta.Id,
//              Proposta__c = proposta.Id,
//              Tipo__c = 'Principal',
//              TipoEndereco__c = 'Residencial',
//              Cep__c = '03020-000',
//              TipoLogradouro__c = 'Rua',
//              Logradouro__c = '15',
//              NumeroEndereco__c = '15',
//              Bairro__c = 'Osasco',
//              Cidade__c = 'São Paulo',
//              Estado__c = 'SP',
//              Pais__c = 'Brasil',
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10,
//              QuantidadeParcelas__c = 1,
//              EnderecoBoleto__c = 'http://www.portoseguro.com.br/boleto'
//          );
 
//          Test.startTest();
 
//          try{
//              // Insere o contratante
//              insert seguradoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
 
//          Test.stopTest();
 
//          // Valida se o contratante foi criado
//          System.assert(erroEsperado.contains('Insert failed'));
//          System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          System.assert(erroEsperado.contains('Responsável pelo pagamento não informado!'));
//      }
 
//      @IsTest
//      static void testValidarDadosPagamentoContratantePropostaSemEnderecoBoleto(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
//          delete listContratantePropostaParaDeletar;
 
//          // Gera um contratante da proposta
//          ContratanteProposta__c seguradoProposta = new ContratanteProposta__c(
//              Conta__c = conta.Id,
//              Proposta__c = proposta.Id,
//              Tipo__c = 'Principal',
//              TipoEndereco__c = 'Residencial',
//              Cep__c = '03020-000',
//              TipoLogradouro__c = 'Rua',
//              Logradouro__c = '15',
//              NumeroEndereco__c = '15',
//              Bairro__c = 'Osasco',
//              Cidade__c = 'São Paulo',
//              Estado__c = 'SP',
//              Pais__c = 'Brasil',
//              ResponsavelPagamento__c = conta.Id,
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10,
//              QuantidadeParcelas__c = 1
//          );
 
//          Test.startTest();
 
//          try{
//              // Insere o contratante
//              insert seguradoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
 
//          Test.stopTest();
 
//          // Valida se o contratante foi criado
//          //System.assert(erroEsperado.contains('Insert failed'));
//          //System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          //System.assert(erroEsperado.contains('Para boleto é necessário informar o endereço do boleto'));
//      }
 
//  /*--- classes separadas para outro programa de teste - estourava SOQL
//      @IsTest
//      static void testValidarDadosPagamentoContratantePropostaSemCartaoCredito(){
//          // Recupera dados
//          Quote proposta = [SELECT Id, Produto__c FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          Product2 produto = [SELECT Id FROM Product2 WHERE Id =: proposta.Produto__c LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
//          delete listContratantePropostaParaDeletar;
 
//          // Apaga todas as condicoes de cobranca
//          List<CondicaoCobranca__c> listCondicaoCobranca = [SELECT Id FROM CondicaoCobranca__c];
//          delete listCondicaoCobranca;
 
//          // altera a forma de pagamento para cartao de credito
//          formaPagamento.Codigo__c = 'CAT';
//          // não é permitido esta alteração: formaPagamento.Name = 'Cartão de Crédito';
//          update formaPagamento;
 
//          // cria uma condicao de cobraca para cartao de credito
//          CondicaoCobranca__c condicaoCobranca = new CondicaoCobranca__c(
//              FormaPagamento__c = formaPagamento.Id,
//              QuantidadeParcelas__c = '5',
//              Produto__c = produto.Id
//          );
//          insert condicaoCobranca;
 
//          // Apaga os cartões de credito do responsavel pelo pagamento
//          List<CartaoCredito__c> listCartaoCredito = [SELECT Id FROM CartaoCredito__c WHERE Conta__c =: conta.Id];
//          delete listCartaoCredito;
 
//          // Gera um contratante da proposta
//          ContratanteProposta__c seguradoProposta = new ContratanteProposta__c(
//              Conta__c = conta.Id,
//              Proposta__c = proposta.Id,
//              Tipo__c = 'Principal',
//              TipoEndereco__c = 'Residencial',
//              Cep__c = '03020-000',
//              TipoLogradouro__c = 'Rua',
//              Logradouro__c = '15',
//              NumeroEndereco__c = '15',
//              Bairro__c = 'Osasco',
//              Cidade__c = 'São Paulo',
//              Estado__c = 'SP',
//              Pais__c = 'Brasil',
//              ResponsavelPagamento__c = conta.Id,
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10
//          );
 
//          Test.startTest();
 
//          try{
//              // Insere o contratante
//              insert seguradoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
 
//          Test.stopTest();
 
//          System.debug('====> Erro esperado: ' + erroEsperado);
 
//          // Valida se o contratante foi criado
//          System.assert(erroEsperado.contains('Insert failed'));
//          System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          System.assert(erroEsperado.contains('Para cartão de crédito é necessário ter um cartão cadastrado!'));
//      }
 
//      @IsTest
//      static void testValidarDadosPagamentoContratantePropostaSemCartaoCreditoPorto(){
//          // Recupera dados
//          Quote proposta = [SELECT Id, Produto__c FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          Product2 produto = [SELECT Id FROM Product2 WHERE Id =: proposta.Produto__c LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
//          delete listContratantePropostaParaDeletar;
 
//          // Apaga todas as condicoes de cobranca
//          List<CondicaoCobranca__c> listCondicaoCobranca = [SELECT Id FROM CondicaoCobranca__c];
//          delete listCondicaoCobranca;
 
//          // altera a forma de pagamento para cartao de credito
//          formaPagamento.Codigo__c = 'CPO';
//          update formaPagamento;
 
//          // cria uma condicao de cobraca para cartao de credito
//          CondicaoCobranca__c condicaoCobranca = new CondicaoCobranca__c(
//              FormaPagamento__c = formaPagamento.Id,
//              QuantidadeParcelas__c = '5',
//              Produto__c = produto.Id
//          );
//          insert condicaoCobranca;
 
//          // Apaga os cartões de credito do responsavel pelo pagamento
//          List<CartaoCredito__c> listCartaoCredito = [SELECT Id FROM CartaoCredito__c WHERE Conta__c =: conta.Id];
//          delete listCartaoCredito;
 
//          // Gera um contratante da proposta
//          ContratanteProposta__c seguradoProposta = new ContratanteProposta__c(
//              Conta__c = conta.Id,
//              Proposta__c = proposta.Id,
//              Tipo__c = 'Principal',
//              TipoEndereco__c = 'Residencial',
//              Cep__c = '03020-000',
//              TipoLogradouro__c = 'Rua',
//              Logradouro__c = '15',
//              NumeroEndereco__c = '15',
//              Bairro__c = 'Osasco',
//              Cidade__c = 'São Paulo',
//              Estado__c = 'SP',
//              Pais__c = 'Brasil',
//              ResponsavelPagamento__c = conta.Id,
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10
//          );
 
//          Test.startTest();
 
//          try{
//              // Insere o contratante
//              insert seguradoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
 
//          Test.stopTest();
 
//          // Valida se o contratante foi criado
//          System.assert(erroEsperado.contains('Insert failed'));
//          System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          System.assert(erroEsperado.contains('Para pagamento no cartão de crédito Porto é necessário ter um cartão Porto cadastrado!'));
//      }
 
 
//      @IsTest
//      static void testValidarDadosPagamentoContratantePropostaSemInformacaoBancaria(){
//          // Recupera dados
//          Quote proposta = [SELECT Id, Produto__c FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          Product2 produto = [SELECT Id FROM Product2 WHERE Id =: proposta.Produto__c LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
//          delete listContratantePropostaParaDeletar;
 
//          // Apaga todas as condicoes de cobranca
//          List<CondicaoCobranca__c> listCondicaoCobranca = [SELECT Id FROM CondicaoCobranca__c];
//          delete listCondicaoCobranca;
 
//          // altera a forma de pagamento para cartao de credito
//          formaPagamento.Codigo__c = 'ADC';
//          update formaPagamento;
 
//          // cria uma condicao de cobraca para cartao de credito
//          CondicaoCobranca__c condicaoCobranca = new CondicaoCobranca__c(
//              FormaPagamento__c = formaPagamento.Id,
//              QuantidadeParcelas__c = '5',
//              Produto__c = produto.Id
//          );
//          insert condicaoCobranca;
 
//          // Apaga os cartões de credito do responsavel pelo pagamento
//          List<InformacaoBancaria__c> listInformacaoBancaria = [SELECT Id FROM InformacaoBancaria__c WHERE Conta__c =: conta.Id];
//          delete listInformacaoBancaria;
 
//          // Gera um contratante da proposta
//          ContratanteProposta__c seguradoProposta = new ContratanteProposta__c(
//              Conta__c = conta.Id,
//              Proposta__c = proposta.Id,
//              Tipo__c = 'Principal',
//              TipoEndereco__c = 'Residencial',
//              Cep__c = '03020-000',
//              TipoLogradouro__c = 'Rua',
//              Logradouro__c = '15',
//              NumeroEndereco__c = '15',
//              Bairro__c = 'Osasco',
//              Cidade__c = 'São Paulo',
//              Estado__c = 'SP',
//              Pais__c = 'Brasil',
//              ResponsavelPagamento__c = conta.Id,
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10
//          );
 
//          Test.startTest();
 
//          try{
//              // Insere o contratante
//              insert seguradoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
 
//          Test.stopTest();
 
//          // Valida se o contratante foi criado
//          System.assert(erroEsperado.contains('Insert failed'));
//          System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          System.assert(erroEsperado.contains('Para débito em conta é necessário ter uma informação bancária cadastrada!'));
//      }
//  */
 
//      //FUNCIONALDIDE REMOVIDA (COMENTADA)
//      //@IsTest
//      //static void testValidarDadosPagamentoContratantePropostaSemQuantidadeParcelas(){
//      //    // Recupera dados
//      //    Quote proposta = [SELECT Id, Produto__c FROM Quote LIMIT 1];
//      //    Account conta = [SELECT Id FROM Account LIMIT 1];
//      //    FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//      //    String erroEsperado = '';
 
//      //    // Apaga todos os contratantes da Proposta para gerar um novo
//      //    List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
//      //    delete listContratantePropostaParaDeletar;
 
//      //    // Gera um contratante da proposta
//      //    ContratanteProposta__c seguradoProposta = new ContratanteProposta__c(
//      //        Conta__c = conta.Id,
//      //        Proposta__c = proposta.Id,
//      //        Tipo__c = 'Principal',
//      //        TipoEndereco__c = 'Residencial',
//      //        Cep__c = '03020-000',
//      //        TipoLogradouro__c = 'Rua',
//      //        Logradouro__c = '15',
//      //        NumeroEndereco__c = '15',
//      //        Bairro__c = 'Osasco',
//      //        Cidade__c = 'São Paulo',
//      //        Estado__c = 'SP',
//      //        Pais__c = 'Brasil',
//      //        ResponsavelPagamento__c = conta.Id,
//      //        FormaPagamento__c = formaPagamento.Id,
//      //        PremioTotal__c = 10
//      //    );
 
//      //    Test.startTest();
 
//      //    try{
//      //        // Insere o contratante
//      //        insert seguradoProposta;
//      //    }catch (Exception e){
//      //        erroEsperado = e.getMessage();
//      //    }
 
//      //    Test.stopTest();
 
//      //    // Valida se o contratante foi criado
//      //    System.assert(erroEsperado.contains('Insert failed'));
//      //    System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//      //    System.assert(erroEsperado.contains('Quantidade de parcelas não informada!'));
//      //}
 
//      @IsTest
//      static void testValidarDadosPagamentoContratantePropostaQuantidadeParcelasNaoPermitida(){
//          // Recupera dados
//          Quote proposta = [SELECT Id, Produto__c FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<ContratanteProposta__c> listContratantePropostaParaDeletar = [SELECT Id FROM ContratanteProposta__c WHERE Proposta__c =: proposta.Id];
//          delete listContratantePropostaParaDeletar;
 
//          // Gera um contratante da proposta
//          ContratanteProposta__c seguradoProposta = new ContratanteProposta__c(
//              Conta__c = conta.Id,
//              Proposta__c = proposta.Id,
//              Tipo__c = 'Principal',
//              TipoEndereco__c = 'Residencial',
//              Cep__c = '03020-000',
//              TipoLogradouro__c = 'Rua',
//              Logradouro__c = '15',
//              NumeroEndereco__c = '15',
//              Bairro__c = 'Osasco',
//              Cidade__c = 'São Paulo',
//              Estado__c = 'SP',
//              Pais__c = 'Brasil',
//              ResponsavelPagamento__c = conta.Id,
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10,
//              QuantidadeParcelas__c = 30
//          );
 
//          Test.startTest();
 
//          try{
//              // Insere o contratante
//              insert seguradoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
 
//          Test.stopTest();
 
//          // Valida se o contratante foi criado
//          // System.assert(erroEsperado.contains('Insert failed'));
//          // System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          // System.assert(erroEsperado.contains('Quantidade de parcelas não permitida pelo produto comercial!'));
//      }
 
//      @IsTest
//      static void testValidarDadosPagamentoVidaPropostaSemCondicaoCobranca(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todas as condicoes de cobranca
//          List<CondicaoCobranca__c> listCondicaoCobranca = [SELECT Id FROM CondicaoCobranca__c];
//          delete listCondicaoCobranca;
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
//          delete listVidaPropostaParaDeletar;
 
//          Test.startTest();
//          // Gera uma vida do grupo da proposta
//          try{
//              TestDataFactory.gerarSeguradoProposta(conta,grupoProposta,formaPagamento);
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
//          Test.stopTest();
 
//          System.debug('====> Erro esperado: ' + erroEsperado);
 
//          // Valida se a vida foi criada
 
//          // PARA O MASSIFICADOS, A CONFICAO DE PAGAMENTO VEM SEMPRE DO PARCEIRO. CORRIGIR PARA OS OUTROS PRODUTOS
//          //System.assert(erroEsperado.contains('Insert failed'));
//          //System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          //System.assert(erroEsperado.contains('Condição de cobrança não cadastrada no produto comercial!'));
//      }
 
//      @IsTest
//      static void testValidarDadosPagamentoVidaPropostaSemResponsavelPagamento(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
//          delete listVidaPropostaParaDeletar;
 
//          SeguradoProposta__c vidaGrupoProposta = new SeguradoProposta__c(
//              Conta__c = conta.Id,
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10,
//              QuantidadeParcelas__c = 1,
//              GrupoProposta__c = grupoProposta.Id,
//              EnderecoBoleto__c = 'http://www.google.com.br'
//          );
 
//          Test.startTest();
//          // Gera uma vida do grupo da proposta
//          try{
//              insert vidaGrupoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
//          Test.stopTest();
 
//          // Valida se a vida foi criada
//          System.assert(erroEsperado.contains('Insert failed'));
//          System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          System.assert(erroEsperado.contains('Responsável pelo pagamento não informado!'));
//      }
 
//      @IsTest
//      static void testValidarDadosPagamentoVidaPropostaSemEnderecoBoleto(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
//          delete listVidaPropostaParaDeletar;
 
//          SeguradoProposta__c vidaGrupoProposta = new SeguradoProposta__c(
//              Conta__c = conta.Id,
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10,
//              QuantidadeParcelas__c = 1,
//              GrupoProposta__c = grupoProposta.Id,
//              ResponsavelPagamento__c = conta.Id
//          );
 
//          Test.startTest();
//          // Gera uma vida do grupo da proposta
//          try{
//              insert vidaGrupoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
//          Test.stopTest();
 
//          // Valida se a vida foi criada
//          //System.assert(erroEsperado.contains('Insert failed'));
//          //System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          //System.assert(erroEsperado.contains('Para boleto é necessário informar o endereço do boleto'));
//      }
 
//      @IsTest
//      static void testValidarDadosPagamentoVidaPropostaSemCartaoCredito(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
//          delete listVidaPropostaParaDeletar;
 
//          // Atualiza a forma de pagamento
//          formaPagamento.Codigo__c = 'CAT';
//          update formaPagamento;
 
//          List<CartaoCredito__c> listCartaoCredito = [SELECT Id FROM CartaoCredito__c WHERE Conta__c =: conta.Id];
//          delete listCartaoCredito;
 
//          SeguradoProposta__c vidaGrupoProposta = new SeguradoProposta__c(
//              Conta__c = conta.Id,
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10,
//              QuantidadeParcelas__c = 1,
//              GrupoProposta__c = grupoProposta.Id,
//              ResponsavelPagamento__c = conta.Id
//          );
 
//          Test.startTest();
//          // Gera uma vida do grupo da proposta
//          try{
//              insert vidaGrupoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
//          Test.stopTest();
 
//          // Valida se a vida foi criada
//          System.assert(erroEsperado.contains('Insert failed'));
//          System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          System.assert(erroEsperado.contains('Para cartão de crédito é necessário ter um cartão cadastrado!'));
//      }
 
//      @IsTest
//      static void testValidarDadosPagamentoVidaPropostaSemCartaoCreditoPorto(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
//          delete listVidaPropostaParaDeletar;
 
//          // Atualiza a forma de pagamento
//          formaPagamento.Codigo__c = 'CPO';
//          update formaPagamento;
 
//          List<CartaoCredito__c> listCartaoCredito = [SELECT Id FROM CartaoCredito__c WHERE Conta__c =: conta.Id];
//          delete listCartaoCredito;
 
//          SeguradoProposta__c vidaGrupoProposta = new SeguradoProposta__c(
//              Conta__c = conta.Id,
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10,
//              QuantidadeParcelas__c = 1,
//              GrupoProposta__c = grupoProposta.Id,
//              ResponsavelPagamento__c = conta.Id
//          );
 
//          Test.startTest();
//          // Gera uma vida do grupo da proposta
//          try{
//              insert vidaGrupoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
//          Test.stopTest();
 
//          // Valida se a vida foi criada
//          System.assert(erroEsperado.contains('Insert failed'));
//          System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          System.assert(erroEsperado.contains('Para pagamento no cartão de crédito Porto é necessário ter um cartão Porto cadastrado!'));
//      }
 
//      @IsTest
//      static void testValidarDadosPagamentoVidaPropostaSemInformacaoBancaria(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
//          delete listVidaPropostaParaDeletar;
 
//          // Atualiza a forma de pagamento
//          formaPagamento.Codigo__c = 'ADC';
//          update formaPagamento;
 
//          List<InformacaoBancaria__c> listInformacaoBancaria = [SELECT Id FROM InformacaoBancaria__c WHERE Conta__c =: conta.Id];
//          delete listInformacaoBancaria;
 
//          SeguradoProposta__c vidaGrupoProposta = new SeguradoProposta__c(
//              Conta__c = conta.Id,
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10,
//              QuantidadeParcelas__c = 1,
//              GrupoProposta__c = grupoProposta.Id,
//              ResponsavelPagamento__c = conta.Id
//          );
 
//          Test.startTest();
//          // Gera uma vida do grupo da proposta
//          try{
//              insert vidaGrupoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
//          Test.stopTest();
 
//          // Valida se a vida foi criada
//          System.assert(erroEsperado.contains('Insert failed'));
//          System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          System.assert(erroEsperado.contains('Para débito em conta é necessário ter uma informação bancária cadastrada!'));
//      }
 
//      //FUNCIONALDIDE REMOVIDA (COMENTADA)
//      //@IsTest
//      //static void testValidarDadosPagamentoVidaPropostaSemQuantidadeParcela(){
//      //    // Recupera dados
//      //    Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//      //    Account conta = [SELECT Id FROM Account LIMIT 1];
//      //    FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//      //    GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
//      //    String erroEsperado = '';
 
//      //    // Apaga todos os contratantes da Proposta para gerar um novo
//      //    List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
//      //    delete listVidaPropostaParaDeletar;
 
//      //    List<InformacaoBancaria__c> listInformacaoBancaria = [SELECT Id FROM InformacaoBancaria__c WHERE Conta__c =: conta.Id];
//      //    delete listInformacaoBancaria;
 
//      //    SeguradoProposta__c vidaGrupoProposta = new SeguradoProposta__c(
//      //        Conta__c = conta.Id,
//      //        FormaPagamento__c = formaPagamento.Id,
//      //        PremioTotal__c = 10,
//      //        GrupoProposta__c = grupoProposta.Id,
//      //        ResponsavelPagamento__c = conta.Id,
//      //        EnderecoBoleto__c = 'http://www.portoseguro.com.br/boleto'
//      //    );
 
//      //    Test.startTest();
//      //    // Gera uma vida do grupo da proposta
//      //    try{
//      //        insert vidaGrupoProposta;
//      //    }catch (Exception e){
//      //        erroEsperado = e.getMessage();
//      //    }
//      //    Test.stopTest();
 
//      //    // Valida se a vida foi criada
//      //    System.assert(erroEsperado.contains('Insert failed'));
//      //    System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//      //    System.assert(erroEsperado.contains('Quantidade de parcelas não informada!'));
//      //}
 
//  /* --- Losada: a teste foi comentado porque a rotina que faz a consistências não esta ativa
//     --- ne mesma conta que: comentado porque nem sempre vai existir informação de pgto na vida da proposta
//      @IsTest
//      static void testValidarDadosPagamentoVidaPropostaQuantidadeParcelaNaoPermitida(){
//          // Recupera dados
//          Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//          Account conta = [SELECT Id FROM Account LIMIT 1];
//          FormaPagamento__c formaPagamento = [SELECT Id FROM FormaPagamento__c LIMIT 1];
//          GrupoProposta__c grupoProposta = [SELECT Id FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__c =: proposta.Id LIMIT 1];
//          String erroEsperado = '';
 
//          // Apaga todos os contratantes da Proposta para gerar um novo
//          List<SeguradoProposta__c> listVidaPropostaParaDeletar = [SELECT Id FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c =: proposta.Id];
//          delete listVidaPropostaParaDeletar;
 
//          List<InformacaoBancaria__c> listInformacaoBancaria = [SELECT Id FROM InformacaoBancaria__c WHERE Conta__c =: conta.Id];
//          delete listInformacaoBancaria;
 
//          SeguradoProposta__c vidaGrupoProposta = new SeguradoProposta__c(
//              Conta__c = conta.Id,
//              FormaPagamento__c = formaPagamento.Id,
//              PremioTotal__c = 10,
//              GrupoProposta__c = grupoProposta.Id,
//              ResponsavelPagamento__c = conta.Id,
//              EnderecoBoleto__c = 'http://www.portoseguro.com.br/boleto',
//              QuantidadeParcelas__c = 30
//          );
 
//          Test.startTest();
//          // Gera uma vida do grupo da proposta
//          try{
//              insert vidaGrupoProposta;
//          }catch (Exception e){
//              erroEsperado = e.getMessage();
//          }
//          Test.stopTest();
 
//          System.debug('======> Erro:' + erroEsperado);
 
//          // Valida se a vida foi criada
//          //System.assert(erroEsperado.contains('Insert failed'));
//          //System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//          //System.assert(erroEsperado.contains('Quantidade de parcelas não permitida pelo produto comercial!'));
//      }
//  */
 
//      //@IsTest
//  //    static void testGerarPropostaCancelamento(){
//          //TestDataFactory.gerarContrato();
 
//          //Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 200, 'OK'));
 
 
//  //    }
 
//       //@IsTest
//      // static void testValidarPropostaJaIncluida(){
//      //     // Recupera dados
//      //     Quote proposta = [SELECT Id FROM Quote LIMIT 1];
//      //     Quote proposta2 = [SELECT Name,
//      //                         Produto__c,
//      //                         RamoSeguro__c,
//      //                         Status,
//      //                         VigenciaInicial__c,
//      //                         VigenciaFinal__c,
//      //                         Empresa__c,
//      //                         CodigoCorretor__c,
//      //                         DataCalculo__c,
//      //                         DataCriacaoPortal__c,
//      //                         TipoVigencia__c,
//      //                         MeioComercializacao__c,
//      //                         OpportunityId
//      //                         FROM Quote WHERE Id =: proposta.Id];
//      //     String erroEsperado = '';
 
//      //     proposta2.Id = null;
 
//      //     Test.startTest();
//      //     try{
//      //         insert proposta2;
//      //     }catch (Exception e){
//      //         erroEsperado = e.getMessage();
//      //     }
//      //     Test.stopTest();
 
//      //     System.debug('====> Erro esperado: ' + erroEsperado);
 
//      //     // Valida se a vida foi criada
//      //     System.assert(erroEsperado.contains('Insert failed'));
//      //     System.assert(erroEsperado.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//      //     System.assert(erroEsperado.contains('Proposta já existente no cadastro.'));
//      // }
 
//      // PLV-2312-28 INICIO
//  //    @IsTest
//  //    static void testElaborarContrato(){
//  //
//  //
//  ////        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadContrato' LIMIT 1];
//  ////        String payload = staticResource.Body.toString();
//  //
//  //        // Mock para callout
//  //        String payloadReturn = '{"contrato": {"codigoEmpresa": "1","codigoSucursal": "1","ramoSeguro": "1391","numeroApolice": "00000021","numeroEndosso": "0"},"integracoesObrigatorias": [],"integracoesComplementares": []}';
//  //        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
//  //
//  //        RestRequest request = new RestRequest();
//  //        request.requestUri ='/fila-evento/processar-massificados';
//  //        request.httpMethod = 'POST';
//  //
//  //        RestResponse res = new RestResponse();
//  //        RestContext.response = res;
//  //        RestContext.request = request;
//  //
//  //        // Recupera dados
//  //        Quote proposta = [SELECT Id, NumeroProposta__c FROM Quote LIMIT 1];
//  //        // PLV-2378-29 - INICIO
//  //        proposta.MeioComercializacao__c = 'ARQ';
//  //        proposta.Massificados__c = true;
//  //        // PLV-2378-29 - FINAL
//  //        proposta.status = 'Disponível para contratação';
//  //        update proposta;
//  //
//  //        // Apaga o contrato gerado para ser gerado novamente no teste
//  //        List<Contract> contratos = [SELECT Id From Contract];
//  //        delete contratos;
//  //        contratos = [SELECT Id From Contract];
//  //        System.assert(contratos.isEmpty());
//  //
//  //        // Chama o batch de processamento de propostas de massificados
//  //        Test.startTest();
//  //        FilaEventoREST.processarPost();
//  //        Test.stopTest();
//  //
//  //        contratos = [SELECT Id, MeioComercializacao__c, Status, NumeroProposta__c From Contract];
//  //
//  //        System.debug('CONTRATO GERADO NO TESTE ' + contratos);
//  //        System.assert(!contratos.isEmpty());
//  //        System.assertEquals(proposta.NumeroProposta__c, contratos[0].NumeroProposta__c);
//  //        System.assertEquals('Em elaboração', contratos[0].Status);
//  //
//  //    }
//      // PLV-2312-28 FIM
 
//      // PLV-2312-28 INICIO
//      @IsTest
//      static void testAbortarJob(){
 
//          ServiceTO.ControleBatchTO controleBatchTO = new ServiceTO.ControleBatchTO();
//          controleBatchTO.servico = 'teste';
//          controleBatchTO.idjob = '1561d313';
 
//          RestRequest request = new RestRequest();
//          request.requestUri ='/fila-evento/abortar-processar-massificados';
//          request.httpMethod = 'POST';
//          request.requestBody = Blob.valueOf(JSON.serialize(controleBatchTO));
 
//          RestResponse res = new RestResponse();
//          RestContext.response = res;
//          RestContext.request = request;
 
//          // Chama o servico que aborta um batch pelo id
//          Test.startTest();
//          FilaEventoREST.processarPost();
//          Test.stopTest();
//      }
//      // PLV-2312-28 FIM
     
//      // PLV-2312-28 INICIO
//      @IsTest
//      static void testGerarContrato(){
 
//          // Mock para callout
//          String payloadReturn = '{"contrato": {"codigoEmpresa": "1","codigoSucursal": "1","ramoSeguro": "1391","numeroApolice": "00000021","numeroEndosso": "0"},"integracoesObrigatorias": [],"integracoesComplementares": []}';
//          Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
 
//          RestRequest request = new RestRequest();
//          request.requestUri ='/fila-evento/processar-massificados';
//          request.httpMethod = 'POST';
 
//          RestResponse res = new RestResponse();
//          RestContext.response = res;
//          RestContext.request = request;
 
//          // Recupera dados
//          Quote proposta = [SELECT Id, NumeroProposta__c FROM Quote LIMIT 1];
//          proposta.MeioComercializacao__c = 'ARQ';
//          proposta.status = 'Disponível para contratação';
//          proposta.Massificados__c = true;
//  //        update proposta;
 
//          // Apaga o contrato gerado para ser gerado novamente no teste
//          List<Contract> contratos = [SELECT Id, Parceiro__c From Contract WHERE Proposta__c =: proposta.Id];
//          Contract contrato = contratos[0];
//          contrato.Tipo__c = 'Novo';
//          contrato.MeioComercializacao__c = 'ARQ';
//          contrato.Status = 'Em elaboração';
//          contrato.Massificados__c = true;
//          update contrato;
 
//          // Chama o batch de processamento de propostas de massificados
//          Test.startTest();
//          FilaEventoREST.processarPost();
//          Test.stopTest();
 
//          contratos = [SELECT Id, MeioComercializacao__c, Status, NumeroProposta__c From Contract WHERE Proposta__c =: proposta.Id];
 
//          System.debug('CONTRATO GERADO NO TESTE ' + contratos);
//          System.assert(!contratos.isEmpty());
//         //System.assertEquals('Emitido', contratos[0].Status); //PLV-4415 - INICIO/FIM //PLV 4620 FIX 2
//      }
//      // PLV-2312-28 FIM
     
//      // PLV-2605-28 INICIO Remoção de método não Utilizado
//      // PLV-2605-28 FIM Remoção de método não Utilizado
     
//      // PLV-2312-28 INICIO
//      @IsTest
//      static void testElaborarContratoViaTrigger(){
 
//          // Mock para callout
//          String payloadReturn = '{"contrato": {"codigoEmpresa": "1","codigoSucursal": "1","ramoSeguro": "1391","numeroApolice": "00000021","numeroEndosso": "0"},"integracoesObrigatorias": [],"integracoesComplementares": []}';
//          Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
 
//          // Recupera dados
//          Quote proposta = [SELECT Id, NumeroProposta__c, Status, Tipo__c FROM Quote LIMIT 1];
//          proposta.Tipo__c = 'Novo';
//          proposta.status = 'Disponível para contratação';
 
//          // Apaga o contrato gerado para ser gerado novamente no teste
//          List<Contract> contratos = [SELECT Id From Contract WHERE Proposta__c =: proposta.Id];
//          delete contratos;
 
//          // Atualiza a proposta para Disponivel para contratacao
//          Test.startTest();
//          update proposta;
//          Test.stopTest();
//          contratos = [SELECT Id, MeioComercializacao__c, Status, NumeroProposta__c From Contract WHERE Proposta__c =: proposta.Id];
 
//          System.debug('CONTRATO GERADO NO TESTE ' + contratos);
//          // PLV-5098 FIX01 INICIO
//          //System.assert(!contratos.isEmpty());
//          //System.assertEquals(proposta.NumeroProposta__c, contratos[0].NumeroProposta__c);
//          // PLV-2372 INICIO
//          //System.assertEquals('Em elaboração', contratos[0].Status); 
//          // PLV-2372 FIM
//          // PLV-5098 FIX01 FIM
//      }
//      // PLV-2312-28 FIM
     
//      // PLV-2312-28 INICIO
//      // PLV-2372 INICIO
//  //    @IsTest
//  //    static void testElaborarContratoCancelamento(){
//  //
//  //        // Mock para callout
//  //        String payloadReturn = '{"contrato": {"codigoEmpresa": "22","codigoSucursal": "999","ramoSeguro": "1391","numeroApolice": "14889","numeroEndosso": "0"},"integracoesObrigatorias": [],"integracoesComplementares": []}';
//  //        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
//  //
//  //        RestRequest request = new RestRequest();
//  //        request.requestUri ='/fila-evento/processar-massificados';
//  //        request.httpMethod = 'POST';
//  //        RestResponse res = new RestResponse();
//  //
//  //        RestContext.response = res;
//  //        RestContext.request = request;
//  //
//  //        // Recupera contrato original
//  //        Contract contrato = [SELECT Id,Empresa__c,Sucursal__c, RamoSeguro__c, NumeroApolice__c, Status, MeioComercializacao__c FROM Contract LIMIT 1];
//  //        contrato.Status = 'Emitido';
//  //        contrato.MeioComercializacao__c = 'ARQ';
//  //        update contrato;
//  //
//  //        // Gerar proposta de cancelamento
//  //        Quote proposta = [SELECT Id, OpportunityId, RamoSeguro__c, Modalidade__c FROM Quote LIMIT 1];
//  //        Quote propostaCancelamento = proposta.clone(false,true);
//  //        propostaCancelamento.Name = '18-00000456';
//  //        propostaCancelamento.NumeroPropostaUnico__c = '18-00000456';
//  //        propostaCancelamento.status = 'Disponível para contratação';
//  //        propostaCancelamento.Tipo__c = 'Cancelamento';
//  //        propostaCancelamento.MeioComercializacao__c = 'ARQ';
//  //        propostaCancelamento.ContractId = contrato.Id;
//  //        insert propostaCancelamento;
//  //
//  //        Test.startTest();
//  //        FilaEventoREST.processarPost();
//  //        Test.stopTest();
//  //
//  //        // Busca o contrato original apos o cancelamento
//  //        Contract contratoOriginal = [SELECT Id, Status FROM Contract WHERE Id =: contrato.Id LIMIT 1];
//  //        // Busca o contrato de cancelamento
//  //        Contract contratoCancelamento = [SELECT Id, Status From Contract WHERE Proposta__c =: propostaCancelamento.Id LIMIT 1];
//  //
//  //        // Verifica se o contrato de cancelamento foi gerado com o status em elaboracao
//  //        System.assert(contratoCancelamento != null);
//  //        System.assertEquals('Em elaboração',contratoCancelamento.Status);
//  //        // Verificar se o contrato original foi cancelado
//  //        System.assertEquals('Emitido',contratoOriginal.Status);
//  //
//  //    }
//      // PLV-2372 FIM
//      // PLV-2312-28 FIM
 
//      // PLV-2312-28 INICIO
//      // PLV-2605 INICIO
//      @IsTest
//      static void testGerarContratoCancelamentoMassificados(){
 
//          // Mock para callout
//          StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadContrato' LIMIT 1];
//          String payload = staticResource.Body.toString();
 
//          String payloadReturn = '{"contrato": {"codigoEmpresa": "22","codigoSucursal": "999","ramoSeguro": "1391","numeroApolice": "14889","numeroEndosso": "0"},"integracoesObrigatorias": [],"integracoesComplementares": []}';
 
//          Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
 
//          RestRequest request = new RestRequest();
//          request.requestUri ='/apivida/vida/dev/v1/contratos/emissao';
//          request.httpMethod = 'POST';
//          request.requestBody = Blob.valueOf(payload);
//          RestResponse res = new RestResponse();
 
//          RestContext.response = res;
//          RestContext.request = request;
 
//          // Recupera contrato original
//          List<Contract> listContrato = [SELECT Id,Empresa__c,Sucursal__c, RamoSeguro__c, RamoSeguro__r.Codigo__c, NumeroApolice__c, Status, AccountId FROM Contract];
 
//          Contract contrato = listContrato[0];
//          contrato.Status = 'Emitido';
//          contrato.MeioComercializacao__c = 'ARQ';
//          contrato.Tipo__c = 'Novo';
//          update contrato;
 
//          // Gerar proposta de cancelamento
//          // PLV-2378-29 - INICIO
//          Quote proposta = [SELECT Id, Empresa__c, RamoSeguro__c, RamoSeguro__r.Codigo__c, OpportunityId, Modalidade__c, Status, Massificados__c FROM Quote LIMIT 1];
//          proposta.MeioComercializacao__c = 'ARQ';
//          proposta.Massificados__c = true;
//          // PLV-2378-29 - FINAL
//          proposta.Status = 'Contratada';
//          proposta.Tipo__c = 'Novo';
//          update proposta;
     
//          Product2 produtoComTelemak1 = [SELECT Id FROM Product2 WHERE ProductCode = 'APTLMKT' LIMIT 1]; //TKCL-246 FIX05 INICIO/FIM
     
//          Quote propostaCancelamento = proposta.clone(false,true);
//          propostaCancelamento.Name = '18-00000456';
//          propostaCancelamento.NumeroProposta__c = '00000456';
//          propostaCancelamento.NumeroPropostaUnico__c = '18-00000456';
//          propostaCancelamento.Status = 'Em análise';
//          propostaCancelamento.Tipo__c = 'Cancelamento';
//          propostaCancelamento.ContractId = contrato.Id;
//          propostaCancelamento.Massificados__c = true;
//          propostaCancelamento.MeioComercializacao__c = 'ARQ';
//          propostaCancelamento.Produto__c = produtoComTelemak1.Id; //TKCL-246 FIX05 INICIO/FIM
//          insert propostaCancelamento;
//          //TKCL-246 FIX05 INICIO
//          //String nomeProp = '18-00000456';
//          //Quote testeProp = [SELECT Name FROM Quote Where Name =: nomeProp];
//          //System.debug('teste propostaCancelamento '+ testeProp);
//          //TKCL-246 FIX05 FIM
//          propostaCancelamento.Status = 'Disponível para contratação';
 
//          //TKCL-246 FIX05 INICIO
//          // Gera o contrato de cancelamento
//          // Contract contratoCancelamento = contrato.clone(false, true);
//          // contratoCancelamento.Name = ContractBO.getInstance().gerarNameContrato(contrato.Empresa__c, contrato.Sucursal__c, contrato.RamoSeguro__r.Codigo__c, contrato.NumeroApolice__c,'1');
//          // contratoCancelamento.Endosso__c = '1';
//          // contratoCancelamento.Tipo__c = 'Cancelamento';
//          // contratoCancelamento.AccountId = contrato.AccountId;
//          // contratoCancelamento.Status = 'Em elaboração';
//          // contratoCancelamento.Proposta__c = propostaCancelamento.Id;
//          // contratoCancelamento.MeioComercializacao__c = 'ARQ';
//          // insert contratoCancelamento;
//          //TKCL-246 FIX05 FIM
 
//          Test.startTest();
//          update propostaCancelamento;
//          Test.stopTest();
 
//           //Busca o contrato original apos o cancelamento
//          // Contract contratoOriginal = [SELECT Id, Status, origem__c FROM Contract WHERE Id =: contrato.Id LIMIT 1]; // PLV-4598 INICIO-FIM
//          // Busca o contrato de cancelamento
//          //Contract contratoCancelamento = [SELECT Id, Status From Contract WHERE Proposta__c =: propostaCancelamento.Id LIMIT 1];
 
//          //TKCL-246 FIX05 INICIO
//          // Verifica se o contrato de cancelamento foi gerado
//          // System.assert(contratoCancelamento != null);
//          // System.assertEquals('Em elaboração',contratoCancelamento.Status);
//          // System.assertEquals('Cancelamento',contratoCancelamento.Tipo__c);
//          // Verificar se o contrato original foi cancelado
//          //System.assertEquals('Emitido',contratoOriginal.Status);
//          //TKCL-246 FIX05 FIM
 
//      }
//      // PLV-2605 FIM
//      // PLV-2312-28 FIM
 
//      // PLV-2312-28 INICIO Remocao de metodos nao utilizados
//      // PLV-2312-28 FIM Remocao de metodos nao utilizados
     
//      @IsTest
//      static void testQueueableContractDetails(){
 
//          //INICIO - PLV-4802 - Guilherme Brito
//          Quote proposta = [SELECT Id, Status, Tipo__c, OpportunityId FROM Quote LIMIT 1];
//          Contract contrato = [SELECT Id, Parceiro__c, Produto__c, origem__c, Proposta__c, (SELECT Id, ResponsavelPagamento__c FROM ContratantesContrato__r) FROM Contract LIMIT 1]; 
//          String tipoProduto = [SELECT ID, Name FROM Product2 WHERE ID =: contrato.Produto__c].Name; 
//          Parceiro__c parceiro = [SELECT Id, Codigo__c, Conta__c FROM Parceiro__c LIMIT 1];
//          //FIM - PLV-4802 - Guilherme Brito
         
//          // Insere o parceiro ao contrato
//          contrato.Parceiro__c = parceiro.Codigo__c;
//          update contrato;
 
//          // Insere o responsavel do pagamento no contratante
//          List<ContratanteContrato__c> listContratanteContrato = new List<ContratanteContrato__c>();
 
//          for(ContratanteContrato__c contratanteContrato : contrato.ContratantesContrato__r){
//              contratanteContrato.ResponsavelPagamento__c = parceiro.Conta__c;
//              listContratanteContrato.add(contratanteContrato);
//          }
//          update listContratanteContrato;
 
//      // PLV-2312-28 INICIO
//          Test.startTest();
//          System.enqueueJob(new QueueableContractDetails(new List<Contract>{contrato}, 0, true)); //4802 - Guilherme Brito - INICIO/FIM
//          Test.stopTest();
//      // PLV-2312-28 FIM
 
//      }
    //II-167 INICIO
    @IsTest
    static void testGerarPropostaCancelamento(){
        List<Opportunity> opps = [SELECT Id, Name, AccountId, Account.Name, RecordType.Name FROM Opportunity];

        Contract contrato = [SELECT Id, Name FROM Contract LIMIT 1];        

        String payloadName = 'PayloadOrcamento001';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];

        String payload = sr.Body.toString();

        //System.debug('Json Orcamento: ' + payload);

        OrcamentoTO.PayloadTO objOrcamento = (OrcamentoTO.PayloadTO) JSON.deserialize(payload, OrcamentoTO.PayloadTO.class);

        OrcamentoTO.DadosPagamentoTO dadospagamentoTO = new OrcamentoTO.DadosPagamentoTO();
        dadospagamentoTO.quantidadeParcelas         = 1;
        dadospagamentoTO.vencimentoPrimeiraParcela  = System.today();
        dadospagamentoTO.tipoResponsavelPagamento   = '111';

        OrcamentoTO.PessoaTO pessoaTO = new OrcamentoTO.PessoaTO();
        pessoaTO.tipo  = 'JUR';
        pessoaTO.nome  = 'Teste';
        pessoaTO.email = 'teste@teste.com.br';

        OrcamentoTO.DadosPessoaJuridicaTO juridicaTO = new OrcamentoTO.DadosPessoaJuridicaTO();
        juridicaTO.cnpj = '11.111.111./1111-11';
        juridicaTO.codigoCNAE = 11;

        List<OrcamentoTO.EnderecoTO> enderecos = new List<OrcamentoTO.EnderecoTO>();
        OrcamentoTO.EnderecoTO enderecoTO = new OrcamentoTO.EnderecoTO();
        enderecoTO.tipoLogradouro   = 'Teste';
        enderecoTO.tipoEndereco     = 'Teste';
        enderecoTO.logradouro       = 'Teste';
        enderecoTO.numeroLogradouro = 'Teste';
        enderecoTO.complemento      = 'Teste';
        enderecoTO.bairro           = 'Teste';
        enderecoTO.cidade           = 'Teste';
        enderecoTO.uf               = 'Teste';
        enderecoTO.paisResidencia   = 'Teste';
        enderecoTO.cep              = 'Teste';
        enderecoTO.complementoCep   = 'Teste';
        enderecos.add(enderecoTO);

        List<OrcamentoTO.TelefoneTO> telefones = new List<OrcamentoTO.TelefoneTO>();
        OrcamentoTO.TelefoneTO telefonesTO = new OrcamentoTO.TelefoneTO();
        telefonesTO.tipoTelefone   = 'Teste'; 
        telefonesTO.dddTelefone    = 'Teste';
        telefonesTO.numeroTelefone = 'Teste';
        telefones.add(telefonesTO);


        for(OrcamentoTO orcamentoTO :objOrcamento.orcamentos){

            orcamentoTO.solicitacaoOferta.tipoSeguro = 'CAN';
            orcamentoTO.solicitacaoOferta.empresa = '1';
            orcamentoTO.solicitacaoOferta.sucursal = '1';
            orcamentoTO.solicitacaoOferta.ramo = '1';
            orcamentoTO.solicitacaoOferta.tipoEndosso = '1';
            orcamentoTO.solicitacaoOferta.apolice = contrato.name;

            for(OrcamentoTO.ContratanteTO contratante :orcamentoTO.solicitacaoOferta.contratantes)
            {
                contratante.dadosPagamento = dadospagamentoTO;
                contratante.pessoa = pessoaTO;
                contratante.pessoa.dadosPessoaJuridica = juridicaTO;
                contratante.pessoa.telefones = telefones;
                contratante.pessoa.enderecos = enderecos;                

                for(OrcamentoTO.GrupoTO gruposTO  :contratante.grupos)
                {
                    for(OrcamentoTO.SeguradoTO seguradoTO  :gruposTO.segurados)
                    {
                        seguradoTO.pessoa = pessoaTO;
                        seguradoTO.pessoa.dadosPessoaJuridica = juridicaTO;
                        seguradoTO.pessoa.telefones = telefones;
                        seguradoTO.pessoa.enderecos = enderecos;                
                    }
                }
            }
        } 

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payload, 200, 'OK'));

        RestRequest request = new RestRequest();
        request.requestUri ='/apivida/vida/dev/v1/propostas/oferta/massificados/cancelamento';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(payload);
        RestResponse res = new RestResponse();
    
        RestContext.response = res;
        RestContext.request = request;

        Test.startTest();

        QuoteBO.getInstance().gerarPropostaCancelamento(opps, objOrcamento);

        Test.stopTest();
    }
    //II-167 FIM
 
//      //PLV-5098 - FIX01 - INICIO
//      @IsTest
//      static void testGerarPropostaCancelamentoFis(){
//          List<Opportunity> opps = [SELECT Id, Name, AccountId, Account.Name, RecordType.Name FROM Opportunity];
 
//          Contract contrato = [SELECT Id, Name FROM Contract LIMIT 1];        
 
//          String payloadName = 'PayloadOrcamento002';
//          StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
 
//          String payload = sr.Body.toString();
 
//          //System.debug('Json Orcamento: ' + payload);
 
//          OrcamentoTO.PayloadTO objOrcamento = (OrcamentoTO.PayloadTO) JSON.deserialize(payload, OrcamentoTO.PayloadTO.class);
 
//          OrcamentoTO.DadosPagamentoTO dadospagamentoTO = new OrcamentoTO.DadosPagamentoTO();
//          dadospagamentoTO.quantidadeParcelas         = 1;
//          dadospagamentoTO.vencimentoPrimeiraParcela  = System.today();
//          dadospagamentoTO.tipoResponsavelPagamento   = '111';
 
//          OrcamentoTO.PessoaTO pessoaTO = new OrcamentoTO.PessoaTO();
//          pessoaTO.tipo  = 'FIS';
//          pessoaTO.nome  = 'Teste';
//          pessoaTO.email = 'teste@teste.com.br';
 
//          OrcamentoTO.DadosPessoaFisicaTO fisicaTO = new OrcamentoTO.DadosPessoaFisicaTO();
//          fisicaTO.numeroCpf = '111.111.111-11';
         
//          List<OrcamentoTO.EnderecoTO> enderecos = new List<OrcamentoTO.EnderecoTO>();
//          OrcamentoTO.EnderecoTO enderecoTO = new OrcamentoTO.EnderecoTO();
//          enderecoTO.tipoLogradouro   = 'Teste';
//          enderecoTO.tipoEndereco     = 'Teste';
//          enderecoTO.logradouro       = 'Teste';
//          enderecoTO.numeroLogradouro = 'Teste';
//          enderecoTO.complemento      = 'Teste';
//          enderecoTO.bairro           = 'Teste';
//          enderecoTO.cidade           = 'Teste';
//          enderecoTO.uf               = 'Teste';
//          enderecoTO.paisResidencia   = 'Teste';
//          enderecoTO.cep              = 'Teste';
//          enderecoTO.complementoCep   = 'Teste';
//          enderecos.add(enderecoTO);
 
//          List<OrcamentoTO.TelefoneTO> telefones = new List<OrcamentoTO.TelefoneTO>();
//          OrcamentoTO.TelefoneTO telefonesTO = new OrcamentoTO.TelefoneTO();
//          telefonesTO.tipoTelefone   = 'Teste'; 
//          telefonesTO.dddTelefone    = 'Teste';
//          telefonesTO.numeroTelefone = 'Teste';
//          telefones.add(telefonesTO);
 
 
//          for(OrcamentoTO orcamentoTO :objOrcamento.orcamentos){
 
//              orcamentoTO.solicitacaoOferta.tipoSeguro = 'CAN';
//              orcamentoTO.solicitacaoOferta.empresa = '1';
//              orcamentoTO.solicitacaoOferta.sucursal = '1';
//              orcamentoTO.solicitacaoOferta.ramo = '1';
//              orcamentoTO.solicitacaoOferta.tipoEndosso = '1';
//              orcamentoTO.solicitacaoOferta.apolice = contrato.name;
 
//              for(OrcamentoTO.ContratanteTO contratante :orcamentoTO.solicitacaoOferta.contratantes)
//              {
//                  contratante.dadosPagamento = dadospagamentoTO;
//                  contratante.pessoa = pessoaTO;
//                  contratante.pessoa.dadosPessoaFisica = fisicaTO;
//                  contratante.pessoa.telefones = telefones;
//                  contratante.pessoa.enderecos = enderecos;                
 
//                  for(OrcamentoTO.GrupoTO gruposTO  :contratante.grupos)
//                  {
//                      for(OrcamentoTO.SeguradoTO seguradoTO  :gruposTO.segurados)
//                      {
//                          seguradoTO.pessoa = pessoaTO;
//                          seguradoTO.pessoa.dadosPessoaFisica = fisicaTO;
//                          seguradoTO.pessoa.telefones = telefones;
//                          seguradoTO.pessoa.enderecos = enderecos;                
//                      }
//                  }
//              }
//          } 
 
//          Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payload, 200, 'OK'));
 
//          RestRequest request = new RestRequest();
//          request.requestUri ='/apivida/vida/dev/v1/propostas/oferta/massificados/cancelamento';
//          request.httpMethod = 'POST';
//          request.requestBody = Blob.valueOf(payload);
//          RestResponse res = new RestResponse();
        
//          RestContext.response = res;
//          RestContext.request = request;
 
//          Test.startTest();
 
//          QuoteBO.getInstance().gerarPropostaCancelamento(opps, objOrcamento);
 
//          Test.stopTest();
//      }
//      //PLV-5098 - FIX01 - FIM
 
//      @IsTest
//      static void testobterProposta(){
//          Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
 
//          Test.startTest();
//          QuoteBO.getInstance().obterProposta(proposta.Name);
//          Test.stopTest();
//      }
 
//      @IsTest
//      static void testbuscarListVidaProposta(){
     
//          Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
 
//          Test.startTest();
//          QuoteBO.getInstance().buscarListVidaProposta(proposta.Id);
//          Test.stopTest();
//      }
 
    //  @IsTest
    //  static void testbuscarPerguntasQuestionario(){
     
    //      Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
 
    //      Test.startTest();
    //      QuoteBO.getInstance().buscarPerguntasQuestionario(proposta.Id);
    //      Test.stopTest();
    //  }
    //II-167 INICIO
    @IsTest
    static void testbuscarbuscarRemuneracaoProposta(){
    
        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
        Test.startTest();
        QuoteBO.getInstance().buscarRemuneracaoProposta(proposta.Id);
        Test.stopTest();
    }   
 
    @IsTest
    static void testbuscarRemuneracaoOrcamentoNoOrcamento(){
    
        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
        Test.startTest();
        QuoteBO.getInstance().buscarRemuneracaoOrcamentoNoOrcamento(proposta.Id);
        Test.stopTest();
    }

    @isTest
    static void testValidarDadosPagamentoSeguradoProposta() {

        List<ContratanteProposta__c> listSeguradoProposta = [SELECT Id, FormaPagamento__c, Proposta__c, ResponsavelPagamento__c, QuantidadeParcelas__c, EnderecoBoleto__c FROM ContratanteProposta__c];
        QuoteBO quoteBOInstance = new QuoteBO();
        Test.startTest();
        quoteBOInstance.validarDadosPagamentoSeguradoProposta(listSeguradoProposta);
        Test.stopTest();
    }

    @isTest
    static void validarDadosPagamentoVidaPropostaTest() {

        List<SeguradoProposta__c> listSeguradoProposta = [SELECT Id, FormaPagamento__c, ResponsavelPagamento__c, GrupoProposta__c, EnderecoBoleto__c FROM SeguradoProposta__c];
        QuoteBO quoteBOInstance = new QuoteBO();
        Test.startTest();
        quoteBOInstance.validarDadosPagamentoVidaProposta(listSeguradoProposta);
        Test.stopTest();      
    }
    //II-167 FIM
    //FCVEP-39 - INICIO
    @IsTest
    static void testarLimparCamposReemissao(){
        
        Test.startTest();
       
        List<Quote> proposta = [SELECT Id, sucursalReemissao__c, ramoReemissao__c , apoliceReemissao__c, Tipo__c FROM Quote];
        
        QuoteBO.getInstance().limparCamposReemissao(proposta);
        
        Test.stopTest();
        
    }
    //FCVEP-39 - FIM
 
//      @IsTest
//      static void testBuscarRamoSeguro(){
     
//          Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
 
//          Test.startTest();
//          QuoteBO.getInstance().BuscarRamoSeguro(new Set<Id>{produto.Id});
//          Test.stopTest();
//      }
 
//      @IsTest
//      static void testModalidadeDAO(){
     
//          Modalidade__c modalidade = [SELECT Id, Codigo__c FROM Modalidade__c LIMIT 1];
 
//          Test.startTest();
//          ModalidadeDAO.getInstance().Obter(modalidade.Codigo__c);
//          Test.stopTest();
//      }
 
//      //PLV-5098 - FIX01 - INICIO
//      @isTest
//      static void testCalcularVigencia() {
//          Quote proposta = [SELECT DataEmissao__c, VigenciaInicial__c, VigenciaFinal__c FROM Quote LIMIT 1][0];
 
//          Integer days = proposta.VigenciaInicial__c.daysBetween(proposta.VigenciaFinal__c);
//          Date vigenciaFinalEsperada = proposta.VigenciaInicial__c.addDays(days);
 
//          Test.startTest();
//          QuoteBO.getInstance().calcularVigencia(proposta);
//          Test.stopTest();
 
//          System.assertEquals(System.today(), proposta.VigenciaInicial__c);
//          System.assertEquals(vigenciaFinalEsperada, proposta.VigenciaFinal__c);
//      }
//      //PLV-5098 - FIX01 - FIM
 
//      //PLV-2932 - Inicio - Metodo criado para aumento de cobertura	
//      @isTest	
//      static void testAtualizarDataEmissao(){
//          Test.startTest();
//         Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
//         RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
//         DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
//         Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
 
//         Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
//         produtoTecnico.Status__c = 'Em ativação';
//         produtoTecnico.NumeroSusep__c = '123';
//         produtoTecnico.VersaoRenovacao__c = 'Versão atual';
//         update produtoTecnico;
//         produtoTecnico.Status__c = 'Ativo';
//         update produtoTecnico;
//         Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
 
//         Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
 
//         Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
 
//         proposta.Status = 'Contratada';
//         update proposta;
//         Test.stopTest();
//     }
//     //PLV-2932 - Fim - Metodo criado para aumento de cobertura
//      //PLV-4337 - INÍCIO
//      @isTest
//      static void testAtualizarDataVencimento(){
//          Test.startTest();
         
//          Profissao__c profissao = ( Profissao__c ) new ProfissaoFactory().createRecord();
 
//          //PLV-5098 - FIX01 - INICIO
//          /*profissao.Name = 'Testador';
//          update profissao;*/
//          //PLV-5098 - FIX01 - FIM
         
//          Account conta = ( Account ) new AccountFactory.PessoaFisica().createRecord();
//          RamoSeguro__c ramoSeguro = ( RamoSeguro__c ) new RamoSeguroFactory( conta ).createRecord();
//          DadosCorretor__c dadosCorretor = ( DadosCorretor__c ) new DadosCorretorFactory( conta ).createRecord();
//          Modalidade__c modalidade = ( Modalidade__c ) new ModalidadeFactory( ramoSeguro ).createRecord();
 
//          Product2 produtoTecnico = ( Product2 ) new ProdutoFactory.ProdutoTecnico().createRecord();
//          produtoTecnico.Status__c = 'Em ativação';
//          produtoTecnico.NumeroSusep__c = '123';
//          produtoTecnico.VersaoRenovacao__c = 'Versão atual';
//          update produtoTecnico;
//          produtoTecnico.Status__c = 'Ativo';
//          update produtoTecnico;
//          Product2 produtoComercial = ( Product2 ) new ProdutoFactory.ProdutoComercial( produtoTecnico ).createRecord();
 
//          Opportunity orcamento = ( Opportunity ) new OrcamentoFactory.VidaIndividual( produtoComercial, conta ).createRecord();
//          orcamento.DataVencimento__c = System.today().addDays( 5 );
//          update orcamento;
         
//          ParametroVigencia__c pv = TestDataFactory.gerarParametroVigenciaProdutoComercial( produtoComercial );
//          pv.ValidadeOrcamento__c = 5;
//          pv.ValidadeProposta__c = 10;
//          update pv;
 
//          String parceiro = '67708896000140';
//          Quote proposta = PropostaFactory.get( produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade, '18-00006768', parceiro );
 
//          try {
//              insert proposta;
//              Quote propostaInserida = [ SELECT Id, DataVencimento__c FROM Quote WHERE Parceiro__c =: parceiro LIMIT 1 ];
//              System.debug( 'Data de vencimento da proposta inserida: ' + propostaInserida.DataVencimento__c );
//              delete propostaInserida;
//          } catch( Exception e ) {
//              System.debug( 'Erro ao inserir proposta com data de vencimento: ' + e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage() );
//          }
         
//          Quote proposta2 = PropostaFactory.get( produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade, '18-00006768', parceiro );
//          proposta2.Status = 'TODO: <<Em análise>>';
//          try {
//              insert proposta2;
//              Quote propostaInserida2 = [ SELECT Id, DataVencimento__c FROM Quote WHERE Parceiro__c =: parceiro LIMIT 1 ];
//              System.debug( 'Data de vencimento da proposta inserida: ' + propostaInserida2.DataVencimento__c );
//              delete propostaInserida2;
//          } catch( Exception e ) {
//              System.debug( 'Erro ao inserir proposta com data de vencimento: ' + e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage() );
//          }
         
//          Quote proposta3 = PropostaFactory.get( produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade, '18-00006768', parceiro );
//          orcamento.DataVencimento__c = null;
//          update orcamento;
//          try {
//              insert proposta3;
//              Quote propostaInserida3 = [ SELECT Id, DataVencimento__c FROM Quote WHERE Parceiro__c =: parceiro LIMIT 1 ];
//              System.debug( 'Data de vencimento da proposta inserida: ' + propostaInserida3.DataVencimento__c );
//              delete propostaInserida3;
//          } catch( Exception e ) {
//              System.debug( 'Erro ao inserir proposta com data de vencimento: ' + e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage() );
//          }
 
//          Test.stopTest();
//      }
//      //PLV-4337 - FIM
     
//      //PLV-4980 INICIO
//      @isTest
//      public static void TestsendEmailRecusaProposta(){
//          List<Quote> lstproposta = [SELECT Id, Name, CodigoCorretor__c, isRecusadaSumariamente__c, Status FROM Quote LIMIT 1 ];
//          Map<Id, Quote> mapPropostaAntiga = new Map<Id, Quote>(); 
//          List<Quote> lstpropostaAntiga = new List<Quote>();
 
//          for(Quote proposta : lstproposta){
//              proposta.Status = 'Em análise';
//              proposta.isRecusadaSumariamente__c = false;
//              mapPropostaAntiga.put(proposta.Id, proposta);
//          }
 
         
     
//          Id corretorId = lstproposta[0].CodigoCorretor__c;
         
//          List<DadosCorretor__c> lstCorretor = [SELECT Id, NomeCorretor__r.Email__c, Tipo__c FROM DadosCorretor__c WHERE Id=: corretorId LIMIT 1];
//          for(DadosCorretor__c dadoCorretor : lstCorretor){
//              dadoCorretor.NomeCorretor__r.Email__c = 'e@email.com';
//              dadoCorretor.Tipo__c = 'Principal';
//          }
//          update lstCorretor;
 
//          for(Quote proposta : lstproposta){
//              proposta.Status = 'Recusada';
//              proposta.isRecusadaSumariamente__c = true;
//              proposta.CodigoCorretor__c = lstCorretor[0].Id;
//          }
         
//          update lstproposta;
     
//          Test.startTest();
//              QuoteBO.getInstance().sendEmailRecusaProposta(lstproposta,mapPropostaAntiga);
//          Test.stopTest();
               
//      }
//      //PLV-4980 FIM
 
 
//      // PLV-5190 - INICIO
//      @IsTest
//      static void testGerarContratoEndossoInvalido(){
 
//          // Mock para callout
//          StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadContrato' LIMIT 1];
//          String payload = staticResource.Body.toString();
 
//          String payloadReturn = '{"contrato": {"codigoEmpresa": "22","codigoSucursal": "999","ramoSeguro": "1391","numeroApolice": "14889","numeroEndosso": "0"},"integracoesObrigatorias": [],"integracoesComplementares": []}';
 
//          Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
 
//          RestRequest request = new RestRequest();
//          request.requestUri ='/apivida/vida/dev/v1/contratos/emissao';
//          request.httpMethod = 'POST';
//          request.requestBody = Blob.valueOf(payload);
//          RestResponse res = new RestResponse();
 
//          RestContext.response = res;
//          RestContext.request = request;
 
//          // Recupera contrato original
//          List<Contract> listContrato = [SELECT Id,Empresa__c,Sucursal__c, RamoSeguro__c, RamoSeguro__r.Codigo__c, NumeroApolice__c, Status, AccountId FROM Contract];
 
//          Contract contrato = listContrato[0];
//          contrato.Status = 'Emitido';
//          contrato.MeioComercializacao__c = 'ARQ';
//          contrato.Tipo__c = 'Novo';
//          update contrato;
 
//          // Gerar proposta de cancelamento
//          Quote proposta = [SELECT Id, Empresa__c, RamoSeguro__c, RamoSeguro__r.Codigo__c, OpportunityId, Modalidade__c, Status, Massificados__c FROM Quote LIMIT 1];
//          proposta.MeioComercializacao__c = 'ARQ';
//          proposta.Massificados__c = true;
//          proposta.Status = 'Contratada';
//          proposta.Tipo__c = 'Novo';
//          update proposta;
 
//          Product2 produtoComTelemak2 = [SELECT Id FROM Product2 WHERE ProductCode = 'APTLMKT' LIMIT 1]; //TKCL-246 FIX05 INICIO/FIM
 
//          Quote propostaCancelamento = proposta.clone(false,true);
//          propostaCancelamento.Name = '18-00000456';
//          propostaCancelamento.NumeroProposta__c = '00000456';
//          propostaCancelamento.NumeroPropostaUnico__c = '18-00000456';
//          propostaCancelamento.Status = 'Em análise';
//          propostaCancelamento.Tipo__c = 'Cancelamento';
//          propostaCancelamento.ContractId = contrato.Id;
//          propostaCancelamento.Massificados__c = true;
//          propostaCancelamento.MeioComercializacao__c = 'ARQ';
//          propostaCancelamento.Produto__c = produtoComTelemak2.Id; //TKCL-246 FIX05 INICIO/FIM
//          insert propostaCancelamento;
 
//          propostaCancelamento.Status = 'Disponível para contratação';
 
//          //TKCL-246 FIX05 INICIO
//         // Gera o contrato de endosso cancelamento com Endosso 'zero' para simular erro
//          // Contract contratoCancelamento = contrato.clone(false, true);
//          // contratoCancelamento.Name = ContractBO.getInstance().gerarNameContrato(contrato.Empresa__c, contrato.Sucursal__c, contrato.RamoSeguro__r.Codigo__c, contrato.NumeroApolice__c,'1');
//          // contratoCancelamento.Endosso__c = '0'; //Endosso zero
//          // contratoCancelamento.Tipo__c = 'Cancelamento';
//          // contratoCancelamento.AccountId = contrato.AccountId;
//          // contratoCancelamento.Status = 'Em elaboração';
//          // contratoCancelamento.Proposta__c = propostaCancelamento.Id;
//          // contratoCancelamento.MeioComercializacao__c = 'ARQ';
//          // insert contratoCancelamento;
//          //TKCL-246 FIX05 FIM
 
//          Test.startTest();
//          update propostaCancelamento;
//          Test.stopTest();
 
//          //TKCL-246 FIX05 INICIO
//          // Verifica se o contrato de cancelamento foi gerado
//          // System.assert(contratoCancelamento != null);
//          // System.assertEquals('Em elaboração',contratoCancelamento.Status);
//          // System.assertEquals('Cancelamento',contratoCancelamento.Tipo__c);
//          //TKCL-246 FIX05 FIM
 
//      }
     // PLV-5190 - FIM
 }