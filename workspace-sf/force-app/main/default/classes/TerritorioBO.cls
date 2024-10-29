/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de Territorio__c
 *
 **************************************************************************************************************************************************************************/
public  class TerritorioBO {
	private static final TerritorioBO instancia = new TerritorioBO();
	private TerritorioDAO dao = TerritorioDAO.getInstance();

	private TerritorioBO() {
	}

	public static TerritorioBO getInstance(){
		return instancia;
	}

	 /**
     * Gera map contendo a relação de prefixos e o seus respectivos SObject
     *
     * @return Map<String, String> - Map contendo os prefixos/objeto
     */
    public Map<String, String> gerarMapPrefixoSobject(){
		Map<String, Schema.SObjectType> globalDescribe  = Schema.getGlobalDescribe();

    	Map<String, String> prefixosSobject = new Map<String, String>();
    	prefixosSobject.put(globalDescribe.get('Product2').getDescribe().getKeyPrefix(), 'Product2');
    	prefixosSobject.put(globalDescribe.get('GarantiaProduto__c').getDescribe().getKeyPrefix(), 'GarantiaProduto__c');
    	
        return prefixosSobject;
    }

	 /**
     * Gera lista de CustomPickListOptionTO com os valores dos tipos de garantia
     *
     * @return List<CustomPickListOptionTO> - Lista contendo os tipos
     */
    public List<CustomPickListOptionTO> gerarListaOpcoesTipos(){
    	List<CustomPickListOptionTO> opcoesTipo = new List<CustomPickListOptionTO>();

    	for(Schema.PicklistEntry pick : Territorio__c.Tipo__c.getDescribe().getPicklistValues()){
    		opcoesTipo.add(new CustomPickListOptionTO(pick.getLabel(), pick.getLabel()));
    	}

        return opcoesTipo;
    }

     /**
     * Gera lista de CustomPickListOptionTO com os valores dos continentes
     *
     * @return List<CustomPickListOptionTO> - Lista contendo os continentes
     */
    public List<CustomPickListOptionTO> gerarListaOpcoesContinentes(){
    	List<CustomPickListOptionTO> opcoesContinente = new List<CustomPickListOptionTO>();

    	for(Continente__mdt continente : MetadataDAO.getInstance().listarContinentes()){
    		opcoesContinente.add(new CustomPickListOptionTO(continente.MasterLabel, continente.MasterLabel));
    	}

        return opcoesContinente;
    }

    /**
     * Gera lista de CustomPickListOptionTO com os valores dos estados
     *
     * @return List<CustomPickListOptionTO> - Lista contendo os estados
     */
    public List<CustomPickListOptionTO> gerarListaOpcoesEstados(){
    	List<CustomPickListOptionTO> opcoesUF = new List<CustomPickListOptionTO>();

    	for(Schema.PicklistEntry pick : Municipio__c.Uf__c.getDescribe().getPicklistValues()){
    		opcoesUF.add(new CustomPickListOptionTO(pick.getLabel(), pick.getLabel()));
    	}

        return opcoesUF;
    }

    /**
     * Gera lista de CustomPickListOptionTO com os valores dos municipios
     *
     * @return List<CustomPickListOptionTO> - Lista contendo os municipios
     */
    public List<CustomPickListOptionTO> gerarListaOpcoesMunicipios(String estados){
        List<CustomPickListOptionTO> opcoesMunicipios = new List<CustomPickListOptionTO>();
        Set<String> setEstados = new Set<String>();
        setEstados.addAll(estados.split(';'));

        for(Municipio__c municipio : MunicipioBO.getInstance().buscarMunicipiosPorEstados(setEstados)){
            opcoesMunicipios.add(new CustomPickListOptionTO(municipio.Uf__c + ' - ' + municipio.Name, municipio.Name));
        }               

        return opcoesMunicipios;
    }

    /**
     * Gera map de CustomPickListOptionTO com os valores dos paises por continente
     *
     * @return Map<String, List<CustomPickListOptionTO>> - Map contendo a relação continente/paises
     */
    public Map<String, List<CustomPickListOptionTO>> gerarListaOpcoesPaises(){
        Map<String, List<CustomPickListOptionTO>> mapOpcoesPais = new Map<String, List<CustomPickListOptionTO>>();

        for(Pais_OLD__mdt pais : MetadataDAO.getInstance().listarPaises()){
            if(!mapOpcoesPais.containsKey(pais.Continente__r.MasterLabel)){
                mapOpcoesPais.put(pais.Continente__r.MasterLabel, new List<CustomPickListOptionTO>());
            }

            mapOpcoesPais.get(pais.Continente__r.MasterLabel).add(new CustomPickListOptionTO(pais.MasterLabel, pais.MasterLabel));
        }

        return mapOpcoesPais;
    }

    /**
     * Gera list de CustomPickListOptionTO com os valores dos paises
     *
     * @return List<CustomPickListOptionTO> - list contendo os paises
     */
    public List<CustomPickListOptionTO> gerarListaOpcoesPaises(String continentes){
        List<CustomPickListOptionTO> opcoesPais = new List<CustomPickListOptionTO>();

        for(String continente : continentes.split(';')){
            for(Pais_OLD__mdt pais : MetadataDAO.getInstance().buscarPaises(continente)){
                opcoesPais.add(new CustomPickListOptionTO(pais.MasterLabel, pais.MasterLabel));
            }
        }

        return opcoesPais;
    }

    /**
     * Realiza as buscas dos territorios de acordo com o tipo de objeto pai
     *
     * @param   sObjectPaiId  - id do objeto pai do território
     * @param   nomeSObjectPai  - nome do objeto pai
     * @return  List<Territorio__c> - Lista contendo os territorios da garantia
     */
    public List<Territorio__c> buscarTerritorios(Id sObjectPaiId, String nomeSObjectPai){
    	List<Territorio__c> territorios = new List<Territorio__c>();

    	if(nomeSObjectPai == 'GarantiaProduto__c'){
    		territorios = dao.buscarTerritoriosGarantia(sObjectPaiId);
    	}
    	else if(nomeSObjectPai == 'Product2'){
    		territorios = dao.buscarTerritoriosProduto(sObjectPaiId);
    	}

    	return territorios;
    }

    /**
     * Salva as informações de territorio da garantia passadas por parametro
     *
     * @param   territoriosGarantia  - lista de Territorio__c para serem salvas
     */
    public void salvar (List<Territorio__c> territoriosGarantia){
		try{

			upsert territoriosGarantia;
			System.debug('OK');
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
    }
}