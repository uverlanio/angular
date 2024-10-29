/**
 * Teste dos serviços do objeto Modalidade__c
 * @author Fernando Barcellos @ 28/06/2018
 *
 **/
@isTest
private class ModalidadeServiceTest {

	@testSetup
	static void setup() {
		Integracao__c integracao = new Integracao__c();
		integracao.Name = 'Modalidade';
		integracao.DeveloperName__c = 'Modalidade__c';
		integracao.UltimaExecucao__c = System.now();
		insert integracao;
	}

	@isTest
	static void testeSincronizarModalidade() {
		String responseJsonString = '{"modalidades": [{"codigoEmpresa": 14,"codigoRamo": 2,"codigoModalidade": 65,"nomeModalidade": "PGBL INDIVIDUAL 12 MESES                ","dataAlteracao": "2017-12-11","grupoRamosProducao": 5}]}';

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 200, 'OK'));
		Test.startTest();

		IntegracaoBO.getInstance().executarIntegracao(Modalidade__c.sObjectType.getDescribe().getName());

		String nomeObjeto = Modalidade__c.sObjectType.getDescribe().getName();
		Integracao__c integracao = [SELECT Id, Name, UltimaExecucao__c FROM Integracao__c WHERE DeveloperName__c =: nomeObjeto LIMIT 1];

		Test.stopTest();

		System.assert(integracao != null);
		System.assert(integracao.UltimaExecucao__c <= System.now());
	}

	@isTest
	static void testarErroSincronizacao() {
		String responseJsonString = '{"modalidades": [{"codigoEmpresa": 14,"codigoRamo": 2,"codigoModalidade": 65,"nomeModalidade": "PGBL INDIVIDUAL 12 MESES                ","dataAlteracao": "2017-12-11","grupoRamosProducao": 5}]}';

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 500, 'OK'));
		Test.startTest();

		try {
			IntegracaoBO.getInstance().executarIntegracao(Modalidade__c.sObjectType.getDescribe().getName());
		}
		catch(Exception e) {
			System.assertEquals('Erro ao buscar modalidade.', e.getMessage());
		}

		String nomeObjeto = Modalidade__c.sObjectType.getDescribe().getName();
		Integracao__c integracao = [SELECT Id, Name, UltimaExecucao__c FROM Integracao__c WHERE DeveloperName__c =: nomeObjeto LIMIT 1];

		Test.stopTest();
	}
	
}