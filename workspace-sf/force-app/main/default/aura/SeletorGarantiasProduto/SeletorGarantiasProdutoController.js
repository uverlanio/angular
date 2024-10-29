({
	inicializar : function(component, event, helper) {
		
	},
	recordUpdated : function(component, event, helper) {
		var changeType = event.getParams().changeType;
		if (changeType === 'ERROR') {
			console.log('ERROR');
		}
		else if (changeType === 'LOADED') {
			console.log('LOADED');
			//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
			helper.LimiteGarantiaPicklist(component);
			//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
			helper.carregarGarantiasDisponiveis(component, event);
		}
		else if (changeType === 'REMOVED') {
			console.log('REMOVED');
		}
		else if (changeType === 'CHANGED') { 
			console.log('CHANGED');
		/* handle record change; reloadRecord will cause you to lose your current record, including any changes you’ve made */ 
			component.find('forceRecord').reloadRecord();
		}
	},
    handleSelect: function(component, event, helper) {
		// atualiza o nome da aba selecionada
		console.log('Passou aqui');
        component.set('v.abaSelecionada', event.getParam('id'));

        var abaSelecionada = component.get('v.abaSelecionada');
      
        if (abaSelecionada == 'disponiveis') {            
			//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
			helper.carregarGarantiasDisponiveis(component, event);
			//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
            component.set('v.buttonVariant', 'brand');
            component.set('v.buttonLabel', 'Selecionar');
        }
		else if(abaSelecionada == 'selecionadas') {
			//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
			helper.carregarGarantiasSelecionadas(component, event);
			//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
            component.set('v.buttonVariant', 'destructive');
            component.set('v.buttonLabel', 'Remover');
        }

        component.set('v.selectedRows', []);
        // cmp.set('v.selectedRows', cmp.get('v.selection'));
        // var sel = component.get('v.selectedRows');
        component.set('v.isInvalid', true);
    },
	onRowSelection: function(component, event, helper) {
		console.log('Passou aqui 2');
	    component.set('v.selectedRows', event.getParam('selectedRows'));
	    var sel = component.get('v.selectedRows');
	    component.set('v.isInvalid', (sel.length == 0)); 
	},
	cancelar: function(component, event, helper) {
		_util.fecharQuickAction();
	},
	fechar: function(component, event, helper) {
		_util.fecharQuickAction();
	},
	//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
	checkChange: function(component, event, helper){
		helper.garantiasId(component, event);
	},
	//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
	selecionar: function(component, event, helper) {
		console.log('Passou aqui 3');
        var abaSelecionada = component.get('v.abaSelecionada');
        if (abaSelecionada === 'disponiveis') {
			//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
            helper.salvarGarantiasSelecionadas(component, event);
        }
        else if(abaSelecionada === 'selecionadas'){
			helper.removerGarantiasSelecionadas(component, event);
			//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
        }
	}
})