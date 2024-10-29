//PLV-2704 - Inicio - Classe criada para validação do Orçamento no Serviço de Proposta
/**
 * @author AVX - Daniel Zampieri
 * @date 2019-09-19
 * @description Validação do Orçamento no Serviço de Proposta
 */
public class ValidarOrcamentoProposta {

    public static List<RetornoPropostaRestTO.DevolutivasTO> validarExistenciaOrcamento(EmissaoTO.PayloadTO payloadTO){
        List<RetornoPropostaRestTO.DevolutivasTO> lDevolutivas = new List<RetornoPropostaRestTO.DevolutivasTO>();
        
        if(String.isEmpty(payloadTO.proposta.numeroOrcamento)){
            RetornoPropostaRestTO.DevolutivasTO devolutiva = new RetornoPropostaRestTO.DevolutivasTO();
            devolutiva.codigo = -2; 
            //PLV-2948 - Inicio - Adição de ponto final
            devolutiva.descricao = 'Sem número Orçamento.';
            //PLV-2948 - Fim - Adição de ponto final
            lDevolutivas.add(devolutiva);
            return lDevolutivas;
        }

        Integer qtdOrcamentos = [SELECT COUNT() 
                                 FROM Opportunity 
                                 WHERE Numero__c = :payloadTO.proposta.numeroOrcamento 
                                 AND StageName = 'Disponível para Contratação'];

        if(qtdOrcamentos > 0) return null;

        RetornoPropostaRestTO.DevolutivasTO devolutiva = new RetornoPropostaRestTO.DevolutivasTO();
        devolutiva.codigo = -2;
        //PLV-2948 - Inicio - Adição de ponto final
        devolutiva.descricao = 'O orçamento não está disponível para contratação.';
        //PLV-2948 - Fim - Adição de ponto final
        lDevolutivas.add(devolutiva);

        return lDevolutivas;
    }


}
//PLV-2704 - Fim - Classe criada para validação do Orçamento no Serviço de Proposta