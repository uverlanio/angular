@isTest
public with sharing class Rvi118Test {
    @isTest
    public static void testTriggerRvi118Quote(){
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
        orcamentoContratado.ContratoRenovado__c = '800L0000003GsysIAC';
        orcamentoContratado.indiceIPCA__c = 0.45;
        update orcamentoContratado;
        
        // Geração Modalidade
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        // Geração Quote
      	Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        
        System.debug('***----- Apos TestDataFactory.gerarPropostaObjeto() -----***');
        System.debug('Id Proposta      = ' + cot.Id);
        System.debug('ContratoRenovado = ' + cot.ContratoRenovado__c);
        System.debug('Indice IPCA      = ' + cot.indiceIPCA__c);
    }
    /*
    @isTest
    public static void testTriggerRvi118() {
        List<Quote> propostas = [SELECT Id, 
                                         ContratoRenovado__c,
                                         indiceIPCA__c 
                                 FROM    Quote
                                 WHERE   ContratoRenovado__c = '800L000000395fcIAA'
                                 AND     indiceIPCA__c       = 0.45];
        
        System.debug('***----- Apos SELECT em Quote -----***');
        System.debug('Total Propostas Selecionadas = ' + propostas.size());
        System.debug('Id Proposta      = ' + propostas[0].Id);
        System.debug('ContratoRenovado = ' + propostas[0].ContratoRenovado__c);
        System.debug('Indice IPCA      = ' + propostas[0].indiceIPCA__c);
    }
	*/
}