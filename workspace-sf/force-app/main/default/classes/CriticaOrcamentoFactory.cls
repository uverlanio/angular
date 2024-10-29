/**
 * @author AVX - Leonardo Camacho
 * @date 2019-08-26
 * @description: Crítica do orçamento Factory Class
 */

@isTest
public class CriticaOrcamentoFactory {

	private static Map<String,CriticaOrcamento__c> mStaticRecord = new Map<String,CriticaOrcamento__c>();
          
	//----------------------------- CriticaOrçamento Fila Médica - Orçamento --------------------------------
	
    private static CriticaOrcamento__c criarRegistroFilaMedicaOrcamento(Opportunity orcamento){

  		if(!mStaticRecord.containsKey('FilaMedicaOrcamento')){
			
			mStaticRecord.put('FilaMedicaOrcamento', new CriticaOrcamento__c(
				Area__c = 'MED',
                Codigo__c = '000MED',
				Status__c = 'Pendente',
				Tipo__c = 'Análise',
				Severidade__c = 1,
				Origem__c = 'ODM',
              	Orcamento__c = orcamento.Id)
               );                      
		}
		return mStaticRecord.get('FilaMedicaOrcamento');
	}

	public class FilaMedicaOrcamento extends SObjectFactory {

        public FilaMedicaOrcamento(){
				
            this(
                	//PLV_2673 - INICIO - Ação em caso de ultrapassar validade de orçamento
                	(Opportunity) new OrcamentoFactory.VidaIndividual().createRecord()
                	//PLV_2673 - INICIO - Ação em caso de ultrapassar validade de orçamento
            	);
        }
        
		public FilaMedicaOrcamento(Opportunity orcamento){

			super(criarRegistroFilaMedicaOrcamento(orcamento));
		}

	}
	
	//----------------------------- CriticaOrçamento Fila Técnica - Orçamento -------------------------------
	@isTest
    private static CriticaOrcamento__c criarRegistroFilaTecnicaOrcamento(){

		if(!mStaticRecord.containsKey('FilaTecnicaOrcamento')){
			
			mStaticRecord.put('FilaTecnicaOrcamento', new CriticaOrcamento__c(
				Area__c = 'TEC',
                Codigo__c = '000TEC',
				Status__c = 'Pendente',
				Tipo__c = 'Análise',
				Severidade__c = 1,
				Origem__c = 'ODM')
			);
		}
		return mStaticRecord.get('FilaTecnicaOrcamento');
	}
    
    public class FilaTecnicaOrcamento extends SObjectFactory {

		public FilaTecnicaOrcamento(){

			super(criarRegistroFilaTecnicaOrcamento());
		}

	}

	 
	//-----------------------------CriticaOrcamento Fila Coordenador - Orçamento -------------------------------
	@isTest
    private static CriticaOrcamento__c criarRegistroFilaCoordenador(){

		if(!mStaticRecord.containsKey('FilaCoordenadorOrcamento')){
			
			mStaticRecord.put('FilaCoordenadorOrcamento', new CriticaOrcamento__c(
				Area__c = 'COR',
                Codigo__c = '000COR',
				Status__c = 'Pendente',
				Tipo__c = 'Análise',
				Severidade__c = 2,
				Origem__c = 'ODM')
			);
		}
		return mStaticRecord.get('FilaCoordenadorOrcamento');
	}

    
	public class FilaCoordenadorOrcamento extends SObjectFactory {

		public FilaCoordenadorOrcamento(){

			super(criarRegistroFilaCoordenador());
		}

	}
}