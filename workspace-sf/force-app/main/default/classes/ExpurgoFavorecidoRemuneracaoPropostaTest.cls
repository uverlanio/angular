/**
 * Classe de teste para ExpurgoFavorecidoRemuneracaoProposta
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoFavorecidoRemuneracaoPropostaTest {
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoFavorecidoRemuneracaoProposta expurgo= new ExpurgoFavorecidoRemuneracaoProposta();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}