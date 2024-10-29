//II-154 INICIO
//PLV-2939 - INICIO
// PLV-3726 INICIO

/**
 * @author AVX - Renato Matheus Simião
 * @date 2019-12-05
 * @description Classe de teste para a classe GeraVoucherPorContratoPDFController
 */
@isTest
public class GeraVoucherPorContratoPDFControllerTest {

    // @TestSetup
    // static void makeData(){
    //     Account contaTeste = TestDataFactory.gerarConta();
    //     DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
    //     RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
    //     Garantia__c garantia1 = TestDataFactory.gerarGarantia();
    //     RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
        
    //     ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	//     ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
    //     Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
    //     produtoTec.Status__c = 'Ativo';
    //     produtoTec.Segmento__c = 'Individual';
    //     produtoTec.ProductCode = '49';
    //     update produtoTec;
        
    //     Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
    //     produtoCom.Status__c ='ativo';
    //     produtoCom.Segmento__c = 'Individual';
    //     produtoCom.ProductCode = 'APTLMKT';
    //     produtoCom.CodigoPrecificaProduto__c = 'APTLMKT';
    //     update produtoCom;


    //     GarantiaProduto__c garantiaTecnica = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);

    //     GarantiaProduto__c garantiaComercial = TestDataFactory.gerarGarantiaProdutoComercial(produtoCom, garantia1, garantiaTecnica, ramoSegurado);

    //     CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
      
    //     Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);   //RVI-247 - INICIO/FIM
    //     // RVI-186-FIX02 - INICIO
       
    //     Opportunity orcamentoRenovado = new Opportunity(
    //         StageName = 'Em criação',
    //         CurrencyIsoCode = 'BRL',
    //         Name = 'ARQ-00006790',
    //         CloseDate = System.today().addDays(20),
    //         VigenciaInicial__c = System.today(),
    //         VigenciaFinal__c = System.today().addDays(1),
    //         Produto__c = produtoCom.Id,
    //         Probability = 10.0,
    //         RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
    //         AccountId = contaTeste.Id,
    //         Numero__c = '00006790',
    //         CanalDistribuicao__c = canalDistribuicao.Id
    //     );
    //     insert orcamentoRenovado;
    //     // RVI-186-FIX02 - FIM
        
    //     Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

    //     ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoCom);
    //     paramVigencia.VigenciaMinimaRenovacao__c = 90;
    //     paramVigencia.Tipo__c = 'Periódico';
    //     update paramVigencia;

    //     Quote proposta = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
    //     proposta.NumeroProposta__c = '00001910';
    //     proposta.email__c = 'abcd@qualqueremail.com';
    //     update proposta;

    //     //TKCL-246 FIX-05 INICIO
    //     ContratanteProposta__c segurado = new ContratanteProposta__c(
	// 		conta__c = contaTeste.Id,
	// 		Proposta__c = proposta.Id,
	// 		Tipo__c = 'Principal'
	// 	);
	// 	insert segurado;

    //     GrupoProposta__c grupo = new GrupoProposta__c(
	// 		Name = 'Teste',
	// 		QuantidadeVidas__c = 1,
	// 		ContratanteProposta__c = segurado.Id
	// 	);
	// 	insert grupo;

    //     SeguradoProposta__c vida = new SeguradoProposta__c(
	// 		Conta__c = contaTeste.Id,
	// 		GrupoProposta__c = grupo.Id
	// 	);
	// 	insert vida;

    //     GarantiaProposta__c garantiaProposta = new GarantiaProposta__c(
	// 		Proposta__c = proposta.Id,
	// 		GarantiaProduto__c = garantiaTecnica.Id,
	// 		Garantia__c = garantiaTecnica.Garantia__c,
	// 		TipoCapital__c = 'Capital uniforme',
    //         Capital__c = 1
    //     );
	// 	insert garantiaProposta;
    //     //TKCL-246 FIX-05 FIM

    //     //RamoSeguro__c ramoSeguro, Modalidade__c modalidade, String name, String codigo
    //     FormaPagamento__c formPag = TestDataFactory.gerarFormaPagamento(ramoSegurado, modalidade, 'CARTAO DE CREDITO (TODAS PARC.EM CARTAO)', '62');

    //     Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta);
    //     contrato.Oportunidade__c = orcamentoContratado.Id;
    //     contrato.NumeroPropostaUnico__c = '18-00001910';
    //     contrato.NumeroApolice__c = '000014419';
    //     contrato.Tipo__c = 'Novo';   //RVI-160 - INICIO/FIM
    //     contrato.Status = 'Emitido'; //RVI-160 - INICIO/FIM
    //     contrato.Endosso__c = '0';
    //     contrato.VigenciaFinal__c = System.today().addDays(30);		       		    		    
    //     contrato.StatusRenovacao__c = 'Renovação em andamento'; //RVI-160 - INICIO/FIM
    //     contrato.CodigoRamo__c = '1391';    
    //     contrato.ApolicePdfDownloadUrl__c = 'https://MestreChico.com'; //RVI-57 - INICIO/FIM   
    //     contrato.AlteraFormaPagto__c = false; // RVI-186 - FIX02 - INICIO/FIM    
    //     update contrato;

    //     // RVI-186-FIX02 - INICIO 

    //     // Contract contratoRenovado = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta);
    //     Contract contratoRenovado = new Contract();
    //     contratoRenovado.Oportunidade__c = orcamentoRenovado.Id;
    //     contratoRenovado.Produto__c = produtoCom.Id;        
    //     contratoRenovado.RamoSeguro__c = ramoSegurado.Id;
    //     contratoRenovado.Status = 'Em elaboração' ;
    //     contratoRenovado.Empresa__c = '22';
    //     contratoRenovado.CodigoCorretor__c = dadosCorretor.Id;
    //     contratoRenovado.Proposta__c = proposta.Id;
    //     contratoRenovado.AccountId = contaTeste.Id;
    //     contratoRenovado.AlteraFormaPagto__c = false;
    //     contratoRenovado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
    //     contratoRenovado.PrimeiroContratoRenovacao__c = contrato.Id;		
    //     contratoRenovado.NumeroPropostaUnico__c = '18-00001911';
    //     contratoRenovado.NumeroApolice__c = '000014419';
    //     contratoRenovado.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
    //     contratoRenovado.Endosso__c = '1';
    //     contratoRenovado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
    //     contratoRenovado.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
    //     contratoRenovado.CodigoRamo__c = '1391';   
    //     contratoRenovado.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';  //RVI-57 - INICIO/FIM 
    //     insert contratoRenovado;
    //     // RVI-186-FIX02 - FIM 


    //     TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('Contrato', 15, 1000, 'Integral');

    //     RemuneracaoContrato__c remCon = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
    //     remCon.CurrencyIsoCode = 'BRL';
    //     remCon.Percentual__c = 10;
    //     remCon.Porcentagem_de_Retencao__c = 0;
    //     update remCon;

    //     //RVI-160 - INICIO
    //     RemuneracaoContrato__c remConRen = TestDataFactory.gerarRemuneracaoContrato(contratoRenovado, tipoRemuneracao);
    //     remConRen.CurrencyIsoCode = 'BRL';
    //     remConRen.Percentual__c = 10;
    //     remConRen.Porcentagem_de_Retencao__c = 0;
    //     update remConRen;
    //     //RVI-160 - FIM

    //     FavorecidoRemuneracaoContrato__c favRemCon = new FavorecidoRemuneracaoContrato__c();
    //     favRemCon.Conta__c = contaTeste.Id;
    //     favRemCon.CorretorLider__c = true;
    //     favRemCon.AntecipacaoComissao__c = true;
    //     favRemCon.RemuneracaoContrato__c = remCon.Id;
    //     favRemCon.Papel__c = 'Corretor';
    //     insert favRemCon;
        
    //     //RVI-160 - INICIO
    //     FavorecidoRemuneracaoContrato__c favRemConRen = new FavorecidoRemuneracaoContrato__c();
    //     favRemConRen.Conta__c = contaTeste.Id;
    //     favRemConRen.CorretorLider__c = true;
    //     favRemConRen.AntecipacaoComissao__c = true;
    //     favRemConRen.RemuneracaoContrato__c = remConRen.Id;
    //     favRemConRen.Papel__c = 'Corretor';
    //     insert favRemConRen;
    //     //RVI-160 - FIM

    //     GarantiaContrato__c garCtr = TestDataFactory.gerarGarantiaContrato(contrato, garantiaComercial);
    //     GarantiaContrato__c garCtrRen = TestDataFactory.gerarGarantiaContrato(contratoRenovado, garantiaComercial); //RVI-160 - INICIO/FIM

    //     //Novos dados
    //     Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();  
    //     //PLV-5231- INICIO
    //     conta.TipoDocidentificacao__c = 'rg'; 
    //     update conta;

    //     //PLV-5231- FIM      
    //     Endereco__c enderecoResidencial = (Endereco__c) TestDataFactory.gerarEndereco(conta);
    //     enderecoResidencial.TipoEndereco__c = 'Residencial';
    //     update enderecoResidencial;
        
    //     Endereco__c enderecoComercial = (Endereco__c) TestDataFactory.gerarEndereco(conta);
    //     enderecoComercial.TipoEndereco__c = 'Comercial';
    //     update enderecoComercial;
        
    //     ContadorCodigo__c contCodigoTec3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
    //     ContadorCodigo__c contCodigoCom3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
    //     Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
    //     produtoTecnico.NumeroSusep__c = '123';
    //     produtoTecnico.VersaoRenovacao__c = 'Versão atual';
    //     produtoTecnico.Status__c = 'Ativo';
    //     produtoTecnico.Segmento__c = 'Individual';
    //     update produtoTecnico;
        
    //     Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
    //     produtoComercial.Status__c = 'Ativo';
    //     produtoComercial.Segmento__c = 'Individual';
    //     update produtoComercial;
        
    //     RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
    //     DadosCorretor__c dadosCorretor1 = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
    //     Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
    //     Modalidade__c modalidade1 = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();    

    //     FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();

    //     Parceiro__c parceiro = new Parceiro__c(
    //         Status__c = 'Ativo',
    //         Sucursal__c = '1',
    //         Ramo__c = '1391',
    //         Empresa__c = '1',
    //         Conta__c = conta.Id,
    //         FormaPagamento__c = formaPagamento.Id,
    //         DiaFaturamento__c = '15',
    //         DiaPreFaturamento__c = '20',
    //         PrazoVencimento__c = '10',
    //         FaturaProdutosSeparados__c = 'Sim',
    //         PossuiAnexoFatura__c = 'Nao',
    //         SiglaParceiro__c = 'PAR'
    //     );
    //     insert parceiro;
        
    //     Contract contract = new Contract(
    //         Name = 'teste',
    //         AccountId = conta.Id,
    //         Produto__c = produtoComercial.Id,
    //         Parceria__c = parceiro.Id,
    //         CodigoRamo__c = '1369'
    //     );
    //     insert contract;

    //     RemuneracaoContrato__c remuneracao = new RemuneracaoContrato__c (Contrato__c = contract.Id);
    //     insert remuneracao;
    //     FavorecidoRemuneracaoContrato__c favRem = new FavorecidoRemuneracaoContrato__c();
    //     favRem.RemuneracaoContrato__c  = remuneracao.Id;
    //     favRem.Conta__c = conta.Id;
    //     insert favRem;
    //     //PLV-4425 - INICIO
    //     ContratanteContrato__c contratante1 = new ContratanteContrato__c(
    //         Contrato__c = contract.Id
    //     );
    //     insert contratante1;

    //     GrupoContrato__c grupo1 = new GrupoContrato__c(
    //         Name = 'Paulo',
    //         ContratanteContrato__c = contratante1.Id
    //     );
    //     insert grupo1;

    //     SeguradoContrato__c seguradoP = new SeguradoContrato__c(
    //         GrupoContrato__c = grupo1.Id
    //     );
    //     insert seguradoP;

    //     BeneficiarioSeguradoContrato__c beneficiario = new BeneficiarioSeguradoContrato__c(
    //         TipoBeneficiario__c = 'Nome do beneficiário',
    //         Nome__c = 'FRANCIS LIU',
    //         CpfCnpj__c = '518.179.180-87',
    //         Data_de_nascimento__c = system.today(),
    //         GrauParentesco__c = 'Amigo (a)',
    //         Participacao__c = 100,
    //         SeguradoContrato__c = seguradoP.Id
    //     );
    //     insert beneficiario;

        
    //     List<String> lstGarantiaSigla = new List<String>{'DG', 'DIT', 'BAS', 'MAP', 'IPA'};
    //     List<Garantia__c> lstGarantias = new List<Garantia__c>();
    //     List<GarantiaContrato__c> lstGarantiasContract = new List<GarantiaContrato__c>();
        
    //     for(String garantiaSigla : lstGarantiaSigla){
    //         Garantia__c garantia = new Garantia__c(
    //             Name        = 'garantia' + garantiaSigla,
    //             Sigla__c    = garantiaSigla
    //         );
    //         lstGarantias.add(garantia);
    //     }
        
    //     insert lstGarantias;
        
    //     String origem = '18';
    //     String numeroProposta = '00006767';

    //     // Quote proposta = new Quote(
    //     //         Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
    //     //         NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
    //     //         Produto__c = produtoCom.Id,
    //     //         RamoSeguro__c = ramoSegurado.Id,
    //     //         Status = 'Em criação',
    //     //         VigenciaInicial__c = System.today(),
    //     //         VigenciaFinal__c = System.today().addMonths(1),
    //     //         Empresa__c = contaTeste.Id,
    //     //         CodigoCorretor__c = dadosCorretor.Id,
    //     //         DataCalculo__c = System.today(),
    //     //         DataCriacaoPortal__c = System.today(),
    //     //         TipoVigencia__c = 'Anual',
    //     //         MeioComercializacao__c = 'PMC', 
    //     //         OpportunityId = orcamentoContratado.Id,
    //     //         Origem__c = origem,
    //     //         Modalidade__c = modalidade.Id,
    //     //         NumeroProposta__c = numeroProposta,
    //     //         Parceiro__c = '67708896000139',
    //     //         CupomDesconto__c = 'VALE50DESCONTO'

    //     // );
    //     // insert proposta;

    //     System.debug('proposta ==>' + JSON.serialize(proposta));

    //     RemuneracaoProposta__c corretagem = new RemuneracaoProposta__c(
    //         Proposta__c = proposta.Id,
    //         Percentual__c = 10            
    //     );
    //     insert corretagem;

    //     RemuneracaoProposta__c agenciamento = new RemuneracaoProposta__c(
    //         Proposta__c = proposta.Id,
    //         Percentual__c = 100            
    //     );
    //     insert agenciamento;

    //     FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c(
    //         Conta__c = contaTeste.Id,           
    //         CorretorLider__c = true,
    //         Papel__c = 'Corretor',
    //         Participacao__c = 10.00,
    //         RemuneracaoProposta__c = corretagem.Id,
    //         Susep__c = 'REN01J',
    //         SusepEmissao__c = 'REN01J',
    //         SusepOficialCorretor__c = '123',
    //         SusepOrcamento__c = 'REN01J',
    //         AntecipacaoComissao__c = true,
    //         DadosCorretor__c = dadosCorretor.Id
    //     );

    //     insert favorecidoRemuneracaoProposta;
    //     //II-167 FIM

    //     ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contract, contaTeste, contaTeste);

    //     GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);

    //     Garantia__c garantia = TestDataFactory.gerarGarantia();

    //     GarantiaContrato__c garantiaContrato = TestDataFactory.gerarGarantiaContrato(contract, garantiaComercial);

    //     CondicaoCobranca__c condicaoCobranca = new CondicaoCobranca__c(
    //             Produto__c = produtoCom.Id,
    //             FormaPagamento__c = formaPagamento.Id,
    //             QuantidadeParcelas__c = '1;2;3;4;5;6;7;8;9;10',            	
    //             PercentualDescontoAgravo__c = 0            	
    //     );
    //     insert condicaoCobranca;
    // }
    
    @TestSetup
    static void makeData(){
        Account contaTeste = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        produtoTec.ProductCode = '49';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        produtoCom.ProductCode = 'APTLMKT';
        produtoCom.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoCom;


        GarantiaProduto__c garantiaTecnica = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);

        GarantiaProduto__c garantiaComercial = TestDataFactory.gerarGarantiaProdutoComercial(produtoCom, garantia1, garantiaTecnica, ramoSegurado);

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
      
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);   //RVI-247 - INICIO/FIM
        // RVI-186-FIX02 - INICIO
       
        Opportunity orcamentoRenovado = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-00006790',
            CloseDate = System.today().addDays(20),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            Produto__c = produtoCom.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
            AccountId = contaTeste.Id,
            Numero__c = '00006790',
            CanalDistribuicao__c = canalDistribuicao.Id
        );
        insert orcamentoRenovado;
        // RVI-186-FIX02 - FIM
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoCom);
        paramVigencia.VigenciaMinimaRenovacao__c = 90;
        paramVigencia.Tipo__c = 'Periódico';
        update paramVigencia;

        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        cot.NumeroProposta__c = '00001910';
        cot.email__c = 'abcd@qualqueremail.com';
        update cot;

        Contract contract = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        contract.AccountId = contaTeste.Id;
        contract.NumeroPropostaUnico__c = '18-00001911';
        update contract;

        //TKCL-246 FIX-05 INICIO
        ContratanteContrato__c segurado = new ContratanteContrato__c(
			conta__c = contaTeste.Id,
			Contrato__c = contract.Id,
			Tipo__c = 'Principal'
		);
		insert segurado;

        GrupoContrato__c grupo = new GrupoContrato__c(
			Name = 'Teste',
			QuantidadeVidas__c = 1,
			ContratanteContrato__c = segurado.Id
		);
		insert grupo;

        SeguradoContrato__c vida = new SeguradoContrato__c(
			Conta__c = contaTeste.Id,
			GrupoContrato__c = grupo.Id
		);
		insert vida;

        GarantiaContrato__c garantiaContrato = new GarantiaContrato__c(
			Contrato__c = contract.Id,
			GarantiaProduto__c = garantiaTecnica.Id,
			Garantia__c = garantiaTecnica.Garantia__c,
			TipoCapital__c = 'Capital uniforme',
            Capital__c = 1
        );
		insert garantiaContrato;
        //TKCL-246 FIX-05 FIM

        //RamoSeguro__c ramoSeguro, Modalidade__c modalidade, String name, String codigo
        FormaPagamento__c formPag = TestDataFactory.gerarFormaPagamento(ramoSegurado, modalidade, 'CARTAO DE CREDITO (TODAS PARC.EM CARTAO)', '62');

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.NumeroPropostaUnico__c = '18-00001910';
        contrato.NumeroApolice__c = '000014419';
        contrato.Tipo__c = 'Novo';   //RVI-160 - INICIO/FIM
        contrato.Status = 'Emitido'; //RVI-160 - INICIO/FIM
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c = System.today().addDays(30);		       		    		    
        contrato.StatusRenovacao__c = 'Renovação em andamento'; //RVI-160 - INICIO/FIM
        contrato.CodigoRamo__c = '1391';    
        contrato.ApolicePdfDownloadUrl__c = 'https://MestreChico.com'; //RVI-57 - INICIO/FIM   
        contrato.AlteraFormaPagto__c = false; // RVI-186 - FIX02 - INICIO/FIM    
        update contrato;

        // RVI-186-FIX02 - INICIO 
        // Contract contratoRenovado = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        // contratoRenovado.Oportunidade__c = orcamentoRenovado.Id;
        // contratoRenovado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
        // contratoRenovado.PrimeiroContratoRenovacao__c = contrato.Id;		
        // contratoRenovado.NumeroPropostaUnico__c = '18-00001911';
        // contratoRenovado.NumeroApolice__c = '000014419';
        // contratoRenovado.ContratoRenovado__c = contrato.Id; //RVI-160 - INICIO/FIM
        // contratoRenovado.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
        // contratoRenovado.Status = 'Emitido';    //RVI-160 - INICIO/FIM
        // contratoRenovado.Endosso__c = '1';
        // contratoRenovado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        // contratoRenovado.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        // contratoRenovado.CodigoRamo__c = '1391';   
        // contratoRenovado.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';  //RVI-57 - INICIO/FIM 
        // update contratoRenovado;

        //Contract contratoRenovado = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        Contract contratoRenovado = new Contract();
        contratoRenovado.Oportunidade__c = orcamentoRenovado.Id;
        contratoRenovado.Produto__c = produtoCom.Id;        
        contratoRenovado.RamoSeguro__c = ramoSegurado.Id;
        contratoRenovado.Status = 'Em elaboração' ;
        contratoRenovado.Empresa__c = '22';
        contratoRenovado.CodigoCorretor__c = dadosCorretor.Id;
        contratoRenovado.Proposta__c = cot.Id;
        contratoRenovado.AccountId = contaTeste.Id;
        contratoRenovado.AlteraFormaPagto__c = false;
        contratoRenovado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
        contratoRenovado.PrimeiroContratoRenovacao__c = contrato.Id;		
        contratoRenovado.NumeroPropostaUnico__c = '18-00001911';
        contratoRenovado.NumeroApolice__c = '000014419';
        contratoRenovado.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
        contratoRenovado.Endosso__c = '1';
        contratoRenovado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        contratoRenovado.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        contratoRenovado.CodigoRamo__c = '1391';   
        contratoRenovado.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';  //RVI-57 - INICIO/FIM 
        insert contratoRenovado;
        // RVI-186-FIX02 - FIM 


        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('Contrato', 15, 1000, 'Integral');

        RemuneracaoContrato__c remCon = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        remCon.CurrencyIsoCode = 'BRL';
        remCon.Percentual__c = 10;
        remCon.Porcentagem_de_Retencao__c = 0;
        update remCon;

        //RVI-160 - INICIO
        RemuneracaoContrato__c remConRen = TestDataFactory.gerarRemuneracaoContrato(contratoRenovado, tipoRemuneracao);
        remConRen.CurrencyIsoCode = 'BRL';
        remConRen.Percentual__c = 10;
        remConRen.Porcentagem_de_Retencao__c = 0;
        update remConRen;
        //RVI-160 - FIM

        FavorecidoRemuneracaoContrato__c favRemCon = new FavorecidoRemuneracaoContrato__c();
        favRemCon.Conta__c = contaTeste.Id;
        favRemCon.CorretorLider__c = true;
        favRemCon.AntecipacaoComissao__c = true;
        favRemCon.RemuneracaoContrato__c = remCon.Id;
        favRemCon.Papel__c = 'Corretor';
        insert favRemCon;
        
        //RVI-160 - INICIO
        FavorecidoRemuneracaoContrato__c favRemConRen = new FavorecidoRemuneracaoContrato__c();
        favRemConRen.Conta__c = contaTeste.Id;
        favRemConRen.CorretorLider__c = true;
        favRemConRen.AntecipacaoComissao__c = true;
        favRemConRen.RemuneracaoContrato__c = remConRen.Id;
        favRemConRen.Papel__c = 'Corretor';
        insert favRemConRen;
        //RVI-160 - FIM

        GarantiaContrato__c garCtr = TestDataFactory.gerarGarantiaContrato(contrato, garantiaComercial);
        GarantiaContrato__c garCtrRen = TestDataFactory.gerarGarantiaContrato(contratoRenovado, garantiaComercial); //RVI-160 - INICIO/FIM
    }
    
    @isTest
    public static void testUnit(){
        Test.startTest(); //AV-824 - iNICIO/FIM
        Contract proposta = [SELECT Id, DataEmissao__c, NumeroPropostaUnico__c FROM Contract LIMIT 1];
        
        proposta.DataEmissao__c  = system.today();
        update proposta;
        ContratanteContrato__c contratanteProp = [SELECT Id FROM ContratanteContrato__c WHERE Contrato__c =: proposta.Id];
        System.debug('ContratanteContrato__c' + contratanteProp);
        GrupoContrato__c grupoProp = [SELECT Id FROM GrupoContrato__c WHERE ContratanteContrato__c =: contratanteProp.Id];
        SeguradoContrato__c seguradoProposta = [SELECT Id FROM SeguradoContrato__c WHERE GrupoContrato__c =:grupoProp.Id];
        
        seguradoProposta.NomeContatoEmergencia__c = 'Esmeralda da Silva Pereiraaaaaaaaaaaaaaaaaaaaaa';
        seguradoProposta.TelefoneContatoEmergencia__c = '11987366364';
        
        update seguradoProposta;
        
        //Test.startTest(); //AV-824 - iNICIO/FIM
        
        PageReference pdf = Page.VoucherContractPage;
        Map<String,String> mPDFParam = pdf.getParameters();
        mPDFParam.put('propostaId', proposta.Id);
        
        //PLV-3746
        
        CryptoToken c = new CryptoToken();
		String cri = c.encrypt(proposta.Id+'|Voucher_18_00022084');
		mPDFParam.put('token', cri);
		
        //Fim - PLV-3746
        
        mPDFParam.put('renderAs', 'pdf');
        Test.setCurrentPage(pdf);
        ApexPages.StandardController sc = new ApexPages.standardController(proposta);
        GeraVoucherPorContratoPDFController apc = new GeraVoucherPorContratoPDFController();
        apc.doAction();
        
        GeraVoucherPorContratoPDFController controller = new GeraVoucherPorContratoPDFController();
	//PlV - inicio 3884 Ajustado Moedas
        //decimal valord = 900.00;
        //string valor = valord.format();
        //GeraVoucherPorContratoPDFController.trataValores(valor);
	//PlV - fim
        Test.stopTest();
    }
    @isTest
    public static void testUnit2(){
         //TKCL-246 FIX-05 INICIO
        Test.startTest(); //AV-824 - iNICIO/FIM
        Contract proposta = [SELECT Id, Produto__c,NumeroPropostaUnico__c, Produto__r.GerarVoucher__c, Segmento__c FROM Contract LIMIT 1];
        //System.debug([SELECT Id, Produto__c, Produto__r.GerarVoucher__c, Segmento__c FROM Quote LIMIT 1]);
        proposta.Produto__r.GerarVoucher__c = true;
        // proposta.DataProtocolo__c = system.today();
        update proposta;
        ContratanteContrato__c contratanteProp = [SELECT Id FROM ContratanteContrato__c WHERE Contrato__c =: proposta.Id];
        GrupoContrato__c grupoProp = [SELECT Id FROM GrupoContrato__c WHERE ContratanteContrato__c =: contratanteProp.Id];
        SeguradoContrato__c seguradoProposta = [SELECT Id FROM SeguradoContrato__c WHERE GrupoContrato__c =:grupoProp.Id];
        
        seguradoProposta.NomeContatoEmergencia__c = 'Esmeralda da Silva Pereiraaaaaaaaaaaaaaaaaaaaaa';
        seguradoProposta.TelefoneContatoEmergencia__c = '11987366364';
        
        update seguradoProposta;
        //System.debug([SELECT Id, Produto__c, Produto__r.GerarVoucher__c FROM Quote LIMIT 1]);
        //Test.startTest(); //AV-824 - iNICIO/FIM
         //TKCL-246 FIX-05 FIM
        PageReference pdf = Page.VoucherContractPage;
        Map<String,String> mPDFParam = pdf.getParameters();
        mPDFParam.put('propostaId', proposta.Id);
        
        //PLV-3746
        
        CryptoToken c = new CryptoToken();
		String cri = c.encrypt(proposta.Id+'|Voucher_18_00022084');
		mPDFParam.put('token', cri);
		
        //Fim - PLV-3746
        
        mPDFParam.put('renderAs', 'pdf');
        Test.setCurrentPage(pdf);
        ApexPages.StandardController sc = new ApexPages.standardController(proposta);
        GeraVoucherPorContratoPDFController apc = new GeraVoucherPorContratoPDFController();
        apc.doAction();
        
        GeraVoucherPorContratoPDFController controller = new GeraVoucherPorContratoPDFController();
        //PLV-3884 - INICIO
        decimal a = 2000.6;
		String valor = a.format();
        GeraVoucherPorContratoPDFController.trataValores(valor, 'BRL');
		GeraVoucherPorContratoPDFController.trataValores(valor, 'USD');
        GeraVoucherPorContratoPDFController.trataValores(valor, 'EUR');
        
        integer b = 2000;
		String valor2 = b.format();

        GeraVoucherPorContratoPDFController.trataValores(valor2, 'BRL');
		GeraVoucherPorContratoPDFController.trataValores(valor2, 'USD');
        GeraVoucherPorContratoPDFController.trataValores(valor2, 'EUR');
        //PLV-3884 - FIM
        Test.stopTest();
    }

    /* PLV-5277 - INICIO */
    @isTest
    public static void testUnit3(){
        
        Test.startTest(); //TKCL-246 FIX-05 INICIO/FIM
        
        Product2 produtoTec = [SELECT Id, ProdutoTecnico__c, GerarVoucher__c FROM Product2 WHERE ProdutoTecnico__c = null LIMIT 1];
        produtoTec.GerarVoucher__c = true;
        update produtoTec;
        
        Product2 produto = [SELECT Id, GerarVoucher__c FROM Product2 WHERE Id IN (
            SELECT produto__c FROM Contract
        ) LIMIT 1];
        produto.GerarVoucher__c = true;
        update produto;
        
        Contract proposta = [SELECT Id, Name, DataEmissao__c, NumeroPropostaUnico__c FROM Contract LIMIT 1];
        proposta.Produto__c = produto.Id;
        proposta.DataEmissao__c = system.today();
        update proposta;

        SeguradoContrato__c seguradoProposta = [SELECT Id, GrupoContrato__r.ContratanteContrato__r.Contrato__r.Name, 
                                                        GrupoContrato__r.ContratanteContrato__r.Contrato__c
                                                FROM SeguradoContrato__c 
                                                WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c =: proposta.Id];

        seguradoProposta.TelefoneContatoEmergencia__c = '1987366364';
        
        update seguradoProposta;
        
        PageReference pdf = Page.VoucherContractPage;
        Map<String,String> mPDFParam = pdf.getParameters();
        mPDFParam.put('numero', proposta.Name);
        mPDFParam.put('renderAs', 'pdf');

        Test.setCurrentPage(pdf);
        ApexPages.StandardController sc = new ApexPages.standardController(proposta);
        // GeraVoucherPorContratoPDFController apc = new GeraVoucherPorContratoPDFController();

        // apc.doAction();
        // GeraVoucherPorContratoPDFController apc = new GeraVoucherPorContratoPDFController();

        
        // GeraVoucherPorContratoPDFController controller = new GeraVoucherPorContratoPDFController();
        // controller.doAction();
        Test.stopTest();
    }

    @isTest
    public static void testUnit4(){
        
        Test.startTest();  //TKCL-246 FIX-05 INICIO
        
        Product2 produtoTec = [SELECT Id, ProdutoTecnico__c, GerarVoucher__c FROM Product2 WHERE ProdutoTecnico__c = null LIMIT 1];
        produtoTec.GerarVoucher__c = true;
        update produtoTec;
        
        Product2 produto = [SELECT Id, GerarVoucher__c FROM Product2 WHERE Id IN (
            SELECT produto__c FROM Contract
        ) LIMIT 1];
        produto.GerarVoucher__c = true;
        update produto;
        
        Contract proposta = [SELECT Id, Name, NumeroPropostaUnico__c FROM Contract LIMIT 1];
        // proposta.DataProtocolo__c = system.today();
        update proposta;

        SeguradoContrato__c seguradoProposta = [SELECT Id, GrupoContrato__r.ContratanteContrato__r.Contrato__r.Name, 
                                                        GrupoContrato__r.ContratanteContrato__r.Contrato__c, 
                                                        GrupoContrato__r.ContratanteContrato__r.Contrato__r.Produto__r.ProdutoTecnico__c
                                                FROM SeguradoContrato__c 
                                                WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c =: proposta.Id];

        seguradoProposta.TelefoneContatoEmergencia__c = '11987366364';
        update seguradoProposta;
		 //TKCL-246 FIX-05 INICIO
        GarantiaProduto__c garantiaProduto = [SELECT  Id, Garantia__c, Garantia__r.Name,OrdemPrioridade__c, LimiteMinimoCaracteristicaEspecial__c,
                                              LimiteMaximoCaracteristicaEspecial__c, TipoCaracteristicaEspecial__c,Garantia__r.Sigla__c
                                              FROM GarantiaProduto__c
                                              WHERE Produto__c =: seguradoProposta.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Produto__r.ProdutoTecnico__c ORDER BY OrdemPrioridade__c ASC LIMIT 1];

        GarantiaContrato__c garantiaProposta = [SELECT Id, Capital__c, Garantia__r.Name, Garantia__r.Sigla__c, Garantia__c, CurrencyIsoCode //AV-824 - INICIO/FIM
                                                FROM GarantiaContrato__c
                                                WHERE Contrato__c =: seguradoProposta.GrupoContrato__r.ContratanteContrato__r.Contrato__c LIMIT 1];

        garantiaProposta.Garantia__c = garantiaProduto.Garantia__c; 
        update garantiaProposta;
        

		 //TKCL-246 FIX-05 FIM
        PageReference pdf = Page.VoucherContractPage;
        Map<String,String> mPDFParam = pdf.getParameters();
        mPDFParam.put('numero', proposta.Name);
        mPDFParam.put('renderAs', 'pdf');

        Test.setCurrentPage(pdf);
        ApexPages.StandardController sc = new ApexPages.standardController(proposta);
        // GeraVoucherPorContratoPDFController apc = new GeraVoucherPorContratoPDFController();

        // apc.doAction();
        
        Test.stopTest();
    }

    @isTest
    public static void testUnit5(){
        
        Test.startTest(); 
        
        Product2 produtoTec = [SELECT Id, ProdutoTecnico__c, GerarVoucher__c FROM Product2 WHERE ProdutoTecnico__c = null LIMIT 1];
        produtoTec.GerarVoucher__c = true;
        update produtoTec;
        
        Product2 produto = [SELECT Id, GerarVoucher__c FROM Product2 WHERE Id IN (
            SELECT produto__c FROM Contract
        ) LIMIT 1];
        produto.GerarVoucher__c = true;
        update produto;
        
        Contract proposta = [SELECT Id, Name, NumeroPropostaUnico__c FROM Contract LIMIT 1];
        // proposta.DataProtocolo__c = system.today();
        update proposta;

        SeguradoContrato__c seguradoProposta = [SELECT Id, GrupoContrato__r.ContratanteContrato__r.Contrato__r.Name, 
                                                        GrupoContrato__r.ContratanteContrato__r.Contrato__c, 
                                                        GrupoContrato__r.ContratanteContrato__r.Contrato__r.Produto__r.ProdutoTecnico__c
                                                FROM SeguradoContrato__c 
                                                WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c =: proposta.Id];

        seguradoProposta.TelefoneContatoEmergencia__c = '11987366364';
        update seguradoProposta;

        GarantiaProduto__c garantiaProduto = [SELECT  Id, Garantia__c, Garantia__r.Name,OrdemPrioridade__c, LimiteMinimoCaracteristicaEspecial__c,
                                              LimiteMaximoCaracteristicaEspecial__c, TipoCaracteristicaEspecial__c,Garantia__r.Sigla__c
                                              FROM GarantiaProduto__c
                                              WHERE Produto__c =: seguradoProposta.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Produto__r.ProdutoTecnico__c ORDER BY OrdemPrioridade__c ASC LIMIT 1];

        GarantiaContrato__c garantiaProposta = [SELECT Id, Capital__c, Garantia__r.Name, Garantia__r.Sigla__c, Garantia__c, CurrencyIsoCode
                                                FROM GarantiaContrato__c
                                                WHERE Contrato__c =: seguradoProposta.GrupoContrato__r.ContratanteContrato__r.Contrato__c LIMIT 1];

        garantiaProposta.Garantia__c = garantiaProduto.Garantia__c;
        garantiaProposta.Capital__c = 0; 
        update garantiaProposta;
        
        PageReference pdf = Page.VoucherContractPage;
        Map<String,String> mPDFParam = pdf.getParameters();
        mPDFParam.put('numero', proposta.Name);
        mPDFParam.put('renderAs', 'pdf');

        Test.setCurrentPage(pdf);
        ApexPages.StandardController sc = new ApexPages.standardController(proposta);
        // GeraVoucherPorContratoPDFController apc = new GeraVoucherPorContratoPDFController();

        // apc.doAction();
        
        Test.stopTest();
    }

    @isTest
    public static void testUnit6(){        
        Test.startTest();
        
        Product2 produtoTec = [SELECT Id, ProdutoTecnico__c, GerarVoucher__c FROM Product2 WHERE ProdutoTecnico__c = null LIMIT 1];
        produtoTec.GerarVoucher__c = true;
        update produtoTec;
        
        Product2 produto = [SELECT Id, GerarVoucher__c FROM Product2 WHERE Id IN (
            SELECT produto__c FROM Contract
        ) LIMIT 1];
        produto.GerarVoucher__c = true;
        update produto;
        
        Contract proposta = [SELECT Id, Name, NumeroPropostaUnico__c FROM Contract LIMIT 1];
        // proposta.DataProtocolo__c = system.today();
        update proposta;

        SeguradoContrato__c seguradoProposta = [SELECT Id, GrupoContrato__r.ContratanteContrato__r.Contrato__r.Name, 
                                                        GrupoContrato__r.ContratanteContrato__r.Contrato__c, 
                                                        GrupoContrato__r.ContratanteContrato__r.Contrato__r.Produto__r.ProdutoTecnico__c
                                                FROM SeguradoContrato__c 
                                                WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c =: proposta.Id];

        seguradoProposta.TelefoneContatoEmergencia__c = '11987366364';
        update seguradoProposta;

        GarantiaProduto__c garantiaProduto = [SELECT  Id, Garantia__c, Garantia__r.Name,OrdemPrioridade__c, LimiteMinimoCaracteristicaEspecial__c,
                                              LimiteMaximoCaracteristicaEspecial__c, TipoCaracteristicaEspecial__c,Garantia__r.Sigla__c
                                              FROM GarantiaProduto__c
                                              WHERE Produto__c =: seguradoProposta.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Produto__r.ProdutoTecnico__c ORDER BY OrdemPrioridade__c ASC LIMIT 1];

        GarantiaContrato__c garantiaProposta = [SELECT Id, Capital__c, Garantia__r.Name, Garantia__r.Sigla__c, Garantia__c, CurrencyIsoCode
                                                FROM GarantiaContrato__c
                                                WHERE Contrato__c =: seguradoProposta.GrupoContrato__r.ContratanteContrato__r.Contrato__c LIMIT 1];
        garantiaProposta.Garantia__c = null;
        update garantiaProposta;
        PageReference pdf = Page.VoucherContractPage;
        Map<String,String> mPDFParam = pdf.getParameters();
        mPDFParam.put('numero', proposta.Name);
        mPDFParam.put('renderAs', 'pdf');

        Test.setCurrentPage(pdf);
        ApexPages.StandardController sc = new ApexPages.standardController(proposta);
        GeraVoucherPorContratoPDFController apc = new GeraVoucherPorContratoPDFController();

        apc.doAction();
        
        Test.stopTest();
    }
    /* PLV-5277 - FIM */
}
//PLV-2939 - FIM
// PLV-3726 FIM
//II-154 FIM