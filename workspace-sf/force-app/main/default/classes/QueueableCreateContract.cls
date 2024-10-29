// PLV-2312-28 INICIO
public class QueueableCreateContract implements Queueable, Database.AllowsCallouts
{
	private List<Quote> listProposta { get; set; }
	private Set<Id> IdsQuotes { get; set; }

	public QueueableCreateContract(List<Quote> listProposta)
	{
		this.listProposta = listProposta;
	}

	public void execute(QueueableContext queueCont)
	{
		try
		{
			// Busca as propostas
			List<Contract> listContrato = new QuoteBO().processarPropostaParaContrato(listProposta);//PLV-4539

			// Envia dados para sistemas externos
			if(!listContrato.isEmpty() && !Test.isRunningTest()){
				System.enqueueJob(new QueueableContractDetails(listContrato));
			}

		} catch(Exception ex)
		{
			//LogBO.logExcepiton(ex);
		}

	}
}
// PLV-2312-28 FIM