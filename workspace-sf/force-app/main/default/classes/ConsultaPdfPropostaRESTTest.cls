/*******************************************************************************************************************************
* Consulta documento
* @author Yuri - Sys4b
* @date 26/04/2021
* Classe criada por conta da história PLV-4896
******************************************************************************************************************************/
@isTest
public class ConsultaPdfPropostaRESTTest {
	@TestSetup
    static void setupUnit(){
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
                
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        RamoSeguro__c ramoSeguro = ( RamoSeguro__c ) new RamoSeguroFactory( conta ).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
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
        
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
		CanalDistribuicao__c canal = new CanalDistribuicao__c(
				Name = 'Corretor',
            	Sigla__c = 'COR',
            	Papeis__c = 'Corretor'
        		);
       	
        insert canal;
       

        proposta.CanalDistribuicao__c = canal.Id;
          proposta.CanalDistribuicao__r = canal;
        proposta.Status = 'Contratada';
        update proposta;
        
        System.debug('@@@@');
        System.debug(canal);
        System.debug(canal.Id);
        System.debug(proposta.CanalDistribuicao__c);
        System.debug(proposta.CanalDistribuicao__r.Name);
        System.debug(proposta.CodigoCorretor__c);
        System.debug(proposta.Name);
    }
    
    @IsTest
    static void valida_parametros(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"proposta\":\"\"}');
        RestContext.request = req;
        
        Test.startTest();
        ConsultaPdfPropostaREST.Response result = ConsultaPdfPropostaREST.consultar();
        System.debug(JSON.serialize(result));
        req.requestBody = Blob.valueof('{\"proposta\":\"18-00006768\", \"canal\":\"Corretor\"}');
        RestContext.request = req;
        result = ConsultaPdfPropostaREST.consultar();
		req.requestBody = Blob.valueof('{\"idCanal\":\"001\", \"canal\":\"Corretor\"}');
        RestContext.request = req;
        result = ConsultaPdfPropostaREST.consultar();
        req.requestBody = Blob.valueof('');
        RestContext.request = req;
        result = ConsultaPdfPropostaREST.consultar();

        Test.stopTest();
    } 
    
    @IsTest
    static void busca_documento(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"proposta\":\"18-00006768\", \"idCanal\":\"001\", \"canal\":\"Corretor\"}');
        RestContext.request = req;

        Test.startTest();
        ConsultaPdfPropostaREST.Response result = ConsultaPdfPropostaREST.consultar();
        System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }
 
}