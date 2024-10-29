/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-29
 * @description PagamentoGarantia__c Classe de Teste
 */
 @isTest
public class PagamentoGarantiaTest {
    
    @isTest
	public static void validarEfetuaPagamentoGarantiaSinistro(){
        //Criando caso de Sinistro
        //Criando Conta
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        //Criando Caso de Atendimento
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro(contaPessoal).createRecord();
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        //PLV-4535 - FIX 6 INICIO
        casoSinistro.DataDocumentacaoCompleta__c = system.today();
        update casoSinistro;
        //PLV-4535 - FIX 6 FIM

	//Atualizando o caso de sinistro até fase: liquidação e status: pago
		//Atulizando CasoSinistro para fase: Avisado
			//Criando relacionamentos necessários para a alteração da fase do caso
				//Criando contato
				Contact contato = (Contact) new ContactFactory().createRecord();
				//Criando Contrato
					//Criando Produto Comercial
						//Criando ProdutoTecnico
							//Criando Contador Codigo
							ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	        				ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
	        			Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
	        				//Ativar o Produto Tecnico
	        					produtoTecnico.Status__c = 'Em ativação';
	        					produtoTecnico.NumeroSusep__c = '123';
	        					produtoTecnico.VersaoRenovacao__c = 'Versão atual';
	        				update produtoTecnico;
	        					produtoTecnico.Status__c = 'Ativo';
	        				update produtoTecnico;
	       	 		Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
	       	 		//Criando Parceiro	
	       	 			//Criando Forma de Pagamento
	       	 				FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
	        		Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
	        	Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();		
                Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        		RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
                RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
               
        		GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        		GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

       			 //Criando Garantia do Segurado do Contrato
	        		//Criando Garantia
	        			
	        		//Criando Contratante
	        			ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
	        		//Criando Grupo
	        			GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
	        		//Criando Segurado
	        		SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
                    GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
                    //PLV-4559 - INICIO
                    garantiaSegurado.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
                    garantiaSegurado.Limite_de_Uso__c = 900;
                    update garantiaSegurado;
                    //PLV-4559 -FIM
        			casoSinistro.ContactId = contato.id;
                    casoSinistro.Contrato__c = contrato.id;
                    casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
                    casoSinistro.NumeroSinistro__c = '321';
                    casoSinistro.Data_sinistro_avisado__c = System.today();
                    casoSinistro.Status = 'Avisado';
                    casoSinistro.Status_Dependente__c = 'Com Pendências';
                    casoSinistro.Segurado_do_Contrato__c = segurado.id;
                    //PLV-2433 - Inicio - Campo criado para reparar a classe de teste
					casoSinistro.ProcessaNumeroSinistro__c = true;
					//PLV-2433 - Inicio - Campo criado para reparar a classe de teste
                    update casoSinistro;

                    //Atualizando CasoSinistro para fase: Em Regulação
					casoSinistro.Status = 'Em Regulação';
                    update casoSinistro;

                    //Atualizando CasoSinistro para fase: Liquidação
                    CasoSinistro.Status = 'Liquidação';
                    CasoSinistro.Status_Dependente__c = 'Pago';
                    update CasoSinistro;

					//Criando Pagamento da Garantia
					PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
					system.debug('test gfs pag' + pag);

        pag.Fase__c = 'Em Análise';
        pag.Status_do_pagamento__c = 'Em Análise';
        update pag;
        test.startTest();
	//Criando Beneficiario da Garantia
		//Criando Infomação Bancária
		InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
		BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBan, pag).createRecord();
			
		//Atualizando Beneficiário para Liberado
			bene.Status__c = 'Liberado';
			bene.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
			bene.Data_programada_do_pagamento__c = system.today() + 2;
        	bene.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
			update bene;
       
			bene.Status__c = 'Pago';        
        	update bene;
        	
        pag.Fase__c = 'Fechado';
        //PLV-4198 - Inicio
        pag.Status_do_pagamento__c = 'Pago';
        //PLV-4198 - Fim
        update pag;
        
        test.stopTest();
		
	}

	@isTest
	public static void validarEfetuaPagamentoGarantiaBeneficio(){
		Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
		Case casoAtendimento = (Case) new CasoFactory.AtendimentoBeneficio(conta).createRecord();
		Case casoBeneficio = (Case) new CasoFactory.Beneficio(casoAtendimento, conta).createRecord();

		casoBeneficio.Status = 'Avisado';
		//PLV-2433 - Inicio - Campo criado para reparar a classe de teste
		casoBeneficio.ProcessaNumeroSinistro__c = true;
		//PLV-2433 - Inicio - Campo criado para reparar a classe de teste
		update casoBeneficio;

		casoBeneficio.Status = 'Em Regulação';
		update casoBeneficio;
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
	        		Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();
	    Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();

		ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
	    GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
	    SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo).createRecord();
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
		GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
		//PLV-4559 - INICIO
        garantiaSegurado.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
        garantiaSegurado.Limite_de_Uso__c = 900;
        update garantiaSegurado;
        //PLV-4559 -FIM
	    PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoBeneficio, garantiaSegurado).createRecord();

	    InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
		BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(conta, infoBan, pag).createRecord();
	
		bene.Status__c = 'Liberado';
		bene.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
		bene.Data_programada_do_pagamento__c = system.today() + 2;
		update bene;
       
        pag.Fase__c = 'Em Análise';
        pag.Status_do_pagamento__c = 'Em Análise';
        update pag;
        	
         //PLV-4559 - INICIO
        try {
             	bene.Status__c = 'Pago';        
        		update bene;
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
			}
		//PLV-4559 - FIM

        //PLV-1096 - Início/Fim - Código removido para adaptação da classe de teste

        pag.Fase__c = 'Fechado';
        pag.Status_do_pagamento__c = 'Serviço Prestado';
        update pag;
	}

	@isTest
	public static void validarEfetuaPagamentoGarantiaLoteBeneficio(){

		Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
		Case casoAtendimento = (Case) new CasoFactory.AtendimentoBeneficio(conta).createRecord();
		Case casoBeneficio = (Case) new CasoFactory.Beneficio(casoAtendimento, conta).createRecord();

		casoBeneficio.Status = 'Avisado';
		//PLV-2433 - Inicio - Campo criado para reparar a classe de teste
		casoBeneficio.ProcessaNumeroSinistro__c = true;
		//PLV-2433 - Inicio - Campo criado para reparar a classe de teste
		update casoBeneficio;

		casoBeneficio.Status = 'Em Regulação';
		update casoBeneficio;
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
	        		Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();
	    Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();

		ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
	    GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
	    SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo).createRecord();
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
		GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
		//PLV-4559 - INICIO
        garantiaSegurado.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
        garantiaSegurado.Limite_de_Uso__c = 900;
        update garantiaSegurado;
        //PLV-4559 -FIM
        
		List<PagamentoGarantia__c> lstPag = (List<PagamentoGarantia__c>) new PagamentoGarantiaFactory(casoBeneficio, garantiaSegurado).createRecords();

		List<PagamentoGarantia__c> lstPag2Update = new List<PagamentoGarantia__c>();
		List<PagamentoGarantia__c> lstServ2Update = new List<PagamentoGarantia__c>();
		List<PagamentoGarantia__c> lstRec2Update = new List<PagamentoGarantia__c>();
		List<PagamentoGarantia__c> lstAltFase = new List<PagamentoGarantia__c>();

		Test.startTest();
		update lstPag;

		for(PagamentoGarantia__c pag : lstPag){
			pag.Fase__c = 'Em Análise';
			pag.Status_do_pagamento__c = 'Em Análise';
			lstAltFase.add(pag);
		}

		update lstAltFase;

		for(PagamentoGarantia__c pag : lstPag){
			pag.Fase__c = 'Fechado';
			pag.Status_do_pagamento__c = 'Pago';
			lstPag2Update.add(pag);
		}

		update lstPag2Update;

		for(PagamentoGarantia__c pag: lstPag){
			pag.Fase__c = 'Fechado';
			pag.Status_do_pagamento__c = 'Serviço Prestado';
			lstServ2Update.add(pag);
		}

		update lstServ2Update;

		//PLV-1096 - Início/Fim - Código removido para adaptação da classe de teste

		Test.stopTest();
	}

	@isTest
	public static void validarEfetuaPagamentoGarantiaLoteSinistro(){
		Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
		Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro(contaPessoal).createRecord();
		Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        //PLV-4535 - FIX 6 INICIO
        casoSinistro.DataDocumentacaoCompleta__c = system.today();
        update casoSinistro;
        //PLV-4535 - FIX 6 FIM        

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
	        	Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();		
                Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        		RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
                RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
               
        		GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        		GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

       				ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
	        		GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
	        		SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
                    GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        			//PLV-4559 - INICIO
                    garantiaSegurado.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
                    garantiaSegurado.Limite_de_Uso__c = 900;
                    update garantiaSegurado;
                    //PLV-4559 -FIM            
        
                    casoSinistro.ContactId = contato.id;
                    casoSinistro.Contrato__c = contrato.id;
                    casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
                    casoSinistro.NumeroSinistro__c = '321';
                    casoSinistro.Data_sinistro_avisado__c = System.today();
                    casoSinistro.Status = 'Avisado';
                    casoSinistro.Status_Dependente__c = 'Com Pendências';
                    casoSinistro.Segurado_do_Contrato__c = segurado.id;
                    //PLV-2433 - Inicio - Campo criado para reparar a classe de teste
					casoSinistro.ProcessaNumeroSinistro__c = true;
					//PLV-2433 - Inicio - Campo criado para reparar a classe de teste
                    update casoSinistro;

                    //Atualizando CasoSinistro para fase: Em Regulação
                    casoSinistro.Status = 'Em Regulação';
                    update casoSinistro;

        List<PagamentoGarantia__c> lstPag = (List<PagamentoGarantia__c>) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecords();

		List<PagamentoGarantia__c> lstPag2Update = new List<PagamentoGarantia__c>();
		List<PagamentoGarantia__c> lstRec2Update = new List<PagamentoGarantia__c>();            
		List<PagamentoGarantia__c> lstAltFase = new List<PagamentoGarantia__c>();

		Test.startTest();
		update lstPag;

		for(PagamentoGarantia__c pag : lstPag){
			pag.Fase__c = 'Em Análise';
			pag.Status_do_pagamento__c = 'Em Análise';
			lstAltFase.add(pag);
		}

		update lstAltFase;

		for(PagamentoGarantia__c pag : lstPag){
			pag.Fase__c = 'Fechado';
			pag.Status_do_pagamento__c = 'Pago';
			lstPag2Update.add(pag);
		}

		update lstPag2Update;

		for(PagamentoGarantia__c pag: lstPag){
			pag.Fase__c = 'Fechado';
			pag.Status_do_pagamento__c = 'Recusado';
			lstRec2Update.add(pag);
		}

		update lstRec2Update;

		Test.stopTest();

	}

	@isTest
	public static void validarListarBeneficiarios(){
		Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
		Case casoAtendimentoSinistro = (Case) new CasoFactory.AtendimentoSinistro(conta).createRecord();
		Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimentoSinistro,conta).createRecord();
		SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory().createRecord();
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
		GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
		//PLV-4559 - INICIO
        garantiaSegurado.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
        garantiaSegurado.Limite_de_Uso__c = 900;
        update garantiaSegurado;
        //PLV-4559 -FIM
        PagamentoGarantia__c pagGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro,garantiaSegurado).createRecord();

		ContadorCodigo__c contCodigoTec2 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom2 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
		Product2 produtoTecnico2 = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
		produtoTecnico2.status__c = 'Em ativação';
		produtoTecnico2.numeroSusep__c = '15414.900476/2015-42';
		update produtoTecnico2;
		produtoTecnico2.Status__c = 'Ativo';
        update produtoTecnico2;
        Product2 produtoComercial2 = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico2).createRecord();
		
		Contact contato2 = (Contact) new ContactFactory().createRecord();
		FormaPagamento__c formaPagamento2 = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro2 = (Parceiro__c) new ParceiroFactory(conta, formaPagamento2).createRecord();

        Contract contrato2 = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial2, parceiro2).createRecord();
        ContratanteContrato__c contratante2 = (ContratanteContrato__c) new ContratanteFactory(contrato2).createRecord();
        GrupoContrato__c grupo2 = (GrupoContrato__c) new GrupoFactory(contratante2).createRecord();
        SeguradoContrato__c segurado2 = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo2).createRecord();
        GarantiaSeguradoContrato__c garantiaSegurado2 = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado2, garantia).createRecord();
		//PLV-4559 - INICIO
        garantiaSegurado2.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
        garantiaSegurado2.Limite_de_Uso__c = 900;
        update garantiaSegurado2;
        //PLV-4559 -FIM
        BeneficiarioSeguradoContrato__c  beneficiarios = (BeneficiarioSeguradoContrato__c ) new BeneficiarioSeguradoContratoFactory(conta, segurado2).createRecord();

		Test.startTest();
 
			//Codigo de implementação aqui
			casoSinistro.ContactId = contato2.id;		
            casoSinistro.Contrato__c = contrato2.id;
            casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado2.id;
            casoSinistro.NumeroSinistro__c = '321';
            casoSinistro.Data_sinistro_avisado__c = System.today();
            casoSinistro.Status = 'Avisado';
            casoSinistro.Status_Dependente__c = 'Em Análise';
            casoSinistro.Segurado_do_Contrato__c = segurado2.id;
            //PLV-2433 - Inicio - Campo criado para reparar a classe de teste
			casoSinistro.ProcessaNumeroSinistro__c = true;
			//PLV-2433 - Inicio - Campo criado para reparar a classe de teste
			update casoSinistro;

			pagGarantia.Fase__C = 'Em Análise';
			pagGarantia.Status_do_pagamento__c = 'Em análise';
			update pagGarantia;
			
			BeneficiarioGarantia__c bene = new BeneficiarioGarantia__c();
			// bene.InformarIndenizacao__c = '% de Indenização'; //PLV-4070 - INICIO/FIM
			bene.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
			bene.ValorIndenizacao__c = 10; //PLV-4070 - INICIO/FIM
			//PLV-2403 - Inicio - Criação para reparar a classe de teste.
			bene.Percentual_de_indenizacao__c = 10.000;
			//PLV-2403 - Fim - Criação para reparar a classe de teste.
			bene.Pagamento_de_garantia__c = pagGarantia.Id;
 			insert bene;
			 
			//PLV-4070 - INICIO
			BeneficiarioGarantia__c bene2 = new BeneficiarioGarantia__c();
			bene.InformarIndenizacao__c = 'Valor de Indenização';
			bene2.ValorIndenizacao__c = 20;
			bene2.Pagamento_de_garantia__c = pagGarantia.id;

			insert bene2;
			//PLV-4070 - FIM
		Test.stopTest();
	}
}