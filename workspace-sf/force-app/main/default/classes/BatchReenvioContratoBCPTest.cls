/*********************************************************************************************************************************************************************
@description Classe de teste da batch responsável por reenvio dos contratos.
@author Uverlanio Silva - Globant
@date 23/01/2023
**********************************************************************************************************************************************************************/
//LECVP-72 - INICIO
@isTest
private class BatchReenvioContratoBCPTest {

    @isTest static void testarExecucaoBatch(){

        Test.startTest();

        Boolean isException = false;

        Account conta = gerarConta();
        insert conta;

        Contract contrato = gerarContrato(conta);
        insert contrato;

        Integer qtde = 199;

        gerarListaBCPLog(contrato, qtde);

        try{
            Database.executeBatch(new BatchReenvioContratoBCP());
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();        
    }
    
    @isTest static void testarSchedulable(){

        Test.startTest();

        Boolean isException = false;

        Account conta = gerarConta();        
        insert conta;

        Contract contrato = gerarContrato(conta);
        insert contrato;

        BCP_Log__c log = gerarBCPLog(contrato);
        insert log;

        BatchReenvioContratoBCP batch = new BatchReenvioContratoBCP();

        try{
            System.schedule('BCPTcktContratoJob', '0 7 11 * * ?', batch);
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();        
    }

    @isTest static void testarSchedulableAsyncException(){

        Test.startTest();

        Account conta = gerarConta();
        
        insert conta;

        Contract contrato = gerarContrato(conta);

        insert contrato;

        BCP_Log__c log = gerarBCPLog(contrato);

        insert log;

        BatchReenvioContratoBCP batch = new BatchReenvioContratoBCP();
        Boolean isException = false;
        
        try{
            System.schedule('BCPTcktContratoJob', '0 7 11 24 2 ? 2023', batch);
        }catch(AsyncException ae){
            isException = true;
        }

        System.assertEquals(true, isException);

        Test.stopTest();        
    }

    @isTest static void testarVerificarContratoPossuiTckt(){

        Test.startTest();

        Boolean isException = false;

        BatchReenvioContratoBCP batch = new BatchReenvioContratoBCP();
    
        Account conta = gerarConta();
        
        insert conta;

        Contract contrato = gerarContrato(conta);
        contrato.BCP_Ticket__c = '';

        insert contrato;

        try{
            batch.verificarContratoPossuiTckt(contrato);
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();
    }

    @isTest static void testarReenviarPayloadSemTckt(){

        Test.startTest();

        Boolean isException = false;

        Account conta = gerarConta();
        insert conta;

        Contract contrato = gerarContrato(conta);
        contrato.BCP_Ticket__c = '';

        insert contrato;

        Quote proposta = gerarProposta();
        insert proposta;

        contrato.Proposta__c = proposta.Id;
        contrato.BCP_Ticket__c = '';

        update contrato;

        List<BCP_Log__c> logs = new List<BCP_Log__c>();
        logs.add(gerarBCPLog(contrato));

        insert logs;

        BatchReenvioContratoBCP batch = new BatchReenvioContratoBCP();
        List<AsyncApexJob> jobs = new List<AsyncApexJob>();

        try{
            batch.reenviarPayloadSemTckt(logs, jobs);
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();
    }

    @isTest static void testarReenviarPayloadSemTcktSemLogs(){
        
        Test.startTest();

        Boolean isException = false;

        Account conta = gerarConta(); 

        insert conta;

        Contract contrato = gerarContrato(conta);

        insert contrato;

        Quote proposta = gerarProposta();

        insert proposta;

        contrato.Proposta__c = proposta.Id;
        contrato.BCP_Ticket__c = '';

        update contrato;

        List<BCP_Log__c> logs = new List<BCP_Log__c>();

        insert logs;

        BatchReenvioContratoBCP batch = new BatchReenvioContratoBCP();
        List<AsyncApexJob> jobs = new List<AsyncApexJob>();

        try{
            batch.reenviarPayloadSemTckt(logs, jobs);
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();
    }

    @isTest static void testarReenviarPayloadSemContrato(){

        Test.startTest();

        Boolean isException = false;

        List<BCP_Log__c> logs = new List<BCP_Log__c>();

        insert logs;

        BatchReenvioContratoBCP batch = new BatchReenvioContratoBCP();
        List<AsyncApexJob> jobs = new List<AsyncApexJob>();

        try{
            batch.reenviarPayloadSemTckt(logs, jobs);
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();
    }

    private static Quote gerarProposta(){
        
        Opportunity orcamento = gerarOrcamento();

        insert orcamento;

        Quote proposta = new Quote(
            Name = 'teste',
            NumeroProposta__c = '00046257',
            OpportunityId = orcamento.Id
        );

        return proposta;
    }

    private static Account gerarConta(){
        Account conta = new Account(
            Name = 'teste',
            Cnpj__c = '80736373000164'
        );
        
        return conta;
    }

    private static Contract gerarContrato(Account conta){
        Contract contrato = new Contract();
            
        contrato = new Contract(
            Name = 'teste',
            AccountId = conta.Id,
            BCP_Ticket__c = '12345678'
        );

        return contrato;
    }

    private static BCP_Log__c gerarBCPLog(Contract contrato){
        BCP_Log__c log = new BCP_Log__c();

        log.BCP_Contrato__c = contrato.Id;
        log.BCP_DataHoraEnvio__c = Datetime.now().addDays(-7);

        return log;
    }

    private static Opportunity gerarOrcamento(){

        Opportunity orcamento = new Opportunity(
            Name = 'teste',
            StageName = 'Em criação',
            CloseDate = Date.today()
        );

        return orcamento;
    }

    private static List<BCP_Log__c> gerarListaBCPLog(Contract contrato, Integer qtde){
        List<BCP_Log__c> listaBCPLog = new List<BCP_Log__c>();
        BCP_Log__c log = new BCP_Log__c();

        for(Integer i = 0; i <= qtde; i++){
            log = new BCP_Log__c(
                BCP_Contrato__c = contrato.Id,
                BCP_DataHoraEnvio__c = Datetime.now()
            );
            listaBCPLog.add(log);
        }
        
        insert listaBCPLog;

        return listaBCPLog;           
    }
}
//LECVP-72 - FIM