//ZSVEP-76-INICIO
@isTest
public class AccountDAOTest {

    @testSetup
    static void setupTestData() {
        // Criando contas de teste
        List<Account> contas = new List<Account>();

            Account acc = new Account(
                Name = 'Account Test ',
                Cpf__c = '25050920019',
                Cnpj__c = '84384238000158',
                Papel__c = 'Papel ',
                ServicosParceiro__c = 'Serviço Parceiro ',
                ServicosPrestador__c = 'Serviço Prestador ',
                CodigoSusepCorretor__c = 'Codigo Susep ',
                Sucursal__c = 'Sucursal ',
                Renda__c = 1000,
                CodigoSusepCia__c = 'Codigo Susep Cia ',
                NumeroContratoParceiro__c = '12345',
                NumeroContratoPrestador__c = '67890',
                NumeroContratoRespresentante__c = '112233',
                IdExterno__c = 'EXT',
                Pep__c = 'Sim',
                CurrencyIsoCode = 'USD',
                Email__c = 'test' + '@example.com',
                CodigoEmpresa__c = 'EMP'
            );
            contas.add(acc);
        
        insert contas;

        List<Endereco__c> enderecos = new List<Endereco__c>();

        for (Account account : contas) {

            Endereco__c endereco = new Endereco__c(
                Conta__c = account.Id,
                CEP__c = '12345-678',
                Cidade__c = 'Cidade ' + account.Name,
                Estado__c = 'SP ',
                Logradouro__c = 'Logradouro ' + account.Name,
                Numero__c = '123',
                Bairro__c = 'Bairro ' + account.Name
            );
            enderecos.add(endereco);
        }
        insert enderecos;
    }

    @isTest
    static void testBuscarContasComFilhos() {
        // Recupera algumas contas de teste
        Set<Id> contaIds = new Set<Id>();
        for (Account acc : [SELECT Id FROM Account LIMIT 3]) {
            contaIds.add(acc.Id);
        }

        // Chama o método a ser testado
        List<Account> result = AccountDAO.getInstance().buscarContasComFilhos(contaIds);

        // Verifica se o resultado não está vazio
        System.assertNotEquals(0, result.size(), 'A lista de contas não deve estar vazia');

        // Verifica se as subconsultas retornaram resultados
        for (Account acc : result) {
            System.assertNotEquals(0, acc.Enderecos__r.size(), 'A lista de Enderecos não deve estar vazia');
        }
    }

    @isTest
    static void testBuscarEmpresasGrupoPorto() {
        // Chama o método a ser testado
        List<Account> result = AccountDAO.getInstance().buscarEmpresasGrupoPorto();

        // Verifica se o resultado não está vazio
        System.assertNotEquals(0, result.size(), 'A lista de empresas não deve estar vazia');

        // Verifica se cada conta possui um CodigoEmpresa__c
        for (Account acc : result) {
            System.assertNotEquals(null, acc.CodigoEmpresa__c, 'CodigoEmpresa__c não deve ser nulo');
        }
    }

    @isTest
    static void testBuscarContasPorPapel() {
        // Chama o método a ser testado com um papel específico
        String papel = 'Papel 1';
        List<Account> result = AccountDAO.getInstance().buscarContasPorPapel(papel);

        // Verifica se cada conta possui o papel esperado
        for (Account acc : result) {
            System.assertEquals(papel, acc.Papel__c, 'Papel__c deve ser ' + papel);
        }
    }

    @isTest
    static void testBuscarContasPorIdExterno() {
        // Recupera algumas contas de teste
        Set<String> idsExternos = new Set<String>();
        for (Account acc : [SELECT IdExterno__c FROM Account LIMIT 3]) {
            idsExternos.add(acc.IdExterno__c);
        }

        // Chama o método a ser testado
        List<Account> result = AccountDAO.getInstance().buscarContasPorIdExterno(idsExternos);

        // Verifica se o resultado não está vazio
        System.assertNotEquals(0, result.size(), 'A lista de contas não deve estar vazia');

        // Verifica se cada conta possui um IdExterno correspondente
        for (Account acc : result) {
            System.assert(idsExternos.contains(acc.IdExterno__c), 'IdExterno__c deve estar nos idsExternos fornecidos');
        }
    }

    @isTest
    static void testBuscarContasPorCodEmpresa() {
        // Recupera algumas contas de teste
        Set<String> codigosEmpresa = new Set<String>();
        for (Account acc : [SELECT CodigoEmpresa__c FROM Account LIMIT 3]) {
            codigosEmpresa.add(acc.CodigoEmpresa__c);
        }

        // Chama o método a ser testado
        List<Account> result = AccountDAO.getInstance().buscarContasPorCodEmpresa(codigosEmpresa);

        // Verifica se o resultado não está vazio
        System.assertNotEquals(0, result.size(), 'A lista de contas não deve estar vazia');

        // Verifica se cada conta possui um CodigoEmpresa correspondente
        for (Account acc : result) {
            System.assert(codigosEmpresa.contains(acc.CodigoEmpresa__c), 'CodigoEmpresa__c deve estar nos codigosEmpresa fornecidos');
        }
    }
}
//ZSVEP-76-FIM