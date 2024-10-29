//PLV-2704 - Inicio - Classe de teste para a classe ValidarOrcamentoProposta
/**
 * @author AVX - Daniel Zampieri
 * @date 2019-09-19
 * @description Classe de teste para a classe ValidarOrcamentoProposta
 */
 @isTest
public class ValidarOrcamentoPropostaTest {

    @isTest
    public static void validarExistenciaOrcamento(){

        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaExistenciaOrcamento' LIMIT 1];
        
        String payload = staticResource.Body.toString();
        
        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);

        ValidarOrcamentoProposta.validarExistenciaOrcamento(payloadTO);

    }

    @isTest
    public static void validarExistenciaOrcamentoSemNumero(){

        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaExistenciaOrcamentoSemNumero' LIMIT 1];
        
        String payload = staticResource.Body.toString();
        
        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);

        ValidarOrcamentoProposta.validarExistenciaOrcamento(payloadTO);

    }

    @isTest
    public static void validarStatusProposta(){

        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaExistenciaOrcamento' LIMIT 1];
        
        String payload = staticResource.Body.toString();
        
        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);

      

    }


}
//PLV-2704 - Fim - Classe de teste para a classe ValidarOrcamentoProposta