//PLV-4148 - INICIO
public class EnviaDadosSAP{
	private static final String mensagemErro = 'Erro no processamento do serviço.';
    @TestVisible
    private static Requisicao_de_Pagamento__c mockRequisicaoPagamento;
    //MGRC-1657 - INICIO
    //PLV-4148 -FIX1 - INICIO
    // @future (callout=true)
	// public static void enviaRequicaoPagamentoAPI(String requisicaoPagamento, String name) {
    //     system.debug('entrou na serviço'+requisicaoPagamento);
    //     String response;  
    //     String body = requisicaoPagamento;
 
	// 	String nomeEndpoint = 'Envia_OP_SAP';
	// 	HttpResponse resposta; 
	// 	//https://tst.portoseguro.com.br/apivida/vida/v1/sinistros/pagamentos
	// 	try {
	// 		resposta = Util.executarHttpRequest(CIVServices.getInstance().gerarEndpoint(nomeEndpoint), 'POST', CIVServices.getInstance().gerarHeaderOAuth2(CIVServices.getInstance().gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);

	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
	// 			response = resposta.getBody();
    //             RetornoSAP obj = RetornoSAP.parse(response);
    //             system.debug('RETORNO SERVICO SAP'+obj);
    //             system.debug('NUMERO DOCUMENTO'+obj.retornoop.numeroDocumento);
                
    //             Requisicao_de_Pagamento__c requisicao = (mockRequisicaoPagamento == null) ? [SELECT Id, Numero_OP_SAP__c FROM Requisicao_de_Pagamento__c WHERE Name =: name LIMIT 1] : mockRequisicaoPagamento;
              
    //             requisicao.Status__c = 'Erro';
    //             if(obj.retornoop.numeroDocumentoOrdemPag != ''){
    //                 system.debug('ATUALIZA REQUISIÇÃO');
    //                 List<Pagamento_de_Sinistro__c> lPagamentoSinistro = [SELECT Requisicao_de_Pagamento__c, Id, OP_SAP__c FROM Pagamento_de_Sinistro__c WHERE Requisicao_de_Pagamento__c =: requisicao.Id];
    //                 List<Pagamento_de_Sinistro__c> atualizaListaPagamentos = new List<Pagamento_de_Sinistro__c>();
    //                 for(Pagamento_de_Sinistro__c p : lPagamentoSinistro){
    //                     p.OP_SAP__c = obj.retornoop.numeroDocumentoOrdemPag;
    //                     //PLV-4148-FIX3 - INICIO
    //                     p.Status__c = 'Pago';
    //                     //PLV-4148-FIX3 - FIM
    //                     //PLV-4148-FIX5 - INICIO
    //                     p.Data_de_pagamento__c = Date.today();
    //                     //PLV-4148-FIX5 - FIM
    //                     atualizaListaPagamentos.add(p);
    //                 }
    //                 update atualizaListaPagamentos;
                    
    //                 requisicao.Numero_OP_SAP__c = obj.retornoop.numeroDocumentoOrdemPag;
    //                 requisicao.data_de_pagamento__c = Date.today();
    //                 requisicao.Status__c = 'Pago';
                    
    //             }
    //             update requisicao;
               
    //                 Note nota = new Note();
    //                 nota.ParentId = requisicao.Id;
    //                 nota.Body = response;
    //                 nota.Title = 'Retorno Integração';
    //                 insert nota;
    //             	system.debug('insert nota'+nota);
                
	// 		}
	// 		else {
	// 			throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
	// 		}
	// 	}
	// 	catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
	// 	}

	
	// }
    //MGRC-1657 - FIM
    //PLV-4148-FIX1 - FIM
    public class CIVServicesException extends Exception { }
    
    
    
    
 
}
//PLV-4148 - FIM