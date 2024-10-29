//LECVP-212 - INICIO
@isTest 
private class PagamentoSinistroDAOTest {
   
    @TestSetup
    static void makeData(){
        Account conta = gerarConta();
        Case casoAtendimento = gerarCasoAtendimento(conta);
        Case casoSinistro = gerarCasoSinistro(casoAtendimento, conta);        
        gerarPagamentoSinistro(casoSinistro);
    }

    @isTest static void testarBuscarPgtoSinistro(){

        Test.startTest();

        Pagamento_de_Sinistro__c ps = getQueryPagamentoSinistro();

        Pagamento_de_Sinistro__c retorno = PagamentoSinistroDAO.getInstance().buscar(new Set<Id>{ps.Id});

        System.assert(retorno.Name != null);

        Test.stopTest();
    }

    private static Account gerarConta(){
        
        Account conta =  new Account( 
            LastName = 'teste',
            Cnpj__c = '69979029000163',
            Sexo__c = 'MASCULINO',
            Cpf__c = '96577845069'
        );

        insert conta;

        return conta;
    }

    private static Case gerarCasoAtendimento(Account conta){

        Recordtype REC_ID_CASEPAI = RecordTypeBO.buscarTipoRegistro('Case', 'Atendimento');

        Case caso = new Case(
            RecordTypeId = REC_ID_CASEPAI.Id,
				Status = 'Aberto',
				Status_Dependente__c = 'Em Análise',
                Origin = 'Backoffice',
				AccountId = conta.Id,
				Subject = 'Test Caso Atendimento Sinistro',
				Vitima__c = 'Filhos',
				Description = 'Test Caso Atendimento Sinistro',
				Dataocorrencia__c = System.today(),
				Type = 'Sinistro',				
				TipoEvento__c = 'Acidente',
				Data_Aviso_Cliente__c = System.today()
        );

        insert caso;

        return caso;
    }

    private static Case gerarCasoSinistro(Case casoAtendimento, Account conta){

        Recordtype REC_ID_CASESINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

        Case caso = new Case(
            RecordTypeId = REC_ID_CASESINISTRO.Id,
            Status = 'Avisar',
            Status_Dependente__c = 'Em Análise',
            Origin = 'Atendimento',
            ParentId = casoAtendimento.Id,
            AccountId = conta.Id,
            Subject = 'Test Caso Sinistro',
            Vitima__c = 'Filhos',
            Description = 'TestCasoSinistro',
            Dataocorrencia__c = System.today(),
            Type = 'Sinistro',
            TipoEvento__c = 'Acidente'
        );

        insert caso;

        return caso;
    }

    private static void gerarPagamentoSinistro(Case casoSinistro){
        Pagamento_de_Sinistro__c ps = new Pagamento_de_Sinistro__c(
            Caso_de_Sinistro__c = casoSinistro.Id
        );

        insert ps;
    }

    private static Pagamento_de_Sinistro__c getQueryPagamentoSinistro(){
        return [
                SELECT 
                    Id,
                    Name 
                FROM 
                    Pagamento_de_Sinistro__c
        ];
    }
}
//LECVP-212 - FIM