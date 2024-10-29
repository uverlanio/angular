/******************************************************************************************************************************
* Consulta dados de Banco
* @author Carlos - Meta
* @date 08/09/2020
* Classe criada por conta da história PLV-4383
******************************************************************************************************************************/
@isTest
public class ConsultaBancoTest {
    @TestSetup
    static void setupUnit(){
        Banco__c banco = new Banco__c(Name= 'Banco teste');
        insert banco;
    }

     
    @IsTest
    static void valida_parametros(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"bancosConveniados\":\"true\"}');
        RestContext.request = req;
        
        Test.startTest();
            ConsultaBancoREST.Response result = ConsultaBancoREST.consultar();
        	System.debug(JSON.serialize(result));
        Test.stopTest();
    }    
    @IsTest
    static void valida_parametros_2(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{}');
        RestContext.request = req;
        
        Test.startTest();
            ConsultaBancoREST.Response result = ConsultaBancoREST.consultar();
        	System.debug(JSON.serialize(result));
        Test.stopTest();
    }    

    
    @IsTest
    static void busca_proposta(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"bancosConveniados\":\"todos\"}');
        RestContext.request = req;

        Test.startTest();
            ConsultaBancoREST.Response result = ConsultaBancoREST.consultar();
            System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }
}