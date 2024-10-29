/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pelo negócio do objeto de SeguradoProposta__c
 *
 
 **************************************************************************************************************************************************************************/
public without sharing class SeguradoPropostaBO { //FNPVVEP-126 INICIO-FIM
	
	private static final SeguradoPropostaBO instance = new SeguradoPropostaBO();
	private static SeguradoPropostaDAO dao = SeguradoPropostaDAO.getInstance();
	public static SeguradoPropostaBO getInstance() { 
		return instance; 
	}

	private SeguradoPropostaBO() { }

	public class SeguradoPropostaException extends Exception {	}
	
	//Não permite incluir registros em SeguradoProposta__c, quando as contas associadas são repetidas
	public void validarVidasCpfRepetidosProposta(List<SeguradoProposta__c> vidasGrupoProposta){
		Set<Id> grupoPropostaIds = new Set<Id>();
		Set<Id> propostaIds = new Set<Id>();
		Map<Id, Id> propostaGrupo = new Map<Id, Id>();
		Map<Id, List<SeguradoProposta__c>> mapVidasProposta = new Map<Id, List<SeguradoProposta__c>>();
		
		//Identifica as propostas através dos grupos da proposta
		for(SeguradoProposta__c SeguradoProposta : vidasGrupoProposta){
			grupoPropostaIds.add(SeguradoProposta.GrupoProposta__c);
		}

		for(SeguradoProposta__c vida : dao.buscarGruposPropostaPorIds(grupoPropostaIds)){
			System.debug('entrou aquii ><:');
			propostaIds.add(vida.GrupoProposta__r.ContratanteProposta__r.Proposta__c);
			propostaGrupo.put(vida.GrupoProposta__c, vida.GrupoProposta__r.ContratanteProposta__r.Proposta__c);
		}
		System.debug('entrou aquii ><:');
		System.debug('grupoPropostaIds ><:' + grupoPropostaIds);

		//Após identificar propostas, fazer busca para poder recuperar todas as vidas pertinentes a uma proposta
		for(SeguradoProposta__c vida : dao.buscarGruposPropostaPorPropostaIds(propostaIds)){
			if(!mapVidasProposta.containsKey(vida.GrupoProposta__r.ContratanteProposta__r.Proposta__c)){
				mapVidasProposta.put(vida.GrupoProposta__r.ContratanteProposta__r.Proposta__c, new List<SeguradoProposta__c>());
			}

			mapVidasProposta.get(vida.GrupoProposta__r.ContratanteProposta__r.Proposta__c).add(vida);
		}

		//Realiza validação, checkando se a uma conta/cpf já existe em uma proposta
		System.debug('vidasGrupoProposta ><:' + vidasGrupoProposta);
		System.debug('propostaGrupo ><:' + propostaGrupo);
		for(SeguradoProposta__c SeguradoProposta : vidasGrupoProposta){
			//Recupera a id da proposta relacionada a um grupo
			Id propostaId = propostaGrupo.get(SeguradoProposta.GrupoProposta__c);
			System.debug('propostaId ><:' + propostaId);
			//Valida todas as vidas dessa prosposta
			for(SeguradoProposta__c vida : mapVidasProposta.get(propostaId)){
				if(SeguradoProposta.Id != vida.Id && SeguradoProposta.Conta__c == vida.Conta__c){
					SeguradoProposta.addError('CPF já existente para uma mesma proposta.');
					break;
				}
			}
		}
	}
}