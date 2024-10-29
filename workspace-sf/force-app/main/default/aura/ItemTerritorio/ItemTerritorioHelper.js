({
	//Exibe combos de acordo com o tipo escolhido
	habilitarCombos : function(component, event, inicializacao) {
		this.habilitarCombosDependentes(component, false);
	},

	habilitarCombosDependentes : function(component, inicializacao) {
		let territorio = component.get("v.item");
		let tipo = territorio.tipo;

		if(tipo){
			territorio.habilitarContinente = false;
			territorio.habilitarPais = false;
			territorio.habilitarEstado = false;
			territorio.habilitarMunicipio = false;

			if(!inicializacao){
				territorio.continente = '';
				territorio.pais = '';
				territorio.estado = '';
			}

			if(tipo == "Continente"){
				territorio.habilitarContinente = true;			
			}else if(tipo == "País"){
				territorio.habilitarContinente = true;
				territorio.habilitarPais = true;
				
			}else if(tipo == "Estado"){
				territorio.habilitarEstado = true;
				territorio.continente = 'América do Sul';
				territorio.pais = 'Brasil';
			}
			else if(tipo == "Município"){
				territorio.habilitarEstado = true;
				territorio.habilitarMunicipio = true;
				territorio.continente = 'América do Sul';
				territorio.pais = 'Brasil';
			}

			component.set("v.item", territorio);

			if(!inicializacao)
				this.atualizarListaPai(component);
		}
	},

	//Gera objeto contendo o a ação a ser disparada ao se escolher um continente
	gerarEventoBuscaPais: function(component, event) {
		component.set("v.buscaPais", {
			component: component,
			dispararAcao: (component, continente) => {
				this.buscarPaises(component, continente);
			}
		});
	},

	//Gera objeto contendo o a ação a ser disparada ao se escolher um estado
	gerarEventoBuscaMunicipio: function(component, event) {
		component.set("v.buscaMunicipio", {
			component: component,
			dispararAcao: (component, estado) => {
				this.buscarMunicipios(component, estado);
			}
		});
	},

	//Busca paises de acordo com o continente escolhido
	buscarPaises: function(component, continente){
		var action = component.get("c.buscarPaises");

		action.setParams({
            continentes: continente
        });

        action.setCallback(this, (response) => {
            var state = response.getState();
            
            if(state == "SUCCESS"){
            	let territorio = component.get("v.item");
            	territorio.pais = '';
		        territorio.optionsPais = JSON.parse(response.getReturnValue());

		        //Atualiza lista do componente pai e também o item principal
		        component.set("v.item", territorio);
		        this.atualizarListaPai(component);
            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},

	//Busca municípios de acordo com o estado escolhido
	buscarMunicipios: function(component, estado){
		var action = component.get("c.buscarMunicipios");

		action.setParams({
            estados: estado
        });

        action.setCallback(this, (response) => {
            var state = response.getState();
            
            if(state == "SUCCESS"){
            	let territorio = component.get("v.item");
            	territorio.municipio = '';
		        territorio.optionsMunicipio = JSON.parse(response.getReturnValue());

		        //Atualiza lista do componente pai e também o item principal
		        component.set("v.item", territorio);
		        this.atualizarListaPai(component);
            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},

	//Exclui um item da lista
	excluirItemTerritorio: function(component, event) {
		let territorio = component.get("v.item");
		let territorios = component.get("v.territorios");

		//Identifica o item a ser excluido
		for(let i = 0; i < territorios.length; i++){
			console.log( territorios.idx );

			if(territorios[i].idx == territorio.idx){
				territorios.splice(i, 1);
			}

			//Caso o territorio exista no Salesforce, excluir de lá também
			if(territorio.id){
				this.excluirItemTerritorioSF(component, event, territorio.id);
			} 
		}				

		//Sobreescreve lista pai
        component.set("v.territorios", territorios);
	},

	excluirItemTerritorioSF: function(component, event, territorioId) {
		var action = component.get("c.excluir");

		action.setParams({
            territorioId: territorioId
        });

        action.setCallback(this, (response) => {
            var state = response.getState();
            
            if(state == "SUCCESS"){
            	$A.get('e.force:refreshView').fire();
            }
            else{
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},

	//Atualiza a lista que contém todos os terrítorios
	atualizarListaPai: function(component){
		let itemTerritorio = component.get("v.item");
		let listaTerritorioPai = component.get("v.territorios");

		for(let itempai of listaTerritorioPai){
			if(itempai.idx == itemTerritorio.idx){
				itempai = itemTerritorio;
			}
		}

		//Sobreescreve item da lista pai
        component.set("v.territorios", listaTerritorioPai);
	}
})