/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description Segurado do Contrato Factory Class
 */

@isTest
public class SeguradoContratoFactory extends SObjectFactory{
	private static SeguradoContrato__c staticRecord;
    
    private static SeguradoContrato__c getRecordStatic(Account contaPessoal, GrupoContrato__c grupo){
        //PLV-3658 - INICIO
        Date dataVigenciaInicial = System.today().addDays(-5);
        Date dataVigenciaFinal = System.today().addDays(5);
        //PLV-3658 - FIM
        
		if(staticRecord == null){
			staticRecord = new SeguradoContrato__c(
                Conta__c = contaPessoal.Id,
                GrupoContrato__c = grupo.Id,
                VigenciaInicial__c = dataVigenciaInicial,
                VIgenciaFinal__c = dataVigenciaFinal
            );
		}
		return staticRecord;
	}
    
    public SeguradoContratoFactory() {

		this(
        	(Account) new AccountFactory.PessoaFisica().createRecord(),
            (GrupoContrato__c) new GrupoFactory().createRecord()
        );
	}

	public SeguradoContratoFactory(Account contaPessoal, GrupoContrato__c grupo) {

		super(getRecordStatic(contaPessoal, grupo));
	}
}