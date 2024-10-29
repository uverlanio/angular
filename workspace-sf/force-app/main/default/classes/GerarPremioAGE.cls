//PLV-4601 - Inicio
public class GerarPremioAGE {
	//PLV-4973 - INICIO
    public static Map<String,Object> gravaValorEndosso(Contract contratoAtual, RemuneracaoContrato__c remuneracao, Integer numeroparcela){
		Map<String,Object> mapToReturn = new Map<String,Object>();
		
		if( contratoAtual == null
		|| String.isBlank(contratoAtual.ContratoOriginal__c)
		|| remuneracao == null
		|| remuneracao.FavorecidosContrato__r.isEmpty()
		|| remuneracao.Percentual__c == 0) {
			mapToReturn.put('proRataAgenciador',calculoValorAgenciamentoPadrao(contratoAtual, remuneracao, numeroparcela));
			return mapToReturn;
		}
		
		
		Decimal newValoragenc;
		double premioTotalAtual			= contratoAtual.ContratoOriginal__r.PremioComercial__c > 0 ? contratoAtual.ContratoOriginal__r.PremioComercial__c : contratoAtual.ContratoOriginal__r.PremioTotal__c;
		double percAgenc   				= remuneracao.Percentual__c;

		Contract contratoOriginal = [
			SELECT
				Id,
				(
					SELECT Id,QuantidadeParcelas__c FROM ContratantesContrato__r
				)
			FROM Contract
			WHERE Id = :contratoAtual.contratoOriginal__r.Id
		];

		if(contratoOriginal == null){
			  mapToReturn.put('proRataAgenciador',calculoValorAgenciamentoPadrao(contratoAtual, remuneracao, numeroparcela));
			  return mapToReturn;
			}

		String papel = remuneracao.FavorecidosContrato__r[0].Papel__c;
		//if(papel != 'Corretor') return calculoValorAgenciamentoPadrao(contratoAtual, remuneracao, numeroparcela);//PLV-4973-INICIO/FIM

		if(numeroparcela == 2) {mapToReturn.put('proRataAgenciador', 0); return mapToReturn;}

		double agencPago = 0;
		double agencTotalPago= 0;
		double excludenteCorretor = 0;//VALOR QUE FOI PARA O AGENCIADOR, QUE NÃO SERÁ COBRADO DO CORRETOR
		double totalpago 	= 0;
		ParcelamentoContratoTO retornoPercela = ContractFacade.getInstance().ObterParcelasContratoSegurado(contratoOriginal.ContratantesContrato__r[0].Id);

		// PLV-4601- FIX INICIO
		Integer qtdParcelasPagas = 0;
		Set<Integer> numeroPaga = new Set<Integer>();
		Map<Integer,ParcelamentoContratoTO.DataTO> mapParcelas = new Map<Integer,ParcelamentoContratoTO.DataTO>();
		for(ParcelamentoContratoTO.DataTO parc : retornoPercela.data) {
			if ( parc.status=='PAGA' ) {
				totalpago += Double.valueOf(parc.valorparcela); // PLV-4172 - FIX 3
				qtdParcelasPagas++;
				numeroPaga.add(parc.numeroparcela);
				agencTotalPago += Double.valueOf(parc.valoragenciamento);
				if(contratoOriginal.ContratantesContrato__r[0].QuantidadeParcelas__c==12 && ((percAgenc == 100 && parc.numeroparcela==1) || (percAgenc == 200 && (parc.numeroparcela==1 || parc.numeroparcela==2))))
					excludenteCorretor+= parc.valoragenciamento!=null ? Double.valueOf(parc.valoragenciamento) : 0;
				else if(contratoOriginal.ContratantesContrato__r[0].QuantidadeParcelas__c==11){
					excludenteCorretor+= parc.valoragenciamento!=null ? Double.valueOf(parc.valoragenciamento) : 0;
				}
			}
			mapParcelas.put(parc.numeroparcela,parc);
			agencPago += Double.valueOf(parc.valoragenciamento);
		}
		mapToReturn.put('excludenteCorretor',excludenteCorretor);
		mapToReturn.put('totalPagoParcelas',agencTotalPago);
		mapToReturn.put('qtdParcelasPagas',qtdParcelasPagas);
		mapToReturn.put('percAgenc',percAgenc);
		mapToReturn.put('originalParcelas',contratoOriginal.ContratantesContrato__r[0].QuantidadeParcelas__c);
		
		// newValoragenc = (premioTotalAtual < 0) ? ((totalpago + (retornoSinapseTotal)) * (percAgenc/(1200))) - agencPago : ((totalpago + (retornoSinapseLiquido)) * (percAgenc/(1200))) - agencPago;
		
		Integer data1 = (contratoAtual.StartDate.daysBetween(contratoAtual.contratoOriginal__r.StartDate));
		Integer data2 = ((contratoAtual.contratoOriginal__r.StartDate + 364).daysBetween(contratoAtual.contratoOriginal__r.StartDate));
		data1 = data1 < 0 ? data1 * -1 : data1;
		data2 = data2 < 0 ? data2 * -1 : data2;
		//PLV-5094 - FIX3 - INICIO
		Decimal pro_rata = Decimal.valueOf(Double.valueOf(data1)/Double.valueOf(data2)).setScale(7);

		//newValoragenc = (premioTotalAtual * ( ( Math.min(percAgenc, (100 * qtdParcelasPagas)) - (pro_rata * percAgenc) ) / 1200 )).setScale(2, RoundingMode.HALF_UP);
		newValoragenc = agencTotalPago * ( 1 - pro_rata );
		//PLV-5094 - FIX3 - FIM

		System.debug('contratoAtual.StartDate ' + contratoAtual.StartDate);
		System.debug('contratoAtual.contratoOriginal__r.StartDate ' + contratoAtual.contratoOriginal__r.StartDate);
		System.debug('contratoAtual.contratoOriginal__r.VigenciaFinal__c ' + contratoAtual.contratoOriginal__r.VigenciaFinal__c);
		System.debug('pro_rata ' + pro_rata);
		System.debug('data1 ' + data1);
		System.debug('data2 ' + data2);
		System.debug('premioTotalAtual ' + premioTotalAtual);
		System.debug('percAgenc ' + percAgenc);
		System.debug('agencTotalPago ' + agencTotalPago);
		System.debug('qtdParcelasPagas ' + qtdParcelasPagas);
		System.debug('Math.min(percAgenc, (100 * qtdParcelasPagas)) ' + Math.min(percAgenc, (100 * qtdParcelasPagas)));
		System.debug('Valor agenciamento enviado: ' + newValoragenc);
		// PLV-4601-FIX2 FIM
		// PLV-4601- FIX FIM
		if(newValoragenc >= 0) {mapToReturn.put('proRataAgenciador',newValoragenc);return mapToReturn;}

		HerokuService.extRemuneracaoCancelaTO req = new HerokuService.extRemuneracaoCancelaTO();

		req.idconta 							= contratoAtual.AccountId;
		req.cnpjcpf 							= contratoAtual.Account.Cpf__c != null? contratoAtual.Account.Cpf__c : contratoAtual.Account.Cnpj__c;
		req.datacancelamento 					= null;
		req.empresa 							= contratoAtual.Empresa__c;
		req.sucursal 							= contratoAtual.Sucursal__c;
		req.ramo 								= contratoAtual.CodigoRamo__c;
		req.apolice 							= contratoAtual.Name.substring(0, contratoAtual.Name.length()-1) + (contratoAtual.Endosso__c + 1); // PLV-4172 - FIX 2
		req.endosso 							= contratoAtual.Endosso__c + 1;
		req.origem 								= contratoAtual.Proposta__r.Origem__c;
		req.numeroproposta 						= contratoAtual.NumeroPropostaUnico__c;
		req.quantidadeparcelas 					= contratoAtual.ContratantesContrato__r[0].QuantidadeParcelas__c;
		req.ramogarantia 						= contratoAtual.RamoSeguro__r.Codigo__c;
		req.modalidade 							= contratoAtual.CodigoModalidade__c;
		req.tipoconta 							= papel;
		req.tiporemuneracao 					= 'AGE';
		req.percentualtiporemuneracao 			= remuneracao.Percentual__c;
		req.valorremuneracao 					= String.valueOf(newValoragenc);
		req.percentualparticipacaofavorecido 	= remuneracao.FavorecidosContrato__r[0].Participacao__c;
		req.premioliquido 						= newValoragenc; // PLV-4172 - FIX 3
		req.susepcorretor 						= contratoAtual.CodigoCorretor__r.Name;
		req.tributacao 							= contratoAtual.Account.Tributavel__c;

		String respExtRem = HerokuService.getInstance().startHerokuExtratoRemuneracaoCancelamento(req);

        system.debug('Enviou Heroku');
		mapToReturn.put('proRataAgenciador',newValoragenc);
		return mapToReturn;
    } 
	//PLV-4973 - FIM
	
	private static Decimal calculoValorAgenciamentoPadrao(Contract contratoAtual, RemuneracaoContrato__c remuneracao, Integer numeroparcela){
		
		if(remuneracao == null || remuneracao.Percentual__c == 0) return 0;
		
		Decimal valorAgenciamento = 0;
		ContratanteContrato__c contratanteContrato = contratoAtual.ContratantesContrato__r[0];

		if (contratanteContrato.PremioComercial__c != null || contratanteContrato.PremioComercial__c > 0)
			valorAgenciamento = contratanteContrato.PremioComercial__c/12;
		
		if(remuneracao.Percentual__c == 100 && numeroParcela == 2)
			valorAgenciamento = 0;

		return valorAgenciamento;		
	}

}
//PLV-4601 - Fim