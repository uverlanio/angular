/*********************************************************************************************************************************************************************
@description Controller responsável por reenvio das contratos não sincronizadas para a BCP.
@author Fernando Rodrigues Ribeiro Martins - Globant
@date 23/01/2023
**********************************************************************************************************************************************************************/
// LECVP-72 - Inicio
public class BtnEnviarContractBCPController
{
    @TestVisible
    private static final String mensagemSucesso = 'Requisição de envio de contratos executado com sucesso!';
    @TestVisible
    private static final String mensagemAviso = 'Já existe um processo de envio em andamento. Tente novamente mais tarde.';
    
    @AuraEnabled
    public static String enviarContractBCP()
    {
        BtnEnviarContractBCPController.Resposta resposta = null;
        try
        {
            List<AsyncApexJob> trabalhos = AsyncApexJobDao.getInstancia().buscarClasses(
                new Set<String> { 'BatchReenvioContratoBCP' }
            );
            if(trabalhos.isEmpty())
            {
                Database.executeBatch(new BatchReenvioContratoBCP(), 30);
                resposta = gerarResposta(mensagemSucesso, true);
            } else
            {
                resposta = gerarResposta(mensagemAviso, false);
            }
        } catch (Exception e)
        {
            resposta = gerarErro(e);
        }
        return JSON.serialize(resposta);
    }

    @TestVisible
    private static BtnEnviarContractBCPController.Resposta gerarResposta(String message, Boolean sucesso)
    {
        BtnEnviarContractBCPController.Resposta resposta = new BtnEnviarContractBCPController.Resposta();
        resposta.message = message;
        resposta.sucesso = sucesso;
        return resposta;
    }

    @TestVisible
    private static BtnEnviarContractBCPController.Resposta gerarErro(Exception e)
    {
        String message = String.format(
            '({0}) {1}: {2}', new String[] {
                String.valueOf(e.getLineNumber()), e.getTypeName(), e.getMessage()
            } 
        );
        System.debug(
            System.LoggingLevel.ERROR,
            String.format(
                '{0}}\n Stacktrace: {1}',
                new String[] { message, e.getStackTraceString() }
            )
        );
        BtnEnviarContractBCPController.Resposta resposta = gerarResposta(message, false);
        return resposta;
    }

    public class Resposta {
        public String message;
        public Boolean sucesso = false;
    }
}
// LECVP-72 - Fim