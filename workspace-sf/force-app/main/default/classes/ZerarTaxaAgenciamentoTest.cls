@isTest
public with sharing class ZerarTaxaAgenciamentoTest {
    @testSetup
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
        
        //RVI-247 - INICIO
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        //Opportunity orcamentoRenovado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        Opportunity orcamentoRenovado = [SELECT Id FROM Opportunity];
        orcamentoRenovado.Name = 'ARQ-00006780';
        orcamentoRenovado.Numero__c = '00006780';
        update orcamentoRenovado;

        Opportunity orcamentoNovo = [SELECT Id FROM Opportunity];
        orcamentoRenovado.Name = 'ARQ-00006780';
        orcamentoRenovado.Numero__c = '00006781';
        update orcamentoRenovado;

        Opportunity orcamentoFinal = [SELECT Id FROM Opportunity];
        orcamentoRenovado.Name = 'ARQ-00006780';
        orcamentoRenovado.Numero__c = '00006782';
        update orcamentoRenovado;

        // Opportunity orcamentoNovo = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        // Opportunity orcamentoFinal = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        //RVI-247 - FIM
        
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoCom);
        paramVigencia.VigenciaMinimaRenovacao__c = 90;
        paramVigencia.Tipo__c = 'Periódico';
        update paramVigencia;

        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        cot.Email = 'gustavo.figueiredo@globant.com';
        cot.Tipo__c = 'Renovacao';
        update cot;

        TipoRemuneracao__c tipoRemCOR = TestDataFactory.gerarTipoRemuneracao();
        tipoRemCOR.Name = 'CORRETAGEM'; 
        tipoRemCOR.Codigo__c = 'COR';
        update tipoRemCOR;

        TipoRemuneracao__c tipoRemAGE = TestDataFactory.gerarTipoRemuneracao();
        tipoRemAGE.Name = 'AGENCIAMENTO'; 
        tipoRemAGE.Codigo__c = 'AGE';
        update tipoRemAGE;

        RemuneracaoProposta__c remuneracaoCOR = TestDataFactory.gerarRemuneracaoProposta(cot, tipoRemCOR);
        RemuneracaoProposta__c remuneracaoAGE = TestDataFactory.gerarRemuneracaoProposta(cot, tipoRemAGE);
        
    }
    
    @isTest
    public static void testFlow(){
	    // SELECT .... FROM Quote ..... 
        List<RemuneracaoProposta__c> agenciamento = [
            SELECT Proposta__r.Email, Proposta__r.Tipo__c, TipoRemuneracao__r.Name, Percentual__c  
            FROM RemuneracaoProposta__c WHERE
                 Proposta__r.Email = 'gustavo.figueiredo@globant.com' AND
                 TipoRemuneracao__r.Name = 'AGENCIAMENTO'
            LIMIT 1];
	    
        for(RemuneracaoProposta__c remuneracao: agenciamento){
            System.debug('Iniciando a apresentação do objeto');
            System.debug('Email: ' + remuneracao.Proposta__r.Email);
            System.debug('-----------------------------------');
            System.debug('Tipo proposta: ' + remuneracao.Proposta__r.Tipo__c);
            System.debug('-----------------------------------');
            System.debug('Tipo remuneracao: ' + remuneracao.TipoRemuneracao__r.Name);
            System.debug('-----------------------------------');
            System.debug('Percentual: ' + remuneracao.Percentual__c);
            System.debug('-----------------------------------');
        }

        // System.assertEquals(0, agenciamento[0].Percentual__c);
    }
}