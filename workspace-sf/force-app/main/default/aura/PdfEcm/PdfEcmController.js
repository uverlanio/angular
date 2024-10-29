({
	inicializar : function(component, event, helper) {
		console.log('Rodei o inicializar do componente que baixa o arquivo!');
		helper.buscarDadosLink(component, event);
	}
})