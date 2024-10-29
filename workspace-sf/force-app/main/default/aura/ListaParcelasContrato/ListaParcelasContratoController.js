({
	init : function(component, event, helper) 
	{	
		//PLV-3869 - INICIO - PEDRO AUGUSTO -SYS4B
		//helper.obterParcelas(component);
		helper.getCanEditHelper(component);
		//PLV-3869 - FIM - PEDRO AUGUSTO -SYS4B
	},

    editarParcela : function (component, event, helper) {

		// Recupera a parcela selecionada
		let indiceParcela = event.getSource().get('v.value');
		let listParcelas = component.get('v.lstParcelas');
		let parcela = listParcelas[indiceParcela];

		// Abre o componente de edicao de parcela
		let modal = component.find('edicaoParcela');
        modal.set('v.ehVisivel',true);
        modal.set('v.parcela',parcela);
        modal.popularSelect();

    },

    atualizarComponente : function (component, event, helper) {
        helper.obterParcelas(component);
    }
})