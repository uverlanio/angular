/***************************************************************************************************************************
* Classe implementada para garantir a cobertura de testes do módulo original: 'UptFormPagPropRen' criada na tarefa RVI-171 *                                   
* @author : Globant                                                                                                        *
* @date 16/01/2023                                                                                                         *
* Disparada através do Schedule  'AltFPgtRenSchedulable'                                                                   *
* **************************************************************************************************************************/

@isTest
public with sharing class UptFormPagPropRenTest {

    @TestSetup
    static void makeData1(){
    
        Account contaTeste = TestDataFactory.gerarConta();

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
    
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
        orcamentoContratado.StageName = 'Disponível para contratação';  
        update orcamentoContratado;
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
    
        Quote propostaRen = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        propostaRen.Status = 'Em análise';
        propostaRen.Tipo__c = 'Renovacao';
        propostaRen.VigenciaInicial__c = System.today().addDays(10);
        update propostaRen;

        FormaPagamento__c pagamento = TestDataFactory.gerarFormaPagamento();
        
        ContratanteProposta__c contratantePropLiberada = TestDataFactory.gerarContratanteProposta(contaTeste, propostaRen, pagamento);

        CriticaProposta__c criticaFalhaInt = TestDataFactory.gerarCriticasPropostaRenovacao(propostaRen, '0', 'Falha na Integração');
        criticaFalhaInt.MensagemInterna__c = 'REJEITADO';
        update criticaFalhaInt;

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, propostaRen);
        contrato.Proposta__c = propostaRen.Id;
        contrato.StatusRenovacao__c = 'Renovação em andamento';
        contrato.AlteraFormaPagto__c = false;
        update contrato;

        propostaRen.ContratoRenovado__c = contrato.Id;
        update propostaRen;
    }
    //FNPVVEP-172 INICIO
    // @istest static void testScheduleCrit(){
    //     Test.StartTest();
    //     System.debug('Iniciando o processamento');
    //     AltFPgtRenSchedulable schd = new AltFPgtRenSchedulable();
    //     String scheduleTest = '0 0 23 ? * *';
    //     System.debug('Iniciando o comparativo');
    //     System.schedule('Teste de Job', scheduleTest, schd);
    //     System.debug('Terminando o comparativo');
    //     Test.stopTest();
    // }

    @istest 
    static void altFPgtTest(){
        Test.StartTest();
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        List<String> idPropostas = new List<String>();
        idPropostas.add(proposta.id);
        UptFormPagPropRen.altFPgt(idPropostas);
        Test.stopTest();
    }

    @istest 
    static void altFPgtFlowTest(){
        Test.StartTest();
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        List<String> idPropostas = new List<String>();
        idPropostas.add(proposta.id);
        UptFormPagPropRen.altFPgtFlow(idPropostas);
        Test.stopTest();
    }
    //FNPVVEP-172 FIM
}