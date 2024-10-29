/**
 * Classe de teste para ExpurgoOrcamento
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoOrcamentoTest {
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoOrcamento expurgo= new ExpurgoOrcamento();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}