/**
 * Classe de teste para ExpurgoGarantiaSeguradoProposta
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoGarantiaSeguradoPropostaTest {
   
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoGarantiaSeguradoProposta expurgo= new ExpurgoGarantiaSeguradoProposta();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}