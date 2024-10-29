public class QueueableProcessaPortoCap implements Queueable, Database.AllowsCallouts
{
	private List<GarantiaContratoTO.DadosPortoCap> parametroPortoCap  { get; set; }
	public static final Integer TOTAL_REGISTROS = 2;

	public QueueableProcessaPortoCap(List<GarantiaContratoTO.DadosPortoCap> parametroPortoCap) 
	{
		this.parametroPortoCap = parametroPortoCap;
	}

	public void execute(QueueableContext queueCont)
	{
		try 
		{
			GarantiaContratoTO.DadosPortoCap itemProcesso;

			if(this.parametroPortoCap.size() > 0)
			{
				itemProcesso = this.parametroPortoCap[0];
				executarNegocio(itemProcesso);
				this.parametroPortoCap.remove(0);

				System.enqueueJob(new QueueableProcessaPortoCap(parametroPortoCap));
			}
			else{
				CriarLog();
			}
		}
		catch(Exception e){

		}
	}	

	private void executarNegocio(GarantiaContratoTO.DadosPortoCap itemProcesso)
	{
		System.debug('Inicio Processamento');

	    GarantiaContratoTO.RetornoConsultaTitulosTO tempList = new GarantiaContratoTO.RetornoConsultaTitulosTO();

		try {
		    System.debug('Json Envio: ' + json.serialize(itemProcesso));

		    //-- Verificado teste por um problema no SalesForce, onde sempre que batia na chamada de um serviço
		    //-- gerava um erro que pendencias de commit e encerrava o teste.
		    if(!Test.isRunningTest())
		    {
				tempList = PortoCapService.getinstance().recuperarTitulosSolicitados(itemProcesso);
		    }
		    else
		    {
			  	String retornoPortoCap = '{"Propostas": [{"nm_pessoa": "I4PROCAP SEGURO VIDA E PREVIDENCIA SA","nr_cnpjcpf": 67567732000139,"Cd_promocao": "VI005","cd_versao": 2,"nr_serie": "02VP02C18","nr_proposta": 2,"dt_emissao": "2018-03-26T00:00:00","dt_inicio_vigencia": "2018-03-26T00:00:00","DadosTitulos": {"Titulos": [{ "cd_cessionario": "14889", "nm_cessionario": "", "nr_cpfcnpj_cessionario": 0, "Nr_titulo": 1, "vr_desconto": 0, "Vr_valor": 0.6, "nr_sorte": "80338", "nm_status": "Suspenso", "nr_Lote": "534543", "dt_sorteio" : "2018-09-04" }]}}]}';
		       	tempList = (GarantiaContratoTO.RetornoConsultaTitulosTO)JSON.deserialize(retornoPortoCap, GarantiaContratoTO.RetornoConsultaTitulosTO.class);
		    }

		    System.debug('Json Retorno: ' + json.serialize(tempList));

	    	executaAtualizacaoContrato(tempList);
		}
		catch (Exception e) {
            throw e;
		}

	}

	private void executaAtualizacaoContrato(GarantiaContratoTO.RetornoConsultaTitulosTO dadosTitulos)
	{
		System.debug('Inicio Atualização');

		Map<String, DadosTitulos> mapTitulos = new Map<String, DadosTitulos>();
		List<String> lstcontratos = new List<String>(); 
		List<GarantiaContrato__c> lstUpdtContratos = new List<GarantiaContrato__c>(); 

       Savepoint sp = Database.setSavepoint();

		try {

			System.debug('Inicio carga map');
			for(GarantiaContratoTO.PropostasTO propostas : dadosTitulos.Propostas)
			{
				for(GarantiaContratoTO.Titulos titulos : propostas.DadosTitulos.Titulos)
				{
					if(!mapTitulos.containsKey(titulos.cd_cessionario))
					{
						System.debug('Contrato: ' + titulos.cd_cessionario);

						DadosTitulos titulo = new DadosTitulos();

						titulo.nrtitulo  = titulos.Nr_titulo;
						titulo.nrlote 	 = titulos.nr_Lote;
						titulo.nrsorte	 = titulos.nr_sorte;
						titulo.dtsorteio = titulos.dt_sorteio;
						titulo.nrserie	 = propostas.nr_serie;

						mapTitulos.put(titulos.cd_cessionario, titulo);
						lstcontratos.add(titulos.cd_cessionario);
					}

				}
			}

			System.debug('Inicio monta atualização');
			for(GarantiaContrato__c objContrato : GarantiaContratoDAO.getinstance().buscarGarantiasContratoPorContrato(lstcontratos))
			{
				System.debug('Contrato retornardo: ' + objContrato.contrato__r.name);

				if(mapTitulos.containsKey(objContrato.contrato__r.name))
				{

					System.debug('Contrato Update: ' + objContrato.contrato__r.name);

					GarantiaContrato__c	updGarantiaContrato = new GarantiaContrato__c();
					
					DadosTitulos titulo = new DadosTitulos();
					titulo = mapTitulos.get(objContrato.contrato__r.name);

					updGarantiaContrato.Id 				= objContrato.Id;
					updGarantiaContrato.NumeroSerie__c	= titulo.nrserie;
					//Inicio - ST-2021-00012
					if(titulo.nrsorte != null){
						updGarantiaContrato.NumeroSorte__c	= StringHelper.FormatNumeroSorte(titulo.nrsorte);
					}else{
						updGarantiaContrato.NumeroSorte__c	= titulo.nrsorte;
					}
					//Fim - ST-2021-00012
					updGarantiaContrato.DataSorteio__c	= titulo.dtsorteio;
					updGarantiaContrato.NumeroTitulo__c	= String.valueOf(titulo.nrtitulo);
					updGarantiaContrato.LoteCapitalizacao__c = String.valueOf(titulo.nrlote);
					updGarantiaContrato.StatusCapitalizacao__c = 'CapitalizacaoGerada';

					lstUpdtContratos.add(updGarantiaContrato);
				}

			}

			update lstUpdtContratos;

		}
		catch (Exception e) {
			System.debug(e.getMessage());
            Database.rollback(sp);
            throw e;
		}
	}

    private void CriarLog()
    {
		ControleIntegracao__c log = new ControleIntegracao__c();

		log.CodigoIntegracao__c 	= '61';
		log.DataCriacaoRegistro__c 	= Date.today();
		log.IdObjeto__c 			= String.valueOf(Date.today());
		log.Status__c 				= 'Pendente';

		insert log;

		System.debug('Gravou Log');

    }

	public class DadosTitulos
	{
		public Integer nrtitulo { get; set; }
		public Integer nrlote { get; set; }
		public String  nrsorte { get; set; }
		public String  nrserie { get; set; }
		public Date dtsorteio { get; set; }
	}
}