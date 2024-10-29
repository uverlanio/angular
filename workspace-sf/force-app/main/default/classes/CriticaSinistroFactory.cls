/*******************************************************************************************************************************
* @author: Leonardo - Avx
* @data: 30/11/2020
* Classe criada por conta da história PLV-4523 - Vida Individual
* Description: Classe Factory do objeto CriticaSinistro__c
******************************************************************************************************************************/
@isTest
public class CriticaSinistroFactory {
	private static Map<String,CriticaSinistro__c> mStaticRecord = new Map<String,CriticaSinistro__c>();

	//----------------------------- CriticaSinistro Template de email RegulacaoResseguro --------------------------------
	private static CriticaSinistro__c getCriticaResseguro(Case sinistro, PagamentoGarantia__c garantiaSinistro){

		if(!mStaticRecord.containsKey('RegulacaoResseguro')){
			
			mStaticRecord.put('RegulacaoResseguro', new CriticaSinistro__c(
                Prioridade__c = '2',
                DisparoAutomaticoEmail__c = true,
                TemplateEmail__c = 'RegulacaoResseguro',
                GarantiaSinistro__c	= garantiaSinistro.id,
                sinistro__c = sinistro.id,
                Email__c = ''
			));
		}
		return mStaticRecord.get('RegulacaoResseguro');
	}

    public class CriticaRegulacaoResseguro extends SObjectFactory{
        
        public CriticaRegulacaoResseguro(){
            this(
                (Case) new CasoFactory.Sinistro().createRecord(),
                (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord()
            );
        }

        public CriticaRegulacaoResseguro(Case sinistro, PagamentoGarantia__c GarantiaSinistro){
            super(getCriticaResseguro(sinistro, GarantiaSinistro));
        }
    }

	//----------------------------- CriticaSinistro Template de email PrevencaoFraude --------------------------------
	private static CriticaSinistro__c getCriticaPrevFraude(Case sinistro, PagamentoGarantia__c garantiaSinistro){

		if(!mStaticRecord.containsKey('PrevencaoFraude')){
			
			mStaticRecord.put('PrevencaoFraude', new CriticaSinistro__c(
                Prioridade__c = '2',
                DisparoAutomaticoEmail__c = true,
                TemplateEmail__c = 'PrevencaoFraude',
                GarantiaSinistro__c	= garantiaSinistro.id,
                sinistro__c = sinistro.id,
                Email__c = ''
			));
		}
		return mStaticRecord.get('PrevencaoFraude');
	}

    public class CriticaPrevencaoFraude extends SObjectFactory{
        
        public CriticaPrevencaoFraude(){
            this(
                (Case) new CasoFactory.Sinistro().createRecord(),
                (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord()
            );
        }

        public CriticaPrevencaoFraude(Case sinistro, PagamentoGarantia__c GarantiaSinistro){
            super(getCriticaPrevFraude(sinistro, GarantiaSinistro));
        }
    }
}