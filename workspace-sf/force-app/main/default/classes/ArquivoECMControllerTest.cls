/**
 * Classe de teste criada porque a Evermind não criou e impactou a PLV-3285 
 */
@isTest
public with sharing class ArquivoECMControllerTest {
    
    @isTest
    public static void consultarArquivoECM(){
        
        ContratoTO.ConsultarArquivoECMTO consultaTO = new ContratoTO.ConsultarArquivoECMTO();
        consultaTO.idsf = 'teste';
        //PLV-3285 - INICIO
        consultaTO.dataInicial = String.valueOf(Date.today());//'2020-02-20';
        consultaTO.dataFinal = String.valueOf(Date.today());//'2020-02-20';
		//PLV-3285 - FIM
        HerokuResponseTO.ArquivoECMTO returnTO = new HerokuResponseTO.ArquivoECMTO();
        returnTO.data = new List<HerokuResponseTO.ArquivoECMTODetalhe>();
        HerokuResponseTO.ArquivoECMTODetalhe arquivo = new HerokuResponseTO.ArquivoECMTODetalhe();
        arquivo.id = 1;
        arquivo.idecm = '1';
        arquivo.datainclusao = System.now();
        arquivo.nomearquivo = 'teste';
        //arquivo.idsf = '1';
        returnTO.data.add(arquivo);
        String payloadReturn = JSON.serialize(returnTO);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));

        String retornoECM = ArquivoECMController.consultarArquivoECM(JSON.serialize(consultaTO));

        System.assertEquals(payloadReturn, retornoECM, 'Retorno do serviço diferente do esperado');
    }

    @isTest
    public static void buscaIdECM(){

        EcmService.RetornoDocumentoIdEntradaTO returnTO = new EcmService.RetornoDocumentoIdEntradaTO();
        returnTO.id = '1';
        String payloadReturn = JSON.serialize(returnTO);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));

        String idRetornoECM = ArquivoECMController.buscaIdECM('1_2_3_4_5');

        System.assertEquals(returnTO.id, idRetornoECM, 'Retorno do serviço diferente do esperado');
    }

    @isTest
    public static void buscarDominioSf(){

        String dominio = ArquivoECMController.buscarDominioSf();

        System.assert(dominio.contains('force.com'), 'Dominio não esperado');
    }
}