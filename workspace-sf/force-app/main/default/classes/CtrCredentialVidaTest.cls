/****
@description Classe de teste para classe da pagina de redirecionamento (Acesso externo ao portal)
@author Isabela Fin - Globant
@date 16/07/2020
@Classe referente a historia PLV-4039      
*****/
@isTest
public class CtrCredentialVidaTest {

    //MGRC-1657 - INICIO
    @isTest
    static void testCredentialRedirect() {
        Test.setMock(HttpCalloutMock.class, new CtrCredentialVidaMock());
        Test.startTest();
        ApexPages.currentPage().getParameters().put('corsus','P5005J');
        ApexPages.currentPage().getParameters().put('sesnum','123456');
        ApexPages.currentPage().getParameters().put('webusrcod','8');
        ApexPages.currentPage().getParameters().put('codigoOfertaConsultiva','ESPECIFICO');
        ApexPages.currentPage().getParameters().put('canalDistribuicao','COR');
        ApexPages.currentPage().getParameters().put('meioComercializacao','PMC'); //PLV-4550 INICIO/FIM
        ApexPages.currentPage().getParameters().put('entradaNegocio','CO2');
        // CtrCredentialVida ctrVida = new CtrCredentialVida(); //MGRC-1657 - INICIO
        // ctrVida.doRedirect(); //MGRC-1657 - FIM
        Test.stopTest();
    }
    
    @isTest
    static void testCredentialCalloutError() {
        Test.setMock(HttpCalloutMock.class, new CtrCredentialVidaMock.CalloutError());
        Test.startTest();
        ApexPages.currentPage().getParameters().put('corsus','P5005J');
        ApexPages.currentPage().getParameters().put('sesnum','654321');
        ApexPages.currentPage().getParameters().put('webusrcod','8');
        ApexPages.currentPage().getParameters().put('codigoOfertaConsultiva','ESPECIFICO');
        ApexPages.currentPage().getParameters().put('canalDistribuicao','COR');
        ApexPages.currentPage().getParameters().put('meioComercializacao','PMC'); //PLV-4550 INICIO/FIM
        ApexPages.currentPage().getParameters().put('entradaNegocio','CO2');
        // CtrCredentialVida ctrVida = new CtrCredentialVida(); //MGRC-1657 - INICIO
        // ctrVida.doRedirect(); //MGRC-1657 - FIM
        Test.stopTest();
    }
   
    @isTest
    static void testCredentialInvalidSession() {
        Test.setMock(HttpCalloutMock.class, new CtrCredentialVidaMock.InvalidSession());
        Test.startTest();
        ApexPages.currentPage().getParameters().put('corsus','P5005J');
        ApexPages.currentPage().getParameters().put('sesnum','654321');
        ApexPages.currentPage().getParameters().put('webusrcod','8');
        ApexPages.currentPage().getParameters().put('codigoOfertaConsultiva','ESPECIFICO');
        ApexPages.currentPage().getParameters().put('canalDistribuicao','COR');
        ApexPages.currentPage().getParameters().put('meioComercializacao','PMC'); //PLV-4550 INICIO/FIM
        ApexPages.currentPage().getParameters().put('entradaNegocio','CO2');
        // CtrCredentialVida ctrVida = new CtrCredentialVida(); //MGRC-1657 - INICIO
        // ctrVida.doRedirect(); //MGRC-1657 - FIM
        Test.stopTest();
    }


    @isTest
    static void testCredentialNoParam() {
        Test.startTest();
        CtrCredentialVida ctrVida = new CtrCredentialVida();
        ctrVida.doRedirect();
        Test.stopTest();
    }
    //MGRC-1657 - FIM
}