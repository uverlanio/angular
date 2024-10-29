@isTest
public with sharing class GarantiaTriggerHandlerTest {

    @isTest
    static void testGarantia() {

        Garantia__c garantiaTestada = (Garantia__c) new GarantiaFactory().createRecord();
        garantiaTestada.Tipo__c = 'Benefício;Cobertura';
		try{
            update garantiaTestada;
        }catch (DmlException error){
			System.assert(error.getMessage().contains('O campo de Tipo deve conter apenas uma opção selecionada'), 'Erro ao atualizar a garantia');
        }
	}
}