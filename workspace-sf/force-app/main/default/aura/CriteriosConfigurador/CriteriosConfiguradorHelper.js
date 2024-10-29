({
	//Incialzia componente
	inicializar : function(component, event) {
		component.set('v.componente', component);
		this.gerarMapsMetadados(component);
		this.gerarValoresOperadores(component);
		this.gerarValoresCampos(component);
	},

	//Insere uma nova linha de critério
	inserirCriterio : function(component, event) {
		let criterios = component.get('v.criterios');
		let timestamp = (Date.now()) + criterios.length;

		let novoCriterio = {
			sobjectType: 'CriterioConfiguracao__c', 
			Id: timestamp,
			Configuracao__c: component.get("v.configuracaoId"),
			Campo__c: component.get('v.campo'), 
			Operador__c: component.get('v.operador'),  
			Valor__c: component.get('v.valor')
		};

		criterios.push(novoCriterio);
		component.set('v.criterios', criterios)
		component.set('v.campo', '');
		component.set('v.operador', '');
		component.set('v.valor', '');
	},

	//Excluir um critério
	excluirCriterio : function(component, event) {
		let criterios = component.get('v.criterios');
		let criterioConfiguracaoId = event.currentTarget.dataset.criterioid;
		
		for(let i=0; i < criterios.length; i++){
			if(criterios[i].Id == criterioConfiguracaoId){
				criterios.splice(i, 1);
				break;
			}
		}

		//Caso seja uma ID valida, gera a exclusão no salesforce
		if(isNaN(criterioConfiguracaoId)){
			let action = component.get("c.excluirCriterioConfiguracao");

			action.setParams({
				criterioConfiguracaoId
			});

	        action.setCallback(this, (response) => {
	            let state = response.getState();
	            
				if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });

	        $A.enqueueAction(action);
    	}
               
        component.set('v.criterios', criterios);
	},

	gerarValoresOperadores : function(component) {
		let valoresComboOperadores = [
			{label: "Igual", value: "Igual" },
			{label: "Diferente", value: "Diferente" },
			{label: "Contém", value: "Contém" },
			{label: "Maior", value: "Maior" },
			{label: "Menor", value: "Menor" },
			{label: "Maior ou igual", value: "Maior ou igual" },
			{label: "Menor ou igual", value: "Menor ou igual" },
		];

		component.set("v.operadores", valoresComboOperadores);
	},

	//Realiza a busca de map contendo informacao de metadados dos campos
	gerarMapsMetadados : function(component) {
		let action = component.get("c.buscarMapInformacoesCamposCriterio");

		action.setParams({
			nomesObjeto: ['Account', 'Opportunity'],
			segmento: component.get('v.segmento'),
			tipoComponente: 'ConfiguradorOferta'			
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
            	let mapRetorno = JSON.parse(response.getReturnValue());
            	let mapNomeCampos = component.get('v.mapNomeCampos');
            	let mapTipoCampos = component.get('v.mapTipoCampos');
            	console.log(mapRetorno);

            	for(let key in mapRetorno){
            		mapNomeCampos[key] = mapRetorno[key].label;
            		mapTipoCampos[key] = mapRetorno[key].type;
            	}		
            	
    			component.set('v.mapNomeCampos', mapNomeCampos);
    			component.set('v.mapTipoCampos', mapTipoCampos);
            }
			else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });

        $A.enqueueAction(action);		
	},

	//Realiza a busca dos valores que deverão ser utilizados para compor a combo de Campos
	gerarValoresCampos : function(component) {
		let action = component.get("c.buscarOpcoesCamposCriterio");

		action.setParams({
			nomesObjeto: ['Account', 'Opportunity'],
			segmento: component.get('v.segmento'),
			tipoComponente: 'ConfiguradorOferta'			
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
            	component.set("v.campos", JSON.parse(response.getReturnValue()));	
            }
			else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });

        $A.enqueueAction(action);		
	}
})