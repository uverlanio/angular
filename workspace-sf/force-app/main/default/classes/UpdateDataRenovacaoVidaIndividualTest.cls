@isTest
public with sharing class UpdateDataRenovacaoVidaIndividualTest {
    @TestSetup
    static void makeData(){
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
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        /* Inicio Geração Contratos Para Teste RVI-80 */

        // Formatação e Gravação Parâmetros Vigência
        ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoCom);
        paramVigencia.VigenciaMinimaRenovacao__c = 90;
        paramVigencia.Tipo__c = 'Periódico';
        update paramVigencia;

        // Formatação e Gravação Quote
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        cot.NumeroProposta__c = '00001910';

        // Formatação e Gravação Contrato
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.NumeroPropostaUnico__c = '18-00001910';
        contrato.NumeroApolice__c = '000014419';
        contrato.Tipo__c = 'Renovacao';
        contrato.Status = 'Ativo';
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c = System.today().addDays(30);
        update contrato;
        /* Fim Geração Contratos Para Teste RVI-80 */
    }

    @isTest
    static void test() {
        Test.startTest();
        UpdateDataRenovacaoVidaIndividual udrvi = new UpdateDataRenovacaoVidaIndividual();
        Id batchId = Database.executeBatch(udrvi);
        Test.stopTest();

        List<Contract> contratos = [SELECT ID, DataRenovacao__c, VigenciaFinal__c, Produto__c 
                                    FROM   Contract 
                                    WHERE  Tipo__c <> 'Cancelamento'
                                    AND    Status  <> 'Cancelado'
                                    AND    Endosso__c = '0'
                                    AND    Segmento__c = 'Individual'];

        Id produtoId = contratos[0].Produto__c;

        List<ParametroVigencia__c> pv = [ SELECT VigenciaMinimaRenovacao__c
                                          FROM   ParametroVigencia__c
                                          WHERE  Produto__c = :produtoId
                                          LIMIT 1 
                                        ];

        Integer subtracaoDias = Integer.valueOf(pv[0].VigenciaMinimaRenovacao__c); 

        System.assertEquals(contratos.size(), 1);
        System.assertEquals(contratos[0].DataRenovacao__c, contratos[0].VigenciaFinal__c.addDays(-subtracaoDias));
    }
}