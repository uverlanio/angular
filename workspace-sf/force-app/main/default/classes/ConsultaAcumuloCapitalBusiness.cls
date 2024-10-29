public class ConsultaAcumuloCapitalBusiness {
    //PLV-4503 INICIO

    //++++++++++++++++++++++++
    // PUBLIC STATIC METHODS
    //++++++++++++++++++++++++

    /**
     * Retorna Response de ConsultaAcumuloCapitalRest contendo os acumulos de capital das coberturas das apolices
     * @param  cpf              Cpf da Conta das Apolices das Garantias de Contrato(coberturas)
     * @param  coberturasLegado Objetos com os acumulos das coberturas do sistema legado, agrupados pela Sigla da cobertura
     * @return                  Objeto ConsultaAcumuloCapitalRest.Response com os valores acumulados das coberturas do Legado + Salesforce
     */
    // public static ConsultaAcumuloCapitalRest.Response getAcumuloCapitalCoberturasByCpf(String cpf, List<ConsultaAcumuloCapitalRest.Cobertura> coberturasLegado) {
        public static ConsultaAcumuloCapitalRest.Response getAcumuloCapitalCoberturasByCpf(ConsultaAcumuloCapitalRest.Request req) {
            
        ConsultaAcumuloCapitalRest.Response res = new ConsultaAcumuloCapitalRest.Response();
        res.coberturas = new List<ConsultaAcumuloCapitalRest.Cobertura>();
        Map<String, Double> coberturasAcumuloMap = new Map<String, Double>();

        //CIV envia CPF sem formatação, formatar XXX.XXX.XXX-XX
        String cpf = Util.imprimeCPF(req.cpf);

        System.debug('ConsultaAcumuloCapitalBusiness :: getAcumuloCapitalCoberturasByCpf : cpf : ' + cpf);
        System.debug('ConsultaAcumuloCapitalBusiness :: getAcumuloCapitalCoberturasByCpf : coberturasLegado : ' + JSON.serializePretty(req.coberturasLegado, true));
        System.debug('ConsultaAcumuloCapitalBusiness :: getAcumuloCapitalCoberturasByCpf : coberturasPortal : ' + JSON.serializePretty(req.coberturasPortal, true));
        System.debug('ConsultaAcumuloCapital SalesForce '+ getGarantiasByCpf(cpf));

        somaAcumulo(coberturasAcumuloMap, req.coberturasLegado);
        somaAcumulo(coberturasAcumuloMap, req.coberturasPortal); 
        somaAcumulo(coberturasAcumuloMap, getGarantiasByCpf(cpf)); 

        //!* Monta Resposta com acumulos do mapa
        if (coberturasAcumuloMap.size() > 0) {

            for (String key : coberturasAcumuloMap.keySet()) {
                ConsultaAcumuloCapitalRest.Cobertura cobertura = new ConsultaAcumuloCapitalRest.Cobertura();
                cobertura.sigla = key;
                cobertura.valor = coberturasAcumuloMap.get(key);

                res.coberturas.add(cobertura);
            }

            System.debug('ConsultaAcumuloCapitalBusiness :: getAcumuloCapitalCoberturasByCpf : res.coberturas : ' + JSON.serializePretty(res.coberturas, true));
        }

        return res;
    }

    //++++++++++++++++++++++++
    // PRIVATE METHODS
    //++++++++++++++++++++++++

    private static void somaAcumulo(Map<String, Double> coberturasAcumuloMap, List<ConsultaAcumuloCapitalRest.Cobertura> coberturas) {
        
        if (coberturas != null && coberturas.size() > 0) {

            for (ConsultaAcumuloCapitalRest.Cobertura cobertura : coberturas) {
                if (coberturasAcumuloMap.containsKey(cobertura.sigla)) {
                    coberturasAcumuloMap.put(cobertura.sigla, coberturasAcumuloMap.get(cobertura.sigla) + cobertura.valor);
                }
                else {
                    coberturasAcumuloMap.put(cobertura.sigla, cobertura.valor);
                } 
            }   
        }
    }

    private static void somaAcumulo(Map<String, Double> coberturasAcumuloMap, List<GarantiaContrato__c> coberturas) {
        
        if (coberturas != null && coberturas.size() > 0) {

            for (GarantiaContrato__c cobertura : coberturas) {

                if (coberturasAcumuloMap.containsKey(cobertura.Garantia__r.Sigla__c)) {
                    coberturasAcumuloMap.put(cobertura.Garantia__r.Sigla__c, coberturasAcumuloMap.get(cobertura.Garantia__r.Sigla__c) + cobertura.Capital__c);
                }
                else {
                    coberturasAcumuloMap.put(cobertura.Garantia__r.Sigla__c, cobertura.Capital__c);
                } 
            }
        }
    }

    private static List<GarantiaContrato__c> getGarantiasByCpf(String cpf) {
		// PLV-4923 INICIO
        Date hoje = System.today();

        list<GarantiaContrato__c> lstResponse = [
            SELECT 
                Id,
                Capital__c,
                Garantia__r.Sigla__c,
                Contrato__r.VigenciaFinal__c,
                Contrato__r.StartDate
            FROM GarantiaContrato__c
            WHERE 
                Contrato__r.Account.Cpf__c =: cpf
                AND Garantia__c <> NULL
                AND Capital__c <> NULL
                AND TipoGarantia__c = 'Cobertura'
                AND Contrato__r.VigenciaFinal__c >=: hoje
                AND Contrato__r.StartDate <=: hoje
                AND Status_do_Contrato__c = 'Emitido'
            ORDER BY Garantia__r.Sigla__c
            LIMIT 50000
        ];   
         
        return lstResponse;
        // PLV-4923 FIM
    }

    //PLV-4503 FIM
}