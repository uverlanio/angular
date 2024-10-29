/**
 * Created by Alessndro Ponte on 18/07/2019.
 */

// PLV-23132 INICIO
@IsTest
public with sharing class HerokuLogsTriggerHandlerTest {

    @IsTest
    public static void testHerokuLogs(){

        String mockGeracaoLog = '{"data": "18:10:20","objeto": "string","idregistro": "string","codigointegracao": "string","codigoerro": "string","descricaoerro": "string","status": "ERRO","id": 153}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockGeracaoLog, 200, 'OK'));


        // Publicando um evento para test
        HerokuLogs__e herokuLogs = new HerokuLogs__e(
                Descricao__c = 'Mensagem do erro',
                Data__c = Datetime.now(),
                Objeto__c = 'NomeObjeto',
                IdRegistro__c = 'ChaveIdentificadora',
                CodigoIntegracao__c = 'AtualizarSistemasExternos',
                CodigoErro__c = 'CodigoErro',
                Status__c = 'ERRO'
        );
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(herokuLogs);
        // Entregue a mensagem do evento inicial.
        // Isso irá disparar o acionador de evento associado.
        Test.getEventBus().deliver();
        Test.stopTest();

        System.assertEquals(true,sr.isSuccess());

        // recupera todas as informacoes do evento
        EventBusSubscriber[] assinantes =
        [
                SELECT
                        Name,
                        Type,
                        Position,
                        Retries,
                        LastError
                FROM
                        EventBusSubscriber
                WHERE
                        Topic='HerokuLogs__e'
        ];

        for (EventBusSubscriber ass : assinantes) {
            System.debug('Assinante ' + ass);
            // Verifica se somente a trigger eh a assinante do evento
            System.assertEquals('HerokuLogsTrigger',ass.Name);
        }
    }
}
// PLV-23132 FIM