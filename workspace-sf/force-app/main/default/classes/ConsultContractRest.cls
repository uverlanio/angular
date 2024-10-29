/*
* Classe consulta de contratos para sistemas externos
* @author Squad Globant
* @date 24/02/23
* Classe criada por conta da história PLV-5775
*/

@RestResource(urlMapping='/evaluable-contracts')
global class ConsultContractRest {

    static final String ERROR_MESSAGE_TO_CODE_22 = 'Cliente não localizado na base';
    static final String ERROR_MESSAGE_TO_CODE_10 = 'Dados de entrada inválidos';

    static final Integer ERROR_CODE_22 = 22;
    static final Integer ERROR_CODE_10 = 10;

    ///II-76 INICIO
    private static String formatCpf(String cpf) {
        cpf = cpf.replaceAll('[^\\d]', ''); 
        return cpf.replaceAll('(\\d{3})(\\d{3})(\\d{3})(\\d{2})', '$1.$2.$3-$4'); 
    }
    ///II-76 FIM
 
    @HttpPost
    global static ContractService.Response consultarContratosLocalizados() {

        ContractService.Response response = new ContractService.Response();
        
        ContractService.Request request = (ContractService.Request) JSON.deserialize(RestContext.request.requestBody.toString(), ContractService.Request.class);
        request.cpf = String.isBlank(request.cpf) ? null : formatCpf(request.cpf); //II-76 INICIO/FIM
        request.dataNascimento = String.isBlank(request.dataNascimento) ? null : request.dataNascimento;
        
        if(request.isValid())
        {

            // PLV-5775 - FIX01 - INICIO
            // Map<Id, SeguradoContrato__c> insuredMap = ContractService.getInsuredMap(request.nome, request.cpf); 
            Map<Id, SeguradoContrato__c> insuredMap = ContractService.getInsuredMap(request.cpf);
            // PLV-5775 - FIX01 - FIM

            System.debug('insuredMap =>' + insuredMap);

            if(insuredMap.isEmpty())
            {
                response.setErrorMessage(ERROR_CODE_22, ERROR_MESSAGE_TO_CODE_22);
                return response;
            }

            Map<Id, Contract> contractMappedByInsured = new Map<Id, Contract>();
            
            for(SeguradoContrato__c sc : insuredMap.values())
            {   
                contractMappedByInsured.put(sc.Id, sc.GrupoContrato__r.ContratanteContrato__r.Contrato__r);
            }

            System.debug('contractMappedByInsured =>' + contractMappedByInsured);

            Map<Id, GarantiaContrato__c> assuranceMap = ContractService.getAssuranceMap(contractMappedByInsured, request.assistencia);

            System.debug('assuranceMap =>' + assuranceMap);

            Map<Id, GarantiaContrato__c> assuranceMappedByContract = new Map<Id, GarantiaContrato__c>();

            for(GarantiaContrato__c gc : assuranceMap.Values())
            {
                assuranceMappedByContract.put(gc.Contrato__c, gc);
            }

            Map<Id, Map<String, Sobject>> contractIndexedByAssurance = ContractService.getGrtAndCtrByInsuredMap(
                contractMappedByInsured, assuranceMappedByContract
            );

            System.debug('contractIndexedByAssurance =>' + contractIndexedByAssurance);

            response = ContractService.createResponse(insuredMap, contractIndexedByAssurance);

            System.debug('response =>' + JSON.serialize(response));


        }else
        {
            response.setErrorMessage(ERROR_CODE_10, ERROR_MESSAGE_TO_CODE_10);
            return response;
        }

        return response;
    }
}