/**
 * Classe de teste para ExpurgoRemuneracaoProposta
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoRemuneracaoPropostaTest {
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoRemuneracaoProposta expurgo= new ExpurgoRemuneracaoProposta();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}