/*********************************************************************************************************************************************************************
@description Classe de teste batch responsavel - casos da Assist Card
@author Uverlanio Silva - Globant
@date 26/05/2023
**********************************************************************************************************************************************************************/
//LECVP-318 - INICIO
@isTest
private class BatchBaixarAssistCardTest {
    
    @isTest static void testarExecucaoBatch(){

        Test.startTest();

        Boolean isException = false;

        try{
            Database.executeBatch(new BatchBaixarAssistCard());
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();        
    }

    @isTest static void testarAgendamento(){

        Test.startTest();

        Boolean isException = false;

        BatchBaixarAssistCard batch = new BatchBaixarAssistCard();

        try{
            System.schedule('BatchBaixarAssistCard', '0 7 11 * * ?', batch);
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();        
    }

    @isTest static void testarAgendamentoAsyncException(){

        Test.startTest();

        BatchBaixarAssistCard batch = new BatchBaixarAssistCard();
        Boolean isException = false;
        
        try{
            System.schedule('BatchBaixarAssistCard', '0 7 11 24 2 ? 2023', batch);
        }catch(AsyncException ae){
            isException = true;
        }

        System.assertEquals(true, isException);

        Test.stopTest();        
    }

    @isTest static void testarBaixarCasosAssistSim(){

        Test.startTest();

        Boolean isException = false; 
        
        BatchBaixarAssistCard batch = new BatchBaixarAssistCard();
        List<AsyncApexJob> jobs = new List<AsyncApexJob>();
        List<Case> casosAssist = new List<Case>();

        List<PagamentoGarantia__c> pgtosGarantia = new List<PagamentoGarantia__c>();

        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();
        conta.Cpf__c = '568.291.210-19';
        insert conta;

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().getRecord();
        garantia.Id = null;
        garantia.Sigla__c = 'DMHO';
        insert garantia;

        PagamentoGarantia__c pgtoGarantia = prepararPagamentoGarantia(casosAssist, conta, garantia);
        pgtosGarantia.add(pgtoGarantia);

        insert pgtosGarantia;

        try{
            batch.baixarCasosAssist(casosAssist, jobs);
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();
    }

    @isTest static void testarBaixarCasosAssistNao(){

        Test.startTest();

        Boolean isException = false; 
        
        BatchBaixarAssistCard batch = new BatchBaixarAssistCard();
        List<AsyncApexJob> jobs = new List<AsyncApexJob>();
        List<Case> casosAssist = new List<Case>();

        List<PagamentoGarantia__c> pgtosGarantia = new List<PagamentoGarantia__c>();

        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();
        conta.Cpf__c = '568.291.210-19';
        insert conta;

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().getRecord();
        garantia.Id = null;
        garantia.Sigla__c = 'DMHO';
        insert garantia;

        PagamentoGarantia__c pgtoGarantia = prepararPagamentoGarantia(casosAssist, conta, garantia);

        Case caso = [SELECT Id, PagtoAssistCardInternacional__c FROM Case WHERE Id = :pgtoGarantia.Caso__c];
        caso.PagtoAssistCardInternacional__c = 'Não';

        update caso;

        pgtoGarantia.Caso__c = caso.Id;
        pgtoGarantia.Caso__r = caso;

        pgtosGarantia.add(pgtoGarantia);

        insert pgtosGarantia;

        try{
            batch.baixarCasosAssist(casosAssist, jobs);
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();
    }

    @isTest static void testarBaixarCasosAssistSimDuasGarantias(){

        Test.startTest();

        Boolean isException = false; 
        
        BatchBaixarAssistCard batch = new BatchBaixarAssistCard();
        List<AsyncApexJob> jobs = new List<AsyncApexJob>();
        List<Case> casosAssist = new List<Case>();

        List<PagamentoGarantia__c> pgtosGarantia = new List<PagamentoGarantia__c>();

        Account conta1 = (Account) new AccountFactory.PessoaFisica().getRecord();
        conta1.Cpf__c = '568.291.210-19';
        insert conta1;

        Garantia__c garantia1 = (Garantia__c) new GarantiaFactory().getRecord();
        garantia1.Id = null;
        garantia1.Sigla__c = 'DMHO';
        insert garantia1;

        PagamentoGarantia__c pgtoGarantia1 = prepararPagamentoGarantia(casosAssist, conta1, garantia1);
        pgtosGarantia.add(pgtoGarantia1);        

        Account conta2 = (Account) new AccountFactory.PessoaFisica().getRecord();
        conta2.Id = null;
        conta2.Cpf__c = '598.296.440-90';
        insert conta2;

        Garantia__c garantia2 = (Garantia__c) new GarantiaFactory().getRecord();
        garantia2.Id = null;
        garantia2.Sigla__c = 'AFI';
        insert garantia2;

        PagamentoGarantia__c pgtoGarantia2 = prepararPagamentoGarantia(casosAssist, conta2, garantia2);

        pgtoGarantia2.Garantia_do_segurado_do_contrato__r.Garantia__r = garantia2;
        pgtoGarantia2.Garantia_do_segurado_do_contrato__r.Garantia__c = garantia2.Id;
        pgtosGarantia.add(pgtoGarantia2);

        insert pgtosGarantia;

        try{
            batch.baixarCasosAssist(casosAssist, jobs);
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();
    }

     @isTest static void testarBaixarCasosAssistNacnl(){

        Test.startTest();

        Boolean isException = false; 
        
        BatchBaixarAssistCard batch = new BatchBaixarAssistCard();
        List<AsyncApexJob> jobs = new List<AsyncApexJob>();
        List<Case> casosAssist = new List<Case>();

        List<PagamentoGarantia__c> pgtosGarantia = new List<PagamentoGarantia__c>();

        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();
        conta.Cpf__c = '568.291.210-19';
        insert conta;

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().getRecord();
        garantia.Id = null;
        garantia.Sigla__c = 'DMHO';
        insert garantia;

        PagamentoGarantia__c pgtoGarantia = prepararPagamentoGarantia(casosAssist, conta, garantia);
        Contract contrato = pgtoGarantia.Caso__r.Contrato__r;
        contrato.TipoViagem__c = 'Nacional';
        update contrato;

        pgtoGarantia.Caso__r.Contrato__r = contrato;
        pgtoGarantia.Caso__r.Contrato__c = contrato.Id;
        pgtosGarantia.add(pgtoGarantia);

        insert pgtosGarantia;

        try{
            batch.baixarCasosAssist(casosAssist, jobs);
        }catch(Exception e){
            isException = true;
        }

        System.assert(!isException);

        Test.stopTest();
    }

    private static Case criarCaso(Contract contrato){

        Case caso = new Case(
            Sinistro_Judicial__c = false,
            Origin = 'Atendimento',
            Type = 'Sinistro',
            Status = 'Avisado',
            Invoice__c = '123456',
            Data_pagamento__c = Date.today() - 1,
            Contrato__c = contrato.Id,
            Contrato__r = contrato,
            PagtoAssistCardInternacional__c = 'Sim'
        );

        return caso;
    }

    private static PagamentoGarantia__c criarPagamentoGarantia(Case caso, GarantiaSeguradoContrato__c garantiaSeguradoContrato){

        // LECVPV-238-FIX01 INICIO
        PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
            Name = 'Despesas Médicas, Hospitalares e Odontológicas',
            Caso__c = caso.Id,
            Caso__r = caso,
            Garantia_do_segurado_do_contrato__c = garantiaSeguradoContrato.Id,
            Garantia_do_segurado_do_contrato__r = garantiaSeguradoContrato,
            Valor_indenizado__c = 30000        
        );
        // LECVPV-238-FIX01 FIM

        return pagamentoGarantia;
    }

    private static Parceiro__c criarParceiro(Account conta, FormaPagamento__c formaPagamento){

        Parceiro__c parceiro = new Parceiro__c(
            Status__c = 'Ativo',
            Sucursal__c = '1',
            Ramo__c = '1391',
            Empresa__c = '1',
            Conta__c = conta.Id,
            FormaPagamento__c = formaPagamento.Id,
            DiaFaturamento__c = '15',
            DiaPreFaturamento__c = '20',
            PrazoVencimento__c = '10',
            FaturaProdutosSeparados__c = 'Sim',
            PossuiAnexoFatura__c = 'Nao',
            SiglaParceiro__c = 'PAR'
        );

        return parceiro;
    }

    private static Product2 criarProduto(){
        Product2 produto = new Product2(
            Name = 'teste',
            NumeroSusep__c = '123',
            VersaoRenovacao__c = 'Versão atual',
            Status__c = 'Ativo',
            ProductCode = '32'
        );

        return produto;
    }

    private static Contract criarContrato(Account conta, Product2 produto, Parceiro__c parceiro){

        Contract contrato =  new Contract(
            Name = 'teste',
            AccountId = conta.Id,
            Produto__c = produto.Id,
            Parceria__c = parceiro.Id,
            CodigoRamo__c = '1369'
        );

        return contrato;
    }

    private static ContratanteContrato__c criarContratanteContrato(Contract contrato, Account conta){

        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
            Contrato__r = contrato,
            Conta__r = conta,
            Tipo__c = 'Principal'
        );

        return contratanteContrato;
    }

    private static GrupoContrato__c criarGrupoContrato(ContratanteContrato__c contratanteContrato){

        GrupoContrato__c grupoContrato = new GrupoContrato__c(
            ContratanteContrato__r = contratanteContrato
        );

        return grupoContrato;
    }

    private static SeguradoContrato__c criarSeguradoContrato(Account conta, GrupoContrato__c grupoContrato){

        SeguradoContrato__c seguradoContrato = new SeguradoContrato__c(
            Conta__r = conta,
            GrupoContrato__c = grupoContrato.Id,
            VigenciaInicial__c = system.today(),
            VigenciaFinal__c = system.today().addMonths(1)
        );

        return seguradoContrato;
    }

    private static GarantiaSeguradoContrato__c criarGarantiaSeguradoContrato(SeguradoContrato__c seguradoContrato, Garantia__c garantia){

        GarantiaSeguradoContrato__c garantiaSeguradoContrato = new GarantiaSeguradoContrato__c(
            SeguradoContrato__c = seguradoContrato.Id,
            Garantia__c = garantia.Id,
            Garantia__r = garantia
        );

        return garantiaSeguradoContrato;
    }

    private static PagamentoGarantia__c prepararPagamentoGarantia(List<Case> casosAssist, Account conta, Garantia__c garantia){

        RamoAtividade__c ramoAtividade = (RamoAtividade__c) new RamoAtividadeFactory().createRecord();
        Account contaParceiro = (Account) new AccountFactory.PessoaJuridica(ramoAtividade).getRecord();

        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();

        Product2 produto = criarProduto();

        Parceiro__c parceiro = criarParceiro(contaParceiro, formaPagamento);

        Contract contrato = criarContrato(conta, produto, parceiro);
        contrato.TipoViagem__c = 'Internacional';
        insert contrato;

        ContratanteContrato__c contratanteContrato = criarContratanteContrato(contrato, conta);
        insert contratanteContrato;

        GrupoContrato__c grupoContrato = criarGrupoContrato(contratanteContrato);
        insert grupoContrato;

        SeguradoContrato__c seguradoContrato = criarSeguradoContrato(conta, grupoContrato);
        insert seguradoContrato;

        GarantiaSeguradoContrato__c garantiaSeguradoContrato = criarGarantiaSeguradoContrato(seguradoContrato, garantia);
        insert garantiaSeguradoContrato;

        Case caso = criarCaso(contrato);
        insert caso;
        
        casosAssist.add(caso);        

        PagamentoGarantia__c pagamentoGarantia = criarPagamentoGarantia(casosAssist[0], garantiaSeguradoContrato);

        return pagamentoGarantia;
    }
}
//LECVP-318 - FIM