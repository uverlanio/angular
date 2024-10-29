public class ContabilizacaoValoresDAO {

	  private static final ContabilizacaoValoresDAO instancia = new ContabilizacaoValoresDAO();

	  private ContabilizacaoValoresDAO(){}

	  public static ContabilizacaoValoresDAO getInstance(){
	    return instancia;
	  }

	  public List<ContabilizacaoValores__c> buscarContabilizacaoValoresPorData(Date dataProcessamento) {
	    return [SELECT
	    			Id,
	    			Data__c 
			    FROM
			        ContabilizacaoValores__c
			    WHERE
			        Data__c =: dataProcessamento];
			  }



}