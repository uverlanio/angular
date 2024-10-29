/**
 * Regras de Negócio do Objeto Modalidade__c
 * @author João Losada @ 28/06/2018
 *
 **/
public with sharing class ModalidadeBO {
	private static final ModalidadeBO instance = new ModalidadeBO();
	private ModalidadeDAO dao = ModalidadeDAO.getInstance();

	private ModalidadeBO() { }

	public static ModalidadeBO getInstance() {
		return instance;
	}

	public void sincronizarDados() {

		System.debug('====== Sincronizando Modalidade');

		ServiceTO.ModalidadeTO tempDados = F5Service.getInstance().buscarModalidades('5');

		System.debug('======= Modalidades retornadas do serviço');
		System.debug(tempDados);

		System.debug('======= Quantidade de modalidades retornadas do serviço');
		System.debug(tempDados.Modalidades.size());

		List<Modalidade__c> dadosParaSincronizar = new List<Modalidade__c>();
		Map<String, Id> mapEmpresa = new Map<String, Id>();
		Map<String, Id> mapRamoSeguro = new Map<String, Id>();

	
		Set<String> LstcodEmpresa = new Set<String>();
		Set<String> LstcodRamo = new Set<String>();

		for (ServiceTO.ListModalidadesTO lstModalidade : tempDados.Modalidades) 
		{
			LstcodEmpresa.add(lstModalidade.codigoEmpresa);
			LstcodRamo.add(lstModalidade.codigoRamo);
		}			

		// busca id ramo atividade
		for(RamoSeguro__c RamoSeguro : RamoSeguroDAO.getInstance().obterRamoPorCodigos(LstcodRamo))
		{
			mapRamoSeguro.put(RamoSeguro.Codigo__c, RamoSeguro.Id);
		}

		// busca id empresa
		for(Account Empresa : AccountDAO.getInstance().buscarContasPorCodEmpresa(lstcodEmpresa))
		{
			mapEmpresa.put(Empresa.CodigoEmpresa__c, Empresa.Id);
		}

		Id strIdEmpresa;
		Id strIdRamo;

		for (ServiceTO.ListModalidadesTO lstModalidade : tempDados.Modalidades) 
		{
			// busca id empresa
			if(mapEmpresa.containsKey(lstModalidade.codigoEmpresa))
			{
				strIdEmpresa = mapEmpresa.get(lstModalidade.codigoEmpresa); 
			}

			// busca id ramo atividade
			if(mapRamoSeguro.containsKey(lstModalidade.codigoRamo))
			{
				strIdRamo    = mapRamoSeguro.get(lstModalidade.codigoRamo);
			}

			String strKey = String.valueOf(lstModalidade.codigoModalidade) + '.' + String.valueOf(lstModalidade.codigoEmpresa) + '.' + String.valueOf(lstModalidade.codigoRamo);

			Modalidade__c modalidade = new Modalidade__c();

			modalidade.Codigo__c 	= lstModalidade.codigoModalidade;
			modalidade.Descricao__c = lstModalidade.nomeModalidade;
			modalidade.Name 		= lstModalidade.nomeModalidade;
			modalidade.Empresa__c 	= strIdEmpresa;
			modalidade.RamoSeguro__c = strIdRamo;
			modalidade.IdExterno__c = strKey;

			dadosParaSincronizar.add(modalidade);

		}

		System.debug('======= Modalidades para inserir: ');
		System.debug(dadosParaSincronizar);

		System.debug('======= Quantidade de modalidades para inserir: ');
		System.debug(dadosParaSincronizar.size());

		if(!dadosParaSincronizar.isEmpty()){
			upsert dadosParaSincronizar IdExterno__c;
		}

		IntegracaoBO.getInstance().atualizarUltimaExecucao('Modalidade__c');

	}
}