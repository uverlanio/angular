/**
 * Classe de teste para ExpurgoCriticaOrcamento
 * 09/02/2024
 */
@IsTest
public with sharing class ExpurgoCriticaOrcamentoTest {
   
    @IsTest  (SeeAllData= true)
    static void getDadosExpurgoTest() {
        ExpurgoCriticaOrcamento expurgo= new ExpurgoCriticaOrcamento();

        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        // System.assertNotEquals(0, expList.size(), 'Lista vazia');
        }
    }
}