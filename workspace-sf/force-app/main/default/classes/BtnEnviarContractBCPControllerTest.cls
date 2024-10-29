/*********************************************************************************************************************************************************************
@description Classe de teste de controller responsável por reenvio dos contratos.
@author Fernando Rodrigues Ribeiro Martins - Globant
@date 23/01/2023
**********************************************************************************************************************************************************************/
// LECVP-72 - Inicio
@isTest
class BtnEnviarContractBCPControllerTest {
    @isTest
    static void gerarRespostaTest()
    {
        String mensagem = 'Teste';
        Boolean sucesso = false;
        Test.startTest();
        BtnEnviarContractBCPController.Resposta resposta = BtnEnviarContractBCPController.gerarResposta(mensagem, sucesso);
        Test.stopTest();
        System.assert(mensagem.equals(resposta?.message));
        System.assert(sucesso == resposta?.sucesso);
    }

    @isTest
    static void gerarErroTest()
    {
        String mensagemTeste = 'gerarErroTest';
        try
        {
            throw new BtnEnvContractBCPCntrlTestException(mensagemTeste);
        } catch(Exception e)
        {
            BtnEnviarContractBCPController.Resposta resposta = BtnEnviarContractBCPController.gerarErro(e);
            System.assert(resposta?.message?.contains(mensagemTeste));
            System.assert(resposta?.sucesso == false);

        }
    }

    @isTest
    static void enviarContractBCPTest()
    {
        Test.startTest();
        String respostaJSON1 = BtnEnviarContractBCPController.enviarContractBCP();
        String respostaJSON2 = BtnEnviarContractBCPController.enviarContractBCP();
        Test.stopTest();
        BtnEnviarContractBCPController.Resposta resposta1 = (BtnEnviarContractBCPController.Resposta) JSON.deserialize(
            respostaJSON1, BtnEnviarContractBCPController.Resposta.class
        );
        BtnEnviarContractBCPController.Resposta resposta2 = (BtnEnviarContractBCPController.Resposta) JSON.deserialize(
            respostaJSON2, BtnEnviarContractBCPController.Resposta.class
        );
        System.assert(resposta1?.sucesso);
        System.debug(resposta2);
    }

    class BtnEnvContractBCPCntrlTestException extends Exception {}
}
// LECVP-72 - Fim