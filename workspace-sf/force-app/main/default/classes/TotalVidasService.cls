/*
* Classe para estruturar payload de contrato para enviar à api node
* @author Squad Globant
* @date 07/03/23
* Classe criada por conta da história PLV-5776
*/

global class TotalVidasService {

    static final String CONTRACT = 'contract';
    static final String ASSURANCE = 'assurance';

    global List<ContratoTO> contratos {get; set;}

    global class ContratoTO {
        global String name {get; set;}
        global String idConta {get; set;}
        global String nomeSegurado {get; set;}
        global List<CoberturasTO> coberturas {get; set;}
        global String status {get; set;}
        global Date vigenciaInicial {get; set;}
        global Date vigenciaFinal {get; set;}
        global String tipo {get; set;}

        global Boolean isValid()
        {
            return (String.isNotBlank(this.name) && 
                    String.isNotBlank(this.tipo) && 
                    String.isNotBlank(this.idConta) && 
                    String.isNotBlank(this.nomeSegurado) && 
                    String.isNotBlank(this.status) && 
                    !this.coberturas.isEmpty() && 
                    this.vigenciaFinal != null && 
                    this.vigenciaInicial != null) 
                    ? true : false;
        }
    } 

    global class CoberturasTO {
        global String sigla { get; set; }
    }

    global static List<ContratoTO> createRequest(
        Map<Id, SeguradoContrato__c> insuredMap,
        Map<Id, Map<String, List<GarantiaContrato__c>>> assuranceAndContractByInsuredMap
    ){
        List<ContratoTO> contratos = new  List<ContratoTO>();

        for(Id insuredId : assuranceAndContractByInsuredMap.keySet())
        {
            SeguradoContrato__c insured = insuredMap?.get(insuredId);

        System.debug('insured henrique: ' + insured);
            List<GarantiaContrato__c> assurance = (List<GarantiaContrato__c>) assuranceAndContractByInsuredMap?.get(insuredId)?.get(ASSURANCE);

            List<CoberturasTO> coberturas = new List<CoberturasTO>();

            ContratoTO contractRequest = new ContratoTO();
            
            for(GarantiaContrato__c gc : assurance){

                contractRequest.name = gc.Contrato__r.IdExterno__c;
                contractRequest.tipo = gc.Contrato__r.Tipo__c;
                contractRequest.idConta = insured.Conta__c;//PLV-5776-INICIO/FIM
                contractRequest.nomeSegurado = gc.Contrato__r.Account.Name; //PLV-5776-INICIO/FIM
                contractRequest.coberturas = coberturas;
                contractRequest.status = gc.Contrato__r.Status;
                contractRequest.vigenciaInicial = gc.Contrato__r.StartDate;
                contractRequest.vigenciaFinal = gc.Contrato__r.VigenciaFinal__c;

                CoberturasTO cobertura = new CoberturasTO();
                cobertura.sigla = gc.GarantiaProduto__r.SiglaGarantia__c;

                coberturas.add(cobertura);
            }

            contratos.add(contractRequest);


            System.debug('ASSURANCE ==>' + JSON.serialize(assurance));
        }

        //ContratoTO contrato = new ContratoTO();
       // contrato = contratos;

        //System.debug('res ==>' + JSON.serialize(res));


        return contratos;
    }

    public static Map<Id, Map<String, List<GarantiaContrato__c>>> getGrtAndCtrByInsuredMap(
        Map<Id, Contract> contractMappedByInsured, Map<Id, List<GarantiaContrato__c>> assuranceMappedByContract
    ){
        Map<Id, Map<String, List<GarantiaContrato__c>>> result = new Map<Id, Map<String, List<SObject>>>();

        for(Id insuredId : contractMappedByInsured.keySet()){

            if(!result.containsKey(insuredId))
                result.put(
                    insuredId, 
                    new Map<String, List<SObject>>()
                );

            Contract contract = contractMappedByInsured.get(insuredId);

            List<GarantiaContrato__c> assurances = assuranceMappedByContract?.get(contract.Id);

            result.get(insuredId).put('assurance', assurances);
        }

        return result;
    }

    public static Map<Id, SeguradoContrato__c> getInsuredMap(Set<Id> contractsId){

        Map<Id, SeguradoContrato__c> insuredMap = new Map<Id, SeguradoContrato__c>();

        List<SeguradoContrato__c> seguradosCtr = [SELECT GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.Cpf__c
                                                        , GrupoContrato__r.ContratanteContrato__r.Contrato__r.IdExterno__c
                                                        , GrupoContrato__r.ContratanteContrato__r.Contrato__r.Status
                                                        , GrupoContrato__r.ContratanteContrato__r.Contrato__r.StartDate
                                                        , GrupoContrato__r.ContratanteContrato__r.Contrato__r.VigenciaFinal__c
                                                        , Conta__r.Cpf__c
                                                        , NomeSegurado__c 
                                                    FROM SeguradoContrato__c 
                                                    WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c IN: contractsId];

        for(SeguradoContrato__c sc : seguradosCtr){
            insuredMap.put(sc.Id, sc);
        }                                 

        return insuredMap;
    }

    public static Map<Id, GarantiaContrato__c> getAssuranceMap(Map<Id, Contract> contractMappedByInsured){

        Map<Id, GarantiaContrato__c> assuranceMap = new Map<Id, GarantiaContrato__c>();

        List<GarantiaContrato__c> garantiasContrato =[SELECT 
                                                          Capital__c
                                                        , GarantiaProduto__r.SiglaGarantia__c
                                                        , Contrato__r.Tipo__c
                                                        , Contrato__r.NumeroApolice__c
                                                        , Contrato__r.IdExterno__c
                                                        , Contrato__r.DataEmissao__c
                                                        , Contrato__r.Status
                                                        , Contrato__r.Origem__c
                                                        , Contrato__r.NumeroProposta__c
                                                        , Contrato__r.Produto__r.Name
                                                        , Contrato__r.Account.Name //PLV-5776-INICIO/FIM
                                                        , Contrato__r.StartDate
                                                        , Contrato__r.VigenciaFinal__c
                                                        , Contrato__c
                                                        FROM GarantiaContrato__c 
                                                        WHERE Contrato__c IN : new Map<Id, Contract>(contractMappedByInsured.values()).keySet()];

        for(GarantiaContrato__c gc : garantiasContrato){
            assuranceMap.put(gc.Id, gc);
        }                                 

        return assuranceMap;
    }
}