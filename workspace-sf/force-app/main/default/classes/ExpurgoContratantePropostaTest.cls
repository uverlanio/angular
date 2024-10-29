/**
 * Classe de teste para ExpurgoContratanteProposta
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoContratantePropostaTest {
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoContratanteProposta expurgo= new ExpurgoContratanteProposta();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}