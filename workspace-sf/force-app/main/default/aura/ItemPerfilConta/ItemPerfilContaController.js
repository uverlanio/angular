({
	inicializar: function(component, event, helper) {
		helper.inicializar(component, event);
		helper.preencherBancoEscolhido(component, event);
	},

	exibirCampos : function(component, event, helper) {
		helper.exibirCampos(component);
	},

	atualizarListaPapeis : function(component, event, helper) {
		helper.atualizarListaPapeis(component, event);	
	},

	excluir: function(component, event, helper) {
		helper.excluir(component);
	},

	insereBancoEscolhido : function (component, event, helper) {
		console.log('papel');
		let index = component.get("v.idx");
		let papeisConta = component.get("v.papeisConta");
		let skip = true;
		for(let i = 0; i < papeisConta.length; i++){
            if(papeisConta[i].idx == index){
				if(papeisConta[i].bancoEscolhido == null)
					skip = false;
            }           
        }    

		if(!skip){
			console.log('entrando');
			component.set("v.iniciando", false);
			helper.insereBancoEscolhido(component);
		}
	}
})