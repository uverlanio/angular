/**
 * Created by Fábio Rente on 17/04/2019.
 */

({
	reenviarPagamento : function(component,event) {
    let action = component.get('c.reenviarPagamento');

    action.setParams({
      idPagamento : component.get('v.recordId')
    });

    action.setCallback(this, function(response){
      let state = response.getState();
      console.log(state);
      if(state === 'SUCCESS'){
        component.find("cmpModalAcaoBotao").callback(response);
        
        setTimeout(() => $A.get('e.force:refreshView').fire(), 3000);

      }else{
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " +
                errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });

    $A.enqueueAction(action);
  }
})