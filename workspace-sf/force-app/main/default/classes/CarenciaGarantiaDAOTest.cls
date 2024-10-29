/*

*/
@isTest
public with sharing class CarenciaGarantiaDAOTest {
    @isTest static void buscarMapCarenciasGarantiaTest(){
        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        Test.startTest();
            Map<String, List<CarenciaGarantia__c>> carenciaIndexByGarantia = CarenciaGarantiaDAO.getInstance().buscarMapCarenciasGarantia(new Set<Id>{records.get('GarantiaProdutoTec').Id});
        Test.stopTest();

        System.assert(carenciaIndexByGarantia.containsKey(records.get('GarantiaProdutoTec').Id), 'O Mapa não possui essa chave');
    }
}