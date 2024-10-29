/**
 * Testes RetornoAcaoBotaoTO
 * @author Diogo Borges @ 25/03/2020
 * PLV-3667
 **/

@IsTest
public class RetornoAcaoBotaoTOtest {
	@IsTest
    static void testRetornoAcaoBotaoTO(){
        
        List<SObject> listSObjects = new List<SObject>();
        List<String> mensagens = new List<String>();
        
    	RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO('', mensagens,'',listSObjects);
        
        /*retorno.linkRedirecionar = '';
        retorno.tipo = '';
        retorno.RetornoAcaoBotaoTO();*/
        
    }
}