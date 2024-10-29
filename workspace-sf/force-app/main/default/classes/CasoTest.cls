/**
 * Testes Caso
 * @author GFS @ 08/01/2019
 *
 **/
@isTest
private class CasoTest {
    /*

    @testSetup
    private static void setup() {
        TestDataFactory.gerarDadosSetup();
    }
    
    @isTest
    static void validarPreencheCorretorCaso() 
    {
        //instancia Tipo de Remuneração
        TipoRemuneracao__c TpRemuneracao = new TipoRemuneracao__c();
        TpRemuneracao.Name = 'Corretagem';
        TpRemuneracao.Codigo__c = 'REP';

        insert(TpRemuneracao);
        
        //instancia conta com email preenchido
        Account conta = new Account();
        conta.Name = 'Conta corretor'; 
        conta.Papel__c = 'Corretor';
        conta.Email__c = 'b@b.com';
        insert conta;
        
        
          
        //instacia Contrato
        Contract contrato = new Contract(
                Name = '14889',
                Status = 'Em elaboração',
                Empresa__c = '22',
                MeioComercializacao__c = 'Portal Multi Canal',
                AccountId = conta.Id,
                StartDate = System.today().addDays(-1),
                VigenciaFinal__c = System.today().addDays(30),
                DataEmissao__c = System.today(),
                Endosso__c = '1485',
                Sucursal__c = '999'
        );

        insert contrato;
        
          //Garantia__c
        Garantia__c Gr = new Garantia__c();
        Gr.Name = 'Invalidez Permanente Total por Acidente';
        Gr.Sigla__c='IPTA';
        Gr.Status__c = 'Ativo';
        Gr.Tipo__c = 'Cobertura';
        //Gr.VigenciaInicial__c = '13/08/2018';
        Gr.TipoEvento__c = 'Invalidez';
        insert Gr;
        
        
         //Garantia_do_contrato__c
        GarantiaContrato__c gc = new GarantiaContrato__c(); 
        gc.Contrato__c = contrato.Id;
        gc.Garantia__c = gr.Id;
        gc.Name = '00004775';
        gc.TipoCapital__c = 'Capital uniforme';
        gc.StatusCapitalizacao__c = 'Processado';
        gc.Capital__c = 10000;
        
        insert gc; 
        
        Id RecordTypeIdsinistro = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistro').getRecordTypeId();
        Id RecordTypeIdsinistropai = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Solicitação Pai').getRecordTypeId();
         
        
        //instancia caso e updata o mesmo pra preencher o email
        Case casopai = new Case();
        casopai.AccountId = conta.Id;
        //casopai.Garantia_do_contrato__c = gc.Id;
        casopai.Type = 'Sinistro';
        casopai.Dataocorrencia__c = system.today();
        casopai.RecordTypeId = RecordTypeIdsinistropai;
        casopai.Status = 'Avisar';
        casopai.Vitima__c = 'Sogros';
        casopai.TipoEvento__c = 'Morte';
        casopai.Dataocorrencia__c = System.today();
        insert casopai;
        
        
        //RemuneracaoContrato__c
        RemuneracaoContrato__c rm = new RemuneracaoContrato__c();
        rm.Lider__c = true;
        rm.Contrato__c = contrato.Id;
        rm.Conta__c = conta.Id;
        rm.TipoRemuneracao__c = TpRemuneracao.Id;
        insert rm;
              
        //Garantia_do_segurado_do_contrato__c
            
        //(Caso: Nome da conta IDigual aGarantia do segurado do contrato: Segurado do contrato: Conta ID) 
        
        ContratanteContrato__c ctrctr = new ContratanteContrato__c();
        ctrctr.Contrato__c = contrato.Id;
        insert ctrctr;
            
        GrupoContrato__c grpctr = new GrupoContrato__c();
        grpctr.ContratanteContrato__c = ctrctr.Id;
        insert grpctr;
                
        SeguradoContrato__c sc = new SeguradoContrato__c();
        sc.GrupoContrato__c = grpctr.Id;
        sc.Conta__c = conta.Id;
        sc.VIgencia_Final__c = system.today();
        sc.Vigencia_Inicial__c = system.today();
        insert sc;
        
        
        GarantiaSeguradoContrato__c gsc = new GarantiaSeguradoContrato__c();
        gsc.Garantia__c = Gr.Id;
        gsc.SeguradoContrato__c = sc.Id;
        insert gsc;
        
        //instancia caso e updata o mesmo pra preencher o email
        Case caso = new Case();
        caso.AccountId = conta.Id;
        //caso.Garantia_do_contrato__c = gc.Id;
        caso.Garantia_do_segurado_do_contrato__c  = gsc.Id;
        caso.Type = 'Sinistro';
        caso.Dataocorrencia__c = system.today();
        caso.RecordTypeId = RecordTypeIdsinistro;
        caso.Status = 'Avisar';
        caso.Vitima__c = 'Sogros';
        caso.TipoEvento__c = 'Morte';
        caso.ParentId = casopai.Id;

        insert caso;
        
        
        update caso;
        
        
        
         //instancia caso e updata o mesmo pra preencher o email
        Case caso2 = new Case();
        caso2.AccountId = conta.Id;
        //caso.Garantia_do_contrato__c = gc.Id;
        caso2.Garantia_do_segurado_do_contrato__c  = null;
        caso2.Type = 'Sinistro';
        caso2.Dataocorrencia__c = system.today();
        caso2.RecordTypeId = RecordTypeIdsinistro;
        caso2.Status = 'Avisar';
        caso2.Vitima__c = 'Sogros';
        caso2.TipoEvento__c = 'Morte';
        caso2.ParentId = casopai.Id;

        insert caso2;
        update caso2;
    }
        */
    
    @IsTest
    static void validarCasoBO(){
        
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
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
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
            
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
		Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        PagamentoGarantia__c pagGaran = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        BeneficiarioGarantia__c beneGaran = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagGaran).createRecord();

        Test.startTest();
            
            casoSinistro.ContactId = contato.id;
            casoSinistro.Contrato__c = contrato.id;
            casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
            casoSinistro.NumeroSinistro__c = '321';
            casoSinistro.Data_sinistro_avisado__c = System.today();
            casoSinistro.Status = 'Avisado';
            casoSinistro.Status_Dependente__c = 'Com Pendências';
            casoSinistro.Segurado_do_Contrato__c = segurado.id;
            ////PLV-2433 - Inicio - Campo criado para cobertura da classe de teste
            casoSinistro.ProcessaNumeroSinistro__c = true;
            //PLV-2433 - Fim - Campo criado para cobertura da classe de teste
            update casoSinistro;

            casoAtendimento.Vitima__c = 'Segurado';
            update casoAtendimento;
            try{
                Case casoAtendimento2 = casoAtendimento.clone();
                insert casoAtendimento2;
            }catch(DmlException e){
                system.assert(e.getMessage().contains('Este caso não pode ser finalizado '));
            }
            //casoAtendimento.Criar_caso_filho_automaticamente__c = true;
            casoAtendimento.Garantia__c = garantia.id;
            update casoAtendimento;
        
            Set<Id> caseidSet = new Set<Id>();

            caseidSet.add(casoSinistro.id);

            CasoBO.criarArquivoLoteSinistroHerokuFuture(caseidSet);
        
        	beneGaran.Observacao__c = 'abc';
        	update beneGaran;
        
        	casoSinistro.Status = 'Liquidação';
        	casoSinistro.Status_Dependente__c = 'Recusado';
        	casoSinistro.Motivos_de_recusa__c = '6';
            garanProdCom.TipoPrazoAvisoSinistro__c = 'Mês';
            update garanProdCom;
        	update casoSinistro;
        	
        	casoSinistro.Status_Dependente__c = 'Cancelado';
        	update casoSinistro;
        
        Test.stopTest();

        //casoSinistro.Status_Dependente__c = 'Cancelado';
        //update casoSinistro;

        //casoSinistro = CasoFactory.mudaStatus(casoSinistro, 'Avisado');
       

        	//casoBeneficio.Criar_caso_filho_automaticamente__c = true;
        	//update casoBeneficio;

 	       //Id RecordTypeIdProdutoTecnico = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('ProdutoTecnico').getRecordTypeId();
     	   //List<Product2> listaProduto = [SELECT Name, Status__c, ProductCode, VigenciaInicial__c, TipoCapital__c, Segmento__c, 
                                       //TipoResponsavelPagamento__c, NumeroSusep__c, Versao__c, VersaoMaxima__c, VersaoRenovacao__c
                                       //FROM Product2 WHERE RecordTypeId =: produto.RecordTypeId];
    }
    @IsTest
    static void validarCasoBO2(){
        
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        contaPessoal.Email__c = 'test@test.com';
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
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
        garanProdCom.TipoPrazoAvisoSinistro__c = 'Mês';
        update garanProdCom;    
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
		Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        PagamentoGarantia__c pagGaran = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        BeneficiarioGarantia__c beneGaran = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagGaran).createRecord();

        Test.startTest();
            
            casoSinistro.ContactId = contato.id;
            casoSinistro.Contrato__c = contrato.id;
            casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
            casoSinistro.NumeroSinistro__c = '321';
            casoSinistro.Data_sinistro_avisado__c = System.today();
            casoSinistro.Status = 'Avisado';
            casoSinistro.Status_Dependente__c = 'Com Pendências';
            casoSinistro.Segurado_do_Contrato__c = segurado.id;
            ////PLV-2433 - Inicio - Campo criado para cobertura da classe de teste
            casoSinistro.ProcessaNumeroSinistro__c = true;
            //PLV-2433 - Fim - Campo criado para cobertura da classe de teste
            update casoSinistro;

            casoAtendimento.Vitima__c = 'Segurado';
            update casoAtendimento;
            try{
                Case casoAtendimento2 = casoAtendimento.clone();
                insert casoAtendimento2;
            }catch(DmlException e){
                system.assert(e.getMessage().contains('Este caso não pode ser finalizado '));
            }
            //casoAtendimento.Criar_caso_filho_automaticamente__c = true;
            casoAtendimento.Garantia__c = garantia.id;
            update casoAtendimento;
        
            Set<Id> caseidSet = new Set<Id>();

            caseidSet.add(casoSinistro.id);

            CasoBO.criarArquivoLoteSinistroHerokuFuture(caseidSet);
        
        	beneGaran.Observacao__c = 'abc';
        	update beneGaran;
        
        	casoSinistro.Status = 'Liquidação';
        	casoSinistro.Status_Dependente__c = 'Recusado';
        	casoSinistro.Motivos_de_recusa__c = '6';            
        	update casoSinistro;
        	
        	casoSinistro.Status_Dependente__c = 'Cancelado';
        	update casoSinistro;
        
        Test.stopTest();
    }
    @IsTest
    static void validarCasoBO3(){
        
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
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
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
        garanProdCom.TipoPrazoAvisoSinistro__c = 'Dia';
        update garanProdCom;    
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
		Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        PagamentoGarantia__c pagGaran = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        BeneficiarioGarantia__c beneGaran = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagGaran).createRecord();
        //test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
            
            casoSinistro.ContactId = contato.id;
            casoSinistro.Contrato__c = contrato.id;
            casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
            casoSinistro.NumeroSinistro__c = '321';
            casoSinistro.Data_sinistro_avisado__c = System.today();
            casoSinistro.Status = 'Avisado';
            casoSinistro.Status_Dependente__c = 'Com Pendências';
            casoSinistro.Segurado_do_Contrato__c = segurado.id;
            ////PLV-2433 - Inicio - Campo criado para cobertura da classe de teste
            casoSinistro.ProcessaNumeroSinistro__c = true;
            //PLV-2433 - Fim - Campo criado para cobertura da classe de teste
            update casoSinistro;

            casoAtendimento.Vitima__c = 'Segurado';
            update casoAtendimento;
            try{
                Case casoAtendimento2 = casoAtendimento.clone();
                insert casoAtendimento2;
            }catch(DmlException e){
                system.assert(e.getMessage().contains('Este caso não pode ser finalizado '));
            }
            //casoAtendimento.Criar_caso_filho_automaticamente__c = true;
            casoAtendimento.Garantia__c = garantia.id;
            update casoAtendimento;
        
            Set<Id> caseidSet = new Set<Id>();

            caseidSet.add(casoSinistro.id);

            CasoBO.criarArquivoLoteSinistroHeroku(caseidSet);
        
        	beneGaran.Observacao__c = 'abc';
        	update beneGaran;
        
        	casoSinistro.Status = 'Liquidação';
        	casoSinistro.Status_Dependente__c = 'Recusado';
        	casoSinistro.Motivos_de_recusa__c = '6';            
        	update casoSinistro;
        	
        	casoSinistro.Status_Dependente__c = 'Cancelado';
        	update casoSinistro;
        
        Test.stopTest();
    }
    @IsTest
    static void validarCasoBO4(){
        
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
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
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
        garanProdCom.TipoPrazoAvisoSinistro__c = 'Dia';
        update garanProdCom;    
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

        //ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
		Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        //PagamentoGarantia__c pagGaran = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        //BeneficiarioGarantia__c beneGaran = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagGaran).createRecord();
        //test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
            
            casoSinistro.ContactId = contato.id;
            casoSinistro.Contrato__c = contrato.id;
            casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
            casoSinistro.NumeroSinistro__c = '321';
            casoSinistro.Data_sinistro_avisado__c = System.today();
            casoSinistro.Status = 'Aberto';
            casoSinistro.Status_Dependente__c = 'Com Pendências';
            casoSinistro.Segurado_do_Contrato__c = segurado.id;
            ////PLV-2433 - Inicio - Campo criado para cobertura da classe de teste
            casoSinistro.ProcessaNumeroSinistro__c = true;
            //PLV-2433 - Fim - Campo criado para cobertura da classe de teste
            //update casoSinistro;
            
            casoAtendimento.Vitima__c = 'Segurado';
            update casoAtendimento;
            try{
                Case casoAtendimento2 = casoAtendimento.clone();
                insert casoAtendimento2;
                casoAtendimento2.Status = 'Avisado';
                update casoAtendimento2;
            }catch(DmlException e){
                system.assert(e.getMessage().contains('Este caso não pode ser finalizado '));
            }
            //casoAtendimento.Criar_caso_filho_automaticamente__c = true;
            casoAtendimento.Garantia__c = garantia.id;
            casoAtendimento.Status = 'Avisado';
            update casoAtendimento;
            
            Set<Id> caseidSet = new Set<Id>();
            
            caseidSet.add(casoSinistro.id);
            
            CasoBO.criarArquivoLoteSinistroHeroku(caseidSet);
            
        	//beneGaran.Observacao__c = 'abc';
        	//update beneGaran;
            casoSinistro.Status = 'Avisado';
            update casoSinistro;
            
        	casoSinistro.Status = 'Liquidação';
        	casoSinistro.Status_Dependente__c = 'Recusado';
        	casoSinistro.Motivos_de_recusa__c = '6';            
        	update casoSinistro;
        	
        	casoSinistro.Status_Dependente__c = 'Cancelado';
        	update casoSinistro;
        
        Test.stopTest();
    }
    @IsTest
    static void validarCriarRegistrosFilhosSinistro(){

        Account contaPessoal2 = (Account) new AccountFactory.PessoaFisica().createRecord();
        Garantia__c garantia2 = (Garantia__c) new GarantiaFactory().createRecord();
        
        ContadorCodigo__c contCodigoTec2 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom2 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico2 = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico2.Status__c = 'Ativo';
        update produtoTecnico2;
        Product2 produtoComercial2 = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico2).createRecord();

        FormaPagamento__c formaPagamento2 = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro2 = (Parceiro__c) new ParceiroFactory(contaPessoal2, formaPagamento2).createRecord();
        ProdutoParceiro__c prodParc2 = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro2, produtoComercial2).createRecord();
        OperacaoProdutoParceiro__c oProdParc2 = (OperacaoProdutoParceiro__c) new OperacaoProdutoParceiroFactory(prodParc2).createRecord();

        Contact contato2 = (Contact) new ContactFactory().createRecord();
        Contract contrato2 = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal2, produtoComercial2, parceiro2).createRecord();
        ContratanteContrato__c contratante2 = (ContratanteContrato__c) new ContratanteFactory(contrato2).createRecord();
        GrupoContrato__c grupo2 = (GrupoContrato__c) new GrupoFactory(contratante2).createRecord();
        SeguradoContrato__c segurado2 = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal2, grupo2).createRecord();
        GarantiaSeguradoContrato__c garantiaSegurado2 = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado2, garantia2).createRecord();

        RamoSeguro__c ramoSeguro2 = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal2).createRecord();
        RamoGarantia__c ramoGarantia2 = (RamoGarantia__c) new RamoGarantiaFactory(garantia2, ramoSeguro2).createRecord();
        GarantiaProduto__c garanProdTec2 = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia2, produtoTecnico2, ramoSeguro2).createRecord();
        GarantiaProduto__c garanProdCom2 = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial2, garantia2, garanProdTec2, ramoSeguro2).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento3 = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        Case casoSinistro2 = (Case) new CasoFactory.Sinistro(casoAtendimento3, contaPessoal2).createRecord();
        //PLV-4535 - FIX 6 INICIO
        casoSinistro2.DataDocumentacaoCompleta__c = system.today();
        update casoSinistro2;
        //PLV-4535 - FIX 6 FIM
            
        Test.startTest();    
            casoSinistro2.ContactId = contato2.id;
            casoSinistro2.Contrato__c = contrato2.id;
            casoSinistro2.Garantia_do_segurado_do_contrato__c = garantiaSegurado2.id;
            casoSinistro2.NumeroSinistro__c = '321';
            casoSinistro2.Data_sinistro_avisado__c = System.today();
            casoSinistro2.Status = 'Avisado';
            casoSinistro2.Status_Dependente__c = 'Em Análise';
            casoSinistro2.Segurado_do_Contrato__c = segurado2.id;
            //PLV-2433 - Inicio - Campo criado para cobertura da classe de teste
            casoSinistro2.ProcessaNumeroSinistro__c = true;
            //PLV-2433 - Fim - Campo criado para cobertura da classe de teste
            update casoSinistro2;

            casoSinistro2.Status = 'Em Regulação';
            update casoSinistro2;

            casoSinistro2.Status = 'Liquidação';
            casoSinistro2.Status_Dependente__c = 'Recusado';
            update casoSinistro2;
            //PLV-1096 - Início - Aumento de cobertura na classe de teste
            //CasoBO.processaHerokuAposBatch(); //Correção ambientes - INICIO/FIM
            //PLV-1096 - Fim - Aumento de cobertura na classe de teste
        Test.stopTest();
    }
    //PLV-2433 - Inicio - Metodo criado para cobertura da classe de teste
    @isTest
    static void atualizaCasoNumeroSinistro(){
        Account contaPessoal3 = (Account) new AccountFactory.PessoaFisica().createRecord();
        Garantia__c garantia3 = (Garantia__c) new GarantiaFactory().createRecord();
        
        ContadorCodigo__c contCodigoTec3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico3 = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico3.Status__c = 'Ativo';
        update produtoTecnico3;
        Product2 produtoComercial3 = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico3).createRecord();

        FormaPagamento__c formaPagamento3 = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro3 = (Parceiro__c) new ParceiroFactory(contaPessoal3, formaPagamento3).createRecord();
        ProdutoParceiro__c prodParc3 = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro3, produtoComercial3).createRecord();
        OperacaoProdutoParceiro__c oprodParc4 = (OperacaoProdutoParceiro__c) new OperacaoProdutoParceiroFactory(prodParc3).createRecord();

        Contact contato3 = (Contact) new ContactFactory().createRecord();
        Contract contrato3 = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal3, produtoComercial3, parceiro3).createRecord();
        ContratanteContrato__c contratante3 = (ContratanteContrato__c) new ContratanteFactory(contrato3).createRecord();
        GrupoContrato__c grupo3 = (GrupoContrato__c) new GrupoFactory(contratante3).createRecord();
        SeguradoContrato__c segurado3 = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal3, grupo3).createRecord();
        GarantiaSeguradoContrato__c garantiasegurado3 = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado3, garantia3).createRecord();

        RamoSeguro__c ramoSeguro3 = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal3).createRecord();
        RamoGarantia__c ramogarantia3 = (RamoGarantia__c) new RamoGarantiaFactory(garantia3, ramoSeguro3).createRecord();
        GarantiaProduto__c garanProdTec3 = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia3, produtoTecnico3, ramoSeguro3).createRecord();
        GarantiaProduto__c garanProdCom3 = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial3, garantia3, garanProdTec3, ramoSeguro3).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento3 = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        Case casoSinistro3 = (Case) new CasoFactory.Sinistro(casoAtendimento3, contaPessoal3).createRecord();
            
        Test.startTest();
            ramoSeguro3.Codigo__c = '123';
            update ramoSeguro3;
            
            contrato3.Empresa__c = '22';
            contrato3.RamoSeguro__c = ramoSeguro3.Id;
            update contrato3;
            
            casoSinistro3.ContactId = contato3.id;
            casoSinistro3.Contrato__c = contrato3.id;
            casoSinistro3.Garantia_do_segurado_do_contrato__c = garantiasegurado3.id;
            casoSinistro3.NumeroSinistro__c = '';
            casoSinistro3.Data_sinistro_avisado__c = System.today();
            casoSinistro3.Status = 'Avisado';
            casoSinistro3.Status_Dependente__c = 'Em Análise';
            casoSinistro3.Segurado_do_Contrato__c = segurado3.id;
            casoSinistro3.ProcessaNumeroSinistro__c = true;
            update casoSinistro3;
            
            CasoBO.ChamaNumeroSinistro('22','123', System.today().year(), casoSinistro3.Id);//Correção ambientes - INICIO/FIM

        Test.stopTest();
    }
    //PLV-2433 - Fim - Metodo criado para cobertura da classe de teste
    
    //PLV-4551 - Inicio
    @isTest
    static void preenchenumsinistro(){
        Account contaPessoal3 = (Account) new AccountFactory.PessoaFisica().createRecord();
        Garantia__c garantia3 = (Garantia__c) new GarantiaFactory().createRecord();
        
        ContadorCodigo__c contCodigoTec3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico3 = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico3.Status__c = 'Ativo';
        update produtoTecnico3;
        Product2 produtoComercial3 = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico3).createRecord();

        FormaPagamento__c formaPagamento3 = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro3 = (Parceiro__c) new ParceiroFactory(contaPessoal3, formaPagamento3).createRecord();
        ProdutoParceiro__c prodParc3 = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro3, produtoComercial3).createRecord();
        OperacaoProdutoParceiro__c oprodParc4 = (OperacaoProdutoParceiro__c) new OperacaoProdutoParceiroFactory(prodParc3).createRecord();

        Contact contato3 = (Contact) new ContactFactory().createRecord();
        Contract contrato3 = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal3, produtoComercial3, parceiro3).createRecord();
        ContratanteContrato__c contratante3 = (ContratanteContrato__c) new ContratanteFactory(contrato3).createRecord();
        GrupoContrato__c grupo3 = (GrupoContrato__c) new GrupoFactory(contratante3).createRecord();
        SeguradoContrato__c segurado3 = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal3, grupo3).createRecord();
        GarantiaSeguradoContrato__c garantiasegurado3 = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado3, garantia3).createRecord();

        RamoSeguro__c ramoSeguro3 = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal3).createRecord();
        RamoGarantia__c ramogarantia3 = (RamoGarantia__c) new RamoGarantiaFactory(garantia3, ramoSeguro3).createRecord();
        GarantiaProduto__c garanProdTec3 = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia3, produtoTecnico3, ramoSeguro3).createRecord();
        GarantiaProduto__c garanProdCom3 = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial3, garantia3, garanProdTec3, ramoSeguro3).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento3 = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        Case casoSinistro3 = (Case) new CasoFactory.Sinistro(casoAtendimento3, contaPessoal3).createRecord();
            
        Test.startTest();
            ramoSeguro3.Codigo__c = '123';
            update ramoSeguro3;
            
            contrato3.Empresa__c = '22';
            contrato3.RamoSeguro__c = ramoSeguro3.Id;
            update contrato3;
            
            casoSinistro3.ContactId = contato3.id;
            casoSinistro3.Contrato__c = contrato3.id;
            casoSinistro3.Garantia_do_segurado_do_contrato__c = garantiasegurado3.id;
            casoSinistro3.NumeroSinistro__c = '';
            casoSinistro3.Data_sinistro_avisado__c = System.today();
            casoSinistro3.Status = 'Avisado';
            casoSinistro3.Status_Dependente__c = 'Em Análise';
            casoSinistro3.Segurado_do_Contrato__c = segurado3.id;
            casoSinistro3.ProcessaNumeroSinistro__c = true;
            update casoSinistro3;
            
        	List<Case> lstCaseNew = new List<Case>{casoSinistro3};
            Map<ID, Case> mpCaseOld = new Map<ID, Case>{casoSinistro3.id => casoSinistro3};
        	new CasoBO().preenchenumsinistro(lstCaseNew, mpCaseOld);

        Test.stopTest();
    }
    //PLV-4551 - Fim

    //PLV-4560 - Inicio
    @IsTest
    static void validarPrenchimentoBeneficiarios(){
        
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        Account contaPessoal2 = (Account) new AccountFactory.PessoaFisica().createRecord();
		contaPessoal2.FirstName = 'SillasTest';
        update contaPessoal2;
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
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();           
            
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
            
        garantiaSegurado.GarantiaProduto__c = garanProdCom.Id;
        update garantiaSegurado;
        
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

         //PLV-4560 - Inicio 
         GarantiaContrato__c garantiaContract = new GarantiaContrato__c();
         garantiaContract.Contrato__c = contrato.Id;
         garantiaContract.GarantiaProduto__c = garanProdCom.Id;    
         garantiaContract.Garantia__c = garantia.Id;
         insert garantiaContract;
         
         BeneficiarioSeguradoContrato__c befSegContr1 = new BeneficiarioSeguradoContrato__c();
         befSegContr1.SeguradoContrato__c = segurado.Id;
         befSegContr1.conta__c = contaPessoal.Id;
         befSegContr1.participacao__c = Decimal.valueOf(50);
         insert befSegContr1;
 
         BeneficiarioSeguradoContrato__c befSegContr2 = new BeneficiarioSeguradoContrato__c();
         befSegContr2.SeguradoContrato__c = segurado.Id;
         befSegContr2.conta__c = contaPessoal.Id;
         befSegContr2.participacao__c = Decimal.valueOf(50);
         insert befSegContr2;
         //PLV-4560 - fim

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
		Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        
        InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        PagamentoGarantia__c pagGaran = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        //BeneficiarioGarantia__c beneGaran = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagGaran).createRecord();

        Test.startTest();
            
            casoSinistro.ContactId = contato.id;
        	casoSinistro.AccountId = contaPessoal2.Id;
            casoSinistro.Contrato__c = contrato.id;
            casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
            casoSinistro.NumeroSinistro__c = '321';
            casoSinistro.Data_sinistro_avisado__c = System.today();
            casoSinistro.Status = 'Em Análise';
            casoSinistro.Status_Dependente__c = 'Com Pendências';
            casoSinistro.Segurado_do_Contrato__c = segurado.id;
            update casoSinistro;

            casoAtendimento.Vitima__c = 'Segurado';
            casoAtendimento.Garantia__c = garantia.id;
            update casoAtendimento;

        
        Test.stopTest();
    }
    
        @IsTest
    static void validarPrenchimentoBeneficiarioPropio(){
        
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        Account contaPessoal2 = (Account) new AccountFactory.PessoaFisica().createRecord();
        contaPessoal2.FirstName = 'SillasTest';
        update contaPessoal2;
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
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();           
            
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
            
        garantiaSegurado.GarantiaProduto__c = garanProdTec.Id;
        update garantiaSegurado;
        
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

         //PLV-4560 - Inicio 
         GarantiaContrato__c garantiaContract = new GarantiaContrato__c();
         garantiaContract.Contrato__c = contrato.Id;
         garantiaContract.GarantiaProduto__c = garanProdCom.Id;    
         garantiaContract.Garantia__c = garantia.Id;
         insert garantiaContract;
         
         BeneficiarioSeguradoContrato__c befSegContr1 = new BeneficiarioSeguradoContrato__c();
         befSegContr1.SeguradoContrato__c = segurado.Id;
         befSegContr1.conta__c = contaPessoal.Id;
         befSegContr1.participacao__c = Decimal.valueOf(50);
         insert befSegContr1;
 
         BeneficiarioSeguradoContrato__c befSegContr2 = new BeneficiarioSeguradoContrato__c();
         befSegContr2.SeguradoContrato__c = segurado.Id;
         befSegContr2.conta__c = contaPessoal.Id;
         befSegContr2.participacao__c = Decimal.valueOf(50);
         insert befSegContr2;
         //PLV-4560 - fim

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
		Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        
        InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        PagamentoGarantia__c pagGaran = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        //BeneficiarioGarantia__c beneGaran = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagGaran).createRecord();

        Test.startTest();
            casoSinistro.AccountId = contaPessoal2.Id;
            casoSinistro.ContactId = contato.id;
            casoSinistro.Contrato__c = contrato.id;
            casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
            casoSinistro.NumeroSinistro__c = '321';
            casoSinistro.Data_sinistro_avisado__c = System.today();
            casoSinistro.Status = 'Em Análise';
            casoSinistro.Status_Dependente__c = 'Com Pendências';
            casoSinistro.Segurado_do_Contrato__c = segurado.id;
            update casoSinistro;
        
        Test.stopTest();
    }
//PLV-4560 - Fim

	//PLV-4707 - Inicio
    @IsTest
    static void validarRealizarEndossoAutomatico(){
        
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        Account contaPessoal2 = (Account) new AccountFactory.PessoaFisica().createRecord();
        update contaPessoal2;
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
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();           
            
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
            
        garantiaSegurado.GarantiaProduto__c = garanProdCom.Id;
        update garantiaSegurado;
        
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

         //PLV-4560 - Inicio 
         GarantiaContrato__c garantiaContract = new GarantiaContrato__c();
         garantiaContract.Contrato__c = contrato.Id;
         garantiaContract.GarantiaProduto__c = garanProdCom.Id;    
         garantiaContract.Garantia__c = garantia.Id;
         insert garantiaContract;
         
         BeneficiarioSeguradoContrato__c befSegContr1 = new BeneficiarioSeguradoContrato__c();
         befSegContr1.SeguradoContrato__c = segurado.Id;
         befSegContr1.conta__c = contaPessoal.Id;
         befSegContr1.participacao__c = Decimal.valueOf(50);
         insert befSegContr1;
 
         BeneficiarioSeguradoContrato__c befSegContr2 = new BeneficiarioSeguradoContrato__c();
         befSegContr2.SeguradoContrato__c = segurado.Id;
         befSegContr2.conta__c = contaPessoal.Id;
         befSegContr2.participacao__c = Decimal.valueOf(50);
         insert befSegContr2;
         //PLV-4560 - fim

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
		Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        
        InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        PagamentoGarantia__c pagGaran = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        //BeneficiarioGarantia__c beneGaran = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagGaran).createRecord();

        //Test.startTest();
            casoSinistro.AccountId = contaPessoal2.Id;
            casoSinistro.ContactId = contato.id;
            casoSinistro.Contrato__c = contrato.id;
            casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
            casoSinistro.NumeroSinistro__c = '321';
            casoSinistro.Data_sinistro_avisado__c = System.today();
            casoSinistro.Status = 'Avisado';
            casoSinistro.Status_Dependente__c = 'Com Pendências';
            casoSinistro.Segurado_do_Contrato__c = segurado.id;
            update casoSinistro;
            
        
        //Test.stopTest();
    }
    //PLV-4707 - Fim
    
    //PLV-4897 INICIO
	@IsTest
    static void validarSinistroJuridico(){
        Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
        
        contact contato = [SELECT Id FROM Contact WHERE AccountId =: contaFisica.Id];
        
        case caso = new case();
        caso.AccountId = contaFisica.Id;
        caso.ContactId = contato.Id;
        caso.Status_Dependente__c = 'Aberto';
        
        caso.Nome_Segurado__c = 'Teste';
        caso.Cpf_Segurado__c = '075.487.587-87';
		caso.Subject = 'Teste';
		caso.Description = 'Teste';
		caso.Numero_titulo__c = '14587452';
		caso.Vitima__c = 'Segurado';
		caso.IdPrestadora__c = 'Teste';
		caso.TipoEvento__c = 'Acidente';
		caso.EmpresaSplit__c = 52.5;
		caso.sucursal__c = 'Teste';
		caso.RamoSplit__c = 54.5;
		caso.Numero_Apolice__c  = '102458798754';
		caso.SinistroPrioritario__c = True;
		caso.Origin = 'Backoffice';
        caso.Data_Aviso_Cliente__c = system.today();
        caso.Dataocorrencia__c = system.today();
        insert caso;
        
        insert new MovimentoSinistro__c(
            Caso__c = caso.id,
            DataMovimento__c = System.now(),
            DescricaoMovimento__c = '1',
            TipoMovimento__c = 'Aviso',
            ValorMovimento__c = 500,
            SequenciaMovimento__c = '1'
        );
        
        insert new MovimentoSinistro__c(
            Caso__c = caso.id,
            DataMovimento__c = System.now(),
            DescricaoMovimento__c = '2',
            TipoMovimento__c = 'Aviso',
            ValorMovimento__c = 400,
            SequenciaMovimento__c = '1'
        );
        
        insert new MovimentoSinistro__c(
            Caso__c = caso.id,
            DataMovimento__c = System.now(),
            DescricaoMovimento__c = '25',
            TipoMovimento__c = 'Aviso',
            ValorMovimento__c = 400,
            SequenciaMovimento__c = 'erro'
        );
        
        
        caso.Sinistro_Judicial__c = true;
        
        Test.startTest();
        update caso;
        
        List<MovimentoSinistro__c> lstMov = [SELECT id FROM MovimentoSinistro__c WHERE Caso__c =: caso.id];
        
        System.assertEquals(3, lstMov.size()); // POR062-1 - INICIO | FIM
        Test.stopTest();
    }
    //PLV-4897 FIM
}