({
    //PLV-3312 - INICIO  
    carregarGarantiasDisponiveis: function (component, event) {
        var produtoComercialId = component.get('v.recordId');
        var produtoTecnicoId = component.get('v.simpleRecord1.ProdutoTecnico__c');
		
         // ACTION
        var action_1 = component.get('c.buscarGarantiasProdutoComercial');

        // PARAMS
        action_1.setParams({
            produtoComercialId: produtoComercialId
        });
        
        action_1.setCallback(this, function (resp) {           
            if(resp.getState() == 'SUCCESS'){
                var obj = resp.getReturnValue();               
            	var arrayObj = [];
                for(var k in obj){
                    //console.log('dados santana'+ obj[k].GarantiaId);
                    arrayObj.push(obj[k].GarantiaId);
                }
                component.set('v.garantiasVinculadas',arrayObj);
                               
                //Retira da lista de disponiveis os itens que já estão vinculados
                // ACTION
                var action = component.get('c.buscarGarantiasProdutoTecnico');
                // PARAMS
                action.setParams({
                    produtoTecnicoId: produtoTecnicoId
                });  
                var garantiasVinculadas = component.get('v.garantiasVinculadas');
                //console.log('array santana'+garantiasVinculadas);
                // CALLBACK
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    console.log('state', state);
                    
                    //PLV_3046 - Inicio
                    if (state == 'SUCCESS') {
                        var data = response.getReturnValue();
                        var objd = [];
                        for (var k in data) {
                         //console.log('LOG id'+data[k].GarantiaId);
                         if (garantiasVinculadas.indexOf(data[k].GarantiaId) == -1) {
                            
                            objd.push(data[k]);
                         }else{
                             console.log("Encontrou");
                         }
                       }
        				
                        component.set('v.data', objd);
                        console.log('data dbg' ,objd);
                    
                    } else if (state == 'ERROR') {
                        alert(response.getError());
                        console.log(response.getError());
                    }
                    //PLV_3046 - Fim
                });
                // ENQUEUE ACTION
                $A.enqueueAction(action);
            }
        });        
        
        $A.enqueueAction(action_1);       
        
    },
    //PLV-3312 - FIM
    carregarGarantiasSelecionadas: function (component, event) {
        var produtoComercialId = component.get('v.recordId');
        var produtoTecnicoId = component.get('v.simpleRecord1.ProdutoTecnico__c');

        // ACTION
        var action = component.get('c.buscarGarantiasProdutoComercial');

        // PARAMS
        action.setParams({
            produtoComercialId: produtoComercialId
        });

        // CALLBACK
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state', state);
            if (state == 'SUCCESS') {
                var data = response.getReturnValue();
                var obj = [];
                for (var k in data) {
                    obj.push(_util.flatten(data[k]));
                }
                component.set('v.data2', obj);

                var idsGarantiasSelecionadas = [];

                for (var k in data) {
                    var id = data[k].GarantiaProduto__c;
                    idsGarantiasSelecionadas.push(id);
					//console.log('GarantiaProduto__c: ' + id);
                }

                var garantiasDisponiveis = component.get('v.data');
                var idsGarantiasRemover = [];
                var garantiasRemover = [];
                for (var k in garantiasDisponiveis) {
                    var obj = garantiasDisponiveis[k];
                    var id = garantiasDisponiveis[k].Id;
                    if (idsGarantiasSelecionadas.indexOf(id) != -1) {
                        idsGarantiasRemover.push(id);
                    } else {
                        garantiasRemover.push(obj);
                    }
                    //console.log('Id: ' + id);
                }

                component.set('v.data', garantiasRemover);
                console.dir(idsGarantiasRemover);

            } else if (state == 'ERROR') {
                alert(response.getError());
                console.log(response.getError());
            }
        });

        // ENQUEUE ACTION
        $A.enqueueAction(action);
    },
    
     // PLV-3450 - inicio
    salvarGarantiasSelecionadas: function (component, event) {
        
        //debugger;
        //PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
        component.set("v.isInvalid", true);
        var idsGarantiasSelecionadas = component.get('v.selectedRows');
        console.log('var ' + idsGarantiasSelecionadas);
        console.log('var2 ' + typeof idsGarantiasSelecionadas);
        var produtoComercialId = component.get('v.recordId');
        var produtoTecnicoId = component.get('v.simpleRecord1.ProdutoTecnico__c');

        idsGarantiasSelecionadas.forEach(garantia => {
            //console.dir(idsGarantiasSelecionadas);
            console.log(':: produtoComercialId: ' + produtoComercialId);
            console.log(':: produtoTecnicoId: ' + produtoTecnicoId);

            // ACTION
            var action = component.get('c.salvarGarantiasSelecionadas');

            // PARAMS
            //console.log('idsGarantiasSelecionadas');
            //console.log(idsGarantiasSelecionadas);

            //console.log('idsGarantiasSelecionadas[i]', idsGarantiasSelecionadas[i]);
            console.log('tete ', garantia);

            

            var valuefield = garantia.CurrencyIsoCode;
            var varDemonstracaoPremio =  garantia.DemonstracaoPremio; //component.get('v.data.DemonstracaoPremio__c'); //document.getElementById(idsGarantiasSelecionadas[i]).DemonstracaoPremio__c;     //PLV_3450
            console.log('valor antes: '+ valuefield);
            if(valuefield !== 'No'){

                console.log('valor antes: '+ valuefield);
                action.setParams({
                    idsGarantiasSelecionadas: garantia.id,
                    produtoComercialId: produtoComercialId,
                    produtoTecnicoId: produtoTecnicoId,
                    moeda: valuefield,
                    demonstracaoPremio: varDemonstracaoPremio   //PLV_3450
                });

                // CALLBACK
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    console.log('state', state);
                    //PLV-3160 INÍCIO
                    if (state == 'SUCCESS') {
                        var ret = response.getReturnValue();
                        console.log('handleSaveRecord-sucess', ret);
                        var action = component.get('v.action');

                        var title = 'Erro ao criar as Garantias do Produto Comercial';
                        var type = 'error';
                        var message = ret;

                        if (ret === 'SUCCESS') {

                            message = 'Garantias do Produto Comercial criadas com sucesso!';
                            type = 'success';
                            title = null;
                        }

                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            'title': title,
                            'type': type,
                            'message': message,
                            'duration': 5000
                        });

                        // Update the UI: close panel, show toast, refresh account page
                        resultsToast.fire();

                        // Reload the view so components not using force:recordData
                        // are updated
                        $A.get('e.force:refreshView').fire();
                        _util.fecharQuickAction();

                    //PLV-3160 FIM
                    } else if (state == 'ERROR') {
                        alert(response.getError());
                        console.log(response.getError());
                    }
                });

                // ENQUEUE ACTION
                $A.enqueueAction(action);
            }else{
                var Toast = $A.get("e.force:showToast");
                Toast.setParams({
                            'title': 'Atenção',
                            'type': 'info',
                            'message': 'Selecione uma moeda!!',
                            'duration': 5000
                        });

                // Update the UI: close panel, show toast, refresh account page
                Toast.fire();
            }
        });    
    },
     // PLV-3450 - fim
    removerGarantiasSelecionadas: function (component, event) {
        var idsGarantiasSelecionadas = component.get('v.selectedRows');
         //PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem

        var produtoComercialId = component.get('v.recordId');
        var produtoTecnicoId = component.get('v.simpleRecord1.ProdutoTecnico__c');

        console.dir(idsGarantiasSelecionadas);
        console.log(':: produtoComercialId: ' + produtoComercialId);
        console.log(':: produtoTecnicoId: ' + produtoTecnicoId);

        // ACTION
        var action = component.get('c.removerGarantiasSelecionadas');
		//PLV_3046 - Inicio
            // PARAMS
            action.setParams({
                idsGarantiasSelecionadas: idsGarantiasSelecionadas,
                produtoComercialId: produtoComercialId,
                produtoTecnicoId: produtoTecnicoId
            });

            // CALLBACK
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state', state);
                if (state == 'SUCCESS') {
                    var data = response.getReturnValue();
                    console.dir(data);
                    $A.get('e.force:refreshView').fire();
                    _util.fecharQuickAction();
                } else if (state == 'ERROR') {
                    alert(response.getError());
                    console.log(response.getError());
                }
            });
        //PLV_3046 - Fim

            // ENQUEUE ACTION
            $A.enqueueAction(action);
        
         //PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
    },
    //PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
    garantiasId: function(component, event){
        console.log('Teste passou aqui');
        var isChecked = event.getSource().get("v.checked");
        console.log('t ' + isChecked);
        var sapid = event.getSource().get("v.name");  
        console.log('y ' + JSON.stringify(sapid));     
        var varLstSelected = component.get("v.selectedRows");
        console.log('x ' + varLstSelected);
		if(isChecked){
            varLstSelected.push(sapid);
            component.set("v.isInvalid", false);
		}else{
			for(var i=0; i<varLstSelected.length; i++){
				if(varLstSelected[i] === sapid){
					varLstSelected.splice(i,1);
					break;
				}
            }
            if(varLstSelected.length === 0){
                component.set("v.isInvalid", true);
            }
		}
        component.set("v.selectedRows", varLstSelected);
        console.log('z ' + JSON.stringify(component.get("v.selectedRows")));
	},
    LimiteGarantiaPicklist : function (component){
        var action = component.get('c.getPickListLabelIntoList');
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log('status: ', state);
            if (state === "SUCCESS"){
                component.set('v.moedaPicklist', a.getReturnValue());
                console.log(a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
     //PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
})