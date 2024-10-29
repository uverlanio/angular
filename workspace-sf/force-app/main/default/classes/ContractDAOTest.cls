/*********************************************************************************************************************************************************************
@description Classe de teste 
@author Uverlanio Mauricio 
@date 23/01/2023
@Classe criada por conta da história LECVP-72        
**********************************************************************************************************************************************************************/
//LECVP-72 - INICIO
@isTest
class ContractDAOTest {

    @TestSetup
    static void setup(){
        Account conta = gerarConta();
        Contract contrato = gerarContrato(conta);
    }

    @isTest static void buscarPorBCPTicketTest() {

        List<Contract> contratos = [SELECT Id, BCP_Ticket__c FROM Contract];
        Set<Id> idsContrato = new Set<Id>();
        Set<String> bcpTickets = new Set<String>();
        for(Contract contrato : contratos) {
            idsContrato.add(contrato.Id);
            bcpTickets.add(contrato.BCP_Ticket__c);
        }
        Test.startTest();

        List<Contract> contratosRecuperados = ContractDAO.getInstance().buscarPorBCPTicket(idsContrato, bcpTickets);
        
        System.assertEquals(contratos.size(), contratosRecuperados.size());

        Test.stopTest();        
    }

    @isTest static void testarBuscarContratos(){

        Test.startTest();

        Account conta = getContaQuery();

        Contract contrato = getContratoQuery();

        List<Contract> listaContratos = ContractDAO.getInstance().buscar(new Set<Id>{contrato.Id});

        System.assert(!listaContratos.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarBuscarPorNumPropostaUnico(){

        Test.startTest();

        Account conta = getContaQuery();

        Contract contrato = getContratoQuery();

        List<Contract> listaContratos = ContractDAO.getInstance().buscarPorNumPropostaUnico(contrato.NumeroPropostaUnico__c);

        System.assert(!listaContratos.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarBuscarPorTicket(){

        Test.startTest();

        Account conta = getContaQuery();

        Contract contrato = getContratoQuery();

        List<Contract> listaContratos = ContractDAO.getInstance().buscarPorBCPTicket(new Set<Id>{contrato.Id}, new Set<String>{contrato.BCP_Ticket__c});

        System.assert(!listaContratos.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarInserirTcktBCPContrato(){

        Test.startTest();

        String payload = '{\"chamouBCP\": true, \"mensagem\": \"Integração efetuada com sucesso\", \"origem\": \"18\", \"proposta\": "00043568", \"respostaBCP\": { \"codigo\": \"0\", \"numeroSequenciaControle\": \"1234567\"}}';
        Boolean isException = false;
        Account conta = getContaQuery();

        Contract contrato = getContratoQuery();

        BCPContratoTcktTO to = (BCPContratoTcktTO) JSON.deserialize(payload, BCPContratoTcktTO.class);

        try{
            ContractDAO.getInstance().inserirTcktBCPContrato(contrato, to);
        }catch(Exception e){
            isException = true;
        } 

        System.assert(!isException);

        Test.stopTest();
    }

    private static Account gerarConta(){
        Account conta =  new Account( 
            LastName = 'teste',
            Cnpj__c = '69979029000163',
            Sexo__c = 'MASCULINO',
            Cpf__c = '96577845069',
            Email__c = 'test@globant.com',
            PersonEmail = 'test@globant.com',
            Phone = '(11)3131-4252',
            PersonHomePhone = '(11)98563-9852',
            PersonOtherPhone = '(11)98563-9752',
            PersonMobilePhone = '(11)98563-9952',
            Fax = '(11)98563-9252',
            EstadoCivil__c = 'Casado (a)',
            PersonBirthdate = Date.today().addYears(-19),
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id
        );

        insert conta;
        
        return conta;
    }
    
    private static Contract gerarContrato(Account conta){

        Contract contrato = new Contract(
            Name = 'teste2',
            StartDate = Date.today(),
            VigenciaFinal__c = Date.today().addYears(1),
            DataEmissao__c = Date.today(),
            NumeroApolice__c = '000001834',
            NumeroProposta__c = '00001234',
            AccountId = conta.Id,
            NumeroPropostaUnico__c = '18-1234567',
            BCP_Data_Ticket__c = Datetime.now(),
            BCP_Ticket__c = '12345678'
        );

        insert contrato;

        return contrato;
    }

    private static Account getContaQuery(){
        Account conta = [
            SELECT
                Id,
                LastName,
                Email__c,
                PersonEmail,
                Cnpj__c,
                Sexo__c,
                Cpf__c,
                Phone,
                PersonHomePhone,
                PersonOtherPhone,
                PersonMobilePhone,
                Fax,
                EstadoCivil__c,
                PersonBirthdate, 
                RecordTypeId
            FROM
                Account
            LIMIT 1
        ];

        return conta;
    }

    private static Contract getContratoQuery(){
        Contract contrato = [
            SELECT 
                Id, 
                NumeroApolice__c, 
                Sucursal__c, 
                DataEmissao__c,
                Endosso__c,
                NumeroPropostaUnico__c,
                BCP_Ticket__c,
                BCP_Data_Ticket__c,
                Proposta__c
            FROM 
                Contract 
            LIMIT 1
        ];

        return contrato;
    }
}
//LECVP-72 - FIM