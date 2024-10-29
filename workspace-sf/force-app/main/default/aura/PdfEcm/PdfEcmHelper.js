({
	buscarDadosLink : function(component, event) {
	    let action = component.get("c.buscarDominioSf");

	    action.setCallback(this, (response) => {
	      let state = response.getState();

	      if(state == "SUCCESS"){
	        component.set('v.dominio', response.getReturnValue());
	        //this.buscarCodigoDocumento(component, event);

	      } else if(state == "ERROR"){
	        console.log(response.getError());
	        alert('Error in calling server side action buscarDadosLink: ' + response.getError());
	        $A.get("e.force:closeQuickAction").fire();
	      }
	    });

	    $A.enqueueAction(action);
	},

	buscarCodigoDocumento : function(component, event) {
	    let action = component.get("c.buscarCodigoEcmDocumento");

	    action.setParams({
	      objetoId : component.get("v.recordId")
	    });

	    action.setCallback(this, (response) => {
	      let state = response.getState();

	      if(state == "SUCCESS"){
	      	let codigo = response.getReturnValue();

	      	if(codigo){
	      		component.set('v.codigoDoc', response.getReturnValue());	
	      		component.set('v.linkgerado', true);
	      	}
	      	else{
	      		alert('Código do documento não encontrado');
	      		$A.get("e.force:closeQuickAction").fire();
	      	}

	      } else if(state == "ERROR"){
	        console.log(response.getError());
	        alert('Error in calling server side action buscarCodigoDocumento: ' + response.getError());
	        $A.get("e.force:closeQuickAction").fire();
	      }
	    });

	    $A.enqueueAction(action);
	}
})