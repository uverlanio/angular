({
    inicializar : function(component, event, helper) {
        var idProduto = component.get('v.recordId');

        // ACTION
        var action = component.get('c.buscarParametrosVigencia');

        // PARAMS
        action.setParams({
            idProduto: idProduto
        });

        // CALLBACK
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state == 'SUCCESS') {
                // component.set('v.idParametroVigencia', 'a0T1F000000Ti3QUAS');
                component.set('v.data', response.getReturnValue());
            }
            else if (state == 'ERROR') {
                console.log(response.getError());
            }
        });

        // ENQUEUE ACTION
        $A.enqueueAction(action);
    },
    cancelar: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    fechar: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    selecionar: function(component, event, helper) {
        var parametroSelecionado = component.get('v.selectedRows')[0];
        var idProdutoComercial = component.get('v.recordId');

        // ACTION
        var action = component.get('c.clonarParametroVigencia');

        // PARAMS
        action.setParams({
            idProdutoComercial: idProdutoComercial,
            idParametroVigencia: parametroSelecionado.Id
        });

        // CALLBACK
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);

            if (state == 'SUCCESS') {
                $A.get('e.force:refreshView').fire();
                var sObjectEvent = $A.get('e.force:navigateToSObject');
                sObjectEvent.setParams({
                    'recordId': response.getReturnValue()
                })
                sObjectEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else if (state == 'ERROR') {
                console.log(response.getError());
            }
        });

        // ENQUEUE ACTION
        $A.enqueueAction(action);

        // $A.get("e.force:closeQuickAction").fire();
    },
    recordUpdated: function(component, event, helper) {
        alert(event.getSource());
        // alert(component.get('v.simpleRecord1').Name);
    },
    onRowSelection: function(component, event, helper) {
        component.set('v.isInvalid', false);
        component.set('v.selectedRows', event.getParam('selectedRows'));
        var linhas = component.get('v.selectedRows');
        component.set('v.idParametroVigencia', linhas[0].Id);
    }
})