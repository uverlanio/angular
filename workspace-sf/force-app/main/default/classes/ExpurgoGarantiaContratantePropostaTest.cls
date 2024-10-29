/**
 * Classe de teste para ExpurgoGarantiaContratanteProposta
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoGarantiaContratantePropostaTest {
    
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoGarantiaContratanteProposta expurgo= new ExpurgoGarantiaContratanteProposta();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}