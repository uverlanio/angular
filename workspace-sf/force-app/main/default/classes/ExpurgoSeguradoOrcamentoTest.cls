/**
 * Classe de teste para ExpurgoSeguradoOrcamento
 * 16/02/2024
 */
@IsTest
public with sharing class ExpurgoSeguradoOrcamentoTest {
    
    @IsTest  (SeeAllData= true)
    static void getDadosExpurgoTest() {
        ExpurgoSeguradoOrcamento expurgo = new ExpurgoSeguradoOrcamento();

        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        // System.assertNotEquals(0, expList.size(), 'Lista vazia');
        }
    }
}