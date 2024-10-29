/**
 * @author AVX - Leonardo Camacho
 * @date 2019-10-17
 * @description: Grupo do Orçamento Factory Class
 * Criada para a história: PLV_2826 - Criar orçamento sem conta
 */

@isTest
public class grupoOrcamentoFactory extends SObjectFactory{

	private static GrupoOrcamento__c staticRecord;
    
    private static GrupoOrcamento__c getRecordStatic(ContratanteOrcamento__c contratante){
        
		if(staticRecord == null){
			staticRecord = new GrupoOrcamento__c(
				ContratanteOrcamento__c = contratante.Id,
                Name = 'TesteGrupoOrcamento'
            );
		}
		return staticRecord;
	}
    
    public grupoOrcamentoFactory() {

		this(
        	(ContratanteOrcamento__c) new ContratanteOrcamentoFactory().createRecord()
        );
	}

	public grupoOrcamentoFactory(ContratanteOrcamento__c contratante) {

		super(getRecordStatic(contratante));
	}
}