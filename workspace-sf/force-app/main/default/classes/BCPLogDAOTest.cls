/*********************************************************************************************************************************************************************
@description Classe de teste do obejto de log BCP
@author Uverlanio Silva - Globant
@date 23/01/2023
**********************************************************************************************************************************************************************/
//LECVP-72 - INICIO
@isTest
public class BCPLogDAOTest {
    
    @isTest static void testarBuscarLogsBCPPorId(){

        Test.startTest();

        Set<Id> idsLogs = new Set<Id>();
        Account conta = gerarConta();
        Contract contrato = gerarContrato(conta);
        gerarBCPLog(contrato);

        List<BCP_Log__c> logsBCP = [SELECT Id FROM BCP_Log__c];
        for(BCP_Log__c log : logsBCP){
            idsLogs.add(log.Id);
        }

        List<BCP_Log__c> logsBCPRetorno = BCPLogDAO.getInstance().buscarLogsBCPPorId(idsLogs);

        System.assert(!logsBCPRetorno.isEmpty());

        Test.stopTest();
    }
    @isTest static void testarBuscarLogsBCPPorIdCtr(){

        Test.startTest();
    
        Set<Id> idsContrato = new Set<Id>();
    
        for(Contract contrato : listaContratos()){
            gerarBCPLog(contrato);
            idsContrato.add(contrato.Id);
        }

        List<BCP_Log__c> logsBCP = BCPLogDAO.getInstance().buscarLogsBCPPorIdCtr(idsContrato);

        System.assert(!logsBCP.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarGerarLogBCPErroAPI(){

        Test.startTest();

        Boolean isException = false;
    
        try{
            BCPLogDAO.getInstance().gerarLogBCPErroAPI('Erro');
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();
    }

    @isTest static void testarAtualizarLogBCPAPI(){

        Test.startTest();

        Boolean isException = false;

        Account conta = gerarConta();
        Contract contrato = gerarContrato(conta);
        gerarBCPLog(contrato);
    
        try{
            BCPLogDAO.getInstance().atualizarLogBCPAPI(contrato, 'Erro');
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();
    }


    private static List<Contract> listaContratos(){
        List<Contract> listaContratos = new  List<Contract>();
        listaContratos.add(gerarContrato(gerarConta()));

        return listaContratos;
    }

    private static Account gerarConta(){
        Account conta = new Account(
            Name = 'teste',
            Cnpj__c = '80736373000164'
        );
        
        insert conta;

        return conta;
    }

    private static Contract gerarContrato(Account conta){
        Contract contrato = new Contract();
            
        contrato = new Contract(
            Name = 'teste',
            AccountId = conta.Id,
            BCP_Ticket__c = '12345678'
        );

        insert contrato;

        return contrato;
    }

    private static void gerarBCPLog(Contract contrato){
        BCP_Log__c log = new BCP_Log__c();

        log.BCP_Contrato__c = contrato.Id;
        log.BCP_DataHoraEnvio__c = Datetime.now();
        log.BCP_DataHoraRetorno__c = Datetime.now().addMinutes(2);

       insert log;
    }
}
//LECVP-72 - FIM