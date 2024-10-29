/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description Contrato Factory Class
 */
@isTest
public class ContratoFactory{

    private static Map<String,Contract> mStaticRecord = new Map<String,Contract>();

	//PLV-5147 - FIX02 - INICIO
	public static final String EMPRESA = '1';
    public static final String SUCURSAL = '1';
    public static final String CODIGORAMO = '1';
    public static final String NUMEROAPOLICE = '0001';
	//PLV-5147 - FIX02 - FIM


	private static Contract getRecordComParam(Account contaPessoal, Product2 produto, Parceiro__c parceiro){
		Date dataContrato = Date.newInstance(2019, 02, 20);
        
        if(!mStaticRecord.containsKey('ContratoComParam')){
		
		mStaticRecord.put('ContratoComParam',new Contract(
				Name = '100',
                Status = 'Em elaboração',
                StartDate = dataContrato,
                AccountId = contaPessoal.id,
                Produto__c = produto.Id,
                Parceria__c = parceiro.id
				));
		}
		return mStaticRecord.get('ContratoComParam');
	}

	public class ContratoFactoryComParam extends SObjectFactory {
    
    public ContratoFactoryComParam() {

		this(
        	(Account) new AccountFactory.PessoaFisica().createRecord(),
        	(Product2) new ProdutoFactory.ProdutoComercial().createRecord(),
        	(Parceiro__c) new ParceiroFactory().createRecord()
        );
	}

	public ContratoFactoryComParam(Account contaPessoal, Product2 produto, Parceiro__c parceiro) {
       
		super(getRecordComParam(contaPessoal, produto, parceiro));
	   	//PLV-3460 Fix 5 - INICIO
	    QueueableQTD__c qtdRecordDetails = (QueueableQTD__c) new QueueableQTDFactory().createRecord();
        QueueableQTD__c qtdRecordSend = qtdRecordDetails.clone();
        qtdRecordSend.Name = 'QueueableContractDetails';
        qtdRecordSend.Quantidade__c = 20;
        insert qtdRecordSend;
        //PLV-3460 Fix 5 - FIM
    }

	}

	private static Contract getRecordStatic(Account contaPessoal){
		Date dataContrato = Date.newInstance(2019, 02, 20);
        
        if(!mStaticRecord.containsKey('ContratoComParam')){
		
		//PLV-5147 - FIX02 - INICIO
		mStaticRecord.put('ContratoComParam',new Contract(
				Name = '100',
                Status = 'Em elaboração',
                StartDate = dataContrato,
                AccountId = contaPessoal.id,
				Empresa__c = EMPRESA,
				Sucursal__c = SUCURSAL,
				CodigoRamo__c = CODIGORAMO,
				NumeroApolice__c = NUMEROAPOLICE));
		//PLV-5147 - FIX02 - FIM
		}
		return mStaticRecord.get('ContratoComParam');
	}

	public class ContratoFactorySemParam extends SObjectFactory {
    
    public ContratoFactorySemParam() {

		this(
        	(Account) new AccountFactory.PessoaFisica().createRecord()
        );
	}

	public ContratoFactorySemParam(Account contaPessoal) {

		super(getRecordStatic(contaPessoal));
	}
	}

}