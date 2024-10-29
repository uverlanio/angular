/**
 * Created on 30/04/2021.
 * Classe Criada por conta da História PLV-4921
 */

@IsTest
private class CasoTOTest {

    @IsTest
    static void testBehavior() {

        CasoTO.datametaTO datametaTO = new CasoTO.datametaTO();
		datametaTO.dataExecucao = 'Teste';
        datametaTO.mensagem = 'Teste';
		datametaTO.statusHttp = 200;
        datametaTO.servico = 'Teste';

		CasoTO.validacaoPropostaTO validacaoPropostaTO = new CasoTO.validacaoPropostaTO();
        validacaoPropostaTO.meta = datametaTO;

        CasoTO casoTO = new CasoTO();
        casoTO.validacaoProposta = validacaoPropostaTO;
        
	}
}