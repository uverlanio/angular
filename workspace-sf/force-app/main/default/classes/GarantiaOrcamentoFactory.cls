/*******************************************************************************************************************************
* GarantiaOrcamento__c Factory class
* @author Isabela Fin - Globant
* @date 06/07/2020
* Classe criada por conta da historia PLV-3989
******************************************************************************************************************************/
@isTest
public class GarantiaOrcamentoFactory extends SObjectFactory{
	private static GarantiaOrcamento__c staticRecord;
    
    private static GarantiaOrcamento__c getRecordStatic(Garantia__c garantia, Opportunity orcamento){
		if(staticRecord == null){
			staticRecord = new GarantiaOrcamento__c(
                Garantia__c = garantia.Id,
                Orcamento__c = orcamento.Id,
                Capital__c = 15000.00,
                TaxaPura__c = 0.1,
                TaxaAnual__c = 0.1,
                TaxaComercial__c = 0.2,
                TaxaMensal__c = 0.5,
                TaxaPuroInterno__c = 0.2,
                TaxaPuroResseguro__c = 0.2,
                PremioComercial__c = 4000.00,
                PremioPuro__c = 4000.00,
                PremioComercialDesconto__c = 4000.00,
                PremioPuroDesconto__c = 4000.00,
                PremioPuroInterno__c = 4000.00,
                PremioPuroResseguro__c = 4000.00
            );
		}
		return staticRecord;
	}
    
    public GarantiaOrcamentoFactory() {
		this(
        	(Garantia__c) new GarantiaFactory().createRecord(),
            (Opportunity) new OrcamentoFactory.VidaIndividual().createRecord()
        );
	}

	public GarantiaOrcamentoFactory(Garantia__c garantia, Opportunity orcamento) {
		super(getRecordStatic(garantia, orcamento));
	}
}