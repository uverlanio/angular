/*******************************************************************************************************************************
* Consulta dados de Orcamento
* @author Carlos - Meta
* @date 30/07/2020
* Classe criada por conta da história PLV-420
******************************************************************************************************************************/
@isTest
public  class ConsultaOrcamentoRESTTest {
    @TestSetup
    static void setupUnit(){
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        CanalDistribuicao__c canalDistribuicao = (CanalDistribuicao__c) new CanalDistribuicaoFactory().createRecord(); 
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        orcamento.Type = 'Novo'; // PLV - 4339 INICIO/FIM
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        GarantiaOrcamento__c garantiaOrcamentoCan = (GarantiaOrcamento__c) new GarantiaOrcamentoFactory(garantia, orcamento).createRecord();
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        orcamento.CodigoCorretor__c = dadosCorretor.Id;
        orcamento.CanalDistribuicao__c = canalDistribuicao.Id;
        update orcamento;
    }

    
    @IsTest
    static void valida_parametros(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"canal\":\"Canal Distribuição Teste 001\"}');
        RestContext.request = req;
        
        Test.startTest();
            ConsultaOrcamentoREST.Response result = ConsultaOrcamentoREST.consultar();
        	System.debug(JSON.serialize(result));
        Test.stopTest();
    }    

    @IsTest
    static void busca_proposta(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"canal\":\"Canal Distribuição Teste 001\", \"idCanal\": \"001\"}');
        RestContext.request = req;

        Test.startTest();
            ConsultaOrcamentoREST.Response result = ConsultaOrcamentoREST.consultar();
            System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }
}