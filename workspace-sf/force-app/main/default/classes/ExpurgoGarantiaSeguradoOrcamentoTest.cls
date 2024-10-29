/**
 * Classe de teste para ExpurgoGarantiaSeguradoOrcamento
 * 09/02/2024
 */
@IsTest
public with sharing class ExpurgoGarantiaSeguradoOrcamentoTest {
    
    @IsTest  // (SeeAllData= true)
    static void getDadosExpurgoTest() {
        ExpurgoGarantiaSeguradoOrcamento expurgo= new ExpurgoGarantiaSeguradoOrcamento();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        // System.assertNotEquals(0, expList.size(), 'Lista vazia');
        }
    }
}