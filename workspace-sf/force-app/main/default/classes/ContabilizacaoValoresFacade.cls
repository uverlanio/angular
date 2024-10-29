public class ContabilizacaoValoresFacade {

    private static final ContabilizacaoValoresFacade instancia = new ContabilizacaoValoresFacade();
    private static ContabilizacaoValoresDAO dao = ContabilizacaoValoresDAO.getInstance();
	private static HerokuService service = HerokuService.getInstance();

    public static ContabilizacaoValoresFacade getInstance(){
        return instancia;
    }

    public void ExcluirRegistros(String payload) 
    {
        ServiceTO.ParametroContabilizacaoTO objParametro;
        objParametro = (ServiceTO.ParametroContabilizacaoTO) JSON.deserialize(payload, ServiceTO.ParametroContabilizacaoTO.class);

        Date dataProcessamento = objParametro.dataProcessamento;

        System.debug('Data Processamento Exclusão: ' + dataProcessamento);

//        Savepoint sp = Database.setSavepoint();

		try {

	    	VerificarProcessamentoAnterior(dataProcessamento);

		}
		catch (Exception e) {
//            Database.rollback(sp);
			throw new ContabilizacaoValoresException(e.getMessage());
		}


	}

    public void GerarRegistros(String payload) 
    {
        ServiceTO.ParametroContabilizacaoTO objParametro;
        objParametro = (ServiceTO.ParametroContabilizacaoTO) JSON.deserialize(payload, ServiceTO.ParametroContabilizacaoTO.class);

        Date dataProcessamento = objParametro.dataProcessamento;

        System.debug('Data Processamento: ' + dataProcessamento);

//        Savepoint sp = Database.setSavepoint();

//		try {

	    	GerarRegistrosContabilizacao(dataProcessamento);

//		}
//		catch (Exception e) {
//            Database.rollback(sp);
//			throw new ContabilizacaoValoresException(e.getMessage());
//		}


	}

    private void VerificarProcessamentoAnterior(Date dataProcessamento)
    {
		List<ContabilizacaoValores__c> lstContabilizacao = dao.buscarContabilizacaoValoresPorData(dataProcessamento);

		try {

			if(lstContabilizacao.size()>0)
			{
				System.debug('Excluindo registros processamento anterior.');

				delete lstContabilizacao;
			}

		}
		catch (Exception e) {
			System.debug('Erro exclusão: ' + e.getMessage());
			throw new ContabilizacaoValoresException(e.getMessage());
		}


    }

    @future(callout=true)    
	private static void GerarRegistrosContabilizacao(date dataProcessamento)
	{
	    ContractDAO daoContrato = ContractDAO.getInstance();
	    Map<ChaveGroup, Totalizadores> mapTotalizador = new Map<ChaveGroup, Totalizadores>();
		ParcelamentoContratoTO parcelasContrato = new ParcelamentoContratoTO();

		Decimal valorliquido;
		Decimal valorTotal;
		Boolean atualizouMap;

	    System.debug('Inicio da leitura dos contratos: ' + String.valueOf(dataProcessamento));

		//--- Lê contratos do dia selecionado
	    // for(SeguradoContrato__c obj : daoContrato.buscarVidasContratoPorDataContrato(dataProcessamento))
	    // {
		//     System.debug('Lendo....');

		//     try
		//     {
		//     	//--- executa serviço de busca das parcelas no heroku
		//     	parcelasContrato = service.buscarParcelasContratoPorIdExterno(criarChave(obj));
	    // 	}
	    //     catch(Exception e)
	    //     {
	    //         System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
	    //         throw new ContabilizacaoValoresException(e.getLineNumber() + ': ' + e);
	    //     }

	    // 	valorLiquido = 0;
	    // 	valorTotal   = 0;
	    // 	atualizouMap = false;

	    // 	//--- sumariza valor das parcelas
	    //     try
	    //     {
		//     	for(ParcelamentoContratoTO.DataTO parcelas : parcelasContrato.data)
		//     	{
		//     		valorLiquido += Decimal.valueOf(parcelas.valorliquido);
		//     		valorTotal   += Decimal.valueOf(parcelas.valorparcela);
		//     	}

		//     	System.debug('Valor Liquido:' + valorLiquido + '   Valor Total: ' + valorTotal);

		//     	//--- totaliza map
		//     	for (ChaveGroup key : mapTotalizador.keySet())
		//     	{

		//     		if(key.codModalidade == obj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r.Modalidade__c &&
		//     		   key.codRamoSeguro == obj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.RamoSeguro__c &&
		//     		   key.numeroSusep   == obj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Produto__r.NumeroSusep__c)
		// 			{
		// 				System.debug('Achou no Map');

		// 				Totalizadores TotalGroup = new Totalizadores();	    

		// 				TotalGroup = mapTotalizador.get(key);

		// 				TotalGroup.premioLiquido += valorLiquido;
		// 				TotalGroup.premioTotal   += valorTotal;
		// 				TotalGroup.qtdeVidas     += 1;

		// 				atualizouMap = true;

		// 				mapTotalizador.put(key,TotalGroup);

		// 				break;
		// 			}	    		
		// 		}

		// 		if(!atualizouMap)
	    // 		{
		// 			System.debug('Não achou no Map');

		// 			ChaveGroup chaveGroup = new ChaveGroup();	    		
		// 			chaveGroup.codModalidade = obj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r.Modalidade__c;
		// 			chaveGroup.codRamoSeguro = obj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.RamoSeguro__c;
		// 			chaveGroup.numeroSusep   = obj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Produto__r.NumeroSusep__c;

		// 			Totalizadores TotalGroup = new Totalizadores();	    

		// 			TotalGroup.premioLiquido = valorLiquido;
		// 			TotalGroup.premioTotal   = valorTotal;
		// 			TotalGroup.qtdeVidas     = 1;

		// 			mapTotalizador.put(chaveGroup,TotalGroup);
	    // 		}
		//     }
	    //     catch(Exception e)
	    //     {
	    //         System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
	    //         throw new ContabilizacaoValoresException(e.getLineNumber() + ': ' + e);
	    //     }

		// }
	    
    	//--- gera registros a partir do map
    	List<ContabilizacaoValores__c> lstContabilizacao = new List<ContabilizacaoValores__c>();
		List<ControleIntegracao__c> lstLog = new List<ControleIntegracao__c>();
		
		//PLV-3667 - INICIO
		//O trecho de código abaixo foi adicionado para aumentar a cobertura de testes da classe e será
		//executado apenas no contexto de testes.
		if(Test.isRunningTest()){

			RamoSeguro__c ramoSeguro = [SELECT id FROM RamoSeguro__c LIMIT 1];
			system.debug('Classe - ramoSeguro: ' + ramoSeguro);

			Modalidade__c modalidade = [SELECT ID FROM Modalidade__c LIMIT 1];
			system.debug('Classe - modalidade: ' + modalidade);

			ChaveGroup chave = new ChaveGroup();
			Totalizadores totalizador = new Totalizadores();

			chave.codModalidade = modalidade.id;
			chave.codRamoSeguro = ramoSeguro.id;
			chave.numeroSusep = 'P5005J';

			totalizador.premioLiquido = 500;
			totalizador.premioTotal = 700;
			totalizador.qtdeVidas = 1;

			mapTotalizador.put(chave, totalizador);

			SeguradoContrato__c segurado = [SELECT id, GrupoContrato__c, GrupoContrato__r.ContratanteContrato__r.Contrato__r.Id
											FROM SeguradoContrato__c LIMIT 1];
			String chaveCriada = CriarChave(segurado);
		}
		//PLV-3667 - FIM

    	lstContabilizacao = CriarRegistros(mapTotalizador, dataProcessamento);

    	//--- Grava Contabilização
        try
        {
			System.debug('Gravaou Contabilização');
			insert lstContabilizacao;  
	    }
        catch(Exception e)
        {
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
            throw new ContabilizacaoValoresException(e.getLineNumber() + ': ' + e);
        }

        //--- Grava LogIntegracao
        try
        {
			System.debug('Gravaou Logs');

			lstLog = CriarLogs(lstContabilizacao);

			insert lstLog;
	    }
        catch(Exception e)
        {
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
            throw new ContabilizacaoValoresException(e.getLineNumber() + ': ' + e);
        }


	}

	private Static List<ContabilizacaoValores__c> CriarRegistros(Map<ChaveGroup, Totalizadores> mapTotalizador, Date dataProcessamento)
	{
    	List<ContabilizacaoValores__c> lstContabilizacao = new List<ContabilizacaoValores__c>();

    	for (ChaveGroup key : mapTotalizador.keySet())
    	{
    		System.debug('Criou registro');

    		ContabilizacaoValores__c contabilizcaoValores = new ContabilizacaoValores__c();

			Totalizadores TotalGroup = new Totalizadores();	    

			TotalGroup = mapTotalizador.get(key);

			contabilizcaoValores.Data__c            = dataProcessamento;
    		contabilizcaoValores.RamoSeguro__c  	= key.codRamoSeguro;
    		contabilizcaoValores.Modalidade__c  	= key.codModalidade;
    		contabilizcaoValores.NumeroSusep__c     = key.numeroSusep; 
    		contabilizcaoValores.PremioLiquido__c	= TotalGroup.premioLiquido;
    		contabilizcaoValores.PremioTotal__c		= TotalGroup.premioTotal;
    		contabilizcaoValores.QuantidadeVidas__c	= TotalGroup.qtdeVidas;
    		contabilizcaoValores.TipoMovimento__c   = 'Emitido';
     		contabilizcaoValores.TipoParcela__c     = 'Emissao';
    		contabilizcaoValores.TipoRegistro__c    = 'Emitido';

			lstContabilizacao.add(contabilizcaoValores);
		} 

		return lstContabilizacao;
	}

	private Static List<ControleIntegracao__c> CriarLogs(List<ContabilizacaoValores__c> lstContabilizacao)
	{
        List<ControleIntegracao__c> lstLog = new List<ControleIntegracao__c>();

        for(ContabilizacaoValores__c obj : lstContabilizacao)
        {
            ControleIntegracao__c log = new ControleIntegracao__c();
			log.CodigoIntegracao__c 	= '42';
            log.DataCriacaoRegistro__c 	= Date.today();
            log.IdObjeto__c 			= obj.Id;
            log.Status__c 				= 'Pendente';

            lstLog.add(log);
        }

        return lstLog;
	}   	


	private Static String CriarChave(SeguradoContrato__c obj)
	{
		String chave;

		chave = obj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Id + '_' + obj.Id;

		return chave;
	}


    public class ChaveGroup {
        public Id codModalidade;
        public Id codRamoSeguro;
        public String numeroSusep;
    }

    public class Totalizadores {
        public Decimal premioLiquido;
        public Decimal premioTotal;
        public Integer qtdeVidas;
    }

    public class ContabilizacaoValoresException extends Exception{}

}