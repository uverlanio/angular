({
	inicializar : function(component, event) {
		var options = [
            { value: "Agenciador", label: "Agenciador" },
            { value: "Corretor", label: "Corretor" },
            { value: "Parceiro", label: "Parceiro" },
            { value: "Prestador", label: "Prestador" },
            { value: "Segurado", label: "Segurado" },            
            { value: "Representante de Seguros", label: "Representante de Seguros" }
        ];

        component.set("v.papelOptions", options);   
                
    },

    preencherBancoEscolhido : function(component, event){
        let index = component.get("v.idx");
        let papeisConta = component.get("v.papeisConta");
        console.log('papeisConta.length ' + papeisConta.length);
        let objBanco = {};
        //Identifica o item a ser excluido
        
        for(let i = 0; i < papeisConta.length; i++){
            if(papeisConta[i].idx == index){
                objBanco = papeisConta[i].bancoEscolhido;
            }           
        }   
        
        console.log('log 2');
        component.set("v.bancoEscolhido", objBanco);
        console.log(component.get("v.bancoEscolhido"));
    },

    atualizarListaPapeis : function(component, event){
        component.set("v.papeisConta", component.get("v.papeisConta"));
    },

    exibirCampos : function(component) {
        let trForm = component.find("trForm");
        $A.util.toggleClass(trForm, "invisivel");
        console.log(component.get("v.papeisConta"));
        console.log(component.get("v.bancoEscolhido"));
    },	

    excluir : function(component) {
		let index = component.get("v.idx");
        let papeisConta = component.get("v.papeisConta");

        //Identifica o item a ser excluido
        for(let i = 0; i < papeisConta.length; i++){
            if(papeisConta[i].idx == index){
                this.excluirPapelContaSalesforce(component, papeisConta[i]);
                papeisConta.splice(i, 1);
            }           
        }               

        //Sobreescreve lista pai
        component.set("v.papeisConta", papeisConta);
	},

    excluirPapelContaSalesforce: function(component, papelExcluir){
        let action = component.get("c.excluirPapel");

        action.setParams({
            contaId: papelExcluir.conta.Id,
            papel: papelExcluir.papel
        });

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
                //$A.get('e.force:refreshView').fire();
            }
            else{
                console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
    },

    insereBancoEscolhido : function(component){
        let index = component.get("v.idx");
        let papeisConta = component.get("v.papeisConta");
        console.log('log 3');

        //Identifica o item a ser excluido
        for(let i = 0; i < papeisConta.length; i++){
            if(papeisConta[i].idx == index){
                papeisConta[i].bancoEscolhido = component.get("v.bancoEscolhido");
            }           
        }               
        //Sobreescreve lista pai
        component.set("v.papeisConta", papeisConta);
        console.log(component.get("v.papeisConta"));
    }
})