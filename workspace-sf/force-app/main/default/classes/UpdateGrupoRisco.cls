public class UpdateGrupoRisco implements
    Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    public Integer registrosLidos = 0;
    public Integer registrosProcessados = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r.NumeroProposta__c, Id, GrupoRisco__c ' +                                                                       +
            'FROM   SeguradoContrato__c '                                                                                  +
            'WHERE  GrupoContrato__r.ContratanteContrato__r.Contrato__r.Segmento__c = \'Individual\''
        );
    }
    public void execute(Database.BatchableContext bc, List<SeguradoContrato__c> scope){
        if (scope.size() == 0) {
            System.debug('Nenhum SeguradoContrato__c encontrado com os parâmetros informados');
            return;
        }

        Map<String, String> mapSeguradosContratos = new Map<String, String>();
        String numeroProposta;

        for (SeguradoContrato__c segCont : scope) {
            // numeroProposta = (String)segCont.getSobject('GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r').get('NumeroProposta__c');
            numeroProposta = segCont.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r.NumeroProposta__c;
            mapSeguradosContratos.put(numeroProposta, segCont.Id);
            registrosLidos = registrosLidos + 1;
        }
        Set<String> propostas = mapSeguradosContratos.keySet();
        List<SeguradoProposta__c> listSeguradosPropostas = [ SELECT GrupoProposta__r.ContratanteProposta__r.Proposta__r.NumeroProposta__c,
                                                                    GrupoRisco__c
                                                             FROM   SeguradoProposta__c
                                                             WHERE  GrupoProposta__r.ContratanteProposta__r.Proposta__r.NumeroProposta__c 
                                                             IN     :propostas
                                                           ];
        if (listSeguradosPropostas.size() == 0) {
            System.debug('Nenhum SeguradoProposta__c encontrado com os Ids referentes a Proposta__c buscados via SeguradoContrato__c');
            return;
        }

        Map<String, String> mapSeguradosPropostas = new Map<String, String>();
        for (SeguradoProposta__c segProp : listSeguradosPropostas) {
            //numeroProposta = (String)segProp.getSobject('GrupoProposta__r.ContratanteProposta__r.Proposta__r').get('NumeroProposta__c');
            numeroProposta = segProp.GrupoProposta__r.ContratanteProposta__r.Proposta__r.NumeroProposta__c;
            mapSeguradosPropostas.put(numeroProposta, segProp.GrupoRisco__c);
        }
        for (SeguradoContrato__c segCont : scope) {
            //numeroProposta = (String)segCont.getSobject('GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r').get('NumeroProposta__c');
            numeroProposta = segCont.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r.NumeroProposta__c;
            if (mapSeguradosContratos.get(numeroProposta) == null) {
                System.debug('Não Encontrado um ID de Segurado Contrato Para um Id de Proposta armazenado no mapSeguradosContratos');
                System.debug('Número Proposta = ' + numeroProposta);
                return;
            }
            if (segCont.Id == mapSeguradosContratos.get(numeroProposta)) {
                segCont.GrupoRisco__c = mapSeguradosPropostas.get(numeroProposta);
                registrosProcessados = registrosProcessados + 1;
            } else {
                System.debug('ID Segurado Contrato armazenado não corresponde ao Número da Proposta');
                System.debug('ID Segurado Contrato = ' + segCont.Id);
                return;
            }   
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc){
        System.debug('Total Registros Lidos = ' + registrosLidos);
        System.debug('Total Registros `Processados = ' + registrosProcessados);
        if(registrosLidos == 0 || registrosProcessados == 0) {
            System.debug('Processamento Não Realizado com Sucesso');
            return;
        }
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        System.debug('Id Job AsyncApexJob = ' + job.Id);
        System.debug('Status Job AsyncApexJob = ' + job.Status);
        System.debug('Numero Erros Job AsyncApexJob = ' + job.NumberOfErrors);
    }
}