//INICIO | PLV-2233-27
/*
*  @author Everymind - Sprint 27
*  @Descrição: classe de teste do objeto nota fiscal
*/
@isTest
public with sharing class NotaFiscalTest {

    private static Integer idPagamento;

    @testSetup
    private static void setup(){
        TestDataFactory.gerarConta();
        
    }

    @isTest
    private static void testeAtualizacaoPagamentoPendente(){ 

        List<Account> lst = [SELECT Id FROM Account limit 5];
        Account conta = lst[0];
		//PLV-3918-FIX4 - INICIO
        Pagamento__x pgto = TestDataFactory.mapeiaPagamento(conta, 'PENDENTE');
        //PLV-3918-FIX4-FIM
        idPagamento = Integer.valueOf(pgto.Id__c);
        PagamentoDAO.mockedPagamentos.add(pgto);
        
        Test.startTest();

        NotaFiscal__c nf = TestDataFactory.mapeiaNotaFiscal(idPagamento, 'Pendente');
        insert nf;
        
        // PLV-3667 - INICIO
        nf.StatusAprovacao__c = 'PAGAMENTO EM APROVAÇÃO';
        update nf;
        // PLV-3667 - FIM

        Test.stopTest();

        List<Integer> l = New List<Integer>();
        l.add(idPagamento);
        List<Pagamento__x> lstPgtoC = PagamentoDAO.getInstance().buscarPagamentosPorIdcs(l);

        System.assertEquals('PAGAMENTO EM APROVAÇÃO', lstPgtoC[0].Status__c);
    }

    
    @isTest
    private static void testeAtualizacaoPagamentoAprovado(){ 

        List<Account> lst = [SELECT Id FROM Account limit 5];
        Account conta = lst[0];

        Pagamento__x pgto = TestDataFactory.mapeiaPagamento(conta, 'PAGAMENTO EM APROVAÇÃO');
        idPagamento = Integer.valueOf(pgto.Id__c);
        PagamentoDAO.mockedPagamentos.add(pgto);
        
        Test.startTest();

        NotaFiscal__c nf = TestDataFactory.mapeiaNotaFiscal(idPagamento, 'Aprovado');
        insert nf;

        Test.stopTest();

        List<Integer> l = New List<Integer>();
        l.add(idPagamento);
        List<Pagamento__x> lstPgtoC = PagamentoDAO.getInstance().buscarPagamentosPorIdcs(l);

       List<ControleIntegracao__c> lstLog = [SELECT CodigoIntegracao__c, DataCriacaoRegistro__c, IdObjeto__c, Status__c FROM ControleIntegracao__c];

      //INICIO | PLV-2376-29
      for(ControleIntegracao__c log : lstLog)
         System.assertEquals('Pendente', log.Status__c);
      //FIM | PLV-2376-29

       System.assertEquals('PAGAMENTO LIBERADO', lstPgtoC[0].Status__c);
    }

    @isTest
    private static void testeAtualizacaoPagamentoReprovado(){ 

        List<Account> lst = [SELECT Id FROM Account limit 5];
        Account conta = lst[0];

        Pagamento__x pgto = TestDataFactory.mapeiaPagamento(conta, 'PAGAMENTO EM APROVAÇÃO');
        idPagamento = Integer.valueOf(pgto.Id__c);
        PagamentoDAO.mockedPagamentos.add(pgto);
        
        Test.startTest();

        NotaFiscal__c nf = TestDataFactory.mapeiaNotaFiscal(idPagamento, 'Reprovado');
        insert nf;

        Test.stopTest();

        List<Integer> l = New List<Integer>();
        l.add(idPagamento);
        List<Pagamento__x> lstPgtoC = PagamentoDAO.getInstance().buscarPagamentosPorIdcs(l);

        System.assertEquals('PAGAMENTO REJEITADO', lstPgtoC[0].Status__c);
    }
}
//FIM | PLV-2233-27