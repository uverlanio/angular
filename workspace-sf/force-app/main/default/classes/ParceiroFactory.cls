/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-19
 * @description Parceiro__c Factory Class
 */
@isTest
public class ParceiroFactory extends SObjectFactory{
	private static Parceiro__c staticRecord;

	private static Parceiro__c getRecordStatic(Account contaPessoal, FormaPagamento__c formaPagamento){

		if(staticRecord == null){
			staticRecord = new Parceiro__c(
				ApoliceFaturamento__c = '1',
                DiaFaturamento__c = '15',
                DiaPreFaturamento__c = '20',
                PrazoVencimento__c = '10',
                Conta__c = contaPessoal.Id,
                FaturaProdutosSeparados__c = 'Sim',
                PossuiAnexoFatura__c = 'Nao',
                FormaPagamento__c = formaPagamento.Id,
                SiglaParceiro__c = 'PAR',
                Empresa__c = '12',
                Sucursal__c = '12',
                Ramo__c = '12');
		}
		return staticRecord;
	}

	public ParceiroFactory(){

		this(
			(Account) new AccountFactory.PessoaFisica().createRecord(),
			(FormaPagamento__c) new FormaPagamentoFactory().createRecord()
		);
	}

	public ParceiroFactory(Account contaPessoal, FormaPagamento__c formaPagamento) {

		super(getRecordStatic(contaPessoal, formaPagamento));
	}
}