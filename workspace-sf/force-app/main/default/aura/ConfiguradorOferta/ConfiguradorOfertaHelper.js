({
	//Inicializa componente com as chamadas iniciais
	inicializar : function(component, event) {
		component.set('v.componente', component);
		this.buscarDadosConfiguracao(component, event);
	},

	//Busca a configuração para 
	buscarDadosConfiguracao : function(component, event){
		let action = component.get("c.buscarConfiguracao");

		action.setParams({
			configuracaoId: component.get('v.recordId')
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
            	let obj = response.getReturnValue();
            	let produtosConfiguracao = obj.ProdutosConfiguracao__r != undefined ? obj.ProdutosConfiguracao__r : [];
            	let criteriosConfiguracao = obj.CriteriosConfiguracao__r != undefined ? obj.CriteriosConfiguracao__r : [];
            	
            	component.set("v.configuracao", obj);
				component.set("v.produtosConfiguracao", produtosConfiguracao);
				component.set("v.criteriosConfiguracao", criteriosConfiguracao);
            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},
	
	//Salva dados da configuração
	salvar: function(component, event) {
		let processarProdutosConfigurador = (component) => {
			console.log('Processando produtos...');
			let mapProdutosConfiguracao = {};
			let cmpProdutosConf = component.find("cmpProdutosConf");
			cmpProdutosConf.buscarProdutosEscolhidos(mapProdutosConfiguracao);

			let produtosEscolhidos = mapProdutosConfiguracao["produtosEscolhidos"];
			let contadorProcessamento = 0;
			let quantidadeTotalProdutos = 0;

			for(let key in produtosEscolhidos){
				quantidadeTotalProdutos++;
			}

			for(let key in produtosEscolhidos){
				contadorProcessamento++;
				this.processarProdutos(component, produtosEscolhidos[key], contadorProcessamento, quantidadeTotalProdutos);
			} 

		};

		//Salva os critérios e após isso, processa os produtos salvando os produtos e suas respectivas garantias
		this.salvarCriteriosConfigurador(component, processarProdutosConfigurador);
	},

	//Fecha o componente e atualiza o registro de configuração
	fecharComponenteAtualizarRegistro: function(){
		$A.get('e.force:refreshView').fire();
		$A.get("e.force:closeQuickAction").fire();
	},

	//Realiza o parse e o DML de um produto e suas garantias
	processarProdutos: function(component, produto, contadorProcessamento, quantidadeTotalProdutos){
		let action = component.get("c.salvarProdutosConfiguracao");

		//Reliza parse para o modelo do objeto do SF
		let produtoConfiguracao = {
			sobjectType: 'ProdutoConfiguracao__c', 
			Id: produto.id,
			Configuracao__c: component.get('v.recordId'),
			Produto__c: produto.produtoId,
			Editavel__c: produto.editavel,
			Ordem__c: produto.ordem
		};

		action.setParams({
			produtoConfiguracao
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){         		
            	this.processarGarantiasProdutos(component, response.getReturnValue(), produto.garantias, contadorProcessamento, quantidadeTotalProdutos);
            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},

	//Realiza o parse e o DML das garantias
	processarGarantiasProdutos: function(component, produtoConfId, garantias, contadorProcessamento, quantidadeTotalProdutos){
		let garantiasConfiguracaoInserir = [];
		let garantiasConfiguracaoExcluir = [];

		for(let garantia of garantias){
			if(garantia.selecionado){
				garantiasConfiguracaoInserir.push({
					sobjectType: 'GarantiaProdutoConfiguracao__c',
					Id: garantia.id,
					ProdutoConfiguracao__c: produtoConfId, 
					GarantiaProduto__c: garantia.garantiaId,
					TipoLimiteCapital__c: garantia.tipoLimiteCapital,
					LimiteCapital__c: garantia.limiteCapital
				});
			}else{
				if(garantia.id){
					garantiasConfiguracaoExcluir.push({
						sobjectType: 'GarantiaProdutoConfiguracao__c',
						Id: garantia.id
					});
				}
			}
		}

		if(garantiasConfiguracaoInserir.length > 0){
			this.salvarGarantiasConfigurador(component, JSON.stringify(garantiasConfiguracaoInserir));
		}

		if(garantiasConfiguracaoExcluir.length > 0){
			this.excluirGarantiasProdutosConfiguracao(component, JSON.stringify(garantiasConfiguracaoExcluir));	
		}

		//TODO: PASSAR A LISTA DE INSERT/EXCLUSAO NA MESMA CHAMADA, E TRATAR INTERNAMENTO NO APEX
		//ESTE TRECHO DE CÓDIGO DEVE FICAR NO CALLBACK DESSA CHAMADA UNICA A SER CRIADA
		if(contadorProcessamento == quantidadeTotalProdutos){
			this.fecharComponenteAtualizarRegistro();
		}
	},

	salvarGarantiasConfigurador: function(component, garantiasProdutosConfiguracao){
		let action = component.get("c.salvarGarantiasProdutosConfiguracao");

		action.setParams({
			garantiasProdutosConfiguracao
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
	},

	excluirGarantiasProdutosConfiguracao: function(component, garantiasProdutosConfiguracao){
		let action = component.get("c.excluirGarantiasProdutosConfiguracao");

		action.setParams({
			garantiasProdutosConfiguracao
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
	},

	salvarCriteriosConfigurador: function(component, callback){
		let criteriosConfiguracao = component.get('v.criteriosConfiguracao');
		let action = component.get("c.salvarCriteriosConfiguracao");

		//Realiza limpeza no campos de id no crétirio
		for(let criterio of criteriosConfiguracao){
			if(!isNaN(criterio.Id)){
				delete criterio.Id;
			}
		}

		action.setParams({
			criteriosConfiguracao: JSON.stringify(criteriosConfiguracao)
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
           	
           	//Caso os critérios tenham sido salvos, executa callback (processamento dos produtos e das garantias)
            if(state == "SUCCESS"){      
            	callback(component);
            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},

	//Fecha popup
	cancelar: function(component, event) {
		$A.get("e.force:closeQuickAction").fire();
	}
})