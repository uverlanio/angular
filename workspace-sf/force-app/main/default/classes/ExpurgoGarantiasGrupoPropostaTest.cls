/**
 * Classe de teste para ExpurgoGarantiasGrupoProposta
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoGarantiasGrupoPropostaTest {
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoGarantiasGrupoProposta expurgo= new ExpurgoGarantiasGrupoProposta();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}