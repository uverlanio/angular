public with sharing class ParcelamentoContratoTO
{
	public MetaTO meta { get; set; }
	public List<DataTO> data { get; set; }

	public class MetaTO 
	{
		public String dataExecucao { get; set; }
		public String servico { get; set; }
		public Integer statusHttp { get; set; }
		public String mensagem { get; set; }
	}

	public class DataTO 
	{
		public Integer idfatura { get; set; }
		public String status { get; set; }
		public String endosso { get; set; }
		public String idexterno { get; set; }
		public String valorparcela { get; set; }
		public String seguradosalesforce { get; set; }
		public String vidasalesforce { get; set; }
		public String valoriof { get; set; }
		public Integer id { get; set; }
		public String empresa { get; set; }
		public String ramo { get; set; }
		public Integer numeroparcela { get; set; }
		public String apolice { get; set; }
		public String responsavelfinanceiro { get; set; }
		public String titulo { get; set; }
		public Integer origemproposta { get; set; }
		public String idparceiro { get; set; }
		public String datavencimento { get; set; }
		public String contrato { get; set; }
		public String numeroproposta { get; set; }
		public String valorliquido { get; set; }
		public String sucursal { get; set; }
		// INICIO | PLV-2216
		public String dataPagamentoParceiro { get; set; }
		// FIM | PLV-2216
		//PLV-4286 - INICIO
		public String datapagamento { get; set; }
		//PLV-4286 - FIM
		public String valoragenciamento { get; set; } //PLV-4601 - INICIO/FIM
	}

	//PLV-4949 FIX 1 - INÍCIO
	public static ParcelamentoContratoTO DTOParcelaContrato(List<public_parcelacontrato__x> parcelas){
		
		ParcelamentoContratoTO parcelaToReturn = new ParcelamentoContratoTO();
		parcelaToReturn.data = new List<DataTO>();
		
		//VIAG-248 - FIX - INICIO
		if(parcelas != null && !parcelas.isEmpty()){
		//VIAG-248 - FIX - FIM		
			for (public_parcelacontrato__x parcela : parcelas){
				DataTO dataToReturn = new DataTO();
				//PLV-4949 FIX 4 - INÍCIO
				dataToReturn.id = integer.valueOf(parcela.id__c);
				dataToReturn.datavencimento = String.valueOf(parcela.datavencimento__c);
				dataToReturn.numeroparcela = integer.valueOf(parcela.numeroparcela__c);
				dataToReturn.valoriof = String.valueOf(parcela.valoriof__c);
				dataToReturn.valorliquido = String.valueOf(parcela.valorliquido__c);
				dataToReturn.idfatura = integer.valueOf(parcela.idfatura__c);
				dataToReturn.idexterno = parcela.idexterno__c;
				dataToReturn.status = parcela.status__c;
				dataToReturn.valorliquido = String.valueOf(parcela.valorliquido__c);
				dataToReturn.valorparcela = String.valueOf(parcela.valorparcela__c);
				//PLV-4949 FIX 4 - FIM
				parcelaToReturn.data.add(dataToReturn);
			}
		}
		return parcelaToReturn;
	}
	//PLV-4949 FIX 1 - FIM
}