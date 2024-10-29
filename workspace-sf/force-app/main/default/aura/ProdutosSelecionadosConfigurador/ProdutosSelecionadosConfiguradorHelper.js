({
	//Inicializa componente
	inicializar: function(component, event) {
		component.set('v.componente', component);
	},

	//Gera lista de objetos pelo controle do acordion de produto/garantias
	gerarListaItens: function(component, event) {
		let produtos = component.get('v.produtos');
		let itens = component.get('v.itens');
		let mapNomeProduto = component.get('v.mapNomeProduto');

		//Adicona todo os itens de produtos
		if(itens.length == 0){
			let contador = 0;

			for(let produto of produtos){
				contador++;
				itens.push(this.gerarItemAccordion(produto, mapNomeProduto, contador));
			}
		}else{
			//Adiciona apenas o ultimo elemento de produto
			itens.push(this.gerarItemAccordion(produtos[produtos.length - 1], mapNomeProduto, produtos.length));
		}

		component.set('v.itens', itens);
		component.set('v.produtos', produtos);
	},

	gerarItemAccordion: function(produtoConf, mapNomes, contador){
		let timestamp = (Date.now()) + contador;
		produtoConf.timestamp = timestamp;

		return {
			id: (produtoConf.Id != undefined ? produtoConf.Id : null),
			timestamp: timestamp,
			aberto: false, 
			nome: mapNomes[produtoConf.Produto__c], 
			produtoId: produtoConf.Produto__c,
			editavel: produtoConf.Editavel__c,
			ordem: produtoConf.Ordem__c,
			garantias: [] //GARANTIAS DAS CONFIGURACAO
		};
	},

	//Remove um produto da configuração
	removerProduto: function(component, event) {
	    let timestamp = event.getParam("value");
	    let itens = component.get("v.itens");
	    let produtos = component.get("v.produtos");
	    let produtoConfiguracaoId = null;
	    
	    //Identifica o item a ser excluido
        for(let i = 0; i < itens.length; i++){
            if(itens[i].timestamp == timestamp){
                produtoConfiguracaoId = itens[i].id;
                itens.splice(i, 1);
            }           
        }

        for(let i = 0; i < produtos.length; i++){
            if(produtos[i].timestamp == timestamp){
                produtos.splice(i, 1);
            }           
        }

        component.set("v.itens", itens);
        component.set("v.produtos", produtos);

        if(produtoConfiguracaoId){
	        let action = component.get("c.excluirProdutoConfiguracao");

			action.setParams({
				produtoConfiguracaoId
			});

	        action.setCallback(this, (response) => {
	            let state = response.getState();
	            
	            if(state == "SUCCESS"){
	            } else if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });
	               
	        $A.enqueueAction(action);
        } 
	},

	//Controle de exibição do acordion
	exibirProduto: function(component, event) {
		let itens = component.get("v.itens");
		let timestampItem = event.currentTarget.dataset.timestamp;
		let itemAberto = null;

		for(let item of itens){
			if(item.timestamp == timestampItem){
				item.aberto = !item.aberto;

				if(item.aberto){
					itemAberto = item;
				}
				break;
			}
		}

		//Se não haver garantias, realiza busca para renderizar na tela (apenas no momento que o accordion for aberto)
		if(itemAberto != null && itemAberto.garantias.length == 0){
			this.buscarGarantias(component, itens, itemAberto);
		}else{
			component.set("v.itens", itens);
		}
	},

	//Busca todas as garantias referente a um produto
	buscarGarantias : function(component, itens, itemAberto) {
		let action = component.get("c.buscarGarantiasProdutos");

		action.setParams({
			produtoId: itemAberto.produtoId
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
            	//Busca as garantias da configuração existentes
				this.buscarGarantiasConfiguracao(component, itens, itemAberto, response.getReturnValue());
            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},

	//Busca todas as garantias referente a um produto
	buscarGarantiasConfiguracao : function(component, itens, itemAberto, garantiasProduto) {
		let garantiasProdutoConfiguracao = [];

		//Realiza parse da estrutura de garantias do produto para garantia da configuração
		for(let garantia of garantiasProduto){
			let garantiaConf = this.instanciarNovoGarantiaConfiguracao();
			garantiaConf.ProdutoConfiguracao__c = itemAberto.id;
			garantiaConf.GarantiaProduto__c = garantia.Id;
			garantiaConf.Name = garantia.Garantia__r.Name;

			garantiasProdutoConfiguracao.push(garantiaConf);
		}

		//Se exirtir ID do produto da configuração, busca as garantias da configuração dele
		if(itemAberto.id){
			let action = component.get("c.buscarGarantiasProdutosConfiguracao");

			action.setParams({
				produtoConfiguracaoId: itemAberto.id
			});

	        action.setCallback(this, (response) => {
	            let state = response.getState();
	            
	            if(state == "SUCCESS"){
	            	//Atribui na lista os valores das garantias da configuração já existentes
	            	for(let registroGarantiaConf of response.getReturnValue()){
						for(let garantiaConf of garantiasProdutoConfiguracao){
							if(garantiaConf.GarantiaProduto__c == registroGarantiaConf.GarantiaProduto__c){
								garantiaConf.Id = registroGarantiaConf.Id;
								garantiaConf.TipoLimiteCapital__c = registroGarantiaConf.TipoLimiteCapital__c;
								garantiaConf.LimiteCapital__c = registroGarantiaConf.LimiteCapital__c;
							}
						}	            		
	            	}

					this.atualizarItensComGarantias(component, itens, itemAberto, garantiasProdutoConfiguracao);
	            } else if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });
	               
	        $A.enqueueAction(action);
		}
		else{
			this.atualizarItensComGarantias(component, itens, itemAberto, garantiasProdutoConfiguracao);
		}

	},

	atualizarItensComGarantias: function(component, itens, itemAberto, garantiasProdutoConfiguracao){
		for(let item of itens){
			if(item.timestamp == itemAberto.timestamp){
				item.garantias = this.gerarItensGarantias(garantiasProdutoConfiguracao);
				break;
			}
		}

		component.set("v.itens", itens);
	},

	instanciarNovoGarantiaConfiguracao: function(){
		return {
			sobjectType: 'GarantiaProdutoConfiguracao__c', 
			Id: null,
			ProdutoConfiguracao__c: null,
			GarantiaProduto__c: null,
			TipoLimiteCapital__c: null,
			LimiteCapital__c: null
		};
	},

	gerarItensGarantias: function(garantiasProdutoConfiguracao){
		let lista = [];

		for(let garantiaConf of garantiasProdutoConfiguracao){
			lista.push(this.gerarItemGarantia(garantiaConf));
		}

		return lista;
	},

	gerarItemGarantia: function(garantiaConf){
		return {
			id: garantiaConf.Id,
			produtoConfiguracaoId: garantiaConf.ProdutoConfiguracao__c,
			nome: garantiaConf.Name,
			garantiaId: garantiaConf.GarantiaProduto__c,
			tipoLimiteCapital: garantiaConf.TipoLimiteCapital__c,
			limiteCapital: garantiaConf.LimiteCapital__c,
			selecionado: garantiaConf.Id != undefined && garantiaConf.Id != null
		};
	},

	//Passa por referencia, a lista contendo os produtos da configuração
	retornarProdutosConfigurador: function(component, event){
		let params = event.getParam('arguments');
    	params.produtosEscolhidos["produtos"] = component.get("v.itens");
	}
})