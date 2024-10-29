/**
 * Classe de teste para ExpurgoGarantiasContratanteOrcamento
 * 09/02/2024
 */
@IsTest
public with sharing class ExpurgoGarantiasContratanteOrcamentoTest {
    @IsTest  (SeeAllData= true)
    static void getDadosExpurgoTest() {
        ExpurgoGarantiasContratanteOrcamento expurgo= new ExpurgoGarantiasContratanteOrcamento();
        List<Object> expList= expurgo.getDadosExpurgo(10);

        System.assertNotEquals(0, expList.size(), 'Lista vazia');
    }
}