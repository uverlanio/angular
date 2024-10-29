({ //PLV_2583 - INICIO - Ajuste na busca de coberturas no objeto "Garantia Relacionada"
    pesquisaGarantias : function(component, event, helper, queryTerm) {
			
        var recId = component.get('v.recordId');
        
        var action = component.get('c.pesquisaGarantiaProduto');
        
        action.setParams({
                            recordId: recId,
                            term: queryTerm
                         });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === 'SUCCESS'){
                var ret = response.getReturnValue();
                
                if(ret === null){
                    component.set("v.semgarantias", 'Nenhuma Garantia encontrada.');
                    component.set("v.data", null);
                }else{
                    component.set("v.data", ret);
                    component.set("v.semgarantias", null);
               }
            } else{
                console.log('Error, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
        component.set("v.issearching", false);
    },
    save : function(component, event, helper){
        var type;
        var message;
        
        var recId = component.get('v.recordId');
        //console.log('recId: '+ recId);
        var valueRadio = component.get('v.valueRadio');
        //console.log('valueRadio: '+ valueRadio);
        var idGarantia = component.get('v.idGarantia');
        //console.log('idGarantia: '+ idGarantia);
        var valueTipo = component.get('v.valueTipo');
        //console.log('valueTipo: '+ valueTipo);
        var acumulativa = component.get('v.acumulativa');
        //console.log('acumulativa: '+ acumulativa);
        var incremento = component.get('v.incremento');
        //console.log('incremento: '+ incremento);

        var action = component.get('c.salvarGarantias');
        
        action.setParams({
            garantiaId: recId,
            recordTyp: valueRadio, 
            GarantiaRelacionada: idGarantia, 
            tipoDependencia: valueTipo, 
            acumulativa: acumulativa, 
            incremento: incremento
        });
        
        console.log(action);
        action.setCallback(this, function(response){
            
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var ret = response.getReturnValue();
                //console.log('id: '+ ret);
                if(ret === 'Sucesso'){
                    type = 'success';
                    message = 'A Garantia Relacionada foi criado(a) com sucesso.';
                }else{
                    type = 'error';
                    message = ret;
                }
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    'type' : type,
                    'message': message,
                    'duration': 5000
                });
                
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
                resultsToast.fire();
                
            } else{
                console.log('Error, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    buscaNomeGarantiaProduto : function(component, event, helper){
        
        var recId = component.get('v.recordId');
        
        var action = component.get('c.buscaNomeGarantiaProduto');
        
        action.setParams({recordId: recId});
        
        action.setCallback(this, function(response){
            
            var state = response.getState();
            
            if(state === 'SUCCESS'){
                var ret = response.getReturnValue();
                
                component.set("v.nomeGarantia", ret);
                console.log('ret: ', ret);
            }else{
                console.log('Error, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    picklistValues: function(component, event) {
        var action = component.get('c.getPickListLabelIntoList');
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log('status: ', state);
            if (state === "SUCCESS"){
                component.set('v.optionsList', a.getReturnValue());
                console.log(a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
    //PLV_2583 - FIM - Ajuste na busca de coberturas no objeto "Garantia Relacionada"
})