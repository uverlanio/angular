({
	consultapagamento : function(component, event, helper) {
        var recId = component.get('v.recordId');
        var action = component.get('c.consultapagamentos');
        action.setParams({recordId: recId});
    
    	action.setCallback( null, function(callbackResult) {
        if(callbackResult.getState()=='SUCCESS') {
            var obj = JSON.parse(callbackResult.getReturnValue());
            
			component.set("v.url", window.location.origin);
			var newlst =[];
            
            for(let i in obj)
            {
                var space = obj[i].idconta;
             	newlst.push(space);  
            }
            helper.getAccName(component, event, helper, newlst, obj);

        }else{
           //alert('erro de conexão');
           var icone = component.find("icone-error");
           $A.util.removeClass(icone, "slds-hide");
           $A.util.addClass(icone, "slds-show");
        }
    });

    $A.enqueueAction( action );
	},
    
    cancelarpagamento : function(component, event, helper) {
       var idregistro = event.target.id;
       var idbeneficiario = event.target.value;
       
       var action = component.get('c.cancelapagamentos');
       action.setParams({recordId: idregistro});
       action.setCallback( null, function(callbackResult) {
            
       if(callbackResult.getState()=='SUCCESS') {
  		  var toastEvent = $A.get("e.force:showToast");
       	  toastEvent.setParams({
          title : 'Sucesso',
          message: 'O pagamento foi cancelado com sucesso',
          messageTemplate: '',
          duration:' 7000',
          key: 'info_alt',
          type: 'success',
          mode: 'pester'
        });
        toastEvent.fire();
        
        //Sempre que for realizado um cancelamento do pagamento, 
        //alterar o status do beneficiário em questão para o status "Pendente".
        
        helper.mudastatusbeneficiarios(component,event,helper,idbeneficiario);
                       
        }else{
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Erro',
            message:'Erro de conexão, tente novamente ou contate o adminstrador do sistema',
            messageTemplate: '',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire(); 
        }
    });
    $A.enqueueAction( action );
   },
    
   getAccName : function(component, event, helper, newlst, obj) {
        var action = component.get('c.retornanomeConta');
        action.setParams({recordId: newlst});
    	action.setCallback( null, function(callbackResult) {
        if(callbackResult.getState()=='SUCCESS') {
  		   var idacc = callbackResult.getReturnValue();
           idacc.NewField = 'nomeconta';
           for(let i in obj)
           {
             for(let j in idacc)
             {
               if(obj[i].idconta == idacc[j].Id)
	           { 
                  obj[i].nomeconta = idacc[j].Name;
               } 
             }
            }
            component.set("v.pagamentos",obj);
        }   
        if(callbackResult.getState()=='ERROR') {
        console.log('ERROR', callbackResult.getError() ); 
    }
    });

    $A.enqueueAction( action );
        
	},
    
    mudastatusbeneficiarios : function(component, event, helper, idben)
    {
        console.log('idben');
        console.log(idben);
        //mudar status do beneficiario para pendente
        
        var action = component.get('c.mudastatusbeneficiario');
        action.setParams({recordId: idben});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === 'SUCCESS') {
               // console.log(callbackResult.getReturnValue());
            }else {
                console.log('ERROR', callbackResult.getError() );
            }
        });
        $A.enqueueAction(action);
        $A.get("e.force:refreshView").fire();
        
    },
      

    
})