/*********************************************************************************************************************************************************************

@description  Clase criada para testar metodos de limpeza
@author Pedro Augusto Braz - SYS4B
@date 22/03/2021
        
**********************************************************************************************************************************************************************/

@isTest
public class LimparUsuarioTest {
    @isTest
	static void LimparUsuarioComponenteInit() {
        Account contaTeste = TestDataFactory.gerarConta();
        ContentVersion file = new ContentVersion(
            Title = 'Proposta-TESTE',
            VersionData = Blob.valueOf('TEST'), 
            PathOnClient = 'Proposta-TESTE.pdf',
            origin = 'H'
        );

        insert file;

        file = [Select id, ContentDocumentId FROM ContentVersion WHERE Id =: file.Id];

        ContentDocumentLink fileLink = new ContentDocumentLink(
            LinkedEntityId = contaTeste.Id,
            ContentDocumentId = file.ContentDocumentId,
            ShareType = 'V'
        );

        insert fileLink;
        Map<String,Object> init = LimparUsuario.Inicializar();
        Map<String,Object> apagar = LimparUsuario.apagarItens(JSON.serialize(init));
    }
    
    @isTest
	static void LimparUsuarioInit() {
        Account contaTeste = TestDataFactory.gerarConta();
        LimparUsuario.iniciar(10,true,true,false);
        LimparUsuario.iniciar(10,true,true,true);
    }
}