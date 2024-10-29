@isTest
public with sharing class UpdateGrupoRiscoTest {
    @TestSetup
    static void makeData(){
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
        
        // Geração Modalidade
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        // Geração Quote
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        cot.NumeroProposta__c = '00001910';

        // Geração Contrato
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.NumeroPropostaUnico__c = '18-00001910';
        contrato.NumeroApolice__c = '000014419';
        contrato.Tipo__c = 'Renovacao';
        contrato.Status = 'Ativo';
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c = System.today().addDays(30);
        update contrato;

        // Geração Contratante do Contrato
        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaTeste, contaTeste);

        // Geração Grupo do Contrato
        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);

        // Geração Segurado do Contrato
        SeguradoContrato__c seguradoContrato = TestDataFactory.gerarSeguradoContrato(grupoContrato, contaTeste);

        // Geração Forma de Pagamento
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();

        // Geração Contratante Proposta
        ContratanteProposta__c contratanteProposta = TestDataFactory.gerarContratanteProposta(contaTeste, cot, formaPagamento);

        // Geração Grupo Proposta
        GrupoProposta__c grupoProposta = TestDataFactory.gerarGrupoProposta(contratanteProposta);

        // Geração Segurado Proposta
        SeguradoProposta__c seguradoProposta = TestDataFactory.gerarSeguradoProposta(contaTeste, grupoProposta, formaPagamento);
        seguradoProposta.GrupoRisco__c = 'DIT-A';
        update seguradoProposta;
    }

    @isTest
    static void test() {
        Test.startTest();
        UpdateGrupoRisco ugr = new UpdateGrupoRisco();
        Id batchId = Database.executeBatch(ugr);
        Test.stopTest();

        List<SeguradoContrato__c> seguradosContrato  = [SELECT GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r.NumeroProposta__c,
                                                               Id,
                                                               GrupoRisco__c
                                                        FROM   SeguradoContrato__c
                                                        WHERE  GrupoContrato__r.ContratanteContrato__r.Contrato__r.Segmento__c = 'Individual'];

        //String numeroProposta = (String)seguradosContrato[0].getSobject('GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r').get('NumeroProposta__c');
        String numeroProposta = seguradosContrato[0].GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r.NumeroProposta__c;

        List<SeguradoProposta__c> seguradosProposta = [SELECT GrupoProposta__r.ContratanteProposta__r.Proposta__r.NumeroProposta__c,
                                                              Id,
                                                              GrupoRisco__c
                                                       FROM   SeguradoProposta__c
                                                       WHERE  GrupoProposta__r.ContratanteProposta__r.Proposta__r.NumeroProposta__c = :numeroProposta];
                                                       
        System.debug('Id Segurado Proposta             = ' + seguradosProposta[0].Id);
        System.debug('Id Segurado Contrato             = ' + seguradosContrato[0].Id);  
        System.debug('Numero Proposta                  = ' + numeroProposta);
        System.debug('Grupo Risco de Segurado Proposta = ' + seguradosProposta[0].GrupoRisco__c);
        System.debug('Grupo Risco de Segurado Contrato = ' + seguradosContrato[0].GrupoRisco__c);   

        System.assertEquals(seguradosContrato.size(), 1);
        System.assertEquals(seguradosProposta.size(), 1);
        System.assertNotEquals(seguradosProposta[0].GrupoRisco__c, null);
        System.assertNotEquals(seguradosContrato[0].GrupoRisco__c, null);
        System.assertEquals(seguradosContrato[0].GrupoRisco__c, seguradosProposta[0].GrupoRisco__c);
    }
}