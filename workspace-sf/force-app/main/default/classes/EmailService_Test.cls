@isTest 
private class EmailService_Test{ 
   // #PLV-3718 - Reenvio de e-mail do kit boas vindas - apólices
    @testSetup  
    static void setup () { 
        TestDataFactory.gerarDadosSetup (); 
        
        Account conta = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
            LastName = 'Teste',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '00478394659',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = (Date.today()-7300),
            EstadoCivil__c = 'Solteiro (a)'
        );
        insert conta;

        Opportunity oportunidade = new Opportunity(
            Name = 'Teste Contrato',
            StageName = 'Em criação',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
            AccountId = conta.Id,
            CloseDate = Date.today()
        );
        insert oportunidade;

        //TKCL-246 FIX05 INICIO
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        CanalDistribuicao__c canalDistribuicao = (CanalDistribuicao__c) new CanalDistribuicaoFactory().createRecord(); 

        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        produtoTecnico.ProductCode = '49';
        produtoTecnico.Segmento__c = 'Individual';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.ProductCode = 'APTLMKT';
        produtoComercial.Segmento__c = 'Individual';
        produtoComercial.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercial;
        //TKCL-246 FIX05 FIM
    
        Quote proposta = new Quote(
            Name= 'Teste Contrato',
            OpportunityId=oportunidade.Id,
            DataProtocolo__c = Date.today(),
            DataCalculo__c =  Date.today(),
            Empresa__c = conta.Id,
            ExpirationDate = Date.today(),
            Produto__c = produtoComercial.Id //TKCL-246 FIX05 INICIO/FIM
        );
        insert proposta;
    }
    
    @isTest 
    static void validRecord() {
        Quote proposta = [SELECT Id FROM Quote WHERE Name = 'Teste Contrato'];
        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];
        List<Account> conta = [SELECT id FROM Account WHERE LastName = 'Teste'];
        
        Contract contrato = new Contract(
            IdExterno__c = 'Test Req 1123',
            Name = '111',
            Status = 'Emitido',
            Oportunidade__c = oportunidade.Id,
            Proposta__c = proposta.Id,
            Tipo__c = 'Novo',
            AccountId = conta[0].Id
        );
        insert contrato;
        
        Test.startTest ();
            EmailService.doPost('Test Req 1123');
        Test.stopTest ();
    }
    
    @isTest 
    static void noContractRecord() {
        Quote proposta = [SELECT Id FROM Quote WHERE Name = 'Teste Contrato'];
        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];
        List<Account> conta = [SELECT id FROM Account WHERE LastName = 'Teste'];
        
        Contract contrato = new Contract(
            IdExterno__c = 'Test Req 1123',
            Name = '111',
            Status = 'Emitido',
            Oportunidade__c = oportunidade.Id,
            Proposta__c = proposta.Id,
            Tipo__c = 'Novo',
            AccountId = conta[0].Id
        );
        insert contrato;
        
        Test.startTest ();
            EmailService.doPost('Test Req 1124');
        Test.stopTest ();
    }
	// #PLV-3718 - FIM
}