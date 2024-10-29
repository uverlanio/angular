({
    validapreenchimentos : function(component, event, helper) {
        var recId = component.get('v.recordId');
        var action = component.get('c.validarpreenchimento');
        action.setParams({recordId: recId});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === 'SUCCESS') {
                var ret = response.getReturnValue();                
                
                if(ret[0] != 'Todos os campos foram preenchidos'){
                    component.set("v.msg", response.getReturnValue());
                    component.set("v.tela", '1');
                }
                helper.toggleSpinner(component);
                var footer = component.find("footer");
                var header = component.find("header");
                $A.util.removeClass(header, "slds-hide");
                $A.util.addClass(header, "slds-show");
                $A.util.removeClass(footer, "slds-hide");
                $A.util.addClass(footer, "slds-show");
                
                if(ret[0] === 'Todos os campos foram preenchidos'){
                    component.set('v.tela', '2');
                }
                
            } else {
                console.log('Error, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
        
    },

    avancarTela : function(component, event, helper){
        var tela = component.get('v.tela');
        if(tela == '2') {
            var tipoEvento = component.get("v.tipoEventoEscolhido");
            if(tipoEvento == ""){
                var mMessage = component.get('v.mMessage');
                if(!mMessage.error.includes('Selecione um tipo de evento antes de avançar.')){
                    mMessage.error.push('Selecione um tipo de evento antes de avançar.');
                    component.set('v.mMessage', mMessage);
                }
            }
            else{
                var recId = component.get('v.recordId');
                helper.pesquisacontratos(component, event, helper, recId, tipoEvento);
            }

        }
        else if(tela == '3') {
            var garantias = component.get("v.garantiaSelected");
            var garantiaSelectedPrices = component.get('v.garantiaSelectedPrices'); //PLV-4176 FIX 3
            var mMessage = component.get('v.mMessage');
            console.log('garantiaSelectedPrices',garantiaSelectedPrices);
            //PLV-4938 - INICIO
            let listadados = component.get('v.listadados');
            let garantiasSelecionadas = {}
            for(let i in listadados){
                let item = listadados[i];
                if(item.selecionado)
                    garantiasSelecionadas[item.sigla] = item;
            }
            //PLV-4789 INICIO
            var inputsValor = [];
            var inputsValorSelecionados = [];
            
            /*inputsValor = inputsValor.concat();
            
            inputsValor.forEach(input => {
                let sigla = input.name.split('--')[0]
                if ((!input.get('v.disabled') && !input.get('v.value')) && garantiasSelecionadas[sigla].exibircampo==true) {
                    inputsValorSelecionados.push(input);
                }
            }) */

            if (inputsValorSelecionados.length > 0) {
                if(!mMessage.error.includes('Todas as garantias selecionadas devem possuir um valor.')){
                    mMessage.error.push('Todas as garantias selecionadas devem possuir um valor.');
                    component.set('v.mMessage', mMessage);
                }
            } else if (garantias.length > 0){
            //PLV-4789 FIM
                helper.toggleSpinner(component);
                component.set("v.tela", '0');
                //PLV-4176 FIX 3
                helper.validaDuplicados(component, helper, garantias, garantiaSelectedPrices); //PLV-3914 - INICIO/FIM, PLV-4176 adicioonado parâmentro garantiasPrices
                //helper.prossegueCriacaoSinistro(component, helper, garantias); //PLV-3914 - INICIO/FIM
            }else{
                if(!mMessage.error.includes('Selecione uma garantia antes de avançar.')){
                    mMessage.error.push('Selecione uma garantia antes de avançar.');
                    component.set('v.mMessage', mMessage);
                }
            }
        }
         //PLV-3914 - INICIO
        else if(tela == '4'){
            var garantias = component.get("v.garantiaSelected");
            var garantiasPrices = component.get("v.garantiaSelectedPrices");
            var mMessage = component.get('v.mMessage');
            if (garantias.length > 0){
                helper.toggleSpinner(component);
                component.set("v.tela", '0');
                helper.prossegueCriacaoSinistro(component, helper, garantias, garantiasPrices);
            }
        }
        //PLV-3914 - FIM
    },
    
    toggleSpinner : function(component){
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },

    pesquisacontratos : function(component, event, helper, recId, tipoEvento) {
        var action = component.get('c.pesquisacontratos');
        
        action.setParams({
            recordId: recId,
            tipoEvento: tipoEvento
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //PLV-4938 - INICIO
            if (state === 'SUCCESS') {
                var ret = JSON.parse(response.getReturnValue());
                
                if(ret.retorno && ret.retorno == 'Sem segurado') {
                    component.set("v.semgarantias", 'Não localizado nenhum seguro para a conta informada');
                    component.set("v.tela", '3');
                    
                }
                else if(ret.retorno && ret.retorno == 'Sem vigencia') {
                    component.set("v.semgarantias", 'Não localizado nenhum seguro vigente para a data de ocorrência informada');    
                    component.set("v.tela", '3');
                }
                else if(ret.retorno && ret.retorno == 'Sem garantia'){
                    component.set("v.semgarantias", 'Não localizada nenhuma garantia para o tipo de evento informado.');    
                    component.set("v.tela", '3');
                }
                else {   
                    var Json = ret.garantias;
                    //PLV-4789 FIX 1 INICIO
                    //PLV-4499 - INICIO
                    Json = Array.from(new Set(Json.map(a => a.sigla)))
                    .map(sigla => {
                    return Json.find(a => a.sigla === sigla)
                    }) 
                                        
                    //Esta Lógica foi enviada para o back-end
                    /*
                    for(var i=0; i<Json.length; i++){                        
                        var tipoPagtoGarantia = Json[i].tipopagamento.split(';');                        
                        if(tipoPagtoGarantia.includes('Diária') || tipoPagtoGarantia.includes('Renda')){                                                        
                            Json[i].LiberarDiasFranquia = true; 
                            Json[i].RotuloCampo = 'Dias';                                                       
                        }else{
                            Json[i].LiberarDiasFranquia = false;
                            Json[i].RotuloCampo = 'Valor';                            
                        }                                            
                    }
                    */                   
                    //PLV-4499 - FIM
                    component.set("v.mostrarMais", Json);
                    
                    var garantias = component.get("v.mostrarMais");                    
                    var sliced = Json.slice(0, 5);                                       
                    //PLV-4789 FIX 1 FIM
                    component.set("v.listadados", sliced);                    

                    component.set("v.semgarantias", null);
                    component.set("v.tela", '3');
                    //component.set("v.listadados", Json);
                    
                    if(garantias.length <= 5){
                        var button = component.find("mostrarMaisButton");
                        component.set("v.HSButton", "slds-hide");
                    }                      
                    console.log('sliced)',sliced);                                        
                }                                
            } else {
                console.log('Error, response state: ' + state);
                component.set("v.tela", '3');
            }            
            //PLV-4938 - FIM
        });
        $A.enqueueAction(action);
    },

    //PLV-4938 - INICIO
    selecionaCheckbox : function(component, event, helper){
        console.log('component',component);
        let current = event.currentTarget
        let valor = current.dataset.value
        let checked = event.currentTarget.checked
        let selecionados = component.get('v.garantiaSelected');

        let listadados = component.get("v.listadados");
        let siglagarantia = valor.split('--')[0];
        let selecionadosPrices = component.get('v.garantiaSelectedPrices');

        let items = [];
        items = items.concat(component.find("garantiasprices"));

        if(checked){
            if(!selecionados.includes(valor)){
                selecionados.push(valor);               
            }
        }
        else{
            let index = selecionados.indexOf(valor);
            if (index > -1) {
                selecionados.splice(index, 1);
            }
            //PLV-4176 - inicio
            let index2 = selecionadosPrices.map(function(e) { return e.valor; }).indexOf(valor);
            if (index2 > -1) {
                selecionadosPrices.splice(index2, 1);
            }            
            //PLV-4176 - fim  
            console.log('selecionadosPrices',selecionadosPrices);  
        }
        for(let i in listadados){
            if(listadados[i].sigla==siglagarantia)
                listadados[i].selecionado= checked==true || false;
        }
        console.log('listadados',[].concat(listadados));  
        component.set("v.listadados",[].concat(listadados));
    },
    //PLV-4938 - FIM
    //PLV-4176 - inicio
    selecionaPrice : function(component, event, helper){
        var opcao = event.getSource();
        var valor = opcao.get('v.name');
        var price = opcao.get('v.value');
        var selecionados = component.get('v.garantiaSelectedPrices');
        
        var index = selecionados.map(function(e) { return e.valor; }).indexOf(valor);
        
        console.log('price',price);
        
        if(index != null){           
            if (index > -1) {
                selecionados.splice(index, 1);
            }
            selecionados.push({valor,price});
        }else{
            selecionados.push({valor,price});
        }
        console.log('AA',{valor,price});
        console.log('selecionadosPrices',selecionados);
    },
    //PLV-4176 - fim    
    
    mostrarMaiss : function(component, event, helper){
        
        var mostrarMais = component.get("v.mostrarMais");
        var resultGarantia = component.get("v.resultGarantia");
        var resultGarantia = resultGarantia+5;
        var sliced = mostrarMais.slice(0,resultGarantia);

        component.set("v.resultGarantia", resultGarantia);          
        
        if(sliced.length >= mostrarMais.length){
            component.set("v.HSButton", "slds-hide");
        }
        
        try { 
            component.set("v.listadados", sliced);
        } 
        catch(e) 
        { 
            //component.set('v.mostrarMais', mostrarMais); 
        }
    },

    mostrarMaissCasos : function(component, event, helper){
        
        var mostrarMais = component.get("v.mostrarMaisCasos");
        var resultCasos = component.get("v.resultCasos");
        var resultCasos = resultCasos+5;
        var sliced = mostrarMais.slice(0,resultCasos);

        component.set("v.resultCasos", resultCasos);         
        
        if(sliced.length >= mostrarMais.length){
            component.set("v.HSButtonCasos", "slds-hide");
        }
        try { 
            component.set("v.LstWrapperCw", sliced);
        } 
        catch(e) 
        { 
            //component.set('v.mostrarMais', mostrarMais); 
        }
        
    },

    prossegueCriacaoSinistro : function (component, helper, garantias,garantiasPrices){
        var tipoEvento = component.get('v.tipoEventoEscolhido');
        var recId = component.get('v.recordId');
        
        var action = component.get('c.criaCasoSinistro');
        action.setParams({
            recordId: recId,
            garantias: garantias,
            tipoEvento: tipoEvento,
            garantiasPrices : JSON.stringify(garantiasPrices), //PLV-4176
            garantiasarray : JSON.stringify(component.get('v.listadados')) //PLV-4176
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    'type' : 'success',
                    'message': 'Caso(s) criado(s) com sucesso.'
                });
                
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
                resultsToast.fire();
                
            }else {
                console.log('Error, response state: ' + state);
                helper.toggleSpinner(component);
                component.set("v.tela", 'error');
                component.set('v.mMessage', '');
            }
        });
        $A.enqueueAction(action);
    },
    
    //PLV-3914 - INICIO, PLV-4176 adicionado parametro garantiasPrices
    validaDuplicados : function (component, helper, garantias, garantiasPrices){
        var tipoEvento = component.get('v.tipoEventoEscolhido');
        var recId = component.get('v.recordId');
        var garantiasPricesString = JSON.stringify(garantiasPrices); //PLV-4176
        
        var action = component.get('c.validarSinistroDuplicado');
        action.setParams({
            recordId: recId,
            tipoEvento: tipoEvento
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                var ret = response.getReturnValue();
                
                if(ret == null){
                    helper.toggleSpinner(component);
                    var tipoEvento = component.get('v.tipoEventoEscolhido');
                    var recId = component.get('v.recordId');
                    
                    var action2 = component.get('c.criaCasoSinistro');
                    action2.setParams({
                        recordId: recId,
                        garantias: garantias,
                        tipoEvento: tipoEvento,
                        garantiasPrices: garantiasPricesString //PLV-4176
                    });

                    action2.setCallback(this, function(response){
                        var state = response.getState();
                        if(state === 'SUCCESS'){
                            var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                'type' : 'success',
                                'message': 'Caso(s) criado(s) com sucesso.'
                            });
                            
                            $A.get("e.force:closeQuickAction").fire();
                            $A.get("e.force:refreshView").fire();
                            resultsToast.fire();
                            
                        }else {
                            console.log('Error, response state: ' + state);
                            helper.toggleSpinner(component);
                            component.set("v.tela", 'error');
                            component.set('v.mMessage', '');
                        }
                        helper.toggleSpinner(component);
                    });
                    $A.enqueueAction(action2);

                }else{
                              
                    //var Json = JSON.parse(ret); 
                    console.log('var Json: ', ret);                   
                    component.set("v.CasosDuplicados", ret);
                    component.set("v.tela", '4');                    
                }
            } else {
                console.log('Error, response state: ' + state);
                component.set("v.tela", '4');
            }
            helper.toggleSpinner(component);
        });
        $A.enqueueAction(action);
    },
    //PLV-3914 - FIM    
})