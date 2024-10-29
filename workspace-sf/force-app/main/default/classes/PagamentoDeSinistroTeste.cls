// história: PLV-4065
// descrição da história: aviso de liquidação de sinistros
// Data de Criação: 31/07/2020
// Desenvolvedor: Tiago Welter - Sys4b
@isTest
private class PagamentoDeSinistroTeste {
    //MGRC-1657 - INICIO
	// @isTest
	// private static void inserePagamentoComParceiro() {
    //     //PLV-4772-INICIO
    //     GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
    //     GrupoRisco__c grupoRisco = new GrupoRisco__c();
    //     Profissao__c profissao = new Profissao__c();

    //     profissao.CodigoProfissao__c = '2111-05';
    //     profissao.Name = 'Atuário';
    //     profissao.Status__c = 'Ativo';
    //     insert profissao;
    //     grupoRisco.Name = 'DIT';
    //     Insert grupoRisco;
    //     grupoProfissao.grupoRisco__c = grupoRisco.Id;
    //     grupoProfissao.profissao__c = profissao.Id;
    //     insert grupoProfissao;
    //     //PLV-4772-FIM

    //     Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
    //     //PLV-4772-INICIO
    //     contaPessoal.Renda__c = 1902.00;
    //     contaPessoal.Profissao__c = profissao.Id;
    //     update contaPessoal;
    //     //PLV-4772-FIM 
    //     Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
    //     Contact contato = (Contact) new ContactFactory().createRecord();
    //     ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
    //     ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
    //     Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
    //     produtoTecnico.Status__c = 'Em ativação';
    //     produtoTecnico.NumeroSusep__c = '123';
    //     produtoTecnico.VersaoRenovacao__c = 'Versão atual';
    //     update produtoTecnico;
    //     produtoTecnico.Status__c = 'Ativo';
    //     update produtoTecnico;
    //     Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();

    //     FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
    //     Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
    //     ProdutoParceiro__c prodParc = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro, produtoComercial).createRecord();
    //     OperacaoProdutoParceiro__c oProdParc = (OperacaoProdutoParceiro__c) new OperacaoProdutoParceiroFactory(prodParc).createRecord();

    //     Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
    //     ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
    //     GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
    //     SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();

    //     RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
    //     RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
    //     GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
    //     //PLV-4772-INICIO
    //     garanProdTec.CancelaGarantia__c = true;
    //     garanProdTec.MomentoCancelamento__c = 'Pagamento';
    //     garanProdTec.PercentualMaximoCancelamento__c = 100;
    //     update garanProdTec;
    //     //PLV-4772-FIM
    //     GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

    //     DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
    //     TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
    //     RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
    //     FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

    //     ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

    //     Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
	//     InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
    //     //PLV-4772-INICIO
    //     GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
    //     garantiaSeguradoContrato.GarantiaProduto__c = garanProdTec.Id;
    //     update garantiaSeguradoContrato;
    //     GarantiaContrato__c garantiaContract = new GarantiaContrato__c();
    //     garantiaContract.Contrato__c = contrato.Id;
    //     garantiaContract.GarantiaProduto__c = garanProdTec.Id;    
    //     garantiaContract.Garantia__c = garantia.Id;
    //     insert garantiaContract;
    //     //PLV-4772-FIM
	// 	Recordtype REC_ID_CASESINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

	// 	Case casoSinistro =  new Case(
	// 			RecordTypeId = REC_ID_CASESINISTRO.Id,
	// 			Status = 'Avisar',
	// 			Status_Dependente__c = 'Em Análise',
	// 			Origin = 'Atendimento',
    //             Contrato__c = contrato.Id,
	// 			ParentId = casoAtendimento.Id,
	// 			AccountId = contaPessoal.Id,
	// 			Subject = 'Test Caso Sinistro',
	// 			Vitima__c = 'Filhos',
    //         	IdPrestadora__c = 'Teste',
	// 			Description = 'TestCasoSinistro',
	// 			Dataocorrencia__c = System.today(),
	// 			Type = 'Sinistro',
	// 			TipoEvento__c = 'Acidente');
	// 	insert casoSinistro;

    //     Case casoSinistro2 =  new Case(
	// 			RecordTypeId = REC_ID_CASESINISTRO.Id,
	// 			Status = 'Avisar',
	// 			Status_Dependente__c = 'Em Análise',
	// 			Origin = 'Atendimento',
    //             Contrato__c = contrato.Id,
	// 			ParentId = casoAtendimento.Id,
	// 			AccountId = contaPessoal.Id,
	// 			Subject = 'Test Caso Sinistro',
	// 			Vitima__c = 'Filhos',
	// 			Description = 'TestCasoSinistro',
	// 			Dataocorrencia__c = System.today(),
	// 			Type = 'Sinistro',
    //         	Lista_de_pendencias__c = 'RG',
	// 			TipoEvento__c = 'Acidente');
	// 	insert casoSinistro2;
    //     //PLV-4772-INICIO
    //     PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro2, garantiaSeguradoContrato).createRecord();
    //     pagamentoGarantia.Garantia_do_segurado_do_contrato__c =  garantiaSeguradoContrato.Id;
    //     update pagamentoGarantia;
    //     //PLV-4772-FIM
    //     Date dtPagamento = system.today().addDays(+20);
    //     //PLV-4772-INICIO
    //     String mock = '{"ofertas":[{'
    //                                 +'"orcamento":{'
    //                                     +'"numeroOrcamento":"32446"'
    //                                     +'}'
    //                                 +'}'
    //                             +']'
    //                             +'}';
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mock, 200, 'OK'));
    //     //PLV-4772-FIM
	// 	 Test.startTest();    
        
    //     	Integer emailbefore = Limits.getEmailInvocations();
        
    //     	//deve enviar apenas o e-mail para o corretor
    //     	Pagamento_de_Sinistro__c pagamento = new Pagamento_de_Sinistro__c();
    //         pagamento.Caso_de_Sinistro__c               = casoSinistro.Id;
    //         pagamento.Status__c                         = 'Liberado';
    //         pagamento.Data_Programada_de_Pagamento__c   = dtPagamento;
    //         insert pagamento;
    //         // LECVPV-200 INICIO
    //         pagamento.Status__c = 'Aprovada';
    //         update pagamento;
    //          // LECVPV-200 FIM
    //         pagamento.Status__c                         = 'Em pagamento';    //PLV-4772-INICIO/FIM    	
    //     	update pagamento;

    //     	//system.assertEquals(emailbefore,Limits.getEmailInvocations()-1,'Enviou mais de um email');

    //     	//deve enviar mais dois e-mails
    //    		Pagamento_de_Sinistro__c pagamento2 = new Pagamento_de_Sinistro__c();
    //         pagamento2.Caso_de_Sinistro__c               = casoSinistro2.Id;
    //         pagamento2.Status__c                         = 'Em pagamento'; //PLV-4772-INICIO/FIM        
    //         pagamento2.Data_Programada_de_Pagamento__c   = dtPagamento;
    //         //PLV-4772-INICIO
    //         pagamento2.Valor_total_a_ser_indenizado__c   = 1000;
    //         //PLV-4772-FIM
    //         insert pagamento2;
	//         //PLV-4772-INICIO
    //     	//system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'Não enviou email'); 
    //         Pagamento_de_Sinistro__c pagamento3 = new Pagamento_de_Sinistro__c();
    //         pagamento3.Caso_de_Sinistro__c               = casoSinistro2.Id;
    //         pagamento3.Status__c                         = 'Cancelado';
    //         pagamento3.Data_Programada_de_Pagamento__c   = dtPagamento;
    //         pagamento2.Valor_total_a_ser_indenizado__c   = 1000000;
    //         pagamento3.Tipo_de_OP__c = 'Indenização';
    //         pagamento3.OP_SAP__c = casoSinistro.Id;
    //         insert pagamento3; 
    //         List<Pagamento_de_Sinistro__c> listPagamentos = new List<Pagamento_de_Sinistro__c>();
    //         listPagamentos.add(pagamento2);
    //         listPagamentos.add(pagamento3);
           
    //         set<Id> sCasos = new set<Id>();
    //         sCasos.add(casoSinistro2.Id);
    //         set<Id> sPag = new set<Id>();
    //         sPag.add(pagamento3.Id);
         
    //         PagamentoDeSinistroBO.gerarPayloadPagamento(sCasos);
            
    //         PagamentoDeSinistroBO.atualizaPagamentoExterno(sPag);
    //         PagamentoDeSinistroBO pagamentoBO = new PagamentoDeSinistroBO();
    //         pagamentoBO.atualizaAprovacaoPorValor(listPagamentos);
    //         //PLV-4772-FIM
    //     Test.stopTest();
    // }
    //MGRC-1657 - FIM

    //LECVP-344 - INICIO
    @isTest static void testarAtualizarValorPagoCaso(){

      //  Test.startTest();  // LECVPV-140-FIX08 INICIO/FIM

        GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        Profissao__c profissao = new Profissao__c();

        profissao.CodigoProfissao__c = '2111-05';
        profissao.Name = 'Atuário';
        profissao.Status__c = 'Ativo';
        insert profissao;
        grupoRisco.Name = 'DIT';
        Insert grupoRisco;
        grupoProfissao.grupoRisco__c = grupoRisco.Id;
        grupoProfissao.profissao__c = profissao.Id;
        insert grupoProfissao;

        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        contaPessoal.Renda__c = 1902.00;
        contaPessoal.Profissao__c = profissao.Id;
        update contaPessoal;

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        Contact contato = (Contact) new ContactFactory().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;

        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;

        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();

        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        ProdutoParceiro__c prodParc = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro, produtoComercial).createRecord();
        OperacaoProdutoParceiro__c oProdParc = (OperacaoProdutoParceiro__c) new OperacaoProdutoParceiroFactory(prodParc).createRecord();

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
     
        garanProdTec.CancelaGarantia__c = true;
        garanProdTec.MomentoCancelamento__c = 'Pagamento';
        garanProdTec.PercentualMaximoCancelamento__c = 100;
        update garanProdTec;

        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
	    InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
 
        GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        garantiaSeguradoContrato.GarantiaProduto__c = garanProdTec.Id;
        update garantiaSeguradoContrato;

        GarantiaContrato__c garantiaContract = new GarantiaContrato__c();
        garantiaContract.Contrato__c = contrato.Id;
        garantiaContract.GarantiaProduto__c = garanProdTec.Id;    
        garantiaContract.Garantia__c = garantia.Id;
        insert garantiaContract;

		Recordtype REC_ID_CASESINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

		Case casoSinistro =  new Case(
				RecordTypeId = REC_ID_CASESINISTRO.Id,
				Status = 'Avisar',
				Status_Dependente__c = 'Em Análise',
				Origin = 'Atendimento',
                Contrato__c = contrato.Id,
				ParentId = casoAtendimento.Id,
				AccountId = contaPessoal.Id,
				Subject = 'Test Caso Sinistro',
				Vitima__c = 'Filhos',
            	IdPrestadora__c = 'Teste',
				Description = 'TestCasoSinistro',
				Dataocorrencia__c = System.today(),
				Type = 'Sinistro',
				TipoEvento__c = 'Acidente');
		insert casoSinistro;

        PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSeguradoContrato).createRecord();
        pagamentoGarantia.Garantia_do_segurado_do_contrato__c =  garantiaSeguradoContrato.Id;
        update pagamentoGarantia;

        Date dtPagamento = system.today().addDays(+20);

        Pagamento_de_Sinistro__c pagamento = new Pagamento_de_Sinistro__c();
        pagamento.Caso_de_Sinistro__c               = casoSinistro.Id;
        pagamento.Status__c                         = 'Pago';
        pagamento.Data_Programada_de_Pagamento__c   = dtPagamento;
        insert pagamento;
        
        Test.startTest();  // LECVPV-140-FIX08 INICIO/FIM

        BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagamentoGarantia).createRecord();

        BeneficiarioGarantia__c benef = new BeneficiarioGarantia__c();
		benef.Percentual_de_indenizacao__c = 1.00; 
		benef.InformarIndenizacao__c = 'Valor de Indenização'; 
		benef.ValorIndenizacao__c = 50.00;
		benef.Conta__c = bene.Conta__c;
		benef.Pagamento_de_garantia__c = pagamentoGarantia.Id;
        benef.Status__c = 'Pendente';
        benef.Tipo_de_Pagamento__c = 'Cheque';
        benef.Sucursal_Destino_de_Cheque__c = 10;
		benef.Data_programada_do_pagamento__c = system.today() + 2;

		insert benef;

        benef.Status__c = 'Aguardando Pagamento';
		update benef;
        
        benef.Status__c = 'Pago';
		update benef;

        List<Pagamento_de_Sinistro__c> listaPgto = new List<Pagamento_de_Sinistro__c>();
        listaPgto.add(pagamento);

        //  Test.startTest();  // LECVPV-140-FIX08 INICIO/FIM

        PagamentoDeSinistroBO.getInstance().atualizarValorPagoCaso(listaPgto);

        Test.stopTest();
    }

    @isTest static void testarAtualizarValorPagoGarantia(){
        
        // Test.startTest();    // LECVPV-140-FIX08 INICIO/FIM

        GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        Profissao__c profissao = new Profissao__c();

        profissao.CodigoProfissao__c = '2111-05';
        profissao.Name = 'Atuário';
        profissao.Status__c = 'Ativo';
        insert profissao;
        grupoRisco.Name = 'DIT';
        Insert grupoRisco;
        grupoProfissao.grupoRisco__c = grupoRisco.Id;
        grupoProfissao.profissao__c = profissao.Id;
        insert grupoProfissao;

        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        contaPessoal.Renda__c = 1902.00;
        contaPessoal.Profissao__c = profissao.Id;
        update contaPessoal;

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        Contact contato = (Contact) new ContactFactory().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;

        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;

        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();

        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        ProdutoParceiro__c prodParc = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro, produtoComercial).createRecord();
        OperacaoProdutoParceiro__c oProdParc = (OperacaoProdutoParceiro__c) new OperacaoProdutoParceiroFactory(prodParc).createRecord();

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
     
        garanProdTec.CancelaGarantia__c = true;
        garanProdTec.MomentoCancelamento__c = 'Pagamento';
        garanProdTec.PercentualMaximoCancelamento__c = 100;
        update garanProdTec;

        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
	    InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
 
        GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        garantiaSeguradoContrato.GarantiaProduto__c = garanProdTec.Id;
        update garantiaSeguradoContrato;

        GarantiaContrato__c garantiaContract = new GarantiaContrato__c();
        garantiaContract.Contrato__c = contrato.Id;
        garantiaContract.GarantiaProduto__c = garanProdTec.Id;    
        garantiaContract.Garantia__c = garantia.Id;
        insert garantiaContract;

		Recordtype REC_ID_CASESINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

		Case casoSinistro =  new Case(
				RecordTypeId = REC_ID_CASESINISTRO.Id,
				Status = 'Avisar',
				Status_Dependente__c = 'Em Análise',
				Origin = 'Atendimento',
                Contrato__c = contrato.Id,
				ParentId = casoAtendimento.Id,
				AccountId = contaPessoal.Id,
				Subject = 'Test Caso Sinistro',
				Vitima__c = 'Filhos',
            	IdPrestadora__c = 'Teste',
				Description = 'TestCasoSinistro',
				Dataocorrencia__c = System.today(),
				Type = 'Sinistro',
				TipoEvento__c = 'Acidente');
		insert casoSinistro;

        PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSeguradoContrato).createRecord();
        pagamentoGarantia.Valor_Pago__c = 0;
        pagamentoGarantia.Garantia_do_segurado_do_contrato__c =  garantiaSeguradoContrato.Id;
        update pagamentoGarantia;

        Date dtPagamento = system.today().addDays(+20);

        Pagamento_de_Sinistro__c pagamento = new Pagamento_de_Sinistro__c();
        pagamento.Caso_de_Sinistro__c               = casoSinistro.Id;
        pagamento.Status__c                         = 'Pago';
        pagamento.Data_Programada_de_Pagamento__c   = dtPagamento;
        pagamento.Garantia_do_Sinistro__c = pagamentoGarantia.Id;
        insert pagamento;
        
        Test.startTest(); // LECVPV-140-FIX08 INICIO/FIM

        BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagamentoGarantia).createRecord();

        BeneficiarioGarantia__c benef = new BeneficiarioGarantia__c();
		benef.Percentual_de_indenizacao__c = 1.00; 
		benef.InformarIndenizacao__c = 'Valor de Indenização'; 
		benef.ValorIndenizacao__c = 50.00;
		benef.Conta__c = bene.Conta__c;
		benef.Pagamento_de_garantia__c = pagamentoGarantia.Id;
        benef.Status__c = 'Pendente';
        benef.Tipo_de_Pagamento__c = 'Cheque';
        benef.Sucursal_Destino_de_Cheque__c = 10;
		benef.Data_programada_do_pagamento__c = system.today() + 2;

		insert benef;

        benef.Status__c = 'Aguardando Pagamento';
		update benef;
        
        benef.Status__c = 'Pago';
		update benef;

        List<Pagamento_de_Sinistro__c> listaPgto = new List<Pagamento_de_Sinistro__c>();
        listaPgto.add(pagamento);


        PagamentoDeSinistroBO.getInstance().atualizarValorPagoGarantia(listaPgto);

        Test.stopTest(); // LECVPV-140-FIX08 INICIO/FIM
    }

    @isTest static void testarCalcularSaldResrvCaso(){
        
      //  Test.startTest();  // LECVPV-140-FIX08 INICIO/FIM

        GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        Profissao__c profissao = new Profissao__c();

        profissao.CodigoProfissao__c = '2111-05';
        profissao.Name = 'Atuário';
        profissao.Status__c = 'Ativo';
        insert profissao;
        grupoRisco.Name = 'DIT';
        Insert grupoRisco;
        grupoProfissao.grupoRisco__c = grupoRisco.Id;
        grupoProfissao.profissao__c = profissao.Id;
        insert grupoProfissao;

        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        contaPessoal.Renda__c = 1902.00;
        contaPessoal.Profissao__c = profissao.Id;
        update contaPessoal;

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        Contact contato = (Contact) new ContactFactory().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;

        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;

        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();

        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        ProdutoParceiro__c prodParc = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro, produtoComercial).createRecord();
        OperacaoProdutoParceiro__c oProdParc = (OperacaoProdutoParceiro__c) new OperacaoProdutoParceiroFactory(prodParc).createRecord();

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
     
        garanProdTec.CancelaGarantia__c = true;
        garanProdTec.MomentoCancelamento__c = 'Pagamento';
        garanProdTec.PercentualMaximoCancelamento__c = 100;
        update garanProdTec;

        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
	    InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
 
        GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        garantiaSeguradoContrato.GarantiaProduto__c = garanProdTec.Id;
        update garantiaSeguradoContrato;

        GarantiaContrato__c garantiaContract = new GarantiaContrato__c();
        garantiaContract.Contrato__c = contrato.Id;
        garantiaContract.GarantiaProduto__c = garanProdTec.Id;    
        garantiaContract.Garantia__c = garantia.Id;
        insert garantiaContract;

		Recordtype REC_ID_CASESINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

		Case casoSinistro =  new Case(
				RecordTypeId = REC_ID_CASESINISTRO.Id,
				Status = 'Avisar',
				Status_Dependente__c = 'Em Análise',
				Origin = 'Atendimento',
                Contrato__c = contrato.Id,
				ParentId = casoAtendimento.Id,
				AccountId = contaPessoal.Id,
				Subject = 'Test Caso Sinistro',
				Vitima__c = 'Filhos',
            	IdPrestadora__c = 'Teste',
				Description = 'TestCasoSinistro',
				Dataocorrencia__c = System.today(),
				Type = 'Sinistro',
				TipoEvento__c = 'Acidente');
		insert casoSinistro;

        PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSeguradoContrato).createRecord();
        pagamentoGarantia.Garantia_do_segurado_do_contrato__c =  garantiaSeguradoContrato.Id;
        update pagamentoGarantia;

        Date dtPagamento = system.today().addDays(+20);

        Pagamento_de_Sinistro__c pagamento = new Pagamento_de_Sinistro__c();
        pagamento.Caso_de_Sinistro__c               = casoSinistro.Id;
        pagamento.Status__c                         = 'Pago';
        pagamento.Data_Programada_de_Pagamento__c   = dtPagamento;
        pagamento.Garantia_do_Sinistro__c = pagamentoGarantia.Id;
        insert pagamento;

        BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagamentoGarantia).createRecord();

        BeneficiarioGarantia__c benef = new BeneficiarioGarantia__c();
		benef.Percentual_de_indenizacao__c = 1.00; 
		benef.InformarIndenizacao__c = 'Valor de Indenização'; 
		benef.ValorIndenizacao__c = 50.00;
		benef.Conta__c = bene.Conta__c;
		benef.Pagamento_de_garantia__c = pagamentoGarantia.Id;
        benef.Status__c = 'Pendente';
        benef.Tipo_de_Pagamento__c = 'Cheque';
        benef.Sucursal_Destino_de_Cheque__c = 10;
		benef.Data_programada_do_pagamento__c = system.today() + 2;
		insert benef;

        List<Pagamento_de_Sinistro__c> listaPgto = new List<Pagamento_de_Sinistro__c>();
        listaPgto.add(pagamento);

        List<MovimentoSinistro__c> listaMV = new List<MovimentoSinistro__c>();
        MovimentoSinistroBO movSinBO = MovimentoSinistroBO.getInstance();

        //LECVPV-140-FIX02 INICIO
        listaMV.add(movSinBO.criarMovimento(casoSinistro.Id, MovimentoSinistroTO.AVISO_MAIS, pagamentoGarantia.Capital__c, null, pagamentoGarantia.Id,true));
        listaMV.add(movSinBO.criarMovimento(casoSinistro.Id, MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS, pagamentoGarantia.Capital__c, null, pagamentoGarantia.Id,true));
        //LECVPV-140-FIX02 FIM

        insert listaMV;

        Test.startTest(); // LECVPV-140-FIX08 INICIO/FIM

        PagamentoDeSinistroBO.getInstance().calcularSaldResrvCaso(listaMV);

        Test.stopTest();
    }

    @isTest static void testarCalcularSaldResrvGarantia(){
        
       //  Test.startTest();  // LECVPV-140-FIX08 INICIO/FIM

        GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        Profissao__c profissao = new Profissao__c();

        profissao.CodigoProfissao__c = '2111-05';
        profissao.Name = 'Atuário';
        profissao.Status__c = 'Ativo';
        insert profissao;
        grupoRisco.Name = 'DIT';
        Insert grupoRisco;
        grupoProfissao.grupoRisco__c = grupoRisco.Id;
        grupoProfissao.profissao__c = profissao.Id;
        insert grupoProfissao;

        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        contaPessoal.Renda__c = 1902.00;
        contaPessoal.Profissao__c = profissao.Id;
        update contaPessoal;

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        Contact contato = (Contact) new ContactFactory().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;

        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;

        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();

        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        ProdutoParceiro__c prodParc = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro, produtoComercial).createRecord();
        OperacaoProdutoParceiro__c oProdParc = (OperacaoProdutoParceiro__c) new OperacaoProdutoParceiroFactory(prodParc).createRecord();

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
     
        garanProdTec.CancelaGarantia__c = true;
        garanProdTec.MomentoCancelamento__c = 'Pagamento';
        garanProdTec.PercentualMaximoCancelamento__c = 100;
        update garanProdTec;

        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
	    InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
 
        GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        garantiaSeguradoContrato.GarantiaProduto__c = garanProdTec.Id;
        update garantiaSeguradoContrato;

        GarantiaContrato__c garantiaContract = new GarantiaContrato__c();
        garantiaContract.Contrato__c = contrato.Id;
        garantiaContract.GarantiaProduto__c = garanProdTec.Id;    
        garantiaContract.Garantia__c = garantia.Id;
        insert garantiaContract;

		Recordtype REC_ID_CASESINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

		Case casoSinistro =  new Case(
				RecordTypeId = REC_ID_CASESINISTRO.Id,
				Status = 'Avisar',
				Status_Dependente__c = 'Em Análise',
				Origin = 'Atendimento',
                Contrato__c = contrato.Id,
				ParentId = casoAtendimento.Id,
				AccountId = contaPessoal.Id,
				Subject = 'Test Caso Sinistro',
				Vitima__c = 'Filhos',
            	IdPrestadora__c = 'Teste',
				Description = 'TestCasoSinistro',
				Dataocorrencia__c = System.today(),
				Type = 'Sinistro',
				TipoEvento__c = 'Acidente');
		insert casoSinistro;

        PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSeguradoContrato).createRecord();
        pagamentoGarantia.Garantia_do_segurado_do_contrato__c =  garantiaSeguradoContrato.Id;
        pagamentoGarantia.Id = null;
        insert pagamentoGarantia;

        Date dtPagamento = system.today().addDays(+20);

        Pagamento_de_Sinistro__c pagamento = new Pagamento_de_Sinistro__c();
        pagamento.Caso_de_Sinistro__c               = casoSinistro.Id;
        pagamento.Data_Programada_de_Pagamento__c   = dtPagamento;
        pagamento.Garantia_do_Sinistro__c = pagamentoGarantia.Id;
        pagamento.Garantia_do_Sinistro__r = pagamentoGarantia;
        pagamento.Garantia_do_Sinistro__r.Status_do_pagamento__c = 'Pago';
        pagamento.Garantia_do_Sinistro__r.Saldo_da_reserva__c = 0;
        insert pagamento;

        BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagamentoGarantia).createRecord();

        BeneficiarioGarantia__c benef = new BeneficiarioGarantia__c();
		benef.Percentual_de_indenizacao__c = 1.00; 
		benef.InformarIndenizacao__c = 'Valor de Indenização'; 
		benef.ValorIndenizacao__c = 1.00;
		benef.Conta__c = bene.Conta__c;
		benef.Pagamento_de_garantia__c = pagamentoGarantia.Id;
        benef.Status__c = 'Pendente';
        benef.Tipo_de_Pagamento__c = 'Cheque';
        benef.Sucursal_Destino_de_Cheque__c = 10;
		benef.Data_programada_do_pagamento__c = system.today() + 2;
		insert benef;

        pagamentoGarantia.Fase__c = 'Fechado';
        pagamentoGarantia.Status_do_pagamento__c = 'Pago';
        pagamentoGarantia.Valor_indenizado__c = 1000.00;
        update pagamentoGarantia;

        List<Pagamento_de_Sinistro__c> listaPgto = new List<Pagamento_de_Sinistro__c>();
        listaPgto.add(pagamento);

        List<MovimentoSinistro__c> listaMV = new List<MovimentoSinistro__c>();
        MovimentoSinistroBO movSinBO = MovimentoSinistroBO.getInstance();

        // LECVPV-140 INICIO
        listaMV.add(movSinBO.criarMovimento(casoSinistro.Id, MovimentoSinistroTO.AVISO_MAIS, pagamentoGarantia.Capital__c, null, pagamentoGarantia.Id,true));
        listaMV.add(movSinBO.criarMovimento(casoSinistro.Id, MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS, pagamentoGarantia.Capital__c, null, pagamentoGarantia.Id,true));
        // LECVPV-140 FIM

        insert listaMV;

        Test.startTest();  // LECVPV-140-FIX08 INICIO/FIM

        PagamentoDeSinistroBO.getInstance().calcularSaldResrvGarantia(listaMV);

        Test.stopTest();
    }
    //LECVP-344 - FIM
}