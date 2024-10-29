@istest
public class ContratPropRenovaScheduleTest {
    
    @testSetup
    public static void gerarDadosTeste(){
        // Geração Account
        Account contaTeste = TestDataFactory.gerarConta();

        // Geração Dados do Corretor
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);

        // Geração Ramo do Seguro
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);

        // Geração Garantia
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	      ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        // Geração Propduto Técnico
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        update produtoTec;
        
        // Geração Produto Comercial
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        update produtoCom;

        // Geração Canal de Distribuição
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        // Geração Orçamento (Opportunity)
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        orcamentoContratado.Type = 'Renovacao';        
        update orcamentoContratado;
        
        // Geração Modalidade
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        // Geração Quote
      	Quote propostaTeste= TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        propostaTeste.Status = 'Em análise';
        propostaTeste.Tipo__c = 'Renovacao';
        propostaTeste.VigenciaInicial__c = System.today().addDays(10);
        propostaTeste.PaisesDestino__c = 'Brasil';
        update propostaTeste;

        //Geração de forma de Pagamento
        FormaPagamento__c pagamento = TestDataFactory.gerarFormaPagamento();

        //Geração do Contratante da Proposta Para Propostas Liberadas e Não Liberadas
        ContratanteProposta__c contratantePropLiberada = TestDataFactory.gerarContratanteProposta(contaTeste, propostaTeste, pagamento);

        //Criação das Criticas Proposta Liberada
        CriticaProposta__c criticaLibRenovacao = TestDataFactory.gerarCriticasPropostaRenovacao(propostaTeste, '154', 'Pendente');
        CriticaProposta__c criticaLibAssEletr = TestDataFactory.gerarCriticasPropostaRenovacao(propostaTeste, '109', 'Pendente');
        CriticaProposta__c criticaLibQuestVida = TestDataFactory.gerarCriticasPropostaRenovacao(propostaTeste, '124', 'Liberado');
    }

    @istest static void testSchedule(){
        List<CriticaProposta__c> criticasLiberadas = [SELECT Id FROM CriticaProposta__c WHERE Codigo__c = '154'];      
        if (criticasLiberadas <> null) {
            System.assertEquals(1, criticasLiberadas.size());
        }
        
        Test.StartTest();
        System.debug('Iniciando o processamento');
        ContratPropRenovaSchedule schd = new ContratPropRenovaSchedule();
        String scheduleTest = '0 0 23 ? * *';
		System.debug('Iniciando o comparativo');
        System.schedule('Teste de Job', scheduleTest, schd);
        System.debug('Terminando o comparativo');
        Test.stopTest();
    }
}