/*******************************************************************************************************************************
* Testar criação arquivos e associá-los à um registro
* @author Isabela - Globant
* @Date 05/02/2020
* @ModifiedAt 05/02/2020
* Classe criada por conta da história PLV-2146
******************************************************************************************************************************/
@isTest
public class FileControllerTest {
    @testSetup
    public static void testSetup(){
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
    }
    @isTest
    public static void testUnit(){
        Account conta = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        FileController.createTextFile('Testing', 'Lorem ipsum dolor sit amet', conta.Id, '.txt');
        Test.stopTest();
    }
}