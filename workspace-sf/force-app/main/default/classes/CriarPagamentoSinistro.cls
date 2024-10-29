//PLV-3918 Inicio
public class CriarPagamentoSinistro  {
	public static void inserirPagamentoSinistro(Set<Id> listIds){
		Pagamento_de_Sinistro__c pgSinistro = new Pagamento_de_Sinistro__c();

		List<Case> listCaso = [select Id, Parceiro__c, Parceiro__r.conta__c, ProdutoContratoFormula__c from Case where Id in : (listIds) ];
		
		Case casoObj = listCaso[0];
				
		List<ProdutoParceiro__c> produtoParceiro = [select Id, Valor_do_Atendimento__c, CurrencyIsoCode from ProdutoParceiro__c where  CodigoProdutoParceiro__c  =: casoObj.ProdutoContratoFormula__c and  Parceiro__c =: casoObj.Parceiro__c ]; //PLV-4826 - Inicio/Fim
					
		List<InformacaoBancaria__c> listInformacaobancaria  = [select Id from InformacaoBancaria__c where Conta__c =: casoObj.Parceiro__r.conta__c and Principal__c = true];
		
		List<Pagamento_de_Sinistro__c> listPgSinistro = [select Id from Pagamento_de_Sinistro__c where Caso_de_Sinistro__c =: casoObj.Id];

		if(listPgSinistro.isEmpty()){
			pgSinistro.Caso_de_Sinistro__c				= casoObj.Id;
			pgSinistro.Dados_Bancarios__c				= !listInformacaobancaria.isEmpty() ? listInformacaobancaria[0].Id : null;//PLV-4826 - Inicio/Fim
			pgSinistro.Beneficiario_da_Garantia__c		= casoObj.Parceiro__r.conta__c;			
			pgSinistro.Valor_total_a_ser_indenizado__c	= !produtoParceiro.isEmpty() ? produtoParceiro[0].Valor_do_Atendimento__c : null; //PLV-4826 - Inicio/Fim
			pgSinistro.CurrencyIsoCode					= !produtoParceiro.isEmpty() ? produtoParceiro[0].CurrencyIsoCode : null; //PLV-4826 - Inicio/Fim
			pgSinistro.Tipo_de_Aprova_o__c				= 'Alçada SAP';
			pgSinistro.Tipo_de_OP__c					= 'Operacional';            
			pgSinistro.OP_SAP__c						= null;
			pgSinistro.Status__c						= 'Pendente';
			pgSinistro.Data_Programada_de_Pagamento__c	= null;                           
			pgSinistro.Data_de_pagamento__c				= null;                                      
			pgSinistro.Requisicao_de_Pagamento__c		= null;
			pgSinistro.Sinistro_com_Pendencias__c		= False;

			System.debug('casoObj.Id = '+ casoObj.Id);
		
			upsert pgSinistro;
		}
			
	}
}
//PLV-3918 Fim