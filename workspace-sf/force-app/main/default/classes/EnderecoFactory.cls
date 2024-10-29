/**
 * @author AVX - Daniel Zampieri
 * @date 2019-09-26
 * @description Endereco__c Factory Class
 */
@isTest
public class EnderecoFactory extends SObjectFactory{
    private static Endereco__c staticRecord;

	private static Endereco__c getRecordStatic(Account conta){

		if(staticRecord == null){
			staticRecord = new Endereco__c(
                CEP__c = '01001-001',
                Bairro__c = 'Centro',
                Logradouro__c = 'Praça da Sé',
                Cidade__c = 'São Paulo',
                Numero__c = '1',
                TipoEndereco__c = 'Recado',
                TipoLogradouro__c = 'Rua',
                Estado__c = 'SP',
                Pais__c = 'Brasil',
                Complemento__c = 'Casa 1',
                Conta__c = conta.Id,
                MaisAtual__c = true
            );
		}
		return staticRecord;
	}

    public EnderecoFactory() {

        this(
            (Account) new AccountFactory.PessoaFisica().createRecord()
        );
    }

    public EnderecoFactory(Account conta) {

        super(getRecordStatic(conta));
    }

}