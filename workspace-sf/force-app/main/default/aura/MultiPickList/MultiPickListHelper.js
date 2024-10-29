({
    //Abre a lista contendo os valores a serem escolhidos
	abrirLista : function(component, event) {
		let divListBox = component.find("divListBox");
        $A.util.removeClass(divListBox, 'opcoes-combo');
        //$A.util.toggleClass(listaOpcoesCombo, "opcoes-combo");
	},

    //Fecha lista de valores
	fecharLista : function(component, event) {
		let divListBox = component.find("divListBox");
		$A.util.addClass(divListBox, 'opcoes-combo');
	},

    //Seleciona os valores
	selecionar: function(component, event){
		let opcoes = component.get("v.opcoes");
        let acao = component.get("v.acaoOnChange");
        let item = event.currentTarget;
        let valor = item.dataset.value;
        let selecionado = item.dataset.selected;

        //Varrea array e marca/desmarca as opções escolhidas
        opcoes.forEach((element) => {
            if (element.value == valor) {
                element.selected = selecionado == "true" ? false : true;
            }
        });

        //Atualiza lista de opções
        component.set("v.opcoes", opcoes);

        //Atualiza valor (input)
        this.atualizarValor(component, event);

        //Caso seja passada alguma ação ao selecionar, disparar
        if(acao.dispararAcao){
            acao.dispararAcao(acao.component, component.get("v.valor"));
        }
	},

    //Atualiza o atributo responsavel de valor, com os valores selecionados
	atualizarValor: function(component, event){
		let opcoes = component.get("v.opcoes");
		let valores = '';

        //Concatena valores escolhidos
		opcoes.forEach((element) => {
            if (element.selected) {
                valores += element.value + ';';
            }
        });

        component.set("v.valor", valores);
	}
})