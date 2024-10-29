/******************************************************************************************************************************
* Executa alterações após a assinatura do documento Docusign
* @author Carlos - Meta
* @date 03/03/2021
* Classe criada por conta da história PLV-4839
******************************************************************************************************************************/
@isTest
public class RetornoDocusignTest {
    @TestSetup
    static void setupUnit(){
        Opportunity opp = new Opportunity();
        opp.Name = 'asd';
        opp.StageName = 'Em criação';
        opp.CloseDate = System.today();
        insert opp;

        //TKCL-246 FIX05 INICIO
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
        produtoTecnico.ProductCode = '49';
        produtoTecnico.Segmento__c = 'Individual';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.ProductCode = 'APTLMKT';
        produtoComercial.Segmento__c = 'Individual';
        produtoComercial.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercial;
        //TKCL-246 FIX05 FIM

        // PLV-4545 - INICIO
        CriticaOrcamento__c criticaOrcamento = new CriticaOrcamento__c();
        criticaOrcamento.Acao__c = 'auto'; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
        criticaOrcamento.Status__c = 'Pendente';
        criticaOrcamento.Origem__c = 'ODM';
        criticaOrcamento.Orcamento__c = opp.Id;
        criticaOrcamento.Justificativa__c = '123';
        insert criticaOrcamento;
        
        Canal_Subscricao__c cs = new Canal_Subscricao__c();
        cs.Name = 'auto';
        cs.Marca_Docusign__c = 'Marcadeexemplodocusign';
        insert cs;
        
        PastaECM__c pasta = new PastaECM__c();
        pasta.Name = 'Proposta';
        pasta.Id_Pasta__c = '12312312321';
        insert pasta;
		// PLV-4545 - FIM
		// 
        Quote proposta = new Quote();
        proposta.OpportunityId = opp.Id;
        proposta.Name = 'asd';
        proposta.Status = 'Em análise';
        proposta.RealizarEnvioDocusign__c = true;
        proposta.Produto__c =produtoComercial.Id; //TKCL-246 FIX05 INICIO/FIM
        insert proposta;

        CriticaProposta__c critica = new CriticaProposta__c();
        critica.Proposta__c = proposta.Id;
        critica.Status__c = 'Em aprovação';
        critica.Integracao__c = 'DOCUSIGN';
        insert critica;
    }

     
    @IsTest
    static void envia(){
        String propostaId = [SELECT Id FROM Quote limit 1].Id;
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"sfId\":\"'+propostaId+'\", \"status\": \"Cancelada\"}');
        RestContext.request = req;
        
        Test.startTest();
            RetornoDocusignREST.Response result = RetornoDocusignREST.consultar();
        	System.debug(JSON.serialize(result));
        Test.stopTest();
    }    
    @IsTest
    static void envia2(){
        String propostaId = [SELECT Id FROM Quote limit 1].Id;
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"sfId\":\"1232131321\", \"status\": \"Cancelada\"}');
        RestContext.request = req;
        
        Test.startTest();
            RetornoDocusignREST.Response result = RetornoDocusignREST.consultar();
        	System.debug(JSON.serialize(result));
        Test.stopTest();
    }    
    @IsTest
    static void valida_parametros(){
        String propostaId = [SELECT Id FROM Quote limit 1].Id;
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"sfId\":\"'+propostaId+'\"}');
        RestContext.request = req;
        
        Test.startTest();
            RetornoDocusignREST.Response result = RetornoDocusignREST.consultar();
        	System.debug(JSON.serialize(result));
        Test.stopTest();
    }    
        
}