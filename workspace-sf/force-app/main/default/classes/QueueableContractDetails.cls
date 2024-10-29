// PLV-2312-28 INICIO
public class QueueableContractDetails implements Queueable, Database.AllowsCallouts
{
	private List<Contract> listContrato { get; set; }
	//PLV-3459 - INICIO - Alterar o processo de Emissão	
	private Integer contadorRegistrosProcessados { get; set; }
	//PLV-3459 - FIM - Alterar o processo de Emissão
	//PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
	private Boolean atualizarOrcamento { get; set; }
	//PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros


	//PLV-3459 - INICIO - Alterar o processo de Emissão
	public QueueableContractDetails(List<Contract> listContrato)
	{
		this.listContrato = listContrato;		
		this.contadorRegistrosProcessados = 0;
		//PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
		this.atualizarOrcamento = true;
		//PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros
	}
	//PLV-3459 - FIM - Alterar o processo de Emissão
	//PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
	public QueueableContractDetails(List<Contract> listContrato, Integer contadorRegistros){
		this.listContrato = listContrato;		
		this.contadorRegistrosProcessados = contadorRegistros;
		this.atualizarOrcamento = true;
	}
	
	public QueueableContractDetails(List<Contract> listContrato, Integer contadorRegistros, Boolean atualizarOrcamentoEntrada)
	{ //PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros

		this.listContrato = listContrato;
		//PLV-3459 - INICIO - Alterar o processo de Emissão
		this.contadorRegistrosProcessados = contadorRegistros;
		//PLV-3459 - FIM - Alterar o processo de Emissão
		//PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
		this.atualizarOrcamento = atualizarOrcamentoEntrada;
		//PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros
	}

	public void execute(QueueableContext queueCont)
	{		
		//PLV-3459 - INICIO - Alterar o processo de Emissão
	
		List<contract> listaContratosParaProcessar = new List<Contract>();	
		
		try
		{

			if(listContrato.isEmpty())
				throw new QueueableContractDetailsException('Não existem contratos para serem processados.');
				
			QueueableQTD__c queueableQtd = [SELECT quantidade__c FROM QueueableQTD__c WHERE name = 'QueueableContractDetails' LIMIT 1];
		
			if(queueableQtd == null || queueableQtd.quantidade__c == null)
				throw new QueueableContractDetailsException('A configuração personalizada QueueableQTD não possui o registro QueueableContractDetails ou não possui quantidade cadastrada para o mesmo.');

			Integer quantidadePorFila = Integer.ValueOf(queueableQtd.quantidade__c);
			
			for(Integer i = 0; i < quantidadePorFila && this.listContrato.size() > contadorRegistrosProcessados; i++){
				
				Contract contratoForAdd = this.listContrato[contadorRegistrosProcessados];
				listaContratosParaProcessar.add(contratoForAdd);
				contadorRegistrosProcessados ++;
			}	
			//PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
			new QuoteBO().atualizarSistemaExterno(listaContratosParaProcessar, this.atualizarOrcamento);//PLV-4539
			//PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros

			//INICIO - PLV-4802 - Guilherme Brito 
			//Valida o segmento do tipo de produto do contrato criado para então duplicar a Declaração de Saúde. Atualmente somente o segmento 'Individual' possui duplicata 
			// PLV-4802-FIX INICIO
			if(listContrato != null && listContrato[0] != null){
				List<Product2> listProduto = [SELECT ID, Name FROM Product2 WHERE ID =: listContrato[0].Produto__c];
				if(listProduto != null && listProduto.size() > 0 ){
					String tipoProduto = listProduto[0].Name; 
					system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ' + tipoProduto); 
					String tipoSegmentoProduto = [SELECT ID, Name, Segmento__c FROM Product2 WHERE Name =: tipoProduto LIMIT 1].Segmento__c; 
					system.debug('tipoSegmentoProduto: ' + tipoSegmentoProduto); 
					List<String> lstSegmentos = new List<String>();  
				
					for(TiposProduto__mdt mdtProdutos : [SELECT MasterLabel FROM TiposProduto__mdt]){ 
						lstSegmentos.add(mdtProdutos.MasterLabel); 
					} 
					
					if (lstSegmentos.contains(tipoSegmentoProduto)) { 
						QuoteBO.getInstance().copiarDeclaracaoSaude(listContrato); 
					}
				}
			}
			// PLV-4802-FIX FIM
			
			//FIM - PLV-4802 - Guilherme Brito 

			system.debug('Lista QueueableContractDetails: ' + listContrato);

			if(contadorRegistrosProcessados != this.listContrato.size()){
				//PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
				System.enqueueJob(new QueueableContractDetails(this.listContrato, contadorRegistrosProcessados, this.atualizarOrcamento));
				//PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros
				return;
			}else{
				QueueableQTD__c queueableQtdSend = [SELECT quantidade__c FROM QueueableQTD__c WHERE name = 'QueueableSendContract' LIMIT 1];			
				if(queueableQtdSend == null || queueableQtdSend.quantidade__c == null){
					throw new QueueableContractDetailsException('A configuração personalizada QueueableQTD não possui o registro QueueableSendContract ou não possui quantidade cadastrada para o mesmo');
				}else if(!Test.isRunningTest()){
					System.enqueueJob(new QueueableSendContract(listaContratosParaProcessar, Integer.valueOf(queueableQtdSend.quantidade__c)));
				}
			}			
		}
		catch(Exception ex)
		{
			System.debug('Erro na geração das PARCELAS: ' + ex.getLineNumber() + ': ' + ex.getMessage());
			throw new QueueableContractDetailsException('Erro no processamento da QueueableContractDetails: ' + ex.getLineNumber() + ': ' + ex.getMessage());
		}		
	}
	public class QueueableContractDetailsException extends Exception{}
	//PLV-3459 - FIM - Alterar o processo de Emissão
}
// PLV-2312-28 FIM