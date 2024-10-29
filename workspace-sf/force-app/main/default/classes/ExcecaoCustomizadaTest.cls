/**
 * Created by Alessandro Ponte on 28/12/2018.
 */

@IsTest
public class ExcecaoCustomizadaTest {

  @IsTest
  static void testExcecaoCustomizada(){
    ExcecaoCustomizada excecaoCustomizada = new ExcecaoCustomizada();
    excecaoCustomizada.codigo = 200;
    excecaoCustomizada.mensagem = 'OK';
    excecaoCustomizada.nome = 'Teste da excecao customizada';

    ExcecaoCustomizada excecaoCustomizada2 = new ExcecaoCustomizada('Teste da excecao customizada','OK',200);

    System.assert(excecaoCustomizada.codigo == excecaoCustomizada2.codigo);

  }



}