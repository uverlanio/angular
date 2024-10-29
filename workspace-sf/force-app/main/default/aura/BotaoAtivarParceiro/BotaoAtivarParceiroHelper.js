/**
 * Created by Alessndro Ponte on 19/09/2018.
 */
({
  ativarParceiro : function(component,event) {
    let action = component.get('c.ativarParceiro');

    action.setParams({
      idParceiro : component.get('v.recordId')
    });

    action.setCallback(this, function(response){

      let state = response.getState();
      console.log(state);
      if(state === 'SUCCESS'){
        component.find("cmpModalAcaoBotao").callback(response);
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