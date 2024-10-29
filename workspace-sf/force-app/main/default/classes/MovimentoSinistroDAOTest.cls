//POR062-1 - INICIO
@isTest
private class MovimentoSinistroDAOTest {
   
    @isTest static void testarBuscarPorIdCaso(){

        Test.startTest();

        Set<Id> idCasos = new Set<Id>();
        idCasos.add('500L000000GS9L5IAL');

        // LECVPV-216 INICIO
        Set<Id> idGarantias = new Set<Id>();
        idGarantias.add('a1r8900000EmNDfAAN');
        MovimentoSinistroDAO.getInstance().buscarPorIdCaso(idCasos);
        MovimentoSinistroDAO.getInstance().buscarMovimentosPorGarantia(idGarantias);
        // LECVPV-216 FIM

        Test.stopTest();
    }
}
//POR062-1 - INICIO