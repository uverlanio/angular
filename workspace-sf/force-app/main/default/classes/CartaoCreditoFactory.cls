/**
 * @author AVX - Renato Matheus Simião
 * @date 2019-09-11
 * @description Cartao Credito Factory Class (CartaoCredito__c)
 */
 @isTest
public class CartaoCreditoFactory{

	private static Map<String,CartaoCredito__c> mStaticRecord = new Map<String,CartaoCredito__c>();
    private static String teste = 'teste10';

//-----------------------------Cartao Credito Pessoa Física------------------------------------------

	private static CartaoCredito__c getRecordPessoaFisica(Account pAccount){

		if(!mStaticRecord.containsKey('PessoaFisica')){
		
			mStaticRecord.put('PessoaFisica', new CartaoCredito__c(
				Conta__c = pAccount.Id,
                NomeTitular__c = 'Porto Seguro Pessoa Fisica',
                NumeroCartao__c = '1234.5678.1234.5678',
                CodigoSeguranca__c = '123',
				Vencimento__c = '12/'+Date.today().year(),
                //PLV_2822 - INICIO - Informações do cartão de crédito não podem ser armazenadas no SF
                Ticket__c = '5678'
                //PLV_2822 - FIM - Informações do cartão de crédito não podem ser armazenadas no SF
            ));
		}
		return mStaticRecord.get('PessoaFisica');
	}

    public class PessoaFisica extends SObjectFactory {

        public PessoaFisica() {

            this(
                (Account) new AccountFactory.PessoaFisica().createRecord()
            );
        }

        public PessoaFisica(Account pAccount){

            super(getRecordPessoaFisica(pAccount));
        }
    }

    //------------------------------Cartao Credito Pessoa Jurídica----------------------------------------

    private static CartaoCredito__c getRecordPessoaJuridica(Account pAccount){

        if(!mStaticRecord.containsKey('PessoaJuridica')){
            //PLV_2822 - INICIO - Informações do cartão de crédito não podem ser armazenadas no SF
            mStaticRecord.put('PessoaJuridica', new CartaoCredito__c(
            //PLV_2822 - FIM - Informações do cartão de crédito não podem ser armazenadas no SF
                Conta__c = pAccount.Id,
                NomeTitular__c = 'Porto Seguro Pessoa Juridica',
                NumeroCartao__c = '1234.5678.1234.5679',
                CodigoSeguranca__c = '124',
                Vencimento__c = '12/'+Date.today().year(),
                //PLV_2822 - INICIO - Informações do cartão de crédito não podem ser armazenadas no SF
                Ticket__c = '5679'
                //PLV_2822 - FIM - Informações do cartão de crédito não podem ser armazenadas no SF
            ));
        }
        return mStaticRecord.get('PessoaJuridica');
    }

    public class PessoaJuridica extends SObjectFactory {
        
        public PessoaJuridica() {

            this(
                (Account) new AccountFactory.PessoaJuridica().createRecord()
            );
        }

        public PessoaJuridica(Account pAccount) {

            super(getRecordPessoaJuridica(pAccount));
        }
    }
}