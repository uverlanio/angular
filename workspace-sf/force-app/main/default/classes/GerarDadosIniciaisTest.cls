/*********************************************************************************************************************************************************************
@description  Classe de teste para geração de dados iniciais no processo de contratação
@author Isabela Fin - Avanxo
@date 13/01/2020
@Classe criada por conta da história PLV-2146      
**********************************************************************************************************************************************************************/
@isTest
public class GerarDadosIniciaisTest {
    @testSetup
    static void setupUnity() {
        //PLV-2146 FIX - INICIO/FIM - Codigo removido por conta da historia PLV-2146
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        //Ativar o Produto Tecnico
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        produtoTecnico.segmento__c = 'Individual'; //PLV-4168 - V.I - INICIO/FIM
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.ProductCode = '1';
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.segmento__c = 'Individual'; //PLV-4168 - V.I - INICIO/FIM
        produtoComercial.CodigoPrecificaProduto__c = 'VI-PESSOAS'; // PLV-5331 INICIO / FIM
        update produtoComercial;
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        CondicaoCobranca__c condicaoCobranca = (CondicaoCobranca__c) new CondicaoCobrancaFactory.CondicaoCobranca(produtoComercial, formaPagamento).createRecord();
		//PLV-3729 - INICIO - Índice monetário
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory().createRecord();
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garantiaProdutoTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garantiaProdutoCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garantiaProdutoTec, ramoSeguro).createRecord();
        
        //PLV - 4487 - VI - INICIO - Gustavo Pereira SYS4B
        Account contaTeste = TestDataFactory.gerarConta();
        Endereco__c endereco = TestDataFactory.gerarEndereco(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Produto Porto';
        update garantiaCobertura;
        RamoGarantia__c ramoGarantia1 = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        Map<String,List<SObject>> mapListSObject = TestDataFactory.gerarProdutoComercialAtivo(false);
        produtoCom.Status__c ='ativo';
        update produtoCom;
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoCom);
        //FormaPagamento__c formaPagamento1 = TestDataFactory.gerarFormaPagamento();
        Parceiro__C parceiro = TestDataFactory.gerarParceiro(contaTeste, formaPagamento);
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoCom);
        Opportunity opp = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        InformacaoBancaria__c InformacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaTeste);
        RemuneracaoProdutoParceiro__c RemuneracaoProdutoParceiro = TestDataFactory.gerarRemuneracaoProdutoParceiro(tipoRemuneracao, produtoParceiro, 20);
        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(contaTeste, 20.00, 'Corretor', true, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);        
        system.debug('favorecidoRemuneracao: '+favorecidoRemuneracao.RemuneracaoProdutoParceiro__c); 
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, opp, modalidade);
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        //FNPVVEP-71 INICIO
        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
        favorecidoRemuneracaoContrato.Conta__c = contaTeste.Id;
        favorecidoRemuneracaoContrato.CorretorLider__c = TRUE;
        favorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
        favorecidoRemuneracaoContrato.Susep__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepEmissao__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepOrcamento__c='p5005j';
        favorecidoRemuneracaoContrato.DadosCorretor__c = dadosCorretor.Id;
        favorecidoRemuneracaoContrato.Papel__c ='Corretor';
        favorecidoRemuneracaoContrato.Participacao__c =100;
        insert favorecidoRemuneracaoContrato;
        //FNPVVEP-71 FIM
        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaTeste, contaTeste);
        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c segurado = TestDataFactory.gerarSeguradoContrato(grupoContrato, contaTeste);
        //FNPVVEP-71 INICIO
        BeneficiarioSeguradoContrato__c beneficiario = new BeneficiarioSeguradoContrato__c();
        beneficiario.Nome__c ='';
        beneficiario.CpfCnpj__c= '';
        beneficiario.Conta__c = contaTeste.Id;
        beneficiario.GrauParentescoPep__c ='Avó';
        beneficiario.SeguradoContrato__c = segurado.Id;
        beneficiario.Participacao__c = 10;
        beneficiario.TipoBeneficiario__c ='Nome do beneficiário';
        insert beneficiario;
        //FNPVVEP-71 FIM
		
        // PLV - 4655 INICIO
        GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        Profissao__c profissao = new Profissao__c();

        profissao.CodigoProfissao__c = '2111-05';
        profissao.Name = 'Atuário';
        insert profissao;
        grupoRisco.Name = 'DIT';
        Insert grupoRisco;
        grupoProfissao.grupoRisco__c = grupoRisco.Id;
        grupoProfissao.profissao__c = profissao.Id;
        insert grupoProfissao;
        // PLV - 4655 FIM

        GarantiaContrato__c garantiacont = TestDataFactory.gerarGarantiaContrato(contrato,garantiaProdutoCom);//PLV-4666 -INICIO/FIM
        
        GerarDadosIniciais controller = new GerarDadosIniciais();
		controller.gerarcontratoOriginal(PayloadTO(contrato.Empresa__c, contrato.Sucursal__c, contrato.CodigoRamo__c, contrato.NumeroApolice__c, contrato.Endosso__c,'VI-PESSOAS'));//PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B 
        controller.gerarcontratoOriginal(PayloadTO(contrato.Empresa__c, contrato.Sucursal__c, contrato.CodigoRamo__c, contrato.NumeroApolice__c, contrato.Endosso__c,'APTLMKT')); // II-25 INICIO/FIM
        //PLV - 4487 - VI - FIM - Gustavo Pereira SYS4B
      		
        garantiaProdutoCom.currencyIsoCode = 'USD';
        update garantiaProdutoCom;
        //PLV-3729 - FIM - Índice monetário

        //PLV-3317 - INÍCIO       
        ContadorCodigo__c confNumOferta = new ContadorCodigo__c(Name='NumeroOferta', Numero__c = 0);
        insert confNumOferta;
        //PLV-3317 - FIM
    }
    @isTest
    static void testUnity() { //PLV-2146 FIX - INICIO/FIM - Alteração de nome e assinatura do método (Conta não será mais gerada nesta etapa)
        String payload = gerarJsonEnvio(); //PLV-2146 FIX - INICIO/FIM - Alteração de 
        System.debug('payload: <>``' + payload);
        Test.startTest();
        // Product2 produto = [SELECT ProductCode, VigenciaInicial__c, Segmento__c FROM Product2 WHERE ProductCode = '1' LIMIT 1]; // PLV-5331 INICIO / FIM
        Product2 produto = [SELECT ProductCode, VigenciaInicial__c, Segmento__c FROM Product2 LIMIT 1]; // PLV-5331 INICIO / FIM
        produto.Segmento__c = 'Viagem';
        
        String jsonRetorno = GerarDadosIniciais.getInstance().gerarDadosIniciais(payload);     
        Test.stopTest(); 
        System.debug('GerarDadosIniciaisTest - TestUnit -  Viagem - jsonRetorno: ' + jsonRetorno);
    }
    // PLV-5461 INICIO 
     @isTest
     static void seguroViagemCupomValido() { //PLV-2146 FIX - INICIO/FIM - Alteração de nome e assinatura do método (Conta não será mais gerada nesta etapa)
     String payload = gerarJsonEnvioCupomValido(); //PLV-2146 FIX - INICIO/FIM - Alteração de assinatura do método (Conta não será mais gerada nesta etapa)
        
        Test.startTest();
        // Product2 produto = [SELECT ProductCode, VigenciaInicial__c, Segmento__c FROM Product2 WHERE ProductCode = '1' LIMIT 1]; // PLV-5331 INICIO / FIM
        Product2 produto = [SELECT ProductCode, VigenciaInicial__c, Segmento__c FROM Product2 LIMIT 1]; // PLV-5331 INICIO / FIM
        produto.Segmento__c = 'Viagem';
        
        String jsonRetorno = GerarDadosIniciais.getInstance().gerarDadosIniciais(payload); 
        Test.stopTest(); 
        System.debug('GerarDadosIniciaisTest - TestUnit -  Viagem Cupom Válido- jsonRetorno: ' + jsonRetorno);
    }
    @isTest
     static void seguroViagemCupomInvalido() { //PLV-2146 FIX - INICIO/FIM - Alteração de nome e assinatura do método (Conta não será mais gerada nesta etapa)
     String payload = gerarJsonEnvioCupomInvalido(); //PLV-2146 FIX - INICIO/FIM - Alteração de assinatura do método (Conta não será mais gerada nesta etapa)
        
        Test.startTest();
        // Product2 produto = [SELECT ProductCode, VigenciaInicial__c, Segmento__c FROM Product2 WHERE ProductCode = '1' LIMIT 1]; // PLV-5331 INICIO / FIM
        Product2 produto = [SELECT ProductCode, VigenciaInicial__c, Segmento__c FROM Product2 LIMIT 1]; // PLV-5331 INICIO / FIM
        produto.Segmento__c = 'Viagem';
        
        String jsonRetorno = GerarDadosIniciais.getInstance().gerarDadosIniciais(payload); 
        Test.stopTest(); 
        System.debug('GerarDadosIniciaisTest - TestUnit -  Viagem - jsonRetorno: ' + jsonRetorno);
    }
   /*
    @isTest
     static void seguroViagemCupomExcedido() { //PLV-2146 FIX - INICIO/FIM - Alteração de nome e assinatura do método (Conta não será mais gerada nesta etapa)
     String payload = gerarJsonEnvioCupomExcedido(); //PLV-2146 FIX - INICIO/FIM - Alteração de assinatura do método (Conta não será mais gerada nesta etapa)
        
        Test.startTest();
        // Product2 produto = [SELECT ProductCode, VigenciaInicial__c, Segmento__c FROM Product2 WHERE ProductCode = '1' LIMIT 1]; // PLV-5331 INICIO / FIM
        Product2 produto = [SELECT ProductCode, VigenciaInicial__c, Segmento__c FROM Product2 LIMIT 1]; // PLV-5331 INICIO / FIM
        produto.Segmento__c = 'Viagem';
        
        String jsonRetorno = GerarDadosIniciais.getInstance().gerarDadosIniciais(payload); 
        Test.stopTest(); 
        System.debug('GerarDadosIniciaisTest - TestUnit -  Viagem - jsonRetorno: ' + jsonRetorno);
    }
*/
     @isTest
     static void seguroViagemCupomExpirado() { //PLV-2146 FIX - INICIO/FIM - Alteração de nome e assinatura do método (Conta não será mais gerada nesta etapa)
     String payload = gerarJsonEnvioCupomExpirado(); //PLV-2146 FIX - INICIO/FIM - Alteração de assinatura do método (Conta não será mais gerada nesta etapa)
        
        Test.startTest();
        // Product2 produto = [SELECT ProductCode, VigenciaInicial__c, Segmento__c FROM Product2 WHERE ProductCode = '1' LIMIT 1]; // PLV-5331 INICIO / FIM
        Product2 produto = [SELECT ProductCode, VigenciaInicial__c, Segmento__c FROM Product2 LIMIT 1]; // PLV-5331 INICIO / FIM
        produto.Segmento__c = 'Viagem';
        
        String jsonRetorno = GerarDadosIniciais.getInstance().gerarDadosIniciais(payload); 
        Test.stopTest(); 
        System.debug('GerarDadosIniciaisTest - TestUnit -  Viagem - jsonRetorno: ' + jsonRetorno);
    }
       

    // II-25-FIX01 INICIO
    //PLV-5461 FIM
    //PLV-4403 INICIO
    // @isTest
    // static void gerarDadosIniciaisComVigenciaTest() { 
    //     Test.startTest();
    //     Product2 produto = [SELECT ProductCode, VigenciaInicial__c, Segmento__c FROM Product2 WHERE ProductCode = '1' LIMIT 1]; //PLV-2146 FIX - INICIO/FIM - Pesquisa do produto pelo código para garantir assertividade da query
    //     produto.ProductCode = 'VI-PESSOAS';
    //     produto.CodigoPrecificaProduto__c = produto.ProductCode; // PLV-5331 INICIO / FIM
    //     update produto;

    //     Contract ctract = [SELECT Id, Produto__c FROM Contract LIMIT 1]; // PLV-5331 INICIO / FIM
    //     ctract.Produto__c = produto.Id; // PLV-5331 INICIO / FIM
    //     update ctract; // PLV-5331 INICIO / FIM
        
    //     ParametroVigencia__c parametroTec = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaTecnico(produto).createRecord(); 
        
    //     parametroTec.PeriodoCoberturaMinimo__c = 1;
    //     parametroTec.PeriodoCoberturaMaximo__c = 1;
    //     parametroTec.Tipo__c = 'Periódico'; 
    //     parametroTec.PrazoMinimoCancelamento__c = null;
    //     parametroTec.ModeloResgate__c = null;
    //     parametroTec.PrazoAplicacaoReajuste__c = null;
    //     parametroTec.IndiceReajuste__c = null;
    //     parametroTec.PeriodoMinimoVigencia__c = null;
    //     parametroTec.PeriodoMaximoVigencia__c = null;

    //     update parametroTec;
        
    //     GerarDadosIniciaisTO.OrcamentoTO orcamentoEnvio = new GerarDadosIniciaisTO.OrcamentoTO();
    //     orcamentoEnvio.meioComercializacao = 'ARQ';
    //     orcamentoEnvio.idProdutoSf = produto.Id; // PLV-5331 INICIO / FIM // II-25-FIX01 INICIO/FIM
    //     orcamentoEnvio.dataCalculo = produto.VigenciaInicial__c;
    //     orcamentoEnvio.ordemPortal = 1;
    //     orcamentoEnvio.codigoProdutoVida = produto.ProductCode;
        
    //     //PLV-2146 FIX - INICIO/FIM - Codigo removido por conta da historia PLV-2146
        
    //     List<GerarDadosIniciaisTO.OrcamentoTO> listOrcamentos = new List<GerarDadosIniciaisTO.OrcamentoTO>();
    //     listOrcamentos.add(orcamentoEnvio);
    //     GerarDadosIniciaisTO.PayloadTO payloadTO = new GerarDadosIniciaisTO.PayloadTO();
    //     payloadTO.orcamentos = listOrcamentos;
    //     String payload = JSON.serialize(payloadTO);
        
    //     String jsonRetorno = GerarDadosIniciais.getInstance().gerarDadosIniciais(payload);      
    //     Test.stopTest();
    // }
    //PLV-4403 FIM

    // II-25-FIX01 FIM
    
    //PLV-2146 FIX - INICIO/FIM - Codigo removido por conta da historia PLV-2146
    
    //PLV-4168 - V.I - INICIO
    @isTest
    public static void preencherRetornoPrecificacaoTest(){

        test.startTest(); // II-25-FIX01 INICIO/FIM

        Product2 produto = [SELECT ProductCode, VigenciaInicial__c FROM Product2 WHERE ProductCode = '1' LIMIT 1];
        Garantia__c garantia = [SELECT Id, sigla__c FROM Garantia__c LIMIT 1];
        system.debug('garantia select: ' + garantia);
        garantia.sigla__c = 'HAH';
        update garantia;

        Recordtype REC_ID_PERSONACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');
		Date datePersonBirthdate = Date.newInstance(1985, 02, 02);

        Account conta = new Account(
            RecordtypeId = REC_ID_PERSONACCOUNT.Id,
            FirstName = 'TestFirstNamePessoaFisica',
            LastName = 'TestLastNamePessoaFisica',
            Cpf__c = '366.685.880-50',
            Pep__c = 'Não',
            Nacionalidade__c = 'Brasileira',
            Phone = '(00) 0000-0000', // ANNVI-55 - INICIO/FIM
            PersonBirthdate = datePersonBirthdate
        );
        
        insert conta;

        Opportunity oportunidade = (Opportunity) new OrcamentoFactory.VidaIndividual(produto,conta).createRecord();
        oportunidade.DescontoAgravoPercentualTecnico__c = 12.3;
        oportunidade.DescontoAgravoPercentualComercial__c = -3;
        oportunidade.DescontoAgravoMonetarioTecnico__c = 10;
        oportunidade.DescontoAgravoMonetarioComercial__c = 2.5;
        update oportunidade;

        GarantiaOrcamento__c coberturaOrcamento = (GarantiaOrcamento__c) new GarantiaOrcamentoFactory(garantia, oportunidade).createRecord();
        
        coberturaOrcamento.DescontoAgravoPercentualTecnico__c = 19.1;
        coberturaOrcamento.DescontoAgravoPercentualComercial__c = 7.0;
        coberturaOrcamento.DescontoAgravoMonetarioTecnico__c = 20;
        coberturaOrcamento.DescontoAgravoMonetarioComercial__c = 8.0;
        update coberturaOrcamento;
        
        //O relacionamento entre os objetos Opportunity e GarantiaOrcamento__c retorna null sem as querys abaixo.
        //Favor, não remover as querys para não quebrar a classe.
        oportunidade = [
            SELECT Id, 
            DescontoAgravoPercentualTecnico__c, DescontoAgravoPercentualComercial__c, 
            DescontoAgravoMonetarioTecnico__c, DescontoAgravoMonetarioComercial__c,
                (SELECT id, Orcamento__c,
                garantia__c, garantia__r.sigla__c,
                DescontoAgravoPercentualTecnico__c, DescontoAgravoPercentualComercial__c,
                DescontoAgravoMonetarioTecnico__c, DescontoAgravoMonetarioComercial__c
                FROM CoberturasOrcamento__r) 
            FROM Opportunity WHERE Id = :oportunidade.Id
            LIMIT 1
        ];
        
        coberturaOrcamento = [
            SELECT id, Orcamento__c, garantia__c, garantia__r.sigla__c, 
            DescontoAgravoPercentualTecnico__c, DescontoAgravoPercentualComercial__c,
            DescontoAgravoMonetarioTecnico__c, DescontoAgravoMonetarioComercial__c
            FROM GarantiaOrcamento__c 
            WHERE Id = :coberturaOrcamento.Id
            LIMIT 1
        ];
        
        GerarDadosIniciais GerarDados = new GerarDadosIniciais();
        List<GerarDadosIniciaisTO.DescontoAgravoTO> listaDescontoAgravoOrcamento = GerarDados.preencherRetornoPrecificacaoOrcamento(oportunidade);
        List<GerarDadosIniciaisTO.CoberturaTO> listaCoberturasOrcamento = GerarDados.preencherRetornoPrecificacaoCoberturasOrcamento(oportunidade);//PLV-4666 - INICIO/FIM

        test.stopTest(); // II-25-FIX01 INICIO/FIM

        system.assertEquals(false, listaDescontoAgravoOrcamento.isEmpty());
        system.assertEquals(false, listaCoberturasOrcamento.isEmpty());        
    }
    //PLV-4168 - V.I - FIM
    
    static String gerarJsonEnvio(){ //PLV-2146 FIX - INICIO/FIM - Alteração de assinatura do método (Conta não será mais gerada nesta etapa)
        Product2 produto = [SELECT ProductCode, VigenciaInicial__c FROM Product2 WHERE ProductCode = '1' LIMIT 1]; //PLV-2146 FIX - INICIO/FIM - Pesquisa do produto pelo código para garantir assertividade da query
        produto.ProductCode = 'VI-PESSOAS'; // PLV-5331 INICIO / FIM
        produto.CodigoPrecificaProduto__c = produto.ProductCode; // PLV-5331 INICIO / FIM
        update produto;

        // II-25-FIX01 INICIO
        // Contract ctract = [SELECT Id, Produto__c FROM Contract LIMIT 1]; // PLV-5331 INICIO / FIM
        // ctract.Produto__c = produto.Id; // PLV-5331 INICIO / FIM
        // update ctract; // PLV-5331 INICIO / FIM
        // II-25-FIX01 FIM
       	
        //PLV-2146 FIX - INICIO/FIM - Codigo removido por conta da historia PLV-2146
        GerarDadosIniciaisTO.OrcamentoTO orcamentoEnvio = new GerarDadosIniciaisTO.OrcamentoTO();
        orcamentoEnvio.meioComercializacao = 'ARQ';
        orcamentoEnvio.idProdutoSf = produto.Id; // PLV-5331 INICIO / FIM // II-25-FIX01 INICIO/FIM
        orcamentoEnvio.dataCalculo = produto.VigenciaInicial__c;
        orcamentoEnvio.ordemPortal = 1; //PLV-2146 FIX - INICIO/FIM - Adição do campo ordemPortal (valor devolvido sem alterações)
        System.debug('produto.dataCalculo: ' + produto.VigenciaInicial__c);
        orcamentoEnvio.codigoProdutoVida = produto.ProductCode;
        System.debug('produto.ProductCode: ' + produto.ProductCode);
        //orcamentoEnvio.tipoSeguro = 'eds';
        
        //PLV-2146 FIX - INICIO/FIM - Codigo removido por conta da historia PLV-2146
        
        List<GerarDadosIniciaisTO.OrcamentoTO> listOrcamentos = new List<GerarDadosIniciaisTO.OrcamentoTO>();
        listOrcamentos.add(orcamentoEnvio);
        GerarDadosIniciaisTO.PayloadTO payloadTO = new GerarDadosIniciaisTO.PayloadTO();
        payloadTO.orcamentos = listOrcamentos;
        String payload = JSON.serialize(payloadTO);
        System.debug('GerarDadosIniciaisTest - TestUnit - payload: ' + payload);
        return payload;
    }
    // PLV-5461 INICIO / FIM
        static String gerarJsonEnvioCupomValido(){ //PLV-2146 FIX - INICIO/FIM - Alteração de assinatura do método (Conta não será mais gerada nesta etapa)
        Product2 produto = [SELECT ProductCode, VigenciaInicial__c FROM Product2 WHERE ProductCode = '1' LIMIT 1]; //PLV-2146 FIX - INICIO/FIM - Pesquisa do produto pelo código para garantir assertividade da query
        produto.ProductCode = 'VI-PESSOAS'; // PLV-5331 INICIO / FIM
        produto.CodigoPrecificaProduto__c = produto.ProductCode; // PLV-5331 INICIO / FIM
        update produto;
          
         Cupom__c GeraCupom = new Cupom__c();
         GeraCupom.Codigo__c = 'FERIAS20';
         GeraCupom.Name = 'FERIAS20';
         GeraCupom.Limite_de_Utilizacao__c = 10.0;
         GeraCupom.Percentual__c = 15.0;
         GeraCupom.CurrencyIsoCode = 'BRL';
         GeraCupom.Meio_de_Comercializacao__c = 'SFC';
         GeraCupom.Vigencia_Final__c =    date.today().addDays(7); 
         GeraCupom.Vigencia_Inicial__c =  date.today().addDays(-1);
         insert GeraCupom; 

        // II-25-FIX01 INICIO
        // Contract ctract = [SELECT Id, Produto__c FROM Contract LIMIT 1]; // PLV-5331 INICIO / FIM
        // ctract.Produto__c = produto.Id; // PLV-5331 INICIO / FIM
       
        // update ctract; // PLV-5331 INICIO / FIM
        // II-25-FIX01 FIM
       	
        //PLV-2146 FIX - INICIO/FIM - Codigo removido por conta da historia PLV-2146
        GerarDadosIniciaisTO.OrcamentoTO orcamentoEnvio = new GerarDadosIniciaisTO.OrcamentoTO();
        orcamentoEnvio.meioComercializacao = GeraCupom.Meio_de_Comercializacao__c ; // PLV-5461 INICIO / FIM
        orcamentoEnvio.idProdutoSf = produto.Id; // PLV-5331 INICIO / FIM // II-25-FIX01 INICIO/FIM
        orcamentoEnvio.dataCalculo = produto.VigenciaInicial__c;
        orcamentoEnvio.ordemPortal = 2; //PLV-2146 FIX - INICIO/FIM - Adição do campo ordemPortal (valor devolvido sem alterações)
        System.debug('produto.dataCalculo: ' + produto.VigenciaInicial__c);
        
        orcamentoEnvio.codigoProdutoVida = produto.ProductCode;
        System.debug('produto.ProductCode: ' + produto.ProductCode);
        orcamentoEnvio.cupom = Geracupom.Codigo__c; // PLV-5461 INICIO / FIM
        System.debug('Geracupom.Codigo__c: ' + Geracupom.Codigo__c);
        
            
        List<GerarDadosIniciaisTO.OrcamentoTO> listOrcamentos = new List<GerarDadosIniciaisTO.OrcamentoTO>();
        listOrcamentos.add(orcamentoEnvio);
        GerarDadosIniciaisTO.PayloadTO payloadTO = new GerarDadosIniciaisTO.PayloadTO();
        payloadTO.orcamentos = listOrcamentos;
        String payload = JSON.serialize(payloadTO);
        System.debug('GerarDadosIniciaisTest - TestUnit - payload: ' + payload);
        return payload;
    }
    
    // PLV-5461 INICIO / FIM
        static String gerarJsonEnvioCupomInvalido(){ //PLV-2146 FIX - INICIO/FIM - Alteração de assinatura do método (Conta não será mais gerada nesta etapa)
        Product2 produto = [SELECT ProductCode, VigenciaInicial__c FROM Product2 WHERE ProductCode = '1' LIMIT 1]; //PLV-2146 FIX - INICIO/FIM - Pesquisa do produto pelo código para garantir assertividade da query
        produto.ProductCode = 'VI-PESSOAS'; // PLV-5331 INICIO / FIM
        produto.CodigoPrecificaProduto__c = produto.ProductCode; // PLV-5331 INICIO / FIM
        update produto;
          
         Cupom__c GeraCupom = new Cupom__c();
         GeraCupom.Codigo__c = 'FERIAS20';
         GeraCupom.Name = 'FERIAS20';
         GeraCupom.Limite_de_Utilizacao__c = 10.0;
         GeraCupom.Percentual__c = 15.0;
         GeraCupom.CurrencyIsoCode = 'BRL';
         GeraCupom.Meio_de_Comercializacao__c = 'SFC';
         GeraCupom.Vigencia_Final__c =    date.today().addDays(-1); 
         GeraCupom.Vigencia_Inicial__c =  date.today().addDays(-5);
         insert GeraCupom; 

        // II-25-FIX01 INICIO
        // Contract ctract = [SELECT Id, Produto__c FROM Contract LIMIT 1]; // PLV-5331 INICIO / FIM
        // ctract.Produto__c = produto.Id; // PLV-5331 INICIO / FIM
       
        // update ctract; // PLV-5331 INICIO / FIM
         // II-25-FIX01 FIM
       	
        //PLV-2146 FIX - INICIO/FIM - Codigo removido por conta da historia PLV-2146
        GerarDadosIniciaisTO.OrcamentoTO orcamentoEnvio = new GerarDadosIniciaisTO.OrcamentoTO();
        orcamentoEnvio.meioComercializacao = GeraCupom.Meio_de_Comercializacao__c ; // PLV-5461 INICIO / FIM
        orcamentoEnvio.idProdutoSf = produto.Id; // PLV-5331 INICIO / FIM // II-25-FIX01 INICIO/FIM
        orcamentoEnvio.dataCalculo = produto.VigenciaInicial__c;
        orcamentoEnvio.ordemPortal = 2; //PLV-2146 FIX - INICIO/FIM - Adição do campo ordemPortal (valor devolvido sem alterações)
        System.debug('produto.dataCalculo: ' + produto.VigenciaInicial__c);
        
        orcamentoEnvio.codigoProdutoVida = produto.ProductCode;
        System.debug('produto.ProductCode: ' + produto.ProductCode);
        orcamentoEnvio.cupom = 'Copa2022'; // PLV-5461 INICIO / FIM
        System.debug('Geracupom.Codigo__c: ' + 'Copa2022');
        
            
        List<GerarDadosIniciaisTO.OrcamentoTO> listOrcamentos = new List<GerarDadosIniciaisTO.OrcamentoTO>();
        listOrcamentos.add(orcamentoEnvio);
        GerarDadosIniciaisTO.PayloadTO payloadTO = new GerarDadosIniciaisTO.PayloadTO();
        payloadTO.orcamentos = listOrcamentos;
        String payload = JSON.serialize(payloadTO);
        System.debug('GerarDadosIniciaisTest - TestUnit - payload: ' + payload);
        return payload;
    }
    
     // PLV-5461 INICIO / FIM
        static String gerarJsonEnvioCupomExpirado(){ //PLV-2146 FIX - INICIO/FIM - Alteração de assinatura do método (Conta não será mais gerada nesta etapa)
        Product2 produto = [SELECT ProductCode, VigenciaInicial__c FROM Product2 WHERE ProductCode = '1' LIMIT 1]; //PLV-2146 FIX - INICIO/FIM - Pesquisa do produto pelo código para garantir assertividade da query
        produto.ProductCode = 'VI-PESSOAS'; // PLV-5331 INICIO / FIM
        produto.CodigoPrecificaProduto__c = produto.ProductCode; // PLV-5331 INICIO / FIM
        update produto;
          
         Cupom__c GeraCupom = new Cupom__c();
         GeraCupom.Codigo__c = 'FERIAS40';
         GeraCupom.Name = 'FERIAS40';
         GeraCupom.Limite_de_Utilizacao__c = 10.0;
         GeraCupom.Percentual__c = 40.0;
         GeraCupom.CurrencyIsoCode = 'BRL';
         GeraCupom.Meio_de_Comercializacao__c = 'SFC';
         GeraCupom.Vigencia_Final__c =    date.today().addDays(-1); 
         GeraCupom.Vigencia_Inicial__c =  date.today().addDays(-8);
         insert GeraCupom; 

        // II-25-FIX01 INICIO
        // Contract ctract = [SELECT Id, Produto__c FROM Contract LIMIT 1]; // PLV-5331 INICIO / FIM
        // ctract.Produto__c = produto.Id; // PLV-5331 INICIO / FIM
       
        // update ctract; // PLV-5331 INICIO / FIM
        // II-25-FIX01 FIM
       	
        //PLV-2146 FIX - INICIO/FIM - Codigo removido por conta da historia PLV-2146
        GerarDadosIniciaisTO.OrcamentoTO orcamentoEnvio = new GerarDadosIniciaisTO.OrcamentoTO();
        orcamentoEnvio.meioComercializacao = GeraCupom.Meio_de_Comercializacao__c ; // PLV-5461 INICIO / FIM
        orcamentoEnvio.idProdutoSf = produto.Id; // PLV-5331 INICIO / FIM // II-25-FIX01 INICIO/FIM
        orcamentoEnvio.dataCalculo = produto.VigenciaInicial__c;
        orcamentoEnvio.ordemPortal = 2; //PLV-2146 FIX - INICIO/FIM - Adição do campo ordemPortal (valor devolvido sem alterações)
        System.debug('produto.dataCalculo: ' + produto.VigenciaInicial__c);
        
        orcamentoEnvio.codigoProdutoVida = produto.ProductCode;
        System.debug('produto.ProductCode: ' + produto.ProductCode);
        orcamentoEnvio.cupom =  GeraCupom.Codigo__c; // PLV-5461 INICIO / FIM
        System.debug('Geracupom.Codigo__c: ' +  GeraCupom.Codigo__c);
        
            
        List<GerarDadosIniciaisTO.OrcamentoTO> listOrcamentos = new List<GerarDadosIniciaisTO.OrcamentoTO>();
        listOrcamentos.add(orcamentoEnvio);
        GerarDadosIniciaisTO.PayloadTO payloadTO = new GerarDadosIniciaisTO.PayloadTO();
        payloadTO.orcamentos = listOrcamentos;
        String payload = JSON.serialize(payloadTO);
        System.debug('GerarDadosIniciaisTest - TestUnit - payload: ' + payload);
        return payload;
    }
    
     // PLV-5461 INICIO
     /*
        static String gerarJsonEnvioCupomExcedido(){ //PLV-2146 FIX - INICIO/FIM - Alteração de assinatura do método (Conta não será mais gerada nesta etapa)
        Product2 produto = [SELECT ProductCode, VigenciaInicial__c FROM Product2 WHERE ProductCode = '1' LIMIT 1]; //PLV-2146 FIX - INICIO/FIM - Pesquisa do produto pelo código para garantir assertividade da query
        produto.ProductCode = 'VI-PESSOAS'; // PLV-5331 INICIO / FIM
        produto.CodigoPrecificaProduto__c = produto.ProductCode; // PLV-5331 INICIO / FIM
        update produto;
          
         Cupom__c GeraCupom = new Cupom__c();
         GeraCupom.Codigo__c = 'FERIAS20';
         GeraCupom.Name = 'FERIAS20';
         GeraCupom.Limite_de_Utilizacao__c = 1;
         GeraCupom.Percentual__c = 15.0;
         GeraCupom.CurrencyIsoCode = 'BRL';
         GeraCupom.Meio_de_Comercializacao__c = 'SFC';
         GeraCupom.Vigencia_Final__c =    date.today().addDays(7); 
         GeraCupom.Vigencia_Inicial__c =  date.today().addDays(-1);
         insert GeraCupom; 

        Contract ctract = [SELECT Id, Produto__c FROM Contract LIMIT 1]; // PLV-5331 INICIO / FIM
        ctract.Produto__c = produto.Id; // PLV-5331 INICIO / FIM
       
        update ctract; // PLV-5331 INICIO / FIM
       	
        //PLV-2146 FIX - INICIO/FIM - Codigo removido por conta da historia PLV-2146
        GerarDadosIniciaisTO.OrcamentoTO orcamentoEnvio = new GerarDadosIniciaisTO.OrcamentoTO();
        orcamentoEnvio.meioComercializacao = GeraCupom.Meio_de_Comercializacao__c ; // PLV-5461 INICIO / FIM
        orcamentoEnvio.idProdutoSf = ctract.Produto__c; // PLV-5331 INICIO / FIM
        orcamentoEnvio.dataCalculo = produto.VigenciaInicial__c;
        orcamentoEnvio.ordemPortal = 2; //PLV-2146 FIX - INICIO/FIM - Adição do campo ordemPortal (valor devolvido sem alterações)
        System.debug('produto.dataCalculo: ' + produto.VigenciaInicial__c);
        
        orcamentoEnvio.codigoProdutoVida = produto.ProductCode;
        System.debug('produto.ProductCode: ' + produto.ProductCode);
        orcamentoEnvio.cupom =  GeraCupom.Codigo__c; // PLV-5461 INICIO / FIM
        System.debug('Geracupom.Codigo__c: ' +  GeraCupom.Codigo__c);
        
            
        List<GerarDadosIniciaisTO.OrcamentoTO> listOrcamentos = new List<GerarDadosIniciaisTO.OrcamentoTO>();
        listOrcamentos.add(orcamentoEnvio);
        GerarDadosIniciaisTO.PayloadTO payloadTO = new GerarDadosIniciaisTO.PayloadTO();
        payloadTO.orcamentos = listOrcamentos;
        String payload = JSON.serialize(payloadTO);
        System.debug('GerarDadosIniciaisTest - TestUnit - payload: ' + payload);
        return payload;
    }
    */
    
    //PLV - 4487 - VI - INICIO - Gustavo Pereira SYS4B
    @IsTest
    static void testTO(){
        
        GerarDadosIniciaisTO.OrcamentoTO orc = new GerarDadosIniciaisTO.OrcamentoTO();
         //PLV-4715 INICIO
        orc.canalDistribuicao = 'a';
        orc.premioPago = 0;
        orc.numeroOferta = '0';
        //FNPVVEP-21 INICIO
        orc.vigenciaFinal = System.today();
        orc.vigenciaInicial = System.today();
        orc.dataEndosso = '';

        GerarDadosIniciaisTO.EndossoTO endossoTO = new GerarDadosIniciaisTO.EndossoTO();
        //FNPVVEP-21 FIM
        GerarDadosIniciaisTO gerarDadosIniciaisTO = new GerarDadosIniciaisTO();
        gerarDadosIniciaisTO.versoesCalculo = new List<GerarDadosIniciaisTO.VersaoCalculoTO>();
        gerarDadosIniciaisTO.versaoCalculo = new GerarDadosIniciaisTO.VersaoCalculoTO();
        //PLV-4715 FIM        

        GerarDadosIniciaisTO.OrcamentoRetornoTO orcTO = new GerarDadosIniciaisTO.OrcamentoRetornoTO();
        //orcTO.ramoSeguro = 'a';
        orcTO.canalDistribuicao = 'a';
        //PLV-4715 INICIO
        orcTO.ramoSeguro = '';
        orcTO.contratoOriginal = new GerarDadosIniciaisTO.ContratoOriginalRetornoTO();
        orcTO.dataEndosso = '';
        //PLV-4715 FIM 
        //FNPVVEP-21 INICIO
        orcTO.vigenciaFinal = System.today();
        orcTO.vigenciaInicial = System.today();
        orcTO.dataEndosso = '';   
        orcTO.tiposEndosso = endossoTO;  
        orcTO.qtdDiasVigencia = 1; 

        GerarDadosIniciaisTO.ContratoOriginalRetornoTO contratoOriginalRetornoTO = new GerarDadosIniciaisTO.ContratoOriginalRetornoTO();
        contratoOriginalRetornoTO.beneficiarios = new List<GerarDadosIniciaisTO.BeneficiarioTO>();
        contratoOriginalRetornoTO.versoesCalculos = new List<GerarDadosIniciaisTO.VersaoCalculoTO>();

        GerarDadosIniciaisTO.RetornosCalculoOriginalTO retornosCalculoOriginalTO = new GerarDadosIniciaisTO.RetornosCalculoOriginalTO();
        retornosCalculoOriginalTO.opcao = 1;
        //FNPVVEP-21 FIM  

        GerarDadosIniciaisTO.ContratoOriginalEntradaTO orcEntradaTO = new GerarDadosIniciaisTO.ContratoOriginalEntradaTO();
        orcEntradaTO.sucursal = 'a';
        orcEntradaTO.ramo = 'a';
        orcEntradaTO.endosso = 'a';
        orcEntradaTO.empresa = 'a';
        orcEntradaTO.apolice = 'a';

    	GerarDadosIniciaisTO.CoberturaTO cobertura = new GerarDadosIniciaisTO.CoberturaTO();
        cobertura.sigla = 'a';
        //cobertura.moeda = 'a';
        //cobertura.cotacaoMoeda = 1.1;
        cobertura.valor = 1.1;
        cobertura.quantidade = 1;
        //cobertura.cobrado = 'a';
        
        GerarDadosIniciaisTO.PremioTO premio = new GerarDadosIniciaisTO.PremioTO();

        premio.minimo = 10.0;
        premio.comercial = 10.0;
        premio.total = 10.0;
        premio.puro = 10.0;

        //FNPVVEP-21 INICIO  
        List<GerarDadosIniciaisTO.ContratanteTO> contratantes = 
        new List<GerarDadosIniciaisTO.ContratanteTO>();
        //FNPVVEP-21 FIM  

        GerarDadosIniciaisTO.PrecificacaoTO p = new GerarDadosIniciaisTO.PrecificacaoTO();
        
        //p.encargos = 1.0;
		//p.iof = 1.0;
        //p.custoApolice = 1.0;
		//p.juros = 1.0;
        p.premio = premio;
        //FNPVVEP-21 INICIO
        p.iof = 0;
        p.juros = 0;
        p.encargos = 0;
        p.custoDeApolice = 0;
        p.contratantes = contratantes;
        //FNPVVEP-21 FIM  
        
        //PLV-4715 INICIO
    
        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(CpfCnpj__c = '000.000.000-00');
        
        GerarDadosIniciaisTO.PessoaTO pessoa = new GerarDadosIniciaisTO.PessoaTO(contratanteContrato);
        
        GerarDadosIniciaisTO.RemuneracaoContratoTO remuneracaoContratoTO = new GerarDadosIniciaisTO.RemuneracaoContratoTO();
        remuneracaoContratoTO.percentual = 0;
        remuneracaoContratoTO.tipoRemuneracao = '';
        remuneracaoContratoTO.favorecidos = new List<GerarDadosIniciaisTO.FavorecidosTO>();
        
        GerarDadosIniciaisTO.FavorecidosTO favorecidosTO = new GerarDadosIniciaisTO.FavorecidosTO();
        favorecidosTO.papel = '';
        favorecidosTO.participacao = 0;
        favorecidosTO.corretorLider = true;
        favorecidosTO.susep = '';
        favorecidosTO.antecipacaoComissao = true;
        favorecidosTO.pessoa = new GerarDadosIniciaisTO.PessoaTO();
        
        //FNPVVEP-21 INICIO  
        GerarDadosIniciaisTO.DadosPagamentoTO dadosPagamentoTO = new GerarDadosIniciaisTO.DadosPagamentoTO();
        dadosPagamentoTO.responsavelFinanceiroSeguro = new EmissaoTO.PessoaTO(); 
        dadosPagamentoTO.dadosBancarios = new EmissaoTO.DadosBancarioTO(); 
        dadosPagamentoTO.dadosCartaoCredito = new EmissaoTO.dadosCartaoCreditoTO(); 
        //FNPVVEP-21 FIM  
        
        GerarDadosIniciaisTO.BeneficiarioTO beneficiarioTO = new GerarDadosIniciaisTO.BeneficiarioTO();
        beneficiarioTO.pessoa = new GerarDadosIniciaisTO.PessoaTO(); 
        
        BeneficiarioSeguradoContrato__c beneficiarioSeguradoContrato = new BeneficiarioSeguradoContrato__c();
        GerarDadosIniciaisTO.BeneficiarioTO beneficiarioTOBeneficiarioSeguradoContrato = new GerarDadosIniciaisTO.BeneficiarioTO(beneficiarioSeguradoContrato);
    
        GerarDadosIniciaisTO.DadosPessoaJuridicaTO dadosPessoaJuridica= new GerarDadosIniciaisTO.DadosPessoaJuridicaTO();
        dadosPessoaJuridica.numeroCnpj = '';
        dadosPessoaJuridica.ordemCnpj = '';
        dadosPessoaJuridica.digitoCnpj = '';
        
        GerarDadosIniciaisTO.CoberturaTO coberturaTO = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaTO.franquia = '';
        
        GerarDadosIniciaisTO.CoberturaTO coberturaPrecificacaoTO = new GerarDadosIniciaisTO.CoberturaTO();//PLV-4666 - INICIO/FIM
        coberturaPrecificacaoTO.sigla = '';
        coberturaPrecificacaoTO.capitalContratacao = 0;
        coberturaPrecificacaoTO.iof = 0;
        coberturaPrecificacaoTO.premio = new GerarDadosIniciaisTO.PremioTO();//PLV-4666 - INICIO/FIM
        coberturaPrecificacaoTO.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
            
        GerarDadosIniciaisTO.PremioTO premioTO = new GerarDadosIniciaisTO.PremioTO();
        premioTO.premioPago = 0;
        
        GerarDadosIniciaisTO.PrecificacaoTO precificacaoTO = new GerarDadosIniciaisTO.PrecificacaoTO();
        precificacaoTO.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        precificacaoTO.coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();//PLV-4666 - INICIO/FIM
    	//PLV-4715 FIM
	}
    //PLV - 4487 - VI - FIM - Gustavo Pereira SYS4B
    //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B 
    public static GerarDadosIniciaisTO.PayloadTO PayloadTO(String empresa, String sucursal, String ramo, String apolice, String endosso, String codProdutoVida){    // II-25 INICIO/FIM
        
        GerarDadosIniciaisTO.PayloadTO retorno = 
        new GerarDadosIniciaisTO.PayloadTO();

        // GerarDadosIniciaisTO.ContratoOriginalTO  contratoOriginal = 
        // new GerarDadosIniciaisTO.ContratoOriginalTO();

        // GerarDadosIniciaisTO.PrecificacaoContratoTO precificacao = 
        // new GerarDadosIniciaisTO.PrecificacaoContratoTO();

        List<GerarDadosIniciaisTO.ContratanteTO> contratantes = 
        new List<GerarDadosIniciaisTO.ContratanteTO>();

        GerarDadosIniciaisTO.ContratanteTO contratante = 
        new GerarDadosIniciaisTO.ContratanteTO();

        GerarDadosIniciaisTO.TaxaTO taxa = 
        new GerarDadosIniciaisTO.TaxaTO(); 

        GerarDadosIniciaisTO.PremioTO premio = 
        new GerarDadosIniciaisTO.PremioTO(); 

        List<GerarDadosIniciaisTO.CoberturaTO> coberturas = 
        new List<GerarDadosIniciaisTO.CoberturaTO>();

        GerarDadosIniciaisTO.CoberturaTO cobertura = 
        new GerarDadosIniciaisTO.CoberturaTO();   
        
        List<GerarDadosIniciaisTO.GrupoTO> grupos = 
        new List<GerarDadosIniciaisTO.GrupoTO>();

        GerarDadosIniciaisTO.GrupoTO grupo = 
        new GerarDadosIniciaisTO.GrupoTO();  

        List<GerarDadosIniciaisTO.SeguradoTO> segurados = 
        new List<GerarDadosIniciaisTO.SeguradoTO>();

        GerarDadosIniciaisTO.SeguradoTO segurado = 
        new GerarDadosIniciaisTO.SeguradoTO();  

        GerarDadosIniciaisTO.PessoaTO pessoa = 
        new GerarDadosIniciaisTO.PessoaTO();

        GerarDadosIniciaisTO.DadosPessoaFisicaTO pessoaFisica = 
        new GerarDadosIniciaisTO.DadosPessoaFisicaTO();


        pessoaFisica.profissao = '2111-05';
        pessoaFisica.sexo = 'FEM';
        pessoaFisica.fumante = false;
        pessoaFisica.dataNascimento = '1959-03-12T00:00:00.000Z';
        pessoaFisica.regimeTrabalho = 'CLT';

        // pessoa.rendaMensal = '5000';
        pessoa.nome = 'XPTO';
        pessoa.dadosPessoaFisica = pessoaFisica;

        taxa.pura = 10;
        taxa.comercial = 20;
        taxa.total = 30;

        premio.minimo = 1.0;
        premio.comercial = 10;
        premio.total = 20;
        premio.puro = 30;

        //cobertura.taxa = taxa;
        //cobertura.premio = premio;
        cobertura.sigla = 'MAP';
        //cobertura.moeda = 'BRL';
        //cobertura.cotacaoMoeda = 1.0;
        cobertura.valor = 10.0;
        cobertura.quantidade = 1;
        //cobertura.cobrado = '30';

        coberturas.add(cobertura);

        segurado.pessoa = pessoa;
        segurado.numero = 1;
        segurado.coberturas = coberturas;

        segurados.add(segurado);

        grupo.segurados = segurados;
        //grupo.coberturas = coberturas;
        //grupo.tipoCalculo = ' ';
        grupo.numero = 1;
        grupo.nome = 'XPTO';
        grupo.qtdeVidas = 1.0;

        grupos.add(grupo);

        contratante.grupos = grupos;
        //contratante.coberturas = coberturas;
        contratante.tipo = 'PRI';
        contratante.numero = 1;
        // contratante.taxa = taxa;
        // contratante.premio = premio;
        //contratante.conta = 'XPTO';

        contratantes.add(contratante);

        
        // precificacao.premio = premio;
        // precificacao.coberturas = coberturas;

        // precificacao.encargos = 1.0;
        // precificacao.iof = 1.0;
        // precificacao.juros = 1.0;
        // precificacao.custoApolice = 1.0;

        // precificacao.taxa = taxa;
        // precificacao.contratantes = contratantes;

        // contratoOriginal.sucursal = sucursal;
        // contratoOriginal.ramo = ramo;
        // contratoOriginal.endosso = endosso;
        // contratoOriginal.empresa = empresa;
        // contratoOriginal.apolice = apolice;
        // contratoOriginal.premioPago = 1.1;
        // contratoOriginal.vigenciaFinal = '28/05/2020';
        // contratoOriginal.codigoProdutoVida = 'VI-PESSOA';
        // contratoOriginal.premioTotal = 1.1;
        // contratoOriginal.vigenciaInicial = '28/05/2020';
        // contratoOriginal.precificacao = precificacao;
        // contratoOriginal.contratantes = contratantes;

        List<GerarDadosIniciaisTO.OrcamentoTO> orcamentos = 
        new List<GerarDadosIniciaisTO.OrcamentoTO>();

        GerarDadosIniciaisTO.OrcamentoTO orcamento = 
        new GerarDadosIniciaisTO.OrcamentoTO();

        GerarDadosIniciaisTO.ContratoOriginalEntradaTO contratoOriginalEntrada = 
        new GerarDadosIniciaisTO.ContratoOriginalEntradaTO();

        contratoOriginalEntrada.sucursal = sucursal;
        contratoOriginalEntrada.ramo = ramo;
        contratoOriginalEntrada.endosso = endosso;
        contratoOriginalEntrada.empresa = empresa;
        contratoOriginalEntrada.apolice = apolice;
    

        orcamento.meioComercializacao = 'CO2';
        orcamento.codigoProdutoVida = codProdutoVida;  // II-25 INICIO/FIM
        orcamento.ordemPortal = 1;
        orcamento.canalDistribuicao = 'CO2';
        orcamento.dataCalculo = System.Today();
        orcamento.contratoOriginal = contratoOriginalEntrada; 
        orcamento.tipoSeguro = 'eds';
        orcamento.contratantes = contratantes;

        orcamentos.add(orcamento); 

        retorno.orcamentos = orcamentos; 
        
        System.debug('retorno:');
        System.debug(retorno);
        return retorno;
    }
    //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B
    //PLV-5066 INICIO
    @isTest
    static void testCheckTipoEndosso() {
        String request = '{"orcamentos": [{"tipoVigencia":"Periódico","vigenciaFinal":"2022-08-19","tipoSeguro":"EDS","numeroOrcamento":"00055978","numeroPortal":"0","dataEndosso":"2021-08-31","codigoProdutoVida":"VI-PESSOAS","contratantes":[{"tipo":"PRI","manterPlanoParcelamento":false,"numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","rendaMensal":"2500","nome":"Magda Rita da Paixão","dadosPessoaFisica":{"grupoProfissao":"DIT-B","profissao":"2410-05","sexo":"FEM","fumante":false,"dataNascimento":"1969-04-22T00:00:00.000Z","regimeTrabalho":"CLT","renda":"2500","CicloVacinal":"0"}},"numero":1,"coberturas":[{"franquia":"","sigla":"BAS","valor":100000.0,"quantidade":6},{"franquia":"","sigla":"AFF","valor":10000.0,"quantidade":30},{"franquia":"FR_REDUZIDA","sigla":"DIT","valor":25.0,"quantidade":1},{"franquia":"","sigla":"CAN","valor":100000.0,"quantidade":100000},{"franquia":"","sigla":"TELEMED","valor":0.0,"quantidade":0}]}],"nome":"Magda Rita da Paixão","qtdeVidas":1}]}],"canalDistribuicao":"COR","meioComercializacao":"SFC","segmento":"Individual","contratoOriginal":{"vigenciaFinal":"2022-08-19","ramo":"1391","endosso":"0","apolice":"000013420","sucursal":"1","empresa":"1","vigenciaInicial":"2021-08-20","premioPago":0.0,"contratantes":[{"grupos":[{"segurados":[{"coberturas":[{"franquia":"","sigla":"BAS","valor":100000.0,"quantidade":6},{"franquia":"FR_NORMAL","sigla":"AFF","valor":10000.0,"quantidade":30},{"franquia":"FR_REDUZIDA","sigla":"DIT","valor":25.0,"quantidade":1},{"franquia":"","sigla":"CAN","valor":100000.0,"quantidade":100000},{"franquia":"","sigla":"TELEMED","valor":0.0,"quantidade":0}]}]}]}]},"entradaNegocio":0,"numeroOferta":"0000023174","ordemPortal":1,"orcnum":"","remuneracoes":[{"percentual":10.0,"tipoRemuneracao":"CORRETAGEM"}],"vigenciaInicial":"2021-08-31","dataCalculo":"2021-08-31"}]}';

        // String seguradoOriginalString = JSON.serialize(proposta.orcamento.contratoOriginal.contratantes[0].grupos[0].segurados[0]);

        
        GerarDadosIniciaisTO.ContratanteTO contratante = new GerarDadosIniciaisTO.ContratanteTO();
        contratante.grupos = new List<GerarDadosIniciaisTO.GrupoTO>();
        
        GerarDadosIniciaisTO.GrupoTO grupo = new GerarDadosIniciaisTO.GrupoTO();
        grupo.segurados = new List<GerarDadosIniciaisTO.SeguradoTO>();
        
        GerarDadosIniciaisTO.SeguradoTO segurado = new GerarDadosIniciaisTO.SeguradoTO();
        segurado.numero = 1;
        segurado.pessoa = new GerarDadosIniciaisTO.PessoaTO();
        segurado.pessoa.tipo = 'FIS';
        segurado.pessoa.rendaMensal = 2500;
        segurado.pessoa.nome = 'Magda Rita da Paixão';
        segurado.pessoa.dadosPessoaFisica = new GerarDadosIniciaisTO.DadosPessoaFisicaTO();
        segurado.pessoa.dadosPessoaFisica.grupoProfissao = 'DIT-B';
        segurado.pessoa.dadosPessoaFisica.profissao = '2410-05';
        segurado.pessoa.dadosPessoaFisica.sexo = 'FEM';
        segurado.pessoa.dadosPessoaFisica.fumante = false;
        segurado.pessoa.dadosPessoaFisica.dataNascimento = '1969-04-22T00:00:00.000Z';
        segurado.pessoa.dadosPessoaFisica.regimeTrabalho = 'CLT';
        //segurado.pessoa.dadosPessoaFisica.CicloVacinal = '0'; //PLV-5150 - FIX01 - INICIO/FIM
        segurado.coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();
        
        GerarDadosIniciaisTO.CoberturaTO coberturaBas = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaBas.franquia = '';
        coberturaBas.sigla = 'BAS';
        coberturaBas.valor = 100000;
        coberturaBas.quantidade = 6;
        segurado.coberturas.add(coberturaBas);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaAff = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaAff.franquia = '';
        coberturaAff.sigla = 'AFF';
        coberturaAff.valor = 10000;
        coberturaAff.quantidade = 6;
        segurado.coberturas.add(coberturaAff);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaDit = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaDit.franquia = 'FR_REDUZIDA';
        coberturaDit.sigla = 'DIT';
        coberturaDit.valor = 25;
        coberturaDit.quantidade = 1;
        segurado.coberturas.add(coberturaDit);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaCan = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaCan.franquia = '';
        coberturaCan.sigla = 'CAN';
        coberturaCan.valor = 100000;
        coberturaCan.quantidade = 100000;
        segurado.coberturas.add(coberturaCan);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaTelemed = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaTelemed.franquia = '';
        coberturaTelemed.sigla = 'TELEMED';
        coberturaTelemed.valor = 0;
        coberturaTelemed.quantidade = 0;
        segurado.coberturas.add(coberturaTelemed);
        
        grupo.segurados.add(segurado);
        contratante.grupos.add(grupo);

        GerarDadosIniciaisTO.OfertaTO proposta = new GerarDadosIniciaisTO.OfertaTO();
        proposta.orcamento = new GerarDadosIniciaisTO.OrcamentoRetornoTO();
        proposta.orcamento.contratantes = new List<GerarDadosIniciaisTO.ContratanteTO>();
        proposta.orcamento.contratantes.add(contratante);
        
        //Contrato Original
        proposta.orcamento.contratoOriginal = new GerarDadosIniciaisTO.ContratoOriginalRetornoTO();
        proposta.orcamento.contratoOriginal.remuneracoes = new List<GerarDadosIniciaisTO.RemuneracaoContratoTO>();
        
        GerarDadosIniciaisTO.RemuneracaoContratoTO corretagem = new GerarDadosIniciaisTO.RemuneracaoContratoTO();
        corretagem.percentual = 10;
        corretagem.tipoRemuneracao = 'COR';     
        proposta.orcamento.contratoOriginal.remuneracoes.add(corretagem);

        proposta.orcamento.contratoOriginal.contratantes = new List<GerarDadosIniciaisTO.ContratanteTO>();
        proposta.orcamento.contratoOriginal.contratantes.add(new GerarDadosIniciaisTO.ContratanteTO());
        proposta.orcamento.contratoOriginal.contratantes[0].grupos = new List<GerarDadosIniciaisTO.GrupoTO>();
        proposta.orcamento.contratoOriginal.contratantes[0].grupos.add(new GerarDadosIniciaisTO.GrupoTO());
        proposta.orcamento.contratoOriginal.contratantes[0].grupos[0].segurados = new List<GerarDadosIniciaisTO.SeguradoTO>();
        
        GerarDadosIniciaisTO.SeguradoTO seguradoOriginal = new GerarDadosIniciaisTO.SeguradoTO();
        seguradoOriginal.numero = 1;
        seguradoOriginal.pessoa = new GerarDadosIniciaisTO.PessoaTO();
        seguradoOriginal.pessoa.tipo = 'FIS';
        seguradoOriginal.pessoa.rendaMensal = 2500;
        seguradoOriginal.pessoa.nome = 'Magda Rita da Paixão';
        seguradoOriginal.pessoa.dadosPessoaFisica = new GerarDadosIniciaisTO.DadosPessoaFisicaTO();
        seguradoOriginal.pessoa.dadosPessoaFisica.grupoProfissao = 'DIT-B';
        seguradoOriginal.pessoa.dadosPessoaFisica.profissao = '2410-05';
        seguradoOriginal.pessoa.dadosPessoaFisica.sexo = 'FEM';
        seguradoOriginal.pessoa.dadosPessoaFisica.fumante = false;
        seguradoOriginal.pessoa.dadosPessoaFisica.dataNascimento = '1969-04-22';
        seguradoOriginal.pessoa.dadosPessoaFisica.regimeTrabalho = 'CLT';
        //seguradoOriginal.pessoa.dadosPessoaFisica.CicloVacinal = '0'; //PLV-5150 - FIX01 - INICIO/FIM
        seguradoOriginal.coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();
        
        GerarDadosIniciaisTO.CoberturaTO coberturaBasOriginal = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaBasOriginal.franquia = '';
        coberturaBasOriginal.sigla = 'BAS';
        coberturaBasOriginal.valor = 100000;
        coberturaBasOriginal.quantidade = 6;
        seguradoOriginal.coberturas.add(coberturaBasOriginal);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaAffOriginal = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaAffOriginal.franquia = '';
        coberturaAffOriginal.sigla = 'AFF';
        coberturaAffOriginal.valor = 10000;
        coberturaAffOriginal.quantidade = 6;
        seguradoOriginal.coberturas.add(coberturaAffOriginal);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaDitOriginal = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaDitOriginal.franquia = 'FR_REDUZIDA';
        coberturaDitOriginal.sigla = 'DIT';
        coberturaDitOriginal.valor = 25;
        coberturaDitOriginal.quantidade = 1;
        seguradoOriginal.coberturas.add(coberturaDitOriginal);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaCanOriginal = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaCanOriginal.franquia = '';
        coberturaCanOriginal.sigla = 'CAN';
        coberturaCanOriginal.valor = 100000;
        coberturaCanOriginal.quantidade = 100000;
        seguradoOriginal.coberturas.add(coberturaCanOriginal);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaTelemedOriginal = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaTelemedOriginal.franquia = '';
        coberturaTelemedOriginal.sigla = 'TELEMED';
        coberturaTelemedOriginal.valor = 0;
        coberturaTelemedOriginal.quantidade = 0;
        seguradoOriginal.coberturas.add(coberturaTelemedOriginal);
        
        proposta.orcamento.contratoOriginal.contratantes[0].grupos[0].segurados.add(seguradoOriginal);
        
        test.startTest();
        GerarDadosIniciais.getInstance().checkTipoEndossoIsOnlyCad(request, proposta);
        test.stopTest();

   }  
    //PLV-5066 FIM
    //RVI-312 - INICIO
    @isTest
    static void verificarAltPgtoTest(){

        Test.startTest();

        Contract ctr = [SELECT Id, AlteraFormaPagto__c FROM Contract LIMIT 1];
        String ctrId = ctr.Id;

        Product2 produto = [SELECT Id, ProductCode, VigenciaInicial__c FROM Product2 WHERE ProductCode = '1' LIMIT 1];
        produto.ProductCode = 'VI-PESSOAS';
        String dataCalculo = String.valueOf(produto.VigenciaInicial__c);
        produto.CodigoPrecificaProduto__c = produto.ProductCode; 
        update produto;
        // RVI-312-FIX01 - INICIO
        CondicaoCobranca__c condicaoCobranca = [SELECT Id, TipoPagamento__c, QuantidadeParcelas__c,PercentualDescontoAgravo__c,Produto__c FROM CondicaoCobranca__c WHERE Produto__c=:produto.Id ];
        condicaoCobranca.TipoPagamento__c = 'Boleto';
        condicaoCobranca.QuantidadeParcelas__c = '2';
        condicaoCobranca.PercentualDescontoAgravo__c = -5;
        update condicaoCobranca;
        // RVI-312-FIX01 - FIM

        String payload = '{"orcamentos":[{"idContratoRenovado":\"'+ ctrId +'\","tipoVigencia":"Periódico","precificacao":{"descontoAgravo":[],"coberturas":[]},"vigenciaFinal":"2023-10-31","tipoSeguro":"Renovacao","qtdDiasVigencia":364,"customizavel":false,"canalDistribuicao":"COR","viagem":null,"varConsultivo":false,"idProdutoSf":\"'+ produto.Id +'\","ramoSeguro":0,"versoesCalculos":[{"opcao":0,"tipo":"FPG","descontoAgravo":-15}],"ordemPortal":1,"rotulo":"Renovacao","susepOrcamento":"67185J","resultadoIntegracoes":{"IndiceMonetario":{"ItensCotacao":[{"moedaDestino":"BRL","dataCotacao":1112023,"moedaOrigem":"BRL","cotacao":"1.0"}]}},"indiceIPCA":0,"remuneracoes":[{"percentual":0,"tipoRemuneracao":"AGENCIAMENTO"},{"percentual":10,"tipoRemuneracao":"CORRETAGEM"}],"dataCalculo":\"'+dataCalculo+'\","Cupom":"FERIAS20","tarifa":"2023-11-01","numeroOrcamento":"00122711","numeroPortal":1,"codigoProdutoVida":"VI-PESSOAS","contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"uf":"SP","cidade":"TaboãodaSerra","complemento":"","logradouro":"AvelinaNogueiradoPrado","bairro":"JardimMonteAlegre","complementoCep":"325","paisResidencia":"","tipoEndereco":"RESIDENCIAL","numeroLogradouro":null,"cep":"06755"}],"nome":"FRANCISLIU","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"1","profissao":"2111-05","temDependentes":true,"tipoContrato":"VOCE","tempoGarantiaRenda":"48","dataNascimento":"1964-05-22","sexo":"MASC","fumante":true,"regimeTrabalho":"CLT","renda":"10000"},"email":"teste@teste.com"},"numero":1,"coberturas":[{"franquia":"","caracteristica":"Principal","limitemaximo":"10000000","moeda":"BRL","sigla":"MAP","valor":120000,"caracteristicaespecialvalor":"0","limiteminimo":"30000","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Serviçocomplementar","limitemaximo":"","moeda":"BRL","sigla":"TELEMED","valor":0,"caracteristicaespecialvalor":"0","limiteminimo":"","caracteristicaespecialtipo":""},{"franquia":"","caracteristica":"Principal","limitemaximo":"10000000","moeda":"BRL","sigla":"BAS","valor":120000,"caracteristicaespecialvalor":"0","limiteminimo":"30000","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Principal","limitemaximo":"10000000","moeda":"BRL","sigla":"IPA","valor":120000,"caracteristicaespecialvalor":"0","limiteminimo":"30000","caracteristicaespecialtipo":"Monetário"},{"franquia":"FR_NORMAL","caracteristica":"Adicional","limitemaximo":"1300","moeda":"BRL","sigla":"DIT","valor":25,"caracteristicaespecialvalor":"0","limiteminimo":"25","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Adicional","limitemaximo":"500000","moeda":"BRL","sigla":"DG17","valor":120000,"caracteristicaespecialvalor":"0","limiteminimo":"30000","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Adicional","limitemaximo":"1000","moeda":"BRL","sigla":"DIH","valor":83.33,"caracteristicaespecialvalor":"1","limiteminimo":"50","caracteristicaespecialtipo":"Dia(s)"},{"franquia":"","caracteristica":"Adicional","limitemaximo":"20000","moeda":"BRL","sigla":"AFF","valor":10000,"caracteristicaespecialvalor":"0","limiteminimo":"5000","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Adicional","limitemaximo":"10000","moeda":"BRL","sigla":"DMHO","valor":4500,"caracteristicaespecialvalor":"0","limiteminimo":"100","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Principal","limitemaximo":"2000000","moeda":"BRL","sigla":"IFPD","valor":120000,"caracteristicaespecialvalor":"0","limiteminimo":"10000","caracteristicaespecialtipo":"Monetário"}]}],"nome":"FRANCISLIU","qtdeVidas":1,"coberturas":[{"franquia":"","caracteristica":"Principal","limitemaximo":"10000000","moeda":"BRL","sigla":"MAP","valor":120000,"caracteristicaespecialvalor":"0","limiteminimo":"30000","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Serviçocomplementar","limitemaximo":"","moeda":"BRL","sigla":"TELEMED","valor":0,"caracteristicaespecialvalor":"0","limiteminimo":"","caracteristicaespecialtipo":""},{"franquia":"","caracteristica":"Principal","limitemaximo":"10000000","moeda":"BRL","sigla":"BAS","valor":120000,"caracteristicaespecialvalor":"0","limiteminimo":"30000","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Principal","limitemaximo":"10000000","moeda":"BRL","sigla":"IPA","valor":120000,"caracteristicaespecialvalor":"0","limiteminimo":"30000","caracteristicaespecialtipo":"Monetário"},{"franquia":"FR_NORMAL","caracteristica":"Adicional","limitemaximo":"1300","moeda":"BRL","sigla":"DIT","valor":25,"caracteristicaespecialvalor":"0","limiteminimo":"25","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Adicional","limitemaximo":"500000","moeda":"BRL","sigla":"DG17","valor":120000,"caracteristicaespecialvalor":"0","limiteminimo":"30000","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Adicional","limitemaximo":"1000","moeda":"BRL","sigla":"DIH","valor":83.33,"caracteristicaespecialvalor":"1","limiteminimo":"50","caracteristicaespecialtipo":"Dia(s)"},{"franquia":"","caracteristica":"Adicional","limitemaximo":"20000","moeda":"BRL","sigla":"AFF","valor":10000,"caracteristicaespecialvalor":"0","limiteminimo":"5000","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Adicional","limitemaximo":"10000","moeda":"BRL","sigla":"DMHO","valor":4500,"caracteristicaespecialvalor":"0","limiteminimo":"100","caracteristicaespecialtipo":"Monetário"},{"franquia":"","caracteristica":"Principal","limitemaximo":"2000000","moeda":"BRL","sigla":"IFPD","valor":120000,"caracteristicaespecialvalor":"0","limiteminimo":"10000","caracteristicaespecialtipo":"Monetário"}]}]}],"meioComercializacao":"SFC","segmento":"Individual","numeroOferta":52595,"orcnum":"00122711","vigenciaInicial":\"2023-11-06"}]}';

        ctr.AlteraFormaPagto__c = true;
        update ctr;

        GerarDadosIniciais.getInstance().gerarDadosIniciais(payload);

        ContratanteContrato__c cteCtr = [
            SELECT Id, DescontoAgravoPercentualFormaPagto__c FROM ContratanteContrato__c WHERE Contrato__c = :ctr.Id
        ];

        Test.stopTest();

        System.assertEquals(-5, cteCtr.DescontoAgravoPercentualFormaPagto__c, '5% de desconto');        
    }
    //RVI-312 - FIM
    //FNPVVEP-71 INICIO 
    @isTest
    static void getDiscCtrOrgTest(){
        Test.startTest();
        Contract contrato = [SELECT Id FROM Contract LIMIT 1]; 
        GerarDadosIniciais.getInstance().getDiscCtrOrg(contrato.Id);
        Test.stopTest();
    }

    @isTest
    static void testUnity2() { 
        Test.startTest();
        String payload = gerarJsonEnvio(); 
        list<Contract> contrato = [SELECT Id, NumeroApolice__c, DescontoAgravoMonetarioTecnico__c FROM Contract]; 
        contrato[0].DescontoAgravoMonetarioTecnico__c = 1000;
        contrato[0].DescontoAgravoMonetarioFormaPagto__c = 5;
        update contrato;
        list<GrupoContrato__c> grupoctr = [SELECT Id, DescontoAgravoPercentualFormaPagto__c, DescontoAgravoMonetarioFormaPagto__c, DescontoAgravoPercentualInformado__c, DescontoAgravoMonetarioInformado__c, DescontoAgravoPercentualTecnico__c, DescontoAgravoMonetarioTecnico__c FROM GrupoContrato__c]; 
        grupoctr[0].DescontoAgravoPercentualFormaPagto__c = 10;
        grupoctr[0].DescontoAgravoMonetarioFormaPagto__c = 10;
        grupoctr[0].DescontoAgravoPercentualInformado__c = 10;
        grupoctr[0].DescontoAgravoMonetarioInformado__c = 10;
        grupoctr[0].DescontoAgravoPercentualTecnico__c = 10;
        grupoctr[0].DescontoAgravoMonetarioTecnico__c = 10;
        update grupoctr;
        list<SeguradoContrato__c> seguradoCtr = [SELECT Id, DescontoAgravoPercentualFormaPagto__c, DescontoAgravoMonetarioFormaPagto__c, DescontoAgravoPercentualInformado__c, DescontoAgravoMonetarioInformado__c, DescontoAgravoPercentualTecnico__c, DescontoAgravoMonetarioTecnico__c FROM SeguradoContrato__c];
        seguradoCtr[0].DescontoAgravoPercentualFormaPagto__c = 10;
        seguradoCtr[0].DescontoAgravoMonetarioFormaPagto__c = 10;
        seguradoCtr[0].DescontoAgravoPercentualInformado__c = 10;
        seguradoCtr[0].DescontoAgravoMonetarioInformado__c = 10;
        seguradoCtr[0].DescontoAgravoPercentualTecnico__c = 10;
        seguradoCtr[0].DescontoAgravoMonetarioTecnico__c = 10;
        update seguradoCtr;
        list<ContratanteContrato__c> contratanteCtr = [SELECT Id, DescontoAgravoPercentualFormaPagto__c, DescontoAgravoMonetarioFormaPagto__c, DescontoAgravoPercentualInformado__c, DescontoAgravoMonetarioInformado__c, DescontoAgravoPercentualTecnico__c, DescontoAgravoMonetarioTecnico__c FROM ContratanteContrato__c];
        contratanteCtr[0].DescontoAgravoPercentualFormaPagto__c = 10;
        contratanteCtr[0].DescontoAgravoMonetarioFormaPagto__c = 10;
        contratanteCtr[0].DescontoAgravoPercentualInformado__c = 10;
        contratanteCtr[0].DescontoAgravoMonetarioInformado__c = 10;
        contratanteCtr[0].DescontoAgravoPercentualTecnico__c = 10;
        contratanteCtr[0].DescontoAgravoMonetarioTecnico__c = 10;
        update contratanteCtr;
        GerarDadosIniciaisTO.ContratoOriginalEntradaTO contratoOriginalEntrada = new GerarDadosIniciaisTO.ContratoOriginalEntradaTO();
        contratoOriginalEntrada.apolice = '000000014889';
        contratoOriginalEntrada.sucursal = '999';
        contratoOriginalEntrada.ramo = '2';
        contratoOriginalEntrada.endosso = '0';
        contratoOriginalEntrada.empresa = '22';
        contratoOriginalEntrada.premioPago = 2;

        GerarDadosIniciaisTO.ContratanteTO contratante = new GerarDadosIniciaisTO.ContratanteTO();
        contratante.grupos = new List<GerarDadosIniciaisTO.GrupoTO>();
        
        GerarDadosIniciaisTO.GrupoTO grupo = new GerarDadosIniciaisTO.GrupoTO();
        grupo.segurados = new List<GerarDadosIniciaisTO.SeguradoTO>();
        
        GerarDadosIniciaisTO.SeguradoTO segurado = new GerarDadosIniciaisTO.SeguradoTO();
        segurado.numero = 1;
        segurado.pessoa = new GerarDadosIniciaisTO.PessoaTO();
        segurado.pessoa.tipo = 'FIS';
        segurado.pessoa.rendaMensal = 2500;
        segurado.pessoa.nome = 'Magda Rita da Paixão';
        segurado.pessoa.dadosPessoaFisica = new GerarDadosIniciaisTO.DadosPessoaFisicaTO();
        segurado.pessoa.dadosPessoaFisica.grupoProfissao = 'DIT-B';
        segurado.pessoa.dadosPessoaFisica.profissao = '2410-05';
        segurado.pessoa.dadosPessoaFisica.sexo = 'FEM';
        segurado.pessoa.dadosPessoaFisica.fumante = false;
        segurado.pessoa.dadosPessoaFisica.dataNascimento = '1969-04-22T00:00:00.000Z';
        segurado.pessoa.dadosPessoaFisica.regimeTrabalho = 'CLT';
        segurado.coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();
        
        GerarDadosIniciaisTO.CoberturaTO coberturaBas = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaBas.franquia = '';
        coberturaBas.sigla = 'BAS';
        coberturaBas.valor = 100000;
        coberturaBas.quantidade = 6;
        segurado.coberturas.add(coberturaBas);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaAff = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaAff.franquia = '';
        coberturaAff.sigla = 'AFF';
        coberturaAff.valor = 10000;
        coberturaAff.quantidade = 6;
        segurado.coberturas.add(coberturaAff);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaDit = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaDit.franquia = 'FR_REDUZIDA';
        coberturaDit.sigla = 'DIT';
        coberturaDit.valor = 25;
        coberturaDit.quantidade = 1;
        segurado.coberturas.add(coberturaDit);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaCan = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaCan.franquia = '';
        coberturaCan.sigla = 'CAN';
        coberturaCan.valor = 100000;
        coberturaCan.quantidade = 100000;
        segurado.coberturas.add(coberturaCan);
        
        GerarDadosIniciaisTO.CoberturaTO coberturaTelemed = new GerarDadosIniciaisTO.CoberturaTO();
        coberturaTelemed.franquia = '';
        coberturaTelemed.sigla = 'TELEMED';
        coberturaTelemed.valor = 0;
        coberturaTelemed.quantidade = 0;
        segurado.coberturas.add(coberturaTelemed);
        
        grupo.segurados.add(segurado);
        contratante.grupos.add(grupo);
        List<GerarDadosIniciaisTO.ContratanteTO> contratantesList = new List<GerarDadosIniciaisTO.ContratanteTO>();
        contratantesList.add(contratante);
        GerarDadosIniciaisTO.PayloadTO payloadTeste = (GerarDadosIniciaisTO.PayloadTO) JSON.deserialize(payload, GerarDadosIniciaisTO.PayloadTO.class);
        payloadTeste.orcamentos[0].contratoOriginal = contratoOriginalEntrada;
        payloadTeste.orcamentos[0].tipoSeguro = 'eds';
        payloadTeste.orcamentos[0].contratantes = contratantesList;
        payload = JSON.serialize(payloadTeste);
        
        String jsonRetorno = GerarDadosIniciais.getInstance().gerarDadosIniciais(payload);     
        Test.stopTest(); 
    }
    //FNPVVEP-71 FIM 
}