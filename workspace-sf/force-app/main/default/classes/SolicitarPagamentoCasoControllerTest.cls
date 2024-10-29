//PLV - 4043 inicio
@isTest
public class SolicitarPagamentoCasoControllerTest {

	//PLV-4374 - INICIO
	@isTest
    static void picklistValue(){
        String fielName = 'Tipo_de_Pagamento__c';
        Test.startTest();
        List<Object> lstPicklist = SolicitarPagamentoCasoController.picklistValue(fielName, true);
        SolicitarPagamentoCasoController.picklistValue(fielName, false);
        Test.stopTest();
    }
    
    @isTest
    static void updateTipoPagamento(){
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();       
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        Contact contato = (Contact) new ContactFactory().createRecord();
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Ativo';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        //Criando Caso Sinistro
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        
        //Atualizando o status do caso para 'Avisado'
        casoSinistro.ContactId = contato.id;
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
        casoSinistro.NumeroSinistro__c = '321';
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Com Pendências';
        casoSinistro.Segurado_do_Contrato__c = segurado.id;
        casoSinistro.ProcessaNumeroSinistro__c = true;
        casoSinistro.Sinistro_Judicial__c = true;
        update casoSinistro;
        
        PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        pag.Fase__c = 'Em Análise';
        pag.Status_do_pagamento__c = 'Em Análise';
        update pag;
        
        //PLV-4559 - INICIO
        Test.startTest();
        //Criando Informação Bancária
        InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        
        String resVerificaFase1 = SolicitarPagamentoCasoFilhoController.verificafase(pag.Id);
                        
        BeneficiarioGarantia__c bene1 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBan, pag).createRecord();
                
        Pagamento_de_Sinistro__c ps = new Pagamento_de_Sinistro__c();
        ps.Caso_de_Sinistro__c = casoSinistro.Id;
        ps.Tipo_de_Pagamento__c = 'Cheque';
        ps.Beneficiario_da_Garantia__c = bene1.Conta__c;
        ps.Data_Programada_de_Pagamento__c = Date.today();
        ps.Dados_Bancarios__c = infoBan.Id;
        Insert ps;
        
        bene1.Status__c = 'Liberado';
        bene1.Tipo_de_Pagamento__c = 'Cheque';
        bene1.Data_programada_do_pagamento__c = Date.today() + 2;
        bene1.StatusSerasa__c = 'Atualizado';	
        bene1.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
        bene1.Pagamento_de_Sinistro__c = ps.Id;
        update bene1;
        
        
        String result = SolicitarPagamentoCasoController.updateTipoPagamento(ps.Tipo_de_Pagamento__c, bene1, 'SÃO PAULO');
        Test.stopTest();
        //PLV-4559 - FIM
    }
    
    @isTest
    static void verificaFasePagamentoNoInformadoElse(){
     
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();       
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
       Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        Contact contato = (Contact) new ContactFactory().createRecord();
        
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        
		 SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        //Criando Caso Sinistro
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        
        //Atualizando o status do caso para 'Avisado'
        casoSinistro.ContactId = contato.id;
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
        casoSinistro.NumeroSinistro__c = '321';
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Com Pendências';
        casoSinistro.Segurado_do_Contrato__c = segurado.id;
        casoSinistro.ProcessaNumeroSinistro__c = true;
        update casoSinistro;
        
      	PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        pag.Fase__c = 'Em Análise';
        pag.Status_do_pagamento__c = 'Em Análise';
        update pag;
        PagamentoGarantia__c lpag = [select id, valor_indenizado__c, valorindenizado__c from PagamentoGarantia__c where id =: pag.Id]; 
        //Criando Informação Bancária
        InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        
        String resVerificaFase1 = SolicitarPagamentoCasoFilhoController.verificafase(pag.Id);
        
       
        casoSinistro.Sinistro_Judicial__c = true;
        update casoSinistro;
              
        BeneficiarioGarantia__c bene1 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBan, pag).createRecord();
        
        casoSinistro.Sinistro_Judicial__c = true;
        update casoSinistro;
        
        bene1.Status__c = 'Liberado';
        bene1.Tipo_de_Pagamento__c = null;
        bene1.Data_programada_do_pagamento__c = null;
        bene1.StatusSerasa__c = 'Atualizado';	
        bene1.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
        update bene1;
       
        Test.startTest();
        String resVerificaFase = SolicitarPagamentoCasoController.verificafase(casoSinistro.Id);
        Test.stopTest();
        
    }

    @isTest
    static void verificaFasePagamentoNoInformado(){
     
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();       
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();

       Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        Contact contato = (Contact) new ContactFactory().createRecord();
        
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        
		 SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        //Criando Caso Sinistro
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        
        //Atualizando o status do caso para 'Avisado'
        casoSinistro.ContactId = contato.id;
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
        casoSinistro.NumeroSinistro__c = '321';
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Com Pendências';
        casoSinistro.Segurado_do_Contrato__c = segurado.id;
        casoSinistro.ProcessaNumeroSinistro__c = true;
        update casoSinistro;
        
      	 PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        pag.Fase__c = 'Em Análise';
        pag.Status_do_pagamento__c = 'Em Análise';
        update pag;
        PagamentoGarantia__c lpag = [select id, valor_indenizado__c, valorindenizado__c from PagamentoGarantia__c where id =: pag.Id]; 
        //Criando Informação Bancária
        InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        
        String resVerificaFase1 = SolicitarPagamentoCasoFilhoController.verificafase(pag.Id);
        
       
        casoSinistro.Sinistro_Judicial__c = true;
        update casoSinistro;
              
        BeneficiarioGarantia__c bene1 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBan, pag).createRecord();
        
        casoSinistro.Sinistro_Judicial__c = true;
        update casoSinistro;
        
        bene1.Status__c = 'Liberado';
        bene1.Tipo_de_Pagamento__c = null;
        bene1.Data_programada_do_pagamento__c = null;
        bene1.StatusSerasa__c = 'Atualizado';	
        bene1.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
        update bene1;
        
         BeneficiarioGarantia__c bene2 = new BeneficiarioGarantia__c();
        bene2.Pagamento_de_garantia__c = pag.Id;
        bene2.Conta__c = contaPessoal.id;
        bene2.Status__c = 'Pendente';
        bene2.Tipo_de_Pagamento__c = 'Cheque';
        // bene2.InformarIndenizacao__c = '% de Indenização'; //PLV-4070 - INICIO/FIM
        bene2.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
        // bene2.Percentual_de_indenizacao__c = 20.000; //PLV-4070 - INICIO/FIM
        bene2.ValorIndenizacao__c = 20.00; //PLV-4070 - INICIO/FIM
        bene2.Sucursal_Destino_de_Cheque__c = 10;
        bene2.Data_programada_do_pagamento__c = system.today() + 2;
        bene2.StatusSerasa__c = 'Atualizado';
        bene2.ValorIndenizacao__c = 10; //PLV-4070 - INICIO/FIM
        insert bene2;
       
        Test.startTest();
        String resVerificaFase = SolicitarPagamentoCasoController.verificafase(casoSinistro.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void validVerificaFaseIf(){
     
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();       
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();

       Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        Contact contato = (Contact) new ContactFactory().createRecord();
        
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        
		 SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        //Criando Caso Sinistro
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        
        //Atualizando o status do caso para 'Avisado'
        casoSinistro.ContactId = contato.id;
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
        casoSinistro.NumeroSinistro__c = '321';
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Com Pendências';
        casoSinistro.Segurado_do_Contrato__c = segurado.id;
        casoSinistro.ProcessaNumeroSinistro__c = true;
        update casoSinistro;
        
      	 PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        pag.Fase__c = 'Em Análise';
        pag.Status_do_pagamento__c = 'Em Análise';
        update pag;
        PagamentoGarantia__c lpag = [select id, valor_indenizado__c, valorindenizado__c from PagamentoGarantia__c where id =: pag.Id]; 
        //Criando Informação Bancária
        InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        
        String resVerificaFase1 = SolicitarPagamentoCasoFilhoController.verificafase(pag.Id);
        
       
        casoSinistro.Sinistro_Judicial__c = true;
        update casoSinistro;
              
       
        Test.startTest();
        String resVerificaFase = SolicitarPagamentoCasoController.verificafase(casoSinistro.Id);
        Test.stopTest();
        
    }
	//PLV-4374 - FIM
    
	//PLV - 4043 FIX 07/08 INICIO
    @isTest
    static void validarVerificafase(){
        
        //Criando Garantia
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();       
        //Criando Conta Pessoal
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();

        //Criando Caso Atendimento Sinistro
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        //Criando contato
        Contact contato = (Contact) new ContactFactory().createRecord();
        
        //Criando Contador Codigo Produto Tecnico e Comercial
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        //Criando Forma de Pagamento
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        //Criando Parceiro e atualizando contrato
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        
        //Criando Produto Tecnico
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        //Criando Produto Comercial
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        //Criando Contrato
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        
        //Criando Contratante
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        
        //Criando Grupo
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        
        //Criando Segurado do Contrato
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        
        //Criando Garantia do Segurado do Contrato
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        //Criando Caso Sinistro
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        
        //Atualizando o status do caso para 'Avisado'
        casoSinistro.ContactId = contato.id;
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
        casoSinistro.NumeroSinistro__c = '321';
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Com Pendências';
        casoSinistro.Segurado_do_Contrato__c = segurado.id;
        casoSinistro.ProcessaNumeroSinistro__c = true;
        update casoSinistro;
        
        
        //Criando Pagamento de Garantia
        PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        pag.Fase__c = 'Em Análise';
        pag.Status_do_pagamento__c = 'Em Análise';
        update pag;
        PagamentoGarantia__c lpag = [select id, valor_indenizado__c, valorindenizado__c from PagamentoGarantia__c where id =: pag.Id]; 
        //Criando Informação Bancária
        InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        //Criando Beneficiario da Garantia
        BeneficiarioGarantia__c bene2 = new BeneficiarioGarantia__c();
        bene2.Pagamento_de_garantia__c = pag.Id;
        bene2.Conta__c = contaPessoal.id;
        bene2.Status__c = 'Pendente';
        bene2.Tipo_de_Pagamento__c = 'Cheque';
        // bene2.InformarIndenizacao__c = '% de Indenização'; //PLV-4070 - INICIO/FIM
        bene2.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
        // bene2.Percentual_de_indenizacao__c = 20.000; //PLV-4070 - INICIO/FIM
        bene2.ValorIndenizacao__c = 20.00; //PLV-4070 - INICIO/FIM
        bene2.Sucursal_Destino_de_Cheque__c = 10;
        bene2.Data_programada_do_pagamento__c = system.today() + 2;
        bene2.StatusSerasa__c = 'Atualizado';
        bene2.ValorIndenizacao__c = 10; //PLV-4070 - INICIO/FIM
        insert bene2;
        
        String resVerificaFase1 = SolicitarPagamentoCasoFilhoController.verificafase(pag.Id);
        
        BeneficiarioGarantia__c bene1 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBan, pag).createRecord();
        
        casoSinistro.Sinistro_Judicial__c = true;
        update casoSinistro;
        
        bene1.Status__c = 'Liberado';
        bene1.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
        bene1.Data_programada_do_pagamento__c = null;
        bene1.StatusSerasa__c = 'Atualizado';
        bene1.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
        update bene1;
        
        //Nome da Classe irá ser trocado
        String resVerificaFase = SolicitarPagamentoCasoController.verificafase(casoSinistro.Id);
        List<BeneficiarioGarantia__c> lstBene = SolicitarPagamentoCasoController.consultainfo(casoSinistro.Id);
        
        Decimal valorPagamento = 10000;
        //PLV-4374 - INICIO
        Map<Id,String> mapPagamento = new Map<Id,String>();
        mapPagamento.put(contaPessoal.id, 'Cheque');
        
        Map<Id,String> mapSuc = new Map<Id,String>();
        mapSuc.put(contaPessoal.id, 'SÃO PAULO');
        
        Test.startTest();
        String resGravapagamento = SolicitarPagamentoCasoController.gravapagamento(casoSinistro.Id, infoBan.Id, mapPagamento, mapSuc);  
        Test.stopTest();
        //PLV-4374 - FIM
    }
    
    @isTest
    static void gravaNovoPagamento(){

        //Criando Garantia
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();     
        Garantia__c garantia2 = TestDataFactory.gerarGarantia();
        //Criando Conta Pessoal
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        Account contaPessoal2 = TestDataFactory.gerarConta();
        //Criando Caso Atendimento Sinistro
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        //Criando contato
        Contact contato = (Contact) new ContactFactory().createRecord();
        
        //Criando Contador Codigo Produto Tecnico e Comercial
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        //Criando Forma de Pagamento
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        //Criando Parceiro e atualizando contrato
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        
        //Criando Produto Tecnico
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        //Criando Produto Comercial
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        //Criando Contrato
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        
        //Criando Contratante
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        
        //Criando Grupo
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        
        //Criando Segurado do Contrato
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        
        //Criando Garantia do Segurado do Contrato
        //PLV-4559 - INICIO
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        garantiaSegurado.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
        garantiaSegurado.Limite_de_Uso__c = 900;
        update garantiaSegurado;
        
        GarantiaSeguradoContrato__c garantiaSegurado2 = TestDataFactory.gerarGarantiaSeguradoContrato(garantia2, segurado);
        garantiaSegurado2.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
        garantiaSegurado2.Limite_de_Uso__c = 900;
        update garantiaSegurado2;
        //PLV-4559 - FIM
       
        
        //Criando Caso Sinistro
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        
        //Atualizando o status do caso para 'Avisado'
        casoSinistro.ContactId = contato.id;
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.NumeroSinistro__c = '321';
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Com Pendências';
        casoSinistro.Segurado_do_Contrato__c = segurado.id;
        casoSinistro.ProcessaNumeroSinistro__c = true;
        update casoSinistro;
        
        Test.startTest();//PLV-4559 - INICIO/FIM
        //Criando Pagamento de Garantia
        PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        pag.Fase__c = 'Em Análise';
        pag.Status_do_pagamento__c = 'Em Análise';
        update pag;
        PagamentoGarantia__c lpag = [select id, valor_indenizado__c, valorindenizado__c from PagamentoGarantia__c where id =: pag.Id]; 
        //Craindo Pagamento de Garantia2
        PagamentoGarantia__c pag2 = new PagamentoGarantia__c();
        pag2.Caso__c = casoSinistro.Id;
		pag2.Garantia_do_segurado_do_contrato__c = garantiaSegurado2.Id;
		pag2.name = 'TestPagamentoGarantia2';
        pag2.Capital__c = 100000.00;
		pag2.Motivo_da_Recusa__c = '1';
        pag2.Fase__c = 'Aberto';
        pag2.Valor_indenizado__c = 50;
        insert pag2;

        pag2.Fase__c = 'Em Análise';
        pag2.Status_do_pagamento__c = 'Em Análise';
        update pag2;
        PagamentoGarantia__c lpag2 = [select id, valor_indenizado__c, valorindenizado__c from PagamentoGarantia__c where id =: pag2.Id]; 
        //Criando Informação Bancária
        
        InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        //PLV-4428 - INICIO
        Banco__c banconew = new Banco__c();
        banconew.CodigoBanco__c = '341';
        banconew.ConveniadoADC__c  = false;
        banconew.Name = 'Itau';
        banconew.Ativo__c = true;
        insert banconew; 
        Banco__c banco1 = [SELECT id, CodigoBanco__c FROM Banco__c limit 1];
        banco1.CodigoBanco__c = '237';
        banco1.Name = 'Bradesco';
        update banco1;
        //PLV-4428 - FIM
        InformacaoBancaria__c infoBan2 = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal2).createRecord();
        //Criando Beneficiario da Garantia
        BeneficiarioGarantia__c bene2 = new BeneficiarioGarantia__c();
        bene2.Pagamento_de_garantia__c = pag.Id;
        bene2.Conta__c = contaPessoal.id;
        bene2.Status__c = 'Pendente';
        bene2.Tipo_de_Pagamento__c = 'Cheque';
        // bene2.InformarIndenizacao__c = '% de Indenização'; //PLV-4070 - INICIO/FIM
        bene2.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
        // bene2.Percentual_de_indenizacao__c = 20.000; //PLV-4070 - INICIO/FIM
        // bene2.ValorIndenizacao__c = 20.00; //PLV-4070 - INICIO/FIM  //PLV-4374 - INICIO/FIM
        bene2.Sucursal_Destino_de_Cheque__c = 10;
        bene2.Data_programada_do_pagamento__c = system.today() + 2;
        bene2.StatusSerasa__c = 'Atualizado';
        bene2.ValorIndenizacao__c = 10; //PLV-4070 - INICIO/FIM
        insert bene2;
            
        update casoSinistro;
        
        bene2.Status__c = 'Liberado';
        bene2.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
        bene2.Data_programada_do_pagamento__c = null;
        bene2.StatusSerasa__c = 'Atualizado';
        bene2.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
        update bene2;
        
        Pagamento_de_Sinistro__c ps = new Pagamento_de_Sinistro__c();
        ps.Caso_de_Sinistro__c = casosinistro.id;
        ps.Beneficiario_da_Garantia__c = bene2.Conta__c;
        ps.Valor_total_a_ser_indenizado__c = bene2.ValorIndenizacao__c;
        ps.Dados_Bancarios__c = infoBan.id;
        ps.Status__c = 'Pendente';
        //PLV-4374 - INICIO
        ps.Tipo_de_OP__c = 'Indenização'; 
        ps.BeneficiarioValidado__c = false;
        insert ps;
        
        ps.Status__c = 'Pendente';
        update ps;
        //PLV-4374 - FIM
        
        bene2.Pagamento_de_Sinistro__c = ps.id;
        update bene2;
        //Criando Beneficiario da Garantia
        BeneficiarioGarantia__c bene3 = new BeneficiarioGarantia__c();
        bene3.Pagamento_de_garantia__c = pag2.Id;
        bene3.Conta__c = contaPessoal.id;
        bene3.Status__c = 'Pendente';
        bene3.Tipo_de_Pagamento__c = 'Cheque';
        // bene3.InformarIndenizacao__c = '% de Indenização'; //PLV-4070 - INICIO/FIM
        bene3.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
        // bene3.Percentual_de_indenizacao__c = 20.000; //PLV-4070 - INICIO/FIM
        bene3.ValorIndenizacao__c = 20.00; //PLV-4070 - INICIO/FIM
        bene3.Sucursal_Destino_de_Cheque__c = 10;
        bene3.Data_programada_do_pagamento__c = system.today() + 2;
        bene3.StatusSerasa__c = 'Atualizado';
        bene3.ValorIndenizacao__c = 10; //PLV-4070 - INICIO/FIM
        insert bene3;
        //Criando Beneficiario da Garantia
        BeneficiarioGarantia__c bene4 = new BeneficiarioGarantia__c();
        bene4.Pagamento_de_garantia__c = pag2.Id;
        bene4.Conta__c = contaPessoal2.id;
        bene4.Status__c = 'Pendente';
        bene4.Tipo_de_Pagamento__c = 'Cheque';
        // bene4.InformarIndenizacao__c = '% de Indenização'; //PLV-4070 - INICIO/FIM
        bene4.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
        // bene4.Percentual_de_indenizacao__c = 20.000; //PLV-4070 - INICIO/FIM
        bene4.ValorIndenizacao__c = 20.00; //PLV-4070 - INICIO/FIM
        bene4.Sucursal_Destino_de_Cheque__c = 10;
        bene4.Data_programada_do_pagamento__c = system.today() + 2;
        bene4.StatusSerasa__c = 'Atualizado';
        bene4.ValorIndenizacao__c = 10; //PLV-4070 - INICIO/FIM
        insert bene4;

        bene3.Status__c = 'Liberado';
        bene3.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
        bene3.Data_programada_do_pagamento__c = null;
        bene3.StatusSerasa__c = 'Atualizado';
        bene3.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
        update bene3;

        bene4.Status__c = 'Liberado';
        bene4.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
        bene4.Data_programada_do_pagamento__c = null;
        bene4.StatusSerasa__c = 'Atualizado';
        bene4.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
        update bene4;
		
        //PLV-4374 - INICIO        
        Map<Id,String> mapPagamento = new Map<Id,String>();
        mapPagamento.put(contaPessoal.id, 'Transferencia Bancaria para Conta Poupanca');
        mapPagamento.put(contaPessoal2.id, 'Cheque');
        
        Map<Id,String> mapSuc = new Map<Id,String>();
        mapSuc.put(contaPessoal.id, 'SÃO PAULO');
        mapSuc.put(contaPessoal2.id, 'SÃO PAULO');
        
        //Test.startTest();//PLV-4559 - INICIO/FIM
        String resGravapagamento = SolicitarPagamentoCasoController.gravapagamento(casoSinistro.Id, (infoBan.Id+';'+infoban2.Id), mapPagamento, mapSuc);  
        Test.stopTest();
        //PLV-4374 - FIM
    }
    
    //PLV-4374 - INICIO
    @isTest
    static void gravaNovoPagamentoForCase(){

        //Criando Garantia
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();     
        Garantia__c garantia2 = TestDataFactory.gerarGarantia();
        //Criando Conta Pessoal
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        Account contaPessoal2 = TestDataFactory.gerarConta();
        //Criando Caso Atendimento Sinistro
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        //Criando contato
        Contact contato = (Contact) new ContactFactory().createRecord();
        
        //Criando Contador Codigo Produto Tecnico e Comercial
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        //Criando Forma de Pagamento
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        //Criando Parceiro e atualizando contrato
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        
        //Criando Produto Tecnico
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        //Criando Produto Comercial
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        //Criando Contrato
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        
        //Criando Contratante
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        
        //Criando Grupo
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        
        //Criando Segurado do Contrato
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        
        //Criando Garantia do Segurado do Contrato
        //PLV-4559 - INICIO
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        garantiaSegurado.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
        garantiaSegurado.Limite_de_Uso__c = 900;
        update garantiaSegurado;
        
        GarantiaSeguradoContrato__c garantiaSegurado2 = TestDataFactory.gerarGarantiaSeguradoContrato(garantia2, segurado);
        garantiaSegurado2.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
        garantiaSegurado2.Limite_de_Uso__c = 900;
        update garantiaSegurado2;
        //PLV-4559 - FIM
        
        //Criando Caso Sinistro
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        
        //Atualizando o status do caso para 'Avisado'
        casoSinistro.ContactId = contato.id;
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.NumeroSinistro__c = '321';
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Com Pendências';
        casoSinistro.Segurado_do_Contrato__c = segurado.id;
        casoSinistro.ProcessaNumeroSinistro__c = true;
        update casoSinistro;
        
        Test.startTest();//PLV-4559 - INICIO/FIM
        //Criando Pagamento de Garantia
        PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        pag.Fase__c = 'Em Análise';
        pag.Status_do_pagamento__c = 'Em Análise';
        update pag;
        PagamentoGarantia__c lpag = [select id, valor_indenizado__c, valorindenizado__c from PagamentoGarantia__c where id =: pag.Id]; 
        //Craindo Pagamento de Garantia2
        PagamentoGarantia__c pag2 = new PagamentoGarantia__c();
        pag2.Caso__c = casoSinistro.Id;
		pag2.Garantia_do_segurado_do_contrato__c = garantiaSegurado2.Id;
		pag2.name = 'TestPagamentoGarantia2';
        pag2.Capital__c = 100000.00;
		pag2.Motivo_da_Recusa__c = '1';
        pag2.Fase__c = 'Aberto';
        pag2.Valor_indenizado__c = 50;
        insert pag2;

        pag2.Fase__c = 'Em Análise';
        pag2.Status_do_pagamento__c = 'Em Análise';
        update pag2;
        PagamentoGarantia__c lpag2 = [select id, valor_indenizado__c, valorindenizado__c from PagamentoGarantia__c where id =: pag2.Id]; 
        //Criando Informação Bancária
        
        InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        //PLV-4428 - INICIO
        Banco__c banconew = new Banco__c();
        banconew.CodigoBanco__c = '341';
        banconew.ConveniadoADC__c  = false;
        banconew.Name = 'Itau';
        banconew.Ativo__c = true;
        insert banconew; 
        Banco__c banco1 = [SELECT id, CodigoBanco__c FROM Banco__c limit 1];
        banco1.CodigoBanco__c = '237';
        banco1.Name = 'Bradesco';
        update banco1;
        //PLV-4428 - FIM
        InformacaoBancaria__c infoBan2 = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal2).createRecord();
        //Criando Beneficiario da Garantia
        BeneficiarioGarantia__c bene2 = new BeneficiarioGarantia__c();
        bene2.Pagamento_de_garantia__c = pag.Id;
        bene2.Conta__c = contaPessoal.id;
        bene2.Status__c = 'Pendente';
        bene2.Tipo_de_Pagamento__c = 'Cheque';
        // bene2.InformarIndenizacao__c = '% de Indenização'; //PLV-4070 - INICIO/FIM
        bene2.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
        // bene2.Percentual_de_indenizacao__c = 20.000; //PLV-4070 - INICIO/FIM
        // bene2.ValorIndenizacao__c = 20.00; //PLV-4070 - INICIO/FIM
        bene2.Sucursal_Destino_de_Cheque__c = 10;
        bene2.Data_programada_do_pagamento__c = system.today() + 2;
        bene2.StatusSerasa__c = 'Atualizado';
        bene2.ValorIndenizacao__c = 10; //PLV-4070 - INICIO/FIM
        insert bene2;
            
        update casoSinistro;
        
        bene2.Status__c = 'Liberado';
        bene2.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
        bene2.Data_programada_do_pagamento__c = Date.today() + 2;
        bene2.StatusSerasa__c = 'Atualizado';
        bene2.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
        update bene2;
        
        Set<Id> idContas = new Set<id>();
        idContas.add(bene2.Conta__c);
       
        
        Pagamento_de_Sinistro__c ps = new Pagamento_de_Sinistro__c();
        ps.Caso_de_Sinistro__c = casosinistro.id;
        ps.Beneficiario_da_Garantia__c = bene2.Conta__c;
        ps.Valor_total_a_ser_indenizado__c = bene2.ValorIndenizacao__c;
        ps.Dados_Bancarios__c = infoBan.id;
        ps.Tipo_de_OP__c = 'Indenização';
        ps.Status__c = 'Pendente';
        insert ps;
        
        //bene2.Pagamento_de_Sinistro__c = ps.id;
        update bene2;
        //Criando Beneficiario da Garantia
        BeneficiarioGarantia__c bene3 = new BeneficiarioGarantia__c();
        bene3.Pagamento_de_garantia__c = pag2.Id;
        bene3.Conta__c = contaPessoal.id;
        bene3.Status__c = 'Liberado';
        bene3.Tipo_de_Pagamento__c = 'Cheque';
        // bene3.InformarIndenizacao__c = '% de Indenização'; //PLV-4070 - INICIO/FIM
        bene3.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
        // bene3.Percentual_de_indenizacao__c = 20.000; //PLV-4070 - INICIO/FIM
        bene3.ValorIndenizacao__c = 20.00; //PLV-4070 - INICIO/FIM
        bene3.Sucursal_Destino_de_Cheque__c = 10;
        bene3.Data_programada_do_pagamento__c = system.today() + 2;
        bene3.StatusSerasa__c = 'Atualizado';
        bene3.ValorIndenizacao__c = 10; //PLV-4070 - INICIO/FIM
        bene3.Status__c = 'Pendente';
        insert bene3;
        //Criando Beneficiario da Garantia
        BeneficiarioGarantia__c bene4 = new BeneficiarioGarantia__c();
        bene4.Pagamento_de_garantia__c = pag2.Id;
        bene4.Conta__c = contaPessoal2.id;
        bene4.Status__c = 'Pendente';
        bene4.Tipo_de_Pagamento__c = 'Cheque';
        // bene4.InformarIndenizacao__c = '% de Indenização'; //PLV-4070 - INICIO/FIM
        bene4.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
        // bene4.Percentual_de_indenizacao__c = 20.000; //PLV-4070 - INICIO/FIM
        bene4.ValorIndenizacao__c = 20.00; //PLV-4070 - INICIO/FIM
        bene4.Sucursal_Destino_de_Cheque__c = 10;
        bene4.Data_programada_do_pagamento__c = system.today() + 2;
        bene4.StatusSerasa__c = 'Atualizado';
        bene4.ValorIndenizacao__c = 10; //PLV-4070 - INICIO/FIM
        insert bene4;

        bene3.Status__c = 'Liberado';
        bene3.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
        bene3.Data_programada_do_pagamento__c = null;
        bene3.StatusSerasa__c = 'Atualizado';
        bene3.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
        update bene3;

        bene4.Status__c = 'Liberado';
        bene4.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
        bene4.Data_programada_do_pagamento__c = null;
        bene4.StatusSerasa__c = 'Atualizado';
        bene4.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
        update bene4;
		
        Map<Id,String> mapPagamento = new Map<Id,String>();
        mapPagamento.put(contaPessoal.id, 'Cheque');
        mapPagamento.put(contaPessoal2.id, 'Transferencia Bancaria para Conta Poupanca');
        
        Map<Id,String> mapSuc = new Map<Id,String>();
        mapSuc.put(contaPessoal.id, 'SÃO PAULO');
        mapSuc.put(contaPessoal2.id, 'SÃO PAULO');
        
        //Test.startTest();//PLV-4559 - INICIO/FIM
        String resGravapagamento = SolicitarPagamentoCasoController.gravapagamento(casoSinistro.Id, (infoBan.Id+';'+infoban2.Id), mapPagamento,mapSuc );  //PLV-4374 INICO/FIM
        Test.stopTest();
             
    }
    
    //PLV-4374 - FIM
	//PLV - 4043 FIX 07/08 FIM    
}
//PLV - 4043 FIM