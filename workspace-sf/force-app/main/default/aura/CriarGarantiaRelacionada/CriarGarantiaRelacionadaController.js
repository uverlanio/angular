({  //PLV_2583 - INICIO - Ajuste na busca de coberturas no objeto "Garantia Relacionada"
    doInit: function (cmp, event, helper) {
        var queryTerm = '';
        cmp.set("v.data", null);
        //helper.pesquisaGarantias(cmp,event, helper, queryTerm);
        helper.buscaNomeGarantiaProduto(cmp, event, helper);
    },
    handleOnChange: function(component, event, helper){
        component.set("v.issearching", true);
        var queryTerm = component.get('v.search');
        helper.pesquisaGarantias(component,event,helper,queryTerm);
    },
    
    voltarBox: function (component) {
        $A.get("e.force:closeQuickAction").fire();
    },
    voltar: function (component) {
        var pagina = component.get("v.page");
    
        if(pagina == 3){
            component.set("v.nomeBotao", 'Avançar');
            component.set("v.tipoBotao", 'brand');
            component.set("v.buttonDisable", true);
        }else if(pagina == 2){
            component.set("v.buttonDisable", false);
        }
        component.set("v.page", pagina-1);
    },
    avancar: function (component, event, helper) {
        var pagina = component.get("v.page");
        if(pagina == 1){
            var radio = component.get("v.valueRadio");
            if(radio === ''){
                
            }else{
                component.set("v.page", 2);
                component.set("v.buttonDisable", true);
            }
        }else if(pagina == 3){
            
            helper.save(component, event, helper);
        }
        
    },
    savePagamento: function(component, event, helper){
        component.set("v.page", 3);
        var name = event.getSource().get("v.name");
        var idg = event.getSource().get("v.value");
        component.set("v.nomeGarantiaSelecionada", name);
        component.set("v.nomeBotao", 'Salvar');
        component.set("v.idGarantia", idg);
        component.set("v.tipoBotao", 'success');
        component.set("v.buttonDisable", false);
        helper.picklistValues(component, event);
    }
    //PLV_2583 - FIM - Ajuste na busca de coberturas no objeto "Garantia Relacionada"
})