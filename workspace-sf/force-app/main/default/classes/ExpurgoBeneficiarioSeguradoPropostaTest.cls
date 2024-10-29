/**
 * Classe de teste para ExpurgoBeneficiarioSeguradoProposta
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoBeneficiarioSeguradoPropostaTest {
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoBeneficiarioSeguradoProposta expurgo= new ExpurgoBeneficiarioSeguradoProposta();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}