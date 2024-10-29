/**
 * @author AVX - Matheus Gomes
 * @date 2019-09-12
 * @description Factory Modalidade
 */
public class ModalidadeFactory extends SObjectFactory {
    
    private static Modalidade__c staticRecord;

    public static Modalidade__c getRecordStatic (RamoSeguro__c ramoSegurado) {
        if(staticRecord == null){
			staticRecord = new Modalidade__c(
                RamoSeguro__c = ramoSegurado.Id,
                Name = 'Factory',
                Codigo__c = '0');
                //Empresa__c = 'Pesq Conta',
                //CodigoEmpresa__c = '',
                //CodigoRamoSeguro__c = '');
		}
		return staticRecord;
    } 
    
    public ModalidadeFactory() {

		this(
            //PLV-2826 - INICIO - Criar oportunidade sem conta
        	(RamoSeguro__c) new RamoSeguroFactory().createRecord()
            //PLV-2826 - FIM - Criar oportunidade sem conta
        );
	}

	public ModalidadeFactory (RamoSeguro__c ramoSegurado) {

		super(getRecordStatic(ramoSegurado));
	}
}