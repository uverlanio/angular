({	
	carregarListaFiltrada: function(component, event){
		component.set("v.itensFiltrados", component.get('v.itens'));
	},

	//Seleciona um produto
	escolherProduto : function(component, event) {
		let itens = component.get("v.itens");
		let produtoEscolhidoId = event.currentTarget.dataset.produtoid;
		let itemSelecionado;

		for(let item of itens){
			item.selecionado = false;

			if(item.produto.Id == produtoEscolhidoId){
				item.selecionado = true;
				itemSelecionado = item;
				component.set("v.produtoEscolhido", itemSelecionado);
			}
		}

		if(itemSelecionado.garantias.length == 0){
			this.buscarGarantias(component, itemSelecionado, itens, produtoEscolhidoId);
		}
		else{
			component.set("v.itens", itens);
		}
	},

	//Filtra os produtos por nome de acordo com com o valor encontrado no campo de filtro
	filtrar : function(component, event) {
		let filtro = component.get("v.filtro");
		let itens = component.get("v.itens");
		let itensFiltrados = [];

		if(filtro){
			itensFiltrados = itens.filter(item => item.produto.Name.toLowerCase().indexOf(filtro.toLowerCase()) > -1);
		}
		else{
			itensFiltrados = itens;
		}
		
		component.set("v.itensFiltrados", itensFiltrados);
	},

	//Busca as garantias de um produto
	buscarGarantias: function(component, item, itens, produtoId){
		let action = component.get("c.buscarGarantiasProdutos");

		action.setParams({
			produtoId
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
            	for(let garantia of response.getReturnValue()){
            		item.garantias.push(this.gerarObjetoGarantiaAccordeon(garantia));
            	}

            	component.set("v.itens", itens);
            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);	
	},

	//Gera estrutura de objeto que o accordeon entenda
	gerarObjetoGarantiaAccordeon: function(garantia){
		return {
			garantia: garantia,
			selecionado: false
		};
	},
})