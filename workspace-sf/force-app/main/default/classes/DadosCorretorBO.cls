//INICIO | PLV-2179-27- remover duplicidade
public with sharing class DadosCorretorBO 
{
	public DadosCorretorBO(){}
	private static final DadosCorretorBO instancia = new DadosCorretorBO();
 	public static DadosCorretorBO getInstance(){ return instancia; }
	DadosCorretorDAO dao = DadosCorretorDAO.getInstance();

	public void removeRegistrosDuplicados(List<StageDadosCorretor__c> listStage){

		system.debug('quantidade de registros Stage: ' + listStage.size());

		Set<Id> setidSfCorretores = new Set<Id>();
		List<FavorecidoRemuneracao__c> listaFavorecidosRem = new List<FavorecidoRemuneracao__c>();
		Set<string> setFavorecidos = new Set<string>();
		Set<string> setCorretores = new Set<string>();
		List<DadosCorretor__c> listaDadosCorretores = new List<DadosCorretor__c> ();
		Map<string, DadosCorretor__c> mapDadosCorretor = new Map<string, DadosCorretor__c>();
		Map<string, DadosCorretor__c> mapDadosExclusao = new Map<string, DadosCorretor__c>();

		// monta o set de códigos p/ obter os corretores duplicados
		for(StageDadosCorretor__c item : listStage){
			if(!setCorretores.contains(item.Name))
				setCorretores.add(item.Name);
		}
		
		listaDadosCorretores = dao.listarDadosCorretorPorCodigo(setCorretores);

		// monta o set com os ids Sf dos corretores p/ saber se esta sendo usado nas adesões
		for(DadosCorretor__c item : listaDadosCorretores){
			if(!setidSfCorretores.contains(item.Id))
				setidSfCorretores.add(item.Id);
		}

		// Lista os corretores com base no set montado acima e monta outro set p/ remover os registros antes do delete
		listaFavorecidosRem = [SELECT Id, DadosCorretor__c FROM FavorecidoRemuneracao__c WHERE DadosCorretor__c IN: setidSfCorretores];
	
		for(FavorecidoRemuneracao__c item : listaFavorecidosRem){
			if(!setFavorecidos.contains(item.DadosCorretor__c))
				setFavorecidos.add(item.DadosCorretor__c);
		}
		system.debug('quantidade de favorecidos: ' + listaFavorecidosRem.size());

		system.debug('quantidade de registros: ' + listaDadosCorretores.size());

		// adicona registros no mapa 
		for(DadosCorretor__c corretor : listaDadosCorretores){
			string chave = corretor.Name;
			// inclui no mapa os corretores, eliminando os duplicados
			if(!mapDadosCorretor.containsKey(chave))
				mapDadosCorretor.put(chave, corretor);    
		}

		system.debug('mapa de referencia p/ exclusâo: ' + mapDadosCorretor.size());

		// varre o mapa p/ incluir os registros dulicados a serem deletados
		for(DadosCorretor__c corretorRef : mapDadosCorretor.values()){

			for(DadosCorretor__c corretor : listaDadosCorretores){

				if(corretorRef.Name == corretor.Name){

					if(corretorRef.Id != corretor.Id){

						// inclui na lista de exclusão se os registros não forem vinaculados à nenhuma adesão
						if(!setFavorecidos.contains(corretor.Id)){
							
							if(!mapDadosExclusao.containsKey(corretor.Id)){

								mapDadosExclusao.put(corretor.Id, corretor);
							}	
						}
						else
							system.debug('é usado nos favorecidos: ' + corretor.Name);
					}
				}
			}
		}
		
		// remove os registros duplicados 
		delete mapDadosExclusao.values();
	}
}
//FIM | PLV-2179-27- remover duplicidade