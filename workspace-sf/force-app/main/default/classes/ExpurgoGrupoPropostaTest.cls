/**
 * Classe de teste para ExpurgoGrupoProposta
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoGrupoPropostaTest {
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoGrupoProposta expurgo= new ExpurgoGrupoProposta();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}