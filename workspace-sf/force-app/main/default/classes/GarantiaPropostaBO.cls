public class GarantiaPropostaBO {
	private static final GarantiaPropostaBO instancia = new GarantiaPropostaBO();

	private GarantiaPropostaBO() {}

	public static GarantiaPropostaBO getInstance() {
		return instancia;
	}

	public void validarGarantias(List<GarantiaProposta__c> lstGarantiasProposta) {
		Map<Id, GarantiaProduto__c> mapGarantiasProduto = new Map<Id, GarantiaProduto__c>();
		Map<Id, Quote> mapProposta = new Map<Id, Quote>();

		for(GarantiaProposta__c garantiaProposta : lstGarantiasProposta) {
			if(garantiaProposta.GarantiaProduto__c == null) {
				continue;
			}

			mapGarantiasProduto.put(garantiaProposta.GarantiaProduto__c, null);
			mapProposta.put(garantiaProposta.Proposta__c, null);
		}

		for(GarantiaProduto__c garantiaProduto : GarantiaProdutoDAO.getInstance().buscarGarantiasPorId(mapGarantiasProduto.keySet())) {
			mapGarantiasProduto.put(garantiaProduto.Id, garantiaProduto);
		}

		for(Quote proposta : QuoteDAO.getInstance().buscarPropostasPorId(mapProposta.keySet())) {
			mapProposta.put(proposta.Id, proposta);
		}

		for(GarantiaProposta__c garantiaProposta : lstGarantiasProposta) {
			Quote proposta;
			GarantiaProduto__c garantiaProduto;

			if(garantiaProposta.GarantiaProduto__c == null) {
				continue;
			}

			proposta = mapProposta.get(garantiaProposta.Proposta__c);
			garantiaProduto = mapGarantiasProduto.get(garantiaProposta.GarantiaProduto__c);
		
			// TODO: Alex, Barcellos verificar se é necessario, se sim temos que incluir na emissão 

			// set<String> setTipoCapitalProd = new set<String>();
			// set<String> setTipoCapitalProp = new set<String>();

			// setTipoCapitalProd.addAll(garantiaProduto.TipoCapital__c.Split(';'));
			// setTipoCapitalProp.addAll(garantiaProposta.TipoCapital__c.Split(';'));

			// for(String tipoCap : garantiaProposta.TipoCapital__c.Split(';'))
			// {
			// 	if(!setTipoCapitalProd.contains(tipoCap)) 
			// 		garantiaProposta.addError('O tipo de capital não corresponde com a garantia do produto. ');
			// }

			// if(!garantiaProduto.TipoCapital__c.contains(garantiaProposta.TipoCapital__c)) {
			// 	garantiaProposta.addError('O tipo de capital não corresponde com a garantia do produto. ' + garantiaProduto.TipoCapital__c + 'CHUPA ' +garantiaProposta.TipoCapital__c);
			// }

			// RVI-143 - INICIO
			if(garantiaProposta.Proposta__r.Tipo__c != 'Renovacao'){ 
				if(garantiaProposta.LimiteCapital__c < garantiaProduto.LimiteCapitalMinimo__c || garantiaProposta.LimiteCapital__c > garantiaProduto.LimiteCapitalMaximo__c ) {
					garantiaProposta.addError('Limite de capital inválido');
				}
			}
			// RVI-143 - FIM

			// PLV-1583-22 - remove a regra de validação de idade
			//if(proposta.Account.Idade__c < garantiaProduto.LimiteIdadeMinimo__c || proposta.Account.Idade__c > garantiaProduto.LimiteIdadeMaximo__c) {
			//	garantiaProposta.addError('Limite de idade inválido');
			//}
		}
	}
    //PLV-4350 FIX 1 - INÍCIO
    public void atualizaGarantiasProposta(String numeroProposta, List<ServiceGarantiaProposta.ApplicantsProduct> obj){

		Map<String,ServiceGarantiaProposta.ApplicantsProduct> mGarantiaSampleMed = new Map<String,ServiceGarantiaProposta.ApplicantsProduct>();
		Map<String, GarantiaProposta__c> mapStatusGarantia = new Map<String, GarantiaProposta__c>();
		Quote proposta = [SELECT Id, Status FROM Quote WHERE NumeroPropostaUnico__c =: numeroProposta];

		String statusAprovado = '1';
		String statusRecusado = '2';
		String statusInconclusivo = '4';

		for(ServiceGarantiaProposta.ApplicantsProduct gpSampleMed : obj){
			mGarantiaSampleMed.put(gpSampleMed.id_on_origin.trim(), gpSampleMed);
		}

		List<GarantiaProposta__c> lGarantiaProposta = [select 
															Id, 
															Proposta__r.NumeroPropostaUnico__c, 
															Id_SampleMed__c, 
															Status_sampleMed__c, 
															Data_SampleMed__c, 
															Observacao_SampleMed__c,  
															Garantia__r.Sigla__c, 
															Garantia__r.Name, 
															Garantia__r.Status__c,
															GarantiaProduto__r.CaracteristicaGarantia__c,
															GarantiaProduto__r.Obrigatoria__c
														from 
														GarantiaProposta__c 
														where 
														Proposta__r.NumeroPropostaUnico__c =: numeroProposta
														];
		
		List<GarantiaProposta__c> lupdateGarantiaProposta = new List<GarantiaProposta__c>(); 	

		if(lGarantiaProposta.size() > 0){

			for(GarantiaProposta__c gp : lGarantiaProposta){

				if(mGarantiaSampleMed.containsKey(gp.Garantia__r.Sigla__c)){
					
					String status = mGarantiaSampleMed.get(gp.Garantia__r.Sigla__c.trim()).status;
					gp.Id_SampleMed__c = mGarantiaSampleMed.get(gp.Garantia__r.Sigla__c.trim()).id;
					gp.Status_sampleMed__c = status == statusAprovado ? 'Aprovado' : status == statusRecusado ? 'Recusado' : 'Inconclusivo' ;
					gp.Data_SampleMed__c = Datetime.now();
					gp.Observacao_SampleMed__c = mGarantiaSampleMed.get(gp.Garantia__r.Sigla__c.trim()).medical_opinion;
					lupdateGarantiaProposta.add(gp);
				}
			}

			update lupdateGarantiaProposta;
			atualizarCritica(numeroProposta, lupdateGarantiaProposta); //PLV - 4350 - FIX2 -INICIO/FIM
			//update proposta; //PLV - 4350 - FIX2 -INICIO/FIM
		}
	}

	//PLV-4936 INICIO
	public void atualizarCriticaSampleMed(String numeroProposta, String status){
		
		List<CriticaProposta__c> criticasProposta = [
			SELECT Id
			FROM CriticaProposta__c 
			WHERE 
				Proposta__r.NumeroPropostaUnico__c =: numeroProposta AND
				Integracao__c = 'SAMPLE' AND 
				MomentoAnalise__c IN ('Subscrição', 'Análise interna')//ANNVI-225 - INICIO/FIM
		];

		System.debug('criticasProposta is null: ' + criticasProposta.isEmpty());

		//PLV-5023 - INICIO
		String [] filasArray = new List<String>();
		filasArray.add('Filaemissao');
		Map<String,Id> mapFila = new Map<String,Id>();		
        for(QueueSobject fila :[SELECT QueueID, Queue.developerName FROM QueueSObject WHERE SobjectType = 'CriticaProposta__c' AND Queue.developerName IN: filasArray]){
            mapFila.put(fila.Queue.developerName, fila.QueueID);
        }
	
		//ANNVI-225 - INICIO
		Set<Id> propCritId = new Set<Id>();
		//ANNVI-225 - FIM
		for(CriticaProposta__c criticaProposta : criticasProposta ) {
			criticaProposta.Status__c = status;
			criticaProposta.OwnerId = mapFila.containsKey('Filaemissao') ? mapFila.get('Filaemissao') : criticaProposta.OwnerId;
			criticaProposta.Setor__c = 'Emissão';
			criticaProposta.MomentoAnalise__c = 'Análise interna';
			propCritId.add(criticaProposta.Proposta__c);//ANNVI-225 - INICIO/FIM
		}		
		//PLV-5023 - FIM
		
		if(!criticasProposta.isEmpty()) update criticasProposta;

		//ANNVI-225 - INICIO
		Map<Id, Quote> mapPropFaseStat = new Map<Id, Quote>(
			[SELECT Id, FaseStatus__c FROM Quote WHERE Id IN :propCritId]
		);

		for(CriticaProposta__c criticaProposta : criticasProposta ) {			

			if(!mapPropFaseStat.values().isEmpty() && criticaProposta.MomentoAnalise__c == 'Análise interna'){
				Quote proposta = mapPropFaseStat.get(criticaProposta.Proposta__c);
				proposta.FaseStatus__c = 'Análise interna';
				update proposta;
			}
		}
		//ANNVI-225 - FIM
	}
	//PLV-4936 FIM
	
	public void atualizarCritica(string numeroProposta, List<GarantiaProposta__c> listGarantiaProposta){ //PLV - 4350 - FIX2 -INICIO/FIM
		
		//VEP - 146 - INICIO
		Map<String,Id> mapFila = new Map<String,Id>();
        for(QueueSobject fila :[SELECT QueueID, Queue.developerName FROM QueueSObject WHERE SobjectType = 'CriticaProposta__c' AND Queue.developerName IN ('Fila_Propostas_Prioritarias')]){
			mapFila.put(fila.Queue.developerName, fila.QueueID);
        }
		//VEP - 146 - FIM


		//PLV-5004 - INICIO
		CriticaProposta__c criticaProposta = [SELECT 
			Id, 
			Proposta__r.NumeroPropostaUnico__c, 
			Status__c, 
			Tipo__c, 
			Area__c, 
			Codigo__c, 
			Descricao__c,
			Integracao__c,
			//VEP - 146 - INICIO 
			MomentoAnalise__c,
			Setor__c 
			//VEP - 146 - FIM
			FROM 
			CriticaProposta__c 
			WHERE 
			Proposta__r.NumeroPropostaUnico__c =: numeroProposta AND 
			Integracao__c = 'SAMPLE' AND 
			MomentoAnalise__c = 'Subscrição' AND 
			Status__c != 'Recusado' AND Status__c != 'Cancelada' AND Status__c != 'Liberado' 
			LIMIT 1
		];
		//PLV-5004 - FIM

		//VEP - 146 - INICIO                               
		List<Quote> lstProposta = [SELECT Id, Name, isRecusadaSumariamente__c,CodigoMotivoDevolucao__c, NR__c FROM Quote WHERE Name =: numeroProposta]; //PLV-4980 INICIO/FIM // II-99 - INICIO/FIM
		//VEP - 146 - FIM

		if(listGarantiaProposta.size() > 0 && criticaProposta != null){
			String parecerProposta;
			Integer totalStatusRecusado = 0; 
			List <GarantiaProposta__c> listGarantiaAprovada = new List<GarantiaProposta__c>();
			List <GarantiaProposta__c> listGarantiaPrincipal = new List<GarantiaProposta__c>();
			List <GarantiaProposta__c> listGarantiaObrigatoria = new List<GarantiaProposta__c>();
			List <GarantiaProposta__c> listGarantiaPrincipalAprovada = new List<GarantiaProposta__c>();

			for(GarantiaProposta__c garantia : listGarantiaProposta){
				
				if(garantia.Status_sampleMed__c == 'Aprovado'){
					listGarantiaAprovada.add(garantia);
				}

				if(garantia.GarantiaProduto__r.CaracteristicaGarantia__c == 'Principal'){
					listGarantiaPrincipal.add(garantia);
				}
			}

			//Aprovação
			if(listGarantiaAprovada.size() == listGarantiaProposta.size()){
				parecerProposta = 'Disponível para contratação'; //PLV - 4350 - FIX 3 -INICIO/FIM
				criticaProposta.Status__c = 'Liberado';
			}
			
			//Recusa Sumária
			if(parecerProposta == null){
				if(listGarantiaPrincipal.size() == 1 &&  listGarantiaProposta.size() == listGarantiaPrincipal.size()){

					if(listGarantiaPrincipal[0].Status_sampleMed__c == 'Recusado'){
						parecerProposta = 'Recusada'; //PLV - 4350 - FIX 3 -INICIO/FIM
						criticaProposta.Status__c = 'Recusado';
						lstProposta[0].CodigoMotivoDevolucao__c = '89'; // II-99 -INICIO/FIM
						lstProposta[0].isRecusadaSumariamente__c = true; //PLV-4980 INICIO/FIM
					}
				}

				if(listGarantiaPrincipal.size() > 0){
					
					
					for(GarantiaProposta__c garantia : listGarantiaPrincipal){
						if(garantia.Status_sampleMed__c == 'Recusado'){
							totalStatusRecusado = totalStatusRecusado + 1;
						}
					}
					if(listGarantiaPrincipal.size() == totalStatusRecusado){
						parecerProposta = 'Recusada'; //PLV - 4350 - FIX 3 -INICIO/FIM
						criticaProposta.Status__c = 'Recusado';
						lstProposta[0].CodigoMotivoDevolucao__c = '89'; // II-99 -INICIO/FIM
						lstProposta[0].isRecusadaSumariamente__c = true; //PLV-4980 INICIO/FIM
					}
				}
				for(GarantiaProposta__c garantia : listGarantiaProposta){
					if(garantia.GarantiaProduto__r.Obrigatoria__c){
						listGarantiaObrigatoria.add(garantia);
						if(garantia.Status_sampleMed__c == 'Recusado'){
							//parecerProposta = 'Recusada'; //PLV - 4350 - FIX 3 -INICIO/FIM
							criticaProposta.Status__c = 'Recusado';
							lstProposta[0].CodigoMotivoDevolucao__c = '89'; // II-99 -INICIO/FIM
							lstProposta[0].isRecusadaSumariamente__c = true; //PLV-4980 INICIO/FIM
						}
					}
				}
			}

			//Em análise
			if(parecerProposta == null){
				if(listGarantiaPrincipal.size() > 0){

					for(GarantiaProposta__c garantia : listGarantiaPrincipal){
						if(garantia.Status_sampleMed__c == 'Aprovado'){
							listGarantiaPrincipalAprovada.add(garantia);
						}
						else if(garantia.Status_sampleMed__c == 'Inconclusivo'){
							parecerProposta = 'Em análise'; //PLV - 4350 - FIX 3 -INICIO/FIM
							criticaProposta.Status__c = 'Inconclusiva';
						}
					}
					if(listGarantiaPrincipalAprovada.size() > 1 && listGarantiaPrincipal.size() != listGarantiaPrincipalAprovada.size()){
						parecerProposta = 'Em análise'; //PLV - 4350 - FIX 3 -INICIO/FIM
						criticaProposta.Status__c = 'Inconclusiva';
					}
				}

				for(GarantiaProposta__c garantia : listGarantiaProposta){
					if(!garantia.GarantiaProduto__r.Obrigatoria__c && (garantia.Status_sampleMed__c == 'Inconclusivo' || garantia.Status_sampleMed__c == 'Recusado')){
						parecerProposta = 'Em análise'; //PLV - 4350 - FIX 3 -INICIO/FIM
						criticaProposta.Status__c = 'Inconclusiva';
					}
					if(garantia.Status_sampleMed__c == 'Inconclusivo'){
						parecerProposta = 'Em análise'; //PLV - 4350 - FIX 3 -INICIO/FIM
						criticaProposta.Status__c = 'Inconclusiva';
					}
				}

				for(GarantiaProposta__c garantia : listGarantiaProposta){
					if(garantia.GarantiaProduto__r.Obrigatoria__c && garantia.Status_sampleMed__c == 'Inconclusivo'){
						parecerProposta = 'Em análise'; //PLV - 4350 - FIX 3 -INICIO/FIM
						criticaProposta.Status__c = 'Inconclusiva';
					}
				}

				if(listGarantiaAprovada.size() != listGarantiaProposta.size()){
					parecerProposta = 'Em análise'; //PLV - 4350 - FIX 3 -INICIO/FIM
					criticaProposta.Status__c = 'Inconclusiva';
				}
			}
			
			//VEP - 146 - INICIO
			Integer nrInt = 0;
            try { nrInt = Integer.valueOf(lstProposta[0].NR__c); } catch (Exception e) {}

			if(nrInt > 4 && criticaProposta.Status__c == 'Recusado') {
				criticaProposta.Status__c = 'Inconclusiva';
				criticaProposta.Procedimento__c = 'Proposta foi recusada pela Samplemed, porém, segurado possui nível de relacionamento superior a 4';
				criticaProposta.OwnerId = mapFila.get('Fila_Propostas_Prioritarias');
				
				CriticaProposta__c novaCriticaProposta = new CriticaProposta__c (
			    	Descricao__c = 'Avaliação de Recusa do NR 5 ou 6',
					Status__c = 'Pendente',
					Setor__c = criticaProposta.Setor__c,
					MomentoAnalise__c = 'Análise interna',     
					Tipo__c = 'Analise',
					OwnerId = mapFila.get('Fila_Propostas_Prioritarias'),
					Proposta__c = criticaProposta.Proposta__c
				);
				insert novaCriticaProposta; 

				lstProposta[0].FaseStatus__c = 'Análise interna';
			}
			//VEP - 146 - FIM
			
			update lstProposta;  //PLV-4980 INICIO/FIM
			update criticaProposta;

			//return parecerProposta; //PLV - 4350 - FIX2 -INICIO/FIM
		}
		//return ''; //PLV - 4350 - FIX2 -INICIO/FIM
	}
	//PLV-4350 FIX 1 - FIM
	
	//PLV-4598 - INICIO
	public Boolean atualizarFranquia(List<GarantiaProposta__c> lstGarantiasProposta){
		Set<ID> setPropostaIds = new Set<ID>();
		
		for(GarantiaProposta__c q : lstGarantiasProposta) if(q.Proposta__c != null ) setPropostaIds.add(q.Proposta__c);

		List<Quote> lstProposta = Test.isRunningTest() ? new List<Quote>() : [ SELECT OpportunityId FROM Quote WHERE ID IN: setPropostaIds ];
		if(lstProposta.isEmpty()) return false;

		Set<ID> setOrcamentosIds = new Set<ID>();
		for(Quote q : lstProposta)if(q.OpportunityId != null ) setOrcamentosIds.add(q.OpportunityId);
		if(setOrcamentosIds.isEmpty()) return false;

		List<GarantiaOrcamento__c> lstGarantiasOrcamento = Test.isRunningTest() ? new List<GarantiaOrcamento__c>() : [SELECT FranquiaGarantia__c, Garantia__r.sigla__c FROM GarantiaOrcamento__c WHERE Orcamento__c IN: setOrcamentosIds AND FranquiaGarantia__c != null ];
		if(lstGarantiasOrcamento.isEmpty()) return false;

		Map<ID, ID> mpFranquia = new Map<ID, ID>();

		for(GarantiaOrcamento__c g : lstGarantiasOrcamento) mpFranquia.put(g.Garantia__c, g.FranquiaGarantia__c);

		for(GarantiaProposta__c gtrPropost : lstGarantiasProposta)
			gtrPropost.FranquiaGarantia__c = mpFranquia.get(gtrPropost.Garantia__c);

		return true;
	}
	//PLV-4598 - FIM

	//AV-824 - INICIO
	public static void setGarantiasProposta(List<GarantiaOrcamento__c> garantiasOpportunity, String idProposta){
		List<GarantiaProposta__c> lgProposta = new List<GarantiaProposta__c>();
		for(GarantiaOrcamento__c gr : garantiasOpportunity){
			GarantiaProposta__c grp = new GarantiaProposta__c();
			grp.Capital__c = gr.Capital__c;
			grp.PremioComercial__c = gr.PremioComercial__c;
			grp.PremioPuro__c = gr.PremioPuro__c;
			grp.PremioTotal__c = gr.PremioTotal__c;
			grp.TaxaComercial__c = gr.TaxaComercial__c;
			grp.TaxaPura__c = gr.TaxaPura__c;
			grp.TaxaTotal__c = gr.TaxaTotal__c;
			grp.IOF__c = gr.IOF__c;
			grp.Garantia__c = gr.Garantia__c;
			grp.GarantiaProduto__c = gr.GarantiaProduto__c;
			grp.Tipo_de_limite_de_utilizacao__c = gr.Tipo_de_limite_de_utilizacao__c;
			grp.Limite_de_Uso__c = gr.Limite_de_Uso__c;
			grp.Proposta__c = idProposta;
			lgProposta.add(grp);
		}
		insert lgProposta;
	}

	public static void setGarantiaContratanteProposta(List<GarantiaContratanteOrcamento__c> gContrProp, String contraPropostaId){
		List<GarantiaContratanteProposta__c> garantiasContrProposta = new List<GarantiaContratanteProposta__c>();
		for(GarantiaContratanteOrcamento__c g : gContrProp){
			GarantiaContratanteProposta__c gr = new GarantiaContratanteProposta__c();
			gr.ContratanteProposta__c = contraPropostaId;
			gr.Capital__c = g.Capital__c;
			gr.PremioComercial__c = g.PremioComercial__c;
			gr.PremioPuro__c = g.PremioPuro__c;
			gr.PremioTotal__c = g.PremioTotal__c;
			gr.CurrencyIsoCode = g.CurrencyIsoCode;
			gr.IOF__c = g.IOF__c;
			gr.TaxaComercial__c = g.TaxaComercial__c;
			gr.TaxaPura__c = g.TaxaPura__c;
			gr.TaxaTotal__c = g.TaxaTotal__c;
			gr.Garantia__c = g.Garantia__c;
			gr.GarantiaProduto__c = g.GarantiaProduto__c;
			garantiasContrProposta.add(gr);
		}
		insert garantiasContrProposta;
		
	}
	//AV-36 - INICIO
	public static void setGarantiasGrupoPosposta( Map<String,List<GarantiaGrupoOrcamento__c>> mgarantiaGOrcamento){
		Set<String> sGrupoPropostaIds = new Set<String>();
		sGrupoPropostaIds = mgarantiaGOrcamento.keySet();
		List<GarantiasGrupoProposta__c> lGarantiasGrupoProp = new List<GarantiasGrupoProposta__c>();
		for(String indice : sGrupoPropostaIds){
			for(GarantiaGrupoOrcamento__c g : mgarantiaGOrcamento.get(indice)){
				GarantiasGrupoProposta__c grupoGarantiaProposta = new GarantiasGrupoProposta__c();
				grupoGarantiaProposta.GrupoProposta__c = indice;
				grupoGarantiaProposta.Capital__c  = g.Capital__c;
				//grupoGarantiaProposta.ClausulaReducaoFranquiaAcidente__c = g.ClausulaReducaoFranquiaAcidente__c;
				grupoGarantiaProposta.DescontoAgravoMonetarioTecnico__c = g.DescontoAgravoMonetarioTecnico__c;
				grupoGarantiaProposta.DescontoAgravoPercentualTecnico__c = g.DescontoAgravoPercentualTecnico__c;
				grupoGarantiaProposta.GarantiaProduto__c = g.GarantiaProduto__c;
				grupoGarantiaProposta.Garantia__c = g.Garantia__c;
				grupoGarantiaProposta.IOF__c = g.IOF__c;
				//grupoGarantiaProposta.Name": "0549182
				grupoGarantiaProposta.PremioComercial__c = g.PremioComercial__c;
				grupoGarantiaProposta.PremioPuro__c = g.PremioPuro__c;
				grupoGarantiaProposta.PremioTotal__c = g.PremioTotal__c;
				grupoGarantiaProposta.CurrencyIsoCode = g.CurrencyIsoCode;
				grupoGarantiaProposta.TaxaComercial__c = g.TaxaComercial__c;
				grupoGarantiaProposta.TaxaPura__c = g.TaxaPura__c;
				grupoGarantiaProposta.TaxaTotal__c = g.TaxaTotal__c;

				lGarantiasGrupoProp.add(grupoGarantiaProposta);
			}
		}
		if(lGarantiasGrupoProp.size() > 0){
			insert lGarantiasGrupoProp;
		}
	}
	//AV-36 - FIM
	public static void setGarantiasSeguradoProposta(List<GarantiasGrupoProposta__c> lGgrupoProposta, Id seguradoProposta){
		List<GarantiaSeguradoProposta__c> lGarantiasSeguradoProposta = new List<GarantiaSeguradoProposta__c>();
		
		for(GarantiasGrupoProposta__c g : lGgrupoProposta){
			GarantiaSeguradoProposta__c garantiasSegProposta = new GarantiaSeguradoProposta__c();
			//garantiasSegProposta.Sigla__c = g.GarantiaReferenciada__r.Sigla__c;
			garantiasSegProposta.Garantia__c = g.Garantia__c; //AV-36 - INICIO/FIM
			garantiasSegProposta.GarantiaProduto__c = g.GarantiaProduto__c; //AV-36 - INICIO/FIM
			garantiasSegProposta.Capital__c = g.Capital__c;
			garantiasSegProposta.Percentual__c = g.Percentual__c;
			garantiasSegProposta.PremioComercial__c = g.PremioComercial__c;
			garantiasSegProposta.PremioPuro__c = g.PremioPuro__c;
			garantiasSegProposta.PremioTotal__c = g.PremioTotal__c;
			garantiasSegProposta.PremioIntegral__c = g.PremioIntegral__c; 
			garantiasSegProposta.TaxaComercial__c = g.TaxaComercial__c;
			garantiasSegProposta.TaxaPura__c = g.TaxaPura__c;
			garantiasSegProposta.TaxaTotal__c = g.TaxaTotal__c;
			garantiasSegProposta.Valor__c = g.Valor__c;
			garantiasSegProposta.ValorCotacao__c = g.ValorCotacao__c;
			garantiasSegProposta.CurrencyIsoCode = g.CurrencyIsoCode; 
			garantiasSegProposta.SeguradoProposta__c = seguradoProposta;
			lGarantiasSeguradoProposta.add(garantiasSegProposta);
		}
		if(lGarantiasSeguradoProposta.size() > 0){
			insert lGarantiasSeguradoProposta;
		}
	}
	//AV-824 - FIM
}