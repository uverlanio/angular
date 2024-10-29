/*
@description  Classe de teste para validar os métodos da CtrBoleto
@author Veronice Boesing - Globant
@date 17/11/2022
@Classe criada por conta da história RVI-204
*/
@isTest
public class CtrBoletoTest {      

    @isTest
   public static void TestgetBoletoData() {
        //coloca atributo da página visualforce
        Test.setCurrentPage(Page.VFGerarBoleto);
        ApexPages.currentPage().getParameters().put('token','1');                                      
              
        //instancia classe a ser testada
        CtrBoleto testClass = new CtrBoleto();    
        
        Test.startTest();                   
            testClass.getBoletoData();
        Test.stopTest();        
    }  
}