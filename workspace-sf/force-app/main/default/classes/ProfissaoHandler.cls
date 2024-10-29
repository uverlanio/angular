/*********************************************************************************************************************************************************************

@description  Classe que contem a Classe Handler Profissao.
@author Renan Martins - Avanxo
@date 28/08/2019
@Classe criada por conta da história PLV-2585
        
**********************************************************************************************************************************************************************/


public with sharing class ProfissaoHandler extends TriggerHandler {


    private List < Profissao__c > tNew;
    /*private List<Profissao__c> tOld;
    private Map<Id, Profissao__c> tNewMap;
    private Map<Id, Profissao__c> tOldMap;*/

    //Construtor
    public ProfissaoHandler() {

        this.tNew = (List < Profissao__c > ) Trigger.new;
        /*this.tOld = (List<Profissao__c>) Trigger.old;
          this.tNewMap = (Map<Id, Profissao__c>) Trigger.newMap;
          this.tOldMap = (Map<Id, Profissao__c>) Trigger.oldMap;*/
    }

    public override void beforeInsert() {

        setNomePadrao();
        //setCodigoPadrao(); // PLV-4878 INICIO/FIM - LINHA COMENTADA
    }

    public override void beforeUpdate() {

        setNomePadrao();
        //setCodigoPadrao(); // PLV-4878 INICIO/FIM - LINHA COMENTADA
    }

    //Regra que valida Campos das Profissões 
    public void setNomePadrao() {

        for (Profissao__c pf: this.tNew) {

            if (pf.NomeFantasia__c != null) {
                pf.NomeOcupacao__c = pf.NomeFantasia__c;
            } else if (pf.NomeFamilia__c != null) {
                pf.NomeOcupacao__c = pf.NomeFamilia__c;
            } else if (pf.NomeSubGrupo__c != null) {
                pf.NomeOcupacao__c = pf.NomeSubGrupo__c;
            } else if (pf.NomeSubGrupoPrincipal__c != null) {
                pf.NomeOcupacao__c = pf.NomeSubGrupoPrincipal__c;
            } else if (pf.NomeGrandeGrupo__c != null) {
                pf.NomeOcupacao__c = pf.NomeGrandeGrupo__c;
            } 
        }
     }
    
    //Regra que valida os Números de Códigos das Profissões 
    public void setCodigoPadrao(){
         
        for (Profissao__c pf: this.tNew){
            
        	if (pf.Codigo__c != null) { 
                pf.CodigoProfissao__c = pf.Codigo__c;
            } else if (pf.CodigoFamilia__c != null) { 
                pf.CodigoProfissao__c = pf.CodigoFamilia__c;
			} else if (pf.CodigoSubGrupo__c != null) { 
                pf.CodigoProfissao__c = pf.CodigoSubGrupo__c;
			} else if (pf.CodigoSubGrupoPrincipal__c != null) { 
                pf.CodigoProfissao__c = pf.CodigoSubGrupoPrincipal__c;
			} else if (pf.CodigoGrandeGrupo__c != null) { 
                pf.CodigoProfissao__c = pf.CodigoGrandeGrupo__c;
			}
						
        }
    }
}