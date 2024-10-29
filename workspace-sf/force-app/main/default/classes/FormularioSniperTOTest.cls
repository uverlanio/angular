/**
 * Teste FormularioSniperTO
 * @author Pedro Augusto Braz - Sys4b
 * @Date 24/04/2020
 **/
@isTest
private class FormularioSniperTOTest {
    
    
    @isTest static void teste(){
        
        String body = '{"consultivo":{"susepCorretor":"abc","meioComercializacao":"abc","conjuntos":[{"titulo":"abc","subtitulo":"abc","regrasSequencia":[{"sequencia":1,"proximoConjunto":null}],"informacoes":[{"tipo":"abc","servico":"abc","opcoes":[{"rotulo":"abc","codigo":"abc"}],"obrigatorio":true,"nome":"abc","id":0,"descricao":"abc"},{"tipo":"abc","servico":"abc","opcoes":[{"rotulo":"abc","codigo":"abc"}],"obrigatorio":false,"nome":"abc","id":1,"descricao":"abc"}],"id":0}],"codigoOfertaConsultiva":"abc","canalDistribuicao":"abc"}}';
        FormularioSniperTO form = new FormularioSniperTO();
        Test.startTest();     
        // PLV-4921-INICIO
        	form = FormularioSniperTO.parse(body);
        // PLV-4921-FIM
        Test.stopTest();
    }

}