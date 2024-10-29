/*******************************************************************************************************************************
* Classe service para consulta de contratos para a atualização de data de cobertura
* @author Squad ICloud
* @date 18/03/2022
* Classe criada por conta da história PLV-5346
******************************************************************************************************************************/

public class DataCoberturaService {    

    public static List<ContratanteContrato__c> getContracts(DataCoberturaRest.Request request){        
        List<ContratanteContrato__c> lstContratos = [ 
            SELECT Contrato__r.Id, Contrato__r.VigenciaFinal__c, Contrato__r.NumeroPropostaUnico__c, 
            ResponsavelPagamento__r.Id, ResponsavelPagamento__r.Cpf__c, ResponsavelPagamento__r.Cnpj__c 
            FROM ContratanteContrato__c 
            WHERE Contrato__r.Id = :request.ids
        ];              

        return lstContratos;
    }   
}