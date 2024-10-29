/**
 * Classe de teste para ExpurgoDeclaracaoSaude
 * 28/02/2024
 */
@IsTest
public with sharing class ExpurgoDeclaracaoSaudeTest {
    @IsTest 
    static void getDadosExpurgoTest() {
        ExpurgoDeclaracaoSaude expurgo= new ExpurgoDeclaracaoSaude();
        
        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        }
    }
}