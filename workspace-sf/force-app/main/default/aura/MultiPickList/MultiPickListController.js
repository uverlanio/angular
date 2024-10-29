({  
    
	//Abre a lista contendo os valores a serem escolhidos
    abrirLista: function(component, event, helper){
        helper.abrirLista(component, event);
    },

    //Fecha lista de valores
    fecharLista: function(component, event, helper){
        helper.fecharLista(component, event);
    },

    //Seleciona os valores
    selecionar: function(component, event, helper){
        helper.selecionar(component, event);
    }
})