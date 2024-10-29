/*
PLV-4632 - CRIADO EM 23/11/2020
AUTOR: JEFERSON SANTANA
DESCRIÇÃO: CLASSE DE TESTE REFERENTE A CLASSE cartarecusacontroller
*/
@IsTest
public class CartaRecusaControllerTest {
    @IsTest
    public static void testePDF() {
        Test.startTest();
        CartaRecusaController carta = new CartaRecusaController();
        carta.dia = 1;
        carta.mes = 'Dezembro';
        carta.nomeCorretor = 'teste';
        carta.nomeSegurado = 'teste';
        carta.produto = 'teste';
        system.assertEquals(carta.dia, 1);
        Test.stopTest();
    }
}