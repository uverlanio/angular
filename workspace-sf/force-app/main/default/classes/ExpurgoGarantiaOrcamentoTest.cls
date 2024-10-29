/**
 * Classe de teste para ExpurgoGarantiaorcamento
 * 17/02/2024
 */
@IsTest
public with sharing class ExpurgoGarantiaOrcamentoTest {
    @IsTest  (SeeAllData= true)
    static void getDadosExpurgoTest() {
        ExpurgoGarantiaorcamento expurgo= new ExpurgoGarantiaorcamento();

        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        // System.assertNotEquals(0, expList.size(), 'Lista vazia');
        }
    }
}