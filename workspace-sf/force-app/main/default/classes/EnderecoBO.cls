/**
 * EnderecoBO
 * @author Fernando Barcellos @ 19/12/2017
 *
 **/
public class EnderecoBO {
	
	private static final EnderecoBO instance = new EnderecoBO();
	private static final EnderecoDAO dao = EnderecoDAO.getInstance();
	private static F5Service f5 = F5Service.getInstance();

	public static EnderecoBO getInstance() {
		return instance;
	}

	private EnderecoBO() { }

	public void desmarcarEnderecosAntigos(List<Endereco__c> lstEnderecos) {
		Set<Id> setIdsContas = new Set<Id>();
		Set<Id> setIdsEnderecosPrincipais = new Set<Id>();

		for (Endereco__c endereco : lstEnderecos) {
			if (endereco.MaisAtual__c == true && TriggerHelper.isChanged(endereco, 'MaisAtual__c')) { //PLV-2728 - Inicio/Fim - Adição de validação
				setIdsContas.add(endereco.Conta__c);
				setIdsEnderecosPrincipais.add(endereco.Id);
			}
		}

		if(setIdsContas.isEmpty()) return; //PLV-2728 - Inicio/Fim
		List<Endereco__c> lstEnderecosDesatualizados = dao.buscarEnderecosDesatualizados(setIdsContas);
		
		for (Endereco__c endereco : lstEnderecosDesatualizados) {
			if(!setIdsEnderecosPrincipais.contains(endereco.Id)){
				endereco.MaisAtual__c = false;
			}
		}
		TriggerHandler.bypass('EnderecoTriggerHandler');
		update lstEnderecosDesatualizados;
	}


	public List<ServiceTO.ListResultadoRetornoBuscaEndereco> buscarEndereco(String searchUf, String cep, String sufixo, String endereco, string cidade, string uf, string numero) 
	{
		List<ServiceTO.ListResultadoRetornoBuscaEndereco> LstRetorno = new List<ServiceTO.ListResultadoRetornoBuscaEndereco>();

		if(!String.isEmpty(searchUf)) 		// Executa busca do endereço pela UF
			LstRetorno = buscarEnderecoUF(searchUf);
		else if (!String.isEmpty(cep))		// Executa busca do endereço pelo CEP
			LstRetorno = buscarEnderecoCEP(cep, sufixo);
		else if (!String.isEmpty(endereco)) // Executa busca do endereço pelo Endereço
			LstRetorno = buscarEnderecoLogradouro(endereco, cidade, uf, numero);

		return LstRetorno;	
	}


	private List<ServiceTO.ListResultadoRetornoBuscaEndereco> buscarEnderecoUF(String uf) {
	
		ServiceTO.ObterCidadeUFTO tempDados = f5.buscarEnderecoPorUF(uf);

		List<ServiceTO.ListResultadoRetornoBuscaEndereco> LstRetorno = new List<ServiceTO.ListResultadoRetornoBuscaEndereco>();

		for (ServiceTO.ListenderecoGuiaPostalEBOTO endereco : tempDados.obterCidadeResponse.obterCidadeEBO.enderecoGuiaPostalEBO) 
		{
			ServiceTO.ListResultadoRetornoBuscaEndereco retorno = new ServiceTO.ListResultadoRetornoBuscaEndereco();

			retorno.codigoCidade     = endereco.codigoCidade;
			retorno.nomeCidade       = endereco.nomeCidade;
			retorno.unidadeFederativaCodigo = endereco.unidadeFederativaCodigo;
			retorno.cepCidade        = endereco.cepCidade;
			retorno.cepCidadeComplemento = endereco.cepComplementoCidade;

			LstRetorno.add(retorno);

		}

		return LstRetorno;

	}

	private List<ServiceTO.ListResultadoRetornoBuscaEndereco> buscarEnderecoCEP(String cep, String sufixo) {
	
		ServiceTO.ObterCidadeCEPTO tempDados = f5.buscarEnderecoPorCEP(cep, sufixo);
		List<ServiceTO.ListResultadoRetornoBuscaEndereco> 	LstRetorno = new List<ServiceTO.ListResultadoRetornoBuscaEndereco>();

		if(tempDados != null)
		{
			system.debug('HEHEHEHEHEHE' + tempDados);

			ServiceTO.ListResultadoRetornoBuscaEndereco retorno = new ServiceTO.ListResultadoRetornoBuscaEndereco();

			retorno.codigoLogradouro 		= tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.codigoLogradouro;
			retorno.tipoLogradouro   		= tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto.tipoLogradouro;
			retorno.nomelogradouro   		= tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto.logradouro;
			retorno.codigoCidade     		= tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.codigoCidade;
			retorno.nomeCidade       		= tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto.cidade;
			retorno.unidadeFederativaCodigo = tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto.uf;
			retorno.cepCidade        		= tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.cepCidade;
			retorno.cepCidadeComplemento 	= tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.cepComplementoCidade;
			retorno.codigoBairro     		= tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.codigoBairro;
			retorno.nomeBairro       		= tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto.bairro;
			retorno.cep              		= tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto.cep;
			retorno.cepcomplemento   		= tempDados.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO.enderecoCompleto.complementocep;
			
			LstRetorno.add(retorno);
		}

		return LstRetorno;
	}


	private List<ServiceTO.ListResultadoRetornoBuscaEndereco> buscarEnderecoLogradouro(String endereco, string cidade, string uf, string numero) {
	
		ServiceTO.ObterCidadeLogradouroTO tempDados = f5.buscarEnderecoPorLogradouro(endereco, cidade, uf, numero);

		List<ServiceTO.ListResultadoRetornoBuscaEndereco> LstRetorno = new List<ServiceTO.ListResultadoRetornoBuscaEndereco>();


		for (ServiceTO.LstEnderecosDetalheTO det : tempDados.obterLogradourosPorLogradouroResponse.enderecosGuiaPostalLocal.enderecoGuiaPostalLocal)
		 {

			ServiceTO.ListResultadoRetornoBuscaEndereco retorno = new ServiceTO.ListResultadoRetornoBuscaEndereco();

			retorno.codigoLogradouro = det.codigoLogradouro;
			retorno.tipoLogradouro   = det.tipoLogradouro;
			retorno.nomelogradouro   = det.nomelogradouro;
			retorno.codigoCidade     = det.cidade.codigoCidadeLocalidade;
			retorno.nomeCidade       = det.cidade.nomeCidadeNoGuiaPostal;
			retorno.unidadeFederativaCodigo = det.unidadeFederacao.codigoUnidadeFederacao;
			retorno.cepCidade        = det.cidade.numeroCepLogradouro;
			retorno.cepCidadeComplemento = det.cidade.complementoCepCidade;
			retorno.codigoBairro     = det.bairro.codigoBairro;
			retorno.nomeBairro       = det.bairro.nomeBairro;

			LstRetorno.add(retorno);

		 } 

		return LstRetorno;

	}

	//Atualiza os campos de endereço de um segurado
	public void atualizarEnderecoSegurados(List<Endereco__c> enderecos){
		Set<Id> contasIds = new Set<Id>();
		Map<Id, List<Endereco__c>> enderecosConta = new Map<Id, List<Endereco__c>>();
		List<ContratanteOrcamento__c> seguradosOrcamentoAtualizar = new List<ContratanteOrcamento__c>();

		//Identifica todas as conta dos endereços
		for(Endereco__c endereco : enderecos){
			contasIds.add(endereco.Conta__c);

			if(!enderecosConta.containsKey(endereco.Conta__c)){
				enderecosConta.put(endereco.Conta__c, new List<Endereco__c>());				
			}

			enderecosConta.get(endereco.Conta__c).add(endereco);
		}

		//Através das contas, identifica os segurados que deverão ter os endereços atualizados
		for(Account conta : AccountBO.getInstance().buscarContasComFilhos(contasIds)){
			Endereco__c enderecoAtual = null;

			//Identifica endereço mais atual 
			for(Endereco__c endereco : enderecosConta.get(conta.Id)){
				if(endereco.MaisAtual__c){
					enderecoAtual = endereco;
					break;
				}
			}

			//Se for encontrado endereço mais atual, atualiza segurados realcionado a mesma conta
			if(enderecoAtual != null){
				String tipoEndereco =  String.isBlank(conta.Cpf__c) ? 'Comercial' : 'Residencial';

				for(ContratanteOrcamento__c segurado : conta.ContratantesOrcamento__r){
					segurado.TipoEndereco__c = tipoEndereco;
					segurado.Bairro__c = enderecoAtual.Bairro__c;
					segurado.CEP__c = enderecoAtual.CEP__c;
					segurado.Cidade__c = enderecoAtual.Cidade__c;
					segurado.Complemento__c = enderecoAtual.Complemento__c;
					segurado.Estado__c = enderecoAtual.Estado__c;
					segurado.Logradouro__c = enderecoAtual.Logradouro__c;
					segurado.NumeroEndereco__c = enderecoAtual.Numero__c;
					segurado.TipoLogradouro__c = enderecoAtual.TipoLogradouro__c;
						
					seguradosOrcamentoAtualizar.add(segurado);
				}
			}
		}

		if(!seguradosOrcamentoAtualizar.isEmpty()){
			update seguradosOrcamentoAtualizar;
		}
	}

	public List<Endereco__c> buscarEnderecosContas(Set<Id> idsContas) {
		return dao.buscarEnderecoContas(idsContas);
	}

	//PLV-2727 - Inicio
		public String montarIdExterno(Endereco__c endereco){
			//PLV-2728 - Inicio - Add toUpperCase() - FIX
			//PLV-2995 - INICIO - Ajuste no IdExterno de endereço para formar caso não venha os dados de logradouro
			String enredecoLogradouro = String.isNotBlank(endereco.Logradouro__c) ? endereco.Logradouro__c.toUpperCase() : '';
			String enderecoComplemento = String.isNotBlank(endereco.Complemento__c) ? endereco.Complemento__c.toUpperCase() : '';
			String enderecoTipo = String.isNotBlank(endereco.TipoEndereco__c) ? endereco.TipoEndereco__c.toUpperCase() : '';//PLV-4894 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
			//PLV-2995 - FIM
			//PLV-2728 - Fim - Add toUpperCase() - FIX
			return endereco.Conta__c+'-'+endereco.CEP__c+'-'+enredecoLogradouro+'-'+endereco.Numero__c+'-'+enderecoComplemento+'-'+enderecoTipo; //PLV-4894 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B //PLV-2728 - Inicio/Fim - Add toUpperCase()
		}
	//PLV-2727 - Fim
     
    //PLV-3995 - INICIO
	public void validaEnderecoCobranca (List<Endereco__c> enderecoNewList, Map<Id,Endereco__c> enderecoOldMap){


		List<Endereco__c> enderecoList = new List<Endereco__c>();
		System.debug('  @@@ EndCobra :> ' + enderecoNewList);
		for( Endereco__c e : enderecoNewList )	if (e.EnderecoCobranca__c)	enderecoList.add(e);
		// if (enderecoList.isEmpty())	return;

		List<String> accIdList = new List<String>();
		for( Endereco__c e : enderecoList )	accIdList.add(e.Conta__c);

		Map<id,Account> accMap = new Map<id,Account>(buscaContasEnderecos(accIdList));

		List<account> accToUp = new List<account>();
		
		if(enderecoOldMap == null){
			for( Endereco__c e : enderecoList){
				Account acc = accMap.get(e.Conta__c);
				if(!acc.Enderecos__r.isEmpty())	e.addError('Apenas um endereço de cobrança pode ser definido por conta.');
				if(acc.Enderecos__r.isEmpty())	accToUp.add(adressToAcc(acc,e));
			}
		}

		if(enderecoOldMap != null){
			for( Endereco__c e : enderecoList){
				Account acc = accMap.get(e.Conta__c);
				if( (!acc.Enderecos__r.isEmpty() && acc.Enderecos__r.size() > 1 ) || 
					(!acc.Enderecos__r.isEmpty() && acc.Enderecos__r[0].Id != e.Id ))		e.addError('Apenas um endereço de cobrança pode ser definido por conta.');
				if(acc.Enderecos__r.isEmpty() || (acc.Enderecos__r[0].Id == e.Id) )		accToUp.add(adressToAcc(acc,e));
			}
		}
		if(!accToUp.isEmpty())	update accToUp;
	}

	public Account adressToAcc(Account acc, Endereco__c adress){
		acc.BillingCountry = adress.Pais__c;
		acc.BillingState = adress.Estado__c;
		acc.BillingCity = adress.Cidade__c;
		acc.BillingPostalCode = adress.CEP__c;
		acc.BillingStreet = adress.Logradouro__c;
		return acc;
	}

	
	public Map<id,Account> buscaContasEnderecos(List<String> accountList){
		return new Map<Id,Account>([
			SELECT 	Id, 
					(SELECT Id, EnderecoCobranca__c	 FROM Enderecos__r WHERE EnderecoCobranca__c = true)
			FROM 	Account
			WHERE 	Id IN :accountList
		]);
	}
	//PLV-3995 - FIM

}