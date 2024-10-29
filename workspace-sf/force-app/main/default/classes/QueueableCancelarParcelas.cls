public class QueueableCancelarParcelas implements Queueable, Database.AllowsCallouts
{
// 	private Quote objPropsota { get; set; }
// 	private Id IdContrato { get; set; }

// 	private Integer empresa { get; set; } 
// 	private Integer sucursal { get; set; }
// 	private Id ramo { get; set; }
// 	private String apolice { get; set; }

//     private static HerokuService herokuServ = HerokuService.getInstance();

	// public QueueableCancelarParcelas(Id IdContrato, Quote objPropsota, Integer empresa, Integer sucursal, Id ramo, String apolice) 
	// {
		// this.objPropsota = objPropsota;
		// this.IdContrato = IdContrato;

		// this.empresa = empresa;
		// this.sucursal = sucursal;
		// this.ramo	= ramo;
		// this.apolice = apolice;
	// }

	public void execute(QueueableContext queueCont)
	{	}}
// 		Integer endosso = null;
// 		String  codigoRamo;
// 		Boolean achouContrato = false;

// 		System.debug('Entrou Queueable Gerar Seguro Heroku');			
// 		ContractBO.getInstance().gerarDadosSeguro(IdContrato);

//         // Se for uma apólice de cancelamento, muda status das apólices anteriores para canceladas
// 		// Método para cancelamento das parcelas dos endossos anteriores
// 		System.debug('==> Executa cancelamento das parcelas dos endossos anteriores');
// 		List<ServiceTO.ParcelaCancelamentoTO> parcelas = new List<ServiceTO.ParcelaCancelamentoTO>();

//         for(Contract contrato : ContractDAO.getInstance().buscarContratosAnteriores(String.valueOf(empresa), String.valueOf(sucursal), ramo, apolice, new List<String>{'Cancelado'}))
//         {
//             if(!String.isBlank(contrato.Endosso__c) && (endosso == null || Integer.valueOf(contrato.Endosso__c) > endosso))
//             {
// 				System.debug('==> Encontrou endosso:' + contrato.Endosso__c + '  Ramo: ' + contrato.CodigoRamo__c);

//                 endosso 	  = Integer.valueOf(contrato.Endosso__c);
//                 codigoRamo    = contrato.CodigoRamo__c;
//                 achouContrato = true;
//             }

// 		}        	
		
// 		if(achouContrato && endosso != null && !String.isBlank(codigoRamo))
// 		{
// 			ServiceTO.ParcelaCancelamentoTO parcela = new ServiceTO.ParcelaCancelamentoTO();

// 			parcela.apolice			= apolice;
// 			parcela.ramo			= codigoRamo;
// 			parcela.endosso			= String.valueOf(endosso);
// 			parcela.sucursal		= String.valueOf(sucursal);

// 			parcelas.add(parcela);

// 			//---Cancela parcelas no Heroku
// 			carcelarParcelasContratoHeroku(parcelas, empresa, sucursal, ramo, apolice);

// 			//--- Cancela contrato no heroku
// 		    carcelarContratoHeroku(empresa, apolice, endosso, sucursal, codigoRamo);

// 	        // Muda Status da Proposta para emitida
// 			System.debug('==> Muda status');
// 			QuoteBO.changeStatus(IdContrato, objPropsota);
// 		}
// 		else
// 		{
// 			// como existem problemas nos dados, todo o processo será revertido
// 			ContractBO.getInstance().rollBackManualContrato(empresa, sucursal, ramo, apolice);
// 		}

// 	}

// 	public static void carcelarParcelasContratoHeroku(List<ServiceTO.ParcelaCancelamentoTO> parcelas, Integer empresa, Integer sucursal, Id ramo, String apolice)
// 	{
// 	    if(!HerokuService.getInstance().cancelarParcelasContrato(parcelas))
// 		{
// 			ContractBO.getInstance().rollBackManualContrato(empresa, sucursal, ramo, apolice);
// 		}

// 	}


// 	public static void carcelarContratoHeroku(Integer empresa, String apolice, Integer endosso, Integer sucursal, String ramo)
// 	{
// 	    ServiceTO.SeguroContratoCancelamentoTO seguro = new ServiceTO.SeguroContratoCancelamentoTO();
// 	    seguro.apolice  = apolice;
// 	    seguro.endosso  = String.valueOf(endosso);
// 	    seguro.sucursal = String.valueOf(sucursal);
// 	    seguro.ramo     = ramo;

// 	    if(!HerokuService.getInstance().cancelarContrato(seguro))
// 		{
// 			ContractBO.getInstance().rollBackManualContrato(empresa, sucursal, ramo, apolice);
// 		}

// 	}


// }