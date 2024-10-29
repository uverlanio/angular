/**
 * Regras de Negócio do Objeto RamoAtividade__c
 * @author Fernando Barcellos @ 05/12/2017
 *         João Losada @ 14/05/2018
 *
 **/
public with sharing class RamoAtividadeBO {
	private static final RamoAtividadeBO instance = new RamoAtividadeBO();

	private RamoAtividadeDAO dao = RamoAtividadeDAO.getInstance();

	private RamoAtividadeBO() { }

	public static RamoAtividadeBO getInstance() {
		return instance;
	}

	public void sincronizarDados() {
		ServiceTO.RamoAtividadeTO tempDados = F5Service.getInstance().buscarRamosAtividade();

		List<RamoAtividade__c> dadosParaSincronizar = new List<RamoAtividade__c>();
	    Map<String, String> mapDetalhes = new Map<String, String>();

        String nomeSubClasse;
        String nomeClasse;
        String nomeGrupo;
        String nomeDivisao;
        String nomeSecao;
	
		for (ServiceTO.ListRamoAtividadeTO lstRamos : tempDados.ResponseObterDominiosCnae.cnae) {

			if(lstRamos.numeroCnae < 0)
				continue;

			nomeSubClasse	= '';
			nomeClasse      = '';
			nomeGrupo       = '';
			nomeDivisao     = '';
			nomeSecao		= '';			

			lstRamos.divisao   = String.valueOf(lstRamos.divisao.length() < 2 && lstRamos.divisao != '0' ? '0' + lstRamos.divisao : lstRamos.divisao);
			lstRamos.classe    = String.valueOf(lstRamos.classe.length() < 2 && lstRamos.classe != '0' ? '0' + lstRamos.classe : lstRamos.classe);
			lstRamos.subClasse = String.valueOf(lstRamos.SubClasse.length() < 2 && lstRamos.SubClasse != '0' ? '0' + lstRamos.SubClasse : lstRamos.SubClasse);

			// Identifica qual é o nivel para gravar a descrição
			if(Integer.valueOf(lstRamos.subclasse) == 0)
			{
				if(Integer.valueOf(lstRamos.classe) == 0)
				{
					if(Integer.valueOf(lstRamos.grupo) == 0)
					{
						if(Integer.valueOf(lstRamos.divisao) == 0)      // Nivel Seção
						{         
							nomeSecao = lstRamos.nomeAtividadecnae;
							guardDescricao(mapDetalhes, lstRamos.secao, lstRamos.nomeAtividadecnae);
						}
						else
						{												// Nivel Divisao
							nomeDivisao = lstRamos.nomeAtividadecnae;
							montaCodHierarquico(lstRamos, 'divisao');
							guardDescricao(mapDetalhes, lstRamos.divisao, lstRamos.nomeAtividadecnae);
						}
					}
					else
					{													// Nivel Grupo
						nomeGrupo = lstRamos.nomeAtividadecnae;
						montaCodHierarquico(lstRamos, 'grupo');
						guardDescricao(mapDetalhes, lstRamos.grupo, lstRamos.nomeAtividadecnae);
					}
				}
				else	
				{													    // Nivel Classe
					nomeClasse = lstRamos.nomeAtividadecnae;
					montaCodHierarquico(lstRamos, 'classe');
					guardDescricao(mapDetalhes, lstRamos.classe, lstRamos.nomeAtividadecnae);
				}
			}
			else
			{															// Nivel Sub-Classe
				nomeSubClasse = lstRamos.nomeAtividadecnae;
				montaCodHierarquico(lstRamos, 'subclasse');
			}				

			// Gera registro

			RamoAtividade__c ramo = new RamoAtividade__c();

			ramo.Name 				= lstRamos.nomeAtividadecnae.abbreviate(80);
		    ramo.CodigoSecao__c     = lstRamos.secao;
		    ramo.CodigoDivisao__c   = lstRamos.divisao;
		    ramo.CodigoGrupo__c     = lstRamos.grupo;
		    ramo.CodigoClasse__c    = lstRamos.classe;
		    ramo.CodigoSubclasse__c = lstRamos.subClasse;
			ramo.NumeroCnae__c		= lstRamos.numeroCnae;
			ramo.IdExterno__c 		= lstRamos.secao + 
									  lstRamos.divisao + 
									  lstRamos.grupo + 
									  lstRamos.classe + 
									  lstRamos.subclasse + 
									  String.valueOf(lstRamos.numeroCnae);

			ramo.NomeSecao__c         = nomeSecao;
			ramo.NomeDivisao__c       = nomeDivisao;
			ramo.NomeGrupo__c         = nomeGrupo;
			ramo.NomeClasse__c        = nomeClasse;
			ramo.NomeAtividadeCnae__c = nomeSubClasse;

			dadosParaSincronizar.add(ramo);

		}

		for(RamoAtividade__c ramo : dadosParaSincronizar)
		{
			if(String.isEmpty(ramo.NomeClasse__c))
				ramo.NomeClasse__c = buscaDescricao(mapDetalhes, ramo.codigoClasse__c);

			if(String.isEmpty(ramo.NomeGrupo__c))
				ramo.NomeGrupo__c = buscaDescricao(mapDetalhes, ramo.codigoGrupo__c);

			if(String.isEmpty(ramo.NomeDivisao__c))
				ramo.NomeDivisao__c = buscaDescricao(mapDetalhes, ramo.codigoDivisao__c);	

			if(String.isEmpty(ramo.NomeSecao__c))
				ramo.NomeSecao__c = buscaDescricao(mapDetalhes, ramo.codigoSecao__c);
		}

		if(!dadosParaSincronizar.isEmpty()){
			upsert dadosParaSincronizar IdExterno__c;
		}


		IntegracaoBO.getInstance().atualizarUltimaExecucao('RamoAtividade__c');
		List<RamoAtividade__c> dadosEmAnalise = RamoAtividadeDAO.getInstance().buscarRamoAtividadePorStatus('Em análise');

		if (dadosEmAnalise.size() > 0) {
			// publicar feed com mencionando
			String mensagem = 'As informações de Ramos de Atividade foram atualizadas. Verifique as novas ocorrências, pois existem Ramos de Atividade que estão aguardando análise.';
			List<User> lstUsuarios = UserBO.getInstance().tempBuscarAliasNotificacoes();
			ChatterBO.publicarItemFeed(mensagem, lstUsuarios);
		}
		else {
			System.debug('::: Ramos de Atividade com Status "Em análise": ' + dadosEmAnalise.size());
		}

	}

	private void guardDescricao(Map<String, String> mapDetalhes, String key, String descricao)
	{
		if(!mapDetalhes.containsKey(key))
		{
			mapDetalhes.put(key, descricao);	
		}
	}

	private String buscaDescricao(Map<String, String> mapDetalhes, String key)
	{
		String descricao;

		if(mapDetalhes.containsKey(key))
		{
			descricao = mapDetalhes.get(key);	
		}

		return descricao;
	}

	private void montaCodHierarquico(ServiceTO.ListRamoAtividadeTO lstRamos, String strTipo)
	{
		if(strTipo == 'subclasse')
		{	
			LstRamos.subclasse = lstRamos.divisao + lstRamos.grupo + LstRamos.classe + LstRamos.subclasse;			
			LstRamos.classe    = lstRamos.divisao + lstRamos.grupo + LstRamos.classe;
			LstRamos.grupo     = lstRamos.divisao + lstRamos.grupo;
			LstRamos.divisao   = lstRamos.divisao;
		}
		else if(strTipo == 'classe')
		{
			LstRamos.classe    = lstRamos.divisao + lstRamos.grupo + LstRamos.classe;
			LstRamos.grupo     = lstRamos.divisao + lstRamos.grupo;
			LstRamos.divisao   = lstRamos.divisao;
		}
		else if(strTipo == 'grupo')
		{
			LstRamos.grupo     = lstRamos.divisao + lstRamos.grupo;
			LstRamos.divisao   = lstRamos.divisao;			
		}
		else if(strTipo == 'divisao')
		{
			LstRamos.divisao   = lstRamos.divisao;						
		}
	}



/*
	public void sincronizarDados() {
		ServiceTO.RamoAtividadeTO tempDados = servico.buscarDados();

		Boolean temDados = false;//(tempDados.size() > 0);

		List<RamoAtividade__c> dadosParaSincronizarSecoes = new List<RamoAtividade__c>();
		List<RamoAtividade__c> dadosParaSincronizarDivisoes = new List<RamoAtividade__c>();
		List<RamoAtividade__c> dadosParaSincronizarGrupos = new List<RamoAtividade__c>();
		List<RamoAtividade__c> dadosParaSincronizarClasses = new List<RamoAtividade__c>();
		List<RamoAtividade__c> dadosParaSincronizarSubclasses = new List<RamoAtividade__c>();

		//System.debug('::: tempDados.secoes[0]: ' + tempDados.secoes[0]);

		for (ServiceTO.RamoAtividadeSecaoTO secao : tempDados.secoes) {
			System.debug(': ' + secao.secao + ', ' + secao.denominacao);
			
			RamoAtividade__c ramo = new RamoAtividade__c();
			ramo.IdExterno__c = secao.secao;
			ramo.Name = secao.denominacao.abbreviate(80);
			ramo.CodigoSecao__c = secao.secao;
			ramo.NomeSecao__c = secao.denominacao.abbreviate(255);
			dadosParaSincronizarSecoes.add(ramo);

			for (ServiceTO.RamoAtividadeDivisaoTO divisao : secao.divisoes) {
				//System.debug(':: \t' + divisao.divisao + ', ' + divisao.denominacao);
				
				ramo = new RamoAtividade__c();
				ramo.IdExterno__c = divisao.divisao;
				ramo.Name = divisao.denominacao.abbreviate(80);
				ramo.CodigoSecao__c = secao.secao;
				ramo.NomeSecao__c = secao.denominacao.abbreviate(255);
				ramo.CodigoDivisao__c = divisao.divisao;
				ramo.NomeDivisao__c = divisao.denominacao.abbreviate(255);
				dadosParaSincronizarDivisoes.add(ramo);

				for (ServiceTO.RamoAtividadeGrupoTO grupo : divisao.grupos) {
					//System.debug('::: \t\t' + grupo.grupo + ', ' + grupo.denominacao);
					
					ramo = new RamoAtividade__c();
					ramo.IdExterno__c = grupo.grupo;
					ramo.Name = grupo.denominacao.abbreviate(80);
					ramo.CodigoSecao__c = secao.secao;
					ramo.NomeSecao__c = secao.denominacao.abbreviate(255);
					ramo.CodigoDivisao__c = divisao.divisao;
					ramo.NomeDivisao__c = divisao.denominacao.abbreviate(255);
					ramo.CodigoGrupo__c = grupo.grupo;
					ramo.NomeGrupo__c = grupo.denominacao.abbreviate(255);
					dadosParaSincronizarGrupos.add(ramo);

					for (ServiceTO.RamoAtividadeClasseTO classe : grupo.classes) {
						//System.debug(':::: \t\t\t' + classe.classe + ', ' + classe.denominacao);
						
						ramo = new RamoAtividade__c();
						ramo.IdExterno__c = classe.classe;
						ramo.Name = classe.denominacao.abbreviate(80);
						ramo.CodigoSecao__c = secao.secao;
						ramo.NomeSecao__c = secao.denominacao.abbreviate(255);
						ramo.CodigoDivisao__c = divisao.divisao;
						ramo.NomeDivisao__c = divisao.denominacao.abbreviate(255);
						ramo.CodigoGrupo__c = grupo.grupo;
						ramo.NomeGrupo__c = grupo.denominacao.abbreviate(255);
						ramo.CodigoClasse__c = classe.classe;
						ramo.NomeClasse__c = classe.denominacao.abbreviate(255);
						dadosParaSincronizarClasses.add(ramo);

						for (ServiceTO.RamoAtividadeSubclasseTO subclasse : classe.subclasses) {
							//System.debug('::::: \t\t\t\t' + subclasse.subclasse + ', ' + subclasse.denominacao);
							
							ramo = new RamoAtividade__c();
							ramo.IdExterno__c = subclasse.subclasse;
							ramo.Name = subclasse.denominacao.abbreviate(80);
							ramo.CodigoSecao__c = secao.secao;
							ramo.NomeSecao__c = secao.denominacao.abbreviate(255);
							ramo.CodigoDivisao__c = divisao.divisao;
							ramo.NomeDivisao__c = divisao.denominacao.abbreviate(255);
							ramo.CodigoGrupo__c = grupo.grupo;
							ramo.NomeGrupo__c = grupo.denominacao.abbreviate(255);
							ramo.CodigoClasse__c = classe.classe;
							ramo.NomeClasse__c = classe.denominacao.abbreviate(255);
							ramo.CodigoSubclasse__c = subclasse.subclasse;
							ramo.Name = subclasse.denominacao.abbreviate(80);
							dadosParaSincronizarSubClasses.add(ramo);
						}
					}
				}
			}
			//System.debug('::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
		}

		if (dadosParaSincronizarSecoes.size() > 0) {
			upsert dadosParaSincronizarSecoes IdExterno__c;
		}

		if (dadosParaSincronizarDivisoes.size() > 0) {
			upsert dadosParaSincronizarDivisoes IdExterno__c;
		}

		if (dadosParaSincronizarGrupos.size() > 0) {
			upsert dadosParaSincronizarGrupos IdExterno__c;
		}

		if (dadosParaSincronizarClasses.size() > 0) {
			upsert dadosParaSincronizarClasses IdExterno__c;
		}

		if (dadosParaSincronizarSubclasses.size() > 0) {
			upsert dadosParaSincronizarSubclasses IdExterno__c;
		}

		IntegracaoBO.getInstance().atualizarUltimaExecucao('RamoAtividade__c');
		List<RamoAtividade__c> dadosEmAnalise = RamoAtividadeDAO.getInstance().buscarRamoAtividadePorStatus('Em análise');

		if (dadosEmAnalise.size() > 0) {
			// publicar feed com mencionando
			String mensagem = 'As informações de Ramos de Atividade foram atualizadas. Verifique as novas ocorrências, pois existem Ramos de Atividade que estão aguardando análise.';
			List<User> lstUsuarios = UserBO.getInstance().tempBuscarAliasNotificacoes();
			ChatterBO.publicarItemFeed(mensagem, lstUsuarios);
		}
		else {
			System.debug('::: Ramos de Atividade com Status "Em análise": ' + dadosEmAnalise.size());
		}
	}
*/
	//private Map<Id, RamoAtividade__c> buscarRamosAtividadePorTipo(String tipo, List<ServiceTO.RamoAtividadeTO> tempDados) {
	//	dadosParaSincronizar = new List<RamoAtividade__c>();
	//	for (ServiceTO.RamoAtividadeTO dado : tempDados) {
	//		if (dado.tipo.toLowerCase() == tipo) {
	//			RamoAtividade__c ramoAtividade = new RamoAtividade__c();
	//			ramoAtividade.Name = dado.denominacao.abbreviate(80);
	//			ramoAtividade.Tipo__c = dado.tipo;
	//			ramoAtividade.Codigo__c = dado.codigo;
	//			if (tipo.toLowerCase() != 'seção') {
	//				ramoAtividade.RamoPai__c = 
	//			}
	//			dadosParaSincronizar.add(ramoAtividade);
	//		}
	//	}

	//	if (!dadosParaSincronizar.isEmpty()) {
	//		// faz upsert
	//		upsert dadosParaSincronizar Codigo__c;

	//		// converte lista para map com os ids recém criados
	//		Map<Id, RamoAtividade__c> mapRamosAtividadeDivisao = new Map<Id, RamoAtividade__c>([SELECT Id, Name, Tipo__c, Codigo__c, Status__c FROM RamoAtividade__c WHERE Tipo__c = 'seção' ORDER BY Codigo__c]);
	//	}
	//}
}