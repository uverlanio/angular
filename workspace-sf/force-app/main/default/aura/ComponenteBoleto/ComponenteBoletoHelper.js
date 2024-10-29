//PLV - 4572 GUSTAVO DA SILVA PEREIRA SYS4B - INICIO

({
    toggleSpinner : function (component)
    {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
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
    
    requestFromServer: function(component, controller, setter, params)
    {
        console.log(component);
        console.log(controller);
        console.log(setter);
        console.log(params);
        
        var action = component.get(controller);
        
        console.log(action);
        if(params)
            action.setParams(params);
        
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               var retorno = response.getReturnValue();
                               
                               console.log(state);
                               console.log(retorno);
                               
                               
                               if(component.isValid() && state === 'SUCCESS')
                               {
                                   if(retorno.length > 0){
                                       console.error('lenght > 0');
                                       component.set('v.mostrar',true);
                                       component.set(setter, retorno.sort(this.compare));
                                   }else{
                                       console.error('lenght = 0');
                                       component.set('v.mostrar',false);
                                   }
                                   
                               }
                               else// Se ocorrer algum erro, exibe mensagem
                               {
                                   this.showToast('Erro!', 'Ocorreu um erro inesperado!', 'error');
                               }
                               
                               $A.util.addClass(component.find("mySpinner"), "slds-hide");
                           });
        
        // Faz a chamada
        $A.enqueueAction(action);
    },
    
    compare : function(a,b)
    {
        if(parseInt(a.parcela) < parseInt(b.parcela)) return -1;
        if(parseInt(a.parcela) > parseInt(b.parcela)) return 1;
        return 0;
    },
    
    obterBoletos : function(component)
    {
        this.toggleSpinner(component);
        var recordId = component.get('v.recordId');
        console.log(recordId);
        this.requestFromServer(	component, 'c.BoletoToComponent', 'v.lstBoleto', {'id': recordId});
    },
    
})
//PLV - 4572 GUSTAVO DA SILVA PEREIRA SYS4B - FIM