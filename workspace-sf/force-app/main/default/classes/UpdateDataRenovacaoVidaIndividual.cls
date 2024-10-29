public class UpdateDataRenovacaoVidaIndividual implements
    Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID,                          '   +
            '       DataRenovacao__c,            '   + 
            '       StatusRenovacao__c,          '   +
            '       VigenciaFinal__c,            '   + 
            '       Produto__c                   '   +
            'FROM   Contract                     '   +
            'WHERE  Tipo__c <> \'Cancelamento\'  '   +
            'AND    Status  <> \'Cancelado\'     '   +
            'AND    Endosso__c = \'0\'           '   +
            'AND    Segmento__c = \'Individual\' '   +
            'AND    CodigoRamo__c <> \'1377\'    '
        );
    }
    public void execute(Database.BatchableContext bc, List<Contract> scope){

        if (scope.size() == 0) {
            System.debug('Nenhum Contrato encontrado para para renovação com os parâmetros informados');
            return;
        }

        // Consiterando que todo e qualquer Contrato do Segmento Individual pertencem ao mesmo Produto

        Id produtoId = scope[0].Produto__c;

        List<ParametroVigencia__c> pv = [ SELECT VigenciaMinimaRenovacao__c
                                          FROM   ParametroVigencia__c
                                          WHERE  Produto__c = :produtoId
                                          LIMIT 1 
                                        ];

        Integer subtracaoDias = Integer.valueOf(pv[0].VigenciaMinimaRenovacao__c);                                        

        if (pv.size() == 0) {
            System.debug('Não existe Parâmetro de Vigência Para o Produto em questão');
            System.debug('Id Produto : 01t5G000005mrqLQAQ' );
            return;
        }

        List<Contract> contratos = new List<Contract>();
        for (Contract contrato : scope) {
                contrato.DataRenovacao__c   = contrato.VigenciaFinal__c.addDays(-subtracaoDias);
                contrato.StatusRenovacao__c = 'Não Renovado';
                contratos.add(contrato);
                recordsProcessed = recordsProcessed + 1;
        }
        update contratos;
    }
    public void finish(Database.BatchableContext bc){
        System.debug('Total Registros Processados = ' + recordsProcessed);
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