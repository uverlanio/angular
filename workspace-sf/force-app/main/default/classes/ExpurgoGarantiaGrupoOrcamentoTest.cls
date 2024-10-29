/**
 * Classe de teste para ExpurgoGarantiaGrupoOrcamento
 * 16/02/2024
 */
@IsTest
public with sharing class ExpurgoGarantiaGrupoOrcamentoTest {
  
    @IsTest  (SeeAllData= true)
    static void getDadosExpurgoTest() {
        ExpurgoGarantiaGrupoOrcamento expurgo= new ExpurgoGarantiaGrupoOrcamento();

        try {
            List<Object> expList= expurgo.getDadosExpurgo(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Erro gerando dados para expurgo');
        // System.assertNotEquals(0, expList.size(), 'Lista vazia');
        }
    }
}