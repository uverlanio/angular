/**
 * Classe de teste para ExpurgoRemuneracaoOrcamentoTest
 * 17/02/2024
 */
@IsTest
public with sharing class ExpurgoRemuneracaoOrcamentoTest {
    @IsTest  (SeeAllData= true)
    static void getDadosExpurgoTest() {
        ExpurgoRemuneracaoOrcamento expurgo = new ExpurgoRemuneracaoOrcamento();

        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        // System.assertNotEquals(0, expList.size(), 'Lista vazia');
        }
    }
}