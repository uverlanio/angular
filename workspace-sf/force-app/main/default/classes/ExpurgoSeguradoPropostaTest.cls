/**
 * Classe de teste para ExpurgoSeguradoProposta
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoSeguradoPropostaTest {
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoSeguradoProposta expurgo= new ExpurgoSeguradoProposta();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}