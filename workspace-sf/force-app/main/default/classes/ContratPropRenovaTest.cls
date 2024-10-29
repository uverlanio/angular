/****************************************************************************************************************************
 * Classe de teste implementada para o processo automático de liberação automática de Propostas do tipo Renovação           *
 * @author : Globant                                                                                                        *
 * @date 06/06/2022                                                                                                         *
 * Classe implementada tendo como origem a história RVI-104                                                                 *
 * Disparada através do Schedule Trggered Flow 'Liberar Contratação de Propostas de Renovação'                              *
 * **************************************************************************************************************************/

@isTest
public with sharing class ContratPropRenovaTest {
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
        propostaTeste.FaseStatus__c = 'Palavra final'; //RVI-247 - INICIO/FIM
        update propostaTeste;

        //Geração de forma de Pagamento
        FormaPagamento__c pagamento = TestDataFactory.gerarFormaPagamento();

        //Geração do Contratante da Proposta Para Propostas Liberadas e Não Liberadas
        ContratanteProposta__c contratantePropLiberada = TestDataFactory.gerarContratanteProposta(contaTeste, propostaTeste, pagamento);

        //Criação das Criticas Proposta Liberada
        //RVI-170 - INICIO
        CriticaProposta__c criticaLibRenovacao = TestDataFactory.gerarCriticasPropostaRenovacao(propostaTeste, '154', 'Pendente');
        CriticaProposta__c criticaLibQuestVida = TestDataFactory.gerarCriticasPropostaRenovacao(propostaTeste, '124', 'Liberado');
        //RVI-247 - INICIO
        criticaLibRenovacao.MomentoAnalise__c = 'Palavra final';
        update criticaLibRenovacao;
        //RVI-247 - FIM
        //RVI-170 - FIM
        //CriticaProposta__c criticaTest = TestDataFactory.gerarCriticasPropostaRenovacao(propostaTeste, '0', 'Não iniciada');

    }
    //RVI-104 - FIX01 - INICIO
    //RVI-297 INICIO
    @isTest
    public static void testLiberarCriticaRenovacao(){
      ContratPropRenova.liberarCriticaRenovacao(); 
      
      List<CriticaProposta__c> criticasLiberadas = [SELECT Id FROM CriticaProposta__c WHERE Codigo__c = '154'];      
      if (criticasLiberadas <> null) {
        System.assertEquals(1, criticasLiberadas.size());
      }
    }    
    //RVI-104 - FIX01 - FIM

    @isTest
    public static void testLiberarCriticaRenovacaoBatch(){

      ContratPropRenova batchPropostas = new ContratPropRenova();
      Database.executeBatch(batchPropostas);     
      
      List<CriticaProposta__c> criticasLiberadas = [SELECT Id FROM CriticaProposta__c WHERE Codigo__c = '154'];      
      if (criticasLiberadas <> null) {
        System.assertEquals(1, criticasLiberadas.size());
      }
    }    
    //RVI-297 FIM
}