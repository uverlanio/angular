@isTest
public with sharing class ProposalPdfGeneratorTest {

    @isTest
    static void testGerarPDFPropostaSync() {

        Account contaTeste = new Account(
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
			LastName = 'Teste',
			Nacionalidade__c = 'Brasileira',
			CPF__c = '00478394659',
			Rg__c = '232323231',
			DataExpedicao__c = Date.today(),
			OrgaoExpedidor__c = '123132',
			PersonBirthDate = (Date.today()-7300),
			EstadoCivil__c = 'Solteiro (a)',
            PersonEmail = 'abc@portoseguro.com.br'
		);
		insert contaTeste;


        Contract contrato = new Contract(
            Name = 'Contrato de Teste',
            NumeroPropostaUnico__c = '123',
            AccountId = contaTeste.Id
        );
        insert contrato;

        List<Id> contractIdList = new List<Id>{contrato.Id};
        Test.startTest();
        ProposalPdfGenerator.gerarPDFPropostaSync(contractIdList);
        Test.stopTest();

        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];
        List<ControleIntegracao__c> controleIntegracoes = [SELECT Id FROM ControleIntegracao__c];

        System.assertEquals(1, contentVersions.size(), 'Deveria ter sido criada uma ContentVersion');
        System.assertEquals(1, controleIntegracoes.size(), 'Deveria ter sido criada uma ControleIntegracao__c');
    }
}