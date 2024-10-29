/*******************************************************************************************************************************
* Consulta dados Básicos do asegurado test
* @author Edgar Peralta - Globant / Francisco Rochett - Globant
* @date 28/07/2020
* Classe criada por conta da história PLV-3956
******************************************************************************************************************************/
@isTest
global with sharing class ConsultaDadosDoSeguradoTest{

    @testSetup static void setup(){
        Account conta = TestDataFactory.gerarConta();
        TestDataFactory.gerarEndereco(conta);
        conta.ShippingCity = 'São Paulo'; 
        conta.ShippingCountry = 'Brasil';
        conta.ShippingPostalCode = '09876123';
        conta.ShippingState = 'SP';
        conta.ShippingStreet = 'Rua Luar do Sertão';
        conta.ShippingLatitude = 2.0;
        conta.ShippingLongitude = 3.0;
        UPDATE conta;
    }
    
    @IsTest
    static void testCPF() {
        Account conta = [SELECT Cpf__c FROM Account LIMIT 1];
        System.debug('conta: ' + conta);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/ConsultaDadosDoSegurado';  //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        	ConsultaDadosDoSegurado.doPost(conta.Cpf__c);
        Test.stopTest();  
          
        System.assert(![SELECT id FROM Account].IsEmpty());
    }
    
    @IsTest
    static void testCPFError() {
        Account conta = [SELECT Cpf__c FROM Account LIMIT 1];
        System.debug('conta2: ' + conta);
        String cpf = '393.652.880-8O';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/ConsultaDadosDoSegurado';  //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        	List<account> listInsuredData = new List<account>();
        	ConsultaDadosDoSegurado.doPost(cpf);
        Test.stopTest();           
        
        System.assert([SELECT id, Cpf__c FROM Account where Cpf__c =: cpf].IsEmpty());
    }    
    
}