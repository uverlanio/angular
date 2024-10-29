/*********************************************************************************************************************************************************************

@description  Classe que contem a Factory Profissao.
@author Renan Martins - Avanxo
@date 28/08/2019
@Classe criada por conta da história PLV-2585
        
**********************************************************************************************************************************************************************/

@isTest
public class ProfissaoFactory extends SObjectFactory {
    private static Profissao__c staticRecord;

    private static Profissao__c getRecordStatic() {

        if (staticRecord == null) {
            staticRecord = new Profissao__c(

                NomeOcupacao__c = Null,
                Name = Null,
                NomeFantasia__c = NULL,
                NomeFamilia__c = Null,
                NomeSubGrupo__c = Null,
                NomeSubGrupoPrincipal__c = Null,
                NomeGrandeGrupo__c = 'teste',

				//PLV-3367 - INICIO
                CodigoProfissao__c = '21111',
                Codigo__c = '21111',
                //PLV-3367 - FIM
                CodigoFamilia__c = Null,
                CodigoSubGrupo__c = Null,
                CodigoSubGrupoPrincipal__c = null,
                CodigoGrandeGrupo__c = '8'
            );
        }
        return staticRecord;
    }



    public ProfissaoFactory() {

        super(getRecordStatic());
    }

}