/*********************************************************************************************************************************************************************

@description  Facade de teste.
@author Uverlanio Mauricio
@date 23/01/2023
@Classe criada por conta da história LECVP-72
        
**********************************************************************************************************************************************************************/
//LECVP-72 - INICIO
@isTest
private class ContratoTcktFacadeTest {

    @TestSetup
    static void makeData(){
        Account conta = gerarConta();
        Contract contrato = gerarContrato(conta);
    }

    @isTest static void testarInserirTicket(){

        Test.startTest();        

        String retorno = ContratoTcktFacade.getInstance().inserirTicket(gerarDados());
        
        Test.stopTest();

        System.assertEquals('{"status" : "ok"}', retorno);
    }

    @isTest static void testarInserirTicketSemPropostaSemTicket(){

        Test.startTest();

        String retorno = ContratoTcktFacade.getInstance().inserirTicket(gerarComDadosFaltantes());

        Test.stopTest();

        System.assertEquals('{"status" : "nok"}', retorno);
    }

    @isTest static void testarBuscarContratoPorNumeroDaProposta(){

        String numeroProposta = '18-00001234';

        Test.startTest();

        Opportunity orcamento = new Opportunity(
            Name = 'teste',
            StageName = 'Em criação',
            CloseDate = Date.today()
        );

        insert orcamento;

        Quote proposta = new Quote(
            Name = 'teste',
            NumeroProposta__c = '00001234',
            OpportunityId = orcamento.Id
        );

        insert proposta;

        Contract contrato = ContractDAO.getInstance().buscarPorNumPropostaUnico(numeroProposta)[0];
        
        System.assertNotEquals(null, contrato);

        Test.stopTest();
    }

    @isTest static void testarInserirContratoTcktFacadeException(){

        Test.startTest();

        BCPContratoTcktTO bCPContratoTcktTO = gerarDados();
        bCPContratoTcktTO.proposta = '123456789';

        Boolean isException = false;

        try{
            ContratoTcktFacade.getInstance().inserirTicket(bCPContratoTcktTO);
        }catch(ContratoTcktFacade.ContratoTcktFacadeException e){
            isException = true;
        }

        Test.stopTest();

        System.assert(isException);
    }

    public static BCPContratoTcktTO gerarDados(){

        BCPContratoTcktTO contratoTckt = new BCPContratoTcktTO();
        BCPContratoTcktTO.RespostaBCP respostaBCP = new BCPContratoTcktTO.RespostaBCP();

        contratoTckt.origem = '18';
        contratoTckt.proposta = '00001234';
        contratoTckt.mensagem = 'a';

        respostaBCP.numeroSequenciaControle = '1234567';
        respostaBCP.codigo = '0';
       
        contratoTckt.respostaBCP = respostaBCP;

        return contratoTckt;
    }

    public static BCPContratoTcktTO gerarComDadosFaltantes(){

        BCPContratoTcktTO contratoTckt = new BCPContratoTcktTO();
        BCPContratoTcktTO.RespostaBCP respostaBCP = new BCPContratoTcktTO.RespostaBCP();
        
        contratoTckt.origem = '18';
        contratoTckt.proposta = '';
        contratoTckt.mensagem = 'a';
        
        respostaBCP.numeroSequenciaControle = '';
        respostaBCP.codigo = '0';
        
        contratoTckt.respostaBCP = respostaBCP;

        return contratoTckt;
    }

    private static Account gerarConta(){
        
        Account conta =  new Account( 
            LastName = 'teste',
            Cnpj__c = '69979029000163',
            Sexo__c = 'MASCULINO'
        );

        insert conta;

        return conta;
    }

    private static Contract gerarContrato(Account conta){

        Contract contrato = new Contract(
            Name = 'teste2',
            AccountId = conta.Id,
            NumeroProposta__c = '00001234',
            NumeroPropostaUnico__c = '18-00001234'
        );

        insert contrato;

        return contrato;
    }
}
//LECVP-72 - FIM