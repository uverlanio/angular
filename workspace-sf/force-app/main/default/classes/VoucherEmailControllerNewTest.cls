//II-154 - INICIO
@IsTest(SeeAllData=true)
private class VoucherEmailControllerNewTest {
    
    @isTest
    static void testUnit() {
        Account acc = new Account(
            FirstName = 'TestFirstNamePessoaFisica',
            LastName = 'TestLastNamePessoaFisica',
            Cpf__c = '027.111.740-00'
        );
        insert acc;
        
        Product2 prod = new Product2(
            Name = 'TestProduto',
            Status__c = 'Em criação',
            ProductCode = '99999',
            VigenciaInicial__c = system.today(),
            TipoCapital__c = 'Capital global',
            Segmento__c = 'Individual',
            TipoResponsavelPagamento__c = 'SEG',
            NumeroSusep__c = '010101',
            RegistroSusep__c = '010101'
        );
        insert prod;
        
        prod.NumeroSusep__c = '123';
        prod.VersaoRenovacao__c = 'Versão atual';
        prod.Status__c = 'Ativo';
        prod.GerarVoucher__c = true; 
        update prod;
        
        Opportunity opp = new Opportunity(Name='Test Opportunity', StageName='Em criação', CloseDate=System.today(), AccountId=acc.Id);
        insert opp;
        
        opp.StageName = 'Closed Won';
        update opp;
        
        Quote quote = new Quote(Name='Test Quote', OpportunityId=opp.Id, Status='Contratada', Produto__c=prod.Id, VoucherPdfDownloadUrl__c = 'abcd', Email__c = 'teste@teste.com', Senha__c = 'ewewqwdd', DistributionPublicUrl__c ='https://google.com/');
        insert quote;
        
        ContratanteProposta__c contratanteProposta = new ContratanteProposta__c(
            conta__c = acc.Id,
            Proposta__c = quote.Id,
            Tipo__c = 'Principal'
        );
        insert contratanteProposta;
        
        GrupoProposta__c grupoProposta = new GrupoProposta__c(
            Name = 'Teste',
            QuantidadeVidas__c = 1,
            ContratanteProposta__c = contratanteProposta.Id
        );
        insert grupoProposta;
        
        SeguradoProposta__c seguradoProposta = new SeguradoProposta__c(
            Conta__c = acc.Id,
            GrupoProposta__c = grupoProposta.Id
        );
        insert seguradoProposta;

        Map<Id, Quote> oldQuotesMap = new Map<Id, Quote>{ quote.Id => quote};
            
        Test.startTest();
        Map<String, String> result = VoucherEmailControllerNew.SendEmailVoucher(new List<Quote>{ quote }, oldQuotesMap);
        Test.stopTest();
    }
    
    @isTest
    static void moreQuotes() {
        Account acc = new Account(
            FirstName = 'TestFirstNamePessoaFisica',
            LastName = 'TestLastNamePessoaFisica',
            Cpf__c = '027.111.740-00'
        );
        insert acc;
        
        Product2 prod = new Product2(
            Name = 'TestProduto',
            Status__c = 'Em criação',
            ProductCode = '99999',
            VigenciaInicial__c = system.today(),
            TipoCapital__c = 'Capital global',
            Segmento__c = 'Individual',
            TipoResponsavelPagamento__c = 'SEG',
            NumeroSusep__c = '010101',
            RegistroSusep__c = '010101'
        );
        insert prod;
        
        prod.NumeroSusep__c = '123';
        prod.VersaoRenovacao__c = 'Versão atual';
        prod.Status__c = 'Ativo';
        prod.GerarVoucher__c = true; 
        update prod;
        
        Opportunity opp = new Opportunity(Name='Test Opportunity', StageName='Em criação', CloseDate=System.today(), AccountId=acc.Id);
        insert opp;
        
        opp.StageName = 'Closed Won';
        update opp;
        
        Quote quote = new Quote(Name='Test Quote', OpportunityId=opp.Id, Status='Contratada', Produto__c=prod.Id, VoucherPdfDownloadUrl__c = 'abcd', Email__c = 'teste@teste.com', Senha__c = 'ewewqwdd', DistributionPublicUrl__c ='https://google.com/'); // VIAG-240 INICIO/FIM
        insert quote;
        
        Quote quote2 = new Quote(Name='Test Quote2', OpportunityId=opp.Id, Status='Contratada', Produto__c=prod.Id, VoucherPdfDownloadUrl__c = 'efgh', Email__c = 'teste2@teste.com', Senha__c = '4atrp4viw', DistributionPublicUrl__c ='https://amazon.com/'); // VIAG-240 INICIO/FIM
        insert quote2;
        
        Map<Id, Quote> oldQuotesMap = new Map<Id, Quote>{ quote.Id => quote,  quote2.Id => quote2 };
            
        Test.startTest();
        Map<String, String> result = VoucherEmailControllerNew.SendEmailVoucher(new List<Quote>{ quote, quote2 }, oldQuotesMap);
        Test.stopTest();
    }
    
    @isTest
    static void nullTest() {   
        Opportunity opp = new Opportunity(Name='Test Opportunity', StageName='Em criação', CloseDate=System.today());
        insert opp;
        
        Quote quote = new Quote(Name='Test Quote', OpportunityId=opp.Id);
        insert quote;
        
        Map<Id, Quote> oldQuotesMap = new Map<Id, Quote>{ quote.Id => quote};
            
        Test.startTest();
        Map<String, String> result = VoucherEmailControllerNew.SendEmailVoucher(new List<Quote>{ quote }, null);
        Test.stopTest();
    }
}
//II-154 - FIM