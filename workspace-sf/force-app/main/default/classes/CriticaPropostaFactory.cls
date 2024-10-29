//PLV-2418 - Início - Classe de Factory para o objeto Criticas da Proposta
/**
 * @author AVX - Isabela Fin
 * @date 2019-07-11
 * @description CriticaPropostaFactory Factory Class
 */
@isTest
public class CriticaPropostaFactory {
	private static Map<String,CriticaProposta__c> mStaticRecord = new Map<String,CriticaProposta__c>();

	//-----------------------------CriticaProposta Fila Médica--------------------------------
	private static CriticaProposta__c getRecordFilaMedica(){

		if(!mStaticRecord.containsKey('FilaMedica')){
			
			mStaticRecord.put('FilaMedica', new CriticaProposta__c(
				Area__c = 'MED',
                Codigo__c = '00000M',
				Status__c = 'Pendente',
				Tipo__c = 'Analise',
				Severidade__c = 1,
				Origem__c = 'ODM')
			);
		}
		return mStaticRecord.get('FilaMedica');
	}

	public class FilaMedica extends SObjectFactory {

		public FilaMedica(){

			super(getRecordFilaMedica());
		}

	}
	
	//-----------------------------CriticaProposta Fila Técnica--------------------------------
	private static CriticaProposta__c getRecordFilaTecnica(){

		if(!mStaticRecord.containsKey('FilaTecnica')){
			
			mStaticRecord.put('FilaTecnica', new CriticaProposta__c(
				Area__c = 'TEC',
                Codigo__c = '00000T',
				Status__c = 'Pendente',
				Tipo__c = 'Analise',
				Severidade__c = 1,
				Origem__c = 'ODM')
			);
		}
		return mStaticRecord.get('FilaTecnica');
	}

	public class FilaTecnica extends SObjectFactory {

		public FilaTecnica(){

			super(getRecordFilaTecnica());
		}

	}

	 //PLV-2418 - Início - Metodo para testes de encaminhamento de registros para a fila do Coordenador.
	//-----------------------------CriticaProposta Fila Coordenador--------------------------------
	private static CriticaProposta__c getRecordFilaCoordenador(){

		if(!mStaticRecord.containsKey('Fila_Coordenador')){
			
			mStaticRecord.put('Fila_Coordenador', new CriticaProposta__c(
				Area__c = 'COR',
                Codigo__c = '00000C',
				Status__c = 'Pendente',
				Tipo__c = 'Analise',
				Severidade__c = 2,
				Origem__c = 'ODM')
			);
		}
		return mStaticRecord.get('Fila_Coordenador');
	}

	public class FilaCoordenador extends SObjectFactory {

		public FilaCoordenador(){

			super(getRecordFilaCoordenador());
		}

	}

	//PLV-4449-VI - INICIO
	//-----------------------------CriticaProposta Docusign--------------------------------
	private static CriticaProposta__c getRecordDocusign(Quote proposta){

		if(!mStaticRecord.containsKey('Docusign')){
			
			mStaticRecord.put('Docusign', new CriticaProposta__c(
				Proposta__c = proposta.Id,
            	MomentoAnalise__c = 'Palavra Final',
            	Status__c = 'Pendente',
				Integracao__c = 'DOCUSIGN')
			);
		}
		return mStaticRecord.get('Docusign');
	}

	public class Docusign extends SObjectFactory {
		public Docusign() {
			this(
				(Quote) new PropostaFactory().createRecord()
			);
		}

		public Docusign(Quote proposta){
			super(getRecordDocusign(proposta));
		}
	}
	//PLV-4449-VI - FIM
}
 //PLV-2418 - Início - Metodo para testes de encaminhamento de registros para a fila do Coordenador.
//PLV-2418 - Fim - Classe de Factory para o objeto Criticas da Proposta