/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description Beneficiário Garantia Factory Class
 */
@isTest
public class BeneficiarioGarantiaFactory {

	private static Map<String,BeneficiarioGarantia__c> mStaticRecord = new Map<String,BeneficiarioGarantia__c>();

//--------------------Beneficiario com Info Bancaria Pessoa Física------------------------------------------

	private static BeneficiarioGarantia__c getRecordInfoPessoaFisica(Account contaFisica, InformacaoBancaria__c infoBanc, PagamentoGarantia__c pagGaran){

		if(!mStaticRecord.containsKey('BenePessoaFisica')){
			
			mStaticRecord.put('BenePessoaFisica', new BeneficiarioGarantia__c(
				//Percentual_de_indenizacao__c = 50.00, //PLV-4070 - INICIO/FIM
				Conta__c = contaFisica.Id,
				Informacao_bancaria__c = infoBanc.Id,
				Pagamento_de_garantia__c = pagGaran.Id,
				Tipo_de_Pagamento__c = 'Cheque',
				Sucursal_Destino_de_Cheque__c = 1,
                StatusSerasa__c = 'Atualizado',
				Status__c = 'Pendente',
				//PLV-2403 - Inicio - Código adicionado para atender regra de negócio
				ValorIndenizacao__c = 50.00, //PLV-4070 - INICIO/FIM 
				InformarIndenizacao__c = 'Valor de Indenização' //PLV-4070 - INICIO/FIM 
				// InformarIndenizacao__c = '% de Indenização' //PLV-4070 - INICIO/FIM
			)
			);
				//PLV-2403- Fim - Código adicionado para atender regra de negócio
		}
		return mStaticRecord.get('BenePessoaFisica');
	}

public class BenePessoaFisica extends SObjectFactory {

	public BenePessoaFisica() {

		this(
			(Account) new AccountFactory.PessoaFisica().createRecord(),
			(InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord(),
			(PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord()
		);
	}

	public BenePessoaFisica(Account contaFisica, InformacaoBancaria__c infoBanc, PagamentoGarantia__c pagGaran){

		super(getRecordInfoPessoaFisica(contaFisica, infoBanc, pagGaran));
	}

}

//------------------------------Info Bancaria Pessoa Jurídica----------------------------------------

	private static BeneficiarioGarantia__c getRecordInfoPessoaJuridica(Account contaJuridica, InformacaoBancaria__c infoBanc, PagamentoGarantia__c pagGaran){

		if(!mStaticRecord.containsKey('InfoPessoaJuridica')){

			mStaticRecord.put('InfoPessoaJuridica', new BeneficiarioGarantia__c(
				// Percentual_de_indenizacao__c = 50.00, //PLV-4070 - INICIO/FIM 
				Conta__c = contaJuridica.Id,
				Informacao_bancaria__c = infoBanc.Id,
				Pagamento_de_garantia__c = pagGaran.Id,
				Status__c = 'Pendente',
				//PLV-2403 - Inicio - Código adicionado para atender regra de negócio
				ValorIndenizacao__c = 50.00, //PLV-4070 - INICIO/FIM 
				InformarIndenizacao__c = 'Valor de Indenização' //PLV-4070 - INICIO/FIM 
				// InformarIndenizacao__c = '% de Indenização' //PLV-4070 - INICIO/FIM 
				)
			);	//PLV-2403- Fim - Código adicionado para atender regra de negócio
		}
		return mStaticRecord.get('InfoPessoaJuridica');
	}

public class InfoPessoaJuridica extends SObjectFactory {
	
	public InfoPessoaJuridica() {

		this(
			(Account) new AccountFactory.PessoaJuridica().createRecord(),
			(InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaJuridica().createRecord(),
			(PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord()
		);
	}

	public InfoPessoaJuridica(Account contaJuridica, InformacaoBancaria__c infoBanc, PagamentoGarantia__c pagGaran) {

		super(getRecordInfoPessoaJuridica(contaJuridica, infoBanc, pagGaran));
	}
}

}