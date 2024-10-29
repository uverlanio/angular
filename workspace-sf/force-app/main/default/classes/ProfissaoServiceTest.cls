/**
 * Teste dos serviços do objeto Profissao__c
 * @author Fernando Barcellos @ 05/12/2017
 *
 **/
@isTest
private class ProfissaoServiceTest {
	@testSetup
	static void setup() {
		Integracao__c integracao = new Integracao__c();
		integracao.Name = 'Profissão';
		integracao.DeveloperName__c = 'Profissao__c';
		integracao.UltimaExecucao__c = System.now();
		insert integracao;
	}
	//PLV-4878 INICIO
	//INICIO | PLV-1586-29-v1
	@isTest
	static void testeSincronizarProfissoes() {
		//PLV 4518 Inicio Fix 3
		String responseJsonString = '{"ocupacoes": [{"numeroOcupacao": 1,"codigoGrupo": 0,"nomeOcupacao": "Membros das forcas armadas, policiais e bombeiros militares","dataAtualizacao": "2020-07-23","codigoSituacao": "A"}]}';
		//String responseJsonString = '{"ocupacoes":[{"numeroOcupacao":1,"codigoGrupo":0,"nomeOcupacao":"Membros das forcas armadas, policiais e bombeiros militares","dataAtualizacao":"2020-07-23","codigoSituacao":"A","codigoFamilia": "0101","codigoOcupacao": "0101-05","codigoSubGrupo": "010"},{"numeroOcupacao":2,"codigoGrupo":1,"nomeOcupacao":"Membros superiores do poder publico, dirigentes de organizações de interesse publico e de empresas, gerentes","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":3,"codigoGrupo":2,"nomeOcupacao":"Profissionais das ciências e das artes","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":4,"codigoGrupo":3,"nomeOcupacao":"Técnicos de nível médio","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":5,"codigoGrupo":4,"nomeOcupacao":"Trabalhadores de serviços administrativos","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":6,"codigoGrupo":5,"nomeOcupacao":"Trabalhadores dos serviços, vendedores do comercio em lojas e mercados","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":7,"codigoGrupo":6,"nomeOcupacao":"Trabalhadores agropecuários, florestais e da pesca","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":8,"codigoGrupo":7,"nomeOcupacao":"Trabalhadores da produção de bens e serviços industriais","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":9,"codigoGrupo":8,"nomeOcupacao":"Trabalhadores da produção de bens e serviços industriais","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":10,"codigoGrupo":9,"nomeOcupacao":"Trabalhadores em serviços de reparação e manutenção","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":11,"codigoGrupo":0,"codigoSubgrupoPrincipal":1,"nomeOcupacao":"Membros das forcas armadas","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":12,"codigoGrupo":0,"codigoSubgrupoPrincipal":2,"nomeOcupacao":"Policiais militares","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":13,"codigoGrupo":0,"codigoSubgrupoPrincipal":3,"nomeOcupacao":"Bombeiros militares","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":14,"codigoGrupo":1,"codigoSubgrupoPrincipal":1,"nomeOcupacao":"Membros superiores e dirigentes do poder publico","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":15,"codigoGrupo":1,"codigoSubgrupoPrincipal":2,"nomeOcupacao":"Dirigentes de empresas e organizações (exceto de interesse publico)","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":16,"codigoGrupo":1,"codigoSubgrupoPrincipal":3,"nomeOcupacao":"Diretores e gerentes em empresa de serviços de saúde, da educação, ou de serviços culturais, sociais ou pessoais","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":17,"codigoGrupo":1,"codigoSubgrupoPrincipal":4,"nomeOcupacao":"Gerentes","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":18,"codigoGrupo":2,"codigoSubgrupoPrincipal":0,"nomeOcupacao":"Pesquisadores e profissionais policientificos","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":19,"codigoGrupo":2,"codigoSubgrupoPrincipal":1,"nomeOcupacao":"Profissionais das ciências exatas, físicas e da engenharia","dataAtualizacao":"2020-07-23","codigoSituacao":"A"},{"numeroOcupacao":20,"codigoGrupo":2,"codigoSubgrupoPrincipal":2,"nomeOcupacao":"Profissionais das ciências biológicas, da saúde e afins","dataAtualizacao":"2020-07-23","codigoSituacao":"A"}]}';
		//PLV 4518 Fim Fix 3
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 200, 'OK'));
		Test.startTest();

		try {
			IntegracaoBO.getInstance().executarIntegracao(Profissao__c.sObjectType.getDescribe().getName());
			
		}
		catch(Exception e) {
			
		}

		String nomeObjeto = Profissao__c.sObjectType.getDescribe().getName();
		Integracao__c integracao = [SELECT Id, Name, UltimaExecucao__c FROM Integracao__c WHERE DeveloperName__c =: nomeObjeto LIMIT 1];
		Test.stopTest();

		System.assert(integracao != null);
		System.assert(integracao.UltimaExecucao__c <= System.now());
		List<Profissao__c> dados = [SELECT Id, Name, Codigo__c, Status__c FROM Profissao__c WHERE Status__c = 'Em análise'];
	}
	//FIM | PLV-1586-29-v1
	//PLV-4878 FIM
	//PLV-4878 INICIO
	@isTest
	static void testarErroSincronizacao() {
		String responseJsonString = '{"ocupacoes": [{"numeroOcupacao": 1,"codigoGrupo": 0,"nomeOcupacao": "Membros das forcas armadas, policiais e bombeiros militares","dataAtualizacao": "2020-07-23","codigoSituacao": "A"}]}';
		
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 500, 'OK'));
		Test.startTest();

		try {
			IntegracaoBO.getInstance().executarIntegracao(Profissao__c.sObjectType.getDescribe().getName());
		}
		catch(Exception e) {
			
		}

		String nomeObjeto = Profissao__c.sObjectType.getDescribe().getName();
		Integracao__c integracao = [SELECT Id, Name, UltimaExecucao__c FROM Integracao__c WHERE DeveloperName__c =: nomeObjeto LIMIT 1];

		Test.stopTest();
	}
	//PLV-4878 FIM
}