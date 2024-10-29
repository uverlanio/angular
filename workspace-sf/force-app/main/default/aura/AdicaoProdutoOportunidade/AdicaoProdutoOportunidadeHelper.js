({
	//Busca a oportunidade e os produtos para serem ofertados
	buscarProdutosOferta : function(component, event) {
		let action = component.get("c.buscarOportunidade");

		action.setParams({
			oportunidadeId : component.get("v.recordId")
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
            	let oportunidade = response.getReturnValue();
            	this.buscarProdutosVigentes(component, oportunidade.RecordType.DeveloperName);
            	//this.buscarProdutosSugestao

            	console.log( oportunidade );
            	component.set("v.oportunidade", oportunidade);
            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},

	//Busca os produtos ativos vigentes
	buscarProdutosVigentes : function(component, segmento) {
		segmento = segmento == 'VidaGrupo' ? 'Coletivo' : 'Individual';
		let action = component.get("c.buscarProdutosComerciais");

		action.setParams({
			segmento
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
            	let produtos = [];

            	for(let produto of response.getReturnValue()){
            		produtos.push(this.gerarObjetoProdutoAccordeon(produto));
            	}
            	
            	component.set("v.produtosComerciais", produtos);
            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
       
        $A.enqueueAction(action);
	},

	//Busca produtos de acordo com as regras de configuração de oferta
	buscarProdutosSugestao : function(component) {

	},

	//Gera estrutura de objeto que o accordeon entenda
	gerarObjetoProdutoAccordeon: function(produto){
		return {
			produto: produto,
			selecionado: false,
			garantias: []
		};
	},

	//Possibilita avançar para etapa de preenchimento de campos de garantias
	avancar : function(component, event) {
		component.set("v.modoEscolha", false);
		console.log( JSON.parse( JSON.stringify( component.get("v.produtoEscolhido") ) ) );
	},

	voltar : function(component, event) {
		component.set("v.modoEscolha", true);
	},	

	salvar : function(component, event) {
		 console.log('TODO');
	},

	cancelar : function(component, event) {
		$A.get("e.force:closeQuickAction").fire();
	}
})