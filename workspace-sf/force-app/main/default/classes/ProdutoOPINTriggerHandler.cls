//PLV-5230 - INICIO
/**
 * Handler da trigger do objeto ProdutoOPIN__c
 * @author Julio Duarte @ 07/12/2021
 *
 **/
public class ProdutoOPINTriggerHandler extends TriggerHandler  {

	public override void beforeInsert() 
	{
        validarJSON();
	}

    public override void beforeUpdate() 
	{
        validarJSON();
	}

    private void validarJSON() {
                //Obtém o Catalogo OPIN ativo
		CatalogoOPIN__c catalogoOPIN = [SELECT Id FROM CatalogoOPIN__c WHERE Ativo__c = TRUE LIMIT 1];

        //Seta os Pradutos incluídos ao catálogo ativo
        for(ProdutoOPIN__c prodOPIN : (List<ProdutoOPIN__c>)trigger.new) {
            try {
                IntegracaoOpinTO.PersonProductsTO personProductTO = (IntegracaoOpinTO.PersonProductsTO)JSON.deserializeStrict(prodOPIN.DetalhesJSON__c, IntegracaoOpinTO.PersonProductsTO.class);
            } catch (Exception ex) {
                prodOPIN.addError(new ProdutoOPINTriggerHandlerException('Campos Detalhes em JSON inválido'));
            }
            if (Trigger.isInsert) {
                prodOPIN.CatalogoOPIN__c = catalogoOPIN.Id;
            }
        }
    }

    public class ProdutoOPINTriggerHandlerException extends Exception {}
}
//PLV-5230 - FIM