/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-28
 * @description CasoRest Classe de Teste
 */
@isTest
public class CasoRestTest {

	//PLV-2285 - In�cio - Cria��o do m�todo para maior cobertura na classe de teste 
	@isTest
	public static void validarCasoRestPago(){

		Test.startTest();
            CasoRest casoRest = new CasoRest();
            casoRest.processarServico('PAGO');
		Test.stopTest();
	
	}
	//PLV-2285 - Fim - Cria��o do m�todo para maior cobertura na classe de teste 

	//PLV-2285 - In�cio - Cria��o do m�todo para maior cobertura na classe de teste 
	@isTest
	public static void validarCasoRestErro(){

		Test.startTest();
            CasoRest casoRest = new CasoRest();
            casoRest.processarServico('ERRO');
		Test.stopTest();
	}
	//PLV-2285 - Fim - Cria��o do m�todo para maior cobertura na classe de teste 

	//PLV-2285 - In�cio - Cria��o do m�todo para maior cobertura na classe de teste 
	@isTest
	public static void validarCasoRestCancelado(){

		Test.startTest();
            CasoRest casoRest = new CasoRest();
            casoRest.processarServico('CANCELADO');
		Test.stopTest();
	}
	//PLV-2285 - Fim - Cria��o do m�todo para maior cobertura na classe de teste 

	//PLV-2285 - In�cio - Ajuste no m�todo para maior cobertura na classe de teste 
	@isTest
	public static void validarCasoRest(){

		Test.startTest();
            CasoRest.processarPost();
		Test.stopTest();
	}
	//PLV-2285 - Fim - Ajuste no m�todo para maior cobertura na classe de teste 

}