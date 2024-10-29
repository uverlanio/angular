/**
 * Created by Alessndro Ponte on 21/01/2019.
 */
({
    requestFromServer: function(component, methodController, params, callback)
    {
        $A.util.removeClass(component.find("mySpinner2"), "slds-hide");
        var action = component.get(`c.${methodController}`);

        if(params){
            action.setParams(params);
        }

        action.setCallback(this, function(response){

            var state = response.getState();
            console.log('state',state);
            if(component.isValid() && state === 'SUCCESS')
            {
                if(callback){
                    callback(response.getReturnValue());
                }

            }
            // Se ocorrer algum erro, exibe mensagem
            else {
                this.showToast('Erro!', 'Ocorreu um erro inesperado!', 'error');
            }

            $A.util.addClass(component.find("mySpinner2"), "slds-hide");
        });

        // Faz a chamada
        $A.enqueueAction(action);
    },

    atualizarComponentEvent: function(component){

        let atualizou = component.get('v.atualizou');
        component.set('v.atualizou',!atualizou);

    },

    showToast: function(titulo, msg, tipo)
    {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent == null)
            return;

        toastEvent.setParams({
            'title': titulo,
            'message': msg,
            'type': tipo
        });
        toastEvent.fire();
    },
})