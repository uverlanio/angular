({
	inicializar : function(component, event) {
		component.set('v.componente', component);
	},

	//Busca todos os produtos possíveis de serem configurados
	buscarProdutos : function(component, event) {
		let action = component.get("c.buscarProdutosComerciais");

		action.setParams({
			segmento: component.get("v.segmento")
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
            	let lista = response.getReturnValue();

            	//Gera map com os nomes dos produtos
				let mapNomeProduto = component.get("v.mapNomeProduto");
				mapNomeProduto = {};

				for(let produto of lista){
					mapNomeProduto[produto.Id] = produto.Name;
				}

				component.set("v.produtos", lista);
            	component.set("v.produtosFiltrados", lista);
            	component.set("v.mapNomeProduto", mapNomeProduto);

            	//Faz com o que os produtos escolhidos já existente sejam renderizados no componente filho
            	this.adicionarProdutosComponenteFilho(component);

            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},

	//Filtra os produtos por nome de acordo com com o valor encontrado no campo de filtro
	filtrar : function(component, event) {
		let filtro = component.get("v.filtro");
		let produtos = component.get("v.produtos");
		let produtosFiltrados = [];

		if(filtro){
			produtosFiltrados = produtos.filter(produto => produto.Name.toLowerCase().indexOf(filtro.toLowerCase()) > -1);
		}
		else{
			produtosFiltrados = produtos;
		}
		
		component.set("v.produtosFiltrados", produtosFiltrados);
	},

	//Seleciona ou remove um produto
	selecionar: function (component, event) {
		let produtoId = event.currentTarget.dataset.produtoid;
		let produtosConfiguracao = component.get("v.produtosConfiguracao");
		let novoProdutoConf = {sobjectType: 'ProdutoConfiguracao__c', Produto__c: produtoId, Editavel__c: false, Ordem__c: null};
		produtosConfiguracao.push(novoProdutoConf);
		component.set("v.produtosConfiguracao", produtosConfiguracao);

		//Chama método diretamento do componente filho para adicionar
		this.adicionarProdutosComponenteFilho(component);
	},

	//Chama método diretamento do componente filho para adicionar os produtos
	adicionarProdutosComponenteFilho: function(component){
		let cmpProdutosSelecioandosConf = component.find("cmpProdutosSelecioandosConf");
		cmpProdutosSelecioandosConf.adicionarProdutoSelecionado();
	},

	//Retorna os produtos/garantias escolhidos
	retornarProdutosConfigurador: function(component, event){
		//Recupera os produtos/garantias
		let produtosEscolhidos = {};
		let produtosRetornar = {};
		let cmpProdutosSelecioandosConf = component.find("cmpProdutosSelecioandosConf");
		cmpProdutosSelecioandosConf.buscarProdutosEscolhidos(produtosEscolhidos);

		//Realiza separação dos produtos/garantias para facilitar no momento de realizar algum DML
		for(let produto of produtosEscolhidos["produtos"]){
			produtosRetornar[produto.timestamp] = JSON.parse(JSON.stringify(produto));
		}

		//Retorna esses produtos para o componente principal por referencia
    	let params = event.getParam('arguments');
    	params.mapProdutosConfigurador['produtosEscolhidos'] = produtosRetornar;
	}	
})