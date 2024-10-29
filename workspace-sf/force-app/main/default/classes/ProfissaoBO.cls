/**
 * Regras de Negócio do Objeto Profissao__c
 * @author Fernando Barcellos @ 05/12/2017
 *
 **/
 //INICIO | PLV-1586-29-v1
public class ProfissaoBO {
	private static final ProfissaoBO instance = new ProfissaoBO();
	private ProfissaoDAO dao = ProfissaoDAO.getInstance();

	private ProfissaoBO() { }

	public static ProfissaoBO getInstance() {
		return instance;
	}

	/*
	public void sincronizarDados() {
		ServiceTO.ProfissaoTO tempDados = F5Service.getInstance().buscarProfissoes();

        List<Profissao__c> lstProfissao = new List<Profissao__c>();

        String strKey;

		for (ServiceTO.ListProfissoesTO profissoes : tempDados.ResponseObterDominiosOcupacao.ocupacao) {

    		strKey = profissoes.codigoOcupacao;

			Profissao__c objProfissao = new Profissao__c();

			objProfissao.CodigoGrandeGrupo__c = profissoes.codigoGrandeGrupo;
			objProfissao.CodigoSubGrupoPrincipal__c = profissoes.codigoSubGrupoPrincipal;
			objProfissao.CodigoSubGrupo__c = profissoes.codigoSubGrupo;
			objProfissao.CodigoFamilia__c = profissoes.codigoFamilia;
			objProfissao.Codigo__c = profissoes.codigoOcupacao;

			objProfissao.NomeGrandeGrupo__c = profissoes.nomeGrandeGrupo;
			objProfissao.NomeSubGrupoPrincipal__c = profissoes.nomeSubGrupoPrincipal;
			objProfissao.NomeSubGrupo__c = profissoes.nomeSubGrupo;
			objProfissao.NomeFamilia__c = profissoes.nomeFamilia;
			objProfissao.Name = profissoes.nomeOcupacao.abbreviate(80);
			
			objProfissao.ProfissaoSAP__c = 'ACOUGUEIRO'; // provisório
			
			objProfissao.IdExterno__c = strKey;

            lstProfissao.add(objProfissao);
		}


		if (lstProfissao.size() > 0) {
			upsert lstProfissao IdExterno__c;
		}


		IntegracaoBO.getInstance().atualizarUltimaExecucao('Profissao__c');
		List<Profissao__c> dadosEmAnalise = ProfissaoDAO.getInstance().buscarProfissoesPorStatus('Em análise');

		if (dadosEmAnalise.size() > 0) {
			// publicar feed com mencionando
			String mensagem = 'As informações de Profissões foram atualizadas. Verifique as novas ocorrências, pois existem Profissões que estão aguardando análise.';
			List<User> lstUsuarios = UserBO.getInstance().tempBuscarAliasNotificacoes();
			ChatterBO.publicarItemFeed(mensagem, lstUsuarios);
		}
		else {
			System.debug('::: Profissões com Status "Em análise": ' + dadosEmAnalise.size());
		}
	}*/


	public void sincronizarDados() {
		//PLV-4878 INICIO
		ServiceTO.OcupacoesTO tempService = F5Service.getInstance().buscarProfissoes();
		system.debug('tempService '+JSON.serialize(tempService));
		

		List<String> lstIdGrandesGrupos = new List<String>();
		List<String> lstIdGruposPrincipais = new List<String>();
		List<String> lstIdSubGrupos = new List<String>();
		List<String> lstIdFamilias = new List<String>();
		List<String> lstIdOcupacoes = new List<String>();


		List<Profissao__c> dadosParaSincronizarGrandesGrupos = new List<Profissao__c>();
		List<Profissao__c> dadosParaSincronizarGruposPrincipais = new List<Profissao__c>();
		List<Profissao__c> dadosParaSincronizarSubGrupos = new List<Profissao__c>();
		List<Profissao__c> dadosParaSincronizarFamilias = new List<Profissao__c>();
		List<Profissao__c> dadosParaSincronizarOcupacoes = new List<Profissao__c>();

		
		List<String> idList1 = new List<String>();
		List<String> idList2 = new List<String>();
		List<String> idList3 = new List<String>();
		List<String> idList4 = new List<String>();
		List<String> idList5 = new List<String>();

		Map<Integer,String> MapGrandeGrupo = new Map<Integer,String>();
		Map<Integer,String> MapSubGrupoPricipal = new Map<Integer,String>();
		Map<Integer,String> MapSubGrupo = new Map<Integer,String>();
		Map<Integer,String> MapFamilia = new Map<Integer,String>();

		

		for (ServiceTO.TestListProfissoesTO ocupacao : tempService.ocupacoes) {
			Profissao__c profissao = new Profissao__c();
			
			if (ocupacao.codigoGrupo != null && !lstIdGrandesGrupos.contains(String.valueOf(ocupacao.codigoGrupo))){
				
				profissao.Name = ocupacao.nomeOcupacao.abbreviate(80).toUpperCase();
				profissao.IdExterno__c = String.valueOf(ocupacao.codigoGrupo);
				idList1.add(profissao.IdExterno__c);
				profissao.CodigoGrandeGrupo__c = String.valueOf(ocupacao.codigoGrupo);
				profissao.NomeGrandeGrupo__c = ocupacao.nomeOcupacao.toUpperCase();
				profissao.Codigo__c = String.valueOf(ocupacao.codigoGrupo);
				profissao.CodigoProfissao__c = String.valueOf(ocupacao.codigoGrupo);
				dadosParaSincronizarGrandesGrupos.add(profissao);
				lstIdGrandesGrupos.add(profissao.CodigoGrandeGrupo__c);
				MapGrandeGrupo.put(ocupacao.codigoGrupo,profissao.NomeGrandeGrupo__c); 
				continue;
			}

			if (ocupacao.codigoSubGrupoPrincipal != null && !lstIdGruposPrincipais.contains(String.valueOf(ocupacao.codigoSubGrupoPrincipal))){
				String codConcat = String.valueOf(ocupacao.codigoGrupo)+String.valueOf(ocupacao.codigoSubGrupoPrincipal);
				profissao.IdExterno__c = codConcat;
				idList2.add(profissao.IdExterno__c);
				profissao.Name = ocupacao.nomeOcupacao.abbreviate(80).toUpperCase();
				profissao.CodigoSubGrupoPrincipal__c = String.valueOf(ocupacao.codigoSubgrupoPrincipal);
				profissao.NomeSubGrupoPrincipal__c = ocupacao.nomeOcupacao.toUpperCase();
				profissao.CodigoGrandeGrupo__c = String.valueOf(ocupacao.codigoGrupo);
				profissao.NomeGrandeGrupo__c = MapGrandeGrupo.get(ocupacao.codigoGrupo); 
				profissao.Codigo__c = codConcat;
				profissao.CodigoProfissao__c = codConcat;
				dadosParaSincronizarGruposPrincipais.add(profissao);
				lstIdGruposPrincipais.add(profissao.CodigoSubGrupoPrincipal__c);
				MapSubGrupoPricipal.put(ocupacao.codigoSubGrupoPrincipal,profissao.NomeSubGrupoPrincipal__c); 
				continue;
			}

			if (ocupacao.codigoSubgrupo!= null && !lstIdSubGrupos.contains(String.valueOf(ocupacao.codigoSubgrupo))){
				String codConcat = String.valueOf(ocupacao.codigoGrupo) + String.valueOf(ocupacao.codigoSubgrupoPrincipal)+ String.valueOf(ocupacao.codigoSubGrupo);
				profissao.IdExterno__c = codConcat;
				idList3.add(profissao.IdExterno__c);
				profissao.Name = ocupacao.nomeOcupacao.abbreviate(80).toUpperCase();
				profissao.CodigoSubGrupo__c = String.valueOf(ocupacao.codigoSubGrupo);
				profissao.NomeSubGrupo__c = ocupacao.nomeOcupacao.toUpperCase();
				profissao.CodigoSubGrupoPrincipal__c = String.valueOf(ocupacao.codigoSubGrupoPrincipal);
				profissao.NomeSubGrupoPrincipal__c = MapSubGrupoPricipal.get(ocupacao.codigoSubGrupoPrincipal); 
				profissao.CodigoGrandeGrupo__c = String.valueOf(ocupacao.codigoGrupo);
				profissao.NomeGrandeGrupo__c = MapGrandeGrupo.get(ocupacao.codigoGrupo); 
				profissao.Codigo__c = codConcat; 
				profissao.CodigoProfissao__c = codConcat;
				dadosParaSincronizarSubGrupos.add(profissao);
				lstIdSubGrupos.add(profissao.CodigoSubGrupo__c);
				MapSubGrupo.put(ocupacao.codigoSubgrupo,profissao.NomeSubGrupo__c);
				continue;
			}

			if (ocupacao.codigoFamilia != null && !lstIdFamilias.contains(String.valueOf(ocupacao.codigoFamilia))){
				String codConcat = String.valueOf(ocupacao.codigoGrupo) + String.valueOf(ocupacao.codigoSubGrupoPrincipal) + String.valueOf(ocupacao.codigoSubGrupo)+ String.valueOf(ocupacao.codigoFamilia);
				profissao.IdExterno__c = codConcat;
				idList4.add(profissao.IdExterno__c);
				profissao.Name = ocupacao.nomeOcupacao.abbreviate(80).toUpperCase();
				profissao.CodigoFamilia__c = codConcat;
				profissao.NomeFamilia__c = ocupacao.nomeOcupacao.toUpperCase();
				profissao.CodigoSubGrupo__c = String.valueOf(ocupacao.codigoSubGrupo);
				profissao.NomeSubGrupo__c = MapSubGrupo.get(ocupacao.codigoSubGrupo); 
				profissao.CodigoSubGrupoPrincipal__c = String.valueOf(ocupacao.codigoSubGrupoPrincipal);
				profissao.NomeSubGrupoPrincipal__c = MapSubGrupoPricipal.get(ocupacao.codigoSubGrupoPrincipal);
				profissao.CodigoGrandeGrupo__c = String.valueOf(ocupacao.codigoGrupo); 
				profissao.NomeGrandeGrupo__c = MapGrandeGrupo.get(ocupacao.codigoGrupo);
				profissao.Codigo__c = codConcat;
				profissao.CodigoProfissao__c = codConcat;
				dadosParaSincronizarFamilias.add(profissao);
				lstIdFamilias.add(String.valueOf(ocupacao.codigoFamilia));
				MapFamilia.put(ocupacao.codigoFamilia,profissao.NomeFamilia__c); 
				continue;
			}
			
			if (ocupacao.codigoOcupacao!= null && !lstIdOcupacoes.contains(String.valueOf(ocupacao.codigoOcupacao))){
				String CodigoOcupacao = String.valueOf(ocupacao.codigoOcupacao);
				if(CodigoOcupacao.length() <= 1){
					CodigoOcupacao = '0' + CodigoOcupacao;
				}
				String codConcat = String.valueOf(ocupacao.codigoGrupo) + String.valueOf(ocupacao.codigoSubGrupoPrincipal) + String.valueOf(ocupacao.codigoSubGrupo)+ String.valueOf(ocupacao.codigoFamilia) + '-' + CodigoOcupacao;
				profissao.IdExterno__c = codConcat;
				idList5.add(profissao.IdExterno__c);
				profissao.Name = ocupacao.nomeOcupacao.abbreviate(80).toUpperCase();
				profissao.CodigoProfissao__c = codConcat;
				profissao.Codigo__c = codConcat;
				profissao.CodigoFamilia__c = String.valueOf(ocupacao.codigoGrupo) + String.valueOf(ocupacao.codigoSubGrupoPrincipal) + String.valueOf(ocupacao.codigoSubGrupo)+ String.valueOf(ocupacao.codigoFamilia);
				profissao.NomeFamilia__c = MapFamilia.get(ocupacao.codigoFamilia); 
				profissao.CodigoSubGrupo__c = String.valueOf(ocupacao.codigoSubGrupo);
				profissao.NomeSubGrupo__c = MapSubGrupo.get(ocupacao.codigoSubGrupo); 
				profissao.CodigoSubGrupoPrincipal__c = String.valueOf(ocupacao.codigoSubGrupoPrincipal);
				profissao.NomeSubGrupoPrincipal__c = MapSubGrupoPricipal.get(ocupacao.codigoSubGrupoPrincipal); 
				profissao.CodigoGrandeGrupo__c = String.valueOf(ocupacao.codigoGrupo);
				profissao.NomeGrandeGrupo__c = MapGrandeGrupo.get(ocupacao.codigoGrupo);
				dadosParaSincronizarOcupacoes.add(profissao);
				lstIdOcupacoes.add(String.valueOf(ocupacao.codigoOcupacao));
				continue;
			}
		}
		

		system.debug('dadosParaSincronizarGrandesGrupos ' + dadosParaSincronizarGrandesGrupos.size());
		system.debug('dadosParaSincronizarGruposPrincipais ' + dadosParaSincronizarGruposPrincipais.size());
		system.debug('dadosParaSincronizarSubGrupos ' + dadosParaSincronizarSubGrupos.size());
		system.debug('dadosParaSincronizarFamilias ' + dadosParaSincronizarFamilias.size());
		system.debug('dadosParaSincronizarOcupacoes ' + dadosParaSincronizarOcupacoes.size());

		if (dadosParaSincronizarGrandesGrupos.size() > 0) {
			
			List<Profissao__c> profList = [select id, 
												Name, 
												IdExterno__c, 
												CodigoGrandeGrupo__c, 
												NomeGrandeGrupo__c ,
												Limite_de_capital_maximo__c 
												from Profissao__c 
												where IdExterno__c in : idList1];
			
			Map<String, Profissao__c> mapdadosParaSincronizarGrandesGrupos = new Map<String, Profissao__c>();

			for(Profissao__c prof : profList){
				if(prof.Limite_de_capital_maximo__c == null){
					prof.Limite_de_capital_maximo__c = 0;
				}
				mapdadosParaSincronizarGrandesGrupos.put(prof.IdExterno__c, prof);
			}

			update profList;
			
			for(Profissao__c prof : dadosParaSincronizarGrandesGrupos){
				if(!mapdadosParaSincronizarGrandesGrupos.containsKey(prof.IdExterno__c)){
					prof.Limite_de_capital_maximo__c = 0;
					System.debug('dadosParaSincronizarGrandesGrupos.Limite_de_capital_maximo__c ');
				}		
			}									
			upsert dadosParaSincronizarGrandesGrupos IdExterno__c;
		}

		if (dadosParaSincronizarGruposPrincipais.size() > 0) {
			
			List<Profissao__c> profList = [select id, 
												Name, 
												IdExterno__c, 
												CodigoGrandeGrupo__c, 
												NomeGrandeGrupo__c,
												Limite_de_capital_maximo__c  
												from Profissao__c 
												where IdExterno__c in : idList2];
			
			Map<String, Profissao__c> mapdadosParaSincronizarGruposPrincipais = new Map<String, Profissao__c>();

			for(Profissao__c prof : profList){
				if(prof.Limite_de_capital_maximo__c == null){
					prof.Limite_de_capital_maximo__c = 0;
				}
				mapdadosParaSincronizarGruposPrincipais.put(prof.IdExterno__c, prof);
			}

			update profList;
			
			for(Profissao__c prof : dadosParaSincronizarGruposPrincipais){
				if(!mapdadosParaSincronizarGruposPrincipais.containsKey(prof.IdExterno__c)){
					prof.Limite_de_capital_maximo__c = 0;
					System.debug('dadosParaSincronizarGruposPrincipais.Limite_de_capital_maximo__c ');
				}
					
			}
			
			upsert dadosParaSincronizarGruposPrincipais IdExterno__c;
		}

		if (dadosParaSincronizarSubGrupos.size() > 0) {
			
			List<Profissao__c> profList = [select id, 
												Name, 
												IdExterno__c, 
												CodigoGrandeGrupo__c, 
												NomeGrandeGrupo__c,
												Limite_de_capital_maximo__c  
												from Profissao__c												 
												where IdExterno__c in : idList3];
			
			Map<String, Profissao__c> mapdadosParaSincronizarSubGrupos = new Map<String, Profissao__c>();

			for(Profissao__c prof : profList){
				if(prof.Limite_de_capital_maximo__c == null){
					prof.Limite_de_capital_maximo__c = 0;
				}
				mapdadosParaSincronizarSubGrupos.put(prof.IdExterno__c, prof);
			}
			
			update profList;

			for(Profissao__c prof : dadosParaSincronizarSubGrupos){
				if(!mapdadosParaSincronizarSubGrupos.containsKey(prof.IdExterno__c)){
					prof.Limite_de_capital_maximo__c = 0;
					System.debug('dadosParaSincronizarSubGrupos.Limite_de_capital_maximo__c ');
				}

			}			
			upsert dadosParaSincronizarSubGrupos IdExterno__c;
		}

		if (dadosParaSincronizarFamilias.size() > 0) {
			
			List<Profissao__c> profList = [select id, 
												Name, 
												IdExterno__c, 
												CodigoGrandeGrupo__c, 
												NomeGrandeGrupo__c,
												Limite_de_capital_maximo__c 
												from Profissao__c 
												where IdExterno__c in : idList4];
			
			Map<String, Profissao__c> mapdadosParaSincronizarFamilias = new Map<String, Profissao__c>();

			for(Profissao__c prof : profList){
				if(prof.Limite_de_capital_maximo__c == null){
					prof.Limite_de_capital_maximo__c = 0;
				}
				mapdadosParaSincronizarFamilias.put(prof.IdExterno__c, prof);
			}
			
			update profList;

			for(Profissao__c prof : dadosParaSincronizarFamilias){
				if(!mapdadosParaSincronizarFamilias.containsKey(prof.IdExterno__c)){
					prof.Limite_de_capital_maximo__c = 0;
					System.debug('dadosParaSincronizarFamilias.Limite_de_capital_maximo__c ');
				}
					
			}
			upsert dadosParaSincronizarFamilias IdExterno__c;
		}

		if (dadosParaSincronizarOcupacoes.size() > 0) {
			
			List<Profissao__c> profList = [select id, 
												Name, 
												IdExterno__c, 
												CodigoGrandeGrupo__c, 
												NomeGrandeGrupo__c,
												Limite_de_capital_maximo__c  
												from Profissao__c 
												where IdExterno__c in : idList5];
			
			Map<String, Profissao__c> mapdadosParaSincronizarOcupacoes = new Map<String, Profissao__c>();

			for(Profissao__c prof : profList){
				if(prof.Limite_de_capital_maximo__c == null){
					prof.Limite_de_capital_maximo__c = 0;
				}
				mapdadosParaSincronizarOcupacoes.put(prof.IdExterno__c, prof);
			}
			
			update profList;

			for(Profissao__c prof : dadosParaSincronizarOcupacoes){
				if(!mapdadosParaSincronizarOcupacoes.containsKey(prof.IdExterno__c)){
					prof.Limite_de_capital_maximo__c = 0;
					System.debug('dadosParaSincronizarOcupacoes.Limite_de_capital_maximo__c ');
				}
					
			}

			upsert dadosParaSincronizarOcupacoes IdExterno__c;
		}


		IntegracaoBO.getInstance().atualizarUltimaExecucao('Profissao__c');
		
		//PLV-4878 FIM
	}


	//Valida as profissões dos segurados de uma oferta
	public Boolean validarProfissoesSeguradosOferta(Map<String, String> mapSegurados){
		try {
			//TODO
			//List<Profissao__c> profissoes = ProfissaoDAO.getInstance().buscarProfisoesPorCodigo(codigosProfissoes);
			
		} catch(Exception e) {
			throw new ProfissaoException('');
		}
		
		return true;
	}

	public List<Profissao__c> buscarProfisoesAtivasPorCodigo(String codigoProfissao) {
		return ProfissaoDAO.getInstance().buscarProfisoesAtivasPorCodigo(new Set<String>{ codigoProfissao });
	}

	public class ProfissaoException extends Exception {	}
}
//FIM | PLV-1586-29-v1