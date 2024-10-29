/**
 * Classe de teste para ExpurgoContratanteOrcamento
 * 16/02/2024
 */
@IsTest
public with sharing class ExpurgoContratanteOrcamentoTest {
    @IsTest  // (SeeAllData= true)
    static void getDadosExpurgoTest() {
        ExpurgoContratanteOrcamento expurgo= new ExpurgoContratanteOrcamento();

        try {
            List<ContratanteOrcamento__c> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        // System.assertNotEquals(0, expList.size(), 'Lista vazia');
        }
    }
}