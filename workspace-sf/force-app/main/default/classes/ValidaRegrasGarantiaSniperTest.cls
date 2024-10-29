/*********************************************************************************************************************************************************************

@description  Classe que contem a Controller para o  Validação de Regras da Garantia Sniper.
@author Renan Martins - Avanxo
@date 26/06/2019
@Hackathon Sniper Atualização 09/08/2019
@Classe criada por conta da história PLV-2502
        
**********************************************************************************************************************************************************************/

@isTest
public class ValidaRegrasGarantiaSniperTest {
    


    @isTest
     static void testRegrasGarantiaSniper() {
         
        
          StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadOrcamentoSniper' LIMIT 1];
                  system.debug('TESTE RM 1' + staticResource);

                String payload = staticResource.Body.toString();
         	
         Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
         
         //Cria Registro Garantia do Produto
        ContadorCodigo__c cdComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        ContadorCodigo__c cdTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
         
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
         
         RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
         
         //Recurso Estático
        Test.startTest();
        
         
        //PLV_2826 - INICIO - Criar oportunidade sem conta
        EmissaoTO.PayloadTO retornoPayloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
        ServiceTO.PayRetornoOfertasTO ofertas = ValidaRegrasGarantiaSniper.ValidaGarantias(retornoPayloadTO);
        //PLV_2826 - FIM  - Criar oportunidade sem conta 
         
 	 ServiceTO.PayRetornoOfertasTO payloadRetorno = (ServiceTO.PayRetornoOfertasTO) JSON.deserialize(payload, ServiceTO.PayRetornoOfertasTO.class);
       ValidaRegrasGarantiaSniper.adicionarErros(payloadRetorno,1,'Prezado cliente, favor selecionar todas as garantias obrigátorias');
         
        Test.stopTest();   

     }
    
}