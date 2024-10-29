/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-06
 * @description RamoSeguro__c Factory Class
 */
@isTest
public class RamoSeguroFactory extends SObjectFactory {
	private static RamoSeguro__c staticRecord;

	private static RamoSeguro__c getRecordStatic(Account conta){

		if(staticRecord == null){
			staticRecord = new RamoSeguro__c(
				Name = 'Segurado',
                CodigoEmpresa__c = '214',
                Codigo__c = '2',
                //PLV-2932 - Inicio - IdExterno alterado
                IdExterno__c = '214_9',
                //PLV-2932 - Fim - IdExterno alterado
								Empresa__c = conta.Id,
								CodigoOrigemDoMovimentoBCP__c = '32', //PLV-3773 INICIO/FIM - incluso campo para rega de validação
                Status__c = 'Ativo');
		}
		return staticRecord;
	}

	public RamoSeguroFactory(){

		this(
			(Account) new AccountFactory.PessoaFisica().createRecord()
		);
	}

	public RamoSeguroFactory(Account conta) {

		super(getRecordStatic(conta));
	}

}