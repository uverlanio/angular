/**
 * @author AVX - Leonardo Camacho
 * @date 2019-10-17
 * @description: Contratante do Orçamento Factory Class
 * Criada para a história: PLV_2826 - Criar oportunidade sem conta
 */

@isTest
public class contratanteOrcamentoFactory extends SObjectFactory{

    private static ContratanteOrcamento__c staticRecord;
    
    private static ContratanteOrcamento__c getRecordStatic(Opportunity orcamento){
        
		if(staticRecord == null){
			staticRecord = new ContratanteOrcamento__c(
				Orcamento__c = orcamento.Id,
                Tipo__c = 'Principal'
            );
		}
		return staticRecord;
	}
    
    public contratanteOrcamentoFactory() {

		this(
        	(Opportunity) new OrcamentoFactory.VidaIndividual().createRecord()
        );
	}

	public contratanteOrcamentoFactory(Opportunity orcamento) {

		super(getRecordStatic(orcamento));
	}
}