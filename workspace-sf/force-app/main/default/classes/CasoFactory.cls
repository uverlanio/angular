/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description Case Factory Class
 */
@isTest
public class CasoFactory {

	private static Map<String,Case> mStaticRecord = new Map<String,Case>();

//--------------------------------------Atendimento Sinistro-------------------------------------------	

	private static Case getRecordPaiSinistro(Account contaPessoal){

		if(!mStaticRecord.containsKey('AtendimentoSinistro')){
			Recordtype REC_ID_CASEPAI = RecordTypeBO.buscarTipoRegistro('Case', 'Atendimento');

			mStaticRecord.put('AtendimentoSinistro', new Case(
				RecordTypeId = REC_ID_CASEPAI.Id,
				Status = 'Aberto',
				Status_Dependente__c = 'Em Análise',
                Origin = 'Backoffice',
				AccountId = contaPessoal.Id,
				Subject = 'Test Caso Atendimento Sinistro',
				Vitima__c = 'Filhos',
				Description = 'Test Caso Atendimento Sinistro',
				Dataocorrencia__c = System.today(),
				Type = 'Sinistro',				
                //PLV-3778 - INICIO - remoção da opção 'Morte' do campo TipoEvento__c para este tipo de registro
				TipoEvento__c = 'Acidente', 
                //PLV-3778 - FIM
				Data_Aviso_Cliente__c = System.today())
                // removido para ajuste nas classes de teste PLV - 4535

			);
		}
		return mStaticRecord.get('AtendimentoSinistro');
	}

	public class AtendimentoSinistro extends SObjectFactory {
		
		public AtendimentoSinistro() {

			this(
				(Account) new AccountFactory.PessoaFisica().createRecord()
			);
		}

		public AtendimentoSinistro(Account pContaPessoal) {

			super(getRecordPaiSinistro(pContaPessoal));
			super.FIELD_INTERATOR = 'Description';
		}
	}

//--------------------------------------Atendimento Beneficio-------------------------------------------	

	private static Case getRecordPaiBeneficio(Account contaPessoal){

		if(!mStaticRecord.containsKey('AtendimentoBeneficio')){
			Recordtype REC_ID_CASEPAI = RecordTypeBO.buscarTipoRegistro('Case', 'Atendimento');

			mStaticRecord.put('AtendimentoBeneficio', new Case(
				RecordTypeId = REC_ID_CASEPAI.Id,
				Status = 'Aberto',
				Status_Dependente__c = 'Em Análise',
				AccountId = contaPessoal.Id,
				Subject = 'Test Caso Atendimento Beneficio',
				Vitima__c = 'Filhos',
				Description = 'Test Caso Atendimento Beneficio',
				Dataocorrencia__c = System.today(),
				Type = 'Benefício',
				//PLV-4176 Inicio
				Origin = 'Backoffice',
				//PLV-4176 Fim
                //PLV-3778 - INICIO - remoção da opção 'Morte' do campo TipoEvento__c para este tipo de registro
				TipoEvento__c = 'Acidente',
                //PLV-3778 - FIM
				Data_Aviso_Cliente__c = System.today())
				// removido para ajuste nas classes de teste PLV - 4535

			);
		}
		return mStaticRecord.get('AtendimentoBeneficio');
	}

	public class AtendimentoBeneficio extends SObjectFactory {
		
		public AtendimentoBeneficio() {

			this(
				(Account) new AccountFactory.PessoaFisica().createRecord()
			);
		}

		public AtendimentoBeneficio(Account pContaPessoal) {

			super(getRecordPaiBeneficio(pContaPessoal));
			super.FIELD_INTERATOR = 'Description';
		}
	}	

//--------------------------------------Sinistro -------------------------------------------

	private static Case getRecordSinistro(Case casoPai, Account contaPessoal){

		if(!mStaticRecord.containsKey('Sinistro')){
			Recordtype REC_ID_CASESINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

			mStaticRecord.put('Sinistro', new Case(
				RecordTypeId = REC_ID_CASESINISTRO.Id,
				Status = 'Avisar',
				Status_Dependente__c = 'Em Análise',
				Origin = 'Atendimento',
				ParentId = casoPai.Id,
				AccountId = contaPessoal.Id,
				Subject = 'Test Caso Sinistro',
				Vitima__c = 'Filhos',
				Description = 'TestCasoSinistro',
				Dataocorrencia__c = System.today(),
				Type = 'Sinistro',
                //PLV-3778 - INICIO  - remoção da opção 'Morte' do campo TipoEvento__c para este tipo de registro
				TipoEvento__c = 'Acidente'
				// removido para ajuste nas classes de teste PLV - 4535
				)
                //PLV-3778 - FIM              
			);
		}
		return mStaticRecord.get('Sinistro');
	}

	public class Sinistro extends SObjectFactory {
	
		public Sinistro() {

			this(
				(Case) new CasoFactory.AtendimentoSinistro().createRecord(),
				(Account) new AccountFactory.PessoaFisica().createRecord()
			);
		}

		public Sinistro(Case pCasoPai, Account pContaPessoal) {

			super(getRecordSinistro(pCasoPai, pContaPessoal));
		}
	}

//--------------------------------------Beneficio -------------------------------------------

private static Case getRecordBeneficio(Case casoPai, Account contaPessoal){

		if(!mStaticRecord.containsKey('Beneficio')){
			Recordtype REC_ID_CASEBeneficio = RecordTypeBO.buscarTipoRegistro('Case', 'Beneficio');

			mStaticRecord.put('Beneficio', new Case(
				RecordTypeId = REC_ID_CASEBeneficio.Id,
				Status = 'Avisar',
				Status_Dependente__c = 'Em Análise',
				Origin = 'Atendimento',
				ParentId = casoPai.Id,
				AccountId = contaPessoal.Id,
				Subject = 'Test Caso Beneficio',
				Vitima__c = 'Filhos',
				Description = 'Test Caso Beneficio',
				Dataocorrencia__c = System.today(),
				Type = 'Benefício',
				// removido para ajuste nas classes de teste PLV - 4535
				TipoEvento__c = 'Morte')
			);
		}
		return mStaticRecord.get('Beneficio');
	}

	public class Beneficio extends SObjectFactory {
	
		public Beneficio() {

			this(
				(Case) new CasoFactory.AtendimentoBeneficio().createRecord(),
				(Account) new AccountFactory.PessoaFisica().createRecord()
			);
		}

		public Beneficio(Case pCasoPai, Account pContaPessoal) {

			super(getRecordBeneficio(pCasoPai, pContaPessoal));
			super.FIELD_INTERATOR = 'Description';
		}

	}

}