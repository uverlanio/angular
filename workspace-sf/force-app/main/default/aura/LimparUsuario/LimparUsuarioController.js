({
	doInit: function (component, event, helper) {
        helper.Init(component);
    },
	selectTodos: function (component, event, helper) {
        let retorno = component.get('v.retorno')
        let valor = event.currentTarget.dataset.selecionado == "false" ? true : false;
        let tipo = event.currentTarget.dataset.tipo;
        if(tipo=='reg'){
            for(let x in retorno.opcoesRegistro){
                retorno.opcoesRegistro[x].selected = valor;
            }
            component.set('v.selreg',valor)

        }
        if(tipo=='doc'){
            for(let x in retorno.opcoesDocumento){
                retorno.opcoesDocumento[x].selected = valor;
            }
            component.set('v.seldoc',valor)
        }
        component.set('v.retorno',retorno);
    },

    confirmar : function(component, event, helper) {
		component.set('v.showConfirmDialog', true);
		component.set('v.tipoConfirm', 'salvar');
		component.set('v.confirmDialogMessage', 'Apagar os registros da organização?');
	},
    handleConfirmDialogNo: function (component, event, helper) {
		component.set('v.showConfirmDialog', false);
		component.set('v.tipoConfirm', '');
	},

    handleConfirmDialogYes: function (component, event, helper) {
		component.set("v.showSpinner", true);
		component.set('v.showConfirmDialog', false);
		component.set('v.tipoConfirm', '');
		
		helper.apagar(component);
	},
    toggleSimulado: function (component, event, helper) {
		let retorno = component.get("v.retorno");
		retorno.simular = retorno.simular == true ? false : true;
		component.set('v.retorno', retorno);
	},

})