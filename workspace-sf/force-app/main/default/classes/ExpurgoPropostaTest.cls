/**
 * Classe de teste para ExpurgoProposta
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoPropostaTest {
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoProposta expurgo= new ExpurgoProposta();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}