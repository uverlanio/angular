/*********************************************************************************************************************************************************************

@description  Classe de Teste que que referência a Classe ProfissaoHandler  
@author Renan Martins - Avanxo
@date 28/08/2019
@Classe criada por conta da história PLV-2585
        
**********************************************************************************************************************************************************************/


@isTest
public class ProfissaoHandlerTest {

    @isTest
    static void ProfissaoHandlerTest() {
		
        Profissao__c prof = (Profissao__c) new ProfissaoFactory().createRecord();
        //Confere afirma que os dois primeiros argumentos são os mesmos. 
       // System.assertEquals(prof.NomeGrandeGrupo__c, [SELECT Name FROM Profissao__c WHERE Id =: prof.Id].Name);


        prof.NomeFantasia__c = 'teste';
        prof.NomeGrandeGrupo__c = null;
        update prof;
        
        prof.CodigoGrandeGrupo__c = null;
        prof.CodigoSubGrupoPrincipal__c = '84';
        update prof;

        prof.CodigoSubGrupoPrincipal__c = null;
        prof.CodigoSubGrupo__c = '848';
        update prof;

        prof.CodigoSubGrupo__c = null;
        prof.CodigoFamilia__c = '8485';
        update prof;

        prof.CodigoFamilia__c = null;
        prof.Codigo__c = '8485-05';
        update prof;

      System.assertEquals('teste', [SELECT NomeOcupacao__c FROM Profissao__c WHERE Id =: prof.Id].NomeOcupacao__c);
    }

    @isTest
    static void ProfissaoHandlerTest1() {

        Profissao__c prof = (Profissao__c) new ProfissaoFactory().createRecord();
       //System.assertEquals(prof.NomeGrandeGrupo__c, [SELECT Name FROM Profissao__c WHERE Id =: prof.Id].Name);

        prof.NomeGrandeGrupo__c = null;
        prof.NomeSubGrupoPrincipal__c = 'TESTE TRABALHADORES DA FABRICACAO DE ALIMENTOS, BEBIDAS E FUMO';
        prof.CodigoGrandeGrupo__c = null;
        prof.CodigoSubGrupoPrincipal__c = '84';
        update prof;

        prof.NomeSubGrupoPrincipal__c = null;
        prof.NomeSubGrupo__c = 'TRABALHADORES ARTESANAIS NA  AGROINDUSTRIA, NA INDUSTRIA DE ALIMENTOS E DO FUMO';
        prof.CodigoSubGrupoPrincipal__c = null;
        prof.CodigoSubGrupo__c = '848';
        update prof;

        prof.NomeSubGrupo__c = null;
        prof.NomeFamilia__c = 'MAGAREFES E AFINS';
        prof.CodigoSubGrupo__c = null;
        prof.CodigoFamilia__c = '8485';
        update prof;
        
        prof.NomeFamilia__c = null;
        //PLV-2699 - Inicio
        prof.NomeFantasia__c = 'ABATEDOR';
        //PLV-2699 - Fim
        prof.CodigoFamilia__c = null;
        prof.Codigo__c = '8485-05';
        update prof;
       
      System.assertEquals('ABATEDOR', [SELECT NomeOcupacao__c FROM Profissao__c WHERE Id =: prof.Id].NomeOcupacao__c);
    }


}