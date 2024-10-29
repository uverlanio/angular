/******************************************************************************************************************************
 * Faz testes na classe RestimuloContratoHeroku                                                                               *
 * @author : Globant                                                                                                          *
 * @date 30/09/2022                                                                                                           *
 * Classe implementada tendo como origem a história PLV-5266                                                                  *
 * Test                                                                                                                       *
 ******************************************************************************************************************************/
@isTest
public with sharing class RestimuloContratoHerokuTest 
{
    @TestSetup
    static void makeData()
    {
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
        produtoTec.ProductCode = 'VIDA_ON';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        produtoCom.ProductCode = 'VIDA_ON';
        update produtoCom;

        GarantiaProduto__c garantiaTecnica = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);

        GarantiaProduto__c garantiaComercial = TestDataFactory.gerarGarantiaProdutoComercial(produtoCom, garantia1, garantiaTecnica, ramoSegurado);

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoCom);
        paramVigencia.VigenciaMinimaRenovacao__c = 90;
        paramVigencia.Tipo__c = 'Periódico';
        update paramVigencia;

        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        cot.NumeroProposta__c = '00039643';
        cot.email__c = 'email@email.com';
        update cot;
        
        FormaPagamento__c formPag = TestDataFactory.gerarFormaPagamento(ramoSegurado, modalidade, 'CARTAO DE CREDITO (TODAS PARC.EM CARTAO)', '62');

        String empresa = '1';
        String sucursal = '1391';
        String ramo = '1';
        String numeroApolice = '000022748'; 
        String endosso = '0';


        Contract contrato = new Contract(
                Name = ContractBO.getInstance().gerarNameContrato(empresa, sucursal, ramo, numeroApolice, endosso),
                Produto__c = produtoCom.Id,
                NumeroApolice__c = numeroApolice,
                RamoSeguro__c = ramoSegurado.Id,
                Status = 'Em elaboração',
                Empresa__c = empresa,
                CodigoCorretor__c = dadosCorretor.Id,
                MeioComercializacao__c = 'PMC', 
                Proposta__c = cot.Id,
                AccountId = contaTeste.Id,
                StartDate = System.today(),
                VigenciaFinal__c = System.today().addDays(30),
                DataEmissao__c = System.today(),
                Endosso__c = endosso,
                Sucursal__c = sucursal,
                CodigoRamo__c = ramo,
                PremioComercial__c = 15000.00,
                Parceiro__c = '67708896000139'
        );

        insert contrato;

        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('Contrato', 15, 1000, 'Integral');

        RemuneracaoContrato__c remCon = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        remCon.CurrencyIsoCode = 'BRL';
        remCon.Percentual__c = 10;
        remCon.Porcentagem_de_Retencao__c = 0;
        update remCon;

        FavorecidoRemuneracaoContrato__c favRemCon = new FavorecidoRemuneracaoContrato__c();
        favRemCon.Conta__c = contaTeste.Id;
        favRemCon.CorretorLider__c = true;
        favRemCon.AntecipacaoComissao__c = true;
        favRemCon.RemuneracaoContrato__c = remCon.Id;
        favRemCon.Papel__c = 'Corretor';
        insert favRemCon;	

        GarantiaContrato__c garCtr = TestDataFactory.gerarGarantiaContrato(contrato, garantiaComercial);
    }
    @isTest
    static void batchRestimuloContratoHerokuTest() 
    {
        String payloadReturn = '{"servico":"/reestimuloapolice/reestimular-status-apolice","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2022-10-21T17:48:15.518Z","descricao":"Consulta realizada com sucesso.","encontrouregistro":true,"dados":[{"idproposta":"18-00039643","empresa":"1","sucursal":"1","ramo":"1391","apolice":"000022748","endosso":"0"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
        RestimuloContratoHeroku RestimuloContrato = new RestimuloContratoHeroku();
        Test.startTest();
        Database.executeBatch(RestimuloContrato,100);
        Test.stopTest();
    }
    @isTest
    static void scheduleRestimuloContratoHerokuTest() 
    {
        String payloadReturn = '{"servico":"/reestimuloapolice/reestimular-status-apolice","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2022-10-21T17:48:15.518Z","descricao":"Consulta realizada com sucesso.","encontrouregistro":true,"dados":[{"idproposta":"18-00039643","empresa":"1","sucursal":"1","ramo":"1391","apolice":"000022748","endosso":"0"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
        RestimuloContratoHeroku RestimuloContrato = new RestimuloContratoHeroku();
        Test.startTest();
        System.schedule('RestimuloContrato: execução de batch > 9 horas', '0 0 9 * * ?', RestimuloContrato);
        Test.stopTest();
    }
}