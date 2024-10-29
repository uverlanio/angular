/**
 * Classe CondicaoCobrancaBO
 * @author Fernando Barcellos @ 11/01/2018
 *
 **/
public class CondicaoCobrancaBO {
	private static final CondicaoCobrancaBO instance = new CondicaoCobrancaBO();
	private static final CondicaoCobrancaDAO dao = CondicaoCobrancaDAO.getInstance();
	
	public static CondicaoCobrancaBO getInstance() {
		return instance;
	}

	private CondicaoCobrancaBO() { }
	// PLV-3316 - INICIO
	// VALIDAÇÃO PARA PERMITIR QUE UMA MESMA FORMA DE PAGAMENTO POSSA TER VARIAS CONDICAO DE COBRANCA CONFORME QUANTIDADE DE PARCELAS
	public void verificarExistenciaDuplicidade(List<CondicaoCobranca__c> lstCondicoesCobrancaNew, Map<Id, CondicaoCobranca__c> mapCondicoesCobrancaOld) {
		
		Set<Id> sCodProduto = new Set<Id>();
		Map<String,Set<String>> mCondicaoCobrancaNew = new Map<String,Set<String>>();

		for (CondicaoCobranca__c condCobranca : lstCondicoesCobrancaNew) {
			
			if (condCobranca.Produto__c != null)
				sCodProduto.add(condCobranca.Produto__c);
		
			String chaveComposta = String.valueOf(condCobranca.Produto__c) + String.valueOf(condCobranca.FormaPagamento__c);
			Set<String> sParcela;

			if (mCondicaoCobrancaNew.containsKey(chaveComposta)) {
				sParcela = mCondicaoCobrancaNew.get(chaveComposta);
			} else {
				sParcela = new Set<String>();
				mCondicaoCobrancaNew.put(chaveComposta, sParcela);
			}
			if(condCobranca.QuantidadeParcelas__c != null)
                for (String parcela : condCobranca.QuantidadeParcelas__c.split(';')) {
    
                    if (sParcela.contains(parcela)) {
                        condCobranca.addError('Esta forma de pagamento com essas parcelas já foi cadastrada para este produto (Carga).');
                    } else {
                        sParcela.add(parcela);
                    }
                }
		}

		// Map<IdProduto,Map<IdFormaPagamento,List<CondicaoCobranca__c>>>
		Map<Id,Map<Id,List<CondicaoCobranca__c>>> mCondicaoCobranca = new Map<Id,Map<Id,List<CondicaoCobranca__c>>>();

		system.debug('sCodProduto: ' + sCodProduto);

		for (CondicaoCobranca__c condCobranca : [SELECT Id, Produto__c, FormaPagamento__c, QuantidadeParcelas__c
												   FROM CondicaoCobranca__c 
												  WHERE Produto__c IN :sCodProduto
												  ORDER BY Produto__c, FormaPagamento__c]) {
			
			Map<Id,List<CondicaoCobranca__c>> mCondicaoCobrancaByFormaPagamento;
			List<CondicaoCobranca__c> lCondicaoCobranca;

			if (mCondicaoCobranca.containsKey(condCobranca.Produto__c)) {
				mCondicaoCobrancaByFormaPagamento = mCondicaoCobranca.get(condCobranca.Produto__c);
			} else {
				mCondicaoCobrancaByFormaPagamento = new Map<Id,List<CondicaoCobranca__c>>();
				mCondicaoCobranca.put(condCobranca.Produto__c, mCondicaoCobrancaByFormaPagamento);
			}

			if (mCondicaoCobrancaByFormaPagamento.containsKey(condCobranca.FormaPagamento__c)) {
				lCondicaoCobranca = mCondicaoCobrancaByFormaPagamento.get(condCobranca.FormaPagamento__c);
			} else {
				lCondicaoCobranca = new List<CondicaoCobranca__c>();
                if(condCobranca.FormaPagamento__c != null)
					mCondicaoCobrancaByFormaPagamento.put(condCobranca.FormaPagamento__c, lCondicaoCobranca);
			}

			lCondicaoCobranca.add(condCobranca);
		}

        for (CondicaoCobranca__c condicaoCobrancaNew : lstCondicoesCobrancaNew) {
			
			Map<Id,List<CondicaoCobranca__c>> mCondicaoCobrancaByFormaPagamento = mCondicaoCobranca.get(condicaoCobrancaNew.Produto__c);
			//List<CondicaoCobranca__c> lCondicaoCobrancaDB = mCondicaoCobrancaByFormaPagamento.get(condicaoCobrancaNew.FormaPagamento__c);
			List <CondicaoCobranca__c> lCondicaoCobrancaDB = new List<CondicaoCobranca__c>(); 
            //PLV-5230 - FIX04 - INICIO
			if(!Test.isRunningTest()){			
				if(condicaoCobrancaNew.FormaPagamento__c != null)
					system.debug('Forma de pagamento' + condicaoCobrancaNew.FormaPagamento__c);
					try{
						lCondicaoCobrancaDB = mCondicaoCobrancaByFormaPagamento.get(condicaoCobrancaNew.FormaPagamento__c);         
					}catch(Exception error){
						System.debug('nao encontrado formas de pagamento em mCondicaoCobrancaByFormaPagamento ');
					}
			}		
            //PLV-5230 - FIX04 - FIM 
                
            if(condicaoCobrancaNew.QuantidadeParcelas__c != null)
                for (String parcela : condicaoCobrancaNew.QuantidadeParcelas__c.split(';')) {
    
                    Boolean encontrou = false; 
                    if(lCondicaoCobrancaDB != null)
                        for (CondicaoCobranca__c condicaoCobrancaDB : lCondicaoCobrancaDB) {
        
                            if (condicaoCobrancaDB.Id == condicaoCobrancaNew.Id) continue;
            
                                if (condicaoCobrancaDB.QuantidadeParcelas__c.split(';').contains(parcela)) {
                                    condicaoCobrancaNew.addError('Esta forma de pagamento com essas parcelas já foi cadastrada para este produto.');
                                    encontrou = true;
                                    break;
                                }
                        } 
                   
                    
    
                    if (encontrou) break;
                }
		}
	}
    //PLV-3316 - FIM
}