/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-29
 * @description Beneficiário Garantia Classe de Teste
 */
 @isTest
public class BeneficiarioGarantiaTest {

	@isTest
	public static void validarEfetuaPagamentoPago(){
        Test.setMock(HttpCalloutMock.class, new ConsultaCivTestMock()); //PLV-4002
        
		Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
		Account contaJuridica = (Account) new AccountFactory.PessoaJuridica().createRecord();
		
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();

		ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();

		FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaFisica, formaPagamento).createRecord();

		Contact contato = (Contact) new ContactFactory().createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaFisica, produtoComercial, parceiro).createRecord();
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaFisica, grupo).createRecord();
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
		//PLV-4559 - INICIO
         garantiaSegurado.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
         garantiaSegurado.Limite_de_Uso__c = 900;
         update garantiaSegurado;
        //PLV-4559 -FIM
        
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaFisica).createRecord();
	//	Test.startTest(); //PLV-4707 Inicio-Fim  // LECVPV-140-FIX06 INICIO/FIM
        casoSinistro.ContactId = contato.id;
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
        casoSinistro.NumeroSinistro__c = '321';
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Em Análise';
        casoSinistro.Segurado_do_Contrato__c = segurado.id;
        //PLV-2433 - Inicio - Criado campo para reparar a classe de teste
        casoSinistro.ProcessaNumeroSinistro__c = true;
        //PLV-2433 - Fim - Criado campo para reparar a classe de teste
        update casoSinistro;
		//	Test.stopTest(); //PLV-4707 Inicio-Fim  // LECVPV-140-FIX06 INICIO/FIM

		InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
		PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
		pag.Valor_indenizado__c = 150; //PLV-4070 - INICIO/FIM		// LECVPV-200 INICIO/FIM
		update pag;
		BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaFisica, infoBan, pag).createRecord();

			infoBan.StatusIntegracao__c = 'Validada';
        	update infoBan;
            //  if(LstPagos.Size() > 0 && LstNaoPagos.size() > 0){ 
              
            PagamentoGarantia__c paggaran = new PagamentoGarantia__c();
            paggaran.Caso__c = pag.Caso__c;
			paggaran.Garantia_do_segurado_do_contrato__c = pag.Garantia_do_segurado_do_contrato__c;
			paggaran.Name = 'TestPagamentoGarantia';
			paggaran.Motivo_da_Recusa__c = '1'; // PLV-4002
			paggaran.Fase__c = 'Aberto';
			paggaran.Status_do_pagamento__c = 'Cancelado';
			paggaran.Capital__c = 100000; //PLV-4070 - INICIO/FIM			
			paggaran.ValorIndenizadoInicial__c = 50; //PLV-4070 - INICIO/FIM
			
        	insert paggaran;

			bene.Status__c = 'Liberado';
			bene.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
			bene.Data_programada_do_pagamento__c = system.today() + 2;
			bene.StatusSerasa__c = 'Atualizado';
        	bene.Percentual_de_indenizacao__c = 0.20; //PLV-4428 - INICIO/FIM // LECVPV-200 INICIO/FIM
			update bene;

			Test.startTest(); // LECVPV-140-FIX06 INICIO/FIM
        	BeneficiarioGarantia__c bene3 = new BeneficiarioGarantia__c();
        	//PLV-2403-Inicio - Campo criado por ser obrigatório.
			bene3.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
			//bene3.InformarIndenizacao__c = '% de Indenização';
			bene3.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
			bene3.ValorIndenizacao__c = 50.00; //PLV-4070 - INICIO/FIM
			//PLV-2403-Fim - Campo criado por ser obrigatório.
			bene3.Conta__c = bene.Conta__c;
			bene3.Informacao_bancaria__c = bene.Informacao_bancaria__c;
			bene3.Pagamento_de_garantia__c = bene.Pagamento_de_garantia__c;
        	bene3.Status__c = 'Pendente';
        	bene3.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
			bene3.Data_programada_do_pagamento__c = system.today() + 2;
        
        	insert bene3;

			bene.Status__c = 'Aguardando Pagamento';
			update bene;
           
        	bene.Status__c = 'Pago';
			BeneficiarioGarantiaTriggerHandler.criarMovimento = true; // LECVPV-174 INICIO/FIM
			update bene;

			bene3.Status__c = 'Aguardando Pagamento';
			update bene3;
			Test.stopTest(); // LECVPV-140-FIX06 INICIO/FIM
        	//PLV-4559 - INICIO       	
			try {
					bene3.Status__c = 'Pago';
					// LECVPV-200 INICIO
					bene3.Permitir_Alteracao__c= true; 
					BeneficiarioGarantiaTriggerHandler.isFirstTime = true;
					// LECVPV-200 FIM	
				update bene3;
				} catch(DmlException e) {
					System.debug('The following exception has occurred: ' + e.getMessage());
				}
			//PLV-4559 - FIM
	}
    

	@isTest
	public static void validarPreencherIdExterno(){
        Test.setMock(HttpCalloutMock.class, new ConsultaCivTestMock()); //PLV-4002

		Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
		PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord();
		InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(conta).createRecord();

		BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(conta, infoBan, pag).createRecord();



	}
	//PLV-2403 - Inicio - Metodo criado para aumentar a cobertura da classe de teste.
	@isTest
	public static void atualizaValoreseValidaSomatoria() {
        Test.setMock(HttpCalloutMock.class, new ConsultaCivTestMock()); //PLV-4002
		Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
		Account contaJuridica = (Account) new AccountFactory.PessoaJuridica().createRecord();
		
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();

		ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();

		FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaFisica, formaPagamento).createRecord();

		Contact contato = (Contact) new ContactFactory().createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaFisica, produtoComercial, parceiro).createRecord();
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaFisica, grupo).createRecord();
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
		//PLV-4559 - INICIO
         garantiaSegurado.Tipo_de_limite_de_utilizacao__c = 'Monetário';
         garantiaSegurado.Limite_de_Uso__c = 900;
         update garantiaSegurado;
        //PLV-4559 -FIM
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaFisica).createRecord();

        casoSinistro.ContactId = contato.id;
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
        casoSinistro.NumeroSinistro__c = '444';
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Em Análise';
        casoSinistro.Segurado_do_Contrato__c = segurado.id;
        //PLV-2433 - Inicio - Criado campo para reparar a classe de teste
        casoSinistro.ProcessaNumeroSinistro__c = true;
        //PLV-2433 - Fim - Criado campo para reparar a classe de teste
        update casoSinistro;

        InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
		PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
		Test.startTest(); //PLV-4707 Inicio-Fim  // LECVPV-216 INICIO/FIM
		BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaFisica, infoBan, pag).createRecord();

			infoBan.StatusIntegracao__c = 'Validada';
        	update infoBan;

        	PagamentoGarantia__c paggaran = new PagamentoGarantia__c();
            paggaran.Caso__c = pag.Caso__c;
			paggaran.Garantia_do_segurado_do_contrato__c = pag.Garantia_do_segurado_do_contrato__c;
			paggaran.Name = 'TestPagamentoGarantia';
			paggaran.Fase__c = 'Aberto';
        	paggaran.Status_do_pagamento__c = 'Em análise';
			paggaran.Capital__c = 10000.00;
			paggaran.Valor_indenizado__c = 50; //PLV-4070 - INICIO/FIM

        	insert paggaran;

        	BeneficiarioGarantia__c benef = new BeneficiarioGarantia__c();
			benef.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
			// benef.InformarIndenizacao__c = '% de Indenização'; //PLV-4070 - INICIO/FIM
			benef.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
			benef.ValorIndenizacao__c = 50.00; //PLV-4070 - INICIO/FIM
			benef.Conta__c = bene.Conta__c;
			benef.Pagamento_de_garantia__c = paggaran.Id;
        	benef.Status__c = 'Pendente';
        	benef.Tipo_de_Pagamento__c = 'Cheque';
        	benef.Sucursal_Destino_de_Cheque__c = 10;
			benef.Data_programada_do_pagamento__c = system.today() + 2;

			insert benef;

			BeneficiarioGarantia__c benef2 = new BeneficiarioGarantia__c();
			benef2.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
			benef2.InformarIndenizacao__c = 'Valor de Indenização';
			benef2.ValorIndenizacao__c = 50.00; //PLV-4070 - INICIO/FIM
			benef2.Conta__c = bene.Conta__c;
			benef2.Pagamento_de_garantia__c = paggaran.Id;
        	benef2.Status__c = 'Pendente';
        	benef2.Tipo_de_Pagamento__c = 'Cheque';
        	benef2.Sucursal_Destino_de_Cheque__c = 10;
			benef2.Data_programada_do_pagamento__c = system.today() + 2;

			insert benef2;

			benef.Status__c = 'Aguardando Pagamento';
			update benef;
        
        	benef.Status__c = 'Pago';
			update benef;

			benef2.Status__c = 'Aguardando Pagamento';
			update benef2;
            //PLV-4559 - INICIO
        try {
             	benef2.Status__c = 'Pago';
                update benef2;
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
			}
		//PLV-4559 - FIM
			paggaran.Status_do_pagamento__c = 'Pago Parcialmente';
			Test.stopTest();//PLV-4707 Inicio-Fim // LECVPV-216 INICIO/FIM
	}
	//PLV-2403 - Fim - Metodo criado para aumentar a cobertura da classe de test.
}