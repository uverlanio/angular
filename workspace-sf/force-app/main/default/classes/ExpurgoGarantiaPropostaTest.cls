/**
 * Classe de teste para ExpurgoGarantiaProposta
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoGarantiaPropostaTest {
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoGarantiaProposta expurgo= new ExpurgoGarantiaProposta();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}